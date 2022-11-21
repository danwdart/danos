load_kernel:
    .reset:
        call reset_disk

    .read:
        mov si, progress_read_kernel
        call write_string
        mov ah, DISK_READ_SECTORS        ; routine
        mov al, 0x40        ; maximum filesize in sectors = 64k / 512 = 0x80 - sectors to read
        ;xor ch, ch 	; Cylinder 8/10 = 0
        ;mov cl, 54  ; Cylinder 2/10 Sector 6 ; todo get this
        xor dh, dh		    ; Head = 0
        mov dl, DISK_SDA 		; drive ; TODO get backed up
        mov bx, KERNEL_SEGMENT 		; segment to load it to
        mov es, bx
        mov bx, KERNEL_OFFSET 		; offset (add to seg)
        int INT_BIOS_DISK
        jnc .ok
    
    .error:
        mov si, err_read_kernel
        call write_string
        cli
        hlt
        jmp $
    .ok: