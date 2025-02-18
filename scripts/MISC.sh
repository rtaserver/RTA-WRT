#!/bin/bash

. ./scripts/INCLUDE.sh

echo "Start Downloading Misc files and setup configuration!"
echo "Current Path: $PWD"

#setup custom setting for openwrt and immortalwrt
sed -i "s/Ouc3kNF6/$DATE/g" files/etc/uci-defaults/99-init-settings.sh
if [[ "$BASE" == "openwrt" ]]; then
    echo "$BASE"
    sed -i '/# setup misc settings/ a\mv \/www\/luci-static\/resources\/view\/status\/include\/29_temp.js \/www\/luci-static\/resources\/view\/status\/include\/17_temp.js' files/etc/uci-defaults/99-init-settings.sh
elif [[ "$BASE" == "immortalwrt" ]]; then
    echo "$BASE"
fi

if [ "$TYPE" == "AMLOGIC" ]; then
    rm files/etc/uci-defaults/70-rootpt-resize
    rm files/etc/uci-defaults/80-rootfs-resize
    rm files/etc/sysupgrade.conf
fi

# add yout custom command for specific target and release branch version here
if [ "$(echo "$BRANCH" | cut -d'.' -f1)" == "24" ]; then
    echo "$BRANCH"
elif [ "$(echo "$BRANCH" | cut -d'.' -f1)" == "23" ]; then
    echo "$BRANCH"
fi

if [ "$TYPE" == "AMLOGIC" ]; then
    sed -i '/# setup misc settings/ a\chmod +x /lib/netifd/proto/3g.sh' files/etc/uci-defaults/99-init-settings.sh
    sed -i '/# setup misc settings/ a\chmod +x /lib/netifd/proto/dhcp.sh' files/etc/uci-defaults/99-init-settings.sh
    sed -i '/# setup misc settings/ a\chmod +x /lib/netifd/proto/dhcpv6.sh' files/etc/uci-defaults/99-init-settings.sh
    sed -i '/# setup misc settings/ a\chmod +x /lib/netifd/proto/ncm.sh' files/etc/uci-defaults/99-init-settings.sh
    sed -i '/# setup misc settings/ a\chmod +x /lib/netifd/proto/wwan.sh' files/etc/uci-defaults/99-init-settings.sh
    sed -i '/# setup misc settings/ a\chmod +x /lib/netifd/wireless/mac80211.sh' files/etc/uci-defaults/99-init-settings.sh
    sed -i '/# setup misc settings/ a\chmod +x /lib/netifd/dhcp-get-server.sh' files/etc/uci-defaults/99-init-settings.sh
    sed -i '/# setup misc settings/ a\chmod +x /lib/netifd/dhcp.script' files/etc/uci-defaults/99-init-settings.sh
    sed -i '/# setup misc settings/ a\chmod +x /lib/netifd/dhcpv6.script' files/etc/uci-defaults/99-init-settings.sh
    sed -i '/# setup misc settings/ a\chmod +x /lib/netifd/hostapd.sh' files/etc/uci-defaults/99-init-settings.sh
    sed -i '/# setup misc settings/ a\chmod +x /lib/netifd/netifd-proto.sh' files/etc/uci-defaults/99-init-settings.sh
    sed -i '/# setup misc settings/ a\chmod +x /lib/netifd/netifd-wireless.sh' files/etc/uci-defaults/99-init-settings.sh
    sed -i '/# setup misc settings/ a\chmod +x /lib/netifd/utils.sh' files/etc/uci-defaults/99-init-settings.sh
    sed -i '/# setup misc settings/ a\chmod +x /lib/wifi/mac80211.sh' files/etc/uci-defaults/99-init-settings.sh
else
    rm -rf files/lib
fi

# custom script files urls
echo "Downloading custom script" 
sync_time="https://raw.githubusercontent.com/frizkyiman/auto-sync-time/main/sbin/sync_time.sh"
clock="https://raw.githubusercontent.com/frizkyiman/auto-sync-time/main/usr/bin/clock"
repair_ro="https://raw.githubusercontent.com/frizkyiman/fix-read-only/main/install2.sh"

wget --no-check-certificate -nv -P files/sbin "$sync_time"
wget --no-check-certificate -nv -P files/usr/bin "$clock"
wget --no-check-certificate -nv -P files/root "$repair_ro"

echo "All custom configuration setup completed!"