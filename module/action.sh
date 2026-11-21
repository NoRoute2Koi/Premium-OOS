#!/system/bin/sh
MODDIR=${0%/*}

echo "Applying Premium OriginOS changes..."

# Ensure correct SELinux context
chcon u:object_r:vendor_configs_file:s0 "$MODDIR/vendor/etc/vivo_config.ini" 2>/dev/null
chcon u:object_r:vendor_configs_file:s0 "$MODDIR/system/vendor/etc/vivo_config.ini" 2>/dev/null

# Ensure in-memory bind mount is active
mount -o bind "$MODDIR/vendor/etc/vivo_config.ini" /vendor/etc/vivo_config.ini 2>/dev/null

# Kill Vivo ConfigStore HAL daemon to force re-parsing config
killall -9 vendor.vivo.hardware.configstore@1.0-service 2>/dev/null
sleep 1

# Soft reboot Zygote to apply spacesystem mode in system_server
echo "Restarting Zygote..."
setprop ctl.restart zygote
