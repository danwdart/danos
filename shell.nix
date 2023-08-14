with import <nixpkgs> {};
runCommand "danos" {
    shellHook = if builtins.currentSystem == "aarch64-darwin" then ''
    export CC_X86_64=x86_64-unknown-linux-gnu-gcc
    export LD_X86_64=x86_64-unknown-linux-gnu-ld
    export AS_X86_64=x86_64-unknown-linux-gnu-as
    export OBJCOPY_X86_64=x86_64-unknown-linux-gnu-objcopy
    export STRIP_X86_64=x86_64-unknown-linux-gnu-strip
    export CC_X86_32=i686-elf-gcc
    export LD_X86_32=i686-elf-ld
    export AS_X86_32=i686-elf-as
    export OBJCOPY_X86_32=i686-elf-objcopy
    export STRIP_X86_32=i686-elf-strip
    export CC_ARM=arm-none-eabi-gcc
    export LD_ARM=arm-none-eabi-ld
    export AS_ARM=arm-none-eabi-as
    export OBJCOPY_ARM=arm-none-eabi-objcopy
    export STRIP_ARM=arm-none-eabi-strip
    export CC_ARMHF=arm-none-eabihf-gcc
    export LD_ARMHF=arm-none-eabihf-ld
    export AS_ARMHF=arm-none-eabihf-as
    export OBJCOPY_ARMHF=arm-none-eabihf-objcopy
    export STRIP_ARMHF=arm-none-eabihf-strip
    export CC_AARCH64=aarch64-none-elf-gcc
    export LD_AARCH64=aarch64-none-elf-ld
    export AS_AARCH64=aarch64-none-elf-as
    export OBJCOPY_AARCH64=aarch64-none-elf-objcopy
    export STRIP_AARCH64=aarch64-none-elf-strip
    '' else (if builtins.currentSystem == "aarch64-linux" then ''
    [ -f AAVMF_CODE.fd ] || cp ${OVMF.fd.outPath}/FV/AAVMF_CODE.fd .
    [ -f AAVMF_VARS.fd ] || cp ${OVMF.fd.outPath}/FV/AAVMF_VARS.fd .
    [ -f QEMU_VARS.fd ] || cp ${OVMF.fd.outPath}/FV/QEMU_VARS.fd .
    [ -f QEMU_EFI.fd ] || cp ${OVMF.fd.outPath}/FV/QEMU_EFI.fd .
    [ -f edk2-x86_64-code.fd ] || cp ${qemu.outPath}/share/qemu/edk2-x86_64-code.fd .
    [ -f edk2-x86_64-vars.fd ] || cp ${qemu.outPath}/share/qemu/edk2-x86_64-vars.fd .
    [ -f edk2-aarch64-code.fd ] || cp ${qemu.outPath}/share/qemu/edk2-aarch64-code.fd .
    [ -f edk2-arm-vars.fd ] || cp ${qemu.outPath}/share/qemu/edk2-arm-vars.fd .
    [ -f u-boot.bin ] || cp ${ubootQemuAarch64.outPath}/u-boot.bin .
    chown $USER *.fd *.bin
    chmod +w *.fd *.bin
    export EFIDIR_AARCH64=${gnu-efi.outPath}
    export EFIDIR_X86_64=${pkgsCross.gnu64.pkgsHostTarget.gnu-efi.outPath}
    export CC_X86_64=x86_64-unknown-linux-gnu-gcc
    export LD_X86_64=x86_64-unknown-linux-gnu-ld
    export AS_X86_64=x86_64-unknown-linux-gnu-as
    export OBJCOPY_X86_64=x86_64-unknown-linux-gnu-objcopy
    export STRIP_X86_64=x86_64-unknown-linux-gnu-strip
    export CC_X86_32=i686-unknown-linux-gnu-gcc
    export LD_X86_32=i686-unknown-linux-gnu-ld
    export AS_X86_32=i686-unknown-linux-gnu-as
    export OBJCOPY_X86_32=i686-unknown-linux-gnu-objcopy
    export STRIP_X86_32=i686-unknown-linux-gnu-strip
    export CC_ARM=arm-none-eabi-gcc
    export LD_ARM=arm-none-eabi-ld
    export AS_ARM=arm-none-eabi-as
    export OBJCOPY_ARM=arm-none-eabi-objcopy
    export STRIP_ARM=arm-none-eabi-strip
    export CC_ARMHF=arm-none-eabihf-gcc
    export LD_ARMHF=arm-none-eabihf-ld
    export AS_ARMHF=arm-none-eabihf-as
    export OBJCOPY_ARMHF=arm-none-eabihf-objcopy
    export STRIP_ARMHF=arm-none-eabihf-strip
    export CC_AARCH64=gcc
    export LD_AARCH64=ld
    export AS_AARCH64=as
    export OBJCOPY_AARCH64=objcopy
    export STRIP_AARCH64=strip
    '' else ''
    [ -f AAVMF_CODE.fd ] || cp ${OVMF.fd.outPath}/FV/AAVMF_CODE.fd .
    [ -f AAVMF_VARS.fd ] || cp ${OVMF.fd.outPath}/FV/AAVMF_VARS.fd .
    [ -f QEMU_VARS.fd ] || cp ${OVMF.fd.outPath}/FV/QEMU_VARS.fd .
    [ -f QEMU_EFI.fd ] || cp ${OVMF.fd.outPath}/FV/QEMU_EFI.fd .
    [ -f edk2-x86_64-code.fd ] || cp ${qemu.outPath}/share/qemu/edk2-x86_64-code.fd .
    [ -f edk2-i386-vars.fd ] || cp ${qemu.outPath}/share/qemu/edk2-i386-vars.fd .
    [ -f edk2-aarch64-code.fd ] || cp ${qemu.outPath}/share/qemu/edk2-aarch64-code.fd .
    [ -f edk2-arm-vars.fd ] || cp ${qemu.outPath}/share/qemu/edk2-arm-vars.fd .
    chown $USER *.fd
    chmod +w *.fd
    export EFIDIR_X86_64=${gnu-efi.outPath}
    export CC_X86_64=gcc
    export LD_X86_64=ld
    export AS_X86_64=as
    export OBJCOPY_X86_64=objcopy
    export STRIP_X86_64=strip
    export CC_X86_32=i686-elf-gcc
    export LD_X86_32=i686-elf-ld
    export AS_X86_32=i686-elf-as
    export OBJCOPY_X86_32=i686-elf-objcopy
    export STRIP_X86_32=i686-elf-strip
    export CC_ARM=arm-none-eabi-gcc
    export LD_ARM=arm-none-eabi-ld
    export AS_ARM=arm-none-eabi-as
    export OBJCOPY_ARM=arm-none-eabi-objcopy
    export STRIP_ARM=arm-none-eabi-strip
    export CC_ARMHF=arm-none-eabihf-gcc
    export LD_ARMHF=arm-none-eabihf-ld
    export AS_ARMHF=arm-none-eabihf-as
    export OBJCOPY_ARMHF=arm-none-eabihf-objcopy
    export STRIP_ARMHF=arm-none-eabihf-strip
    export CC_AARCH64=aarch64-none-elf-gcc
    export LD_AARCH64=aarch64-none-elf-ld
    export AS_AARCH64=aarch64-none-elf-as
    export OBJCOPY_AARCH64=aarch64-none-elf-objcopy
    export STRIP_AARCH64=aarch64-none-elf-strip
    '');
    buildInputs = [
        nasm
        gcc
        qemu
        dtc
    ] ++ (if builtins.currentSystem == "aarch64-darwin" then [
        pkgsCross.gnu32.pkgsBuildHost.gcc
        # pkgsCross.x86_64-embedded.pkgsBuildHost.gcc # not cached
        pkgsCross.gnu64.pkgsBuildHost.gcc
        # pkgsCross.aarch64-embedded.pkgsBuildHost.gcc # not cached
        pkgsCross.arm-embedded.pkgsBuildHost.gcc
        # pkgsCross.armhf-embedded.pkgsBuildHost.gcc # not cached
        pkgsCross.armv7l-hf-multiplatform.pkgsBuildHost.gcc
        pkgsCross.gnu64.pkgsHostTarget.gnu-efi
        # more pkgsCross for linux
        # gnu-efi
        # OVMF.fd
        # ubootQemuAarch64
    ] else (if builtins.currentSystem == "aarch64-linux" then [
        pkgsCross.gnu32.pkgsBuildHost.gcc
        # pkgsCross.x86_64-embedded.pkgsBuildHost.gcc # not cached
        pkgsCross.gnu64.pkgsBuildHost.gcc
        # pkgsCross.aarch64-embedded.pkgsBuildHost.gcc # not cached
        pkgsCross.arm-embedded.pkgsBuildHost.gcc
        # pkgsCross.armhf-embedded.pkgsBuildHost.gcc # not cached
        pkgsCross.armv7l-hf-multiplatform.pkgsBuildHost.gcc
        pkgsCross.gnu64.pkgsHostTarget.gnu-efi
        gnu-efi
        OVMF.fd
        ubootQemuAarch64
    ] else [
        gnu-efi
        pkgsi686Linux.glibc.dev
        OVMFFull.fd
        syslinux
    ]));
} ""
