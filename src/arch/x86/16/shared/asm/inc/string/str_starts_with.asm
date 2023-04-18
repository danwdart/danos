; reads: si, di
; clobbers:
; writes: carry
str_starts_with:
    .startfind:
        cmp byte [si], 0
        jz .success
        cmpsb
        je .startfind
        jnz .fail
    .success:
        stc
        ret
    .fail:
        clc
        ret