%include "src/inc/video/write_hex.asm"

; param: ds:si, cx = length
; clobbers: al
write_hexes:
    .whs:
        lodsb ; mov al, ds:[si]
        call write_hex
        dec cx
        test cx, cx ; compare to 0
        jg .whs
        ret