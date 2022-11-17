
[BITS 32]
enter_longmode:
    ; pae
    mov eax, 0xa0
    mov cr4, eax

    ; after bios
    mov edi,0x100000

    ; pd: 2MiB pages
    mov eax, 0x83 ; origin 0, RW, P, PS
    xor edx, edx
    mov [edi], eax
    mov [edi+4], edx
    add edi, 8

    ; zero other
    mov ecx, 511*2
    xor eax, eax
    rep stosd

    ; pdp 1GiB pages
    mov eax, 0x100003 ; start 0x100000 RW P
    mov [edi], eax
    mov [edi+4], edx
    add edi, 8

    mov ecx,511*2
    xor eax,eax
    rep stosd

    ; PML4: 512 GiB pages
    mov eax,0x101003 ; starts at 0x101000 (R/W, P)
    mov [edi],eax
    mov [edi+4],edx
    add edi,8

    mov ecx,511*2
    xor eax,eax
    rep stosd

    ; set PML4 pointer
    mov eax,0x102000
    mov cr3,eax

    ; set LME bit (long mode enable) in the IA32_EFER machine specific register
    ; MSRs are 64-bit wide and are written/read to/from eax:edx
    mov ecx,0xC0000080 ; this is the register number for EFER
    mov eax,0x00000100 ; LME bit set
    xor edx,edx ; other bits zero
    wrmsr

    ; enable paging
    mov eax,cr0
    bts eax,31
    mov cr0,eax

    jmp GDT_CS64-GDT:KERNEL_SEGMENT*0x10+longmode