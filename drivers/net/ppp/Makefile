#
# Makefile for the Linux PPP network device drivers.
#

obj-$(CONFIG_PPP) += ppp_generic.o
obj-$(CONFIG_PPP_ASYNC) += ppp_async.o
obj-$(CONFIG_PPP_BSDCOMP) += bsd_comp.o
obj-$(CONFIG_PPP_DEFLATE) += ppp_deflate.o
obj-$(CONFIG_PPP_MPPE) += ppp_mppe.o
obj-$(CONFIG_PPP_SYNC_TTY) += ppp_synctty.o
obj-$(CONFIG_PPPOE) += pppox.o pppoe.o
obj-$(CONFIG_PPPOL2TP) += pppox.o
obj-$(CONFIG_PPTP) += pppox.o pptp.o
obj-$(CONFIG_PPPOLAC) += pppox.o pppolac.o
obj-$(CONFIG_PPPOPNS) += pppox.o pppopns.o

ifdef CONFIG_MACH_MSM8974_HAMMERHEAD_STRICT_ALIASING
CFLAGS_ppp_generic.o := -fno-strict-aliasing
CFLAGS_ppp_async.o := -fno-strict-aliasing
CFLAGS_ppp_synctty.o := -fno-strict-aliasing
CFLAGS_pppoe.o := -fno-strict-aliasing
CFLAGS_pppolac.o := -fno-strict-aliasing
CFLAGS_pppox.o := -fno-strict-aliasing
CFLAGS_pppopns.o := -fno-strict-aliasing
endif

