<?php

ini_set('max_execution_time', 900);

$ldaprdn;
$ldappass;
$server_name;
$port;

function _log($message) {


	$fn = 'generateReport.log';

	$fh = fopen($fn, "a") or die("can't open file");
	fwrite($fh, ":".$message);
	fclose($fh);

}


function generateReport($email, $company, $companyDN, $env, $reportType){

	$fn = 'generateReport.log';

	$fh = fopen($fn, "w") or die("can't open file");
	fwrite($fh, ":". date("ymdHms")." : ".$email." : ".$company." : ".$companyDN." : ".$env." : ".$reportType);
	fclose($fh);

	setEnv($env);

	$userInfo = buildCompanyUserProfile($companyDN);
		
	date_default_timezone_set('America/Toronto');
	//date_default_timezone_set(date_default_timezone_get());
	
	include_once('lib/phpmailer/class.phpmailer.php');
	
	$mail             = new PHPMailer();
	$body             = 'Your requested reports are attached.

				';
	$body             = eregi_replace("[\]",'',$body);
	
	$mail->IsSendmail(); // telling the class to use SendMail transport
	$mail->FromName   = "donotreply";
	$mail->From       = "donotreply@worksafe.vic.gov.au";
	$mail->Subject    = "Worksafe Portal User Report.";
	$mail->Body = $body;
	$mail->AddAddress($email);

	$reports = explode("|", $reportType);

	foreach ($reports as &$reportType) {
	
		switch ($reportType) {
	
			case "xls":
				$cmpCN = substr($companyDN, strpos($companyDN, "=")+1, strpos($companyDN, ",")-3);
				$groupInfo = buildCompanyGroupProfile($cmpCN);
				$xlsFile = generateXLSreport($company, $companyDN, $userInfo, $groupInfo);
				$mail->AddAttachment($xlsFile);
			break;
			case "html":
				$htmlFile = generateHTMLreport($company, $userInfo);		
				$mail->AddAttachment($htmlFile);
			break;
	
		}
	}
	
	if(!$mail->Send()) {
		throw new SoapFault("Server","Unknown Symbol.");
	} else {
		if(isset($htmlFile)) {

			unlink($htmlFile);
		}
		if(isset($xlsFile)) {

			unlink($xlsFile);
		}
	}

}


function setEnv($env) {

// Declare globals

global 	$ldaprdn, $ldappass, $server_name, $port;


switch ($env) {
	case "dev":

		$ldaprdn  = 'cn=admin,o=admin';     // ldap rdn or dn
		$ldappass = 'k00w33';  // associated password
		// $ldappass = 'password';  // associated password
		// $server_name="172.29.2.138";
		$server_name="172.29.2.234";
		$port="389"; 
    	break;

	case "test":

 		$ldaprdn  = 'cn=admin,o=admin';     // ldap daterdn or dn
		$ldappass = 'password';  // associated password
		// $server_name="172.29.2.237";
		$server_name="172.29.2.242";
		$port="389";     
	break;
	case "prod":

		$ldaprdn  = 'cn=uaaread,o=admin';     // ldap rdn or dn
		$ldappass = 'K616m6L';  // associated password
		// $server_name="172.29.2.80";
		$server_name="172.29.2.205";
		$port="389"; 
    	break;

}

}


function buildCompanyUserProfile($companyDN) {


	global	$ldaprdn, $ldappass ,$server_name, $port;

	//$basedn = "ou=active,ou=vwa,ou=Workforce,o=communities";
	$basedn = "o=communities";
	$attributes = array('cn', 'logindisabled', 'surname', 'givenname', 'groupmembership', 'logintime', 'mail', 'auvwaacctionuserid','auvwaaltuid','passwordexpirationtime');

	$query = "(AUVWAuserCompanyLink=".$companyDN.")";

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

function buildCompanyGroupProfile($company) {


	global	$ldaprdn, $ldappass ,$server_name, $port;

	$basedn = "ou=extranet,o=groups";
	$attributes = array('cn', 'auvwaapplicationpage');
	$query = "(cn=".$company.")";

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



function getGroupMembers($group) {


	global	$ldaprdn, $ldappass ,$server_name, $port;

	$basedn = "ou=extranet,o=groups";
	$attributes = array('cn', 'member', 'auvwagroupcompanylink');

	$query = "(cn=".$group.")";

	// connect to ldap server
	$ds = ldap_connect($server_name, $port)
	or die("Could not connect to LDAP server.");
	
	if ($ds) {
	
		
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

function getApplicationRoles($application) {

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

function getRoleInfo($role) {

	global	$ldaprdn, $ldappass ,$server_name, $port;

	$basedn = "ou=extranet,o=groups";
	$attributes = array("description", "auvwagroupcompanylink", "cn", "member");

	$query = "(cn=".$role.")";

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



function generateHTMLreport($company, $info) {


	$result = "<html><head><style>

		/* 

		*/
		
		table,td
		{
			border               : 1px solid #CCC;
			border-collapse      : collapse;
			font                 : small/1.5 \"Tahoma\", \"Bitstream Vera Sans\", Verdana, Helvetica, sans-serif;
			font-size	      : 12;
		}
		table
		{
			border                :none;
			border                :1px solid #CCC;
		}
		thead th,
		tbody th
		{
			background            : #FFF url(th_bck.gif) repeat-x;
		color                 : #666;  
			padding               : 5px 10px;
		border-left           : 1px solid #CCC;
		}
		tbody th
		{
		background            : #fafafb;
		border-top            : 1px solid #CCC;
		text-align            : left;
		font-weight           : normal;
		}
		tbody tr td
		{
			padding               : 5px 10px;
		color                 : #666;
		}
		tbody tr:hover
		{
		background            : #FFF url(tr_bck.gif) repeat;
		}
		
		tbody tr:hover td
		{
		color                 : #454545;
		}
		tfoot td,

		tfoot th
		{
		border-left           : none;
		border-top            : 1px solid #CCC;
			padding               : 4px;
		background            : #FFF url(foot_bck.gif) repeat;
		color                 : #666;
		}
		caption
		{
			text-align            : left;
			font-size             : 120%;
			padding               : 10px 0;
			color                 : #666;
		}
		table a:link
		{
			color                 : #666;
		}
		table a:visited
		{
			color                 : #666;
		}
		table a:hover
		{
			color                 : #003366;
			text-decoration       : none;
		}
		table a:active
		{
			color                 : #003366;
		}


	</style>

		<script type=\"text/javascript\"> 
		function dispHandle(obj) 
		{
		if (obj.style.display == \"none\")
		obj.style.display = \"\";
		else
		obj.style.display = \"none\";
		}
	</script>
	
	</head>
	<body>
	<table>
		<caption><b>Worksafe Portal User Report - ".$company."</b></caption>
		<thread>
				<tr>
					<th>User Name</th><th>Given Name</th><th>Surname</th><th>eMail Address</th><th>ACCtion ID</th></th><th>AIS User ID</th><th>Login Disabled</th><th>Last Login Date</th><th>Applications</th>
				</tr>
			     </thread>
	                     <tfoot>

				<tr>

					<th scope=\"row\">Total </th>

					<td colspan=\"4\">" .$info["count"]." Users</td>

				</tr>

			</tfoot>";
	

	for ($i=0; $i<$info["count"]; $i++) {
	
		$arrInfo[$i]["dn"] =  strtolower($info[$i]["dn"]);
		$arrInfo[$i]["cn"] =  $info[$i]["cn"][0];
		$arrInfo[$i]["givenname"] =  $info[$i]["givenname"][0];
		$arrInfo[$i]["surname"] =  $info[$i]["surname"][0];
		if ($info[$i]["logindisabled"][0] != "") {
			$arrInfo[$i]["logindisabled"] =  $info[$i]["logindisabled"][0];
		} else {
			$arrInfo[$i]["logindisabled"] =  "FALSE";
		}
		
		for ($x=0; $x<$info[$i]["groupmembership"]["count"]; $x++) {

			$arrInfo[$i]["groupmembership"][$x] =  $info[$i]["groupmembership"][$x];
		}
		
		$arrInfo[$i]["logintime"] =  $info[$i]["logintime"][0];
		$arrInfo[$i]["mail"] =  $info[$i]["mail"][0];
		$arrInfo[$i]["auvwaacctionuserid"] =  $info[$i]["auvwaacctionuserid"][0];
		$arrInfo[$i]["auvwaaltuid"] =  $info[$i]["auvwaaltuid"][0];


	
	
	}
	
	usort($arrInfo, "cmp");
		
	while (list($key, $value) = each($arrInfo)) {
	
		$result = $result . "<tr>\n";
		$result = $result . "<td>" . $value["cn"] ."</td>\n";
		$result = $result . "<td>" . $value["givenname"] ."</td>\n";
		$result = $result . "<td>" . $value["surname"] ."</td>\n";
		$result = $result . "<td>" . $value["mail"] ."</td>\n";
		$result = $result . "<td>" . $value["auvwaacctionuserid"] ."</td>\n";
		$result = $result . "<td>" . $value["auvwaaltuid"] ."</td>\n";
		if ($value["logindisabled"] == "TRUE") {
			$result = $result . "<td><font color=red>" . $value["logindisabled"] ."</font></td>\n";
		} else {
			$result = $result . "<td>" . $value["logindisabled"] ."</td>\n";
		}
		
		$logindate = $value["logintime"];
		$logintime = "Never";

		if ($logindate != "") {
	
			$logintime = substr($logindate, 0, 4) . "-" . substr($logindate, 4, 2) . "-" . substr($logindate, 6, 2);
		}

		$result = $result . "<td>" . $logintime ."</td>\n";
		$result = $result . "<td><a href=\"#\" onClick=\"dispHandle(div".$key.");return false;\">Show / Hide</a></td>\n";
		$result = $result . "</tr>\n";
		
		$result = $result . "<tr style=\"display:none\" id=\"div".$key."\"><td colspan=10>";
		$result = $result . "<div>
					<table>
					<thread>
						<th>Application</th><th>Role</th>
			     		</thread>";

		while (list($key1, $pageGroup) = each($value["groupmembership"])) {

 			if (strtolower(substr($pageGroup, 0, 7)) == "cn=page") {
		
				$appInfo = getApplicationRoles(substr($pageGroup, strpos($pageGroup, "=")+1, strpos($pageGroup, ",")-3));
	
				$result = $result . "<tr>";
				$result = $result . "<td>".$appInfo[0]["description"][0]."</td>";
				$count = 0;

				if ($appInfo[0]["auvwaapplicationrole"]["count"] > 0) {

					foreach ($appInfo[0]["auvwaapplicationrole"] as &$appRole) {
	
						if (in_array($appRole, $value["groupmembership"])) {
		
							$roleDesc = getRoleInfo(substr($appRole, strpos($appRole, "=")+1, strpos($appRole, ",")-3));
	
							if ($count == 0) {
	
								$result = $result . "<td>".$roleDesc[0]["description"][0]."</td></tr>";
	
							} else {
								$result = $result . "<tr><td></td><td>".$roleDesc[0]["description"][0]."</td></tr>";
							}
	
							$count++;
						}
						
					}
				}

				$result = $result . "<tr><td colspan=2>&nbsp</td></tr>";

 			}
		}

		$result = $result . "</table></div>";
		
		$result = $result . "</td></tr>";
	
		$row++;
	
	}

	$result = $result . "</tbody>\n</table></body></html>";


	$fn = 'role_report' . $company . date("ymdHms").'.html';

	$fh = fopen($fn, "w") or die("can't open file");
	fwrite($fh, $result);
	fclose($fh);

	return $fn;

}


function generateXLSreport($company, $companyDN, $info, $groupInfo) {



	require_once 'Spreadsheet/Excel/Writer.php';
	
	$tmpFileName = 'role_report' . $company . date("ymdHms").'.xls';
	
	$row = 1;
	
	$arrInfo = array();
	$userDN = array();
	
	for ($i=0; $i<$info["count"]; $i++) {
	
		$arrInfo[$i]["dn"] =  strtolower($info[$i]["dn"]);
		$userDN[$i] =  strtolower($info[$i]["dn"]);
		$arrInfo[$i]["cn"] =  $info[$i]["cn"][0];
		$arrInfo[$i]["givenname"] =  $info[$i]["givenname"][0];
		$arrInfo[$i]["surname"] =  $info[$i]["surname"][0];
		$arrInfo[$i]["logindisabled"] =  $info[$i]["logindisabled"][0];
		$arrInfo[$i]["logintime"] =  $info[$i]["logintime"][0];
		$arrInfo[$i]["mail"] =  $info[$i]["mail"][0];
		$arrInfo[$i]["auvwaacctionuserid"] =  $info[$i]["auvwaacctionuserid"][0];
		$arrInfo[$i]["auvwaaltuid"] =  $info[$i]["auvwaaltuid"][0];
		$arrInfo[$i]["passwordexpirationtime"] =  $info[$i]["passwordexpirationtime"][0];
	
	}
	
	usort($arrInfo, "cmp");


	$workbook = new Spreadsheet_Excel_Writer($tmpFileName);
	
	$worksheet =& $workbook->addWorksheet('User Details');
	$worksheet->setMargins(0.25);
	$worksheet->centerHorizontally(1);
	$worksheet->activate();
		
	$format_header =& $workbook->addFormat();
	$format_header->setBold();
	$format_header->setSize(15);
	
	$format_row_left =& $workbook->addFormat();
	$format_row_left->setSize(12);
	$format_row_left->setAlign('left');
	
	$format_row_center =& $workbook->addFormat();
	$format_row_center->setSize(12);
	$format_row_center->setAlign('left');
	
	$worksheet->write(0, 0, 'Username', $format_header);
	$worksheet->write(0, 1, 'Given Name',$format_header);
	$worksheet->write(0, 2, 'Surname',$format_header);
	$worksheet->write(0, 3, 'eMail Address',$format_header);
	$worksheet->write(0, 4, 'ACCtion ID',$format_header);
	$worksheet->write(0, 5, 'AIS User ID',$format_header);
	$worksheet->write(0, 6, 'Disabled',$format_header);
	$worksheet->write(0, 7, 'Last Login Date',$format_header);
	$worksheet->write(0, 8, 'Password Expiration',$format_header);

	$worksheet->setColumn("0","0", 30);
	$worksheet->setColumn("0","1", 20);
	$worksheet->setColumn("0","2", 20);
	$worksheet->setColumn("0","3", 40);
	$worksheet->setColumn("0","4", 15);
	$worksheet->setColumn("0","5", 16);
	$worksheet->setColumn("0","6", 12);
	$worksheet->setColumn("0","7", 23);
	$worksheet->setColumn("0","8", 26);
	
	while (list($key, $value) = each($arrInfo)) {
	
		$worksheet->write($row, 0, $value["cn"], $format_row_left);
		$worksheet->write($row, 1, $value["givenname"],$format_row_left);
		$worksheet->write($row, 2, $value["surname"],$format_row_center);
		$worksheet->write($row, 3, $value["mail"],$format_row_center);
		$worksheet->write($row, 4, $value["auvwaacctionuserid"],$format_row_center);
		$worksheet->write($row, 5, $value["auvwaaltuid"],$format_row_center);
		if ($value["logindisabled"] == "") {
			$worksheet->write($row, 6, "FALSE", $format_row_left);
		} else {
			$worksheet->write($row, 6, $value["logindisabled"], $format_row_left);
		}

		$logindate = $value["logintime"];
		$logintime = "Never";

		if ($logindate != "") {
	
			$logintime = substr($logindate, 0, 4) . "-" . substr($logindate, 4, 2) . "-" . substr($logindate, 6, 2);
		}

		$worksheet->write($row, 7, $logintime, $format_row_left);

		$passwordExpirationTime = $value["passwordexpirationtime"];
		$passwordtime = "Never";

		if ($passwordExpirationTime != "") {
	
			$passwordtime = substr($passwordExpirationTime, 0, 4) . "-" . substr($passwordExpirationTime, 4, 2) . "-" . substr($passwordExpirationTime, 6, 2) . "-" . substr($passwordExpirationTime, 8, 2) . ":" . substr($passwordExpirationTime, 10, 2);
		}
				
		$worksheet->write($row, 8, $passwordtime, $format_row_left);

		$row++;
	
	}
	
	
	// Sheet 2 - User role assignment
	
	$row = 1;

	$worksheet1 =& $workbook->addWorksheet('User Role Assignment');
	$worksheet1->setMargins(0.25);
	$worksheet1->centerHorizontally(1);
	
	$worksheet1->setColumn("0","0", 40);
	$worksheet1->setColumn("0","1", 50);
	$worksheet1->setColumn("0","2", 32);

	$worksheet1->write(0, 0, 'Application', $format_header);
	$worksheet1->write(0, 1, 'Role',$format_header);
	$worksheet1->write(0, 2, 'Username',$format_header);

	foreach ($groupInfo[0]["auvwaapplicationpage"] as &$group) {

		$groupRoles = getApplicationRoles(substr($group, strpos($group, "=")+1, strpos($group, ",")-3));

		if ($groupRoles[0]["auvwaapplicationrole"] != "") {

			foreach ($groupRoles[0]["auvwaapplicationrole"] as &$appRole) {

				$roleInfo = getRoleInfo(substr($appRole, strpos($appRole, "=")+1, strpos($appRole, ",")-3));
	
				//echo $roleInfo[0]["cn"][0]." :: ".$roleInfo[0]["auvwagroupcompanylink"][0] . "  ::  ". $companyDN."<br>";


	
				if (!isset($roleInfo[0]["auvwagroupcompanylink"][0]) || strtolower($roleInfo[0]["auvwagroupcompanylink"][0]) == strtolower($companyDN)) {

					_log("\nApp Page :". $group."  :::::  App Role : " .$appRole."  :::: COmpanyLink : ".$roleInfo[0]["auvwagroupcompanylink"][0]);	


					if ($roleInfo[0]["member"]["count"] > 0 ) {

						foreach ($roleInfo[0]["member"] as &$member) {

							if (in_array(strtolower($member), $userDN)) {

								if(substr($member, strpos($member, "=")+1, strpos($member, ",")-3) != "") {
	
									$worksheet1->write($row, 0, $groupRoles[0]["description"][0], $format_row_left);
									$worksheet1->write($row, 1, $roleInfo[0]["description"][0],$format_row_left);
									$worksheet1->write($row, 2, substr($member, strpos($member, "=")+1, strpos($member, ",")-3),$format_row_center);
			
									$row++;
								}
							}
						}
					}
				}
	
			}
		}
		
	}

	$workbook->close();


	return $tmpFileName;
}

function cmp($a, $b)
{
    return strcmp($a["dn"], $b["dn"]);
}
?>
