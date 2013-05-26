; Written for tniasm 0.45
incbin "animalland-expanded.rom"
cpu z80


; BIOS stuff
RDVRM:          equ     $004a
WRTVRM:         equ     $004d

; Variables from the original game
text_color:     equ     $f301

; This variable was used for this purpose in the original code
char_to_print:  equ     $f2e1

; Other variables
; @TODO@ -- verify this region is safe, or considering using MSX2-specific system RAM (FAF5-FB34)
org $e000

; How many pixels to the right do we draw the next char?
pixel_offset:   rb 1

; How much we need to increment VRAM addr to get to the next tile on the right
tile_increment: rw 1

vram_addr:      rw 1

char_width:     rb 1


; This code originally called PrintChar (where PrintChar8 is now) and bumped the VRAM pointer in the dialogue routine
forg    $028b7
org     $48b7, $48bf
        call    PrintChar64
        nop                     ; push bc
        nop                     ; ld bc, 64
        nop
        nop
        nop                     ; add hl, bc
        nop                     ; pop bc

; Again for "PUSH SPACE KEY !"
forg    $02a60
org     $4a60, $4a66
        call    PrintChar64
        nop                     ; ld bc, 64
        nop
        nop
        nop                     ; add hl, bc


; NOPping the VRAM bump in title screen code
forg    $002ad
org     $62ad, $62b0
        nop                     ; ld de, 8
        nop
        nop
        nop                     ; add hl, de


; NOPping some VRAM bumps in menu code
; After drawing digit (the "1" in "1.TABLE")
forg    $02943
org     $4943, $4943
        nop                     ; add hl, bc    (BC is guaranteed to be 8)

; After drawing period
forg    $0294b
org     $494b, $494b
        nop                     ; add hl, bc    (BC is guaranteed to be 8)

; After printing letter
forg    $02964
org     $4964, $4964
        nop                     ; add hl, bc    (BC is guaranteed to be 8)


; @TODO@ -- look for more instances of "call/jp $47ba/$4018" ($4018 jumps to $47ba)


; This is a reworked version of the display code from the original game,
; found at $027ba in ROM, $47ba in CPU space. The original routine did
; NOT increment the VRAM pointer on exit; our version does (and so all
; calls to it have to be adjusted accordingly), because now this only
; has to be done sometimes.
;
; Inputs:
;   A = char to print
;   HL = address in VRAM to write char to
;   pixel_offset
;
; Outputs:
;   HL = address in VRAM of next char to write to
;   pixel_offset
forg    $027ba
org     $47ba, $4846
; This must be at $47ba!
PrintChar8:
        push    bc
        ld      bc, 8
        ld      (tile_increment), bc
        pop     bc
        jr      PrintChar

PrintChar64:
        push    bc
        ld      bc, 64
        ld      (tile_increment), bc
        pop     bc
        ; Fall through to PrintChar

PrintChar:
        ld      (char_to_print), a
        ld      (vram_addr), hl
        push    bc
        push    de

        ; @TODO@ -- is it safe to just switch this bank?
        ; Does the VBLANK interrupt handler depend on which bank is loaded?
        ld      a, 16                   ; put ROM bank 16 in $6000-7fff
        ld      ($6800),a
        call    PrintCharImpl
        ld      a, 0                    ; switch back to ROM bank 0
        ld      ($6800), a

        ; This part has to be done after $6000-7fff has been switched back
        ld      a, (char_to_print)      ; Put char we've displayed back in A
        cp      '!'                     ; These insert a delay after certain punctuation symbols
        call    z, $4708
        cp      '?'
        call    z, $4708
        cp      ','
        call    z, $4708
        call    $4c56                   ; I assume this is a delay, music, misc. handling
        ld      hl, (vram_addr)
        pop     de
        pop     bc
        ret


; Stuff from here on goes in ROM bank 16
forg    $20000
org     $6000, $7fff

PrintCharImpl:
        ld      a, (pixel_offset)       ; If pixel offset is 8...
        cp      8
        jr      nz, .dont_bump
        xor     a                       ; ...set it to 0 now...
        ld      (pixel_offset), a 
        ld      hl, (vram_addr)         ; ...and bump VRAM address up to next tile
        ld      bc, (tile_increment)
        add     hl, bc
        ld      (vram_addr), hl

.dont_bump:
        call    CalcCharWidth

        call    GetPtrToCharData
        call    Write1stTile

        call    BumpPixelOffset
        jr      c, .one_tile            ; Branch if we don't need to print to another tile

        ; Now we have to draw the second tile
        ; But first write the color for the first tile
        ld      hl, (vram_addr)
        call    WriteColor

        ; Now we get ready to actually draw the second tile
        ld      hl, (vram_addr)         ; Bump VRAM address up to next tile
        ld      bc, (tile_increment)
        add     hl, bc
        ld      (vram_addr), hl

        call    GetPtrToCharData
        call    Write2ndTile

.one_tile:
        ld      hl, (vram_addr)
        call    WriteColor
        ret


; Points DE to the first row of pixels to the char in char_to_print
; Preserves HL
GetPtrToCharData:
        ld      a, (char_to_print)
        ex      de, hl
        ld      bc, font_data
        ld      h, 0                    ; All this bit does is hl = a*8...
        ld      l, a
        sla     l
        rl      h
        sla     l
        rl      h
        sla     l
        rl      h
        add     hl, bc                  ; ...then adds the font's base address
        ex      de, hl
        ret


CalcCharWidth:
        push    hl
        ld      b, 0
        ld      a, (char_to_print)
        ld      c, a
        ld      hl, char_widths
        add     hl, bc
        ld      a, (hl)
        ld      (char_width),a
        pop     hl
        ret


; Carry flag will be clear on exit if caller must draw another tile
BumpPixelOffset:
        ; Bump up the pixel offset
        ld      a, (pixel_offset)
        ld      b, a
        ld      a, (char_width)
        add     a, b
        ld      (pixel_offset), a
        cp      9                       ; Did we go past the tile boundary (not just the edge)?
        ret     c                       ; Return if not

        ; Yep, we did
        and     7                       ; carry flag will still be clear after this
        ld      (pixel_offset), a
        ret


Write1stTile:
        ld      b, 8
.loop:
        push    bc
        ld      a, (de)                 ; Put line of char to print in C
        ld      c, a
        call    RDVRM                   ; ...and the char that's already in this tile into H
        push    hl
        ld      h, a
        ld      a, (pixel_offset)
        or      a                       ; If pixel offset is zero...
        jr      z, .no_shift            ; ...then don't shift
        ld      b, a
        ld      a, c                    ; Now put line of char to print back in A
.shift:
        srl     a                       ; ...else shift
        djnz    .shift
        ld      c, a                    ; undoes the effect of the next line
                                        ; (A is already line to draw)
.no_shift:
        ld      a, c                    ; put line to draw back in A
        or      h                       ; combine with the tile that was in VRAM before
        pop     hl
        call    WRTVRM
        inc     hl
        inc     de
        pop     bc                      ; Put the .write_chr counter back
        djnz    .loop
        ret


Write2ndTile:
        ld      b, 8
.loop:
        push    bc
        ld      a, (pixel_offset)       ; This loop does A = [DE] << (8 - pixel_offset)
        ld      b, a
        ld      a, (char_width)
        sub     a, b
        ld      b, a
        ld      a, (de)
.shift:
        sla     a
        djnz    .shift
        call    WRTVRM
        inc     hl
        inc     de
        pop     bc
        djnz    .loop
        ret


; HL holds the VRAM addr of the character data (NOT color data!)
WriteColor:
        ld      de, $2000               ; Now we write to this tile's color table
        add     hl, de
        ld      b, $08
.write_color:
        ld      a, (text_color)
        call    WRTVRM
        inc     hl
        djnz    .write_color
        ret


font_data:
        incbin  "vwf.bin"


char_widths:
        db      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0

        db      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0

        ;       [first char here is space]
        ;       [asterisk in this row is not the one we use]
        ;          !  "  #  $  %  &  '  (  )  *  +  ,  -  .  /
        db      3, 2, 5, 6, 6, 6, 6, 3, 3, 3, 6, 6, 3, 5, 2, 4

        ;       0  1  2  3  4  5  6  7  8  9  :  ;  <  =  >  ?
        db      5, 3, 6, 6, 6, 6, 6, 6, 6, 6, 2, 3, 6, 6, 6, 6

        ;       @  A  B  C  D  E  F  G  H  I  J  K  L  M  N  O
        db      6, 6, 6, 6, 6, 5, 5, 6, 6, 2, 5, 5, 5, 6, 6, 6

        ;       P  Q  R  S  T  U  V  W  X  Y  Z  [  ¥  ]  ^  _
        db      5, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6

        ;       `  a  b  c  d  e  f  g  h  i  j  k  l  m  n  o
        db      6, 6, 5, 5, 5, 5, 4, 5, 5, 2, 3, 5, 2, 6, 5, 5

        ;       p  q  r  s  t  u  v  w  x  y  z  {  |  }  ~
        db      5, 5, 4, 5, 4, 5, 6, 6, 5, 5, 5, 6, 6, 6, 6, 0

        db      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0

        ;          *
        db      0, 6, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0

        db      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0

        db      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0

        db      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0

        db      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0

        db      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0

        db      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
