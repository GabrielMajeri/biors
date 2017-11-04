# Directory to store built files.
BUILD_DIR := build

# The BIOS as an ELF executable.
bios_elf := target/x86_64-bios/debug/biors.elf

# The BIOS ROM image.
bios_bin := $(BUILD_DIR)/bios.bin

# QEMU's debug console log file.
log_file := $(BUILD_DIR)/debug.log

dis := $(BUILD_DIR)/bios.dis.asm

.PHONY: build run

all: build run

build: $(bios_bin)

run: $(bios_bin)
	@echo Running QEMU...
	@qemu-system-x86_64 \
		-nodefaults -nographic \
		-M q35 \
		-bios '$<' \
		-debugcon file:$(log_file) \
		-no-reboot \
		-d int,guest_errors -D build/qemu.log

$(bios_bin): $(bios_elf)
	@objcopy --output-format binary $< $@

$(bios_elf): FORCE
	@xargo build --target x86_64-bios

FORCE:

dis: $(dis)

$(dis): $(bios_elf)
	@objdump -d $< -M intel,amd64 > $@
