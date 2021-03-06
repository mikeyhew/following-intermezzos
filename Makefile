default: build

build: target/kernel.bin

.PHONY: clean
.PHONY: cargo

target/multiboot_header.o: src/asm/multiboot_header.asm
	mkdir -p target
	nasm -f elf64 src/asm/multiboot_header.asm -o target/multiboot_header.o

target/boot.o: src/asm/boot.asm
	mkdir -p target
	nasm -f elf64 src/asm/boot.asm -o target/boot.o

target/kernel.bin: target/multiboot_header.o target/boot.o src/asm/linker.ld cargo
	 ${HOME}/opt/bin/x86_64-pc-elf-ld -n -o target/kernel.bin -T src/asm/linker.ld target/multiboot_header.o target/boot.o target/x86_64-unknown-intermezzos-gnu/debug/libintermezzos.a

target/os.iso: target/kernel.bin src/asm/grub.cfg
	mkdir -p target/isofiles/boot/grub
	cp src/asm/grub.cfg target/isofiles/boot/grub
	cp target/kernel.bin target/isofiles/boot/
	 ${HOME}/opt/bin/grub-mkrescue -o target/os.iso target/isofiles

run: target/os.iso
	qemu-system-x86_64 -cdrom target/os.iso

clean:
	cargo clean

cargo:
	xargo build --target x86_64-unknown-intermezzos-gnu
