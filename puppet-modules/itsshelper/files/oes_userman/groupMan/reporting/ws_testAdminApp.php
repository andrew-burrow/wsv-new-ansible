<?php 

require_once("generateAppAdminReport_OAN_TEST.php");

$ret = generateAppAdminReport("aaron_sayer@itss.vic.gov.au", "cn=aaron sayer,ou=active,ou=vwa,ou=workforce,o=communities", "test");
//$ret = generateAppAdminReport("aaron_sayer@itss.vic.gov.au", "cn=aaron sayer,ou=active,ou=vwa,ou=workforce,o=communities", "prod");
//$ret = generateAppAdminReport("aaron_sayer@itss.vic.gov.au", "cn=John Reginato,ou=active,ou=vwa,ou=workforce,o=communities", "prod");
//$ret = generateAppAdminReport("aaron_sayer@itss.vic.gov.au", "cn=aa test1,ou=active,ou=vwa,ou=workforce,o=communities", "prod");
//$ret = generateAppAdminReport("aaron_sayer@itss.vic.gov.au", "cn=aaron sayer,ou=active,ou=vwa,ou=workforce,o=communities", "dev");
echo $ret

?> 



