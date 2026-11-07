# likebook-s61p-openlinux

Open research project: faster firmware and mainline Linux for the
**Boyue Likebook S61P** e-ink reader (Rockchip PX30 / RK3326, 1 GB RAM, 6.1" 1024x768 EBC panel).

Status: **research / pre-alpha. Nothing here is flashable yet.** Flashing can brick your device.

## Device facts (from a stock unit, BYRead-V1.0.0-2021072109)
| Item | Value |
|---|---|
| SoC | Rockchip PX30 (RK3326 family), Cortex-A35 x4 |
| RAM / storage | ~970 MB / 16 GB eMMC (`mmcblk1`) |
| OS | Android 8.1, 32-bit userland, Linux 4.4.138 vendor kernel |
| E-ink | Rockchip EBC (`CONFIG_EBC=y`), TPS65185 PMIC, waveform in reserved-memory `waveform@8300000` |
| Partitions | uboot, trust, misc, resource, kernel, boot, recovery, backup, security, system, vendor, userdata ... see `docs/device/by-name.txt` |

Raw data in `docs/device/` (serials removed).

## Roadmap
See [PLAN.md](PLAN.md).

## Safety
Never publish `userdata`, `security`, `frp` or `oem` partition dumps: they hold personal and device-unique data.
