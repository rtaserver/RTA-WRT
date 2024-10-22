#!/bin/bash
#================================================================================================
# Description: Build OpenWrt with Image Builder
# Copyright (C) 2021~ https://github.com/unifreq/openwrt_packit
# Copyright (C) 2021~ https://github.com/ophub/amlogic-s9xxx-openwrt
# Copyright (C) 2021~ https://downloads.openwrt.org/releases
# Copyright (C) 2023~ https://downloads.immortalwrt.org/releases
#
#
# Command: ./config/imagebuilder/imagebuilder.sh <source:branch> <target>
#          ./config/imagebuilder/imagebuilder.sh openwrt:21.02.3 x86_64
#
#
# Set default parameters
make_path="${PWD}"
openwrt_dir="imagebuilder"
imagebuilder_path="${make_path}/${openwrt_dir}"
custom_files_path="${make_path}/files"
custom_scripts_file="${make_path}/scripts"

# Set default parameters
STEPS="[\033[95m STEPS \033[0m]"
INFO="[\033[94m INFO \033[0m]"
SUCCESS="[\033[92m SUCCESS \033[0m]"
WARNING="[\033[93m WARNING \033[0m]"
ERROR="[\033[91m ERROR \033[0m]"
#
#================================================================================================

# Encountered a serious error, abort the script execution
error_msg() {
    echo -e "${ERROR} ${1}"
    exit 1
}

# External Packages Download
download_packages() {
    local list=("${!2}") # Capture array argument
    if [[ $1 == "github" ]]; then
        for entry in "${list[@]}"; do
            IFS="|" read -r filename base_url <<< "$entry"
            echo -e "${INFO} Processing file: $filename"
            file_urls=$(curl -s "$base_url" | grep "browser_download_url" | grep -oE "https.*/${filename}_[_0-9a-zA-Z\._~-]*\.ipk" | sort -V | tail -n 1)
            for file_url in $file_urls; do
                if [ -n "$file_url" ]; then
                    echo -e "${INFO} Downloading $(basename "$file_url")"
                    echo -e "${INFO} from $file_url"
                    curl -Lo "$(basename "$file_url")" "$file_url"
                    echo -e "${SUCCESS} Packages [$filename] downloaded successfully!"
                    break
                else
                    error_msg "Failed to retrieve packages [$filename]. Retrying before exit..."
                fi
            done
        done
    elif [[ $1 == "custom" ]]; then
        for entry in "${list[@]}"; do
            IFS="|" read -r filename base_url <<< "$entry"
            echo -e "${INFO} Processing file: $filename"
            file_urls=$(curl -sL "$base_url" | grep -oE "${filename}_[0-9a-zA-Z\._~-]*\.ipk" | grep -v 'git' | sort -V | tail -n 1)
            if [ -z "$file_urls" ]; then
                echo -e "${WARNING} No matching stable file found. Trying general search..."
                file_urls=$(curl -sL "$base_url" | grep -oE "${filename}_[0-9a-zA-Z\._~-]*\.ipk" | sort -V | tail -n 1)
            fi
            echo -e "${INFO} Matching files found:"
            echo -e "${INFO} $file_urls"
            if [ -n "$file_urls" ]; then
                full_url="$base_url/$file_urls"
                echo -e "${INFO} Downloading $filename from $full_url"
                curl -Lo "${filename}.ipk" "$full_url"
                if [ $? -eq 0 ]; then
                    echo -e "${SUCCESS} Package [$filename] downloaded successfully."
                else
                    error_msg "Failed to download package [$filename]."
                fi
            else
                error_msg "No matching file found for [$filename] at $base_url."
            fi
        done
    fi
}


# Downloading OpenWrt ImageBuilder
download_imagebuilder() {
    cd ${make_path}
    echo -e "${STEPS} Start downloading OpenWrt files..."

    if [[ "${op_target}" == "amlogic" || "${op_target}" == "armsr-armv8" ]]; then
        target_profile=""
        target_system="armsr/armv8"
        target_name="armsr-armv8"
        ARCH_1="armv8"
        ARCH_2="aarch64"
        ARCH_3="aarch64_generic"
    elif [[ "${op_target}" == "rpi-3" || "${op_target}" == "bcm27xx-bcm2710" ]]; then
        target_profile="rpi-3"
        target_system="bcm27xx/bcm2710"
        target_name="bcm27xx-bcm2710"
        ARCH_1="arm64"
        ARCH_2="aarch64"
        ARCH_3="aarch64_cortex-a53"
    elif [[ "${op_target}" == "rpi-4" ]]; then
        target_profile="rpi-4"
        target_system="bcm27xx/bcm2711"
        target_name="bcm27xx-bcm2711"
        ARCH_1="arm64"
        ARCH_2="aarch64"
        ARCH_3="aarch64_cortex-a72"
    elif [[ "${op_target}" == "friendlyarm_nanopi-r2c" ]]; then
        target_profile="friendlyarm_nanopi-r2c"
        target_system="rockchip/armv8"
        target_name="rockchip-armv8"
        ARCH_1="armv8"
        ARCH_2="aarch64"
        ARCH_3="aarch64_generic"
    elif [[ "${op_target}" == "friendlyarm_nanopi-r2s" ]]; then
        target_profile="friendlyarm_nanopi-r2s"
        target_system="rockchip/armv8"
        target_name="rockchip-armv8"
        ARCH_1="armv8"
        ARCH_2="aarch64"
        ARCH_3="aarch64_generic"
    elif [[ "${op_target}" == "friendlyarm_nanopi-r4s" ]]; then
        target_profile="friendlyarm_nanopi-r4s"
        target_system="rockchip/armv8"
        target_name="rockchip-armv8"
        ARCH_1="armv8"
        ARCH_2="aarch64"
        ARCH_3="aarch64_generic"
    elif [[ "${op_target}" == "xunlong_orangepi-r1-plus" ]]; then
        target_profile="xunlong_orangepi-r1-plus"
        target_system="rockchip/armv8"
        target_name="rockchip-armv8"
        ARCH_1="armv8"
        ARCH_2="aarch64"
        ARCH_3="aarch64_generic"
    elif [[ "${op_target}" == "xunlong_orangepi-r1-plus-lts" ]]; then
        target_profile="xunlong_orangepi-r1-plus-lts"
        target_system="rockchip/armv8"
        target_name="rockchip-armv8"
        ARCH_1="armv8"
        ARCH_2="aarch64"
        ARCH_3="aarch64_generic"
    elif [[ "${op_target}" == "generic" || "${op_target}" == "x86-64" || "${op_target}" == "x86_64" ]]; then
        target_profile="generic"
        target_system="x86/64"
        target_name="x86-64"
        ARCH_1="amd64"
        ARCH_2="x86_64"
        ARCH_3="x86_64"
    fi

    # Downloading imagebuilder files
    download_file="https://downloads.${op_sourse}.org/releases/${op_branch}/targets/${target_system}/${op_sourse}-imagebuilder-${op_branch}-${target_name}.Linux-x86_64.tar.xz"
    curl -fsSOL ${download_file}
    [[ "${?}" -eq "0" ]] || error_msg "Download failed: [ ${download_file} ]"
    echo -e "${SUCCESS} Download Base ${op_branch} ${target_name} successfully!"

    # Unzip and change the directory name
    tar -xJf *-imagebuilder-* && sync && rm -f *-imagebuilder-*.tar.xz
    mv -f *-imagebuilder-* ${openwrt_dir}

    sync && sleep 3
    echo -e "${INFO} [ ${make_path} ] directory status: $(ls -al 2>/dev/null)"
}

# Adjust related files in the ImageBuilder directory
adjust_settings() {
    cd ${imagebuilder_path}
    echo -e "${STEPS} Start adjusting .config file settings..."

    sed -i '\|option check_signature| s|^|#|' repositories.conf
    sed -i "s/install \$(BUILD_PACKAGES)/install \$(BUILD_PACKAGES) --force-overwrite --force-downgrade/" Makefile

    # For .config file
    if [[ -s ".config" ]]; then

        # Resize Boot and Rootfs partition size
        option_squashfs=$( [ "$ROOTFS_SQUASHFS" == "true" ] && echo "CONFIG_TARGET_ROOTFS_SQUASHFS=y" || echo "# CONFIG_TARGET_ROOTFS_SQUASHFS is not set" )
        sed -i "s/CONFIG_TARGET_KERNEL_PARTSIZE=.*/CONFIG_TARGET_KERNEL_PARTSIZE=128/" .config
        sed -i "s/CONFIG_TARGET_ROOTFS_PARTSIZE=.*/CONFIG_TARGET_ROOTFS_PARTSIZE=1024/" .config
        sed -i "s/CONFIG_TARGET_ROOTFS_SQUASHFS=y/$option_squashfs/" .config
        # Root filesystem archives
        sed -i "s|CONFIG_TARGET_ROOTFS_CPIOGZ=.*|# CONFIG_TARGET_ROOTFS_CPIOGZ is not set|g" .config
        # Root filesystem images
        sed -i "s|CONFIG_TARGET_ROOTFS_EXT4FS=.*|# CONFIG_TARGET_ROOTFS_EXT4FS is not set|g" .config
        sed -i "s|CONFIG_TARGET_IMAGES_GZIP=.*|# CONFIG_TARGET_IMAGES_GZIP is not set|g" .config

        if [[ "$op_target" == "x86_64" ]]; then
            # Not generate ISO images for it is too big
            sed -i "s/CONFIG_ISO_IMAGES=y/# CONFIG_ISO_IMAGES is not set/" .config
            # Not generate VHDX images
            sed -i "s/CONFIG_VHDX_IMAGES=y/# CONFIG_VHDX_IMAGES is not set/" .config
        fi
    else
        echo -e "${INFO} [ ${imagebuilder_path} ] directory status: $(ls -al 2>/dev/null)"
        error_msg "There is no .config file in the [ ${download_file} ]"
    fi

    bash 

    sync && sleep 3
    echo -e "${INFO} [ ${imagebuilder_path} ] directory status: $(ls -al 2>/dev/null)"
}

# Add custom packages
# If there is a custom package or ipk you would prefer to use create a [ packages ] directory,
# If one does not exist and place your custom ipk within this directory.
custom_packages() {
    cd ${imagebuilder_path}
    echo -e "${STEPS} Start adding custom packages..."

    # Create a [ packages ] directory
    [[ -d "packages" ]] || mkdir packages
    cd packages

    # Download IPK From Github
    # Download luci-app-amlogic
    if [ "$op_target" == "amlogic" ]; then
        echo "Adding [luci-app-amlogic] from bulider script type."
        github_packages+=("luci-app-amlogic|https://api.github.com/repos/ophub/luci-app-amlogic/releases/latest")
    fi
    github_packages+=(
        "luci-app-netmonitor|https://api.github.com/repos/rtaserver/rta-packages/releases"
        "luci-app-base64|https://api.github.com/repos/rtaserver/rta-packages/releases"
        "luci-app-whatsapp-bot|https://api.github.com/repos/Maizil41/whatsapp-bot/releases"
        "luci-app-radmon-php8|https://api.github.com/repos/Maizil41/RadiusMonitor/releases"
    )
    download_packages "github" github_packages[@]

    # Download IPK From Custom
    other_packages=(
        "lolcat|https://downloads.openwrt.org/snapshots/packages/$ARCH_3/packages"
        "modemmanager-rpcd|https://downloads.openwrt.org/snapshots/packages/$ARCH_3/packages"
        "luci-proto-modemmanager|https://downloads.openwrt.org/snapshots/packages/$ARCH_3/luci"
        "libqmi|https://downloads.openwrt.org/snapshots/packages/$ARCH_3/packages"
        "libmbim|https://downloads.openwrt.org/snapshots/packages/$ARCH_3/packages"
        "modemmanager|https://downloads.openwrt.org/snapshots/packages/$ARCH_3/packages"
        "sms-tool|https://downloads.openwrt.org/snapshots/packages/$ARCH_3/packages"
        "luci-app-netspeedtest|https://fantastic-packages.github.io/packages/releases/23.05/packages/x86_64/luci"
        "luci-app-zerotier|https://dl.openwrt.ai/latest/packages/$ARCH_3/kiddin9"
        "tailscale|https://dl.openwrt.ai/latest/packages/$ARCH_3/kiddin9"
        "luci-app-tailscale|https://dl.openwrt.ai/latest/packages/$ARCH_3/kiddin9"
        "luci-app-mmconfig|https://dllkids.xyz/packages/$ARCH_3"
        "pdnsd-alt|https://dl.openwrt.ai/latest/packages/$ARCH_3/kiddin9"
        "brook|https://dl.openwrt.ai/latest/packages/$ARCH_3/kiddin9"
        "luci-app-internet-detector|https://dl.openwrt.ai/latest/packages/$ARCH_3/kiddin9"
        "internet-detector|https://dl.openwrt.ai/latest/packages/$ARCH_3/kiddin9"
        "internet-detector-mod-modem-restart|https://dl.openwrt.ai/latest/packages/$ARCH_3/kiddin9"
        "luci-app-cpu-status-mini|https://dl.openwrt.ai/latest/packages/$ARCH_3/kiddin9"
        "luci-app-diskman|https://dl.openwrt.ai/latest/packages/$ARCH_3/kiddin9"
        "luci-app-disks-info|https://dl.openwrt.ai/latest/packages/$ARCH_3/kiddin9"
        "luci-app-log|https://dl.openwrt.ai/latest/packages/$ARCH_3/kiddin9"
        "luci-app-temp-status|https://dl.openwrt.ai/latest/packages/$ARCH_3/kiddin9"
        "luci-app-ramfree|https://dl.openwrt.ai/latest/packages/$ARCH_3/kiddin9"
        "modeminfo|https://dl.openwrt.ai/latest/packages/$ARCH_3/kiddin9"
        "atinout|https://dl.openwrt.ai/latest/packages/$ARCH_3/kiddin9"
        "luci-app-poweroff|https://dl.openwrt.ai/latest/packages/$ARCH_3/kiddin9"
        "xmm-modem|https://dl.openwrt.ai/latest/packages/$ARCH_3/kiddin9"
        "luci-app-3ginfo-lite|https://dl.openwrt.ai/latest/packages/$ARCH_3/kiddin9"
        "luci-app-lite-watchdog|https://dl.openwrt.ai/latest/packages/$ARCH_3/kiddin9"
        "modemband|https://dl.openwrt.ai/latest/packages/$ARCH_3/kiddin9"
        "luci-app-modemband|https://dl.openwrt.ai/latest/packages/$ARCH_3/kiddin9"
        "luci-app-sms-tool-js|https://dl.openwrt.ai/latest/packages/$ARCH_3/kiddin9"
    )
    download_packages "custom" other_packages[@]

    # OpenClash
    openclash_api="https://api.github.com/repos/vernesong/OpenClash/releases"
    openclash_file="luci-app-openclash"
    openclash_file_down="$(curl -s ${openclash_api} | grep "browser_download_url" | grep -oE "https.*${openclash_file}.*.ipk" | head -n 1)"

    # Mihomo
    mihomo_api="https://api.github.com/repos/rtaserver/OpenWrt-mihomo-Mod/releases"
    mihomo_file="mihomo_${ARCH_3}"
    mihomo_file_down="$(curl -s ${mihomo_api} | grep "browser_download_url" | grep -oE "https.*${mihomo_file}.*.tar.gz" | head -n 1)"
                        
    # Output download information
    echo -e "${STEPS} Installing OpenClash, Mihomo"

    echo -e "${INFO} Downloading OpenClash package"
    wget ${openclash_file_down} -nv
    if [ "$?" -ne 0 ]; then
        error_msg "Error: Failed to download OpenClash package."
        exit 1
    fi

    echo -e "${INFO} Downloading Mihomo package"
    wget "${mihomo_file_down}" -nv
    if [ "$?" -ne 0 ]; then
        error_msg "Error: Failed to download Mihomo package."
        exit 1
    fi

    echo -e "${INFO} Extract Mihomo package"
    tar -xzvf "mihomo_${ARCH_3}.tar.gz" && rm "mihomo_${ARCH_3}.tar.gz"
    if [ "$?" -ne 0 ]; then
        error_msg "Error: Failed to extract Mihomo package."
        exit 1
    fi

    echo -e "${SUCCESS} Download and extraction complete."

    sync && sleep 3
    echo -e "${INFO} [ packages ] directory status: $(ls -al 2>/dev/null)"
}

# Add custom packages, lib, theme, app and i18n, etc.
custom_config() {
    cd ${imagebuilder_path}
    echo -e "${STEPS} Start adding custom config..."

    echo -e "${INFO} Downloading custom script" 
    sync_time="https://raw.githubusercontent.com/frizkyiman/auto-sync-time/main/sbin/sync_time.sh"
    clock="https://raw.githubusercontent.com/frizkyiman/auto-sync-time/main/usr/bin/clock"
    repair_ro="https://raw.githubusercontent.com/frizkyiman/fix-read-only/main/install2.sh"
    mount_hdd="https://raw.githubusercontent.com/frizkyiman/auto-mount-hdd/main/mount_hdd"

    wget --no-check-certificate -nv -P ${custom_files_path}/sbin "$sync_time"
    wget --no-check-certificate -nv -P ${custom_files_path}/usr/bin "$clock"
    wget --no-check-certificate -nv -P ${custom_files_path}/root "$repair_ro"
    wget --no-check-certificate -nv -P ${custom_files_path}/usr/bin "$mount_hdd"

    echo -e "${STEPS} Downloading files for hotspot" 
    git clone -b "main" "https://github.com/Maizil41/RadiusMonitor.git" "${custom_files_path}/usr/share/RadiusMonitor"
    git clone -b "main" "https://github.com/Maizil41/hotspotlogin.git" "${custom_files_path}/usr/share/hotspotlogin"
    git clone -b "main" "https://github.com/Maizil41/whatsapp-bot.git" "${custom_files_path}/root/whatsapp"
    git clone -b "master" "https://github.com/phpmyadmin/phpmyadmin.git" "${custom_files_path}/www/phpmyadmin"
    mv ${custom_files_path}/root/whatsapp/luci-app-whatsapp-bot/root/root/whatsapp-bot ${custom_files_path}/root/whatsapp-bot
    rm -rf ${custom_files_path}/root/whatsapp

    echo -e "${INFO} All custom configuration setup completed!"
}

# Add custom files
# The FILES variable allows custom configuration files to be included in images built with Image Builder.
# The [ files ] directory should be placed in the Image Builder root directory where you issue the make command.
custom_files() {
    cd ${imagebuilder_path}
    echo -e "${STEPS} Start adding custom files..."

    if [[ -d "${custom_files_path}" ]]; then
        # Copy custom files
        [[ -d "files" ]] || mkdir -p files
        cp -rf ${custom_files_path}/* files

        sync && sleep 3
        echo -e "${INFO} [ files ] directory status: $(ls files -al 2>/dev/null)"
    else
        echo -e "${INFO} No customized files were added."
    fi
}

# Rebuild OpenWrt firmware
rebuild_firmware() {
    cd ${imagebuilder_path}
    echo -e "${STEPS} Start building OpenWrt with Image Builder..."

    # Selecting default packages, lib, theme, app and i18n, etc.
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

    if [ "$op_target" == "rpi-4" ]; then
        misc+=" kmod-i2c-bcm2835 i2c-tools kmod-i2c-core kmod-i2c-gpio luci-app-oled"
    elif [ "$ARCH_2" == "x86_64" ]; then
        misc+=" kmod-iwlwifi iw-full pciutils"
    fi

    if [ "$op_target" == "amlogic" ]; then
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

    # Rebuild firmware
    make image PROFILE="${target_profile}" PACKAGES="${PACKAGES} ${EXCLUDED}" FILES="files"

    sync && sleep 3
    echo -e "${INFO} [ ${openwrt_dir}/bin/targets/*/* ] directory status: $(ls bin/targets/*/* -al 2>/dev/null)"
    echo -e "${SUCCESS} The rebuild is successful, the current path: [ ${PWD} ]"
}

# Show welcome message
echo -e "${STEPS} Welcome to Rebuild OpenWrt Using the Image Builder."
[[ -x "${0}" ]] || error_msg "Please give the script permission to run: [ chmod +x ${0} ]"
[[ -z "${1}" ]] && error_msg "Please specify the OpenWrt Branch, such as [ ${0} openwrt:22.03.3 x86-64 ]"
[[ -z "${2}" ]] && error_msg "Please specify the OpenWrt Target, such as [ ${0} openwrt:22.03.3 x86-64 ]"
[[ "${1}" =~ ^[a-z]{3,}:[0-9]+ ]] || echo "Incoming parameter format <source:branch> <target>: openwrt:22.03.3 x86-64 or openwrt:22.03.3 amlogic"
[[ "${2}" =~ ^[a-zA-Z0-9_-]+ ]] || echo "Incoming parameter format <source:branch> <target>: openwrt:22.03.3 x86-64 or openwrt:22.03.3 amlogic"
op_sourse="${1%:*}"
op_branch="${1#*:}"
op_target="${2}"
echo -e "${INFO} Rebuild path: [ ${PWD} ]"
echo -e "${INFO} Rebuild Source: [ ${op_sourse} ], Branch: [ ${op_branch} ], Target: ${op_target}"
echo -e "${INFO} Server space usage before starting to compile: \n$(df -hT ${make_path}) \n"
#
# Perform related operations
download_imagebuilder
adjust_settings
custom_packages
custom_config
custom_files
rebuild_firmware
#
# Show server end information
echo -e "Server space usage after compilation: \n$(df -hT ${make_path}) \n"
# All process completed
wait