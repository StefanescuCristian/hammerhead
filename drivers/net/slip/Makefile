#
# Makefile for the SLIP network device drivers.
#

obj-$(CONFIG_SLIP) += slip.o
obj-$(CONFIG_SLHC) += slhc.o

ifdef CONFIG_MACH_MSM8974_HAMMERHEAD_STRICT_ALIASING
CFLAGS_slip.o := -fno-strict-aliasing
CFLAGS_slhc.o := -fno-strict-aliasing
endif

