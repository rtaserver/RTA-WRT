#!/bin/sh

exec > /root/setup.log 2>&1

# dont remove!
echo "Installed Time: $(date '+%A, %d %B %Y %T')"
echo "###############################################"
echo "Processor: $(ubus call system board | grep '\"system\"' | sed 's/ \+/ /g' | awk -F'\"' '{print $4}')"
echo "Device Model: $(ubus call system board | grep '\"model\"' | sed 's/ \+/ /g' | awk -F'\"' '{print $4}')"
echo "Device Board: $(ubus call system board | grep '\"board_name\"' | sed 's/ \+/ /g' | awk -F'\"' '{print $4}')"
sed -i "s#_('Firmware Version'),(L.isObject(boardinfo.release)?boardinfo.release.description+' / ':'')+(luciversion||''),#_('Firmware Version'),(L.isObject(boardinfo.release)?boardinfo.release.description+' build by RTA-WRT [Ouc3kNF6]':''),#g" /www/luci-static/resources/view/status/include/10_system.js
sed -i "s/\(DISTRIB_DESCRIPTION='OpenWrt [0-9]*\.[0-9]*\.[0-9]*\).*'/\1'/g" /etc/openwrt_release
echo Branch version: "$(grep 'DISTRIB_DESCRIPTION=' /etc/openwrt_release | awk -F"'" '{print $2}')"
echo "Tunnel Installed: $(opkg list-installed | grep -e luci-app-openclash -e luci-app-passwall | awk '{print $1}' | tr '\n' ' ')"
echo "###############################################"

# Set login root password
(echo "rtawrt"; sleep 1; echo "rtawrt") | passwd > /dev/null

# Set hostname and Timezone to Asia/Jakarta
echo "Setup NTP Server and Time Zone to Asia/Jakarta"
uci set system.@system[0].hostname='RTA-WRT'
uci set system.@system[0].timezone='WIB-7'
uci set system.@system[0].zonename='Asia/Jakarta'
uci -q delete system.ntp.server
uci add_list system.ntp.server="pool.ntp.org"
uci add_list system.ntp.server="id.pool.ntp.org"
uci add_list system.ntp.server="time.google.com"
uci commit system

# configure wan interface
chmod +x /usr/lib/ModemManager/connection.d/10-report-down
echo "Setup WAN and LAN Interface"
uci set network.lan.ipaddr="192.168.1.1"
uci set network.wan=interface 
uci set network.wan.proto='modemmanager'
uci set network.wan.device='/sys/devices/platform/scb/fd500000.pcie/pci0000:00/0000:00:00.0/0000:01:00.0/usb2/2-1'
uci set network.wan.apn='internet'
uci set network.wan.auth='none'
uci set network.wan.iptype='ipv4'
uci set network.tethering=interface
uci set network.tethering.proto='dhcp'
uci set network.tethering.device='usb0'
uci commit network
uci set firewall.@zone[1].network='wan tethering'
uci commit firewall

# configure ipv6
uci -q delete dhcp.lan.dhcpv6
uci -q delete dhcp.lan.ra
uci -q delete dhcp.lan.ndp
uci commit dhcp

# configure WLAN
echo "Setup Wireless if available"
uci set wireless.@wifi-device[0].disabled='0'
uci set wireless.@wifi-iface[0].disabled='0'
uci set wireless.@wifi-iface[0].encryption='none'
uci set wireless.@wifi-device[0].country='ID'
if grep -q "Raspberry Pi 4\|Raspberry Pi 3" /proc/cpuinfo; then
  uci set wireless.@wifi-iface[0].ssid='RTA-WRT_5g'
  uci set wireless.@wifi-device[0].channel='149'
  uci set wireless.radio0.htmode='HT40'
  uci set wireless.radio0.band='5g'
else
  uci set wireless.@wifi-iface[0].ssid='RTA-WRT_2g'
  uci set wireless.@wifi-device[0].channel='1'
  uci set wireless.@wifi-device[0].band='2g'
fi
uci commit wireless
wifi reload && wifi up
if iw dev | grep -q Interface; then
  if grep -q "Raspberry Pi 4\|Raspberry Pi 3" /proc/cpuinfo; then
    if ! grep -q "wifi up" /etc/rc.local; then
      sed -i '/exit 0/i # remove if you dont use wireless' /etc/rc.local
      sed -i '/exit 0/i sleep 10 && wifi up' /etc/rc.local
    fi
    if ! grep -q "wifi up" /etc/crontabs/root; then
      echo "# remove if you dont use wireless" >> /etc/crontabs/root
      echo "0 */12 * * * wifi down && sleep 5 && wifi up" >> /etc/crontabs/root
      service cron restart
    fi
  fi
else
  echo "No wireless device detected."
fi

# custom repo and Disable opkg signature check
echo "Setup custom Repo By kiddin9"
sed -i 's/option check_signature/# option check_signature/g' /etc/opkg.conf
echo "src/gz custom_arch https://dl.openwrt.ai/latest/packages/$(grep "OPENWRT_ARCH" /etc/os-release | awk -F '"' '{print $2}')/kiddin9" >> /etc/opkg/customfeeds.conf

# set argon as default theme
echo "Setup Default Theme"
uci set luci.main.mediaurlbase='/luci-static/argon' && uci commit

echo "Setup misc settings"
# remove login password required when accessing terminal
uci set ttyd.@ttyd[0].command='/bin/bash --login'
uci commit

# remove huawei me909s usb-modeswitch
sed -i -e '/12d1:15c1/,+5d' /etc/usb-mode.json

# remove dw5821e usb-modeswitch
sed -i -e '/413c:81d7/,+5d' /etc/usb-mode.json

# Disable /etc/config/xmm-modem
uci set xmm-modem.@xmm-modem[0].enable='0'
uci commit

# setup nlbwmon database dir
uci set nlbwmon.@nlbwmon[0].database_directory='/etc/nlbwmon'
uci set nlbwmon.@nlbwmon[0].commit_interval='3h'
uci set nlbwmon.@nlbwmon[0].refresh_interval='60s'
uci commit nlbwmon
bash /etc/init.d/nlbwmon restart

# setup auto vnstat database backup
sed -i 's/;DatabaseDir "\/var\/lib\/vnstat"/DatabaseDir "\/etc\/vnstat"/' /etc/vnstat.conf
mkdir -p /etc/vnstat
chmod +x /etc/init.d/vnstat_backup
bash /etc/init.d/vnstat_backup enable

# adjusting app catagory
sed -i 's/services/nas/g' /usr/lib/lua/luci/controller/aria2.lua 2>/dev/null || sed -i 's/services/nas/g' /usr/share/luci/menu.d/luci-app-aria2.json
sed -i 's/services/nas/g' /usr/share/luci/menu.d/luci-app-samba4.json
sed -i 's/services/nas/g' /usr/share/luci/menu.d/luci-app-hd-idle.json
sed -i 's/services/modem/g' /usr/share/luci/menu.d/luci-app-lite-watchdog.json

# setup misc settings
sed -i 's/\[ -f \/etc\/banner \] && cat \/etc\/banner/#&/' /etc/profile
sed -i 's/\[ -n "$FAILSAFE" \] && cat \/etc\/banner.failsafe/& || \/usr\/bin\/neofetch/' /etc/profile
chmod +x /root/fix-tinyfm.sh && bash /root/fix-tinyfm.sh
chmod +x /root/install2.sh && bash /root/install2.sh
chmod +x /sbin/sync_time.sh
chmod +x /sbin/free.sh
chmod +x /usr/bin/neofetch
chmod +x /usr/bin/clock
chmod +x /usr/bin/mount_hdd
chmod +x /usr/bin/openclash.sh
chmod +x /usr/bin/cek_sms.sh

# configurating openclash
if opkg list-installed | grep luci-app-openclash > /dev/null; then
  echo "Openclash Detected!"
  echo "Configuring Core..."
  chmod +x /etc/openclash/core/clash
  chmod +x /etc/openclash/core/clash_tun
  chmod +x /etc/openclash/core/clash_meta
  chmod +x /usr/bin/patchoc.sh
  echo "Patching Openclash Overview"
  bash /usr/bin/patchoc.sh
  sed -i '/exit 0/i #/usr/bin/patchoc.sh' /etc/rc.local
  echo "YACD and Core setup complete!"
else
  echo "No Openclash Detected."
  uci delete internet-detector.Openclash
  uci commit internet-detector
  service internet-detector restart
fi

# adding new line for enable i2c oled display
if grep -q "Raspberry Pi 4\|Raspberry Pi 3" /proc/cpuinfo; then
  echo -e "\ndtparam=i2c1=on\ndtparam=spi=on\ndtparam=i2s=on" >> /boot/config.txt
fi

#################### HOTSPOT SETUP ####################
# Setting php8
sed -i -E "s|memory_limit = [0-9]+M|memory_limit = 100M|g" /etc/php.ini
uci set uhttpd.main.index_page='index.php'
uci set uhttpd.main.interpreter='.php=/usr/bin/php-cgi'
uci commit uhttpd

ln -s /usr/bin/php-cli /usr/bin/php

sed -i '$ a include_path=".:/usr/share/pear"' /etc/php.ini

sed -i -E "s|option enabled '0'|option enabled '1'|g" /etc/config/mysqld
sed -i -E "s|# datadir		= /srv/mysql|datadir	= /usr/share/mysql|g" /etc/mysql/conf.d/50-server.cnf
sed -i -E "s|127.0.0.1|0.0.0.0|g" /etc/mysql/conf.d/50-server.cnf

/etc/init.d/mysqld restart
/etc/init.d/mysqld reload


cd /etc/freeradius3/mods-enabled
rm -rf *
ln -s ../mods-available/always
ln -s ../mods-available/attr_filter
ln -s ../mods-available/chap
ln -s ../mods-available/detail
ln -s ../mods-available/digest
ln -s ../mods-available/eap
ln -s ../mods-available/exec
ln -s ../mods-available/expiration
ln -s ../mods-available/expr
ln -s ../mods-available/files
ln -s ../mods-available/logintime
ln -s ../mods-available/mschap
ln -s ../mods-available/pap
ln -s ../mods-available/preprocess
ln -s ../mods-available/radutmp
ln -s ../mods-available/realm
ln -s ../mods-available/sql
ln -s ../mods-available/sradutmp
ln -s ../mods-available/unix

cd /etc/freeradius3/sites-enabled
rm -rf *
ln -s ../sites-available/default
ln -s ../sites-available/inner-tunnel

mysql -e "SET PASSWORD FOR 'root'@'localhost' = PASSWORD('radius');"
mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED BY 'radius';"
mysql -u root -p"radius" <<EOF
DELETE FROM mysql.user WHERE User='';
DROP DATABASE IF EXISTS test;
DELETE FROM mysql.db WHERE Db='test' OR Db='test_%';
FLUSH PRIVILEGES;
EOF

mysql -u root -p"radius" -e "CREATE DATABASE radius CHARACTER SET utf8";
mysql -u root -p"radius" -e "GRANT ALL ON radius.* TO 'radius'@'localhost' IDENTIFIED BY 'radius' WITH GRANT OPTION";

mysql -u root -p"radius" radius -e "SET FOREIGN_KEY_CHECKS = 0; $(mysql -u root -p"radius" radius -e 'SHOW TABLES' | awk '{print "DROP TABLE IF EXISTS `" $1 "`;"}' | grep -v '^Tables' | tr '\n' ' ') SET FOREIGN_KEY_CHECKS = 1;"
mysql -u root -p"radius" radius < /www/RadiusMonitor/radius_monitor.sql
cat <<'EOF' >/usr/lib/lua/luci/controller/radmon.lua
module("luci.controller.radmon", package.seeall)
function index()
entry({"admin","services","radmon"}, template("radmon"), _("Radius Monitor"), 3).leaf=true
end
EOF

cat <<'EOF' >/usr/lib/lua/luci/view/radmon.htm
<%+header%>
<div class="cbi-map"><br/>
<iframe id="rad_mon" style="width: 100%; min-height: 100vh; border: none; border-radius: 2px;"></iframe>
</div>
<script type="text/javascript">
document.getElementById("rad_mon").src = window.location.protocol + "//" + window.location.host + "/RadiusMonitor";
</script>
<%+footer%>
EOF

chmod +x /usr/lib/lua/luci/view/radmon.htm

ln -s /usr/share/hotspotlogin /www/hotspotlogin
chmod +x /etc/init.d/chilli


uci set network.hotspot=device
uci set network.hotspot.name='br-hotspot'
uci set network.hotspot.type='bridge'
uci set network.hotspot.ipv6='0'
uci add_list network.hotspot.ports='wlan0'

uci set network.voucher=interface
uci set network.voucher.name='voucher'
uci set network.voucher.proto='static'
uci set network.voucher.device='br-hotspot'
uci set network.voucher.ipaddr='10.10.30.1'
uci set network.voucher.netmask='255.255.255.0'

uci set network.chilli=interface
uci set network.chilli.proto='none'
uci set network.chilli.device='tun0'

uci commit network

## Config Firewall
if ! uci show firewall | grep -q "firewall\.tun="; then
  echo "Adding 'tun' zone..."
  uci set firewall.tun=zone
  uci set firewall.tun.name='tun'
  uci set firewall.tun.input='ACCEPT'
  uci set firewall.tun.output='ACCEPT'
  uci set firewall.tun.forward='REJECT'
  uci add_list firewall.tun.network='chilli'
else
  echo "'tun' zone already exists."
fi

sleep 3

forwarding_exists=false
for i in $(uci show firewall | grep -o "firewall.@forwarding\[[0-9]\+\]"); do
  src=$(uci get ${i}.src)
  dest=$(uci get ${i}.dest)
  if [ "$src" = "tun" ] && [ "$dest" = "wan" ]; then
    forwarding_exists=true
    break
  fi
done

if [ "$forwarding_exists" = false ]; then
  echo "Adding forwarding from 'tun' to 'wan'..."
  uci add firewall forwarding
  uci set firewall.@forwarding[-1].src='tun'
  uci set firewall.@forwarding[-1].dest='wan'
else
  echo "Forwarding from 'tun' to 'wan' already exists."
fi
    
sleep 3

if ! uci show firewall | grep -q "firewall\.voucher="; then
  echo "Adding 'voucher' zone..."
  uci set firewall.voucher=zone
  uci set firewall.voucher.name='hotspot'
  uci set firewall.voucher.input='ACCEPT'
  uci set firewall.voucher.output='ACCEPT'
  uci set firewall.voucher.forward='ACCEPT'
  uci add_list firewall.voucher.network='voucher'
else
  echo "'voucher' zone already exists."
fi

sleep 3

forwarding_exists=false
for i in $(uci show firewall | grep -o "firewall.@forwarding\[[0-9]\+\]"); do
  src=$(uci get ${i}.src)
  dest=$(uci get ${i}.dest)
  if [ "$src" = "hotspot" ] && [ "$dest" = "tun" ]; then
    forwarding_exists=true
    break
  fi
done

if [ "$forwarding_exists" = false ]; then
  echo "Adding forwarding from 'voucher' to 'tun'..."
  uci add firewall forwarding
  uci set firewall.@forwarding[-1].src='hotspot'
  uci set firewall.@forwarding[-1].dest='tun'
else
  echo "Forwarding from 'voucher' to 'tun' already exists."
fi

uci commit firewall

/etc/init.d/radiusd restar
/etc/init.d/chilli restart

echo "All first boot setup complete!"
reboot
exit 0
