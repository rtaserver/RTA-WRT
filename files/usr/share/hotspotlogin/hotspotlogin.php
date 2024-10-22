<?php
#
# chilli - ChilliSpot.org. A Wireless LAN Access Point Controller
# Copyright (C) 2003, 2004 Mondru AB.
#
# The contents of this file may be used under the terms of the GNU
# General Public License Version 2, provided that the above copyright
# notice and this permission notice is included in all copies or
# substantial portions of the software.

# Redirects from ChilliSpot daemon:
#
# Redirection when not yet or already authenticated
#   notyet:  ChilliSpot daemon redirects to login page.
#  already: ChilliSpot daemon redirects to success status page.
#
# Response to login:
#   already: Attempt to login when already logged in.
#   failed:  Login failed
#   success: Login succeded
#
# logoff:  Response to a logout
#
#/*
# *********************************************************************************************************
# *
# * Authors:     Liran Tal <liran@enginx.com>
# *
# * daloRADIUS edition - fixed up variable definition through-out the code
# * as well as parted the code for the sake of modularity and ability to
# * to support templates and languages easier.
# * Copyright (C) Enginx and Liran Tal 2007, 2008
# *
# *********************************************************************************************************
# */

# Shared secret used to encrypt challenge with. Prevents dictionary attacks.
# You should change this to your own shared secret.
$uamsecret = "mutiara-net";

# Uncomment the following line if you want to use ordinary user-password
# for radius authentication. Must be used together with $uamsecret.
# pap or mschapv2
$userpassword="pap";

# Define your template here
$template_name = "default";
$language = "en";

# Our own path
$loginpath = $_SERVER['PHP_SELF'];

if(empty($template_name)) $template_name = "default";
if (file_exists("template/".$template_name)) {
    $template = $template_name;
} else {
    $template =  "default";
}

include('util/password.php');

include('lang/main.php');

#/* if SSL was not used show an error */
#if (!($_SERVER['HTTPS'] == 'on')) {
#include('hotspotlogin-nonssl.php');
#exit(0);
#}

# Read form parameters which we care about
if (isset($_POST['UserName']))    
	$username    = $_POST['UserName'];
elseif (isset($_GET['UserName']))
	$username    = $_GET['UserName'];
else
	$username    = "";


if (isset($_POST['Password']))    
	$password    = $_POST['Password'];
elseif (isset($_GET['Password']))
	$password    = $_GET['Password'];
else
	$password    = "";


if (isset($_POST['challenge']))    
	$challenge    = $_POST['challenge'];
elseif (isset($_GET['challenge']))    
	$challenge    = $_GET['challenge'];
else
	$challenge    = "";


if (isset($_POST['button']))
    $button        = $_POST['button'];
elseif (isset($_GET['button']))
    $button        = $_GET['button'];
else
    $button        = "";


if (isset($_POST['logout']))
    $logout        = $_POST['logout'];
elseif (isset($_GET['logout']))
    $logout        = $_GET['logout'];
else
    $logout        = "";


if (isset($_POST['prelogin']))    
	$prelogin    = $_POST['prelogin'];
elseif (isset($_GET['prelogin']))    
	$prelogin    = $_GET['prelogin'];
else
	$prelogin    = "";


if (isset($_POST['res']))    
	$res        = $_POST['res'];
elseif (isset($_GET['res']))    
	$res        = $_GET['res'];
else
	$res        = "";


if (isset($_POST['uamip']))
    $uamip        = $_POST['uamip'];
elseif (isset($_GET['uamip']))
    $uamip        = $_GET['uamip'];
else
    $uamip        = "";


if (isset($_POST['uamport']))
    $uamport    = $_POST['uamport'];
elseif (isset($_GET['uamport']))
    $uamport    = $_GET['uamport'];
else
    $uamport    = "";


if (isset($_POST['userurl']))
    $userurl    = $_POST['userurl'];
elseif (isset($_GET['userurl']))
    $userurl    = $_GET['userurl'];
else
    $userurl    = "";


if (isset($_POST['timeleft']))
    $timeleft    = $_POST['timeleft'];
elseif (isset($_GET['timeleft']))
    $timeleft    = $_GET['timeleft'];
else
    $timeleft    = "";


if (isset($_POST['redirurl']))
    $redirurl    = $_POST['redirurl'];
elseif (isset($_GET['redirurl']))
    $redirurl    = $_GET['redirurl'];
else
    $redirurl    = "";


(isset($_GET['reply']))      ? $reply        = $_GET['reply']       : $reply = "";

$userurldecode = $userurl;
$redirurldecode = $redirurl;

# If attempt to login
if ($button == 'Login') {
  $hexchal = pack("H*", $challenge);
  if ($uamsecret) {
    $newchal = pack ("H*", md5($hexchal . $uamsecret));
  } else {
    $newchal = $hexchal;
  }
  $newpwd = pack("a32", $password);

  $response = md5("\0" . $password . $newchal);
  $pappassword = implode ("", unpack("H32", ($newpwd ^ $newchal)));

  //$pappassword = getEncryptedPasswordPAP($password, $uamsecret, $challenge);
  //$response = getEncryptedPasswordOther($password, $uamsecret, $challenge);

    echo "<!doctype html>
    <html lang=\"en\">
    <head>
    <!-- Required meta tags -->
    <meta charset=\"utf-8\">
    <meta name=\"viewport\" content=\"width=device-width, initial-scale=1, shrink-to-fit=no\">
    
  <title>$title</title>
  <meta http-equiv=\"Cache-control\" content=\"no-cache\">
  <meta http-equiv=\"Pragma\" content=\"no-cache\">
  <meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\" />
  <link rel=\"stylesheet\" href=\"css/bootstrap.min.css\" integrity=\"sha384-Gn5384xqQ1aoWXA+058RXPxPg6fy4IWvTNh0E263XmFcJlSAwiGgFAW/dAiS6JXm\" crossorigin=\"anonymous\">"
  ;
  
    if (file_exists("assets/css/style.css")) {
        echo "<link href=\"assets/css/style.css\" rel=\"stylesheet\" type=\"text/css\" />";
    }

  if (isset($uamsecret) && isset($userpassword) && $userpassword=="pap" ) {
    echo "  <meta http-equiv=\"refresh\" content=\"0;url=http://$uamip:$uamport/login?username=$username&password=$pappassword\">";
  } else {
    echo "  <meta http-equiv=\"refresh\" content=\"0;url=http://$uamip:$uamport/login?username=$username&response=$response&userurl=$userurl\">";
  }

    echo "</head>";
    echo "<body>";

    include('template/'.$template.'/loggingin.php');

    echo "</body>";
    echo "</html>";

    echo "
<!--
<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<WISPAccessGatewayParam 
  xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\"
  xsi:noNamespaceSchemaLocation=\"http://www.acmewisp.com/WISPAccessGatewayParam.xsd\">
<AuthenticationReply>
<MessageType>120</MessageType>
<ResponseCode>201</ResponseCode>
";
  if (isset($uamsecret) && isset($userpassword) && $userpassword=="pap") {
    echo "<LoginResultsURL>http://$uamip:$uamport/login?username=$username&password=$pappassword</LoginResultsURL>";
  } else {
    echo "<LoginResultsURL>http://$uamip:$uamport/login?username=$username&response=$response&userurl=$userurl</LoginResultsURL>";
  }
  echo "</AuthenticationReply> 
</WISPAccessGatewayParam>
-->
";

    exit(0);
}

switch($res) {
  case 'success':     $result =  1; break; // If login successful
  case 'failed':      $result =  2; break; // If login failed
  case 'logoff':      $result =  3; break; // If logout successful
  case 'already':     $result =  4; break; // If tried to login while already logged in
  case 'notyet':      $result =  5; break; // If not logged in yet
  case 'smartclient': $result =  6; break; // If login from smart client
  case 'popup1':      $result = 11; break; // If requested a logging in pop up window
  case 'popup2':      $result = 12; break; // If requested a success pop up window
  case 'popup3':      $result = 13; break; // If requested a logout pop up window
  default: $result = 0; // Default: It was not a form request
}

/* Testing */
# $result = 1;

/* Otherwise it was not a form request
 * Send out an error message
 */
if ($result == 0) {
	include('template/'.$template.'/hotspotlogin-nonchilli.php');
	exit(0);
}

# Generate the output
#echo "Content-type: text/html\n\n";

# HTML 4
#echo "<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01 Transitional//EN\">
#<html>

# HTML5 doctype
echo "<!doctype html>
<html lang=\"en\">
<head>
    <!-- Required meta tags -->
    <meta charset=\"utf-8\">
    <meta name=\"viewport\" content=\"width=device-width, initial-scale=1, shrink-to-fit=no\">


  <title>$title</title>
  <meta http-equiv=\"Cache-control\" content=\"no-cache\">
  <meta http-equiv=\"Pragma\" content=\"no-cache\">
  <meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\" />
  <link rel=\"stylesheet\" href=\"css/bootstrap.min.css\" integrity=\"sha384-Gn5384xqQ1aoWXA+058RXPxPg6fy4IWvTNh0E263XmFcJlSAwiGgFAW/dAiS6JXm\" crossorigin=\"anonymous\">
  
  ";
  
    if (file_exists("assets/css/style.css")) {
        echo "<link href=\"assets/css/style.css\" rel=\"stylesheet\" type=\"text/css\" />";
    }
  
    if (file_exists("template/".$template."/js/style.js")) {
        echo "<script src=\"template/".$template."/js/style.js\" ></script>";
    }
  
  echo "<script language=\"javascript\">";
    include('js/hotspotlogin.js');
  echo "</script>";

echo "</head>";
//echo "<body onLoad=\"javascript:doOnLoad($result, '$loginpath?res=popup2&uamip=$uamip&uamport=$uamport&userurl=$userurl&redirurl=$redirurl&timeleft=$timeleft','$userurldecode', '$redirurldecode', '$timeleft')\" onBlur = 'javascript:doOnBlur($result)' >";
echo "<body onBlur = 'javascript:doOnBlur($result)' >";
if ($result == 2) {
    include('template/'.$template.'/login-failed-notification.php');
}

if ($result == 2 || $result == 5) {
	include('template/'.$template.'/loginform-header.php');
	include('template/'.$template.'/loginform-login.php');
	include('template/'.$template.'/loginform-footer.php');
}

if ($result == 1) {
    include('template/'.$template.'/login-successful.php');
}

if (($result == 4) || ($result == 12)) {
    include('template/'.$template.'/logoff.php');
}


if ($result == 11) {
        include('template/'.$template.'/loggingin-popup.php');
}


if (($result == 3) || ($result == 13)) {
    include('template/'.$template.'/prelogin.php');
}



//var_dump($_POST);
//var_dump($_GET);

echo "<script src=\"js/jquery-3.2.1.slim.min.js\" integrity=\"sha384-KJ3o2DKtIkvYIK3UENzmM7KCkRr/rE9/Qpg6aAZGJwFDMVNA/GpGFF93hXpG5KkN\" crossorigin=\"anonymous\"></script>";
echo "<script src=\"js/popper.min.js\" integrity=\"sha384-ApNbgh9B+Y1QKtv3Rn7W3mgPxhU9K/ScQsAP7hUibX39j7fakFPskvXusvfa0b4Q\" crossorigin=\"anonymous\"></script>";
echo "<script src=\"js/bootstrap.min.js\" integrity=\"sha384-JZR6Spejh4U02d8jOt6vLEHfe/JQGiRRSQQxSfFWpi1MquVdAyjUar5+76PVCmYl\" crossorigin=\"anonymous\"></script>";
echo "</body>";
echo "</html>";
exit(0);
