<?php
require 'data/pdo.php';

session_start();

if ($_SERVER["REQUEST_METHOD"] == "POST") {
    $username = $_POST['username'];
    $password = $_POST['password'];

    $stmt = $pdo->prepare("SELECT password FROM operators WHERE username = ?");
    $stmt->execute([$username]);
    $user = $stmt->fetch();

    if ($user && $user['password'] === $password) {
        $_SESSION['username'] = $username;
        header("Location: ./index.php");
        exit();
    } else {
        $_SESSION['error'] = "Username atau password salah.";
        header("Location: login.php");
        exit();
    }
}
?>

<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1">
    <title>RadiusMonitor | Login</title>
    <link rel="stylesheet" href="../../dist/login/bootstrap.min.css">
    <link rel="stylesheet" href="../../dist/login/all.min.css">
</head>

<body class="hold-transition login-page">
    <div class="login-box">
        <div class="login-logo">
            RadiusMonitor
        </div>
        <div class="login-box-body">
            <?php
            session_start();
            if (isset($_SESSION['error'])) {
                echo '<div class="alert alert-danger">' . $_SESSION['error'] . '</div>';
                unset($_SESSION['error']);
            }
            ?>
            <form action="./login.php" method="post">
                <div class="form-group has-feedback">
                    <input type="text" required class="form-control" name="username" placeholder="Username" autocomplete="username">
                    <span class="fas fa--user form-control-feedback"></span>
                </div>
                <div class="form-group has-feedback">
                    <input type="password" required class="form-control" name="password" placeholder="Password">
                    <span class="fas fa--lock form-control-feedback"></span>
                </div>
                <button type="submit" class="btn btn-primary btn-block btn-flat">Login</button>
            </form>
        </div>
    </div>
    <script src="../../dist/login/jquery-3.5.1.slim.min.js"></script>
    <script src="../../dist/login/popper.min.js"></script>
    <script src="../../dist/login/bootstrap.min.js"></script>
</body>

</html>

