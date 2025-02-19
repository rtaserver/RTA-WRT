#!/bin/bash

. ./scripts/INCLUDE.sh

# Logging functions
log() {
    echo "[INFO] $1"
}

error() {
    echo "[ERROR] $1"
    exit 1
}

# Initialize environment
init_environment() {
    log "Start Downloading Misc files and setup configuration!"
    log "Current Path: $PWD"
}

# Setup base-specific configurations
setup_base_config() {
    # Update date in init settings
    sed -i "s/Ouc3kNF6/$DATE/g" files/etc/uci-defaults/99-init-settings.sh
    
    case "$BASE" in
        "openwrt")
            log "Configuring OpenWrt specific settings"
            sed -i '/# setup misc settings/ a\mv \/www\/luci-static\/resources\/view\/status\/include\/29_temp.js \/www\/luci-static\/resources\/view\/status\/include\/17_temp.js' files/etc/uci-defaults/99-init-settings.sh
            ;;
        "immortalwrt")
            log "Configuring ImmortalWrt specific settings"
            ;;
        *)
            log "Unknown base system: $BASE"
            ;;
    esac
}

# Handle Amlogic-specific files
handle_amlogic_files() {
    if [ "$TYPE" == "AMLOGIC" ]; then
        log "Removing Amlogic-specific files"
        rm -f files/etc/uci-defaults/70-rootpt-resize
        rm -f files/etc/uci-defaults/80-rootfs-resize
        rm -f files/etc/sysupgrade.conf
    fi
}

# Setup branch-specific configurations
setup_branch_config() {
    local branch_major=$(echo "$BRANCH" | cut -d'.' -f1)
    case "$branch_major" in
        "24")
            log "Configuring for branch 24.x"
            ;;
        "23")
            log "Configuring for branch 23.x"
            ;;
        *)
            log "Unknown branch version: $BRANCH"
            ;;
    esac
}

# Configure file permissions for Amlogic
configure_amlogic_permissions() {
    if [ "$TYPE" == "AMLOGIC" ]; then
        log "Setting up Amlogic file permissions"
        local netifd_files=(
            "/lib/netifd/proto/3g.sh"
            "/lib/netifd/proto/dhcp.sh"
            "/lib/netifd/proto/dhcpv6.sh"
            "/lib/netifd/proto/ncm.sh"
            "/lib/netifd/proto/wwan.sh"
            "/lib/netifd/wireless/mac80211.sh"
            "/lib/netifd/dhcp-get-server.sh"
            "/lib/netifd/dhcp.script"
            "/lib/netifd/dhcpv6.script"
            "/lib/netifd/hostapd.sh"
            "/lib/netifd/netifd-proto.sh"
            "/lib/netifd/netifd-wireless.sh"
            "/lib/netifd/utils.sh"
            "/lib/wifi/mac80211.sh"
        )
        
        for file in "${netifd_files[@]}"; do
            sed -i "/# setup misc settings/ a\chmod +x $file" files/etc/uci-defaults/99-init-settings.sh
        done
    else
        log "Removing lib directory for non-Amlogic build"
        rm -rf files/lib
    fi
}

# Download custom scripts
download_custom_scripts() {
    log "Downloading custom scripts"
    
    local scripts=(
        "https://raw.githubusercontent.com/frizkyiman/auto-sync-time/main/sbin/sync_time.sh|files/sbin"
        "https://raw.githubusercontent.com/frizkyiman/auto-sync-time/main/usr/bin/clock|files/usr/bin"
        "https://raw.githubusercontent.com/frizkyiman/fix-read-only/main/install2.sh|files/root"
    )
    
    for script in "${scripts[@]}"; do
        IFS='|' read -r url path <<< "$script"
        wget --no-check-certificate -nv -P "$path" "$url" || error "Failed to download: $url"
    done
}

# Main execution
main() {
    init_environment
    setup_base_config
    handle_amlogic_files
    setup_branch_config
    configure_amlogic_permissions
    download_custom_scripts
    log "All custom configuration setup completed!"
}

# Execute main function
main