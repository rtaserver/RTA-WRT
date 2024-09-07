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
    <title>RadiusMonitor | Add Plans</title><!--begin::Primary Meta Tags-->
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
<h3 class="mb-0">Edit Plan</h3>
</div> <!--end::Row-->
</div> <!--end::Container-->
<?php
include("data/db.php");

if (!isset($_GET['id'])) {
    echo "<script>alert('Plan ID is missing!'); window.location.href = 'list_plan.php';</script>";
    exit();
}

$plan_id = $_GET['id'];

$stmt = $conn->prepare("SELECT 
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
WHERE bp.id = ?");
$stmt->bind_param("i", $plan_id);
$stmt->execute();
$result = $stmt->get_result();
$plan = $result->fetch_assoc();

if (!$plan) {
    echo "<script>alert('Plan not found!'); window.location.href = 'list_plan.php';</script>";
    exit();
}

?>
<div class="col-sm-12 col-md-12">
    <div class="panel panel-primary panel-hovered panel-stacked mb30">
        <div class="panel-heading">Edit Plan</div>
        <div class="panel-body">
            <form class="form-horizontal" method="post" role="form" action="./update_plan.php">
                <div class="form-group">
                    <label for="planName" class="col-md-2 control-label">Plan Name</label>
                    <div class="col-md-6">
                        <input type="text" class="form-control" id="planName_display" name="planName_display" maxlength="10" value="<?php echo htmlspecialchars($plan['planName']); ?>" disabled>
                        <input type="hidden" id="planName" name="planName" value="<?php echo htmlspecialchars($plan['planName']); ?>">
                    </div>
                </div>

                <div class="form-group">
                    <label class="col-md-2 control-label">Plan Type</label>
                    <div class="col-md-10">
                        <input type="radio" id="Unlimited" name="typebp" value="Unlimited" checked> Unlimited
                        <input type="radio" id="Limited" name="typebp" value="Limited"> Limited
                    </div>
                </div>
                
                <!-- Bagian untuk memilih Limit Type -->
                <div style="display:none;" id="Type">
                    <div class="form-group">
                        <label class="col-md-2 control-label">Limit Type</label>
                        <div class="col-md-10">
                            <input type="radio" id="Time_Limit" name="limit_type" value="Time_Limit" checked> Time Limit
                            <input type="radio" id="Data_Limit" name="limit_type" value="Data_Limit"> Data Limit
                            <input type="radio" id="Both_Limit" name="limit_type" value="Both_Limit"> Both Limit
                        </div>
                    </div>
                </div>
                
                <!-- Bagian untuk Time Limit -->
                <div style="display:none;" id="TimeLimit">
                    <div class="form-group">
                        <label for="profileTimeBankInput" class="col-md-2 control-label">Plan Duration</label>
                        <div class="col-md-4">
                            <input type="number" class="form-control" id="profileTimeBankInput" name="profileTimeBankInput" value="0" min="0">
                        </div>
                        <div class="col-md-2">
                            <select class="form-select" id="profileTimeBankSelect" name="profileTimeBankSelect">
                                <option value="M">Menit</option>
                                <option value="H">Jam</option>
                                <option value="D">Hari</option>
                            </select>
                        </div>
                    </div>
                </div>
                
                <!-- Bagian untuk Data Limit -->
                <div style="display:none;" id="DataLimit">
                    <div class="form-group">
                        <label for="data_limit" class="col-md-2 control-label">Data Limit</label>
                        <div class="col-md-4">
                            <input type="number" class="form-control" id="data_limit" name="data_limit" value="0" min="0">
                        </div>
                        <div class="col-md-2">
                            <select class="form-select" id="data_unit" name="data_unit">
                                <option value="MB">MB</option>
                                <option value="GB">GB</option>
                            </select>
                        </div>
                    </div>
                </div>
                
                <div class="form-group">
                    <label for="bw_name" class="col-md-2 control-label">Bandwidth</label>
                    <div class="col-md-6">
                        <select id="bw_name" name="bw_name" class="form-select">
                            <option value="">Select Bandwidth...</option>
                        </select>
                    </div>
                </div>

                <div class="form-group">
                    <label for="planCost" class="col-md-2 control-label">Plan Cost</label>
                    <div class="col-md-6">
                        <div class="input-group">
                            <span class="input-group-addon">Rp.</span>
                            <input type="number" id="planCost" class="form-control" name="planCost" value="<?php echo htmlspecialchars($plan['planCost']); ?>" min="0" required>
                        </div>
                    </div>
                </div>
                
                <div class="form-group">
                    <label for="shared" class="col-md-2 control-label">Shared Users</label>
                    <div class="col-md-6">
                        <input type="number" class="form-control" id="shared" name="shared" value="<?php echo htmlspecialchars($plan['Simultaneous_Use']); ?>">
                    </div>
                </div>
                
                <div class="form-group">
                    <label for="planTimeBankInput" class="col-md-2 control-label">Plan Validity</label>
                    <div class="col-md-4">
                        <input type="number" class="form-control" id="planTimeBankInput" name="planTimeBankInput" min="0">
                    </div>
                    <div class="col-md-2">
                        <select class="form-select" id="planTimeBankSelect" name="planTimeBankSelect">
                            <option value="M">Menit</option>
                            <option value="H">Jam</option>
                            <option value="D">Hari</option>
                        </select>
                    </div>
                </div>
                <div class="form-group">
                    <div class="col-md-offset-2 col-md-10">
                        <input type="hidden" id="planTimeBank" name="planTimeBank">
                        <input type="hidden" id="profileTimeBank" name="profileTimeBank">
                        <input type="hidden" id="dataLimit" name="dataLimit">
                        <input type="hidden" id="rate_down" name="rate_down">
                        <input type="hidden" id="rate_up" name="rate_up">
                        <button class="btn btn-primary" type="submit" name="updatebillplans" value="top">Update</button>
                        <a href="./list_plan.php" class="btn btn-default">Cancel</a>
                    </div>
                </div>
            </form>
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
document.addEventListener('DOMContentLoaded', function() {
    fetch('api/bandwidth.php')
        .then(response => response.json())
        .then(data => {
            let bwDropdown = document.getElementById('bw_name'); 

            if (Array.isArray(data.data)) {
                data.data.forEach(item => {
                    let option = document.createElement('option');
                    option.value = item.bw_name; // Misalkan 'bw_name' adalah nilai yang unik
                    option.textContent = item.bw_name; // Tampilkan nama bandwidth di dropdown
                    bwDropdown.appendChild(option);
                });

                bwDropdown.addEventListener('change', function() {
                    let selectedBw = bwDropdown.value;

                    let selectedItem = data.data.find(item => item.bw_name === selectedBw);

                    if (selectedItem) {
                        // Set nilai ke hidden input
                        document.getElementById('rate_down').value = selectedItem.rate_down || '';
                        document.getElementById('rate_up').value = selectedItem.rate_up || '';
                    }
                });
            } else {
                console.error('Format tidak sesuai.');
            }
        })
        .catch(error => console.error('Error:', error));
});
</script>
<script>
document.addEventListener("DOMContentLoaded", function() {
    function handlePlanTypeChange() {
        var planType = document.querySelector('input[name="typebp"]:checked');
        if (!planType) return; // Cek jika ada elemen yang dipilih

        var planTypeValue = planType.value;
        var limitTypeSection = document.getElementById('Type');
        var timeLimitSection = document.getElementById('TimeLimit');
        var dataLimitSection = document.getElementById('DataLimit');

        if (planTypeValue === 'Limited') {
            limitTypeSection.style.display = 'block';

            var limitType = document.querySelector('input[name="limit_type"]:checked');
            if (!limitType) return; // Cek jika ada elemen yang dipilih

            var limitTypeValue = limitType.value;

            if (limitTypeValue === 'Time_Limit') {
                timeLimitSection.style.display = 'block';
                dataLimitSection.style.display = 'none';
            } else if (limitTypeValue === 'Data_Limit') {
                timeLimitSection.style.display = 'none';
                dataLimitSection.style.display = 'block';
            } else if (limitTypeValue === 'Both_Limit') {
                timeLimitSection.style.display = 'block';
                dataLimitSection.style.display = 'block';
            }
        } else {
            limitTypeSection.style.display = 'none';
            timeLimitSection.style.display = 'none';
            dataLimitSection.style.display = 'none';
        }
    }

    // Tambahkan event listener untuk radio buttons
    document.querySelectorAll('input[name="typebp"]').forEach(function(radio) {
        radio.addEventListener('change', handlePlanTypeChange);
    });

    document.querySelectorAll('input[name="limit_type"]').forEach(function(radio) {
        radio.addEventListener('change', handlePlanTypeChange);
    });

    handlePlanTypeChange(); // Panggil fungsi ini sekali saat halaman dimuat untuk mengatur tampilan awal

    // Event listener untuk input dan select
    document.getElementById('planTimeBankInput').addEventListener('input', function() {
        calculatePlanBank();
    });

    document.getElementById('planTimeBankSelect').addEventListener('change', function() {
        calculatePlanBank();
    });
    
    document.getElementById('profileTimeBankInput').addEventListener('input', function() {
        calculateProfileBank();
    });

    document.getElementById('profileTimeBankSelect').addEventListener('change', function() {
        calculateProfileBank();
    });

    document.getElementById('data_limit').addEventListener('input', function() {
        calculateDataLimit();
    });

    document.getElementById('data_unit').addEventListener('change', function() {
        calculateDataLimit();
    });

    function calculatePlanBank() {
        let timeValue = parseFloat(document.getElementById('planTimeBankInput').value);
        let timeUnit = document.getElementById('planTimeBankSelect').value;
        let convertedValue;

        if (isNaN(timeValue)) {
            console.log('Invalid input for planTimeBankInput:', timeValue);
            return; // Stop execution if input is not valid
        }

        if (timeUnit === "M") {
            convertedValue = timeValue * 60; // Mengkonversi menit ke detik
        } else if (timeUnit === "H") {
            convertedValue = timeValue * 3600; // Mengkonversi jam ke detik
        } else if (timeUnit === "D") {
            convertedValue = timeValue * 86400; // Mengkonversi hari ke detik
        } else {
            console.log('Invalid time unit for planTimeBankSelect:', timeUnit);
            return;
        }

        // Set the calculated value to the hidden input
        document.getElementById('planTimeBank').value = convertedValue;
        console.log('planTimeBank value set to:', convertedValue); // Debugging line
    }

    function calculateProfileBank() {
        let timeValue = parseFloat(document.getElementById('profileTimeBankInput').value);
        let timeUnit = document.getElementById('profileTimeBankSelect').value;
        let convertedValue;

        if (isNaN(timeValue)) {
            console.log('Invalid input for profileTimeBankInput:', timeValue);
            return; // Stop execution if input is not valid
        }

        if (timeUnit === "M") {
            convertedValue = timeValue * 60; // Mengkonversi menit ke detik
        } else if (timeUnit === "H") {
            convertedValue = timeValue * 3600; // Mengkonversi jam ke detik
        } else if (timeUnit === "D") {
            convertedValue = timeValue * 86400; // Mengkonversi hari ke detik
        } else {
            console.log('Invalid time unit for profileTimeBankSelect:', timeUnit);
            return;
        }

        // Set the calculated value to the hidden input
        document.getElementById('profileTimeBank').value = convertedValue;
        console.log('profileTimeBank value set to:', convertedValue); // Debugging line
    }

    function calculateDataLimit() {
        let dataValue = parseFloat(document.getElementById('data_limit').value);
        let dataUnit = document.getElementById('data_unit').value;
        let convertedValue;

        if (isNaN(dataValue)) {
            console.log('Invalid input for data_limit:', dataValue);
            return; // Stop execution if input is not valid
        }

        if (dataUnit === "MB") {
            convertedValue = dataValue * 1048576; // Mengkonversi MB ke byte (1 MB = 1048576 bytes)
        } else if (dataUnit === "GB") {
            convertedValue = dataValue * 1073741824; // Mengkonversi GB ke byte (1 GB = 1073741824 bytes)
        } else {
            console.log('Invalid data unit for data_unit:', dataUnit);
            return;
        }

        // Set the calculated value to the hidden input
        document.getElementById('dataLimit').value = convertedValue;
        console.log('dataLimit value set to:', convertedValue); // Debugging line
    }

});
</script>
</body>
</html>