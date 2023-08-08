with import <nixpkgs> {};
runCommand "danos" {
    shellHook = if builtins.currentSystem == "aarch64-darwin" then ''
    export EFIDIR=${pkgsCross.gnu64.pkgsHostTarget.gnu-efi.outPath}
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
    export EFIDIR=${pkgsCross.gnu64.pkgsHostTarget.gnu-efi.outPath}
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
    '' else ''
    [ -f OVMF_VARS.fd ] || cp ${OVMFFull.fd.outPath}/FV/OVMF_CODE.fd .
    [ -f OVMF_VARS.fd ] || cp ${OVMFFull.fd.outPath}/FV/OVMF_VARS.fd .
    chown $USER *.fd
    chmod +w *.fd
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
        gnu-efi
    ] ++ (if builtins.currentSystem == "aarch64-darwin" then [
        pkgsCross.i686-embedded.pkgsBuildHost.gcc
        pkgsCross.x86_64-embedded.pkgsBuildHost.gcc
        pkgsCross.gnu64.pkgsBuildHost.gcc
        pkgsCross.aarch64-embedded.pkgsBuildHost.gcc
        pkgsCross.arm-embedded.pkgsBuildHost.gcc
        pkgsCross.armhf-embedded.pkgsBuildHost.gcc
        pkgsCross.gnu64.pkgsHostTarget.gnu-efi
    ] else (if builtins.currentSystem == "aarch64-linux" then [
        pkgsCross.i686-embedded.pkgsBuildHost.gcc
        pkgsCross.x86_64-embedded.pkgsBuildHost.gcc
        pkgsCross.gnu64.pkgsBuildHost.gcc
        pkgsCross.aarch64-embedded.pkgsBuildHost.gcc
        pkgsCross.arm-embedded.pkgsBuildHost.gcc
        pkgsCross.armhf-embedded.pkgsBuildHost.gcc
        pkgsCross.gnu64.pkgsHostTarget.gnu-efi
    ] else [
        pkgsi686Linux.glibc.dev
        OVMFFull.fd
        syslinux
    ]));
} ""
