; this seems pretty invalid - this program has 32 bits of returns and uses bios video mode alls

%include "src/inc/constants.asm"

cpuid:
    .init:
        cpuid
        push ecx
        push edx
        push ebx
        mov cl, 12
        mov ah, VIDEO_PRINT
    .start:
        pop ax
        int INT_VIDEO
        test cl, cl ; compare to 0
        jz .end
        dec cl
        jmp .start
    .end: 
        ret