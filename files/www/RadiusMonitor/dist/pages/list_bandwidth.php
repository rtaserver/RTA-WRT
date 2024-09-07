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
    <title>RadiusMonitor | List Bandwidth</title><!--begin::Primary Meta Tags-->
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
                        <li class="nav-item"> <a href="./index.php" class="nav-link"> <i class="nav-icon bi tabler--device-laptop"></i>
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
                        <li class="nav-item"> <a href="#" class="nav-link active"> <i class="nav-icon bi ic--baseline-add-card"></i>
                                <p>
                                    Billing
                                    <span class="nav-badge badge text-bg-secondary me-3"></span> <i class="nav-arrow bi iconoir--nav-arrow-right"></i>
                                </p>
                            </a>
                            <ul class="nav nav-treeview">
                                <li class="nav-item"> <a href="./list_plan.php" class="nav-link"> <i class="nav-icon bi mdi--scheduled-payment"></i>
                                        <p>Plans</p>
                                    </a> </li>
                                <li class="nav-item"> <a href="./list_bandwidth.php" class="nav-link active"> <i class="nav-icon bi mdi--invoice-schedule"></i>
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
<h3 class="mb-0">List Bandwidth</h3>
</div> <!--end::Row-->
</div> <!--end::Container-->
<div id="overlay" class="overlay"></div>
<div id="confirmPopup" class="confirm-popup">
    <p id="confirmMessage"></p>
    <button id="confirmYes">Yes</button>
    <button id="confirmNo" class="cancel">No</button>
</div>
<?php
include("data/db.php");

$limit = 10;
$page = isset($_GET['page']) ? (int)$_GET['page'] : 1;
$offset = ($page - 1) * $limit;

$sql_total = "SELECT COUNT(*) as total FROM bandwidth";
$result_total = $conn->query($sql_total);
$row_total = $result_total->fetch_assoc();
$total_batches = $row_total['total'];
$total_pages = ceil($total_batches / $limit);

$sql = "SELECT name, rate_down, rate_up
FROM bandwidth
ORDER BY id DESC
LIMIT $limit OFFSET $offset";

$result = $conn->query($sql);
?>  
<div class="col-sm-12">
<div class="panel panel-hovered mb20 panel-primary">
    <div class="panel-heading">List All Bandwidth</div>
        <div class="panel-body">
            <div class="md-whiteframe-z1 mb20 text-center" style="padding: 15px">
                <div class="col-md-8">
                    </div>
                        <a href="./add_bandwidth.php" class="btn btn-primary btn-block">
                    <i class="ion ion--add"></i> New Bandwidth </a>
                </div>&nbsp;
            <div class="table-responsive">
        <table class="table table-bordered table-condensed table-striped table_mobile">
    <thead>
<tr>
    <th><center>Bandwidth Name</center></th>
    <th><center>Download Rate</center></th>
    <th><center>Upload Rate</center></th>
    <th><center>Actions</center></th>
</tr>
</thead>
<tbody>
<?php
if ($result->num_rows > 0) {
    while ($row = $result->fetch_assoc()) {
        $bw_name = htmlspecialchars($row['name']);
        $rate_down = format_bandwidth($row['rate_down']);
        $rate_up = format_bandwidth($row['rate_up']);

        echo "<td><center>$bw_name</td>";
        echo "<td><center>$rate_down</td>";
        echo "<td><center>$rate_up</td>";

        echo "<td><center>
            <form data-confirm action='list_bandwidth.php' method='post'>
                <input type='hidden' name='bw_name' value='$bw_name'>
                <input type='hidden' name='action' value='delete'>
                <button type='submit' class='btn btn-danger btn-sm'><i class='fa6-solid--trash-can'></i></button>
            </form>
            </td>
        </tr>";
    }
} else {
    echo "<tr><td colspan='6'><center>Tidak ada data</center></td></tr>";
}
echo"
    </tbody>
       </table>
         </div>
            <center>
               <nav aria-label='Page navigation pagination-sm'>
                 <ul class='pagination'>
                    <li class='enabled'>
                    <a href='?page=" . max(1, $page - 1) . "' class='page-link' aria-hidden='true' aria-label='Previous' " . ($page <= 1 ? "style='pointer-events: none; opacity: 0.5;'" : "") . ">
                    <span aria-hidden='true'>Prev</span>
                    </a>
                    </li>
                    <li class='active'>
                    <span class='page-link'>$page of $total_pages</span>
                    </li>
                    <li class='enabled'>
                    <a href='?page=" . min($total_pages, $page + 1) . "' class='page-link' aria-hidden='true' aria-label='Next' " . ($page >= $total_pages ? "style='pointer-events: none; opacity: 0.5;'" : "") . ">
                  <span aria-hidden='true'>Next</span>
                </a>
              </li>
            </ul>
          </nav>
        <div></div>
    </section>
</main>
"; ?>
<footer class="app-footer"> <!--begin::To the end-->
<div class="float-end d-none d-sm-inline">Themes by <a href="https://adminlte.io" target="_blank" class="text-decoration-none">AdminLTE.io</a></div>
Radius Monitor by 
<a href="https://github.com/Maizil41" target="_blank" class="text-decoration-none">Maizil41</a>
</strong>
<!--end::Copyright-->
</footer> <!--end::Footer-->
</div> <!--end::App Wrapper--> <!--begin::Script--> <!--begin::Third Party Plugin(OverlayScrollbars)-->
<script src="../../dist/js/adminlte.js"></script> <!--end::Required Plugin(AdminLTE)--><!--begin::OverlayScrollbars Configure-->
<script>
let formToSubmit = null;
let actionUrl = '';

function showConfirmPopup(message, form) {
    document.getElementById('confirmMessage').innerText = message;
    document.getElementById('overlay').classList.add('show');
    document.getElementById('confirmPopup').classList.add('show');
    formToSubmit = form; // Simpan formulir yang akan dikirim
}

function closeConfirmPopup(confirmed) {
    document.getElementById('overlay').classList.remove('show');
    document.getElementById('confirmPopup').classList.remove('show');
    if (confirmed) {
        if (formToSubmit) {
            formToSubmit.submit(); // Kirim formulir setelah konfirmasi
        }
    }
}

document.getElementById('confirmYes').onclick = function() {
    closeConfirmPopup(true);
};

document.getElementById('confirmNo').onclick = function() {
    closeConfirmPopup(false);
};

// Menangani event submit pada formulir
document.querySelectorAll('form[data-confirm]').forEach(form => {
    form.onsubmit = function(event) {
        event.preventDefault(); // Cegah pengiriman formulir standar
        showConfirmPopup(
            `Apakah Anda yakin ingin menghapus bandwidth ${form.querySelector('input[name="bw_name"]').value}?`,
            form
        );
    };
});
</script>
<?php
function format_bandwidth($bps) {
    if ($bps >= 1048576) {
        $value = $bps / 1048576;
        $formatted_value = ($value == (int)$value) ? (int)$value : number_format($value, 1, '.', '');
        return $formatted_value . ' Mbps';
    } elseif ($bps >= 1000) {
        $value = $bps / 1000;
        $formatted_value = ($value == (int)$value) ? (int)$value : number_format($value, 1, '.', '');
        return $formatted_value . ' Kbps';
    } else {
        return number_format($bps) . ' bps';
    }
}

function get_db_connection() {
    $host = '127.0.0.1';
    $db = 'radius';
    $user = 'radius';
    $pass = 'radius';
    try {
        $pdo = new PDO("mysql:host=$host;dbname=$db", $user, $pass);
        $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
        return $pdo;
    } catch (PDOException $e) {
        echo 'Connection failed: ' . $e->getMessage();
        return null;
    }
}

if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['bw_name']) && isset($_POST['action']) && $_POST['action'] === 'delete') {
    $bw_name = $_POST['bw_name'];
    
    $pdo = get_db_connection();
    
    if ($pdo) {
        try {
            // Mulai transaksi
            $pdo->beginTransaction();
            
            // Menyiapkan dan menjalankan kueri penghapusan untuk billing_plans
            $stmt_billing = $pdo->prepare("DELETE FROM bandwidth WHERE name = ?");
            $stmt_billing->execute([$bw_name]);
            
            // Commit transaksi
            $pdo->commit();
            
            if ($stmt_billing->rowCount() > 0 || $stmt_reply->rowCount() > 0 || $stmt_check->rowCount() > 0) {
                echo "<script>window.location.href = 'list_bandwidth.php';</script>";
            } else {
                echo "<script>window.location.href = 'list_bandwidth.php?error=No records found with the provided ID';</script>";
            }
        } catch (PDOException $e) {
            // Rollback transaksi jika terjadi kesalahan
            $pdo->rollBack();
            echo "<script>window.location.href = 'list_bandwidth.php?error=Error: " . addslashes($e->getMessage()) . "';</script>";
        }
    } else {
        echo "<script>window.location.href = 'list_bandwidth.php?error=Failed to connect to the database.';</script>";
    }
    exit();
}
?>
</body>
</html>