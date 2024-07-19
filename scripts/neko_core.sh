#!/bin/bash

echo "Current Path: $PWD"
echo "Start Neko Core Download !"
#core download url
neko_dir="files/etc/neko"

core_ver="neko"
url_core="https://github.com/nosignals/neko/releases/download/core_neko"
url_geo="https://github.com/MetaCubeX/meta-rules-dat/releases/download/latest"

geoip_path="${neko_dir}/geoip.metadb"
geosite_path="${neko_dir}/geosite.db"
neko_bin="${neko_dir}/core/mihomo"

mkdir -p "$neko_dir/core"

rpid=`pgrep "neko/core"`
if [[ -n $rpid ]] ; then
    kill $rpid 
fi

echo "[ `date +%T` ] - Checking Files"

if [ -f ${neko_bin} ]; then
    echo "[ `date +%T` ] - Mihomo OK"
else
    echo "[ `date +%T` ] - Downloading Mihomo Binary - $ARCH_1"
    wget -q --no-check-certificate -O ${neko_dir}/core/mihomo.gz ${url_core}/mihomo-linux-${ARCH_1}-${core_ver}.gz
    gzip -d ${neko_dir}/core/mihomo.gz
fi

if [ -f ${geoip_path} ]; then
    echo "[ `date +%T` ] - GeoIP OK"
else
    echo "[ `date +%T` ] - Downloading GeoIP"
    wget -q --no-check-certificate -O ${geoip_path} ${url_geo}/geoip.metadb
fi

if [ -f ${geosite_path} ]; then
    echo "[ `date +%T` ] - GeoSite OK"
else
    echo "[ `date +%T` ] - Downloading GeoSite"
    wget -q --no-check-certificate -O ${geosite_path} ${url_geo}/geosite.db
fi
