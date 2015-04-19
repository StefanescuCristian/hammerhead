#
# Makefile for the key AF.
#

obj-$(CONFIG_NET_KEY) += af_key.o

ifdef CONFIG_MACH_MSM8974_HAMMERHEAD_STRICT_ALIASING
CFLAGS_KERNEL := -fno-strict-aliasing
endif
