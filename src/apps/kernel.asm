.kernel_start:
    cli             ; Clear interrupts
    mov ax, 0
    mov ss, ax              ; Set stack segment and pointer
    mov sp, 0FFFFh
    sti                     ; Restore interrupts
    cld                 ; stack goes upwards   
    mov ax, 0x4000          ; Set all segments to match where booter is loaded
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax

    mov al, "R"
    mov ah, 0x0e
    int 0x10
.loop:
    jmp $

    prompt db '>',0
    cmd_buffer times 64 db 0 
    newline db 0x0a, 0x0d, 0
