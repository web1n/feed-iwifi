#
# Copyright (C) 2022 web1n
#

include $(TOPDIR)/rules.mk

PKG_NAME:=iwifi
PKG_RELEASE:=1
PKG_VERSION:=1

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)

include $(INCLUDE_DIR)/package.mk

define Package/iwifi
	SECTION:=utils
	CATEGORY:=Utilities
	TITLE:=iWiFi
	PKGARCH:=all
	DEPENDS:=+lua +lua-argparse +luci-base +curl
endef

define Build/Compile
	true
endef

define Package/iwifi/install
	$(INSTALL_DIR) $(1)/usr/lib/lua
	$(INSTALL_BIN) ./files/iwifi.lua $(1)/usr/lib/lua/iwifi.lua

	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) ./files/iwifi_service.lua $(1)/usr/sbin/iwifi

	$(INSTALL_DIR) $(1)/lib/netifd
	$(INSTALL_BIN) ./files/iwifi.script $(1)/lib/netifd/iwifi.script

	$(INSTALL_DIR) $(1)/lib/netifd/proto
	$(INSTALL_BIN) ./files/iwifi.sh $(1)/lib/netifd/proto/iwifi.sh
endef

$(eval $(call BuildPackage,iwifi))
