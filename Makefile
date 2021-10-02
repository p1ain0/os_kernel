CC = gcc
AS = gas
LD = ld
OBJCOPY = objcopy
OBJDUMP = objdump
CFLAGS = -fno-pic -static -fno-builtin -fno-strict-aliasing -O2 -Wall -MD -ggdb -Werror -fno-stack-protector -fno-pie -no-pie
LDFLAGS = 
fd.img: bootblock
	dd if=/dev/zero of=fd.img count=10000
	dd if=bootblock of=fd.img conv=notrunc

bootblock: bootload.S
	$(CC) $(CFLAGS) -fno-pic -nostdinc -c bootload.S
	$(LD) $(LDFLAGS) -N -e start -Ttext 0x7C00 -o bootblock.o bootload.o
	$(OBJCOPY) -S -O binary -j .text bootblock.o bootblock	
	./sign.pl bootblock

