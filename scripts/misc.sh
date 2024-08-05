#!/bin/bash

echo "Start Downloading Misc files and setup configuration!"
echo "Current Path: $PWD"

# sed -i "/src\/gz openwrt_telephony/a src\/gz kiddin9 https:\/\/dl\.openwrt\.ai\/packages-23\.05\/$ARCH_3\/kiddin9" repositories.conf

#setup custom setting for openwrt and immortalwrt
sed -i "s/Ouc3kNF6/$DATE/g" files/etc/uci-defaults/99-init-settings.sh
if [[ "$BASE" == "openwrt" ]]; then
    echo "$BASE"
    sed -i '/# setup misc settings/ a\mv \/www\/luci-static\/resources\/view\/status\/include\/29_temp.js \/www\/luci-static\/resources\/view\/status\/include\/17_temp.js' files/etc/uci-defaults/99-init-settings.sh
elif [[ "$BASE" == "immortalwrt" ]]; then
    echo "$BASE"
    if [ "$(echo "$BRANCH" | cut -d'.' -f1)" == "23" ] && "$PROFILE" == "rpi-4" ]]; then
        cp packages/luci-app-oled_1.0_all.ipk files/root/luci-app-oled_1.0_all.ipk
        sed -i '/# setup misc settings/ a\rm /root/luci-app-oled_1.0_all.ipk' files/etc/uci-defaults/99-init-settings.sh
        sed -i '/# setup misc settings/ a\opkg install /root/luci-app-oled_1.0_all.ipk --force-downgrade' files/etc/uci-defaults/99-init-settings.sh
    fi
fi

if [ "$(echo "$BRANCH" | cut -d'.' -f1)" == "21" ] || [ "$TYPE" == "AMLOGIC" ] || [ "$ROOTFS_SQUASHFS" == "true" ]; then
    rm files/etc/uci-defaults/70-rootpt-resize
    rm files/etc/uci-defaults/80-rootfs-resize
    rm files/etc/sysupgrade.conf
fi

# add yout custom command for specific target and release branch version here
if [ "$(echo "$BRANCH" | cut -d'.' -f1)" == "21" ]; then
    echo "$BRANCH"
elif [ "$(echo "$BRANCH" | cut -d'.' -f1)" == "23" ]; then
    echo "$BRANCH"
fi

if [ "$TARGET" == "Raspberry Pi 4B" ]; then
    echo "$TARGET"
elif [ "$TARGET" == "x86-64" ]; then
    rm packages/luci-app-oled_1.0_all.ipk
else
    rm packages/luci-app-oled_1.0_all.ipk
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

echo "All custom configuration setup completed!"
