; Written for tniasm 0.45
incbin "animalland-expanded.rom"
cpu z80

; BIOS stuff
WRTVRM:         equ     $004d


; Variable was used for this purpose in the original code
char_to_print:  equ     $f2e1

; Other variables
text_color:     equ     $f301


; This is a reworked version of the display code from the original game,
; found at $027ba in ROM, $47ba in CPU space
;
; Inputs:
;   A = char to print
;   HL = address in VRAM to write char to
;
; Outputs:
;   HL = same as input
forg    $027ba
org     $47ba                           ; @TODO@ -- set maximum address
PrintChar:
        ld      (char_to_print), a
        push    bc
        push    de
        push    hl
        ld      a, 16                   ; put ROM bank 16 in $6000-7fff
        ld      ($6800),a
        call    PrintCharImpl
        ld      a, 0                    ; switch back to ROM bank 0
        ld      ($6800), a
        ld      a, (char_to_print)      ; Put char we've displayed back in A
        cp      '!'                     ; These insert a delay after certain punctuation symbols
        call    z, $4708
        cp      '?'
        call    z, $4708
        cp      ','
        call    z, $4708
        call    $4c56                   ; I assume this is a delay, music, misc. handling
        pop     hl
        pop     de
        pop     bc
        ret


; Stuff from here on goes in ROM bank 16
forg    $20000
org     $6000
PrintCharImpl:
        push    hl                      ; Keep original value of hl for later

        ld      a, (char_to_print)
        ex      de, hl
        ld      bc, FontData
        ld      h, $00                  ; All this bit does is hl = a*8...
        ld      l, a
        sla     l
        rl      h
        sla     l
        rl      h
        sla     l
        rl      h
        add     hl, bc                  ; ...then adds the font's base address
        ex      de, hl

        ld      b, $08
.write_chr:
        ld      a, (de)
        call    WRTVRM
        inc     hl
        inc     de
        djnz    .write_chr

        pop     hl                      ; restore hl to the value it had coming in
        ld      de, $2000               ; Now we write to this tile's color table
        add     hl, de

        ld      b, $08
.write_color:
        ld      a, (text_color)
        call    WRTVRM
        inc     hl
        djnz    .write_color
        ret


FontData:
        incbin  "testfont.bin"
