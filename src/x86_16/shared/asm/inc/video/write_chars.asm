; reads: cx, ds:si
; clobbers: al, sets cx to 0
; writes:
write_chars:
    .wchs:
        lodsb
        call write_char
        inc si
        dec cx
        cmp cx, 0 ; is it zero yet/
        jnz .wchs
        ret