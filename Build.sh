as -o Boot.o AdamAndEve.asm
ld -o Boot.tmp -Ttext 0x7c00 Boot.o
objcopy -O binary Boot.tmp -j .text AdamAndEve.bin
rm Boot.o
rm Boot.tmp