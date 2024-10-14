#!/bin/bash

# Profile info
make info

# Main configuration name
PROFILE=""
PACKAGES=""

# Modem and UsbLAN Driver
PACKAGES+=" wget kmod-usb-net-rtl8150 kmod-usb-net-rtl8152 kmod-usb-net-asix kmod-usb-net-asix-ax88179"
PACKAGES+=" kmod-mii kmod-usb-net kmod-usb-wdm kmod-usb-net-qmi-wwan uqmi luci-proto-qmi \
kmod-usb-net-cdc-ether kmod-usb-serial-option kmod-usb-serial kmod-usb-serial-wwan qmi-utils \
kmod-usb-serial-qualcomm kmod-usb-acm kmod-usb-net-cdc-ncm kmod-usb-net-cdc-mbim umbim \
modemmanager modemmanager-rpcd luci-proto-modemmanager libmbim libqmi usbutils luci-proto-mbim luci-proto-ncm \
kmod-usb-net-huawei-cdc-ncm kmod-usb-net-cdc-ether kmod-usb-net-rndis kmod-usb-net-sierrawireless kmod-usb-ohci kmod-usb-serial-sierrawireless \
kmod-usb-uhci kmod-usb2 kmod-usb-ehci kmod-usb-net-ipheth usbmuxd libusbmuxd-utils libimobiledevice-utils usb-modeswitch kmod-nls-utf8 mbim-utils xmm-modem \
kmod-phy-broadcom kmod-phylib-broadcom kmod-tg3"
PACKAGES+=" acpid attr base-files bash bc blkid block-mount blockd bsdtar btrfs-progs busybox bzip2 \
cgi-io chattr comgt comgt-ncm containerd coremark coreutils coreutils-base64 coreutils-nohup \
coreutils-truncate curl dosfstools dumpe2fs e2freefrag e2fsprogs \
exfat-mkfs f2fs-tools f2fsck fdisk gawk getopt git gzip hostapd-common iconv iw iwinfo jq \
jshn kmod-brcmfmac kmod-brcmutil kmod-cfg80211 kmod-mac80211 libjson-script liblucihttp \
liblucihttp-lua losetup lsattr lsblk lscpu mkf2fs openssl-util parted \
perl-http-date perlbase-file perlbase-getopt perlbase-time perlbase-unicode perlbase-utf8 \
pigz ppp ppp-mod-pppoe proto-bonding pv rename resize2fs runc tar tini ttyd tune2fs \
uclient-fetch uhttpd uhttpd-mod-ubus unzip uqmi usb-modeswitch uuidgen wget-ssl whereis \
which wwan xfs-fsck xfs-mkfs xz xz-utils ziptool zoneinfo-asia zoneinfo-core zstd \
luci luci-base luci-compat luci-lib-base \
luci-lib-ip luci-lib-ipkg luci-lib-jsonc luci-lib-nixio luci-mod-admin-full luci-mod-network \
luci-mod-status luci-mod-system luci-proto-bonding \
luci-proto-ppp lolcat coreutils-stty git git-http"


PACKAGES+=" luci-app-zerotier luci-app-cloudflared tailscale luci-app-tailscale"

# Modem Tools
PACKAGES+=" modeminfo luci-app-modeminfo atinout modemband luci-app-modemband luci-app-mmconfig sms-tool luci-app-sms-tool-js luci-app-lite-watchdog luci-app-3ginfo-lite picocom minicom"

# Tunnel option
OPENCLASH="coreutils-nohup bash dnsmasq-full curl ca-certificates ipset ip-full libcap libcap-bin ruby ruby-yaml kmod-tun kmod-inet-diag unzip kmod-nft-tproxy luci-compat luci luci-base luci-app-openclash"
PASSWALL="coreutils coreutils-base64 coreutils-nohup curl \
chinadns-ng dns2socks dns2tcp dnsmasq-full ip-full \
libuci-lua lua luci-compat luci-lib-jsonc \
microsocks resolveip tcping \
hysteria ipt2socks shadowsocks-rust-sslocal shadowsocks-rust-ssserver shadowsocksr-libev-ssr-local \
shadowsocksr-libev-ssr-redir shadowsocksr-libev-ssr-server simple-obfs sing-box trojan-plus tuic-client v2ray-geoip v2ray-geosite v2ray-plugin xray-core xray-plugin luci-app-passwall"
MIHOMO+="mihomo luci-app-mihomo"

PACKAGES+=" $OPENCLASH $MIHOMO"

# NAS and Hard disk tools
PACKAGES+=" luci-app-diskman luci-app-hd-idle luci-app-disks-info smartmontools kmod-usb-storage kmod-usb-storage-uas ntfs-3g"
# PACKAGES+=" luci-app-tinyfilemanager"

PACKAGES+=" luci-app-mmconfig pdnsd-alt brook"

# Bandwidth And Network Monitoring
PACKAGES+=" internet-detector luci-app-internet-detector internet-detector-mod-modem-restart nlbwmon luci-app-nlbwmon vnstat2 vnstati2 luci-app-vnstat2 luci-app-netmonitor"

# Speedtest
PACKAGES+=" librespeed-go python3-speedtest-cli iperf3 luci-app-netspeedtest"

# Base64 Encode Decode
PACKAGES+=" luci-app-base64"

# Material Theme
PACKAGES+=" luci-theme-material"

# PHP8
PACKAGES+=" libc php8 php8-fastcgi php8-fpm coreutils-stat zoneinfo-asia php8-cgi \
php8-cli php8-mod-bcmath php8-mod-calendar php8-mod-ctype php8-mod-curl php8-mod-dom php8-mod-exif \
php8-mod-fileinfo php8-mod-filter php8-mod-gd php8-mod-iconv php8-mod-intl php8-mod-mbstring php8-mod-mysqli \
php8-mod-mysqlnd php8-mod-opcache php8-mod-pdo php8-mod-pdo-mysql php8-mod-phar php8-mod-session \
php8-mod-xml php8-mod-xmlreader php8-mod-xmlwriter php8-mod-zip libopenssl-legacy"

# Misc and some custom .ipk files
misc+=" luci-app-temp-status luci-app-cpu-status-mini"

if [ "$1" == "rpi-4" ]; then
    misc+=" kmod-i2c-bcm2835 i2c-tools kmod-i2c-core kmod-i2c-gpio luci-app-oled"
elif [ "$ARCH_2" == "x86_64" ]; then
    misc+=" kmod-iwlwifi iw-full pciutils"
fi

if [ "$TYPE" == "AMLOGIC" ]; then
    PACKAGES+=" luci-app-amlogic ath9k-htc-firmware btrfs-progs hostapd hostapd-utils kmod-ath kmod-ath9k kmod-ath9k-common kmod-ath9k-htc kmod-cfg80211 kmod-crypto-acompress kmod-crypto-crc32c kmod-crypto-hash kmod-fs-btrfs kmod-mac80211 wireless-tools wpa-cli wpa-supplicant"
    EXCLUDED+=" -procd-ujail"
fi

PACKAGES+=" $misc zram-swap adb parted losetup resize2fs luci luci-ssl block-mount luci-app-poweroff luci-app-log luci-app-ramfree htop bash curl wget-ssl tar unzip unrar gzip jq luci-app-ttyd nano httping screen openssh-sftp-server"


# HOTSPOT-SETUP
PACKAGES+=" mariadb-server mariadb-server-extra mariadb-client mariadb-client-extra libmariadb nano"
PACKAGES+=" freeradius3 freeradius3-common freeradius3-default freeradius3-mod-always freeradius3-mod-attr-filter \
freeradius3-mod-chap freeradius3-mod-detail freeradius3-mod-digest freeradius3-mod-eap \
freeradius3-mod-eap-gtc freeradius3-mod-eap-md5 freeradius3-mod-eap-mschapv2 freeradius3-mod-eap-peap \
freeradius3-mod-eap-pwd freeradius3-mod-eap-tls freeradius3-mod-eap-ttls freeradius3-mod-exec \
freeradius3-mod-expiration freeradius3-mod-expr freeradius3-mod-files freeradius3-mod-logintime \
freeradius3-mod-mschap freeradius3-mod-pap freeradius3-mod-preprocess freeradius3-mod-radutmp \
freeradius3-mod-realm freeradius3-mod-sql freeradius3-mod-sql-mysql freeradius3-mod-sqlcounter \
freeradius3-mod-unix freeradius3-utils libfreetype wget-ssl curl unzip tar zoneinfo-asia coova-chilli"

PACKAGES+=" node node-npm"

PACKAGES+=" luci-app-radmon-php8 luci-app-whatsapp-bot"

# Exclude package (must use - before packages name)
EXCLUDED+=" -dnsmasq -libgd"

# Custom Files
FILES="files"

# Disable service
# DISABLED_SERVICES=""

# Start build firmware
make image PROFILE="$1" PACKAGES="$PACKAGES $EXCLUDED" FILES="$FILES" DISABLED_SERVICES="$DISABLED_SERVICES"
