Structure

The DanOS OS structure looks like:

Bootcode:

MBR @ 07c0:0000h
v
Partition bootsector @ 1000:0000h / 07c0:000h
v
Kernel @ 2000:0000h > Modules [3000:0000h]
v
Interpreter - directly after kernel

Filesystem
The filesystem module will expose a virtual file structure:

[HardDisk[0,1,2..][a,b,c], label, fs]:/ - for FAT12, LFN
	Modules - libraries
		Disks
			IDE
		Devices
			Network
			r8169
		Filesystems
			FAT12
		Networking
			ethernet
			ipv4
			ipv6
			icmp
			tcp
			udp
		Graphics
			vesa
		ApplicationSupport
			com
			elf32
			pe etc.

	Services - daemons - invokable but do not show output normally (or only to logs)
		Networking
			dhcp
				client
			http
				client
		Graphics
			workspace
			window

	Applications - invokable
Floppy0:/
[Usb0a,label]:/

System:/ - In-memory virtual FS
	Modules - modules loaded - they may be loaded or unloaded by copying or using loadmod/unloadmod
	Applications
		Active
		Resident
	Files - open files are copied here for peeking/poking

Counter app for binary set bgcolours
Timing button press game
Basic like or forth language
Text editor
Com runner
Emulator for arm or gameboy
Shift ctrl flags with keys

file access like:

Uppercase, pad to 8, change dot to space