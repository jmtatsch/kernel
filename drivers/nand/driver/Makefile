#
# Makefile
#

KBUILD_CFLAGS	+= -I$/drivers/nand/driver/inc/ \
		-I$/drivers/nand/manager/inc/

obj-$(CONFIG_NAND)	+= hw/transadaptor/cpu_trans.o \
			hw/transadaptor/dma_trans.o \
			hw/nand_bch.o

obj-$(CONFIG_NAND_NEMC) += hw/nand_io_emc.o
obj-$(CONFIG_NAND_NFI) += hw/nand_io_nfi.o

obj-$(CONFIG_NAND)	+= ops/

obj-$(CONFIG_NAND)	+= chips/nand_chip.o chips/nand_info.o chips/nand_errpt.o \
			utils/os_clib.o utils/speed_dug.o \
			utils/nand_debug.o nand_api.o

obj-$(CONFIG_NAND)	+= nand_driver.o
