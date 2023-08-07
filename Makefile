CC_X86 = x86_64-elf-gcc
LD_X86 = x86_64-elf-ld
AS_X86 = x86_64-elf-as
NASM = nasm
RM = rm
CFLAGSx86_32 = -m32 -Wall -Wextra -nostdlib -fno-builtin -nostartfiles -nodefaultlibs -Isrc/arch/x86/32/kernel/c/lib -Isrc/arch/x86/32/boot/c/lib
CFLAGSx86_64 = -m64 -Wall -Wextra -nostdlib -fno-builtin -nostartfiles -nodefaultlibs -Isrc/arch/x86/64/kernel/c/lib -Isrc/arch/x86/64/boot/c/lib
CFLAGSx86_64EFI = -Wall -Werror -fno-stack-protector -fpic -fshort-wchar -mno-red-zone -DEFI_FUNCTION_WRAPPER
CFLAGSx86_64EFINEW = -Wall -Werror -fno-stack-protector -fpic -ffreestanding -fno-stack-check -fshort-wchar -mno-red-zone -maccumulate-outgoing-args
CFLAGSAARCH26 =
CFLAGSAARCH32 =
CFLAGSAARCH64 =
EFIDIR = /nix/store/vm982y77hrc626va4mcpr73vsskqgvll-gnu-efi-3.0.15
HEADERPATH = ${EFIDIR}/include/efi
HEADERS = -I ${HEADERPATH} -I ${HEADERPATH}/x86/64
LIBDIR = ${EFIDIR}/lib
LDFLAGSx86_32BIN = -m elf_i386 -T src/arch/x86/32/boot/loadable16.ld
LDFLAGSx86_32ELF = -m elf_i386 -T src/arch/x86/32/kernel/linker.ld
LDFLAGSx86_64BIN = -m elf_x86_64
LDFLAGSx86_64ELF = -m elf_x86_64 -T src/arch/x86/64/kernel/linker.ld
LDFLAGSx86_64EFI = -nostdlib -znocombreloc -T ${LIBDIR}/elf_x86_64_efi.lds -shared -Bsymbolic -L ${LIBDIR} -l:libgnuefi.a -l:libefi.a
LDFLAGSx86_64EFINEW = -T ${LIBDIR}/elf_x86_64_efi.lds -shared -Bsymbolic -L ${LIBDIR} -l:libgnuefi.a -l:libefi.a
LDFLAGSAARCH26 =
LDFLAGSAARCH32 =
LDFLAGSAARCH64 = -T src/arch/arm/64/kernel/linker.ld
OBJCOPY = objcopy
OBJCOPY_FLAGSx86_64EFINEW = -j .text -j .sdata -j .data -j .dynamic -j .dynsym -j .rel -j .rela -j .reloc --target=efi-app-x86/64
OBJCOPY_FLAGSx86_64EFINEW = -j .text -j .sdata -j .data -j .dynamic -j .dynsym -j .rel -j .rela -j .rel.* -j .rela.* -j .reloc --target=efi-app-x86/64 --subsystem=10
ASFLAGSx86_32 = --32
ASFLAGSAARCH26 =
ASFLAGSAARCH32 =
ASFLAGSAARCH64 =
NASMFLAGSX86_16 = -i src/arch/x86/16/shared/asm/inc
NASMFLAGSx86_32BIN = -i src/arch/x86/32/shared/asm/inc -fbin
NASMFLAGSx86_32ELF = -i src/arch/x86/32/shared/asm/inc -felf
NASMFLAGSx86_64BIN = -i src/arch/x86/64/shared/asm/inc -fbin
NASMFLAGSx86_64ELF = -i src/arch/x86/64/shared/asm/inc -felf64
CKERNLIBX86_32 = src/arch/x86/32/kernel/c/lib
OBJFILESX86_32 = src/arch/x86/32/boot/asm/inc/multiboot.o src/arch/x86/32/boot/c/multiboot.o ${CKERNLIBX86_32}/video.o ${CKERNLIBX86_32}/io.o ${CKERNLIBX86_32}/8042.o ${CKERNLIBX86_32}/clever.o ${CKERNLIBX86_32}/string.o src/arch/x86/32/kernel/c/main.o
OBJFILESX86_64 = src/arch/x86/64/boot/asm/inc/multiboot.o src/arch/x86/64/boot/c/multiboot.o src/arch/x86/64/kernel/c/kernel64.o
OBJFILESAARCH26 =
OBJFILESAARCH32 =
OBJFILESAARCH64 =

.PHONY: all

all: x86_64_all x86_32_all x86_16_all

clean:
	$(RM) -rf build
	find . -name *.o -delete

build:
	mkdir -pv build

build/x86/uefi/hd.bin: build/x86/uefi build/x86/uefi/fat32.bin
	dd if=/dev/zero of=build/x86/uefi/hd.bin bs=1M count=32
	sgdisk -o -n1 -t1:ef00 build/x86/uefi/hd.bin
	dd if=build/x86/uefi/fat32.bin of=build/x86/uefi/hd.bin seek=2048 conv=notrunc

build/x86/uefi/fat32.bin: build/x86/uefi build/x86/uefi/root/EFI/BOOT/BOOTX64.EFI build/x86/bios/root/kern64c.elf build/x86/bios/root/kern64c.bin build/x86/bios/root/kern64a.bin
	dd if=/dev/zero of=build/x86/uefi/fat32.bin bs=1M count=31
	mkfs.vfat -F32 build/x86/uefi/fat32.bin # mformat -i build/x86/uefi/fat32.bin -h 32 -t 32 -n 64 -c 1
	mmd -i build/x86/uefi/fat32.bin ::/EFI
	mmd -i build/x86/uefi/fat32.bin ::/EFI/BOOT
	mcopy -i build/x86/uefi/fat32.bin build/x86/uefi/root/EFI/BOOT/BOOTX64.EFI ::/EFI/BOOT/BOOTX64.EFI
	mcopy -i build/x86/uefi/fat32.bin build/x86/bios/root/* ::/

# BEGIN UEFI DIRS

build/x86/uefi: build
	mkdir -pv build/x86/uefi

build/x86/uefi/root: build/x86/uefi
	mkdir -pv build/x86/uefi/root

build/x86/uefi/root/EFI: build/x86/uefi/root
	mkdir -pv build/x86/uefi/root/EFI

build/x86/uefi/root/EFI/BOOT: build/x86/uefi/root/EFI
	mkdir -pv build/x86/uefi/root/EFI/BOOT

src/arch/x86/64/boot/c/efimain.o: src/arch/x86/64/boot/c/efimain.c
	${CC_X86} src/arch/x86/64/boot/c/efimain.c -c ${CFLAGSx86_64EFI} ${HEADERS} -o src/arch/x86/64/boot/c/efimain.o

src/arch/x86/64/boot/c/efimain.so: src/arch/x86/64/boot/c/efimain.o
	$(LD_X86) src/arch/x86/64/boot/c/efimain.o ${LIBDIR}/crt0-efi-x86/64.o ${LDFLAGSx86_64EFI} -o src/arch/x86/64/boot/c/efimain.so

build/x86/uefi/root/EFI/BOOT/BOOTX64.EFI: build/x86/uefi/root/EFI/BOOT src/arch/x86/64/boot/c/efimain.so
	objcopy -j .text -j .sdata -j .data -j .dynamic -j .dynsym -j .rel -j .rela -j .reloc --target=efi-app-x86/64 src/arch/x86/64/boot/c/efimain.so build/x86/uefi/root/EFI/BOOT/BOOTX64.EFI
	strip build/x86/uefi/root/EFI/BOOT/BOOTX64.EFI

# END UEFI DIRS

# BEGIN BIOS DIRS

build/bios: build
	mkdir -pv build/bios

build/x86/bios/root: build/bios
	mkdir -pv build/x86/bios/root

# END BIOS DIRS

# BEGIN 64

build/x86/bios/x86/64: build/bios
	mkdir -pv build/x86/bios/x86/64

build/x86/bios/x86/64/hd.bin: build/x86/bios/x86/64 build/x86/bios/x86/64/fat32.bin
	dd if=/dev/zero of=build/x86/bios/x86/64/hd.bin bs=1M count=32
	sgdisk -o -n1 -t1:ef00 build/x86/bios/x86/64/hd.bin
	dd if=build/x86/bios/x86/64/fat32.bin of=build/x86/bios/x86/64/hd.bin seek=2048 conv=notrunc

build/x86/bios/x86/64/fat32.bin: build/x86/bios/x86/64 build/x86/bios/root/kern64c.elf build/x86/bios/root/kern64c.bin build/x86/bios/root/kern64a.bin build/x86/bios/root/flat64c.bin
	dd if=/dev/zero of=build/x86/bios/x86/64/fat32.bin bs=1M count=31
	mkfs.vfat -F32 build/x86/bios/x86/64/fat32.bin # mformat -i build/x86/bios/x86/64/fat32.bin -h 32 -t 32 -n 64 -c 1
	mmd -i build/x86/bios/x86/64/fat32.bin ::/boot
	mcopy -i build/x86/bios/x86/64/fat32.bin build/x86/bios/root/kern64c.elf ::/boot/kern64c.elf
	mcopy -i build/x86/bios/x86/64/fat32.bin build/x86/bios/root/kern64c.bin ::/boot/kern64c.bin
	mcopy -i build/x86/bios/x86/64/fat32.bin build/x86/bios/root/kern64a.bin ::/boot/kern64a.bin
	mcopy -i build/x86/bios/x86/64/fat32.bin build/x86/bios/root/flat64c.bin ::/boot/flat64c.bin

src/arch/x86/64/kernel/c/kernel64.o: src/arch/x86/64/kernel/c/kernel64.c
	$(CC_X86) $(CFLAGSx86_64) -o $@ -c $<

build/x86/bios/root/flat64c.bin: build/x86/bios/root src/arch/x86/64/kernel/c/kernel64.o
	$(LD_X86) $(LDFLAGSx86_64ELF) -o build/x86/bios/root/flat64cp.elf src/arch/x86/64/kernel/c/kernel64.o
	objcopy -O binary -j .text -j .rodata -j .data -j .bss build/x86/bios/root/flat64cp.elf build/x86/bios/root/flat64c.bin

src/arch/x86/64/boot/c/multiboot.o: src/arch/x86/64/boot/c/multiboot.c
	$(CC_X86) $(CFLAGSx86_64) -o $@ -c $<

src/arch/x86/64/boot/asm/inc/multiboot.o: src/arch/x86/64/boot/asm/inc/multiboot.asm
	$(NASM) $(NASMFLAGSx86_64ELF) -o $@ $<

build/x86/bios/root/kern64c.elf: build/x86/bios/root $(OBJFILESX86_64)
	$(LD_X86) $(LDFLAGSx86_64ELF) -o build/x86/bios/root/kern64c.elf $(OBJFILESX86_64)

build/x86/bios/root/kern64c.bin: build/x86/bios/root $(OBJFILESX86_64)
	$(LD_X86) $(LDFLAGSx86_64ELF) -o build/x86/bios/root/kern64cp.elf $(OBJFILESX86_64)
	objcopy -O binary -j .text -j .rodata -j .data -j .bss build/x86/bios/root/kern64cp.elf build/x86/bios/root/kern64c.bin

build/x86/bios/root/kern64a.bin: build/x86/bios/root src/arch/x86/64/kernel/asm/kernel64.asm
	$(NASM) $(NASMFLAGSx86_64BIN) src/arch/x86/64/kernel/asm/kernel64.asm -o build/x86/bios/root/kern64a.bin

# END 64

# BEGIN 32

build/x86/bios/x86/32: build/bios
	mkdir -pv build/x86/bios/x86/32

# these don't yet have a bootloader
build/x86/bios/x86/32/hd.bin: build/x86/bios/x86/32 build/x86/bios/x86/32/fat32.bin build/x86/bios/x86/16/mbr.bin
	dd if=/dev/zero of=build/x86/bios/x86/32/hd.bin bs=1M count=32
	sfdisk build/x86/bios/x86/32/hd.bin < src/arch/x86/32/boot/sfdisk.conf
	dd if=build/x86/bios/x86/32/fat32.bin of=build/x86/bios/x86/32/hd.bin bs=512 seek=2048 conv=notrunc

build/x86/bios/x86/32/fat32.bin: build/x86/bios/x86/32 build/x86/bios/root/kern16a.bin build/x86/bios/root/kern32c.elf build/x86/bios/root/kern32c.bin build/x86/bios/root/kern32a.bin # add the others?
	dd if=/dev/zero of=build/x86/bios/x86/32/fat32.bin bs=1M count=32
	mkfs.vfat -F16 build/x86/bios/x86/32/fat32.bin
# convert this
	mkdir -p mounts/x86/bios/x86/32/
	sudo umount mounts/x86/bios/x86/32/ || echo "ok"
	sudo mount -oloop build/x86/bios/x86/32/fat32.bin mounts/x86/bios/x86/32/
	sudo cp -r build/x86/bios/root/*.bin build/x86/bios/root/*.elf mounts/x86/bios/x86/32/
	sync
	sudo umount mounts/x86/bios/x86/32/
	rm -rf mounts

src/arch/x86/32/kernel/c/lib/%.o: src/arch/x86/32/kernel/c/lib/%.c
	echo "Compiling $@ from $< in 32-bit mode"
	$(CC_X86) $(CFLAGSx86_32) -o $@ -c $<

src/arch/x86/32/boot/c/multiboot.o: src/arch/x86/32/boot/c/multiboot.c
	$(CC_X86) $(CFLAGSx86_32) -o $@ -c $<

src/arch/x86/32/kernel/c/main.o: src/arch/x86/32/kernel/c/main.c
	$(CC_X86) $(CFLAGSx86_32) -o $@ -c $<

src/arch/x86/32/boot/asm/inc/multiboot.o: src/arch/x86/32/boot/asm/inc/multiboot.asm
	$(NASM) $(NASMFLAGSx86_32ELF) -o $@ $<

src/arch/x86/32/kernel/c/kernel32.o: src/arch/x86/32/kernel/c/kernel32.c
	$(CC_X86) $(CFLAGSx86_32) -o $@ -c $<

build/x86/bios/root/flat32c.bin: build/x86/bios/root src/arch/x86/32/kernel/c/kernel32.o
	$(LD_X86) $(LDFLAGSx86_32ELF) -o build/x86/bios/root/flat32cp.elf src/arch/x86/32/kernel/c/kernel32.o
	objcopy -O binary -j .text -j .rodata -j .data -j .bss build/x86/bios/root/flat32cp.elf build/x86/bios/root/flat32c.bin

build/x86/bios/root/kern32c.bin: build/x86/bios/root $(OBJFILESX86_32)
	$(LD_X86) $(LDFLAGSx86_32ELF) -o build/x86/bios/root/kern32cp.elf $(OBJFILESX86_32)
	objcopy -O binary -j .text -j .rodata -j .data -j .bss build/x86/bios/root/kern32cp.elf build/x86/bios/root/kern32c.bin

build/x86/bios/root/kern32c.elf: build/x86/bios/root $(OBJFILESX86_32)
	$(LD_X86) $(LDFLAGSx86_32ELF) -o build/x86/bios/root/kern32c.elf $(OBJFILESX86_32)

build/x86/bios/root/kern32a.bin: build/x86/bios/root src/arch/x86/32/kernel/asm/kernel32.asm
	$(NASM) $(NASMFLAGSx86_32BIN) src/arch/x86/32/kernel/asm/kernel32.asm -o build/x86/bios/root/kern32a.bin

# END 32


# BEGIN 16

build/x86/bios/x86/16: build/bios
	mkdir -pv build/x86/bios/x86/16

build/x86/bios/x86/16/hd.bin: build/x86/bios/x86/16 build/x86/bios/x86/16/mbr.bin build/x86/bios/x86/16/fat12.bin
	cat build/x86/bios/x86/16/mbr.bin build/x86/bios/x86/16/fat12.bin > build/x86/bios/x86/16/hd.bin

build/x86/bios/x86/16/mbr.bin: build/x86/bios/x86/16 src/arch/x86/16/boot/asm/mbr.asm
	$(NASM) $(NASMFLAGSX86_16) src/arch/x86/16/boot/asm/mbr.asm -o build/x86/bios/x86/16/mbr.bin

build/x86/bios/x86/16/fat12.bin: build/x86/bios/x86/16 build/x86/bios/x86/16/vbr.bin build/x86/bios/root/kern16a.bin build/x86/bios/root/kern32a.bin build/x86/bios/root/flat32c.bin # build/x86/bios/root/kern32c.bin build/x86/bios/root/kern32c.elf
	dd if=/dev/zero of=build/x86/bios/x86/16/fat12.bin count=2K
	dd if=build/x86/bios/x86/16/vbr.bin of=build/x86/bios/x86/16/fat12.bin conv=notrunc
	mkdir -p mounts/x86/bios/x86/16/
	sudo umount mounts/x86/bios/x86/16/ || echo "ok"
	sudo mount -oloop build/x86/bios/x86/16/fat12.bin mounts/x86/bios/x86/16/
	sudo cp -r build/x86/bios/root/kern16a.bin build/x86/bios/root/kern32a.bin build/x86/bios/root/flat32c.bin mounts/x86/bios/x86/16/
	sync
	sudo umount mounts/x86/bios/x86/16/
	rm -rf mounts

build/x86/bios/x86/16/vbr.bin: build/x86/bios/x86/16 src/arch/x86/16/boot/asm/vbr.asm
	$(NASM) $(NASMFLAGSX86_16) src/arch/x86/16/boot/asm/vbr.asm -o build/x86/bios/x86/16/vbr.bin

build/x86/bios/root/kern16a.bin: build/x86/bios/root src/arch/x86/16/kernel/asm/kernel16.asm
	$(NASM) $(NASMFLAGSX86_16) src/arch/x86/16/kernel/asm/kernel16.asm -o build/x86/bios/root/kern16a.bin

# END 16


# BEGIN ALL

x86_64_all: build/x86/uefi/hd.bin build/x86/bios/x86/64/hd.bin build/x86/bios/root/kern64c.elf

x86_32_all: build/x86/bios/x86/32/hd.bin build/x86/bios/root/kern32c.elf

x86_16_all: build/x86/bios/x86/16/hd.bin

aarch64_all:

aarch32_all:

aarch26_all:

x86_all: x86_16_all x86_32_all x86_64_all

arm_all: aarch26_all aarch32_all aarch64_all
# END ALL


# BEGIN QEMU

qemu_x86_16a: build/x86/bios/x86/16/hd.bin
	qemu-system-i386 -m 8 build/x86/bios/x86/16/hd.bin

qemu_x86_32c: build/x86/bios/x86/32/hd.bin
	qemu-system-i386 -m 64 build/x86/bios/x86/32/hd.bin

qemu_x86_32c_direct: build/x86/bios/root/kern32c.elf
	qemu-system-i386 -m 64 -kernel build/x86/bios/root/kern32c.elf # build/x86/bios/x86/32/hd.bin

qemu_x86_64c: build/x86/bios/x86/64/hd.bin
	qemu-system-x86/64 -enable-kvm -cpu qemu64 -drive file=build/x86/bios/x86/64/hd.bin,format=raw

# qemu doesn't support 64 bit images but this seems ok to actually do the boot from, maybe it's 32 but hiding
qemu_x86_64c_direct: build/x86/bios/root/kern64c.elf build/x86/bios/x86/64/hd.bin
	qemu-system-x86/64 -enable-kvm -cpu qemu64 -drive file=build/x86/bios/x86/64/hd.bin,format=raw

qemu_x86_64c_uefi: build/x86/uefi/hd.bin
	qemu-system-x86/64 -enable-kvm -cpu qemu64 -pflash OVMF_CODE.fd -pflash OVMF_VARS.fd -drive file=build/x86/uefi/hd.bin,format=raw

# END QEMU