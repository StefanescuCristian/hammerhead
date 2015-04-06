#
# Makefile for the packet AF.
#

obj-$(CONFIG_PACKET) += af_packet.o

ifdef CONFIG_MACH_MSM8975_HAMMERHEAD_STRICT_ALIASING
CFLAGS_KERNEL := -fno-strict-aliasing
endif
