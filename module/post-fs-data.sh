#!/system/bin/sh
MODDIR=${0%/*}

# Set correct SELinux context on config file
if [ -f "$MODDIR/system/vendor/etc/vivo_config.ini" ]; then
    chcon u:object_r:vendor_configs_file:s0 "$MODDIR/system/vendor/etc/vivo_config.ini"
fi
if [ -f "$MODDIR/vendor/etc/vivo_config.ini" ]; then
    chcon u:object_r:vendor_configs_file:s0 "$MODDIR/vendor/etc/vivo_config.ini"
fi

# Fallback in-memory bind mount if overlay is delayed
if [ -f "$MODDIR/vendor/etc/vivo_config.ini" ]; then
    mount -o bind "$MODDIR/vendor/etc/vivo_config.ini" /vendor/etc/vivo_config.ini 2>/dev/null
fi

# Reset properties early before Zygote and system_server read them
resetprop -n ro.launcher.blur.appLaunch 1
resetprop -n ro.surface_flinger.supports_background_blur 1
resetprop -n persist.sys.one_shot_blur_enabled true
resetprop -n debug.blur.enable true
resetprop -n persist.blur.GPU.enable true
resetprop -n persist.debug.systemeffect.switch true
resetprop -n persist.debug.systemeffect.enable true
resetprop -n persist.debug.pertexteffect.switch true
resetprop -n persist.debug.BorderHighLightEffect.isG2 true
resetprop -n persist.debug.blurlevel_4 true
