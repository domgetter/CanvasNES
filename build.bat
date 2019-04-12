@echo off

:: assemble Canvas.asm to an object file
:: -g 
::   output debug symbols
:: -o Canvas.o
::   output into specified file
ca65 Canvas.asm -g -o Canvas.o

:: link Canvas.o to produce a final binary
:: -t nes 
::   using the "nes" linker configuration for memory layout 
::   instead of, e.g., commodore 64 or apple ][
:: -C nes_mmc1.cfg
::   Use the specified configuration for linking
:: -o Canvas.nes
::   output into specified file
:: --dbgfile Canvas.dbg
::   output debug symbols to specified file (must have used -g in ca65)
ld65 -C nes_mmc1.cfg -o Canvas.nes Canvas.o --dbgfile Canvas.dbg