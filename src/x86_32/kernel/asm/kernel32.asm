[BITS 32]
_start:
%include "setup_segs.asm"

    mov edi, 0xb8000 + 0xa0
    mov eax, "P R "
    stosd
    mov eax, "O T "
    stosd

    mov edi, 0xb8000 + 0xa0 * 5

    pause

    jmp $

    ; call cpuid
    
    ; jmp enter_longmode