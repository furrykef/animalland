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
        ld      a, 11               ; Put the $16000-$17fff bank into $a000-bfff
        ld      ($7800), a
        ld      ($f2dd), a          ; Tell game to restore $8000-bfff to bank 11
                                    ; after the "GRAVE MESSAGE" intro
        ret


; Replace the original game's password table with ours
forg    $0044d
org     $644d, $648a
include "passwords.inc"


forg    $00378
org     $6378, $637b
        jp      HandlePasswordChar
        nop


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


; NOPping the VRAM bump in title screen code
forg    $002ad
org     $62ad, $62b0
;        nop                     ; ld de, 8
;        nop
;        nop
;        nop                     ; add hl, de


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
        cp ':'


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
        cp      ':'

; This bit of code gets executed after displaying a name tag in the main script
; It originally just jumped to $47a1 (the part in the fetch char routine after fetching a char)
forg    $025e4
org     $4534, $4536
        jp      AfterDisplayingNameTag


; This is where the original game's PrintChar routine was. We'll just hook it to PrintChar8
forg    $027ba
org     $47ba, $4846
PrintChar8_hook:
        jp      PrintChar8


forg $14000 + MULTIBANK_OFFSET
org $a000, $bfff
incbin "multibank.out"

forg $18000 + MULTIBANK_OFFSET
org $a000, $bfff
incbin "multibank.out"

forg $1c000 + MULTIBANK_OFFSET
org $a000, $bfff
incbin "multibank.out"

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
