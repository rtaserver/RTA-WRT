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
<!DOCTYPE html>
<html>
<head>
<title id="title"></title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<meta name="theme-color" content="#3B5998" />
<meta name="viewport" content="width=device-width; initial-scale=1.0; maximum-scale=1.0;"/>
<link rel="stylesheet" href="assets/style.css">
<style>.frame img {width: 100%;height: auto;}</style>
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

    $mac_address = $conn->real_escape_string($_GET['mac']);
    
    $query = "SELECT acctinputoctets, acctoutputoctets, framedipaddress, callingstationid
              FROM radacct
              WHERE callingstationid = '$mac_address'
                AND acctstoptime IS NULL
              ORDER BY acctstarttime DESC
              LIMIT 1;";
    
    $result = $conn->query($query);

    $data = array();

    $sqlUser = "SELECT username FROM radacct
    WHERE callingstationid = '$mac_address'
                AND acctstoptime IS NULL
              ORDER BY acctstarttime DESC
              LIMIT 1;";
              
    $resultUser = mysqli_fetch_assoc(mysqli_query($conn, $sqlUser));
    $user = $resultUser['username'];
    
    $sqlSession = "SELECT acctsessiontime FROM radacct
    WHERE username = '$user'
                AND acctstoptime IS NULL
              ORDER BY acctstarttime DESC
              LIMIT 1;";
              
    $resultSession = mysqli_fetch_assoc(mysqli_query($conn, $sqlSession));
    $Session = $resultSession['acctsessiontime'];
    
    $sqlTerpakai = "SELECT username, 
           SUM(acctsessiontime) AS total_acctsessiontime
    FROM radacct WHERE username = '$user';";
    
    $resultTerpakai = mysqli_fetch_assoc(mysqli_query($conn, $sqlTerpakai));
    $Terpakai = $resultTerpakai['total_acctsessiontime'];
    
    $sqlTotalSession = "SELECT ug.username, rc.value AS max_all_session
    FROM radusergroup ug
    JOIN radgroupcheck rc ON ug.groupname = rc.groupname
    WHERE ug.username = '$user'
    AND rc.attribute = 'Max-All-Session';";
              
    $resultTotalSession = mysqli_fetch_assoc(mysqli_query($conn, $sqlTotalSession));
    if (is_array($resultTotalSession) && isset($resultTotalSession['max_all_session'])) {
        $totalSession = $resultTotalSession['max_all_session'];
    } else {
        $totalSession = 0;
    }
    
    $sqlTotalKuota = "SELECT VALUE AS total_kuota
    FROM radgroupreply
    WHERE ATTRIBUTE = 'ChilliSpot-Max-Total-Octets'
      AND GROUPNAME = (
        SELECT GROUPNAME
        FROM radusergroup
        WHERE USERNAME = '$user'
      )";

    $resultTotalKuota = mysqli_fetch_assoc(mysqli_query($conn, $sqlTotalKuota));
    if (is_array($resultTotalKuota) && isset($resultTotalKuota['total_kuota'])) {
        $totalKuota = $resultTotalKuota['total_kuota'];
    } else {
        $totalKuota = 0;
    }
            
    $sqlKuotaDigunakan = "SELECT SUM(acctinputoctets + acctoutputoctets) as kuota_terpakai FROM radacct WHERE username = '$user';";
    $resultKuotaDigunakan = mysqli_fetch_assoc(mysqli_query($conn, $sqlKuotaDigunakan));
    $KuotaDigunakan = $resultKuotaDigunakan['kuota_terpakai'];
    
    $expiryTime = $totalSession - $Terpakai;

    $sisaKuota = $totalKuota - $KuotaDigunakan;
    
    if ($result->num_rows > 0) {
        while ($row = $result->fetch_assoc()) {
            $username = $user;
            $userUpload = toxbyte($row['acctinputoctets']);
            $userDownload = toxbyte($row['acctoutputoctets']);
            $userTraffic = toxbyte($row['acctoutputoctets'] + $row['acctinputoctets']);
            $userKuota = toxbyte($sisaKuota);
            $userOnlineTime = time2str($Session);
            echo "<script>var initialSessionTime = $Session;</script>";
            $userExpired = sisa($expiryTime);
            $userIPAddress = $row['framedipaddress'];
            $userMacAddress = $row['callingstationid'];
            
            $data[] = array(
                'username' => $username,
                'userIPAddress' => $userIPAddress,
                'userMacAddress' => $userMacAddress,
                'userDownload' => $userDownload,
                'userUpload' => $userUpload,
                'userTraffic' => $userTraffic,
                'userKuota' => $userKuota,
                'userOnlineTime' => $userOnlineTime,
                'userExpired' => $userExpired,
            );
        }
    }

    $conn->close();
           
            foreach ($data as $row) {
                    echo '<div style="margin-top:20px; text-align: center;"><h3>Welcome</h3><i style="font-size:50px;" class="icon icon-user-circle-o">&#xf2be;</i> <h2 id="user">' . $row['username'] . '</h2></div><br>';
                    echo '<table class="table2">';
                    echo '<br/>';
                    echo '<tr><td align="right" style="width: 40%;">IP Address <i class="icon icon-sitemap">&#xf0e8;</i></td><td>' . $row['userIPAddress'] . '</td></tr>';
                    echo '<tr><td align="right">MAC Address <i class="icon icon-barcode">&#xe80a;</i></td><td>' . $row['userMacAddress'] . '</td></tr>';
                    echo '<tr><td align="right">Upload <i class="icon icon-upload">&#xe808;</i></td><td><div id="upload">' . $row['userUpload'] . '</td></tr>';
                    echo '<tr><td align="right">Download <i class="icon icon-download">&#xe809;</i></td><td><div id="download">' . $row['userDownload'] . '</td></tr>';
                    echo '<tr><td align="right">Total Traffic <i class="icon icon-exchange">&#xf0ec;</i></td><td><div id="traffic">' . $row['userTraffic'] . '</td></tr>';
                    echo '<tr><td align="right">Terkoneksi <i class="icon icon-clock">&#xe805;</i></td><td><div id="aktif"><?php echo $userOnlineTime; ?></div></td></tr>';
if ($totalSession >= 1) {
                    echo '<tr><td align="right">Sisa Waktu <i class="icon icon-clock">&#xe805;</i></td><td><div id="expired">' . $row['userExpired'] . '</td></tr>';
}
if ($totalKuota >= 1) {
                    echo '<tr><td align="right">Sisa Kuota <i class="icon icon-clock">&#xf252;</i></td><td><div id="kuota">' . $row['userKuota'] . '</td></tr>';
}
                    echo '</table>';
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
	
	function time2str($time) {

	$str = "";
	$time = floor($time);
	if (!$time)
		return "0 Detik";
	$d = $time/86400;
	$d = floor($d);
	if ($d){
		$str .= "$d Hari, ";
		$time = $time % 86400;
	}
	$h = $time/3600;
	$h = floor($h);
	if ($h){
		$str .= "$h Jam, ";
		$time = $time % 3600;
	}
	$m = $time/60;
	$m = floor($m);
	if ($m){
		$str .= "$m Menit, ";
		$time = $time % 60;
	}
	if ($time)
		$str .= "$time Detik, ";
	$str = preg_replace("/, $/",'',$str);
	return $str;

}

	function sisa($time) {

	$str = "";
	$time = floor($time);
	if (!$time)
		return "Unlimited";
	$d = $time/86400;
	$d = floor($d);
	if ($d){
		$str .= "$d Hari ";
		$time = $time % 86400;
	}
	$h = $time/3600;
	$h = floor($h);
	if ($h){
		$str .= "$h Jam ";
		$time = $time % 3600;
	}
	$m = $time/60;
	$m = floor($m);
	if ($m){
		$str .= "$m Menit ";
		$time = $time % 60;
	}
	if ($time)
	$str = preg_replace("/, $/",'',$str);
	return $str;

}
?>



<br>

</form>
</div>
<script type="text/javascript">
    document.getElementById('title').innerHTML = window.location.hostname + " > status";
</script>
<script src="assets/js/jquery-3.6.3.min.js"></script>
<script>
    $(document).ready(function () {
        setInterval(function(){
            $("#download").load(window.location.href + " #download");
            $("#upload").load(window.location.href + " #upload");
            $("#traffic").load(window.location.href + " #traffic");
            $("#expired").load(window.location.href + " #expired");
            $("#kuota").load(window.location.href + " #kuota");
        },1000);
    });
</script>
<script>
    function updateSessionTime(seconds) {
        var d = Math.floor(seconds / (3600*24));
        var h = Math.floor(seconds % (3600*24) / 3600);
        var m = Math.floor(seconds % 3600 / 60);
        var s = Math.floor(seconds % 60);

        var timeString = 
            (d > 0 ? d + " hari, " : "") +
            (h > 0 ? h + " jam, " : "") +
            (m > 0 ? m + " menit, " : "") +
            (s > 0 ? s + " detik" : "");

        return timeString;
    }

    function startTimer(initialTime) {
        var currentTime = initialTime;

        setInterval(function() {
            currentTime++;
            document.getElementById('aktif').innerText = updateSessionTime(currentTime);
        }, 1000);
    }

    // Start the timer with the initial session time from PHP
    startTimer(initialSessionTime);
</script>
</body>
</html>
