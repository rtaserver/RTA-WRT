#!/bin/bash

# Source the include file containing common functions and variables
. ./scripts/INCLUDE.sh

# Initialize package arrays based on target type
declare -a github_packages
if [ "$TYPE" == "AMLOGIC" ]; then
    echo -e "${INFO} Adding Amlogic-specific packages..."
    github_packages+=(
        "luci-app-amlogic|https://api.github.com/repos/ophub/luci-app-amlogic/releases/latest"
    )
fi

# Core GitHub packages
github_packages+=(
    "luci-app-alpha-config|https://api.github.com/repos/animegasan/luci-app-alpha-config/releases/latest"
    "luci-theme-material3|https://api.github.com/repos/AngelaCooljx/luci-theme-material3/releases/latest"
    "luci-app-neko|https://api.github.com/repos/nosignals/openwrt-neko/releases/latest"
)

# Download GitHub packages
echo -e "${INFO} Downloading GitHub packages..."
download_packages "github" github_packages[@]

# Define package repositories
KIDDIN9_REPO="https://dl.openwrt.ai/releases/24.10/packages/$ARCH_3/kiddin9"
GSPOTX2F_REPO="https://github.com/gSpotx2f/packages-openwrt/raw/refs/heads/master/current"

# Define package categories
declare -A package_categories=(
    ["openwrt"]="
        modemmanager-rpcd|https://downloads.openwrt.org/releases/packages-24.10/$ARCH_3/packages
        luci-proto-modemmanager|https://downloads.openwrt.org/releases/packages-24.10/$ARCH_3/luci
        libqmi|https://downloads.openwrt.org/releases/packages-24.10/$ARCH_3/packages
        libmbim|https://downloads.openwrt.org/releases/packages-24.10/$ARCH_3/packages
        modemmanager|https://downloads.openwrt.org/releases/packages-24.10/$ARCH_3/packages
        sms-tool|https://downloads.openwrt.org/releases/packages-$VEROP/$ARCH_3/packages
        tailscale|https://downloads.openwrt.org/releases/packages-$VEROP/$ARCH_3/packages 
        python3-speedtest-cli|https://downloads.openwrt.org/releases/packages-$VEROP/$ARCH_3/packages     
    "
    ["kiddin9"]="
        luci-app-tailscale|https://dl.openwrt.ai/releases/24.10/packages/$ARCH_3/kiddin9
        luci-app-diskman|https://dl.openwrt.ai/releases/24.10/packages/$ARCH_3/kiddin9
        modeminfo-serial-zte|https://dl.openwrt.ai/releases/24.10/packages/$ARCH_3/kiddin9
        modeminfo-serial-gosun|https://dl.openwrt.ai/releases/24.10/packages/$ARCH_3/kiddin9
        modeminfo-qmi|https://dl.openwrt.ai/releases/24.10/packages/$ARCH_3/kiddin9
        modeminfo-serial-yuge|https://dl.openwrt.ai/releases/24.10/packages/$ARCH_3/kiddin9
        modeminfo-serial-thales|https://dl.openwrt.ai/releases/24.10/packages/$ARCH_3/kiddin9
        modeminfo-serial-tw|https://dl.openwrt.ai/releases/24.10/packages/$ARCH_3/kiddin9
        modeminfo-serial-meig|https://dl.openwrt.ai/releases/24.10/packages/$ARCH_3/kiddin9
        modeminfo-serial-styx|https://dl.openwrt.ai/releases/24.10/packages/$ARCH_3/kiddin9
        modeminfo-serial-mikrotik|https://dl.openwrt.ai/releases/24.10/packages/$ARCH_3/kiddin9
        modeminfo-serial-dell|https://dl.openwrt.ai/releases/24.10/packages/$ARCH_3/kiddin9
        modeminfo-serial-sierra|https://dl.openwrt.ai/releases/24.10/packages/$ARCH_3/kiddin9
        modeminfo-serial-quectel|https://dl.openwrt.ai/releases/24.10/packages/$ARCH_3/kiddin9
        modeminfo-serial-huawei|https://dl.openwrt.ai/releases/24.10/packages/$ARCH_3/kiddin9
        modeminfo-serial-xmm|https://dl.openwrt.ai/releases/24.10/packages/$ARCH_3/kiddin9
        modeminfo-serial-telit|https://dl.openwrt.ai/releases/24.10/packages/$ARCH_3/kiddin9
        modeminfo-serial-fibocom|https://dl.openwrt.ai/releases/24.10/packages/$ARCH_3/kiddin9
        modeminfo-serial-simcom|https://dl.openwrt.ai/releases/24.10/packages/$ARCH_3/kiddin9
        modeminfo|https://dl.openwrt.ai/releases/24.10/packages/$ARCH_3/kiddin9
        luci-app-modeminfo|https://dl.openwrt.ai/releases/24.10/packages/$ARCH_3/kiddin9
        atinout|https://dl.openwrt.ai/releases/24.10/packages/$ARCH_3/kiddin9
        luci-app-poweroff|https://dl.openwrt.ai/releases/24.10/packages/$ARCH_3/kiddin9
        xmm-modem|https://dl.openwrt.ai/releases/24.10/packages/$ARCH_3/kiddin9
        luci-app-lite-watchdog|https://dl.openwrt.ai/releases/24.10/packages/$ARCH_3/kiddin9
        luci-theme-alpha|https://dl.openwrt.ai/releases/24.10/packages/$ARCH_3/kiddin9
        luci-app-adguardhome|https://dl.openwrt.ai/releases/24.10/packages/$ARCH_3/kiddin9
        adguardhome|https://dl.openwrt.ai/releases/24.10/packages/$ARCH_3/kiddin9
        sing-box|https://dl.openwrt.ai/releases/24.10/packages/$ARCH_3/kiddin9
        mihomo|https://dl.openwrt.ai/releases/24.10/packages/$ARCH_3/kiddin9
    "
    ["immortalwrt"]="
        luci-app-zerotier|https://downloads.immortalwrt.org/releases/packages-$VEROP/$ARCH_3/luci
        luci-app-ramfree|https://downloads.immortalwrt.org/releases/packages-$VEROP/$ARCH_3/luci
        luci-app-3ginfo-lite|https://downloads.immortalwrt.org/releases/packages-$VEROP/$ARCH_3/luci
        modemband|https://downloads.immortalwrt.org/releases/packages-$VEROP/$ARCH_3/packages
        luci-app-modemband|https://downloads.immortalwrt.org/releases/packages-$VEROP/$ARCH_3/luci
        luci-app-sms-tool-js|https://downloads.immortalwrt.org/releases/packages-$VEROP/$ARCH_3/luci
        dns2tcp|https://downloads.immortalwrt.org/releases/packages-$VEROP/$ARCH_3/packages
        luci-app-argon-config|https://downloads.immortalwrt.org/releases/packages-$VEROP/$ARCH_3/luci
        luci-theme-argon|https://downloads.immortalwrt.org/releases/packages-$VEROP/$ARCH_3/luci
        luci-app-openclash|https://downloads.immortalwrt.org/releases/packages-$VEROP/$ARCH_3/luci
        luci-app-passwall|https://downloads.immortalwrt.org/releases/packages-$VEROP/$ARCH_3/luci
    "
    ["gSpotx2f"]="
        luci-app-internet-detector|https://github.com/gSpotx2f/packages-openwrt/raw/refs/heads/master/current
        internet-detector|https://github.com/gSpotx2f/packages-openwrt/raw/refs/heads/master/current
        internet-detector-mod-modem-restart|https://github.com/gSpotx2f/packages-openwrt/raw/refs/heads/master/current
        luci-app-cpu-status-mini|https://github.com/gSpotx2f/packages-openwrt/raw/refs/heads/master/current
        luci-app-disks-info|https://github.com/gSpotx2f/packages-openwrt/raw/refs/heads/master/current
        luci-app-log-viewer|https://github.com/gSpotx2f/packages-openwrt/raw/refs/heads/master/current
        luci-app-temp-status|https://github.com/gSpotx2f/packages-openwrt/raw/refs/heads/master/current
    "
    ["etc"]="
        luci-app-netspeedtest|https://fantastic-packages.github.io/packages/releases/$VEROP/packages/x86_64/luci
    "
)

# Process and download packages by category
declare -a all_packages
for category in "${!package_categories[@]}"; do
    echo -e "${INFO} Processing $category packages..."
    while read -r package_line; do
        [[ -z "$package_line" ]] && continue
        all_packages+=("$package_line")
    done <<< "${package_categories[$category]}"
done

# Download all packages
echo -e "${INFO} Downloading custom packages..."
download_packages "custom" all_packages[@]

# Verify downloads
echo -e "${INFO} Verifying downloaded packages..."
verify_packages() {
    local pkg_dir="packages"
    local total_pkgs=$(find "$pkg_dir" -name "*.ipk" | wc -l)
    echo -e "${INFO} Total packages downloaded: $total_pkgs"
    
    # List any failed downloads
    local failed=0
    for pkg in "${all_packages[@]}"; do
        local pkg_name="${pkg%%|*}"
        if ! find "$pkg_dir" -name "${pkg_name}*.ipk" >/dev/null 2>&1; then
            echo -e "${WARNING} Package not found: $pkg_name"
            ((failed++))
        fi
    done
    
    if [ $failed -eq 0 ]; then
        echo -e "${SUCCESS} All packages downloaded successfully"
    else
        echo -e "${WARNING} $failed package(s) failed to download"
    fi
}

verify_packages