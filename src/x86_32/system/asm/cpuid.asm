; todo esi/edi
cpuid:
    mov eax, 0
    push eax
    cpuid
    push ecx
    push edx
    push ebx

loop:
    pop eax
    cmp eax, 0
    je done

next_byte:
    stosb
    mov al, 0x0f ; ???
    stosb
    shr eax, 8
    cmp al, 0x00
    jne next_byte

    jmp loop

done:
    ret