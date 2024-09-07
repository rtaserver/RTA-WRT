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
    <title>RadiusMonitor | Add Mac</title><!--begin::Primary Meta Tags-->
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
                        <li class="nav-item"> <a href="#" class="nav-link active"> <i class="nav-icon bi fa6-solid--user-large"></i>
                                <p>
                                    Users
                                    <i class="nav-arrow bi iconoir--nav-arrow-right"></i>
                                </p>
                            </a>
                            <ul class="nav nav-treeview">
                                <li class="nav-item"> <a href="./list_user.php" class="nav-link"> <i class="nav-icon bi mdi--user-group"></i>
                                        <p>All User</p>
                                    </a> </li>
                                <li class="nav-item"> <a href="./mac_binding.php" class="nav-link active"> <i class="nav-icon bi eos-icons--role-binding-outlined"></i>
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
<h3 class="mb-0">Add Mac</h3>
</div> <!--end::Row-->
</div> <!--end::Container-->
<div id="overlay" class="overlay"></div>
<div id="errorPopup" class="confirm-popup">
    <center><p id="popupMessage"></p>
    <center><button onclick="closePopup()">OK</button>
</div>
<div class="col-sm-12 col-md-12">
    <div class="panel panel-primary panel-hovered panel-stacked mb30">
        <div class="panel-heading">Add New Mac</div>
        <div class="panel-body">
            <form class="form-horizontal" method="post" role="form" action="./add_mac.php">
                <div class="form-group">
                    <label for="useraliasTop" class="col-md-2 control-label">Name</label>
                    <div class="col-md-6">
                        <input type="text" id="useraliasTop" class="form-control" name="useralias" placeholder="Name" maxlength="12" required>
                    </div>
                </div>
                
                <!-- Ini ytta -->
                <div class="form-group">
                    <label for="planDropup" class="col-md-2 control-label">Select Plan</label>
                    <div class="col-md-6">
                        <select id="planDropup" name="planName" class="form-select" autocomplete="off">
                            <option value="">Select Plan</option>
                        </select>
                    </div>
                </div>

                <!-- Ini Mac type -->
                <div class="form-group">
                    <label class="col-md-2 control-label">Mac Type</label>
                    <div class="col-md-10">
                        <input type="radio" id="Select" name="typebp" value="Select" checked onclick="toggleMacInput()"> Select
                        <input type="radio" id="Manual" name="typebp" value="Manual" onclick="toggleMacInput()"> Manual
                    </div>
                </div>
                
                <!-- Ini mac select -->
                <div class="form-group" id="macSelect">
                    <label for="macDropdown" class="col-md-2 control-label">Mac Address</label>
                    <div class="col-md-6">
                        <select id="macDropdown" name="macSelect" class="form-select" autocomplete="off">
                            <option value="">Select Mac</option>
                        </select>
                    </div>
                </div>

                <!-- Ini mac manual -->
                <div class="form-group" id="macManual" style="display:none;">
                    <label for="usernameTop" class="col-md-2 control-label">Mac Address</label>
                    <div class="col-md-6">
                        <input type="text" id="usernameTop" class="form-control" name="macManual" placeholder="Mac Address" maxlength="17" autocomplete="on">
                    </div>
                </div>
                
                <!-- Ini ytta -->
                <div class="form-group">
                    <div class="col-lg-offset-2 col-lg-10">
                        <button class="btn btn-primary" type="submit" name="addUser" value="top">Add</button>
                        <a href="./mac_binding.php" class="btn btn-default">Cancel</a>
                    </div>
                </div>
            </form>
        </div>
    </div>
</div>
</main>

<footer class="app-footer">
    <div class="float-end d-none d-sm-inline">Themes by <a href="https://adminlte.io" target="_blank" class="text-decoration-none">AdminLTE.io</a></div>
    Radius Monitor by <a href="https://github.com/Maizil41" target="_blank" class="text-decoration-none">Maizil41</a>
</footer>

<script src="../../dist/js/adminlte.js"></script>
    
<script>
    function showPopup(message) {
        document.getElementById('popupMessage').innerText = message;
        document.getElementById('overlay').classList.add('show');
        document.getElementById('errorPopup').classList.add('show');
    }

    function closePopup() {
        document.getElementById('overlay').classList.remove('show');
        document.getElementById('errorPopup').classList.remove('show');
        window.location.href = 'add_mac.php';
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
    
<script>
    function toggleMacInput() {
        var select = document.getElementById('Select');
        var macSelect = document.getElementById('macSelect');
        var macManual = document.getElementById('macManual');

        if (select.checked) {
            macSelect.style.display = 'block';
            macManual.style.display = 'none';
        } else {
            macSelect.style.display = 'none';
            macManual.style.display = 'block';
        }
    }
</script>

<script>
    document.addEventListener('DOMContentLoaded', function() {
        fetch('../pages/api/radgroup.php')
            .then(response => response.json())
            .then(data => {
                let planDropdown = document.getElementById('planDropup');
                data.plans.forEach(item => {
                    let option = document.createElement('option');
                    option.value = item.planName;
                    option.textContent = item.planName;
                    planDropdown.appendChild(option);
                });
            })
            .catch(error => console.error('Error:', error));

        fetch('../pages/api/mac_address.php')
            .then(response => response.json())
            .then(data => {
                let macDropdown = document.getElementById('macDropdown');
                data.data.forEach(item => {
                    let option = document.createElement('option');
                    option.value = item.mac_address;
                    option.textContent = item.mac_address;
                    macDropdown.appendChild(option);
                });
            })
            .catch(error => console.error('Error:', error));
    });
</script>

<?php
// Konfigurasi database
$host = "127.0.0.1";
$user = "radius";
$password = "radius";
$dbname = "radius";

$conn = new mysqli($host, $user, $password, $dbname);

if ($conn->connect_error) {
    die("Koneksi gagal: " . $conn->connect_error);
}

if ($_SERVER["REQUEST_METHOD"] == "POST") {
    $firstname = $_POST['useralias'];
    $plan_name = isset($_POST['planName']) ? trim($_POST['planName']) : '';
    $now = date('Y-m-d H:i:s');

    $code = '';
    if (isset($_POST['typebp']) && $_POST['typebp'] == 'Select') {
        $code = $_POST['macSelect'];
    } elseif (isset($_POST['typebp']) && $_POST['typebp'] == 'Manual') {
        $code = $_POST['macManual'];

        if (preg_match('/^([0-9A-Fa-f]{2}-){5}[0-9A-Fa-f]{2}$/', $code) || preg_match('/^([0-9A-Fa-f]{2}:){5}[0-9A-Fa-f]{2}$/', $code)) {
            $code = strtoupper(str_replace(':', '-', $code));
        } else {
            echo "<script>window.location.href = 'add_mac.php?error=Format MAC address tidak valid. Gunakan format seperti : C8-16-DA-4F-47-C9 atau C8:16:DA:4F:47:C9';</script>";
            exit();
        }
    }

    if (!empty($code) && !empty($plan_name)) {
        // Logika untuk menyimpan ke database
        try {
            $conn->begin_transaction();
            // cek apakah username sudah ada
            $stmt = $conn->prepare("SELECT username FROM radcheck WHERE username = ?");
            $stmt->bind_param("s", $code);
            $stmt->execute();
            $stmt->store_result();

            if ($stmt->num_rows > 0) {
                echo "<script>window.location.href = 'add_mac.php?error=Mac address sudah terdaftar di database.';</script>";
                $stmt->close();
                $conn->close();
                exit();
            }
            $stmt->close();

            // Logika insert data ke database
            if (isset($_POST['addUser']) && $_POST['addUser'] == 'top') {
                $stmt = $conn->prepare("INSERT INTO radcheck (username, attribute, op, value) VALUES (?, ?, ?, ?)");
                $stmt->bind_param("ssss", $code, $attribute, $op, $value);
                $attribute = "Auth-Type";
                $op = ":=";
                $value = "Accept";
                $stmt->execute();
                $stmt->close();

                $stmt = $conn->prepare("INSERT INTO radusergroup (username, groupname, priority) VALUES (?, ?, ?)");
                $stmt->bind_param("sss", $code, $plan_name, $priority);
                $priority = "0";
                $stmt->execute();
                $stmt->close();

                $stmt = $conn->prepare("INSERT INTO userinfo (username, firstname, lastname, email, department, company, workphone, homephone, mobilephone, address, city, state, country, zip, notes, changeuserinfo, portalloginpassword, creationdate, creationby) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)");
                $stmt->bind_param("sssssssssssssssssss", $code, $firstname, $lastname, $email, $department, $company, $workphone, $homephone, $mobilephone, $address, $city, $state, $country, $zip, $notes, $changeuserinfo, $portalloginpassword, $now, $creationby);
                $lastname = '';
                $email = '';
                $department = '';
                $company = '';
                $workphone = '';
                $homephone = '';
                $mobilephone = '';
                $address = '';
                $city = '';
                $state = '';
                $country = '';
                $zip = '';
                $notes = '';
                $changeuserinfo = '0';
                $portalloginpassword = '';
                $creationby = 'administrator';
                $stmt->execute();
                $stmt->close();

                $stmt = $conn->prepare("INSERT INTO userbillinfo (username, planName, contactperson, company, email, phone, address, city, state, country, zip, paymentmethod, cash, creditcardname, creditcardnumber, creditcardverification, creditcardtype, creditcardexp, notes, changeuserbillinfo, lead, coupon, ordertaker, billstatus, nextinvoicedue, billdue, postalinvoice, faxinvoice, emailinvoice, creationdate, creationby) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)");
                $stmt->bind_param("sssssssssssssssssssssssssssssss", $code, $plan_name, $contactperson, $company, $email, $phone, $address, $city, $state, $country, $zip, $paymentmethod, $cash, $creditcardname, $creditcardnumber, $creditcardverification, $creditcardtype, $creditcardexp, $notes, $changeuserbillinfo, $lead, $coupon, $ordertaker, $billstatus, $nextinvoicedue, $billdue, $postalinvoice, $faxinvoice, $emailinvoice, $now, $creationby);
                $contactperson = '';
                $company = '';
                $email = '';
                $phone = '';
                $address = '';
                $city = '';
                $state = '';
                $country = '';
                $zip = '';
                $paymentmethod = '';
                $cash = '';
                $creditcardname = '';
                $creditcardnumber = '';
                $creditcardverification = '';
                $creditcardtype = '';
                $creditcardexp = '';
                $notes = '';
                $changeuserbillinfo = '0';
                $lead = '';
                $coupon = '';
                $ordertaker = '';
                $billstatus = '';
                $nextinvoicedue = '0';
                $billdue = '0';
                $postalinvoice = '';
                $faxinvoice = '';
                $emailinvoice = '';
                $creationby = 'administrator';
                $stmt->execute();
                $stmt->close();

                $conn->commit();

                echo "<script>window.location.href = 'mac_binding.php';</script>";
            }

        } catch (Exception $e) {
            $conn->rollback();
            echo "<script>window.location.href = 'add_mac.php?error=Error: " . addslashes($e->getMessage()) . "';</script>";
        }
    } else {
        echo "<script>window.location.href = 'add_mac.php?error=Semua data harus diisi.';</script>";
    }

    $conn->close();
}
?>
</body>
</html>