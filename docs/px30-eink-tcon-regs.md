# PX30 e-ink TCON register programming (from stock kernel disassembly)

Source: `px30_eink_tcon_enable/disable/flush` in the stock 4.4.138 arm64 kernel (boot.img, symbols recovered with `vmlinux-to-elf`).
Method: capstone disassembly; values below are what the driver writes, names are my interpretation (unverified on hardware).
TCON base `0xff470000`, 32-bit registers, driver writes through a regmap-like shadow (cache + MMIO).
Driver is the **software EBC** type (`CONFIG_SOFTWARE_EBC`): the CPU turns grayscale into waveform phases (`epd_lut_*`, `pvi_wf_*`), the TCON only streams the resulting 2-bit/pixel (or 4-bit) phase frames by DMA.
Kernel also contains an `rk3288_eink_tcon` variant: a sibling older design.

## enable(panel x=1024, y=758, mode)
| Reg | Value | Meaning (guess) |
|---|---|---|
| 0x98 | `x & 0x1fff` (mode 8) / `((x+1)>>1) & 0x1fff` | line width in words |
| 0x90 | `0` (mode 8) / `0x20` | data format / start bit0 |
| 0x28 | `0x400000` / `0x420000` | DMA / format control |
| 0x1f4 | clear bit24 | global enable/clock gate |
| 0xa4 | `((y-1)<<16) \| ((x-1)&0x7ff)` | active size |
| 0xa8 | `0x00020002` | |
| 0x100 | `((x+3)<<16) \| 1` | horizontal timing |
| 0x104 | `0x20000 \| ((x+2)&0xfff)` | |
| 0x108 | `((y+3)<<16) \| 1` | vertical timing |
| 0x10c | `0x20000 \| ((y+2)&0xfff)` | |
| 0x0c | `0x88200804` | main control |
| 0x38 | `0x100` | |
| 0x34 | `0x01000100` | |
| 0x00 | `1` | commit/apply |

Also: enables three clocks (aclk/dclk/hclk), pinctrl, a power-domain; sets the sdck clock to `5 * dclk_param`; resets via `0x438`-offset write on the GRF with value `0xc0008 | (w<<2)` (selects the tcon).

## flush(frame)
1. `0xa0` = physical address of the phase buffer
2. toggle bit0 of `0x90` (start)
3. `0x18 &= ~0x4b` (unmask the done IRQ)
4. `0x00 = 1`
5. toggle bit28 of `0x0c`
IRQ handler `eink_tcon_irq_hanlder` acks and signals frame done; `ebc_thread` then queues the next phase.

## disable
toggle bit24 of `0x1f4`, `0x18 |= 0x4a` (mask irqs), `0x00 = 1`, gate clocks.

Full symbol list: `docs/device/kernel-ebc-symbols.txt`.
