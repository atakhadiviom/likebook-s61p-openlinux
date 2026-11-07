#!/usr/bin/env python3
"""Pack a Rockchip-style Android boot.img (v0, page 2048) for the Likebook S61P.
The stock image carries a Rockchip resource image (RSCE) in the 'second' slot holding rk-kernel.dtb,
so we rebuild that RSCE with our DTB. Header addresses are copied from the stock boot.img.
Usage: mkboot.py <Image> <initramfs.cpio.gz> <dtb> <out boot.img> [cmdline]
"""
import sys, struct, hashlib

PAGE = 2048
def pad(b, n=PAGE): return b + b'\0' * (-len(b) % n)

def rsce(name, blob):
    hdr = bytearray(512)
    hdr[0:4] = b'RSCE'; hdr[8] = 1; hdr[9] = 1; hdr[10] = 1; hdr[12] = 1   # hdr blocks, table offset, entry size, count
    ent = bytearray(512)
    ent[0:4] = b'ENTR'; ent[4:4 + len(name)] = name.encode()
    struct.pack_into('<II', ent, 260, 2, len(blob))                         # data starts at block 2
    return bytes(hdr) + bytes(ent) + pad(blob, 512)

def main(img, rd, dtb, out, cmdline='buildvariant=user'):
    k, r, d = (open(p, 'rb').read() for p in (img, rd, dtb))
    second = rsce('rk-kernel.dtb', d)
    hdr = bytearray(PAGE)
    hdr[0:8] = b'ANDROID!'
    # kernel_size, kernel_addr, ramdisk_size, ramdisk_addr, second_size, second_addr, tags_addr, page_size (stock values)
    struct.pack_into('<8I', hdr, 8, len(k), 0x10008000, len(r), 0x11000000, len(second), 0x10f00000, 0x10000100, PAGE)
    hdr[64:64 + len(cmdline)] = cmdline.encode()
    sha = hashlib.sha1()
    for blob in (k, r, second):
        sha.update(blob); sha.update(struct.pack('<I', len(blob)))
    hdr[576:596] = sha.digest()
    open(out, 'wb').write(bytes(hdr) + pad(k) + pad(r) + pad(second))
    print('wrote', out, 'kernel', len(k), 'ramdisk', len(r), 'second', len(second))

if __name__ == '__main__':
    main(*sys.argv[1:])
