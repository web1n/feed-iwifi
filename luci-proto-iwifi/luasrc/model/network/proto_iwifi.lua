local proto = luci.model.network:register_protocol("iwifi")

function proto.get_i18n(_)
    return luci.i18n.translate("Hebei Unicom iWiFi Client")
end

function proto.opkg_package(_)
    return "iwifi"
end

function proto.is_installed(_)
    return nixio.fs.access("/lib/netifd/proto/iwifi.sh")
end
