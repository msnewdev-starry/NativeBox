CC = i686-w64-mingw32-gcc
AS = nasm
LD = i686-w64-mingw32-ld
OBJCOPY = i686-w64-mingw32-objcopy
CFLAGS = -ffreestanding -fno-builtin -Wall -Wextra -I./kernel -fno-asynchronous-unwind-tables
ASFLAGS = -f win32

.PHONY: all clean run debug

all: nativebox.bin

# Build bootloader
bootloader/boot.bin: bootloader/boot.asm
	$(AS) $(ASFLAGS) -o bootloader/boot.o $<
	$(LD) -T kernel/link.ld -o bootloader/boot.elf bootloader/boot.o
	$(OBJCOPY) -O binary bootloader/boot.elf $@

# Build kernel object files
kernel/kernel.o: kernel/kernel.c kernel/kernel.h
	$(CC) $(CFLAGS) -c -o $@ $<

# Link everything together (PE format)
nativebox.exe: bootloader/boot.bin kernel/kernel.o
	$(LD) -T kernel/link.ld --oformat pei-i386 -o $@ kernel/kernel.o

# Convert to raw binary
nativebox.bin: nativebox.exe
	$(OBJCOPY) -O binary $< $@

# Run in QEMU
run: nativebox.bin
	qemu-system-i386 -drive file=$<,format=raw -m 64

# Debug with GDB
debug: nativebox.exe
	qemu-system-i386 -drive file=nativebox.bin,format=raw -m 64 -S -gdb tcp::1234

# Clean build artifacts
clean:
	rm -f bootloader/boot.o bootloader/boot.elf bootloader/boot.bin
	rm -f kernel/kernel.o
	rm -f nativebox.exe nativebox.bin
