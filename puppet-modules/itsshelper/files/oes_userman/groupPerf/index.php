<?php 
//error_reporting(0);

//Globals

$loginStatus = "";
$env = "TEST"; //Change for different environments
$version = "v0.13";

/* Declaration LDAP variables*/ 

if ($env == "TEST") {

	$ldaprdn  = 'cn=admin,o=admin';     // ldap rdn or dn
	$ldappass = 'password';  // associated password
	
	$server_name="172.29.2.138"; 
	$port="389"; 
	
	$basedn = "ou=extranet,o=groups";
	
	

} else if ($env == "PROD"){

$ldaprdn  = 'cn=admin,o=admin';     // ldap rdn or dn
$ldappass = 'nothere';  // associated password
$server_name="172.29.2.80"; 
$port="389"; 
$basedn = "ou=extranet,o=groups";

}




if (isset($_POST["cmpGroup"])) {

	$cmpGroup = $_POST["cmpGroup"];
	$cmpGroupDN = "cn=".$cmpGroup.",".$basedn;
} else {

	$cmpGroup = "";
}

if (isset($_POST["cmpUser"])) {

	$cmpUser = $_POST["cmpUser"];
} else {

	$cmpUser = "";
}

?>

<html>
<head>
<meta http-equiv="cache-control" content="no-cache">
<meta http-equiv="cache-control" content="no-store">
<meta http-equiv="expires" content="0">
<meta http-equiv="pragma" content="no-cache">

<title>
Enterprise Group performance Test

</title>

<link rel="stylesheet" type="text/css"
	href="themes/main.css" />
<link rel="stylesheet" type="text/css"
	href="themes/tables.css" /> 
<link rel="stylesheet" type="text/css"
	href="themes/error.css" /> 

</head>


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
	<li>Group Performance Testing
	<ul>		

		
	</ul>
	</li>
</ul>
</div>

	<!-- End Menu -->
	
</div>
<!-- END #header -->


<div class="heading"><br></div>

	<SCRIPT language="JavaScript">
		function submitform()
		{
			document.options.submit();
		}
	</SCRIPT>


<form name="options" method="post" action="">
	<table border="0" cellpadding="0" cellspacing="0">
		<tr>
			<td class="first">
			<select name=cmpGroup onChange="submitform();"><option value="---">Please select a Company</option>
			<?php

			$ds = ldap_connect($server_name, $port)
			or die("Could not connect to LDAP server.");

			// binding to ldap server

			$ldapbind = ldap_bind($ds, $ldaprdn, $ldappass);
			
			
			// verify binding
			if ($ldapbind) {

				$attributes = array("cn");

				$sr=ldap_search($ds, $basedn, "cn=cmp*", $attributes);
				
				$info = ldap_get_entries($ds, $sr);
			
			
				if ($info["count"] > 0) {
			
					for ($i=0; $i<$info["count"]; $i++) {

						if ($info[$i]["cn"][0] == $cmpGroup) {

							echo "<option SELECTED value=\"".$info[$i]["cn"][0]."\">".$info[$i]["cn"][0]."</option>";
						} else {
							echo "<option  value=\"".$info[$i]["cn"][0]."\">".$info[$i]["cn"][0]."</option>";
						}
					}
				}
			}	
			?>

			</select>
			</td>
		</tr>
		<tr>
			<td colspan="3" class="comment">
			<br> <br>
			</td>
		</tr>
	</table>
</form>

<form name="groups" method="post" action="">
	<table border="0" cellpadding="0" cellspacing="0">


		<?php

		if ($cmpGroup != "") {
		
			// connect to ldap server
			$ds = ldap_connect($server_name, $port)
			or die("Could not connect to LDAP server.");
			
			if ($ds) {
			
		
				// binding to ldap server
				$ldapbind = ldap_bind($ds, $ldaprdn, $ldappass);
				
				
				// verify binding
				if ($ldapbind) {
	
					$attributes = array("auvwaapplication");

					$sr=ldap_search($ds, $cmpGroupDN, "objectclass=group", $attributes);
					
					$info = ldap_get_entries($ds, $sr);
				
				
					if ($info["count"] > 0) {
				
						for ($i=0; $i<$info[0]["auvwaapplication"]["count"]; $i++) {
											
							$attributes = array("description");

							$appsr=ldap_search($ds, $info[0]["auvwaapplication"][$i], "objectclass=group", $attributes);
							
							$appinfo = ldap_get_entries($ds, $appsr);

							?>
							<tr bgcolor=#D7DCDE>
								<td class="first"><B><?php echo $appinfo[0]["description"][0]; ?></B></td><td width=200px align="right" ><input type=checkbox></td>
														
							</tr>
							<tr bgcolor=#D7DCDE>
								<td class="first">This application is available in multiple places.<h1><br></td><td width=200px align="right" >ITSS<input type=checkbox><br>Agent Portal<input type=checkbox></td>
														
							</tr>


							<?php

							$attributes = array("auvwaapplicationrole");

							$rolesr=ldap_search($ds, $info[0]["auvwaapplication"][$i], "objectclass=group", $attributes);
							
							$roleinfo = ldap_get_entries($ds, $rolesr);

							for ($x=0; $x<$roleinfo[0]["auvwaapplicationrole"]["count"]; $x++) {

								$attributes = array("auvwagroupcompanylink");

								$rolecmpsr=ldap_search($ds, $roleinfo[0]["auvwaapplicationrole"][$x], "objectclass=group", $attributes);
							
								$rolecmpinfo = ldap_get_entries($ds, $rolecmpsr);

								if (strtolower($rolecmpinfo[0]["auvwagroupcompanylink"][0]) == strtolower($cmpGroupDN) || $rolecmpinfo[0]["auvwagroupcompanylink"][0] == "") {

									$attributes = array("description");

									$rolecmpdessr=ldap_search($ds, $roleinfo[0]["auvwaapplicationrole"][$x], "objectclass=group", $attributes);
																
									$rolecmpdesinfo = ldap_get_entries($ds, $rolecmpdessr)

									?>
									<tr>
										<td class="first"><?php echo $rolecmpdesinfo[0]["description"][0]; ?></td><td align="right"><input type=checkbox></td>
																
									</tr>
		
									<?php
								}

							}
						}
					}	
				}
			}
		} else {

			?><tr>
				<td class="first"><b>Please select a group from the list above.</b></td>
										
			</tr> <?php
		}

			

		?>

	</table>
</form>

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


