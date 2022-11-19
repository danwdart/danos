%include "src/x86_16/shared/asm/inc/constants.asm"

init:
    mov ax, MBR_SEGMENT  ; set up segments
    mov ds, ax
    mov es, ax
loader:
    .start:

    .print_welcome:
        mov si, welcome
        call write_string

        call reset_disk

    .detect_boot_disk:
        cmp bl, DISK_SDA
        je .is_first_hd
        mov si, is_not_first_hd_msg
        jmp .print_boot_disk

    .is_first_hd:
        mov si, is_first_hd_msg

    .print_boot_disk:
        call write_string

    .read:
        mov ah, 0x02
        mov al, 20 ; sectors to read
        mov ch, DISK_CYLINDER ; cylinder
        mov cl, DISK_SECTOR ; sector, 1-based
        mov dh, DISK_HEAD ; head
        mov dl, DISK_SDA ; drive
        mov bx, VBR_SEGMENT ; segment ( * 0x10 )
        mov es, bx
        mov bx, VBR_OFFSET ; offset (add to seg)
        int INT_IO
        jnc .ok
    .error:
        mov al, ah
        call write_hex
        cli
        hlt
    .ok: ; we've now loaded our sectors into memory
        push es ; our new cs
        push bx ; our new ip
        retf ; ip=bx. cs = es

    welcome db "DanLoader 0.2 booting...", 0x0a, 0x0d, 0x0
    is_not_first_hd_msg db "Not booting from first HD. There may be trouble.", 0x0a, 0x0d, 0x0
    is_first_hd_msg db "Booting from first HD...", 0x0a, 0x0d, 0x0
    
%include "src/x86_16/shared/asm/inc/video/write_string.asm"
%include "src/x86_16/shared/asm/inc/video/write_hex.asm"
%include "src/x86_16/shared/asm/inc/io/reset_disk.asm"

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
