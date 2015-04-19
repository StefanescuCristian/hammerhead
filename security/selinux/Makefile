#
# Makefile for building the SELinux module as part of the kernel tree.
#

obj-$(CONFIG_SECURITY_SELINUX) := selinux.o

selinux-y := avc.o hooks.o selinuxfs.o netlink.o nlmsgtab.o netif.o \
	     netnode.o netport.o exports.o \
	     ss/ebitmap.o ss/hashtab.o ss/symtab.o ss/sidtab.o ss/avtab.o \
	     ss/policydb.o ss/services.o ss/conditional.o ss/mls.o ss/status.o

selinux-$(CONFIG_SECURITY_NETWORK_XFRM) += xfrm.o

selinux-$(CONFIG_NETLABEL) += netlabel.o

ccflags-y := -Isecurity/selinux -Isecurity/selinux/include

$(addprefix $(obj)/,$(selinux-y)): $(obj)/flask.h

quiet_cmd_flask = GEN     $(obj)/flask.h $(obj)/av_permissions.h
      cmd_flask = scripts/selinux/genheaders/genheaders $(obj)/flask.h $(obj)/av_permissions.h

targets += flask.h av_permissions.h
$(obj)/flask.h: $(src)/include/classmap.h FORCE
	$(call if_changed,flask)

ifdef CONFIG_MACH_MSM8974_HAMMERHEAD_STRICT_ALIASING
CFLAGS_avc.o := -fno-strict-aliasing
CFLAGS_hooks.o := -fno-strict-aliasing
CFLAGS_selinuxfs.o := -fno-strict-aliasing
CFLAGS_netlink.o := -fno-strict-aliasing
CFLAGS_nlmsgtab.o := -fno-strict-aliasing
CFLAGS_netif.o := -fno-strict-aliasing
CFLAGS_netnode.o := -fno-strict-aliasing
CFLAGS_netport.o := -fno-strict-aliasing
CFLAGS_exports.o := -fno-strict-aliasing
CFLAGS_ebitmap.o := -fno-strict-aliasing
CFLAGS_hashtab.o := -fno-strict-aliasing
CFLAGS_symtab.o := -fno-strict-aliasing
CFLAGS_sidtab.o := -fno-strict-aliasing
CFLAGS_avtab.o := -fno-strict-aliasing
CFLAGS_policydb.o := -fno-strict-aliasing
CFLAGS_services.o := -fno-strict-aliasing
CFLAGS_conditional.o := -fno-strict-aliasing
CFLAGS_mls.o := -fno-strict-aliasing
CFLAGS_status.o := -fno-strict-aliasing
endif

