# CC_X86 = x86_64-elf-gcc
# LD_X86 = x86_64-elf-ld
# AS_X86 = x86_64-elf-as
# CC_ARM
# LD_ARM
# AS_ARM
NASM = nasm
RM = rm
# OBJCOPY = objcopy
CFLAGS_X86_32 = -m32 -Wall -Wextra -nostdlib -fno-builtin -nostartfiles -nodefaultlibs -Isrc/arch/x86/32/kernel/c/lib -Isrc/arch/x86/32/boot/c/lib
CFLAGS_X86_64 = -m64 -Wall -Wextra -nostdlib -fno-builtin -nostartfiles -nodefaultlibs -Isrc/arch/x86/64/kernel/c/lib -Isrc/arch/x86/64/boot/c/lib
CFLAGS_X86_64EFI = -Wall -Werror -fno-stack-protector -fpic -fshort-wchar -mno-red-zone -DEFI_FUNCTION_WRAPPER
CFLAGS_X86_64EFINEW = -Wall -Werror -fno-stack-protector -fpic -ffreestanding -fno-stack-check -fshort-wchar -mno-red-zone -maccumulate-outgoing-args
CFLAGS_AARCH32_LEGACY =
CFLAGS_AARCH32 =
CFLAGS_AARCH64 = -Wall -O2 -ffreestanding -nostdinc -nostdlib -nostartfiles
# EFIDIR = /nix/store/vm982y77hrc626va4mcpr73vsskqgvll-gnu-efi-3.0.15
HEADERPATH = ${EFIDIR}/include/efi
HEADERS = -I ${HEADERPATH} -I ${HEADERPATH}/x86/64
LIBDIR = ${EFIDIR}/lib
LDFLAGS_X86_32_BIN = -m elf_i386 -T src/arch/x86/32/boot/loadable16.ld
LDFLAGS_X86_32_ELF = -m elf_i386 -T src/arch/x86/32/kernel/linker.ld
LDFLAGS_X86_64_BIN = -m elf_x86_64
LDFLAGS_X86_64_ELF = -m elf_x86_64 -T src/arch/x86/64/kernel/linker.ld
LDFLAGS_X86_64EFI = -nostdlib -znocombreloc -T ${LIBDIR}/elf_x86_64_efi.lds -shared -Bsymbolic -L ${LIBDIR} -l:libgnuefi.a -l:libefi.a
LDFLAGS_X86_64EFINEW = -T ${LIBDIR}/elf_x86_64_efi.lds -shared -Bsymbolic -L ${LIBDIR} -l:libgnuefi.a -l:libefi.a
LDFLAGS_AARCH32_LEGACY =
LDFLAGS_AARCH32 =
LDFLAGS_AARCH64 = -T src/arch/arm/64/kernel/linker.ld -nostdlib
OBJCOPY_FLAGS_X86_64_EFINEW = -j .text -j .sdata -j .data -j .dynamic -j .dynsym -j .rel -j .rela -j .reloc --target=efi-app-x86_64
OBJCOPY_FLAGS_X86_64_EFINEW = -j .text -j .sdata -j .data -j .dynamic -j .dynsym -j .rel -j .rela -j .rel.* -j .rela.* -j .reloc --target=efi-app-x86_64 --subsystem=10
ASFLAGS_X86_32 = --32
ASFLAGS_AARCH32_LEGACY =
ASFLAGS_AARCH32 =
ASFLAGS_AARCH64 =
NASMFLAGS_X86_16 = -i src/arch/x86/16/shared/asm/inc
NASMFLAGS_X86_32_BIN = -i src/arch/x86/32/shared/asm/inc -fbin
NASMFLAGS_X86_32_ELF = -i src/arch/x86/32/shared/asm/inc -felf
NASMFLAGS_X86_64_BIN = -i src/arch/x86/64/shared/asm/inc -fbin
NASMFLAGS_X86_64_ELF = -i src/arch/x86/64/shared/asm/inc -felf64
CKERNLIB_X86_32 = src/arch/x86/32/kernel/c/lib
OBJFILES_X86_32 = src/arch/x86/32/boot/asm/inc/multiboot.o src/arch/x86/32/boot/c/multiboot.o ${CKERNLIB_X86_32}/video.o ${CKERNLIB_X86_32}/io.o ${CKERNLIB_X86_32}/8042.o ${CKERNLIB_X86_32}/clever.o ${CKERNLIB_X86_32}/string.o src/arch/x86/32/kernel/c/main.o
OBJFILES_X86_64 = src/arch/x86/64/boot/asm/inc/multiboot.o src/arch/x86/64/boot/c/multiboot.o src/arch/x86/64/kernel/c/kernel64.o
OBJFILES_AARCH32_LEGACY =
OBJFILES_AARCH32 =
OBJFILES_AARCH64 = src/arch/arm/aarch64/boot/asm/bootstrap.o src/arch/arm/aarch64/kernel/c/kernel64.o

.PHONY: all clean x86_64_all x86_32_all x86_16_all x86_all aarch64_all aarch32_all aarch32_legacy_all arm_all qemu_x86_16a qemu_x86_32c qemu_x86_32c_direct qemu_x86_64c qemu_aarch64c_direct qemu_x86_64c_uefi

all: x86_64_all x86_32_all x86_16_all

clean:
	$(RM) -rf build
	find . -name *.o -delete
	find . -name *.so -delete

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

build/x86: build
	mkdir -pv build/x86

build/x86/uefi: build/x86
	mkdir -pv build/x86/uefi

build/x86/uefi/root: build/x86/uefi
	mkdir -pv build/x86/uefi/root

build/x86/uefi/root/EFI: build/x86/uefi/root
	mkdir -pv build/x86/uefi/root/EFI

build/x86/uefi/root/EFI/BOOT: build/x86/uefi/root/EFI
	mkdir -pv build/x86/uefi/root/EFI/BOOT

src/arch/x86/64/boot/c/efimain.o: src/arch/x86/64/boot/c/efimain.c
	${CC_X86_64} src/arch/x86/64/boot/c/efimain.c -c ${CFLAGS_X86_64EFI} ${HEADERS} -o src/arch/x86/64/boot/c/efimain.o

src/arch/x86/64/boot/c/efimain.so: src/arch/x86/64/boot/c/efimain.o
	$(LD_X86_64) src/arch/x86/64/boot/c/efimain.o ${LIBDIR}/crt0-efi-x86_64.o ${LDFLAGS_X86_64EFI} -o src/arch/x86/64/boot/c/efimain.so

build/x86/uefi/root/EFI/BOOT/BOOTX64.EFI: build/x86/uefi/root/EFI/BOOT src/arch/x86/64/boot/c/efimain.so
	$(OBJCOPY_X86_64) -j .text -j .sdata -j .data -j .dynamic -j .dynsym -j .rel -j .rela -j .reloc --target=efi-app-x86_64 src/arch/x86/64/boot/c/efimain.so build/x86/uefi/root/EFI/BOOT/BOOTX64.EFI
	$(STRIP_X86_64) build/x86/uefi/root/EFI/BOOT/BOOTX64.EFI

# END UEFI DIRS

# BEGIN BIOS DIRS

build/x86/bios: build
	mkdir -pv build/x86/bios

build/x86/bios/root: build/x86/bios
	mkdir -pv build/x86/bios/root

# END BIOS DIRS

# BEGIN 64

build/x86/bios/x86_64: build/x86/bios
	mkdir -pv build/x86/bios/x86_64

build/x86/bios/x86_64/hd.bin: build/x86/bios/x86_64 build/x86/bios/x86_64/fat32.bin
	dd if=/dev/zero of=build/x86/bios/x86_64/hd.bin bs=1M count=32
	sgdisk -o -n1 -t1:ef00 build/x86/bios/x86_64/hd.bin
	dd if=build/x86/bios/x86_64/fat32.bin of=build/x86/bios/x86_64/hd.bin seek=2048 conv=notrunc

build/x86/bios/x86_64/fat32.bin: build/x86/bios/x86_64 build/x86/bios/root/kern64c.elf build/x86/bios/root/kern64c.bin build/x86/bios/root/kern64a.bin build/x86/bios/root/flat64c.bin
	dd if=/dev/zero of=build/x86/bios/x86_64/fat32.bin bs=1M count=31
	mkfs.vfat -F32 build/x86/bios/x86_64/fat32.bin # mformat -i build/x86/bios/x86_64/fat32.bin -h 32 -t 32 -n 64 -c 1
	mmd -i build/x86/bios/x86_64/fat32.bin ::/boot
	mcopy -i build/x86/bios/x86_64/fat32.bin build/x86/bios/root/kern64c.elf ::/boot/kern64c.elf
	mcopy -i build/x86/bios/x86_64/fat32.bin build/x86/bios/root/kern64c.bin ::/boot/kern64c.bin
	mcopy -i build/x86/bios/x86_64/fat32.bin build/x86/bios/root/kern64a.bin ::/boot/kern64a.bin
	mcopy -i build/x86/bios/x86_64/fat32.bin build/x86/bios/root/flat64c.bin ::/boot/flat64c.bin

src/arch/x86/64/kernel/c/kernel64.o: src/arch/x86/64/kernel/c/kernel64.c
	$(CC_X86_64) $(CFLAGS_X86_64) -o $@ -c $<

build/x86/bios/root/flat64c.bin: build/x86/bios/root src/arch/x86/64/kernel/c/kernel64.o
	$(LD_X86_64) $(LDFLAGS_X86_64_ELF) -o build/x86/bios/root/flat64cp.elf src/arch/x86/64/kernel/c/kernel64.o
	$(OBJCOPY_X86_64) -O binary -j .text -j .rodata -j .data -j .bss build/x86/bios/root/flat64cp.elf build/x86/bios/root/flat64c.bin

src/arch/x86/64/boot/c/multiboot.o: src/arch/x86/64/boot/c/multiboot.c
	$(CC_X86_64) $(CFLAGS_X86_64) -o $@ -c $<

src/arch/x86/64/boot/asm/inc/multiboot.o: src/arch/x86/64/boot/asm/inc/multiboot.asm
	$(NASM) $(NASMFLAGS_X86_64_ELF) -o $@ $<

build/x86/bios/root/kern64c.elf: build/x86/bios/root $(OBJFILES_X86_64)
	$(LD_X86_64) $(LDFLAGS_X86_64_ELF) -o build/x86/bios/root/kern64c.elf $(OBJFILES_X86_64)

build/x86/bios/root/kern64c.bin: build/x86/bios/root $(OBJFILES_X86_64)
	$(LD_X86_64) $(LDFLAGS_X86_64_ELF) -o build/x86/bios/root/kern64cp.elf $(OBJFILES_X86_64)
	$(OBJCOPY_X86_64) -O binary -j .text -j .rodata -j .data -j .bss build/x86/bios/root/kern64cp.elf build/x86/bios/root/kern64c.bin

build/x86/bios/root/kern64a.bin: build/x86/bios/root src/arch/x86/64/kernel/asm/kernel64.asm
	$(NASM) $(NASMFLAGS_X86_64_BIN) src/arch/x86/64/kernel/asm/kernel64.asm -o build/x86/bios/root/kern64a.bin

# END 64

# BEGIN 32

build/x86/bios/x86_32: build/x86/bios
	mkdir -pv build/x86/bios/x86_32

# these don't yet have a bootloader
build/x86/bios/x86_32/hd.bin: build/x86/bios/x86_32 build/x86/bios/x86_32/fat32.bin build/x86/bios/x86_16/mbr.bin
	dd if=/dev/zero of=build/x86/bios/x86_32/hd.bin bs=1M count=32
	sfdisk build/x86/bios/x86_32/hd.bin < src/arch/x86/32/boot/sfdisk.conf
	dd if=build/x86/bios/x86_32/fat32.bin of=build/x86/bios/x86_32/hd.bin bs=512 seek=2048 conv=notrunc

build/x86/bios/x86_32/fat32.bin: build/x86/bios/x86_32 build/x86/bios/root/kern16a.bin build/x86/bios/root/kern32c.elf build/x86/bios/root/kern32c.bin build/x86/bios/root/kern32a.bin # add the others?
	dd if=/dev/zero of=build/x86/bios/x86_32/fat32.bin bs=1M count=32
	mkfs.vfat -F16 build/x86/bios/x86_32/fat32.bin
# convert this
	mkdir -pv mounts/x86/bios/x86/32/
	sudo umount mounts/x86/bios/x86/32/ || echo "ok"
	sudo mount -oloop build/x86/bios/x86_32/fat32.bin mounts/x86/bios/x86/32/
	sudo cp -r build/x86/bios/root/*.bin build/x86/bios/root/*.elf mounts/x86/bios/x86/32/
	sync
	sudo umount mounts/x86/bios/x86/32/
	rm -rf mounts

src/arch/x86/32/kernel/c/lib/%.o: src/arch/x86/32/kernel/c/lib/%.c
	echo "Compiling $@ from $< in 32-bit mode"
	$(CC_X86_32) $(CFLAGS_X86_32) -o $@ -c $<

src/arch/x86/32/boot/c/multiboot.o: src/arch/x86/32/boot/c/multiboot.c
	$(CC_X86_32) $(CFLAGS_X86_32) -o $@ -c $<

src/arch/x86/32/kernel/c/main.o: src/arch/x86/32/kernel/c/main.c
	$(CC_X86_32) $(CFLAGS_X86_32) -o $@ -c $<

src/arch/x86/32/boot/asm/inc/multiboot.o: src/arch/x86/32/boot/asm/inc/multiboot.asm
	$(NASM) $(NASMFLAGS_X86_32_ELF) -o $@ $<

src/arch/x86/32/kernel/c/kernel32.o: src/arch/x86/32/kernel/c/kernel32.c
	$(CC_X86_32) $(CFLAGS_X86_32) -o $@ -c $<

build/x86/bios/root/flat32c.bin: build/x86/bios/root src/arch/x86/32/kernel/c/kernel32.o
	$(LD_X86_32) $(LDFLAGS_X86_32_ELF) -o build/x86/bios/root/flat32cp.elf src/arch/x86/32/kernel/c/kernel32.o
	$(OBJCOPY_X86_32) -O binary -j .text -j .rodata -j .data -j .bss build/x86/bios/root/flat32cp.elf build/x86/bios/root/flat32c.bin

build/x86/bios/root/kern32c.bin: build/x86/bios/root $(OBJFILES_X86_32)
	$(LD_X86_32) $(LDFLAGS_X86_32_ELF) -o build/x86/bios/root/kern32cp.elf $(OBJFILES_X86_32)
	$(OBJCOPY_X86_32) -O binary -j .text -j .rodata -j .data -j .bss build/x86/bios/root/kern32cp.elf build/x86/bios/root/kern32c.bin

build/x86/bios/root/kern32c.elf: build/x86/bios/root $(OBJFILES_X86_32)
	$(LD_X86_32) $(LDFLAGS_X86_32_ELF) -o build/x86/bios/root/kern32c.elf $(OBJFILES_X86_32)

build/x86/bios/root/kern32a.bin: build/x86/bios/root src/arch/x86/32/kernel/asm/kernel32.asm
	$(NASM) $(NASMFLAGS_X86_32_BIN) src/arch/x86/32/kernel/asm/kernel32.asm -o build/x86/bios/root/kern32a.bin

# END 32


# BEGIN 16

build/x86/bios/x86_16: build/x86/bios
	mkdir -pv build/x86/bios/x86_16

build/x86/bios/x86_16/hd.bin: build/x86/bios/x86_16 build/x86/bios/x86_16/mbr.bin build/x86/bios/x86_16/fat12.bin
	cat build/x86/bios/x86_16/mbr.bin build/x86/bios/x86_16/fat12.bin > build/x86/bios/x86_16/hd.bin

build/x86/bios/x86_16/mbr.bin: build/x86/bios/x86_16 src/arch/x86/16/boot/asm/mbr.asm
	$(NASM) $(NASMFLAGS_X86_16) src/arch/x86/16/boot/asm/mbr.asm -o build/x86/bios/x86_16/mbr.bin

build/x86/bios/x86_16/fat12.bin: build/x86/bios/x86_16 build/x86/bios/x86_16/vbr.bin build/x86/bios/root/kern16a.bin build/x86/bios/root/kern32a.bin build/x86/bios/root/flat32c.bin # build/x86/bios/root/kern32c.bin build/x86/bios/root/kern32c.elf
	dd if=/dev/zero of=build/x86/bios/x86_16/fat12.bin count=2K
	dd if=build/x86/bios/x86_16/vbr.bin of=build/x86/bios/x86_16/fat12.bin conv=notrunc
	mkdir -pv mounts/x86/bios/x86/16/
	sudo umount mounts/x86/bios/x86/16/ || echo "ok"
	sudo mount -oloop build/x86/bios/x86_16/fat12.bin mounts/x86/bios/x86/16/
	sudo cp -r build/x86/bios/root/kern16a.bin build/x86/bios/root/kern32a.bin build/x86/bios/root/flat32c.bin mounts/x86/bios/x86/16/
	sync
	sudo umount mounts/x86/bios/x86/16/
	rm -rf mounts

build/x86/bios/x86_16/vbr.bin: build/x86/bios/x86_16 src/arch/x86/16/boot/asm/vbr.asm
	$(NASM) $(NASMFLAGS_X86_16) src/arch/x86/16/boot/asm/vbr.asm -o build/x86/bios/x86_16/vbr.bin

build/x86/bios/root/kern16a.bin: build/x86/bios/root src/arch/x86/16/kernel/asm/kernel16.asm
	$(NASM) $(NASMFLAGS_X86_16) src/arch/x86/16/kernel/asm/kernel16.asm -o build/x86/bios/root/kern16a.bin

# END 16


# BEGIN ALL

x86_64_all: build/x86/uefi/hd.bin build/x86/bios/x86_64/hd.bin build/x86/bios/root/kern64c.elf

x86_32_all: build/x86/bios/x86_32/hd.bin build/x86/bios/root/kern32c.elf

x86_16_all: build/x86/bios/x86_16/hd.bin

x86_all: x86_16_all x86_32_all x86_64_all

build/arm: build
	mkdir -pv build/arm

build/arm/uboot: build/arm
	mkdir -pv build/arm/uboot

build/arm/uboot/root: build/arm/uboot
	mkdir -pv build/arm/uboot/root

build/arm/uboot/root/kern64c.elf: build/arm/uboot/root

build/arm/uefi/hd.bin: build/arm/uboot/root/kern64c.elf

build/arm/uboot/aarch64/hd.bin: build/arm/uboot/root/kern64c.elf

build/arm/uboot/root/kern32c.elf: build/arm/uboot/root

build/arm/uboot/aarch32/hd.bin: build/arm/uboot/root/kern32c.elf

build/arm/uboot/root/kern32_legacy_c.elf: build/arm/uboot/root

build/arm/uboot/aarch32_legacy/hd.bin: build/arm/uboot/root/kern32_legacy_c.elf

src/arch/arm/aarch64/kernel/c/kernel64.o: src/arch/arm/aarch64/kernel/c/kernel64.c
	$(CC_AARCH64) $(CFLAGS_AARCH64) -o $@ -c $<

src/arch/arm/aarch64/boot/asm/bootstrap.o: src/arch/arm/aarch64/boot/asm/bootstrap.s
	$(AS_AARCH64) $(ASFLAGS_AARCH64) -o $@ -c $<

build/arm/uboot/root/kern64c.so: build/arm/uboot/root $(OBJFILES_AARCH64)
	$(LD_AARCH64) $(LDFLAGS_AARCH64_ELF) -T src/arch/arm/aarch64/kernel/linker.ld -o build/arm/uboot/root/kern64c.so $(OBJFILES_AARCH64)

build/arm/uboot/root/kern64c.elf: build/arm/uboot/root/kern64c.so
	$(OBJCOPY_AARCH64) -O binary build/arm/uboot/root/kern64c.so build/arm/uboot/root/kern64c.elf

aarch64_all: build/arm/uefi/hd.bin build/arm/uboot/aarch64/hd.bin build/arm/uboot/root/kern64c.elf

aarch32_all: build/arm/uboot/aarch32/hd.bin build/arm/uboot/root/kern32c.elf

aarch32_legacy_all: build/arm/uboot/aarch32_legacy/hd.bin build/arm/uboot/root/kern32_legacy_c.elf

arm_all: aarch32_legacy_all aarch32_all aarch64_all
# END ALL


# BEGIN QEMU

qemu_x86_16a: build/x86/bios/x86_16/hd.bin
	qemu-system-i386 -m 8 build/x86/bios/x86_16/hd.bin $(EXTRA_QEMU_OPTS)

qemu_x86_32c: build/x86/bios/x86_32/hd.bin
	qemu-system-i386 -m 64 build/x86/bios/x86_32/hd.bin $(EXTRA_QEMU_OPTS)

qemu_x86_32c_direct: build/x86/bios/root/kern32c.elf
	qemu-system-i386 -m 64 -kernel build/x86/bios/root/kern32c.elf $(EXTRA_QEMU_OPTS)

qemu_x86_64c: build/x86/bios/x86_64/hd.bin
	qemu-system-x86_64 -cpu qemu64 -drive file=build/x86/bios/x86_64/hd.bin,format=raw $(EXTRA_QEMU_OPTS)


qemu_aarch64c_direct: build/arm/uboot/root/kern64c.elf
	qemu-system-aarch64 -M virt -device ramfb -cpu max -kernel build/arm/uboot/root/kern64c.elf $(EXTRA_QEMU_OPTS)

# qemu doesn't support 64 bit images but this seems ok to actually do the boot from, maybe it's 32 but hiding
# qemu_x86_64c_direct: build/x86/bios/root/kern64c.elf build/x86/bios/x86_64/hd.bin
# 	qemu-system-x86_64 -cpu qemu64 -drive file=build/x86/bios/x86_64/hd.bin,format=raw $(EXTRA_QEMU_OPTS)

qemu_x86_64c_uefi: build/x86/uefi/hd.bin
	qemu-system-x86_64 -cpu qemu64 -pflash OVMF_CODE.fd -pflash OVMF_VARS.fd -drive file=build/x86/uefi/hd.bin,format=raw $(EXTRA_QEMU_OPTS)

# END QEMU