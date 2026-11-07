# Stock firmware pieces (Boyue Likebook S61P, BYRead-V1.0.0-2021072109)

Boot-chain images only, xz-compressed (`xz -d x.img.xz`): uboot, trust, misc, resource, kernel, boot, recovery,
plus the E Ink waveform `waveform-ED060XCD.wbf` (extracted from `trust` @ 0x400000).

Scanned for the device serial: none found. NOT included on purpose: `idbloader` (contains serial),
`security`, `frp`, `oem`, `metadata`, `backup` (device-unique or account data), `system`, `vendor` (huge, proprietary, hold MAC-like strings), `userdata`.

Contents are third-party (Rockchip, E Ink, Boyue, Google/AOSP, Linux GPL). Provided for interoperability research and recovery. Verify rights before making the repo public.
