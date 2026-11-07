#!/usr/bin/env bash
# Restore stock partitions to a Likebook S61P in Rockchip Loader/Maskrom mode.
# Usage: scripts/restore.sh <dir-with-images> [partition ...]
# Default partitions: boot kernel recovery resource misc (safe set). uboot/trust/idbloader only if named.
# Requires rkdeveloptool (https://github.com/rockchip-linux/rkdeveloptool). Enter loader mode: `adb reboot bootloader`.
set -euo pipefail
dir="${1:?image dir}"; shift || true
parts=("$@"); [ ${#parts[@]} -eq 0 ] && parts=(boot kernel recovery resource misc)
# name start_lba (from the stock GPT, see docs/device/by-name.txt)
declare -A LBA=([idbloader]=0 [uboot]=16384 [trust]=24576 [misc]=36864 [resource]=45056 [kernel]=77824 [boot]=143360 [recovery]=208896)
rkdeveloptool ld | grep -q Loader || { echo "device not in Loader mode"; exit 1; }
for p in "${parts[@]}"; do
  img="$dir/$p.img"; [ -f "$img" ] || { echo "missing $img"; exit 1; }
  echo "== writing $p @ LBA ${LBA[$p]}"; rkdeveloptool wl "${LBA[$p]}" "$img"
done
rkdeveloptool rd
