#!/system/bin/sh

ui_print "- Installing Premium OriginOS"

# Set permissions
set_perm_recursive "$MODPATH" 0 0 0755 0644
set_perm "$MODPATH/action.sh" 0 0 0755
set_perm "$MODPATH/post-fs-data.sh" 0 0 0755
set_perm "$MODPATH/service.sh" 0 0 0755
set_perm "$MODPATH/uninstall.sh" 0 0 0755

# Temproot / live update support:
# If installed via KernelSU Manager into modules_update, directly sync into active modules directory
# so the module appears immediately in KernelSU Manager without requiring a hardware reboot.
if $BOOTMODE && echo "$MODPATH" | grep -q "modules_update"; then
    ui_print "- Live update detected: syncing to active modules..."
    REAL_MODPATH="/data/adb/modules/$MODID"
    # Safely unmount any legacy mounts on previous module files
    grep "modules/$MODID" /proc/mounts 2>/dev/null | cut -d' ' -f2 | while read -r mnt; do
        umount -l "$mnt" 2>/dev/null || true
    done
    mkdir -p "$REAL_MODPATH"
    cp -af "$MODPATH/." "$REAL_MODPATH/"
    rm -f "$REAL_MODPATH/update"
    rm -f "$REAL_MODPATH/customize.sh"
    set_perm_recursive "$REAL_MODPATH" 0 0 0755 0644
    set_perm "$REAL_MODPATH/action.sh" 0 0 0755
    set_perm "$REAL_MODPATH/post-fs-data.sh" 0 0 0755
    set_perm "$REAL_MODPATH/service.sh" 0 0 0755
    set_perm "$REAL_MODPATH/uninstall.sh" 0 0 0755
    ui_print "- Module active and updated without reboot"
fi
