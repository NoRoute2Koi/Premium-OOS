# premium-OOS

English | [Русский](README-RU.md)

KernelSU module to unlock flagship blur, translucency, and premium UI effects on iQOO Z9 (OriginOS 6).

## Overview

On budget and midrange devices such as the iQOO Z9 (Snapdragon 7 Gen 3 / SM7550), OriginOS 6 visual effects are limited at the configuration table and framework check level:
- Lockscreen and Always-On Display clock blur, widget blur, and deformation shaders are gated by the Space System mode (`ssMode`) in `ActivityTaskManagerService`. If the mode is 0 (`?spacesystem`), `VivoDreamClockApp` completely disables blur shaders.
- The window manager only sets the mode to `ssMode = 2` if `FtFeature.getFeatureAttribute("vivo.software.spacesystem", "version", "0") >= 2` returns true during `system_server` startup.
- The vendor ConfigStore HAL (`vendor.vivo.hardware.configstore@1.0-service`) strictly requires `vivo-support = 1` and `is_support_zygote = 1` in `vivo_config.ini`. If `vivo-support` is missing, the HAL treats the feature as unsupported and returns the default value `0`.
- SystemUI evaluates device tier in `SystemPropertiesFacade.getPerformanceLevel()`. Without `vivo.software.nativeblur` and Space System v2+, the device is classified as low-performance (tier 40 instead of 30), which disables window deformation animations.
- App launch and exit background deformation blur is disabled (`support_blur=0` in vendor config, `ro.launcher.blur.appLaunch=0`).
- The system effect profile is set to Lite (`system_effect_type=1` instead of `0`).

This module dynamically replaces configuration in-memory via KernelSU overlayfs and system property injection without writing to physical partitions or altering AVB hashes.

## Features

- Unlock lockscreen and AOD clock blur and widget blur shaders.
- Enable app launch and exit background deformation blur in launcher.
- Activate Space System v3 level 1 blur pipeline (`spacesystem` mode 2).
- Switch system effect profile from Lite (`1`) to Full (`0`).
- Enable native hardware blur, motion blur, and V-Glass translucency.
- Retain temporary root (temproot) safety with zero physical partition writes.
- Manager Action button support for soft reload and ConfigStore HAL restart.
- Clean unmount on module removal via `uninstall.sh` preventing resource busy errors (`EBUSY`).
- Rendering optimization suite for Snapdragon 7 Gen 3 (Adreno 720) and 1.5K display.

## Performance Tuning for iQOO Z9

To prevent micro-stutters and frame drops on Adreno 720:
- **Balanced deformation radius**: Window blur radius is reduced from 44 to 24 (`min_blur_radius_temp = 24`), halving GPU texture sampling load while preserving a soft visual aesthetic.
- **Dynamic blur frame rate**: The `debug.blur.dynamic.frameRate=true` parameter is enabled. This allows the graphics engine to refresh the blur texture at 60-90 fps while window motion remains smooth at 120/144 fps.
- **Disabled excessive gradient**: Heavy level 4 gradient passes (`persist.debug.blurlevel_4=false`) are disabled, avoiding memory fillrate bottlenecks on high-resolution displays.
- **Hardware control center optimization**: Enabled `persist.debug.qs_enable_hardware_optimize=true`.
- **GPU frequency boost**: Set a minimum Adreno clock threshold upon entering blur animations (`persist.blur.GPU.minlevel=60`, duration 600 ms).

## Technical Architecture

1. `vendor/etc/vivo_config.ini`:
   - Configures `[vivo.software.spacesystem]`, `[vivo.software.spacesystem.borderlight]`, `[vivo.software.nativeblur]`, `[vivo.software.motionblur]`, `[vivo.software.asyncanimboost]`, `[vivo.software.vglasseffect]`, `[vivo.software.realtimeblur]`, and optimized `[vivo.software.windowdeformblur]`.
   - Adds `vivo-support = 1` and `is_support_zygote = 1` attributes for proper feature export via ConfigStore HAL into Zygote and System Server.
2. `system.prop`:
   - Sets `ro.vendor.vivo.software.*` system properties at early Android initialization.
   - Sets optimizations for the Adreno 720 graphics core.
3. `post-fs-data.sh`:
   - Assigns `u:object_r:vendor_configs_file:s0` SELinux context to mounted files.
   - Sets up a fallback bind-mount for `/vendor/etc/vivo_config.ini`.
   - Injects parameters via `resetprop`.
4. `service.sh`:
   - Configures settings in system settings providers (`reduced_dynamic_effects=0`, `disable_window_blurs=0`).
   - Keeps properties asserted after boot completion.
5. `action.sh`:
   - Triggered via the Action button in KernelSU / SukiSU Manager.
   - Verifies mounts, restarts `vendor.vivo.hardware.configstore@1.0-service`, and performs a Zygote soft reboot.
6. `uninstall.sh`:
   - Triggered when removing the module in manager.
   - Unmounts `/vendor/etc/vivo_config.ini` layers to prevent inode locks (`Device or resource busy`).

## Safe Architecture

- Does not modify read-only physical partitions (`/system`, `/vendor`, `/product`).
- Fully compatible with temporary root (temproot) and AVB verification.
- All modifications are applied exclusively via overlayfs in memory and via `resetprop`.

## Requirements

- iQOO Z9 running OriginOS 6 (Android 16 / SM7550 platform).
- KernelSU / APatch / Magisk with overlay support.
- NixOS build environment (via `nix-shell`).

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
   - For standard permanent root: reboot the device.
   - For temporary root (temproot): tap the Action button next to the module in KernelSU / SukiSU Manager, or execute manually:
     ```bash
     su -c "killall -9 vendor.vivo.hardware.configstore@1.0-service && setprop ctl.restart zygote"
     ```
4. Verify activation via adb shell:
   ```bash
   su -c "dumpsys window | grep spacesystem"
   ```
   The global configuration string should display `spacesystem` instead of `?spacesystem`.
5. Allow the smartphone time for background optimization (leave it charging overnight undisturbed).

## License

This project is licensed under the GNU General Public License v3.0 (GPLv3). See the [LICENSE](LICENSE) file for details.
