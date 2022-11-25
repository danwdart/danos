; reads:
; clobbers: ax
; writes:
reset_video:
    mov ah, VIDEO_SET_MODE
    mov al, VIDEO_MODE_TEXT_80X25
    int INT_BIOS_VIDEO
    ;mov ah, VIDEO_SET_BORDER_COLOUR ; background too in text mode
    ;mov bx, 0x02
    ;int INT_BIOS_VIDEO
    ret