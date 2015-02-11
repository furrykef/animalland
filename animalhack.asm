; Written for tniasm 0.45
incbin "animalland-expanded.rom"
cpu z80

include "multibank.sym"


; Set up banks at program start
forg    $00084
org     $6084, $6086
        call    SetUpBanks          ; Replaces ld ($6000), a


; Use the free space at the end of the $6000-7fff bank to set up banks
forg    $01f90
org     $7f90, $7fff
SetUpBanks:
        ld      ($6000), a
        ld      a, $11              ; Put the $22000-$23fff bank into $a000-bfff
        ld      ($7800), a
        ld      ($f2dd), a          ; Tell game to restore $8000-bfff to bank $11
                                    ; after temporarily switching banks in the intro
        ret


; Replace the original game's password table with ours
forg    $0044d
org     $644d, $648a
include "passwords.out.inc"


forg    $00378
org     $6378, $637b
        jp      HandlePasswordChar
        nop


; Code that switches banks
; This code is sensitive! It can be jumped into at multiple places,
; and the script will overwrite several pointers. We must take care not
; to change anything but pointers and bank numbers.
forg    $02bb8
org     $4bb8, $4c24
        ; Chapter 1
        xor     a
        ld      h, $10                      ; bank number
        ld      de, 0                       ; command table pointer
                                            ; (will be overwritten by script)
                                            ; (file offset for this operand is $02bbc)
        ld      bc, $8000                   ; text pointer
        call    $4c3a
        jp      $68a0

        ; Chapter 2
        xor     a
        ld      h, $12
        ld      de, 0                       ; $02bcb (file offset for this operand)
        ld      bc, $8000
        call    $4c3a
        jp      $6f30

        ; Chapter 3
        ld      a, 3
        ld      h, $14
        ld      de, 0                       ; $02bdb
        ld      bc, $8000
        call    $4c3a
        jp      $6000

        ; Chapter 4
        ld      a, 1
        ld      h, $16
        ld      de, 0                       ; $02beb
        ld      bc, $8000
        call    $4c3a
        jp      $7640

        ; Chapter 5
        ld      a, 2
        ld      h, $18
        ld      de, 0                       ; $02bfb
        ld      bc, $8000
        call    $4c3a
        jp      $7800

        ; Chapter 6
        ld      a, 3
        ld      h, $1a
        ld      de, 0                       ; $02c0b
        ld      bc, $8000
        call    $4c3a
        jp      $6b20

        ; Chapter 7
        xor     a
        ld      h, $1c
        ld      de, 0                       ; $02c1a
        ld      bc, $8000
        call    $4c3a
        jp      $7840


; Set pixel_offset to 0 before printing "What's the file's name, boss?"
forg    $002ef
org     $62ef, $62f1
        call    ClearPixelOffsetAndPrintString

; Clear password dialogue when printing "No such file, boss."
forg    $00434
org     $6434, $6436
        call    ClearPasswordDialogueAndPrintString

; Clear password dialogue when printing "OK, let's go."
forg    $0043f
org     $643f, $6441
        call    ClearPasswordDialogueAndPrintString

; Set pixel_offset to 0 before printing "Password:"
forg    $00302
org     $6302, $6304
        call    ClearPixelOffsetAndPrintString


; Replace the code that displays prompts ("What to do?" etc.)
forg    $029a2
org     $49a2, $49a4
        jp      DisplayPrompt


; This code originally called PrintChar (where PrintChar8 is now) and bumped the VRAM pointer in the dialogue routine
forg    $028b7
org     $48b7, $48bf
        call    PrintChar64
        nop                         ; push bc
        nop                         ; ld bc, 64
        nop
        nop
        nop                         ; add hl, bc
        nop                         ; pop bc

; Prints "PRESS SPACE" (formerly "PUSH SPACE KEY !")
forg    $02a56
org     $4a56, $4a6a
        xor     a
        ld      (pixel_offset), a
        ld      hl, $13b8           ; VRAM address
        ld      de, PressSpace
        ld      b, PressSpaceLen
.loop:
        ld      a, (de)
        call    PrintChar64
        inc     de
        djnz    .loop
        jr      $4a6b


; The "PRESS SPACE" string, unencoded
forg    $02aa4
org     $4aa4, $4ab3
PressSpace:
        db $82, $83, $84, $85, $86
PressSpaceLen:  equ $ - PressSpace


; The code that prints the title screen text ("START", "CONTINUE", copyright notice)
forg    $0020e
org     $620e, $6227
        jp      PrintTitleScreenText


; Removes the VRAM bump in title screen code
forg    $002a7
org     $62a7, $62ab
        call    $4018
        jr      $62a2


; @TODO@ -- look for more instances of "call/jp $47ba/$4018" ($4018 jumps to $47ba)


; This erases the "PUSH SPACE KEY !" message.
; The original routine just wrote over it with spaces. No good with our VWF.
forg    $02a7e
org     $4a7e, $4a80
        jp      ErasePushSpaceKey


; Since we use colon instead of Japanese open-quote for dialogue tags now
; This code is used to scan the list of dialogue tags
forg    $025cc
org     $45cc, $45cd
        cp      CHAR_BOLD_COLON


; Hook for first line of dialogue
forg    $0275d
org     $475d, $47ef
        call    HandleFirstLineOfDialogue

; Hook for newlines in main script
forg    $02771
org     $4771, $477a
        jp      HandleNewline


; Draws the command menu ("1. TABLE", etc.)
; This is partially rewritten from the original game
forg    $0291f
org     $491f, $4980
DrawCmdMenu:
        ld      hl, $0600               ; VRAM address
        ld      iy, $f302
        ld      d, 1                    ; Digit to display (e.g. the '1' in "1. TABLE")

.draw_menu_item:
        ld      a, 3
        ld      (pixel_offset), a
        ld      a, (iy+0)
        inc     iy
        ld      ix, ($f2f6)             ; Load IX with addr of char in the script
        or      a
        jr      z, .first_menu_item     ; Skip next line if already pointing to the first menu item
        call    $4b11                   ; Adjust text pointer to Nth menu item
.first_menu_item:
        ld      a, $6b                  ; Set text color to orange
        ld      (text_color), a
        ld      a, d                    ; Number of menu item (in MSX charset)
        call    PrintChar8              ; Display it
        ld      a, CHAR_BOLD_PERIOD
        call    PrintChar8
        ld      bc, 8                   ; Need to align text so first letter starts on third tile
        add     hl, bc                  ; (if we don't, colors will be wrong)
        xor     a
        ld      (pixel_offset), a
        push    hl
        call    DrawMenuLetters
        pop     hl                      ; HL now points to after the '.' in VRAM
        ld      bc, $70                 ; Bump VRAM to start of next menu item
        add     hl, bc
        xor     a
        ld      (pixel_offset), a
        inc     d
        ld      a, 5                    ; Need to adjust VRAM addr after drawing 4th item
        cp      d
        jr      nz, .dont_adjust
        ld      hl, $0e00
.dont_adjust:
        ld      a, (iy+00)              ; Is this the last menu entry?
        cp      $ff
        jr      nz, .draw_menu_item     ; Nope
        jp      $4981


; This tells the name tag routine to check for a colon, not a Japanese open-quote mark, as the end-of-nametag marker
forg    $2795
org     $4795, $4796
        cp      CHAR_BOLD_COLON

forg    $02792
org     $4792, $4794
        jp      DisplayNameTag


; This is where the original game's PrintChar routine was. We'll just hook it to PrintChar8
forg    $027ba
org     $47ba, $4846
        jp      PrintChar8


; This is our hook for linewrapping
; This is at the start of the original FetchAndPrintChar
forg    $025e7
org     $45e7
        call    FetchCharWithLinewrapping


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Graphics
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Animal Land Police Department
forg    $0b8ef
org     $98ef, $a0dd
        db      1
        incbin  "gfx/alpd-e.comp.1.bin"
        db      1
        incbin  "gfx/alpd.comp.2.bin"
        db      1
        incbin  "gfx/alpd.comp.3.bin"
        db      1
        incbin  "gfx/alpd.comp.4.bin"
        incbin  "gfx/alpd.map"


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Banks
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

forg $20000 + MULTIBANK_OFFSET
org $a000, $bfff
incbin "multibank.out"

forg $24000 + MULTIBANK_OFFSET
org $a000, $bfff
incbin "multibank.out"

forg $28000 + MULTIBANK_OFFSET
org $a000, $bfff
incbin "multibank.out"

forg $2c000 + MULTIBANK_OFFSET
org $a000, $bfff
incbin "multibank.out"

forg $30000 + MULTIBANK_OFFSET
org $a000, $bfff
incbin "multibank.out"

forg $34000 + MULTIBANK_OFFSET
org $a000, $bfff
incbin "multibank.out"

forg $38000 + MULTIBANK_OFFSET
org $a000, $bfff
incbin "multibank.out"
