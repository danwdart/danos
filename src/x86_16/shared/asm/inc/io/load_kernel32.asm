%include "constants/int/bios/disk.asm"
%include "constants/config.asm"

load_kernel32:
    .reset:
        call reset_disk

    .read:
        mov si, progress_read_kernel
        call write_string
        mov ah, DISK_READ_SECTORS        ; routine
        mov al, 0x0f        ; maximum filesize in sectors = 64k / 512 = 0x80 - sectors to read - seems to fault when loading kernel over 0x0f - so not 8k or 0x2000 bytes
        ;xor ch, ch 	; Cylinder 8/10 = 0
        ;mov cl, 54  ; Cylinder 2/10 Sector 6 ; todo get this
        xor dh, dh		    ; Head = 0
        mov dl, DISK_SDA 		; drive ; TODO get backed up
        mov bx, KERNEL32_SEGMENT 		; segment to load it to
        mov es, bx
        mov bx, KERNEL32_OFFSET 		; offset (add to seg)
        int INT_BIOS_DISK
        jnc .ok
    
    .error:
        mov si, err_read_kernel
        call write_string
        cli
        hlt
        jmp $
    .ok:
        ret