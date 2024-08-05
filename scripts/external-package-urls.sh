#!/bin/bash
# This script for custom download the latest packages version from snapshots/stable repo's url and github releases.
# Put file name and url base.

# Download packages from official snapshots, stable repo's urls and custom repo's.
{
files1=(
    "modemmanager|https://downloads.openwrt.org/snapshots/packages/$ARCH_3/packages"
    "libmbim|https://downloads.openwrt.org/snapshots/packages/$ARCH_3/packages"
    "libqmi|https://downloads.openwrt.org/snapshots/packages/$ARCH_3/packages"
    "sms-tool|https://downloads.openwrt.org/snapshots/packages/$ARCH_3/packages"
    "luci-app-argon-config|https://fantastic-packages.github.io/packages/releases/23.05/packages/x86_64/luci"
    #"luci-theme-argon|https://dl.openwrt.ai/23.05/packages/$ARCH_3/kiddin9"
    #"luci-app-cpu-status-mini|https://dl.openwrt.ai/23.05/packages/$ARCH_3/kiddin9"
    #"luci-app-diskman|https://dl.openwrt.ai/23.05/packages/$ARCH_3/kiddin9"
    #"luci-app-disks-info|https://dl.openwrt.ai/23.05/packages/$ARCH_3/kiddin9"
    #"luci-app-log|https://dl.openwrt.ai/23.05/packages/$ARCH_3/kiddin9"
    #"luci-app-temp-status|https://dl.openwrt.ai/23.05/packages/$ARCH_3/kiddin9"
    #"luci-app-internet-detector|https://fantastic-packages.github.io/packages/releases/$(echo "$BRANCH" | cut -d'.' -f1-2)/packages/x86_64/luci"
    "internet-detector|https://fantastic-packages.github.io/packages/releases/23.05/packages/x86_64/packages"
    "internet-detector-mod-modem-restart|https://fantastic-packages.github.io/packages/releases/23.05/packages/x86_64/packages"
    "luci-app-netspeedtest|https://fantastic-packages.github.io/packages/releases/23.05/packages/x86_64/luci"
    "python3-speedtest-cli|https://downloads.openwrt.org/releases/packages-$(echo "$BRANCH" | cut -d'.' -f1-2)/$ARCH_3/packages"
    "librespeed-go|https://downloads.openwrt.org/releases/packages-$(echo "$BRANCH" | cut -d'.' -f1-2)/$ARCH_3/packages"
    #"luci-app-ramfree|https://dl.openwrt.ai/23.05/packages/$ARCH_3/kiddin9"
    #"quickstart|https://dl.openwrt.ai/23.05/packages/$ARCH_3/kiddin9"
    #"luci-app-tinyfilemanager|https://dl.openwrt.ai/23.05/packages/$ARCH_3/kiddin9"
    #"modeminfo|https://dl.openwrt.ai/23.05/packages/$ARCH_3/kiddin9"
    #"atinout|https://dl.openwrt.ai/23.05/packages/$ARCH_3/kiddin9"
    #"luci-app-poweroff|https://dl.openwrt.ai/23.05/packages/$ARCH_3/kiddin9"
    #"xmm-modem|https://dl.openwrt.ai/23.05/packages/$ARCH_3/kiddin9"
)

echo "###########################################################"
echo "Downloading packages from official repo's and custom repo's"
echo "###########################################################"
echo "#"
for entry in "${files1[@]}"; do
    IFS="|" read -r filename1 base_url <<< "$entry"
    echo "Processing file: $filename1"

    file_urls=$(curl -sL "$base_url" | grep -oE "${filename1}_[0-9a-zA-Z\._~-]*\.ipk" | grep -v 'git' | sort -V | tail -n 1)

    if [ -z "$file_urls" ]; then
        echo "No matching stable file found. Trying general search..."
        file_urls=$(curl -sL "$base_url" | grep -oE "${filename1}_[0-9a-zA-Z\._~-]*\.ipk" | sort -V | tail -n 1)
    fi

    echo "Matching files found:"
    echo "$file_urls"

    if [ -n "$file_urls" ]; then
        full_url="$base_url/$file_urls"
        echo "Downloading $filename1 from $full_url"
        curl -Lo "packages/${filename1}.ipk" "$full_url"
        
        if [ $? -eq 0 ]; then
            echo "Package [$filename1] downloaded successfully."
        else
            echo "Failed to download package [$filename1]."
        fi
    else
        echo "No matching file found for [$filename1] at $base_url."
    fi
    echo "#"
done
}

# Download custom packages from github release api urls
{
if [ "$TYPE" == "AMLOGIC" ]; then
    echo "Adding [luci-app-amlogic] from bulider script type."
    files2+=("luci-app-amlogic|https://api.github.com/repos/ophub/luci-app-amlogic/releases/latest")
fi

files2+=(
    #"luci-app-sms-tool-js|https://api.github.com/repos/4IceG/luci-app-sms-tool-js/releases/latest"
    #"luci-app-modemband|https://api.github.com/repos/4IceG/luci-app-modemband/releases/latest"
    #"modemband|https://api.github.com/repos/4IceG/luci-app-modemband/releases/latest"
    #"luci-app-lite-watchdog|https://api.github.com/repos/4IceG/luci-app-lite-watchdog/releases/latest"
    #"luci-app-3ginfo-lite|https://api.github.com/repos/4IceG/luci-app-3ginfo-lite/releases/latest"
    "luci-app-netmonitor|https://api.github.com/repos/rtaserver/rta-packages/releases"
    "luci-app-base64|https://api.github.com/repos/rtaserver/rta-packages/releases"
    "luci-theme-rta|https://api.github.com/repos/rtaserver/RTA-Theme-OpenWrt/releases/latest"
    "luci-app-rtaconfig|https://api.github.com/repos/rtaserver/RTA-Theme-OpenWrt/releases/latest"
    "luci-theme-alpha|https://api.github.com/repos/derisamedia/luci-theme-alpha/releases/latest"
    "luci-app-alpha-config|https://api.github.com/repos/derisamedia/luci-theme-alpha/releases/latest"
    "luci-app-quickstart|https://api.github.com/repos/animegasan/luci-app-quickstart/releases/latest"
)

echo "#########################################"
echo "Downloading packages from github releases"
echo "#########################################"
echo "#"
for entry in "${files2[@]}"; do
    IFS="|" read -r filename2 base_url <<< "$entry"
    echo "Processing file: $filename2"
    file_urls=$(curl -s "$base_url" | grep "browser_download_url" | grep -oE "https.*/${filename2}_[_0-9a-zA-Z\._~-]*\.ipk" | sort -V | tail -n 1)
    for file_url in $file_urls; do
        if [ ! -z "$file_url" ]; then
            echo "Downloading $(basename "$file_url")"
            echo "from $file_url"
            curl -Lo "packages/$(basename "$file_url")" "$file_url"
            echo "Packages [$filename2] downloaded successfully!."
            echo "#"
            break
        else
            echo "Failed to retrieve packages [$filename2] because it's different from $file_url. Retrying before exit..."
        fi
    done
done
}

#################################################################################################################################
# Download custom packages from external-package-urls.txt

echo "###################################################"
echo "Downloading packages from external-package-urls.txt"
echo "###################################################"
echo "#"
[ "$ARCH_1" == "amd64" ] && ARCH_1=x86
if [[ "$BRANCH" == "21.02.7" ]]; then
    if [[ "$TYPE" == "AMLOGIC" ]]; then
      grep -E "^all-all|^old-21.02|^amlogic-21.02|^amlogic" external-package-urls.txt | awk '{print $2}' > output_url.txt
    else
      grep -E "^all-all|^old-21.02|^$ARCH_1-21.02|^$ARCH_1" external-package-urls.txt | awk '{print $2}' > output_url.txt
    fi
else
    if [[ "$TYPE" == "AMLOGIC" ]]; then
      grep -E "^all-all|^all|^amlogic" external-package-urls.txt | grep -vE "^amlogic-21.02" | awk '{print $2}' > output_url.txt
    else
      grep -E "^all-all|^all|^$ARCH_1" external-package-urls.txt | grep -vE "^$ARCH_1-21.02" | awk '{print $2}' > output_url.txt
    fi
fi
wget --no-check-certificate -i output_url.txt -nv -P packages

#################################################################################################################################


{
    echo "###################################################"
    echo "Downloading packages from external-kiddin9"
    echo "###################################################"
    echo "#"
    BASE_URL="https://dl.openwrt.ai/packages-23.05/$ARCH_3/kiddin9"
    BASE_LIST="https://dl.openwrt.ai/latest/packages/$ARCH_3/kiddin9/Packages.gz"

    PACKAGES_GZ="Packages.gz"
    PACKAGES_FILE="Packages"

    #===============================================
    input_packages=(
        "luci-app-internet-detector"
    "luci-theme-argon"
    "luci-app-cpu-status-mini"
    "luci-app-diskman"
    "luci-app-disks-info"
    "luci-app-log"
    "luci-app-temp-status"
    "luci-app-ramfree"
    "quickstart"
    "luci-app-tinyfilemanager"
    "modeminfo"
    "atinout"
    "luci-app-poweroff"
    "xmm-modem"
    "luci-app-3ginfo-lite"
    "luci-app-lite-watchdog"
    "modemband"
    "luci-app-modemband"
    "luci-app-sms-tool-js"
    )
    #================================================
    
    echo "Downloading $PACKAGES_GZ from $BASE_LIST..."
    curl -L "$BASE_LIST" -o "$PACKAGES_GZ"

    echo "Extracting $PACKAGES_GZ..."
    gunzip "$PACKAGES_GZ"

    declare -A files_map

    while IFS= read -r line; do
        if [[ $line == Package:* ]]; then
            package_name=$(echo $line | awk '{print $2}')
        elif [[ $line == Filename:* ]]; then
            filename=$(echo $line | awk '{print $2}')
            files_map["$package_name"]="$filename"
        fi
    done < "$PACKAGES_FILE"

    for input_package in "${input_packages[@]}"; do
        if [[ -n ${files_map[$input_package]} ]]; then
            FILENAME=${files_map[$input_package]}
            URL="$BASE_URL/$FILENAME"
            SAVE_AS="packages/${input_package}.ipk"
            echo "Downloading $FILENAME from $URL..."
            curl -L "$URL" -o "$SAVE_AS"
        else
            echo "Paket '$input_package' tidak ditemukan dalam daftar."
        fi
    done

    rm -f "$PACKAGES_GZ" "$PACKAGES_FILE"
}
