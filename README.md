# premium-OOS

KernelSU module to unlock flagship blur, translucency, and premium UI effects on iQOO Z9 (OriginOS 6).

## Overview

On budget devices like iQOO Z9, OriginOS 6 disables flagship visual effects via configuration flags:
- App launch/exit deformation blur is disabled (`ro.launcher.blur.appLaunch=0` and `support_blur=0` in `vivo_config.ini`).
- System effect profile is set to lite (`system_effect_type=1` instead of `0`).
- Space system effects (clock blur, lockscreen effects, widget blur, space blur 3) are disabled due to missing `vivo.software.spacesystem` section in `vivo_config.ini`.
- Glass and realtime blur features (`vivo.software.vglasseffect`, `vivo.software.realtimeblur`) are disabled.

This module patches configuration in-memory via KernelSU overlay mounts without modifying physical partitions or altering AVB hashes.

## Features

- Unlock lockscreen clock blur and widget blur.
- Unlock app launch and exit background deformation blur.
- Switch system effect profile from Lite (`1`) to Full (`0`).
- Enable Space System v3 level 1 blur pipeline.
- Enable realtime blur and V-Glass effects.

## Safe Architecture

- Does not modify read-only physical partitions (`/system`, `/vendor`, `/product`).
- Safe for devices with temporary root (temproot) and enforced AVB.
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

The resulting zip package is placed in `out/premium-oos-v<VERSION>.zip`.

## Installation

1. Transfer `out/premium-oos-v0.2.0.zip` to the device.
2. Install via KernelSU Manager or APatch/Magisk app.
3. Reboot the device.
