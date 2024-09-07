<?php
echo <<<END
<!doctype html>
<html lang="en">

<head>
    <title id="title"></title>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
    <meta name="theme-color" content="#3B5998" />
    <meta name="viewport" content="width=device-width; initial-scale=1.0; maximum-scale=1.0;" />
    <link rel="icon" type="image" href="favicon.ico" sizes="32x32">
    <link rel="stylesheet" href="assets/style.css">
   <style>
        .frame img {
            width: 100%;
            height: auto;
        }
        body {
            color: #fff;
            font-family: Arial, sans-serif;
            background-image: url("background.avif");
            background-size: cover;
            background-position: auto;
        }
    </style>
<body>
            <div id="main" class="main">
            
            <div class="box">
                <h3 class="brand">MUTIARA-NET</h3>
            </div>
            <div class="box">
                <button id="btnvrc" class="small-button" onclick="voucher();"><i class="icon icon-ticket">&#xe802;</i> Voucher</button>
                <button id="btnmem" class="small-button" onclick="member()"><i class="icon icon-user-circle-o">&#xf2be;</i> Member</button>
                <button id="qr" class="small-button" onclick="window.location='https://laksa19.github.io/myqr';"> <i class="icon icon-qrcode">&#xe801;</i> QR Code</button>
            </div>
            <div class="box" id="infologin">
            </div>
            <form autocomplete="off" name="login" action="$loginpath" method='post' name='Login_Form' class='animated-input'>

                <input type="hidden" name="dst" value="$(link-orig)" />
                <input type="hidden" name="popup" value="true" />
                <input class="username" name="username" type="hidden" value="$(username)"/>

                <form action='$loginpath' method='post' name='Login_Form' class='animated-input'>
                <input type='hidden' name='uamip' value='$uamip'>
                <input type='hidden' name='uamport' value='$uamport'>
                <input type='hidden' name='button' value='Login'>

                <input class="username" name="UserName" type="text" id='idusr' class="form-control" placeholder="Kode Voucher" required="" autofocus=""/>
                <input class="password" name="password" type="hidden" id="pass" class="form-control" placeholder="Password Member" required="" autofocus=""/>
                
                <button class="button" onClick='\'javascript:popUp('$loginpath?res=popup1&uamip=$uamip&uamport=$uamport')\'><i class="icon icon-login">&#xe803;</i> Login</button>

                <table class="table">
                    <tr>
                        <th>Paket</th>
                        <th>Speed</th>
                        <th>Harga</th>
						
                    </tr>
                    <tr>
                        <td>3 Jam</td>
                        <td>2M/1M</td>
                        <td>Rp.1000</td>
                    </tr>
					<tr>
                        <td>6 Jam</td>
                        <td>2M/1M</td>
                        <td>Rp.2000</td>
                    </tr>
					<tr>
                        <td>1 Hari</td>
                        <td>2M/1M</td>
                        <td>Rp.5000</td>
					</tr>
					<tr>
                        <td>7 Hari</td>
                        <td>2M/1M</td>
                        <td>Rp.25000</td>
                    </tr>
                </table>
                <br/>
                <div class="frame">
                <img src="daloradius.png" alt="logo">
                Voucher bisa dibeli melalui<br>
                Whatsapp : <a href="https://wa.me/+6285372687484" style="text-decoration: underline; color:#000;">0853-7268-7484<br></a>
        </div>
        </div>
<script type="text/javascript">
var hostname = window.location.hostname;
document.getElementById('title').innerHTML = hostname  + " > login";

document.login.username.focus();

var infologin = document.getElementById('infologin');
infologin.innerHTML = "Masukkan Kode Voucher<br>kemudian klik login";

// login page 2 mode by Laksamadi Guko
var username = document.login.username;
var password = document.login.password;

username.placeholder = "Kode Voucher";

// set password = username
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
    password.type = "password";
    infologin.innerHTML = "Masukkan Username dan Password<br>kemudian klik login.";
}
</script>
</body>

</html>


END;


?>