#!/system/bin/sh
MODDIR=${0%/*}

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
