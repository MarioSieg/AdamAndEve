as -o Boot.o Boot16.asm
ld -o Boot.tmp -Ttext 0x7c00 Boot.o
objcopy -O binary Boot.tmp -j .text Booster.iso
rm Boot.o
rm Boot.tmp