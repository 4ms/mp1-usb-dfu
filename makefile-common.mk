LINKSCR ?= linkscript.ld
BUILDDIR ?= build
BINARYNAME ?= main
UIMAGENAME ?= $(BUILDDIR)/a7-main.uimg
SCRIPTDIR ?= .

OBJDIR = $(BUILDDIR)/obj/obj
LOADADDR 	?= 0xC2000040
ENTRYPOINT 	?= 0xC2000040

OBJECTS   = $(addprefix $(OBJDIR)/, $(addsuffix .o, $(basename $(SOURCES))))
DEPS   	  = $(addprefix $(OBJDIR)/, $(addsuffix .d, $(basename $(SOURCES))))

MCU ?=  -mcpu=cortex-a7 -march=armv7ve -mfpu=neon-vfpv4 -mlittle-endian -mfloat-abi=hard

EXTRA_ARCH_CFLAGS ?= 

ARCH_CFLAGS ?= -DUSE_FULL_LL_DRIVER \
			   -DSTM32MP157Cxx \
			   -DSTM32MP1 \
			   -DCORE_CA7 \
			   $(EXTRA_ARCH_CFLAGS) \

OPTFLAG ?= -O0

AFLAGS = $(MCU)

CFLAGS = -g2 \
		 -fno-common \
		 $(ARCH_CFLAGS) \
		 $(MCU) \
		 $(INCLUDES) \
		 -fdata-sections -ffunction-sections \
		 -nostartfiles \
		 $(EXTRACFLAGS)\

CXXFLAGS = $(CFLAGS) \
		-std=c++2a \
		-fno-rtti \
		-fno-exceptions \
		-fno-unwind-tables \
		-fno-threadsafe-statics \
		-mno-unaligned-access \
		-Werror=return-type \
		-Wdouble-promotion \
		-Wno-register \
		-Wno-volatile \
		 $(EXTRACXXFLAGS) \

LINK_STDLIB ?= -nostdlib

LFLAGS = -Wl,--gc-sections \
		 -Wl,-Map,$(BUILDDIR)/$(BINARYNAME).map,--cref \
		 $(MCU)  \
		 -T $(LINKSCR) \
		 $(LINK_STDLIB) \
		 -nostartfiles \
		 -ffreestanding \
		 -Wl,--no-warn-rwx-segments \
		 $(EXTRALDFLAGS) \

DEPFLAGS = -MMD -MP -MF $(OBJDIR)/$(basename $<).d

# By default, this uses the toolchain on your path
# Override by invoking make with TOOLCHAIN_DIR=/my/location/ (final slash is required)
TOOLCHAIN_DIR ?= 
ARCH 	= arm-none-eabi
CC 		= ${TOOLCHAIN_DIR}$(ARCH)-gcc
CXX 	= ${TOOLCHAIN_DIR}$(ARCH)-g++
LD 		= ${TOOLCHAIN_DIR}$(ARCH)-g++
AS 		= ${TOOLCHAIN_DIR}$(ARCH)-as
OBJCPY 	= ${TOOLCHAIN_DIR}$(ARCH)-objcopy
OBJDMP 	= ${TOOLCHAIN_DIR}$(ARCH)-objdump
GDB 	= ${TOOLCHAIN_DIR}$(ARCH)-gdb
SZ 		= ${TOOLCHAIN_DIR}$(ARCH)-size

SZOPTS 	= -d

ELF 	= $(BUILDDIR)/$(BINARYNAME).elf
HEX 	= $(BUILDDIR)/$(BINARYNAME).hex
BIN 	= $(BUILDDIR)/$(BINARYNAME).bin

all: Makefile makefile-common.mk $(ELF) $(UIMAGENAME)
	@:

elf: $(ELF)

install:
	@if [ "$${SD_DISK_DEVPART}" = "" ]; then echo "Please specify the disk and partition like this: make install SD_DISK_DEVPART=/dev/diskXs3"; \
	else \
	echo "sudo dd if=${UIMAGENAME} of=$${SD_DISK_DEVPART}" && \
	sudo dd if=${UIMAGENAME} of=$${SD_DISK_DEVPART};  fi

$(OBJDIR)/%.o: %.s
	@mkdir -p $(dir $@)
	$(info Building $< at $(OPTFLAG))
	@$(AS) $(AFLAGS) $< -o $@ 

$(OBJDIR)/%.o: %.c $(OBJDIR)/%.d
	@mkdir -p $(dir $@)
	$(info Building $< at $(OPTFLAG))
	@$(CC) -c $(DEPFLAGS) $(OPTFLAG) $(CFLAGS) $< -o $@

$(OBJDIR)/%.o: %.c[cp]* $(OBJDIR)/%.d
	@mkdir -p $(dir $@)
	$(info Building $< at $(OPTFLAG))
	@$(CXX) -c $(DEPFLAGS) $(OPTFLAG) $(CXXFLAGS) $< -o $@

$(ELF): $(OBJECTS) $(LINKSCR)
	$(info Linking...)
	@$(LD) $(LFLAGS) -o $@ $(OBJECTS) 

$(BIN): $(ELF)
	$(OBJCPY) -O binary $< $@

$(HEX): $(ELF)
	@$(OBJCPY) --output-target=ihex $< $@
	@$(SZ) $(SZOPTS) $(ELF)

$(UIMAGENAME): $(BIN)
	$(info Creating uimg file)
	python3 $(SCRIPTDIR)/uimg_header.py $< $@ $(LOADADDR) $(ENTRYPOINT)

%.d: ;

clean:
	rm -rf build

ifneq "$(MAKECMDGOALS)" "clean"
-include $(DEPS)
endif

.PRECIOUS: $(DEPS) $(OBJECTS) $(ELF)
.PHONY: all clean install 

.PHONY: compile_commands
compile_commands:
	compiledb make
	compdb -p ./ list > compile_commands.tmp 2>/dev/null
	rm compile_commands.json
	mv compile_commands.tmp compile_commands.json
