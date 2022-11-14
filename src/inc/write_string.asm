%include "src/inc/constants.asm"

write_string:
        mov ah, VIDEO_PRINT
    .char:
        lodsb ; load the next si into al
        cmp al, 0 ; 0-terminated string
        jz .done
        int INT_VIDEO
        jmp .char
    .done:
        ret
