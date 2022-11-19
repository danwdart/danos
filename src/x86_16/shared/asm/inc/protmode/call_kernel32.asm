call_kernel32:
    
    cli ; timer will fault otherwise
    
    ; fast a20
    in al, 0x92
    or al, 0x02
    out 0x92, al

    mov ax, KERNEL_SEGMENT
    mov ds, ax

    lgdt [GDT_PTR]

    mov eax, 0x11 ; paging disabled, protection bit enabled. bit4, the extension type is always 1
    mov cr0, eax

    jmp GDT_BOOT_CS-GDT:KERNEL32_SEGMENT*0x10+KERNEL32_OFFSET ; not + protmode