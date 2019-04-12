.segment "ZEROPAGE"

joypad_buttons: .res 1
mouse_status: .res 1
mouse_x_displacement: .res 1
mouse_y_displacement: .res 1
mode_target: .res 2

; cursor is 2 sprites
cursor: .tag Cursor
palette_cursor: .tag Cursor
palette_cursor_on_bg: .res 1
a_pressed_last_frame: .res 1
left_mouse_pressed_last_frame: .res 1
right_mouse_pressed_last_frame: .res 1
either_button_pressed: .res 1
select_pressed_last_frame: .res 1
select_being_held: .res 1
up_pressed_last_frame: .res 1
up_being_held: .res 1
down_pressed_last_frame: .res 1
down_being_held: .res 1
right_pressed_last_frame: .res 1
right_being_held: .res 1
left_pressed_last_frame: .res 1
left_being_held: .res 1
y_coord_canvas_within_bank: .res 1
x_coord_canvas: .res 1
tile_row_in_canvas_within_bank: .res 1
y_mod_8: .res 1
tile_column_in_canvas: .res 1
x_mod_8: .res 1
tile_index_in_canvas_within_bank: .res 1
new_tile_address_high: .res 1
new_tile_address_low: .res 1
new_char_val_plane_1: .res 1
new_char_val_plane_2: .res 1
cursor_tile_row: .res 1
cursor_attr_byte_row: .res 1
cursor_tile_column: .res 1
attr_byte_address: .res 1
attr_byte_value: .res 1
tile_index_within_block: .res 1
within_canvas_bounds: .res 1
canvas_modified: .res 1
palette_selector_0: .tag PaletteSelector
palette_selector_1: .tag PaletteSelector
palette_selector_2: .tag PaletteSelector
palette_selector_3: .tag PaletteSelector
palette_selector_4: .tag PaletteSelector
palette_selector_5: .tag PaletteSelector
palette_selector_6: .tag PaletteSelector
palette_selector_7: .tag PaletteSelector
palette_selector_8: .tag PaletteSelector
palette_selector_column: .res 1
palette_selector_row: .res 1
palette_selector_row_adder: .res 1

; Set to true just before NMI exits back to main code.
vblank_happened: .res 1
current_color: .res 1
current_bank: .res 1
current_palette: .res 32
current_mode: .res 1
previous_mode: .res 1

cursor_x_coord = $0207
cursor_y_coord = $0204