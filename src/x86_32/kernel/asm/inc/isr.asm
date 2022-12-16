; In isr.c
[EXTERN isr_handler]

isr_common_stub:
   pusha                    ; Pushes edi,esi,ebp,esp,ebx,edx,ecx,eax

   ; We were here
   mov ax, ds               ; Lower 16-bits of eax = ds.
   push eax                 ; save the data segment descriptor

   ; We're back in kernel mode!
   mov ax, 0x10  ; load the kernel data segment descriptor
   mov ds, ax
   mov es, ax
   mov fs, ax
   mov gs, ax

   ; do the C
   call isr_handler

   ; go back to whence we came
   pop eax
   mov ds, ax
   mov es, ax
   mov fs, ax
   mov gs, ax

   ; Restore the state
   popa
   add esp, 8     ; Cleans up the pushed error code and pushed ISR number
   sti
   ; Goodbye!
   iret           ; pops 5 things at once: CS, EIP, EFLAGS, SS, and ESP