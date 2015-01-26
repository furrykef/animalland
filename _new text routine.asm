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
        ld      (start_txtptr), ixl
        id      (start_txtptr+1), ixh
        ld      hl, formatted_text          ; HL will be our pointer to buffer
        ld      (start_bufptr), l
        ld      (start_bufptr+1), h
NextWord:
        ld      (old_txtptr), ixl
        ld      (old_txtptr+1), ixh
        ld      (old_bufptr), l
        ld      (old_bufptr), h
        call    CopyWord
        ld      a, cur_x
        cp      MAX_CUR_X+1                 ; cur_x > MAX_CUR_X?
        jr      nc, .no_newline             ; skip ahead if not
        ld      ixl, (old_txtptr)
        ld      ixh, (old_txtptr+1)
        ld      l, (old_bufptr)
        ld      h, (old_bufptr+1)
        jp      FormatNewline
.no_newline:
        ld      a, (ix+0)
        cp      CHAR_END
        jr      nz, .not_end
        ld      (hl), a
        jr      .done
.not_end:
        cp      CHAR_NEWLINE
        jp      z, FormatNewlineChar
        cp      CHAR_KEY
        jp      z, FormatKey
        cp      CHAR_SPACE
        jp      z, FormatSpace
        ; Can't get here
        ???
.done:
        pop     hl
        pop     de
        ld      ix, formatted_text          ; we'll be printing from this buffer, not script
        ret


CopyWord:
        ???


FormatKey:
        ???


FormatSpace:
        ???


FormatNewlineChar:
        inc     ix                          ; bump script pointer past the newline
FormatNewline:
        ld      a, CHAR_NEWLINE
        ld      (hl), a
        inc     hl                          ; bump buffer pointer
        xor     a                           ; set cursor to left margin
        ld      (cur_x), a
        ld      a, (cur_y)
        inc     a
        ld      (cur_y), a
        cp      MAX_CUR_Y+1                 ; cur_y > MAX_CUR_Y?
        jp      nc, NextWord                ; go to next word if not
        xor     a
        ld      (cur_y), a                  ; set cursor to top margin
        ???
        jp      NextWord
