# Mainline Linux for the Likebook S61P

Target tree: torvalds/linux (checked against 7.4-rc1). PX30 (`px30.dtsi`) and the TPS65185 regulator (`drivers/regulator/tps65185.c`) are already mainline; the **PX30 e-ink TCON/EBC driver is not** and must be written (see `docs/px30-eink-tcon-regs.md`, `docs/waveform-engine.md`).

## Milestones
1. **Boot to console.** `kernel/dts/px30-likebook-s61p.dts` (compiles with dtc; untested on hardware). Needs: arm64 `defconfig` + eMMC + dwc2 gadget, boot.img packed with `mkbootimg`, UART2 @115200 (pads on the board) or USB gadget networking for a shell.
2. **PMIC + regulators.** Stock uses an RK81x PMIC (`rk818-charger` strings in the kernel); mainline `rk808` MFD covers it. Needed before eMMC/USB are reliable.
3. **TPS65185 power sequencing** via mainline `ti,tps65185` binding (VCOM 2540 mV).
4. **EBC driver** (`drivers/gpu/drm/rockchip/` or fbdev): program `0xff470000` per `docs/px30-eink-tcon-regs.md`, load waveform (`firmware/stock/waveform-ED060XCD.wbf` via `request_firmware`), generate phases per `tools/pvi_wbf.py`.
5. **Userspace**: Alpine/Debian + KOReader.

## Safe test loop
Only `boot` is replaced; back it up first (it is in `firmware/stock/boot.img.xz`). Loader mode stays reachable via `adb reboot bootloader` while stock `uboot` is intact. Restore with `scripts/restore.sh` (see `docs/recovery.md`).

## Build (Linux VM/container; Apple Silicon hosts are native arm64)
```
colima start && docker run --rm -v $PWD:/w -w /w debian:trixie bash -c \
 'apt update && apt install -y build-essential flex bison bc libssl-dev device-tree-compiler && \
  make -C linux ARCH=arm64 defconfig Image dtbs -j$(nproc)'
```
