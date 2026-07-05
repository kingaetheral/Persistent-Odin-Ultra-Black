# OLED Ultra Black Keeper

**by KingAether** · Magisk module · v1.1.0 · Unihertz Odin 3

The Odin 3's "OLED Ultra Black Mode" (Settings → Advanced Settings) improves color shift and the mura effect at very low brightness — but the stock ROM **never persists it**. Every reboot silently turns it back off.

This module fixes that: it re-enables Ultra Black Mode at every boot and keeps it on with a lightweight watchdog. Flash it once and forget it.

## How it works

Ultra Black Mode isn't stored in Android settings, properties, or any file — the vendor Settings app (`com.odin.settings`) applies it live through `PServiceBridgeV2` by writing to a kernel node:

```
/sys/class/enhance_color_class/enhance_color_device/enhance_color
```

`1` = Ultra Black on, `0` = off. Since nothing persists the value, it resets on reboot. This module's boot service simply writes `1` after the system settles, then re-checks every 30 seconds (configurable) in case anything flips it back.

## Install

1. Download the zip from [Releases](../../releases)
2. Magisk → Modules → Install from storage
3. Reboot — done

No configuration needed on the Odin 3. The stock toggle in Settings keeps working, but the watchdog will re-enable Ultra Black within 30 seconds if you turn it off there.

## Configuration

`/data/adb/ultra_black_keeper/config.conf`:

- `SYSFS_VALUE=1` — set to `0` to keep Ultra Black forced *off* instead
- `WATCHDOG_INTERVAL=30` — seconds between re-checks; `0` = apply once at boot only
- Delete the file and reinstall the module to reset defaults

Actions are logged to `/data/adb/ultra_black_keeper/keeper.log`.

## Verifying

After a reboot:

```
su -c 'cat /data/adb/ultra_black_keeper/keeper.log'
su -c 'cat /sys/class/enhance_color_class/enhance_color_device/enhance_color'
```

Expect a `sysfs: ... -> 1` log line and the node reading `1`.

## Other devices

The module also supports guarding an Android settings key, a system property, or a different sysfs node — see the alternative methods in `config.conf`. A helper at `/data/adb/ultra_black_keeper/find_key.sh` snapshots and diffs system state around a toggle to help you discover what your device uses.

## Uninstall

Remove the module in Magisk and reboot. Ultra Black returns to stock behavior (off after reboot). Optionally delete `/data/adb/ultra_black_keeper/`.

## Credits

- **KingAether** — module author, sysfs node discovery
- Powered by [Magisk](https://github.com/topjohnwu/Magisk)
