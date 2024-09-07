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
    <title>RadiusMonitor | Add Bandwidth</title><!--begin::Primary Meta Tags-->
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
                        </li>
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
<h3 class="mb-0">Add Bandwidth</h3>
</div> <!--end::Row-->
</div> <!--end::Container-->
<div id="overlay" class="overlay"></div>
<div id="errorPopup" class="confirm-popup">
    <center><p id="popupMessage"></p>
    <center><button onclick="closePopup()">OK</button>
</div>
<div class="col-sm-12 col-md-12">
	<div class="panel panel-primary panel-hovered panel-stacked mb30">
		<div class="panel-heading">Add New Bandwidth</div>
		<div class="panel-body">

<form class="form-horizontal" method="post" role="form" action="./add_bandwidth.php">
    <div class="form-group">
        <label for="name" class="col-md-2 control-label">Bandwidth Name</label>
        <div class="col-md-6">
            <input type="text" class="form-control" id="name" name="name" autocomplete="name" required>
        </div>
    </div>

    <div class="form-group">
        <label for="rate_down" class="col-md-2 control-label">Rate Download</label>
        <div class="col-md-4">
            <input type="number" class="form-control" id="rate_down" name="rate_down" required>
        </div>
        <div class="col-md-2">
            <select class="form-select" id="rate_down_unit" name="rate_down_unit">
                <option value="Kbps">Kbps</option>
                <option value="Mbps">Mbps</option>
            </select>
        </div>
    </div>
    <div class="form-group">
        <label for="rate_up" class="col-md-2 control-label">Rate Upload</label>
        <div class="col-md-4">
            <input type="number" class="form-control" id="rate_up" name="rate_up" required>
        </div>
        <div class="col-md-2">
            <select class="form-select" id="rate_up_unit" name="rate_up_unit">
                <option value="Kbps">Kbps</option>
                <option value="Mbps">Mbps</option>
            </select>
        </div>
    </div>
    <div class="form-group">
        <div class="col-lg-offset-2 col-lg-10">
            <button class="btn btn-primary" type="submit">Submit</button>
            <a href="./list_bandwidth.php" class="btn btn-default">Cancel</a>
        </div>
    </div>
</form>
    </div>
        </div>
    </div>
</div>
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
<script>
    function showPopup(message) {
        document.getElementById('popupMessage').innerText = message;
        document.getElementById('overlay').classList.add('show');
        document.getElementById('errorPopup').classList.add('show');
    }

    function closePopup() {
        document.getElementById('overlay').classList.remove('show');
        document.getElementById('errorPopup').classList.remove('show');
        window.location.href = 'add_bandwidth.php';
    }

    // Menampilkan popup berdasarkan parameter URL
    window.onload = function() {
        const urlParams = new URLSearchParams(window.location.search);
        if (urlParams.has('error')) {
            const errorMessage = urlParams.get('error');
            showPopup(errorMessage);
        }
    }
</script>
<?php
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    // Ambil data dari formulir dengan validasi
    $name = isset($_POST['name']) ? trim($_POST['name']) : '';
    
    // Ganti koma dengan titik dan konversi ke float
    $rate_down = isset($_POST['rate_down']) ? floatval(str_replace(',', '.', $_POST['rate_down'])) : 0;
    $rate_down_unit = isset($_POST['rate_down_unit']) ? $_POST['rate_down_unit'] : 'Kbps';
    $rate_up = isset($_POST['rate_up']) ? floatval(str_replace(',', '.', $_POST['rate_up'])) : 0;
    $rate_up_unit = isset($_POST['rate_up_unit']) ? $_POST['rate_up_unit'] : 'Kbps';

    // Konversi rate_down dan rate_up ke bit per detik (bps)
    if ($rate_down_unit === 'Kbps') {
        $rate_down_bps = $rate_down * 1000;
    } elseif ($rate_down_unit === 'Mbps') {
        $rate_down_bps = $rate_down * 1048576;
    } else {
        $rate_down_bps = $rate_down;
    }

    if ($rate_up_unit === 'Kbps') {
        $rate_up_bps = $rate_up * 1000;
    } elseif ($rate_up_unit === 'Mbps') {
        $rate_up_bps = $rate_up * 1048576;
    } else {
        $rate_up_bps = $rate_up;
    }

    // Tanggal pembuatan (creation_date)
    $creation_date = date('Y-m-d H:i:s');

    // Koneksi ke database
    $servername = "127.0.0.1";
    $username = "radius";
    $password = "radius";
    $dbname = "radius";

    // Buat koneksi
    $conn = new mysqli($servername, $username, $password, $dbname);

    // Cek koneksi
    if ($conn->connect_error) {
        die("Koneksi gagal: " . $conn->connect_error);
    }

    // Cek apakah nama sudah ada di database
    $sql = "SELECT COUNT(*) as count FROM bandwidth WHERE name = ?";
    $stmt = $conn->prepare($sql);
    if ($stmt) {
        $stmt->bind_param("s", $name);
        $stmt->execute();
        $stmt->bind_result($count);
        $stmt->fetch();
        $stmt->close();

        if ($count > 0) {
            echo "<script>window.location.href = 'add_bandwidth.php?error=Nama bandwidth sudah ada didatabase.';</script>";
            $conn->close();
            exit();
        }
    } else {
        echo "Error: " . $conn->error;
        $conn->close();
        exit();
    }

    // Insert data ke database
    $insert = "INSERT INTO bandwidth (name, rate_down, rate_up, creation_date) VALUES (?, ?, ?, ?)";
    $stmt = $conn->prepare($insert);
    if ($stmt) {
        $stmt->bind_param("siis", $name, $rate_down_bps, $rate_up_bps, $creation_date);
        if ($stmt->execute()) {
            echo "<script>window.location.href = 'list_bandwidth.php';</script>";
        } else {
            echo "Error: " . $conn->error;
        }
        $stmt->close();
    } else {
        echo "Error: " . $conn->error;
    }

    $conn->close();
    exit();
}
?>
</body>
</html>