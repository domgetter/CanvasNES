CalculateAttributeTileInfo:
  ; RAM: R/W
  ; OAM: R
  ; Stack: None
  ; PPU: None
  ; APU: None
  ; Dependencies: None

    LDA cursor + Cursor::y_coord

    ; add height of sprite, accounting for sprite render +1
    CLC
    ADC #$01

    CMP #$10
    BCC @outside_canvas
    CMP #$D0
    BCS @outside_canvas
    LDA cursor + Cursor::x_coord
    CMP #$10
    BCC @outside_canvas
    CMP #$B0
    BCS @outside_canvas
    
  @within_canvas:
    ; Load y coord of cursor
    LDA cursor + Cursor::y_coord

    ; add height of sprite, accounting for sprite render +1
    CLC
    ADC #$01
    divmod #$08
    STX cursor_tile_row
    LDA cursor_tile_row
    LSR
    LSR
    ASL
    ASL
    ASL
    STA cursor_attr_byte_row

    LDA cursor + Cursor::x_coord
    divmod #$08
    STX cursor_tile_column
    LDA cursor_tile_column
    LSR
    LSR
    CLC
    ADC cursor_attr_byte_row
    ADC #$C0
    STA attr_byte_address

    LDA cursor_tile_row
    LSR
    AND #$01
    ASL
    STA tile_index_within_block
    LDA cursor_tile_column
    LSR
    AND #$01
    ORA tile_index_within_block
    STA tile_index_within_block

    RTS
  @outside_canvas:
    RTS

CheckForModifyCanvas:
  ; RAM: W
  ; OAM: R
  ; Stack: W
  ; PPU: None
  ; APU: None
  ; Dependencies: DetermineBank

    LDA cursor + Cursor::y_coord

    CLC
    ADC #$01
    CMP #CANVAS_TOP
    BCC @no_modify_canvas

    ; canvas bottom
    CMP #CANVAS_BOTTOM
    BCS @no_modify_canvas

    ; load cursor x coord
    LDA cursor + Cursor::x_coord

    ; canvas left
    CMP #CANVAS_LEFT
    BCC @no_modify_canvas

    ; canvas right
    CMP #CANVAS_RIGHT
    BCS @no_modify_canvas
  @modify_canvas:
    LDA #$01
    STA within_canvas_bounds

    ; Determine which quadrant we're in
    JSR DetermineBank

    JMP @after_no_modify_canvas
  @no_modify_canvas:
    LDA #$00
    STA within_canvas_bounds
  @after_no_modify_canvas:
    RTS

DetermineBank:
  ; RAM: W
  ; OAM: R
  ; Stack: None
  ; PPU: None
  ; APU: None
  ; Dependencies: None

    LDA cursor + Cursor::y_coord
    SEC
    ; Subtract y offset of canvas (16), accounting for size of sprite (6) and y-1 render
    SBC #$10 - 1
    CMP #$30

    BCS @after_first_bank
  @within_first_bank:
    STA y_coord_canvas_within_bank
    LDA #$00
    STA current_bank
    RTS
  @after_first_bank:
    
    SEC
    SBC #$30
    CMP #$30
    BCS @after_second_bank
  @within_second_bank:
    STA y_coord_canvas_within_bank
    LDA #$01
    STA current_bank
    RTS
  @after_second_bank:

    SEC
    SBC #$30
    CMP #$30
    BCS @after_third_bank
  @within_third_bank:
    STA y_coord_canvas_within_bank
    LDA #$02
    STA current_bank
    RTS
  @after_third_bank:
    
    SEC
    SBC #$30
    STA y_coord_canvas_within_bank
    LDA #$03
    STA current_bank

    RTS

CheckIfAPressed:
  ; RAM: R/W
  ; OAM: None
  ; Stack: None
  ; PPU: None
  ; APU: None
  ; Dependencies: None

    LDA joypad_buttons
    AND #JOYPAD_A
    BNE @a_pressed
  @no_a_pressed:
    LDA #$00
    JMP @after_a_pressed
  @a_pressed:
    LDA #$01
  @after_a_pressed:
    STA a_pressed_last_frame
    RTS

CheckIfLeftMousePressed:
  ; RAM: R/W
  ; OAM: None
  ; Stack: None
  ; PPU: None
  ; APU: None
  ; Dependencies: None

    LDA mouse_status
    AND #LEFT_MOUSE_PRESSED
    BNE :+
    LDA #$00
    JMP :++
  : LDA #$01
  : STA left_mouse_pressed_last_frame
    RTS

CheckIfRightMousePressed:
  ; RAM: R/W
  ; OAM: None
  ; Stack: None
  ; PPU: None
  ; APU: None
  ; Dependencies: None

    LDA mouse_status
    AND #RIGHT_MOUSE_PRESSED
    BNE :+
    LDA #$00
    JMP :++
  : LDA #$01
  : STA right_mouse_pressed_last_frame
    RTS

CheckIfSelectPressed:
  ; RAM: R/W
  ; OAM: None
  ; Stack: None
  ; PPU: None
  ; APU: None
  ; Dependencies: None

    LDA joypad_buttons
    AND #JOYPAD_SELECT
    BNE @select_pressed
  @no_select_pressed:
    LDA #$00
    LDX #$00
    JMP @after_select_pressed
  @select_pressed:
    LDA select_being_held
    BNE @except_when_already_pressed
    LDA #$01
    LDX #$01
    JMP @after_select_pressed
  @except_when_already_pressed:
    LDA #$00
    LDX #$01
  @after_select_pressed:
    
    STA select_pressed_last_frame
    STX select_being_held
    RTS

CheckIfUpPressed:
  ; RAM: R/W
  ; OAM: None
  ; Stack: None
  ; PPU: None
  ; APU: None
  ; Dependencies: None

    LDA joypad_buttons
    AND #JOYPAD_UP
    BNE @up_pressed
  @no_up_pressed:
    LDA #$00
    LDX #$00
    JMP @after_up_pressed
  @up_pressed:
    LDA up_being_held
    BNE @except_when_already_pressed
    LDA #$01
    LDX #$01
    JMP @after_up_pressed
  @except_when_already_pressed:
    LDA #$00
    LDX #$01
  @after_up_pressed:
    
    STA up_pressed_last_frame
    STX up_being_held
    RTS

CheckIfDownPressed:
  ; RAM: R/W
  ; OAM: None
  ; Stack: None
  ; PPU: None
  ; APU: None
  ; Dependencies: None

    LDA joypad_buttons
    AND #JOYPAD_DOWN
    BNE @down_pressed
  @no_down_pressed:
    LDA #$00
    LDX #$00
    JMP @after_down_pressed
  @down_pressed:
    LDA down_being_held
    BNE @except_when_already_pressed
    LDA #$01
    LDX #$01
    JMP @after_down_pressed
  @except_when_already_pressed:
    LDA #$00
    LDX #$01
  @after_down_pressed:
    
    STA down_pressed_last_frame
    STX down_being_held
    RTS

CheckIfLeftPressed:
  ; RAM: R/W
  ; OAM: None
  ; Stack: None
  ; PPU: None
  ; APU: None
  ; Dependencies: None

    LDA joypad_buttons
    AND #JOYPAD_LEFT
    BNE @left_pressed
  @no_left_pressed:
    LDA #$00
    LDX #$00
    JMP @after_left_pressed
  @left_pressed:
    LDA left_being_held
    BNE @except_when_already_pressed
    LDA #$01
    LDX #$01
    JMP @after_left_pressed
  @except_when_already_pressed:
    LDA #$00
    LDX #$01
  @after_left_pressed:
    
    STA left_pressed_last_frame
    STX left_being_held
    RTS

CheckIfRightPressed:
  ; RAM: R/W
  ; OAM: None
  ; Stack: None
  ; PPU: None
  ; APU: None
  ; Dependencies: None

    LDA joypad_buttons
    AND #JOYPAD_RIGHT
    BNE @right_pressed
  @no_right_pressed:
    LDA #$00
    LDX #$00
    JMP @after_right_pressed
  @right_pressed:
    LDA right_being_held
    BNE @except_when_already_pressed
    LDA #$01
    LDX #$01
    JMP @after_right_pressed
  @except_when_already_pressed:
    LDA #$00
    LDX #$01
  @after_right_pressed:
    
    STA right_pressed_last_frame
    STX right_being_held
    RTS

TileNumberInCanvas:
  ; RAM: R/W
  ; OAM: R
  ; Stack: None
  ; PPU: None
  ; APU: None
  ; Dependencies: None

    LDA cursor + Cursor::x_coord
    SEC
    ; Subtract x offset of canvas (16), accounting for size of sprite (6)
    SBC #$10
    STA x_coord_canvas

    LDA y_coord_canvas_within_bank
    divmod #$08
    STX tile_row_in_canvas_within_bank
    STA y_mod_8

    ; now calculate *20
    ; first *16, then add itself 4 times
    LDA tile_row_in_canvas_within_bank
    ASL
    ASL
    ASL
    ASL
    CLC
    ADC tile_row_in_canvas_within_bank
    ADC tile_row_in_canvas_within_bank
    ADC tile_row_in_canvas_within_bank
    ADC tile_row_in_canvas_within_bank

    ; tile_row_in_canvas_within_bank now has 20*(y/8)
    STA tile_row_in_canvas_within_bank

    ; now calculate x / 8 and x % 8
    LDA x_coord_canvas
    divmod #$08
    STX tile_column_in_canvas
    STA x_mod_8

    LDA tile_column_in_canvas
    CLC
    ADC tile_row_in_canvas_within_bank
    STA tile_index_in_canvas_within_bank
    RTS

ChoosePalette:
  ; RAM: R/W
  ; OAM: R/W
  ; Stack: None
  ; PPU: None
  ; APU: None
  ; Dependencies: None

    LDA a_pressed_last_frame
    ORA left_mouse_pressed_last_frame
    BEQ @above_palette_selector
    LDA cursor + Cursor::y_coord

    ; add height of cursor
    CLC
    ADC #$01
    CMP #$20
    BCC @above_palette_selector
    CMP #$30
    BCC @in_background_selector
    CMP #$40
    BCC @in_first_palette_row
    CMP #$50
    BCC @in_second_palette_row
    CMP #$60
    BCC @in_third_palette_row
  @below_palette_selector:
  @above_palette_selector:
    RTS
  @in_background_selector:
    LDA cursor + Cursor::x_coord

    ; add width of cursor
    CMP #$C0
    BCC @left_of_palette_selector
    CMP #$F0
    BCC @within_bg_selector
    RTS
  @within_bg_selector:
    JMP ChangePaletteCursorToBG
  @in_first_palette_row:
    JMP FirstPaletteRow
  @in_second_palette_row:
    JMP SecondPaletteRow
  @in_third_palette_row:
    JMP ThirdPaletteRow
  @left_of_palette_selector:
    RTS

  ChangePaletteCursorToBG:
    ; set currently selected palette
    LDA #$00
    STA current_color

    LDA #$1F
    STA palette_cursor + Cursor::y_coord
    LDA #$C0
    STA palette_cursor + Cursor::x_coord

    LDA #$01
    STA palette_cursor_on_bg
    RTS

  FirstPaletteRow:

    LDA cursor + Cursor::x_coord

    ; add width of cursor
    CMP #$C0
    BCC @left_of_row_1
    CMP #$D0
    BCC @in_palette_row_1_col_1
    CMP #$E0
    BCC @in_palette_row_1_col_2
    CMP #$F0
    BCC @in_palette_row_1_col_3
    RTS
  @in_palette_row_1_col_1:
    
    ; set currently selected palette
    LDA #$01
    STA current_color

    LDA #$2F
    STA palette_cursor + Cursor::y_coord
    LDA #$C0
    STA palette_cursor + Cursor::x_coord

    LDA #$00
    STA palette_cursor_on_bg
    RTS
  @in_palette_row_1_col_2:

    
    ; set currently selected palette
    LDA #$02
    STA current_color

    LDA #$2F
    STA palette_cursor + Cursor::y_coord
    LDA #$D0
    STA palette_cursor + Cursor::x_coord

    LDA #$00
    STA palette_cursor_on_bg
    RTS
  @in_palette_row_1_col_3:
    
    ; set currently selected palette
    LDA #$03
    STA current_color

    LDA #$2F
    STA palette_cursor + Cursor::y_coord
    LDA #$E0
    STA palette_cursor + Cursor::x_coord

    LDA #$00
    STA palette_cursor_on_bg
    RTS
  @left_of_row_1:
    RTS

  SecondPaletteRow:

    LDA cursor + Cursor::x_coord

    ; add width of cursor
    CMP #$C0
    BCC @left_of_row_2
    CMP #$D0
    BCC @in_palette_row_2_col_1
    CMP #$E0
    BCC @in_palette_row_2_col_2
    CMP #$F0
    BCC @in_palette_row_2_col_3
    RTS
  @in_palette_row_2_col_1:
    
    ; set currently selected palette
    LDA #$05
    STA current_color

    LDA #$3F
    STA palette_cursor + Cursor::y_coord
    LDA #$C0
    STA palette_cursor + Cursor::x_coord

    LDA #$00
    STA palette_cursor_on_bg
    RTS
  @in_palette_row_2_col_2:
    
    ; set currently selected palette
    LDA #$06
    STA current_color

    LDA #$3F
    STA palette_cursor + Cursor::y_coord
    LDA #$D0
    STA palette_cursor + Cursor::x_coord

    LDA #$00
    STA palette_cursor_on_bg
    RTS
  @in_palette_row_2_col_3:
    
    ; set currently selected palette
    LDA #$07
    STA current_color

    LDA #$3F
    STA palette_cursor + Cursor::y_coord
    LDA #$E0
    STA palette_cursor + Cursor::x_coord

    LDA #$00
    STA palette_cursor_on_bg
    RTS

  @left_of_row_2:
    RTS
  ThirdPaletteRow:

    LDA cursor + Cursor::x_coord

    ; add width of cursor
    CMP #$C0
    BCC @left_of_row_3
    CMP #$D0
    BCC @in_palette_row_3_col_1
    CMP #$E0
    BCC @in_palette_row_3_col_2
    CMP #$F0
    BCC @in_palette_row_3_col_3
    RTS
  @in_palette_row_3_col_1:
    
    ; set currently selected palette
    LDA #$09
    STA current_color

    LDA #$4F
    STA palette_cursor + Cursor::y_coord
    LDA #$C0
    STA palette_cursor + Cursor::x_coord

    LDA #$00
    STA palette_cursor_on_bg
    RTS
  @in_palette_row_3_col_2:
    
    ; set currently selected palette
    LDA #$0A
    STA current_color

    LDA #$4F
    STA palette_cursor + Cursor::y_coord
    LDA #$D0
    STA palette_cursor + Cursor::x_coord

    LDA #$00
    STA palette_cursor_on_bg
    RTS
  @in_palette_row_3_col_3:
    
    ; set currently selected palette
    LDA #$0B
    STA current_color

    LDA #$4F
    STA palette_cursor + Cursor::y_coord
    LDA #$E0
    STA palette_cursor + Cursor::x_coord

    LDA #$00
    STA palette_cursor_on_bg
    RTS

  @left_of_row_3:
    RTS

OAMDMA:
  ; RAM: W
  ; OAM: R
  ; Stack: None
  ; PPU: W
  ; APU: None
  ; Dependencies: None

    LDA #$00
    STA $2003
    LDA #$02
    STA $4014

    RTS

CanvasVBL:
  ; RAM: R/W
  ; OAM: R
  ; Stack: W
  ; PPU: W
  ; APU: None
  ; Dependencies: OAMDMA, CheckSelectForColorChange, UpdateTileInVRAM

    JSR OAMDMA
    ; If A is pressed, and the cursor is within the canvas,
    ;   we must update the color in CHR RAM
    ; If A is pressed, but the cursor is over the palette,
    ;   we must update the current palette selection
    LDA a_pressed_last_frame
    ORA left_mouse_pressed_last_frame
    STA either_button_pressed

    LDA within_canvas_bounds
    AND either_button_pressed
    BNE @modify_canvas
    JMP @after_modify_canvas
  @modify_canvas:
    LDA current_bank
    JSR UpdateTileInVRAM
  @after_modify_canvas:

    ;;; Set Palettes ;;;

    JSR RefreshBackgroundPalettes

    ;;; Reset VRAM address and scroll ;;;

    LDA $2002
    LDA #$00
    STA $2006
    STA $2006
    STA $2005
    STA $2005

    LDA #%10001000
    STA $2000

    LDA select_pressed_last_frame
    CMP #$01
    BNE :+
    LDA #mode::palette_select
    STA current_mode
  :
    RTS

CanvasToPaletteSelectVBL:
    RTS

PaletteSelectVBL:

    JSR OAMDMA
    JSR RefreshBackgroundPalettes
    JSR RefreshSpritePalettes

    LDA $2002
    LDA #$00
    STA $2006
    STA $2006
    STA $2005
    STA $2005

    LDA #%10001001
    STA $2000

    LDA select_pressed_last_frame
    CMP #$01
    BNE :+
    LDA #mode::canvas
    STA current_mode
  :
    RTS

PaletteSelectToCanvasVBL:
    RTS

ReadControllers:
  ; RAM: R/W
  ; OAM: None
  ; Stack: None
  ; PPU: None
  ; APU: None
  ; Dependencies: None

    LDA #$00
    STA joypad_buttons

    LDA #$01
    STA $4016
    LDA #$00
    STA $4016

    LDX #$00
  :
    LDA $4016
    AND #$01
    CLC
    ORA joypad_buttons
    ROL
    STA joypad_buttons
    INX
    CPX #$07
    BNE :-
    LDA $4016
    AND #$01
    ORA joypad_buttons
    STA joypad_buttons

  ; read mouse bits from controller port 2

    LDA #$00
    STA mouse_status
    STA mouse_x_displacement
    STA mouse_y_displacement
  ; ignore first byte
  ; 76543210  First byte
  ; ++++++++- Always zero: 00000000
    LDX #$08
  :
    NOP
    NOP
    NOP
    LDA $4017
    DEX
    BNE :-
    NOP
    NOP
    NOP
  
  ; get buttons, sensitivity, and signature
  ;
  ; 76543210  Second byte
  ; ||||++++- Signature: 0001
  ; ||++----- Current sensitivity (0: low; 1: medium; 2: high)
  ; |+------- Left button (1: pressed)
  ; +-------- Right button (1: pressed)
    LDX #$07
  :
    LDA $4017
    NOP
    NOP
    NOP
    AND #$01
    CLC
    ORA mouse_status
    ROL
    STA mouse_status
    DEX
    BNE :-
    LDA $4017
    AND #$01
    ORA mouse_status
    STA mouse_status
  
  ; get vertical displacement
  ;
  ; 76543210  Third byte
  ; |+++++++- Vertical displacement since last read
  ; +-------- Direction (1: up; 0: down)
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    LDX #$07
  :
    LDA $4017
    NOP
    NOP
    NOP
    AND #$01
    CLC
    ORA mouse_y_displacement
    ROL
    STA mouse_y_displacement
    DEX
    BNE :-
    LDA $4017
    AND #$01
    ORA mouse_y_displacement
    STA mouse_y_displacement
  
  ; get horizontal displacement
  ;
  ; 76543210  Fourth byte
  ; |+++++++- Horizontal displacement since last read
  ; +-------- Direction (1: left; 0: right)
    NOP
    NOP
    LDX #$07
  :
    LDA $4017
    NOP
    NOP
    NOP
    AND #$01
    CLC
    ORA mouse_x_displacement
    ROL
    STA mouse_x_displacement
    DEX
    BNE :-
    LDA $4017
    AND #$01
    ORA mouse_x_displacement
    STA mouse_x_displacement

    RTS

CalculateCursorMotion:
  ; RAM: R/W
  ; OAM: None
  ; Stack: None
  ; PPU: None
  ; APU: None
  ; Dependencies: None

    LDA joypad_buttons
    AND #%00001000
    BNE @dpad_up_pressed
    JMP :+
  @dpad_up_pressed:
    DEC cursor + Cursor::y_coord
    JMP @dpad_updown_movement_done
  :
    LDA joypad_buttons
    AND #%00000100
    BNE @dpad_down_pressed
    JMP :+
  @dpad_down_pressed:
    INC cursor + Cursor::y_coord
    JMP @dpad_updown_movement_done
  :

  @dpad_updown_movement_done:
    LDA joypad_buttons
    AND #%00000010
    BNE @dpad_left_pressed
    JMP :+
  @dpad_left_pressed:
    DEC cursor + Cursor::x_coord
    JMP @dpad_movement_done
  :

    LDA joypad_buttons
    AND #%00000001
    BNE @dpad_right_pressed
    JMP :+
  @dpad_right_pressed:
    INC cursor + Cursor::x_coord
    JMP @dpad_movement_done
  :
  @dpad_movement_done:

    LDA mouse_status
    AND #$0F
    CMP #$01
    BNE @movement_done
    LDA mouse_y_displacement
    AND #$80
    BEQ @move_down
  @move_up:

    ; strip displacement sign
    LDA mouse_y_displacement
    AND #$7F
    STA mouse_y_displacement

    ; calculate cursor - displacement
    LDA cursor + Cursor::y_coord
    SEC
    SBC mouse_y_displacement
    STA cursor + Cursor::y_coord
    JMP @move_updown_done
  @move_down:
    ; calculate cursor + displacement
    LDA cursor + Cursor::y_coord
    CLC
    ADC mouse_y_displacement
    STA cursor + Cursor::y_coord

  @move_updown_done:

    LDA mouse_x_displacement
    AND #$80
    BEQ @move_right
  @move_left:

    ; strip displacement sign
    LDA mouse_x_displacement
    AND #$7F
    STA mouse_x_displacement

    ; calculate cursor - displacement
    LDA cursor + Cursor::x_coord
    SEC
    SBC mouse_x_displacement
    STA cursor + Cursor::x_coord
    JMP @move_rightleft_done

  @move_right:

    ; calculate cursor + displacement
    LDA cursor + Cursor::x_coord
    CLC
    ADC mouse_x_displacement
    STA cursor + Cursor::x_coord
  @move_rightleft_done:
  @movement_done:
    RTS

WriteCursorSprites:
  ; RAM: R
  ; OAM: W
  ; Stack: None
  ; PPU: None
  ; APU: None
  ; Dependencies: None

    LDA cursor + Cursor::y_coord
    SEC
    SBC #$06
    STA $0204
    CLC
    ADC #$05
    STA $0208
    LDA cursor + Cursor::x_coord
    SEC
    SBC #$06
    STA $0207
    CLC
    ADC #$05
    STA $020B

    RTS

WritePaletteCursorSprites:

    LDA palette_cursor + Cursor::y_coord
    STA $020C
    CLC
    ADC #$08
    STA $0210
    LDA palette_cursor + Cursor::x_coord
    STA $020F
    CLC
    LDX palette_cursor_on_bg
    BNE @over_bg
    ADC #$08
    JMP @done_checking_over_bg
  @over_bg:
    ADC #$28
  @done_checking_over_bg:
    STA $0213

    RTS

Write0Sprite:

    LDA #$3D
    STA $0200
  
    RTS

ClearOAM:
  ; completely unrolled:
  ;  258 cycles
  ;  194 bytes
  ;  total: 50,052 cyclebytes
  ; completely rolled:
  ;  1027 cycles
  ;  13 bytes
  ;  total: 13,351 cyclebytes
  ; mid1 unroll (2):
  ;  675 cycles
  ;  17 bytes
  ; mid2 unroll (4):
  ;  499 cycles
  ;  23 bytes
  ; mid3 unroll (8):
  ;  411 cycles
  ;  35 bytes
  ; mid4 unroll (16):
  ;  370 cycles
  ;  59 bytes

    LDX #$00
    CLC
  :
    LDA #$FF
    STA $0200,X
    STA $0204,X
    STA $0208,X
    STA $020C,X
    STA $0210,X
    STA $0214,X
    STA $0218,X
    STA $021C,X
    TXA
    ADC #$20
    TAX
    BNE :-

    RTS

SwitchBanksForFrame:

  @sprite0wait:
    LDA $2002
    AND #$40
    BEQ @sprite0wait

    ; wait until end of next scanline
    LDX #$12
  :
    DEX
    BNE :-

  @first_switch:
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

    LDY #$33
    LDX #$14
  :
    DEX
    BNE :-
    LDX #$14
    DEY
    BNE :-
    LDX #$03
  :
    DEX
    BNE :-
  @second_switch:
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

    LDY #$33
    LDX #$14
  :
    DEX
    BNE :-
    LDX #$14
    DEY
    BNE :-
    LDX #$03
  :
    DEX
    BNE :-
  @third_switch:
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

    LDY #$33
    LDX #$14
  :
    DEX
    BNE :-
    LDX #$14
    DEY
    BNE :-
    LDX #$06
  :
    DEX
    BNE :-
  @final_switch:
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

DelayUntilAfterFirstScanline:
    LDX #$00
  :
    DEX
    BNE :-
    RTS

UpdatePalette:
    LDA up_pressed_last_frame
    BEQ @no_update_up
  @update_up:
    LDX current_color
    INC current_palette,X
    JMP @done_updown_update_palette
  @no_update_up:

    LDA down_pressed_last_frame
    BEQ @done_updown_update_palette
  @update_down:
    LDX current_color
    DEC current_palette,X
  
  @done_updown_update_palette:

    LDA right_pressed_last_frame
    BEQ @no_update_right
  @update_right:
    LDX current_color
    LDA current_palette,X
    CLC
    ADC #$10
    STA current_palette,X
    JMP @done_update_palette
  @no_update_right:

    LDA left_pressed_last_frame
    BEQ @done_update_palette
  @update_left:
    LDX current_color
    LDA current_palette,X
    CLC
    ADC #$10
    STA current_palette,X
  
  @done_update_palette:
    RTS

RefreshBackgroundPalettes:

    LDA $2002
    LDA #$3F
    STA $2006
    LDA #$00
    STA $2006

    LDA current_palette
    STA $2007
    LDA current_palette+1
    STA $2007
    LDA current_palette+2
    STA $2007
    LDA current_palette+3
    STA $2007
    LDA current_palette+4
    STA $2007
    LDA current_palette+5
    STA $2007
    LDA current_palette+6
    STA $2007
    LDA current_palette+7
    STA $2007
    LDA current_palette+8
    STA $2007
    LDA current_palette+9
    STA $2007
    LDA current_palette+10
    STA $2007
    LDA current_palette+11
    STA $2007

    RTS

RefreshSpritePalettes:

    LDA $2002
    LDA #$3F
    STA $2006
    LDA #$14
    STA $2006
    
    LDA current_palette+20
    STA $2007
    LDA current_palette+21
    STA $2007
    LDA current_palette+22
    STA $2007
    LDA current_palette+23
    STA $2007
    LDA current_palette+24
    STA $2007
    LDA current_palette+25
    STA $2007
    LDA current_palette+26
    STA $2007
    LDA current_palette+27
    STA $2007
    LDA current_palette+28
    STA $2007
    LDA current_palette+29
    STA $2007
    LDA current_palette+30
    STA $2007
    LDA current_palette+31
    STA $2007

ResetVRAMAndScroll:

    RTS

CalculateSpritePalette:
  ; Given the cursor position, figure out what 9 colors to put in the spare cursor palette slots

  ; row = cursor.y / 8
  ; column = cursor.x / 8

    LDA cursor + Cursor::y_coord
    CMP #$20
    BCC @palette_selection_OOB
    CMP #$40
    BCS @palette_selection_OOB
    LDA cursor + Cursor::x_coord
    CMP #$40
    BCC @palette_selection_OOB
    CMP #$B0
    BCS @palette_selection_OOB
    JMP @do_palette_selection
  @palette_selection_OOB:
    JMP @skip_palette_selection

  @do_palette_selection:
    LDA cursor + Cursor::x_coord
    SEC
    SBC #$40
    divmod #$08
    STX palette_selector_column

    LDA cursor + Cursor::y_coord
    SEC
    SBC #$20
    divmod #$08
    TXA
    ASL
    ASL
    ASL
    ASL
    STA palette_selector_row

    LDA palette_selector_row
    BNE @add_one_to_palette_selector
    STA palette_selector_row_adder
    JMP @done_add_one_palette_selector
  @add_one_to_palette_selector:
    LDA #$10
    STA palette_selector_row_adder
  @done_add_one_palette_selector:

  ; first sprite
    LDA #$00
    CLC
    ADC palette_selector_column
    CLC
    ADC palette_selector_row_adder
    STA palette_selector_0 + PaletteSelector::color
    LDA palette_selector_column
    ASL
    ASL
    ASL
    CLC
    ADC #$38
    STA palette_selector_0 + PaletteSelector::x_coord
    LDA palette_selector_row_adder
    LSR
    CLC
    ADC #$18
    STA palette_selector_0 + PaletteSelector::y_coord

  ; second sprite
    LDA #$01
    CLC
    ADC palette_selector_column
    CLC
    ADC palette_selector_row_adder
    STA palette_selector_1 + PaletteSelector::color
    LDA palette_selector_column
    ASL
    ASL
    ASL
    CLC
    ADC #$40
    STA palette_selector_1 + PaletteSelector::x_coord
    LDA palette_selector_row_adder
    LSR
    CLC
    ADC #$18
    STA palette_selector_1 + PaletteSelector::y_coord

  ; third sprite
    LDA #$02
    CLC
    ADC palette_selector_column
    CLC
    ADC palette_selector_row_adder
    STA palette_selector_2 + PaletteSelector::color
    LDA palette_selector_column
    ASL
    ASL
    ASL
    CLC
    ADC #$48
    STA palette_selector_2 + PaletteSelector::x_coord
    LDA palette_selector_row_adder
    LSR
    CLC
    ADC #$18
    STA palette_selector_2 + PaletteSelector::y_coord

  ; fourth sprite
    LDA #$10
    CLC
    ADC palette_selector_column
    CLC
    ADC palette_selector_row_adder
    STA palette_selector_3 + PaletteSelector::color
    LDA palette_selector_column
    ASL
    ASL
    ASL
    CLC
    ADC #$38
    STA palette_selector_3 + PaletteSelector::x_coord
    LDA palette_selector_row_adder
    LSR
    CLC
    ADC #$20
    STA palette_selector_3 + PaletteSelector::y_coord

  ; fifth sprite
    LDA #$11
    CLC
    ADC palette_selector_column
    CLC
    ADC palette_selector_row_adder
    STA palette_selector_4 + PaletteSelector::color
    LDA palette_selector_column
    ASL
    ASL
    ASL
    CLC
    ADC #$40
    STA palette_selector_4 + PaletteSelector::x_coord
    LDA palette_selector_row_adder
    LSR
    CLC
    ADC #$20
    STA palette_selector_4 + PaletteSelector::y_coord

  ; sixth sprite
    LDA #$12
    CLC
    ADC palette_selector_column
    CLC
    ADC palette_selector_row_adder
    STA palette_selector_5 + PaletteSelector::color
    LDA palette_selector_column
    ASL
    ASL
    ASL
    CLC
    ADC #$48
    STA palette_selector_5 + PaletteSelector::x_coord
    LDA palette_selector_row_adder
    LSR
    CLC
    ADC #$20
    STA palette_selector_5 + PaletteSelector::y_coord

  ; seventh sprite
    LDA #$20
    CLC
    ADC palette_selector_column
    CLC
    ADC palette_selector_row_adder
    STA palette_selector_6 + PaletteSelector::color
    LDA palette_selector_column
    ASL
    ASL
    ASL
    CLC
    ADC #$38
    STA palette_selector_6 + PaletteSelector::x_coord
    LDA palette_selector_row_adder
    LSR
    CLC
    ADC #$28
    STA palette_selector_6 + PaletteSelector::y_coord

  ; eighth sprite
    LDA #$21
    CLC
    ADC palette_selector_column
    CLC
    ADC palette_selector_row_adder
    STA palette_selector_7 + PaletteSelector::color
    LDA palette_selector_column
    ASL
    ASL
    ASL
    CLC
    ADC #$40
    STA palette_selector_7 + PaletteSelector::x_coord
    LDA palette_selector_row_adder
    LSR
    CLC
    ADC #$28
    STA palette_selector_7 + PaletteSelector::y_coord

  ; ninth sprite
    LDA #$22
    CLC
    ADC palette_selector_column
    CLC
    ADC palette_selector_row_adder
    STA palette_selector_8 + PaletteSelector::color
    LDA palette_selector_column
    ASL
    ASL
    ASL
    CLC
    ADC #$48
    STA palette_selector_8 + PaletteSelector::x_coord
    LDA palette_selector_row_adder
    LSR
    CLC
    ADC #$28
    STA palette_selector_8 + PaletteSelector::y_coord

  @skip_palette_selection:

    RTS

WriteSpritePalette:

    LDA palette_selector_0 + PaletteSelector::color
    STA current_palette+21
    LDA palette_selector_1 + PaletteSelector::color
    STA current_palette+22
    LDA palette_selector_2 + PaletteSelector::color
    STA current_palette+23

    LDA palette_selector_3 + PaletteSelector::color
    STA current_palette+25
    LDA palette_selector_4 + PaletteSelector::color
    STA current_palette+26
    LDA palette_selector_5 + PaletteSelector::color
    STA current_palette+27

    LDA palette_selector_6 + PaletteSelector::color
    STA current_palette+29
    LDA palette_selector_7 + PaletteSelector::color
    STA current_palette+30
    LDA palette_selector_8 + PaletteSelector::color
    STA current_palette+31

    RTS

WritePaletteSprites:
    LDA palette_selector_0 + PaletteSelector::y_coord
    STA $0214

    LDA #$14
    STA $0215

    LDA #$01
    STA $0216

    LDA palette_selector_0 + PaletteSelector::x_coord
    STA $0217
    
    LDA palette_selector_1 + PaletteSelector::y_coord
    STA $0218

    LDA #$15
    STA $0219

    LDA #$01
    STA $021A

    LDA palette_selector_1 + PaletteSelector::x_coord
    STA $021B
    
    LDA palette_selector_2 + PaletteSelector::y_coord
    STA $021C

    LDA #$16
    STA $021D

    LDA #$01
    STA $021E

    LDA palette_selector_2 + PaletteSelector::x_coord
    STA $021F
    
    LDA palette_selector_3 + PaletteSelector::y_coord
    STA $0220

    LDA #$14
    STA $0221

    LDA #$02
    STA $0222

    LDA palette_selector_3 + PaletteSelector::x_coord
    STA $0223
    
    LDA palette_selector_4 + PaletteSelector::y_coord
    STA $0224

    LDA #$15
    STA $0225

    LDA #$02
    STA $0226

    LDA palette_selector_4 + PaletteSelector::x_coord
    STA $0227
    
    LDA palette_selector_5 + PaletteSelector::y_coord
    STA $0228

    LDA #$16
    STA $0229

    LDA #$02
    STA $022A

    LDA palette_selector_5 + PaletteSelector::x_coord
    STA $022B
    
    LDA palette_selector_6 + PaletteSelector::y_coord
    STA $022C

    LDA #$14
    STA $022D

    LDA #$03
    STA $022E

    LDA palette_selector_6 + PaletteSelector::x_coord
    STA $022F
    
    LDA palette_selector_7 + PaletteSelector::y_coord
    STA $0230

    LDA #$15
    STA $0231

    LDA #$03
    STA $0232

    LDA palette_selector_7 + PaletteSelector::x_coord
    STA $0233
    
    LDA palette_selector_8 + PaletteSelector::y_coord
    STA $0234

    LDA #$16
    STA $0235

    LDA #$03
    STA $0236

    LDA palette_selector_8 + PaletteSelector::x_coord
    STA $0237
    
    RTS


; End of Subroutine definitions