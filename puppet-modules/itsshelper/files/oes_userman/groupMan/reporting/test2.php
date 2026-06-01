
<?php

ini_set('max_execution_time', 300);

$ldaprdn;
$ldappass;
$server_name;
$port;
$allUserInfo = array();

generateUsersAppList ('cn=aaron sayer,ou=active,ou=vwa,ou=workforce,o=communities', 'test');


function generateUsersAppList($adminDN, $env){

	$fn = 'generateAppAdminReport.log';

	$fh = fopen($fn, "w") or die("can't open file");
	fwrite($fh, ":". date("ymdHms")." : ".$adminDN." : ".$env." : ");
	fclose($fh);

	setEnv($env);

	$adminInfo = buildAdminProfile($adminDN);

	$admApps = buildAppAdminGroups($adminInfo);

	$appInfo = buildAppProfiles($admApps);
	

	while (list($key, $value) = each($appInfo)) {

	    echo $value["appName"], $format_row_left."<BR>";
	    echo $value["appRole"], $format_row_left."<BR>";
	    echo $value["appUser"], $format_row_left."<BR>";
	    echo $value["userCompany"], $format_row_left."<BR>";
	    echo $value["loginTime"], $format_row_left."<BR>";
	    echo $value["loginDisabled"], $format_row_left."<BR>";

	}
	





	//echo $adminInfo."<BR>;

	//$xlsFile = generateXSLReport($appInfo, $adminDN);

	




	//date_default_timezone_set('America/Toronto');
	//date_default_timezone_set(date_default_timezone_get());
	
	/*include_once('lib/phpmailer/class.phpmailer.php');
	
	$mail             = new PHPMailer();
	$body             = 'Your requested report is attached.

				';
	$body             = eregi_replace("[\]",'',$body);
	
	$mail->IsSendmail(); // telling the class to use SendMail transport
	$mail->FromName   = "donotreply";
	$mail->From       = "donotreply@worksafe.vic.gov.au";
	$mail->Subject    = "Worksafe Portal Application Admin Report.";
	$mail->Body = $body;
	$mail->AddAddress($email);

	$mail->AddAttachment($xlsFile);
	
	if(!$mail->Send()) {
		throw new SoapFault("Server","Unknown Symbol.");
	} else {
		if(isset($htmlFile)) {

			unlink($htmlFile);
		}
		if(isset($xlsFile)) {

			unlink($xlsFile);
		}
	}*/

	

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

function buildAppAdminGroups($adminInfo) {


	global	$ldaprdn, $ldappass ,$server_name, $port;

	$admApps = array();

	foreach ($adminInfo[0]["groupmembership"] as &$adminGroup) {

	  if (substr($adminGroup, 0, 9) == "cn=ADMAPP") {

	      $admApps[] = $adminGroup;
	      
	  }

	}

	return $admApps;

}

function buildAppProfiles($admApps) {


	global	$ldaprdn, $ldappass ,$server_name, $port, $allUserInfo;

	$allUserInfo = array ();
	$allAppInfo = array ();


	//$allUserInfo = array (array("dn" => "cn=Rachel Pike,ou=External Parties,o=Communities"));
	

	foreach ($admApps as &$app) {

	    //echo "<b>".$app."</B><BR>";
	    $appPageInfo = getApplicationPages($app);

	    for ($i=0; $i<$appPageInfo["count"]; $i++) {
		//echo "<b>".$appPageInfo[$i]."</B><BR>";

		for ($x=0; $x<$appPageInfo[$i]["auvwaapplicationrole"]["count"]; $x++) {
		    echo "<b>".$appPageInfo[$i]["cn"][$x]."</B>/";

		    $appRoleInfo = getRoleInfo($appPageInfo[$i]["auvwaapplicationrole"][$x]);

		    for ($y=0; $y<$appRoleInfo["count"]; $y++) {

			for ($z=0; $z<$appRoleInfo[$y]["member"]["count"]; $z++) {
			    
			  //Check for member in all users array

			  $tmpUserDN = $appRoleInfo[$y]["member"][$z];

			  if (!(array_key_exists($tmpUserDN, $allUserInfo))) {

			     

			      $tmpUserInfo = getUserInfo($tmpUserDN);

			      $logindate = $tmpUserInfo[0]["logintime"][0];
			      $logintime = "Never";			


			      if ($logindate != "") {
		      
				      $logintime = substr($logindate, 0, 4) . "-" . substr($logindate, 4, 2) . "-" . substr($logindate, 6, 2);
			      }

			      
                              $createdate = $tmpUserInfo[0]["createtimestamp"][0];
			      $createtime = substr($createdate, 0, 4) . "-" . substr($createdate, 4, 2) . "-" . substr($createdate, 6, 2);


			      $tmpUserCN = explode("=",$tmpUserDN);
			      
			      $tmpUserCompany = explode(",",$tmpUserInfo[0]["auvwausercompanylink"][0]);

			      $tmpUser = array("dn" => $tmpUserDN, "cn" => substr($tmpUserCN[1],0,-3), "company" => substr($tmpUserCompany[0],7), "loginDisabled" => $tmpUserInfo[0]["logindisabled"][0], "loginTime" => $logintime, "createTime" => $createtime, "AUVWAshortName" => $tmpUserInfo[0]["auvwashortname"][0]);

			      $allUserInfo[$tmpUserDN] = $tmpUser;

			  }


			$allAppInfoTmp = array("appName" => $appPageInfo[$i]["description"][0], "appRole" => $appRoleInfo[$y]["description"][0], "appUser" => $allUserInfo[$tmpUserDN]["cn"], "userCompany" => $allUserInfo[$tmpUserDN]["company"], "loginDisabled" => $allUserInfo[$tmpUserDN]["loginDisabled"], "loginTime" => $allUserInfo[$tmpUserDN]["loginTime"], "createTime" => $allUserInfo[$tmpUserDN]["createTime"], "AUVWAshortName" => $allUserInfo[$tmpUserDN]["AUVWAshortName"]);

			$tmpAppName = $allAppInfo[$appPageInfo[$i]["description"][0]];

			$allAppInfo[] = $allAppInfoTmp;

			//echo $allAppInfo[$tmpAppName]["appName"]."<br>";

			}
		    }
		}			
	    }
	}

      echo "<p><h1>Report Generation Complete</h1></p>";

      return $allAppInfo;

}


function getApplicationPages($admappDN) {

	global	$ldaprdn, $ldappass ,$server_name, $port;

	$basedn = "ou=extranet,o=groups";
	$attributes = array('auvwaapplicationrole', 'description', 'cn', 'member');

	$query = "(auvwaapplicationadmin=".$admappDN.")";

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

function getGroupInfo($application) {

	global	$ldaprdn, $ldappass ,$server_name, $port;

	$basedn = "ou=extranet,o=groups";
	$attributes = array('auvwaapplicationrole', 'description', 'cn');

	$query = "(cn=". $application.")";

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


function getRoleInfo($roleDN) {

	global	$ldaprdn, $ldappass ,$server_name, $port;

	$basedn = $roleDN;
	$attributes = array("description", "auvwagroupcompanylink", "cn", "member","company");

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

function getUserInfo($UserDN) {

	global	$ldaprdn, $ldappass ,$server_name, $port;

	$basedn = $UserDN;
	$attributes = array("cn", "auvwausercompanylink", "logintime","logindisabled");

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

function cmp($a, $b)
{
    return strcmp($a["dn"], $b["dn"]);
}

?>
