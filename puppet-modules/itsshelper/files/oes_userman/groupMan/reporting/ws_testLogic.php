<?php 

require_once("generatereport.php");

$ret = generateReport("rowan_truscott@itss.vic.gov.au", "Lander & Rogers", "cn=CMP-Lander & Rogers,ou=extranet,o=groups", "prod", "xls|html|");

echo $ret

?> 



