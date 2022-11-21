%include "src/x86_16/shared/asm/inc/constants/int/bios/disk.asm"

; clobbers: dl, ah
reset_disk:
    mov dl, DISK_SDA ; sda
    xor ah, ah ; set to 0
    int INT_BIOS_DISK
    ret