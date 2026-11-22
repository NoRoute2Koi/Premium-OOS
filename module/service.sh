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
