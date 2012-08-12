%define FILENAME_LENGTH 11

signature:
        call init
        OEMId db 'DANOS0.1'
        BytesPerSector dw 512
        SectorsPerCluster db 1
        ReservedForBoot dw 1
        NumberOfFats db 2
        NumberOfDirEntries dw 512 	; sectors to read = direntries * 32 / (bytespercluster*sectorspercluster) = 32
        LogicalSectors dw 2047 	;= 1M. 0x0800
        MediaDescriptor db 0xf8 	; f8 = HD
        SectorsPerFat dw 9 		;2
        SectorsPerTrack dw 18 	;32
        TotalHeads dw 2 		; 0x0040
        HiddenSectors dd 0
        LargeSectors dd 0
        ; fat12
        DriveNumber db 0x80 	; useless!
        NTFlags db 0x00 		; reserved
        DriveSignature db 0x29 	; or 0x28 - so NT recognises it
        VolumeId dd 0x78563412
        VolumeLabel db 'DANOS FILES'
        SysId db 'FAT12   '
init:
        cli				; Clear interrupts
        mov ax, 0
        mov ss, ax 		        ; Set stack segment and pointer
        mov sp, 0FFFFh
        sti             		; Restore interrupts
        cld         		; stack goes upwards   
        mov ax, 2000h       	; Set all segments to match where booter is loaded
        mov ds, ax    
        mov es, ax    
        mov fs, ax    
        mov gs, ax
code:
        mov si, kernld
        call write_string   
        jmp load_kernel
        jmp $

load_kernel:
    .reset:
        mov dl, 0x80 		; sda
        mov ah, 0
        int 0x13

    .read:
        mov ah, 0x02        ; routine
        mov al, 19          ; [NumberOfFats]*[SectorsPerFat]+[ReservedForBoot]
        mov ch, 0 		    ; track
        mov cl, 3 		    ; sector, 1-based
        mov dh, 0 		    ; head
        mov dl, 0x80 		; drive
        mov bx, 0x0300 		; segment to load it to
        mov es, bx
        mov bx, 0x0000 		; offset (add to seg)
        int 0x13
        jnc .ok
    
    .error:
        mov al, ah
	    mov ah, 0x0e
	    int 0x10
        cli
        hlt
        jmp $
    .ok:
        mov cx, 10000
        mov si, filename 
        call findfile
        jc .win
        mov al, "F"
        mov ah, 0x0e
        int 0x10
        jmp $
    .win:
        add di, 15 ; get to the info block
        ; The next two bytes are the location in secateurs.
        mov ax, [di]
        jmp word [ax]

        mov al, "Y"
        mov ah, 0x0e
        int 0x10
        jmp $

findfile:
        mov dx, di ; addr
        ; es:di is where it's at, ds:si is where we put stuff
    .startfind:
        cmp byte [di], 0
        jz .success
        cmp cx, 0
        je .fail
        dec cx
        cmpsb
        jne .rstdi
        jmp .startfind

    .rstdi:
        mov di, dx
        jmp .startfind

    .success:
        stc
        ret

    .fail:
        clc
        ret       

write_string:
        mov ah, 0x0e
    .char:
        lodsb
        cmp al, 0
        jz .done
        int 0x10
        jmp .char
    .done:
        ret

        kernld db 'Finding kernel.bin', 0x0d, 0x0a, 0
        filename db 'KERNEL  BIN', 0
        newline db 0x0a, 0x0d, 0

bootlabel:
        times 510-($-$$) db 0
        dw 0AA55h ; bootsector
buffer:
        ; pad the rest with zeroes
        times 1048576-($-$$) db 0
