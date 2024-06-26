// Toro Write Pascal Example.
// Example using a minimal kernel to print "Pascal" in 3D

// Changes : Made example 1 a little more obscure

// 19/06/2017 Second Version by Joe Care.

// Copyright (c) 2017 Joe Care
// All Rights Reserved
unit uTestConsole;

{$mode delphi}

interface

uses
    Console;

procedure Main;

 const
    CComp: array[1..4, -2 .. 2] of word =
        ((42, 23, 0, 63, 127),
(85, 42, 0, 42, 85),
(127, 63, 0, 23, 42),
(170, 85, 0, 0, 0));

      JC:array[0..5073] of byte=
              ($78,$9C,$AD,$99,$6F,$6C,$1B,$F7,$79,$C7,$3D,$20,$C0,$44,
        	 $89,$05,$68,$F1,$14,$5C,$AC,$D3,$CA,$2B,$7C,$C0,$8E,$E4,$6F,$DB,
        	 $59,$FA,$C9,$3D,$D5,$BC,$CC,$D7,$E2,$5E,$9C,$C8,$0B,$C0,$5A,$47,
        	 $5B,$AC,$4D,$CC,$94,$CB,$17,$12,$A9,$60,$8E,$25,$B9,$6B,$6B,$0C,
        	 $96,$B4,$BD,$B0,$28,$25,$58,$2D,$CB,$01,$A2,$17,$B3,$A8,$EC,$45,
        	 $4D,$2A,$41,$E3,$D8,$19,$96,$57,$A6,$E4,$0E,$98,$25,$B9,$58,$63,
        	 $A7,$43,$DE,$45,$94,$32,$A0,$D1,$9F,$15,$B3,$DD,$CE,$FB,$3E,$C7,
        	 $28,$CE,$1F,$A7,$4D,$86,$E9,$A0,$54,$95,$A5,$FB,$DC,$F3,$FC,$9E,
        	 $E7,$FB,$7C,$9F,$D3,$9E,$3D,$F4,$D1,$6C,$06,$CD,$0E,$2B,$CF,$8A,
        	 $DA,$B2,$5E,$64,$EB,$D2,$92,$54,$93,$D6,$F1,$E9,$93,$6B,$D2,$A2,
        	 $38,$27,$CC,$89,$DD,$6A,$99,$97,$79,$BB,$45,$D7,$69,$67,$CF,$97,
        	 $FE,$78,$74,$EE,$D1,$B9,$FA,$57,$41,$53,$30,$8E,$78,$8C,$15,$7D,
        	 $82,$6D,$48,$8B,$20,$D0,$E5,$6B,$03,$43,$1A,$FB,$04,$A3,$E3,$FF,
        	 $C4,$38,$62,$75,$98,$15,$ED,$82,$36,$26,$64,$03,$27,$03,$59,$5C,
        	 $EF,$4B,$8D,$4A,$44,$8E,$2B,$DD,$4A,$58,$F6,$B5,$55,$45,$D3,$3F,
        	 $27,$54,$A5,$5A,$A8,$2A,$85,$D5,$88,$3A,$C9,$2F,$25,$BF,$2A,$E3,
        	 $36,$5F,$E1,$1F,$C6,$8A,$AC,$26,$8D,$E2,$79,$E7,$C4,$51,$61,$4D,
        	 $6A,$94,$23,$0A,$5D,$3E,$D9,$27,$57,$C5,$AC,$1F,$DF,$0B,$F9,$94,
        	 $06,$25,$CE,$06,$58,$59,$1F,$FA,$8A,$8C,$17,$AC,$0E,$E3,$2A,$EF,
        	 $F3,$67,$03,$74,$8F,$AC,$B0,$A7,$61,$4F,$C3,$37,$FC,$7D,$B8,$C6,
        	 $02,$25,$01,$B9,$12,$6B,$12,$E2,$08,$D4,$A4,$88,$32,$26,$F4,$05,
        	 $AA,$92,$4F,$AD,$E8,$0F,$4F,$CE,$9E,$9E,$3D,$FD,$65,$19,$B7,$79,
        	 $87,$55,$D6,$70,$AE,$62,$83,$52,$0B,$65,$85,$BF,$F4,$1F,$6E,$E8,
        	 $43,$BE,$C6,$84,$92,$40,$27,$4F,$D7,$79,$FF,$28,$18,$61,$A5,$84,
        	 $9F,$AA,$85,$C2,$6C,$F3,$70,$87,$FD,$F0,$C4,$DD,$DE,$2F,$CB,$D8,
        	 $D4,$2F,$30,$5F,$1B,$DD,$BF,$2A,$51,$14,$87,$C1,$90,$FD,$F2,$53,
        	 $63,$02,$28,$E2,$A2,$E8,$93,$F3,$EA,$FB,$62,$B3,$D1,$96,$BE,$E7,
        	 $9C,$B1,$8A,$DA,$BC,$78,$4A,$EC,$13,$70,$26,$6E,$91,$4F,$BB,$8F,
        	 $86,$A5,$EC,$83,$DE,$D7,$DD,$DF,$CF,$F8,$B5,$7E,$55,$0B,$CB,$6B,
        	 $A1,$B5,$D0,$62,$E8,$BC,$17,$C5,$E1,$80,$F9,$94,$19,$18,$0B,$EC,
        	 $32,$BA,$D5,$45,$B1,$A2,$BD,$E9,$4C,$DB,$CD,$5D,$79,$B6,$24,$8D,
        	 $49,$F3,$A1,$29,$FD,$9A,$BB,$1A,$FB,$75,$AC,$2D,$FB,$EF,$C9,$1E,
        	 $EB,$2F,$AC,$DF,$CF,$B8,$AA,$51,$16,$D6,$70,$DE,$D9,$C0,$E1,$C0,
        	 $95,$C0,$15,$11,$95,$25,$98,$C8,$4E,$36,$40,$8C,$79,$01,$E7,$2F,
        	 $97,$D9,$C3,$5E,$29,$7D,$2E,$37,$9B,$6B,$CB,$0C,$39,$5B,$B1,$BD,
        	 $E6,$9D,$D8,$01,$2B,$C1,$3E,$D4,$17,$F8,$1B,$C9,$61,$E7,$DA,$17,
        	 $46,$52,$3F,$0F,$9F,$AC,$82,$31,$27,$9C,$AF,$57,$AE,$70,$38,$D0,
        	 $E7,$7F,$CC,$58,$14,$1B,$E5,$C6,$B6,$32,$7F,$98,$6C,$4D,$1D,$4A,
        	 $1F,$4A,$DF,$4D,$B6,$9B,$15,$7D,$EB,$B0,$60,$6D,$C7,$26,$78,$D0,
        	 $D8,$6B,$0C,$DB,$FF,$E0,$04,$CD,$DF,$C7,$E8,$57,$55,$A5,$2A,$AE,
        	 $49,$E7,$85,$93,$81,$EF,$F8,$FF,$16,$39,$1A,$0D,$F4,$D1,$A7,$F0,
        	 $6D,$44,$45,$27,$BE,$28,$0E,$B0,$79,$61,$49,$8C,$2A,$53,$6C,$99,
        	 $97,$B5,$0F,$D0,$95,$83,$6C,$59,$17,$AC,$67,$73,$0F,$DC,$61,$3B,
        	 $68,$5C,$73,$EF,$B9,$FF,$FD,$05,$15,$40,$8C,$0B,$AC,$41,$6E,$90,
        	 $AB,$5E,$AE,$FE,$CA,$DF,$17,$38,$8F,$E7,$A7,$BA,$EA,$13,$E8,$7F,
        	 $17,$BD,$BA,$8A,$28,$8D,$72,$54,$79,$9E,$6D,$EA,$CD,$C6,$2A,$0F,
        	 $2B,$1B,$A1,$22,$5F,$D5,$B7,$0F,$3F,$E8,$BD,$9B,$BC,$68,$B7,$9B,
        	 $94,$AB,$23,$5F,$70,$26,$75,$46,$55,$BC,$29,$9E,$17,$46,$85,$51,
        	 $3C,$FD,$3F,$0A,$57,$04,$52,$A7,$51,$81,$7A,$61,$4C,$40,$A5,$CA,
        	 $EB,$52,$54,$89,$2A,$4D,$E8,$C8,$B8,$3A,$A5,$AD,$85,$4E,$05,$D6,
        	 $43,$05,$B6,$28,$25,$58,$59,$AB,$68,$1D,$50,$A1,$66,$F3,$7A,$F2,
        	 $80,$B9,$2F,$3B,$F2,$04,$8D,$F9,$2C,$E3,$FC,$E7,$19,$E8,$78,$62,
        	 $44,$C0,$88,$2A,$CF,$B1,$AB,$9A,$5F,$19,$15,$36,$42,$03,$DA,$07,
        	 $A1,$BC,$B6,$A3,$2F,$73,$6E,$B6,$9B,$82,$F9,$4B,$37,$68,$1E,$B1,
        	 $9F,$74,$2A,$C4,$E8,$56,$D7,$A4,$F7,$A5,$2B,$82,$77,$E1,$DE,$57,
        	 $48,$4F,$F0,$59,$C2,$35,$2A,$CC,$43,$B9,$A2,$8A,$A3,$16,$58,$41,
        	 $9D,$64,$65,$BE,$C0,$D7,$42,$F3,$D2,$B2,$7E,$D0,$0A,$2B,$53,$DA,
        	 $56,$6C,$80,$45,$F0,$EF,$D0,$62,$73,$C8,$79,$C1,$D9,$FB,$39,$46,
        	 $57,$8E,$18,$03,$A8,$FE,$27,$33,$A8,$0B,$C1,$C0,$49,$C4,$C1,$C8,
        	 $AB,$45,$36,$05,$CA,$BA,$34,$2E,$56,$78,$BB,$E9,$57,$8A,$7C,$3B,
        	 $56,$D4,$F2,$F8,$97,$BD,$66,$0F,$B4,$F8,$CC,$13,$18,$A7,$1D,$2F,
        	 $0E,$D4,$6D,$55,$A4,$3B,$5F,$C1,$35,$87,$0A,$A3,$4C,$91,$66,$2C,
        	 $49,$14,$CB,$7A,$28,$81,$08,$96,$B5,$0A,$5B,$D0,$96,$B5,$49,$AD,
        	 $24,$CE,$4B,$41,$73,$27,$56,$0B,$2D,$E8,$15,$BE,$A2,$E7,$59,$18,
        	 $CA,$39,$C0,$6E,$EB,$61,$B5,$5F,$7B,$26,$BB,$2F,$FB,$49,$C6,$BE,
        	 $EC,$6E,$AE,$3E,$C9,$A8,$4A,$25,$8F,$B1,$86,$0A,$AD,$33,$E2,$60,
        	 $54,$B4,$49,$B6,$E2,$31,$E6,$F1,$BD,$9D,$58,$BB,$F5,$73,$A9,$8C,
        	 $FE,$2B,$F3,$02,$B3,$D5,$6E,$75,$02,$B3,$6D,$82,$F7,$6B,$49,$FB,
        	 $E2,$A7,$34,$F9,$7E,$2F,$31,$6C,$CC,$88,$AA,$77,$EF,$9B,$12,$FD,
        	 $17,$97,$97,$AB,$45,$64,$C9,$27,$2F,$61,$4E,$25,$94,$B2,$B6,$C3,
        	 $B7,$71,$81,$A4,$11,$79,$C8,$69,$92,$CB,$FC,$45,$9C,$07,$6A,$CA,
        	 $58,$E0,$61,$75,$3D,$14,$51,$07,$F8,$05,$BE,$D7,$FA,$A5,$2B,$7E,
        	 $1C,$C9,$A3,$73,$3D,$56,$9D,$E1,$93,$D7,$BC,$BB,$CF,$89,$37,$71,
        	 $FF,$C7,$0C,$9A,$B3,$C4,$E8,$56,$5E,$64,$5B,$7C,$55,$7B,$CC,$70,
        	 $ED,$01,$E6,$A8,$CB,$E8,$91,$A0,$B1,$AA,$97,$79,$93,$D2,$A8,$74,
        	 $B3,$0B,$FC,$82,$76,$C0,$BA,$96,$FC,$EB,$8F,$2B,$F8,$78,$EE,$5A,
        	 $92,$18,$61,$B9,$A1,$AD,$5A,$7F,$7E,$E9,$A6,$88,$AF,$28,$26,$2F,
        	 $53,$8B,$52,$5C,$8D,$AB,$B7,$24,$A6,$AC,$F0,$94,$49,$D7,$96,$BE,
        	 $A2,$67,$03,$B5,$50,$8F,$F5,$61,$EC,$5C,$7F,$41,$75,$AD,$94,$D5,
        	 $69,$B6,$18,$15,$1E,$51,$D7,$F7,$87,$D5,$30,$3B,$62,$BF,$D2,$DF,
        	 $95,$D9,$8D,$22,$AE,$DC,$14,$1F,$33,$4A,$E2,$63,$46,$FD,$5A,$F4,
        	 $FA,$3B,$A2,$DC,$42,$77,$DC,$E1,$DC,$E8,$34,$3A,$CD,$55,$E4,$FF,
        	 $94,$B0,$28,$F5,$D8,$CB,$FA,$C3,$DE,$29,$AD,$C5,$74,$2D,$6E,$04,
        	 $3D,$46,$A3,$12,$56,$BB,$D9,$77,$ED,$EF,$E5,$F6,$A5,$EB,$8C,$D6,
        	 $AC,$66,$D6,$24,$62,$C4,$D5,$46,$D9,$53,$71,$A9,$B4,$9B,$27,$A1,
        	 $CE,$20,$DF,$50,$D1,$E2,$CA,$73,$0A,$37,$5C,$F3,$AC,$39,$62,$05,
        	 $BB,$B6,$63,$E8,$55,$41,$55,$96,$C4,$11,$BB,$A0,$72,$E3,$AC,$95,
        	 $32,$8F,$9A,$DC,$A8,$68,$8D,$0A,$22,$61,$11,$F5,$41,$EF,$0F,$73,
        	 $EF,$9D,$DE,$97,$FB,$D1,$E0,$05,$ED,$8F,$1A,$F6,$3C,$B5,$CB,$A0,
        	 $FA,$79,$32,$A3,$C8,$98,$12,$57,$10,$83,$31,$62,$9D,$B5,$B6,$F4,
        	 $AD,$18,$D5,$DC,$00,$9C,$CB,$B4,$53,$60,$1C,$DF,$FD,$A6,$D9,$09,
        	 $35,$99,$44,$FF,$FB,$D4,$30,$EA,$EB,$7E,$EF,$89,$EC,$3B,$BD,$D7,
        	 $92,$6F,$B8,$7B,$2D,$9A,$79,$BB,$8C,$71,$61,$DE,$EB,$6B,$74,$9F,
        	 $D7,$1D,$BB,$B9,$AA,$49,$E8,$0C,$3E,$88,$E7,$4D,$99,$C7,$8C,$19,
        	 $67,$95,$4F,$68,$E3,$E2,$C9,$C0,$A9,$C0,$9C,$30,$C8,$0A,$6C,$C6,
        	 $79,$D9,$C6,$BF,$20,$C2,$A7,$29,$5F,$88,$84,$4E,$E5,$D7,$A8,$EC,
        	 $A4,$7D,$95,$C3,$19,$F8,$1F,$C7,$F1,$98,$51,$FD,$14,$03,$71,$68,
        	 $53,$1A,$E5,$E4,$A0,$71,$D4,$BA,$6C,$6D,$F1,$49,$30,$B2,$01,$52,
        	 $81,$05,$5E,$50,$CF,$DA,$3F,$B0,$8F,$9A,$23,$E6,$37,$CD,$20,$22,
        	 $89,$A2,$BA,$7C,$EA,$84,$E7,$C1,$8E,$D8,$CB,$B1,$F3,$E2,$9E,$A7,
        	 $1E,$C7,$41,$1D,$8D,$33,$C1,$FD,$B3,$A4,$8D,$1E,$83,$3C,$62,$44,
        	 $C9,$A3,$42,$57,$B4,$61,$F3,$B2,$F5,$96,$7D,$DD,$0E,$76,$15,$D8,
        	 $9C,$74,$12,$1A,$E3,$93,$0B,$AA,$60,$FC,$8F,$4B,$51,$CC,$58,$23,
        	 $E0,$EC,$F0,$29,$9C,$3C,$CE,$1E,$A7,$5F,$43,$B7,$14,$79,$6D,$BF,
        	 $19,$F8,$C6,$C7,$8C,$79,$71,$97,$31,$FA,$29,$46,$A3,$3C,$01,$05,
        	 $59,$D0,$52,$38,$F1,$CB,$CE,$65,$30,$26,$B4,$92,$84,$D9,$25,$AC,
        	 $63,$4A,$6D,$EB,$BF,$4D,$1E,$33,$87,$CD,$1F,$98,$67,$ED,$83,$C6,
        	 $B6,$5E,$D4,$A2,$60,$50,$75,$75,$B3,$BC,$06,$46,$C8,$F4,$EF,$32,
        	 $6A,$9E,$6A,$E0,$DE,$D0,$92,$93,$D0,$73,$30,$A4,$92,$D7,$E7,$A4,
        	 $A9,$DB,$5C,$E8,$9A,$B1,$DE,$72,$28,$0E,$C1,$88,$AB,$63,$F8,$99,
        	 $B8,$CA,$91,$9D,$1B,$CE,$0F,$10,$C1,$31,$E3,$A0,$75,$B0,$AB,$D3,
        	 $E0,$98,$5E,$83,$5A,$02,$95,$15,$85,$82,$AD,$EF,$DF,$08,$4D,$F0,
        	 $A8,$DC,$CD,$EA,$8C,$75,$4C,$53,$62,$8C,$89,$E4,$17,$CE,$7F,$8A,
        	 $91,$50,$57,$C0,$18,$31,$7F,$65,$5F,$76,$66,$C0,$48,$B0,$51,$F1,
        	 $DB,$01,$5B,$DE,$42,$87,$5F,$B2,$2F,$DB,$67,$CD,$83,$D6,$31,$74,
        	 $4E,$67,$57,$87,$F1,$12,$2F,$6A,$71,$16,$45,$DF,$36,$2A,$8D,$AA,
        	 $4F,$C9,$33,$CA,$84,$D7,$83,$CA,$6E,$1C,$59,$81,$66,$FA,$18,$D4,
        	 $9D,$EA,$B6,$16,$F2,$C9,$09,$D5,$56,$B7,$F5,$11,$EB,$86,$F5,$AB,
        	 $E4,$8C,$D5,$D9,$B5,$A9,$FB,$14,$68,$A7,$10,$51,$56,$71,$E2,$AB,
        	 $7C,$95,$DF,$D1,$5B,$BA,$B6,$F5,$1D,$3C,$C7,$8E,$BE,$C2,$A7,$10,
        	 $47,$41,$A3,$68,$C2,$6A,$13,$CE,$60,$52,$AB,$F0,$3A,$63,$37,$0E,
        	 $62,$50,$1C,$57,$10,$07,$55,$55,$23,$9C,$55,$42,$DD,$E4,$C3,$38,
        	 $55,$8A,$C3,$35,$57,$F4,$B0,$32,$86,$9F,$24,$C6,$24,$CE,$63,$47,
        	 $FF,$2F,$5D,$E8,$7A,$BA,$4B,$E8,$6C,$E9,$0A,$76,$AD,$A0,$EA,$1C,
        	 $96,$07,$25,$CE,$22,$DE,$6C,$4E,$A0,$5F,$EA,$5A,$E2,$6B,$A3,$E7,
        	 $1E,$15,$CC,$C0,$A8,$17,$07,$6A,$13,$AE,$9A,$9C,$C1,$04,$2B,$B2,
        	 $6D,$30,$DE,$B2,$CF,$DA,$23,$66,$4B,$57,$5E,$5D,$92,$12,$6A,$B3,
        	 $71,$47,$CB,$2B,$1F,$84,$D6,$A5,$A6,$B6,$88,$F2,$1A,$6A,$62,$85,
        	 $4F,$B0,$3B,$DC,$B5,$EE,$40,$E9,$07,$D9,$A0,$D6,$A4,$D0,$75,$2B,
        	 $44,$7A,$FC,$31,$43,$5C,$F4,$7C,$C9,$49,$E1,$54,$80,$62,$A1,$E9,
        	 $81,$5A,$97,$0B,$60,$DC,$F1,$18,$97,$D1,$E5,$D4,$CD,$B7,$C0,$C6,
        	 $AC,$42,$14,$61,$F9,$6B,$98,$90,$CF,$29,$15,$6D,$95,$53,$96,$56,
        	 $30,$D9,$91,$41,$74,$66,$51,$F3,$CB,$14,$C7,$06,$18,$4D,$0A,$31,
        	 $7C,$6D,$3E,$99,$9C,$1A,$D5,$6D,$1F,$E2,$E8,$0B,$5C,$F1,$94,$1D,
        	 $1B,$4E,$28,$82,$FB,$75,$98,$67,$AD,$1B,$F6,$30,$54,$57,$E8,$4A,
        	 $20,$AF,$0B,$DA,$43,$D7,$48,$3F,$4C,$76,$1A,$1D,$C6,$F3,$AC,$09,
        	 $A7,$EA,$28,$03,$AC,$24,$14,$D8,$96,$5E,$21,$9F,$62,$3C,$6D,$2D,
        	 $62,$8A,$25,$D8,$5A,$28,$AA,$6E,$78,$71,$D0,$86,$41,$71,$CC,$09,
        	 $74,$22,$B4,$E5,$D4,$A7,$C7,$7A,$68,$3D,$14,$C5,$53,$B6,$18,$D3,
        	 $F6,$5B,$C8,$D4,$51,$0B,$0C,$D4,$E0,$A4,$76,$C3,$6E,$4D,$5D,$C2,
        	 $46,$F1,$BA,$3E,$89,$BC,$7F,$4D,$A6,$67,$AF,$49,$05,$16,$EC,$AA,
        	 $68,$53,$EC,$8E,$1E,$34,$7F,$2E,$DD,$D6,$13,$8C,$7E,$DF,$E7,$D5,
        	 $55,$2D,$D4,$80,$5C,$91,$16,$7A,$A7,$0E,$8F,$75,$53,$6C,$90,$C9,
        	 $03,$57,$70,$86,$0B,$7C,$4B,$1F,$B6,$AE,$DB,$9D,$50,$D6,$88,$DC,
        	 $84,$EF,$37,$C9,$CD,$C6,$0E,$1F,$B2,$46,$EC,$61,$EB,$92,$7D,$10,
        	 $BE,$67,$08,$BB,$C5,$B8,$10,$56,$06,$D1,$F9,$D7,$9D,$19,$67,$03,
        	 $93,$6D,$10,$F3,$3D,$AA,$4C,$6A,$05,$F6,$24,$C6,$79,$30,$6A,$21,
        	 $54,$15,$EA,$9B,$7C,$08,$D5,$EE,$65,$DB,$35,$17,$78,$42,$A1,$1A,
        	 $8C,$28,$2D,$C6,$11,$23,$65,$0D,$99,$C3,$96,$0B,$C5,$0D,$A2,$FB,
        	 $CA,$DA,$BC,$80,$3B,$B2,$20,$74,$78,$C4,$C6,$CC,$11,$AF,$E2,$84,
        	 $22,$CA,$20,$B6,$2E,$2F,$57,$50,$17,$72,$0D,$38,$8F,$00,$71,$E0,
        	 $1C,$E0,$0E,$31,$0D,$70,$1A,$05,$56,$E1,$CB,$DC,$C5,$7C,$58,$E1,
        	 $35,$69,$5E,$FC,$7E,$60,$1C,$BE,$D7,$D7,$B6,$11,$52,$B1,$2D,$3A,
        	 $70,$43,$E0,$99,$BF,$3B,$B1,$AD,$8F,$C2,$27,$83,$D1,$75,$C3,$89,
        	 $C8,$B7,$C4,$76,$EB,$EF,$03,$13,$98,$0A,$79,$F6,$BC,$BA,$CB,$58,
        	 $FC,$1C,$83,$3A,$34,$4E,$8E,$0A,$F5,$E2,$9A,$AE,$B9,$C5,$B1,$EB,
        	 $62,$4F,$98,$17,$EA,$AE,$D1,$51,$E1,$B7,$50,$B5,$CD,$C6,$D3,$E6,
        	 $3D,$77,$13,$8C,$92,$40,$8C,$EB,$CE,$20,$B4,$E9,$35,$BE,$1E,$1A,
        	 $64,$DD,$C8,$5E,$B1,$AE,$25,$E8,$78,$62,$80,$02,$C6,$4D,$10,$68,
        	 $E2,$86,$71,$9F,$79,$71,$43,$9A,$D0,$B6,$75,$4C,$D3,$AE,$25,$B1,
        	 $CF,$FF,$1D,$FF,$A2,$70,$0B,$99,$8E,$2B,$1B,$12,$CD,$FB,$5B,$A2,
        	 $8A,$49,$1C,$51,$6E,$24,$27,$18,$79,$FD,$15,$7D,$DA,$E6,$66,$5F,
        	 $C3,$14,$36,$86,$57,$31,$C7,$FE,$0C,$3D,$38,$E5,$F5,$60,$84,$F9,
        	 $14,$8F,$21,$10,$83,$28,$60,$48,$3E,$30,$96,$A0,$BC,$14,$C7,$19,
        	 $E8,$5F,$93,$DC,$87,$AD,$64,$1C,$8C,$BC,$1A,$47,$B5,$6C,$78,$3A,
        	 $10,$55,$FC,$B8,$CF,$3D,$B7,$C0,$50,$F7,$81,$0A,$C7,$09,$59,$E3,
        	 $A8,$E2,$A0,$F9,$AA,$90,$67,$E8,$1E,$75,$D2,$63,$94,$F5,$F5,$FD,
        	 $3E,$78,$C5,$92,$50,$A7,$78,$5E,$14,$15,$10,$C6,$69,$E4,$D9,$8A,
        	 $DE,$6E,$6E,$EB,$03,$EA,$B7,$B1,$F3,$D0,$3D,$07,$59,$87,$F9,$3A,
        	 $CE,$B3,$C1,$BB,$7F,$18,$2E,$75,$10,$5E,$74,$0E,$93,$61,$5C,$48,
        	 $40,$A3,$B7,$F5,$25,$31,$65,$AD,$E2,$F4,$FC,$F2,$1D,$7D,$5B,$7F,
        	 $DD,$63,$14,$B9,$4F,$A1,$6C,$7D,$92,$41,$3E,$A5,$11,$BF,$9F,$50,
        	 $97,$A1,$49,$ED,$A6,$A3,$5E,$41,$2E,$A0,$1D,$F0,$9C,$E4,$D5,$8B,
        	 $EC,$03,$89,$B2,$D9,$24,$13,$63,$99,$57,$EB,$0C,$35,$D8,$25,$18,
        	 $AF,$0A,$1D,$78,$AA,$5B,$62,$B7,$FA,$A2,$B6,$AA,$AF,$78,$8C,$AD,
        	 $98,$8F,$66,$24,$FA,$B0,$24,$AC,$89,$55,$2F,$53,$14,$C7,$22,$BA,
        	 $AD,$A2,$6D,$C1,$A1,$F9,$95,$F3,$C8,$D1,$24,$A6,$AE,$4F,$6E,$31,
        	 $5C,$6B,$18,$2A,$3C,$A5,$E5,$D5,$0A,$1F,$40,$75,$1F,$B1,$1C,$B5,
        	 $CF,$8B,$71,$8A,$5D,$B2,$19,$EA,$ED,$98,$45,$BD,$FA,$E7,$EA,$8C,
        	 $D3,$69,$6C,$79,$BA,$BB,$1C,$C3,$86,$B1,$9F,$18,$55,$44,$F2,$98,
        	 $01,$BF,$00,$57,$08,$7D,$E0,$03,$DA,$98,$40,$5A,$38,$00,$E5,$D8,
        	 $D2,$5D,$74,$C5,$25,$7B,$12,$79,$C4,$A7,$9A,$47,$F5,$4E,$68,$A7,
        	 $28,$C6,$B6,$49,$ED,$98,$35,$C9,$9A,$DA,$86,$ED,$02,$BB,$25,$39,
        	 $EA,$30,$FC,$DD,$AA,$17,$47,$D0,$F8,$50,$27,$F7,$1F,$57,$A1,$8D,
        	 $34,$65,$25,$52,$44,$AA,$9B,$46,$85,$28,$4D,$0A,$EA,$49,$DC,$8A,
        	 $5D,$74,$D0,$BB,$78,$AA,$E7,$95,$11,$BB,$2D,$75,$C3,$99,$D2,$36,
        	 $31,$A7,$0A,$AA,$0F,$11,$DC,$12,$F3,$8C,$74,$44,$30,$FE,$2E,$B0,
        	 $A3,$B7,$18,$11,$E5,$5F,$A5,$05,$FE,$AB,$24,$94,$DF,$20,$46,$33,
        	 $39,$0A,$D4,$4A,$84,$E6,$C8,$47,$8C,$F7,$3D,$27,$1A,$01,$E3,$45,
        	 $2D,$A2,$96,$E0,$F0,$CA,$3C,$65,$4D,$68,$83,$A8,$F6,$97,$58,$CA,
        	 $6A,$4B,$0D,$5B,$15,$54,$5C,$73,$97,$C3,$E2,$6A,$14,$8E,$8E,$29,
        	 $70,$30,$8C,$9B,$AF,$06,$16,$A0,$BF,$7E,$EC,$5E,$2F,$69,$6F,$39,
        	 $1C,$53,$9E,$18,$EF,$26,$57,$B0,$B1,$4C,$69,$17,$A0,$C9,$D8,$45,
        	 $3C,$4F,$4A,$5D,$B8,$48,$7E,$3A,$94,$67,$DF,$87,$1A,$57,$F4,$33,
        	 $F6,$90,$0D,$1F,$11,$7A,$D9,$D9,$D2,$53,$E6,$7F,$38,$7F,$92,$EA,
        	 $30,$76,$62,$9D,$D0,$FB,$28,$E2,$68,$81,$7B,$FF,$05,$A7,$B9,$B8,
        	 $24,$9E,$85,$7F,$8C,$2A,$FF,$29,$8D,$D8,$47,$AD,$96,$8F,$18,$6F,
        	 $3A,$1F,$EA,$AB,$FA,$55,$9E,$47,$BE,$C3,$32,$ED,$54,$D4,$F3,$6B,
        	 $D0,$17,$52,$94,$04,$2B,$49,$7D,$C2,$84,$D6,$63,$0D,$D9,$35,$69,
        	 $23,$D4,$9A,$86,$4B,$B1,$7E,$97,$7C,$D7,$79,$DA,$0C,$76,$71,$54,
        	 $10,$6A,$58,$DE,$D4,$EF,$E8,$44,$D8,$D6,$FF,$49,$74,$AD,$05,$CC,
        	 $8F,$46,$F9,$20,$66,$C2,$B6,$5E,$67,$9C,$CB,$BA,$E6,$5E,$A8,$F2,
        	 $6D,$7D,$5D,$02,$45,$A9,$BF,$0F,$58,$C3,$D7,$EB,$A1,$71,$61,$2D,
        	 $54,$92,$4A,$D2,$A6,$FE,$82,$D5,$6C,$F4,$F9,$C7,$44,$AA,$F9,$B3,
        	 $70,$73,$37,$EC,$19,$EB,$28,$BC,$DB,$75,$E7,$2C,$BA,$61,$C4,$DA,
        	 $D1,$A7,$E0,$92,$12,$6A,$44,$39,$68,$16,$D4,$86,$B6,$AF,$C9,$23,
        	 $D0,$51,$72,$E1,$C4,$38,$9E,$E6,$F0,$FC,$57,$79,$85,$D3,$C6,$B5,
        	 $FB,$CE,$61,$4D,$EA,$C6,$CC,$A7,$29,$32,$2E,$96,$B0,$63,$A6,$AC,
        	 $A0,$D9,$17,$98,$17,$05,$38,$9C,$A3,$E6,$3F,$3B,$37,$6C,$72,$87,
        	 $43,$98,$8E,$1D,$C6,$6B,$1E,$E3,$45,$30,$0A,$A8,$3C,$D7,$2A,$C2,
        	 $0D,$47,$94,$A3,$D6,$08,$72,$B5,$EA,$C5,$31,$9B,$3B,$94,$7A,$D3,
        	 $A9,$68,$07,$4C,$38,$AD,$D0,$00,$AB,$BF,$3D,$99,$13,$8A,$E8,$F1,
        	 $22,$1F,$27,$07,$2C,$5D,$E5,$CD,$66,$59,$EB,$0B,$0C,$62,$9E,$AC,
        	 $F2,$97,$E1,$79,$46,$90,$89,$11,$FB,$18,$18,$2F,$3B,$DB,$BC,$05,
        	 $59,$7B,$11,$0A,$B9,$EE,$F9,$E3,$46,$4C,$19,$47,$11,$E0,$F5,$B7,
        	 $31,$19,$3D,$46,$B6,$F5,$BB,$23,$CE,$6D,$6D,$3B,$D6,$CD,$1A,$94,
        	 $6E,$95,$E6,$22,$31,$F2,$EC,$2A,$2F,$68,$F3,$D2,$98,$48,$0C,$C1,
        	 $BC,$AD,$F7,$05,$12,$6C,$05,$8C,$CB,$9E,$AF,$1A,$B6,$41,$01,$E3,
        	 $B2,$BD,$8D,$ED,$84,$E2,$AB,$68,$4D,$6D,$79,$B6,$CA,$49,$DD,$BB,
        	 $D5,$4E,$B3,$BE,$99,$D4,$19,$E7,$B2,$B1,$14,$CE,$C4,$08,$9A,$8B,
        	 $F0,$D0,$35,$64,$89,$B6,$9E,$01,$B5,$AC,$71,$33,$CE,$C8,$17,$36,
        	 $CA,$36,$D8,$25,$31,$CE,$06,$D5,$19,$10,$2E,$21,$37,$77,$40,$DB,
        	 $41,$04,$33,$76,$CA,$58,$D5,$76,$30,$77,$E3,$A8,$E1,$41,$F4,$59,
        	 $14,$3F,$CD,$94,$02,$9C,$72,$E5,$A3,$39,$08,$46,$5A,$4A,$77,$40,
        	 $5B,$97,$F5,$DA,$FE,$3C,$A3,$ED,$A9,$86,$DA,$CA,$AB,$65,$BE,$15,
        	 $23,$46,$36,$10,$C6,$6F,$86,$95,$71,$91,$B6,$E8,$14,$DC,$F5,$8C,
        	 $05,$E7,$C6,$77,$A0,$65,$9D,$C6,$8C,$DD,$D9,$45,$5A,$58,$D1,$12,
        	 $60,$C0,$FB,$E0,$27,$9B,$E0,$CC,$E0,$88,$A0,$45,$45,$2F,$57,$3F,
        	 $CE,$CC,$F6,$CF,$66,$63,$E9,$8B,$0E,$37,$BB,$D9,$B2,$DE,$28,$D3,
        	 $BE,$5D,$93,$54,$A8,$58,$8F,$75,$CF,$BD,$68,$43,$93,$45,$9F,$42,
        	 $8E,$BB,$C0,$5C,$0B,$CF,$0D,$85,$C0,$1D,$BD,$77,$0F,$45,$F6,$0B,
        	 $DE,$83,$09,$B6,$C2,$E9,$A4,$FB,$02,$5B,$B1,$4D,$3D,$AF,$F6,$43,
        	 $29,$2B,$1A,$DC,$1C,$3A,$B4,$5E,$BB,$B3,$99,$73,$D9,$7D,$A9,$94,
        	 $4D,$A7,$5E,$D1,$1B,$3E,$62,$40,$57,$D5,$0E,$73,$C4,$69,$37,$97,
        	 $BC,$79,$B2,$18,$1A,$C3,$64,$10,$E0,$A4,$C9,$05,$51,$16,$26,$D1,
        	 $F7,$53,$98,$7D,$DC,$C0,$2E,$EA,$39,$AE,$53,$FE,$15,$A8,$F2,$04,
        	 $26,$07,$A6,$34,$7E,$62,$02,$4F,$42,$8C,$47,$B9,$13,$59,$3A,$93,
        	 $07,$49,$C1,$2A,$6A,$57,$39,$BD,$6F,$0D,$7B,$33,$BE,$24,$26,$58,
        	 $8F,$FD,$DE,$A0,$94,$09,$63,$42,$8D,$42,$89,$B7,$62,$43,$36,$9E,
        	 $18,$CA,$83,$7D,$46,$FE,$00,$13,$99,$D4,$7D,$41,$F3,$9E,$59,$25,
        	 $86,$AF,$8D,$94,$BF,$A0,$DE,$86,$A7,$29,$A2,$CE,$D6,$A4,$3A,$E3,
        	 $78,$66,$16,$9F,$6F,$B9,$ED,$66,$1E,$3E,$24,$5C,$67,$48,$0D,$E8,
        	 $8E,$09,$CD,$B5,$4E,$E4,$AE,$39,$8D,$0A,$6D,$25,$50,$46,$BD,$C7,
        	 $22,$17,$95,$C0,$8E,$88,$09,$A5,$36,$C1,$0F,$3E,$A7,$2E,$6B,$CB,
        	 $F4,$CC,$50,$DC,$D1,$40,$54,$29,$6B,$93,$F8,$7A,$4A,$23,$DF,$43,
        	 $3E,$66,$F7,$5D,$F8,$A3,$BF,$69,$4B,$C7,$D2,$D3,$CE,$66,$2C,$8F,
        	 $FD,$01,$33,$8B,$A6,$2F,$AE,$F5,$FD,$65,$1E,$CB,$BC,$77,$3A,$96,
        	 $29,$73,$52,$AF,$22,$A6,$06,$79,$2F,$9F,$B7,$79,$CD,$63,$8E,$DD,
        	 $92,$C8,$0D,$15,$58,$37,$2A,$A9,$1F,$CC,$92,$B0,$21,$D1,$9D,$69,
        	 $47,$A2,$E9,$58,$12,$3F,$66,$0C,$C7,$70,$EA,$67,$EC,$0F,$63,$05,
        	 $ED,$31,$03,$EA,$8E,$39,$F4,$A3,$EC,$B9,$DC,$FD,$24,$39,$C1,$F5,
        	 $10,$69,$7D,$54,$0E,$CB,$F4,$4E,$6B,$5E,$5C,$82,$7E,$AD,$87,$36,
        	 $24,$F2,$2F,$4C,$21,$8F,$FF,$C7,$32,$9C,$91,$4C,$79,$24,$97,$49,
        	 $DB,$40,$F5,$63,$C6,$9E,$3D,$6F,$F7,$B7,$A6,$0F,$65,$7A,$EC,$09,
        	 $8D,$B6,$39,$7A,$D7,$4B,$EF,$BE,$C3,$4A,$BB,$79,$39,$79,$DF,$6D,
        	 $B1,$66,$FB,$0F,$65,$9F,$36,$37,$63,$4D,$0A,$69,$25,$E5,$31,$AC,
        	 $D2,$3E,$16,$C5,$13,$51,$84,$98,$A5,$32,$9D,$4E,$83,$5C,$7F,$5B,
        	 $44,$9E,$80,$DE,$F1,$54,$A5,$C7,$8C,$D9,$5C,$6B,$BA,$35,$FD,$5D,
        	 $9C,$FA,$2E,$63,$51,$6A,$00,$23,$68,$3C,$93,$FE,$AD,$7B,$C6,$6A,
        	 $4D,$DF,$4D,$1E,$30,$5F,$E3,$DD,$98,$A2,$C4,$58,$43,$A5,$25,$B4,
        	 $02,$26,$4F,$23,$18,$4D,$20,$D0,$45,$59,$AA,$6F,$4C,$25,$9A,$10,
        	 $DE,$9E,$FC,$98,$41,$F9,$1A,$72,$4E,$E4,$AE,$E2,$2E,$DD,$8C,$DE,
        	 $BC,$57,$A1,$BC,$3E,$65,$19,$3A,$1B,$30,$8A,$9A,$60,$B4,$66,$8C,
        	 $1C,$E2,$50,$97,$42,$6B,$A1,$DB,$50,$32,$7A,$AF,$10,$67,$0C,$53,
        	 $27,$C1,$28,$02,$DF,$47,$35,$5F,$7F,$FB,$B5,$1B,$C5,$67,$18,$A7,
        	 $A7,$93,$0F,$7A,$6F,$EB,$1F,$31,$90,$8D,$6E,$EC,$A8,$CB,$7A,$07,
        	 $E6,$D0,$32,$EA,$E9,$AE,$DB,$9A,$0D,$9A,$78,$6A,$44,$39,$C1,$F3,
        	 $1A,$ED,$7C,$51,$CC,$F3,$04,$B6,$D8,$26,$C5,$E7,$45,$D1,$E8,$31,
        	 $E6,$BC,$5C,$79,$6F,$C3,$A4,$6A,$E8,$93,$0C,$EF,$54,$4E,$F7,$D8,
        	 $B7,$F5,$BC,$16,$C6,$BC,$2A,$6A,$ED,$66,$85,$A3,$D2,$B0,$13,$A2,
        	 $6E,$B0,$4B,$BE,$2A,$9A,$B4,$F5,$E2,$37,$07,$B4,$03,$D8,$F2,$7B,
        	 $EC,$37,$DD,$BB,$BD,$52,$DA,$C8,$C6,$32,$C7,$33,$82,$B9,$0C,$9F,
        	 $02,$4A,$A8,$5E,$93,$EF,$7B,$67,$BA,$F6,$39,$C6,$EC,$60,$BB,$55,
        	 $86,$0F,$51,$D5,$6E,$3C,$E1,$A6,$FE,$6F,$FA,$8A,$FE,$53,$9E,$50,
        	 $2F,$A0,$9E,$9E,$D3,$C2,$6C,$5E,$18,$93,$E8,$D9,$06,$B4,$CD,$C3,
        	 $CD,$66,$BB,$35,$E4,$4C,$27,$DF,$4C,$22,$C2,$F4,$9B,$C9,$03,$46,
        	 $91,$25,$54,$8A,$9F,$18,$37,$3D,$CE,$E2,$13,$18,$87,$72,$97,$92,
        	 $67,$9C,$1E,$FB,$05,$E7,$BA,$BB,$2F,$BD,$0F,$95,$F6,$13,$3B,$96,
        	 $79,$C1,$A6,$B7,$BB,$51,$28,$C4,$07,$7F,$DA,$A8,$34,$61,$FF,$AE,
        	 $8A,$E3,$C2,$AB,$98,$F7,$11,$EC,$E9,$6F,$F7,$3F,$82,$DE,$BD,$0D,
        	 $AD,$68,$4B,$BD,$93,$DC,$84,$8A,$D6,$F6,$57,$43,$F4,$24,$70,$E6,
        	 $A8,$E8,$CF,$32,$8E,$E7,$86,$1D,$FA,$9B,$56,$D0,$1C,$72,$7E,$E9,
        	 $DE,$73,$EF,$BB,$AE,$7D,$BF,$57,$30,$E0,$AC,$30,$D9,$9B,$B0,$41,
        	 $6E,$EC,$6F,$84,$8E,$DD,$0A,$A1,$5E,$F1,$55,$42,$3D,$62,$41,$EF,
        	 $3C,$C5,$3B,$9E,$7A,$37,$39,$64,$2D,$73,$1B,$8C,$52,$88,$DE,$21,
        	 $79,$D5,$FF,$39,$C6,$A3,$13,$3F,$73,$CF,$38,$97,$92,$D3,$C9,$6F,
        	 $22,$FA,$AE,$EC,$EC,$E0,$0F,$B3,$99,$5C,$B3,$41,$73,$24,$C1,$56,
        	 $63,$8C,$61,$A7,$8D,$4D,$EA,$51,$CC,$ED,$79,$69,$5C,$2C,$EB,$E7,
        	 $72,$EF,$E1,$7A,$BB,$FF,$BD,$1C,$A9,$77,$6B,$8A,$76,$EB,$12,$E5,
        	 $68,$3F,$BD,$69,$1A,$60,$9F,$8F,$E3,$EB,$D9,$8B,$C8,$D5,$B0,$73,
        	 $C6,$B9,$9F,$BC,$D6,$DB,$9A,$79,$A5,$BF,$35,$73,$3C,$2B,$98,$7B,
        	 $4D,$A8,$34,$5B,$D0,$E3,$EA,$4B,$FA,$72,$EC,$79,$D4,$44,$23,$94,
        	 $60,$5E,$2A,$F2,$43,$99,$F7,$FA,$67,$73,$8F,$72,$B3,$20,$3D,$9B,
        	 $D9,$97,$62,$2A,$65,$A9,$1A,$5A,$F4,$62,$E8,$56,$E3,$EC,$B3,$8C,
        	 $CF,$7E,$BC,$32,$F8,$4C,$FA,$BA,$FB,$AD,$DC,$8C,$73,$BF,$F7,$5D,
        	 $77,$52,$BB,$A3,$63,$12,$6A,$13,$1A,$6D,$C5,$71,$96,$47,$0F,$BE,
        	 $DD,$FF,$C0,$7D,$25,$6B,$64,$7E,$9C,$79,$36,$7B,$3C,$FD,$6C,$EE,
        	 $A2,$5D,$84,$1A,$41,$B5,$11,$49,$6D,$3F,$9D,$FF,$1F,$66,$DC,$EF,
        	 $7D,$D0,$FB,$8E,$3B,$ED,$4C,$3B,$D7,$92,$F4,$36,$F7,$39,$9A,$F2,
        	 $4C,$A5,$BF,$B9,$21,$13,$05,$6D,$36,$F7,$AD,$F4,$6C,$EE,$C7,$99,
        	 $4C,$F6,$44,$E6,$EB,$A8,$60,$D7,$A2,$B7,$E3,$75,$86,$CF,$53,$8C,
        	 $3F,$C4,$A0,$8F,$7D,$D9,$69,$E7,$99,$74,$6B,$E6,$7E,$EF,$3D,$F7,
        	 $12,$B2,$38,$62,$5F,$4C,$6E,$C7,$EE,$F7,$16,$B4,$32,$EF,$B0,$A6,
        	 $ED,$6B,$C4,$77,$62,$99,$69,$27,$69,$FE,$B6,$77,$16,$59,$3B,$9E,
        	 $1D,$71,$36,$F5,$01,$AD,$24,$7D,$56,$4B,$BE,$90,$91,$99,$86,$2A,
        	 $3E,$3C,$71,$D7,$BD,$96,$1C,$72,$B8,$D5,$63,$BB,$D0,$E7,$61,$67,
        	 $02,$8A,$D8,$6E,$DE,$45,$7F,$BC,$93,$BC,$9B,$3C,$91,$B9,$E4,$0C,
        	 $59,$FB,$D2,$DF,$CB,$48,$99,$07,$BD,$47,$CC,$32,$B2,$5A,$95,$4A,
        	 $D2,$97,$63,$EC,$7E,$FC,$4B,$7F,$D2,$BC,$E8,$0C,$D9,$6F,$38,$D3,
        	 $2E,$65,$EF,$27,$E8,$BF,$37,$92,$BF,$31,$A9,$52,$7E,$E6,$5C,$4F,
        	 $FE,$54,$DB,$B3,$47,$F6,$6F,$C0,$27,$75,$98,$27,$72,$0F,$DC,$3C,
        	 $E2,$A8,$86,$46,$C5,$AF,$C2,$F8,$61,$B6,$C7,$3E,$63,$FF,$04,$55,
        	 $47,$7F,$E3,$7A,$23,$D9,$61,$9E,$41,$96,$7E,$63,$13,$E3,$0D,$E7,
        	 $6E,$6F,$85,$9B,$81,$9A,$10,$57,$57,$A1,$6D,$FB,$D2,$EF,$24,$8B,
        	 $9C,$A2,$98,$FB,$4A,$8C,$3F,$F4,$F1,$CA,$E9,$50,$C3,$9E,$86,$DD,
        	 $FF,$87,$41,$E2,$A7,$37,$49,$66,$C3,$FF,$27,$E3,$5B,$39,$D3,$EF,
        	 $51,$1A,$E4,$06,$FA,$CB,$09,$BD,$A9,$1A,$0D,$98,$7E,$62,$FC,$2F,
        	 $D6,$C8,$E8,$F6);

type
    TColor = Cardinal;

    TColorKmpn = record
        case boolean of
            False: (c: TColor);
            True: (r, g, b, a: byte);
    end;

    TColIndex = record
        ci: TCHAR_INFO;
        cc: TColorKmpn;
    end;

function CalcTPxColor(const i, j: integer; const lComp_2, lComp_1, lComp2, lComp1: word): TColorKmpn;

var
    ColIdx: array of TColIndex;
    istcol: array[0..79, 0..49] of TColorKmpn;
    chh: array[0..79, 0..49] of Word;

implementation

uses
    Toro.PasZlib;

const
    maxanim = 500;
    Filler = #$b0#$b1#$b2#$db;

var
    i, j, k, l, found: integer;
    cc: TColorKmpn;
    chi: TCHAR_INFO;


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

type
    TchinfArr = array of TCHAR_INFO;

procedure FlushScreen(const sb: TchinfArr);

var
    srctReadRect: TRect;
    coordBufSize, coordBufCoord: TPoint;
begin
    srctReadRect.Top := 0; // top left: row 0, col 0
    srctReadRect.Left := 0;
    srctReadRect.Bottom := 49; // bot. right: row 1, col 79
    srctReadRect.Right := 79;

    coordBufSize.x := 80;
    coordBufSize.y := 50;

    coordBufCoord.x := 0;
    coordBufCoord.y := 0;

    console.WriteConsoleOutput(
        sb[0], // buffer to copy into
        coordbufSize, // col-row size of chiBuffer
        coordBufCoord, // top left dest. cell in chiBuffer
        srctReadRect); // screen buffer source rectangle
end;

function CalcTPxColor(const i, j: integer; const lComp_2, lComp_1, lComp2, lComp1: word): TColorKmpn;
begin
    Result.r := (i and $4) shr $2 * lComp_2 + (i and $8) shr $3 * lComp_1 +
        (j and $4) shr $2 * lComp2 + (J and $8) shr $3 * lComp1;
    Result.g := (i and $2) shr $1 * lComp_2 + (i and $8) shr $3 * lComp_1 +
        (j and $2) shr $1 * lComp2 + (J and $8) shr $3 * lComp1;
    Result.b := (i and $1) shr $0 * lComp_2 + (i and $8) shr $3 * lComp_1 +
        (j and $1) shr $0 * lComp2 + (J and $8) shr $3 * lComp1;
end;



procedure Execute(const aGraph: TGraphic = nil);

var
    mb, bew: extended;
    rc: TColorKmpn;
    hashtab: array[0..32768] of word;
    sb: TchinfArr;

    bmp: TPortableNetworkGraphic;
    ll: cardinal;

begin
    ll:=8000;
    paszlib.uncompress(@chh[0,0],ll,@jc[0],length(jc));
      try
        TextMode(co80 + font8x8);
        // init
        for I := 0 to 15 do
            for J := 0 to 15 do
                for K := 4 downto 1 do
                  begin
                    chi.AsciiChar := filler[K];
                    chi.Attributes := i + J * 16;
                    cc := CalcTPxColor(i, j, CComp[K, -2], CComp[K, -1], CComp[K, 2], CComp[K, 1]);

                    // append Coloridx
                    found := -1;
                    for L := 0 to high(ColIdx) do
                        if cc.c = colIdx[L].cc.c then
                          begin
                            found := L;
                            break;
                          end;
                    if found = -1 then
                      begin
                        setlength(colIdx, high(colidx) + 2);
                        colidx[high(colidx)].ci := chi;
                        colidx[high(colidx)].cc := cc;
                      end;

                  end;

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
          end;
        fillchar(istcol{%H-}, sizeof(istcol), byte(0));
        if not assigned(aGraph) then
          begin
            writeln('Press Enter to Start');
            readln;
          end;
        GotoY(49);
        setlength(sb, 80 * 50);
      //  setlength(chh, 80 * 50);
        //          For I := 0 To maxanim Do
          begin
            for J := 0 to 79 do
                for K := 0 to 49 do
                  begin
                   (* rc.c := bmp.Canvas.Pixels[J div 2 + 6, K];
                    {if (J > 0) and (k > 0) then
                        rc := ColorSubtr(rc, istcol[j - 1, k - 1]);}
                    if K > 0 then
                        rc := ColorSubtr(rc, istcol[j, k - 1]);
                    if J > 0 then
                        cc := ColorSubtr(rc, istcol[j - 1, k])
                    else  //}
                        cc := rc;
                    // cc := ColorSubtr(rc, istcol[j , k]);
                    chh[j, k ] := colorhash(cc);// *)
                    chi := colidx[hashtab[chh[j, k ]]].ci;
                    sb[j + k * 80] := chi;
                    istcol[j, k] := colidx[hashtab[chh[j, k ]]].cc;
                  end;
            FlushScreen(sb);
            delay(10);
          end;
        FreeAndNil(bmp);
        if not assigned(aGraph) then
          begin
            Printl('Press Enter');
            readln;
          end;

      except
        On E: Exception do
            Writeln(E.ClassName, ': ', E.Message);
      end;
end;

end.
