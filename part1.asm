    call init
    OEMId db 'DANOS0.1'
    BytesPerSector dw 512
    SectorsPerCluster db 1
    ReservedForBoot dw 1
    NumberOfFats db 2
    NumberOfDirEntries dw 512 ; sectors to read = direntries * 32 / (bytespercluster*sectorspercluster) = 32
    LogicalSectors dw 2047 ;= 1M. 0x0800
    MediaDescriptor db 0xf8 ; f8 = HD
    SectorsPerFat dw 9 ;2
    SectorsPerTrack dw 18 ;32
    TotalHeads dw 2 ; 0x0040
    HiddenSectors dd 0
    LargeSectors dd 0
    ; fat12
    DriveNumber db 0x80 ; useless!
    NTFlags db 0x00 ; reserved
    DriveSignature db 0x29 ; or 0x28 - so NT recognises it
    VolumeId dd 0x78563412
    VolumeLabel db 'DANOS FILES'
    SysId db 'FAT12   '
init:
    cli             ; Clear interrupts
    mov ax, 0
    mov ss, ax          ; Set stack segment and pointer
    mov sp, 0FFFFh
    sti             ; Restore interrupts
    cld            
    mov ax, 2000h           ; Set all segments to match where booter is loaded
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
        mov dl, 0x80 ; sda
        mov ah, 0
        int 0x13

    .read:
        mov ah, 0x02
        mov al, 19 ; sectors to read = reserved + fats * sectors per fat
        mov ch, 0 ; track
        mov cl, 3 ; sector, 1-based
        mov dh, 0 ; head
        mov dl, 0x80 ; drive
        mov bx, 0x3000 ; segment to load it to
        mov es, bx
        mov bx, 0x0000 ; offset (add to seg)
        int 0x13
        jnc .ok
    
    .error:
        mov al, ah
        call write_hex
        cli
        hlt
        jmp $

    .ok:
        ; Compare from where we loaded it 
        mov bx, 0x3000
        mov es, bx ; here is the data segment
        mov di, 0
        
        ; compare to our segment
        mov ax, 0x2000
        mov ds, ax
        mov si, filename
        
        mov cx, 0x3600 ; bigger than this 
        mov bx, 11

        clc
        call findstr_in_junk
        jc .getsector
    .notfound:
        mov ah, 0x0e
        mov al, "N"
        int 0x10
        hlt
        jmp $
    .getsector:
    ; By this time my location of string will be in es:di
    ; get low cluster number
    mov ax, [si+26]

    ; sector = cluster here + 32
    ;cheating here
    mov ax, 35

    .readfile:
        ; Sector 35 (ax)
        ; Since now SectorsPerTrack > Sector we need to do:
        ; Sector += 1 - for 1-based Sector later
        ; Track = Sector \ SectorsPerTrack quotient = 35/18 = 1 
        ; Sector = Sector \ SectorsPerTrack remainder =  17
        div byte [SectorsPerTrack]
        ; al = quotient track, ah = remainder sector

        mov ch, 1 ;al ; track
        mov cl, 17 ;ah ; sector = 17 - maybe not 1-based - 0-based?
        mov al, 4 ; sectors to read - from the file size but for now just one
        mov ah, 0x02
        mov dh, 0 ; head
        mov dl, 0x80 ; drive
        mov bx, 0x3000 ; segment to load it to
        mov es, bx
        mov bx, 0x0000 ; offset (add to seg)
        int 0x13
        jnc .readfileok
    .readfileerror:
        mov ah, 0x0e
        mov al, "E"
        int 0x10
        hlt
        jmp $
    .readfileok:
        mov ax, es
    ;    call ax:bx 
        mov ax, 0x3000 
        mov ds, ax
        mov si, 0
        mov cx, 0x800
        call write_hexes
    
ret

write_string:
    .writechar:
    lodsb ; load [si] into al
    mov ah, 0x0E ; write function
    int 0x10
    or al, al
    jz .done

    jmp .writechar
    .done:
     ret

write_hexes:
    .start:
    ;ds:si
    lodsb
    call write_hex
    cmp cx, 0
    je .end
    dec cx
    jmp .start
    .end:
    ret

write_string_hex:
    .wsh:
    lodsb
    or al, al ; 0-terminated
    jz .endwsh
    call write_hex
    
    jmp .wsh

    .endwsh:
    ret

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

findstr_in_junk:
    ; 1. ds:si = ^HELLO
    ; 2. es:di = ^\0\0\0\0\0\0HELLO\0\0\0\0\0
    ; 3. bx = string length
    ; 3. cx = when to give up
    ; CACHE bx in dx
    ; CACHE si in ax
    ; loop:
    ; if bx = 0 then return success
    ; if cx = 0 then return fail
    ; cmp [si], [di]
    ; if so inc si, inc di, dec bx 
    ; if not, inc di, reset si, reset bx
    ; regardless decrement cx
    ; jmp loop
    ; return value: dx
    mov dx, bx
    mov ax, si
    .loop:
    cmp bx, 0
    je .success
    cmp cx, 0
    je .fail
    cmpsb
    je .ok
    .notok:
    ;inc di
    mov si, ax
    mov bx, dx
    jmp .cont
    .ok:
    ;inc si
    ;inc di
    dec bx
    ;jmp .cont
    .cont:
    dec cx
    jmp .loop
    .success:
    stc
    mov dx, di
    ret
    .fail:
    clc
    mov dx, 0
    ret

kernld db 'Finding kernel.bin', 0x0d, 0x0a, 0
filename db 'KERNEL  BIN'
newline db 0x0a, 0x0d, 0

bootlabel:
    times 510-($-$$) db 0
    dw 0AA55h ; bootsector
buffer:
; pad the rest with zeroes
times 1048576-($-$$) db 0
