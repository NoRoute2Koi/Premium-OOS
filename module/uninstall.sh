#!/system/bin/sh
MODDIR=${0%/*}

# 1. Unmount in-memory overlays to release busy inodes
grep -E "premium|vivo_config" /proc/mounts 2>/dev/null | cut -d' ' -f2 | while read -r mnt; do
    umount -l "$mnt" 2>/dev/null || true
done

# 2. Reload stock config in Vivo ConfigStore HAL daemon
killall -9 vendor.vivo.hardware.configstore@1.0-service 2>/dev/null

# 3. Clean up injected system and persistent properties
resetprop -d ro.launcher.blur.appLaunch 2>/dev/null
resetprop -d ro.surface_flinger.supports_background_blur 2>/dev/null

resetprop -p -d persist.sys.one_shot_blur_enabled 2>/dev/null
resetprop -p -d persist.blur.GPU.enable 2>/dev/null
resetprop -p -d persist.blur.GPU.minlevel 2>/dev/null
resetprop -p -d persist.blur.GPU.duration 2>/dev/null
resetprop -p -d persist.debug.systemeffect.switch 2>/dev/null
resetprop -p -d persist.debug.systemeffect.enable 2>/dev/null
resetprop -p -d persist.debug.pertexteffect.switch 2>/dev/null
resetprop -p -d persist.debug.BorderHighLightEffect.isG2 2>/dev/null
resetprop -p -d persist.debug.blurlevel_4 2>/dev/null
resetprop -p -d persist.debug.qs_enable_hardware_optimize 2>/dev/null

resetprop -d debug.blur.enable 2>/dev/null
resetprop -d debug.blur.dynamic.frameRate 2>/dev/null
resetprop -d debug.hwui.vivo_blur_dualKawase 2>/dev/null
resetprop -d debug.hwui.vivo_blur_opt 2>/dev/null

# 4. Remove injected spacesystem and blur HAL properties
resetprop -d ro.vendor.vivo.software.spacesystem 2>/dev/null
resetprop -d ro.vendor.vivo.software.spacesystem:level 2>/dev/null
resetprop -d ro.vendor.vivo.software.spacesystem:version 2>/dev/null
resetprop -d ro.vendor.vivo.software.spacesystem:vivo-support 2>/dev/null
resetprop -d ro.vendor.vivo.software.spacesystem:is_support_zygote 2>/dev/null

resetprop -d ro.vendor.vivo.software.spacesystem.borderlight 2>/dev/null
resetprop -d ro.vendor.vivo.software.spacesystem.borderlight:version 2>/dev/null
resetprop -d ro.vendor.vivo.software.spacesystem.borderlight:vivo-support 2>/dev/null
resetprop -d ro.vendor.vivo.software.spacesystem.borderlight:is_support_zygote 2>/dev/null

resetprop -d ro.vendor.vivo.software.nativeblur 2>/dev/null
resetprop -d ro.vendor.vivo.software.nativeblur:vivo-support 2>/dev/null
resetprop -d ro.vendor.vivo.software.nativeblur:is_support_zygote 2>/dev/null

resetprop -d ro.vendor.vivo.software.motionblur 2>/dev/null
resetprop -d ro.vendor.vivo.software.motionblur:vivo-support 2>/dev/null
resetprop -d ro.vendor.vivo.software.motionblur:is_support_zygote 2>/dev/null

resetprop -d ro.vendor.vivo.software.asyncanimboost 2>/dev/null
resetprop -d ro.vendor.vivo.software.asyncanimboost:vivo-support 2>/dev/null
resetprop -d ro.vendor.vivo.software.asyncanimboost:is_support_zygote 2>/dev/null

resetprop -d ro.vendor.vivo.software.realtimeblur 2>/dev/null
resetprop -d ro.vendor.vivo.software.realtimeblur:vivo-support 2>/dev/null
resetprop -d ro.vendor.vivo.software.realtimeblur:is_support_zygote 2>/dev/null

resetprop -d ro.vendor.vivo.software.vglasseffect 2>/dev/null
resetprop -d ro.vendor.vivo.software.vglasseffect:vivo-support 2>/dev/null
resetprop -d ro.vendor.vivo.software.vglasseffect:is_support_zygote 2>/dev/null

resetprop -d ro.vendor.vivo.software.windowdeformblur 2>/dev/null
resetprop -d ro.vendor.vivo.software.windowdeformblur:support_blur 2>/dev/null
resetprop -d ro.vendor.vivo.software.windowdeformblur:min_blur_radius 2>/dev/null
resetprop -d ro.vendor.vivo.software.windowdeformblur:min_blur_radius_temp 2>/dev/null
resetprop -d ro.vendor.vivo.software.windowdeformblur:vivo-support 2>/dev/null
resetprop -d ro.vendor.vivo.software.windowdeformblur:is_support_zygote 2>/dev/null

resetprop -d ro.vendor.vivo.software.systemeffect 2>/dev/null
resetprop -d ro.vendor.vivo.software.systemeffect:system_effect_type 2>/dev/null
resetprop -d ro.vendor.vivo.software.systemeffect:vivo-support 2>/dev/null
resetprop -d ro.vendor.vivo.software.systemeffect:is_support_zygote 2>/dev/null
