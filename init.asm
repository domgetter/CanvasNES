DisableAPUInterrupt:

  LDA #$40
  STA $4017
  RTS

DisableDMCInterrupt:

  LDA #$00
  STA $4010
  RTS

WaitForNextVBlank:

:
  BIT $2002
  BPL :-
  RTS

DisableRendering:

  LDA #$00
  STA $2000
  STA $2001
  RTS

InitializePPURAM:

@ClearCharacterTables:
  LDA $2002
  LDA #$00
  STA $2006
  STA $2006

  LDA #$00
  LDX #$00
  LDY #$00
:
  STA $2007
  INX
  BNE :-
  INY
  CPY #$20
  BNE :-

@ClearNametables:
  LDA $2002
  LDA #$20
  STA $2006
  LDA #$00
  STA $2006

  LDA #$00
  LDX #$00
  LDY #$00
:
  STA $2007
  INX
  BNE :-
  INY
  CPY #$08
  BNE :-

@ClearPalettes:
  LDA $2002
  LDA #$3F
  STA $2006
  LDA #$00
  STA $2006

  LDA #$0F
  LDX #$00
:
  STA $2007
  INX
  CPX #$20
  BNE :-

  RTS

LoadChars:

  LDA $2002
  LDA #$00
  STA $2006
  STA $2006

  LDX #$00
:
  LDA BackgroundChars, X
  STA $2007
  INX
  BNE :-

  LDX #$00
:
  LDA BackgroundChars+$0100, X
  STA $2007
  INX
  BNE :-

  LDX #$00
:
  LDA BackgroundChars+$0200, X
  STA $2007
  INX
  BNE :-

  LDX #$00
:
  LDA BackgroundChars+$0300, X
  STA $2007
  INX
  BNE :-

  LDX #$00
:
  LDA BackgroundChars+$0400, X
  STA $2007
  INX
  BNE :-

  LDX #$00
:
  LDA BackgroundChars+$0500, X
  STA $2007
  INX
  BNE :-

  LDX #$00
:
  LDA BackgroundChars+$0600, X
  STA $2007
  INX
  BNE :-

  LDX #$00
:
  LDA BackgroundChars+$0700, X
  STA $2007
  INX
  BNE :-

  LDX #$00
:
  LDA BackgroundChars+$0800, X
  STA $2007
  INX
  BNE :-

  LDX #$00
:
  LDA BackgroundChars+$0900, X
  STA $2007
  INX
  BNE :-

  LDX #$00
:
  LDA BackgroundChars+$0A00, X
  STA $2007
  INX
  BNE :-

  LDX #$00
:
  LDA BackgroundChars+$0B00, X
  STA $2007
  INX
  BNE :-

  LDX #$00
:
  LDA BackgroundChars+$0C00, X
  STA $2007
  INX
  BNE :-

  LDX #$00
:
  LDA BackgroundChars+$0D00, X
  STA $2007
  INX
  BNE :-

  LDX #$00
:
  LDA BackgroundChars+$0E00, X
  STA $2007
  INX
  BNE :-

  LDX #$00
:
  LDA BackgroundChars+$0F00, X
  STA $2007
  INX
  BNE :-

  ; In MMC1, sometimes the bank isn't correctly set
  ;  Need to figure this out.
  ;  I think this is caused by not setting any banks in the init code before this.
  ;   So we need to set the banks to have known state.
LoadSprites:
  LDA $2002
  LDA #$10
  STA $2006
  LDA #$00
  STA $2006

  LDX #$00
:
  LDA BackgroundChars+$1000, X
  STA $2007
  INX
  BNE :-

:
  LDA BackgroundChars+$1100, X
  STA $2007
  INX
  CPX #$70
  BNE :-

  RTS

LoadBackground:
  LDA $2002
  LDA #$20
  STA $2006
  LDA #$00
  STA $2006

  LDX #$00
:
  LDA BaseNametable0, X
  STA $2007
  INX
  BNE :-

  LDX #$00
:
  LDA BaseNametable0+$0100, X
  STA $2007
  INX
  BNE :-

  LDX #$00
:
  LDA BaseNametable0+$0200, X
  STA $2007
  INX
  BNE :-

  LDX #$00
:
  LDA BaseNametable0+$0300, X
  STA $2007
  INX
  CPX #$C0
  BNE :-

  LDA #$24
  STA $2006
  LDA #$00
  STA $2006

  LDX #$00
:
  LDA BaseNametable1, X
  STA $2007
  INX
  BNE :-

  LDX #$00
:
  LDA BaseNametable1+$0100, X
  STA $2007
  INX
  BNE :-

  LDX #$00
:
  LDA BaseNametable1+$0200, X
  STA $2007
  INX
  BNE :-

  LDX #$00
:
  LDA BaseNametable1+$0300, X
  STA $2007
  INX
  CPX #$C0
  BNE :-

  RTS

LoadPalette:

  LDA $2002
  LDA #$3F
  STA $2006
  LDA #$00
  STA $2006

  LDX #$00
:
  LDA BasePalette, X
  STA $2007
  STA current_palette, X
  INX
  CPX #$20
  BNE :-
  RTS

LoadAttributes:
  LDA $2002
  LDA #$23
  STA $2006
  LDA #$C0
  STA $2006

  LDX #$00
:
  LDA BaseAttributes0, X
  STA $2007
  INX
  CPX #$40
  BNE :-

  LDA $2002
  LDA #$27
  STA $2006
  LDA #$C0
  STA $2006

  LDX #$00
:
  LDA BaseAttributes1, X
  STA $2007
  INX
  CPX #$40
  BNE :-

  RTS

InitializeSprites:
  
  ; main cursor top left
  ; y coord
  LDA #$12
  STA $0204

  ; oam index
  LDA #$00
  STA $0205

  ; attrs
  LDA #$00
  STA $0206

  ; x coord
  LDA #$60
  STA $0207
  
  ; main cursor bottom right
  ; y coord
  LDA #$17
  STA $0208

  ; oam index
  LDA #$00
  STA $0209

  ; attrs
  LDA #$C0
  STA $020A

  ; x coord
  LDA #$65
  STA $020B
  
  ; palette cursor top left
  ; y coord
  LDA #$2F
  STA $020C

  ; oam index
  LDA #$01
  STA $020D

  ; attrs
  LDA #$00
  STA $020E

  ; x coord
  LDA #$C0
  STA $020F
  
  ; palette cursor bottom right
  ; y coord
  LDA #$37
  STA $0210

  ; oam index
  LDA #$01
  STA $0211

  ; attrs
  LDA #$C0
  STA $0212

  ; x coord
  LDA #$C8
  STA $0213
  
  ; 0-sprite for bank switching
  ; y coord
  LDA #$3D
  STA $0200

  ; oam index
  LDA #$02
  STA $0201

  ; attrs
  LDA #$00
  STA $0202

  ; x coord
  LDA #$F1
  STA $0203


  RTS

InitializeMMC1:
  ; Reset MMC1 shift register
  LDA #$80
  STA $8000

  ; write 5 bits one bit at a time
  ;  with each bit in the last slot
  ; Set MMC1 to 32K PRG ROM
  ;              4k CHR RAM*2
  ; 4bit0
  ; -----
  ; CPPMM
  ; |||||
  ; |||++- Mirroring (0: one-screen, lower bank; 1: one-screen, upper bank;
  ; |||               2: vertical; 3: horizontal)
  ; |++--- PRG ROM bank mode (0, 1: switch 32 KB at $8000, ignoring low bit of bank number;
  ; |                         2: fix first bank at $8000 and switch 16 KB bank at $C000;
  ; |                         3: fix last bank at $C000 and switch 16 KB bank at $8000)
  ; +----- CHR ROM bank mode (0: switch 8 KB at a time; 1: switch two separate 4 KB banks)
  LDA #%00010010
  STA $8000
  LSR
  STA $8000
  LSR
  STA $8000
  LSR
  STA $8000
  LSR
  STA $8000
  LDA #$00
  STA $A000
  LSR
  STA $A000
  LSR
  STA $A000
  LSR
  STA $A000
  LSR
  STA $A000
  LDA #$01
  STA $C000
  LSR
  STA $C000
  LSR
  STA $C000
  LSR
  STA $C000
  LSR
  STA $C000
  RTS

LoadAllChars:

  JSR LoadChars
  LDA #$02
  STA $A000
  LSR
  STA $A000
  LSR
  STA $A000
  LSR
  STA $A000
  LSR
  STA $A000
  JSR LoadChars
  LDA #$04
  STA $A000
  LSR
  STA $A000
  LSR
  STA $A000
  LSR
  STA $A000
  LSR
  STA $A000
  JSR LoadChars
  LDA #$06
  STA $A000
  LSR
  STA $A000
  LSR
  STA $A000
  LSR
  STA $A000
  LSR
  STA $A000
  JSR LoadChars
  LDA #$00
  STA $A000
  LSR
  STA $A000
  LSR
  STA $A000
  LSR
  STA $A000
  LSR
  STA $A000
  RTS

  ;;;;;;;;; RESET ;;;;;;;;;

RESET:
  ; Initialize stack
  LDX #$FF
  TXS

  JSR InitializeMMC1
  JSR DisableAPUInterrupt
  JSR DisableDMCInterrupt
  JSR WaitForNextVBlank
  JSR DisableRendering

InitializeCPURAM:

  LDX #$00
:
  LDA #$00
  STA $0000, x
  STA $0100, x
  STA $0300, x
  STA $0400, x
  STA $0500, x
  STA $0600, x
  STA $0700, x
  LDA #$FF
  STA $0200, x
  INX
  BNE :-

  JSR InitializePPURAM
  JSR LoadAllChars
  JSR LoadBackground
  JSR LoadPalette
  JSR LoadAttributes

  LDA $2002
  LDA #$00
  STA $2006
  STA $2006

  STA $2005
  STA $2005

  JSR WaitForNextVBlank

  LDA #%10001000
  STA $2000
  LDA #%00011010
  STA $2001

  JSR InitializeSprites

  ; set palette choice to 1
  LDA #$01
  STA current_color

  ; set mode to 0 (canvas)
  LDA mode::canvas
  STA current_mode
  STA previous_mode

  ; initialize canvas and palette cursor positions
  LDA #$12
  STA cursor + Cursor::y_coord
  LDA #$60
  STA cursor + Cursor::x_coord

  LDA #$2F
  STA palette_cursor + Cursor::y_coord
  LDA #$C0
  STA palette_cursor + Cursor::x_coord

  JMP Main