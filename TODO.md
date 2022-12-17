restructure
    /src
        /x86_16
            /boot
                mbr.asm
                part1.asm
                Makefile
            /kernel
                /asm
                    /inc
                        /io
                            ata.asm
            /system (ringless)
                prog.asm
        /x86_32
            /boot
                [multilib specific stuff]
            /kernel
                /asm
                    /inc
                /c
            /system (ring 0) - only use for now
                /asm
                    cpuid.asm
                /c
            /user (ring 3) - maybe call it user-later
                /asm
                    /inc
                /c
        /x86_64
            /boot
                [uefi specific stuff]
            /kernel
                /asm
                    /inc
                /c
            /system (ring 0) - only use for now
                /asm
                /c
            /user (ring 3) - maybe call it user-later
                /asm
                    /inc
                /c
        ... more architectures maybe
    /build (flat for now)
        /mbr.bin
        /part1.bin
        /root
            /prog16a.bin
            /prog16c.bin
            /prog32a.bin
            /prog32c.bin
            /kern32a.bin
            /kern32c.bin
            /kern64a.bin
            /kern64c.bin
    /mount
        /root

have kern16a choose the kernel to next load and choose whether to prot or long directly


have kern32a/kern32c choose the kernel to next load and choose whether to stay or long directly
    prog16.bin (go back to realmode)
    prog32.bin
    prog64.bin (go to long mode)
    kern64a.bin
    kern64c.bin

have kern64a/kern64c choose the kernel to next load and choose whether to stay or long directly
    prog16.bin (go back to real/unreal/compat?)
    prog32.bin (go back to prot or use compat?)
    prog64.bin
    kern64a.bin
    kern64c.bin

danos: go to protmode and then load a 32 bit kernel which can then go to longmode and load a 64 bit kernel?
load either the 16 bit kernel which loads the 32 bit kernel - that's quite doable from 16 bit mode if we have a standard place to load it to

Then hopefully go higher one day

TODO: experiment with some kind of openwatcom/borland C to x16 compiler?

Move to Multi project type & merge danos32 into it

Directory Makefiles

qemus:
    make qemu16a
    make qemu32a
    make qemu32c
    make qemu64a
    make qemu64c

merge kernel32c and main