; reads:
; clobbers: dl, ah
; writes:
reset_disk:
    mov dl, DISK_SDA ; sda
    xor ah, ah ; set to 0
    int INT_BIOS_DISK
    ret