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
resetprop -n persist.debug.systemeffect.switch true
resetprop -n persist.debug.systemeffect.enable true
resetprop -n persist.debug.pertexteffect.switch true
resetprop -n persist.debug.BorderHighLightEffect.isG2 true

# Performance Optimization for Snapdragon 7 Gen 3 (Adreno 720)
resetprop -n persist.debug.blurlevel_4 false
resetprop -n debug.blur.dynamic.frameRate true
resetprop -n persist.debug.qs_enable_hardware_optimize true
resetprop -n persist.blur.GPU.enable true
resetprop -n persist.blur.GPU.minlevel 60
resetprop -n persist.blur.GPU.duration 600

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
resetprop -n ro.vendor.vivo.software.windowdeformblur:min_blur_radius_temp 24
resetprop -n ro.vendor.vivo.software.windowdeformblur:vivo-support 1
resetprop -n ro.vendor.vivo.software.windowdeformblur:is_support_zygote 1

resetprop -n ro.vendor.vivo.software.systemeffect 1
resetprop -n ro.vendor.vivo.software.systemeffect:system_effect_type 0
resetprop -n ro.vendor.vivo.software.systemeffect:vivo-support 1
resetprop -n ro.vendor.vivo.software.systemeffect:is_support_zygote 1
