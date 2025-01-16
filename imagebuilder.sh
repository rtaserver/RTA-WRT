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
                        echo -e "${SUCCESS} Package [$filename] downloaded successfully."
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
    cd "${make_path}" || { error_msg "Failed to change directory to ${make_path}"; }
    echo -e "${STEPS} Start downloading OpenWrt files..."

    case "${op_devices}" in
        h5-*|h616-*|h618-*|h6-*)
            op_target="allwinner"
            target_profile="generic"
            target_system="armsr/armv8"
            target_name="armsr-armv8"
            ARCH_1="arm64"
            ARCH_2="aarch64"
            ARCH_3="aarch64_generic"
            KERNEL="6.6.6-AW64-DBAI"
            ;;
        s905*)
            op_target="amlogic"
            target_profile="generic"
            target_system="armsr/armv8"
            target_name="armsr-armv8"
            ARCH_1="arm64"
            ARCH_2="aarch64"
            ARCH_3="aarch64_generic"
            KERNEL="6.1.66-DBAI"
            ;;
        rk*)
            op_target="rockchip"
            target_profile="generic"
            target_system="armsr/armv8"
            target_name="armsr-armv8"
            ARCH_1="arm64"
            ARCH_2="aarch64"
            ARCH_3="aarch64_generic"
            KERNEL="5.10.160-rk35v-dbai"
            ;;
        x86-64|x86_64)
            op_target="x86-64"
            target_profile="generic"
            target_system="x86/64"
            target_name="x86-64"
            ARCH_1="amd64"
            ARCH_2="x86_64"
            ARCH_3="x86_64"
            ;;
        *)
            echo -e "${INFO} Available target devices: h5-*, h616-*, h618-*, h6-*, s905*, rk*, x86-64"
            error_msg "Unknown target: ${op_devices}"
            ;;
    esac

    # Penentuan URL file download
    CURVER=$(echo "${op_branch}" | awk -F. '{print $1"."$2}')
    if [[ "${CURVER}" == "23.05" ]]; then
        archive_ext="tar.xz"
    else
        archive_ext="tar.zst"
    fi
    download_file="https://downloads.${op_sourse}.org/releases/${op_branch}/targets/${target_system}/${op_sourse}-imagebuilder-${op_branch}-${target_name}.Linux-x86_64.${archive_ext}"

    curl -fsSOL "${download_file}"
    if [ "$?" -ne 0 ]; then
         error_msg "Failed to download ${download_file}"
    fi

    # Ekstraksi file
    if [[ "${archive_ext}" == "tar.xz" ]]; then
        tar -xJf *-imagebuilder-* && sync && rm -f *-imagebuilder-*.tar.xz
    else
        tar --use-compress-program=unzstd -xvf *-imagebuilder-* && sync && rm -f *-imagebuilder-*.tar.zst
    fi

    mv -f *-imagebuilder-* "${openwrt_dir}" || {
        error_msg "Failed to move extracted files to ${openwrt_dir}."
    }

    sync && sleep 3
    echo -e "${INFO} [ ${make_path} ] directory status: $(ls -al 2>/dev/null)"
}


# Adjust related files in the ImageBuilder directory
adjust_settings() {
    cd "${imagebuilder_path}" || { error_msg "Failed to change directory to ${imagebuilder_path}"; }
    echo -e "${STEPS} Start adjusting .config file settings..."

    # Variabel
    DTM=$(date '+%d-%m-%Y')
    CURVER=$(echo "$op_branch" | awk -F. '{print $1"."$2}')

    # Update 99-first-setup
    if [[ -s "${custom_files_path}/etc/uci-defaults/99-first-setup" ]]; then
        sed -i "s|Ouc3kNF6|$DTM|g" "${custom_files_path}/etc/uci-defaults/99-first-setup"
        echo -e "${INFO} Updated 99-first-setup with date: $DTM"
    else
        echo -e "${WARN} File 99-first-setup not found or is empty."
    fi

    # Update repositories.conf
    if [[ -s "repositories.conf" ]]; then
        sed -i '\|option check_signature| s|^|#|' repositories.conf
        echo -e "${INFO} Updated repositories.conf to disable signature checks."
    else
        echo -e "${WARN} File repositories.conf not found or is empty."
    fi

    # Update Makefile
    if [[ -s "Makefile" ]]; then
        sed -i "s/install \$(BUILD_PACKAGES)/install \$(BUILD_PACKAGES) --force-overwrite --force-downgrade/" Makefile
        echo -e "${INFO} Updated Makefile to include force-overwrite and force-downgrade."
    else
        echo -e "${WARN} File Makefile not found or is empty."
    fi

    # Update .config
    if [[ -s ".config" ]]; then
        echo -e "${INFO} Updating .config file settings..."

        # Resize Boot and Rootfs partition size
        sed -i "s/CONFIG_TARGET_KERNEL_PARTSIZE=.*/CONFIG_TARGET_KERNEL_PARTSIZE=128/" .config
        sed -i "s/CONFIG_TARGET_ROOTFS_PARTSIZE=.*/CONFIG_TARGET_ROOTFS_PARTSIZE=1024/" .config

        # Specific settings for Amlogic
        if [[ "$op_target" == "amlogic" ]]; then
            sed -i "s|CONFIG_TARGET_ROOTFS_CPIOGZ=.*|# CONFIG_TARGET_ROOTFS_CPIOGZ is not set|g" .config
            sed -i "s|CONFIG_TARGET_ROOTFS_EXT4FS=.*|# CONFIG_TARGET_ROOTFS_EXT4FS is not set|g" .config
            sed -i "s|CONFIG_TARGET_ROOTFS_SQUASHFS=.*|# CONFIG_TARGET_ROOTFS_SQUASHFS is not set|g" .config
            sed -i "s|CONFIG_TARGET_IMAGES_GZIP=.*|# CONFIG_TARGET_IMAGES_GZIP is not set|g" .config
            echo -e "${INFO} Updated Amlogic-specific .config settings."
        fi

        # Specific settings for x86_64 architecture
        if [[ "$ARCH_2" == "x86_64" ]]; then
            sed -i "s/CONFIG_ISO_IMAGES=y/# CONFIG_ISO_IMAGES is not set/" .config
            sed -i "s/CONFIG_VHDX_IMAGES=y/# CONFIG_VHDX_IMAGES is not set/" .config
            echo -e "${INFO} Updated x86_64-specific .config settings."
        fi
    else
        error_msg "No .config file found in ${imagebuilder_path}. Ensure the correct file is available."
    fi

    # Sinkronisasi dan cek status direktori
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
    # github_packages+=(
    #     "luci-app-netmonitor|https://api.github.com/repos/rizkikotet-dev/rta-packages/releases"
    #     "luci-app-base64|https://api.github.com/repos/rizkikotet-dev/rta-packages/releases"
    # )
    download_packages "github" github_packages[@]

    # Download IPK From Custom
    CURVER=$(echo $op_branch | awk -F. '{print $1"."$2}')
    other_packages=(
        "modemmanager-rpcd|https://downloads.$op_sourse.org/releases/packages-24.10/$ARCH_3/packages"
        "luci-proto-modemmanager|https://downloads.$op_sourse.org/releases/packages-24.10/$ARCH_3/luci"
        "libqmi|https://downloads.$op_sourse.org/releases/packages-24.10/$ARCH_3/packages"
        "libmbim|https://downloads.$op_sourse.org/releases/packages-24.10/$ARCH_3/packages"
        "modemmanager|https://downloads.$op_sourse.org/releases/packages-24.10/$ARCH_3/packages"
        "sms-tool|https://downloads.$op_sourse.org/releases/packages-24.10/$ARCH_3/packages"
        "tailscale|https://downloads.$op_sourse.org/releases/packages-24.10/$ARCH_3/packages"
        "python3-speedtest-cli|https://downloads.openwrt.org/releases/packages-$CURVER/$ARCH_3/packages"

        "dns2tcp|https://downloads.immortalwrt.org/releases/packages-$CURVER/$ARCH_3/packages"

        "luci-app-tailscale|https://dl.openwrt.ai/packages-$CURVER/$ARCH_3/kiddin9"
        "luci-app-diskman|https://dl.openwrt.ai/packages-$CURVER/$ARCH_3/kiddin9"
        "modeminfo|https://dl.openwrt.ai/packages-$CURVER/$ARCH_3/kiddin9"
        "luci-app-modeminfo|https://dl.openwrt.ai/packages-$CURVER/$ARCH_3/kiddin9"
        "atinout|https://dl.openwrt.ai/packages-$CURVER/$ARCH_3/kiddin9"
        "luci-app-poweroff|https://dl.openwrt.ai/packages-$CURVER/$ARCH_3/kiddin9"
        "xmm-modem|https://dl.openwrt.ai/packages-$CURVER/$ARCH_3/kiddin9"
        "luci-app-lite-watchdog|https://dl.openwrt.ai/packages-$CURVER/$ARCH_3/kiddin9"

        "luci-app-internet-detector|https://github.com/gSpotx2f/packages-openwrt/raw/refs/heads/master/current"
        "internet-detector|https://github.com/gSpotx2f/packages-openwrt/raw/refs/heads/master/current"
        "internet-detector-mod-modem-restart|https://github.com/gSpotx2f/packages-openwrt/raw/refs/heads/master/current"
        "luci-app-cpu-status-mini|https://github.com/gSpotx2f/packages-openwrt/raw/refs/heads/master/current"
        "luci-app-disks-info|https://github.com/gSpotx2f/packages-openwrt/raw/refs/heads/master/current"
        "luci-app-log-viewer|https://github.com/gSpotx2f/packages-openwrt/raw/refs/heads/master/current"
        "luci-app-temp-status|https://github.com/gSpotx2f/packages-openwrt/raw/refs/heads/master/current"
        
        "luci-app-zerotier|https://downloads.immortalwrt.org/releases/packages-24.10/$ARCH_3/luci"
        "luci-app-ramfree|https://downloads.immortalwrt.org/releases/packages-24.10/$ARCH_3/luci"
        "luci-app-3ginfo-lite|https://downloads.immortalwrt.org/releases/packages-24.10/$ARCH_3/luci"
        "modemband|https://downloads.immortalwrt.org/releases/packages-24.10/$ARCH_3/packages"
        "luci-app-modemband|https://downloads.immortalwrt.org/releases/packages-24.10/$ARCH_3/luci"
        "luci-app-sms-tool-js|https://downloads.immortalwrt.org/releases/packages-24.10/$ARCH_3/luci"

        "luci-app-netspeedtest|https://fantastic-packages.github.io/packages/releases/$CURVER/packages/x86_64/luci"
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
    mihomo_api="https://api.github.com/repos/rizkikotet-dev/OpenWrt-mihomo-Mod/releases"
    mihomo_file_ipk="mihomo_${ARCH_3}-openwrt-${CURVER}" #$op_branch | cut -d '.' -f 1-2
    mihomo_file_ipk_down="$(curl -s ${mihomo_api} | grep "browser_download_url" | grep -oE "https.*${mihomo_file_ipk}.*.tar.gz" | head -n 1)"

    #passwall
    passwall_api="https://api.github.com/repos/xiaorouji/openwrt-passwall/releases"
    passwall_file_ipk="luci-23.05_luci-app-passwall"
    passwall_file_zip="passwall_packages_ipk_${ARCH_3}"
    passwall_file_ipk_down="$(curl -s ${passwall_api} | grep "browser_download_url" | grep -oE "https.*${passwall_file_ipk}.*.ipk" | head -n 1)"
    passwall_file_zip_down="$(curl -s ${passwall_api} | grep "browser_download_url" | grep -oE "https.*${passwall_file_zip}.*.zip" | head -n 1)"


    # Output download information
    echo -e "${STEPS} Installing OpenClash, Mihomo And Passwall"

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
    tar -xzvf "mihomo_${ARCH_3}-openwrt-${CURVER}.tar.gz" && rm "mihomo_${ARCH_3}-openwrt-${CURVER}.tar.gz"
    if [ "$?" -ne 0 ]; then
        error_msg "Error: Failed to extract Mihomo package."
    fi
    echo -e "${INFO} Mihomo Packages downloaded successfully."

    echo -e "${INFO} Downloading Passwall package"
    curl -fsSOL ${passwall_file_ipk_down}
    if [ "$?" -ne 0 ]; then
        error_msg "Error: Failed to download Passwall package."
    fi
    curl -fsSOL ${passwall_file_zip_down}
    if [ "$?" -ne 0 ]; then
        error_msg "Error: Failed to download Passwall Zip package."
    fi
    unzip -q "passwall_packages_ipk_${ARCH_3}.zip" && rm "passwall_packages_ipk_${ARCH_3}.zip"
    if [ "$?" -ne 0 ]; then
        error_msg "Error: Failed to extract Passwall package."
    fi
    echo -e "${INFO} Passwall Packages downloaded successfully."


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
    mount_hdd="https://raw.githubusercontent.com/frizkyiman/auto-mount-hdd/main/mount_hdd"

    curl -fsSL -o "${custom_files_path}/sbin/sync_time.sh" "${sync_time}"
    curl -fsSL -o "${custom_files_path}/usr/bin/clock" "${clock}"
    curl -fsSL -o "${custom_files_path}/root/install2.sh" "${repair_ro}"
    curl -fsSL -o "${custom_files_path}/usr/bin/mount_hdd" "${mount_hdd}"

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
    PACKAGES+=" modeminfo luci-app-modeminfo atinout modemband luci-app-modemband sms-tool luci-app-sms-tool-js luci-app-lite-watchdog luci-app-3ginfo-lite picocom minicom"

    # Tunnel option
    OPENCLASH="coreutils-nohup bash dnsmasq-full curl ca-certificates ipset ip-full libcap libcap-bin ruby ruby-yaml kmod-tun kmod-inet-diag unzip kmod-nft-tproxy luci-compat luci luci-base luci-app-openclash"
    MIHOMO+="mihomo luci-app-mihomo"
    PASSWALL+="chinadns-ng resolveip dns2socks dns2tcp ipt2socks microsocks tcping xray-core xray-plugin luci-app-passwall"
    PACKAGES+=" $OPENCLASH $MIHOMO $PASSWALL"

    # Remote Services
    PACKAGES+=" luci-app-zerotier luci-app-cloudflared"

    # NAS and Hard disk tools
    PACKAGES+=" luci-app-diskman luci-app-disks-info smartmontools kmod-usb-storage kmod-usb-storage-uas ntfs-3g"

    # Bandwidth And Network Monitoring
    PACKAGES+=" internet-detector luci-app-internet-detector internet-detector-mod-modem-restart nlbwmon luci-app-nlbwmon vnstat2 vnstati2 luci-app-vnstat2 netdata"

    # Speedtest
    PACKAGES+=" librespeed-go python3-speedtest-cli iperf3 luci-app-netspeedtest"

    # Material Theme
    PACKAGES+=" luci-theme-material"

    # PHP8
    PACKAGES+=" libc php8 php8-fastcgi php8-fpm coreutils-stat zoneinfo-asia php8-cgi \
    php8-cli php8-mod-bcmath php8-mod-calendar php8-mod-ctype php8-mod-curl php8-mod-dom php8-mod-exif \
    php8-mod-fileinfo php8-mod-filter php8-mod-gd php8-mod-iconv php8-mod-intl php8-mod-mbstring php8-mod-mysqli \
    php8-mod-mysqlnd php8-mod-opcache php8-mod-pdo php8-mod-pdo-mysql php8-mod-phar php8-mod-session \
    php8-mod-xml php8-mod-xmlreader php8-mod-xmlwriter php8-mod-zip libopenssl-legacy"

    # Misc and some custom .ipk files
    misc=""
    if [ "$op_sourse" == "openwrt" ]; then
        misc+=" luci-app-temp-status luci-app-cpu-status-mini"
    elif [ "$op_sourse" == "immortalwrt" ]; then
        misc+=" "
    fi

    if [ "$op_target" == "rpi-4" ]; then
        misc+=" kmod-i2c-bcm2835 i2c-tools kmod-i2c-core kmod-i2c-gpio"
    elif [ "$ARCH_2" == "x86_64" ]; then
        misc+=" kmod-iwlwifi iw-full pciutils"
    fi

    if [ "$op_target" == "amlogic" ]; then
        PACKAGES+=" luci-app-amlogic ath9k-htc-firmware btrfs-progs hostapd hostapd-utils kmod-ath kmod-ath9k kmod-ath9k-common kmod-ath9k-htc kmod-cfg80211 kmod-crypto-acompress kmod-crypto-crc32c kmod-crypto-hash kmod-fs-btrfs kmod-mac80211 wireless-tools wpa-cli wpa-supplicant"
        EXCLUDED+=" -procd-ujail"
    fi

    PACKAGES+=" $misc zram-swap adb parted losetup resize2fs luci luci-ssl block-mount luci-app-poweroff luci-app-log-viewer luci-app-ramfree htop bash curl wget wget-ssl tar unzip unrar gzip jq luci-app-ttyd nano httping screen openssh-sftp-server"

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
        mkdir -p out_firmware out_rootfs
        if [ -f "bin/targets/*/*/*.img.gz" ]; then
            cp -f bin/targets/*/*/*.img.gz out_firmware
            echo -e "${SUCCESS} Coppy Image Successfully."
        fi
        if [ -f "bin/targets/*/*/*-rootfs.tar.gz" ]; then
            cp -f bin/targets/*/*/*-rootfs.tar.gz out_rootfs
            echo -e "${SUCCESS} Coppy Rootfs Successfully."
        fi
        sync && sleep 3
        echo -e "${INFO} [ ${openwrt_dir}/bin/targets/*/* ] directory status: $(ls bin/targets/*/* -al 2>/dev/null)"
        echo -e "${SUCCESS} The rebuild is successful, the current path: [ ${PWD} ]"
    fi
}

ulobuilder() {
    echo -e "${STEPS} Start Repacking firmware With UloBuilder..."
    cd ${imagebuilder_path}
    curl -fsSOL https://github.com/armarchindo/ULO-Builder/archive/refs/heads/main.zip
    unzip -q main.zip && rm -f main.zip
    mkdir -p ULO-Builder-main/rootfs
    if [ -f "out_rootfs/${op_sourse}-${op_branch}-armsr-armv8-generic-rootfs.tar.gz" ]; then
        cp -f out_rootfs/${op_sourse}-${op_branch}-armsr-armv8-generic-rootfs.tar.gz ULO-Builder-main/rootfs
        cd ULO-Builder-main
        sudo ./ulo -y -m ${op_devices} -r ${op_sourse}-${op_branch}-armsr-armv8-generic-rootfs.tar.gz -k ${KERNEL} -s 1024
        cp -rf ./out/${op_devices}/* ${imagebuilder_path}/out_firmware
    else
        error_msg "Rootfs file not found in ${openwrt_dir}/bin/targets/*/*/${op_sourse}-${op_branch}-armsr-armv8-generic-rootfs.tar.gz"
    fi
}

# Show welcome message
echo -e "${STEPS} Welcome to Rebuild OpenWrt Using the Image Builder."
[[ -x "${0}" ]] || error_msg "Please give the script permission to run: [ chmod +x ${0} ]"
[[ -z "${1}" ]] && error_msg "Please specify the OpenWrt Branch, such as [ ${0} openwrt:22.03.3 x86-64 ]"
[[ -z "${2}" ]] && error_msg "Please specify the OpenWrt Devices, such as [ ${0} openwrt:22.03.3 x86-64 ]"
[[ "${1}" =~ ^[a-z]{3,}:[0-9]+ ]] || echo "Incoming parameter format <source:branch> <target>: openwrt:22.03.3 x86-64 or openwrt:22.03.3 amlogic"
[[ "${2}" =~ ^[a-zA-Z0-9_-]+ ]] || echo "Incoming parameter format <source:branch> <target>: openwrt:22.03.3 x86-64 or openwrt:22.03.3 amlogic"
op_sourse="${1%:*}"
op_branch="${1#*:}"
op_devices="${2}"
echo -e "${INFO} Rebuild path: [ ${PWD} ]"
echo -e "${INFO} Rebuild Source: [ ${op_sourse} ], Branch: [ ${op_branch} ], Devives: ${op_devices}"
echo -e "${INFO} Server space usage before starting to compile: \n$(df -hT ${make_path}) \n"
#
# Perform related operations
download_imagebuilder
adjust_settings
custom_packages
custom_config
custom_files
rebuild_firmware
case "${op_devices}" in
    h5-*|h616-*|h618-*|h6-*|s905*|rk*)
        ulobuilder
        ;;
    *)
        ;;
esac
#
# Show server end information
echo -e "Server space usage after compilation: \n$(df -hT ${make_path}) \n"
# All process completed
wait
