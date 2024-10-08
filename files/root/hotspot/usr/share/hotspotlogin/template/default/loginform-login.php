<?php
/*
 *********************************************************************************************************
 * Hotspotlogin daloRADIUS by Maizil https://t.me/maizil41
 * This program is free and not for sale. If you want to sell one, make your own, don't take someone else's work.
 * Don't change what doesn't need to be changed, please respect others' work
 * Copyright (C) 2024 - Mutiara-Wrt by <@maizil41>. 
 *********************************************************************************************************
*/ 
echo <<<END
<!doctype html>
<html lang="en">

<head>
    <title id="title"></title>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
    <meta name="theme-color" content="#3B5998" />
    <meta name="viewport" content="width=device-width; initial-scale=1.0; maximum-scale=1.0;" />
    <link rel="icon" type="image" href="assets/images/favicon.svg" sizes="32x32">
    <link rel="stylesheet" href="assets/style.css">
    <style> .frame img {width: 100%;height: auto;}</style>
<body>
            <div id="main" class="main">
            
            <div class="box">
            <div class="frame">
            <img src="assets/images/mutiara.png" alt="logo"><br>
            </div>
            <div class="box">
                <button id="btnvrc" class="small-button1" onclick="voucher();"><i class="icon icon-ticket">&#xe802;</i> Voucher</button>
                <button id="btnmem" class="small-button" onclick="member()"><i class="icon icon-user-circle-o">&#xf2be;</i> Member</button>
                <button id="qr" class="small-button3" onclick="window.location='https://maizil41.github.io/scanner';"> <i class="icon icon-qrcode">&#xe801;</i> QR Code</button>
            </div>
            <div class="box" id="infologin">
            </div>
            <form autocomplete="off" name="login" action="$loginpath" method='post' name='Login_Form' class='animated-input'>

                <input type="hidden" name="dst" value="$(link-orig)" />
                <input type="hidden" name="popup" value="true" />
                <input class="username" name="username" type="hidden" value="$(username)"/>

                <form action='$loginpath' method='post' name='Login_Form'>
                <input type='hidden' name='challenge' value='$challenge'>
                <input type='hidden' name='uamip' value='$uamip'>
                <input type='hidden' name='uamport' value='$uamport'>
                <input type='hidden' name='userurl' value='$userurl'>

                <input class="username" name="UserName"type='text' id='user' class='form-use' name='UserName' placeholder='Username' required='' autofocus=''/><br>
                <input type='hidden' id='pass' class='password' name='Password' placeholder='Password' required='' autofocus=''/>
                
                <input type='hidden' name='button' value='Login'>
                <button class='login-button onClick=\'javascript:popUp('$loginpath?res=popup1&uamip=$uamip&uamport=$uamport')\'><i class="icon icon-login">&#xe807;</i>MASUK</button>
                <button class='login-button' onclick='handleButtonClick()' id='trialButton'><i class="icon icon-login">&#xe803;</i>GRATIS</button>
            </form>
            <b>

                <table class="table">
                    <tr>
                        <th>Paket</th>
                        <th>Aktif</th>
                        <th>Harga</th>
						
                    </tr>
					<tr>
                        <td>Gratis</td>
                        <td>5 Menit</td>
                        <td>Rp.0</td>
					</tr>
					<tr>
                        <td>3 Jam</td>
                        <td>3 Jam</td>
                        <td>Rp.1000</td>
					</tr>
					<tr>
                        <td>Harian</td>
                        <td>1 Hari</td>
                        <td>Rp.5000</td>
					</tr>
					<tr>
                        <td>Mingguan</td>
                        <td>7 Hari</td>
                        <td>Rp.20000</td>
                    </tr>
					<tr>
                        <td>Bulanan</td>
                        <td>30 Hari</td>
                        <td>Rp.50000</td>
                    </tr>
                </table>
                <br/>
                <div class="frame">
                Voucher bisa dibeli melalui<br>
                Whatsapp : <a href="https://wa.me/+6285372687484" style="text-decoration: underline; color:#000;">0853-7268-7484<br></a>
        </div>
</div>
        
<script type="text/javascript">
var hostname = window.location.hostname;
document.getElementById('title').innerHTML = hostname  + " > login";

document.login.username.focus();

var infologin = document.getElementById('infologin');
infologin.innerHTML = "Masukkan Kode Voucher<br>kemudian klik login.";

var username = document.login.username;
var password = document.getElementById('pass');

username.placeholder = "Kode Voucher";

function setpass() {
    var user = username.value
    user = user.toLowerCase();
    username.value = user;
    password.value = user;
}

username.onkeyup = setpass;

function voucher() {
    username.focus();
    username.onkeyup = setpass;
    username.placeholder = "Kode Voucher";
    username.style = "border-radius:3px;"
    password.type = "hidden";
    infologin.innerHTML = "Masukkan Kode Voucher<br>kemudian klik login.";
}

function member() {
    username.focus();
    username.onkeyup = "";
    username.placeholder = "Username";
    username.style = "border-radius:3px 3px 0px 0px;"
    password.type = "text";
    infologin.innerHTML = "Masukkan Username dan Password<br>kemudian klik login.";
}
</script>
    <script>
        function getCookie(name) {
            var cookies = document.cookie.split(';');
            for (var i = 0; i < cookies.length; i++) {
                var cookie = cookies[i].trim();
                if (cookie.indexOf(name + '=') === 0) {
                    return cookie.substring(name.length + 1, cookie.length);
                }
            }
            return null;
        }

        function setCookie(name, value, days) {
            var expirationDate = new Date();
            expirationDate.setHours(23, 59, 59);
            var cookieValue = name + '=' + value + '; expires=' + expirationDate.toUTCString() + '; path=/';
            document.cookie = cookieValue;
        }

        function handleButtonClick() {
            var userField = document.getElementById('user');
            userField.value = 'TRIAL'; // Ganti 'TRIAL' sesuai dengan username Gratis yg kalian buat
            setCookie('buttonHidden', 'true', 1); // Simpan cookie selama 1 hari
            var trialButton = document.getElementById('trialButton');
            trialButton.style.display = 'none';
        }

        var cookieValue = getCookie('buttonHidden');
        if (cookieValue === 'true') {
            var trialButton = document.getElementById('trialButton');
            trialButton.style.display = 'none';
        }
    </script>
</body>

</html>


END;


?>