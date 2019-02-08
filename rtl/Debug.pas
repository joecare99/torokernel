//
// Debug.pas
//
// This units contains functions and procedures to Debug the kernel.
//
// Copyright (c) 2003-2018 Matias Vara <matiasevara@gmail.com>
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

unit Debug;

{$I Toro.inc}

interface

uses
  Arch;

procedure DebugInit;
procedure WriteDebug (const Format: AnsiString; const Args: array of PtrUInt);
procedure SetBreakPoint(Id: Qword);

implementation

uses
  Console, Process;

{$MACRO ON}
{$DEFINE EnableInt := asm sti;end;}
{$DEFINE DisableInt := asm pushf;cli;end;}
{$DEFINE RestoreInt := asm popf;end;}

var
  LockDebug: UInt64 = 3;

const
  BASE_COM_PORT = $3f8;

procedure WaitForCompletion;
var
  lsr: Byte;
begin
  repeat
    lsr := read_portb(BASE_COM_PORT+5);
  until (lsr and $20) = $20;
end;

procedure SendChar(C: XChar);
begin
  write_portb(Byte(C), BASE_COM_PORT);
  WaitForCompletion;
end;


function ReadChar: XChar;
begin
  while (read_portb(BASE_COM_PORT+5) and 1 ) = 0 do;
  Result := XChar(read_portb(BASE_COM_PORT));
end;


procedure SetBreakPoint(Id: Qword);
var
  tmp: Char;
begin
  WriteDebug('Debug: Breakpoint %d reached, press any key to continue\n',[Id]);
  DisableInt;
  tmp := ReadChar;
  RestoreInt;
end;

// Print in decimal form
procedure DebugPrintDecimal(Value: PtrUInt);
var
  I, Len: Byte;
  // 21 is the max number of characters needed to represent 64 bits number in decimal
  S: string[21];
begin
  Len := 0;
  I := 21;
  if Value = 0 then
  begin
    SendChar('0');
  end else
  begin
    while Value <> 0 do
    begin
      S[I] := AnsiChar((Value mod 10) + $30);
      Value := Value div 10;
      Dec(I);
      Inc(Len);
    end;
    S[0] := XChar(Len);
   for I := (sizeof(S)-Len) to sizeof(S)-1 do
   begin
    SendChar(S[I]);
   end;
  end;
end;

procedure DebugPrintHexa(const Value: PtrUInt);
var
  I: Byte;
  P: Boolean;
begin
  P := False;
  SendChar('0');
  SendChar('x');
  if Value = 0 then
  begin
    SendChar('0');
    Exit;
  end;
  for I := SizeOf(PtrUInt)*2-1 downto 0 do
  begin
   if not(P) and (HEX_CHAR[(Value shr (I*4)) and $0F] <> '0') then
     P:= True;
   if P then
     SendChar(HEX_CHAR[(Value shr (I*4)) and $0F]);
  end;
end;

procedure DebugPrintString(const S: shortstring);
var
  I: LongInt;
begin
  for I := 1 to Length(S) do
    SendChar(S[I]);
end;


procedure WriteSerial(const Format: AnsiString; const Args: array of PtrUInt);
var
  ArgNo: LongInt;
  I, J: LongInt;
  Value: QWORD;
  Values: PXChar;
  tmp: TNow;
begin
  ArgNo := 0 ;
  J := 1;
  while J <= Length(Format) do
  begin
    // we have an argument
    if (Format[J] = '%') and (High(Args) <> -1) and (High(Args) >= ArgNo) then
    begin
      Inc(J);
      if J > Length(Format) then
        Exit ;
      case Format[J] of
        'c':
          begin
            SendChar(XChar(args[ArgNo]));
          end;
        'h':
          begin
            Value := args[ArgNo];
            DebugPrintHexa(Value);
          end;
        'd':
          begin
            Value := args[ArgNo];
            DebugPrintDecimal (Value);
          end;
        '%':
          begin
            SendChar('%');
          end;
        'p':
          begin
            Values := pointer(args[ArgNo]);
            while Values^ <> #0 do
            begin
              SendChar(Values^);
              Inc(Values);
            end;
          end;
        else
        begin
          Inc(J);
          Continue;
        end;
      end;
      Inc(J);
      Inc(ArgNo);
      Continue;
    end;
    if Format[J] = '\' then
    begin
      Inc(J);
      if J > Length(Format) then
        Exit ;
      case Format[J] of
        'c':
          begin
            Inc(J);
          end;
        'n':
          begin
            SendChar(XChar(13));
            SendChar(XChar(10));
            Inc(J);
          end;
        '\':
          begin
            SendChar('\');
            Inc(J);
          end;
        'v':
          begin
            I := 1;
            while I < 10 do
            begin
              SendChar(' ');
              Inc(I);
            end;
            Inc(J);
          end;
        'r':
          begin
            DebugPrintDecimal (read_rdtsc);
            Inc(J);
          end;
        't':
          begin
            Now(@tmp);
            if tmp.Day < 10 then
              DebugPrintDecimal  (0);
            DebugPrintDecimal (tmp.Day);
            SendChar('/');
            if tmp.Month < 10 then
              DebugPrintDecimal  (0);
            DebugPrintDecimal (tmp.Month);
            SendChar('/');
            DebugPrintDecimal (tmp.Year);
            SendChar('-');
            if tmp.Hour < 10 then
              DebugPrintDecimal  (0);
            DebugPrintDecimal(tmp.Hour);
            SendChar(':');
            if tmp.Min < 10 then
              DebugPrintDecimal  (0);
            DebugPrintDecimal(tmp.Min);
            SendChar(':');
            if tmp.Sec < 10 then
              DebugPrintDecimal  (0);
            DebugPrintDecimal (tmp.Sec);
            Inc(J);
          end;
        else
        begin
          SendChar('\');
          SendChar(Format[J]);
        end;
      end;
      Continue;
    end;
    SendChar(Format[J]);
    Inc(J);
  end;
end;

procedure WriteDebug (const Format: AnsiString; const Args: array of PtrUInt);
var
  CPUI: LongInt;
  Thread: PThread;
begin
  DisableInt;
  SpinLock (3,4,LockDebug);
  CPUI := GetApicID;
  Thread := Cpu[CPUI].CurrentThread;
  {$IFDEF UseStampCounterinDebug}
     WriteSerial('[\r] CPU%d Thread#%d ',[CPUI, Int64(PtrUInt(Thread))]);
  {$ELSE}
     WriteSerial('[\t] CPU%d Thread#%d ',[CPUI, Int64(PtrUInt(Thread))]);
  {$ENDIF}
  WriteSerial (Format, Args);
  LockDebug := 3;
  RestoreInt;
end;


procedure DebugInit;
begin
  write_portb ($83, BASE_COM_PORT+3);
  write_portb (0, BASE_COM_PORT+1);
  write_portb (1, BASE_COM_PORT);
  write_portb (3, BASE_COM_PORT+3);
  WriteConsoleF ('Toro on /Vdebug mode/n using /VCOM1/n\n',[]);
  WriteDebug('Initialization of debugging console.\n',[]);
  {$IFDEF DebugCrash}
     WriteDebug('Crash dumping is Enabled\n',[]);
  {$ELSE}
     WriteDebug('Crash dumping is Disable\n',[]);
  {$ENDIF}
  {$IFDEF DCC} System.DebugTraceProc := @DebugTrace; {$ENDIF}
end;

end.

