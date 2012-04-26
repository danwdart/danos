init:
    mov ax, 0x07C0  ; set up segments
    mov ds, ax
    mov es, ax

main:
    mov si, msg
    call write_string

    mov si, msg2
    call write_string_hex 

    mov si, newline
    call write_string

    call cli

cli:
    .loop:
        mov si, prompt
        call write_string

        call get_string
    
        ; by now the full string is in [di], [di+1], ...
        ; we need to compare to si
        
        ;mov si, cmd_buffer
        ;call write_string
        
        mov si, hello
        call strcmp
        jc .hello ; Jump if Carry (bit set)

        mov si, boot_string
        call strcmp
        jc .boot

        jmp .loop 

    .hello:
        mov si, hello_response
        call write_string
        jmp .loop

    .boot:
        call loader
        jmp .loop

loader:
    .reset:
        mov dl, 0x80 ; sda
        mov ah, 0
        int 0x13

    .read:
        mov ah, 0x02
        mov al, 8 ; sectors to read
        mov ch, 0 ; track
        mov cl, 2 ; sector
        mov dh, 0 ; head
        mov dl, 0x80 ; drive
        mov bx, 0x2000 ; segment ( * 0x10 )
        mov es, bx
        mov bx, 0x0000 ; offset (add to seg)
        int 0x13
        jnc .ok

        mov al, ah
        call write_hex
        cli
        hlt

    .ok:
        push es
        push bx
        retf ; ip=bx. cs = es 

get_string:
    xor cl, cl ; blank count
    mov di, cmd_buffer

    .getchar:

    mov ah, 0
    int 0x16 ; al contains the key

    cmp al, 0x0d
    je .enter

    stosb
    ; Don't inc di here - it does it - and if you do, you could end up with 0x41 0x00 0x42
    ; - and the comparison would end at 0x00 of course

    ; echo it
    mov ah, 0x0e
    int 0x10

    jmp .getchar

    .enter:
    ; store a 0
    mov al, 0
    stosb
    inc di

    ; do the newline
    mov si, newline
    call write_string
    
    ; reset di
    mov di, cmd_buffer
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
    ; 0-9 = 0x30 - 0x39
    ; A-F = 0x41 - 0x46
    ; Input: 0x0E (in al)
    ; Output: 0x3045 (big-endian to print)
    ; Get the first nybble, SHL it by 8
    ; If the first nybble is below 0x0A00
    ; add 0x2F00
    ; If it's not
    ; add 0x4000
    ; SHL 4
    ; Add the 2nd nybble
    ; If the 2nd nybble is below 0x0A
    ; add 0x2F
    ; if not
    ; add 0x40
    ; Ret

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

strcmp:
    .loop:
    mov al, [si] ; Move the value of the current source index into al
    mov bl, [di] ; move the value of the current dest index into bl
   
    cmp al, bl ; are they the same?

    jne .notequal
    ; so we're equal 
    
    cmp al, 0 ; is al 0 (we know bl is 0)
    je .done

    inc si
    inc di ; increment the index counters (so we can get the next bytes)
    jmp .loop

    .notequal:
            ; so we need somewhere to store our result,
            ; we could use anywhere but here an easy 1-bit ref will do 
        clc ; CLear Carry
        ret

    .done:
        stc ; SeT Carry
        ret

data:
    msg db 'Welcome to DanOS!', 0x0a, 0x0d, 0
    msg2 db 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 0
    hello db 'hello', 0
    hello_response db 'Salutations!', 0x0a, 0x0d, 0
    boot_string db 'boot', 0
    newline db 0x0a, 0x0d, 0
    prompt db '>',0
    cmd_buffer times 64 db 0 

times 440-($-$$) db 0

;db = 1, dw = 2, dd = 4
disksig dd "DAND"
extra dw 0x0000

status db 0x80 ; 0x00 not bootable
head_start db 0x00
sector_start db 0x02
cylinder_start db 0x00
parttype db 0x01 ; 1 = FAT12
head_end db 0x01
sector_end db 0x20
cylinder_end db 0x02
lba_firstsector_le dd 0x00000001
num_sect_le dd 0x000007ff

; no more parts
part2 dd 0,0,0,0
part3 dd 0,0,0,0
part4 dd 0,0,0,0

dw 0AA55h ; bootsector - some BIOSes require this signature
