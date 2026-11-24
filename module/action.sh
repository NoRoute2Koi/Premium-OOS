#!/system/bin/sh
MODDIR=${0%/*}

export PATH="/data/adb/ksu/bin:/data/adb/ap/bin:/data/adb/magisk:$PATH"

# Cycle active profile: high -> medium -> lite -> high
CURRENT_PROFILE="high"
if [ -f "$MODDIR/profile.conf" ]; then
    . "$MODDIR/profile.conf"
    CURRENT_PROFILE="${PROFILE:-high}"
fi

case "$CURRENT_PROFILE" in
    high)
        NEXT_PROFILE="medium"
        RADIUS_TEMP=16
        GPU_MIN=60
        GPU_DUR=800
        ;;
    medium)
        NEXT_PROFILE="lite"
        RADIUS_TEMP=8
        GPU_MIN=50
        GPU_DUR=600
        ;;
    *)
        NEXT_PROFILE="high"
        RADIUS_TEMP=24
        GPU_MIN=70
        GPU_DUR=1000
        ;;
esac

echo "Switching Premium OriginOS profile: $CURRENT_PROFILE -> $NEXT_PROFILE"
echo "PROFILE=$NEXT_PROFILE" > "$MODDIR/profile.conf"

# Re-patch vivo_config.ini from saved stock backup
if [ -f "$MODDIR/stock_vivo_config.ini" ] && [ -f "$MODDIR/patch_config.sh" ]; then
    sh "$MODDIR/patch_config.sh" "$MODDIR/stock_vivo_config.ini" "$MODDIR/system/vendor/etc/vivo_config.ini" "$NEXT_PROFILE"
fi

# Ensure correct SELinux context
chcon u:object_r:vendor_configs_file:s0 "$MODDIR/system/vendor/etc/vivo_config.ini" 2>/dev/null

# Ensure in-memory bind mount is active (fallback only if manager overlay is inactive)
if [ -f "$MODDIR/system/vendor/etc/vivo_config.ini" ]; then
    if ! grep -q "vivo.software.spacesystem" /vendor/etc/vivo_config.ini 2>/dev/null; then
        mount -o bind "$MODDIR/system/vendor/etc/vivo_config.ini" /vendor/etc/vivo_config.ini 2>/dev/null
    fi
fi

# Update properties
setprop debug.hwui.vivo_blur_dualKawase true 2>/dev/null
setprop debug.hwui.vivo_blur_opt true 2>/dev/null
setprop debug.blur.dynamic.frameRate true 2>/dev/null
resetprop -p persist.debug.blurlevel_4 false 2>/dev/null
resetprop -p persist.debug.qs_enable_hardware_optimize true 2>/dev/null
resetprop -p persist.blur.GPU.minlevel "$GPU_MIN" 2>/dev/null
resetprop -p persist.blur.GPU.duration "$GPU_DUR" 2>/dev/null
resetprop -n ro.vendor.vivo.software.windowdeformblur:min_blur_radius_temp "$RADIUS_TEMP" 2>/dev/null

# Kill Vivo ConfigStore HAL daemon to force re-parsing config
killall -9 vendor.vivo.hardware.configstore@1.0-service 2>/dev/null
sleep 1

# Soft reboot Zygote to apply changes in system_server
echo "Restarting Zygote..."
setprop ctl.restart zygote
