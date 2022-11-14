%include "src/inc/constants.asm"

init:
    mov ax, BOOTSEG  ; set up segments
    mov ds, ax
    mov es, ax
loader:
    .start:
        mov si, welcome
        call write_string

    .reset_disk:
        mov dl, DISK_SDA ; sda
        mov ah, 0
        int INT_IO

    .read:
        mov ah, 0x02
        mov al, 20 ; sectors to read
        mov ch, DISK_TRACK ; track
        mov cl, DISK_SECTOR ; sector, 1-based
        mov dh, DISK_HEAD ; head
        mov dl, DISK_SDA ; drive
        mov bx, MEM_SEGMENT ; segment ( * 0x10 )
        mov es, bx
        mov bx, MEM_OFFSET ; offset (add to seg)
        int INT_IO
        jnc .ok
        mov al, ah
        call write_hex
        cli
        hlt
    .ok: ; we've now loaded our sectors into memory
        push es ; our new cs
        push bx ; our new ip
        retf ; ip=bx. cs = es 

    welcome db "I am the MBR. Welcome!", 0x0a, 0x0d, 0x0
    
%include "src/inc/write_string.asm"
%include "src/inc/write_hex.asm"

disk_sig:
    times 440-($-$$) db 0
    ;db = 1, dw = 2, dd = 4
    disksig dd DISK_SIG
    extra dw DISK_EXTRA

    status db 0x80 ; 0x00 not bootable
    head_start db DISK_PART_HEAD_START
    sector_start db DISK_PART_SECTOR_START
    cylinder_start db DISK_PART_CYLINDER_START
    parttype db DISK_PART_TYPE_FAT12 ; 1 = FAT12
    head_end db DISK_PART_HEAD_END
    sector_end db DISK_PART_SECTOR_END
    cylinder_end db DISK_PART_CYLINDER_END
    lba_firstsector_le dd DISK_PART_LBA_FIRSTSECTOR
    num_sect_le dd DISK_PART_NUM_SECT_LE

    ; no more parts
    part2 dd 0,0,0,0
    part3 dd 0,0,0,0
    part4 dd 0,0,0,0

    dw FLAGS_BOOTABLE ; bootsector - some BIOSes require this signature
