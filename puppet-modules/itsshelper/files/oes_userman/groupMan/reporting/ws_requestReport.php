<?php 
  $client = new SoapClient("ws_generateReport.wsdl"); 
  try { 
    echo "<pre>\n"; 
    print($client->generateReport("rowan_truscott@itss.vic.gov.au", "Allianz", "cn=CMP-Allianz,ou=extranet,o=groups", "dev", "html|")); 
    echo "\n"; 
     } catch (SoapFault $exception) { 
    echo $exception;       
  } 
?> 
