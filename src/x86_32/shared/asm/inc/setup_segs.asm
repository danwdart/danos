[BITS 32]
setup_segs:
    mov ax, 0x08 ; GDT_BOOT_DS-GDT
    mov ds, ax
    mov ss, ax
    mov es, ax
    mov esp, 0x90000