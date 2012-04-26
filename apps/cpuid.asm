


;cpuid:
;cpuid
;push ecx
;push edx
;push ebx
;mov cl, 12
;mov ah, 0x0e
;.start:
;pop al
;int 0x10
;cmp cl, 0
;je .end
;dec cl
;jmp .start
;.end: 
