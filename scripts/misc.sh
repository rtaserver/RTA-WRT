#!/bin/bash

echo "Start Downloading Misc files and setup configuration!"
echo "Current Path: $PWD"

#setup custom setting for openwrt and immortalwrt
sed -i "s/Ouc3kNF6/$DATE/g" files/etc/uci-defaults/99-init-settings.sh
echo "$BASE"
sed -i '/# setup misc settings/ a\mv \/www\/luci-static\/resources\/view\/status\/include\/29_temp.js \/www\/luci-static\/resources\/view\/status\/include\/17_temp.js' files/etc/uci-defaults/99-init-settings.sh

if [ "$TARGET" == "Raspberry Pi 4B" ]; then
    echo "$TARGET"
elif [ "$TARGET" == "x86-64" ]; then
    rm packages/luci-app-oled_1.0_all.ipk
else
    rm packages/luci-app-oled_1.0_all.ipk
fi

if [ "$TYPE" == "AMLOGIC" ]; then
    sed -i -E "s|nullwrt|amlogic|g" files/etc/uci-defaults/99-init-settings.sh
    sed -i '/# setup misc settings/ a\chmod +x /lib/netifd/dhcp-get-server.sh' files/etc/uci-defaults/99-init-settings.sh
    sed -i '/# setup misc settings/ a\chmod +x /lib/netifd/dhcp.script' files/etc/uci-defaults/99-init-settings.sh
    sed -i '/# setup misc settings/ a\chmod +x /lib/netifd/dhcpv6.script' files/etc/uci-defaults/99-init-settings.sh
    sed -i '/# setup misc settings/ a\chmod +x /lib/netifd/ppp6-up' files/etc/uci-defaults/99-init-settings.sh
    sed -i '/# setup misc settings/ a\chmod +x /lib/netifd/ppp-down' files/etc/uci-defaults/99-init-settings.sh
    sed -i '/# setup misc settings/ a\chmod +x /lib/netifd/ppp6-down' files/etc/uci-defaults/99-init-settings.sh
    sed -i '/# setup misc settings/ a\chmod +x /lib/netifd/ppp-up' files/etc/uci-defaults/99-init-settings.sh
    sed -i '/# setup misc settings/ a\chmod +x /lib/netifd/wireless/mac80211.sh' files/etc/uci-defaults/99-init-settings.sh
    sed -i '/# setup misc settings/ a\chmod +x /lib/netifd/proto/dhcp.sh' files/etc/uci-defaults/99-init-settings.sh
    sed -i '/# setup misc settings/ a\chmod +x /lib/nefitd/proto/dhcpv6.sh' files/etc/uci-defaults/99-init-settings.sh
    sed -i '/# setup misc settings/ a\chmod +x /lib/netifd/proto/ppp.sh' files/etc/uci-defaults/99-init-settings.sh
else
    sed -i -E "s|nullwrt|$TYPE|g" files/etc/uci-defaults/99-init-settings.sh
    rm -rf files/lib
    rm -rf files/etc/config/amlogic
    rm -rf files/etc/config/fstab
    rm -rf files/etc/custom_service
    rm -rf files/etc/profile.d
    rm -rf files/etc/banner
    rm -rf files/etc/fstab
    rm -rf files/etc/model_database.conf
    rm -rf files/lib/firmware
    rm -rf files/sbin/firstboot
    rm -rf files/sbin/kmod
    rm -rf files/usr/bin/7z
    rm -rf files/usr/sbin
fi

# custom script files urls
echo "Downloading custom script" 
sync_time="https://raw.githubusercontent.com/frizkyiman/auto-sync-time/main/sbin/sync_time.sh"
clock="https://raw.githubusercontent.com/frizkyiman/auto-sync-time/main/usr/bin/clock"
repair_ro="https://raw.githubusercontent.com/frizkyiman/fix-read-only/main/install2.sh"
mount_hdd="https://raw.githubusercontent.com/frizkyiman/auto-mount-hdd/main/mount_hdd"

wget --no-check-certificate -nv -P files/sbin "$sync_time"
wget --no-check-certificate -nv -P files/usr/bin "$clock"
wget --no-check-certificate -nv -P files/root "$repair_ro"
wget --no-check-certificate -nv -P files/usr/bin "$mount_hdd"


# echo "src/gz custom_arch https://dl.openwrt.ai/latest/packages/$ARCH_3/kiddin9" >> repositories.conf

# setup hotspot
echo "Downloading files for hotspot" 
git clone -b "main" "https://github.com/Maizil41/RadiusMonitor.git" "files/usr/share/RadiusMonitor"
git clone -b "main" "https://github.com/Maizil41/hotspotlogin.git" "files/usr/share/hotspotlogin"
git clone -b "main" "https://github.com/Maizil41/whatsapp-bot.git" "files/root/whatsapp"
mv files/root/whatsapp/luci-app-whatsapp-bot/root/root/whatsapp-bot files/root/whatsapp-bot
rm -rf files/root/whatsapp

wget https://files.phpmyadmin.net/phpMyAdmin/5.2.1/phpMyAdmin-5.2.1-all-languages.zip
unzip phpMyAdmin-5.2.1-all-languages.zip
rm -rf phpMyAdmin-5.2.1-all-languages.zip
mv phpMyAdmin-5.2.1-all-languages files/www/phpmyadmin

echo "All custom configuration setup completed!"
