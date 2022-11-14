%include "src/inc/write_hex.asm"

write_hexes:
    .whs:
        lodsb
        call write_hex
        dec cx
        cmp cx, 0
        jg .whs
        ret