CANVAS_TOP = $10
CANVAS_BOTTOM = $D0
CANVAS_LEFT = $10
CANVAS_RIGHT = $B0
LEFT_MOUSE_PRESSED = %01000000
RIGHT_MOUSE_PRESSED = %10000000
JOYPAD_UP = %00001000
JOYPAD_DOWN = %00000100
JOYPAD_LEFT = %00000001
JOYPAD_RIGHT = %00000010
JOYPAD_SELECT = %00100000
JOYPAD_START = %00010000
JOYPAD_A = %10000000

.ENUM mode
  canvas
  canvas_to_palette_select
  palette_select
  palette_select_to_canvas
.ENDENUM

.STRUCT Sprite
  y_coord .byte
  index .byte
  attrs .byte
  x_coord .byte
.ENDSTRUCT

.STRUCT Cursor
  x_coord .byte
  y_coord .byte
.ENDSTRUCT

.STRUCT PaletteSelector
  x_coord .byte
  y_coord .byte
  color .byte
.ENDSTRUCT