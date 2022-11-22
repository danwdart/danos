; We want to find a string in another string
; es:di = big string, ds:si = 0-term'd string, 
; es:di e.g. 3000:0000 00 0f ff 00 00 K E R N E L 1 6 B I N 00 00 
; ds:si e.g. 2000:0128 K E R N E L 1 6 B I N 00

; params: es:di = needle, ds:si = haystack, cx = max length.
; returns: carry bit if ok, es:di to beginning of match.
; clobbers: cx, dx, equal bit. (for now... is that reasonably restorable? pusha/pushf/popf/popa?)
; interrupt flag status: unchanged (should we clear as we go through here?)
findfile:
    ; backup si into dx (so we can check from the beginning)
    mov dx, si
    mov si, progress_find_kernel_location
    call write_string
    mov si, dx
    .startfind:
        ; end of check?
        cmp byte [si], 0 ; nothing left to check, end of string
        jz .success ; note that we cannot then check for zeroes in our comparison string.
        cmp cx, 0 ; too late! compare to 0
        jz .fail
        dec cx
        cmpsb ; compare ds:si with es:di and also increment each
        je .startfind

    .rstdi:
        ; alright... the string hasn't started yet...
        ; restore si (check again from the beginning)
        mov si, dx
        jmp .startfind

    .success:
        mov si, progress_found_kernel_location
        call write_string
        ; heck yeah, we found it!
        ; now es:di is at the character at the end of its first occurrence.
        
        add di, 0x0f ; That should be enough! es:di should now point to where we should look for the file. At least the low part.
        stc
        ret

    .fail:
        mov si, err_finding_kernel_location
        call write_string
        clc
        ret