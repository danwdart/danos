; param: al
; clobbers: ah
write_char:
        mov ah, VIDEO_WRITE_CHAR_TTY
        int INT_BIOS_VIDEO
        ret