#!/system/bin/sh
MODDIR=${0%/*}

# Ensure root tools are in PATH
export PATH="/data/adb/ksu/bin:/data/adb/ap/bin:/data/adb/magisk:$PATH"

# Set correct SELinux context on patched config file
if [ -f "$MODDIR/system/vendor/etc/vivo_config.ini" ]; then
    chcon u:object_r:vendor_configs_file:s0 "$MODDIR/system/vendor/etc/vivo_config.ini"
fi

# Read active profile
PROFILE="high"
if [ -f "$MODDIR/profile.conf" ]; then
    . "$MODDIR/profile.conf"
fi

case "$PROFILE" in
    medium)
        RADIUS_TEMP=16
        GPU_MIN=60
        GPU_DUR=800
        ;;
    lite)
        RADIUS_TEMP=8
        GPU_MIN=50
        GPU_DUR=600
        ;;
    *)
        RADIUS_TEMP=24
        GPU_MIN=70
        GPU_DUR=1000
        ;;
esac

# Capability flags
resetprop -n ro.launcher.blur.appLaunch 1
resetprop -n ro.surface_flinger.supports_background_blur 1

# Dual Kawase & Notification Shade Performance Optimization
resetprop -p persist.debug.blurlevel_4 false
resetprop -p persist.debug.qs_enable_hardware_optimize true
resetprop -n debug.blur.dynamic.frameRate true
resetprop -n debug.hwui.vivo_blur_dualKawase true
resetprop -n debug.hwui.vivo_blur_opt true
resetprop -p persist.blur.GPU.enable true
resetprop -p persist.blur.GPU.minlevel "$GPU_MIN"
resetprop -p persist.blur.GPU.duration "$GPU_DUR"

# Spacesystem and blur HAL properties
resetprop -n ro.vendor.vivo.software.spacesystem 1
resetprop -n ro.vendor.vivo.software.spacesystem:level 1
resetprop -n ro.vendor.vivo.software.spacesystem:version 3
resetprop -n ro.vendor.vivo.software.spacesystem:vivo-support 1
resetprop -n ro.vendor.vivo.software.spacesystem:is_support_zygote 1

resetprop -n ro.vendor.vivo.software.spacesystem.borderlight 1
resetprop -n ro.vendor.vivo.software.spacesystem.borderlight:version 3
resetprop -n ro.vendor.vivo.software.spacesystem.borderlight:vivo-support 1
resetprop -n ro.vendor.vivo.software.spacesystem.borderlight:is_support_zygote 1

resetprop -n ro.vendor.vivo.software.nativeblur 1
resetprop -n ro.vendor.vivo.software.nativeblur:vivo-support 1
resetprop -n ro.vendor.vivo.software.nativeblur:is_support_zygote 1

resetprop -n ro.vendor.vivo.software.motionblur 1
resetprop -n ro.vendor.vivo.software.motionblur:vivo-support 1
resetprop -n ro.vendor.vivo.software.motionblur:is_support_zygote 1

resetprop -n ro.vendor.vivo.software.asyncanimboost 1
resetprop -n ro.vendor.vivo.software.asyncanimboost:vivo-support 1
resetprop -n ro.vendor.vivo.software.asyncanimboost:is_support_zygote 1

resetprop -n ro.vendor.vivo.software.realtimeblur 1
resetprop -n ro.vendor.vivo.software.realtimeblur:vivo-support 1
resetprop -n ro.vendor.vivo.software.realtimeblur:is_support_zygote 1

resetprop -n ro.vendor.vivo.software.vglasseffect 1
resetprop -n ro.vendor.vivo.software.vglasseffect:vivo-support 1
resetprop -n ro.vendor.vivo.software.vglasseffect:is_support_zygote 1

resetprop -n ro.vendor.vivo.software.windowdeformblur 1
resetprop -n ro.vendor.vivo.software.windowdeformblur:support_blur 1
resetprop -n ro.vendor.vivo.software.windowdeformblur:min_blur_radius 8
resetprop -n ro.vendor.vivo.software.windowdeformblur:min_blur_radius_temp "$RADIUS_TEMP"
resetprop -n ro.vendor.vivo.software.windowdeformblur:vivo-support 1
resetprop -n ro.vendor.vivo.software.windowdeformblur:is_support_zygote 1

resetprop -n ro.vendor.vivo.software.systemeffect 1
resetprop -n ro.vendor.vivo.software.systemeffect:system_effect_type 0
resetprop -n ro.vendor.vivo.software.systemeffect:vivo-support 1
resetprop -n ro.vendor.vivo.software.systemeffect:is_support_zygote 1
