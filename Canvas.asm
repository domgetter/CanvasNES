.include "header.asm"
.include "constants.asm"
.include "variables.asm"
.include "macros.asm"
.segment "STARTUP"
.include "init.asm"
.include "nmi.asm"
.include "subroutines.asm"

Main:

Forever:
  LDA vblank_happened
  BEQ Forever
  LDA #$00
  STA vblank_happened

PostVBlank:

  LDA previous_mode
  CMP #mode::canvas
  BEQ @canvas_mode_post_vlbank
  CMP #mode::palette_select
  BEQ @palette_select_mode_post_vblank

  @palette_select_mode_post_vblank:
    JSR ClearOAM
    JSR ReadControllers
    JSR CalculateCursorMotion
    JSR WriteCursorSprites
    JSR CheckIfSelectPressed
    JSR CheckIfUpPressed
    JSR CheckIfDownPressed
    JSR CheckIfLeftPressed
    JSR CheckIfRightPressed
    JSR CalculateSpritePalette
    JSR WriteSpritePalette
    JSR WritePaletteSprites
    JSR UpdatePalette
    
    JMP @done_mode_post_vblank
  @canvas_mode_post_vlbank:
    JSR ClearOAM
    JSR ReadControllers
    JSR CalculateCursorMotion
    JSR CheckIfAPressed
    JSR CheckIfLeftMousePressed
    JSR CheckIfRightMousePressed
    JSR CheckIfSelectPressed
    JSR CheckForModifyCanvas
    JSR ChoosePalette
    JSR TileNumberInCanvas
    JSR CalculateAttributeTileInfo
    JSR WriteCursorSprites
    JSR WritePaletteCursorSprites
    JSR Write0Sprite
    JSR DelayUntilAfterFirstScanline
    JSR SwitchBanksForFrame

    JMP @done_mode_post_vblank
  @done_mode_post_vblank:
    LDA current_mode
    STA previous_mode

    JMP Main

BREAK:
    RTI

.include "vram_init.asm"

.segment "VECTORS"
  .word NMI
  .word RESET
  .word BREAK

