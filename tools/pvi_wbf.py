#!/usr/bin/env python3
"""Decode an E Ink PVI .wbf waveform file, following the stock Rockchip kernel logic
(pvi_wf_input / get_wf_frm_num / decodewaveform, kernel 4.4.138 on Likebook S61P).

Layout (derived from disassembly, validated on the dumped file):
  hdr[0x10]  waveform "mode version" (0x12,0x18,0x19,0x20,0x23 accepted by stock driver)
  hdr[0x41:0x60] version string
  hdr[0x20]  byte offset of the mode table
  table entry (4 bytes): off24 little endian, chk = (b0+b1+b2)&0xff
    mode table[mode]   -> offset of that mode's temperature-range table
    temp table[range]  -> offset of the compressed waveform blob
  blob: stream of bytes; 0xff ends; 0xfc toggles RLE/raw state; each data byte holds 4 x 2-bit
        drive values (bits 0-1,2-3,4-5,6-7); in RLE state (initial) a count byte follows (n extra repeats).
        Cells fill a SxS matrix per frame (S = 32 for 5-bit, 16 for 4-bit gray), inner index = column.
        Result: frames[frame][a][b] in {0:hold,1,2,3}  (drive voltage code per phase).
"""
import sys, struct, re

def entry(d, off):
    b0, b1, b2, ck = d[off:off+4]
    if (b0 + b1 + b2) & 0xff != ck:
        return None
    return b0 | b1 << 8 | b2 << 16

def decode(d, off, size):
    p = off; rle = True; frame = row = col = 0
    out = {}
    def put(vals):
        nonlocal col, row, frame
        for v in vals:
            out.setdefault(frame, {})[(col, row)] = v
            col += 1
        if col >= size:
            col = 0; row += 1
            if row >= size:
                row = 0; frame += 1
    while p < len(d):
        b = d[p]
        if b == 0xff:
            break
        if b == 0xfc:
            rle ^= True; p += 1; b = d[p]
        vals = [b & 3, b >> 2 & 3, b >> 4 & 3, b >> 6]
        if rle:
            n = d[p + 1]
            for _ in range(n + 1):
                put(vals)
            p += 2
        else:
            put(vals); p += 1
        if frame > 0x1ff:
            raise ValueError('too many frames')
    return frame + (1 if col or row else 0), out

def main(path):
    d = open(path, 'rb').read()
    print('mode_version byte 0x10 = %#x' % d[0x10])
    print('version string:', re.match(rb'[ -~]*', d[0x41:0x60]).group().decode())
    size = 16 if d[0x10] in (0x10,) else 32
    mt = d[0x20]
    print('mode table at %#x' % mt)
    m = 0
    while True:
        off = entry(d, mt + 4 * m)
        if off is None:
            break
        tr = 0
        frames = []
        while True:
            o = entry(d, off + 4 * tr)
            if o is None or o >= len(d):
                break
            try:
                n, _ = decode(d, o, size)
            except Exception:
                break
            frames.append(n); tr += 1
            if tr >= 14: break  # empirical: 14 temperature ranges (frame counts fall with temperature)
        print('mode %d: temp-table %#x, %d ranges, frames/range %s' % (m, off, len(frames), frames))
        m += 1
        if not frames: break

if __name__ == '__main__':
    main(sys.argv[1])
