#!/usr/bin/env bash
# Build a tiny arm64 initramfs (busybox + USB gadget shell) -> $1 (initramfs.cpio.gz)
set -euo pipefail
out="$(cd "$(dirname "${1:?out file}")" && pwd)/$(basename "$1")"
repo="$(cd "$(dirname "$0")/.." && pwd)"
docker run --rm -v "$(dirname "$out")":/o -v "$repo/kernel/initramfs":/src:ro debian:trixie bash -c '
  apt-get update -qq && DEBIAN_FRONTEND=noninteractive apt-get install -y -qq busybox-static cpio >/dev/null &&
  r=/tmp/rootfs && mkdir -p $r/bin $r/sbin $r/proc $r/sys $r/dev $r/etc $r/tmp $r/mnt &&
  cp /bin/busybox $r/bin/busybox && for a in sh mount umount ls cat echo sleep mkdir dmesg ip ifconfig dd poweroff reboot ps; do ln -sf busybox $r/bin/$a; done &&
  cp /src/init $r/init && chmod +x $r/init &&
  (cd $r && find . | cpio -o -H newc | gzip -9) > /o/'"$(basename "$out")"
ls -la "$out"
