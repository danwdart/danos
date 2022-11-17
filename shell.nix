with import <nixpkgs> {};
runCommand "danos" {
    buildInputs = [
        nasm
        gcc
        qemu
    ];
} ""
