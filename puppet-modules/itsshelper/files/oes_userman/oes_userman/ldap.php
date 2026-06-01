<?php





function ldapSearch($query, $baseOverride, $attributes) {

	/* Declaration LDAP variables*/ 
	
	global $ldaprdn, $ldappass, $basedn, $server_name, $port;

$ldaprdn  = 'cn=admin,ou=admin,o=vwa';     // ldap rdn or dn
$ldappass = 'password';  // associated password
$server_name="172.29.2.235"; 
$port="389"; 
$basedn = "ou=extranet,o=groups";


	if ($baseOverride != "") {
		$ldapBasedn = $baseOverride;
	} else {
		$ldapBasedn = $basedn;
	}

	// connect to ldap server
	$ds = ldap_connect($server_name, $port)
	or die("Could not connect to LDAP server.");
	
	if ($ds) {
	
		// Set search limit to 100
		ldap_set_option($ds, LDAP_OPT_SIZELIMIT, 200);

		// binding to ldap server
		$ldapbind = ldap_bind($ds, $ldaprdn, $ldappass);
		
		
		// verify binding
		if ($ldapbind) {
		
			$sr=ldap_search($ds, $ldapBasedn, $query, $attributes);
echo $ldapBasedn." | ".$query." | ".$attributes[0];
			$info = ldap_get_entries($ds, $sr);
		
			return $info;	
		}
	}


}

function ldapModify_add($modifyDN, $entry) {



	/* Declaration LDAP variables*/ 
	
	global $ldaprdn, $ldappass, $server_name, $port;

	// connect to ldap server
	$ds = ldap_connect($server_name, $port)
	or die("Could not connect to LDAP server.");
	
	if ($ds) {

		// binding to ldap server
		$ldapbind = ldap_bind($ds, $ldaprdn, $ldappass);
		
		
		// verify binding
		if ($ldapbind) {
		
			$result=ldap_mod_add($ds, $modifyDN, $entry);
			
			return $result;
		}
	}


}

function ldapModify_replace($modifyDN, $entry) {

	/* Declaration LDAP variables*/ 
	
	global $ldaprdn, $ldappass, $server_name, $port;

	// connect to ldap server
	$ds = ldap_connect($server_name, $port)
	or die("Could not connect to LDAP server.");
	
	if ($ds) {

		// binding to ldap server
		$ldapbind = ldap_bind($ds, $ldaprdn, $ldappass);
		
		
		// verify binding
		if ($ldapbind) {
		
			$result=ldap_mod_replace($ds, $modifyDN, $entry);
			
			return $result;
		}
	}


}
