#!/bin/bash

# openclash
openclash_api="https://api.github.com/repos/vernesong/OpenClash/releases"
openclash_file="luci-app-openclash"
openclash_file_down="$(curl -s ${openclash_api} | grep "browser_download_url" | grep -oE "https.*${openclash_file}.*.ipk" | head -n 1)"

# neko
neko_api="https://api.github.com/repos/nosignals/neko/releases"
neko_file="luci-app-neko"
neko_file_down="$(curl -s https://api.github.com/repos/nosignals/neko/releases/latest | jq -r '.assets[] | select(.name | endswith("_23_05.ipk")) | .browser_download_url')"

# passwall
passwall_api="https://api.github.com/repos/xiaorouji/openwrt-passwall/releases"
passwall_file="luci-23.05_luci-app-passwall"
passwall_file_down="$(curl -s ${passwall_api} | grep "browser_download_url" | grep -oE "https.*${passwall_file}.*.ipk" | head -n 1)"

passwall_ipk_packages="$(curl -s ${passwall_api} | grep "browser_download_url" | grep -oE "https.*passwall_packages_ipk_$ARCH_3.zip" | head -n 1)"
                       

if [ "$1" == "openclash" ]; then
    echo "Downloading Openclash packages"
    wget ${openclash_file_down} -nv -P packages
elif [ "$1" == "neko" ]; then
    echo "Downloading Neko packages"
    wget "${neko_file_down}" -nv -P packages
elif [ "$1" == "passwall" ]; then
    echo "Downloading Passwall packages ipk"
    wget "$passwall_file_down" -nv -P packages
    wget "${passwall_ipk_packages}" -nv -P packages
    unzip -qq packages/"passwall_packages_ipk_$ARCH_3.zip" -d packages && rm packages/"passwall_packages_ipk_$ARCH_3.zip"
    rm files/usr/bin/patchoc.sh
elif [ "$1" == "neko-openclash" ]; then
    echo "Installing Neko and Openclash"
    echo "Downloading Neko packages"
    wget "${neko_file_down}" -nv -P packages
    echo "Downloading Openclash packages"
    wget ${openclash_file_down} -nv -P packages
elif [ "$1" == "openclash-passwall" ]; then
    echo "Installing Openclash and Passwall"
    echo "Downloading Openclash packages"
    wget ${openclash_file_down} -nv -P packages
    echo "Downloading Passwall packages ipk"
    wget "$passwall_file_down" -nv -P packages
    wget "${passwall_ipk_packages}" -nv -P packages
    unzip -qq packages/"passwall_packages_ipk_$ARCH_3.zip" -d packages && rm packages/"passwall_packages_ipk_$ARCH_3.zip"
elif [ "$1" == "neko-passwall" ]; then
    echo "Installing Neko and Passwall"
    echo "Downloading Neko packages"
    wget "${neko_file_down}" -nv -P packages
    echo "Downloading Passwall packages ipk"
    wget "$passwall_file_down" -nv -P packages
    wget "${passwall_ipk_packages}" -nv -P packages
    unzip -qq packages/"passwall_packages_ipk_$ARCH_3.zip" -d packages && rm packages/"passwall_packages_ipk_$ARCH_3.zip"
elif [ "$1" == "openclash-passwall-neko" ]; then
    echo "Installing Openclash, Neko and Passwall"
    echo "Downloading Openclash packages"
    wget ${openclash_file_down} -nv -P packages
    echo "Downloading Neko packages"
    wget "${neko_file_down}" -nv -P packages
    echo "Downloading Passwall packages ipk"
    wget "$passwall_file_down" -nv -P packages
    wget "${passwall_ipk_packages}" -nv -P packages
    unzip -qq packages/"passwall_packages_ipk_$ARCH_3.zip" -d packages && rm packages/"passwall_packages_ipk_$ARCH_3.zip"
fi 
if [ "$?" -ne 0 ]; then
    echo "Error: Download or extraction failed."
    exit 1
else
    echo "Download complete."
fi
