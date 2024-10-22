<?php
/*
 *********************************************************************************************************
 * Hotspotlogin daloRADIUS by Maizil https://t.me/maizil41
 * This program is free and not for sale. If you want to sell one, make your own, don't take someone else's work.
 * Don't change what doesn't need to be changed, please respect others' work
 * Copyright (C) 2024 - Mutiara-Wrt by <@maizi41>. 
 *********************************************************************************************************
*/ 
?>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html>
<head>
  <title>Mutiara-Wrt</title>
  <script type="text/javascript" language="Javascript">
  //<!--
  function getURLParam(name) {
    var params = new URLSearchParams(window.location.search);
    return params.get(name);
  }

  var loginUrl = 'http://10.10.10.1:3990/prelogin';
  function redirect() { 
    if (loginUrl) {
      window.location = loginUrl; 
    } else {
      console.error('Login URL is not defined.');
    }
    return false; 
  }

  window.onload = function() {
    var paramUrl = getURLParam("loginurl");
    if (paramUrl) {
      loginUrl = paramUrl;
    }
    setTimeout(redirect, 5000); 
  }
  //-->
  </script>
</head>
<body style="margin: 0pt auto; height:100%;">
  <div style="width:100%;height:80%;position:fixed;display:table;">
    <p style="display: table-cell; line-height: 2.5em; vertical-align:middle; text-align:center; color:grey;">
      <a href="#" onclick="javascript:return redirect();">
        <img src="assets/images/mutiara.png" alt="" border="0" height="50" width="150"/>
      </a><br>
      <small><img src="assets/images/wait.gif"/> redirecting...</small>
    </p>
    <br><br>
  </div>
</body>
</html>
