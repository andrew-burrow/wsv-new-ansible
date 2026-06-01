<?php 
session_set_cookie_params(1200);
session_start(); 




error_reporting(0);

//Globals

$loginStatus = "";
$env = "TEST"; //Change for different environments
$version = "v0.13";

/* Declaration LDAP variables*/ 

if ($env == "TEST") {

$ldaprdn  = 'cn=admin,o=admin';     // ldap rdn or dn
$ldappass = 'password';  // associated password
$server_name="172.29.2.245"; 
$port="389"; 
$basedn = "ou=test,ou=employers,o=communities";


} else if ($env == "PROD"){

$ldaprdn  = 'cn=oesadmin,o=admin';     // ldap rdn or dn
$ldappass = '21JumpSt';  // associated password
$server_name="172.29.2.195"; 
$port="389"; 
$basedn = "ou=prod,ou=employers,o=communities";

}


$attributes = array("cn","description", "accesscardnumber", "auvwaorrregistered", "auvwaorrinsurercode");

$modAttributes = array("givenname","telephonenumber","mobile","title","mail", "passwordexpirationtime", "auvwaorremployeddrr", "auvwaorremployercity", "auvwaorremployercontactname","auvwaorremployerphone", "auvwaorremployerpostalcode", "auvwaorremployerstate", "auvwaorremployerstreetaddress", "auvwaorrsecretanswer", "auvwaorrsecretcount", "auvwaorrsecretquestion","auvwaorrsecrettime", "auvwaorrtermsconditionsacc");


?>

<html>
<head>
<meta http-equiv="cache-control" content="no-cache">
<meta http-equiv="cache-control" content="no-store">
<meta http-equiv="expires" content="0">
<meta http-equiv="pragma" content="no-cache">

<title>
OES Employer Management

</title>

<link rel="stylesheet" type="text/css"
	href="themes/main.css" />
<link rel="stylesheet" type="text/css"
	href="themes/tables.css" /> 
<link rel="stylesheet" type="text/css"
	href="themes/error.css" /> 

</head>

<?php

if (isset($_POST["appFunction"])) {
	
	if ($_POST["appFunction"] == "logout") {

		session_unset();
		session_destroy();
		
	}

}


if(isset($_SESSION['user'])) {

	if($_SESSION['user'] == "valid") {

		//User is logged in
	
		//Build session variables

		if (isset($_POST["appFunction"])) {

			$appFunction = $_POST["appFunction"];

			if (isset($_POST["searchWEN"])) {
		
				$searchWEN = $_POST["searchWEN"];
			}
			if (isset($_POST["searchName"])) {
		
				$searchName = $_POST["searchName"];
			}

			if ($appFunction == "resetPassword") {

				if (isset($_POST["resetPasswordNewPassword"])) {
			
					$resetPasswordNewPassword = $_POST["resetPasswordNewPassword"];
				}

				if (isset($_POST["resetPasswordConfirmPassword"])) {
			
					$resetPasswordConfirmPassword = $_POST["resetPasswordConfirmPassword"];
				}
			}

			if ($appFunction == "resetAccount") {

				if (isset($_POST["resetAccountConfirmPassword"])) {
			
					$resetAccountConfirmPassword = $_POST["resetAccountConfirmPassword"];
				}

				if (isset($_POST["resetAccountNewPassword"])) {
			
					$resetAccountNewPassword = $_POST["resetAccountNewPassword"];
				}
				if (isset($_POST["resetAccountEmail"])) {
			
					$resetAccountEmail = $_POST["resetAccountEmail"];
				}
			}

	
		}

		dispHeader();
		dispBody();
		dispFooter();
	}
} else {

	// Display login form
	if (isset($_POST['username']) && isset($_POST['password'])) {

		$username = $_POST["username"];
		$userPassword = $_POST["password"];

		ldapLogin();

	} else {

		dispHeader();
		dispLogin();
		dispFooter();
	}
}

function ldapLogin() {

	global $username, $userPassword, $loginStatus;

	// Build username

	$ldaprdn  = 'cn='.$username.",ou=internal,o=vwa";

	// connect to ldap server
	$ldapconn = ldap_connect("ldbenldap.services.workcover.vic.gov.au")
	or die("Could not connect to LDAP server.");
	
	if ($ldapconn) {
	
		// binding to ldap server
		$ldapbind = ldap_bind($ldapconn, $ldaprdn, $userPassword);
		
		// verify binding
		if ($ldapbind) {
	
			//Check group membership
			$attributes = array("groupmembership");

			$sr=ldap_read($ldapconn, $ldaprdn, "(objectClass=*)", $attributes);
			
			$info = ldap_get_entries($ldapconn, $sr);
		
			if ($info["count"] > 0) {
		
				for ($i=0; $i<$info[0]["groupmembership"]["count"]; $i++) {
					
					if ($info[0]["groupmembership"][$i] == "cn=ROL-ORR-HELPDESK,ou=GROUPS,o=VWA") {

						$groupStatus = "member";

					}
				}
			}

			if ($groupStatus == "member") {

				$_SESSION['user'] = "valid";
		
				dispHeader();
				dispBody();
				//testSearch();
				dispFooter();
			} else {

				$loginStatus = "You do not have access to use this application. Please see the Help Desk manager to arrange access.";
			
				dispHeader();
				dispLogin();
				dispFooter();

			}



	
		} else {
	
			$loginStatus = "Incorrect Password. Please try again";
		
			dispHeader();
			dispLogin();
			dispFooter();
		}

	ldap_close($ldapconn);
	
	}

}

function dispHeader() {

	global $version, $env;

?>

<!-- START header -->
<div id="header">
	<h1 id="logo">	
		<a href="http://www.worksafe.vic.gov.au/" target="_blank" title="Work Safe Victoria, Victorian WorkCover Authority">
			<img src="images/logo.gif" height="64" width="354" border="0" alt="WorkSafe Victoria, Victorian WorkCover Authority">
		</a>
	</h1>
	<SCRIPT language="JavaScript">
		function submitLogoutForm()
		{		
			document.logoutForm.submit();
		}
	</SCRIPT>
	
	<form name="logoutForm" method="post" action="">
		<input type=hidden name=appFunction value="logout">
	</form>

	<div id="siteInformation">
		<ul>
			<?php if($_SESSION['user'] == "valid") { ?> <li><a href="#" onclick="document.logoutForm.submit();">Logout</a> </li> <?php } ?>
			<li><?php echo $version; ?></li>
			<li><?php echo $env; ?></li>
			
		</ul>
	</div>


	<!-- Start Menu -->
	
<div id="menu">
<ul>
	<li>Employer Administration
	<ul>		

		
	</ul>
	</li>
</ul>
</div>

	<!-- End Menu -->
	
</div>
<!-- END #header -->


<?php	

}

function dispLogin() {

	global $loginStatus;

	?>
	
	<div id="content" class="fullWidth">
			<div id="contentMain">
				<div class="heading">Please login with your Enterprise Username and Password. </div>
	
	<?php
	
	if ($loginStatus != "") {

		?>

		<div class="errorList">
		<h2>Login Error:</h2>
		<ul>

			<li><?php echo $loginStatus; ?> </li>

		</ul>
		</div>

		<?php

	}
	?>
	<form name="loginForm" method="post" action="">
	
	
		<table border="0" cellpadding="0" cellspacing="0">
			<tr>
				<td colspan="3" class="comment">
					<br><br>
				</td>
			</tr>
			<!--  Entry fields -->
			<tr>
				<td class="first">Username</td>
				<td><input type="text" name="username" maxlength="30" tabindex="1" value=""> 
				</td>
			</tr>
			<tr>
				<td nowrap>Password:</td>
				<td><input type="password" name="password" maxlength="12" tabindex="2" value="">
				</td>
			</tr>
			<tr>
				
				<td colspan="2"  class="white"><span class="indent"> <input type="submit" name="method" tabindex="4" value="Login >" class="button"> </span></td>
			</tr>
	
	
			</form>
	
			</div>
			</div>
			
		</table>
		<br />
		<br />
		</div>
		</div>
	<?php

}

function resetPassword() {

	global $searchWEN, $searchStatus, $ldaprdn, $ldappass, $attributes, $attributes, $server_name, $port, $basedn, $resetPasswordConfirmPassword, $resetPasswordNewPassword, $passwordSaveStatus;


	if ($resetPasswordNewPassword == $resetPasswordConfirmPassword) {

		if ($resetPasswordNewPassword != "")  {
		
			// connect to ldap server
		
			$saveDN = "cn=".$searchWEN.",".$basedn;
	
			$ds = ldap_connect($server_name, $port)
			or die("Could not connect to LDAP server.");
			
			if ($ds) {
			
				// Set search limit to 100 enmployers
				ldap_set_option($ds, LDAP_OPT_SIZELIMIT, 100);
		
				// binding to ldap server
				$ldapbind = ldap_bind($ds, $ldaprdn, $ldappass);
						
				// verify binding
				if ($ldapbind) {
		
					$entry["userPassword"][0] = $resetPasswordNewPassword;
		
					$saveResult = ldap_modify($ds, $saveDN, $entry);
		
					if($saveResult == "TRUE") {
		
						$passwordSaveStatus = "Password successfully saved.";
		
						dispResetPasswordForm() ;
		
					} else {
		
						$passwordSaveStatus = "Unable to save password. Please try again";
		
						dispResetPasswordForm();
					}
				}
				ldap_close($ds);
			}
		} else {

			$passwordSaveStatus = "Password cannot be blank. Please try again";
	
			dispResetPasswordForm();
		}

	} else {

		$passwordSaveStatus = "Passwords did not match. Please try again";

		dispResetPasswordForm();
		
	}

}

function resetAccount() {

	global $searchWEN, $searchStatus, $ldaprdn, $ldappass, $attributes, $attributes, $server_name, $port, $basedn, $resetAccountConfirmPassword, $resetAccountNewPassword, $resetAccountSaveStatus, $resetAccountEmail, $searchName, $modAttributes;

	// Mail config
	
	$subject = 'OES Password Recovery';
	$headers = 'From: online@worksafe.vic.gov.au' . "\r\n";
	$headers .= 'MIME-Version: 1.0' . "\r\n";
	$headers .= 'Content-type: text/html; charset=iso-8859-1' . "\r\n";


	if ($resetAccountNewPassword == $resetAccountConfirmPassword) {

		if ($resetAccountNewPassword != "")  {
		
			if (eregi('^[a-zA-Z0-9._-]+@[a-zA-Z0-9._-]+\.([a-zA-Z]{2,4})$', $resetAccountEmail )) {
			
				// connect to ldap server
			
				$saveDN = "cn=".$searchWEN.",".$basedn;
		
				$ds = ldap_connect($server_name, $port)
				or die("Could not connect to LDAP server.");
				
				if ($ds) {
				
					// Set search limit to 100 enmployers
					ldap_set_option($ds, LDAP_OPT_SIZELIMIT, 100);
			
					// binding to ldap server
					$ldapbind = ldap_bind($ds, $ldaprdn, $ldappass);
							
					// verify binding
					if ($ldapbind) {
			
						$entry["userPassword"][0] = $resetAccountNewPassword;
						$entry["auvwaorrregistered"][0] = "false";
						#$entry["surname"][0] = trim($searchWEN) ;
						$entry["surname"][0] = $searchWEN ;
						
	
						$saveResult = ldap_modify($ds, $saveDN, $entry);
			
						if($saveResult == "TRUE") {

							// Query for all related ORR attributes. If present then add to ldap mod_delete attribute array.

							$saveResult = "";

							$modQuery = "(cn=".$searchWEN.")";

							$sr=ldap_search($ds, $basedn, $modQuery, $modAttributes);
							
							$info = ldap_get_entries($ds, $sr);

							$entryDel = array();
						
							if ($info["count"] > 0) {
						
								for ($i=0; $i<$info["count"]; $i++) {

									foreach($modAttributes as $key => $value) {

										if($info[$i][$value][0] != "") {

											$entryDel[$value] = array();
										}
									}
								}
							}

							$saveResult = ldap_mod_del($ds, $saveDN, $entryDel); 
			
							if($saveResult == "TRUE") {

			
								$to = $resetAccountEmail;
								$message = '
								<html>
								<head>
								<meta http-equiv="cache-control" content="no-cache">
								<meta http-equiv="cache-control" content="no-store">
								<meta http-equiv="expires" content="0">
								<meta http-equiv="pragma" content="no-cache">
								
								<title>
								Worksafe OES Password Recovery
								</title>
								
								
								<style type="text/css">
								
								/*******************************************************************************
								*** INDEX **********************************************************************
								********************************************************************************
								**
								* - GENERAL/BODY
								* - HEADER
								* - MENU
								* - CONTENT
								* - SUBCONTENT
								* - FOOTER
								* - FORMS
								* - TABLES
								**
								*******************************************************************************/
								
								
								/* GENERAL/BODY ------------------------------------------------------------- */
								
								/* Zero default margin & padding around common elements */
								blockquote, body, dd, dl, dt, fieldset, form, h1, h2, h3, h4, h5, h6, hr, li, ol, p, ul
								{
									margin: 0;
									padding: 0;
								}
								
								body
								{
									min-width: 744px;
									padding: 10px 10px 25px 10px;
									background-color: #FFFFFF;
									color: #000000;
									font-size: 70%;
									font-family: Verdana, Arial, Helvetica, sans-serif;
									line-height: 1.4;
								}
								
								* html body
								{
									w\idth: expression(document.body.clientWidth < 764 ? "744px" : "auto");
								}
								
								a:link
								{
									color: #336699;
								}
								
								a:visited
								{
									color: #336699;
								}
								
								a:hover, a:focus
								{
									text-decoration: none;
								}
								
								hr 
								{
									margin-top: 1em;
									border: 0;
									height: 1px;
									background-color: #000000;
									color: #000000;
								}
								
								input, select, table, textarea
								{
									font-family: Verdana, Arial, Helvetica, sans-serif;
									font-size: 100%;
								}
								
								.hidden
								{
									position: absolute;
									left: -9999px;
									height: 1px;
									width: 1px;
									overflow: hidden;
									margin-bottom: -1px;
									font-size: 1px;
									line-height: 1px;
								}
								
								.clearer
								{
									clear: both;
									height: 1px;
									overflow: hidden;
									margin-bottom: -1px;
									font-size: 1px;
									line-height: 1px;
								}
								
								.footer-clearer
								{
									width: 364px;
									clear: both;
									height: 1px;
									overflow: hidden;
									margin-bottom: -1px;
									font-size: 1px;
									line-height: 1px;
								}
								
								/* HEADER ------------------------------------------------------------------- */
								
								* html #header
								{
									min-width: 744px;
									width:expression(document.body.clientWidth < 764 ? "744px" : "auto" );
									height: 1px;
								}
								
								/* Fix for logo spacing inside a H1 */
								#header p
								{
									margin-bottom: 3px;
								}
								
								* html #header p 
								{
									margin-bottom: 4px;
								}
								
								#header table
								{
									border: 0;
									width: 100%;
								}
								
								#logo
								{
									display: inline;
									float: left;
									width: 400px;
									margin-top: 8px;
									margin-right: -353px;
									margin-left: 10px;
									margin-bottom: 8px;
								}
								
								#siteInformation
								{
									display: inline;
									float: right;
									height: 1.1em;
									margin-right: 10px;
								}
								
								#siteInformation ul
								{
									list-style: none;
								}
								
								#siteInformation li
								{
									float: left;
									margin-left: 0.5em;
									border-left: 1px solid #666666;
									padding-left: 0.5em;
									line-height: 1.1;
								}
								
								#siteInformation li.first
								{
									border-left: 0 none #FFFFFF;
								}
								
								#siteInformation a
								{
									color: #666666;
									text-decoration: none;
								}
								
								#siteInformation a:hover
								{
									text-decoration: underline;
								}
								
								
								/* MENU --------------------------------------------------------------------- */
								
								
								#menu
								{
									clear:both;
									float:inherit;
									position:static;
									height: 42px;
									width: inherit;
									border-top: 4px solid #205B81;
									border-bottom:4px solid #205B81;
									border-left: 1px solid #E0E0E0;
									border-right: 1px solid #E0E0E0;
									background-color: #669ACC;
									text-indent:10px;
								
								}
								
								#menu ul{
									display:block;
									position:relative;
									list-style: none; 
									text-align: left;
									padding:0;
									margin:0;
								
									}
									
									
								#menu li{
									display:inline;
									color:#FFFFFF;
									height:inherit;
									font-weight: bold;
									text-align: left;
									font-size: small;
									
									}
								
								
								#menu ul ul{
									width: inherit;
									display:block;
									position:relative;
									list-style: none; 
									text-align: left;
									margin-top: 0.1em;
									border-top:1px solid #000000;
									background-color: #FFFFFF;
									height:21px;
									}
									
								#menu ul li ul li{
									display: inline;
									position:relative;
									color:#CCCCCC;
									font-weight:normal;
									font-size:11px;
									text-decoration:none;
									padding-right:20px;
									width: 20%;
								}
								
								
								#menu ul li ul li.highlight
								{
									color:#333333;
									font-weight:bold;
									position: relative;
								}
								
								#menu img
								{
									width:16px;
									height:16px;
									vertical-align:bottom;
									padding-right:5px;
									position:relative;
								}
								
								#menu table
								{
									border: 0;
									width: 100%;
								}
								/* CONTENT ------------------------------------------------------------------ */
								
								#content
								{
									min-width: 744px;
									width:expression(document.body.clientWidth < 764 ? "744px" : "auto" );
									border-left: 1px solid #EDEDED;
									border-right: 1px solid #EDEDED;
									padding-bottom: 38px;
									background-repeat: repeat-y;
									background-position: 100% 0;
									background-color:#FFFFFF;
								}
								
								
								#contentMain
								{
									display: block;
									float: left;
									width: 100%;
									background-repeat: repeat-x;
									margin:0;
									border-top: 1px solid #E0E0E0;
								}
								
								#contentMainInner {
									width: 730px; 
									vertical-align:top; 
									padding:10px;
									}
								
								.contentButtons {
									width: 500px; 
									vertical-align:top; 
									text-align:right;
									border:none;
									}
								
								
								#contentMain .heading
								{
									color: #000000;
									font-size: 100%;
									padding: 10px;
									text-transform: uppercase;
									font-weight: bold;
									background-color: #F5F5F5;
									border-bottom:1px solid #E0E0E0;
								}
								
								#content h1, #contentMain h1
								{
									color: #205B81;
									font-size: 160%;
									font-weight: bold;
									padding: 1em 0.5em 0.5em 0.5em;
								}
								
								#content h2, #contentMain h2
								{
									margin-top: 1em;
									color: #585858;
									font-size: 135%;
									margin-bottom: 0em;
									text-transform: none;
									font-weight: bold;
									
								}
								
								#content h3, #contentMain h3
								{
									font-size: 100%;
									margin-top: 1em;
								
								}
								
								#content h4, #contentMain h4
								{
									margin-top: 1em;
									font-size: 100%;
									padding-left: 10px;
									padding-right: 10px;
								}
								
								#content p, #contentMain p, #contentMainInner p
								{
									margin-top: 1em;
									line-height:1.5;
								}
								
								
								#contentMain ul
								{
									margin-top: 1em;
									list-style: none;
								}
								
								#contentMain ul li
								{
									margin-top: 0.5em;
									padding-left: 15px;
									background-repeat: no-repeat;
									background-position: 0 0.5em;
								}
								
								#contentMain ol
								{
									margin: 1em 0 0 2em;
								}
								
								#contentMain ol li
								{
									margin-top: 0.5em;
								}
								
								
								#content .backToTop
								{
									margin-top: 2em;
									border-bottom: 1px solid #E0E0E0;
									text-align: right;
								}
								
								.backToTop a
								{
									position: relative;
									top: 8px;
								}
								
								
								
								/* SUBCONTENT --------------------------------------------------------------- */
								
								
								#contentSubLeft
								{
									float: left;
									display:block;
									position:static;
									width: 70%;
									w\idth: 70%;
									padding: 19px 10px 0px 10px;
									background-repeat: repeat-y;
								}
								
								
								#contentSubRight
								{
									float: right;
									display:block;
									position:static;
									width: 24%;
									w\idth: 24%;
									margin-top: 1em;
									margin-right: 5px;
									background-repeat: repeat-y;
								}
								
								
								
								
								/* FOOTER ------------------------------------------------------------------- */
								
								#footer
								{
									clear: both;
									border-top: 4px solid #205B81;
									padding-top: 7px;
									padding-bottom: 1em;
									padding-left: 10px;
									color: #666666;
								}
								
								* html #footer
								{
									height: 1px;
								}
								
								#footer table
								{
									border: 0;
									width: 100%;
								}
								
								#footer p
								{
									float: left;
									margin-right: 5em;
								}
								
								#footer ul
								{
									float: left;
									margin-right: 3em;
									padding-top: 0.25em;
									list-style: none;
									line-height: 1.1;
								}
								
								#footer li
								{
									float: left;
								}
								
								#footer li.first
								{
									margin-right: 0.5em;
									border-right: 1px solid #666666;
									padding-right: 0.5em;
								}
								
								#footer a
								{
									color: #666666;
									text-decoration: none;
								}
								
								#footer a:hover, #footer a:focus, #footer a:active
								{
									text-decoration: underline;
								}
								
								#downloads
								{
									float: right;
									min-width: 160px;
								}
								
								#downloads p
								{
									margin-right: 0.5em;
								}
								
								#downloads ul
								{
									float: left;
									margin-top: -5px;
									margin-right: 0;
								}
								
								#downloads li
								{
									position: relative;
									width: 21px;
									height: 21px;
									overflow: hidden;
									margin-left: 0.5em;
								}
								
								#disclaimer
								{
									float: left;
									min-width: 220px;
								}
								
								/* FORMS -------------------------------------------------------------------- */
								
								form 
								
								{
									background-color:#F5F5F5;
								}
								
								
								
								input.button
								{
									margin-top: 1em;
									height: 1.7em;
									border: 1px solid #D0D0D0;
									border-right-color: #9495A2;
									border-bottom-color: #9495A2;
									padding-right: 1px;
									padding-left: 1px;
									background-color: #FFFFFF;
									background-repeat: repeat-x;
									background-position: 0 100%;
									background:  url("../images/button_bg.gif") bottom right repeat;
									font-weight: bold;
								}
								
								.required
								{
									color: #CC0000;
								}
								
								#content .errorList h2
								{
									color: #CC0000;
									font-size: 100%;
									font-weight: bold;
								}
								
								#content .errorList ul
								{
									margin-top: 0;
									list-style-image: url(../images/icons/bullet_diamond.gif);
									list-style-type:circle;
									padding-bottom: 15px;
									padding-left: 25px;
								
								}
								
								
								
								/*==========================================
								Tables
								==========================================*/
								
								
								#content table
								{
									width: 100%;
									border: 0 none #FFFFFF;
									border-top: 1px solid #000000;
								}
								
								
								#content th
								{
									padding: 1px 10px 3px 10px;
									background-color: #205B81;
									background-repeat: no-repeat;
									background-position: 100% 50%;
									color: #FFF;
									text-align: left;
									vertical-align: top;
									text-transform: uppercase;
								}
								#content th.leftBorder
								{
									border-left: 1px solid #FFFFFF;
								}
								
								#content th.rightBorder
								{
									border-right: 1px solid #FFFFFF;
								}
								
								
								.th a
								{
									color: #FFFFFF;
								}
								
								
								#content td
								{
									border: 0 none #FFFFFF;
									border-right: 1px none #E0E0E0;
									border-bottom: 1px solid #E0E0E0;
									padding: 4px 4px 4px 10px;
									vertical-align: top;
									text-align: left;
								}
								
								#content td.leftBorder
								{
									border-left: 1px solid #E0E0E0;
								}
								
								#content td.rightBorder
								{
									border-right: 1px solid #E0E0E0;
								}
								
								#content td.comment
								{
									background-color: #FFFFFF;
									width: 600px;
								}
								
								#content td.first
								{
									width:25%;
								}
								
								#content td.white
								{
									background-color: #FFFFFF;
									border: none;
								}
								
								#content td.info
								{
									width:5%;
								}
								
								#content td.subTitle
								{
									background-color: #E0E0E0;
									color:#333333;
									font-weight:bold;
								}
								
								#content .indent
								{
									margin-left: 1em;
								}
								
								#content td.innerTable
								{
									border-bottom: none;
								}
								
								#content td a
								{
									font-weight: bold;
								}
								
								#content td.center
								{
									text-align: center;
								}
								
								#content td p
								{
									padding:2px;
									/*changed from 0 by KERZL1 to
									*imitate spacing of sample html page
									*/
								}
								
								
								
								/*==========================================
								ORR Tables
								==========================================*/
								
								#content table.priorPolicy thead th {
									background-color:#85B8EB;
									text-transform: uppercase;
								}
								
								#content table.currentPolicy thead th {
									background-color: #6699CC;
									text-transform: uppercase;
								}
								
								#content th.priorPolicy {
									background-color: #8EB8EB;
									text-transform: uppercase;
								}
								
								#content th.currentPolicy {
									background-color: #6699CC;
									text-transform: uppercase;
								}
								
								
								#content table.searchPolicy thead tr th {
									border-right: 1px solid #FFFFFF; 
									text-transform: uppercase;
								}
								
								#content table.priorPolicy thead tr th {
									border-right: 1px solid #FFFFFF; 
									text-transform: uppercase;
								}
								#content table tbody tr.alt td {
									background-color: #F5F5F5;
								}
								
								#content table.searchPolicy tbody tr td {
									border-right: 1px solid #E0E0E0; 
								}
								
								#content table.priorPolicy tbody tr td {
									border-right: 1px solid #E0E0E0; 
								}
								
								#content table.currentPolicy tbody tr td {
									border-right: 1px solid #E0E0E0; 
								}
								
								/****** Not used yet Ruler Tables*******/
								
								#content table.ruler tbody tr.ruled td {
									border-top: 1px solid #205B81;
									border-bottom: 1px solid #205B81;
									padding-top: 3px;
								}
								
								#content table.ruler tbody tr.ruled td.first {
									border-left: 1px solid #205B81;
								}
								
								
								.url
								{
									color: #666666 !important;
									font-weight: normal !important;
									text-decoration: none !important;
								}
								
								.url:hover
								{
									text-decoration: underline !important;
								}
								
								#content .errorlist {
									border-bottom: 1px solid #E0E0E0;
								}
								
								#contentOtherPosition {
									display: none;
								}
								
								#contentAgentDRRSubmission {
									display: none;
								}
								
								</style>
								
								</head>
								
								
								<!-- START header -->
								<div id="header">
									<h1 id="logo">	
										<a href="http://www.worksafe.vic.gov.au/" target="_blank" title="Work Safe Victoria, Victorian WorkCover Authority">
											<img src="images/logo.gif" height="64" width="354" border="0" alt="WorkSafe Victoria, Victorian WorkCover Authority">
										</a>
									</h1>
									<!-- Start Menu -->
									
								<div id="menu">
								<ul>
									<li><font size="3"><b>Online Employer Service</b></font>
									</li>
								</ul>
								</div>
								
									<!-- End Menu -->
									
								
								</div>
								<!-- END #header -->
								
									<div id="content" class="fullWidth">
											<div id="contentMain">
												<div class="heading">Password Recovery</div>
									
										<form name="loginForm" method="post" action="">
									
									
										<table border="0" cellpadding="0" cellspacing="0">
											<tr>
								
												<td colspan="3" class="comment">
													<br>
													<p>Dear Sir/Madam,
													<p>As per your request, your login details and new password to access the WorkSafe Victoria Online Employer System is as follows:
													<p>Please allow 10 minutes before attempting to login again.
													<p>Should you have any queries in relation to using the Online Employer System please contact your VWA Agent.
													<br><br><br>
												</td>
											</tr>
											<!--  Entry fields -->
											<tr>
												<td class="first">Employer Number:</td>
												<td>'.$searchWEN.'
												</td>
								
											</tr>
											<tr>
											<td class="first">Employer Name:</td>
												<td>'.$searchName.'
											</td>
								
											</tr>
											<tr>
												<td nowrap>Password:</td>
												<td>'.$resetAccountNewPassword.'
											</td>
											</tr>
											<tr>
												
												<td colspan="2"  class="white"><br><br><br></td>
								
											</tr>
									
									
											</form>
									
											</div>
											</div>
											
										</table>
										<br />
										<br />
										</div>
										</div>
								
									
								<!-- START #footer -->
								<div id="footer">
								<table>
								<tr>
								<td>
								<div id="disclaimer">
								
								</div>
								</td>
								<td> <div class="footer-clearer"></div></td>
								<td>
								</td>
								</tr>
								</table>
								<!-- END #downloads -->
								
								
								</div>
								<!-- END #footer -->
								
								
								</body>
								
								</html>
								
								

								';

								$result = mail($to, $subject, $message, $headers);

								if($result == "TRUE") {

									$resetAccountSaveStatus = "Account successfully reset. An email has been sent to ".$resetAccountEmail.".";
								} else {
									$resetAccountSaveStatus = "Account successfully reset. Email notification has failed for ".$resetAccountEmail.". Please try again or contact Nwtwork Services.";
								}
			
							dispResetAccountForm();
							}	
						} else {
			
							$resetAccountSaveStatus = "Unable to save password. Please try again.";
			
							dispResetAccountForm();
						}
					}
					ldap_close($ds);
				}
			} else {

				$resetAccountSaveStatus = $resetAccountSaveStatus."Email does not appear to be a valid email address.<p>";

				dispResetAccountForm();
			}
		
		} else {

			$resetAccountSaveStatus = $resetAccountSaveStatus."Password cannot be blank. Please try again";
	
			dispResetAccountForm();
		}

	} else {

		$resetAccountSaveStatus = $resetAccountSaveStatus."Passwords did not match. Please try again";

		dispResetAccountForm();
		
	}
}

function testSearch() {


	/* Declaration LDAP variables*/ 
	
	$ldaprdn  = 'cn=admin,o=admin';     // ldap rdn or dn
	$ldappass = 'password';  // associated password
	
	$attributes = array("cn","description", "accesscardnumber", "auvwaorrregistered", "auvwaorrinsurercode");
	$server_name="172.29.2.245"; 
	$port="389"; 

	$basedn = "ou=test,ou=employers,o=communities";
	$query = "(cn=1000614)";

	// connect to ldap server
	$ds = ldap_connect($server_name, $port)
	or die("Could not connect to LDAP server.");
	
	if ($ds) {
	
		// Set search limit to 100 enmployers
		ldap_set_option($ds, LDAP_OPT_SIZELIMIT, 100);

		// binding to ldap server
		$ldapbind = ldap_bind($ds, $ldaprdn, $ldappass);
		
		
		// verify binding
		if ($ldapbind) {
		
			$sr=ldap_search($ds, $basedn, $query, $attributes);
			
			$info = ldap_get_entries($ds, $sr);
		
		
			if ($info["count"] > 0) {
		
				for ($i=0; $i<$info["count"]; $i++) {
					echo $info[$i]["cn"][0];
				}
			}	
		}
	}



}

function dispBody() {

	global $appFunction, $searchWEN, $searchStatus, $ldaprdn, $ldappass, $attributes, $attributes, $server_name, $port, $basedn, $passwordSaveStatus, $searchName;

	
	
?>
	<div id="content" class="fullWidth">
		<div id="contentMain">

			<?php 
	
			if (!isset($appFunction)) {
	
				dispSearchForm();

			} else if ($appFunction == "search") {
	
				dispFunctionForm();
			
			} else if ($appFunction == "resetAccountForm") {

				dispResetAccountForm();

			} else if ($appFunction == "resetPasswordForm") {

				dispResetPasswordForm();

			} else if ($appFunction == "resetPassword") {

				resetPassword();

			} else if ($appFunction == "resetAccount") {

				resetAccount();

			}
		?>
		</div>
	</div>

<?php

}

function dispFunctionForm() {

	global $appFunction, $searchWEN, $searchStatus, $ldaprdn, $ldappass, $attributes, $attributes, $server_name, $port, $basedn, $passwordSaveStatus, $searchName;

	$query = "(cn=".$searchWEN.")";

	// connect to ldap server
	$ds = ldap_connect($server_name, $port)
	or die("Could not connect to LDAP server.");
	
	if ($ds) {
	
		// Set search limit to 100 enmployers
		ldap_set_option($ds, LDAP_OPT_SIZELIMIT, 100);

		// binding to ldap server
		$ldapbind = ldap_bind($ds, $ldaprdn, $ldappass);
		
		
		// verify binding
		if ($ldapbind) {
		
			$sr=ldap_search($ds, $basedn, $query, $attributes);
			
			$info = ldap_get_entries($ds, $sr);
		
		
			if ($info["count"] > 0) {
		
				for ($i=0; $i<$info["count"]; $i++) {

					?>
					<div class="heading">EMPLOYER DETAILS</div>
					<form>
						<table border="0" cellpadding="0" cellspacing="0">
							<tr>
								<td colspan="3" class="comment">
								<p></p>
								<br />
								</td>
							</tr>
							
							<tr>
								<td class="first">Employer Number:</td>
								<td class="first"><?php echo $info[$i]["cn"][0]; ?></td>
								<td class="first">&nbsp; </td>
								
							</tr>
							<tr>
								<td class="first">Legal Name:</td>
								<td class="first"><?php echo $info[$i]["description"][0]; ?></td>
								<td class="first"> &nbsp;</td>
								
							</tr>
							<tr>
								<td class="first">Registered:</td>
								<td class="first"><?php echo $info[$i]["auvwaorrregistered"][0]; ?></td>
								<td class="first">&nbsp;</td>
								
							</tr>
							<tr>
								<td class="first">Agent Code:</td>
								<td class="first"><?php echo $info[$i]["auvwaorrinsurercode"][0]; ?></td>
								<td class="first">&nbsp;</td>
							</tr>									
							<tr>
								<td colspan="3" class="white">&nbsp;</td>
								
							</tr>
							<tr>
								<td colspan="3" class="comment">
								<p>
								<input type="button" name="submit" tabindex="4" value="< Back to Search" class="button" onClick="submitform('returnToSearch');">
								<input type="button" name="submit" tabindex="4" value="Reset Account >" class="button" onClick="submitform('resetAccount');">
								<!-- <input type="button" name="submit" tabindex="4" value="Reset Password >" class="button" onClick="submitform('resetPassword');"> -->
								</p>
								<br />
								</td>
							</tr>	
						</table>
					</form>
					<br />
					<br />

					<SCRIPT language="JavaScript">
						function submitform(formName)
						{		
												
							document.forms[formName].submit();
						}
					</SCRIPT>
					<form name="returnToSearch" method="post" action=""></form>
					<form name="resetAccount" method="post" action="">
						<input type=hidden name=appFunction value="resetAccountForm">
						<input type=hidden name="searchName" value="<?php echo $info[$i]["description"][0]; ?>">
						<input type=hidden name="searchWEN" value="<?php echo $info[$i]["cn"][0]; ?> ">
						
					</form>

					<form name="resetPassword" method="post" action="">
						<input type=hidden name=appFunction value="resetPasswordForm">
						<input type=hidden name="searchWEN" value="<?php echo $info[$i]["cn"][0] ?>">
						
					</form>
							
					<?php
				}
			} else {

				$searchStatus = "Unable to find Employer Code. Please try again.";
				dispSearchForm();
			}	
		}
		ldap_close($ds);
	}
}


function dispResetPasswordForm() {

	global $passwordSaveStatus, $searchWEN;

?>
	<div class="heading">RESET EMPLOYER PASSWORD - <?php echo $searchWEN; ?></div>

	<?php
	if ($passwordSaveStatus != "") {

		?>

		<div class="errorList">
		<h2>Password Save:</h2>
		<ul>

			<li><?php echo $passwordSaveStatus ?> </li>

		</ul>
		</div>

		<?php

		$passwordSaveStatus = "";
	}
	?>

	<form name="changePasswordForm" method="post" action="">
		<table border="0" cellpadding="0" cellspacing="0">
			<tr>
				<td colspan="3" class="comment">
				<p><b>Warning:</b> the password must conform to the following rules:</p>
				<p><b>1.</b> The new password cannot be the same as your current or previous password<br>
				<b>2.</b> The password must be at least 8 characters long<br>
				<b>3.</b> The password must contain at least one number and one lowercase letter<br>
				<b>4.</b> The password cannot contain special characters (e.g. @#%)<br>
				<b>5.</b> The password cannot be equal to your username</p>
				<br/><br>
				</td>
				
				</tr>
			<!--  Entry fields -->
			<tr>
				<td class="first">Please enter new password:</td>
				<td class="info"><span class="first"><img src="images/icons/icon_question.gif" border="0" title="Enter password" tabindex="17"></span></td>
				<td class="required"><span class="required">*</span> <input type="password" name="resetPasswordNewPassword" maxlength="12" tabindex="2">
					</td>
			</tr>
			<tr>
				<td class="first">Please re-enter new password for verification:</td>
				<td class="info"><span class="first"><img src="images/icons/icon_question.gif" border="0" title="Enter password" tabindex="17"></span></td>
				<td class="required"><span class="required">*</span> <input type="password" name="resetPasswordConfirmPassword" maxlength="12" tabindex="3">
				<input type=hidden name=appFunction value="resetPassword">
				<input type=hidden name=searchWEN value="<?php echo $searchWEN; ?>">
				</td>
			</tr>
			<tr>
				<td colspan="3" class="white"><br>
				<input type="button" name="back" tabindex="4" value="< Back to Search" class="button"" onClick="submitform();">	
				
				<input type="submit" name="method" tabindex="4" value="Change Password >" class="button">
				</td>
			</tr>
		</table>
	</form>

	<SCRIPT language="JavaScript">
		function submitform()
		{
			document.returnToSearch.submit();
		}
	</SCRIPT>
	<form name="returnToSearch" method="post" action=""></form>

	<?php

}

function dispResetAccountForm() {

	global $resetAccountSaveStatus, $searchWEN, $searchName;

?>
	<div class="heading">RESET EMPLOYER ACCOUNT - <?php echo $searchWEN; ?></div>

	<?php
	if ($resetAccountSaveStatus != "") {

		?>

		<div class="errorList">
		<h2>Account Reset:</h2>
		<ul>

			<li><?php echo $resetAccountSaveStatus ?> </li>

		</ul>
		</div>

		<?php

		$resetAccountSaveStatus = "";
	}
	?>

	<form name="resetAccountForm" method="post" action="">
		<table border="0" cellpadding="0" cellspacing="0">
			<tr>
				<td colspan="3" class="comment">
				<p><b>Warning:</b> resetting an employer account will remove all user information that the employer has previously entered.</p>
				<p><b>Warning:</b> the password must conform to the following rules:</p>
				<p><b>1.</b> The new password cannot be the same as your current or previous password<br>
				<b>2.</b> The password must be at least 8 characters long<br>
				<b>3.</b> The password must contain at least one number and one lowercase letter<br>
				<b>4.</b> The password cannot contain special characters (e.g. @#%)<br>
				<b>5.</b> The password cannot be equal to your username</p>
				<br/><br>
				</td>
				
				</tr>
			<!--  Entry fields -->
			<tr>
				<td class="first">Please enter new password:</td>
				<td class="info"><span class="first"><img src="images/icons/icon_question.gif" border="0" title="Enter password" tabindex="17"></span></td>
				<td class="required"><span class="required">*</span> <input type="password" name="resetAccountNewPassword" maxlength="12" tabindex="2">
					</td>
			</tr>
			<tr>
				<td class="first">Please re-enter new password for verification:</td>
				<td class="info"><span class="first"><img src="images/icons/icon_question.gif" border="0" title="Enter password" tabindex="17"></span></td>
				<td class="required"><span class="required">*</span> <input type="password" name="resetAccountConfirmPassword" maxlength="12" tabindex="3">
				</td>
			</tr>
			<tr>
				<td class="first">Please provide email address of employer:</td>
				<td class="info"><span class="first"><img src="images/icons/icon_question.gif" border="0" title="Employer will be notified of the new password on this address." tabindex="17"></span></td>
				<td class="required"><span class="required">*</span> <input type="test" name="resetAccountEmail" maxlength="100" tabindex="4">
				<input type=hidden name=appFunction value="resetAccount">
				<input type=hidden name="searchWEN" value="<?php echo $searchWEN; ?>">
				<input type=hidden name="searchName" value="<?php echo $searchName; ?>">
				</td>
			</tr>
			<tr>
				<td colspan="3" class="white"><br>
				<input type="button" name="back" tabindex="4" value="< Back to Search" class="button"" onClick="submitform();">	
				
				<input type="submit" name="method" tabindex="4" value="Reset Account >" class="button">
				</td>
			</tr>
		</table>
	</form>

	<SCRIPT language="JavaScript">
		function submitform()
		{
			document.returnToSearch.submit();
		}
	</SCRIPT>
	<form name="returnToSearch" method="post" action=""></form>

	<?php

}



function dispSearchForm() {
	
	global $searchStatus;

?>

	<div class="heading">PLEASE SEARCH FOR AN EMPLOYER TO MANAGE</div>
	<?php
	
	if ($searchStatus != "") {

		?>

		<div class="errorList">
		<h2>Search Error:</h2>
		<ul>

			<li><?php echo $searchStatus; ?> </li>

		</ul>
		</div>

		<?php

		$searchStatus = "";
	}
	?>


	<form name="searchForWEN" method="post" action="">
	
	
		<table border="0" cellpadding="0" cellspacing="0">
			<tr>
				<td colspan="3" class="comment">
				<p></p>
				<br />
				</td>
			</tr>
			
			<tr>
				<td class="first">Employer Number</td>
				<td class="info"><span class="first"> <img src="images/icons/icon_question.gif" border="0" title="Employer Number" tabindex="5" >
	</span></td>
				<td><span class="required">*</span> <input type="test" name="searchWEN" maxlength="8" tabindex="1" value=""> 
					</td>
			</tr>
			
			<tr>
				<td colspan="2" class="white"><input type=hidden name=appFunction value="search"></input>&nbsp;</td>
				<td class="white"><span class="indent"> <input type="submit" name="submit" tabindex="4" value="Continue >" class="button"> </span></td>
			</tr>
	
	
			
		</table>
	</form>
	<br />
	<br />
	</div>

<?php


}


function dispFooter() {

?>

<!-- START #footer -->
<div id="footer">
<table>
<tr>
<td>
<div id="disclaimer">

</div>
</td>
<td> <div class="footer-clearer"></div></td>
<td>
</td>
</tr>
</table>
<!-- END #downloads -->


</div>
<!-- END #footer -->


</body>

<?php 

}

?>
</html>


