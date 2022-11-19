with import <nixpkgs> {};
runCommand "danos" {
    shellHook = ''
      [ -f OVMF_VARS.fd ] || cp ${OVMFFull.fd.outPath}/FV/OVMF_CODE.fd .
      [ -f OVMF_VARS.fd ] || cp ${OVMFFull.fd.outPath}/FV/OVMF_VARS.fd .
      chown $USER *.fd
      chmod +w *.fd
    '';
    buildInputs = [
        nasm
        gcc
        pkgsi686Linux.glibc.dev
        qemu
        OVMFFull.fd
        gnu-efi
        syslinux
    ];
} ""
