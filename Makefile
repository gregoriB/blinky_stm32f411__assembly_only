CC        := arm-none-eabi-gcc
LD        := arm-none-eabi-gcc
OBJCOPY   := arm-none-eabi-objcopy

SRC_DIR   := src
LD_DIR    := ld
BUILD_DIR := build

CFLAGS    := -g -mcpu=cortex-m4 -mthumb -mfloat-abi=hard -mfpu=fpv4-sp-d16 -O0 -nostdlib -ffreestanding
LDFLAGS   := -g -nostdlib -Wl,--gc-sections
INCLUDES  := -Iinclude

BOOT_SRC  := $(SRC_DIR)/bootloader.S
FW_SRC    := $(SRC_DIR)/firmware.S

BOOT_OBJ  := $(BUILD_DIR)/bootloader.o
FW_OBJ    := $(BUILD_DIR)/firmware.o

BOOT_ELF  := $(BUILD_DIR)/bootloader.elf
FW_ELF    := $(BUILD_DIR)/firmware.elf

BOOT_BIN  := $(BUILD_DIR)/bootloader.bin
FW_BIN    := $(BUILD_DIR)/firmware.bin

BOOT_LD   := -T$(LD_DIR)/bootloader.ld
FW_LD     := -T$(LD_DIR)/firmware.ld

.PHONY: all bootloader firmware flash clean

all: $(BOOT_ELF) $(FW_ELF)

bootloader: $(BOOT_ELF)
firmware:  $(FW_ELF)

$(BUILD_DIR)/%.o: $(SRC_DIR)/%.S
	@mkdir -p $(dir $@)
	$(CC) -c $< $(CFLAGS) $(INCLUDES) -o $@

$(BUILD_DIR)/bootloader.elf: $(BOOT_OBJ)
	$(LD) $< $(BOOT_LD) $(LDFLAGS) -Wl,-Map=$(BUILD_DIR)/bootloader.map -o $@
	$(OBJCOPY) -O binary $@ $(BOOT_BIN)

$(BUILD_DIR)/firmware.elf: $(FW_OBJ)
	$(LD) $< $(FW_LD) $(LDFLAGS) -Wl,-Map=$(BUILD_DIR)/firmware.map -o $@
	$(OBJCOPY) -O binary $@ $(FW_BIN)

flash: all
	st-flash write $(BOOT_BIN) 0x08000000
	st-flash write $(FW_BIN)   0x08004000

clean:
	@rm -rf $(BUILD_DIR)
