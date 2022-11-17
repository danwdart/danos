%include "src/inc/constants.asm"

;signature:
;    jmp kernel_start

;    db "DOK1"

kernel_start:
    cli                     ; Clear interrupts
    xor ax, ax ; set to 0
    mov ss, ax              ; Set stack segment and pointer
    mov sp, 0xFFFF
    sti                     ; Restore interrupts
    cld                     ; stack goes upwards
    
    mov ax, KERNEL_SEGMENT  ; Set all segments to match where kernel is loaded
    
    ; mov cs, ax ; this was already pushed, so I don't need to reset it...???
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax

    mov ax, KERNEL_OFFSET

    ; let's reset the video mode for some reason...
    call reset_video

print_welcome:
    mov si, welcome
    mov cx, 0x20
    call write_string

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

    ; call enable_protmode

loop:
    jmp $
    
; %include "src/inc/video/write_char.asm"
%include "src/inc/video/reset_video.asm"
%include "src/inc/video/write_chars.asm"
%include "src/inc/video/write_string.asm"
%include "src/inc/video/write_hexes.asm"

; %include "src/apps/protmode.asm"

    welcome db "Welcome to DanOS. Loaded kernel v0.2.", 0x0a, 0x0d, 0x0 
    prompt db '>', 0
    cmd_buffer times 64 db 0 
    newline db 0x0a, 0x0d, 0

; pad with zeroes
; times 0x10000-($-$$) db 0