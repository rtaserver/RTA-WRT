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
    <title>RadiusMonitor | List Plans</title><!--begin::Primary Meta Tags-->
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
                </ul>                </ul> <!--end::End Navbar Links-->
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
                        </li>
                        <li class="nav-item"> <a href="#" class="nav-link active"> <i class="nav-icon bi ic--baseline-add-card"></i>
                                <p>
                                    Billing
                                    <span class="nav-badge badge text-bg-secondary me-3"></span> <i class="nav-arrow bi iconoir--nav-arrow-right"></i>
                                </p>
                            </a>
                            <ul class="nav nav-treeview">
                                <li class="nav-item"> <a href="./list_plan.php" class="nav-link active"> <i class="nav-icon bi mdi--scheduled-payment"></i>
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
<h3 class="mb-0">List Plan</h3>
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

$sql_total = "SELECT COUNT(*) as total FROM billing_plans";
$result_total = $conn->query($sql_total);
$row_total = $result_total->fetch_assoc();
$total_batches = $row_total['total'];
$total_pages = ceil($total_batches / $limit);

$sql = "SELECT 
    bp.id, 
    bp.planName, 
    bp.planType, 
    bp.planTimeBank, 
    bp.planCost,
    rgc_simultaneous.value AS Simultaneous_Use,
    rgc_max.value AS Max_All_Session,
    rgr_octets.value AS Max_Total_Octets
FROM 
    billing_plans bp
LEFT JOIN 
    radgroupcheck rgc_simultaneous 
ON 
    bp.planName = rgc_simultaneous.groupname 
    AND rgc_simultaneous.attribute = 'Simultaneous-Use'
LEFT JOIN 
    radgroupcheck rgc_max 
ON 
    bp.planName = rgc_max.groupname 
    AND rgc_max.attribute = 'Max-All-Session'
LEFT JOIN 
    radgroupreply rgr_octets 
ON 
    bp.planName = rgr_octets.groupname 
    AND rgr_octets.attribute = 'ChilliSpot-Max-Total-Octets'
ORDER BY 
    bp.id DESC
LIMIT $limit OFFSET $offset";

$result = $conn->query($sql);
?>
<div class="col-sm-12">
<div class="panel panel-hovered mb20 panel-primary">
    <div class="panel-heading">List All Plan</div>
        <div class="panel-body">
            <div class="md-whiteframe-z1 mb20 text-center" style="padding: 15px">
                <div class="col-md-8">
                    </div>
                        <a href="./add_plan.php" class="btn btn-primary btn-block">
                    <i class="ion ion--add"></i> New Plan </a>
                </div>&nbsp;
            <div class="table-responsive">
        <table class="table table-bordered table-condensed table-striped table_mobile">
    <thead>
<tr>
    <th><center>Name</th>
    <th><center>Cost</th>
    <th><center>Type</th>
    <th><center>Duration</th>
    <th><center>Validity</th>
    <th><center>Kuota</th>
    <th><center>Shared</th>
    <th><center>Actions</th>
</tr>
</thead>
<tbody>
<?php
if ($result->num_rows > 0) {
    while ($row = $result->fetch_assoc()) {
        $plan_id = htmlspecialchars($row['id']);
        $plan_names = htmlspecialchars($row['planName']);
        $plan_cost = htmlspecialchars($row['planCost']);
        $plan_type = htmlspecialchars($row['planType']);
        $shared = htmlspecialchars($row['Simultaneous_Use']);
        $duration = (int)$row['Max_All_Session'];
        $validity = (int)$row['planTimeBank'];
        $kuota = toxbyte($row['Max_Total_Octets']);
        $plan_validity = formatTime($validity);
        $plan_duration = formatTime($duration);

        echo "<td><center>$plan_names</td>
        <td><center>Rp $plan_cost</td>
        <td><center>$plan_type</td>
        <td><center>$plan_duration</td>
        <td><center>$plan_validity</td>
        <td><center>$kuota</td>
        <td><center>$shared</td>";

        echo "<td><center>
            <form data-confirm action='list_plan.php' method='post'>
                <input type='hidden' name='id' value='$plan_id'>
                <input type='hidden' name='plan_name' value='$plan_names'>
                <input type='hidden' name='action' value='delete'>
                <a href='edit_plan.php?id=$plan_id' class='btn btn-warning btn-sm'><i class='tabler--edit'></i></a>
                <button type='submit' class='btn btn-danger btn-sm'><i class='fa6-solid--trash-can'></i></button>
            </form>
            </td>
        </tr>";
    }
} else {
    echo "<tr><td colspan='7'><center>Tidak ada data</center></td></tr>";
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
            `Apakah Anda yakin ingin menghapus plan ${form.querySelector('input[name="plan_name"]').value}?`,
            form
        );
    };
});
</script>
<?php
function toxbyte($size) {
    if (empty($size)) {
        return "Unlimited";
    }
    
    if ($size >= 1073741824) {
        return round($size / 1073741824, 2) . " GB";
    } elseif ($size >= 1048576) {
        return round($size / 1048576, 2) . " MB";
    } elseif ($size >= 1024) {
        return round($size / 1024, 2) . " KB";
    } else {
        return $size . " B";
    }
}

function formatTime($time) {
    // Waktu dalam detik
    if ($time < 60) {
        // Kurang dari 60 detik, bulatkan ke detik
        return sprintf("Unlimited");
    } elseif ($time < 3600) {
        // Kurang dari 1 jam (3600 detik), bulatkan ke menit
        $minutes = round($time / 60); // Bulatkan ke menit terdekat
        return sprintf("%d minutes", $minutes);
    } elseif ($time < 86400) {
        // Kurang dari 1 hari (86400 detik), bulatkan ke jam
        $hours = round($time / 3600); // Bulatkan ke jam terdekat
        return sprintf("%d hours", $hours);
    } else {
        // 1 hari atau lebih, bulatkan ke hari
        $days = round($time / 86400); // Bulatkan ke hari terdekat
        return sprintf("%d days", $days);
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

if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['id']) && isset($_POST['action']) && $_POST['action'] === 'delete') {
    $id = intval($_POST['id']);
    $plan_name = $_POST['plan_name']; // Ambil plan_name dari POST
    
    $pdo = get_db_connection();
    
    if ($pdo) {
        try {
            // Mulai transaksi
            $pdo->beginTransaction();
            
            // Menyiapkan dan menjalankan kueri penghapusan untuk billing_plans
            $stmt_billing = $pdo->prepare("DELETE FROM billing_plans WHERE id = ?");
            $stmt_billing->execute([$id]);
            
            // Menyiapkan dan menjalankan kueri penghapusan untuk radgroupreply
            $stmt_reply = $pdo->prepare("DELETE FROM radgroupreply WHERE groupname = ?");
            $stmt_reply->execute([$plan_name]);
            
            // Menyiapkan dan menjalankan kueri penghapusan untuk radgroupcheck
            $stmt_check = $pdo->prepare("DELETE FROM radgroupcheck WHERE groupname = ?");
            $stmt_check->execute([$plan_name]);
            
            // Commit transaksi
            $pdo->commit();
            
            if ($stmt_billing->rowCount() > 0 || $stmt_reply->rowCount() > 0 || $stmt_check->rowCount() > 0) {
                echo "<script>window.location.href = 'list_plan.php';</script>";
            } else {
                echo "<script>window.location.href = 'list_plan.php?error=No records found with the provided ID';</script>";
            }
        } catch (PDOException $e) {
            // Rollback transaksi jika terjadi kesalahan
            $pdo->rollBack();
            echo "<script>window.location.href = 'list_plan.php?error=Error: " . addslashes($e->getMessage()) . "';</script>";
        }
    } else {
        echo "<script>window.location.href = 'list_plan.php?error=Failed to connect to the database.';</script>";
    }
    exit();
}
?>
</body>
</html>