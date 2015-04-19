#
# Makefile for the Linux Bluetooth BNEP layer.
#

obj-$(CONFIG_BT_BNEP) += bnep.o

bnep-objs := core.o sock.o netdev.o
ifdef CONFIG_MACH_MSM8974_HAMMERHEAD_STRICT_ALIASING
CFLAGS_core.o := -fno-strict-aliasing
CFLAGS_sock.o := -fno-strict-aliasing
CFLAGS_netdev.o := -fno-strict-aliasing
endif

