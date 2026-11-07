# First mainline boot attempt (2026-11-07)

- Kernel: torvalds/linux 7.4-rc1, arm64 defconfig + `kernel/s61p.config` + `kernel/shrink.sh` -> Image 15.6 MB (fits the 32 MiB `boot` partition).
- DTB: `kernel/dts/px30-likebook-s61p.dts` (px30-evb base, RK809 PMIC).
- initramfs: busybox + USB gadget (ACM serial + ECM net, product string `S61P-Linux`), `kernel/initramfs/init`.
- Pack: `tools/mkboot.py` -> 15.9 MB boot.img with the DTB in the `second` RSCE slot like stock.
- **Restore path verified**: writing the stock `boot.img` back with `rkdeveloptool wl 143360` read back with an identical SHA256 and Android booted normally afterwards.
- Flashed the Linux boot.img with `wl 143360`. Result: **no USB device of any kind appeared** (no adb, no Loader, no `S61P-Linux` gadget) for 100+ s. Nothing visible on this host to say whether the kernel hung, panicked early, or booted without a working USB gadget.

## Likely causes (to check next, in order)
1. No early console visible (UART2 pads unknown), so a hang before USB is invisible. Add `earlycon` on a reachable UART or enable pstore/ramoops readback from stock after a failed boot.
2. RK809 rails/regulators differ from the EVB description; the USB PHY needs its supply.
3. dwc2 gadget not bound (OTG role needs the PHY and VBUS/extcon; stock used an extcon from the charger).
4. Memory map: stock reserves DRAM ranges for ATF/OP-TEE; mainline may use them (add `reserved-memory` for 0x0-0x200000 etc.).

## Recovery
Put the device in Loader mode by hardware (power off, hold the key used earlier while plugging USB; VID:PID 2207:330d), then:
```
rkdeveloptool wl 143360 boot.img        # stock boot.img from firmware/stock/boot.img.xz (xz -dk first)
rkdeveloptool rd
```
`scripts/restore.sh firmware/stock boot` does the same.
