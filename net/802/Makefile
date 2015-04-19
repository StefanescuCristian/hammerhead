#
# Makefile for the Linux 802.x protocol layers.
#

# Check the p8022 selections against net/core/Makefile.
obj-$(CONFIG_LLC)	+= p8022.o psnap.o
obj-$(CONFIG_TR)	+= p8022.o psnap.o tr.o
obj-$(CONFIG_NET_FC)	+=                 fc.o
obj-$(CONFIG_FDDI)	+=                 fddi.o
obj-$(CONFIG_HIPPI)	+=                 hippi.o
obj-$(CONFIG_IPX)	+= p8022.o psnap.o p8023.o
obj-$(CONFIG_ATALK)	+= p8022.o psnap.o
obj-$(CONFIG_STP)	+= stp.o
obj-$(CONFIG_GARP)	+= garp.o

ifdef CONFIG_MACH_MSM8974_HAMMERHEAD_STRICT_ALIASING
CFLAGS_stp.o := -fno-strict-aliasing
CFLAGS_p8022.o := -fno-strict-aliasing
CFLAGS_psnap.o := -fno-strict-aliasing
endif

