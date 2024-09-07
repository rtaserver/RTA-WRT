<?php
//PrintTickets by Maizil//
include('../../library/checklogin.php');
$cs = "0853-7268-7484";
$dnsname = "http://mutiara.net";
if (isset($_REQUEST['type']) && $_REQUEST['type'] == "batch") {
$format = $_REQUEST['format'];
$plan = $_REQUEST['plan'];
$accounts_temp = $_REQUEST['accounts'];
$accounts = explode("||", $accounts_temp);
include_once('../../library/opendb.php');
include_once('../management/pages_common.php');
$sql = "SELECT ".$configValues['CONFIG_DB_TBL_DALOBILLINGPLANS'].
".planCost AS planCost, ".$configValues['CONFIG_DB_TBL_DALOBILLINGPLANS'].".planTimeBank AS planTimeBank, ".
$configValues['CONFIG_DB_TBL_DALOBILLINGPLANS'].".planCurrency AS planCurrency ".
" FROM ".
$configValues['CONFIG_DB_TBL_DALOBILLINGPLANS'].
" WHERE ".$configValues['CONFIG_DB_TBL_DALOBILLINGPLANS'].".planName=".
" '$plan' ";
$res = $dbSocket->query($sql);
$row = $res->fetchRow(DB_FETCHMODE_ASSOC);
$ticketCurrency = $row['planCurrency'];
$ticketCost = $row['planCost'] ." " . $ticketCurrency;
$ticketTime = time2str($row['planTimeBank']);
printTicketsHTMLTable($accounts, $ticketCost, $ticketTime);}
function printTicketsHTMLTable($accounts, $ticketCost, $ticketTime) {
$output = "";
global $penyimpanan;
global $dnsname;
global $cs;
if ($ticketCost <= 500) {$color = "#4bde97";}
elseif ($ticketCost >= 1000 && $ticketCost <= 4000) {$color = "#e83e8c";}
elseif ($ticketCost >= 4000 && $ticketCost <= 24000) { $color = "#f74e07";}
elseif ($ticketCost >= 25000 && $ticketCost <= 49000) { $color = "#0f8d43";}
elseif ($ticketCost >= 50000 && $ticketCost <= 100000) { $color = "#9911b1";}
array_shift($accounts);
$trCounter = 0;
foreach($accounts as $userpass) {
list($user, $pass) = explode(",", $userpass);
$output .= "";?>
<title><?php echo $ticketTime ?></title>
<style type="text/css">.rotate {
vertical-align: center;
text-align: center;
font-size: 20px;}.rotate span {
-ms-writing-mode: tb-rl;
-webkit-writing-mode: vertical-rl;
writing-mode: vertical-rl;
transform: rotate(180deg);
white-space: nowrap;}
</style>
<table style="display: inline-block;border-collapse: collapse;border: 1px solid #666;margin: 2.5px;width: 210px;overflow:hidden;position:relative;padding: 1px;margin: 0px;border: 1px solid <?php echo $color;?>; background:; ">
<tr>
<td style="font-size: 13.5px; font-weight: bold; line white; color:#fff;background-color:<?php echo $color;?>; -webkit-print-color-adjust: exact;" class="rotate" rowspan="4"><span>Rp.<?php echo $ticketCost;?></span></td>
</div>
<td><center><span style="font-size: 13.5px;font-weight: bold;">𝗠𝗨𝗧𝗜𝗔𝗥𝗔<span style="color:<?php echo $color;?>;">𝗡𝗘𝗧</td>
<td style="" rowspan="4">
<img src="/daloradius/images/qrcode.png" style="border: 2px solid ' . $color . '; width: 65px; height: 65px;">
</td>
</tr>
<tr>
<?php if($mutiara_net=='up'){ ?>
<?php }else{ ?>
<td style="width: 100%; font-weight: bold; font-size: 18px; color:#111; text-align: center;"><?php echo $user;?></td>
<?php }?> 
</tr>
<tr>
<td style="font-weight: bold; font-size: 10px; color:#000000;"><center>Masa Aktif : <?php echo $ticketTime;?> 
</tr>
<tr>
<td style="font-weight: bold; font-size: 10px; color:#000000;"><center>CS : <?php echo $cs;?></td>
</tr>
</tbody>
</table> 
<?php } } ?> 