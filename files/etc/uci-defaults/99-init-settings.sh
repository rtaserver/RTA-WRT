#!/bin/sh

TYPEOPENWRT="nullwrt"

sed -i 's/\[ -f \/etc\/banner \] && cat \/etc\/banner/#&/' /etc/profile
sed -i 's/\[ -n "$FAILSAFE" \] && cat \/etc\/banner.failsafe/& || \/usr\/bin\/rtawrt/' /etc/profile
echo "clear1() {
  clear
}
alias clear1='clear1'" >> /etc/profile
echo "alias clear='/usr/bin/rtawrt'" >> /etc/profile

if [ "$TYPEOPENWRT" == "amlogic" ]; then
chmod +x /bin/getcpu
chmod +x /etc/custom_service/start_service.sh
rm -rf /etc/profile.d/30-sysinfo.sh
chmod +x /sbin/firstboot
chmod +x /sbin/kmod
chmod +x /usr/bin/7z
chmod +x /usr/bin/cpustat
chmod +x /usr/sbin/openwrt-install-allwinner
chmod +x /usr/sbin/openwrt-openvfd
chmod +x /usr/sbin/openwrt-swap
chmod +x /usr/sbin/openwrt-tf
fi

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

chmod +x /usr/lib/ModemManager/connection.d/10-report-down

echo "Setup WAN and LAN Interface"
# Configure Network
uci set network.lan.ipaddr="192.168.1.1"
uci del network.lan.ip6assign
uci set network.modemmanager=interface
uci set network.modemmanager.proto='modemmanager'
uci set network.modemmanager.device='/sys/devices/pci0000:00/0000:00:15.0/usb2/2-1/2-1.1'
uci set network.modemmanager.apn='internet'
uci set network.modemmanager.auth='none'
uci set network.modemmanager.iptype='ipv4'
uci set network.modemmanager.loglevel='ERR'
uci set network.modemmanager.metric='10'
uci set network.modemmanager.force_connection='1'
uci set network.tethering=interface
uci set network.tethering.proto='dhcp'
uci set network.tethering.device='usb0'
uci set network.tethering.metric='20'
uci set network.wan=interface
uci set network.wan.proto='dhcp'
uci set network.wan.device='eth1'
uci set network.wan.metric='1'
uci del network.wan6
uci set network.wan2=interface
uci set network.wan2.proto='dhcp'
uci set network.wan2.device='eth2'
uci set network.wan2.metric='2'
uci set network.hotspot=device
uci set network.hotspot.name='br-hotspot'
uci set network.hotspot.type='bridge'
uci set network.hotspot.ipv6='0'
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

# configure Firewall
uci set firewall.tun=zone
uci set firewall.tun.name='tun'
uci set firewall.tun.input='ACCEPT'
uci set firewall.tun.output='ACCEPT'
uci set firewall.tun.forward='REJECT'
uci add_list firewall.tun.network='chilli'
uci add firewall forwarding
uci set firewall.@forwarding[-1].src='tun'
uci set firewall.@forwarding[-1].dest='wan'
uci set firewall.@zone[0].network='lan voucher'
uci set firewall.@zone[1].network='wan wan2 modemmanager tethering'
uci commit firewall

# configure DHCP
uci del dhcp.@dnsmasq[0].nonwildcard
uci del dhcp.@dnsmasq[0].noresolv
uci del dhcp.@dnsmasq[0].boguspriv
uci del dhcp.@dnsmasq[0].filterwin2k
uci del dhcp.@dnsmasq[0].filter_aaaa
uci del dhcp.@dnsmasq[0].filter_a
uci del dhcp.@dnsmasq[0].nonegcache
uci add_list dhcp.@dnsmasq[0].server='1.1.1.1'
uci -q delete dhcp.lan.dhcpv6
uci -q delete dhcp.lan.ra
uci -q delete dhcp.lan.ndp
uci -q delete dhcp.lan.ra_slaac
uci -q delete dhcp.lan.ra_flags
uci commit dhcp
/etc/init.d/dnsmasq restart

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
uci set luci.main.mediaurlbase='/luci-static/material' && uci commit

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
sed -i -E "s|status|services|g" /usr/lib/lua/luci/controller/base64.lua

# setup misc settings

chmod +x /root/fix-tinyfm.sh && bash /root/fix-tinyfm.sh
chmod +x /root/install2.sh && bash /root/install2.sh
chmod +x /sbin/sync_time.sh
chmod +x /sbin/free.sh
chmod +x /usr/bin/rtawrt
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
  ln -s /etc/openclash/history/config-wrt.db /etc/openclash/cache.db
  ln -s /etc/openclash/core/clash_meta  /etc/openclash/clash
  echo "YACD and Core setup complete!"
else
  echo "No Openclash Detected."
  uci delete internet-detector.Openclash
  uci commit internet-detector
  service internet-detector restart
fi

if opkg list-installed | grep luci-app-passwall > /dev/null; then
  echo "Passwall Detected!"
else
  sed -i '/<a href="\/cgi-bin\/luci\/admin\/services\/passwall">/d' /usr/share/ucode/luci/template/themes/material/header.ut
fi

# adding new line for enable i2c oled display
if grep -q "Raspberry Pi 4\|Raspberry Pi 3" /proc/cpuinfo; then
  echo -e "\ndtparam=i2c1=on\ndtparam=spi=on\ndtparam=i2s=on" >> /boot/config.txt
fi

# Setting php8
sed -i -E "s|memory_limit = [0-9]+M|memory_limit = 100M|g" /etc/php.ini
uci set uhttpd.main.index_page='index.php'
uci set uhttpd.main.interpreter='.php=/usr/bin/php-cgi'
uci commit uhttpd

ln -s /usr/bin/php-cli /usr/bin/php

# Setting Tinyfm
ln -s / /www/tinyfm/rootfs

# Setting Hotspot
chmod +x /usr/bin/acct_log.sh
chmod +x /usr/bin/check_kuota.sh
chmod +x /usr/bin/client_check.sh
chmod +x /usr/bin/pear
chmod +x /usr/bin/peardev

sed -i -E "s|memory_limit = [0-9]+M|memory_limit = 100M|g" /etc/php.ini
sed -i -E "s|display_errors = On|display_errors = Off|g" /etc/php.ini
uci set uhttpd.main.index_page='index.php'
uci set uhttpd.main.interpreter='.php=/usr/bin/php-cgi'
uci commit uhttpd
/etc/init.d/uhttpd restart

sed -i -E "s|option enabled '0'|option enabled '1'|g" /etc/config/mysqld
sed -i -E "s|# datadir		= /srv/mysql|datadir	= /usr/share/mysql|g" /etc/mysql/conf.d/50-server.cnf
sed -i -E "s|127.0.0.1|0.0.0.0|g" /etc/mysql/conf.d/50-server.cnf
/etc/init.d/mysqld restart
/etc/init.d/mysqld reload
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
mysql -u root -p"radius" radius < /root/hotspot/radius_monitor.sql
rm -rf /root/hotspot/radius_monitor.sql
mysql -u root -p"radius" radius < /www/RadiusMonitor/radmon.sql

mv /www/phpmyadmin/config.sample.inc.php /www/phpmyadmin/config.inc.php
sed -i -E "s|localhost|127.0.0.1|g" /www/phpmyadmin/config.inc.php
sed -i "/\$cfg\['Servers'\]\[.*\]\['AllowNoPassword'\] = false;/a \$cfg\['AllowThirdPartyFraming'\] = true;" /www/phpmyadmin/config.inc.php
cat <<'EOF' >/usr/lib/lua/luci/controller/phpmyadmin.lua
module("luci.controller.phpmyadmin", package.seeall)
function index()
entry({"admin","services","phpmyadmin"}, template("phpmyadmin"), _("PhpMyAdmin"), 3).leaf=true
end
EOF
cat <<'EOF' >/usr/lib/lua/luci/view/phpmyadmin.htm
<%+header%>
<div class="cbi-map"><br/>
<iframe id="phpmyadmin" style="width: 100%; min-height: 100vh; border: none; border-radius: 2px;"></iframe>
</div>
<script type="text/javascript">
document.getElementById("phpmyadmin").src = window.location.protocol + "//" + window.location.host + "/phpmyadmin";
</script>
<%+footer%>
EOF
chmod +x /usr/lib/lua/luci/view/phpmyadmin.htm

/etc/init.d/radiusd stop
rm -rf /etc/freeradius3
cd /root/hotspot/etc
mv freeradius3 /etc/freeradius3
rm -rf /usr/share/freeradius3
cd /root/hotspot/usr/share
mv freeradius3 /usr/share/freeradius3
cd /etc/freeradius3/mods-enabled
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
ln -s ../sites-available/default
ln -s ../sites-available/inner-tunnel
if ! grep -q '/etc/init.d/radiusd restart' /etc/rc.local; then
    sed -i '/exit 0/i /etc/init.d/radiusd restart' /etc/rc.local
fi

/etc/init.d/chilli stop
rm -rf /etc/config/chilli
rm -rf /etc/init.d/chilli
mv /root/hotspot/etc/config/chilli /etc/config/chilli
mv /root/hotspot/etc/init.d/chilli /etc/init.d/chilli

ln -s /usr/share/hotspotlogin /www/hotspotlogin
mv /usr/share/RadiusMonitorx /usr/share/RadiusMonitor
ln -s /usr/share/RadiusMonitor /www/RadiusMonitor

chmod +x /etc/init.d/chilli
if ! grep -q '/etc/init.d/chilli restart' /etc/rc.local; then
    sed -i '/exit 0/i /etc/init.d/chilli restart' /etc/rc.local
fi

echo "src/gz mutiara_wrt https://raw.githubusercontent.com/maizil41/mutiara-wrt-opkg/main/generic" >> /etc/opkg/customfeeds.conf

echo "All first boot setup complete!"
rm -rf /root/hotspot
touch /etc/hotspotsetup
echo "All first boot setup complete!"
rm -rf /etc/uci-defaults/99-init-settings.sh
reboot
exit 0
