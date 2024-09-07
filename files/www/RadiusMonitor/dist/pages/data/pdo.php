<?php
$dsn = 'mysql:host=127.0.0.1;dbname=radius'; // Ganti dengan nama database Anda
$username = 'radius'; // Ganti dengan username database Anda
$password = 'radius'; // Ganti dengan password database Anda

try {
    $pdo = new PDO($dsn, $username, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
} catch (PDOException $e) {
    echo 'Connection failed: ' . $e->getMessage();
}
?>