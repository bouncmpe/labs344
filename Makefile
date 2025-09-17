.PHONY: all clean run

TOOLCHAIN_PREFIX := riscv64-unknown-elf
CC := $(TOOLCHAIN_PREFIX)-gcc

SRC_DIR := examples/fibonacci
TARGET_DIR := target

SRC := $(wildcard $(SRC_DIR)/*.s $(SRC_DIR)/*.c)
TARGET_NAME := main

RV_ARCH := rv64gc
LD_FLAGS :=
C_FLAGS := -Wall -Wextra -std=c11 -pedantic -O2 -ffreestanding -nostdlib \
           -mcmodel=medany -march=$(RV_ARCH)


all: $(TARGET_DIR)/$(TARGET_NAME)

$(TARGET_DIR)/$(TARGET_NAME): $(SRC)
	mkdir -p $(TARGET_DIR)
	$(CC) $(C_FLAGS) $(LD_FLAGS) -o $@ $^

clean:
	rm -rf $(TARGET_DIR)

run: all
	spike $(TARGET_DIR)/$(TARGET_NAME)
