#!/bin/bash

. ./scripts/INCLUDE.sh

# Exit on error
set -e

# Profile info
make info

# Main configuration name
PROFILE=""
PACKAGES=""

# Base packages
PACKAGES+=" -dnsmasq dnsmasq-full cgi-io libiwinfo libiwinfo-data libiwinfo-lua liblua \
luci-base luci-lib-base luci-lib-ip luci-lib-jsonc luci-lib-nixio luci-mod-admin-full \
cpusage ttyd dmesg kmod-tun luci-lib-ipkg \
zram-swap adb parted losetup resize2fs luci luci-ssl block-mount htop bash curl wget-ssl \
tar unzip unrar gzip jq luci-app-ttyd nano httping screen openssh-sftp-server \
liblucihttp liblucihttp-lua libubus-lua lua luci-app-firewall luci-app-opkg \
ca-bundle ca-certificates luci-compat coreutils-sleep fontconfig coreutils-whoami file lolcat \
luci-base luci-lib-base luci-lib-ip luci-lib-jsonc luci-lib-nixio luci-mod-admin-full \
luci-mod-network luci-mod-status luci-mod-system luci-proto-ipv6 luci-proto-ppp \
luci-theme-bootstrap px5g-wolfssl rpcd rpcd-mod-file rpcd-mod-iwinfo rpcd-mod-luci \
rpcd-mod-rrdns uhttpd uhttpd-mod-ubus coreutils coreutils-base64 coreutils-nohup coreutils-stty libc coreutils-stat \
ip-full libuci-lua microsocks resolveip ipset iptables iptables-legacy \
iptables-mod-iprange iptables-mod-socket iptables-mod-tproxy kmod-ipt-nat luci-lua-runtime zoneinfo-asia zoneinfo-core \
perl perlbase-base perlbase-bytes perlbase-class perlbase-config perlbase-cwd perlbase-dynaloader perlbase-errno perlbase-essential perlbase-fcntl perlbase-file \
perlbase-filehandle perlbase-i18n perlbase-integer perlbase-io perlbase-list perlbase-locale perlbase-params perlbase-posix \
perlbase-re perlbase-scalar perlbase-selectsaver perlbase-socket perlbase-symbol perlbase-tie perlbase-time perlbase-unicore perlbase-utf8 perlbase-xsloader"

# Modem and UsbLAN Driver
PACKAGES+=" kmod-usb-net-rtl8150 kmod-usb-net-rtl8152 kmod-usb-net-asix kmod-usb-net-asix-ax88179"
PACKAGES+=" kmod-mii kmod-usb-net kmod-usb-wdm kmod-usb-net-qmi-wwan uqmi luci-proto-qmi \
kmod-usb-net-cdc-ether kmod-usb-serial-option kmod-usb-serial kmod-usb-serial-wwan qmi-utils \
kmod-usb-serial-qualcomm kmod-usb-acm kmod-usb-net-cdc-ncm kmod-usb-net-cdc-mbim umbim \
modemmanager  modemmanager-rpcd luci-proto-modemmanager libmbim libqmi usbutils luci-proto-mbim luci-proto-ncm \
kmod-usb-net-huawei-cdc-ncm kmod-usb-net-cdc-ether kmod-usb-net-rndis kmod-usb-net-sierrawireless kmod-usb-ohci kmod-usb-serial-sierrawireless \
kmod-usb-uhci kmod-usb2 kmod-usb-ehci kmod-usb-net-ipheth usbmuxd libusbmuxd-utils libimobiledevice-utils usb-modeswitch kmod-nls-utf8 mbim-utils xmm-modem \
kmod-phy-broadcom kmod-phylib-broadcom kmod-tg3 libusb-1.0-0"

# Modem Tools
PACKAGES+=" modeminfo-serial-zte modeminfo-serial-gosun modeminfo-qmi modeminfo-serial-yuge modeminfo-serial-thales modeminfo-serial-tw modeminfo-serial-meig modeminfo-serial-styx modeminfo-serial-mikrotik modeminfo-serial-dell modeminfo-serial-sierra modeminfo-serial-quectel modeminfo-serial-huawei modeminfo-serial-xmm modeminfo-serial-telit modeminfo-serial-fibocom modeminfo-serial-simcom modeminfo luci-app-modeminfo"
PACKAGES+=" atinout modemband luci-app-modemband sms-tool luci-app-sms-tool-js luci-app-lite-watchdog luci-app-3ginfo-lite picocom minicom"

# Tunnel option
OPENCLASH+="coreutils-nohup bash dnsmasq-full curl ca-certificates ipset ip-full libcap libcap-bin ruby ruby-yaml kmod-tun kmod-inet-diag unzip kmod-nft-tproxy luci-compat luci luci-base luci-app-openclash"
NIKKI+="nikki luci-app-nikki"
PASSWALL+="chinadns-ng resolveip dns2socks dns2tcp ipt2socks microsocks tcping xray-core xray-plugin luci-app-passwall"

# Tunnel options handling
handle_tunnel_option() {
    case "$1" in
        "openclash")
            PACKAGES+=" $OPENCLASH"
            ;;
        "passwall")
            PACKAGES+=" $PASSWALL"
            ;;
        "nikki")
            PACKAGES+=" $NIKKI"
            ;;
        "openclash-passwall")
            PACKAGES+=" $OPENCLASH $PASSWALL"
            ;;
        "nikki-passwall")
            PACKAGES+=" $NIKKI $PASSWALL"
            ;;
        "nikki-openclash")
            PACKAGES+=" $NIKKI $OPENCLASH"
            ;;
        "openclash-passwall-nikki")
            PACKAGES+=" $OPENCLASH $PASSWALL $NIKKI"
            ;;
    esac
}

# Remote Services
PACKAGES+=" luci-app-zerotier luci-app-cloudflared tailscale luci-app-tailscale"

# NAS and Hard disk tools
PACKAGES+=" luci-app-diskman luci-app-disks-info smartmontools kmod-usb-storage kmod-usb-storage-uas ntfs-3g"

# Bandwidth And Network Monitoring
PACKAGES+=" internet-detector luci-app-internet-detector internet-detector-mod-modem-restart nlbwmon luci-app-nlbwmon vnstat2 vnstati2 luci-app-vnstat2 netdata"

# Theme
PACKAGES+=" luci-theme-material luci-theme-argon luci-app-argon-config"

# PHP8
PACKAGES+=" php8 php8-fastcgi php8-fpm php8-mod-session php8-mod-ctype php8-mod-fileinfo php8-mod-zip php8-mod-iconv php8-mod-mbstring"

# More
PACKAGES+=" luci-app-poweroff luci-app-log-viewer luci-app-ramfree"

# Handle profile-specific packages
handle_profile_packages() {
    if [ "$1" == "rpi-4" ]; then
        PACKAGES+=" kmod-i2c-bcm2835 i2c-tools kmod-i2c-core kmod-i2c-gpio"
    elif [ "$ARCH_2" == "x86_64" ]; then
        PACKAGES+=" kmod-iwlwifi iw-full pciutils"
    fi

    if [ "$TYPE" == "AMLOGIC" ]; then
        PACKAGES+=" luci-app-amlogic ath9k-htc-firmware btrfs-progs hostapd hostapd-utils kmod-ath kmod-ath9k kmod-ath9k-common kmod-ath9k-htc kmod-cfg80211 kmod-crypto-acompress kmod-crypto-crc32c kmod-crypto-hash kmod-fs-btrfs kmod-mac80211 wireless-tools wpa-cli wpa-supplicant"
        EXCLUDED+=" -procd-ujail"
    fi
}

# Handle release branch specific packages
handle_release_packages() {
    if [ "${RELEASE_BRANCH%:*}" == "openwrt" ]; then
        PACKAGES+=" luci-app-temp-status luci-app-cpu-status-mini"
        EXCLUDED+=" -dnsmasq"
    elif [ "${RELEASE_BRANCH%:*}" == "immortalwrt" ]; then
        EXCLUDED+=" -dnsmasq -automount -libustream-openssl -default-settings-chn -luci-i18n-base-zh-cn"
        if [ "$ARCH_2" == "x86_64" ]; then
            EXCLUDED+=" -kmod-usb-net-rtl8152-vendor"
        fi
    fi
}

# Main build function
build_firmware() {
    local profile=$1
    local tunnel_option=$2

    log "INFO" "Starting build for profile: $profile"
    
    # Handle packages based on profile and tunnel option
    handle_profile_packages "$profile"
    handle_tunnel_option "$tunnel_option"
    handle_release_packages
    
    # Custom Files
    FILES="files"
    
    log "INFO" "Building image..."
    make image PROFILE="$profile" PACKAGES="$PACKAGES $EXCLUDED" FILES="$FILES" DISABLED_SERVICES="$DISABLED_SERVICES" 2>&1 | tee -a "$BUILD_LOG"
    
    if [ ${PIPESTATUS[0]} -eq 0 ]; then
        log "INFO" "Build completed successfully!"
    else
        log "ERROR" "Build failed. Check $BUILD_LOG for details."
    fi
}

# Main script execution
if [ -z "$1" ]; then
    log "ERROR" "Profile not specified"
fi

build_firmware "$1" "$2"