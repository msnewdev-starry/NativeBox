CC = i686-elf-gcc
AS = nasm
LD = i686-elf-ld
CFLAGS = -ffreestanding -fno-builtin -Wall -Wextra -I./kernel
ASFLAGS = -f elf

all: nativebox.iso

# Build bootloader
bootloader/boot.bin: bootloader/boot.asm
	$(AS) -f bin -o $@ $<

# Build kernel object files
kernel/kernel.o: kernel/kernel.c kernel/kernel.h
	$(CC) $(CFLAGS) -c -o $@ kernel/kernel.c

# Link everything together
nativebox.elf: bootloader/boot.bin kernel/kernel.o
	$(LD) -T kernel/link.ld -o $@ kernel/kernel.o

# Create ISO image
nativebox.iso: nativebox.elf
	# Create ISO using grub-mkrescue or similar tool
	# This requires additional setup with GRUB bootloader

# Run in QEMU
run: nativebox.iso
	qemu-system-i386 -cdrom nativebox.iso -m 64

# Run with debugging
debug: nativebox.elf
	qemu-system-i386 -kernel nativebox.elf -m 64 -S -gdb tcp::1234

# Clean build artifacts
clean:
	rm -f bootloader/boot.bin kernel/kernel.o nativebox.elf nativebox.iso

.PHONY: all run debug clean
