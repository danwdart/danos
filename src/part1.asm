%include "src/inc/constants.asm"

%define FILENAME_LENGTH 11

signature:
    call init
    OEMId: db 'DANOS0.1'
    BytesPerSector: dw 512
    SectorsPerCluster: db 1
    ReservedForBoot: dw 1
    NumberOfFats: db 2
    NumberOfDirEntries: dw 512 	; sectors to read = direntries * 32 / (bytespercluster*sectorspercluster) = 32
    LogicalSectors: dw 2047 	;= 1M. 0x0800
    MediaDescriptor: db 0xf8 	; f8 = HD
    SectorsPerFat: dw 9 		;2
    SectorsPerTrack: dw 18 	;32
    TotalHeads: dw 2 		; 0x0040
    HiddenSectors: dd 0
    LargeSectors: dd 0
    ; fat12
    DriveNumber: db 0x80 	; useless!
    NTFlags: db 0x00 		; reserved
    DriveSignature: db 0x29 	; or 0x28 - so NT recognises it
    VolumeId: dd 0x78563412
    VolumeLabel: db 'DANOS FILES'
    SysId: db 'FAT12   '

init:
        cli				; Clear interrupts
        mov ax, 0
        mov ss, ax 		        ; Set stack segment and pointer
        mov sp, 0FFFFh
        sti             		; Restore interrupts
        cld         		; stack goes upwards   
        mov ax, 0x2000       	; Set all segments to match where booter is loaded
        mov ds, ax    
        mov es, ax    
        mov fs, ax    
        mov gs, ax
code:
        mov si, kernld
        call write_string   

find_file_kernel:
    .reset:
        mov dl, 0x80 		; sda
        mov ah, 0
        int INT_IO

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
        int INT_IO
        jnc ok
    
    .error:
        mov al, "E"
        ; mov al, ah
	    mov ah, VIDEO_PRINT
	    int INT_VIDEO
        cli
        hlt
        jmp $

    .ok:
        mov cx, 10000
        mov di, bx
        mov si, filename
        call findfile
        jc win
        mov al, "F"
        mov ah, VIDEO_PRINT
        int INT_VIDEO
        jmp $

    win:

        ; everything is in es:di, we want it in ds:si
        ;add di, 15 ; get to the info block
        ; The next two bytes are the location in secateurs.

        ; The FAT directory entries look like:
        ; 00-0a FILE    EXT
        ; 0d-0d ATTRS RO=01 HIDE=02 SYS=04 VOLID=08 DIR=10 ARCHIVE=20
        ; 0c-0c RESVD NT
        ; 0d-0d CREATIME 1/10S
        ; 0e-0f CREATIME HHHHHMMMMMMSSSSS
        ; 10-11 CREADATE YYYYYYYMMMMDDDDD
        ; 12-13 ACCDATE  YYYYYYYMMMMDDDDD
        ; 14-15 HIGHCLUST
        ; 16-17 MODTIME  HHHHHMMMMMMSSSSS
        ; 18-19 MODDATE  YYYYYYYMMMMDDDDD
        ; 1a-1b LOWCLUST
        ; 1c-1f FILESIZE
        
        add di, 0x1a    
        mov word cx, [di] ; ax = lowclust
        add cl, 3 ; Forst sector of old one

load_kernel:
    reset:
        mov dl, 0x80 		; sda
        mov ah, 0
        int INT_IO

    read:
        mov ah, 0x02        ; routine
        mov al, 0x40        ; maximum filesize in sectors = 64k / 512 = 0x80
        mov ch, 0 		    ; track ; note sector already set
        mov cl, 7
        mov dh, 0 		    ; head
        mov dl, 0x80 		; drive
        mov bx, 0x0400 		; segment to load it to
        mov es, bx
        mov bx, 0x0000 		; offset (add to seg)
        int INT_IO
        jnc ok
    
    error:
        mov al, ah
	    mov ah, VIDEO_PRINT
	    int INT_VIDEO
        cli
        hlt
        jmp $
    ok:
        mov al, "Y"
        call write_char
        mov ax, es
        mov ds, ax
        mov si, 0
        mov cx, 0x20
        call write_hexes
        jmp $

        push es
        push bx
        retf

%include "src/inc/write_hexes.asm"
%include "src/inc/write_chars.asm"
%include "src/inc/write_string.asm"

; We want to find a string in another string
; es:di = big string, ds:si = 0-term'd string, 

; es:di e.g. 3000:0000 00 0f ff 00 00 K E R N E L     B I N 00 00 
; ds:si e.g. 2000:0128 K E R N E L     B I N 00

findfile:
        mov dx, si ; addr
    .startfind:
        cmp byte [si], 0
        jz .success
        cmp cx, 0
        je .fail
        dec cx
        cmpsb
        jne .rstdi
        jmp .startfind

    .rstdi:
        mov si, dx
        jmp .startfind

    .success:
        stc
        ret

    .fail:
        clc
        ret
        
data:
        kernld db 'I am partition 1 bootcode. Finding kernel.bin...', 0x0d, 0x0a, 0
        filename db 'KERNEL  BIN', 0
        newline db 0x0a, 0x0d, 0

bootlabel:
        times 510-($-$$) db 0
        dw 0AA55h ; bootsector
buffer:
        ; pad the rest with zeroes
        times 1048576-($-$$) db 0
