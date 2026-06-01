<?php

function getEnvs($env) {

    global $ldaprdn, $ldappass, $basedn, $server_name, $port;

    if ($env == "DEV") {

    $ldaprdn  = 'cn=admin,ou=admin,o=vwa';     // ldap rdn or dn
    $ldappass = 'password';  // associated password
    $server_name="172.29.2.135"; 
    $port="389"; 
    $basedn = "ou=extranet,o=groups";


    } else if ($env == "TEST") {

    $ldaprdn  = 'cn=admin,ou=admin,o=vwa';     // ldap rdn or dn
    $ldappass = 'password';  // associated password
    $server_name="172.29.2.235"; 
    $port="389"; 
    $basedn = "ou=extranet,o=groups";


    } else if ($env == "PROD"){

    $ldaprdn  = 'cn=grpadmin,ou=admin,o=vwa';     // ldap rdn or dn
    $ldappass = '21JumpSt';  // associated password
    $server_name="172.29.2.203"; 
    $port="389"; 
    $basedn = "ou=extranet,o=groups";

    } else {

    ?><script>alert("Cant find env");</script> <?php

    }

}



function ldapSearch($env, $query, $context, $attributes) {

	/* Declaration LDAP variables*/ 
	
	global $ldaprdn, $ldappass, $basedn, $server_name, $port;

	getEnvs($env);

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
		
			$sr=ldap_search($ds, $context, $query, $attributes);

			$info = ldap_get_entries($ds, $sr);
		
			return $info;	
		}
	}


}

function ldapModify_add($env, $modifyDN, $entry) {



	/* Declaration LDAP variables*/ 
	
	global $ldaprdn, $ldappass, $server_name, $port;

	getEnvs($env);

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

function ldapModify_replace($env, $modifyDN, $entry) {

	/* Declaration LDAP variables*/ 
	
	global $ldaprdn, $ldappass, $server_name, $port;

	getEnvs($env);

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
