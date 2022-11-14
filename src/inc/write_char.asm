%include "src/inc/constants.asm"

write_char:
        mov ah, VIDEO_PRINT
        int INT_VIDEO
        ret