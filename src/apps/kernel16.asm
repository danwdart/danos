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
    
    mov ax, 0  ; Set all segments to match where kernel is loaded
    
    ; mov cs, ax ; this was already pushed, so I don't need to reset it...???
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax

    ; let's reset the video mode for some reason...
    call reset_video

print_welcome:
    mov si, KERNEL_SEGMENT*0x10+welcome
    mov cx, 0x20
    call write_string

    call enter_protmode
    
; %include "src/inc/video/write_char.asm"
%include "src/inc/video/reset_video.asm"
%include "src/inc/video/write_chars.asm"
%include "src/inc/video/write_string.asm"
%include "src/inc/video/write_hexes.asm"

%include "src/apps/enter_protmode.asm"
%include "src/apps/protmode.asm"
%include "src/apps/cpuid.asm"
%include "src/apps/enter_longmode.asm"
%include "src/apps/longmode.asm"
%include "src/apps/gdt64.asm"

    welcome db "Welcome to DanOS. Loaded 16-bit kernel v0.2.", 0x0a, 0x0d, 0x0 
    prompt db '>', 0
    cmd_buffer times 64 db 0 
    newline db 0x0a, 0x0d, 0

; pad with zeroes
; times 0x10000-($-$$) db 0