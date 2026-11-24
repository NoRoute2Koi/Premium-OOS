#!/system/bin/sh
MODDIR=${0%/*}

export PATH="/data/adb/ksu/bin:/data/adb/ap/bin:/data/adb/magisk:$PATH"

# Wait until system boot is completed
until [ "$(getprop sys.boot_completed)" = "1" ]; do
    sleep 2
done

# Ensure in-memory bind mount is active (fallback only if manager overlay is inactive)
if [ -f "$MODDIR/system/vendor/etc/vivo_config.ini" ]; then
    if ! grep -q "vivo.software.spacesystem" /vendor/etc/vivo_config.ini 2>/dev/null; then
        mount -o bind "$MODDIR/system/vendor/etc/vivo_config.ini" /vendor/etc/vivo_config.ini 2>/dev/null
    fi
fi

# Re-enforce Dual Kawase and active profile GPU settings after boot
PROFILE="high"
if [ -f "$MODDIR/profile.conf" ]; then
    . "$MODDIR/profile.conf"
fi

case "$PROFILE" in
    medium)
        GPU_MIN=60
        GPU_DUR=800
        ;;
    lite)
        GPU_MIN=50
        GPU_DUR=600
        ;;
    *)
        GPU_MIN=70
        GPU_DUR=1000
        ;;
esac

setprop debug.hwui.vivo_blur_dualKawase true 2>/dev/null
setprop debug.hwui.vivo_blur_opt true 2>/dev/null
setprop debug.blur.dynamic.frameRate true 2>/dev/null
resetprop -p persist.debug.blurlevel_4 false 2>/dev/null
resetprop -p persist.debug.qs_enable_hardware_optimize true 2>/dev/null
resetprop -p persist.blur.GPU.minlevel "$GPU_MIN" 2>/dev/null
resetprop -p persist.blur.GPU.duration "$GPU_DUR" 2>/dev/null
