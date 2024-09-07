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
?>
<?php
// Koneksi ke database
$servername = "127.0.0.1";
$username = "radius";
$password = "radius";
$dbname = "radius";

$conn = new mysqli($servername, $username, $password, $dbname);

if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

// Query untuk mendapatkan name, rate_down, dan rate_up
$sql_bw = "SELECT DISTINCT name, rate_down, rate_up FROM bandwidth";
$result_bw = $conn->query($sql_bw);

if (!$result_bw) {
    die("Query failed: " . $conn->error);
}

$options = array();
$options['data'] = array(); // Menggunakan 'data' untuk menyimpan hasil

if ($result_bw->num_rows > 0) {
    while($row = $result_bw->fetch_assoc()) {
        $options['data'][] = array(
            'bw_name' => $row['name'],
            'rate_down' => $row['rate_down'],
            'rate_up' => $row['rate_up']
        );
    }
}

$conn->close();

// Menetapkan header konten JSON
header('Content-Type: application/json');

// Mengeluarkan data dalam format JSON
echo json_encode($options);
?>