# Backup manifest

Stock firmware BYRead-V1.0.0-2021072109 dumped over Rockchip loader mode (`rkdeveloptool rl`) on 2026-11-07.
Images are kept privately, never committed. SHA256 of each:

```
302bf7864d49421085d07f3b54a9127d0b789822e0a72385d7ce751ef28f958f  backup.img
db0b35de0d44fd277a89ceae9ccc8a25eea9bca19e9cb16070c969797a9e540e  boot.img
07854d2fef297a06ba81685e660c332de36d5d18d546927d30daad6d7fda1541  frp.img
d41c053abb9fb4f74db3cb4a793d8e61aed7bb239dbf784b9d86b72c6350466c  idbloader.img
fa91a224c72600da01f9e8fbf480566b56f5a0c83b24448688b18b87a61a2c26  kernel.img
e7d0adeb287e9a1abafadac5b46640668816379f5a19bee28555e78d658c57c3  metadata.img
ed25372e0a2f7d166bbeebeb97b96450fb3932ee4f646e8bdecb5e94937863c6  misc.img
430880b8e908aaab110405a16976d1c172424a86882540c31244034af1294272  oem.img
784d1dddcdd81c215b871735e796cc057535f9485dd05e476184bbb509af51b4  recovery.img
13e1b3300f0d3bd4f61ebe2aeea7311092d297ae14ee41429bd14035a849e931  resource.img
03aff8e0dc2d569d30e0012ee0e39dd46f651f78ba6e8aaaf1e14e06eac18872  security.img
cf3d4b6fe6de27dc11d3c9a576a24304e1cef475c0146b938fc9b2c26c2818fb  system.img
eb940da84cacde987ae8e82bd4ad9c367d02e5f8d6008409bc1207cd9a2476f6  trust.img
b348a08e9acd331dc62b0522cb5ac8f7400e001d66386ef2fc4187cfad4cd7aa  uboot.img
f13378c51d24725343eaff3e2e7db348f1ca27936ba8e204c79fbc4080331398  vendor.img
```

Not dumped: `userdata` (personal data), `cache`.
Bootloader reaches Rockusb Loader via `adb reboot bootloader` (VID 2207, PID 330d). `rkdeveloptool rd` reboots back to Android.
`resource.img` holds `rk-kernel.dtb` and boot logos but no waveform; look for it in `vendor`/`oem` or the boot loader.

## Waveform located
E Ink waveform `320_R174_ABBE01_ED060XCDU1_TC` (E Ink .wbf header, 291,997 bytes) sits in the **`trust` partition at byte offset 0x400000** (4 MiB), not in `resource`.
Extract: `dd if=trust.img bs=1 skip=4194304 count=291997 of=waveform.wbf`.
SHA256 of the extracted file: see below. The blob is E Ink's proprietary data: kept in `backups/private/`, not committed.
Also found: a second waveform tag `320_R178_AF1521_ED097TC2U1_TC` (9.7" panel) embedded in kernel/boot/recovery images: unused by this unit.
`14b1e1471cb6ee8502c64143b41e1c6802a092aaaf3e01780844055885bdea15  backups/private/emmc/waveform-ED060XCD.wbf`
