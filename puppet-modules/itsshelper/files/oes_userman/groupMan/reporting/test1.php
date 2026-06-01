
<?php

ini_set('max_execution_time', 300);

main ('cn=aaron sayer,ou=active,ou=vwa,ou=workforce,o=communities', 'dev');


function Main($adminDN, $env){
	setEnv($env);
	$adminInfo = listUsers($adminDN);
	
	echo "Result $adminInfo <BR>";

	foreach ($adminInfo[0]["groupmembership"] as &$adminGroup) {

	  
	  echo "adminGroup:$adminGroup<BR>";
	  //echo "adminGroup SubStr:".substr($adminGroup, 0, 9)."\n";

	  //if (substr($adminGroup, 0, 9) == "cn=ADMAPP") {

	 //     $admApps[] = $adminGroup;
	      
	 // }

	}

	
}

function setEnv($env) {

	// Declare globals

	global 	$ldaprdn, $ldappass, $server_name, $port;


	switch ($env) {
		case "dev":

			$ldaprdn  = 'cn=admin,o=admin';     // ldap rdn or dn
			$ldappass = 'password';  // associated password
			$server_name="172.29.2.138"; 
			$port="389"; 
			break;
		case "test":

			$ldaprdn  = 'cn=admin,o=admin';     // ldap daterdn or dn
			$ldappass = 'password';  // associated password"
			$server_name="172.29.2.237"; 
			$port="389";     
			break;
			
			
	}

}



function listUsers($adminDN) {


	global	$ldaprdn, $ldappass ,$server_name, $port;

	//$basedn = "ou=active,ou=vwa,ou=Workforce,o=communities";
	$basedn = $adminDN;
	$attributes = array('cn', 'surname', 'givenname', 'groupmembership');

	$query = "(cn=*)";

	// connect to ldap server
	$ds = ldap_connect($server_name, $port)
	or die("Could not connect to LDAP server.");
	
	if ($ds) {
	
		// Set search limit to 100
		ldap_set_option($ds, LDAP_OPT_SIZELIMIT, 2000);

		// binding to ldap server
		$ldapbind = ldap_bind($ds, $ldaprdn, $ldappass);
		
		
		// verify binding
		if ($ldapbind) {
		
			$sr=ldap_search($ds, $basedn, $query, $attributes);
			
			$info = ldap_get_entries($ds, $sr);
		
			return $info;	
		}
	}


}


function buildAdminProfile($adminDN) {


	global	$ldaprdn, $ldappass ,$server_name, $port;

	//$basedn = "ou=active,ou=vwa,ou=Workforce,o=communities";
	$basedn = $adminDN;
	$attributes = array('cn', 'surname', 'givenname', 'groupmembership');

	$query = "(cn=*)";

	// connect to ldap server
	$ds = ldap_connect($server_name, $port)
	or die("Could not connect to LDAP server.");
	
	if ($ds) {
	
		// Set search limit to 100
		ldap_set_option($ds, LDAP_OPT_SIZELIMIT, 1000);

		// binding to ldap server
		$ldapbind = ldap_bind($ds, $ldaprdn, $ldappass);
		
		
		// verify binding
		if ($ldapbind) {
		
			$sr=ldap_search($ds, $basedn, $query, $attributes);
			
			$info = ldap_get_entries($ds, $sr);
		
			return $info;	
		}
	}


}
?>