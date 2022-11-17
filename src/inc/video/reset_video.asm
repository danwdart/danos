%include "src/inc/constants.asm"

reset_video:
    mov ah, 0x00
    mov al, 0x03
    int INT_VIDEO
    ret