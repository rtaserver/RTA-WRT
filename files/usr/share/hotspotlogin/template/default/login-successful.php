<!DOCTYPE html>
<html>
<head>
<title id="title"></title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<meta name="theme-color" content="#3B5998" />
<meta name="viewport" content="width=device-width; initial-scale=1.0; maximum-scale=1.0;"/>
<link rel="stylesheet" href="assets/style.css">
   <style>
        body {
        color: #fff;
        font-family: Arial, sans-serif;
        background-image: url("background.avif");
        background-size: cover;
        background-position: auto;
        }
    </style>
<script language="JavaScript">

function updateData() {
location.reload();
}
setInterval(updateData, 5000);

</script>

</head>
</br><br>
<div class="main">
<form action="http://10.10.10.1:3990/logoff" name="logout" onSubmit="return openLogout()">


<?php
	    if (isset($_GET['mac'])) {
            $servername = "127.0.0.1";
            $username = "radius";
            $password = "radius";
            $dbname = "radius";

            $conn = new mysqli($servername, $username, $password, $dbname);

        if ($conn->connect_error) {
            die("Koneksi database gagal: " . $conn->connect_error);
            }

            $mac_address = $_GET['mac'];
			$query = "SELECT username, AcctStartTime,CASE WHEN AcctStopTime is NULL THEN timestampdiff(SECOND,AcctStartTime,NOW()) ELSE AcctSessionTime END AS AcctSessionTime,
					NASIPAddress,CalledStationId,FramedIPAddress,CallingStationId,AcctInputOctets,AcctOutputOctets 
					FROM radacct
					WHERE callingstationid = '$mac_address' ORDER BY RadAcctId DESC LIMIT 1";

            $result = $conn->query($query);

            $data = array();

            $sqlUser = "SELECT username FROM radacct WHERE callingstationid='$mac_address' ORDER BY acctstarttime DESC LIMIT 1;";
            $resultUser = mysqli_fetch_assoc(mysqli_query($conn, $sqlUser));
            $user = $resultUser['username'];
                    
            $sqlTotalSession = "SELECT g.value as total_session FROM radgroupcheck as g, radusergroup as u WHERE u.username = '$user' AND g.groupname = u.groupname AND g.attribute ='Max-All-Session';";
            $resultTotalSession = mysqli_fetch_assoc(mysqli_query($conn, $sqlTotalSession));
            $totalSession = $resultTotalSession['total_session'];

            $sqlTotalKuota = "SELECT h.value as total_kuota FROM radgroupreply as h, radusergroup as i WHERE i.username = '$user' AND h.groupname = i.groupname AND h.attribute ='ChilliSpot-Max-Total-Octets';";
            $resultTotalKuota = mysqli_fetch_assoc(mysqli_query($conn, $sqlTotalKuota));
            $totalKuota = $resultTotalKuota['total_kuota'];
            
            $sqlOctetsDigunakan = "SELECT SUM(acctinputoctets + acctoutputoctets) as total_octets FROM radacct WHERE username = '$user';";
            $resultOctetsDigunakan = mysqli_fetch_assoc(mysqli_query($conn, $sqlOctetsDigunakan));
            $octetsDigunakan = $resultOctetsDigunakan['total_octets'];

            $sqlFirstLogin = "SELECT acctstarttime AS first_login FROM radacct WHERE username='$user' ORDER BY acctstarttime ASC LIMIT 1;";
            $resultFirstLogin = mysqli_fetch_assoc(mysqli_query($conn, $sqlFirstLogin));
            $firstLogin = $resultFirstLogin['first_login'];

            $duration = $totalSession - 25200;
            $expiryTime = strtotime($firstLogin) + $duration;
            
            $kuotatotal = strtotime($firstLogin) + $totalKuota;
            $kuotaUtama = $kuotatotal - 1702887424;
            $sisaKuota = $kuotaUtama - $octetsDigunakan;

            $remainingTime = $expiryTime - time();

        if ($result->num_rows > 0) {
            while ($row = $result->fetch_assoc()) {

                $username = $row['username'];
                $userUpload = toxbyte($row['AcctInputOctets']);
				$userDownload = toxbyte($row['AcctOutputOctets']);
				$userTraffic = toxbyte($row['AcctOutputOctets'] + $row['AcctInputOctets']);
				$userLastConnected = $row['AcctStartTime'];
				$userOnlineTime = time2str($row['AcctSessionTime']);
				$nasIPAddress = $row['NASIPAddress'];
				$nasMacAddress = $row['CalledStationId'];
				$userIPAddress = $row['FramedIPAddress'];
				$userMacAddress = $row['CallingStationId'];
				$userExpired = time2str($remainingTime);
				$UserKuota = toxbyte($sisaKuota);

                $data[] = array(
                'username' => $username,
                'userIPAddress' => $userIPAddress,
                'userMacAddress' => $userMacAddress,
                'userDownload' => $userDownload,
                'userUpload' => $userUpload,
                'userTraffic' => $userTraffic,
				'userLastConnected' => $userLastConnected,
                'userOnlineTime' => $userOnlineTime,
                'userExpired' => $userExpired,
                'userKuota' => $UserKuota,
                );
            }
        }

                $conn->close();
           
            foreach ($data as $row) {
                echo '<div style="margin-top:20px; text-align: center;"><h3>Welcome</h3><i style="font-size:50px;" class="icon icon-user-circle-o">&#xf2be;</i> <h2 id="user">' . $row['username'] . '</h2></div><br>';
                echo '<table class="table2">';
                echo '<br/>';
                echo '<tr><td align="right" style="width: 40%;">IP Address <i class="icon icon-sitemap">&#xf0e8;</i> </td><td>' . $row['userIPAddress'] . '</td></tr>';
                echo '<tr><td align="right">MAC Address <i class="icon icon-barcode">&#xe80a;</i> </td><td>' . $row['userMacAddress'] . '</td></tr>';
                echo '<tr><td align="right">Upload <i class="icon icon-upload">&#xe808;</i> </td><td>' . $row['userUpload'] . '</td></tr>';
                echo '<tr><td align="right">Download <i class="icon icon-download">&#xe809;</i> </td><td>' . $row['userDownload'] . '</td></tr>';
                echo '<tr><td align="right">Total Traffic <i class="icon icon-exchange">&#xf0ec;</i> </td><td>' . $row['userTraffic'] . '</td></tr>';
                echo '<tr><td align="right">Terkoneksi <i class="icon icon-clock">&#xe805;</i> </td><td>' . $row['userOnlineTime'] . '</td></tr>';
if ($duration <= 8640000) {
                echo '<tr><td align="right">Sisa Waktu <i class="icon icon-clock">&#xe805;</i> </td><td>' . $row['userExpired'] . '</td></tr>';
}
if ($totalKuota <= 536870912000) {
                echo '<tr><td align="right">Sisa Kuota <i class="icon icon-clock">&#xf252;</i> </td><td>' . $row['userKuota'] . '</td></tr>';
}
                echo '</table>';
                echo '<br/>';
                echo '<br/>';
                echo '<button class="button2" type="submit"><i class="icon icon-logout">&#xe804;</i> Logout</button>';
                echo '</div>';
            }
        }


    function toxbyte($size)
	{
        // Gigabytes
        if ( $size > 1073741824 )
        {
                $ret = $size / 1073741824;
                $ret = round($ret,2)." GB";
                return $ret;
        }

        // Megabytes
        if ( $size > 1048576 )
        {
                $ret = $size / 1048576;
                $ret = round($ret,2)." MB";
                return $ret;
        }

        // Kilobytes
        if ($size > 1024 )
        {
                $ret = $size / 1024;
                $ret = round($ret,2)." KB";
                return $ret;
        }

        // Bytes
        if ( ($size != "") && ($size <= 1024 ) )
        {
                $ret = $size." B";
                return $ret;
        }
	}
	
	// function taken from dialup_admin
	function time2str($time) {

	$str = "";				// initialize variable
	$time = floor($time);
	if (!$time)
		return "0 detik";
	$d = $time/86400;
	$d = floor($d);
	if ($d){
		$str .= "$d hari, ";
		$time = $time % 86400;
	}
	$h = $time/3600;
	$h = floor($h);
	if ($h){
		$str .= "$h jam, ";
		$time = $time % 3600;
	}
	$m = $time/60;
	$m = floor($m);
	if ($m){
		$str .= "$m menit, ";
		$time = $time % 60;
	}
	if ($time)
		$str .= "$time detik, ";
	$str = preg_replace("/, $/",'',$str);
	return $str;

}
?>



<br>

</form>
</div>
<script type="text/javascript">
    document.getElementById('title').innerHTML = window.location.hostname + " > status";
//get vaidity
/*
    var usr = document.getElementById('user').innerHTML
    var url = "https://example.com/status/status.php?name="; // http://ip-server-mikhmon/mikhmonv2/status/status.php?name=
    var SessionName = "wifijoss"
    var getvalid = url+usr+"&session="+SessionName
    document.getElementById('exp').src = getvalid;
*/
</script>
</body>
</html>
