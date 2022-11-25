%include "constants/int/bios/disk.asm"
%include "constants/config.asm"

; reads:
; clobbers: si, ax, dx, si
; writes:
load_file:
    .reset:
        call reset_disk

    .read:
        mov ah, DISK_READ_SECTORS        ; routine
        mov al, 0x80        ; maximum filesize in sectors = 64k / 512 = 0x80 - sectors to read
        ;xor ch, ch 	; Cylinder 8/10 = 0
        ;mov cl, 54  ; Cylinder 2/10 Sector 6 ; todo get this
        xor dh, dh		    ; Head = 0
        mov dl, DISK_SDA 		; drive ; TODO get backed up
        int INT_BIOS_DISK