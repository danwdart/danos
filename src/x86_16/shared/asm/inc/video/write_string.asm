%include "src/x86_16/shared/asm/inc/constants/int/bios/video.asm"

; params: ds:si
; clobbers: al
write_string:
        mov ah, VIDEO_WRITE_CHAR_TTY
    .char:
        lodsb ; load the next ds:si into al
        test al, al ; 0-terminated string ; compare to 0
        jz .done
        int INT_BIOS_VIDEO
        jmp .char
    .done:
        ret