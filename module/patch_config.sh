#!/system/bin/sh
# Dynamically patches a stock vivo_config.ini for any iQOO/Vivo device.
# Usage: patch_config.sh <stock_ini> <output_ini> [high|medium|lite]

STOCK_INI="$1"
OUT_INI="$2"
PROFILE="${3:-high}"

if [ ! -f "$STOCK_INI" ]; then
    echo "Error: stock ini not found at $STOCK_INI" >&2
    exit 1
fi

case "$PROFILE" in
    medium)
        RADIUS_TEMP="16"
        ;;
    lite)
        RADIUS_TEMP="8"
        ;;
    *)
        RADIUS_TEMP="24"
        ;;
esac

AWK_BIN=""
for b in /data/adb/ksu/bin/busybox /data/adb/ap/bin/busybox /data/adb/magisk/busybox "$(command -v busybox 2>/dev/null)"; do
    if [ -x "$b" ]; then
        AWK_BIN="$b awk"
        break
    fi
done
if [ -z "$AWK_BIN" ] && command -v awk >/dev/null 2>&1; then
    AWK_BIN="awk"
fi
if [ -z "$AWK_BIN" ]; then
    echo "Error: awk not found" >&2
    exit 1
fi

OUT_DIR="${OUT_INI%/*}"
mkdir -p "$OUT_DIR"

$AWK_BIN -v radius_temp="$RADIUS_TEMP" '
BEGIN {
    req_sec["vivo.software.nativeblur"] = 1
    kv["vivo.software.nativeblur", "is_support_zygote"] = "1"
    kv["vivo.software.nativeblur", "vivo-support"] = "1"

    req_sec["vivo.software.asyncanimboost"] = 1
    kv["vivo.software.asyncanimboost", "is_support_zygote"] = "1"
    kv["vivo.software.asyncanimboost", "vivo-support"] = "1"

    req_sec["vivo.software.motionblur"] = 1
    kv["vivo.software.motionblur", "is_support_zygote"] = "1"
    kv["vivo.software.motionblur", "vivo-support"] = "1"

    req_sec["vivo.software.windowdeformblur"] = 1
    kv["vivo.software.windowdeformblur", "support_blur"] = "1"
    kv["vivo.software.windowdeformblur", "min_blur_radius"] = "8"
    kv["vivo.software.windowdeformblur", "min_blur_radius_temp"] = radius_temp
    kv["vivo.software.windowdeformblur", "is_support_zygote"] = "1"
    kv["vivo.software.windowdeformblur", "vivo-support"] = "1"

    req_sec["vivo.software.systemeffect"] = 1
    kv["vivo.software.systemeffect", "system_effect_type"] = "0"
    kv["vivo.software.systemeffect", "is_support_zygote"] = "1"
    kv["vivo.software.systemeffect", "vivo-support"] = "1"

    req_sec["vivo.software.spacesystem"] = 1
    kv["vivo.software.spacesystem", "version"] = "3"
    kv["vivo.software.spacesystem", "level"] = "1"
    kv["vivo.software.spacesystem", "is_support_zygote"] = "1"
    kv["vivo.software.spacesystem", "vivo-support"] = "1"

    req_sec["vivo.software.spacesystem.borderlight"] = 1
    kv["vivo.software.spacesystem.borderlight", "version"] = "3"
    kv["vivo.software.spacesystem.borderlight", "is_support_zygote"] = "1"
    kv["vivo.software.spacesystem.borderlight", "vivo-support"] = "1"

    req_sec["vivo.software.vglasseffect"] = 1
    kv["vivo.software.vglasseffect", "is_support_zygote"] = "1"
    kv["vivo.software.vglasseffect", "vivo-support"] = "1"

    req_sec["vivo.software.realtimeblur"] = 1
    kv["vivo.software.realtimeblur", "is_support_zygote"] = "1"
    kv["vivo.software.realtimeblur", "vivo-support"] = "1"

    keys["vivo.software.nativeblur"] = "is_support_zygote vivo-support"
    keys["vivo.software.asyncanimboost"] = "is_support_zygote vivo-support"
    keys["vivo.software.motionblur"] = "is_support_zygote vivo-support"
    keys["vivo.software.windowdeformblur"] = "support_blur min_blur_radius min_blur_radius_temp is_support_zygote vivo-support"
    keys["vivo.software.systemeffect"] = "system_effect_type is_support_zygote vivo-support"
    keys["vivo.software.spacesystem"] = "version level is_support_zygote vivo-support"
    keys["vivo.software.spacesystem.borderlight"] = "version is_support_zygote vivo-support"
    keys["vivo.software.vglasseffect"] = "is_support_zygote vivo-support"
    keys["vivo.software.realtimeblur"] = "is_support_zygote vivo-support"

    sec_order[1] = "vivo.software.nativeblur"
    sec_order[2] = "vivo.software.asyncanimboost"
    sec_order[3] = "vivo.software.motionblur"
    sec_order[4] = "vivo.software.windowdeformblur"
    sec_order[5] = "vivo.software.systemeffect"
    sec_order[6] = "vivo.software.spacesystem"
    sec_order[7] = "vivo.software.spacesystem.borderlight"
    sec_order[8] = "vivo.software.vglasseffect"
    sec_order[9] = "vivo.software.realtimeblur"
    num_secs = 9

    cur_sec = ""
}
function flush_missing_keys(s,    n, arr, i, k) {
    if (!(s in req_sec)) return
    n = split(keys[s], arr, " ")
    for (i = 1; i <= n; i++) {
        k = arr[i]
        if (!((s, k) in seen_key)) {
            print k " = " kv[s, k]
            seen_key[s, k] = 1
        }
    }
}
{
    line = $0
    sub(/\r$/, "", line)
    if (line ~ /^\[[^]]+\][ \t]*$/) {
        if (cur_sec != "") {
            flush_missing_keys(cur_sec)
        }
        cur_sec = line
        gsub(/^\[|\][ \t]*$/, "", cur_sec)
        seen_sec[cur_sec] = 1
        print line
        next
    }
    if ((cur_sec in req_sec) && line ~ /^[ \t]*[A-Za-z0-9_.-]+[ \t]*=/) {
        k = line
        sub(/^[ \t]*/, "", k)
        sub(/[ \t]*=.*$/, "", k)
        if ((cur_sec, k) in kv) {
            if (!((cur_sec, k) in seen_key)) {
                print k " = " kv[cur_sec, k]
                seen_key[cur_sec, k] = 1
            }
            next
        }
    }
    if ((cur_sec in req_sec) && line ~ /^[ \t]*$/) {
        flush_missing_keys(cur_sec)
    }
    print line
}
END {
    if (cur_sec != "") {
        flush_missing_keys(cur_sec)
    }
    for (i = 1; i <= num_secs; i++) {
        s = sec_order[i]
        if (!(s in seen_sec)) {
            print ""
            print "[" s "]"
            flush_missing_keys(s)
        }
    }
}
' "$STOCK_INI" > "${OUT_INI}.tmp" && mv -f "${OUT_INI}.tmp" "$OUT_INI"

chmod 644 "$OUT_INI" 2>/dev/null
chcon u:object_r:vendor_configs_file:s0 "$OUT_INI" 2>/dev/null || true
