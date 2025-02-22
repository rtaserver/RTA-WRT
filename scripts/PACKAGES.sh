#!/bin/bash

# Source the include file containing common functions and variables
if [[ ! -f "./scripts/INCLUDE.sh" ]]; then
    log "ERROR" "INCLUDE.sh not found in ./scripts/"
    exit 1
fi

. ./scripts/INCLUDE.sh

# Initialize package arrays based on target type
declare -a packages_github
if [ "$TYPE" == "AMLOGIC" ]; then
    log "INFO" "Adding Amlogic-specific packages..."
    packages_github=(
        "luci-app-amlogic_|https://api.github.com/repos/ophub/luci-app-amlogic/releases/latest"
    )
fi

# Add core GitHub packages
packages_github+=(
    "luci-app-alpha-config|https://api.github.com/repos/animegasan/luci-app-alpha-config/releases/latest"
    "luci-theme-material3|https://api.github.com/repos/AngelaCooljx/luci-theme-material3/releases/latest"
    "luci-app-neko|https://api.github.com/repos/nosignals/openwrt-neko/releases/latest"
)

# Define repositories with proper quoting
declare -A REPOS
REPOS=(
    ["KIDDIN9"]="https://dl.openwrt.ai/releases/24.10/packages/$ARCH_3/kiddin9"
    ["IMMORTALWRT"]="https://downloads.immortalwrt.org/releases/packages-$VEROP/$ARCH_3"
    ["OPENWRT"]="https://downloads.openwrt.org/releases/packages-$VEROP/$ARCH_3"
    ["GSPOTX2F"]="https://github.com/gSpotx2f/packages-openwrt/raw/refs/heads/master/current"
    ["FANTASTIC"]="https://fantastic-packages.github.io/packages/releases/$VEROP/packages/x86_64"
)

# Define package categories with improved structure
declare -a packages_custom=(
    "modemmanager-rpcd_|${REPOS[OPENWRT]}/packages"
    "luci-proto-modemmanager|${REPOS[OPENWRT]}/luci"
    "libqmi|${REPOS[OPENWRT]}/packages"
    "libmbim|${REPOS[OPENWRT]}/packages"
    "modemmanager|${REPOS[OPENWRT]}/packages"
    "sms-tool|${REPOS[OPENWRT]}/packages"
    "tailscale|${REPOS[OPENWRT]}/packages"
    "python3-speedtest-cli|${REPOS[OPENWRT]}/packages"

    "luci-app-tailscale|${REPOS[KIDDIN9]}"
    "luci-app-diskman|${REPOS[KIDDIN9]}"
    "modeminfo-serial-zte|${REPOS[KIDDIN9]}"
    "modeminfo-serial-gosun|${REPOS[KIDDIN9]}"
    "modeminfo-qmi|${REPOS[KIDDIN9]}"
    "modeminfo-serial-yuge|${REPOS[KIDDIN9]}"
    "modeminfo-serial-thales|${REPOS[KIDDIN9]}"
    "modeminfo-serial-tw|${REPOS[KIDDIN9]}"
    "modeminfo-serial-meig|${REPOS[KIDDIN9]}"
    "modeminfo-serial-styx|${REPOS[KIDDIN9]}"
    "modeminfo-serial-mikrotik|${REPOS[KIDDIN9]}"
    "modeminfo-serial-dell|${REPOS[KIDDIN9]}"
    "modeminfo-serial-sierra|${REPOS[KIDDIN9]}"
    "modeminfo-serial-quectel|${REPOS[KIDDIN9]}"
    "modeminfo-serial-huawei|${REPOS[KIDDIN9]}"
    "modeminfo-serial-xmm|${REPOS[KIDDIN9]}"
    "modeminfo-serial-telit|${REPOS[KIDDIN9]}"
    "modeminfo-serial-fibocom|${REPOS[KIDDIN9]}"
    "modeminfo-serial-simcom|${REPOS[KIDDIN9]}"
    "modeminfo|${REPOS[KIDDIN9]}"
    "luci-app-modeminfo|${REPOS[KIDDIN9]}"
    "atinout|${REPOS[KIDDIN9]}"
    "luci-app-poweroff|${REPOS[KIDDIN9]}"
    "xmm-modem|${REPOS[KIDDIN9]}"
    "luci-app-lite-watchdog|${REPOS[KIDDIN9]}"
    "luci-theme-alpha|${REPOS[KIDDIN9]}"
    "luci-app-adguardhome|${REPOS[KIDDIN9]}"
    "sing-box|${REPOS[KIDDIN9]}"
    "mihomo|${REPOS[KIDDIN9]}"

    "luci-app-zerotier|${REPOS[IMMORTALWRT]}/luci"
    "luci-app-ramfree|${REPOS[IMMORTALWRT]}/luci"
    "luci-app-3ginfo-lite|${REPOS[IMMORTALWRT]}/luci"
    "modemband|${REPOS[IMMORTALWRT]}/packages"
    "luci-app-modemband|${REPOS[IMMORTALWRT]}/luci"
    "luci-app-sms-tool-js|${REPOS[IMMORTALWRT]}/luci"
    "dns2tcp|${REPOS[IMMORTALWRT]}/packages"
    "luci-app-argon-config|${REPOS[IMMORTALWRT]}/luci"
    "luci-theme-argon|${REPOS[IMMORTALWRT]}/luci"
    "luci-app-openclash|${REPOS[IMMORTALWRT]}/luci"
    "luci-app-passwall|${REPOS[IMMORTALWRT]}/luci"

    "luci-app-internet-detector|${REPOS[GSPOTX2F]}"
    "internet-detector|${REPOS[GSPOTX2F]}"
    "internet-detector-mod-modem-restart|${REPOS[GSPOTX2F]}"
    "luci-app-cpu-status-mini|${REPOS[GSPOTX2F]}"
    "luci-app-disks-info|${REPOS[GSPOTX2F]}"
    "luci-app-log-viewer|${REPOS[GSPOTX2F]}"
    "luci-app-temp-status|${REPOS[GSPOTX2F]}"

    "luci-app-netspeedtest|${REPOS[FANTASTIC]}/luci"
)

# Enhanced package verification function
verify_packages() {
    local pkg_dir="packages"
    local -a failed_packages=()
    local -a package_list=("${!1}")  # Fixed parameter passing
    
    if [[ ! -d "$pkg_dir" ]]; then
        log "ERROR" "Package directory not found: $pkg_dir"
        return 1
    fi
    
    local total_found=$(find "$pkg_dir" \( -name "*.ipk" -o -name "*.apk" \) | wc -l)
    log "INFO" "Found $total_found package files"
    
    for package in "${package_list[@]}"; do
        local pkg_name="${package%%|*}"
        if ! find "$pkg_dir" \( -name "${pkg_name}*.ipk" -o -name "${pkg_name}*.apk" \) -print -quit | grep -q .; then
            failed_packages+=("$pkg_name")
        fi
    done
    
    local failed=${#failed_packages[@]}
    
    if ((failed > 0)); then
        log "WARNING" "$failed packages failed to download:"
        printf '%s\n' "${failed_packages[@]}" | while read -r pkg; do
            log "WARNING" "  - $pkg"
        done
        return 1
    fi
    
    log "SUCCESS" "All packages downloaded successfully"
    return 0
}

# Main execution
main() {
    local rc=0
    
    # Download GitHub packages
    log "INFO" "Downloading GitHub packages..."
    download_packages "github" packages_github[@] || rc=1
    
    # Download Custom packages
    log "INFO" "Downloading Custom packages..."
    download_packages "custom" packages_custom[@] || rc=1
    
    # Verify all downloads
    log "INFO" "Verifying all packages..."
    verify_packages packages_github[@] || rc=1
    verify_packages packages_custom[@] || rc=1
    
    if [ $rc -eq 0 ]; then
        log "SUCCESS" "Package download and verification completed successfully"
    else
        log "ERROR" "Package download or verification failed"
    fi
    
    return $rc
}

# Run main function if script is not sourced
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi