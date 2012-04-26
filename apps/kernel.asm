mov al, "K"
mov ah, 0x0e
int 0x10

; Begin kernel functions

findstr:
    ; 1. si = ^HELLO
    ; 2. di = ^ASTRINGHELLOASTRING
    ; cmp [si], [di]
    ; if [si] = 0 then return carry decrement di
    ; if cx = 0 then return nocarry
    ; if same, increment both
    ; 1. si = H^ELLO
    ; if different, increment di, reset si
    ; regardless decrement cx
    ; go to 3

    .loop:
    mov al, [si] ; lodsb would work just as well I suppose
    mov dx, si ; save location
    mov bl, [di]
    cmp al, 0
    je .success
    cmp cx, 0
    je .fail
    cmp al, bl
    jne .different
    .same:
    inc si
    inc di
    jmp .finish
    .different:
    inc di
    mov si, dx
    jmp .finish
    .finish:
    dec cx
    jmp .loop
    .success:
    dec di
    stc
    mov dx, di ; I just added this for good measure
    ret
    .fail:
    clc
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


prompt db '>',0
cmd_buffer times 64 db 0 
newline db 0x0a, 0x0d, 0
