; https://en.wikipedia.org/wiki/BIOS_interrupt_call
; https://www.ctyme.com/intr/int.htm

%define INT_BIOS_PRTSCR_BOUND 0x05
%define INT_BIOS_RTC 0x08
%define INT_BIOS_KBD 0x09
%define INT_BIOS_VIDEO 0x10
%define INT_BIOS_EQUIPMENT_LIST 0x11
%define INT_BIOS_CONV_MEM_SIZE 0x12
%define INT_BIOS_DISK 0x13
%define INT_BIOS_SERIAL 0x14
%define INT_BIOS_MISC_SYSTEM 0x15
; skip cassette stuff
%define INT_BIOS_KB 0x16
%define INT_BIOS_PRINTER 0x17
; ignoring cassette basic
%define INT_BIOS_BOOT_PASSTHROUGH 0x18
%define INT_BIOS_REBOOT 0x19
%define INT_BIOS_RTC 0x1A
%define INT_BIOS_PCI 0x1a
%define INT_BIOS_CTRL_BREAK 0x1b ; called by 0x09
%define INT_BIOS_TIMER_TICK 0x1c
; next few are not to be called, VPT DPT VGCT
%define INT_BIOS_VID_PARAM_TABLE 0x1d
%define INT_BIOS_DISK_PARAM_TABLE 0x1e
%define INT_BIOS_VID_GRAPHICS_CHAR_TABLE 0x1f
%define INT_BIOS_ADDR_FIXED_DISK_1 0x41
%define INT_BIOS_ADDR_FIXED_DISK_2 0x42
%define INT_BIOS_RTC_ALARM 0x4a ; called by rtc for alarm