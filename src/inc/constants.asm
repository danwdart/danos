%define BOOTSEG 0x07C0

%define INT_VIDEO 0x10
%define VIDEO_PRINT 0x0e

%define INT_IO 0x13
%define DISK_SDA 0x80
%define DISK_TRACK 0
%define DISK_SECTOR 2
%define DISK_HEAD 0
%define DISK_SIG "DAND"
%define DISK_EXTRA 0x0000
%define DISK_PART_HEAD_START 0x00
%define DISK_PART_HEAD_END 0x00
%define DISK_PART_SECTOR_START 0x02
%define DISK_PART_SECTOR_END 0x20
%define DISK_PART_CYLINDER_START 0x00
%define DISK_PART_CYLINDER_END 0x02
%define DISK_PART_TYPE_FAT12 0x01
%define DISK_PART_LBA_FIRSTSECTOR 0x00000001
%define DISK_PART_NUM_SECT_LE 0x000007ff

%define MEM_SEGMENT 0x2000
%define MEM_OFFSET 0x0000

%define ASCII_HEX_LETTER_OFFSET 0x37
%define ASCII_HEX_NUMBER_OFFSET 0x30
%define FLAGS_BOOTABLE 0xAA55