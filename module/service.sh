#!/system/bin/sh
MODDIR=${0%/*}

# Wait until system boot is completed
until [ "$(getprop sys.boot_completed)" = "1" ]; do
    sleep 2
done

# Ensure in-memory bind mount is active
if [ -f "$MODDIR/vendor/etc/vivo_config.ini" ]; then
    mount -o bind "$MODDIR/vendor/etc/vivo_config.ini" /vendor/etc/vivo_config.ini 2>/dev/null
fi

# Enable realtime blur in settings providers
settings put system realtime_blur_state 1
settings put secure realtime_blur_state 1
settings put global realtime_blur_state 1
settings put system reduced_dynamic_effects 0
settings put global disable_window_blurs 0

# Re-assert properties in case any service overrode them
resetprop -n ro.launcher.blur.appLaunch 1
resetprop -n persist.sys.one_shot_blur_enabled true
resetprop -n debug.blur.enable true
resetprop -n persist.debug.systemeffect.switch true
resetprop -n persist.debug.systemeffect.enable true
resetprop -n ro.vendor.vivo.software.spacesystem:version 3
resetprop -n ro.vendor.vivo.software.spacesystem:vivo-support 1
resetprop -n ro.vendor.vivo.software.nativeblur:vivo-support 1
resetprop -n ro.vendor.vivo.software.motionblur:vivo-support 1
