#
# Makefile for the packet AF.
#

obj-$(CONFIG_PACKET) += af_packet.o

ifdef CONFIG_MACH_MSM8974_HAMMERHEAD_STRICT_ALIASING
CFLAGS_KERNEL := -fno-strict-aliasing
endif
