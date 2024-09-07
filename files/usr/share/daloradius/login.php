<?php
/*
 *******************************************************************************
 * daloRADIUS - RADIUS Web Platform
 * Copyright (C) 2007 - Liran Tal <liran@enginx.com> All Rights Reserved.
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 2
 * of the License, or (at your option) any later version.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
 *
 *******************************************************************************
 *
 * Authors:	Liran Tal <liran@enginx.com>
 *
 *******************************************************************************
 */

include_once("library/sessions.php");
dalo_session_start();

if (array_key_exists('daloradius_logged_in', $_SESSION)
    && $_SESSION['daloradius_logged_in'] !== false) {
    header('Location: index.php');
    exit;
}

include("lang/main.php");

// ~ used later for rendering location select element
$onlyDefaultLocation = !(array_key_exists('CONFIG_LOCATIONS', $configValues)
                        && is_array($configValues['CONFIG_LOCATIONS'])
                        && count($configValues['CONFIG_LOCATIONS']) > 0);

?>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
    "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html lang="<?= $langCode ?>" xml:lang="<?= $langCode ?>"
    xmlns="http://www.w3.org/1999/xhtml">
    <head>
        <script src="library/javascript/pages_common.js"
            type="text/javascript"></script>
        <title>daloRADIUS</title>
        <meta http-equiv="content-type" content="text/html; charset=utf-8" />
        <link rel="stylesheet" href="css/1.css" type="text/css"
            media="screen,projection" />
        <link rel="stylesheet" href="css/style.css" type="text/css"
            media="screen,projection" />
           <link rel="shortcut icon" href="images/favicon.ico" />
    </head>

    <body onLoad="document.login.operator_user.focus()">
        <div id="#">
            <div id="#">
                <div id="#">
                    <br/>
                </div><!-- #header -->
		
        
                <div id="main">
                    <h1 class="form-header"><?= t('text','LoginRequired') ?></h1>
                    </br><br>
                    
                     <form class="form-box" name="login" action="dologin.php" method="post">
                            
                        <label for="operator_user">Username</label>
                        <input class="form-input" id="operator_user"
                            name="operator_user" value="administrator"
                            type="text" tabindex="1" />
                        
                        <label for="operator_pass">Password</label>
                        <input class="form-input" id="operator_pass"
                            name="operator_pass" value="mutiara"
                            type="password" tabindex="2" />
                        
                        </select>
                        <input class="form-submit" type="submit"
                            value="<?= t('text','LoginPlease') ?>" tabindex="4" />
                    </form>
                    
                  
                    
                    <?php
                        if (array_key_exists('operator_login_error', $_SESSION)
                            && $_SESSION['operator_login_error'] !== false) {
                    ?>
                    
                    <div id="inner-box">
                        <center><h3 class="text-title error-title">Error!</h3></center>
                        <center><?= t('messages','loginerror') ?> </center>
                    </div><!-- #inner-box -->
                    
                    <?php
                        }
                    ?>
                </div><!-- #main -->
            </div><!-- #innerwrapper -->
        </div><!-- #wrapper -->
    </body>
</html>
