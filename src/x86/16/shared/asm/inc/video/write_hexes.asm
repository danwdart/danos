; reads: ds:si, cx = length
; clobbers: al
; writes:
write_hexes:
    .whs:
        lodsb ; mov al, ds:[si] and inc si
        call write_hex
        dec cx
        test cx, cx ; compare to 0
        jg .whs
        ret