#!/system/bin/sh
MODDIR=${0%/*}

export PATH="/data/adb/ksu/bin:/data/adb/ap/bin:/data/adb/magisk:$PATH"

echo "Applying Premium OriginOS changes..."

# Ensure correct SELinux context
chcon u:object_r:vendor_configs_file:s0 "$MODDIR/system/vendor/etc/vivo_config.ini" 2>/dev/null

# Ensure in-memory bind mount is active (fallback only if manager overlay is inactive)
if [ -f "$MODDIR/system/vendor/etc/vivo_config.ini" ]; then
    if ! grep -q "vivo.software.spacesystem" /vendor/etc/vivo_config.ini 2>/dev/null; then
        mount -o bind "$MODDIR/system/vendor/etc/vivo_config.ini" /vendor/etc/vivo_config.ini 2>/dev/null
    fi
fi

# Kill Vivo ConfigStore HAL daemon to force re-parsing config
killall -9 vendor.vivo.hardware.configstore@1.0-service 2>/dev/null
sleep 1

# Soft reboot Zygote to apply changes in system_server
echo "Restarting Zygote..."
setprop ctl.restart zygote
