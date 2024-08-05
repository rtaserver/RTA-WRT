#!/bin/bash

# Profile info
make info

# Main configuration name
PROFILE=""
PACKAGES=""

# Modem and UsbLAN Driver
PACKAGES+=" kmod-usb-net-rtl8150 kmod-usb-net-rtl8152 kmod-usb-net-asix kmod-usb-net-asix-ax88179"
PACKAGES+=" kmod-mii kmod-usb-net kmod-usb-wdm kmod-usb-net-qmi-wwan uqmi \
kmod-usb-net-cdc-ether kmod-usb-serial-option kmod-usb-serial kmod-usb-serial-wwan qmi-utils \
kmod-usb-serial-qualcomm kmod-usb-acm kmod-usb-net-cdc-ncm kmod-usb-net-cdc-mbim umbim \
libmbim libqmi modemmanager luci-proto-modemmanager usbutils luci-proto-mbim luci-proto-ncm luci-proto-qmi \
kmod-usb-net-huawei-cdc-ncm kmod-usb-net-cdc-ether kmod-usb-net-rndis kmod-usb-net-sierrawireless kmod-usb-ohci kmod-usb-serial-sierrawireless \
kmod-usb-uhci kmod-usb2 kmod-usb-ehci kmod-usb-net-ipheth usbmuxd libusbmuxd-utils libimobiledevice-utils usb-modeswitch kmod-nls-utf8 mbim-utils xmm-modem \
kmod-phy-broadcom kmod-phylib-broadcom kmod-tg3"

# Modem Tools
PACKAGES+=" modeminfo luci-app-modeminfo atinout modemband luci-app-modemband luci-app-mmconfig sms-tool luci-app-sms-tool-js luci-app-lite-watchdog luci-app-3ginfo-lite picocom minicom"

# Tunnel option
OPENCLASH=" coreutils-nohup bash dnsmasq-full curl ca-certificates ipset ip-full libcap libcap-bin ruby ruby-yaml kmod-tun kmod-inet-diag unzip kmod-nft-tproxy luci-compat luci luci-base luci-app-openclash"
PASSWALL=" ipset ipt2socks iptables iptables-legacy iptables-mod-iprange iptables-mod-socket iptables-mod-tproxy kmod-ipt-nat coreutils coreutils-base64 coreutils-nohup curl dns2socks ip-full libuci-lua lua luci-compat luci-lib-jsonc microsocks resolveip tcping unzip dns2tcp hysteria trojan-go xray-core xray-plugin sing-box chinadns-ng haproxy ip6tables-mod-nat kcptun-client naiveproxy shadowsocks-libev-ss-local shadowsocks-libev-ss-redir shadowsocks-libev-ss-server shadowsocks-rust-sslocal shadowsocksr-libev-ssr-local shadowsocksr-libev-ssr-redir shadowsocksr-libev-ssr-server simple-obfs trojan-plus v2ray-core v2ray-plugin luci-app-passwall"
if [ "$2" == "openclash" ]; then
    PACKAGES+="$OPENCLASH"
elif [ "$2" == "passwall" ]; then
    PACKAGES+=" $PASSWALL"
elif [ "$2" == "openclash-passwall" ]; then
    PACKAGES+="$OPENCLASH" 
    PACKAGES+="$PASSWALL"
fi

# NAS and Hard disk tools
PACKAGES+=" luci-app-diskman luci-app-disks-info smartmontools kmod-usb-storage kmod-usb-storage-uas ntfs-3g"
# PACKAGES+=" luci-app-tinyfm"
PACKAGES+=" luci-app-tinyfilemanager"

PACKAGES+=" quickstart luci-app-quickstart"

# Bandwidth And Network Monitoring
PACKAGES+=" internet-detector luci-app-internet-detector internet-detector-mod-modem-restart nlbwmon luci-app-nlbwmon vnstat2 vnstati2 luci-app-vnstat2 luci-app-netmonitor"

# Speedtest
PACKAGES+=" librespeed-go python3-speedtest-cli iperf3 luci-app-netspeedtest"

# Base64 Encode Decode
PACKAGES+=" luci-app-base64"

# Argon Theme
PACKAGES+=" luci-theme-argon luci-app-argon-config"

# Alpha Theme
PACKAGES+=" luci-theme-alpha luci-app-alpha-config"

# RTA Theme
PACKAGES+=" luci-theme-rta luci-app-rtaconfig"

# PHP8
PACKAGES+=" libc php8 php8-fastcgi php8-fpm php8-mod-session php8-mod-ctype php8-mod-fileinfo php8-mod-zip php8-mod-iconv php8-mod-mbstring coreutils-stat zoneinfo-asia"

PACKAGES+=" perl perlbase-extutils"

# Misc and some custom .ipk files
misc=""
if [ "${RELEASE_BRANCH%:*}" == "openwrt" ]; then
    misc+=" luci-app-temp-status luci-app-cpu-status-mini"
elif [ "${RELEASE_BRANCH%:*}" == "immortalwrt" ]; then
    misc+=" "
fi

if [ "$(echo "$BRANCH" | cut -d'.' -f1)" == "21" ]; then
    misc+=" iptables-mod-ipopt"
else
    misc+=" "
fi

if [ "$1" == "rpi-4" ]; then
    misc+=" kmod-i2c-bcm2835 i2c-tools kmod-i2c-core kmod-i2c-gpio luci-app-oled"
elif [ "$ARCH_2" == "x86_64" ]; then
    misc+=" kmod-iwlwifi iw-full pciutils"
fi

if [ "$TYPE" == "AMLOGIC" ]; then
    PACKAGES+=" luci-app-amlogic ath9k-htc-firmware btrfs-progs hostapd hostapd-utils kmod-ath kmod-ath9k kmod-ath9k-common kmod-ath9k-htc kmod-cfg80211 kmod-crypto-acompress kmod-crypto-crc32c kmod-crypto-hash kmod-fs-btrfs kmod-mac80211 wireless-tools wpa-cli wpa-supplicant"
    EXCLUDED+=" -procd-ujail"
fi

PACKAGES+=" $misc zram-swap adb parted losetup resize2fs luci luci-ssl block-mount luci-app-poweroff luci-app-log luci-app-ramfree htop bash curl wget wget-ssl tar unzip unrar gzip jq luci-app-ttyd nano httping screen openssh-sftp-server"

# Exclude package (must use - before packages name)
EXCLUDED=""
if [ "${RELEASE_BRANCH%:*}" == "openwrt" ]; then
    EXCLUDED+=" -dnsmasq"
elif [ "${RELEASE_BRANCH%:*}" == "immortalwrt" ]; then
    EXCLUDED+=" -dnsmasq -automount -libustream-openssl -default-settings-chn -luci-i18n-base-zh-cn"
    if [ "$ARCH_2" == "x86_64" ]; then
      EXCLUDED+=" -kmod-usb-net-rtl8152-vendor"
    fi
fi

# Custom Files
FILES="files"

# Start build firmware
make image PROFILE="$1" PACKAGES="$PACKAGES $EXCLUDED" FILES="$FILES" DISABLED_SERVICES="$DISABLED_SERVICES"
