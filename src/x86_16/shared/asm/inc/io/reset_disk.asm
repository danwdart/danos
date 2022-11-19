; clobbers: dl, ah
reset_disk:
    mov dl, DISK_SDA ; sda
    xor ah, ah ; set to 0
    int INT_IO
    ret