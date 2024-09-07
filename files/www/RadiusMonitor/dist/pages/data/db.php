<?php
$servername = "127.0.0.1"; // Ubah sesuai dengan host database
$username = "radius"; // Ubah dengan username database
$password = "radius"; // Ubah dengan password database
$dbname = "radius"; // Ubah dengan nama database yang ingin digunakan

// Buat koneksi
$conn = new mysqli($servername, $username, $password, $dbname);

// Periksa koneksi
if ($conn->connect_error) {
    die("Koneksi gagal: " . $conn->connect_error);
}

?>