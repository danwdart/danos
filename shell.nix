with import <nixpkgs> {};
runCommand "danos" {
    shellHook = if builtins.currentSystem == "aarch64-darwin" then ''
    '' else ''
      [ -f OVMF_VARS.fd ] || cp ${OVMFFull.fd.outPath}/FV/OVMF_CODE.fd .
      [ -f OVMF_VARS.fd ] || cp ${OVMFFull.fd.outPath}/FV/OVMF_VARS.fd .
      chown $USER *.fd
      chmod +w *.fd
    '';
    buildInputs = [
        nasm
        gcc
        qemu
    ] ++ (if builtins.currentSystem == "aarch64-darwin" then [
        pkgsCross.x86_64-embedded.pkgsBuildHost.gcc
        pkgsCross.aarch64-embedded.pkgsBuildHost.gcc
    ] else (if builtins.currentSystem == "aarch64-linux" then [
        pkgsCross.x86_64-embedded.pkgsBuildHost.gcc
        pkgsCross.aarch64-embedded.pkgsBuildHost.gcc
    ] else [
        pkgsi686Linux.glibc.dev
        OVMFFull.fd
        gnu-efi
        syslinux
    ]));
} ""
