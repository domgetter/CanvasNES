NMI:

    JSR VBLModeSelect
    
    LDA #$01
    STA vblank_happened
    RTI

VBLModeTargets:
    .word CanvasVBL-1
    .word CanvasToPaletteSelectVBL-1
    .word PaletteSelectVBL-1
    .word PaletteSelectToCanvasVBL-1

VBLModeSelect:
    LDA current_mode
    ASL
    TAX
    LDA VBLModeTargets+1,X
    PHA
    LDA VBLModeTargets,X
    PHA

    RTS
  
UpdateAttributeTable:

  ; attr byte is $23C0 + (x / 4) + 8*(y / 4)

  ; now figure out which of the 4 tiles within a block we have
  ; and do 4 cases to update the appropriate 2 bits

  LDA $2002
  LDA #$23
  STA $2006
  LDA attr_byte_address
  STA $2006
  ; Dummy read to flush read buffer
  LDA $2007
  LDA $2007
  STA attr_byte_value
  LDA tile_index_within_block
  CMP #$00
  BNE @not0
  LDA current_color
  CMP #$00
  BEQ @in_attr_0_bg
  
  LSR
  LSR
  CMP #$00
  BEQ @in_attr_0_pal_1
  CMP #$01
  BEQ @in_attr_0_pal_2
  CMP #$02
  BEQ @in_attr_0_pal_3
@in_attr_0_bg:
  ; do nothing
  JMP @done_in_attr_0
@in_attr_0_pal_1:
  ; set fourth pair of bits to "00"
  LDA attr_byte_value
  AND #%11111100
  STA attr_byte_value
  JMP @done_in_attr_0
@in_attr_0_pal_2:
  ; set fourth pair of bits to "01"
  LDA attr_byte_value
  AND #%11111101
  ORA #%00000001
  STA attr_byte_value

  JMP @done_in_attr_0
@in_attr_0_pal_3:
  ; set fourth pair of bits to "10"
  LDA attr_byte_value
  AND #%11111110
  ORA #%00000010
  STA attr_byte_value

@done_in_attr_0:
  JMP @done_block_within_attr
@not0:
  CMP #$01
  BNE @not1
  LDA current_color
  CMP #$00
  BEQ @in_attr_1_bg
  
  LSR
  LSR
  CMP #$00
  BEQ @in_attr_1_pal_1
  CMP #$01
  BEQ @in_attr_1_pal_2
  CMP #$02
  BEQ @in_attr_1_pal_3
@in_attr_1_bg:
  ; do nothing
  JMP @done_in_attr_1
@in_attr_1_pal_1:
  ; set third pair of bits to "00"
  LDA attr_byte_value
  AND #%11110011
  STA attr_byte_value
  JMP @done_in_attr_1
@in_attr_1_pal_2:
  ; set third pair of bits to "01"
  LDA attr_byte_value
  AND #%11110111
  ORA #%00000100
  STA attr_byte_value

  JMP @done_in_attr_1
@in_attr_1_pal_3:
  ; set third pair of bits to "10"
  LDA attr_byte_value
  AND #%11111011
  ORA #%00001000
  STA attr_byte_value

@done_in_attr_1:
  JMP @done_block_within_attr
@not1:
  CMP #$02
  BNE @not2
  LDA current_color
  CMP #$00
  BEQ @in_attr_2_bg
  
  LSR
  LSR
  CMP #$00
  BEQ @in_attr_2_pal_1
  CMP #$01
  BEQ @in_attr_2_pal_2
  CMP #$02
  BEQ @in_attr_2_pal_3
@in_attr_2_bg:
  ; do nothing
  JMP @done_in_attr_2
@in_attr_2_pal_1:
  ; set second pair of bits to "00"
  LDA attr_byte_value
  AND #%11001111
  STA attr_byte_value
  JMP @done_in_attr_0
@in_attr_2_pal_2:
  ; set second pair of bits to "01"
  LDA attr_byte_value
  AND #%11011111
  ORA #%00010000
  STA attr_byte_value

  JMP @done_in_attr_2
@in_attr_2_pal_3:
  ; set second pair of bits to "10"
  LDA attr_byte_value
  AND #%11101111
  ORA #%00100000
  STA attr_byte_value

@done_in_attr_2:
  JMP @done_block_within_attr
@not2:
  LDA current_color
  CMP #$00
  BEQ @in_attr_3_bg
  
  LSR
  LSR
  CMP #$00
  BEQ @in_attr_3_pal_1
  CMP #$01
  BEQ @in_attr_3_pal_2
  CMP #$02
  BEQ @in_attr_3_pal_3
@in_attr_3_bg:
  ; do nothing
  JMP @done_in_attr_3
@in_attr_3_pal_1:
  ; set first pair of bits to "00"
  LDA attr_byte_value
  AND #%00111111
  STA attr_byte_value
  JMP @done_in_attr_3
@in_attr_3_pal_2:
  ; set first pair of bits to "01"
  LDA attr_byte_value
  AND #%01111111
  ORA #%01000000
  STA attr_byte_value

  JMP @done_in_attr_3
@in_attr_3_pal_3:
  ; set first pair of bits to "10"
  LDA attr_byte_value
  AND #%10111111
  ORA #%10000000
  STA attr_byte_value

@done_in_attr_3:
@done_block_within_attr:

  LDA $2002
  LDA #$23
  STA $2006
  LDA attr_byte_address
  STA $2006
  LDA attr_byte_value
  STA $2007
  RTS

UpdateTileInVRAM:
  
  ; switch chr bank
  LDA current_bank
  ASL
  STA $A000
  LSR
  STA $A000
  LSR
  STA $A000
  LSR
  STA $A000
  LSR
  STA $A000

  JSR UpdateAttributeTable
  LDA tile_index_in_canvas_within_bank
  CLC
  ADC #$80
  STA tile_index_in_canvas_within_bank
  AND #%11110000
  LSR
  LSR
  LSR
  LSR
  STA new_tile_address_high
  LDA tile_index_in_canvas_within_bank
  ASL
  ASL
  ASL
  ASL
  CLC
  ADC y_mod_8
  ; $30, $31 now contain the long address in vram of the tile
  STA new_tile_address_low

  ; load x%8 which corresponds to which bitmask is chosen
  LDX x_mod_8

  ; Reset PPUADDR latch
  LDA $2002

  ; set VRAM address to contents of $30, $31
  LDA new_tile_address_high
  STA $2006
  LDA new_tile_address_low
  STA $2006
  ; dummy read to flush interal read buffer in PPU
  LDA $2007
  ; if bg or first, AND with bitmask
  ; if second or third, ORA with complement
  LDA current_color
  AND #%00000011
  AND #$01
  BNE :+
  ; 0 or 1
  LDA bitmask, X
  AND $2007
  JMP :++
:
  ; 2 or 3
  LDA bitmask_complement, X
  ORA $2007
:
  ; store new value, reset vram address, and write new value
  STA new_char_val_plane_1
  LDA new_tile_address_high
  STA $2006
  LDA new_tile_address_low
  STA $2006
  LDA new_char_val_plane_1
  STA $2007

  ; now do the same 8 bytes later
  LDA new_tile_address_low
  CLC
  ADC #$08
  STA new_tile_address_low
  LDA new_tile_address_high
  STA $2006
  LDA new_tile_address_low
  STA $2006
  ; dummy read to flush interal read buffer in PPU
  LDA $2007
  LDA current_color
  AND #%00000011
  CMP #$02
  BCS :+
  ; 0 or 2
  LDA bitmask, X
  AND $2007
  JMP :++
:
  ; 1 or 3
  LDA bitmask_complement, X
  ORA $2007
:

  ; save newval2, reset vram address, and store newval2
  STA new_char_val_plane_2
  LDA new_tile_address_high
  STA $2006
  LDA new_tile_address_low
  STA $2006
  LDA new_char_val_plane_2
  STA $2007
  
  ; reset to chr bank 0
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

bitmask:
  .byte %01111111, %10111111, %11011111, %11101111, %11110111, %11111011, %11111101, %11111110

bitmask_complement:
  .byte %10000000, %01000000, %00100000, %00010000, %00001000, %00000100, %00000010, %00000001
