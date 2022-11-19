callprog32:
        mov si, progress_calling_kernel
        call write_string
        mov bx, KERNEL_SEGMENT 		; segment to load it to
        mov es, bx
        mov bx, KERNEL_OFFSET 		; offset (add to seg)
        
         
        call enter_protmode

protmode:
        push es
        push bx
        retf
        