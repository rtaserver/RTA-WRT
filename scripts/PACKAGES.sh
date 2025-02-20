#!/bin/bash

# Source the include file containing common functions and variables
if [[ ! -f "./scripts/INCLUDE.sh" ]]; then
    echo "Error: INCLUDE.sh not found in ./scripts/"
    exit 1
fi

. ./scripts/INCLUDE.sh

# Setup logging for this script
readonly SCRIPT_LOG="${CONFIG[LOG_DIR]}/package-downloader.log"
log "INFO" "Starting package download script"

# Validate required variables
required_vars=("TYPE" "ARCH_3" "VEROP")
for var in "${required_vars[@]}"; do
    if [[ -z "${!var}" ]]; then
        log "ERROR" "Required variable $var is not set"
        exit 1
    fi
done

# Initialize arrays with type declarations
declare -A REPOS
declare -a github_packages

# Define repositories
REPOS=(
    ["KIDDIN9"]="https://dl.openwrt.ai/releases/24.10/packages/$ARCH_3/kiddin9"
    ["IMMORTALWRT"]="https://downloads.immortalwrt.org/releases/packages-$VEROP/$ARCH_3"
    ["OPENWRT"]="https://downloads.openwrt.org/releases/packages-$VEROP/$ARCH_3"
    ["GSPOTX2F"]="https://github.com/gSpotx2f/packages-openwrt/raw/refs/heads/master/current"
    ["FANTASTIC"]="https://fantastic-packages.github.io/packages/releases/$VEROP/packages/x86_64"
)

# Initialize package arrays based on target type
if [[ "$TYPE" == "AMLOGIC" ]]; then
    log "INFO" "Adding Amlogic-specific packages..."
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

# Define package categories with improved structure
declare -A package_categories=(
    ["openwrt"]="
        modemmanager-rpcd|${REPOS[OPENWRT]}/packages
        luci-proto-modemmanager|${REPOS[OPENWRT]}/luci
        libqmi|${REPOS[OPENWRT]}/packages
        libmbim|${REPOS[OPENWRT]}/packages
        modemmanager|${REPOS[OPENWRT]}/packages
        sms-tool|${REPOS[OPENWRT]}/packages
        tailscale|${REPOS[OPENWRT]}/packages
        python3-speedtest-cli|${REPOS[OPENWRT]}/packages
    "
    ["kiddin9"]="
        luci-app-tailscale|${REPOS[KIDDIN9]}
        luci-app-diskman|${REPOS[KIDDIN9]}
        modeminfo-serial-zte|${REPOS[KIDDIN9]}
        modeminfo-serial-gosun|${REPOS[KIDDIN9]}
        modeminfo-qmi|${REPOS[KIDDIN9]}
        modeminfo-serial-yuge|${REPOS[KIDDIN9]}
        modeminfo-serial-thales|${REPOS[KIDDIN9]}
        modeminfo-serial-tw|${REPOS[KIDDIN9]}
        modeminfo-serial-meig|${REPOS[KIDDIN9]}
        modeminfo-serial-styx|${REPOS[KIDDIN9]}
        modeminfo-serial-mikrotik|${REPOS[KIDDIN9]}
        modeminfo-serial-dell|${REPOS[KIDDIN9]}
        modeminfo-serial-sierra|${REPOS[KIDDIN9]}
        modeminfo-serial-quectel|${REPOS[KIDDIN9]}
        modeminfo-serial-huawei|${REPOS[KIDDIN9]}
        modeminfo-serial-xmm|${REPOS[KIDDIN9]}
        modeminfo-serial-telit|${REPOS[KIDDIN9]}
        modeminfo-serial-fibocom|${REPOS[KIDDIN9]}
        modeminfo-serial-simcom|${REPOS[KIDDIN9]}
        modeminfo|${REPOS[KIDDIN9]}
        luci-app-modeminfo|${REPOS[KIDDIN9]}
        atinout|${REPOS[KIDDIN9]}
        luci-app-poweroff|${REPOS[KIDDIN9]}
        xmm-modem|${REPOS[KIDDIN9]}
        luci-app-lite-watchdog|${REPOS[KIDDIN9]}
        luci-theme-alpha|${REPOS[KIDDIN9]}
        luci-app-adguardhome|${REPOS[KIDDIN9]}
        sing-box|${REPOS[KIDDIN9]}
        mihomo|${REPOS[KIDDIN9]}
    "
    ["immortalwrt"]="
        luci-app-zerotier|${REPOS[IMMORTALWRT]}/luci
        luci-app-ramfree|${REPOS[IMMORTALWRT]}/luci
        luci-app-3ginfo-lite|${REPOS[IMMORTALWRT]}/luci
        modemband|${REPOS[IMMORTALWRT]}/packages
        luci-app-modemband|${REPOS[IMMORTALWRT]}/luci
        luci-app-sms-tool-js|${REPOS[IMMORTALWRT]}/luci
        dns2tcp|${REPOS[IMMORTALWRT]}/packages
        luci-app-argon-config|${REPOS[IMMORTALWRT]}/luci
        luci-theme-argon|${REPOS[IMMORTALWRT]}/luci
        luci-app-openclash|${REPOS[IMMORTALWRT]}/luci
        luci-app-passwall|${REPOS[IMMORTALWRT]}/luci
    "
    ["gSpotx2f"]="
        luci-app-internet-detector|${REPOS[GSPOTX2F]}
        internet-detector|${REPOS[GSPOTX2F]}
        internet-detector-mod-modem-restart|${REPOS[GSPOTX2F]}
        luci-app-cpu-status-mini|${REPOS[GSPOTX2F]}
        luci-app-disks-info|${REPOS[GSPOTX2F]}
        luci-app-log-viewer|${REPOS[GSPOTX2F]}
        luci-app-temp-status|${REPOS[GSPOTX2F]}
    "
    ["etc"]="
        luci-app-netspeedtest|${REPOS[FANTASTIC]}/luci
    "
)

# Enhanced download function for GitHub packages
download_github_packages() {
    log "INFO" "Downloading GitHub packages..."
    local failed=0
    local total=${#github_packages[@]}
    
    for package in "${github_packages[@]}"; do
        IFS="|" read -r name url <<< "$package"
        if ! download_packages "github" "$name|$url"; then
            ((failed++))
            log "ERROR" "Failed to download GitHub package: $name"
        fi
    done
    
    local success=$((total - failed))
    log "INFO" "GitHub packages: $success/$total successful"
    return $((failed > 0))
}

# Enhanced function to process package categories
process_package_categories() {
    local -a all_packages
    local total_categories=${#package_categories[@]}
    local processed=0
    
    for category in "${!package_categories[@]}"; do
        ((processed++))
        log "INFO" "Processing $category packages ($processed/$total_categories)"
        
        while read -r package_line; do
            [[ -z "$package_line" ]] && continue
            all_packages+=("$package_line")
        done <<< "${package_categories[$category]}"
    done
    
    log "INFO" "Downloading custom packages..."
    download_packages "custom" all_packages[@]
    
    echo "${all_packages[@]}"  # Return all packages for verification
}

# Enhanced package verification function
verify_packages() {
    local pkg_dir="packages"
    local -a failed_packages=()
    local total_expected=$1
    shift
    local -a package_list=("$@")
    
    if [[ ! -d "$pkg_dir" ]]; then
        log "ERROR" "Package directory not found: $pkg_dir"
        return 1
    fi
    
    local total_found=$(find "$pkg_dir" \( -name "*.ipk" -o -name "*.apk" \) | wc -l)
    log "INFO" "Found $total_found package files"
    
    for package in "${package_list[@]}"; do
        local pkg_name="${package%%|*}"
        if ! find "$pkg_dir" \( -name "${pkg_name}*.ipk" -o -name "${pkg_name}*.apk" \) >/dev/null 2>&1; then
            failed_packages+=("$pkg_name")
        fi
    done
    
    local failed=${#failed_packages[@]}
    local success=$((total_expected - failed))
    local success_rate=$((success * 100 / total_expected))
    
    log "STEPS" "Download Summary:"
    log "INFO" "Expected packages: $total_expected"
    log "INFO" "Successfully downloaded: $success ($success_rate%)"
    
    if ((failed > 0)); then
        log "WARNING" "Failed packages:"
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
    local start_time=$(date +%s)
    
    # Create necessary directories
    mkdir -p "packages" "${CONFIG[TEMP_DIR]}" "${CONFIG[LOG_DIR]}"
    
    # Download GitHub packages
    download_github_packages
    
    # Process and download category packages
    local all_packages=$(process_package_categories)
    local total_packages=$((${#github_packages[@]} + $(echo "$all_packages" | wc -w)))
    
    # Verify all downloads
    if ! verify_packages "$total_packages" "${all_packages[@]}"; then
        log "ERROR" "Package verification failed"
        return 1
    fi
    
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    log "SUCCESS" "Package download completed in $(format_time $duration)"
    return 0
}

# Run main function if script is not sourced
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
