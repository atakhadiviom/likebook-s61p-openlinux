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
8 modes x 14 temperature ranges (temperature thresholds at hdr 0x30: 0,3,6,9,12,15,18,21,24,27,30,33,38,43,48,71 °C).
Phases per range (cold -> hot):
- mode 0 (init/clear): 150 → 13
- mode 1: 73 → 12; mode 2/3: 131 → 38 (GC16-class full quality)
- mode 4/5: 131 → 38 / 37 → 4 (partial)
- mode 6: 35 → 10; mode 7: 84 → 24 (fast A2/DU-class)
Phase counts fall monotonically with temperature, which independently confirms the decoder.

## Open items
- Exact meaning of each mode number (which is GC16/GL16/DU/A2): confirm via `get_wf_mode_index` mapping.
- Temperature source: TPS65185 internal sensor (`tps65185_temperature_get`).
- VCOM: 2540 mV (device tree) via `tps65185_vcom_set`.
