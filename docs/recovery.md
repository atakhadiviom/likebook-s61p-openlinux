# Recovery

1. Get into Loader mode: `adb reboot bootloader` (Android running), or hold the device's recovery/volume key while plugging USB. VID:PID `2207:330d`.
   If the device is bricked and not enumerating at all, short the eMMC CLK/maskrom pad (hardware step; not documented for this board yet) to get `2207:350a` Maskrom, then `rkdeveloptool db <loader.bin>` first.
2. Decompress images: `xz -dk firmware/stock/*.xz` (boot, kernel, recovery, resource, misc, trust, uboot are in the repo; the rest you must have from your own backup).
3. `scripts/restore.sh firmware/stock boot kernel recovery resource misc`
4. Verify with `rkdeveloptool rl <lba> <sectors> out.img` and compare against `docs/backup-manifest.md` SHA256.

Never touch `idbloader`, `uboot`, `trust` while experimenting. Our experiments only replace `boot` (and `kernel`/`resource` if needed), so Loader mode stays reachable.
