//
// VirtIO.pas
//
// This unit contains code to handle VirtIO modern devices.
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

unit VirtIO;

interface

{$I ..\Toro.inc}

{$IFDEF EnableDebug}
       //{$DEFINE DebugVirtioFS}
{$ENDIF}

uses
  {$IFDEF EnableDebug} Debug, {$ENDIF}
  Arch, Console, Network, Process, Memory;

type
  PVirtIOMMIODevice = ^TVirtIOMMIODevice;
  
  TVirtIOMMIODevice = record
    Base: QWord;
    Irq: byte;
    QueueHandler: Procedure;
  end;

  PByte = ^TByte;
  TByte = array[0..0] of byte;

  PBufferInfo = ^TBufferInfo;
  TBufferInfo = record
    buffer: ^Byte;
    size: QWord;
    flags: Byte;
    copy: Boolean;
  end;

  VirtIOUsedItem = record
    index: Dword;
    length: Dword;
  end;

  PVirtIOUsed = ^TVirtIOUsed;
  TVirtIOUsed = record
    flags: word;
    index: word;
    rings: array[0..0] of VirtIOUsedItem;
  end;

  PVirtIOAvailable = ^TVirtIOAvailable;
  TVirtIOAvailable = record
    flags: Word;
    index: Word;
    rings: Array[0..0] of Word;
  end;

  PQueueBuffer = ^TQueueBuffer;
  TQueueBuffer = record
    address: QWord;
    length: DWord;
    flags: Word;
    next: Word;
  end;

  PVirtQueue = ^TVirtQueue;
  TVirtQueue = record
    queue_size: WORD;
    buffers: PQueueBuffer;
    available: PVirtIOAvailable;
    used: PVirtIOUsed;
    last_used_index: word;
    last_available_index: word;
    buffer: PByte;
    chunk_size: dword;
    next_buffer: word;
    lock: QWord;
  end;

const
  MAX_MMIO_DEVICES = 2;

  MMIO_MODERN = 2;
  MMIO_VERSION = 4;
  MMIO_SIGNATURE = $74726976;
  MMIO_DEVICEID = $8;
  MMIO_QUEUENOTIFY = $50;
  MMIO_CONFIG = $100;
  MMIO_FEATURES = $10;
  MMIO_STATUS = $70;
  MMIO_GUESTFEATURES = $20;
  MMIO_QUEUESEL = $30;
  MMIO_QUEUENUMMAX = $34;
  MMIO_QUEUENUM = $38;
  MMIO_QUEUEREADY = $44;
  MMIO_GUESTPAGESIZE = $28;
  MMIO_QUEUEPFN = $40;
  MMIO_QUEUEALIGN = $3C;
  MMIO_INTSTATUS = $60;
  MMIO_INTACK = $64;
  MMIO_READY = $44;
  MMIO_DESCLOW = $80;
  MMIO_DESCHIGH = $84;
  MMIO_AVAILLOW = $90;
  MMIO_AVAILHIGH = $94;
  MMIO_USEDLOW = $a0;
  MMIO_USEDHIGH = $a4;

  VIRTIO_ACKNOWLEDGE = 1;
  VIRTIO_DRIVER = 2;
  VIRTIO_CTRL_VQ = 17;
  VIRTIO_MRG_RXBUF = 15;
  VIRTIO_CSUM = 0;
  VIRTIO_FEATURES_OK = 8;
  VIRTIO_DRIVER_OK = 4;
  VIRTIO_DESC_FLAG_WRITE_ONLY = 2;
  VIRTIO_DESC_FLAG_NEXT = 1;

procedure SetDeviceStatus(Base: QWORD; Value: DWORD);
procedure SetDeviceGuestPageSize(Base: QWORD; Value: DWORD);
function GetIntStatus(Base: QWORD): DWORD;
procedure SetIntACK(Base: QWORD; Value: DWORD);
function GetDeviceFeatures(Base: QWORD): DWORD;
function VirtIOInitQueue(Base: QWORD; QueueId: Word; Queue: PVirtQueue; HeaderLen: DWORD): Boolean;
procedure VirtIOSendBuffer(Base: QWORD; queue_index: word; Queue: PVirtQueue; bi:PBufferInfo; count: QWord);

var
  VirtIOMMIODevices: array[0..MAX_MMIO_DEVICES-1] of TVirtIOMMIODevice;
  VirtIOMMIODevicesCount: LongInt = 0;
 
implementation

{$MACRO ON}
{$DEFINE EnableInt := asm sti;end;}
{$DEFINE DisableInt := asm pushfq;cli;end;}
{$DEFINE RestoreInt := asm popfq;end;}

function startsWith(p1, p2: PChar): Boolean;
var
  j: LongInt;
begin
  Result := false;
  if strlen(p2) > strlen(p1) then
    Exit;
  for j:= 0 to (strlen(p2)-1) do
  begin
    if p1[j] <> p2[j] then
      Exit;
  end;
  Result := True;
end;

function LookForChar(p1: PChar; c: Char): PChar;
begin
  Result := nil;
  while (p1^ <> Char(0)) and (p1^ <> c) do
  begin
    Inc(p1);
  end;
  if p1^ = Char(0) then
    Exit;
  Result := p1; 
end;

function HexStrtoQWord(start, last: PChar): QWord;
var
  bt: Byte;
  i: PChar;
  Base: QWord;
begin
  i := start;
  Base := 0;
  while (i <> last) do
  begin
    bt := Byte(i^);
    Inc(i);
    if (bt >= Byte('0')) and (bt <= Byte('9')) then
      bt := bt - Byte('0')
    else if (bt >= Byte('a')) and (bt <= Byte('f')) then
      bt := bt - Byte('a') + 10
    else if (bt >= Byte('A')) and (bt <= Byte('F')) then
      bt := bt - Byte('A') + 10; 
    Base := (Base shl 4) or (bt and $F);
  end;
  Result := Base;
end;

function StrtoByte(p1: PChar): Byte;
var
  ret: Byte;
begin
  ret := 0;
  while p1^ <> Char(0) do
  begin
    ret := ret * 10 + Byte(p1^) - Byte('0');
    Inc(p1);
  end;
  Result := ret;
end;

procedure SetDeviceStatus(Base: QWORD; Value: DWORD);
var
  status: ^DWORD;
begin
  status := Pointer(Base + MMIO_STATUS);
  status^ := Value;
  ReadWriteBarrier;
end;

procedure SetDeviceGuestPageSize(Base: QWORD; Value: DWORD);
var
  GuestPageSize: ^DWORD;
begin
  GuestPageSize := Pointer(Base + MMIO_GUESTPAGESIZE);
  GuestPageSize^ := Value;
end;

function GetIntStatus(Base: QWORD): DWORD;
var
  IntStatus: ^DWORD;
begin
  IntStatus := Pointer(Base + MMIO_INTSTATUS);
  Result := IntStatus^;
end;

procedure SetIntACK(Base: QWORD; Value: DWORD);
var
  IntACK: ^DWORD;
begin
  IntACK := Pointer(Base + MMIO_INTACK);
  IntAck^ := Value;
end;

function GetDeviceFeatures(Base: QWORD): DWORD;
var
  value: ^DWORD;
begin
  value := Pointer(Base + MMIO_FEATURES);
  Result := value^;
end;

procedure VirtIOSendBuffer(Base: QWORD; queue_index: word; Queue: PVirtQueue; bi:PBufferInfo; count: QWord);
var
  index, buffer_index, next_buffer_index: word;
  vq: PVirtQueue;
  buf: ^Byte;
  b: PBufferInfo;
  i: LongInt;
  tmp: PQueueBuffer;
  QueueNotify: ^DWORD;
begin
  vq := Queue;

  index := vq.available.index mod vq.queue_size;
  buffer_index := vq.next_buffer;
  vq.available.rings[index] := buffer_index;
  buf := Pointer(PtrUInt(vq.buffer) + vq.chunk_size*buffer_index);

  for i := 0 to (count-1) do
  begin
    next_buffer_index:= (buffer_index +1) mod vq.queue_size;
    b := Pointer(PtrUInt(bi) + i * sizeof(TBufferInfo));

    tmp := Pointer(PtrUInt(vq.buffers) + buffer_index * sizeof(TQueueBuffer));
    tmp.flags := b.flags;
    tmp.next := next_buffer_index;
    tmp.length := b.size;
    if (i <> (count-1)) then
        tmp.flags := tmp.flags or VIRTIO_DESC_FLAG_NEXT;

    // TODO: use copy=false to use zero-copy approach
    if b.copy then
    begin
       tmp.address:= PtrUInt (buf); // check this
       if (bi.buffer <> nil) then
           Move(b.buffer^, buf^, b.size);
       Inc(buf, b.size);
    end else
       tmp.address:= PtrUInt(b.buffer);

    buffer_index := next_buffer_index;
  end;

  ReadWriteBarrier;
  vq.next_buffer := buffer_index;
  vq.available.index:= vq.available.index + 1;

  // notification are not needed
  // TODO: remove the use of base
  if (vq.used.flags and 1 <> 1) then
  begin
    QueueNotify := Pointer(Base + MMIO_QUEUENOTIFY);
    QueueNotify^ := queue_index;
  end;
end;

function VirtIOInitQueue(Base: QWORD; QueueId: Word; Queue: PVirtQueue; HeaderLen: DWORD): Boolean;
var
  j: LongInt;
  QueueSize, sizeOfBuffers: DWORD;
  sizeofQueueAvailable, sizeofQueueUsed: DWORD;
  buff: PChar;
  bi: TBufferInfo;
  QueueSel: ^DWORD;
  QueueNumMax, QueueNum, AddrLow: ^DWORD;
  EnableQueue: ^DWORD;
begin
  Result := False;
  FillByte(Queue^, sizeof(TVirtQueue), 0);

  QueueSel := Pointer(Base + MMIO_QUEUESEL);
  QueueSel^ := QueueId;
  ReadWriteBarrier;

  QueueNumMax := Pointer(Base + MMIO_QUEUENUMMAX);
  QueueSize := QueueNumMax^;
  if QueueSize = 0 then
    Exit;
  Queue.queue_size := QueueSize;

  // set queue size
  QueueNum := Pointer (Base + MMIO_QUEUENUM);
  QueueNum^ := QueueSize;
  ReadWriteBarrier;

  sizeOfBuffers := (sizeof(TQueueBuffer) * QueueSize);
  sizeofQueueAvailable := (2*sizeof(WORD)+2) + (QueueSize*sizeof(WORD));
  sizeofQueueUsed := (2*sizeof(WORD)+2)+(QueueSize*sizeof(VirtIOUsedItem));

  // buff must be 4k aligned
  buff := ToroGetMem(sizeOfBuffers + sizeofQueueAvailable + sizeofQueueUsed + PAGE_SIZE*2);
  If buff = nil then
    Exit;
  FillByte(buff^, sizeOfBuffers + sizeofQueueAvailable + sizeofQueueUsed + PAGE_SIZE*2, 0);
  buff := buff + (PAGE_SIZE - PtrUInt(buff) mod PAGE_SIZE);

  // 16 bytes aligned
  Queue.buffers := PQueueBuffer(buff);

  // 2 bytes aligned
  Queue.available := @buff[sizeOfBuffers];

  // 4 bytes aligned
  Queue.used := PVirtIOUsed(@buff[((sizeOfBuffers + sizeofQueueAvailable + $0FFF) and not($0FFF))]);
  Queue.next_buffer := 0;
  Queue.lock := 0;

  AddrLow := Pointer(Base + MMIO_DESCLOW);
  AddrLow^ := DWORD(PtrUint(Queue.buffers) and $ffffffff);
  AddrLow := Pointer(Base + MMIO_DESCHIGH);
  AddrLow^ := 0;

  AddrLow := Pointer(Base + MMIO_AVAILLOW);
  AddrLow^ := DWORD(PtrUInt(Queue.available) and $ffffffff);
  AddrLow := Pointer(Base + MMIO_AVAILHIGH);
  AddrLow^ := 0;

  AddrLow := Pointer(Base + MMIO_USEDLOW);
  AddrLow^ := DWORD(PtrUInt(Queue.used) and $ffffffff);
  AddrLow := Pointer(Base + MMIO_USEDHIGH);
  AddrLow^ := 0;

  EnableQueue := Pointer(Base + MMIO_QUEUEREADY);
  EnableQueue^ := 1;

  // Device queues are fill
  if HeaderLen <> 0 then
  begin
    Queue.Buffer := ToroGetMem(Queue.queue_size * (HeaderLen) + PAGE_SIZE);
    if Queue.Buffer = nil then
      Exit;
    Queue.Buffer := Pointer(PtrUint(queue.Buffer) + (PAGE_SIZE - PtrUInt(Queue.Buffer) mod PAGE_SIZE));
    Queue.chunk_size := HeaderLen;

    bi.size := HeaderLen;
    bi.buffer := nil;
    bi.flags := VIRTIO_DESC_FLAG_WRITE_ONLY;
    bi.copy := True;
    for j := 0 to Queue.queue_size - 1 do
    begin
      VirtIOSendBuffer(Base, QueueId, Queue, @bi, 1);
    end;
  end;

  Result := True;
end;

procedure VirtIOIRQHandler; forward;

// parse the kernel command-line to get the device tree
procedure FindVirtIOMMIODevices;
var
  j: LongInt;
  Base: QWord;
  Irq: Byte;
begin
  for j:= 1 to KernelParamCount do 
  begin
    if startsWith (GetKernelParam(j), 'virtio_mmio') then
    begin
      Base := HexStrtoQWord(LookForChar(GetKernelParam(j), '@') + 3 , LookForChar(GetKernelParam(j), ':'));
      Irq := StrtoByte(LookForChar(GetKernelParam(j), ':') + 1);
      CaptureInt(BASE_IRQ + Irq, @VirtIOIrqHandler);
      VirtIOMMIODevices[VirtIOMMIODevicesCount].Base := Base;
      VirtIOMMIODevices[VirtIOMMIODevicesCount].Irq := Irq;
      Inc(VirtIOMMIODevicesCount);
      WriteConsoleF('VirtIO: found device at %h:%d\n', [Base, Irq]);
    end;
  end;
end;

procedure VirtIOHandler;
var
  r, j: DWORD;
begin
  for j := 0 to VirtIOMMIODevicesCount -1 do
  begin
    r := GetIntStatus(VirtIOMMIODevices[j].Base);
    if r and 1 = 1 then
    begin
      VirtIOMMIODevices[j].QueueHandler;
      SetIntACK(VirtIOMMIODevices[j].Base, r);
    end;
  end;
  eoi_apic;
end;

procedure VirtIOIrqHandler; {$IFDEF FPC} [nostackframe]; assembler; {$ENDIF}
asm
  {$IFDEF DCC} .noframe {$ENDIF}
  // save registers
  push rbp
  push rax
  push rbx
  push rcx
  push rdx
  push rdi
  push rsi
  push r8
  push r9
  push r10
  push r11
  push r12
  push r13
  push r14
  push r15
  mov r15 , rsp
  mov rbp , r15
  sub r15 , 32
  mov  rsp , r15
  xor rcx , rcx
  Call VirtIOHandler
  mov rsp , rbp
  pop r15
  pop r14
  pop r13
  pop r12
  pop r11
  pop r10
  pop r9
  pop r8
  pop rsi
  pop rdi
  pop rdx
  pop rcx
  pop rbx
  pop rax
  pop rbp
  db $48
  db $cf
end;

initialization
  FindVirtIOMMIODevices;
end.
