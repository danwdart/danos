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
        xor ax, ax ; set to 0
        mov ss, ax 		    ; Set stack segment and pointer
        mov sp, 0x0FFFF
        sti             	; Restore interrupts
        cld         		; stack goes upwards   
        mov ax, VBR_SEGMENT ; Set all segments to match where booter is loaded
        mov ds, ax    
        mov es, ax    
        mov fs, ax    
        mov gs, ax
code:
        mov si, welcome
        call write_string   

find_file_kernel:
    call reset_disk

    .read:
        mov si, progress_read_fat
        call write_string
        mov ah, 0x02        ; routine
        mov al, 19          ; [NumberOfFats]*[SectorsPerFat]+[ReservedForBoot] ; so we load enough to go from the first fat.
        xor ch, ch 		    ; track = 0
        mov cl, 3 		    ; sector, 1-based
        xor dh, dh 		    ; head = 0
        mov dl, DISK_SDA 		; drive
        mov bx, FAT_SEGMENT 		; segment to load it to
        mov es, bx
        mov bx, FAT_OFFSET 		; offset (add to seg)
        int INT_IO
        jnc .ok
    
    .error:
        mov si, err_read_fat
        call write_string
        cli
        hlt
        jmp $

    .ok:
        mov cx, 0x3000 ; max length to find
        mov di, bx ; offset to find it from (implicit segment)
        mov si, filename
        call findfile
        jc .win
        ; we didn't find anything, we can't load our kernel, oh woe!
        jmp $
    .win:
        ; everything is in es:di, we want it in ds:si
        ; The next two bytes are the location in secateurs.

        ; The FAT directory entries look like:
        ; e.g. Start of segment = absolute 0x2860 (the FAT started at sector 20... there is one boot sector and 19 reserved sectors before it.
        ; 00-0a FILE    EXT
        ; 0d-0d ATTRS RO=01 HIDE=02 SYS=04 VOLID=08 DIR=10 ARCHIVE=20
        ; 0c-0c RESVD NT
        ; 0d-0d CREATIME 1/10S
        ; 0e-0f CREATIME HHHHHMMMMMMSSSSS
        ; 10-11 CREADATE YYYYYYYMMMMDDDDD
        ; 12-13 ACCDATE  YYYYYYYMMMMDDDDD
        ; 14-15 HIGHCLUST - a word for the higher 2 bytes (here at 0x2874 / 0x2875 = 00 00) - only in FAT32
        ; 16-17 MODTIME  HHHHHMMMMMMSSSSS
        ; 18-19 MODDATE  YYYYYYYMMMMDDDDD
        ; 1a-1b LOWCLUST - a word for the lower 2 bytes. (here at 0x287a / 0x287b = 04 00) - making di say "sector 4"
        ; 1c-1f FILESIZE

        ; we finished finding the kernel...
        ; so where is it?
        ; di is the location of the location, so [di] is the location
        mov word cx, [di] ; ax = lowclust - TODO highclust - this is probably highclust x 0x10000 + lowclust - for now we assume it's in the first 32M.
        ; if lowclust only the location could only be up to 128K! This is NOT always guaranteed so we need to use both!

        ; we still need to add the location of the partition (one more cluster above) and also the location of the first fat.
        ; e.g. [di] = 4.

        ; actually we had to look at sector 53 from start of part! How's that from 19? Extra 35... that's still 31 more than I expected.
        ; Where did that 31 come from? First past a bunch more reserved sectors? Relative to the last file on disk?
        
        ; for where it is...
        ;add cx, 49

        ; for that it's in a part...
        ;dec cx

        add cx, 0x36 ; where does this come from?

        ; add cx, 0x05

            ; hey you know what? fuck it. Let's just look for a signature from the kernel and then just go jump to it.
            ; And you know what also... let's just do that in the mbr? Can that happen? Can that therefore be jumped to by different parts of code?

            ; e,g, [SIG] CODE16 [SIG] CODE32 [SIG] CODE64 etc - so all the asm will just be "go 32, if you can go 64 boot danos64 otherwise boot danos32" etc
            ; will the kernel be sector aligned, though?

            ; For now the initial bootsector should just be a smart booter that boots to the first partition. Is that all gonna help with EFI? Nope.
        
        ; now cx is the location in sectors.

        ; alright, go there..
        ; mul cx, 0x200 ; is that gonna help, this ain't relative anymore as it's in sectors.
        ; can't do that directly
        ; mov si, cx

        ; actually, what's there? Let us know.
        
        ;mov cx, 0x20
        ;mov si, [di]
        ;call write_hexes

        ;mov cx, si

        ;jmp $

        ; we're ready to load the kernel... let's go find it on disk in case the file pointed to somewhere we hadn't loaded.

load_kernel:
    .reset:
        call reset_disk

    .read:
        mov si, progress_read_kernel
        call write_string
        mov ah, 0x02        ; routine
        mov al, 0x40        ; maximum filesize in sectors = 64k / 512 = 0x80 - sectors to read
        ;xor ch, ch 	; Cylinder 8/10 = 0
        ;mov cl, 54  ; Cylinder 2/10 Sector 6 ; todo get this
        xor dh, dh		    ; Head = 0
        mov dl, DISK_SDA 		; drive ; TODO get backed up
        mov bx, KERNEL_SEGMENT 		; segment to load it to
        mov es, bx
        mov bx, KERNEL_OFFSET 		; offset (add to seg)
        int INT_IO
        jnc .ok
    
    .error:
        mov si, err_read_kernel
        call write_string
        cli
        hlt
        jmp $
    .ok:
        mov si, progress_calling_kernel
        call write_string
        mov bx, KERNEL_SEGMENT 		; segment to load it to
        mov es, bx
        mov bx, KERNEL_OFFSET 		; offset (add to seg)
        
        push es
        push bx
        retf
%include "src/inc/video/write_string.asm"
%include "src/inc/io/reset_disk.asm"

; We want to find a string in another string
; es:di = big string, ds:si = 0-term'd string, 
; es:di e.g. 3000:0000 00 0f ff 00 00 K E R N E L 1 6 B I N 00 00 
; ds:si e.g. 2000:0128 K E R N E L 1 6 B I N 00

; params: es:di = needle, ds:si = haystack, cx = max length.
; returns: carry bit if ok, es:di to beginning of match.
; clobbers: cx, dx, equal bit. (for now... is that reasonably restorable? pusha/pushf/popf/popa?)
; interrupt flag status: unchanged (should we clear as we go through here?)
findfile:
    ; backup si into dx (so we can check from the beginning)
    mov dx, si
    mov si, progress_find_kernel_location
    call write_string
    mov si, dx
    .startfind:
        ; end of check?
        cmp byte [si], 0 ; nothing left to check, end of string
        jz .success ; note that we cannot then check for zeroes in our comparison string.
        cmp cx, 0 ; too late! compare to 0
        jz .fail
        dec cx
        cmpsb ; compare ds:si with es:di and also increment each
        je .startfind

    .rstdi:
        ; alright... the string hasn't started yet...
        ; restore si (check again from the beginning)
        mov si, dx
        jmp .startfind

    .success:
        mov si, progress_found_kernel_location
        call write_string
        ; heck yeah, we found it!
        ; now di is at the character at the end of its first occurrence.
        ; We need to add all the way to the proper offset.
        add di, 0x0f ; That should be enough! di should now point to where we should look for the file. At least the low part.
        stc
        ret

    .fail:
        mov si, err_finding_kernel_location
        call write_string
        clc
        ret

data:

        progress_read_fat db "Reading FAT", 0x0d, 0x0a, 0
        progress_find_kernel_location db "Finding kernel...", 0x0d, 0x0a, 0
        progress_found_kernel_location db "Found kernel", 0x0d, 0x0a, 0
        progress_read_kernel db "Reading kernel", 0x0d, 0x0a, 0
        progress_calling_kernel db "Calling kernel...", 0x0d, 0x0a, 0
        err_read_fat db "Can't read FAT", 0x0d, 0x0a, 0
        err_finding_kernel_location db "Can't find kernel", 0x0d, 0x0a, 0
        err_read_kernel db "Can't read kernel", 0x0d, 0x0a, 0
        welcome db "DanLoader stage 2 booting...", 0x0d, 0x0a, 0
        filename db 'KERNEL16BIN', 0
        newline db 0x0a, 0x0d, 0

bootlabel:
        times 510-($-$$) db 0
        dw 0AA55h ; bootsector
buffer:
        ; pad the rest with zeroes
        times 1048576-($-$$) db 0
