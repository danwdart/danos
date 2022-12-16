CC	= gcc
CFLAGS32	= -m32 -Wall -Wextra -nostdlib -fno-builtin -nostartfiles -nodefaultlibs -Isrc/x86_32/kernel/c/lib -Isrc/x86_32/boot/c/lib
CFLAGS64	= -Wall -Wextra -nostdlib -fno-builtin -nostartfiles -nodefaultlibs -Isrc/x86_64/kernel/c/lib -Isrc/x86_64/boot/c/lib
CFLAGS64EFI = -Wall -Werror -fno-stack-protector -fpic -fshort-wchar -mno-red-zone -DEFI_FUNCTION_WRAPPER
CFLAGS64EFINEW = -Wall -Werror -fno-stack-protector -fpic -ffreestanding -fno-stack-check -fshort-wchar -mno-red-zone -maccumulate-outgoing-args
EFIDIR = /nix/store/vm982y77hrc626va4mcpr73vsskqgvll-gnu-efi-3.0.15
HEADERPATH = ${EFIDIR}/include/efi
HEADERS = -I ${HEADERPATH} -I ${HEADERPATH}/x86_64
LIBDIR = ${EFIDIR}/lib
LD	= ld
LDFLAGS32BIN = -m elf_i386 -T src/x86_32/boot/loadable16.ld
LDFLAGS32ELF = -m elf_i386 -T src/x86_32/kernel/linker.ld
LDFLAGS64BIN = -m elf_x86_64
LDFLAGS64ELF = -m elf_x86_64
LDFLAGS64EFI = -nostdlib -znocombreloc -T ${LIBDIR}/elf_x86_64_efi.lds -shared -Bsymbolic -L ${LIBDIR} -l:libgnuefi.a -l:libefi.a
LDFLAGS64EFINEW = -T ${LIBDIR}/elf_x86_64_efi.lds -shared -Bsymbolic -L ${LIBDIR} -l:libgnuefi.a -l:libefi.a
OBJCOPY = objcopy
OBJCOPY_FLAGS64EFINEW = -j .text -j .sdata -j .data -j .dynamic -j .dynsym -j .rel -j .rela -j .reloc --target=efi-app-x86_64
OBJCOPY_FLAGS64EFINEW = -j .text -j .sdata -j .data -j .dynamic -j .dynsym -j .rel -j .rela -j .rel.* -j .rela.* -j .reloc --target=efi-app-x86_64 --subsystem=10
AS = as
ASFLAGS32 = --32
NASM = nasm
NASMFLAGS16 = -i src/x86_16/shared/asm/inc
NASMFLAGS32BIN = -i src/x86_32/shared/asm/inc -fbin
NASMFLAGS32ELF = -i src/x86_32/shared/asm/inc -felf
NASMFLAGS64 = -i src/x86_64/shared/asm/inc
RM = rm
CKERNLIB32 = src/x86_32/kernel/c/lib
OBJFILES32 = src/x86_32/boot/asm/inc/loader.o src/x86_32/boot/c/kernel.o ${CKERNLIB32}/video.o ${CKERNLIB32}/io.o ${CKERNLIB32}/8042.o ${CKERNLIB32}/clever.o ${CKERNLIB32}/string.o src/x86_32/kernel/c/main.o

.PHONY: all

all:

clean:
	$(RM) -rf build
	find . -name *.o -delete

build:
	mkdir -pv build

build/uefi/hd.bin: build/uefi build/uefi/fat32.bin
	dd if=/dev/zero of=build/uefi/hd.bin bs=1M count=32
	sgdisk -o -n1 -t1:ef00 build/uefi/hd.bin
	dd if=build/uefi/fat32.bin of=build/uefi/hd.bin seek=2048 conv=notrunc

build/uefi/fat32.bin: build/uefi build/uefi/root/EFI/BOOT/BOOTX64.EFI
	dd if=/dev/zero of=build/uefi/fat32.bin bs=1M count=31
	mkfs.vfat -F32 build/uefi/fat32.bin # mformat -i build/uefi/fat32.bin -h 32 -t 32 -n 64 -c 1
	mmd -i build/uefi/fat32.bin ::/EFI
	mmd -i build/uefi/fat32.bin ::/EFI/BOOT
	mcopy -i build/uefi/fat32.bin build/uefi/root/EFI/BOOT/BOOTX64.EFI ::/EFI/BOOT/BOOTX64.EFI
	mcopy -i build/uefi/fat32.bin build/uefi/root/* ::/EFI/BOOT/

# BEGIN UEFI DIRS

build/uefi: build
	mkdir -pv build/uefi

build/uefi/root: build/uefi
	mkdir -pv build/uefi/root

build/uefi/root/EFI: build/uefi/root
	mkdir -pv build/uefi/root/EFI

build/uefi/root/EFI/BOOT: build/uefi/root/EFI
	mkdir -pv build/uefi/root/EFI/BOOT

src/x86_64/boot/c/efimain.o: src/x86_64/boot/c/efimain.c
	${CC} src/x86_64/boot/c/efimain.c -c ${CFLAGS64EFI} ${HEADERS} -o src/x86_64/boot/c/efimain.o

src/x86_64/boot/c/efimain.so: src/x86_64/boot/c/efimain.o
	$(LD) src/x86_64/boot/c/efimain.o ${LIBDIR}/crt0-efi-x86_64.o ${LDFLAGS64EFI} -o src/x86_64/boot/c/efimain.so

build/uefi/root/EFI/BOOT/BOOTX64.EFI: build/uefi/root/EFI/BOOT src/x86_64/boot/c/efimain.so
	objcopy -j .text -j .sdata -j .data -j .dynamic -j .dynsym -j .rel -j .rela -j .reloc --target=efi-app-x86_64 src/x86_64/boot/c/efimain.so build/uefi/root/EFI/BOOT/BOOTX64.EFI
	strip build/uefi/root/EFI/BOOT/BOOTX64.EFI

# END UEFI DIRS

# BEGIN BIOS DIRS

build/bios: build
	mkdir -pv build/bios

build/bios/root: build/bios
	mkdir -pv build/bios/root

# END BIOS DIRS

# BEGIN 64

build/bios/x86_64: build/bios
	mkdir -pv build/bios/x86_64

build/bios/x86_64/hd.bin: build/bios/x86_64 build/bios/x86_64/fat32.bin
	dd if=/dev/zero of=build/bios/x86_64/hd.bin bs=1M count=32
	sgdisk -o -n1 -t1:ef00 build/bios/x86_64/hd.bin
	dd if=build/bios/x86_64/fat32.bin of=build/bios/x86_64/hd.bin seek=2048 conv=notrunc

build/bios/x86_64/fat32.bin: build/bios/x86_64 build/bios/root/kern64c.elf build/bios/root/kern64c.bin
	dd if=/dev/zero of=build/bios/x86_64/fat32.bin bs=1M count=31
	mkfs.vfat -F32 build/bios/x86_64/fat32.bin # mformat -i build/bios/x86_64/fat32.bin -h 32 -t 32 -n 64 -c 1
	mmd -i build/uefi/fat32.bin ::/boot
	mcopy -i build/uefi/fat32.bin build/bios/root/kern64c.elf ::/boot/kernel.elf

build/bios/root/kern64c.elf: build/bios/root

build/bios/root/kern64c.bin: build/bios/root

# END 64

# BEGIN 32

build/bios/x86_32: build/bios
	mkdir -pv build/bios/x86_32

# these don't yet have a bootloader
build/bios/x86_32/hd.bin: build/bios/x86_32 build/bios/x86_32/fat32.bin build/bios/x86_16/mbr.bin
	dd if=/dev/zero of=build/bios/x86_32/hd.bin bs=1M count=32
	sfdisk build/bios/x86_32/hd.bin < src/x86_32/boot/sfdisk.conf
	dd if=build/bios/x86_32/fat32.bin of=build/bios/x86_32/hd.bin bs=512 seek=2048 conv=notrunc

build/bios/x86_32/fat32.bin: build/bios/x86_32 build/bios/root/kern16a.bin build/bios/root/kern32c.elf build/bios/root/kern32c.bin build/bios/root/kern32a.bin # add the others?
	dd if=/dev/zero of=build/bios/x86_32/fat32.bin bs=1M count=32
	mkfs.vfat -F16 build/bios/x86_32/fat32.bin
	mkdir -p mounts/bios/x86_32/
	sudo umount mounts/bios/x86_32/ || echo "ok"
	sudo mount -oloop build/bios/x86_32/fat32.bin mounts/bios/x86_32/
	sudo cp -r build/bios/root/*.bin build/bios/root/*.elf mounts/bios/x86_32/
	sync
	sudo umount mounts/bios/x86_32/
	rm -rf mounts
# done not having a bootloader

src/x86_32/kernel/c/lib/%.o: src/x86_32/kernel/c/lib/%.c
	echo "Compiling $@ from $< in 32-bit mode"
	$(CC) $(CFLAGS32) -o $@ -c $<

src/x86_32/boot/c/kernel.o: src/x86_32/boot/c/kernel.c
	$(CC) $(CFLAGS32) -o $@ -c $<

src/x86_32/kernel/c/main.o: src/x86_32/kernel/c/main.c
	$(CC) $(CFLAGS32) -o $@ -c $<

src/x86_32/boot/asm/inc/loader.o: src/x86_32/boot/asm/inc/loader.asm
	$(NASM) $(NASMFLAGS32ELF) -o $@ $<

src/x86_32/boot/c/kernel32.o: src/x86_32/boot/c/kernel32.c
	$(CC) $(CFLAGS32) -o $@ -c $<

build/bios/root/flat32c.bin: build/bios/root src/x86_32/boot/c/kernel32.o
	$(LD) $(LDFLAGS32BIN) -o build/bios/root/flat32cp.elf src/x86_32/boot/c/kernel32.o
	objcopy -O binary -j .text -j .rodata -j .data -j .bss build/bios/root/flat32cp.elf build/bios/root/flat32c.bin

build/bios/root/kern32c.bin: build/bios/root $(OBJFILES32)
	$(LD) $(LDFLAGS32ELF) -o build/bios/root/kern32cp.elf $(OBJFILES32)
	objcopy -O binary -j .text -j .rodata -j .data -j .bss build/bios/root/kern32cp.elf build/bios/root/kern32c.bin

build/bios/root/kern32c.elf: build/bios/root $(OBJFILES32)
	$(LD) $(LDFLAGS32ELF) -o build/bios/root/kern32c.elf $(OBJFILES32)

build/bios/root/kern32a.bin: build/bios/root src/x86_32/kernel/asm/kernel32.asm
	$(NASM) $(NASMFLAGS32BIN) src/x86_32/kernel/asm/kernel32.asm -o build/bios/root/kern32a.bin

# END 32


# BEGIN 16

build/bios/x86_16: build/bios
	mkdir -pv build/bios/x86_16

build/bios/x86_16/hd.bin: build/bios/x86_16 build/bios/x86_16/mbr.bin build/bios/x86_16/fat12.bin
	cat build/bios/x86_16/mbr.bin build/bios/x86_16/fat12.bin > build/bios/x86_16/hd.bin

build/bios/x86_16/mbr.bin: build/bios/x86_16 src/x86_16/boot/asm/mbr.asm
	$(NASM) $(NASMFLAGS16) src/x86_16/boot/asm/mbr.asm -o build/bios/x86_16/mbr.bin

build/bios/x86_16/fat12.bin: build/bios/x86_16 build/bios/x86_16/vbr.bin build/bios/root/kern16a.bin build/bios/root/kern32a.bin build/bios/root/flat32c.bin # build/bios/root/kern32c.bin  build/bios/root/kern32c.elf
	dd if=/dev/zero of=build/bios/x86_16/fat12.bin count=2K
	dd if=build/bios/x86_16/vbr.bin of=build/bios/x86_16/fat12.bin conv=notrunc
	mkdir -p mounts/bios/x86_16/
	sudo umount mounts/bios/x86_16/ || echo "ok"
	sudo mount -oloop build/bios/x86_16/fat12.bin mounts/bios/x86_16/
	sudo cp -r build/bios/root/kern16a.bin build/bios/root/kern32a.bin build/bios/root/flat32c.bin mounts/bios/x86_16/
	sync
	sudo umount mounts/bios/x86_16/
	rm -rf mounts

build/bios/x86_16/vbr.bin: build/bios/x86_16 src/x86_16/boot/asm/vbr.asm
	$(NASM) $(NASMFLAGS16) src/x86_16/boot/asm/vbr.asm -o build/bios/x86_16/vbr.bin

build/bios/root/kern16a.bin: build/bios/root src/x86_16/kernel/asm/kernel16.asm
	$(NASM) $(NASMFLAGS16) src/x86_16/kernel/asm/kernel16.asm -o build/bios/root/kern16a.bin

# END 16


# BEGIN ALL

x86_64_all: build/uefi/hd.bin build/bios/x86_64/hd.bin build/bios/root/kern32c.elf

x86_32_all: build/bios/x86_32/hd.bin build/bios/root/kern32c.elf

x86_16_all: build/bios/x86_16/hd.bin

all: x86_64_all x86_32_all x86_16_all

# END ALL


# BEGIN QEMU

qemu16a: build/bios/x86_16/hd.bin
	qemu-system-i386 -m 8 build/bios/x86_16/hd.bin

qemu32c: build/bios/x86_32/hd.bin
	qemu-system-i386 -m 64 build/bios/x86_32/hd.bin

qemu32c_direct: build/bios/root/kern32c.elf
	qemu-system-i386 -m 64 -kernel build/bios/root/kern32c.elf # build/bios/x86_32/hd.bin

qemu64c: build/bios/x86_64/hd.bin
	qemu-system-x86_64 -enable-kvm -cpu qemu64 -drive file=build/bios/x86_64/hd.bin,format=raw

qemu64c_direct: build/bios/x86_64/hd.bin
	qemu-system-x86_64 -enable-kvm -cpu qemu64 -kernel build/bios/x86_64/kern32c.elf -drive file=build/bios/x86_64/hd.bin,format=raw

qemu64c_uefi: build/uefi/hd.bin
	qemu-system-x86_64 -enable-kvm -cpu qemu64 -pflash OVMF_CODE.fd -pflash OVMF_VARS.fd -drive file=build/uefi/hd.bin,format=raw

# END QEMU