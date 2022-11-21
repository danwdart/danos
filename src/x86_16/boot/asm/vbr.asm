%include "constants/config.asm"
%include "constants/int/bios.asm"
%include "constants/int/bios/video.asm"
%include "constants/int/bios/disk.asm"

%define FILENAME_LENGTH 11

signature:
    call init
    OEMId: db 'DANOS0.1'
    BytesPerSector: dw 512
    SectorsPerCluster: db 1
    ReservedForBoot: dw 1
    NumberOfFats: db 2
    NumberOfDirEntries: dw 512 	; sectors to read = direntries * 32 / (bytespercluster*sectorspercluster) = 32
    LogicalSectors: dw 2047 	;= 1M. 0x0800
    MediaDescriptor: db 0xf8 	; f8 = HD
    SectorsPerFat: dw 9 		;2
    SectorsPerTrack: dw 18 	;32
    TotalHeads: dw 2 		; 0x0040
    HiddenSectors: dd 0
    LargeSectors: dd 0
    ; fat12
    DriveNumber: db 0x80 	; useless!
    NTFlags: db 0x00 		; reserved
    DriveSignature: db 0x29 	; or 0x28 - so NT recognises it
    VolumeId: dd 0x78563412
    VolumeLabel: db 'DANOS FILES'
    SysId: db 'FAT12   '

init:
        cli				; Clear interrupts
        xor ax, ax ; set to 0
        mov ss, ax 		    ; Set stack segment and pointer
        mov sp, 0x0FFFF
        sti             	; Restore interrupts
        cld         		; stack goes upwards   
        mov ax, VBR_SEGMENT ; Set all segments to match where booter is loaded
        mov ds, ax    
        mov es, ax    
        mov fs, ax    
        mov gs, ax
code:
        ;mov si, welcome
        ;call write_string   
        call find_file_kernel
        call load_kernel
        jmp callprog16

%include "video/write_string.asm"
%include "io/reset_disk.asm"
%include "io/find_file_kernel.asm"
%include "io/findfile.asm"
%include "video/write_char.asm"
%include "io/load_kernel.asm"
%include "io/callprog16.asm"

data:
        progress_read_fat db "Reading FAT", 0x0d, 0x0a, 0
        progress_find_kernel_location db "Finding kernel...", 0x0d, 0x0a, 0
        progress_found_kernel_location db "Found kernel", 0x0d, 0x0a, 0
        progress_read_kernel db "Reading kernel", 0x0d, 0x0a, 0
        progress_calling_kernel db "Calling kernel...", 0x0d, 0x0a, 0
        err_read_fat db "Can't read FAT", 0x0d, 0x0a, 0
        err_finding_kernel_location db "Can't find kernel", 0x0d, 0x0a, 0
        err_read_kernel db "Can't read kernel", 0x0d, 0x0a, 0
        welcome db "DanLoader stage 2 booting...", 0x0d, 0x0a, 0
        filename db 'KERN16A BIN', 0
        newline db 0x0a, 0x0d, 0

bootlabel:
        times 510-($-$$) db 0
        dw 0AA55h ; bootsector