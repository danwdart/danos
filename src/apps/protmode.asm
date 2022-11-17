[BITS 16]
enable_protmode:
    cli ; timer will fault otherwise
    ; enable A20
    ; hack!
    in al, 0x92
    or al, 0x02
    out 0x92, al

    xor ax, ax
    mov ds, ax

    lgdt [GDT_PTR]

    mov eax, 0x11 ; paging disabled, protection bit enabled. bit4, the extension type is always 1
    mov cr0, eax

    jmp GDT_BOOT_CS-GDT:protmode

[BITS 32]
protmode:
    mov ax, GDT_BOOT_DS-GDT
    mov ds, ax
    mov ss, ax
    mov es, ax
    mov esp, 0x90000
    
    mov edi, 0xb8000
    mov eax, "P R "
    stosd
    mov eax, "O T "

    pause
    jmp $

align 4

GDT_PTR:
dw GDT_END-GDT-1 ; size - 1
dd GDT ; offset

align 16

GDT:
GDT_NULL: dq 0
; base = 0x00000000
; limit = 0xFFFFF * 4 kB granularity = full 4GB address space
; flags = 0xC = 0b1100 (4KB granularity, 32bit)
; access byte = 0x92 = 10010010 (present, ring 0, code/data segment, writable
GDT_BOOT_DS: dq 0x00CF92000000FFFF
GDT_BOOT_CS: dq 0x00CF9A000000FFFF ; same as DS but with executable set in access byte
GDT_END:

