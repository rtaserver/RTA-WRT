<?php
/*
*******************************************************************************************************************
* Warning!!!, Tidak untuk diperjual belikan!, Cukup pakai sendiri atau share kepada orang lain secara gratis
*******************************************************************************************************************
* Dibuat oleh @Maizil https://t.me/maizil41
*******************************************************************************************************************
* © 2024 Mutiara-Net By @Maizil
*******************************************************************************************************************
*/

// Koneksi ke database
$servername = "127.0.0.1";
$username = "radius";
$password = "radius";
$dbname = "radius";

$conn = new mysqli($servername, $username, $password, $dbname);

if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

// Query untuk mendapatkan username yang berupa MAC address dari radpostauth, radcheck, dan radacct
$sql_mac = "
SELECT DISTINCT username
FROM (
    SELECT username 
    FROM radpostauth 
    WHERE username REGEXP '^[0-9A-Fa-f]{2}([-:]?)[0-9A-Fa-f]{2}([-:]?)[0-9A-Fa-f]{2}([-:]?)[0-9A-Fa-f]{2}([-:]?)[0-9A-Fa-f]{2}([-:]?)[0-9A-Fa-f]{2}$'
    UNION
    SELECT username 
    FROM radcheck 
    WHERE username REGEXP '^[0-9A-Fa-f]{2}([-:]?)[0-9A-Fa-f]{2}([-:]?)[0-9A-Fa-f]{2}([-:]?)[0-9A-Fa-f]{2}([-:]?)[0-9A-Fa-f]{2}([-:]?)[0-9A-Fa-f]{2}$'
    UNION
    SELECT username 
    FROM radacct 
    WHERE username REGEXP '^[0-9A-Fa-f]{2}([-:]?)[0-9A-Fa-f]{2}([-:]?)[0-9A-Fa-f]{2}([-:]?)[0-9A-Fa-f]{2}([-:]?)[0-9A-Fa-f]{2}([-:]?)[0-9A-Fa-f]{2}$'
) AS mac_usernames;
";

$result_mac = $conn->query($sql_mac);

if (!$result_mac) {
    die("Query failed: " . $conn->error);
}

$options = array();
$options['data'] = array(); // Menggunakan 'data' untuk menyimpan hasil

if ($result_mac->num_rows > 0) {
    while($row = $result_mac->fetch_assoc()) {
        $options['data'][] = array(
            'mac_address' => $row['username']
        );
    }
}

$conn->close();

// Menetapkan header konten JSON
header('Content-Type: application/json');

// Mengeluarkan data dalam format JSON
echo json_encode($options);
?>
