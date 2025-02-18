#!/bin/bash

. ./scripts/INCLUDE.sh

# openclash_core
if [[ "$ARCH_3" == "x86_64" ]]; then
    openclash_core=$(meta_api="https://api.github.com/repos/MetaCubeX/mihomo/releases/latest" && meta_file="mihomo-linux-${ARCH_1}-compatible" && curl -s "${meta_api}" | grep "browser_download_url" | grep -oE "https.*${meta_file}-v[0-9]+\.[0-9]+\.[0-9]+\.gz" | head -n 1)
else
    openclash_core=$(meta_api="https://api.github.com/repos/MetaCubeX/mihomo/releases/latest" && meta_file="mihomo-linux-${ARCH_1}" && curl -s "${meta_api}" | grep "browser_download_url" | grep -oE "https.*${meta_file}-v[0-9]+\.[0-9]+\.[0-9]+\.gz" | head -n 1)
fi

#passwall_core
passwall_core_api="https://api.github.com/repos/xiaorouji/openwrt-passwall/releases"
passwall_core_file_zip="passwall_packages_ipk_${ARCH_3}"
passwall_core_file_zip_down=$(curl -s "${passwall_core_api}" | grep "browser_download_url" | grep -oE "https.*${passwall_core_file_zip}.*.zip" | head -n 1)

# Nikki
nikki_api="https://api.github.com/repos/rizkikotet-dev/OpenWrt-nikki-Mod/releases"
nikki_file_ipk="nikki_${ARCH_3}-openwrt-${CURVER}"
nikki_file_ipk_down=$(curl -s "${nikki_api}" | grep "browser_download_url" | grep -oE "https.*${nikki_file_ipk}.*.tar.gz" | head -n 1)


case "$1" in
    openclash)
        echo "Downloading Openclash packages"
        download_packages "custom" "luci-app-openclash|https://downloads.immortalwrt.org/releases/packages-$VEROP/$ARCH_3/luci"
        ariadl "${clash_meta}" "files/etc/openclash/core/clash_meta.gz"
        gzip -d "files/etc/openclash/core/clash_meta.gz" || error_msg "Error: Failed to extract OpenClash package."
        ;;
    passwall)
        echo "Downloading Passwall packages ipk"
        download_packages "custom" "luci-app-passwall|https://downloads.immortalwrt.org/releases/packages-$VEROP/$ARCH_3/luci"
        ariadl "${passwall_core_file_zip_down}" "packages/passwall.zip"
        unzip -qq "packages/passwall.zip" -d packages && rm "packages/passwall.zip" || error_msg "Error: Failed to extract Passwall package."
        ;;
    nikki)
        echo "Downloading Nikki packages ipk"
        download_packages "custom" "luci-app-passwall|https://downloads.immortalwrt.org/releases/packages-$VEROP/$ARCH_3/luci"
        ariadl "${nikki_file_ipk_down}" "packages/nikki.tar.gz"
        tar -xzvf "packages/nikki.tar.gz" > /dev/null 2>&1 && rm "packages/nikki.tar.gz" || error_msg "Error: Failed to extract Nikki package."
        ;;
    openclash-passwall-nikki)
        echo "Installing Openclash, Passwall And Nikki"
        echo "Downloading Openclash packages"
        download_packages "custom" "luci-app-openclash|https://downloads.immortalwrt.org/releases/packages-$VEROP/$ARCH_3/luci"
        ariadl "${clash_meta}" "files/etc/openclash/core/clash_meta.gz"
        gzip -d "files/etc/openclash/core/clash_meta.gz" || error_msg "Error: Failed to extract OpenClash package."
        echo "Downloading Passwall packages ipk"
        download_packages "custom" "luci-app-passwall|https://downloads.immortalwrt.org/releases/packages-$VEROP/$ARCH_3/luci"
        ariadl "${passwall_core_file_zip_down}" "packages/passwall.zip"
        unzip -qq "packages/passwall.zip" -d packages && rm "packages/passwall.zip" || error_msg "Error: Failed to extract Passwall package."
        echo "Downloading Nikki packages ipk"
        download_packages "custom" "luci-app-passwall|https://downloads.immortalwrt.org/releases/packages-$VEROP/$ARCH_3/luci"
        ariadl "${nikki_file_ipk_down}" "packages/nikki.tar.gz"
        tar -xzvf "packages/nikki.tar.gz" > /dev/null 2>&1 && rm "packages/nikki.tar.gz" || error_msg "Error: Failed to extract Nikki package."
        ;;
    *)
        echo "Invalid option. Usage: $0 {openclash|passwall|nikki|openclash-passwall-nikki}"
        exit 1
        ;;
esac 

if [ "$?" -ne 0 ]; then
    echo "Error: Download or extraction failed."
    exit 1
else
    echo "Download complete."
fi
