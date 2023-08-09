%include "constants/config.asm"
%include "constants/kb.asm"
%include "constants/int/bios.asm"
%include "constants/int/bios/kb.asm"
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
        mov sp, 0x0FFF          ; Stack goes from 0000:ffff downwards now (bottom 64k)

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

print_cli:
    mov si, prompt
    call write_string

    mov di, cmd_buffer

    ; clear first byte
    mov al, 0
    stosb

    mov di, cmd_buffer

    .kb_check:
        ; check for key
        mov ah, KB_READ_INPUT_STATUS
        int INT_BIOS_KB
        jz .kb_check

        ; get ascii code into al, scancode into ah
        mov ah, KB_READ_CHAR
        int INT_BIOS_KB

        cmp al, KB_CR
        je .crlf

        cmp al, KB_BKSP
        je .bksp

        stosb ; al -> es:di, inc di

        jmp .writeit

    .crlf:
        mov al, KB_LF
        call write_char
        mov al, KB_CR

        call write_char

        call process_cmd

        mov di, cmd_buffer
        mov al, 0
        mov cx, 64
        rep stosb

        jmp print_cli

    .bksp:
        mov al, KB_BKSP
        call write_char
        mov al, " "
        call write_char
        mov al, KB_BKSP

        jmp .writeit

    .writeit:
        call write_char

        jmp .kb_check

process_cmd:
        ; blank line?
        mov si, cmd_buffer
        cmp byte [si], 0
        jne .continue
        ret ; retne?

    .continue:
        mov si, cmd_ver
        mov di, cmd_buffer
        call str_starts_with ; doesn't mind if stuff after, not a "real" command, @TODO match exactly
        jc .is_ver

        mov si, cmd_run
        mov di, cmd_buffer ; will have been incremented a fair bit
        call str_starts_with
        jc .is_run

        mov si, cmd_help
        mov di, cmd_buffer ; will have been incremented a fair bit
        call str_starts_with
        jc .is_help

        mov si, cmd_echo
        mov di, cmd_buffer
        call str_starts_with
        jc .is_echo

        ; debug
        ;jmp .otherwise

    .filename_to_run:
        ;mov si, cmd_buffer
        ;call write_string
        ;jmp .otherwise
        mov si, cmd_buffer
        call find_file

        ; jc .problem_finding_file - probably no such file! Let's move on.
        jc .otherwise

        ; debug

        mov bx, EXE16_SEGMENT
        mov es, bx
        mov bx, EXE16_OFFSET

        call load_file

        jc .problem_loading_file ; we know it's a real file but we can't load it

        call call_file

        mov bx, KERNEL_SEGMENT
        mov es, bx
        mov bx, KERNEL_OFFSET

        ret
    .problem_loading_file:
        mov si, err_read_file
        call write_string
        ret
    .otherwise:
        mov si, result_unknown_command
        call write_string
        ret
    ; @TODO table
    .is_help:
        mov si, result_help
        call write_string
        ret
    .is_ver:
        mov si, result_ver
        call write_string
        ret
    .is_run:
        mov si, result_run
        call write_string
        ret
    .is_echo:
        mov si, di
        inc si ; to get rid of the first space
        call write_string
        mov si, newline
        call write_string
        ret

;loadk32:
;    mov si, filename
;    call find_file
;    mov bx, KERNEL32_SEGMENT 		; segment to load it to
;    mov es, bx
;    mov bx, KERNEL32_OFFSET 		; offset (add to seg)
;    call load_file
;    jc .noproblem
;    .problem:
;        mov si, err_read_file
;        call write_string
;        cli
;        hlt
;        jmp $;

;    .noproblem:

;    call reset_video;

;    call setup_protmode

;    jmp call_kernel32

end_of_kernel:
    mov si, err_end_of_kernel
    call write_string
    jmp $

%include "video/reset_video.asm"
%include "video/write_char.asm"
%include "video/write_chars.asm"
%include "video/write_string.asm"
%include "video/write_hex.asm"
%include "video/write_hexes.asm"

%include "io/load_file.asm"
%include "io/find_file.asm"
%include "io/call_file.asm"
%include "io/reset_disk.asm"
%include "string/strfind.asm"
%include "string/str_starts_with.asm"

%include "protmode/setup_protmode.asm"
%include "protmode/call_kernel32.asm"
%include "protmode/gdt32.asm"

; temp
;protmode:
;jmp $

; %include "src/x86_16/kernel/asm/inc/protmode/protmode.asm"

; %include "src/root/cpuid.asm"

; %include "src/inc/longmode/enter_longmode.asm"
; %include "src/inc/longmode/longmode.asm"
; %include "src/inc/longmode/gdt64.asm"
constants_for_loading_kernel32:
    ; filename db "KERN32A BIN", 0x0
    progress_read_fat db "Reading FAT for kernel32", 0x0d, 0x0a, 0
    progress_find_kernel_location db "Finding kernel32...", 0x0d, 0x0a, 0
    progress_found_kernel_location db "Found kernel32", 0x0d, 0x0a, 0
    progress_read_kernel db "Reading kernel32", 0x0d, 0x0a, 0
    progress_calling_kernel db "Calling kernel32...", 0x0d, 0x0a, 0
    err_read_fat db "Can't read FAT for kernel32", 0x0d, 0x0a, 0
    err_finding_kernel_location db "Can't find kernel32", 0x0d, 0x0a, 0
    err_read_file db "Can't read file", 0x0d, 0x0a, 0
    err_end_of_kernel db "You've reached the end of the kernel. You should not be here.", 0x0d, 0x0a, 0

std_constants:
    welcome db "Welcome to DanOS. Loaded 16-bit kernel v0.2.", 0x0a, 0x0d, 0x0a, 0x0d, 0x0
    prompt db '(kern) hd0a:/# ', 0 ;  (DANOS FILES, FAT12) ; HardDisk
    cmd_help db "help", 0
    cmd_echo db "echo", 0
    cmd_run db "run", 0
    cmd_ver db "ver", 0
    result_help db "Available commands: help, ver, run, echo", 0x0a, 0x0d, 0
    result_run db "I would run something but I have nothing to run.", 0x0a, 0x0d, 0
    result_ver db "DanOS version 0.2, at your service!", 0x0a, 0x0d, 0
    result_unknown_command db "Sorry, I don't know what that means.", 0x0a, 0x0d, 0
    cmd_buffer times 64 db 0
    cmd_buffer_ptr db 0
    newline db 0x0a, 0x0d, 0

; pad with zeroes
; times 0x10000-($-$$) db 0