%include "constants/config.asm"
%include "constants/int/bios.asm"
%include "constants/int/bios/video.asm"
%include "constants/int/bios/video/mode.asm"

;signature:
;    jmp kernel_start

;    db "DOK1"

kernel_start:
    .setup_stack:
        cli                     ; Clear interrupts
    
        xor ax, ax ; set to 0
        mov ss, ax              ; Set stack segment and pointer
        mov sp, 0xFFFF          ; Stack goes from 0000:ffff downwards now (bottom 64k)
    
        sti                     ; Restore interrupts
        cld                     ; stack goes upwards
    
    .setup_segs:
        mov ax, KERNEL_SEGMENT  ; Set all segments to match where kernel is loaded
        
        ; mov cs, ax ; this was already pushed, so I don't need to reset it...???
        mov ds, ax
        mov es, ax
        mov fs, ax
        mov gs, ax
    .start:
        ; let's reset the video mode for some reason...
        call reset_video

print_welcome:
    mov si, welcome
    call write_string

;loadk32:
    call find_file_kernel
    call load_kernel32
    
    call reset_video

    call setup_protmode

    jmp call_kernel32

    jmp $

%include "video/reset_video.asm"
%include "video/write_char.asm"
%include "video/write_chars.asm"
%include "video/write_string.asm"
%include "video/write_hex.asm"
%include "video/write_hexes.asm"

%include "io/load_kernel32.asm"
%include "io/find_file_kernel.asm"
%include "io/reset_disk.asm"
%include "string/strfind.asm"

%include "protmode/setup_protmode.asm"
%include "protmode/call_kernel32.asm"
%include "protmode/gdt32.asm"

filename db "KERN32A BIN", 0x0
progress_read_fat db "Reading FAT for kernel32", 0x0d, 0x0a, 0
progress_find_kernel_location db "Finding kernel32...", 0x0d, 0x0a, 0
progress_found_kernel_location db "Found kernel32", 0x0d, 0x0a, 0
progress_read_kernel db "Reading kernel32", 0x0d, 0x0a, 0
progress_calling_kernel db "Calling kernel32...", 0x0d, 0x0a, 0
err_read_fat db "Can't read FAT for kernel32", 0x0d, 0x0a, 0
err_finding_kernel_location db "Can't find kernel32", 0x0d, 0x0a, 0
err_read_kernel db "Can't read kernel32", 0x0d, 0x0a, 0

; temp
;protmode:
;jmp $

; %include "src/x86_16/kernel/asm/inc/protmode/protmode.asm"

; %include "src/root/cpuid.asm"

; %include "src/inc/longmode/enter_longmode.asm"
; %include "src/inc/longmode/longmode.asm"
; %include "src/inc/longmode/gdt64.asm"

    welcome db "Welcome to DanOS. Loaded 16-bit kernel v0.2.", 0x0a, 0x0d, 0x0 
    prompt db '>', 0
    cmd_buffer times 64 db 0 
    newline db 0x0a, 0x0d, 0

; pad with zeroes
; times 0x10000-($-$$) db 0