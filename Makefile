KMODULE_NAME = ssv6x5x

ARCH ?= arm
KSRC ?= $(HOME)/firmware/output/build/linux-custom
CROSS_COMPILE ?= $(HOME)/firmware/output/per-package/linux/host/opt/ext-toolchain/bin/arm-linux-

KBUILD_TOP ?= $(PWD)
SSV_DRV_PATH ?= $(PWD)

include $(KBUILD_TOP)/config.mak

EXTRA_CFLAGS := -I$(KBUILD_TOP) -I$(KBUILD_TOP)/include

#------------------------------
# ssvdevice/
KERN_SRCS := ssvdevice/ssvdevice.c
KERN_SRCS += ssvdevice/init.c
KERN_SRCS += ssvdevice/debugfs_cmd.c
KERN_SRCS += ssvdevice/rftool/ssv_phy_rf.c
KERN_SRCS += ssvdevice/ssv_custom_func.c
KERN_SRCS += ssvdevice/rftool/ssv_efuse.c
KERN_SRCS += ssvdevice/ssv_version.c

# KERN_SRCS += hwif/common/common.c
KERN_SRCS += hwif/hwif.c
ifneq ($(CONFIG_HWIF_SUPPORT),2)
KERN_SRCS += hwif/usb/usb.c
endif
ifneq ($(CONFIG_HWIF_SUPPORT),1)
KERN_SRCS += hwif/sdio/sdio.c
endif

KERN_SRCS += hci/ssv_hci.c

KERN_SRCS += utils/debugfs.c
KERN_SRCS += utils/ssv_netlink_ctl.c

ifeq ($(CONFIG_WPA_SUPPLICANT_CTL),y)
KERN_SRCS += utils/ssv_wpas_ctl.c
endif

KERN_SRCS += utils/ssv_alloc_skb.c

#.fmac/
KERN_SRCS += fmac/cfg_ops.c
KERN_SRCS += fmac/fmac.c
KERN_SRCS += fmac/fmac_mod_params.c
KERN_SRCS += fmac/fmac_cmds.c
KERN_SRCS += fmac/fmac_msg_tx.c
KERN_SRCS += fmac/fmac_msg_rx.c
KERN_SRCS += fmac/fmac_utils.c
KERN_SRCS += fmac/fmac_strs.c
KERN_SRCS += fmac/fmac_tx.c
KERN_SRCS += fmac/fmac_rx.c
KERN_SRCS += fmac/ipc_host.c
KERN_SRCS += fmac/netdev_ops.c

KERN_SRCS += ssvdevice/rftool/ssv_rftool.c
KERN_SRCS += ssvdevice/rftool/ssv_rftool_msg.c

# nimble/
KERN_SRCS += ble/nimble/nimble.c
KERN_SRCS += ble/nimble/nimble_msg.c

ifeq ($(CONFIG_FMAC_BRIDGE),y)
KERN_SRCS += fmac/fmac_bridge.c
endif

# ble-hci/
ifeq ($(CONFIG_BLE),y)
KERN_SRCS += ble/ble_hci/ble_hci.c
KERN_SRCS += ble/ble_hci/ble_hci_msg.c
ifneq ($(CONFIG_BLE_USE_LL_ONLY),y)
KERN_SRCS += ble/ble_hci/hcidev_ops.c
endif
endif

#------------------------------
KERN_SRCS += $(KMODULE_NAME)-generic-wlan.c

$(KMODULE_NAME)-y += $(KERN_SRCS_S:.S=.o)
$(KMODULE_NAME)-y += $(KERN_SRCS:.c=.o)

obj-$(CONFIG_SSV6X5X) += $(KMODULE_NAME).o

ifeq ($(CONFIG_PRE_ALLOC_SKB),2)
	KMODULE_PRE_ALLOCATE_NAME = pre-allocate
	PRE_ALLOC_SRCS += utils/pre_alloc_skb.c
	PRE_ALLOC_SRCS += utils/pre_allocate.c
	$(KMODULE_PRE_ALLOCATE_NAME)-y += $(PRE_ALLOC_SRCS:.c=.o)
	obj-$(CONFIG_SSV6X5X) += $(KMODULE_PRE_ALLOCATE_NAME).o
else
	ifeq ($(CONFIG_PRE_ALLOC_SKB),1)
		KERN_SRCS += utils/pre_alloc_skb.c
		KERN_SRCS += utils/pre_allocate.c
	endif
endif

all: modules

modules:
	$(MAKE) -C $(KSRC) M=$(SSV_DRV_PATH) ARCH=$(ARCH) CROSS_COMPILE=$(CROSS_COMPILE) modules

strip:
	$(CROSS_COMPILE)strip $(KMODULE_NAME).ko --strip-unneeded

clean:
	$(MAKE) -C $(KSRC) M=$(SSV_DRV_PATH) ARCH=$(ARCH) CROSS_COMPILE=$(CROSS_COMPILE) clean
