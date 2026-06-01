<?php 

require_once("generateAppAdminReport.php");

ini_set("soap.wsdl_cache_enabled", "0"); // disabling WSDL cache 
$server = new SoapServer("ws_generateAppAdminReport.wsdl"); 
$server->addFunction("generateAppAdminReport"); 
$server->handle();

?> 
