%include "src/inc/constants.asm"

; param: al
; clobbers: ah
write_char:
        mov ah, VIDEO_PRINT
        int INT_VIDEO
        ret