; https://en.wikipedia.org/wiki/INT_13H
; https://www.ctyme.com/intr/int-13.htm
%define DISK_RESET 0x00
%define DISK_CHECK_STATUS 0x01
%define DISK_READ_SECTORS 0x02
%define DISK_WRITE_SECTORS 0x03
%define DISK_VERIFY_SECTORS 0x04
%define DISK_FORMAT_TRACK 0x05
%define DISK_GET_PARAMS 0x08
%define DISK_INIT_FIXED_PARAMS 0x09
%define DISK_SEEK_TRACK 0x0c
%define DISK_RESET_FIXED_CONTROLLER 0x0d
%define DISK_GET_DRIVE_TYPE 0x15
%define DISK_GET_FLOPPY_MEDIA_CHANGE_STATUS 0x16
%define DISK_SET_TYPE 0x17
%define DISK_SET_FLOPPY_MEDIA_TYPE 0x18
%define DISK_EDD_CHECK 0x41
%define DISK_EXT_READ_SECTORS 0x42
%define DISK_EXT_WRITE_SECTORS 0x43
%define DISK_EXT_VERIFY_SECTORS 0x44
%define DISK_LOCK_UNLOCK 0x45
%define DISK_EJECT 0x46
%define DISK_EXT_SEEK 0x47
%define DISK_EXT_GET_PARAMS 0x48
%define DISK_EXT_GET_MEDIA_CHANGE_STATUS 0x49
%define DISK_EXT_SET_HW_CONFIG 0x4e