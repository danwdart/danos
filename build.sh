echo Building DanOS...
echo Compiling MBR...
nasm mbr.asm -ombr.bin || exit 1
echo Compiling Partition 1,,,
nasm part1.asm -opart1.bin || exit 1
echo Mounting the image...
mkdir danos/
sudo umount danos/
sudo mount -oloop part1.bin danos/ || exit 1
echo Compiling the programs...
for i in apps/*.asm
do
     nasm $i -o apps/`basename $i .asm`.bin || exit
done
sudo cp apps/*.bin danos/
sync
echo Unmounting the disk image...
umount danos/
echo Combining the MBR...
cat mbr.bin part1.bin > danos.bin
echo Running the emulator...
kvm  -hda danos.bin -boot c
