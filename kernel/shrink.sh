#!/bin/sh
# Run in the kernel tree after merging s61p.config: the stock `boot` partition is only 32 MiB, so drop everything this board lacks.
set -e
for a in $(grep -o '^config ARCH_[A-Z0-9_]*' arch/arm64/Kconfig.platforms | sed 's/config ARCH_//' | grep -v '^ROCKCHIP$'); do
  scripts/config -d "ARCH_$a" 2>/dev/null || true
done
scripts/config -d DRM -d SOUND -d MEDIA_SUPPORT -d WLAN -d CFG80211 -d BT -d NFC -d PCI -d VIRTUALIZATION \
  -d ETHERNET -d ATA -d NVME_CORE -d INFINIBAND -d HID -d USB_NET_DRIVERS -d DEBUG_INFO -d DEBUG_INFO_DWARF4 \
  -d DEBUG_INFO_DWARF5 -d MTD -d SPI -d IIO -d HWMON -d WATCHDOG -d RTC_CLASS -d CRYPTO_TEST -d FB -d FRAMEBUFFER_CONSOLE \
  -d STAGING -d REMOTEPROC -d ANDROID_BINDER_IPC -d NETFILTER -d BPF_SYSCALL -d EXT4_FS -d XFS_FS -d BTRFS_FS \
  -d F2FS_FS -d NFS_FS -d NETWORK_FILESYSTEMS -d SECURITY -d AUDIT
scripts/config -e CC_OPTIMIZE_FOR_SIZE -d DEBUG_KERNEL
