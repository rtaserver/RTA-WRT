#!/bin/bash

. ./scripts/INCLUDE.sh

declare -a github_packages
if [ "$TYPE" == "AMLOGIC" ]; then
    echo -e "${INFO} Adding luci-app-amlogic for target Amlogic."
    github_packages+=("luci-app-amlogic|https://api.github.com/repos/ophub/luci-app-amlogic/releases/latest")
fi
github_packages+=(
    "luci-app-alpha-config|https://api.github.com/repos/animegasan/luci-app-alpha-config/releases/latest"
    "luci-theme-material3|https://api.github.com/repos/AngelaCooljx/luci-theme-material3/releases/latest"
    "luci-app-neko|https://api.github.com/repos/nosignals/openwrt-neko/releases/latest"
)

download_packages "github" github_packages[@]

declare -a other_packages=(
    "modemmanager-rpcd|https://downloads.$BASE.org/releases/packages-24.10/$ARCH_3/packages"
    "luci-proto-modemmanager|https://downloads.$BASE.org/releases/packages-24.10/$ARCH_3/luci"
    "libqmi|https://downloads.$BASE.org/releases/packages-24.10/$ARCH_3/packages"
    "libmbim|https://downloads.$BASE.org/releases/packages-24.10/$ARCH_3/packages"
    "modemmanager|https://downloads.$BASE.org/releases/packages-24.10/$ARCH_3/packages"
    "sms-tool|https://downloads.$BASE.org/releases/packages-$VEROP/$ARCH_3/packages"
    "tailscale|https://downloads.$BASE.org/releases/packages-$VEROP/$ARCH_3/packages"

    "python3-speedtest-cli|https://downloads.openwrt.org/releases/packages-$VEROP/$ARCH_3/packages"
    "dns2tcp|https://downloads.immortalwrt.org/releases/packages-$VEROP/$ARCH_3/packages"
    "luci-app-argon-config|https://downloads.immortalwrt.org/releases/packages-$VEROP/$ARCH_3/luci"
    "luci-theme-argon|https://downloads.immortalwrt.org/releases/packages-$VEROP/$ARCH_3/luci"
    "luci-app-openclash|https://downloads.immortalwrt.org/releases/packages-$VEROP/$ARCH_3/luci"
    "luci-app-passwall|https://downloads.immortalwrt.org/releases/packages-$VEROP/$ARCH_3/luci"

    "luci-app-tailscale|https://dl.openwrt.ai/releases/24.10/packages/$ARCH_3/kiddin9"
    "luci-app-diskman|https://dl.openwrt.ai/releases/24.10/packages/$ARCH_3/kiddin9"
    "modeminfo-serial-zte|https://dl.openwrt.ai/releases/24.10/packages/$ARCH_3/kiddin9"
    "modeminfo-serial-gosun|https://dl.openwrt.ai/releases/24.10/packages/$ARCH_3/kiddin9"
    "modeminfo-qmi|https://dl.openwrt.ai/releases/24.10/packages/$ARCH_3/kiddin9"
    "modeminfo-serial-yuge|https://dl.openwrt.ai/releases/24.10/packages/$ARCH_3/kiddin9"
    "modeminfo-serial-thales|https://dl.openwrt.ai/releases/24.10/packages/$ARCH_3/kiddin9"
    "modeminfo-serial-tw|https://dl.openwrt.ai/releases/24.10/packages/$ARCH_3/kiddin9"
    "modeminfo-serial-meig|https://dl.openwrt.ai/releases/24.10/packages/$ARCH_3/kiddin9"
    "modeminfo-serial-styx|https://dl.openwrt.ai/releases/24.10/packages/$ARCH_3/kiddin9"
    "modeminfo-serial-mikrotik|https://dl.openwrt.ai/releases/24.10/packages/$ARCH_3/kiddin9"
    "modeminfo-serial-dell|https://dl.openwrt.ai/releases/24.10/packages/$ARCH_3/kiddin9"
    "modeminfo-serial-sierra|https://dl.openwrt.ai/releases/24.10/packages/$ARCH_3/kiddin9"
    "modeminfo-serial-quectel|https://dl.openwrt.ai/releases/24.10/packages/$ARCH_3/kiddin9"
    "modeminfo-serial-huawei|https://dl.openwrt.ai/releases/24.10/packages/$ARCH_3/kiddin9"
    "modeminfo-serial-xmm|https://dl.openwrt.ai/releases/24.10/packages/$ARCH_3/kiddin9"
    "modeminfo-serial-telit|https://dl.openwrt.ai/releases/24.10/packages/$ARCH_3/kiddin9"
    "modeminfo-serial-fibocom|https://dl.openwrt.ai/releases/24.10/packages/$ARCH_3/kiddin9"
    "modeminfo-serial-simcom|https://dl.openwrt.ai/releases/24.10/packages/$ARCH_3/kiddin9"
    "modeminfo|https://dl.openwrt.ai/releases/24.10/packages/$ARCH_3/kiddin9"
    "luci-app-modeminfo|https://dl.openwrt.ai/releases/24.10/packages/$ARCH_3/kiddin9"
    "atinout|https://dl.openwrt.ai/releases/24.10/packages/$ARCH_3/kiddin9"
    "luci-app-poweroff|https://dl.openwrt.ai/releases/24.10/packages/$ARCH_3/kiddin9"
    "xmm-modem|https://dl.openwrt.ai/releases/24.10/packages/$ARCH_3/kiddin9"
    "luci-app-lite-watchdog|https://dl.openwrt.ai/releases/24.10/packages/$ARCH_3/kiddin9"
    "luci-theme-alpha|https://dl.openwrt.ai/releases/24.10/packages/$ARCH_3/kiddin9"
    "luci-app-adguardhome|https://dl.openwrt.ai/releases/24.10/packages/$ARCH_3/kiddin9"
    "adguardhome|https://dl.openwrt.ai/releases/24.10/packages/$ARCH_3/kiddin9"
    "luci-app-netspeedtest|https://fantastic-packages.github.io/packages/releases/$VEROP/packages/x86_64/luci"
    "sing-box|https://dl.openwrt.ai/releases/24.10/packages/$ARCH_3/kiddin9"
    "mihomo|https://dl.openwrt.ai/releases/24.10/packages/$ARCH_3/kiddin9"

    "luci-app-internet-detector|https://github.com/gSpotx2f/packages-openwrt/raw/refs/heads/master/current"
    "internet-detector|https://github.com/gSpotx2f/packages-openwrt/raw/refs/heads/master/current"
    "internet-detector-mod-modem-restart|https://github.com/gSpotx2f/packages-openwrt/raw/refs/heads/master/current"
    "luci-app-cpu-status-mini|https://github.com/gSpotx2f/packages-openwrt/raw/refs/heads/master/current"
    "luci-app-disks-info|https://github.com/gSpotx2f/packages-openwrt/raw/refs/heads/master/current"
    "luci-app-log-viewer|https://github.com/gSpotx2f/packages-openwrt/raw/refs/heads/master/current"
    "luci-app-temp-status|https://github.com/gSpotx2f/packages-openwrt/raw/refs/heads/master/current"

    "luci-app-zerotier|https://downloads.immortalwrt.org/releases/packages-$VEROP/$ARCH_3/luci"
    "luci-app-ramfree|https://downloads.immortalwrt.org/releases/packages-$VEROP/$ARCH_3/luci"
    "luci-app-3ginfo-lite|https://downloads.immortalwrt.org/releases/packages-$VEROP/$ARCH_3/luci"
    "modemband|https://downloads.immortalwrt.org/releases/packages-$VEROP/$ARCH_3/packages"
    "luci-app-modemband|https://downloads.immortalwrt.org/releases/packages-$VEROP/$ARCH_3/luci"
    "luci-app-sms-tool-js|https://downloads.immortalwrt.org/releases/packages-$VEROP/$ARCH_3/luci"
)

download_packages "custom" other_packages[@]