#!/bin/sh

# Create a log file with timestamp
LOGFILE="/root/setup_$(date +%Y%m%d_%H%M%S).log"
exec > "$LOGFILE" 2>&1

# Function for logging with timestamps
log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

# System information banner
log "==================== SYSTEM INFORMATION ===================="
log "Installed Time: $(date '+%A, %d %B %Y %T')"
log "Processor: $(ubus call system board | grep '\"system\"' | sed 's/ \+/ /g' | awk -F'\"' '{print $4}')"
log "Device Model: $(ubus call system board | grep '\"model\"' | sed 's/ \+/ /g' | awk -F'\"' '{print $4}')"
log "Device Board: $(ubus call system board | grep '\"board_name\"' | sed 's/ \+/ /g' | awk -F'\"' '{print $4}')"
log "Memory: $(free -m | grep Mem | awk '{print $2}') MB"
log "Storage: $(df -h / | tail -1 | awk '{print $2}')"
log "==================== CONFIGURATION START ===================="

# Backup original configuration
log "Creating configuration backup..."
mkdir -p /root/config_backup
cp -r /etc/config/* /root/config_backup/
cp /etc/openwrt_release /root/config_backup/

# Firmware customization
log "Customizing firmware information..."
sed -i "s#_('Firmware Version'),(L.isObject(boardinfo.release)?boardinfo.release.description+' / ':'')+(luciversion||''),#_('Firmware Version'),(L.isObject(boardinfo.release)?boardinfo.release.description+' build by RTA-WRT [ Ouc3kNF6 ]':''),#g" /www/luci-static/resources/view/status/include/10_system.js
sed -i -E "s|icons/port_%s.png|icons/port_%s.gif|g" /www/luci-static/resources/view/status/include/29_ports.js

# Detect and configure for specific OpenWrt distributions
if grep -q "ImmortalWrt" /etc/openwrt_release; then
  log "ImmortalWrt detected, applying specific configurations..."
  sed -i "s/\(DISTRIB_DESCRIPTION='ImmortalWrt [0-9]*\.[0-9]*\.[0-9]*\).*'/\1'/g" /etc/openwrt_release
  sed -i -E "s|services/ttyd|system/ttyd|g" /usr/share/ucode/luci/template/themes/material/header.ut
  sed -i -E "s|services/ttyd|system/ttyd|g" /usr/lib/lua/luci/view/themes/argon/header.htm
  log "Branch version: $(grep 'DISTRIB_DESCRIPTION=' /etc/openwrt_release | awk -F"'" '{print $2}')"
elif grep -q "OpenWrt" /etc/openwrt_release; then
  log "OpenWrt detected, applying specific configurations..."
  sed -i "s/\(DISTRIB_DESCRIPTION='OpenWrt [0-9]*\.[0-9]*\.[0-9]*\).*'/\1'/g" /etc/openwrt_release
  log "Branch version: $(grep 'DISTRIB_DESCRIPTION=' /etc/openwrt_release | awk -F"'" '{print $2}')"
fi

# Log installed tunnel applications
log "Tunnel Applications Installed: $(opkg list-installed | grep -e luci-app-openclash -e luci-app-nikki -e luci-app-passwall -e luci-app-clash -e luci-app-shadowsocks | awk '{print $1}' | tr '\n' ' ')"

# System user configuration
log "Setting up root password..."
(echo "rtawrt"; sleep 1; echo "rtawrt") | passwd > /dev/null

# Time zone and NTP configuration
log "Setting up time zone to Asia/Jakarta and NTP servers..."
uci set system.@system[0].hostname='RTA-WRT'
uci set system.@system[0].timezone='WIB-7'
uci set system.@system[0].zonename='Asia/Jakarta'
uci -q delete system.ntp.server
uci add_list system.ntp.server="0.pool.ntp.org"
uci add_list system.ntp.server="1.pool.ntp.org"
uci add_list system.ntp.server="id.pool.ntp.org"
uci add_list system.ntp.server="time.google.com"
uci add_list system.ntp.server="time.cloudflare.com"
uci commit system

# Network interface configuration
log "Configuring network interfaces..."
# LAN configuration
uci set network.lan.ipaddr="192.168.1.1"
uci set network.lan.netmask="255.255.255.0"
uci set network.lan.dns="8.8.8.8,1.1.1.1"

# WAN configuration
uci set network.wan=interface 
uci set network.wan.proto='modemmanager'
uci set network.wan.device='/sys/devices/platform/scb/fd500000.pcie/pci0000:00/0000:00:00.0/0000:01:00.0/usb2/2-1'
uci set network.wan.apn='internet'
uci set network.wan.auth='none'
uci set network.wan.iptype='ipv4'

# Add failover WAN interface
log "Adding failover WAN interface..."
uci set network.wan2=interface
uci set network.wan2.proto='dhcp'
uci set network.wan2.device='eth1'
uci commit network

# Firewall configuration
log "Configuring firewall..."
uci set firewall.@zone[1].network='wan wan2'
uci commit firewall

# Disable IPv6
log "Disabling IPv6..."
uci -q delete dhcp.lan.dhcpv6
uci -q delete dhcp.lan.ra
uci -q delete dhcp.lan.ndp
uci commit dhcp

# Wireless configuration with auto-detection
log "Configuring wireless networks..."
# Function to detect and configure wireless devices
setup_wireless() {
  local devices=$(ls /sys/class/ieee80211/)
  local device_count=0
  
  for device in $devices; do
    local dev_path="/sys/class/ieee80211/$device"
    local phy_idx=$(echo $device | sed 's/phy//')
    local hwmode=$(iw phy$phy_idx info | grep -i "band" | head -1)
    
    # Determine the band (2.4GHz or 5GHz)
    if echo "$hwmode" | grep -q "5"; then
      log "5GHz wireless device detected: $device"
      uci set wireless.radio$device_count=wifi-device
      uci set wireless.radio$device_count.type='mac80211'
      uci set wireless.radio$device_count.path="platform/soc/$device"
      uci set wireless.radio$device_count.band='5g'
      uci set wireless.radio$device_count.channel='36'
      uci set wireless.radio$device_count.htmode='VHT80'
      uci set wireless.radio$device_count.country='ID'
      uci set wireless.radio$device_count.disabled='0'
      
      # Configure interface for 5GHz
      uci set wireless.default_radio$device_count=wifi-iface
      uci set wireless.default_radio$device_count.device="radio$device_count"
      uci set wireless.default_radio$device_count.network='lan'
      uci set wireless.default_radio$device_count.mode='ap'
      uci set wireless.default_radio$device_count.ssid="RTA-WRT_5G"
      uci set wireless.default_radio$device_count.encryption='psk2'
      uci set wireless.default_radio$device_count.key='rtawrt123'
      uci set wireless.default_radio$device_count.disabled='0'
    else
      log "2.4GHz wireless device detected: $device"
      uci set wireless.radio$device_count=wifi-device
      uci set wireless.radio$device_count.type='mac80211'
      uci set wireless.radio$device_count.path="platform/soc/$device"
      uci set wireless.radio$device_count.band='2g'
      uci set wireless.radio$device_count.channel='6'
      uci set wireless.radio$device_count.htmode='HT20'
      uci set wireless.radio$device_count.country='ID'
      uci set wireless.radio$device_count.disabled='0'
      
      # Configure interface for 2.4GHz
      uci set wireless.default_radio$device_count=wifi-iface
      uci set wireless.default_radio$device_count.device="radio$device_count"
      uci set wireless.default_radio$device_count.network='lan'
      uci set wireless.default_radio$device_count.mode='ap'
      uci set wireless.default_radio$device_count.ssid="RTA-WRT_2G"
      uci set wireless.default_radio$device_count.encryption='psk2'
      uci set wireless.default_radio$device_count.key='rtawrt123'
      uci set wireless.default_radio$device_count.disabled='0'
    fi
    
    device_count=$((device_count + 1))
  done
  
  # Commit and restart wireless
  if [ $device_count -gt 0 ]; then
    uci commit wireless
    wifi reload && wifi up
    log "$device_count wireless devices configured."
    
    # Add wireless maintenance scripts
    if ! grep -q "wifi up" /etc/rc.local; then
      sed -i '/exit 0/i # Wireless maintenance' /etc/rc.local
      sed -i '/exit 0/i sleep 15 && wifi up' /etc/rc.local
    fi
    
    if ! grep -q "wifi up" /etc/crontabs/root; then
      echo "# Wireless maintenance - Auto restart every 12 hours" >> /etc/crontabs/root
      echo "0 */12 * * * wifi down && sleep 5 && wifi up" >> /etc/crontabs/root
      service cron restart
    fi
  else
    log "No wireless devices detected."
  fi
}

# Call the wireless setup function
setup_wireless

# Package management and repositories
log "Setting up package management and repositories..."
# Disable signature check for opkg
sed -i 's/option check_signature/# option check_signature/g' /etc/opkg.conf

# Add custom repositories
echo "src/gz openwrt_packages https://dl.openwrt.ai/latest/packages/$(grep "OPENWRT_ARCH" /etc/os-release | awk -F '"' '{print $2}')/kiddin9" >> /etc/opkg/customfeeds.conf

# UI configuration
log "Setting up UI configuration..."
# Set Argon as default theme
uci set luci.main.mediaurlbase='/luci-static/argon' && uci commit
echo >> /usr/share/ucode/luci/template/header.ut && cat /usr/share/ucode/luci/template/theme.txt >> /usr/share/ucode/luci/template/header.ut
rm -rf /usr/share/ucode/luci/template/theme.txt

# Configure TTYD
log "Configuring TTYD..."
uci set ttyd.@ttyd[0].command='/bin/bash --login'
uci set ttyd.@ttyd[0].interface='@lan'
uci set ttyd.@ttyd[0].port='7681'
uci commit ttyd

# USB modem configuration - remove problematic USB mode switch entries
log "Configuring USB modem settings..."
# Function to safely edit USB mode switch configuration
edit_usb_mode_json() {
  local vid_pid=$1
  log "Removing USB mode switch for $vid_pid"
  sed -i -e "/$vid_pid/,+5d" /etc/usb-mode.json
}

# Remove specific USB mode switches
edit_usb_mode_json "12d1:15c1" # Huawei ME909s
edit_usb_mode_json "413c:81d7" # DW5821e
edit_usb_mode_json "1e2d:00b3" # Thales MV31-W T99W175

# Disable XMM modem service
log "Disabling XMM modem service..."
uci set xmm-modem.@xmm-modem[0].enable='0'
uci commit xmm-modem

# Traffic monitoring configuration
log "Setting up traffic monitoring..."
# Configure nlbwmon
uci set nlbwmon.@nlbwmon[0].database_directory='/etc/nlbwmon'
uci set nlbwmon.@nlbwmon[0].commit_interval='3h'
uci set nlbwmon.@nlbwmon[0].refresh_interval='30s'
uci set nlbwmon.@nlbwmon[0].database_limit='10000'
uci commit nlbwmon
/etc/init.d/nlbwmon restart

# Configure vnstat for traffic statistics
log "Setting up vnstat..."
sed -i 's/;DatabaseDir "\/var\/lib\/vnstat"/DatabaseDir "\/etc\/vnstat"/' /etc/vnstat.conf
mkdir -p /etc/vnstat
chmod +x /etc/init.d/vnstat_backup
/etc/init.d/vnstat_backup enable
if [ -f "/www/vnstati/vnstati.sh" ]; then
  chmod +x /www/vnstati/vnstati.sh
  /www/vnstati/vnstati.sh
fi

# Adjust app categories in LuCI
log "Adjusting application categories..."
sed -i 's/services/modem/g' /usr/share/luci/menu.d/luci-app-lite-watchdog.json

# Shell environment and profile setup
log "Setting up shell environment..."
sed -i 's/\[ -f \/etc\/banner \] && cat \/etc\/banner/#&/' /etc/profile
sed -i 's/\[ -n "$FAILSAFE" \] && cat \/etc\/banner.failsafe/#&/' /etc/profile

# Setup utility scripts
log "Setting up utility scripts..."
for script in /sbin/sync_time.sh /sbin/free.sh /usr/bin/clock /usr/bin/openclash.sh /usr/bin/cek_sms.sh; do
  if [ -f "$script" ]; then
    chmod +x "$script"
    log "Made $script executable"
  fi
done

# Make install scripts executable
if [ -f "/root/install2.sh" ]; then
  chmod +x /root/install2.sh && /root/install2.sh
fi

# Configure OpenClash if installed
log "Checking and configuring OpenClash..."
if opkg list-installed | grep -q luci-app-openclash; then
  log "OpenClash detected, configuring..."
  # Create directory structure if it doesn't exist
  mkdir -p /etc/openclash/core
  mkdir -p /etc/openclash/history
  
  # Set permissions for core files
  for file in /etc/openclash/core/clash_meta /etc/openclash/GeoIP.dat /etc/openclash/GeoSite.dat /etc/openclash/Country.mmdb; do
    if [ -f "$file" ]; then
      chmod +x "$file"
      log "Set permissions for $file"
    fi
  done
  
  # Apply patches
  if [ -f "/usr/bin/patchoc.sh" ]; then
    chmod +x /usr/bin/patchoc.sh
    log "Patching OpenClash overview..."
    /usr/bin/patchoc.sh
    sed -i '/exit 0/i # OpenClash patch' /etc/rc.local
    sed -i '/exit 0/i #/usr/bin/patchoc.sh' /etc/rc.local
  fi
  
  # Create symbolic links
  ln -sf /etc/openclash/history/config-wrt.db /etc/openclash/cache.db 2>/dev/null
  ln -sf /etc/openclash/core/clash_meta /etc/openclash/clash 2>/dev/null
  
  # Move configuration file
  if [ -f "/etc/config/openclash1" ]; then
    rm -rf /etc/config/openclash
    mv /etc/config/openclash1 /etc/config/openclash
    log "Moved OpenClash configuration file"
  fi
  
  log "OpenClash setup complete!"
else
  log "OpenClash not detected, cleaning up..."
  uci delete internet-detector.Openclash 2>/dev/null
  uci commit internet-detector 2>/dev/null
  service internet-detector restart
  rm -rf /etc/config/openclash1
fi

# Configure Nikki if installed
log "Checking and configuring Nikki..."
if opkg list-installed | grep -q luci-app-nikki; then
  log "Nikki detected, configuring..."
  # Create directory structure if it doesn't exist
  mkdir -p /etc/nikki/run
  
  # Set permissions for core files
  for file in /etc/nikki/run/GeoIP.dat /etc/nikki/run/GeoSite.dat; do
    if [ -f "$file" ]; then
      chmod +x "$file"
      log "Set permissions for $file"
    fi
  done
  
  log "Nikki setup complete!"
else
  log "Nikki not detected, cleaning up..."
  rm -rf /etc/config/nikki
  rm -rf /etc/nikki
fi

# Setup PHP for web applications
log "Setting up PHP..."
uci set uhttpd.main.ubus_prefix='/ubus'
uci set uhttpd.main.interpreter='.php=/usr/bin/php-cgi'
uci set uhttpd.main.index_page='cgi-bin/luci'
uci add_list uhttpd.main.index_page='index.html'
uci add_list uhttpd.main.index_page='index.php'
uci commit uhttpd

# Optimize PHP configuration
if [ -f "/etc/php.ini" ]; then
  sed -i -E "s|memory_limit = [0-9]+M|memory_limit = 128M|g" /etc/php.ini
  sed -i -E "s|max_execution_time = [0-9]+|max_execution_time = 60|g" /etc/php.ini
  sed -i -E "s|display_errors = On|display_errors = Off|g" /etc/php.ini
  sed -i -E "s|;date.timezone =|date.timezone = Asia/Jakarta|g" /etc/php.ini
  log "PHP configuration optimized"
fi

# Create symbolic links for PHP
ln -sf /usr/bin/php-cli /usr/bin/php
[ -d /usr/lib/php8 ] && [ ! -d /usr/lib/php ] && ln -sf /usr/lib/php8 /usr/lib/php
/etc/init.d/uhttpd restart

# Setup TinyFM file manager
log "Setting up TinyFM file manager..."
mkdir -p /www/tinyfm
ln -sf / /www/tinyfm/rootfs

# Set up system information script
if [ -f "/etc/profile.d/30-sysinfo.sh-bak" ]; then
  rm -rf /etc/profile.d/30-sysinfo.sh 2>/dev/null
  mv /etc/profile.d/30-sysinfo.sh-bak /etc/profile.d/30-sysinfo.sh
  log "Restored original system information script"
fi

# Complete setup
log "==================== CONFIGURATION COMPLETE ===================="
log "All setup tasks completed successfully!"
log "Cleaning up and finalizing..."

# Remove temporary files
rm -rf /root/install2.sh /tmp/* 2>/dev/null

# Clean up the setup script
rm -f /etc/uci-defaults/$(basename $0) 2>/dev/null

echo "Setup complete! The system will now reboot in 5 seconds..."
sleep 5
reboot

exit 0