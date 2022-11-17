[BITS 32]
protmode:
    mov ax, GDT_BOOT_DS-GDT
    mov ds, ax
    mov ss, ax
    mov es, ax
    mov esp, 0x90000

    mov edi, 0xb8000 + 0xa0
    mov eax, "P R "
    stosd
    mov eax, "O T "
    stosd

    mov edi, 0xb8000 + 0xa0 * 5

    call cpuid
    
    jmp enter_longmode