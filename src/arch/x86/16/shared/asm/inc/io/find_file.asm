; reads:
; clobbers: si, di, ax, cx, dx, bx, ds, es,
; writes: carry, cx for location
find_file:
    call reset_disk

    .read:
        ; mov si, progress_read_fat
        ; call write_string
        mov ah, DISK_READ_SECTORS        ; routine
        mov al, 0x1e         ; [NumberOfFats]*[SectorsPerFat]+[ReservedForBoot] ; so we load enough to go from the first fat
        xor ch, ch 		    ; track = 0
        mov cl, 0x15 		    ; sector, 1-based (0x13 start of fat, +1 for disk, +1 for 1-based)
        xor dh, dh 		    ; head = 0
        mov dl, DISK_SDA 		; drive
        mov bx, FAT_SEGMENT 		; segment to load it to
        mov es, bx
        mov bx, FAT_OFFSET 		; offset (add to seg)
        int INT_BIOS_DISK
        jnc .ok
    .error:
        stc
        ret
    .ok:
        mov cx, 0xffff ; max length to find - must be in first 64kB
        mov di, bx ; offset to find it from (implicit segment)

        call strfind
        jnc .win
        ; we didn't find anything, we can't load our kernel, oh woe!
        stc
        ret
    .win:
        ;mov si, progress_found_file_location
        ;call write_string

        add di, 0x0f ; That should be enough! es:di should now point to where we should look for the file. At least the low part.

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
        mov ax, FAT_SEGMENT
        mov ds, ax
        mov es, ax
        mov word cx, [di] ; ax = lowclust - TODO highclust - this is probably highclust x 0x10000 + lowclust - for now we assume it's in the first 32M.

        ; We need to add all the way to the proper offset.

        ; FAT started at 0x13 sectors * 0x200 bytes per sector = 0x2600 bytes into partition (0x2800 bytes into disk)
        ; The entry was found at 0x283a, so 0x003a from the start of the FAT.
        ;
        ; FAT           Bytes from disk     Sectors from disk       Bytes from part     Sectors from part   Bytes From FAT start    Sectors from FAT start
        ; FAT start     0x2800              0x14                    0x2600              0x13                0                       0
        ; FAT end       0x6400              0x32                    0x6200              0x31                0x3c00                  0x18
        ; 0x03 0x00     0x6a00              0x35                    0x6800              0x34                0x4200                  0x21
        ; 0x05 0x00     0x6e00              0x37                    0x6c00              0x36                0x4600                  0x23
        ; 0x06 0x00     0x7000              0x38                    0x6e00              0x37                0x4800                  0x24

        ; if lowclust only the location could only be up to 128K! This is NOT always guaranteed so we need to use both!

        ; we still need to add the location of the partition (one more cluster above) and also the location of the first fat.
        ; e.g. [di] = 4.

        ; actually we had to look at sector 53 from start of part! How's that from 19? Extra 35... that's still 31 more than I expected.
        ; Where did that 31 come from? First past a bunch more reserved sectors? Relative to the last file on disk?

        ; for where it is...
        ;add cx, 49

        ; for that it's in a part...
        ;dec cx

        add cx, 0x33 ; jump over the fat (end of fat = 0x32, + 1 for MBR)

        ; now cl points to the correct file sector.


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

        ;clz ; clear zero bit
        clc

        mov ax, KERNEL_SEGMENT
        mov ds, ax
        mov es, ax
        ret