; reads: ioport 0x92,
; clobbers: ax, eax,
; writes: ioport 0x92,
setup_protmode:
    cli ; timer will fault otherwise

    ; fast a20
    in al, 0x92
    or al, 0x02
    out 0x92, al

    mov ax, KERNEL_SEGMENT
    mov ds, ax

    lgdt [GDT_PTR]

    mov eax, 0x0000000000010001 ; paging disabled, protection bit enabled. bit4, the extension type is always 1
    mov cr0, eax

    ret