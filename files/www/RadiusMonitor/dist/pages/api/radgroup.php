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

// Cek koneksi
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

// Query untuk mengambil data yang ada di ketiga tabel
$sql_combined = "
    SELECT DISTINCT planName FROM billing_plans
    WHERE planName IN (
        SELECT DISTINCT groupname FROM radgroupcheck
        INTERSECT
        SELECT DISTINCT groupname FROM radgroupreply
    )
";

// Eksekusi query
$result_combined = $conn->query($sql_combined);

$options = array();
$options['plans'] = array();

// Ambil data yang valid dari query gabungan
if ($result_combined->num_rows > 0) {
    while($row = $result_combined->fetch_assoc()) {
        $options['plans'][] = $row;
    }
}

$conn->close();

// Mengembalikan data dalam format JSON
echo json_encode($options);
?>