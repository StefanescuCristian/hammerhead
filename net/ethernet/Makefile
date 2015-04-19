#
# Makefile for the Linux Ethernet layer.
#

obj-y					+= eth.o
obj-$(subst m,y,$(CONFIG_IPX))		+= pe2.o
obj-$(subst m,y,$(CONFIG_ATALK))	+= pe2.o

ifdef CONFIG_MACH_MSM8974_HAMMERHEAD_STRICT_ALIASING
CFLAGS_eth.o := -fno-strict-aliasing
endif

