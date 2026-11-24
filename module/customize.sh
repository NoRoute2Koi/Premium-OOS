#!/system/bin/sh

ui_print "- Installing Premium OriginOS (Universal)"

# Locate BusyBox across KernelSU, APatch, and Magisk
BB=""
for b in /data/adb/ksu/bin/busybox /data/adb/ap/bin/busybox /data/adb/magisk/busybox "$(command -v busybox 2>/dev/null)"; do
    if [ -x "$b" ]; then
        BB="$b"
        break
    fi
done

wait_for_vol_key() {
    while true; do
        EVENT=$(getevent -lqc 1 2>/dev/null)
        if echo "$EVENT" | grep -q "KEY_VOLUMEUP.*DOWN"; then
            return 0
        elif echo "$EVENT" | grep -q "KEY_VOLUMEDOWN.*DOWN"; then
            return 1
        fi
    done
}

# 1. Extract true factory /vendor/etc/vivo_config.ini (bypassing active module mounts)
STOCK_OUT="$MODPATH/stock_vivo_config.ini"
if [ -n "$BB" ]; then
    "$BB" unshare -m "$BB" sh -c "
        '$BB' mount --make-rprivate / 2>/dev/null
        '$BB' umount -l /vendor/etc/vivo_config.ini 2>/dev/null
        cat /vendor/etc/vivo_config.ini 2>/dev/null
    " > "$STOCK_OUT" 2>/dev/null
fi

if [ ! -s "$STOCK_OUT" ]; then
    if [ -s "/data/adb/modules/$MODID/stock_vivo_config.ini" ]; then
        cp -f "/data/adb/modules/$MODID/stock_vivo_config.ini" "$STOCK_OUT"
    elif [ -f "/vendor/etc/vivo_config.ini" ]; then
        cp -f "/vendor/etc/vivo_config.ini" "$STOCK_OUT"
    fi
fi

if [ ! -s "$STOCK_OUT" ]; then
    abort "! Error: /vendor/etc/vivo_config.ini not found. Unsupported device."
fi

# 2. Check if premium UI effects are already enabled from the factory
IS_FACTORY_PREMIUM=0
AWK_CMD="${BB:+$BB }awk"
if ! command -v awk >/dev/null 2>&1 && [ -n "$BB" ]; then
    AWK_CMD="$BB awk"
fi

FACTORY_CHECK=$($AWK_CMD '
    BEGIN { sec=""; ss_ver=0; ss_sup=0; se_type=-1; nb_sup=0 }
    /^\[[^]]+\]/ {
        sec = $0
        gsub(/^\[|\][ \t\r]*$/, "", sec)
        next
    }
    /=/ {
        line = $0
        gsub(/\r/, "", line)
        split(line, a, "=")
        k = a[1]; gsub(/^[ \t]+|[ \t]+$/, "", k)
        v = a[2]; gsub(/^[ \t]+|[ \t]+$/, "", v)
        if (sec == "vivo.software.spacesystem") {
            if (k == "version" && v + 0 >= 2) ss_ver = 1
            if (k == "vivo-support" && v == "1") ss_sup = 1
        } else if (sec == "vivo.software.systemeffect") {
            if (k == "system_effect_type" && v == "0") se_type = 0
        } else if (sec == "vivo.software.nativeblur") {
            if (k == "vivo-support" && v == "1") nb_sup = 1
        }
    }
    END {
        if ((ss_ver && ss_sup) || (se_type == 0 && nb_sup == 1)) print "1"
        else print "0"
    }
' "$STOCK_OUT" 2>/dev/null)

if [ "$FACTORY_CHECK" = "1" ]; then
    ui_print "!"
    ui_print "! WARNING: Premium UI effects are ALREADY supported"
    ui_print "! from the factory on this device!"
    ui_print "!"
    ui_print "! Press [Volume +] to continue installation anyway"
    ui_print "! Press [Volume -] to abort installation"
    ui_print "!"
    if wait_for_vol_key; then
        ui_print "- Continuing installation by user choice..."
    else
        abort "! Installation cancelled by user."
    fi
fi

# 3. Optimization profile selection
PROFILE="high"
ui_print ""
ui_print "- Select Optimization Profile:"
ui_print "  1. High   - Full flagship blur (radius 24, Dual Kawase, GPU 70)"
ui_print "  2. Medium - Balanced blur (radius 16, Dual Kawase, GPU 60)"
ui_print "  3. Lite   - Minimal blur / matte tint (radius 8, max FPS, all other effects kept)"
ui_print ""
ui_print "  Current selection: [High]"
ui_print "  Press [Volume +] to confirm, [Volume -] to switch"

while true; do
    if wait_for_vol_key; then
        break
    else
        case "$PROFILE" in
            high)   PROFILE="medium"; ui_print "  Selected: [Medium] (Vol+ confirm / Vol- switch)" ;;
            medium) PROFILE="lite";   ui_print "  Selected: [Lite] (Vol+ confirm / Vol- switch)" ;;
            lite)   PROFILE="high";   ui_print "  Selected: [High] (Vol+ confirm / Vol- switch)" ;;
        esac
    fi
done

ui_print "- Applying profile: $PROFILE"
echo "PROFILE=$PROFILE" > "$MODPATH/profile.conf"

# 4. Dynamically patch vivo_config.ini for this device
ui_print "- Patching /vendor/etc/vivo_config.ini dynamically..."
sh "$MODPATH/patch_config.sh" "$STOCK_OUT" "$MODPATH/system/vendor/etc/vivo_config.ini" "$PROFILE" || abort "! Failed to patch vivo_config.ini"

# 5. Set permissions
set_perm_recursive "$MODPATH" 0 0 0755 0644
set_perm "$MODPATH/action.sh" 0 0 0755
set_perm "$MODPATH/patch_config.sh" 0 0 0755
set_perm "$MODPATH/post-fs-data.sh" 0 0 0755
set_perm "$MODPATH/service.sh" 0 0 0755
set_perm "$MODPATH/uninstall.sh" 0 0 0755

# 6. Temproot / live update support
if $BOOTMODE && echo "$MODPATH" | grep -q "modules_update"; then
    ui_print "- Live update detected: syncing to active modules..."
    REAL_MODPATH="/data/adb/modules/$MODID"
    grep "modules/$MODID" /proc/mounts 2>/dev/null | cut -d' ' -f2 | while read -r mnt; do
        umount -l "$mnt" 2>/dev/null || true
    done
    mkdir -p "$REAL_MODPATH"
    cp -af "$MODPATH/." "$REAL_MODPATH/"
    rm -f "$REAL_MODPATH/update"
    rm -f "$REAL_MODPATH/customize.sh"
    set_perm_recursive "$REAL_MODPATH" 0 0 0755 0644
    set_perm "$REAL_MODPATH/action.sh" 0 0 0755
    set_perm "$REAL_MODPATH/patch_config.sh" 0 0 0755
    set_perm "$REAL_MODPATH/post-fs-data.sh" 0 0 0755
    set_perm "$REAL_MODPATH/service.sh" 0 0 0755
    set_perm "$REAL_MODPATH/uninstall.sh" 0 0 0755
    ui_print "- Module active and updated without reboot"
fi
