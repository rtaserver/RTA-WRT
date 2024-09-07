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
// Query SQL
$sql = "SELECT ra.username, 
       ra.acctstarttime, 
       ra.framedipaddress, 
       ra.callingstationid,
       ub.planname AS harga
FROM radacct ra
LEFT JOIN userbillinfo ub ON ra.username = ub.username
WHERE ra.acctstoptime IS NULL
LIMIT 10";

$result = $conn->query($sql);

// Cek apakah ada hasil
if ($result->num_rows > 0) {
    // Menampilkan data
    while($row = $result->fetch_assoc()) {
        echo "<tr>";
        echo "<td><center>" . htmlspecialchars($row["username"]) . "</td>";
        echo "<td><center>" . htmlspecialchars($row["framedipaddress"]) . "</td>";
        echo "<td><center>" . htmlspecialchars($row["callingstationid"]) . "</td>";
        echo "<td><center>" . htmlspecialchars($row["acctstarttime"]) . "</td>";
        echo "<td><center><span class='btn btn-danger btn-sm' style='cursor: pointer;' onclick=\"deleteUser('" . $row["username"] . "')\">Kick</span></td>";
        echo "</tr>";
    }
} else {
    echo "<tr><td colspan='6'><center>Tidak ada pengguna online</td></tr>";
}

?>
