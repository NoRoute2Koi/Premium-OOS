#!/system/bin/sh
MODDIR=${0%/*}

# Unmount in-memory overlays to release busy inodes
umount -l /vendor/etc/vivo_config.ini 2>/dev/null

# Reload stock config in Vivo ConfigStore HAL daemon
killall -9 vendor.vivo.hardware.configstore@1.0-service 2>/dev/null
