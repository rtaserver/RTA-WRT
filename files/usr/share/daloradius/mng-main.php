<?php
	include ("library/checklogin.php");
    $operator = $_SESSION['operator_user'];
        
	include_once('library/config_read.php');
    $log = "visited page: ";

	//setting values for the order by and order type variables
	isset($_REQUEST['orderBy']) ? $orderBy = $_REQUEST['orderBy'] : $orderBy = "radacctid";
	isset($_REQUEST['orderType']) ? $orderType = $_REQUEST['orderType'] : $orderType = "asc";
	isset($_REQUEST['usernameOnline']) ? $usernameOnline = $_GET['usernameOnline'] : $usernameOnline = "%";	
	
?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en">
<head>
<title>daloRADIUS</title>
<meta http-equiv="content-type" content="text/html; charset=utf-8" />
<link rel="stylesheet" href="css/1.css" type="text/css" media="screen,projection" />

</head>
 
 
<?php include "menu-mng-users.php"; ?>		
		
		<div id="contentnorightbar">
			<h2 id="Intro"><a href="#"><?php echo t("Intro", "mngmain.php"); ?></a></h2>
		
	<?php

	include 'library/opendb.php';
	include 'include/management/pages_common.php';
	include 'include/management/pages_numbering.php';		// must be included after opendb because it needs to read the CONFIG_IFACE_TABLES_LISTING variable from the config file

        // setup php session variables for exporting
        $_SESSION['reportTable'] = $configValues['CONFIG_DB_TBL_RADACCT'];
        $_SESSION['reportQuery'] = " WHERE (AcctStopTime IS NULL OR AcctStopTime = '0000-00-00 00:00:00') AND (UserName LIKE '".$dbSocket->escapeSimple($usernameOnline)."%')";
        $_SESSION['reportType'] = "reportsOnlineUsers";
	
	//orig: used as maethod to get total rows - this is required for the pages_numbering.php page
	$sql = "SELECT ".$configValues['CONFIG_DB_TBL_RADACCT'].".Username, ".$configValues['CONFIG_DB_TBL_RADACCT'].".FramedIPAddress,
			".$configValues['CONFIG_DB_TBL_RADACCT'].".CallingStationId, ".$configValues['CONFIG_DB_TBL_RADACCT'].".AcctStartTime,
			".$configValues['CONFIG_DB_TBL_RADACCT'].".AcctSessionTime, ".$configValues['CONFIG_DB_TBL_RADACCT'].".NASIPAddress,
			".$configValues['CONFIG_DB_TBL_RADACCT'].".CalledStationId, ".$configValues['CONFIG_DB_TBL_RADACCT'].".AcctSessionId FROM ".
			$configValues['CONFIG_DB_TBL_RADACCT']." WHERE (".$configValues['CONFIG_DB_TBL_RADACCT'].".AcctStopTime IS NULL OR ". 
			$configValues['CONFIG_DB_TBL_RADACCT'].".AcctStopTime = '0000-00-00 00:00:00') AND ".
			" (".$configValues['CONFIG_DB_TBL_RADACCT'].".Username LIKE '".$dbSocket->escapeSimple($usernameOnline)."%')";
	$res = $dbSocket->query($sql);
	$numrows = $res->numRows();


	/* we are searching for both kind of attributes for the password, being User-Password, the more
	   common one and the other which is Password, this is also done for considerations of backwards
	   compatibility with version 0.7        */

	   
	$sql = "SELECT ".$configValues['CONFIG_DB_TBL_RADACCT'].".Username, ".$configValues['CONFIG_DB_TBL_RADACCT'].".FramedIPAddress,
			".$configValues['CONFIG_DB_TBL_RADACCT'].".CallingStationId, ".$configValues['CONFIG_DB_TBL_RADACCT'].".AcctStartTime,
			".$configValues['CONFIG_DB_TBL_RADACCT'].".AcctSessionTime, ".$configValues['CONFIG_DB_TBL_RADACCT'].".NASIPAddress, 
			".$configValues['CONFIG_DB_TBL_RADACCT'].".CalledStationId, ".$configValues['CONFIG_DB_TBL_RADACCT'].".AcctSessionId, 
			".$configValues['CONFIG_DB_TBL_RADACCT'].".AcctInputOctets AS Upload,
			".$configValues['CONFIG_DB_TBL_RADACCT'].".AcctOutputOctets AS Download,
			".$configValues['CONFIG_DB_TBL_DALOHOTSPOTS'].".name AS hotspot, 
			".$configValues['CONFIG_DB_TBL_RADNAS'].".shortname AS NASshortname, 
			".$configValues['CONFIG_DB_TBL_DALOUSERINFO'].".Firstname AS Firstname, 
			".$configValues['CONFIG_DB_TBL_DALOUSERINFO'].".Lastname AS Lastname".
			" FROM ".$configValues['CONFIG_DB_TBL_RADACCT'].
		" LEFT JOIN ".$configValues['CONFIG_DB_TBL_DALOHOTSPOTS']." ON (".$configValues['CONFIG_DB_TBL_DALOHOTSPOTS'].".mac = ".
		$configValues['CONFIG_DB_TBL_RADACCT'].".CalledStationId)".
		" LEFT JOIN ".$configValues['CONFIG_DB_TBL_RADNAS']." ON (".$configValues['CONFIG_DB_TBL_RADNAS'].".nasname = ".
		$configValues['CONFIG_DB_TBL_RADACCT'].".NASIPAddress)".
		" LEFT JOIN ".$configValues['CONFIG_DB_TBL_DALOUSERINFO']." ON (".$configValues['CONFIG_DB_TBL_RADACCT'].".Username = ".
		$configValues['CONFIG_DB_TBL_DALOUSERINFO'].".Username)".
		" WHERE (".$configValues['CONFIG_DB_TBL_RADACCT'].".AcctStopTime IS NULL OR ".
		$configValues['CONFIG_DB_TBL_RADACCT'].".AcctStopTime = '0000-00-00 00:00:00') AND (".$configValues['CONFIG_DB_TBL_RADACCT'].".Username LIKE '".$dbSocket->escapeSimple($usernameOnline)."%')".
		" ORDER BY $orderBy $orderType LIMIT $offset, $rowsPerPage";
	$res = $dbSocket->query($sql);
	$logDebugSQL = "";
	$logDebugSQL .= $sql . "\n";

	/* START - Related to pages_numbering.php */
	$maxPage = ceil($numrows/$rowsPerPage);
	/* END */
	
	if ($numrows > 0) {
		echo '
		<style>
				.responsive {
				  width: 100%;
				  height: auto;
				}
				h5 { 
					text-align: center;    
				}
				.row {
				  --bs-gutter-x: 1.5rem;
				  --bs-gutter-y: 0;
				  display: flex;
				  flex-wrap: wrap;
				}
				.card-body {
				  flex: 1 1 auto;
				  padding: 2px;
				  color: #444;
				}
				.row-cols-2 > * {
				  flex: 0 0 auto;
				  width: 50%;
				}
				.col-8 {
				  flex: 0 0 auto;
				  width: 66.66666667%;
				}
				.col-4 {
				  flex: 0 0 auto;
				  width: 33.33333333%;
				}
				</style>
				<br>
				<div class="row row-cols-2 g-1">	
				  <div class="col-6">
					<div class="card-body">
						<h5> Traffic Download </h5>
						<a type="button" class="btn btn-light btn-sm" href="library/graphs-alltime-users-data.php?category=download&type=%s&size=%s\">
							<img class="responsive" src="library/graphs-alltime-users-data.php?category=download&type=%s&size=%s\" />
						</a>
					</div>
				  </div>
				  
				  <div class="col-6">
					<div class="card-body">
						<h5> Traffic Upload </h5>
						<a type="button" class="btn btn-light btn-sm" href="library/graphs-alltime-users-data.php?category=upload&type=%s&size=%s\">
							<img class="responsive" src="library/graphs-alltime-users-data.php?category=upload&type=%s&size=%s\" />
						</a>
					</div>
				  </div>
				</div>
				<br>
		';
		
		echo "<form name='usersonline' method='get' >";

		echo "<table border='0' class='table1'>\n";

		if ($orderType == "asc") {
				$orderTypeNextPage = "desc";
		} else  if ($orderType == "desc") {
				$orderTypeNextPage = "asc";
		}
					
		echo "<thread> <tr>
			<th scope='col'>
			<a title='Sort' class='novisit' href=\"" . $_SERVER['PHP_SELF'] . "?usernameOnline=$usernameOnline&orderBy=username&orderType=$orderTypeNextPage\">
			".t('all','Username'). "</a>
			</th>
			
			<th scope='col'>
			<a title='Sort' class='novisit' href=\"" . $_SERVER['PHP_SELF'] . "?usernameOnline=$usernameOnline&orderBy=framedipaddress&orderType=$orderTypeNextPage\">
			".t('all','IPAddress')."</a>
			</th>
			
			<th scope='col'>
			<a title='Sort' class='novisit' href=\"" . $_SERVER['PHP_SELF'] . "?usernameOnline=$usernameOnline&orderBy=callingstationid&orderType=$orderTypeNextPage\">
			".t('all','MACAddress')."</a>
			</th>

			<th scope='col'>
			<a title='Sort' class='novisit' href=\"" . $_SERVER['PHP_SELF'] . "?usernameOnline=$usernameOnline&orderBy=acctstarttime&orderType=$orderTypeNextPage\">
			".t('all','StartTime')."</a>
			</th>

			<th scope='col'>
			<a title='Sort' class='novisit' href=\"" . $_SERVER['PHP_SELF'] . "?usernameOnline=$usernameOnline&orderBy=acctsessiontime&orderType=$orderTypeNextPage\">
			".t('all','TotalTime')."</a>
			</th>


			<th scope='col'>
			<a title='Sort' class='novisit' href=\"" . $_SERVER['PHP_SELF'] . "?usernameOnline=$usernameOnline&orderBy=nasipaddress&orderType=$orderTypeNextPage\">
				".t('all','NASIPAddress')."
			</th>

			<th scope='col'>
			<a title='Sort' class='novisit' href=\"" . $_SERVER['PHP_SELF'] . "?usernameOnline=$usernameOnline&orderBy=Download&orderType=$orderTypeNextPage\">
				".t('all','Download')."
			</th>
			
			<th scope='col'>
			<a title='Sort' class='novisit' href=\"" . $_SERVER['PHP_SELF'] . "?usernameOnline=$usernameOnline&orderBy=Upload&orderType=$orderTypeNextPage\">
				".t('all','Upload')."
			</th>
			
			<th scope='col'>
			<a title='Sort' class='novisit' href=\"" . $_SERVER['PHP_SELF'] . "?usernameOnline=$usernameOnline&orderBy=TotalTraffic&orderType=$orderTypeNextPage\">
				".t('all','TotalTraffic')."
			</th>		
			

		</tr> </thread>";

		while($row = $res->fetchRow(DB_FETCHMODE_ASSOC)) {

			$username = $row['Username'];
			$ip = $row['FramedIPAddress'];
			$usermac = $row['CallingStationId'];
			$start = $row['AcctStartTime'];
			$nasip = $row['NASIPAddress'];
			$nasmac = $row['CalledStationId'];
			$hotspot = $row['hotspot'];
			$nasipaddress = $row['NASIPAddress'];
			$acctsessionid = $row['AcctSessionId'];
			$name = $row['Firstname'] . " " . $row['Lastname'];		
			$upload = toxbyte($row['Upload']);
			$download = toxbyte($row['Download']);
			$traffic = toxbyte($row['Upload']+$row['Download']);
			$totalTime = time2str($row['AcctSessionTime']);

			echo "<tr>
					<td><center>$username</td>
					<td><center>$ip</td>
					<td><center>$usermac</td>
					<td><center>$start </td>
					<td><center>$totalTime </td>
					<td><center>$nasipaddress</td>
					<td><center>$upload </td>
					<td><center>$download </td>
					<td><center>$traffic </td>
			</tr>";
		}

			echo "
				<tfoot>
					<tr>
				<th colspan='10' align='left'>
			";
			setupLinks($pageNum, $maxPage, $orderBy, $orderType, "&usernameOnline=$usernameOnline");
			echo "
				</th>
					</tr>
				</tfoot>
			";
		
		echo "</table>";
	} 
	
	include 'library/closedb.php';
		
?>
			<?php include "include/config/logging.php"; ?>	
		</div>
		<div id="footer">
		<?php include "page-footer.php"; ?>
		</div>
	</div>
</div>
</body>
</html>
