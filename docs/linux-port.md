# Linux port notes (Phase 3)

Source: stock DTS `docs/device/rk-kernel.dts` (decompiled from `resource.img:rk-kernel.dtb`), board `rockchip,px30-evb-ddr3-v10-eink`.

## E-ink hardware map
| Block | Address / detail |
|---|---|
| E-ink TCON | `rockchip,px30-eink-tcon` @ `0xff470000` (second instance @ `0xff460000`, disabled), IRQ SPI 78, clocks aclk/dclk/hclk, power-domain 12, GRF |
| Pixel/panel node | `rockchip,eink` 1024x758, sdck 20 MHz, 4 px/sdck (timings: `panel-timing.md`) |
| Framebuffer reserved mem | `0x10000000`, 6 MiB, no-map |
| Waveform reserved mem | `0x08300000`, 1 MiB, no-map; stock loads the .wbf from `trust` @ 0x400000 |
| PMIC | TI TPS65185 @ I2C `0x68`; GPIO wakeup/vcomctl/powerup on GPIO bank 2 pins 2/1/4 |
| OTP | `rockchip-otp` nvmem (panel/temperature calibration) |

## Key finding (corrects earlier assumption)
PX30 uses its own **`px30-eink-tcon`** block. The mainline-track `rockchip_ebc` driver (PineNote) targets the RK356x EBC at a different address with a different register layout, so it does **not** drive this panel unchanged.
A new driver is needed. Starting points: the vendor `drivers/video/rockchip/eink/` in Rockchip's 4.4 kernel, and `rockchip_ebc` for the DRM/waveform-engine structure (drm_gem, Y4 conversion, .wbf parsing).

## Steps
1. Obtain vendor 4.4.138 kernel source (Rockchip `rockchip-linux/kernel` branch `develop-4.4` / Boyue GPL request) and extract the eink tcon register programming.
2. Boot test, no flash: mainline kernel + PX30 DTS via SD card or `rkdeveloptool` RAM boot, serial console if a UART pad exists. Display unused at first.
3. Write minimal tcon driver: fixed-frame GC16 refresh using the extracted waveform.
4. Port TPS65185 power sequencing (mainline has `ti,tps65185` hwmon-less; may need small driver).
5. Userspace: Alpine armhf/aarch64 + KOReader on fbdev.

## Safety
Stock images are backed up (`docs/backup-manifest.md`) and the device enters Loader mode with `adb reboot bootloader`, so recovery via `rkdeveloptool wl` works. Never flash `uboot`/`trust`/`idbloader` experimentally.
