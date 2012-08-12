mov al, "R"
mov ah, 0x0e
int 0x10
jmp $

prompt db '>',0
cmd_buffer times 64 db 0 
newline db 0x0a, 0x0d, 0
