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
# Example: ./config/imagebuilder/imagebuilder.sh openwrt:24.10.0 x86-64
# Available Devices
#- s905x | HG680P, B860Hv1/v2
#- s905x2 | HG680FJ, B860Hv5, MNC CYBORG001
#- s905x3 | 
#- s905x4 | AKARI AX810, dll
#- s912
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
#- bcm2711 | Raspberry Pi 4B/400 (64bit)
#- x86-64 | x86 64bit
#================================================================================================

# Default parameters
make_path="${PWD}/scripts"
openwrt_dir="imagebuilder"
imagebuilder_path="${make_path}/${openwrt_dir}"
custom_files_path="${make_path}/files"
custom_packages_path="${make_path}/packages"

# Output log prefixes with better color handling and backup if tput fails
setup_colors() {
    PURPLE="\033[95m"
    BLUE="\033[94m"
    GREEN="\033[92m"
    YELLOW="\033[93m"
    RED="\033[91m"
    MAGENTA='\033[0;35m'
    CYAN='\033[0;36m'
    RESET="\033[0m"

    STEPS="[${PURPLE} STEPS ${RESET}]"
    INFO="[${BLUE} INFO ${RESET}]"
    SUCCESS="[${GREEN} SUCCESS ${RESET}]"
    WARNING="[${YELLOW} WARNING ${RESET}]"
    ERROR="[${RED} ERROR ${RESET}]"

    # Formatting
    CL=$(echo "\033[m")
    UL=$(echo "\033[4m")
    BOLD=$(echo "\033[1m")
    BFR="\\r\\033[K"
    HOLD=" "
    TAB="  "
}

spinner() {
  local frames=('⠋' '⠙' '⠹' '⠸' '⠼' '⠴' '⠦' '⠧' '⠇' '⠏')
  local colors=("\033[31m" "\033[33m" "\033[32m" "\033[36m" "\033[34m" "\033[35m" "\033[91m" "\033[92m" "\033[93m" "\033[94m")
  local spin_i=0
  local color_i=0
  local interval=0.1

  printf "\e[?25l"

  while true; do
    local color="${colors[color_i]}"
    printf "\r ${color}%s${CL}" "${frames[spin_i]}"

    spin_i=$(( (spin_i + 1) % ${#frames[@]} ))
    color_i=$(( (color_i + 1) % ${#colors[@]} ))

    sleep "$interval"
  done
}

setup_colors

format_time() {
  local total_seconds=$1
  local hours=$((total_seconds / 3600))
  local minutes=$(( (total_seconds % 3600) / 60 ))
  local seconds=$((total_seconds % 60))
  printf "%02d:%02d:%02d" $hours $minutes $seconds
}

cmdinstall() {
    local cmd="$1"
    local desc="${2:-$cmd}"

    echo -ne "${TAB}${HOLD}${INFO} ${desc}${HOLD}"
    spinner &
    SPINNER_PID=$!
    local start_time=$(date +%s)
    local output=$($cmd 2>&1)
    local exit_code=$?
    local end_time=$(date +%s)
    local elapsed_time=$((end_time - start_time))
    local formatted_time=$(format_time $elapsed_time)

    if [ $exit_code -eq 0 ]; then
        if [ -n "$SPINNER_PID" ] && ps | grep $SPINNER_PID > /dev/null; then kill $SPINNER_PID > /dev/null; fi
        printf "\e[?25h"
        echo -e "${BFR}${SUCCESS} ${desc} ${BLUE}[$formatted_time]${RESET}"
    else
        if [ -n "$SPINNER_PID" ] && ps | grep $SPINNER_PID > /dev/null; then kill $SPINNER_PID > /dev/null; fi
        printf "\e[?25h"
        echo -e "${BFR}${ERROR} ${desc} ${BLUE}[$formatted_time]${RESET}"
        echo "$output"
        exit 1
    fi
}

#================================================================================================

# Handle errors and exit
error_msg() {
    local line_number=${2:-${BASH_LINENO[0]}}
    echo -e "${ERROR} ${1} (Line: ${line_number})" >&2
    echo "Call stack:" >&2
    local frame=0
    while caller $frame; do
        ((frame++))
    done >&2
    exit 1
}
# Check And Install Required Dependencies
check_dependencies() {
    local dependencies=("aria2" "curl" "tar" "gzip" "unzip" "git" "wget" "sed" "grep")

    echo -e "${STEPS} Checking and installing required dependencies..."
    
    echo -e "${INFO} Updating package lists..."
    sudo apt update -qq &> /dev/null 2>&1

    for pkg in "${dependencies[@]}"; do
        if sudo dpkg -s "$pkg" &> /dev/null 2>&1; then
            echo -e "${SUCCESS} ✓ $pkg is already installed"
        else
            echo -e "${INFO} Installing $pkg..."
            
            if sudo apt-get install -y "$pkg" &> /dev/null 2>&1; then
                echo -e "${SUCCESS} ✓ $pkg installed successfully"
            else
                echo -e "${ERROR} ✗ Failed to install $pkg"
                exit 1
            fi
        fi
    done

    echo -e "${SUCCESS} Dependencies installation complete!"
}

# Aria2 Download Function
ariadl() {
    if [ "$#" -lt 1 ]; then
        echo -e "${ERROR} Usage: ariadl <URL> [OUTPUT_FILE]"
        return 1
    fi

    echo -e "${STEPS} Aria2 Downloader"

    local URL OUTPUT_FILE OUTPUT_DIR OUTPUT
    URL=$1
    local RETRY_COUNT=0
    local MAX_RETRIES=3

    if [ "$#" -eq 1 ]; then
        OUTPUT_FILE=$(basename "$URL")
        OUTPUT_DIR="."
    else
        OUTPUT=$2
        OUTPUT_DIR=$(dirname "$OUTPUT")
        OUTPUT_FILE=$(basename "$OUTPUT")
    fi

    if [ ! -d "$OUTPUT_DIR" ]; then
        mkdir -p "$OUTPUT_DIR"
    fi

    while [ $RETRY_COUNT -lt $MAX_RETRIES ]; do
        echo -e "${INFO} Downloading: $URL (Attempt $((RETRY_COUNT + 1))/$MAX_RETRIES)"
        
        if [ -f "$OUTPUT_DIR/$OUTPUT_FILE" ]; then
            rm "$OUTPUT_DIR/$OUTPUT_FILE"
        fi
        
        aria2c -q -d "$OUTPUT_DIR" -o "$OUTPUT_FILE" "$URL"
        
        if [ $? -eq 0 ]; then
            echo -e "${SUCCESS} Downloaded: $OUTPUT_FILE"
            return 0
        else
            RETRY_COUNT=$((RETRY_COUNT + 1))
            if [ $RETRY_COUNT -lt $MAX_RETRIES ]; then
                echo -e "${ERROR} Download failed. Retrying..."
                sleep 2
            fi
        fi
    done

    echo -e "${ERROR} Failed to download: $OUTPUT_FILE after $MAX_RETRIES attempts"
    return 1
}

# Download external packages
download_packages() {
    local list=("${!2}") # Capture array argument
    
    if [[ $1 == "github" ]]; then
        for entry in "${list[@]}"; do
            IFS="|" read -r filename base_url <<< "$entry"
            local file_urls=$(curl -s "$base_url" | grep "browser_download_url" | grep -oE "https.*/${filename}_[_0-9a-zA-Z\._~-]*\.ipk" | sort -V | tail -n 1)
            
            if [ -z "$file_urls" ]; then
                error_msg "Failed to retrieve package info for [$filename] from $base_url"
                continue
            fi

            for file_url in $file_urls; do
                if [ -n "$file_url" ]; then
                    ariadl "$file_url" "$(basename "$file_url")"
                fi
            done
        done
    elif [[ $1 == "custom" ]]; then
        for entry in "${list[@]}"; do
            IFS="|" read -r filename base_url <<< "$entry"
            
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
            
            if [ -n "$full_url" ]; then
                ariadl "$full_url" "${filename}.ipk"
            else
                error_msg "No matching file found for [$filename] at $base_url"
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
        h5-*|h616-*|h618-*|h6-*) # Allwinner (H5/H616/H618/H6)
            op_target="allwinner"
            target_profile="generic"
            target_system="armsr/armv8"
            target_name="armsr-armv8"
            ARCH_1="arm64"
            ARCH_2="aarch64"
            ARCH_3="aarch64_generic"
            KERNEL="6.1.104-AW64-DBAI"
            KERNEL2="6.1.31-AW64-DBAI"
            KERNEL3="6.6.6-AW64-DBAI"
            ;;
        s905*) # Amlogic (S905*)
            op_target="amlogic"
            target_profile="generic"
            target_system="armsr/armv8"
            target_name="armsr-armv8"
            ARCH_1="arm64"
            ARCH_2="aarch64"
            ARCH_3="aarch64_generic"
            KERNEL="6.1.66-DBAI"
            KERNEL2="5.15.y_6.6.y"
            ;;
        s912) # Amlogic (S912)
            op_target="amlogic"
            target_profile="generic"
            target_system="armsr/armv8"
            target_name="armsr-armv8"
            ARCH_1="arm64"
            ARCH_2="aarch64"
            ARCH_3="aarch64_generic"
            KERNEL=""
            KERNEL2="5.15.y_6.6.y"
            ;;
        rk*) # Rockchip (RK*)
            op_target="rockchip"
            target_profile="generic"
            target_system="armsr/armv8"
            target_name="armsr-armv8"
            ARCH_1="arm64"
            ARCH_2="aarch64"
            ARCH_3="aarch64_generic"
            KERNEL="5.10.160-rk35v-dbai"
            KERNEL2="5.15.y_6.6.y"
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
        bcm2711*) # Raspberry Pi 4B/400 (64bit)
            op_target="bcm2711"
            target_profile="rpi-4"
            target_system="bcm27xx/bcm2711"
            target_name="bcm27xx-bcm2711"
            ARCH_1="arm64"
            ARCH_2="aarch64"
            ARCH_3="aarch64_cortex-a72"
            ;;
        x86-64|x86_64) # (x86_64)
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

    CURVER=$(echo "${op_branch}" | awk -F. '{print $1"."$2}')
    if [[ ${CURVER} == "24.10" ]]; then
        archive_ext="tar.zst"
    elif [[ ${CURVER} == "23.05" ]]; then
        archive_ext="tar.xz"
    fi
    download_file="https://downloads.${op_sourse}.org/releases/${op_branch}/targets/${target_system}/${op_sourse}-imagebuilder-${op_branch}-${target_name}.Linux-x86_64.${archive_ext}"

    ariadl "${download_file}" "${op_sourse}-imagebuilder-${op_branch}-${target_name}.Linux-x86_64.${archive_ext}"

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
    CURVER=$(echo "${op_branch}" | awk -F. '{print $1"."$2}')

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
        if [[ "$op_fiturs" == "full-fitur" ]]; then
            sed -i "s/CONFIG_TARGET_ROOTFS_PARTSIZE=.*/CONFIG_TARGET_ROOTFS_PARTSIZE=2048/" "${CONFIG_FILE}"
        elif [[ "$op_fiturs" == "simpel" ]]; then
            sed -i "s/CONFIG_TARGET_ROOTFS_PARTSIZE=.*/CONFIG_TARGET_ROOTFS_PARTSIZE=1024/" "${CONFIG_FILE}"
        fi

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
    cd "${imagebuilder_path}" || { error_msg "Failed to change directory to ${imagebuilder_path}"; }
    echo -e "${STEPS} Start adding custom packages..."

    # Create the [packages] directory if not exists
    [[ -d "packages" ]] || mkdir -p "packages"
    if [[ -d "${custom_packages_path}" ]]; then
        # Copy custom packages
        cp -rf "${custom_packages_path}/"* "packages/" > /dev/null 2>&1
        if [[ $? -eq 0 ]]; then
            echo -e "${SUCCESS} Custom packages successfully copied to the [ packages ] directory."
        else
            echo -e "${WARNING} Failed to copy packages from ${custom_packages_path} to the [ packages ] directory."
        fi
    else
        echo -e "${WARNING} No customized packages found in ${custom_packages_path}."
    fi

    cd "packages" || { error_msg "Failed to access [packages] directory."; }

    # Handle GitHub-based IPK downloads
    declare -a github_packages
    if [[ "$op_target" == "amlogic" ]]; then
        echo -e "${INFO} Adding luci-app-amlogic for target Amlogic."
        github_packages+=("luci-app-amlogic|https://api.github.com/repos/ophub/luci-app-amlogic/releases/latest")
    fi
    github_packages+=(
        "luci-app-alpha-config|https://api.github.com/repos/animegasan/luci-app-alpha-config/releases/latest"
        "luci-theme-material3|https://api.github.com/repos/AngelaCooljx/luci-theme-material3/releases/latest"
        "luci-app-neko|https://api.github.com/repos/nosignals/openwrt-neko/releases/latest"
    )

    download_packages "github" github_packages[@]

    # Handle other custom package downloads
    CURVER=$(echo "${op_branch}" | awk -F. '{print $1"."$2}')
    declare -a other_packages=(

        "modemmanager-rpcd|https://downloads.$op_sourse.org/releases/packages-24.10/$ARCH_3/packages"
        "luci-proto-modemmanager|https://downloads.$op_sourse.org/releases/packages-24.10/$ARCH_3/luci"
        "libqmi|https://downloads.$op_sourse.org/releases/packages-24.10/$ARCH_3/packages"
        "libmbim|https://downloads.$op_sourse.org/releases/packages-24.10/$ARCH_3/packages"
        "modemmanager|https://downloads.$op_sourse.org/releases/packages-24.10/$ARCH_3/packages"
        "sms-tool|https://downloads.$op_sourse.org/releases/packages-$CURVER/$ARCH_3/packages"
        "tailscale|https://downloads.$op_sourse.org/releases/packages-$CURVER/$ARCH_3/packages"
        
        "python3-speedtest-cli|https://downloads.openwrt.org/releases/packages-$CURVER/$ARCH_3/packages"
        "dns2tcp|https://downloads.immortalwrt.org/releases/packages-$CURVER/$ARCH_3/packages"
        "luci-app-argon-config|https://downloads.immortalwrt.org/releases/packages-$CURVER/$ARCH_3/luci"
        "luci-theme-argon|https://downloads.immortalwrt.org/releases/packages-$CURVER/$ARCH_3/luci"
        "luci-app-openclash|https://downloads.immortalwrt.org/releases/packages-$CURVER/$ARCH_3/luci"
        "luci-app-passwall|https://downloads.immortalwrt.org/releases/packages-$CURVER/$ARCH_3/luci"
        
        "luci-app-tailscale|https://dl.openwrt.ai/releases/24.10/packages/$ARCH_3/kiddin9"
        "luci-app-diskman|https://dl.openwrt.ai/releases/24.10/packages/$ARCH_3/kiddin9"
        "modeminfo-serial-zte|https://dl.openwrt.ai/releases/24.10/packages/$ARCH_3/kiddin9"
        "modeminfo-serial-gosun|https://dl.openwrt.ai/releases/24.10/packages/$ARCH_3/kiddin9"
        "modeminfo-qmi|https://dl.openwrt.ai/releases/24.10/packages/$ARCH_3/kiddin9"
        "modeminfo-serial-yuge|https://dl.openwrt.ai/releases/24.10/packages/$ARCH_3/kiddin9"
        "modeminfo-serial-thales|https://dl.openwrt.ai/releases/24.10/packages/$ARCH_3/kiddin9"
        "modeminfo-serial-tw|https://dl.openwrt.ai/releases/24.10/packages/$ARCH_3/kiddin9"
        "modeminfo-serial-meig|https://dl.openwrt.ai/releases/24.10/packages/$ARCH_3/kiddin9"
        "modeminfo-serial-styx|https://dl.openwrt.ai/releases/24.10/packages/$ARCH_3/kiddin9"
        "modeminfo-serial-mikrotik|https://dl.openwrt.ai/releases/24.10/packages/$ARCH_3/kiddin9"
        "modeminfo-serial-dell|https://dl.openwrt.ai/releases/24.10/packages/$ARCH_3/kiddin9"
        "modeminfo-serial-sierra|https://dl.openwrt.ai/releases/24.10/packages/$ARCH_3/kiddin9"
        "modeminfo-serial-quectel|https://dl.openwrt.ai/releases/24.10/packages/$ARCH_3/kiddin9"
        "modeminfo-serial-huawei|https://dl.openwrt.ai/releases/24.10/packages/$ARCH_3/kiddin9"
        "modeminfo-serial-xmm|https://dl.openwrt.ai/releases/24.10/packages/$ARCH_3/kiddin9"
        "modeminfo-serial-telit|https://dl.openwrt.ai/releases/24.10/packages/$ARCH_3/kiddin9"
        "modeminfo-serial-fibocom|https://dl.openwrt.ai/releases/24.10/packages/$ARCH_3/kiddin9"
        "modeminfo-serial-simcom|https://dl.openwrt.ai/releases/24.10/packages/$ARCH_3/kiddin9"
        "modeminfo|https://dl.openwrt.ai/releases/24.10/packages/$ARCH_3/kiddin9"
        "luci-app-modeminfo|https://dl.openwrt.ai/releases/24.10/packages/$ARCH_3/kiddin9"
        "atinout|https://dl.openwrt.ai/releases/24.10/packages/$ARCH_3/kiddin9"
        "luci-app-poweroff|https://dl.openwrt.ai/releases/24.10/packages/$ARCH_3/kiddin9"
        "xmm-modem|https://dl.openwrt.ai/releases/24.10/packages/$ARCH_3/kiddin9"
        "luci-app-lite-watchdog|https://dl.openwrt.ai/releases/24.10/packages/$ARCH_3/kiddin9"
        "luci-theme-alpha|https://dl.openwrt.ai/releases/24.10/packages/$ARCH_3/kiddin9"
        "luci-app-adguardhome|https://dl.openwrt.ai/releases/24.10/packages/$ARCH_3/kiddin9"
        "adguardhome|https://dl.openwrt.ai/releases/24.10/packages/$ARCH_3/kiddin9"
        "luci-app-netspeedtest|https://fantastic-packages.github.io/packages/releases/$CURVER/packages/x86_64/luci"
        "sing-box|https://dl.openwrt.ai/releases/24.10/packages/$ARCH_3/kiddin9"
        "mihomo|https://dl.openwrt.ai/releases/24.10/packages/$ARCH_3/kiddin9"
        
        "luci-app-internet-detector|https://github.com/gSpotx2f/packages-openwrt/raw/refs/heads/master/current"
        "internet-detector|https://github.com/gSpotx2f/packages-openwrt/raw/refs/heads/master/current"
        "internet-detector-mod-modem-restart|https://github.com/gSpotx2f/packages-openwrt/raw/refs/heads/master/current"
        "luci-app-cpu-status-mini|https://github.com/gSpotx2f/packages-openwrt/raw/refs/heads/master/current"
        "luci-app-disks-info|https://github.com/gSpotx2f/packages-openwrt/raw/refs/heads/master/current"
        "luci-app-log-viewer|https://github.com/gSpotx2f/packages-openwrt/raw/refs/heads/master/current"
        "luci-app-temp-status|https://github.com/gSpotx2f/packages-openwrt/raw/refs/heads/master/current"

        "luci-app-zerotier|https://downloads.immortalwrt.org/releases/packages-$CURVER/$ARCH_3/luci"
        "luci-app-ramfree|https://downloads.immortalwrt.org/releases/packages-$CURVER/$ARCH_3/luci"
        "luci-app-3ginfo-lite|https://downloads.immortalwrt.org/releases/packages-$CURVER/$ARCH_3/luci"
        "modemband|https://downloads.immortalwrt.org/releases/packages-$CURVER/$ARCH_3/packages"
        "luci-app-modemband|https://downloads.immortalwrt.org/releases/packages-$CURVER/$ARCH_3/luci"
        "luci-app-sms-tool-js|https://downloads.immortalwrt.org/releases/packages-$CURVER/$ARCH_3/luci"
    )

    download_packages "custom" other_packages[@]

    echo -e "${STEPS} Start Clash Core Download !"
    if [[ "$ARCH_3" == "x86_64" ]]; then
        clash_meta=$(meta_api="https://api.github.com/repos/MetaCubeX/mihomo/releases/latest" && meta_file="mihomo-linux-${ARCH_1}-compatible" && curl -s "${meta_api}" | grep "browser_download_url" | grep -oE "https.*${meta_file}-v[0-9]+\.[0-9]+\.[0-9]+\.gz" | head -n 1)
    else
        clash_meta=$(meta_api="https://api.github.com/repos/MetaCubeX/mihomo/releases/latest" && meta_file="mihomo-linux-${ARCH_1}" && curl -s "${meta_api}" | grep "browser_download_url" | grep -oE "https.*${meta_file}-v[0-9]+\.[0-9]+\.[0-9]+\.gz" | head -n 1)
    fi

    # Nikki
    nikki_api="https://api.github.com/repos/rizkikotet-dev/OpenWrt-nikki-Mod/releases"
    nikki_file_ipk="nikki_${ARCH_3}-openwrt-${CURVER}"
    nikki_file_ipk_down=$(curl -s "${nikki_api}" | grep "browser_download_url" | grep -oE "https.*${nikki_file_ipk}.*.tar.gz" | head -n 1)

    #passwall
    passwall_api="https://api.github.com/repos/xiaorouji/openwrt-passwall/releases"
    passwall_file_zip="passwall_packages_ipk_${ARCH_3}"
    passwall_file_zip_down=$(curl -s "${passwall_api}" | grep "browser_download_url" | grep -oE "https.*${passwall_file_zip}.*.zip" | head -n 1)


    # Output download information
    echo -e "${STEPS} Installing OpenClash, Nikki And Passwall"

    mkdir -p "${custom_files_path}/etc/openclash/core"
    ariadl "${clash_meta}" "${custom_files_path}/etc/openclash/core/clash_meta.gz"
    gzip -d "${custom_files_path}/etc/openclash/core/clash_meta.gz" || error_msg "Error: Failed to extract OpenClash package."

    ariadl "${nikki_file_ipk_down}" "${nikki_file_ipk}.tar.gz"
    tar -xzvf "nikki_${ARCH_3}-openwrt-${CURVER}.tar.gz" > /dev/null 2>&1 && rm "nikki_${ARCH_3}-openwrt-${CURVER}.tar.gz" || error_msg "Error: Failed to extract Nikki package."

    ariadl "${passwall_file_zip_down}" "passwall_packages_ipk_${ARCH_3}.zip"
    unzip -q "passwall_packages_ipk_${ARCH_3}.zip" && rm "passwall_packages_ipk_${ARCH_3}.zip" || error_msg "Error: Failed to extract Passwall package."

    # Sync and provide directory status
    sync && sleep 3
    echo -e "${SUCCESS} All custom packages successfully downloaded and extracted."
}

# Add custom packages, lib, theme, app and i18n, etc.
custom_config() {
    cd "${imagebuilder_path}" || { error_msg "Failed to change directory to ${imagebuilder_path}"; }
    echo -e "${STEPS} Start adding custom config..."

    # Define URLs for custom scripts
    declare -A custom_scripts=(
        ["${custom_files_path}/sbin/sync_time.sh"]="https://raw.githubusercontent.com/frizkyiman/auto-sync-time/main/sbin/sync_time.sh"
        ["${custom_files_path}/usr/bin/clock"]="https://raw.githubusercontent.com/frizkyiman/auto-sync-time/main/usr/bin/clock"
        ["${custom_files_path}/usr/bin/mount_hdd"]="https://raw.githubusercontent.com/frizkyiman/auto-mount-hdd/main/mount_hdd"
    )

    echo -e "${INFO} Downloading custom scripts..."

    for file_path in "${!custom_scripts[@]}"; do
        file_url="${custom_scripts[$file_path]}"
        target_dir=$(dirname "$file_path")
        
        # Ensure target directory exists
        mkdir -p "$target_dir" || { echo -e "${ERROR} Failed to create directory $target_dir"; continue; }
        
        # Download the script
        ariadl "$file_url" "$file_path"
    done

    # Add custom config files
    if [[ "$op_fiturs" == "full-fitur" ]]; then
        echo -e "${INFO} No custom config added." 
    elif [[ "$op_fiturs" == "simpel" ]]; then
        echo -e "${INFO} No custom config added."
    fi

    # Sync and provide directory status
    sync && sleep 3
    echo -e "${SUCCESS} All custom configuration setup completed!"
}

# Add custom files
# The FILES variable allows custom configuration files to be included in images built with Image Builder.
# The [ files ] directory should be placed in the Image Builder root directory where you issue the make command.
custom_files() {
    cd "${imagebuilder_path}" || { error_msg "Failed to change directory to ${imagebuilder_path}"; }
    echo -e "${STEPS} Start adding custom files..."

    if [[ -d "${custom_files_path}" ]]; then
        # Ensure the [ files ] directory exists
        [[ -d "files" ]] || mkdir -p "files"

        # Copy custom files
        cp -rf "${custom_files_path}/"* "files"
        if [[ $? -eq 0 ]]; then
            echo -e "${SUCCESS} Custom files successfully copied to the [ files ] directory."
        else
            error_msg "Failed to copy files from ${custom_files_path} to the [ files ] directory."
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

    # Selecting default packages, lib, app and etc.
    # Profile info
    make info

    # Main configuration name
    PROFILE=""
    PACKAGES=""

    # Default
    PACKAGES+=" -dnsmasq dnsmasq-full cgi-io libiwinfo libiwinfo-data libiwinfo-lua liblua \
    luci-base luci-lib-base luci-lib-ip luci-lib-jsonc luci-lib-nixio luci-mod-admin-full \
    luci-app-temp-status cpusage ttyd dmesg kmod-tun luci-lib-ipkg \
    zram-swap adb parted losetup resize2fs luci luci-ssl block-mount htop bash curl wget-ssl \
    tar unzip unrar gzip jq luci-app-ttyd nano httping screen openssh-sftp-server \
    liblucihttp liblucihttp-lua libubus-lua lua luci-app-firewall luci-app-opkg \
    ca-bundle ca-certificates luci-compat coreutils-sleep fontconfig coreutils-whoami file lolcat \
    luci-base luci-lib-base luci-lib-ip luci-lib-jsonc luci-lib-nixio luci-mod-admin-full \
    luci-mod-network luci-mod-status luci-mod-system luci-proto-ipv6 luci-proto-ppp \
    luci-theme-bootstrap px5g-wolfssl rpcd rpcd-mod-file rpcd-mod-iwinfo rpcd-mod-luci \
    rpcd-mod-rrdns uhttpd uhttpd-mod-ubus coreutils coreutils-base64 coreutils-nohup coreutils-stty libc coreutils-stat\
    ip-full libuci-lua microsocks resolveip tcping ipset ipt2socks iptables iptables-legacy \
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
    MIHOMO+="nikki luci-app-nikki"
    PASSWALL+="chinadns-ng resolveip dns2socks dns2tcp ipt2socks microsocks tcping xray-core xray-plugin luci-app-passwall"
    NEKOCLASH+="kmod-tun bash curl jq mihomo sing-box php8 php8-mod-curl luci-app-neko"

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

    if [[ "$op_fiturs" == "full-fitur" ]]; then
        # Python3
        PACKAGES+=" python3 python3-pip"
        # AdguardHome
        PACKAGES+=" adguardhome luci-app-adguardhome"
        # Tunnel
        PACKAGES+=" $OPENCLASH $MIHOMO $PASSWALL $NEKOCLASH"
        # Docker
        PACKAGES+=" docker docker-compose dockerd luci-app-dockerman"
        # Speedtest
        PACKAGES+=" librespeed-go python3-speedtest-cli iperf3-ssl luci-app-netspeedtest"


        # Disable service
        DISABLED_SERVICES+=" AdGuardHome"
    elif [[ "$op_fiturs" == "simpel" ]]; then
        # Tunnel
        PACKAGES+=" $OPENCLASH $MIHOMO $PASSWALL"

        # Disable service
        DISABLED_SERVICES+=""
    fi

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
        MISC+=" luci-app-amlogic ath9k-htc-firmware btrfs-progs hostapd hostapd-utils kmod-ath kmod-ath9k kmod-ath9k-common kmod-ath9k-htc kmod-cfg80211 kmod-crypto-acompress kmod-crypto-crc32c kmod kmod-fs-btrfs kmod-mac80211 wireless-tools wpa-cli wpa-supplicant"
        EXCLUDED+=" -procd-ujail"
        ;;
    bcm27*)
        MISC+=" kmod-i2c-bcm2835 i2c-tools kmod-i2c-core kmod-i2c-gpio"
        EXCLUDED+=" -hostapd -hostapd-common -hostapd-utils"
        ;;
    x86-64)
        MISC+=" kmod-iwlwifi iw-full pciutils"
        ;;
    esac 

    PACKAGES+=" $MISC"

    # Membuat image firmware dan menampilkan progress bar
    make image PROFILE="${target_profile}" PACKAGES="${PACKAGES} ${EXCLUDED}" FILES="files" DISABLED_SERVICES="$DISABLED_SERVICES"
    if [[ $? -eq 0 ]]; then
        echo -e "${SUCCESS} Firmware build completed."
        for file in ${imagebuilder_path}/bin/targets/*/*/*.img.gz; do
            [[ -e "$file" ]] || continue
            mv -f "$file" "${imagebuilder_path}/out_firmware"
            echo -e "${SUCCESS} Firmware successfully created: $file"
        done
        for file in ${imagebuilder_path}/bin/targets/*/*/*rootfs.tar.gz; do
            [[ -e "$file" ]] || continue
            if [[ "${op_target}" == "x86-64" ]]; then
                mv -f "$file" "${imagebuilder_path}/out_firmware"
            else
                mv -f "$file" "${imagebuilder_path}/out_rootfs"
            fi
            echo -e "${SUCCESS} Rootfs successfully created: $file"
        done

        sync && sleep 3
        echo -e "${SUCCESS} Build completed successfully."
    else
        error_msg "Error: OpenWrt build failed. Check logs for details."
    fi
}

repackwrt() {
    # Parse arguments
    local builder_type=""
    local target_board=""
    local target_kernel=""
    
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --ophub|--ulo)
                builder_type="$1"
                shift
                ;;
            -t|--target)
                target_board="$2"
                shift 2
                ;;
            -k|--kernel)
                target_kernel="$2"
                shift 2
                ;;
            *)
                error_msg "Unknown option: $1"
                ;;
        esac
    done

    # Validate required parameters
    if [[ -z "$builder_type" ]]; then
        error_msg "Builder type (--ophub or --ulo) is required"
    fi
    
    if [[ -z "$target_board" ]]; then
        error_msg "Target board (-t) is required"
    fi
    
    if [[ -z "$target_kernel" ]]; then
        error_msg "Target kernel (-k) is required"
    fi

    local readonly OPHUB_REPO="https://github.com/ophub/amlogic-s9xxx-openwrt/archive/refs/heads/main.zip"
    local readonly ULO_REPO="https://github.com/armarchindo/ULO-Builder/archive/refs/heads/main.zip"
    local readonly REQUIRED_SPACE_MB=2048

    # Validate required variables
    local readonly REQUIRED_VARS=("imagebuilder_path" "op_sourse" "op_branch" "op_devices")
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
    local builder_dir output_dir repo_url

    if [[ "$builder_type" == "--ophub" ]]; then
        builder_dir="${work_dir}/amlogic-s9xxx-openwrt-main"
        repo_url="${OPHUB_REPO}"
        echo -e "${STEPS} Starting firmware repackaging with Ophub..."
    else
        builder_dir="${work_dir}/ULO-Builder-main"
        repo_url="${ULO_REPO}"
        echo -e "${STEPS} Starting firmware repackaging with UloBuilder..."
    fi

    output_dir="${work_dir}/out_firmware"

    # Navigate to working directory
    if ! cd "${work_dir}"; then
        error_msg "Failed to access working directory: ${work_dir}"
    fi

    # Download and extract builder
    ariadl "${repo_url}" "main.zip"

    if ! unzip -q main.zip; then
        error_msg "Failed to extract builder archive"
        rm -f main.zip
    fi
    rm -f main.zip

    # Prepare builder directory
    if [[ "$builder_type" == "--ophub" ]]; then
        mkdir -p "${builder_dir}/openwrt-armvirt"
    else
        mkdir -p "${builder_dir}/rootfs"
    fi

    # Validate and copy rootfs
    local readonly rootfs_file="${work_dir}/out_rootfs/${op_sourse}-${op_branch}-armsr-armv8-generic-rootfs.tar.gz"
    if [[ ! -f "${rootfs_file}" ]]; then
        error_msg "Rootfs file not found: ${rootfs_file}"
    fi

    echo -e "${INFO} Copying rootfs file..."
    if [[ "$builder_type" == "--ophub" ]]; then
        if ! cp -f "${rootfs_file}" "${builder_dir}/openwrt-armvirt/"; then
            error_msg "Failed to copy rootfs file"
        fi
    else
        if ! cp -f "${rootfs_file}" "${builder_dir}/rootfs/"; then
            error_msg "Failed to copy rootfs file"
        fi
    fi

    # Change to builder directory
    if ! cd "${builder_dir}"; then
        error_msg "Failed to access builder directory: ${builder_dir}"
    fi

    # Run builder-specific operations
    if [[ "$builder_type" == "--ophub" ]]; then
        echo -e "${INFO} Running OphubBuilder..."
        if ! sudo ./remake -b "${target_board}" -k "${target_kernel}" -s 1024; then
            error_msg "OphubBuilder execution failed"
        fi
        device_output_dir="./openwrt/out"
    else
        # Apply ULO patches
        echo -e "${INFO} Applying UloBuilder patches..."
        if [[ -f "./.github/workflows/ULO_Workflow.patch" ]]; then
            mv ./.github/workflows/ULO_Workflow.patch ./ULO_Workflow.patch
            if ! patch -p1 < ./ULO_Workflow.patch >/dev/null 2>&1; then
                echo -e "${WARN} Failed to apply UloBuilder patch"
            else
                echo -e "${SUCCESS} UloBuilder patch applied successfully"
            fi
        else
            echo -e "${WARN} UloBuilder patch not found"
        fi

        # Run UloBuilder
        echo -e "${INFO} Running UloBuilder..."
        local readonly rootfs_basename=$(basename "${rootfs_file}")
        if ! sudo ./ulo -y -m "${target_board}" -r "${rootfs_basename}" -k "${target_kernel}" -s 1024; then
            error_msg "UloBuilder execution failed"
        fi
        device_output_dir="./out/${target_board}"
    fi

    # Verify and copy output files
    if [[ ! -d "${device_output_dir}" ]]; then
        error_msg "Builder output directory not found: ${device_output_dir}"
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
    ls -lh "${output_dir}"/*
    echo -e "${SUCCESS} Firmware repacking completed successfully!"
}

# Modify boot files for Amlogic devices
# Usage :
# build_mod_sdcard <image_path> <pack_name> <fw_dtb> <image_suffix>
build_mod_sdcard() {
    local image_path="$1"
    local pack_name="$2"
    local dtb="$3"
    local suffix="$4"

    echo -e "${STEPS} Modifying boot files for Amlogic s905x devices..."
    
    # Validate input parameters
    if [ -z "$pack_name" ] || [ -z "$suffix" ] || [ -z "$dtb" ] || [ -z "$image_path" ]; then
        error_msg "Missing required parameters. Usage: build_mod_sdcard <image_path> <pack_name> <dtb> <image_suffix>"
        return 1
    fi

    # Validate and set paths
    if ! cd "${imagebuilder_path}/out_firmware"; then
        error_msg "Failed to change directory to ${imagebuilder_path}/out_firmware"
        return 1
    fi

    local imgpath="${imagebuilder_path}/out_firmware"
    local file_to_process="$image_path"

    cleanup() {
        echo -e "${INFO} Cleaning up temporary files..."
        sudo umount boot 2>/dev/null || true
        sudo losetup -D 2>/dev/null || true
    }

    trap cleanup EXIT

    if [ -z "$file_to_process" ] || [ ! -f "$file_to_process" ]; then
        error_msg "Image file not found: ${file_to_process}"
        return 1
    fi

    # Download modification files
    ariadl "https://github.com/rizkikotet-dev/mod-boot-sdcard/archive/refs/heads/main.zip" "main.zip"

    # Extract files
    echo -e "${INFO} Extracting mod-boot-sdcard..."
    if ! unzip -q main.zip; then
        error_msg "Failed to extract mod-boot-sdcard"
        return 1
    fi
    rm -f main.zip
    echo -e "${SUCCESS} mod-boot-sdcard successfully extracted."
    sleep 3

    # Create working directory
    mkdir -p "${suffix}/boot"
    
    # Copy required files
    echo -e "${INFO} Preparing image for ${suffix}..."
    cp "$file_to_process" "${suffix}/"
    if ! sudo cp mod-boot-sdcard-main/BootCardMaker/u-boot.bin \
        mod-boot-sdcard-main/files/mod-boot-sdcard.tar.gz "${suffix}/"; then
        error_msg "Failed to copy bootloader or modification files"
        return 1
    fi

    # Process the image
    cd "${suffix}" || {
        error_msg "Failed to change directory to ${suffix}"
        return 1
    }

    local file_name=$(basename "${file_to_process%.gz}")

    # Decompress the OpenWRT image
    if ! sudo gunzip "${file_name}.gz"; then
        error_msg "Failed to decompress image"
        return 1
    fi

    # Set up loop device
    local device
    echo -e "${INFO} Setting up loop device..."
    for i in {1..3}; do
        device=$(sudo losetup -fP --show "${file_name}" 2>/dev/null)
        [ -n "$device" ] && break
        sleep 1
    done

    if [ -z "$device" ]; then
        error_msg "Failed to set up loop device"
        return 1
    fi

    # Mount the image
    echo -e "${INFO} Mounting the image..."
    local attempts=0
    while [ $attempts -lt 3 ]; do
        if sudo mount "${device}p1" boot; then
            break
        fi
        attempts=$((attempts + 1))
        sleep 1
    done

    if [ $attempts -eq 3 ]; then
        error_msg "Failed to mount image"
        return 1
    fi

    # Apply modifications
    echo -e "${INFO} Applying boot modifications..."
    if ! sudo tar -xzf mod-boot-sdcard.tar.gz -C boot; then
        error_msg "Failed to extract boot modifications"
        return 1
    fi

    # Update configuration files
    echo -e "${INFO} Updating configuration files..."
    local uenv=$(sudo cat boot/uEnv.txt | grep APPEND | awk -F "root=" '{print $2}')
    local extlinux=$(sudo cat boot/extlinux/extlinux.conf | grep append | awk -F "root=" '{print $2}')
    local boot=$(sudo cat boot/boot.ini | grep dtb | awk -F "/" '{print $4}' | cut -d'"' -f1)

    sudo sed -i "s|$extlinux|$uenv|g" boot/extlinux/extlinux.conf
    sudo sed -i "s|$boot|$dtb|g" boot/boot.ini
    sudo sed -i "s|$boot|$dtb|g" boot/extlinux/extlinux.conf
    sudo sed -i "s|$boot|$dtb|g" boot/uEnv.txt

    sync
    sudo umount boot

    # Write bootloader
    echo -e "${INFO} Writing bootloader..."
    if ! sudo dd if=u-boot.bin of="${device}" bs=1 count=444 conv=fsync 2>/dev/null || \
       ! sudo dd if=u-boot.bin of="${device}" bs=512 skip=1 seek=1 conv=fsync 2>/dev/null; then
        error_msg "Failed to write bootloader"
        return 1
    fi

    # Detach loop device and compress
    sudo losetup -d "${device}"
    if ! sudo gzip "${file_name}"; then
        error_msg "Failed to compress image"
        return 1
    fi

    # Rename image file
    echo -e "${INFO} Renaming image file..."
    local kernel
    kernel=$(grep -oP 'k[0-9]+\.[0-9]+\.[0-9]+(-[A-Za-z0-9-]+)?' <<<"${file_name}")
    local new_name="RTA-WRT${op_source}-${op_branch}-Amlogic_s905x-${suffix}-${kernel}.img.gz"

    if -f "../${new_name}"; then
        rm -rf "../${new_name}"
    fi
    mv "${file_name}.gz" "../${new_name}" || {
        error_msg "Failed to rename image file"
        return 1
    }

    cd ..
    rm -rf "${suffix}"
    rm -rf mod-boot-sdcard-main
    cleanup
    echo -e "${SUCCESS} Successfully processed ${suffix}"
    return 0
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
        "-bcm27xx-bcm2710-rpi-3-ext4-factory|Broadcom_RaspberryPi_3B-Ext4_Factory"
        "-bcm27xx-bcm2710-rpi-3-ext4-sysupgrade|Broadcom_RaspberryPi_3B-Ext4_Sysupgrade"
        "-bcm27xx-bcm2710-rpi-3-squashfs-factory|Broadcom_RaspberryPi_3B-Squashfs_Factory"
        "-bcm27xx-bcm2710-rpi-3-squashfs-sysupgrade|Broadcom_RaspberryPi_3B-Squashfs_Sysupgrade"

        "-bcm27xx-bcm2711-rpi-4-ext4-factory|Broadcom_RaspberryPi_4B-Ext4_Factory"
        "-bcm27xx-bcm2711-rpi-4-ext4-sysupgrade|Broadcom_RaspberryPi_4B-Ext4_Sysupgrade"
        "-bcm27xx-bcm2711-rpi-4-squashfs-factory|Broadcom_RaspberryPi_4B-Squashfs_Factory"
        "-bcm27xx-bcm2711-rpi-4-squashfs-sysupgrade|Broadcom_RaspberryPi_4B-Squashfs_Sysupgrade"
        
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
        "-s905x4-|Amlogic_s905x4"
        "_amlogic_s912_|Amlogic_s912"
        "_amlogic_s905x2_|Amlogic_s905x2"
        "_amlogic_s905x3_|Amlogic_s905x3"

        # x86_64
        "x86-64-generic-ext4-combined-efi|X86_64_Generic_Ext4_Combined_EFI"
        "x86-64-generic-ext4-combined|X86_64_Generic_Ext4_Combined"
        "x86-64-generic-ext4-rootfs|X86_64_Generic_Ext4_Rootfs"
        "x86-64-generic-squashfs-combined-efi|X86_64_Generic_Squashfs_Combined_EFI"
        "x86-64-generic-squashfs-combined|X86_64_Generic_Squashfs_Combined"
        "x86-64-generic-squashfs-rootfs|X86_64_Generic_Squashfs_Rootfs"
        "x86-64-generic-rootfs|X86_64_Generic_Rootfs"
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
                    echo -e "${WARN} Failed to rename $file"
                    continue
                }
            fi
        done
        for file in *"${search}"*.tar.gz; do
            if [[ -f "$file" ]]; then
                local new_name
                new_name="RTA-WRT${op_source}-${op_branch}-${replace}.tar.gz"
                echo -e "${INFO} Renaming: $file → $new_name"
                mv "$file" "$new_name" || {
                    echo -e "${WARN} Failed to rename $file"
                    continue
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
[[ -z "${1}" ]] && error_msg "Please specify the OpenWrt Branch, such as [ ${0} openwrt:24.10.0 x86-64 full-fitur or openwrt:24.10.0 s905x simpel ]"
[[ -z "${2}" ]] && error_msg "Please specify the OpenWrt Devices, such as [ ${0} openwrt:24.10.0 x86-64 full-fitur or openwrt:24.10.0 s905x simpel ]"
[[ "${1}" =~ ^[a-z]{3,}:[0-9]+ ]] || echo "Incoming parameter format <source:branch> <target> <fiturs>: openwrt:24.10.0 x86-64 full-fitur or openwrt:24.10.0 s905x simpel"
[[ "${2}" =~ ^[a-zA-Z0-9_-]+ ]] || echo "Incoming parameter format <source:branch> <target> <fiturs>: openwrt:24.10.0 x86-64 full-fitur or openwrt:24.10.0 s905x simpel"
[[ "${3}" =~ ^[a-zA-Z0-9_-]+ ]] || echo "Incoming parameter format <source:branch> <target> <fiturs>: openwrt:24.10.0 x86-64 full-fitur or openwrt:24.10.0 s905x simpel"
op_sourse="${1%:*}"
op_branch="${1#*:}"
op_devices="${2}"
op_fiturs="${3}"
echo -e "${INFO} Rebuild path: [ ${PWD} ]"
echo -e "${INFO} Rebuild Source: [ ${op_sourse} ], Branch: [ ${op_branch} ], Devices: ${op_devices}"
echo -e "${INFO} Server space usage before starting to compile: \n$(df -hT ${make_path}) \n"

# Perform related operations
setup_colors
check_dependencies
download_imagebuilder
adjust_settings
custom_packages
custom_config
custom_files
rebuild_firmware
case "${op_devices}" in
    s905x)
        repackwrt --ophub -t "s905x_s905x-b860h" -k "$KERNEL2"
        # Process HG680P with OPHUB firmware
        build_mod_sdcard "$(find "${imagebuilder_path}/out_firmware" -name "*_s905x_k5.15*.img.gz")" "OPHUB" "meson-gxl-s905x-p212.dtb" "HG680P"
        build_mod_sdcard "$(find "${imagebuilder_path}/out_firmware" -name "*_s905x_k6.6*.img.gz")" "OPHUB" "meson-gxl-s905x-p212.dtb" "HG680P"
        # Process B860H with OPHUB firmware
        build_mod_sdcard "$(find "${imagebuilder_path}/out_firmware" -name "*_s905x-b860h_k5.15*.img.gz")" "OPHUB" "meson-gxl-s905x-b860h.dtb" "B860H_v1-v2"
        build_mod_sdcard "$(find "${imagebuilder_path}/out_firmware" -name "*_s905x-b860h_k6.6*.img.gz")" "OPHUB" "meson-gxl-s905x-b860h.dtb" "B860H_v1-v2"
        ;;
    s905x[2-3])
        repackwrt --ophub -t "s905x2_s905x3" -k "$KERNEL2"
        ;;
    s912)
        repackwrt --ophub -t "s912" -k "$KERNEL2"
        ;;
    s905x4)
        repackwrt --ulo -t "$op_devices" -k "$KERNEL"
        ;;
    h5-*|h616-*|h618-*|h6-*)
        repackwrt --ulo -t "$op_devices" -k "$KERNEL"
        repackwrt --ulo -t "$op_devices" -k "$KERNEL2"
        repackwrt --ulo -t "$op_devices" -k "$KERNEL3"
        ;;
    rk*)
        repackwrt --ulo -t "$op_devices" -k "$KERNEL"
        ;;
    *)
        ;;
esac
rename_firmware

# Show server end information
echo -e "Server space usage after compilation: \n$(df -hT ${make_path}) \n"
# All process completed
wait