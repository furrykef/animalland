; Inputs:
;   IX = pointer to beginning of text block in script
;   cur_x
;   cur_y
;
; Outputs:
;   IX = pointer to formatted text buffer
;   cur_x
;   cur_y
FormatText:
        push    de
        push    hl
        push    ix
        pop     de                          ; DE will be our script pointer
        ld      (start_scriptptr), e
        ld      (start_scriptptr+1), d
        ld      hl, formatted_text          ; HL will be our pointer to buffer
        ld      (start_bufptr), l
        ld      (start_bufptr+1), h
NextWord:
        ld      (old_scriptptr), e
        ld      (old_scriptptr+1), d
        ld      (old_bufptr), l
        ld      (old_bufptr), h
        call    CopyWord
        ld      a, cur_x
        ; Note: if the cursor advances exactly to the right margin, we want to allow it.
        ; This is because otherwise text cannot go right up against the margin.
        ; Hence we test A <= BOX_WIDTH, not A < BOX_WIDTH.
        cp      BOX_WIDTH+1                 ; cursor still within or just past right margin (cur_x <= BOX_WIDTH)?
        jr      c, .no_newline              ; skip ahead if so
        ld      e, (old_scriptptr)
        ld      d, (old_scriptptr+1)
        ld      l, (old_bufptr)
        ld      h, (old_bufptr+1)
        call    FormatNewline
        jp      NextWord
.no_newline:
        ld      a, (de)
        cp      CHAR_END
        jr      nz, .not_end
        ld      (hl), a
        jr      .done
.not_end:
        cp      CHAR_NEWLINE
        jp      z, FormatNewlineChar
        cp      CHAR_KEY
        jp      z, FormatKeyChar
        cp      CHAR_SPACE
        jp      z, FormatSpace
        ; Can't get here
        pop     hl
        pop     de
        ld      ix, CantGetHereMsg
        ret
.done:
        pop     hl
        pop     de
        ld      ix, formatted_text          ; we'll be printing from this buffer, not script
        ret

CantGetHereMsg:
        ;       E    R    R    O    R    <nl>
        db      $34, $41, $41, $3e, $41, $7e
        ;       C    a    n    '    t         g    e    t         h    e    r    e    <end>
        db      $c3, $e1, $ee, $a7, $f4, $a0, $e7, $e5, $f4, $a0, $e8, $e5, $f2, $e5, $7f


FormatKeyChar:
        inc     de
FormatKey:
        xor     a
        ld      (cur_x), a
        ld      (cur_y), a
        ld      a, CHAR_KEY
        ld      (hl), a
        inc     hl
        jp      EndOfUtterance


; NB: does not advance DE or HL past the space
FormatSpace:
        dec     de
        ld      a, (de)                     ; get the char before the space
        inc     de
        cp      CHAR_QUESTION
        jp      z, EndOfUtterance
        cp      CHAR_EXCLAM
        jp      z, EndOfUtterance
        cp      CHAR_PERIOD
        jp      z, EndOfUtterance
        cp      CHAR_COMMA
        jp      z, EndOfUtterance
        cp      CHAR_COLON
        jp      z, EndOfUtterance
        cp      CHAR_SEMICOLON
        jp      z, EndOfUtterance
        cp      CHAR_RIGHT_PAREN
        jp      z, EndOfUtterance
        cp      CHAR_RIGHT_BRACKET
        jp      z, EndOfUtterance
        cp      CHAR_CLOSE_QUOTE
        jp      z, EndOfUtterance
        ret


FormatNewlineChar:
        ld      a, (cur_y)                  ; if we're on the bottom line...
        cp      BOX_HEIGHT-1
        jp      z, FormatKeyChar            ; ...then replace the <nl> with a <key>
        inc     de                          ; bump script pointer past the newline
        call    FormatNewline
        jp      EndOfUtterance


EndOfUtterance:
        ld      (start_scriptptr), e
        ld      (start_scriptptr+1), d
        ld      (start_bufptr), l
        ld      (start_bufptr+1), h
        jp      NextWord


; Print characters until we reach an end-of-word character
;
; Inputs:
;   DE = Script pointer
;   HL = Format buffer
;   cur_x
;   cur_y
;
; Outputs:
;   DE = Script pointer
;   HL = Format buffer
;   cur_x
;   cur_y
;
; Note: DE and HL will point at, not beyond, the terminator at exit
CopyWord:
        ld      a, (de)
        cp      CHAR_SPACE
        jr      nz, .not_space
        ld      a, (cur_x)                  ; is cursor at left margin?
        or      a
        jr      z, .skip_space              ; don't output space if so
        ld      a, CHAR_SPACE
        ld      (hl), a
        call    AddCharWidthToCurX
.skip_space:
        inc     hl
.not_space:
.loop:
        ld      a, (de)
        ld      (hl), a
        call    AddCharWidthToCurX
        cp      CHAR_SPACE
        ret     z
        cp      CHAR_NEWLINE
        ret     z
        cp      CHAR_KEY
        ret     z
        cp      CHAR_END
        ret     z
        inc     de
        inc     hl
        jr      .loop


FormatNewline:
        ld      a, CHAR_NEWLINE
        ld      (hl), a
        inc     hl                          ; bump buffer pointer
        xor     a                           ; set cursor to left margin
        ld      (cur_x), a
        ld      a, (cur_y)
        inc     a
        ld      (cur_y), a
        cp      BOX_HEIGHT                  ; cursor still within bottom margin (cur_y < BOX_HEIGHT)?
        jp      c, NextWord                 ; go to next word if so

        ; We've overflowed the bottom margin; back up to the previous stopping point
        ld      e, (start_scriptptr)
        ld      d, (start_scriptptr+1)
        ld      l, (start_bufptr)
        ld      h, (start_bufptr+1)

        ; @TODO@ -- if (HL) is CHAR_KEY, we're in an infinite loop
        ; abort and print and error if this happens

        ; Insert wait for keypress
        ; (Note: not using FormatKey for this because that jumps to EndOfUtterance)
        ld      a, CHAR_KEY
        ld      (hl), a
        inc     hl

        ; Reset cursor
        xor     a
        ld      (cur_x), a
        ld      (cur_y), a

        ; And finally go on our way
        jp      NextWord
