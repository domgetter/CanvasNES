.segment "HEADER"
  .byte "NES", $1A

  ; 4: PRG bank count
  .byte $02

  ; 5: CHR bank count
  ; 0 for CHR RAM
  .byte $00

  ; 6: Mapper mirroring, others
  .byte %00010000

  ; 7: NES2.0
  .byte %00001000

  ; 8: Mapper MSB/Submapper
  .byte %00000000

  ; 9: PRG-ROM/CHR-ROM size MSB
  .byte %00000000

  ; 10: PRG-RAM/EEPROM size
  .byte %00000000

  ; 11: CHR-RAM size
  ; 1001 => 64 * 2**9 == 32k
  .byte %00001001

  ; others
  .byte 0,0,0,0
