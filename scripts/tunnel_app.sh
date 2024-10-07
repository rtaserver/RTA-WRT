#!/bin/bash

# OpenClash
openclash_api="https://api.github.com/repos/vernesong/OpenClash/releases"
openclash_file="luci-app-openclash"
openclash_file_down="$(curl -s ${openclash_api} | grep "browser_download_url" | grep -oE "https.*${openclash_file}.*.ipk" | head -n 1)"

# Passwall
passwall_api="https://api.github.com/repos/xiaorouji/openwrt-passwall/releases"
passwall_file="luci-23.05_luci-app-passwall"
passwall_file_down="$(curl -s ${passwall_api} | grep "browser_download_url" | grep -oE "https.*${passwall_file}.*.ipk" | head -n 1)"
passwall_ipk_packages="$(curl -s ${passwall_api} | grep "browser_download_url" | grep -oE "https.*passwall_packages_ipk_${ARCH_3}.zip" | head -n 1)"

# Mihomo
mihomo_api="https://api.github.com/repos/rtaserver/OpenWrt-mihomo-Mod/releases"
mihomo_file="mihomo_${ARCH_3}"
mihomo_file_down="$(curl -s ${mihomo_api} | grep "browser_download_url" | grep -oE "https.*${mihomo_file}.*.tar.gz" | head -n 1)"
                       
# Output download information
echo "Installing OpenClash, Passwall, Mihomo"
echo "Downloading OpenClash package"
wget ${openclash_file_down} -nv -P packages
if [ "$?" -ne 0 ]; then
    echo "Error: Failed to download OpenClash package."
    exit 1
fi

echo "Downloading Passwall package"
wget "$passwall_file_down" -nv -P packages
if [ "$?" -ne 0 ]; then
    echo "Error: Failed to download Passwall package."
    exit 1
fi

echo "Downloading Passwall IPK packages"
wget "${passwall_ipk_packages}" -nv -P packages
if [ "$?" -ne 0 ]; then
    echo "Error: Failed to download Passwall IPK packages."
    exit 1
fi

# Unzip Passwall packages
unzip -qq packages/"passwall_packages_ipk_${ARCH_3}.zip" -d packages && rm packages/"passwall_packages_ipk_${ARCH_3}.zip"
if [ "$?" -ne 0 ]; then
    echo "Error: Failed to unzip Passwall IPK packages."
    exit 1
fi

echo "Downloading Mihomo package"
wget "${mihomo_file_down}" -nv -P packages
if [ "$?" -ne 0 ]; then
    echo "Error: Failed to download Mihomo package."
    exit 1
fi

# Extract Mihomo package
tar -xzvf packages/"mihomo_${ARCH_3}.tar.gz" -C packages && rm packages/"mihomo_${ARCH_3}.tar.gz"
if [ "$?" -ne 0 ]; then
    echo "Error: Failed to extract Mihomo package."
    exit 1
fi

echo "Download and extraction complete."