NASM = nasm
NASMFLAGS =
FILES = build/root/kernel16.bin # build/root/cpuid.bin build/root/vesa.bin
RM = rm

.PHONY: all

all: build/danos.bin

build:
	mkdir build

root: build
	mkdir -p build/root

build/mbr.bin: build src/mbr.asm
	$(NASM) $(NASMFLAGS) src/mbr.asm -o build/mbr.bin

build/root/%.bin: src/root/%.asm
	$(NASM) $(NASMFLAGS)  -o $@ $<

build/part1.bin: root src/part1.asm $(FILES)
	$(NASM) $(NASMFLAGS) src/part1.asm -o build/part1.bin
	mkdir -p mounts/danos/
	sudo umount mounts/danos/ || echo "ok"
	sudo mount -oloop build/part1.bin mounts/danos/
	sudo cp -r build/root/*.bin mounts/danos/
	sync
	sudo umount mounts/danos/
	rm -rf mounts

build/danos.bin: build build/mbr.bin build/part1.bin
	cat build/mbr.bin build/part1.bin > build/danos.bin

clean:
	$(RM) -r build

qemu:
	qemu-system-x86_64 -enable-kvm -cpu host -d pcall,guest_errors,unimp build/danos.bin