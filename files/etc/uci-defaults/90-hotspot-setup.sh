#!/bin/sh

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
mysql -u root -p"radius" radius < /root/radius_monitor.sql
rm -rf /root/radius_monitor.sql
mysql -u root -p"radius" radius < /www/RadiusMonitor/radmon.sql
mysql -u root -p"radius" radius < /www/raddash/raddash.sql
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
mv /root/hotspot/usr/share/hotspotlogin /usr/share/hotspotlogin
ln -s /usr/share/hotspotlogin /www/hotspotlogin
chmod +x /etc/init.d/chilli
echo "src/gz mutiara_wrt https://raw.githubusercontent.com/maizil41/mutiara-wrt-opkg/main/generic" >> /etc/opkg/customfeeds.conf
echo "All first boot setup complete!"
if [ ! -e /etc/hotspotsetup ] \
rm -rf /root/hotspot
touch /etc/hotspotsetup
reboot
fi
exit 1