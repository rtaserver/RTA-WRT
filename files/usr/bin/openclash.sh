#!/bin/bash
# Script to install openclash, gabut version.
# Created by Frizkyiman
# Github https://github.com/frizkyiman/

INFO="[\033[94m INFO \033[0m]"
SUCCESS="[\033[92m SUCCESS \033[0m]"
ERROR="[\033[91m ERROR \033[0m]"
opkg_updated=false
openclash_api="https://api.github.com/repos/vernesong/OpenClash/releases"
openclash_file="luci-app-openclash"
openclash_file_down="$(curl -s "${openclash_api}" | grep "browser_download_url" | grep -oE "https.*${openclash_file}.*.ipk" | head -n 1)"
patchoc="https://raw.githubusercontent.com/rizkikotet-dev/RTA-WRT/main/files/usr/bin/patchoc.sh"

check_and_install_packages() {
    required_packages=("wget-ssl" "bash" "curl" "gzip" "tar")
    for package in "${required_packages[@]}"; do
        if ! opkg list-installed | grep -q "^$package -"; then
            echo -e "${INFO} Package $package to initialize setup not found. Installing..."
            [ "$opkg_updated" = false ] && { opkg update || { echo -e "${ERROR} Failed to update opkg!"; exit 1; }; opkg_updated=true; }
            opkg install $package
        else
            echo -e "${INFO} $package Installed!."
        fi
    done
}

install_openclash_depands() {
    echo -e "${INFO} Start installing [ ${openclash_file} ] dependencies first"
    if opkg list-installed | grep -q '^dnsmasq[[:space:]]'; then
        echo -e "${INFO} dnsmasq is already installed. Removing..."
        opkg remove dnsmasq
    fi
    if [ -n "$(command -v fw4)" ]; then
        echo -e "${INFO} Firewall 4 nftables detected"
        [ "$opkg_updated" = false ] && { opkg update || { echo -e "${ERROR} Failed to update opkg!"; exit 1; }; opkg_updated=true; }
        opkg install coreutils-nohup bash dnsmasq-full curl ca-certificates ipset ip-full libcap libcap-bin ruby ruby-yaml kmod-tun kmod-inet-diag unzip kmod-nft-tproxy luci-compat luci luci-base
    else
        echo -e "${INFO} Firewall 3 iptables detected"
        [ "$opkg_updated" = false ] && { opkg update || { echo -e "${ERROR} Failed to update opkg!"; exit 1; }; opkg_updated=true; }
        opkg install coreutils-nohup bash iptables dnsmasq-full curl ca-certificates ipset ip-full iptables-mod-tproxy iptables-mod-extra libcap libcap-bin ruby ruby-yaml kmod-tun kmod-inet-diag unzip luci-compat luci luci-base
    fi
}

install_openclash() {
    echo -e "${INFO} Start downloading [ ${openclash_file} ]."
    if wget -q -N -P /root "${openclash_file_down}"; then
        echo -e "${SUCCESS} The [ $(basename "${openclash_file_down}") ] is downloaded successfully."
        echo -e "${INFO} Start installing [ ${openclash_file} ]"
        [ "$opkg_updated" = false ] && { opkg update || { echo -e "${ERROR} Failed to update opkg!"; exit 1; }; opkg_updated=true; }
        if opkg install /root/*openclash*.ipk; then
            patch_openclash
            [ "${?}" -eq "0" ] && echo -e "${SUCCESS} Openclash successfully installed and patched." || echo -e "${ERROR} Failed to apply patch! Check for errors during patching."
            echo "Installed version: $(opkg list-installed | grep openclash)"
        else
            echo -e "${ERROR} Failed to install [ ${openclash_file} ]! Check for errors during installation."
        fi
        rm /root/*openclash*.ipk
    else
        echo -e "${ERROR} [ ${openclash_file} ] download failed! Make sure the connection is accessible."
    fi
}

patch_openclash() {
    if wget -q -N -P /usr/bin "$patchoc"; then
        echo -e "${INFO} Start applying patch for [ ${openclash_file} ]."
        chmod +x /usr/bin/patchoc.sh && /usr/bin/patchoc.sh
    else
        echo -e "${ERROR} Failed to download patchoc.sh! Make sure the connection is accessible."
    fi
}

install_openclash_core() {
    echo -e "${INFO} Start downloading core..."
    core_dir="/etc/openclash/core"
    ARCH_1=$(uname -m) && { [ "$ARCH_1" == "aarch64" ] && ARCH_1="arm64"; } || { [ "$ARCH_1" == "x86_64" ] && ARCH_1="amd64" && ARCH_2="x86_64"; }
    rm -r "$core_dir"
    wget -qO- https://github.com/ratserver/RTA-WRT/raw/main/scripts/clash-core.sh | bash -s "$core_dir" "$ARCH_1" "$ARCH_2"
    echo -e "${SUCCESS} Done!"
    chmod +x "$core_dir/clash"
    chmod +x "$core_dir/clash_tun"
    chmod +x "$core_dir/clash_meta"
}

uninstall_openclash() {
    echo -e "${INFO} Start uninstalling [ ${openclash_file} ]"
    if opkg list-installed | grep -q 'luci-app-openclash'; then
        echo -e "${INFO} Detect luci-app-openclash installed. Removing..."
        opkg remove luci-app-openclash
        rm -rf /usr/lib/lua/luci/model/cbi/openclash
        rm -rf /usr/lib/lua/luci/view/openclash
        rm -rf /www/luci-static/resources/openclash
        rm -rf /usr/share/openclash/
        rm -rf /tmp/luci*
        echo -e "${SUCCESS} Done!"
    fi
}

setup() {
    case "$1" in
        reinstall)
            uninstall_openclash
            install_openclash
            ;;
        install-core)
            install_openclash_core
            ;;
        full-install)
            install_openclash_depands
            install_openclash
            install_openclash_core
            patch_openclash
            ;;
        patch-only)
            patch_openclash
            ;;
        uninstall)
            uninstall_openclash
            ;;
        *)
            echo -e "${ERROR} Invalid argument. Usage: $0 {full-install|reinstall|install-core|patch-only|uninstall}"
            ;;
    esac
}

check_and_install_packages
setup "$@"
