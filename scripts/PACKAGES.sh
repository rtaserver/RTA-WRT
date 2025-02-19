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
    ["modem"]="
        modemmanager-rpcd|https://downloads.openwrt.org/releases/packages-24.10/$ARCH_3/packages
        luci-proto-modemmanager|https://downloads.openwrt.org/releases/packages-24.10/$ARCH_3/luci
        libqmi|https://downloads.openwrt.org/releases/packages-24.10/$ARCH_3/packages
        libmbim|https://downloads.openwrt.org/releases/packages-24.10/$ARCH_3/packages
        modemmanager|https://downloads.openwrt.org/releases/packages-24.10/$ARCH_3/packages
        sms-tool|https://downloads.openwrt.org/releases/packages-$VEROP/$ARCH_3/packages
    "
    ["network"]="
        tailscale|https://downloads.openwrt.org/releases/packages-$VEROP/$ARCH_3/packages
        python3-speedtest-cli|https://downloads.openwrt.org/releases/releases/packages-$VEROP/$ARCH_3/packages
        dns2tcp|https://downloads.immortalwrt.org/releases/packages-$VEROP/$ARCH_3/packages
    "
    ["themes"]="
        luci-app-argon-config|https://downloads.immortalwrt.org/releases/packages-$VEROP/$ARCH_3/luci
        luci-theme-argon|https://downloads.immortalwrt.org/releases/packages-$VEROP/$ARCH_3/luci
        luci-theme-alpha|$KIDDIN9_REPO
    "
    ["vpn"]="
        luci-app-openclash|https://downloads.immortalwrt.org/releases/packages-$VEROP/$ARCH_3/luci
        luci-app-passwall|https://downloads.immortalwrt.org/releases/packages-$VEROP/$ARCH_3/luci
        luci-app-tailscale|$KIDDIN9_REPO
    "
)

# Modeminfo packages from Kiddin9 repo
MODEMINFO_VARIANTS=(
    "zte" "gosun" "qmi" "yuge" "thales" "tw" "meig" "styx" "mikrotik" 
    "dell" "sierra" "quectel" "huawei" "xmm" "telit" "fibocom" "simcom"
)

for variant in "${MODEMINFO_VARIANTS[@]}"; do
    package_categories["modem"]+="
        modeminfo-serial-$variant|$KIDDIN9_REPO
    "
done

# Additional utility packages
package_categories["utils"]="
    luci-app-diskman|$KIDDIN9_REPO
    luci-app-poweroff|$KIDDIN9_REPO
    xmm-modem|$KIDDIN9_REPO
    luci-app-lite-watchdog|$KIDDIN9_REPO
    luci-app-adguardhome|$KIDDIN9_REPO
    adguardhome|$KIDDIN9_REPO
    luci-app-netspeedtest|$KIDDIN9_REPO
    sing-box|$KIDDIN9_REPO
    mihomo|$KIDDIN9_REPO
"

# System monitoring packages
package_categories["monitoring"]="
    luci-app-internet-detector|$GSPOTX2F_REPO
    internet-detector|$GSPOTX2F_REPO
    internet-detector-mod-modem-restart|$GSPOTX2F_REPO
    luci-app-cpu-status-mini|$GSPOTX2F_REPO
    luci-app-disks-info|$GSPOTX2F_REPO
    luci-app-log-viewer|$GSPOTX2F_REPO
    luci-app-temp-status|$GSPOTX2F_REPO
"

# Additional ImmortalWRT packages
package_categories["immortalwrt"]="
    luci-app-zerotier|https://downloads.immortalwrt.org/releases/packages-$VEROP/$ARCH_3/luci
    luci-app-ramfree|https://downloads.immortalwrt.org/releases/packages-$VEROP/$ARCH_3/luci
    luci-app-3ginfo-lite|https://downloads.immortalwrt.org/releases/packages-$VEROP/$ARCH_3/luci
    modemband|https://downloads.immortalwrt.org/releases/packages-$VEROP/$ARCH_3/packages
    luci-app-modemband|https://downloads.immortalwrt.org/releases/packages-$VEROP/$ARCH_3/luci
    luci-app-sms-tool-js|https://downloads.immortalwrt.org/releases/packages-$VEROP/$ARCH_3/luci
"

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
