#!/usr/bin/env bash
# Build mainline Linux (arm64) for the Likebook S61P inside a Debian container (Colima/Docker).
# Usage: scripts/build-kernel.sh <path-to-linux-tree>
set -euo pipefail
tree="$(cd "${1:?linux tree}" && pwd)"
repo="$(cd "$(dirname "$0")/.." && pwd)"
cp "$repo/kernel/dts/px30-likebook-s61p.dts" "$tree/arch/arm64/boot/dts/rockchip/"
grep -q likebook "$tree/arch/arm64/boot/dts/rockchip/Makefile" || \
  sed -i.bak 's/^dtb-\$(CONFIG_ARCH_ROCKCHIP) += px30-evb.dtb/&\ndtb-$(CONFIG_ARCH_ROCKCHIP) += px30-likebook-s61p.dtb/' "$tree/arch/arm64/boot/dts/rockchip/Makefile"
docker run --rm -v "$tree":/w -v "$repo/kernel":/cfg:ro -w /w debian:trixie bash -c '
  apt-get update -qq &&
  DEBIAN_FRONTEND=noninteractive apt-get install -y -qq build-essential flex bison bc libssl-dev libelf-dev device-tree-compiler python3 >/dev/null &&
  make ARCH=arm64 defconfig &&
  scripts/kconfig/merge_config.sh -m .config /cfg/s61p.config >/dev/null &&
  make ARCH=arm64 olddefconfig &&
  make ARCH=arm64 -j"$(nproc)" Image rockchip/px30-likebook-s61p.dtb'
ls -la "$tree/arch/arm64/boot/Image" "$tree/arch/arm64/boot/dts/rockchip/px30-likebook-s61p.dtb"
