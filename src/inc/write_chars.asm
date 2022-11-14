%include "src/inc/write_char.asm"

write_chars:
    .wchs:
        lodsb
        call write_char
        dec cx
        cmp cx, 0
        jg .wchs
        ret