%include "src/inc/constants.asm"
%include "src/inc/video/write_hexes.asm"

vesa_get_info:
        mov ax, VESA_GET_INFO
        int INT_VIDEO
        ; this should have set es:di to our point
        cmp ax, VESA_GET_INFO ; did it work
        je .fail

        ;add di, 4 ; get to after the VESA signature
        ;mov ax, di
        ;mov si, ax
        mov si, di
        mov cx, 0x10 ; how much data do we want
        call write_hexes
        jmp .end

    .fail:
        mov ah, VIDEO_PRINT
        mov al, "F"
        int INT_VIDEO
    .end:
        ret