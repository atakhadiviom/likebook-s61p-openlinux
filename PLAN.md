# Plan

## Phase 0 - Recon (in progress)
- [x] Identify SoC, kernel, partition layout, EBC driver in stock kernel
- [x] Export kernel config and device facts to `docs/device/`
- [ ] Dump device tree (`/sys/firmware/devicetree/base`) and decompile to DTS
- [ ] Locate waveform source (`resource` partition or `waveform@8300000`)

## Phase 1 - Backup (needs root or Rockchip loader mode)
adb shell has no root, so raw partitions are unreadable over normal adb.
Options: (a) `rkdeveloptool` in maskrom/loader mode, (b) obtain Boyue official update.img,
(c) Magisk-style root via patched boot (needs unlocked bootloader).
- [ ] Full eMMC image stored privately, SHA256 recorded in `docs/backup-manifest.md`
- [ ] Confirm recovery path (maskrom entry) before any flash

## Phase 2 - Faster stock (reversible, no flash)
- [ ] Disable unused system apps via `pm disable-user`
- [ ] Animation scales 0, background sync off
- [ ] Install KOReader; document e-ink refresh settings
- [ ] Publish `scripts/debloat.sh` plus revert script

## Phase 3 - Linux bring-up
- [ ] Request GPL kernel source from Boyue
- [ ] Mainline kernel with PX30 DTS for this board
- [ ] Port `rockchip_ebc` (PineNote driver) to PX30 EBC, feed waveform
- [ ] Boot Alpine/Debian armhf/arm64 rootfs from SD card first (non-destructive)
- [ ] KOReader on framebuffer, tuned refresh

## Phase 4 - Release
- [ ] Images, install guide, recovery guide, known-issues
