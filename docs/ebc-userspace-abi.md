# /dev/ebc userspace ABI (stock software-EBC driver)

From `ebc_io_ctl` disassembly; first row verified on a live unit with `tools/ebc-test/ebc_probe.c`.

| ioctl | Handler | Notes |
|---|---|---|
| 0x7000 GET_BUFFER | `ebc_empty_buf_get` + `ebc_phy_buf_base_get` | returns a 56-byte (14 x int) info struct; **verified** |
| 0x7001 SEND_BUFFER | `ebc_add_to_dsp_buf_list` | queues the buffer for refresh; takes the same struct, mode value checked against 7 |
| 0x7002 | takes a 0x28-byte struct, returns it | unclear |
| 0x7003 .. 0x7006 | see `px30` handlers at ebc_io_ctl+0x48/0x2d8/0x374/0x3a4 | not yet decoded |

mmap the fd (framebuffer pool, 6 MiB at phys 0x10000000) and write pixels at `info[0]` bytes.

## GET_BUFFER result on the S61P
| int | value | meaning |
|---|---|---|
| 0 | 388096 (0x5ec00) | byte offset of the buffer in the mmap |
| 1 | -128 | mode/flag field (not a pixel count) |
| 2,4 | 758 | height / virtual height |
| 3,5 | 1024 | width / virtual width |
| 6,7 | 1024, 758 | window x2,y2 (full screen) |

Row stride is 512 bytes for 1024 px, so pixels are **4 bit gray** (2 px per byte). Freshly returned buffer reads `0xff` (white).

## Test binary
`zig cc -target arm-linux-musleabihf -static tools/ebc-test/ebc_probe.c`, push to `/data/local/tmp`, run as shell user (the node is world-writable). The Android UI also uses `/dev/ebc`; each GET_BUFFER takes a buffer from the pool, so do not loop it.

## Verified: test pattern (2026-11-08)
`tools/ebc-test/ebc_pattern.c` writes a 4-bit gray image into the GET_BUFFER buffer, sets `info[1]=epd_mode` and the window `info[9..12]=0,0,1024,758`, then calls 0x7001. **Panel displayed the 16 gray bars and checkerboard correctly** with `epd_mode=1` (EPD_FULL).
So: pixel format (4 bit, 2 px/byte, low nibble = left pixel), buffer offset, window fields and the send path are confirmed on hardware.
epd_mode enum (old Rockchip set, matches kernel strings): 0 AUTO, 1 FULL, 2 A2, 3 PART, 4 FULL_DITHER, 5 RESET, 6 BLACK_WHITE, 7 BG, 8 BLOCK.
