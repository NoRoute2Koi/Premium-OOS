# premium-OOS

KernelSU module to unlock flagship blur, translucency, and premium UI effects on iQOO Z9 (OriginOS 6).

## Overview

On budget and midrange devices such as the iQOO Z9 (Snapdragon 7 Gen 3 / SM7550), OriginOS 6 disables flagship visual effects via configuration tables and framework gates:
- Lockscreen and AOD clock blur, widget blur, and lockscreen deformation shaders are gated by `ActivityTaskManagerService` space system mode (`ssMode`). If mode is 0 (`?spacesystem`), `VivoDreamClockApp` completely disables blur shaders.
- The window manager only activates `ssMode = 2` if `FtFeature.getFeatureAttribute("vivo.software.spacesystem", "version", "0") >= 2` during `system_server` boot.
- The vendor ConfigStore HAL (`vendor.vivo.hardware.configstore@1.0-service`) requires both `vivo-support = 1` and `is_support_zygote = 1` in `vivo_config.ini`. If `vivo-support` is absent, the HAL drops feature lookups and returns default `0`.
- SystemUI measures device tier via `SystemPropertiesFacade.getPerformanceLevel()`. Without `vivo.software.nativeblur` and Space System v2+, performance level defaults to 40 (low performance), disabling deformation and window blur transitions.
- App opening and closing background deformation blur is disabled (`support_blur=0` in vendor config, `ro.launcher.blur.appLaunch=0`).
- System effect profile defaults to Lite (`system_effect_type=1` instead of `0`).

This module patches configuration in-memory via KernelSU overlay mounts and runtime property injection without modifying physical partitions or altering AVB hashes.

## Features

- Unlock lockscreen and AOD clock blur and widget blur shaders.
- Unlock app launch and exit background deformation blur in launcher.
- Activate Space System v3 level 1 blur pipeline (`spacesystem` mode 2).
- Switch system effect profile from Lite (`1`) to Full (`0`).
- Enable native blur, motion blur, and V-Glass translucency.
- Retain temporary root (temproot) safety with zero physical disk modifications.
- Manager Action button support to trigger soft reload without changing `realtime_blur_state`.
- Clean unmount on module removal via `uninstall.sh` preventing resource busy errors.
- Tailored performance tuning for Snapdragon 7 Gen 3 (Adreno 720) on 1.5K display resolution.

## Performance Tuning for iQOO Z9

To prevent micro-stutters and frame drops on Adreno 720:
- **Deformation Blur Radius**: Scaled from 44 down to balanced 24 (`min_blur_radius_temp = 24`), halving GPU texture sampling overhead while preserving soft visual aesthetics.
- **Dynamic Blur Frame Rate**: Enabled `debug.blur.dynamic.frameRate=true` allowing blur sessions to update asynchronously (60-90 fps) while window translations stay at 120/144 fps.
- **Gradient Pass Optimization**: Disabled heavy `blurlevel_4` gradient passes (`persist.debug.blurlevel_4=false`) to eliminate fillrate bottlenecks.
- **Quick Settings Optimization**: Enabled `persist.debug.qs_enable_hardware_optimize=true` for control center rendering.
- **GPU Boost Floor**: Set `persist.blur.GPU.minlevel=60` and duration to 600ms to maintain GPU clocks during transition animations.

## Technical Architecture

1. `vendor/etc/vivo_config.ini`:
   - Configures `[vivo.software.spacesystem]`, `[vivo.software.spacesystem.borderlight]`, `[vivo.software.nativeblur]`, `[vivo.software.motionblur]`, `[vivo.software.asyncanimboost]`, `[vivo.software.vglasseffect]`, `[vivo.software.realtimeblur]`, and optimized `[vivo.software.windowdeformblur]`.
   - Injects `vivo-support = 1` and `is_support_zygote = 1` across all target sections so the HAL exports them to Zygote and System Server.
2. `system.prop`:
   - Pre-seeds `ro.vendor.vivo.software.*` properties at early init to guarantee Zygote processes read supported flags immediately.
   - Sets performance tuning properties for Adreno 720.
3. `post-fs-data.sh`:
   - Sets `u:object_r:vendor_configs_file:s0` SELinux context on config mounts.
   - Provides an in-memory bind-mount fallback for `/vendor/etc/vivo_config.ini`.
   - Injects required runtime flags via `resetprop`.
4. `service.sh`:
   - Configures settings providers (`reduced_dynamic_effects=0`, `disable_window_blurs=0`).
   - Ensures properties remain asserted after boot completion.
5. `action.sh`:
   - Triggered via the Action button in KernelSU / SukiSU Manager.
   - Ensures bind mounts, restarts `vendor.vivo.hardware.configstore@1.0-service`, and triggers Zygote soft restart without altering `realtime_blur_state`.
6. `uninstall.sh`:
   - Triggered when the module is removed in Manager.
   - Cleanly unmounts overlay mounts to prevent device busy (`EBUSY`) locks.

## Safe Architecture

- Does not modify read-only physical partitions (`/system`, `/vendor`, `/product`).
- Safe for devices running temporary root (temproot) and enforced AVB.
- All modifications are applied dynamically via overlayfs and property injection.

## Requirements

- iQOO Z9 running OriginOS 6 (Android 16 / SM7550 platform).
- KernelSU / APatch / Magisk with overlay support.
- NixOS with nix-shell (for host build environment).

## Building

To build the flashable zip package:

```bash
./build.sh
```

The resulting package is placed in `out/premium-oos-v<VERSION>.zip`.

## Installation and Activation

1. Transfer `out/premium-oos-v0.5.0.zip` to the device.
2. Flash the zip via KernelSU Manager (or APatch / Magisk).
3. Activation:
   - For standard root: reboot the device.
   - For temporary root (temproot): tap the "Action" button next to the module in KernelSU / SukiSU Manager, or execute:
     ```bash
     su -c "killall -9 vendor.vivo.hardware.configstore@1.0-service && setprop ctl.restart zygote"
     ```
4. Verify activation via adb shell:
   ```bash
   su -c "dumpsys window | grep spacesystem"
   ```
   The configuration string should show `spacesystem` instead of `?spacesystem`.
