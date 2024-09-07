<h1 align="center">
  <img src="/pictures/logo.png" alt="OpenWrt" width="100">
  <br>RTA WRT - OpenWrt<br>

</h1>


<p align="center">
Builder With ImageBuilder
</p>
<p align="center">
Custom Script By FriWrt
</p>
<br>


* [Apache License 2.0](https://github.com/rtaserver/RTA-WRT/blob/main/LICENSE)
* [friWrt-MyWrtBuilder](https://github.com/frizkyiman/friWrt-MyWrtBuilder) by [frizkyiman](https://github.com/frizkyiman)
* [MyWrtBuilder](https://github.com/Revincx/MyWrtBuilder) by [Revincx](https://github.com/Revincx)
* [RadiusMonitor](https://github.com/Maizil41/RadiusMonitor) by [Revincx](https://github.com/Maizil41)

Warning for First Installation: 
---
```Initial boot takes a little while due to Repartitioning Storage and additional configuration```


Firmware details
---
Tunneling Include
* OpenWrt Latest : Openclash And Passwall
* Openwrt Snapshots : OpenClash
---
Hotspot Voucher Settings
1. Change Network Settings -> Interface -> Device -> br-hotspot . click the Configure button..
2. Change the Bridge ports section for Voucher Output
3. Click Save Then Save & Apply
4. Next, just restart Chilli and Freeradius
    * ```/etc/init.d/chilli/restart```
    * ```/etc/init.d/radiusd restart```
5. Now Reconnect Device :)
---
Database Information
* MySQL For Admin DB Username = ```root``` & Password = ```radius```
* MySQL For Radius DB Username = ```radius``` Password = ```radius```
---
Information
* 192.168.1.1 | user: root | password: rtawrt

---
* SSID: RTA-WRT_2g / RTA-WRT_5g
* Modemmanager with auto-reconnect,
* Openclash with latest beta release and latest MetaCubeX Mihomo core,
* Passwall as alternate tunneling app,
* TinyFm file manager,
* Internet Detector and Lite Watchdog,
* Argon Theme with some cool custom login image,
* 3ginfo lite and Modeminfo, sms-tool, and other modem support app,
* OLED Display support (only Raspberrry Pi 4B tested),
* etc~
---
Preview
---


* Login View
<p align="center">
    <img src="/pictures/Login.png">
</p>

* Main View
<p align="center">
    <img src="/pictures/Status.png">
</p>
