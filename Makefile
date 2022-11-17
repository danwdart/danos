NASM = nasm
NASMFLAGS =
APPS = build/apps/kernel16.bin # build/apps/cpuid.bin build/apps/vesa.bin
RM = rm

.PHONY: all

all: build/danos.bin

build:
	mkdir build

apps: build
	mkdir -p build/apps

build/mbr.bin: build src/mbr.asm
	$(NASM) $(NASMFLAGS) src/mbr.asm -o build/mbr.bin

build/apps/%.bin: src/apps/%.asm
	$(NASM) $(NASMFLAGS)  -o $@ $<

build/part1.bin: apps src/part1.asm $(APPS)
	$(NASM) $(NASMFLAGS) src/part1.asm -o build/part1.bin
	mkdir -p build/danos/
	sudo umount build/danos/ || echo "ok"
	sudo mount -oloop build/part1.bin build/danos/
	sudo cp -r build/apps/*.bin build/danos/
	sync
	sudo umount build/danos/

build/danos.bin: build build/mbr.bin build/part1.bin
	cat build/mbr.bin build/part1.bin > build/danos.bin

clean:
	$(RM) -r build

qemu:
	qemu-system-x86_64 -enable-kvm -cpu host -d pcall,guest_errors,unimp build/danos.bin