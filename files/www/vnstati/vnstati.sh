#!/bin/bash
vnstati -s -i br-lan -o /www/vnstati/br-lan_vnstat_s.png
vnstati -5 -i br-lan -o /www/vnstati/br-lan_vnstat_5.png
vnstati -h -i br-lan -o /www/vnstati/br-lan_vnstat_h.png
vnstati -d -i br-lan -o /www/vnstati/br-lan_vnstat_d.png
vnstati -m -i br-lan -o /www/vnstati/br-lan_vnstat_m.png
vnstati -y -i br-lan -o /www/vnstati/br-lan_vnstat_y.png
vnstati -t -i br-lan -o /www/vnstati/br-lan_vnstat_t.png
