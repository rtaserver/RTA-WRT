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
passwall_api="https://api.github.com/repos/xiaorouji/openwrt-passwall2/releases"
passwall_file="passwall2_packages_ipk_$ARCH_3.zip"
passwall_file_down="$(curl -s ${passwall_api} | grep "browser_download_url" | grep -oE "https.*${passwall_file}" | head -n 1)"
passwall_ipk="https://github.com/xiaorouji/openwrt-passwall/releases/download/4.71-2/luci-app-passwall_4.71-2_all.ipk"

# passwall2
passwall2_api="https://api.github.com/repos/rtaserver/openwrt-passwall2/releases"
passwall2_file="luci-23.05_luci-app-passwall2"
passwall2_file_down="$(curl -s ${passwall2_api} | grep "browser_download_url" | grep -oE "https.*${passwall2_file}.*.ipk" | head -n 1)"

passwall_ipk_packages=("https://github.com/lrdrdn/my-opkg-repo/raw/main/$ARCH_3/dns2socks_2.1-2_$ARCH_3.ipk"
                       "https://github.com/lrdrdn/my-opkg-repo/raw/main/$ARCH_3/dns2tcp_1.1.0-1_$ARCH_3.ipk"
                       "https://github.com/lrdrdn/my-opkg-repo/raw/main/$ARCH_3/chinadns-ng_2023.06.01-1_$ARCH_3.ipk"
                       "https://github.com/lrdrdn/my-opkg-repo/raw/main/$ARCH_3/xray-plugin_1.8.4-1_$ARCH_3.ipk"
                       "https://github.com/lrdrdn/my-opkg-repo/raw/main/$ARCH_3/trojan-plus_10.0.3-2_$ARCH_3.ipk"
                       "https://github.com/lrdrdn/my-opkg-repo/raw/main/$ARCH_3/ipt2socks_1.1.3-3_$ARCH_3.ipk"
                       "https://github.com/lrdrdn/my-opkg-repo/raw/main/$ARCH_3/pdnsd-alt_1.2.9b-par-3_$ARCH_3.ipk")
                       

if [ "$1" == "openclash" ]; then
    echo "Downloading Openclash packages"
    wget ${openclash_file_down} -nv -P packages
elif [ "$1" == "neko" ]; then
    echo "Downloading Neko packages"
    wget "${neko_file_down}" -nv -P packages
elif [ "$1" == "passwall" ]; then
    echo "Downloading Passwall packages ipk"
    wget "$passwall_file_down" -nv -P packages
    wget "$passwall_ipk" -nv -P packages
    wget "${passwall_ipk_packages[@]}" -nv -P packages
    wget "${passwall2_file_down}" -nv -P packages
    unzip -qq packages/"$passwall_file" -d packages && rm packages/"$passwall_file"
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
    wget "$passwall_ipk" -nv -P packages
    wget "${passwall_ipk_packages[@]}" -nv -P packages
    wget "${passwall2_file_down}" -nv -P packages
    unzip -qq packages/"$passwall_file" -d packages && rm packages/"$passwall_file"
elif [ "$1" == "neko-passwall" ]; then
    echo "Installing Neko and Passwall"
    echo "Downloading Neko packages"
    wget "${neko_file_down}" -nv -P packages
    echo "Downloading Passwall packages ipk"
    wget "$passwall_file_down" -nv -P packages
    wget "$passwall_ipk" -nv -P packages
    wget "${passwall_ipk_packages[@]}" -nv -P packages
    wget "${passwall2_file_down}" -nv -P packages
    unzip -qq packages/"$passwall_file" -d packages && rm packages/"$passwall_file"
elif [ "$1" == "openclash-passwall-neko" ]; then
    echo "Installing Openclash, Neko and Passwall"
    echo "Downloading Openclash packages"
    wget ${openclash_file_down} -nv -P packages
    echo "Downloading Neko packages"
    wget "${neko_file_down}" -nv -P packages
    echo "Downloading Passwall packages ipk"
    wget "$passwall_file_down" -nv -P packages
    wget "$passwall_ipk" -nv -P packages
    wget "${passwall_ipk_packages[@]}" -nv -P packages
    wget "${passwall2_file_down}" -nv -P packages
    unzip -qq packages/"$passwall_file" -d packages && rm packages/"$passwall_file"
fi 
if [ "$?" -ne 0 ]; then
    echo "Error: Download or extraction failed."
    exit 1
else
    echo "Download complete."
fi
