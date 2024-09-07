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
$sqlOnlineCount = "
    SELECT 
        COUNT(*) AS total_online
    FROM radacct ra
    LEFT JOIN userbillinfo ub ON ra.username = ub.username
    WHERE ra.acctstoptime IS NULL
";
$resultOnlineCount = $conn->query($sqlOnlineCount);
$rowOnlineCount = $resultOnlineCount->fetch_assoc();
$totalOnline = $rowOnlineCount['total_online'];

$sqlTotalUser = "SELECT COUNT(*) AS total_user FROM radcheck";
$resultTotalUser = $conn->query($sqlTotalUser);
$rowTotalUser = $resultTotalUser->fetch_assoc();
$totalUser = $rowTotalUser['total_user'];

$sqlUserCountToday = "
    SELECT COUNT(DISTINCT a.username) AS total_user_today
    FROM radacct a
    WHERE a.acctstarttime IS NOT NULL AND DATE(a.acctstarttime) = CURDATE()
";

$sqlUserCountYesterday = "
    SELECT COUNT(DISTINCT a.username) AS total_user_yesterday
    FROM radacct a
    WHERE a.acctstoptime IS NOT NULL AND DATE(a.acctstarttime) = CURDATE() - INTERVAL 1 DAY
";

$resultUserCountToday = $conn->query($sqlUserCountToday);
$userCountToday = $resultUserCountToday->fetch_assoc()['total_user_today'];

$resultUserCountYesterday = $conn->query($sqlUserCountYesterday);
$userCountYesterday = $resultUserCountYesterday->fetch_assoc()['total_user_yesterday'];

    if ($userCountYesterday > 0 && $userCountToday > 0) {
        $percentChange1 = (($userCountToday - $userCountYesterday) / $userCountYesterday) * 100;
    } else {
        $percentChange1 = ($userCountToday > 0) ? 100 : 0;
    }

$percentChangeFormatted1 = number_format($percentChange1, 0) . '%';

$sqlPendapatanHariIni = "
    SELECT 
        SUM(planCost) AS total_pendapatan
    FROM (
        SELECT 
            DATE(a.acctstarttime) AS tanggal,
            p.planCost
        FROM radacct a
        JOIN userbillinfo u ON a.username = u.username
        JOIN billing_plans p ON u.planName = p.planName
        WHERE a.acctstarttime IS NOT NULL AND DATE(a.acctstarttime) = CURDATE()
        GROUP BY tanggal, a.username
    ) AS daily_totals;
";
$resultPendapatanHariIni = $conn->query($sqlPendapatanHariIni);
$rowPendapatanHariIni = $resultPendapatanHariIni->fetch_assoc();
$totalPendapatanHariIni = $rowPendapatanHariIni['total_pendapatan'];

$sqlPendapatanKemarin = "
    SELECT 
        SUM(planCost) AS total_pendapatan
    FROM (
        SELECT 
            DATE(a.acctstoptime) AS tanggal,
            p.planCost
        FROM radacct a
        JOIN userbillinfo u ON a.username = u.username
        JOIN billing_plans p ON u.planName = p.planName
        WHERE a.acctstoptime IS NOT NULL AND DATE(a.acctstoptime) = CURDATE() - INTERVAL 1 DAY
        GROUP BY tanggal, a.username
    ) AS daily_totals;
";
$resultPendapatanKemarin = $conn->query($sqlPendapatanKemarin);
$rowPendapatanKemarin = $resultPendapatanKemarin->fetch_assoc();
$totalPendapatanKemarin = $rowPendapatanKemarin['total_pendapatan'];

        if ($totalPendapatanKemarin > 0 && $totalPendapatanHariIni > 0) {
            $percentChange2 = (($totalPendapatanHariIni - $totalPendapatanKemarin) / $totalPendapatanKemarin) * 100;
        } else {
            $percentChange2 = ($totalPendapatanHariIni > 0) ? 100 : 0;
        }

$percentChangeFormatted2 = number_format(abs($percentChange2), 0) . '%';
$percentChangeFormatted2 = number_format($percentChange2, 0) . '%';

$totalPendapatanKemarin = number_format($totalPendapatanKemarin, 0);

$sqlPendapatan_bulanIni = "
    SELECT 
        bulan,
        SUM(planCost) AS total_pendapatan
    FROM (
        SELECT 
            DATE_FORMAT(a.acctstarttime, '%Y-%m') AS bulan,
            p.planCost
        FROM radacct a
        JOIN userbillinfo u ON a.username = u.username
        JOIN billing_plans p ON u.planName = p.planName
        WHERE a.acctstarttime IS NOT NULL 
          AND YEAR(a.acctstarttime) = YEAR(CURDATE())
          AND MONTH(a.acctstarttime) = MONTH(CURDATE())
        GROUP BY bulan, a.username
    ) AS monthly_totals
    GROUP BY bulan
    ORDER BY bulan;
";

$resultPendapatan_bulanIni = $conn->query($sqlPendapatan_bulanIni);
$rowPendapatan_bulanIni = $resultPendapatan_bulanIni->fetch_assoc();

if (is_array($rowPendapatan_bulanIni) && isset($rowPendapatan_bulanIni['total_pendapatan'])) {
    $totalPendapatan_bulanIni = $rowPendapatan_bulanIni['total_pendapatan'];
} else {
    $totalPendapatan_bulanIni = 0;
}

$sqlPendapatan_bulanLalu = "
    SELECT 
        bulan,
        SUM(planCost) AS total_pendapatan
    FROM (
        SELECT 
            DATE_FORMAT(a.acctstoptime, '%Y-%m') AS bulan,
            p.planCost
        FROM radacct a
        JOIN userbillinfo u ON a.username = u.username
        JOIN billing_plans p ON u.planName = p.planName
        WHERE a.acctstoptime IS NOT NULL 
          AND YEAR(a.acctstoptime) = YEAR(CURDATE() - INTERVAL 1 MONTH)
          AND MONTH(a.acctstoptime) = MONTH(CURDATE() - INTERVAL 1 MONTH)
        GROUP BY bulan, a.username
    ) AS monthly_totals
    GROUP BY bulan
    ORDER BY bulan;
";

$resultPendapatan_bulanLalu = $conn->query($sqlPendapatan_bulanLalu);
$rowPendapatan_bulanLalu = $resultPendapatan_bulanLalu->fetch_assoc();

if (is_array($rowPendapatan_bulanLalu) && isset($rowPendapatan_bulanLalu['total_pendapatan'])) {
    $totalPendapatan_bulanLalu = $rowPendapatan_bulanLalu['total_pendapatan'];
} else {
    $totalPendapatan_bulanLalu = 0;
}

        if ($totalPendapatan_bulanLalu > 0 && $totalPendapatan_bulanIni > 0) {
            $percentChange3 = (($totalPendapatan_bulanIni - $totalPendapatan_bulanLalu) / $totalPendapatan_bulanIni) * 100;
        } else {
            $percentChange3 = ($totalPendapatan_bulanIni > 0) ? 100 : 0;
        }

$percentChangeFormatted3 = number_format(abs($percentChange3), 0) . '%';
$percentChangeFormatted3 = number_format($percentChange3, 0) . '%';

$totalPendapatan_bulanLalu = number_format($totalPendapatan_bulanLalu, 0);

?>
