include $(TOPDIR)/rules.mk

PKG_NAME:=rtl8188eu
PKG_RELEASE=1

PKG_SOURCE_URL:=https://github.com/pritam-singh-db/rtl8188eu.git
PKG_SOURCE_PROTO:=git
PKG_SOURCE_DATE:=2025-12-11
PKG_SOURCE_VERSION:=857b0876a45eb55b467336b61014773ceb2ac373
PKG_MIRROR_HASH:=skip

PKG_BUILD_PARALLEL:=1

STAMP_CONFIGURED_DEPENDS := $(STAGING_DIR)/usr/include/mac80211-backport/backport/autoconf.h

include $(INCLUDE_DIR)/kernel.mk
include $(INCLUDE_DIR)/package.mk

define KernelPackage/rtl8188eu
  SUBMENU:=Wireless Drivers
  TITLE:=Driver for RTL8188EU Wireless Chipsets
  DEPENDS:= +kmod-cfg80211 +rtl8188eu-firmware +kmod-usb-core +kmod-mac80211 +@DRIVER_11N_SUPPORT
  FILES:=$(PKG_BUILD_DIR)/8188eu.ko
  AUTOLOAD:=$(call AutoProbe,8188eu)
  PROVIDES:=kmod-rtl8188eu
endef

define KernelPackage/rtl8188eu/description
	Realtek RTL8188EU USB WiFi driver
endef

BACKPORT_DIR:=$(STAGING_DIR)/usr/include/mac80211-backport

NOSTDINC_FLAGS := \
	$(KERNEL_NOSTDINC_FLAGS) \
	-I$(PKG_BUILD_DIR)/include \
	-I$(BACKPORT_DIR) \
	-I$(BACKPORT_DIR)/uapi \
	-I$(STAGING_DIR)/usr/include/mac80211 \
	-I$(STAGING_DIR)/usr/include/mac80211/uapi \
	-include backport/backport.h

CT_MAKEDEFS += CONFIG_RTL8188EU=m

EXTRA_CFLAGS:= \
  -DCONFIG_IOCTL_CFG80211 \
  -DRTW_USE_CFG80211_STA_EVENT \
  -D_LINUX_BYTEORDER_SWAB_H \
  -DCONFIG_RADIO_WORK \
  -DCONFIG_POWER_SAVING=0 \
  -DBUILD_OPENWRT

ifeq ($(CONFIG_BIG_ENDIAN),y)
	EXTRA_CFLAGS += -DCONFIG_BIG_ENDIAN
else
	EXTRA_CFLAGS += -DCONFIG_LITTLE_ENDIAN
endif

define Build/Compile
	+$(KERNEL_MAKE) $(PKG_JOBS) \
		M="$(PKG_BUILD_DIR)" \
		NOSTDINC_FLAGS="$(NOSTDINC_FLAGS)" \
		USER_EXTRA_CFLAGS="$(EXTRA_CFLAGS)" \
		$(CT_MAKEDEFS) modules

endef

$(eval $(call KernelPackage,rtl8188eu))
