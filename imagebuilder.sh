#!/bin/bash
#================================================================================================
# Description: Build OpenWrt with Image Builder
#================================================================================================
# Author: https://github.com/unifreq/openwrt_packit
#         https://github.com/ophub/amlogic-s9xxx-openwrt
#         https://downloads.openwrt.org/releases
#         https://downloads.immortalwrt.org/releases
#         https://github.com/rtaserver/RTA-WRT
#
# Command: ./config/imagebuilder/imagebuilder.sh <source:branch> <target>
# Example: ./config/imagebuilder/imagebuilder.sh openwrt:21.02.3 x86-64
# Available Devices
#- s905x | Amlogic S905X
#- s905x2 | Amlogic S905X2
#- s905x3 | Amlogic S905X3
#- s905x4 | Amlogic S905X4
#- h5-orangepi-zeroplus2 | Alwiner H5 Orange Pi Zero Plus 2
#- h5-orangepi-zeroplus | Alwiner H5 Orange Pi Zero Plus
#- h5-orangepi-prime | Alwiner H5 Orange Pi Prime
#- h5-orangepi-pc2 | Alwiner H5 Orange Pi PC 2
#- h6-orangepi-lite2 | Alwiner H6 Orange Pi Lite 2
#- h6-orangepi-1plus | Alwiner H6 Orange Pi 1 Plus
#- h6-orangepi-3 | Alwiner H6 Orange Pi 3
#- h6-orangepi-3lts | Alwiner H6 Orange Pi 3 LTS
#- h616-orangepi-zero2 | Alwiner H616 Orange Pi Zero 2
#- h618-orangepi-zero2w | Alwiner H618 Orange Pi Zero 2W
#- h618-orangepi-zero3 | Alwiner H618 Orange Pi Zero 3
#- rk3566-orangepi-3b | Rockchip RK3566 Orange Pi 3B
#- rk3588-orangepi-5plus | Rockchip RK3588 Orange Pi 5 Plus
#- rk3588s-orangepi-5 | Rockchip RK3588S Orange Pi 5
#- bcm2710 | Raspberry Pi 3A+/3B/3B+/CM3/Zero2/Zero2W (64bit)
#- x86-64 | x86 64bit
#================================================================================================

# Default parameters
make_path="${PWD}"
openwrt_dir="imagebuilder"
imagebuilder_path="${make_path}/${openwrt_dir}"
custom_files_path="${make_path}/files"
custom_packages_path="${make_path}/packages"
custom_scripts_file="${make_path}/scripts"

# Output log prefixes
STEPS="[\033[95m STEPS \033[0m]"
INFO="[\033[94m INFO \033[0m]"
SUCCESS="[\033[92m SUCCESS \033[0m]"
WARNING="[\033[93m WARNING \033[0m]"
ERROR="[\033[91m ERROR \033[0m]"

#================================================================================================

# Handle errors and exit
error_msg() {
    echo -e "${ERROR} $1"
    exit 1
}

# Download external packages
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

# Downloading OpenWrt ImageBuilder
download_imagebuilder() {
    cd "${make_path}" || { error_msg "Failed to change directory to ${make_path}"; }
    echo -e "${STEPS} Start downloading OpenWrt files..."

    # Determine target and architecture based on device
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
        bcm2710*) # Raspberry Pi 3A+/3B/3B+/CM3/Zero2/Zero2W (64bit)
            op_target="bcm2710"
            target_profile="rpi-3"
            target_system="bcm27xx/bcm2710"
            target_name="bcm27xx-bcm2710"
            ARCH_1="arm64"
            ARCH_2="aarch64"
            ARCH_3="aarch64_cortex-a53"
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

    # Determine file extension and download URL
    CURVER=$(echo "${op_branch}" | awk -F. '{print $1"."$2}')
    archive_ext="tar.$([[ "${CURVER}" == "23.05" ]] && echo "xz" || echo "zst")"
    download_file="https://downloads.${op_sourse}.org/releases/${op_branch}/targets/${target_system}/${op_sourse}-imagebuilder-${op_branch}-${target_name}.Linux-x86_64.${archive_ext}"

    echo -e "${INFO} Downloading ImageBuilder from: ${download_file}"
    curl -fsSOL "${download_file}" || error_msg "Failed to download ${download_file}"

    # Extract downloaded archive
    echo -e "${INFO} Extracting archive..."
    case "${archive_ext}" in
        tar.xz)
            tar -xJf *-imagebuilder-* > /dev/null 2>&1 || error_msg "Failed to extract tar.xz archive."
            ;;
        tar.zst)
            tar -xvf *-imagebuilder-* > /dev/null 2>&1 || error_msg "Failed to extract tar.zst archive."
            ;;
        *)
            error_msg "Unknown archive extension: ${archive_ext}"
            ;;
    esac

    # Move extracted files to the appropriate directory
    rm -f *-imagebuilder-*.${archive_ext}
    mv -f *-imagebuilder-* "${openwrt_dir}" || error_msg "Failed to move extracted files to ${openwrt_dir}."

    # Finalize and verify
    sync && sleep 3
    echo -e "${SUCCESS} OpenWrt ImageBuilder downloaded and extracted successfully."
}


# Adjust related files in the ImageBuilder directory
adjust_settings() {
    cd "${imagebuilder_path}" || { error_msg "Failed to change directory to ${imagebuilder_path}"; }
    echo -e "${STEPS} Start adjusting .config file and related settings..."

    # Variables
    DTM=$(date '+%d-%m-%Y')
    CURVER=$(echo "$op_branch" | awk -F. '{print $1"."$2}')

    # Update 99-first-setup
    FIRST_SETUP_FILE="${custom_files_path}/etc/uci-defaults/99-first-setup"
    if [[ -s "${FIRST_SETUP_FILE}" ]]; then
        sed -i "s|Ouc3kNF6|$DTM|g" "${FIRST_SETUP_FILE}"
        echo -e "${INFO} Updated 99-first-setup with date: $DTM"
    else
        echo -e "${WARN} File 99-first-setup not found or is empty at: ${FIRST_SETUP_FILE}"
    fi

    # Update repositories.conf
    REPO_CONF="repositories.conf"
    if [[ -s "${REPO_CONF}" ]]; then
        sed -i '\|option check_signature| s|^|#|' "${REPO_CONF}"
        echo -e "${INFO} Updated repositories.conf to disable signature checks."
    else
        echo -e "${WARN} File repositories.conf not found or is empty."
    fi

    # Update Makefile
    MAKEFILE="Makefile"
    if [[ -s "${MAKEFILE}" ]]; then
        sed -i "s/install \$(BUILD_PACKAGES)/install \$(BUILD_PACKAGES) --force-overwrite --force-downgrade/" "${MAKEFILE}"
        echo -e "${INFO} Updated Makefile to include force-overwrite and force-downgrade."
    else
        echo -e "${WARN} File Makefile not found or is empty."
    fi

    # Update .config
    CONFIG_FILE=".config"
    if [[ -s "${CONFIG_FILE}" ]]; then
        echo -e "${INFO} Updating .config file settings..."

        # Resize Boot and Rootfs partition sizes
        sed -i "s/CONFIG_TARGET_KERNEL_PARTSIZE=.*/CONFIG_TARGET_KERNEL_PARTSIZE=128/" "${CONFIG_FILE}"
        sed -i "s/CONFIG_TARGET_ROOTFS_PARTSIZE=.*/CONFIG_TARGET_ROOTFS_PARTSIZE=1024/" "${CONFIG_FILE}"

        # Amlogic-specific settings
        case "${op_target}" in
            amlogic|allwinner|rockchip)
                sed -i "s/CONFIG_TARGET_ROOTFS_CPIOGZ=.*/# CONFIG_TARGET_ROOTFS_CPIOGZ is not set/" "${CONFIG_FILE}"
                sed -i "s/CONFIG_TARGET_ROOTFS_EXT4FS=.*/# CONFIG_TARGET_ROOTFS_EXT4FS is not set/" "${CONFIG_FILE}"
                sed -i "s/CONFIG_TARGET_ROOTFS_SQUASHFS=.*/# CONFIG_TARGET_ROOTFS_SQUASHFS is not set/" "${CONFIG_FILE}"
                sed -i "s/CONFIG_TARGET_IMAGES_GZIP=.*/# CONFIG_TARGET_IMAGES_GZIP is not set/" "${CONFIG_FILE}"
                echo -e "${INFO} Updated Amlogic-specific .config settings."
                ;;
            x86-64)
                sed -i "s/CONFIG_ISO_IMAGES=y/# CONFIG_ISO_IMAGES is not set/" "${CONFIG_FILE}"
                sed -i "s/CONFIG_VHDX_IMAGES=y/# CONFIG_VHDX_IMAGES is not set/" "${CONFIG_FILE}"
                echo -e "${INFO} Updated x86_64-specific .config settings."
                ;;
        esac
    else
        error_msg "No .config file found in ${imagebuilder_path}. Ensure the correct file is available."
    fi

    # Final synchronization and directory status check
    sync && sleep 3
    echo -e "${SUCCESS} Adjusted .config file and related settings successfully."
}


# Add custom packages
# If there is a custom package or ipk you would prefer to use create a [ packages ] directory,
# If one does not exist and place your custom ipk within this directory.
custom_packages() {
    cd "${imagebuilder_path}" || { error_msg "Failed to change directory to ${imagebuilder_path}"; return 1; }
    echo -e "${STEPS} Start adding custom packages..."

    # Create the [packages] directory if not exists
    [[ -d "packages" ]] || mkdir -p "packages"
    if [[ -d "${custom_packages_path}" ]]; then
        # Copy custom packages
        cp -rf "${custom_packages_path}/"* "packages/" > /dev/null 2>&1
        if [[ $? -eq 0 ]]; then
            echo -e "${SUCCESS} Custom packages successfully copied to the [ packages ] directory."
        else
            echo -e "${WARN} Failed to copy packages from ${custom_packages_path} to the [ packages ] directory."
        fi
    else
        echo -e "${WARN} No customized packages found in ${custom_packages_path}."
    fi

    cd "packages" || { error_msg "Failed to access [packages] directory."; return 1; }

    # Handle GitHub-based IPK downloads
    declare -a github_packages
    if [[ "$op_target" == "amlogic" ]]; then
        echo -e "${INFO} Adding luci-app-amlogic for target Amlogic."
        github_packages+=("luci-app-amlogic|https://api.github.com/repos/ophub/luci-app-amlogic/releases/latest")
    fi

    download_packages "github" github_packages[@]

    # Handle other custom package downloads
    CURVER=$(echo "$op_branch" | awk -F. '{print $1"."$2}')
    declare -a other_packages=(
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
    openclash_file_ipk_down=$(curl -s "${openclash_api}" | grep "browser_download_url" | grep -oE "https.*${openclash_file_ipk}.*.ipk" | head -n 1)

    echo -e "${STEPS} Start Clash Core Download !"
    core_dir="${custom_files_path}/etc/openclash/core"
    mkdir -p "$core_dir"
    if [[ "$ARCH_3" == "x86_64" ]]; then
        clash_meta=$(meta_api="https://api.github.com/repos/MetaCubeX/mihomo/releases/latest" && meta_file="mihomo-linux-$ARCH_1-compatible" && curl -s "${meta_api}" | grep "browser_download_url" | grep -oE "https.*${meta_file}-v[0-9]+\.[0-9]+\.[0-9]+\.gz" | head -n 1)
    else
        clash_meta=$(meta_api="https://api.github.com/repos/MetaCubeX/mihomo/releases/latest" && meta_file="mihomo-linux-$ARCH_1" && curl -s "${meta_api}" | grep "browser_download_url" | grep -oE "https.*${meta_file}-v[0-9]+\.[0-9]+\.[0-9]+\.gz" | head -n 1)
    fi

    # Mihomo
    mihomo_api="https://api.github.com/repos/rizkikotet-dev/OpenWrt-mihomo-Mod/releases"
    mihomo_file_ipk="mihomo_${ARCH_3}-openwrt-${CURVER}" #$op_branch | cut -d '.' -f 1-2
    mihomo_file_ipk_down=$(curl -s "${mihomo_api}" | grep "browser_download_url" | grep -oE "https.*${mihomo_file_ipk}.*.tar.gz" | head -n 1)

    #passwall
    passwall_api="https://api.github.com/repos/xiaorouji/openwrt-passwall/releases"
    passwall_file_ipk="luci-23.05_luci-app-passwall"
    passwall_file_zip="passwall_packages_ipk_${ARCH_3}"
    passwall_file_ipk_down=$(curl -s "${passwall_api}" | grep "browser_download_url" | grep -oE "https.*${passwall_file_ipk}.*.ipk" | head -n 1)
    passwall_file_zip_down=$(curl -s "${passwall_api}" | grep "browser_download_url" | grep -oE "https.*${passwall_file_zip}.*.zip" | head -n 1)


    # Output download information
    echo -e "${STEPS} Installing OpenClash, Mihomo And Passwall"

    echo -e "${INFO} Downloading OpenClash package"
    curl -fsSOL "${openclash_file_ipk_down}" || error_msg "Error: Failed to download OpenClash package."
    curl -fsSL -o "${core_dir}/clash_meta.gz" "${clash_meta}" || error_msg "Error: Failed to download Clash Meta package."
    gzip -d "$core_dir/clash_meta.gz" || error_msg "Error: Failed to extract OpenClash package."
    echo -e "${SUCCESS} OpenClash Packages downloaded successfully."

    echo -e "${INFO} Downloading Mihomo package"
    curl -fsSOL "${mihomo_file_ipk_down}" || error_msg "Error: Failed to download Mihomo package."
    tar -xzvf "mihomo_${ARCH_3}-openwrt-${CURVER}.tar.gz" > /dev/null 2>&1 && rm "mihomo_${ARCH_3}-openwrt-${CURVER}.tar.gz" || error_msg "Error: Failed to extract Mihomo package."
    echo -e "${SUCCESS} Mihomo Packages downloaded successfully."

    echo -e "${INFO} Downloading Passwall package"
    curl -fsSOL "${passwall_file_ipk_down}" || error_msg "Error: Failed to download Passwall package."
    curl -fsSOL "${passwall_file_zip_down}" || error_msg "Error: Failed to download Passwall Zip package."
    unzip -q "passwall_packages_ipk_${ARCH_3}.zip" && rm "passwall_packages_ipk_${ARCH_3}.zip" || error_msg "Error: Failed to extract Passwall package."
    echo -e "${SUCCESS} Passwall Packages downloaded successfully."

    # Sync and provide directory status
    sync && sleep 3
    echo -e "${SUCCESS} All custom packages successfully downloaded and extracted."
}

# Add custom packages, lib, theme, app and i18n, etc.
custom_config() {
    cd "${imagebuilder_path}" || { error_msg "Failed to change directory to ${imagebuilder_path}"; return 1; }
    echo -e "${STEPS} Start adding custom config..."

    # Define URLs for custom scripts
    declare -A custom_scripts=(
        ["${custom_files_path}/sbin/sync_time.sh"]="https://raw.githubusercontent.com/frizkyiman/auto-sync-time/main/sbin/sync_time.sh"
        ["${custom_files_path}/usr/bin/clock"]="https://raw.githubusercontent.com/frizkyiman/auto-sync-time/main/usr/bin/clock"
        ["${custom_files_path}/root/install2.sh"]="https://raw.githubusercontent.com/frizkyiman/fix-read-only/main/install2.sh"
        ["${custom_files_path}/usr/bin/mount_hdd"]="https://raw.githubusercontent.com/frizkyiman/auto-mount-hdd/main/mount_hdd"
    )

    echo -e "${INFO} Downloading custom scripts..."

    for file_path in "${!custom_scripts[@]}"; do
        file_url="${custom_scripts[$file_path]}"
        target_dir=$(dirname "$file_path")
        
        # Ensure target directory exists
        mkdir -p "$target_dir" || { echo -e "${ERROR} Failed to create directory $target_dir"; continue; }
        
        # Download the script
        curl -fsSL -o "$file_path" "$file_url"
        if [ "$?" -ne 0 ]; then
            echo -e "${WARN} Failed to download $file_url to $file_path."
        else
            echo -e "${SUCCESS} Successfully downloaded $file_url to $file_path."
            chmod +x "$file_path" # Make the script executable
        fi
    done

    # Sync and provide directory status
    sync && sleep 3
    echo -e "${SUCCESS} All custom configuration setup completed!"
}

# Add custom files
# The FILES variable allows custom configuration files to be included in images built with Image Builder.
# The [ files ] directory should be placed in the Image Builder root directory where you issue the make command.
custom_files() {
    cd "${imagebuilder_path}" || { error_msg "Failed to change directory to ${imagebuilder_path}"; return 1; }
    echo -e "${STEPS} Start adding custom files..."

    if [[ -d "${custom_files_path}" ]]; then
        # Ensure the [ files ] directory exists
        [[ -d "files" ]] || mkdir -p "files"

        # Copy custom files
        cp -rf "${custom_files_path}/"* "files"
        if [[ $? -eq 0 ]]; then
            echo -e "${SUCCESS} Custom files successfully copied to the [ files ] directory."
        else
            echo -e "${ERROR} Failed to copy files from ${custom_files_path} to the [ files ] directory."
            return 1
        fi
    else
        echo -e "${WARNING} No customized files were found in ${custom_files_path}."
    fi

    # Sync and provide directory status
    sync && sleep 3
    echo -e "${SUCCESS} All custom files successfully added."
}

# Rebuild OpenWrt firmware
rebuild_firmware() {
    set -e  # Hentikan eksekusi jika terjadi kesalahan
    echo -e "${STEPS} Start building OpenWrt with Image Builder..."

    # Validasi variabel penting
    if [[ -z ${imagebuilder_path} || -z ${op_sourse} || -z ${op_target} || -z ${target_profile} ]]; then
        error_msg "Error: Required variables are not set. Exiting..."
    fi

    # Masuk ke direktori Image Builder
    cd "${imagebuilder_path}" || { error_msg "Error: Unable to access ${imagebuilder_path}"; }

    # Membersihkan build lama
    make clean > /dev/null 2>&1 || { error_msg "Error: Failed to clean previous build"; }
    mkdir -p ${imagebuilder_path}/out_firmware ${imagebuilder_path}/out_rootfs

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
    # Exclude package (must use - before packages name)
    EXCLUDED+=" -libgd"
    MISC=""
    case "${op_sourse}" in
    openwrt)
        MISC+=" luci-app-temp-status luci-app-cpu-status-mini"
        EXCLUDED+=" -dnsmasq"
        ;;
    immortalwrt)
        MISC+=" "
        EXCLUDED+=" -dnsmasq -automount -libustream-openssl -default-settings-chn -luci-i18n-base-zh-cn"
        if [ "$ARCH_2" == "x86_64" ]; then
            EXCLUDED+=" -kmod-usb-net-rtl8152-vendor"
        fi
        ;;
    esac

    case "${op_target}" in
    amlogic)
        MISC+=" luci-app-amlogic ath9k-htc-firmware btrfs-progs hostapd hostapd-utils kmod-ath kmod-ath9k kmod-ath9k-common kmod-ath9k-htc kmod-cfg80211 kmod-crypto-acompress kmod-crypto-crc32c kmod-crypto-hash kmod-fs-btrfs kmod-mac80211 wireless-tools wpa-cli wpa-supplicant"
        EXCLUDED+=" -procd-ujail"
        ;;
    allwinner|rockchip)
        #MISC+=" kmod-i2c-bcm2835 i2c-tools kmod-i2c-core kmod-i2c-gpio"
        ;;
    x86_64)
        MISC+=" kmod-iwlwifi iw-full pciutils"
        ;;
    esac

    PACKAGES+=" $MISC zram-swap adb parted losetup resize2fs luci luci-ssl block-mount luci-app-poweroff luci-app-log-viewer luci-app-ramfree htop bash curl wget wget-ssl tar unzip unrar gzip jq luci-app-ttyd nano httping screen openssh-sftp-server"

    # Membuat image firmware
    make image PROFILE="${target_profile}" PACKAGES="${PACKAGES} ${EXCLUDED}" FILES="files" >/dev/null 2>&1
    if [[ $? -ne 0 ]]; then
        error_msg "Error: OpenWrt build failed. Check logs for details."
    else
        for file in ${imagebuilder_path}/bin/targets/*/*/*.img.gz; do
            [[ -e "$file" ]] || continue
            mv -f "$file" "${imagebuilder_path}/out_firmware"
            echo -e "${SUCCESS} Firmware successfully created: $file"
        done
        for file in ${imagebuilder_path}/bin/targets/*/*/*rootfs.tar.gz; do
            [[ -e "$file" ]] || continue
            mv -f "$file" "${imagebuilder_path}/out_rootfs"
            echo -e "${SUCCESS} Rootfs successfully created: $file"
        done

        sync && sleep 3
        echo -e "${SUCCESS} Build completed successfully."
    fi
}

ulobuilder() {
    local readonly ULO_REPO="https://github.com/armarchindo/ULO-Builder/archive/refs/heads/main.zip"
    local readonly REQUIRED_SPACE_MB=2048  # 2GB minimum required space

    echo -e "${STEPS} Starting firmware repackaging with UloBuilder..."

    # Validate required variables
    local readonly REQUIRED_VARS=("imagebuilder_path" "op_sourse" "op_branch" "op_devices" "KERNEL")
    for var in "${REQUIRED_VARS[@]}"; do
        if [[ -z "${!var}" ]]; then
            error_msg "Required variable '${var}' is not set"
        fi
    done

    # Check available disk space
    local available_space
    available_space=$(df -m "${imagebuilder_path}" | awk 'NR==2 {print $4}')
    if [[ ${available_space} -lt ${REQUIRED_SPACE_MB} ]]; then
        error_msg "Insufficient disk space. Required: ${REQUIRED_SPACE_MB}MB, Available: ${available_space}MB"
    fi

    # Create working directory structure
    local readonly work_dir="${imagebuilder_path}"
    local readonly ulo_dir="${work_dir}/ULO-Builder-main"
    local readonly output_dir="${work_dir}/out_firmware"

    # Navigate to working directory
    if ! cd "${work_dir}"; then
        error_msg "Failed to access working directory: ${work_dir}"
    fi

    # Download and extract UloBuilder
    echo -e "${INFO} Downloading UloBuilder..."
    if ! curl -fsSL "${ULO_REPO}" -o main.zip; then
        error_msg "Failed to download UloBuilder from ${ULO_REPO}"
    fi

    if ! unzip -q main.zip; then
        error_msg "Failed to extract UloBuilder archive"
        rm -f main.zip
    fi
    rm -f main.zip

    # Prepare UloBuilder directory
    mkdir -p "${ulo_dir}/rootfs"

    # Validate and copy rootfs
    local readonly rootfs_file="${work_dir}/out_rootfs/${op_sourse}-${op_branch}-armsr-armv8-generic-rootfs.tar.gz"
    if [[ ! -f "${rootfs_file}" ]]; then
        error_msg "Rootfs file not found: ${rootfs_file}"
    fi

    echo -e "${INFO} Copying rootfs file..."
    if ! cp -f "${rootfs_file}" "${ulo_dir}/rootfs/"; then
        error_msg "Failed to copy rootfs file"
    fi

    # Change to UloBuilder directory
    if ! cd "${ulo_dir}"; then
        error_msg "Failed to access UloBuilder directory: ${ulo_dir}"
    fi

    # Apply patches
    echo -e "${INFO} Applying UloBuilder patches..."
    if [[ -f "./.github/workflows/ULO_Workflow.patch" ]]; then
        mv ./.github/workflows/ULO_Workflow.patch ./ULO_Workflow.patch
        if ! patch -p1 < ./ULO_Workflow.patch; then
            error_msg "Failed to apply UloBuilder patch"
        fi
    else
        error_msg "UloBuilder patch file not found"
    fi

    # Run UloBuilder
    echo -e "${INFO} Running UloBuilder..."
    local readonly rootfs_basename=$(basename "${rootfs_file}")
    if ! sudo ./ulo -y -m "${op_devices}" -r "${rootfs_basename}" -k "${KERNEL}" -s 1024 >/dev/null 2>&1; then
        error_msg "UloBuilder execution failed"
    fi

    # Verify and copy output files
    local readonly device_output_dir="./out/${op_devices}"
    if [[ ! -d "${device_output_dir}" ]]; then
        error_msg "UloBuilder output directory not found: ${device_output_dir}"
    fi

    echo -e "${INFO} Copying firmware files to output directory..."
    if ! cp -rf "${device_output_dir}"/* "${output_dir}/"; then
        error_msg "Failed to copy firmware files to output directory"
    fi

    # Verify output files exist
    if ! ls "${output_dir}"/* >/dev/null 2>&1; then
        error_msg "No firmware files found in output directory"
    fi

    sync && sleep 3
    echo -e "${SUCCESS} Firmware repacking completed successfully!"
}

rename_firmware() {
    echo -e "${STEPS} Renaming firmware files..."

    # Validasi direktori firmware
    local firmware_dir="${imagebuilder_path}/out_firmware"
    if [[ -z "$imagebuilder_path" ]] || [[ ! -d "$firmware_dir" ]]; then
        error_msg "Invalid firmware directory: ${firmware_dir}"
    fi

    # Pindah ke direktori firmware
    cd "${firmware_dir}" || {
       error_msg "Failed to change directory to ${firmware_dir}"
    }

    # Pola pencarian dan penggantian
    local search_replace_patterns=(
        # Format: "search|replace"

        # bcm27xx
        "-bcm27xx-bcm2710-rpi-3|Broadcom_RaspberryPi_3"
        
        # Allwinner
        "-h5-orangepi-pc2-|Allwinner_OrangePi_PC2"
        "-h5-orangepi-prime-|Allwinner_OrangePi_Prime"
        "-h5-orangepi-zeroplus-|Allwinner_OrangePi_ZeroPlus"
        "-h5-orangepi-zeroplus2-|Allwinner_OrangePi_ZeroPlus2"
        "-h6-orangepi-1plus-|Allwinner_OrangePi_1Plus"
        "-h6-orangepi-3-|Allwinner_OrangePi_3"
        "-h6-orangepi-3lts-|Allwinner_OrangePi_3LTS"
        "-h6-orangepi-lite2-|Allwinner_OrangePi_Lite2"
        "-h616-orangepi-zero2-|Allwinner_OrangePi_Zero2"
        "-h618-orangepi-zero2w-|Allwinner_OrangePi_Zero2W"
        "-h618-orangepi-zero3-|Allwinner_OrangePi_Zero3"
        
        # Rockchip
        "-rk3566-orangepi-3b-|Rockchip_OrangePi_3B"
        "-rk3588s-orangepi-5-|Rockchip_OrangePi_5"
        
        # Amlogic
        "-s905x-|Amlogic_s905x"
        "-s905x2-|Amlogic_s905x2"
        "-s905x3-|Amlogic_s905x3"
        "-s905x4-|Amlogic_s905x4"

        # x86_64
        "x86-64-generic-ext4-combined-efi|X86_64_Generic_Ext4_Combined_EFI"
        "x86-64-generic-ext4-combined|X86_64_Generic_Ext4_Combined"
        "x86-64-generic-ext4-rootfs|X86_64_Generic_Ext4_Rootfs"
        "x86-64-generic-squashfs-combined-efi|X86_64_Generic_Squashfs_Combined_EFI"
        "x86-64-generic-squashfs-combined|X86_64_Generic_Squashfs_Combined"
        "x86-64-generic-squashfs-rootfs|X86_64_Generic_Squashfs_Rootfs"
    )

   for pattern in "${search_replace_patterns[@]}"; do
        local search="${pattern%%|*}"
        local replace="${pattern##*|}"

        for file in *"${search}"*.img.gz; do
            if [[ -f "$file" ]]; then
                local kernel=""
                if [[ "$file" =~ k[0-9]+\.[0-9]+\.[0-9]+(-[A-Za-z0-9-]+)? ]]; then
                    kernel="${BASH_REMATCH[0]}"
                fi
                local new_name
                if [[ -n "$kernel" ]]; then
                    new_name="RTA-WRT${op_source}-${op_branch}-${replace}-${kernel}.img.gz"
                else
                    new_name="RTA-WRT${op_source}-${op_branch}-${replace}.img.gz"
                fi
                echo -e "${INFO} Renaming: $file → $new_name"
                mv "$file" "$new_name" || {
                    echo -e "${ERROR} Failed to rename $file"
                    return 1
                }
            fi
        done
    done

    sync && sleep 3
    echo -e "${INFO} Rename operation completed."
}

# Show welcome message
echo -e "${STEPS} Welcome to Rebuild OpenWrt Using the Image Builder."
[[ -x "${0}" ]] || error_msg "Please give the script permission to run: [ chmod +x ${0} ]"
[[ -z "${1}" ]] && error_msg "Please specify the OpenWrt Branch, such as [ ${0} openwrt:22.03.3 x86-64 or openwrt:22.03.3 s905x ]"
[[ -z "${2}" ]] && error_msg "Please specify the OpenWrt Devices, such as [ ${0} openwrt:22.03.3 x86-64 or openwrt:22.03.3 s905x ]"
[[ "${1}" =~ ^[a-z]{3,}:[0-9]+ ]] || echo "Incoming parameter format <source:branch> <target>: openwrt:22.03.3 x86-64 or openwrt:22.03.3 s905x"
[[ "${2}" =~ ^[a-zA-Z0-9_-]+ ]] || echo "Incoming parameter format <source:branch> <target>: openwrt:22.03.3 x86-64 or openwrt:22.03.3 s905x"
op_sourse="${1%:*}"
op_branch="${1#*:}"
op_devices="${2}"
echo -e "${INFO} Rebuild path: [ ${PWD} ]"
echo -e "${INFO} Rebuild Source: [ ${op_sourse} ], Branch: [ ${op_branch} ], Devices: ${op_devices}"
echo -e "${INFO} Server space usage before starting to compile: \n$(df -hT ${make_path}) \n"

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
rename_firmware

# Show server end information
echo -e "Server space usage after compilation: \n$(df -hT ${make_path}) \n"
# All process completed
wait
