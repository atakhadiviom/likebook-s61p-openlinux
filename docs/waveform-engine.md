# Waveform engine (decoded from stock kernel + validated on the real file)

The stock driver has three waveform parsers: `pvi_wf_*` (E Ink PVI .wbf, **ours**, `mode_version` byte 0x19), `rkf_wf_*` (Rockchip format) and `oed_wf_*`.
Accepted PVI `mode_version` values: 0x12, 0x18, 0x19, 0x20, 0x23. Header byte 0x10 selects the mode-number mapping (`get_wf_mode_index`); the version string sits at 0x41.

## File layout (reference decoder: `tools/pvi_wbf.py`)
1. `hdr[0x20]` = offset of the mode table (here `0x5f`).
2. Table entries are 4 bytes: 24-bit LE offset + checksum byte `(b0+b1+b2)&0xff`. Mode table -> per-mode temperature table -> per-temperature-range blob.
3. Blob = compressed LUT stream: `0xff` ends; `0xfc` toggles RLE/raw; every data byte holds four 2-bit drive codes (0 hold, 1/2/3 = drive polarity/voltage); in RLE state a repeat-count byte follows.
4. Decoded form is `frames[frame][a][b]`: a 32x32 (5-bit gray) or 16x16 (4-bit) matrix per phase, indexed by source gray and target gray. ≤ 512 phases.
5. The software EBC engine picks a frame sequence by `(mode, temperature range)`, then for each pixel looks up `lut[phase][old][new]`, packs 4 pixels/byte (2-bit) and DMAs that phase buffer to the TCON (`px30-eink-tcon-regs.md`).

## What the real ED060XCD file contains (decoded OK)
8 modes (0-7) x 14 temperature ranges; a 16-byte threshold table sits at hdr 0x30 (`00 03 06 09 0c 0f 12 15 18 1b 1e 21 26 2b 30 47`, assumed °C).
Phases per range (index 0..13):
- mode 0: 150 134 118 103 89 159 135 111 99 87 79 71 63 59 (init/clear class)
- mode 1: 73 65 57 50 43 37 31 25 22 19 17 15 13 12
- modes 2-5: 131 116 102 90 77 66 55 46 38 38 38 38 38 38 (identical counts, different LUTs: GC16/GL16-class)
- mode 6: 35 31 28 24 21 17 15 12 10 x6 (fast)
- mode 7: 84 75 65 58 49 42 35 29 24 x6
Phase counts fall with range index for each mode, which supports the decoder. Pixel-level LUT values are not yet cross-checked against a real refresh.

## Open items
- Exact meaning of each mode number (which is GC16/GL16/DU/A2): confirm via `get_wf_mode_index` mapping.
- Temperature source: TPS65185 internal sensor (`tps65185_temperature_get`).
- VCOM: 2540 mV (device tree) via `tps65185_vcom_set`.
