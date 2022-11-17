[BITS 64]
longmode:
    mov rdi, 0xb8000 + 2 * 0xa0
    mov rax, "L O N G "
    stosq
    mov rax, "M O D E "
    stosq

    pause
    jmp $