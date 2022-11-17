kb_test:
    ; check for key
    mov ah, 0x01
    int 0x16
    jz kb_test

    ; get ascii code into al, scancode into ah
    mov ah, 0x00
    int 0x16

    cmp al, 0x0d
    je crlf

    cmp al, 0x08
    je bksp

    jmp writeit

crlf:
    mov al, 0x0a
    call write_char
    mov al, 0x0d

    jmp writeit

bksp:
    mov al, 0x08
    call write_char
    mov al, " "
    call write_char
    mov al, 0x08

    jmp writeit

writeit:
    call write_char
    
    jmp kb_test

loop:
    jmp $