%include "src/x86_16/shared/asm/inc/constants/config.asm"


align 4

GDT_PTR:
dw GDT_END-GDT-1 ; size - 1
dd KERNEL_SEGMENT*0x10+GDT ; offset

align 16

GDT:
GDT_NULL: dq 0
; base = 0x00000000
; limit = 0xFFFFF * 4 kB granularity = full 4GB address space
; flags = 0xC = 0b1100 (4KB granularity, 32bit)
; access byte = 0x92 = 10010010 (present, ring 0, code/data segment, writable
GDT_BOOT_DS: dq 0x00CF92000000FFFF
GDT_BOOT_CS: dq 0x00CF9A000000FFFF ; same as DS but with executable set in access byte
GDT_END: