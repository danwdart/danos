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
        ret