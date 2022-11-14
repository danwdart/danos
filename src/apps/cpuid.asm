%include "src/inc/constants.asm"

cpuid:
    init:
        cpuid
        push ecx
        push edx
        push ebx
        mov cl, 12
        mov ah, VIDEO_PRINT
    start:
        pop ax
        int INT_VIDEO
        cmp cl, 0
        je end
        dec cl
        jmp start
    end: 
