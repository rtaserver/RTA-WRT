#!/bin/bash

. ./scripts/INCLUDE.sh

# openclash_core URL generation
if [[ "$ARCH_3" == "x86_64" ]]; then
    meta_file="mihomo-linux-${ARCH_1}-compatible"
else
    meta_file="mihomo-linux-${ARCH_1}"
fi
openclash_core=$(curl -s "https://api.github.com/repos/MetaCubeX/mihomo/releases/latest" | grep "browser_download_url" | grep -oE "https.*${meta_file}-v[0-9]+\.[0-9]+\.[0-9]+\.gz" | head -n 1)

# passwall_core URL generation
passwall_core_file_zip="passwall_packages_ipk_${ARCH_3}"
passwall_core_file_zip_down=$(curl -s "https://api.github.com/repos/xiaorouji/openwrt-passwall/releases" | grep "browser_download_url" | grep -oE "https.*${passwall_core_file_zip}.*.zip" | head -n 1)

# Nikki URL generation
nikki_file_ipk="nikki_${ARCH_3}-openwrt-${VEROP}"
nikki_file_ipk_down=$(curl -s "https://api.github.com/repos/rizkikotet-dev/OpenWrt-nikki-Mod/releases" | grep "browser_download_url" | grep -oE "https.*${nikki_file_ipk}.*.tar.gz" | head -n 1)

# Package repositories
declare -a openclash_ipk=("luci-app-openclash|https://downloads.immortalwrt.org/releases/packages-$VEROP/$ARCH_3/luci")
declare -a passwall_ipk=("luci-app-passwall|https://downloads.immortalwrt.org/releases/packages-$VEROP/$ARCH_3/luci")

# Function to download and setup OpenClash
setup_openclash() {
    log "INFO" "Downloading OpenClash packages"
    download_packages openclash_ipk[@]
    ariadl "${openclash_core}" "files/etc/openclash/core/clash_meta.gz"
    gzip -d "files/etc/openclash/core/clash_meta.gz" || error_msg "Error: Failed to extract OpenClash package."
}

# Function to download and setup PassWall
setup_passwall() {
    log "INFO" "Downloading PassWall packages"
    download_packages passwall_ipk[@]
    ariadl "${passwall_core_file_zip_down}" "packages/passwall.zip"
    unzip -qq "packages/passwall.zip" -d packages && rm "packages/passwall.zip" || error_msg "Error: Failed to extract PassWall package."
}

# Function to download and setup Nikki
setup_nikki() {
    log "INFO" "Downloading Nikki packages"
    ariadl "${nikki_file_ipk_down}" "packages/nikki.tar.gz"
    tar -xzvf "packages/nikki.tar.gz" -C packages > /dev/null 2>&1 && rm "packages/nikki.tar.gz" || error_msg "Error: Failed to extract Nikki package."
}

# Main installation logic
remove_icons() {
    local icons=("$@")
    local paths=(
        "files/usr/share/ucode/luci/template/themes/material/header.ut"
        "files/usr/lib/lua/luci/view/themes/argon/header.htm"
    )
    
    for icon in "${icons[@]}"; do
        for path in "${paths[@]}"; do
            sed -i "/${icon}/d" "$path"
        done
    done
}

case "$1" in
    openclash)
        setup_openclash
        remove_icons "passwall.png" "mihomo.png"
        ;;
    passwall)
        setup_passwall
        remove_icons "clash.png" "mihomo.png"
        ;;
    nikki)
        setup_nikki
        remove_icons "clash.png" "passwall.png"
        ;;
    openclash-passwall)
        setup_openclash
        setup_passwall
        remove_icons "mihomo.png"
        ;;
    nikki-passwall)
        setup_nikki
        setup_passwall
        remove_icons "clash.png"
        ;;
    nikki-openclash)
        setup_nikki
        setup_openclash
        remove_icons "passwall.png"
        ;;
    openclash-passwall-nikki)
        log "INFO" "Installing OpenClash, PassWall and Nikki"
        setup_openclash
        setup_passwall
        setup_nikki
        ;;
    no-tunnel)
        log "info" "Use No Tunnel"
        remove_icons "clash.png" "passwall.png" "mihomo.png"
        ;;
    *)
        log "INFO" "Invalid option. Usage: $0 {openclash|passwall|nikki|openclash-passwall|nikki-passwall|nikki-openclash|openclash-passwall-nikki}"
        exit 1
        ;;
esac

# Check final status
if [ "$?" -ne 0 ]; then
    error_msg "Download or extraction failed."
    exit 1
else
    log "INFO" "Download and installation completed successfully."
fi