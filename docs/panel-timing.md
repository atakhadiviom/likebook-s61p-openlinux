# Panel / EBC timing (from stock device tree, `/sys/firmware/devicetree/base/eink`)

Panel: E Ink **ED060XCD** (waveform tag `320_R174_ABBE01_ED060XCDU1_TC`), 1024 x 758 visible.
Compatible: `rockchip,eink`. Waveform loaded into reserved-memory `waveform@8300000`; tcon, nvmem (otp), memory-region are phandles.

| Property | Value |
|---|---|
| width x height | 1024 x 758 |
| sdck | 20,000,000 Hz |
| pixels-per-sdck | 4 |
| fsl / fbl / fdl / fel | 2 / 4 / 758 / 5 |
| lsl / lbl / ldl / lel | 6 / 6 / 256 / 38 |
| gdck-sta | 4 |
| lgonl | 262 |
| vcom | 2540 mV |

Raw hex: `dt-eink-hex.txt`. Next: map to mainline `rockchip_ebc` panel properties and find where the waveform blob lives.
