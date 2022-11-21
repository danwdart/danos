%include "src/x86_16/shared/asm/inc/constants/int/bios/video.asm"
%include "src/x86_16/shared/asm/inc/constants/int/bios/video/mode.asm"

reset_video:
    mov ah, VIDEO_SET_MODE
    mov al, VIDEO_MODE_TEXT_80X25
    int INT_BIOS_VIDEO
    ret