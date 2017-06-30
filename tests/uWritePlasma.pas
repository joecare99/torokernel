// Toro Write Pascal Example.
// Example using a minimal kernel to print "Pascal" in 3D

// Changes : Made example 1 a little more obscure

// 19/06/2017 Second Version by Joe Care.

// Copyright (c) 2017 Joe Care
// All Rights Reserved
unit uWritePlasma;

{$mode delphi}

interface

uses
    Console;

procedure Main;
procedure Init;


implementation

uses Sysutils,Process;

type
    TColor = Cardinal;


    TColorKmpn = record
        case boolean of
            False: (c: TColor);
            True: (r, g, b, a: byte);
    end;

    TColIndex = record
        ci: TChar_Info;
        cc: TColorKmpn;
    end;

    TchinfArr = array[0..80 * 50-1] of TChar_Info;

const
CComp: array[1..4, -2 .. 2] of word =
    ((42, 23, 0, 63, 127),
    (85, 42, 0, 42, 85),
    (127, 63, 0, 23, 42),
    (170, 85, 0, 0, 0));


const
    maxanim = 1;
    Filler=#$b0#$b1#$b2#$db;


    function max(n1, n2: integer): integer; inline;
begin
    Result := n1;
    if n2 > n1 then
        Result := n2;
end;



    function ColorComp(c1, c2: TColorKmpn): extended;
        inline;

    var
        r, b, g: integer;
    begin
        r := abs(c1.r - c2.r);
        g := abs(c1.g - c2.g);
        b := abs(c1.b - c2.b);
        Result := 1024 - (r + b + g + max(r, max(b, g))) / 1024;
    end;

    function CalcTPxColor(const i, j: integer; const lComp_2, lComp_1, lComp2, lComp1: word): TColorKmpn;
        inline;
    begin
        Result.r := (i and $4) shr $2 * lComp_2 + (i and $8) shr $3 * lComp_1 +
            (j and $4) shr $2 * lComp2 + (J and $8) shr $3 * lComp1;
        Result.g := (i and $2) shr $1 * lComp_2 + (i and $8) shr $3 * lComp_1 +
            (j and $2) shr $1 * lComp2 + (J and $8) shr $3 * lComp1;
        Result.b := (i and $1) shr $0 * lComp_2 + (i and $8) shr $3 * lComp_1 +
            (j and $1) shr $0 * lComp2 + (J and $8) shr $3 * lComp1;
    end;

    function ColorHash(const c: TColorKmpn): word;
        inline;

    begin
        Result := (c.r and $F8) shr 3 or (c.g and $F8) shl 2 or (c.b and $F8) shl 7;
    end;

    function hashcolor(const h: word): TColorKmpn;
        inline;
    begin
        Result.r := (h and $1F) shl 3;
        Result.g := (h and $3E0) shr 2;
        Result.b := (h and $7C00) shr 7;
    end;

    function ColorSubtr(const c1, c2: TColorKmpn): TColorKmpn;

        function begr(r, mi, mx: integer): integer;
        inline;

        begin
            if r <= mi then
                Result := mi
            else if r > mx then
                Result := mx
            else
                Result := r;
        end;

    var
        r, b, g: integer;

    begin
        r := c1.r;
        g := c1.g;
        b := c1.b;
        r := r - c2.r;
        g := g - c2.g;
        b := b - c2.b;
        r := c1.r + r div 4;
        G := c1.G + G div 4;
        b := c1.b + b div 4;
        Result.r := begr(r, 0, 255);
        Result.g := begr(g, 0, 255);
        Result.b := begr(b, 0, 255);
    end;

Procedure MyCosSin(d:ValReal;out sinus,cosinus : double); assembler;

{$asmmode intel}
var
  t : double;
asm
  movsd qword ptr t,xmm0
  fld qword ptr t
  fsincos
  fstp qword ptr [cosinus]
  fstp qword ptr [sinus]
  fwait
end;

procedure FlushScreen(const sb: TchinfArr);

var
    srctReadRect: TSmallRect;
    coordBufSize, coordBufCoord: TCoord;
begin
    srctReadRect.Top := 0; // top left: row 0, col 0
    srctReadRect.Left := 0;
    srctReadRect.Bottom := 49; // bot. right: row 1, col 79
    srctReadRect.Right := 79;

    coordBufSize.x := 80;
    coordBufSize.y := 50;

    coordBufCoord.x := 0;
    coordBufCoord.y := 0;

    WriteConsoleOutput(
        console.OutHandle, // screen buffer to read from
        @sb[0], // buffer to copy into
        coordbufSize, // col-row size of chiBuffer
        coordBufCoord, // top left dest. cell in chiBuffer
        srctReadRect); // screen buffer source rectangle
end;

var
    istcol: array[0..79, 0..49] of TColorKmpn;
    hashtab: array[0..32768] of word;
    sb: TchinfArr;
    ColIdx: array[0..1000] of TColIndex;

procedure Main;

var
  I, J, K: Integer;
  cc: TColorKmpn;
  Chh: Word;
  chi: TChar_Info;
  s, c: double;
begin
    PrintString('Let''s Go...');
     MyCosSin(0.0,s,c);
     PrintStringLn('..');
    for I := 0 to maxanim do
      begin
        MyCosSin(i/50,s,c);
        for K := 0 to 23 do
          for J := 0 to 79 do
              begin
              //  gotoxy(j+1,k+1);
                if k > (i - maxanim + 50) then
                  begin
                    cc.r := trunc(J * (1.5 + s * 1.5)) + random(10);
                    cc.g := trunc((79 - J) * (1.5 + c * 1.5)) +
                        random(10);
                    cc.b := K * 5 + random(10);
                  end
                else
                    cc.c := 0;
                If (J > 0) And (k > 0) Then
                  cc := ColorSubtr(cc, istcol[j - 1, k - 1]);
                if K > 0 then
                    cc := ColorSubtr(cc, istcol[j, k - 1]);
                if J > 0 then
                    cc := ColorSubtr(cc, istcol[j - 1, k]);
                cc := ColorSubtr(cc, istcol[j, k]);
                Chh := colorhash(cc);
                chi := colidx[hashtab[chh]].ci;
                sb[j + k * 80] := chi;
                Color:=chi.form;
                case chi.car of
                #$b0:  PrintString(#$b0);
                #$b1:  PrintString(#$b1);
                #$b2:  PrintString(#$b2);
                #$db:  PrintString(#$db);
                else
                   PrintString('.');
                end;
                istcol[j, k] := colidx[hashtab[chh]].cc;
              end;
   //     FlushScreen(sb);
 //  gotoxy(1,1);
        sleep(10);
      //   SysThreadSwitch;
      end;
    PrintStringLn('Press Enter ...');
end;

procedure Init;
var
    mb, bew: extended;
    //  rc: TColorKmpn;
    chi: TChar_Info;
    I, J, found, K, L: Integer;
    cc: TColorKmpn;
    high_ColIdx:integer;

begin
    high_ColIdx:=-1;
    PrintStringLn('Init1');
//    TextMode(258);
        // init
        for I := 0 to 15 do
            for J := 0 to 15 do
                for K := 1 to 2 do
                  begin
                    chi.car := filler[K];
                    chi.form := i + J * 16;
                     cc := CalcTPxColor(i, j, CComp[K, -2], CComp[K, -1], CComp[K, 2], CComp[K, 1]);

                    // append Coloridx
                    found := -1;
                    for L := 0 to high_ColIdx do
                        if cc.c = colIdx[L].cc.c then
                          begin
                            found := L;
                            break;
                          end;
                    if found = -1 then
                      begin
                        inc( high_colidx );
                        colidx[high_colidx].ci := chi;
                        colidx[high_colidx].cc := cc;
                      end;

                  end;
        PrintStringLn('Init2');
        for I := 0 to 32767 do
          begin
            cc := hashcolor(i);
            mb := ColorComp(cc, ColIdx[0].cc);
            found := 0;
            for l := 1 to high(ColIdx) do
              begin

                bew := ColorComp(cc, ColIdx[l].cc);
                if bew > mb then
                  begin
                    mb := bew;
                    chi := ColIdx[l].ci;
                    found := l;
                  end;
              end;
            hashtab[I] := found;
            if i mod 1000 = 0 then
              begin
                color := ColIdx[found].ci.form;
              PrintString(#$b1);

              end;
          end;
        fillchar(istcol{%H-}, sizeof(istcol), byte(0));
end;

initialization
  Init;
end.
