#!/bin/bash

. ./scripts/INCLUDE.sh

# Initialize environment
init_environment() {
    log "INFO" "Start Downloading Misc files and setup configuration!"
    log "INFO" "Current Path: $PWD"
}

# Setup base-specific configurations
setup_base_config() {
    # Update date in init settings
    sed -i "s/Ouc3kNF6/${DATE}/g" files/etc/uci-defaults/99-init-settings.sh
    
    case "${BASE}}" in
        "openwrt")
            log "INFO" "Configuring OpenWrt specific settings"
            sed -i '/# setup misc settings/ a\mv \/www\/luci-static\/resources\/view\/status\/include\/29_temp.js \/www\/luci-static\/resources\/view\/status\/include\/17_temp.js' files/etc/uci-defaults/99-init-settings.sh
            ;;
        "immortalwrt")
            log "INFO" "Configuring ImmortalWrt specific settings"
            ;;
        *)
            log "INFO" "Unknown base system: ${BASE}}"
            ;;
    esac
}

# Handle Amlogic-specific files
handle_amlogic_files() {
    case "${TYPE}" in
        "OPHUB"|"ULO")
            log "INFO" "Removing Amlogic-specific files"
            rm -f files/etc/uci-defaults/70-rootpt-resize
            rm -f files/etc/uci-defaults/80-rootfs-resize
            rm -f files/etc/sysupgrade.conf
            ;;
        *)
            log "INFO" "system type: ${TYPE}"
            ;;
    esac
}

# Setup branch-specific configurations
setup_branch_config() {
    local branch_major=$(echo "${BRANCH}" | cut -d'.' -f1)
    case "$branch_major" in
        "24")
            log "INFO" "Configuring for branch 24.x"
            ;;
        "23")
            log "INFO" "Configuring for branch 23.x"
            ;;
        *)
            log "INFO" "Unknown branch version: ${BRANCH}"
            ;;
    esac
}

# Configure file permissions for Amlogic
configure_amlogic_permissions() {
    case "${TYPE}" in
        "OPHUB"|"ULO")
            log "INFO" "Setting up Amlogic file permissions"
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
            ;;
        *)
            log "INFO" "Removing lib directory for non-Amlogic build"
            rm -rf files/lib
            ;;
    esac
}

# Download custom scripts
download_custom_scripts() {
    log "INFO" "Downloading custom scripts"
    
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
    log "SUCCESS" "All custom configuration setup completed!"
}

# Execute main function
main