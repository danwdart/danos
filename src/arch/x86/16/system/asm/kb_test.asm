kb_test:
    ; check for key
    mov ah, KB_READ_INPUT_STATUS
    int INT_BIOS_KB
    jz kb_test

    ; get ascii code into al, scancode into ah
    mov ah, KB_READ_CHAR
    int INT_BIOS_KB

    cmp al, KB_CR
    je crlf

    cmp al, KB_BKSP
    je bksp

    jmp writeit

crlf:
    mov al, KB_LF
    call write_char
    mov al, KB_CR

    jmp writeit

bksp:
    mov al, KB_BKSP
    call write_char
    mov al, " "
    call write_char
    mov al, KB_BKSP

    jmp writeit

writeit:
    call write_char

    jmp kb_test

loop:
    jmp $