#!/bin/bash

# openclash
openclash_api="https://api.github.com/repos/vernesong/OpenClash/releases"
openclash_file="luci-app-openclash"
openclash_file_down="$(curl -s ${openclash_api} | grep "browser_download_url" | grep -oE "https.*${openclash_file}.*.ipk" | head -n 1)"

# passwall
passwall_api="https://api.github.com/repos/xiaorouji/openwrt-passwall/releases"
passwall_file="luci-23.05_luci-app-passwall"
passwall_file_down="$(curl -s ${passwall_api} | grep "browser_download_url" | grep -oE "https.*${passwall_file}.*.ipk" | head -n 1)"
passwall_ipk_packages="$(curl -s ${passwall_api} | grep "browser_download_url" | grep -oE "https.*passwall_packages_ipk_$ARCH_3.zip" | head -n 1)"
                       
echo "Installing Openclash and Passwall"
echo "Downloading Openclash packages"
wget ${openclash_file_down} -nv -P packages
echo "Downloading Passwall packages ipk"
wget "$passwall_file_down" -nv -P packages
wget "${passwall_ipk_packages}" -nv -P packages
unzip -qq packages/"passwall_packages_ipk_$ARCH_3.zip" -d packages && rm packages/"passwall_packages_ipk_$ARCH_3.zip"


if [ "$?" -ne 0 ]; then
    echo "Error: Download or extraction failed."
    exit 1
else
    echo "Download complete."
fi