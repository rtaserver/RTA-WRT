#!/bin/bash

echo "Current Path: $PWD"

echo "Start Clash Core Download !"
#core download url
core_dir="${1:-files/etc/openclash/core}"
ARCH_1="${2:-$ARCH_1}"
clash="https://github.com/vernesong/OpenClash/raw/core/master/dev/clash-linux-$ARCH_1.tar.gz"
clash_tun="https://github.com/vernesong/OpenClash/raw/core/master/premium/$(curl -s "https://github.com/vernesong/OpenClash/tree/core/master/premium" | grep -o "clash-linux-$ARCH_1-[0-9]*\.[0-9]*\.[0-9]*-[0-9]*-[a-zA-Z0-9]*\.gz" | awk 'NR==1 {print $1}')"
if [[ "${3:-$ARCH_2}" == "x86_64" ]]; then
  clash_meta="$(meta_api="https://api.github.com/repos/MetaCubeX/mihomo/releases/latest" && meta_file="mihomo-linux-$ARCH_1-compatible" && curl -s ${meta_api} | grep "browser_download_url" | grep -oE "https.*${meta_file}-v[0-9]+\.[0-9]+\.[0-9]+\.gz" | head -n 1)"
else
  clash_meta="$(meta_api="https://api.github.com/repos/MetaCubeX/mihomo/releases/latest" && meta_file="mihomo-linux-$ARCH_1" && curl -s ${meta_api} | grep "browser_download_url" | grep -oE "https.*${meta_file}-v[0-9]+\.[0-9]+\.[0-9]+\.gz" | head -n 1)"
fi

mkdir -p $core_dir
echo "Downloading clash.tar.gz..."
if wget --no-check-certificate -nv -O $core_dir/clash.tar.gz $clash; then
   tar -zxf $core_dir/clash.tar.gz -C $core_dir && rm $core_dir/clash.tar.gz
   echo "clash.tar.gz downloaded and extracted successfully."
else
   echo "Failed to download clash.tar.gz."
fi
   
echo "Downloading clash_meta.gz..."
if wget --no-check-certificate -nv -O $core_dir/clash_meta.gz $clash_meta; then
   gzip -d $core_dir/clash_meta.gz
   echo "clash_meta.gz downloaded successfully."
else
   echo "Failed to download clash_meta.gz."
fi
   
echo "Downloading clash_tun.gz..."
if wget --no-check-certificate -nv -O $core_dir/clash_tun.gz $clash_tun; then
   gzip -d $core_dir/clash_tun.gz
   echo "clash_tun.gz downloaded successfully."
else
   echo "Failed to download clash_tun.gz."
fi

ls -l $core_dir
echo "All Core Downloaded succesfully"
