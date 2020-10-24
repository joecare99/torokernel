//
// VirtIOVSocket.pas
//
// This unit contains code for the VirtIOVSocket driver.
//
// Copyright (c) 2003-2020 Matias Vara <matiasevara@gmail.com>
// All Rights Reserved
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

unit VirtIOVSocket;

interface

{$I ..\Toro.inc}

{$IFDEF EnableDebug}
       //{$DEFINE DebugVirtioFS}
{$ENDIF}

uses
  {$IFDEF EnableDebug} Debug, {$ENDIF}
  Arch, VirtIO, Console, Network, Process, Memory;

type
  PVirtIOVSocketDevice = ^TVirtIOVSocketDevice;

  TVirtIOVSocketDevice = record
    IRQ: LongInt;
    Base: QWORD;
    VirtQueues: array[0..2] of TVirtQueue;
    GuestId: QWORD;
    Driverinterface: TNetworkInterface;
  end;

const
  VIRTIO_ID_VSOCKET = 19;
  FRAME_SIZE = 1526;
  VIRTIO_VSOCK_MAX_PKT_BUF_SIZE = 1024 * 64;
  RX_QUEUE = 0;
  TX_QUEUE = 1;
  EVENT_QUEUE = 2;

  PAGE_SIZE = 4096;
  MMIO_GUESTID = $100;

var
  VirtIOVSocketDev: TVirtIOVSocketDevice;

implementation

{$MACRO ON}
{$DEFINE EnableInt := asm sti;end;}
{$DEFINE DisableInt := asm pushfq;cli;end;}
{$DEFINE RestoreInt := asm popfq;end;}

procedure VirtIOProcessTxQueue(vq: PVirtQueue);
var
  index, norm_index, buffer_index: Word;
  tmp: PQueueBuffer;
begin
  if (vq.last_used_index = vq.used.index) then
    Exit;

  index := vq.last_used_index;

  while (index <> vq.used.index) do
  begin
    norm_index := index mod vq.queue_size;
    buffer_index := vq.used.rings[norm_index].index;
    tmp := Pointer(PtrUInt(vq.buffers) + buffer_index * sizeof(TQueueBuffer));
    // mark buffer as free
    tmp.length:= 0;
    inc(index);
  end;

  ReadWriteBarrier;

  vq.last_used_index:= index;
end;

type
  TByteArray = array[0..0] of Byte;
  PByteArray = ^TByteArray;

procedure VirtIOProcessRxQueue(vq: PVirtQueue);
var
  Packet: PPacket;
  index, buffer_index, Len, I: dword;
  Data, P: PByteArray;
  buf: PQueueBuffer;
  bi: TBufferInfo;
begin
  // empty queue?
  if (vq.last_used_index = vq.used.index) then
    Exit;

  while (vq.last_used_index <> vq.used.index) do
  begin
    index := vq.last_used_index mod vq.queue_size;
    buffer_index := vq.used.rings[index].index;

    buf := vq.buffers;
    Inc(buf, buffer_index);

    P := Pointer(buf.address);
    Len := vq.used.rings[index].length;

    Packet := ToroGetMem(Len+SizeOf(TPacket));

    if (Packet <> nil) then
    begin
      Packet.data:= Pointer(PtrUInt(Packet) + SizeOf(TPacket));
      Packet.size:= Len;
      Packet.Delete:= False;
      Packet.Ready:= False;
      Packet.Next:= nil;
      Data := Packet.data;
      for I := 0 to Len-1 do
        Data^[I] := P^[I];
      EnqueueIncomingPacket(Packet);
    end;

    Inc(vq.last_used_index);

    // return the buffer
    bi.size := VIRTIO_VSOCK_MAX_PKT_BUF_SIZE + sizeof(TVirtIOVSockHdr);
    bi.buffer := Pointer(buf.address);
    bi.flags := VIRTIO_DESC_FLAG_WRITE_ONLY;
    bi.copy := false;

    VirtIOSendBuffer(VirtIOVSocketDev.Base, RX_QUEUE, vq, @bi, 1);
    ReadWriteBarrier;
  end;
end;

procedure VirtIOVSocketHandler;
begin
  VirtIOProcessRxQueue (@VirtIOVSocketDev.VirtQueues[RX_QUEUE]);
  VirtIOProcessTxQueue (@VirtIOVSocketDev.VirtQueues[TX_QUEUE]);
  UpdateLastIrq;
end;

// TODO: Use net to get the IRQ
procedure VirtIOVSocketStart(net: PNetworkInterface);
begin
  IOApicIrqOn(VirtIOVSocketDev.IRQ);
end;

procedure virtIOVSocketSend(Net: PNetworkInterface; Packet: PPacket);
var
  bi: TBufferInfo;
begin
  DisableInt;

  bi.buffer := Packet.Data;
  bi.size := Packet.Size;
  bi.flags := 0;
  bi.copy := true;

  Net.OutgoingPackets := Packet;
  // TODO: Remove the use of VirtIOVSocketDev
  VirtIOSendBuffer(VirtIOVSocketDev.Base, TX_QUEUE, @VirtIOVSocketDev.VirtQueues[TX_QUEUE], @bi, 1);
  DequeueOutgoingPacket;
  RestoreInt;
end;

procedure FindVirtIOVSocketonMMIO;
var
  magic, device, version, guestid: ^DWORD;
  tx: PVirtQueue;
  Net: PNetworkInterface;
  j: LongInt;
begin
  for j := 0 to (VirtIOMMIODevicesCount -1) do
  begin  
    magic := Pointer(VirtIOMMIODevices[j].Base);
    version := Pointer(VirtIOMMIODevices[j].Base + MMIO_VERSION);
    if (magic^ = MMIO_SIGNATURE) and (version^ = MMIO_MODERN) then
    begin
      device := Pointer(VirtIOMMIODevices[j].Base + MMIO_DEVICEID);
      if device^ = VIRTIO_ID_VSOCKET then
      begin
        VirtIOVSocketDev.IRQ := VirtIOMMIODevices[j].Irq;
        VirtIOVSocketDev.Base := VirtIOMMIODevices[j].Base;

        // reset
        SetDeviceStatus(VirtIOVSocketDev.Base, 0);

        // tell driver we found it
        SetDeviceStatus(VirtIOVSocketDev.Base, VIRTIO_ACKNOWLEDGE or VIRTIO_DRIVER);

        // get cid
        guestid := Pointer(VirtIOVSocketDev.Base + MMIO_GUESTID);
        VirtIOVSocketDev.GuestID := guestid^;
        WriteConsoleF('VirtIOVSocket: cid=%d\n',[VirtIOVSocketDev.GuestID]);

        if not VirtIOInitQueue(VirtIOVSocketDev.Base, RX_QUEUE, @VirtIOVSocketDev.VirtQueues[RX_QUEUE], VIRTIO_VSOCK_MAX_PKT_BUF_SIZE + sizeof(TVirtIOVSockHdr)) then
        begin
          WriteConsoleF('VirtIOVSocket: RX_QUEUE has not been initializated\n', []);
          Exit;
        end;

        if not VirtIOInitQueue(VirtIOVSocketDev.Base, EVENT_QUEUE, @VirtIOVSocketDev.VirtQueues[EVENT_QUEUE], sizeof(TVirtIOVSockEvent)) then
        begin
          WriteConsoleF('VirtIOVSocket: EVENT_QUEUE has not been initializated\n', []);
          Exit;
        end;

        if not VirtIOInitQueue(VirtIOVSocketDev.Base, TX_QUEUE, @VirtIOVSocketDev.VirtQueues[TX_QUEUE], 0) then
        begin
          WriteConsoleF('VirtIOVSocket: TX_QUEUE has not been initializated\n', []);
          Exit;
        end;

        // set up buffers for transmission
        tx := @VirtIOVSocketDev.VirtQueues[TX_QUEUE];
        tx.buffer := ToroGetMem((VIRTIO_VSOCK_MAX_PKT_BUF_SIZE + sizeof(TVirtIOVSockHdr)) * tx.queue_size + PAGE_SIZE);
        tx.buffer := Pointer(PtrUInt(tx.buffer) + (PAGE_SIZE - PtrUInt(tx.buffer) mod PAGE_SIZE));
        tx.chunk_size:= VIRTIO_VSOCK_MAX_PKT_BUF_SIZE + sizeof(TVirtIOVSockHdr);

        // driver is alive
        SetDeviceStatus(VirtIOVSocketDev.Base, VIRTIO_ACKNOWLEDGE or VIRTIO_DRIVER or VIRTIO_DRIVER_OK);
        VirtIOMMIODevices[j].QueueHandler := @VirtIOVSocketHandler;
        Net := @VirtIOVSocketDev.Driverinterface;
        Net.Name := 'virtiovsocket';
        Net.start := @VirtIOVSocketStart;
        Net.send := @VirtIOVSocketSend;
        Net.Minor := VirtIOVSocketDev.GuestID;
        RegisterNetworkInterface(Net);
      end;
    end else
    begin
      WriteConsoleF('VirtIOVsocket: magic or version unknow, base-address may be wrong\n', []);
    end;
  end;
end;

initialization
  FindVirtIOVSocketonMMIO;
end.
