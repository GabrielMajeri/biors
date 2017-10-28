CONFIG := debug
TARGET := x86_64-bios

BUILD_DIR := build
TARGET_DIR := target/$(TARGET)/$(CONFIG)

BIOS_ELF := $(BUILD_DIR)/bios.elf
BIOS_IMAGE := $(BUILD_DIR)/bios.bin

.PHONY: all test

all: test

build:
	@mkdir $@

$(BIOS_IMAGE): $(BIOS_ELF) | build
	@echo Creating final object binary
	@objcopy --output-format binary $< $@

$(BIOS_ELF): scripts/link.ld $(BUILD_DIR)/start.o $(TARGET_DIR)/libbiors.a
	@echo Linking BIOS
	@ld -fatal-warnings --gc-sections --script=$^ -o $@

$(BUILD_DIR)/start.o: src/start.S
	@echo Assembling real mode stage
	@$(CC) -fvisibility=hidden -Wall -Wextra -Werror -c $< -o $@

$(TARGET_DIR)/libbiors.a: src/lib.rs
	@echo Building Rust stage
	@xargo build --target x86_64-bios

test: $(BIOS_IMAGE)
	@echo Running in QEMU
	@qemu-system-x86_64 \
		-nodefaults -nographic \
		-M q35,accel=kvm:zen:hax:tcg \
		-bios $(BIOS_IMAGE) \
		-debugcon file:$(BUILD_DIR)/debug.log
