#!/bin/sh

# Autofix download index.php, index.html
if ! grep -q ".php=/usr/bin/php-cgi" /etc/config/uhttpd; then
	echo -e "  helmilog : system not using php-cgi, patching php config ..."
	logger "  helmilog : system not using php-cgi, patching php config..."
	uci set uhttpd.main.ubus_prefix='/ubus'
	uci set uhttpd.main.interpreter='.php=/usr/bin/php-cgi'
	uci set uhttpd.main.index_page='cgi-bin/luci'
	uci add_list uhttpd.main.index_page='index.html'
	uci add_list uhttpd.main.index_page='index.php'
	uci commit uhttpd
	echo -e "  helmilog : patching system with php configuration done ..."
	echo -e "  helmilog : restarting some apps ..."
	logger "  helmilog : patching system with php configuration done..."
	logger "  helmilog : restarting some apps..."
	/etc/init.d/uhttpd restart
fi
/etc/init.d/uhttpd restart
[ -d /usr/lib/php8 ] && [ ! -d /usr/lib/php ] && ln -sf /usr/lib/php8 /usr/lib/php
rm "$0"
