BINARYNAME = main
BUILDDIR = build

OPTFLAG = -O3

EXTLIBDIR = third-party
STM32HALDIR = $(EXTLIBDIR)/STM32MP1xx_HAL_Driver
PATCHEDSTM32HALDIR = stm32hal_patched
USBLIBDIR = $(EXTLIBDIR)/STM32_USB_Device_Library

LOADADDR   = 0xC0200000
ENTRYPOINT = 0xC0200040

SOURCES = src/startup.s \
		  src/main.cc \
		  src/print.cc \
		  src/system/irq_init.c \
		  src/system/libc_stub.c \
		  src/system/libcpp_stub.cc \
		  src/system/mmu_ca7.c \
		  src/system/system_ca7.c \
		  src/drivers/irq_handler.cc \
		  src/drivers/norflash/qspi_flash_driver.cc \
		  src/usb_dfu/usbd_conf.c \
		  src/usb_dfu/usbd_desc.c \
		  src/usb_dfu/usbd_dfu_media.cc \
		  $(PATCHEDSTM32HALDIR)/stm32mp1xx_hal.c \
		  $(PATCHEDSTM32HALDIR)/stm32mp1xx_hal_pcd.c \
		  $(PATCHEDSTM32HALDIR)/stm32mp1xx_hal_pcd_ex.c \
		  $(PATCHEDSTM32HALDIR)/stm32mp1xx_ll_usb.c \
		  $(PATCHEDSTM32HALDIR)/stm32mp1xx_ll_usb_phy.c \
		  $(STM32HALDIR)/Src/stm32mp1xx_hal_gpio.c \
		  $(STM32HALDIR)/Src/stm32mp1xx_hal_rcc.c \
		  $(STM32HALDIR)/Src/stm32mp1xx_hal_rcc_ex.c \
		  $(STM32HALDIR)/Src/stm32mp1xx_hal_qspi.c \
		  $(STM32HALDIR)/Src/stm32mp1xx_ll_rcc.c \
		  $(USBLIBDIR)/Class/DFU/Src/usbd_dfu.c \
		  $(USBLIBDIR)/Core/Src/usbd_core.c \
		  $(USBLIBDIR)/Core/Src/usbd_ctlreq.c \
		  $(USBLIBDIR)/Core/Src/usbd_ioreq.c \


INCLUDES = -Isrc \
		   -Isrc/usb_dfu \
		   -Isrc/system \
		   -I$(PATCHEDSTM32HALDIR) \
		   -I$(STM32HALDIR)/Inc \
		   -I$(EXTLIBDIR)/CMSIS/Core_A/Include \
		   -I$(EXTLIBDIR)/CMSIS/Device/ST/STM32MP1xx/Include \
		   -I$(USBLIBDIR)/Class/DFU/Inc \
		   -I$(USBLIBDIR)/Core/Inc \

EXTRA_ARCH_CFLAGS = -DUSE_HAL_DRIVER 

LINK_STDLIB = --specs=nosys.specs
# LINK_STDLIB =

ifneq ("$(BOARD_CONF)","")
	EXTRA_ARCH_CFLAGS += -DBOARD_CONF_PATH=$(BOARD_CONF)
endif

UIMAGENAME = $(BUILDDIR)/usbdfu.uimg
include makefile-common.mk

