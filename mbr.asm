init:
        mov ax, 0x07C0  ; set up segments
        mov ds, ax
        mov es, ax
loader:
    .reset:
        mov dl, 0x80 ; sda
        mov ah, 0
        int 0x13

    .read:
        mov ah, 0x02
        mov al, 20 ; sectors to read
        mov ch, 0 ; track
        mov cl, 2 ; sector, 1-based
        mov dh, 0 ; head
        mov dl, 0x80 ; drive
        mov bx, 0x2000 ; segment ( * 0x10 )
        mov es, bx
        mov bx, 0x0000 ; offset (add to seg)
        int 0x13
        jnc .ok
        mov al, ah
        call write_hex
        cli
        hlt
    .ok:
        push es
        push bx
        retf ; ip=bx. cs = es 

write_hex:
    .write:
        mov bl, al ; bl now 0x41 for example
        shr bl, 4 ; bl now 0x04
        and bl, 0x0f ; make sure!!!
        cmp bl, 0x0a
        jl .isless
    .isge:
        add bl, 0x37 ; for instance 0x0b + 0x37 = "B"
        jmp .cont
    .isless:
        add bl, 0x30 ; e.g. 0x04 + 0x30 = 0x34 = "4"
        jmp .cont
    .cont: 
        ; bl now correct
        ; bh can now be the higher byte
        mov bh, al ; bl now 0xba
        and bh, 0x0f ; bl now 0x0a
        cmp bh, 0x0a
        jl .islesst
    .isget:
        add bh, 0x37
        jmp .contt
    .islesst:
        add bh, 0x30
        jmp .contt
    .contt:
        ; bx now correct
        mov al, bl
        mov ah, 0x0e; print
        int 0x10
        mov al, bh
        int 0x10
    .end:
        ret

disk_sig:
        times 440-($-$$) db 0
        ;db = 1, dw = 2, dd = 4
        disksig dd "DAND"
        extra dw 0x0000

        status db 0x80 ; 0x00 not bootable
        head_start db 0x00
        sector_start db 0x02
        cylinder_start db 0x00
        parttype db 0x01 ; 1 = FAT12
        head_end db 0x01
        sector_end db 0x20
        cylinder_end db 0x02
        lba_firstsector_le dd 0x00000001
        num_sect_le dd 0x000007ff

        ; no more parts
        part2 dd 0,0,0,0
        part3 dd 0,0,0,0
        part4 dd 0,0,0,0

        dw 0AA55h ; bootsector - some BIOSes require this signature
