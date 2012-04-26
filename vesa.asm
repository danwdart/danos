vesa_get_info:
    mov ax, 0x4f00
    int 0x10
	; this should have set es:di to our point
    cmp ax, 0x4f00 ; did it work
    je .fail

    ;add di, 4 ; get to after the VESA signature
    ;mov ax, di
    ;mov si, ax
    mov si, di
    mov cx, 16
    call write_hexes
    jmp .end

.fail:
    mov ah, 0x0e
    mov al, "F"
    int 0x10
.end:
