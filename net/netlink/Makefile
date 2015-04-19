#
# Makefile for the netlink driver.
#

obj-y  				:= af_netlink.o genetlink.o

ifdef CONFIG_MACH_MSM8974_HAMMERHEAD_STRICT_ALIASING
CFLAGS_KERNEL := -fno-strict-aliasing
endif
