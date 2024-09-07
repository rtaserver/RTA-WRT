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
require './auth.php';
?>
<!DOCTYPE html>
<html lang="en"> <!--begin::Head-->

<head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
    <title>RadiusMonitor | Dashboard</title><!--begin::Primary Meta Tags-->
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="author" content="ColorlibHQ">
    <meta name="description" content="AdminLTE is a Free Bootstrap 5 Admin Dashboard, 30 example pages using Vanilla JS.">
    <meta name="keywords" content="bootstrap 5, bootstrap, bootstrap 5 admin dashboard, bootstrap 5 dashboard, bootstrap 5 charts, bootstrap 5 calendar, bootstrap 5 datepicker, bootstrap 5 tables, bootstrap 5 datatable, vanilla js datatable, colorlibhq, colorlibhq dashboard, colorlibhq admin dashboard"><!--end::Primary Meta Tags--><!--begin::Fonts-->
    <link rel="stylesheet" href="../../dist/css/adminlte.css"><!--end::Required Plugin(AdminLTE)--><!-- apexcharts -->
    <link rel="stylesheet" href="../../dist/css/logo.css">
    <link rel="stylesheet" href="../../dist/css/bootstrap.css">
    <link rel="icon" href="../../dist/assets/img/favicon.svg" />
</head> <!--end::Head--> <!--begin::Body-->

<body class="layout-fixed sidebar-expand-lg bg-body-tertiary"> <!--begin::App Wrapper-->
    <div class="app-wrapper"> <!--begin::Header-->
        <nav class="app-header navbar navbar-expand bg-body"> <!--begin::Container-->
            <div class="container-fluid"> <!--begin::Start Navbar Links-->
                <ul class="navbar-nav">
                    <li class="nav-item"> <a class="nav-link" data-lte-toggle="sidebar" href="#" role="button"> <i class="bi mdi--menu-open"></i> </a> </li>
                </ul> <!--end::Start Navbar Links--> <!--begin::End Navbar Links-->
                <ul class="navbar-nav ms-auto"> <!--begin::Navbar Search-->
                        <div class="dropdown-menu dropdown-menu-lg dropdown-menu-end"> <a href="#" class="dropdown-item"> <!--begin::Message-->
                                <div class="d-flex">
                                    <div class="flex-shrink-0"> <img src="../../dist/assets/img/user1-128x128.jpg" alt="User Avatar" class="img-size-50 rounded-circle me-3"> </div>
                                    <div class="flex-grow-1">
                                        <h3 class="dropdown-item-title">
                                            Brad Diesel
                                            <span class="float-end fs-7 text-danger"><i class="bi bi-star-fill"></i></span>
                                        </h3>
                                        <p class="fs-7">Call me whenever you can...</p>
                                        <p class="fs-7 text-secondary"> <i class="bi bi-clock-fill me-1"></i> 4 Hours Ago
                                        </p>
                                    </div>
                                </div> <!--end::Message-->
                            </a>
                            <div class="dropdown-divider"></div> <a href="#" class="dropdown-item"> <!--begin::Message-->
                                <div class="d-flex">
                                    <div class="flex-shrink-0"> <img src="../../dist/assets/img/user8-128x128.jpg" alt="User Avatar" class="img-size-50 rounded-circle me-3"> </div>
                                    <div class="flex-grow-1">
                                        <h3 class="dropdown-item-title">
                                            John Pierce
                                            <span class="float-end fs-7 text-secondary"> <i class="bi bi-star-fill"></i> </span>
                                        </h3>
                                        <p class="fs-7">I got your message bro</p>
                                        <p class="fs-7 text-secondary"> <i class="bi bi-clock-fill me-1"></i> 4 Hours Ago
                                        </p>
                                    </div>
                                </div> <!--end::Message-->
                            </a>
                        </div>
                    </li> <!--end::Notifications Dropdown Menu--> <!--begin::Fullscreen Toggle-->
                    <li class="nav-item"> <a class="nav-link" href="#" data-lte-toggle="fullscreen"> <i data-lte-icon="maximize" class="bi mdi--fullscreen"></i> <i data-lte-icon="minimize" class="bi mdi--fullscreen-exit" style="display: none;"></i> </a> </li> <!--end::Fullscreen Toggle--> <!--begin::User Menu Dropdown-->
                    <li class="nav-item"> <a class="nav-link" href="./logout.php" data-lte-toggle="logout"> <i data-lte-icon="logout" class="bi material-symbols--logout"></i></a>
                </ul> <!--end::End Navbar Links-->
            </div> <!--end::Container-->
        </nav> <!--end::Header--> <!--begin::Sidebar-->
        <aside class="app-sidebar bg-body-secondary shadow" data-bs-theme="dark"> <!--begin::Sidebar Brand-->
            <div class="sidebar-brand"><a href="./index.php" class="brand-link"><center>Radius Monitor</a></div>
            <div class="sidebar-wrapper">
                <nav class="mt-2"> <!--begin::Sidebar Menu-->
                    <ul class="nav sidebar-menu flex-column" data-lte-toggle="treeview" role="menu" data-accordion="false">
                        <li class="nav-item"> <a href="./index.php" class="nav-link active"> <i class="nav-icon bi tabler--device-laptop"></i>
                                <p>
                                    Dashboard
                                </p>
                            </a>
                        <li class="nav-item"> <a href="#" class="nav-link"> <i class="nav-icon bi fa6-solid--user-large"></i>
                                <p>
                                    Users
                                    <i class="nav-arrow bi iconoir--nav-arrow-right"></i>
                                </p>
                            </a>
                            <ul class="nav nav-treeview">
                                <li class="nav-item"> <a href="./list_user.php" class="nav-link"> <i class="nav-icon bi mdi--user-group"></i>
                                        <p>All User</p>
                                    </a> </li>
                                <li class="nav-item"> <a href="./mac_binding.php" class="nav-link"> <i class="nav-icon bi eos-icons--role-binding-outlined"></i>
                                        <p>Mac Binding</p>
                                    </a> </li>
                                <li class="nav-item"> <a href="./online_user.php" class="nav-link"> <i class="nav-icon bi gis--globe-user"></i>
                                        <p>Online User</p>
                                    </a> </li>
                            </ul>
                        </li>
                        <li class="nav-item"> <a href="#" class="nav-link"> <i class="nav-icon bi ic--baseline-add-card"></i>
                                <p>
                                    Billing
                                    <span class="nav-badge badge text-bg-secondary me-3"></span> <i class="nav-arrow bi iconoir--nav-arrow-right"></i>
                                </p>
                            </a>
                            <ul class="nav nav-treeview">
                                <li class="nav-item"> <a href="./list_plan.php" class="nav-link"> <i class="nav-icon bi mdi--scheduled-payment"></i>
                                        <p>Plans</p>
                                    </a> </li>
                                <li class="nav-item"> <a href="./list_bandwidth.php" class="nav-link"> <i class="nav-icon bi mdi--invoice-schedule"></i>
                                        <p>Bandwidth</p>
                                    </a> </li>
                            </ul>
                        </li>
                        <li class="nav-item"> <a href="#" class="nav-link"> <i class="nav-icon bi mdi--printer"></i>
                                <p>
                                    Print
                                    <i class="nav-arrow bi iconoir--nav-arrow-right"></i>
                                </p>
                            </a>
                            <ul class="nav nav-treeview">
                                <li class="nav-item"> <a href="./print_user.php" class="nav-link"> <i class="nav-icon bi mingcute--user-add-fill"></i>
                                        <p>User</p>
                                    </a> </li>
                                <li class="nav-item"> <a href="./list_batch.php" class="nav-link"> <i class="nav-icon bi material-symbols--group-add"></i>
                                        <p>Batch</p>
                                    </a> </li>
                            </ul>
                        </li>
                        <li class="nav-item"> <a href="#" class="nav-link"> <i class="nav-icon bi mdi--gear"></i>
                                <p>
                                    System
                                    <i class="nav-arrow bi iconoir--nav-arrow-right"></i>
                                </p>
                            </a>
                            <ul class="nav nav-treeview">
                                <li class="nav-item"> <a href="./sys_info.php" class="nav-link"> <i class="nav-icon bi mdi--server-outline"></i>
                                        <p>Information</p>
                                    </a> </li>
                                <li class="nav-item"> <a href="./sys_db.php" class="nav-link"> <i class="nav-icon bi material-symbols--database"></i>
                                        <p>Database</p>
                                    </a> </li>
                                <li class="nav-item"> <a href="./client_tester.php" class="nav-link"> <i class="nav-icon bi ep--connection"></i>
                                        <p>Client Tester</p>
                                    </a> </li>
                                <li class="nav-item"> <a href="./php_admin.php" class="nav-link"> <i class="nav-icon bi phpmyadmin"></i>
                                        <p>Php Admin</p>
                                    </a> </li>
                                </ul>
                            </li>
                        </ul> <!--end::Sidebar Menu-->
                    </nav>
                </div> <!--end::Sidebar Wrapper-->
            </aside> <!--end::Sidebar--> 
        <main class="app-main"> <!--begin::App Content Header-->
    <div class="app-content-header"> <!--begin::Container-->
<section class="content">
<div class="container-fluid"> <!--begin::Row-->
<h3 class="mb-0">Dashboard</h3>
</div> <!--end::Row-->
</div> <!--end::Container-->
<div id="overlay" class="overlay"></div>
<div id="confirmPopup" class="confirm-popup">
    <p id="confirmMessage"></p>
    <button id="confirmYes">Yes</button>
    <button id="confirmNo" class="cancel">No</button>
</div>
<?php
include ("data/db.php");
include ("data/data.php");

$sql     = "SELECT acctsessionid FROM radacct WHERE acctstoptime IS NULL";
$result  = mysqli_query($conn, $sql);

if (mysqli_num_rows($result) > 0) {
  while ($row     = mysqli_fetch_assoc($result)) {
    $acctid  = $row['acctsessionid'];

    if (isset($_GET['id'])) {

      $user    = $_GET['id'];

      $command = 'echo \'User-Name="' . $user . '",Acct-Session-Id="' . $acctid . '",Framed-IP-Address=10.10.10.1\' | radclient -c \'1\' -n \'3\' -r \'3\' -t \'3\' -x \'127.0.0.1:3799\' \'disconnect\' \'testing123\' 2>&1';

      $output  = shell_exec($command);
    }
  }
}
        
echo "  <div class='app-content'> <!--begin::Container-->
                <div class='container-fluid'> <!--begin::Row-->
                    <div class='row'> <!--begin::Col-->
                        <div class='col-lg-3 col-6'> <!--begin::Small Box Widget 1-->
                            <div class='small-box text-bg-primary'>
                                <div class='inner'>
                                    <h3>Rp " . number_format($totalPendapatanHariIni, 0, ',', '.') . "</h3>
                                    <p>Pendapatan Hari Ini</p>
                                </div> <svg class='small-box-icon' fill='currentColor' viewBox='0 0 24 24' xmlns='http://www.w3.org/2000/svg' aria-hidden='true'>
                                    <path fill='currentColor' d='M5 6h18v12H5zm9 3a3 3 0 0 1 3 3a3 3 0 0 1-3 3a3 3 0 0 1-3-3a3 3 0 0 1 3-3M9 8a2 2 0 0 1-2 2v4a2 2 0 0 1 2 2h10a2 2 0 0 1 2-2v-4a2 2 0 0 1-2-2zm-8 2h2v10h16v2H1z'/></path>
                                </svg> <a class='small-box-footer link-light link-underline-opacity-0'>
                                    $percentChangeFormatted2 Dari kemaren</i> </a>
                            </div> <!--end::Small Box Widget 1-->
                        </div> <!--end::Col-->
                        <div class='col-lg-3 col-6'> <!--begin::Small Box Widget 2-->
                            <div class='small-box text-bg-success'>
                                <div class='inner'>
                                    <h3>$userCountToday<sup class='fs-5'></sup></h3>
                                    <p>Login Hari Ini</p>
                                </div> <svg class='small-box-icon' fill='currentColor' viewBox='0 0 24 24' xmlns='http://www.w3.org/2000/svg' aria-hidden='true'>
                                    <path fill='currentColor' d='M17 18h4v-2h-4v-2l-3 3l3 3zM11 4C8.8 4 7 5.8 7 8s1.8 4 4 4s4-1.8 4-4s-1.8-4-4-4m0 10c-4.4 0-8 1.8-8 4v2h9.5c-.3-.8-.5-1.6-.5-2.5c0-1.2.3-2.3.9-3.4c-.6 0-1.2-.1-1.9-.1'/></path>
                                </svg> <a class='small-box-footer link-light link-underline-opacity-0'>
                                    $percentChangeFormatted1 Dari kemaren</i> </a>
                            </div> <!--end::Small Box Widget 2-->
                        </div> <!--end::Col-->
                        <div class='col-lg-3 col-6'> <!--begin::Small Box Widget 3-->
                            <div class='small-box text-bg-warning'>
                                <div class='inner'>
                                    <h3>$totalOnline</h3>
                                    <p>Pengguna Online</p>
                                </div> <svg class='small-box-icon' fill='currentColor' viewBox='0 0 24 24' xmlns='http://www.w3.org/2000/svg' aria-hidden='true'>
                                    <path fill='currentColor' d='M1 20v-2.8q0-.85.438-1.562T2.6 14.55q1.55-.775 3.15-1.162T9 13t3.25.388t3.15 1.162q.725.375 1.163 1.088T17 17.2V20zm18 0v-3q0-1.1-.612-2.113T16.65 13.15q1.275.15 2.4.513t2.1.887q.9.5 1.375 1.112T23 17v3zM9 12q-1.65 0-2.825-1.175T5 8t1.175-2.825T9 4t2.825 1.175T13 8t-1.175 2.825T9 12m10-4q0 1.65-1.175 2.825T15 12q-.275 0-.7-.062t-.7-.138q.675-.8 1.038-1.775T15 8t-.362-2.025T13.6 4.2q.35-.125.7-.163T15 4q1.65 0 2.825 1.175T19 8'/></path>
                                </svg> <a class='small-box-footer link-dark link-underline-opacity-0'>
                                    Total Voucher $totalUser</i> </a>
                            </div> <!--end::Small Box Widget 3-->
                        </div> <!--end::Col-->
                        <div class='col-lg-3 col-6'> <!--begin::Small Box Widget 4-->
                            <div class='small-box text-bg-danger'>
                                <div class='inner'>
                                    <h3>Rp " . number_format($totalPendapatan_bulanIni, 0, ',', '.') . "</h3>
                                    <p>Pendapatan Bulan Ini</p>
                                </div> <svg class='small-box-icon' fill='currentColor' viewBox='0 0 24 24' xmlns='http://www.w3.org/2000/svg' aria-hidden='true'>
                                    <path fill='currentColor' d='M9 10v2H7v-2zm4 0v2h-2v-2zm4 0v2h-2v-2zm2-7a2 2 0 0 1 2 2v14a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h1V1h2v2h8V1h2v2zm0 16V8H5v11zM9 14v2H7v-2zm4 0v2h-2v-2zm4 0v2h-2v-2z'/></path>
                                </svg> <a class='small-box-footer link-light link-underline-opacity-0'>
                                    $percentChangeFormatted3 Dari bulan lalu</i> </a>
                            </div> <!--end::Small Box Widget 4-->
                        </div> <!--end::Col-->
                    </div> <!--end::Row--> <!--begin::Row-->
                    
";

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

echo "
<div class='col-sm-12'>
    <div class='row'>
        <!-- Kolom Kiri -->
        <div class='col-sm-8'>
            <div class='row'>
                <div class='col-sm-12'>
                    <div class='panel panel-hovered mb20 panel-primary'>
                        <div class='panel-heading'>Pendapatan & Kuota</div>
                        <div class='card-header border-0'>
                            <div class='chart'>
                                <select id='dataSelect'>
                                    <option value='daily'>Harian</option>
                                    <option value='monthly'>Bulanan</option>
                                    <option value='yearly'>Tahunan</option>
                                </select> 
                                <canvas id='combinedChart' aria-label='Site statistics' role='img'></canvas> 
                            </div>
                        </div>
                    </div>
                </div>

                <div class='col-sm-12'>
                    <div class='panel panel-hovered mb20 panel-primary'>
                        <div class='panel-heading'>List Online User</div>
                        <div class='panel-body'>
                            <div class='md-whiteframe-z1 mb20 text-center' style='padding: 15px'>
                                <div class='table-responsive'>
                                    <table class='table table-bordered table-condensed table-striped table_mobile'>
                                        <thead>
                                            <tr>
                                                <th class='text-center'>USERNAME</th>
                                                <th class='text-center'>IP</th>
                                                <th class='text-center'>MAC</th>
                                                <th class='text-center'>LOGIN</th>
                                                <th class='text-center'>ACTION</th>
                                            </tr>
                                        </thead>
                                        <tbody>";

if ($result->num_rows > 0) {
    while ($row = $result->fetch_assoc()) {
        echo "<tr>";
        echo "<td><center>" . htmlspecialchars($row["username"]) . "</td>";
        echo "<td><center>" . htmlspecialchars($row["framedipaddress"]) . "</td>";
        echo "<td><center>" . htmlspecialchars($row["callingstationid"]) . "</td>";
        echo "<td><center>" . htmlspecialchars($row["acctstarttime"]) . "</td>";
        echo "<td><center><span class='btn btn-danger btn-sm' style='cursor: pointer;' onclick=\"deleteUser('" . htmlspecialchars($row["username"]) . "')\">Kick</span></td>";
        echo "</tr>";
    }
} else {
    echo "<tr><td colspan='5'><center>Tidak ada data</center></td></tr>";
}

echo "
    </tbody>
        </table>
            </div>
                </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

        <div class='col-sm-4'>
            <div class='row'>
                <div class='col-sm-12'>
                    <div class='panel panel-hovered mb20 panel-primary'>
                        <div class='panel-heading'>Login Harian</div>
                        <div class='panel-body'>
                            <div class='md-whiteframe-z1 mb20 text-center' style='padding: 15px'>
                                <div class='table-responsive'>
                                    <canvas id='chart-bars' aria-label='Customers statistics' role='img'></canvas>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <div class='col-sm-12'>
                    <div class='panel panel-hovered mb20 panel-primary'>
                        <div class='panel-heading'>Login Terbaru</div>
                        <div class='panel-body'>
                            <div class='md-whiteframe-z1 mb20 text-center' style='padding: 15px'>
                                <div class='table-responsive'>
                                    <table class='table table-bordered table-condensed table-striped table_mobile'>
                                        <thead>
                                            <tr>
                                                <th><center>Username</center></th>
                                                <th><center>Reply</center></th>
                                                <th><center>Auth Date</center></th>
                                            </tr>
                                        </thead>
                                        <tbody>";
                                
$sql = "SELECT username, reply, authdate FROM radpostauth ORDER BY id DESC LIMIT 7";
$result = $conn->query($sql);

$user_data = [];
if ($result->num_rows > 0) {
    while ($row = $result->fetch_assoc()) {
        // Cek apakah username adalah MAC address dan reply adalah Access-Reject
        if (preg_match('/^([A-Fa-f0-9]{2}[:-]){5}([A-Fa-f0-9]{2})$/', $row['username']) && $row['reply'] == 'Access-Reject') {
            continue; // Lewati iterasi ini
        }
        $user_data[] = [
            'username' => htmlspecialchars($row['username']),
            'reply' => htmlspecialchars($row['reply']),
            'authdate' => htmlspecialchars($row['authdate'])
        ];
    }
} else {
    $user_data[] = [
        'username' => '',
        'reply' => '',
        'authdate' => ''
    ];
}

foreach ($user_data as $user) {
    echo "
    <tr>
        <td><center>{$user['username']}</center></td>
        <td style='color: " . ($user['reply'] == 'Access-Accept' ? 'green' : ($user['reply'] == 'Access-Reject' ? 'red' : 'black')) . ";'><center>{$user['reply']}</center></td>
        <td><center>{$user['authdate']}</center></td>
    </tr>";
}

echo "
    </tbody>
        </table>
            </div>
                </div>
                 </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>";
?>
</main>
    <footer class="app-footer"> <!--begin::To the end-->
            <div class="float-end d-none d-sm-inline">Themes by <a href="https://adminlte.io" target="_blank" class="text-decoration-none">AdminLTE.io</a></div>
                Radius Monitor by 
                <a href="https://github.com/Maizil41" target="_blank" class="text-decoration-none">Maizil41</a>
            </strong>
        <!--end::Copyright-->
    </footer> <!--end::Footer-->
    </div> <!--end::App Wrapper--> <!--begin::Script--> <!--begin::Third Party Plugin(OverlayScrollbars)-->
    <script src="../../dist/js/adminlte.js"></script> <!--end::Required Plugin(AdminLTE)--><!--begin::OverlayScrollbars Configure-->
    <script src="./plugins/chart.min.js"></script>
    <script src="./plugins/chart-script.js" defer></script>
    <script src="./plugins/daily-user-chart.js" defer></script> <!-- Icons library -->
    <script src="plugins/feather.min.js"></script> <!-- Custom scripts -->
    <script src="js/script.js"></script>
<script>
let deleteUserUsername = '';

function showConfirmPopup(message, username) {
    document.getElementById('confirmMessage').innerText = message;
    document.getElementById('overlay').classList.add('show');
    document.getElementById('confirmPopup').classList.add('show');
    deleteUserUsername = username; // Simpan username yang akan dihapus
}

function closeConfirmPopup(confirmed) {
    document.getElementById('overlay').classList.remove('show');
    document.getElementById('confirmPopup').classList.remove('show');
    if (confirmed) {
        if (deleteUserUsername) {
            // Redirect ke halaman penghapusan dengan username yang disimpan
            window.location.href = `index.php?id=${encodeURIComponent(deleteUserUsername)}`;
        }
    }
}

document.getElementById('confirmYes').onclick = function() {
    closeConfirmPopup(true);
};

document.getElementById('confirmNo').onclick = function() {
    closeConfirmPopup(false);
};

// Fungsi untuk memanggil popup konfirmasi
function deleteUser(username) {
    showConfirmPopup(`Apakah Anda yakin ingin memutuskan pengguna ${username}?`, username);
}
</script>
</body><!--end::Body-->

</html>