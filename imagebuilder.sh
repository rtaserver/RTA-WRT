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
custom_packages_path="${make_path}/packages"
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
                    echo -e "${INFO} From $file_url"
                    curl -fsSL -o "$(basename "$file_url")" "$file_url"
                    if [ $? -eq 0 ]; then
                        echo -e "${SUCCESS} Package [$filename] downloaded successfully."
                    else
                        error_msg "Failed to download package [$filename]."
                    fi
                else
                    error_msg "Failed to retrieve packages [$filename]. Retrying before exit..."
                fi
            done
        done
    elif [[ $1 == "custom" ]]; then
        for entry in "${list[@]}"; do
            IFS="|" read -r filename base_url <<< "$entry"
            echo -e "${INFO} Processing file: $filename"
            
            # Array untuk menyimpan pola pencarian
            local search_patterns=(
                "\"${filename}[^\"]*\.ipk\""
                "\"${filename}[^\"]*\.apk\""
                "${filename}_.*\.ipk"
				"${filename}_.*\.apk"
                "${filename}.*\.ipk"
				"${filename}.*\.apk"
            )
            
            local file_urls=""
            local full_url=""
            
            # Coba berbagai pola pencarian
            for pattern in "${search_patterns[@]}"; do
                file_urls=$(curl -sL "$base_url" | grep -oE "$pattern" | sed 's/"//g' | sort -V | tail -n 1)
                if [ -n "$file_urls" ]; then
                    full_url="${base_url}/${file_urls%%\"*}"
                    break
                fi
            done
            
            # Percobaan download dengan mekanisme fallback
            if [ -n "$full_url" ]; then
                echo -e "${INFO} Downloading ${file_urls%%\"*}"
                echo -e "${INFO} From $full_url"
                
                local max_attempts=3
                local attempt=1
                local download_success=false
                
                while [ $attempt -le $max_attempts ]; do
                    echo -e "${INFO} Attempt $attempt to download $filename"
                    if curl -fsSL --max-time 60 --retry 2 -o "${filename}.ipk" "$full_url"; then
                        download_success=true
                        break
                    else
                        echo -e "${WARNING} Download failed for $filename (Attempt $attempt)"
                        ((attempt++))
                        sleep 5
                    fi
                done
                
                if [ "$download_success" = false ]; then
                    error_msg "FAILED: Could not download $filename after $max_attempts attempts"
                fi
            else
                error_msg "No matching file found for [$filename] at $base_url."
            fi
        done
    fi
}

# USAGE:
# dl_zip_gh "githubuser/repo:branch" "path to extract"
dl_zip_gh() {
    # Cek format input
    if [[ "${1}" =~ ^([a-zA-Z0-9_-]+)/([a-zA-Z0-9_-]+):([a-zA-Z0-9_-]+)$ ]]; then
        github_user="${BASH_REMATCH[1]}"
        repo="${BASH_REMATCH[2]}"
        branch="${BASH_REMATCH[3]}"
        extract_path="${2}"

        # Tentukan direktori target
        if [[ "${extract_path}" == */ ]]; then
            target_dir="${extract_path%/}"
        else
            target_dir="${extract_path}"
        fi

        [[ -d "${2}" ]] || rm -rf ${2}
        mkdir -p "${target_dir}"

        # Tentukan nama ZIP dan URL
        zip_file="${target_dir}/${repo}-${branch}.zip"
        zip_url="https://github.com/${github_user}/${repo}/archive/refs/heads/${branch}.zip"

        # Unduh ZIP dari GitHub
        echo -e "${INFO} Downloading ZIP from: ${zip_url}"
        curl -fsSL -o "${zip_file}" "${zip_url}"

        # Periksa apakah ZIP berhasil diunduh
        if [[ -f "${zip_file}" ]]; then
            echo -e "${INFO} ZIP file downloaded to: ${zip_file}"

            # Hapus direktori target jika sudah ada
            if [[ -d "${target_dir}/${repo}-${branch}" ]]; then
                echo -e "${INFO} Removing existing directory: ${target_dir}/${repo}-${branch}"
                rm -rf "${target_dir}/${repo}-${branch}"
            fi

            # Ekstrak ZIP
            echo -e "${INFO} Extracting ${zip_file} to ${target_dir}..."
            unzip -q "${zip_file}" -d "${target_dir}"

            # Pindahkan direktori hasil ekstraksi
            extracted_dir="${target_dir}/${repo}-${branch}"
            if [[ -d "${extracted_dir}" ]]; then
                echo -e "${INFO} Moving extracted directory to ${target_dir}..."
                mv "${extracted_dir}"/* "${target_dir}/"
            else
                error_msg "Extracted directory not found. Expected: ${extracted_dir}"
            fi

            # Hapus file ZIP
            echo -e "${INFO} Removing ZIP file: ${zip_file}"
            rm -f "${zip_file}"
            rm -rf "${2}/${repo}-${branch}"

            echo -e "${SUCCESS} Download and extraction complete. Directory created at: ${target_dir}"
        else
            error_msg "ZIP file not downloaded successfully."
        fi
    else
        error_msg "Invalid format. Usage: dl_zip_gh \"githubuser/repo:branch\" \"path to extract\""
    fi
}

# Downloading OpenWrt ImageBuilder
download_imagebuilder() {
    cd ${make_path}
    echo -e "${STEPS} Start downloading OpenWrt files..."

    if [[ "${op_target}" == "amlogic" || "${op_target}" == "AMLOGIC" ]]; then
        op_target="amlogic"
        target_profile=""
        target_system="armsr/armv8"
        target_name="armsr-armv8"
        ARCH_1="arm64"
        ARCH_2="aarch64"
        ARCH_3="aarch64_generic"
    elif [[ "${op_target}" == "rpi-3" ]]; then
        op_target="rpi-3"
        target_profile="rpi-3"
        target_system="bcm27xx/bcm2710"
        target_name="bcm27xx-bcm2710"
        ARCH_1="arm64"
        ARCH_2="aarch64"
        ARCH_3="aarch64_cortex-a53"
    elif [[ "${op_target}" == "rpi-4" ]]; then
        op_target="rpi-4"
        target_profile="rpi-4"
        target_system="bcm27xx/bcm2711"
        target_name="bcm27xx-bcm2711"
        ARCH_1="arm64"
        ARCH_2="aarch64"
        ARCH_3="aarch64_cortex-a72"
    elif [[ "${op_target}" == "friendlyarm_nanopi-r2c" ]]; then
        op_target="nanopi-r2c"
        target_profile="friendlyarm_nanopi-r2c"
        target_system="rockchip/armv8"
        target_name="rockchip-armv8"
        ARCH_1="arm64"
        ARCH_2="aarch64"
        ARCH_3="aarch64_generic"
    elif [[ "${op_target}" == "friendlyarm_nanopi-r2s" ]]; then
        op_target="nanopi-r2s"
        target_profile="friendlyarm_nanopi-r2s"
        target_system="rockchip/armv8"
        target_name="rockchip-armv8"
        ARCH_1="arm64"
        ARCH_2="aarch64"
        ARCH_3="aarch64_generic"
    elif [[ "${op_target}" == "friendlyarm_nanopi-r4s" ]]; then
        op_target="nanopi-r4s"
        target_profile="friendlyarm_nanopi-r4s"
        target_system="rockchip/armv8"
        target_name="rockchip-armv8"
        ARCH_1="arm64"
        ARCH_2="aarch64"
        ARCH_3="aarch64_generic"
    elif [[ "${op_target}" == "xunlong_orangepi-r1-plus" ]]; then
        op_target="orangepi-r1-plus"
        target_profile="xunlong_orangepi-r1-plus"
        target_system="rockchip/armv8"
        target_name="rockchip-armv8"
        ARCH_1="arm64"
        ARCH_2="aarch64"
        ARCH_3="aarch64_generic"
    elif [[ "${op_target}" == "xunlong_orangepi-r1-plus-lts" ]]; then
        op_target="orangepi-r1-plus-lts"
        target_profile="xunlong_orangepi-r1-plus-lts"
        target_system="rockchip/armv8"
        target_name="rockchip-armv8"
        ARCH_1="arm64"
        ARCH_2="aarch64"
        ARCH_3="aarch64_generic"
    elif [[ "${op_target}" == "generic" || "${op_target}" == "x86-64" || "${op_target}" == "x86_64" ]]; then
        op_target="x86-64"
        target_profile="generic"
        target_system="x86/64"
        target_name="x86-64"
        ARCH_1="amd64"
        ARCH_2="x86_64"
        ARCH_3="x86_64"
    fi

    # Downloading imagebuilder files
    # PIlih Salah Satu Versi #
    # Openwrt 23.05.5 #
    #download_file="https://downloads.${op_sourse}.org/releases/${op_branch}/targets/${target_system}/${op_sourse}-imagebuilder-${op_branch}-${target_name}.Linux-x86_64.tar.xz"
    # Openwrt 24.10.0 #
    download_file="https://downloads.${op_sourse}.org/releases/${op_branch}/targets/${target_system}/${op_sourse}-imagebuilder-${op_branch}-${target_name}.Linux-x86_64.tar.zst"
    
    curl -fsSOL ${download_file}
    [[ "${?}" -eq "0" ]] || error_msg "Download failed: [ ${download_file} ]"
    echo -e "${SUCCESS} Download Base ${op_branch} ${target_name} successfully!"

    # Unzip and change the directory name
    # Untuk Openwrt 23.05.5 #
    #tar -xJf *-imagebuilder-* && sync && rm -f *-imagebuilder-*.tar.xz
    # Untuk Openwrt 24.10.0 #
    tar -zstd -zvf *-imagebuilder-* && sync && rm -f *-imagebuilder-*.tar.zst
    mv -f *-imagebuilder-* ${openwrt_dir}

    sync && sleep 3
    echo -e "${INFO} [ ${make_path} ] directory status: $(ls -al 2>/dev/null)"
}

# Adjust related files in the ImageBuilder directory
adjust_settings() {
    cd ${imagebuilder_path}
    echo -e "${STEPS} Start adjusting .config file settings..."

    DTM=$(date '+%d-%m-%Y')
    CURVER=$(echo $op_branch | awk -F. '{print $1"."$2}')

    sed -i "s|Ouc3kNF6|$DTM|g" "${custom_files_path}/etc/uci-defaults/99-first-setup"

    if [[ -s "repositories.conf" ]]; then
        sed -i '\|option check_signature| s|^|#|' repositories.conf
    fi

    if [[ -s "Makefile" ]]; then
        sed -i "s/install \$(BUILD_PACKAGES)/install \$(BUILD_PACKAGES) --force-overwrite --force-downgrade/" Makefile
    fi

    # For .config file
    if [[ -s ".config" ]]; then

        # Resize Boot and Rootfs partition size
        sed -i "s/CONFIG_TARGET_KERNEL_PARTSIZE=.*/CONFIG_TARGET_KERNEL_PARTSIZE=128/" .config
        sed -i "s/CONFIG_TARGET_ROOTFS_PARTSIZE=.*/CONFIG_TARGET_ROOTFS_PARTSIZE=1024/" .config

        if [ "$op_target" == "amlogic" ]; then
            sed -i "s|CONFIG_TARGET_ROOTFS_CPIOGZ=.*|# CONFIG_TARGET_ROOTFS_CPIOGZ is not set|g" .config
            sed -i "s|CONFIG_TARGET_ROOTFS_EXT4FS=.*|# CONFIG_TARGET_ROOTFS_EXT4FS is not set|g" .config
            sed -i "s|CONFIG_TARGET_ROOTFS_SQUASHFS=.*|# CONFIG_TARGET_ROOTFS_SQUASHFS is not set|g" .config
            sed -i "s|CONFIG_TARGET_IMAGES_GZIP=.*|# CONFIG_TARGET_IMAGES_GZIP is not set|g" .config
        fi

        if [ "$ARCH_2" == "x86_64" ]; then
            # Not generate ISO images for it is too big
            sed -i "s/CONFIG_ISO_IMAGES=y/# CONFIG_ISO_IMAGES is not set/" .config
            # Not generate VHDX images
            sed -i "s/CONFIG_VHDX_IMAGES=y/# CONFIG_VHDX_IMAGES is not set/" .config
        fi
    else
        echo -e "${INFO} [ ${imagebuilder_path} ] directory status: $(ls -al 2>/dev/null)"
        error_msg "There is no .config file in the [ ${download_file} ]"
    fi

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
    [[ -d "packages" ]] || mkdir -p packages
    if [[ -d "${custom_packages_path}" ]]; then
        # Copy custom packages
        cp -rf ${custom_packages_path}/* packages
        echo -e "${INFO} [ packages ] directory status: $(ls packages -al 2>/dev/null)"
    else
        echo -e "${WARNING} No customized Packages were added."
    fi

    cd packages

    # Download IPK From Github
    # Download luci-app-amlogic
    if [ "$op_target" == "amlogic" ]; then
        echo "Adding [luci-app-amlogic] from bulider script type."
        github_packages+=("luci-app-amlogic|https://api.github.com/repos/ophub/luci-app-amlogic/releases/latest")
    fi
    github_packages+=(
        "luci-app-netmonitor|https://api.github.com/repos/rtaserver/rta-packages/releases"
        #"luci-app-base64|https://api.github.com/repos/rtaserver/rta-packages/releases"
    )
    download_packages "github" github_packages[@]

    # Download IPK From Custom
    CURVER=$(echo $op_branch | awk -F. '{print $1"."$2}')
    other_packages=(
        "luci-app-3ginfo-lite|https://dl.openwrt.ai/packages-24.10/$ARCH_3/kiddin9"
        "modemband|https://dl.openwrt.ai/packages-24.10/$ARCH_3/kiddin9"
        "luci-app-sms-tool|https://dl.openwrt.ai/packages-24.10/$ARCH_3/kiddin9"
        "luci-app-modemband|https://dl.openwrt.ai/packages-24.10/$ARCH_3/kiddin9"
        "luci-app-sms-tool-js|https://dl.openwrt.ai/packages-24.10/$ARCH_3/kiddin9"
        "speedtestcli|https://dl.openwrt.ai/packages-24.10/$ARCH_3/kiddin9"
        "luci-app-ramfree|https://dl.openwrt.ai/packages-24.10/$ARCH_3/kiddin9"
        "modemmanager-rpcd|https://downloads.$op_sourse.org/releases/packages-24.10/$ARCH_3/packages"
        "luci-proto-modemmanager|https://downloads.$op_sourse.org/releases/packages-24.10/$ARCH_3/luci"
        "libqmi|https://downloads.$op_sourse.org/releases/packages-24.10/$ARCH_3/packages"
        "libmbim|https://downloads.$op_sourse.org/releases/packages-24.10/$ARCH_3/packages"
        "modemmanager|https://downloads.$op_sourse.org/releases/packages-24.10/$ARCH_3/packages"
        "sms-tool|https://downloads.$op_sourse.org/releases/packages-24.10/$ARCH_3/packages"
        "tailscale|https://downloads.$op_sourse.org/releases/packages-24.10/$ARCH_3/packages"
        "luci-app-tailscale|https://dl.openwrt.ai/packages-24.10/$ARCH_3/kiddin9"
        "luci-app-diskman|https://dl.openwrt.ai/packages-24.10/$ARCH_3/kiddin9"
        "luci-app-modeminfo|https://dl.openwrt.ai/packages-24.10/$ARCH_3/kiddin9"
        "modeminfo|https://dl.openwrt.ai/packages-24.10/$ARCH_3/kiddin9"
        "atinout|https://dl.openwrt.ai/packages-24.10/$ARCH_3/kiddin9"
        "luci-app-poweroff|https://dl.openwrt.ai/packages-24.10/$ARCH_3/kiddin9"
        "xmm-modem|https://dl.openwrt.ai/packages-24.10/$ARCH_3/kiddin9"
        "luci-app-log-viewer|https://github.com/gSpotx2f/packages-openwrt/raw/refs/heads/master/current"
        "luci-app-temp-status|https://github.com/gSpotx2f/packages-openwrt/raw/refs/heads/master/current"
        "luci-theme-argon|https://dl.openwrt.ai/packages-24.10/$ARCH_3/kiddin9"
        "luci-app-droidnet|https://dl.openwrt.ai/packages-24.10/aarch64_generic/kiddin9"
        "luci-app-internet-detector|https://dl.openwrt.ai/packages-24.10/$ARCH_3/kiddin9"
        "internet-detector-mod-modem-restart|https://dl.openwrt.ai/packages-24.10/$ARCH_3/kiddin9"
        "internet-detector|https://dl.openwrt.ai/packages-24.10/$ARCH_3/kiddin9"
        "luci-app-eqosplus|https://dl.openwrt.ai/packages-24.10/$ARCH_3/kiddin9"
        "luci-app-tinyfm|https://dl.openwrt.ai/packages-24.10/$ARCH_3/kiddin9"
        #"luci-app-zerotier|https://dl.openwrt.ai/packages-24.10/$ARCH_3/kiddin9"
        #"luci-app-gpioled|https://dl.openwrt.ai/packages-24.10/$ARCH_3/kiddin9"
    )
    download_packages "custom" other_packages[@]

    # OpenClash
    openclash_api="https://api.github.com/repos/vernesong/OpenClash/releases"
    openclash_file_ipk="luci-app-openclash"
    openclash_file_ipk_down="$(curl -s ${openclash_api} | grep "browser_download_url" | grep -oE "https.*${openclash_file_ipk}.*.ipk" | head -n 1)"

    echo -e "${STEPS} Start Clash Core Download !"
    core_dir="${custom_files_path}/etc/openclash/core"
    mkdir -p $core_dir
    if [[ "$ARCH_3" == "x86_64" ]]; then
        clash_meta="$(meta_api="https://api.github.com/repos/MetaCubeX/mihomo/releases/latest" && meta_file="mihomo-linux-$ARCH_1-compatible" && curl -s ${meta_api} | grep "browser_download_url" | grep -oE "https.*${meta_file}-v[0-9]+\.[0-9]+\.[0-9]+\.gz" | head -n 1)"
    else
        clash_meta="$(meta_api="https://api.github.com/repos/MetaCubeX/mihomo/releases/latest" && meta_file="mihomo-linux-$ARCH_1" && curl -s ${meta_api} | grep "browser_download_url" | grep -oE "https.*${meta_file}-v[0-9]+\.[0-9]+\.[0-9]+\.gz" | head -n 1)"
    fi

    # Mihomo
    mihomo_api="https://api.github.com/repos/rtaserver/OpenWrt-mihomo-Mod/releases"
    mihomo_file_ipk="mihomo_${ARCH_3}-openwrt-23.05" #$op_branch | cut -d '.' -f 1-2
    mihomo_file_ipk_down="$(curl -s ${mihomo_api} | grep "browser_download_url" | grep -oE "https.*${mihomo_file_ipk}.*.tar.gz" | head -n 1)"


    # Output download information
    echo -e "${STEPS} Installing OpenClash, Mihomo"

    echo -e "${INFO} Downloading OpenClash package"
    curl -fsSOL ${openclash_file_ipk_down}
    if [ "$?" -ne 0 ]; then
        error_msg "Error: Failed to download OpenClash package."
    fi
    curl -fsSL -o "${core_dir}/clash_meta.gz" "${clash_meta}"
    gzip -d $core_dir/clash_meta.gz
    if [ "$?" -ne 0 ]; then
        error_msg "Error: Failed to extract OpenClash package."
    fi
    echo -e "${INFO} OpenClash Packages downloaded successfully."

    echo -e "${INFO} Downloading Mihomo package"
    curl -fsSOL ${mihomo_file_ipk_down}
    if [ "$?" -ne 0 ]; then
        error_msg "Error: Failed to download Mihomo package."
    fi
    tar -xzvf "mihomo_${ARCH_3}-openwrt-23.05.tar.gz" && rm "mihomo_${ARCH_3}-openwrt-23.05.tar.gz"
    if [ "$?" -ne 0 ]; then
        error_msg "Error: Failed to extract Mihomo package."
    fi
    echo -e "${INFO} Mihomo Packages downloaded successfully."


    echo -e "${SUCCESS} Download and extraction All complete."
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
    #mount_hdd="https://raw.githubusercontent.com/frizkyiman/auto-mount-hdd/main/mount_hdd"

    curl -fsSL -o "${custom_files_path}/sbin/sync_time.sh" "${sync_time}"
    curl -fsSL -o "${custom_files_path}/usr/bin/clock" "${clock}"
    curl -fsSL -o "${custom_files_path}/root/install2.sh" "${repair_ro}"
    #curl -fsSL -o "${custom_files_path}/usr/bin/mount_hdd" "${mount_hdd}"

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
        echo -e "${WARNING} No customized files were added."
    fi
}

# Rebuild OpenWrt firmware
rebuild_firmware() {
    cd ${imagebuilder_path}
    echo -e "${STEPS} Start building OpenWrt with Image Builder..."

    # Selecting default packages, lib, theme, app and i18n, etc.
    PACKAGES+=" file lolcat kmod-usb-net-rtl8150 kmod-usb-net-rtl8152 kmod-usb-net-asix kmod-usb-net-asix-ax88179"
    PACKAGES+=" kmod-mii kmod-usb-net kmod-usb-wdm kmod-usb-net-qmi-wwan uqmi \
    kmod-usb-net-cdc-ether kmod-usb-serial-option kmod-usb-serial kmod-usb-serial-wwan qmi-utils \
    kmod-usb-serial-qualcomm kmod-usb-acm kmod-usb-net-cdc-ncm kmod-usb-net-cdc-mbim umbim \
    modemmanager modemmanager-rpcd luci-proto-modemmanager libmbim libqmi usbutils luci-proto-mbim luci-proto-ncm \
    kmod-usb-net-huawei-cdc-ncm kmod-usb-net-cdc-ether kmod-usb-net-rndis kmod-usb-net-sierrawireless kmod-usb-ohci kmod-usb-serial-sierrawireless \
    kmod-usb-uhci kmod-usb2 kmod-usb-ehci kmod-usb-net-ipheth usbmuxd libusbmuxd-utils libimobiledevice-utils usb-modeswitch kmod-nls-utf8 mbim-utils xmm-modem \
    kmod-phy-broadcom kmod-phylib-broadcom kmod-tg3 iptables-nft coreutils-stty"
    
    # Modem Tools
    PACKAGES+=" modeminfo luci-app-modeminfo atinout modemband luci-app-modemband sms-tool luci-app-sms-tool-js luci-app-3ginfo-lite picocom minicom"

    # Tunnel option
    OPENCLASH="coreutils-nohup bash dnsmasq-full curl ca-certificates ipset ip-full libcap libcap-bin ruby ruby-yaml kmod-tun kmod-inet-diag unzip kmod-nft-tproxy luci-compat luci luci-base luci-app-openclash"
    MIHOMO+="mihomo luci-app-mihomo"
    PACKAGES+=" $OPENCLASH $MIHOMO"

    # Remote Services
    PACKAGES+=" tailscale luci-app-tailscale"

    # NAS and Hard disk tools
    PACKAGES+=" luci-app-diskman ntfs-3g"

    # Docker
    #PACKAGES+=" docker docker-compose dockerd luci-app-dockerman"

    # Bandwidth And Network Monitoring
    PACKAGES+=" internet-detector luci-app-internet-detector internet-detector-mod-modem-restart vnstat2 vnstati2 luci-app-netmonitor"

    # Speedtest
    PACKAGES+=" speedtestcli"

    # Base64 Encode Decode
    #PACKAGES+=" luci-app-base64"

    # Custom Package #
    #Theme materual
    #PACKAGES+=" luci-theme-material"

    # PHP8
    PACKAGES+=" php8 php8-cgi php8-fastcgi php8-fpm php8-mod-session php8-mod-ctype php8-mod-fileinfo php8-mod-zip php8-mod-iconv php8-mod-mbstring coreutils-stat zoneinfo-asia bash curl tar"
    #PACKAGES+=" libc php8 php8-fastcgi php8-fpm coreutils-stat zoneinfo-asia php8-cgi \
    #php8-cli php8-mod-bcmath php8-mod-calendar php8-mod-ctype php8-mod-curl php8-mod-dom php8-mod-exif \
    #php8-mod-fileinfo php8-mod-filter php8-mod-gd php8-mod-iconv php8-mod-intl php8-mod-mbstring php8-mod-mysqli \
    #php8-mod-mysqlnd php8-mod-opcache php8-mod-pdo php8-mod-pdo-mysql php8-mod-phar php8-mod-session \
   # php8-mod-xml php8-mod-xmlreader php8-mod-xmlwriter php8-mod-zip libopenssl-legacy"

    # Misc and some custom .ipk files
    misc=""
    if [ "$op_target" == "openwrt" ]; then
        misc+=" luci-app-temp-status luci-app-rakitanmanager luci-theme-alpha luci-theme-argon luci-app-droidnet"
    elif [ "$op_target" == "immortalwrt" ]; then
        misc+=" luci-app-temp-status luci-app-rakitanmanager luci-theme-alpha luci-theme-argon luci-app-droidnet"
    fi

    if [ "$op_target" == "rpi-4" ]; then
        misc+=" kmod-i2c-bcm2835 i2c-tools kmod-i2c-core kmod-i2c-gpio luci-app-oled"
    elif [ "$ARCH_2" == "x86_64" ]; then
        misc+=" kmod-iwlwifi iw-full pciutils"
    fi

    if [ "$op_target" == "amlogic" ]; then
        PACKAGES+=" luci-app-amlogic ath9k-htc-firmware btrfs-progs hostapd hostapd-utils kmod-ath kmod-ath9k kmod-ath9k-common kmod-ath9k-htc kmod-cfg80211 kmod-crypto-acompress kmod-crypto-crc32c kmod-crypto-hash kmod-fs-btrfs kmod-mac80211 wireless-tools wpa-cli wpa-supplicant"
        EXCLUDED+=" -procd-ujail"
    fi

    PACKAGES+=" $misc zram-swap adb parted losetup luci luci-ssl block-mount luci-app-poweroff luci-app-ramfree htop bash curl wget-ssl unzip jq luci-app-ttyd nano luci-app-tinyfm luci-app-eqosplus"

    # Exclude package (must use - before packages name)
    EXCLUDED+=" -libgd"
    if [ "${op_sourse}" == "openwrt" ]; then
        EXCLUDED+=" -dnsmasq"
    elif [ "${op_sourse}" == "immortalwrt" ]; then
        EXCLUDED+=" -dnsmasq -automount -libustream-openssl -default-settings-chn -luci-i18n-base-zh-cn"
        if [ "$ARCH_2" == "x86_64" ]; then
        EXCLUDED+=" -kmod-usb-net-rtl8152-vendor"
        fi
    fi

    # Rebuild firmware
    make clean
    make image PROFILE="${target_profile}" PACKAGES="${PACKAGES} ${EXCLUDED}" FILES="files"
    if [ $? -ne 0 ]; then
        error_msg "OpenWrt build failed. Check logs for details."
    else
        sync && sleep 3
        echo -e "${INFO} [ ${openwrt_dir}/bin/targets/*/* ] directory status: $(ls bin/targets/*/* -al 2>/dev/null)"
        echo -e "${SUCCESS} The rebuild is successful, the current path: [ ${PWD} ]"
    fi
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