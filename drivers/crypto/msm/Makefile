obj-$(CONFIG_CRYPTO_DEV_QCEDEV) += qcedev.o
ifeq ($(CONFIG_CRYPTO_DEV_QCE50), y)
	obj-$(CONFIG_CRYPTO_DEV_QCE) += qce50.o
else
	ifeq ($(CONFIG_CRYPTO_DEV_QCE40), y)
		obj-$(CONFIG_CRYPTO_DEV_QCE) += qce40.o
	else
		obj-$(CONFIG_CRYPTO_DEV_QCE) += qce.o
	endif
endif
obj-$(CONFIG_CRYPTO_DEV_QCRYPTO) += qcrypto.o
obj-$(CONFIG_CRYPTO_DEV_OTA_CRYPTO) += ota_crypto.o

ifdef CONFIG_MACH_MSM8974_HAMMERHEAD_STRICT_ALIASING
CFLAGS_qcrypto.o := -fno-strict-aliasing
endif

