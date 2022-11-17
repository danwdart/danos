%include "src/inc/constants.asm"

; params: ds:si
; clobbers: al
write_string:
        mov ah, VIDEO_PRINT
    .char:
        lodsb ; load the next ds:si into al
        test al, al ; 0-terminated string ; compare to 0
        jz .done
        int INT_VIDEO
        jmp .char
    .done:
        ret