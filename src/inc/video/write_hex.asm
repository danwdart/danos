%include "src/inc/constants.asm"

; input: al
; clobbers: bl, ah
write_hex:
    .write:
        mov bl, al ; bl now 0x41 for example
        shr bl, 4 ; bl now 0x04
        ; and bl, 0x0f ; make sure!!!
        cmp bl, 0x0a
        jl .cont
        add bl, 0x07
    .cont: 
        add bl, 0x30
        ; bl now correct
        ; bh can now be the higher byte
        mov bh, al ; bl now 0xba
        and bh, 0x0f ; bl now 0x0a
        cmp bh, 0x0a
        jl .islesst
        add bh, 0x07
    .islesst:
        add bh, 0x30
        ; bx now correct
        mov al, bl
        mov ah, VIDEO_PRINT; print
        int INT_VIDEO
        mov al, bh
        int INT_VIDEO
        mov al, " "
        int INT_VIDEO
    .end:
        ret

;write_hex:
;    .write:
;        mov bl, al ; bl now 0x41 for example
;        shr bl, 4 ; bl now 0x04
;        and bl, 0x0f ; make sure!!!
;        cmp bl, 0x0a
;        jl .isless
;    .isge:
;        add bl, ASCII_HEX_LETTER_OFFSET ; for instance 0x0b + 0x37 = "B"
;        jmp .cont
;    .isless:
;        add bl, ASCII_HEX_NUMBER_OFFSET ; e.g. 0x04 + 0x30 = 0x34 = "4"
;        jmp .cont
;    .cont: 
;        ; bl now correct
;        ; bh can now be the higher byte
;        mov bh, al ; bl now 0xba
;        and bh, 0x0f ; bl now 0x0a
;        cmp bh, 0x0a
;        jl .islesst
;    .isget:
;        add bh, ASCII_HEX_LETTER_OFFSET
;        jmp .contt
;    .islesst:
;        add bh, ASCII_HEX_NUMBER_OFFSET
;        jmp .contt
;    .contt:
;        ; bx now correct
;        mov al, bl
;        mov ah, VIDEO_PRINT; print
;        int INT_VIDEO
;        mov al, bh
;        int INT_VIDEO
;    .end:
 ;       ret;