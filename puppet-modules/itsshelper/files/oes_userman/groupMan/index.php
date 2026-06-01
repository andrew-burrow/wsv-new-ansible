<?php

session_set_cookie_params(1200);
session_start(); 


//Includes



require_once("xajax_core/xajax.inc.php");



//Globals

$xajax = new xajax();
//$xajax->setFlag("debug", true);
$xajax->setFlag('allowAllResponseTypes', true);

$xajax->registerFunction("loadUsers");
$xajax->registerFunction("loadUserAtts");


$xajax->processRequest();

//include_once("consolidateUsers.php");

$loginStatus = "";

$version = "v0.01";

if(isset($_POST['env'])) {
	
	$_SESSION['env'] = $_POST['env'];
	

}else if(!isset($_SESSION['env'])) {
	
	$_SESSION['env'] = "DEV";	
}


/* Declaration LDAP variables*/ 

if ($_SESSION['env'] == "DEV") {

$ldaprdn  = 'cn=admin,o=admin';     // ldap rdn or dn
$ldappass = 'password';  // associated password
$server_name="172.29.2.138"; 
$port="389"; 
$basedn = "ou=extranet,o=groups";


} else if ($_SESSION['env'] == "TEST") {

$ldaprdn  = 'cn=admin,o=admin';     // ldap rdn or dn
$ldappass = 'password';  // associated password
$server_name="172.29.2.237"; 
$port="389"; 
$basedn = "ou=extranet,o=groups";


} else if ($_SESSION['env'] == "PROD"){

$ldaprdn  = 'cn=grpadmin,o=admin';     // ldap rdn or dn
$ldappass = '21JumpSt';  // associated password
$server_name="172.29.2.80"; 
$port="389"; 
$basedn = "ou=extranet,o=groups";

} else {

 ?><script>alert("Cant find env");</script> <?php

}


?>

<html>

<head>
	<LINK href="themes/layout.css" rel="stylesheet" type="text/css">	
	<LINK href="themes/main.css" rel="stylesheet" type="text/css">	
	<LINK href="themes/menu.css" rel="stylesheet" type="text/css">	
</head>

<body>
<?php $xajax->printJavascript(); ?>
<script>

function do_loadUsers(userDiv) {

var env = document.getElementById("envSelect").value;
var surname = document.getElementById(userDiv + "Surname").value;
var givenName = document.getElementById(userDiv + "GivenName").value;
var context = document.getElementById(userDiv + "Context").value;

document.getElementById(userDiv + "Atts").innerHTML = "";

xajax_loadUsers(env, userDiv, context, surname, givenName);	

}


function do_loadUserAtts(userDiv) {

var env = document.getElementById("envSelect").value;
var userDN = document.getElementById(userDiv + "UserDN").value;

xajax_loadUserAtts(env, userDiv, userDN);

}



</script>
<div id="maincontainer">


<?php


include_once('auth.php');
include_once('menu.php');
include_once('ldap2.php');
include_once('roles.php');
include_once('header.php');
require_once("reporting/generatereport.php");
#include_once('webservice.php');

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

			if ($appFunction == "migrateApplication") {

				if (isset($_POST["migrateStep"])) {
			
					$migrateStep = $_POST["migrateStep"];
				} else {

					$migrateStep = "1";
				}

				if (isset($_POST["applicationDN"])) {
			
					$applicationDN = $_POST["applicationDN"];
				}


				if (isset($_POST["pageCount"])) {

					$arrPageDN = array();
	
					$pageCount = $_POST["pageCount"];


					$x = 0;	

					for ($i = 0; $pageCount > $i; $i++) {

						if (isset($_POST[$i."pageDN"])) {

							$arrPageDN[$x] = $_POST[$i."pageDN"];
							$x++;

						}
					}
				}

				if (isset($_POST["companyCount"])) {

					$arrCompanyDN = array();
	
					$companyCount = $_POST["companyCount"];

					$x = 0;	

					for ($i = 0; $companyCount > $i; $i++) {

						if (isset($_POST[$i."companyDN"])) {

							$arrCompanyDN[$x] = $_POST[$i."companyDN"];
							$x++;

						}
					}
				}
	
				migrateApplication();
			}

			if ($appFunction == "manageCompany") {

				if (isset($_POST["companyDN"])) {
			
					$companyDN = $_POST["companyDN"];
				}


				if (isset($_POST["Action"])) {

					$action = $_POST["Action"];

					if (isset($_POST["attribute"])) {
	
						$attribute = $_POST["attribute"];
	
					}		
	
					if (isset($_POST["attributeValue"])) {
	
						$attributeValue = $_POST["attributeValue"];
	
					}
				
				
				} 


				manageCompany();
			}
			if ($appFunction == "webservice") {

				dispWS();
			}

			if ($appFunction == "agentReport") {

				if (isset($_POST["reportStep"])) {

					$reportStep = $_POST["reportStep"];

					if (isset($_POST["altEmail"])) {
	
						$altEmail = $_POST["altEmail"];
	
					}	
					
					$reportType = "";

					if (isset($_POST["xls"])) {
	
						$reportType = "xls|";
	
					}	
					if (isset($_POST["html"])) {
	
						$reportType = $reportType."html|";
	
					}
				} 


				agentReport();
			}

			if ($appFunction == "consolidateUsers") {

			  consolidateUsers();

			}

			if ($appFunction == "todo") {

				todo();
			}

		} else {
			dispBody();
		}
		
		
		dispMenu();
		

	}
} else {

	

	if (isset($_POST['username']) && isset($_POST['password'])) {

		// Try to log user in

		$username = $_POST["username"];
		$userPassword = $_POST["password"];

		ldapLogin();

	} else {

		// Display login form
	
		dispLogin();
		
	}
}

function dispBody() {

?>

<div id="contentwrapper">
<div id="contentcolumn">
<div class="innertube">
<table width=80%>
<tr align="center" border=1px><td align="center"><br><br>
<img src="images/app-cmp-role-pla-relationship.png">
</td></tr>
</table>
</div>
</div>
</div>


<?

}

function todo() {

global $applicationDN, $arrPageDN, $pageCount, $appFunction;

$roleCount = sizeof($arrPageDN);

?>

<div id="contentwrapper">
<div id="contentcolumn">
<div class="innertube">
<b>This functionality is not available yet!</b>
</div>
</div>
</div>
<?php
}

function migrateApplication() {

global $applicationDN, $arrPageDN, $pageCount, $appFunction, $arrCompanyDN, $migrateStep;

?>

<div id="contentwrapper">
<div id="contentcolumn">
<div class="innertube">

<SCRIPT language="JavaScript">
	function submitMigrateApp(applicationDN, arrPageDN, step)
	{		
		document.migrateAppForm.applicationDN.value = applicationDN;
		document.migrateAppForm.arrPageDN.value = arrPageDN;
		document.migrateAppForm.migrateStep.value = step;
		document.migrateAppForm.submit();
	}
</SCRIPT>

<form name="migrateAppForm" method="post" action="">
	<input type="hidden" name="migrateStep" id="migrateStep">
	<input type=hidden name=appFunction id=appFunction value=migrateApplication>
	<input type=hidden name=applicationDN id=applicationDN>
	<input type=hidden name=arrPageDN id=arrPageDN>
</form>

<?php 

	if ($migrateStep == "1") {

		$pageCount = null;

		$attributes = array("cn", "description", "dn");
	
		$info = ldapSearch("(cn=app-*)","", $attributes);
	
		if ($info["count"] > 0) {
	
			?>
			
			<table summary="Select an Application to migrate">
				<caption>Available Applications</caption>
				<thead>
					<tr>
						<th scope="col">Description</th>
						<th scope="col">Common Name</th>
						<th scope="col">Distinguished Name</th>
					</tr>
				</thead>	

				<tbody>
		
				<?php
				
				for ($i=0; $i<$info["count"]; $i++) {
	
					?>
					<tr >
						<th scope="row"><a href="javascript:submitMigrateApp('<?php echo $info[$i]["dn"]; ?>', '', '2');"><?php echo $info[$i]["description"][0]; ?></a></th>
						<td><?php echo $info[$i]["cn"][0]; ?></td>
						<td><?php echo $info[$i]["dn"]; ?></td>
					</tr>
					<?php
				}
	
				?>
				</tbody>
			</table>

			
			<?php
		}

	} else if ($migrateStep == "2") {

		$attributes = array("cn", "description", "dn", "applicationRoles");
	
		$appInfo = ldapSearch("(cn=*)", $applicationDN, $attributes);

		$appCN = "";
	
		if ($appInfo["count"] > 0) {
	
				
			for ($i=0; $i<$appInfo["count"]; $i++) {

				$appCN = $appInfo[$i]["cn"][0];
	
			?>
			
				<table summary="Select an Application to migrate">
					<caption><?php echo $appInfo[0]["description"][0]; ?></caption>
					<thead>
						<tr>
							<th scope="col">Description</th>
							<th scope="col">Common Name</th>
							<th scope="col">Distinguished Name</th>
						</tr>
					</thead>	
	
					<tbody>
						<tr >
							<th scope="row"><?php echo $appInfo[$i]["description"][0]; ?></th>
							<td><?php echo $appInfo[$i]["cn"][0]; ?></td>
							<td><?php echo $appInfo[$i]["dn"]; ?></td>
						</tr>
	
					</tbody>
				</table>
	
				<br>
			<?php 
			}
		}

		$attributes = array("cn", "description", "dn");

		$splitAppName = split("-", $appCN);
	
		$pageInfo = ldapSearch("(cn=page-*-".$splitAppName[1]."*)", "", $attributes);
	
		if ($pageInfo["count"] > 0) {

			
				?>
				<form class="white" name="migrateAppFormPage" method="post" action="">

					<table summary="Select Page group to Migrate to">
						<caption>Select Page group to be migrated</caption>
						<thead>
							<tr>
								<th scope="col">Description</th>
								<th scope="col">Common Name</th>
								<th scope="col">Distinguished Name</th>
								<th scope="col">Migrate</th>
							</tr>
						</thead>	
		
						<tbody>
							<?php
							for ($i=0; $i<$pageInfo["count"]; $i++) {
								?>
								<tr >
									<th scope="row"><?php echo $pageInfo[$i]["description"][0]; ?></th>
									<td><?php echo $pageInfo[$i]["cn"][0]; ?></td>
									<td><?php echo $pageInfo[$i]["dn"]; ?></td>
									<td align=center><input type=checkbox name="<?php echo $i."pageDN"; ?>" value="<?php echo $pageInfo[$i]["dn"]; ?>"></td>
	
								</tr>
							
							<?php 
							} 
							?>
		
						</tbody>
					</table>
					<br>
		
					<input type="hidden" name="appFunction" id="appFunction" value="migrateApplication">
					<input type="hidden" name="migrateStep" id="migrateStep" value="3">
					<input type="hidden" name="applicationDN" id="applicationDN" value="<?php echo $applicationDN?>">
					<input type="hidden" name="pageCount" id="pageCount" value="<?php echo $pageInfo["count"];?>">

					<input type="button" name="back" tabindex="4" value="< Back" class="button" onClick="javascript:submitFunction('migrateApplication');">
	
					<input type="submit" name="submit" tabindex="4" value="Migrate >" class="button">

				</form>
				<br>
				
				<?php
		}


	} else if ($migrateStep == "3") {

		
		$attributes = array("cn", "description", "dn", "auvwaapplicationrole", "auvwaapplicationadmin");
			
		$appInfo = ldapSearch("(cn=*)", $applicationDN, $attributes);
	
		$appCN = "";
		$appDN = "";
		$appDescription = "";
		$applicationRoles = array();
		$applicationAdmin = "";

		if ($appInfo["count"] > 0) {
			
			for ($i=0; $i<$appInfo["count"]; $i++) {

				$appCN = $appInfo[$i]["cn"][0];
				$appDN = $appInfo[$i]["dn"];
				$appDescription = $appInfo[$i]["description"][0];
				$applicationAdmin = $appInfo[$i]["auvwaapplicationadmin"][0];

			}

			for ($x=0; $x<$appInfo[0]["auvwaapplicationrole"]["count"]; $x++) {

				$applicationRoles[$x] = $appInfo[0]["auvwaapplicationrole"][$x];

			}

		}


		foreach ($arrPageDN as $key => $pageDN) {

			// Check for Object Class

			$attributes = array("cn", "objectclass");

			$pageInfo = ldapSearch("(cn=*)", $pageDN, $attributes);
	
			$foundClass = "false";

			if ($pageInfo["count"] > 0) {

				for ($x=0; $x<$pageInfo[0]["objectclass"]["count"]; $x++) {
		
					if ($pageInfo[0]["objectclass"][$x] == "AUVWAgroupAuxClass") {
	
						$foundClass = "true";

					}
				}
			
			}

			if ($foundClass == "false") {

				$entryClass["objectClass"] = "AUVWAgroupAuxClass";
				$result = ldapModify_add($pageDN, $entryClass);	

			}

			$entry["description"] = array($appDescription);

			if ($applicationAdmin != "") {

				$entry["auvwaapplicationadmin"] = array($applicationAdmin);
			}	

			$entry["auvwaapplicationrole"] = $applicationRoles;
		
			$result = ldapModify_replace($pageDN, $entry);

			if ($result = 1) {
					
				}
		}

		?>
		<form class="white" name="migrateCmpFormPage" method="post" action="">
		<table summary="Page group has been migrated">
			<caption>Select the appropriate page group for each company</caption>
			<thead>
				<tr>
					<th scope="col">Company</th>
					<th scope="col">Company Place</th>
					<th scope="col">Current Applications</th>
					<th scope="col">Select Appropriate Page Group</th>
				</tr>
			</thead>	

			<tbody>

		<?php

		$attributes = array("cn", "description", "auvwacompanyplace", "auvwaapplication");

		$cmpInfo = ldapSearch("(cn=cmp-*)", "", $attributes);

		for ($i=0; $i<$cmpInfo["count"]; $i++) {
			if (!ereg('CMP-RTO', $cmpInfo[$i]["dn"])) {
				?>
					<tr >
						<th scope="row"><?php echo $cmpInfo[$i]["description"][0]; ?></th>
						<td scope="row"><?php $tmpCmpPlaceInfo = split("=", $cmpInfo[$i]["auvwacompanyplace"][0]); echo $tmpCmpPlaceInfo[1]; ?></td>
						<td><?php
							for ($x=0; $x<$cmpInfo[$i]["auvwaapplication"]["count"]; $x++) {
					
								$tmpCmpApp = split("=",$cmpInfo[$i]["auvwaapplication"][$x]);
								echo $tmpCmpApp[1]."<br>";
							}
							?>
						</td>
						<td><?php
							foreach ($arrPageDN as $key => $pageDN) {
							
							?><input type=checkbox name="<?php echo $i."companyDN"; ?>" value="<?php echo $cmpInfo[$i]["dn"].":".$pageDN; ?>"><?php
							$tmpPageInfo = split("=", $pageDN);
							echo $tmpPageInfo[1]."<br>"; 
							}
							?>
						</td>
					</tr>
				<?php
			}
		}
		?>
	
			</tbody>
		</table>
		<input type="hidden" name="appFunction" id="migrateStep" value="migrateApplication">
		<input type="hidden" name="migrateStep" id="migrateStep" value="4">
		<input type="hidden" name="companyCount" id="companyCount" value="<?php echo $cmpInfo["count"];?>">
		<input type="hidden" name="applicationDN" id="applicationDN" value="<?php echo $applicationDN?>">
		<input type="button" name="back" tabindex="4" value="< Back" class="button" onClick="javascript:submitFunction('migrateApplication');">

		<input type="submit" name="submit" tabindex="4" value="Migrate Companies >" class="button">

		</form>
		<br>
	
		<?php							
			
	} else if ($migrateStep == "4") {	

		foreach ($arrCompanyDN as $key => $companyDN) {

			$tmpCompanyInfo = split(":", $companyDN);
	
			$cmpDN = $tmpCompanyInfo[0];
			$pageDN = $tmpCompanyInfo[1];

			$attributes = array("cn", "auvwaapplicationpage");

			$cmpAppPageInfo = ldapSearch("(cn=*)", $cmpDN, $attributes);

			if ($cmpAppPageInfo["count"] > 0) {

				$foundPage = "false";

				for ($x=0; $x<$cmpAppPageInfo[0]["auvwaapplicationpage"]["count"]; $x++) {

					if ($cmpAppPageInfo[0]["auvwaapplicationpage"][$x] == $pageDN) {

						$foundPage = "true";
					}
					
				}
				
				if ($foundPage == "false") {

					$cmpEntry["auvwaapplicationpage"] = array($pageDN);
					$result = ldapModify_add($cmpDN, $cmpEntry);	
				}

			}

		}

		echo "<b>The migration for ".$applicationDN. " has completed.<br><br> Please choose a menu item on the left to continue or logout.</b>";

	} else {

		?> <b> Unable to process request. Please try again</b> <?php
	}

	?>
	</div>
	</div>
	</div>
	<?php
}

function manageCompany() {

global $companyDN, $description, $companyAdmin, $companyPlace, $companyPages, $action, $attribute, $attributeValue;


?>

<div id="contentwrapper">
<div id="contentcolumn">
<div class="innertube">

<SCRIPT language="JavaScript">
	function submitManageCompany(companyDN, Action, attribute)
	{		
		document.manageCompanyForm.companyDN.value = companyDN;
		document.manageCompanyForm.Action.value = Action;
		document.manageCompanyForm.attribute.value = attribute;
		document.manageCompanyForm.submit();
	}
</SCRIPT>

<form name="manageCompanyForm" method="post" action="">
	<input type=hidden name=appFunction id=appFunction value=manageCompany>
	<input type=hidden name=Action id=Action>
	<input type=hidden name=attribute id=attribute>
	<input type=hidden name=companyDN id=companynDN>
</form>

<?php 

	if (!isset($action)) {

		$attributes = array("cn", "description", "dn");
	
		$info = ldapSearch("(cn=cmp-*)","", $attributes);
	
		if ($info["count"] > 0) {
	
			?>
			
			<table summary="Select an Company to Manage">
				<caption>Available Companies</caption>
				<thead>
					<tr>
						<th scope="col">Description</th>
						<th scope="col">Common Name</th>
						<th scope="col">Distinguished Name</th>
					</tr>
				</thead>	
				<tbody>
		
				<?php
				
				for ($i=0; $i<$info["count"]; $i++) {
					if (!ereg('CMP-RTO', $info[$i]["dn"])) {
					?>
					<tr >
						<th scope="row"><a href="javascript:submitManageCompany('<?php echo $info[$i]["dn"]; ?>','display','');"><?php echo $info[$i]["description"][0]; ?></a></th>
						<td><?php echo $info[$i]["cn"][0]; ?></td>
						<td><?php echo $info[$i]["dn"]; ?></td>
					</tr>
					<?php
					}
				}
	
				?>
				</tbody>
			</table>

			
			<?php
		}

	} else if ($action == "display") {


		$attributes = array("cn", "description", "auvwacompanyadmin", "auvwaapplicationPage", "auvwacompanyPlace");
	
		$cmpInfo = ldapSearch("(cn=*)", $companyDN, $attributes);
	
			
		if ($cmpInfo["count"] > 0) {

			
				?>
				

					<table summary="Company Details">
						<caption><?php echo $cmpInfo[0]["description"][0]; ?></caption>
						<tbody>
							<tr>
								<th scope="col">Common Name</th>
								<td scope="col"><?php echo $cmpInfo[0]["cn"][0]; ?></td>
								<td/>
							</tr>
							<tr>
								<th scope="col">Description</th>
								<td scope="col"><?php echo $cmpInfo[0]["description"][0]; ?></td>
								<td scope="col"><input class="button" type="button" value="Edit" onClick="javascript:submitManageCompany('<?php echo $cmpInfo[0]["dn"]; ?>','edit','description');"></td>
							</tr>
							<tr>
								<th scope="col">Company Admin</th>
								<td scope="col"><?php echo $cmpInfo[0]["auvwacompanyadmin"][0]; ?></td>
								<td scope="col"><input class="button" type="button" value="Edit" onClick="javascript:submitManageCompany('<?php echo $cmpInfo[0]["dn"]; ?>','edit','auvwacompanyadmin');"></td>
							</tr>
							<tr>
								<th scope="col">Portal Place</th>
								<td scope="col"><?php echo $cmpInfo[0]["auvwacompanyplace"][0]; ?></td>
								<td scope="col"><input class="button" type="button" value="Edit" onClick="javascript:submitManageCompany('<?php echo $cmpInfo[0]["dn"]; ?>','edit','auvwacompanyplace');"></td>
							</tr>
							<tr>
								<th scope="col">Portal Page Groups</th>
								<td scope="col">
									<?php
									for ($x=0; $x<$cmpInfo[0]["auvwaapplicationpage"]["count"]; $x++) {
					
										echo $cmpInfo[0]["auvwaapplicationpage"][$x]."<br>";
										
									}
								?>
								</td>
								<td scope="col"><input class="button" type="button" value="Edit" onClick="javascript:submitManageCompany('<?php echo $cmpInfo[0]["dn"]; ?>','edit','auvwaapplicationpage');"></td>
							</tr>
						</tbody>
					</table>
					<br>

					<input type="hidden" name="appFunction" id="appFunction" value="manageCompany">
					<input type="hidden" name="applicationDN" id="companyDN" value="<?php echo $companyDN?>">
					
					<input type="button" name="back" tabindex="4" value="< Back" class="button" onClick="javascript:submitFunction('manageCompany');">
	
					

				
				<br>
				
				<?php
		}


	} else if ($action == "edit") {


		$attributes = array("cn", "description", $attribute);
	
		$cmpInfo = ldapSearch("(cn=*)", $companyDN, $attributes);
	
			
		if ($cmpInfo["count"] > 0) {

			
				?>
				<form class="white" name="migrateCmpFormPage" method="post" action="">
					<table summary="Company Details">
						<caption><?php echo $cmpInfo[0]["description"][0]; ?></caption>
						<tbody>
							<?php
							if ($attribute == "description") {
							?>							
								<tr>
									<th scope="col">Description</th>
									<td scope="col"><input name="attributeValue" id="attributeValue" value="<?php echo $cmpInfo[0]["description"][0]; ?>" size="100"></td>
								</tr>
							<?php
							} else if ($attribute == "auvwacompanyplace") {
							?>							
								<tr>
									<th scope="col">Portal Place</th>
									<td scope="col">
									<select id="attributeValue" name="attributeValue">
									<?php
									$attributes = array("cn", "description");
								
									$placeInfo = ldapSearch("(cn=PLA-*)", '', $attributes);

									for ($x=0; $x<$placeInfo["count"]; $x++) {
					
										?> 
										<option value="<?php echo $placeInfo[$x]["dn"];?>" 
										<?php
										if ($cmpInfo[0]["auvwacompanyplace"][0] == $placeInfo[$x]["dn"]) {
											echo " SELECTED ";
										}
										?> ><?php echo $placeInfo[$x]["dn"]; ?> </option> <?php
									}
									

									?>
									</select>
									</td>
									
								</tr>
							<?php

							} else if ($attribute == "auvwacompanyadmin") {
							?>							
								<tr>
									<th scope="col">Company Administrator</th>
									<td scope="col">
									<select id="attributeValue" name="attributeValue">
									<?php
									$attributes = array("cn", "description");
								
									$admInfo = ldapSearch("(cn=ADMCMP-*)", '', $attributes);

									for ($x=0; $x<$admInfo["count"]; $x++) {
					
										?> 
										<option value="<?php echo $admInfo[$x]["dn"];?>" 
										<?php
										if ($cmpInfo[0]["auvwacompanyadmin"][0] == $cmpInfo[$x]["dn"]) {
											echo " SELECTED ";
										}
										?> ><?php echo $admInfo[$x]["dn"]; ?> </option> <?php
									}
									

									?>
									</select>
									</td>
									
								</tr>
							<?php

							}
							?>
						</tbody>
					</table>
					<br>

					<input type="hidden" name="appFunction" id="appFunction" value="manageCompany">
					<input type="hidden" name="companyDN" id="companyDN" value="<?php echo $companyDN?>">
					<input type=hidden name=Action id=Action value="save">
					<input type=hidden name=attribute id=attribute value="<?php echo $attribute; ?>">
					<input type="button" name="back" tabindex="4" value="< Back" class="button" onClick="javascript:submitManageCompany('<?php echo $cmpInfo[0]["dn"]; ?>','display','');">
					<input type="submit" name="submit" tabindex="4" value="Save >" class="button">
					
				</form>
				
				<br>

	<?
		}

	} else if ($action == "save") {


		$entry[$attribute] = array($attributeValue);
		
		$result = ldapModify_replace($companyDN, $entry);


		?>
			<script>submitManageCompany('<?php echo $companyDN; ?>','display','');</script>

		<?php
	} else {

		?> <b> Unable to process request. Please select try again</b> <?php
	}

	?>
	</div>
	</div>
	</div>
	<?php
}


function loadUsers($env, $userDiv, $context, $surname, $givenName) {

include_once('ldap2.php');

$attributes = array("cn", "dn");
 
 if ($surname == "") {
   $surname = "*";
 }
 
 if ($givenName == "") {
   $givenName = "*";
 }
 

$query = "(&(givenName=".$givenName."*)(surname=".$surname."*))";
 
$userInfo = ldapSearch($env, $query, $context, $attributes);
 
$allUserSelect;

if ($userInfo["count"] > 0) {
	
		for ($i=0; $i<$userInfo["count"]; $i++) {
	
		  $allUserSelect = $allUserSelect."<option value='".$userInfo[$i]["dn"]."'>".$userInfo[$i]["cn"][0]."</option>";

	    }

	  $userAttDiv = '"'.$userDiv.'"';
	  $html =  "
		  <select id='".$userDiv."UserDN' SIZE=10 onclick='do_loadUserAtts(".$userAttDiv.");'>".$allUserSelect."</select>
	  
	  ";

} else {

  $html =  "Unable to find user";

}

    $objResponse = new xajaxResponse();
    
    $objResponse->assign($userDiv."List","innerHTML", $html);
    
    //return the  xajaxResponse object
    return $objResponse;


}

function loadUserAtts($env, $userDiv, $userDN) {

include_once('ldap2.php');

$attributes = array("cn", "dn", "mail", "surname", "givenname");

$query = "(cn=*)";
 
$userInfo = ldapSearch($env, $query, $userDN, $attributes);
 

if ($userInfo["count"] > 0) {
	
    for ($i=0; $i<$userInfo["count"]; $i++) {

	    if ($userDiv == "source") {

	      $tbodyHtml = $tbodyHtml."<tr><td>GivenName</td><td>".$userInfo[$i]["givenname"][0]."</td><td><input id=migrateCN type=checkbox DISABLED /></td></tr>";
	      $tbodyHtml = $tbodyHtml."<tr><td>Surname</td><td>".$userInfo[$i]["surname"][0]."</td><td><input id=migrateEmail type=checkbox DISABLED /></td></tr>";
	      $tbodyHtml = $tbodyHtml."<tr><td>eMail</td><td>".$userInfo[$i]["mail"][0]."</td><td><input id=migrateEmail type=checkbox /></td></tr>";
	    
	     $migrateTH = '<th scope="col">Migrate</th>';

	    } elseif ($userDiv == "dest") {

	      $tbodyHtml = $tbodyHtml."<tr><td>GivenName</td><td>".$userInfo[$i]["givenname"][0]."</td></tr>";
	      $tbodyHtml = $tbodyHtml."<tr><td>Surname</td><td>".$userInfo[$i]["surname"][0]."</td></tr>";
	      $tbodyHtml = $tbodyHtml."<tr><td>eMail</td><td>".$userInfo[$i]["mail"][0]."</td></tr>";
	    }

    }

	  $html = '
		<table>
			    
			    <thead>
				    <tr>
					    <th scope="col">Attribute</th>
					    <th scope="col">Value</th>
					   '.$migrateTH.'
				    </tr>
			    </thead>	

			    <tbody>
				 '.$tbodyHtml.'
			    </tbody>
		    </table>
		  
	  
	  ';

} else {

  $html = "Unable to find user";

}

    $objResponse = new xajaxResponse();
    
    $objResponse->assign($userDiv."Atts","innerHTML", $html);
    
    //return the  xajaxResponse object
    return $objResponse;


}




function consolidateUsers() {

?>

<div id="contentwrapper">
<div id="contentcolumn">
<div class="innertube">

<table>
<tr>
<td>

    <table summary="Source User">
		<caption>Source User</caption>
		<thead>
			<tr>
				<th scope="col">Context</th>
				<th scope="col">Given Name</th>
				<th scope="col">Surname</th>
				<th scope="col">Search</th>
			</tr>
		</thead>	

		<tbody>

						
			<tr >
				<td>
				<select id="sourceContext">
					<option value="ou=INTERNAL,o=vwa">Internal</option>
					<option value="ou=EXTERNAL,o=vwa">External</option>
					<option value="ou=TAC,o=vwa">TAC</option>
				</select>

				</td>
				<td><input id="sourceGivenName"></td>
				<td><input id="sourceSurname"></td>
			    <td align=center><input type="submit" name="submit" tabindex="4" value="Search >" onclick="do_loadUsers('source'); return false;" class="button"></td>
			</tr>
			<tr>
			      <td align=center><div id=sourceList></div></td>
			      <td colspan=3><div id="sourceAtts"></div></td>

			</tr>

		</tbody>
	</table>
    <br>
    <br>

</td>
<td>

   <table summary="Destination User">
		<caption>Destination User</caption>
		<thead>
			<tr>
				<th scope="col">Context</th>
				<th scope="col">Given Name</th>
				<th scope="col">Surname</th>
				<th scope="col">Search</th>
			</tr>
		</thead>	

		<tbody>

						
			<tr >
				<td>
				<select id="destContext">
					<option value="ou=INTERNAL,o=vwa">Internal</option>
					<option value="ou=EXTERNAL,o=vwa">External</option>
					<option value="ou=TAC,o=vwa">TAC</option>
				</select>

				</td>
				<td><input id="destGivenName"></td>
				<td><input id="destSurname"></td>
			    <td align=center><input type="submit" name="submit" tabindex="4" value="Search >" onclick="do_loadUsers('dest'); return false;" class="button"></td>
			</tr>
			<tr>
			      <td align=center><div id=destList></div></td>
			      <td colspan=3><div id="destAtts"></div></td>

			</tr>

		</tbody>
	</table>
    <br>
    <br>




</td>
</tr>
</table>




</div>
</div>
</div>

<?php

}

function agentReport() {

global $altEmail, $reportStep, $reportType;

 if ($reportStep != "1") {

  ?>

  <div id="contentwrapper">
  <div id="contentcolumn">
  <div class="innertube">
  <b></b>

  <form class="white" name="agentReport" method="post" action="">

					  <table summary="Agent Report Details">
						  <caption>Agent Report Details</caption>
						  <thead>
							  <tr>
								  <th scope="col"> Current Agents</th>
								  <th scope="col">eMail Address</th>
								  <th scope="col">Report Type</th>
								  
							  </tr>
						  </thead>	
		  
						  <tbody>

								  <tr >
									  <td>Allianz <br> QME <br> WGB <br> GIO <br> Cambridge <br> CGU</td>
									  <td align=center><?php echo $_SESSION['userEmail']; ?> <br><br> or <br><br> <input size="35" name="altEmail" id="altEmail"></td>
									  <td align=center>Excel <input type=checkbox id="xls" value="xls" name="xls"> <br><br> Html <input type=checkbox id="html" value="html" name="html"> </td>
	  
								  </tr>
		  
						  </tbody>
					  </table>
					  <br>
		  
					  <input type="hidden" name="appFunction" id="appFunction" value="agentReport">
					  <input type="hidden" name="reportStep" id="reportStep" value="1">
					  <input type="submit" name="submit" tabindex="4" value="Generate Report >" class="button">

				  </form>

  </div>
  </div>
  </div>
  <?php
  } else if ($reportStep == "1") {

  ?>

    <div id="contentwrapper">
      <div id="contentcolumn">
      <div class="innertube">
      <b></b>

      <form class="white" name="agentReport" method="post" action="">

					      <table summary="Agent Report Details">
						      <caption>Report Generation Complete - Please check for emails</caption>
					  </table>
			  <?php 

				  if (isset($altEmail)) {

				    $email = $altEmail;

				  } else {
				  
				    $email = $_SESSION['userEmail'];

				  }

				  $ret = generateReport($email, "Allianz", "cn=CMP-Allianz,ou=extranet,o=groups", "prod", $reportType);
				  $ret = generateReport($email, "CGU", "cn=CMP-CGU,ou=extranet,o=groups", "prod", $reportType);
				  $ret = generateReport($email, "QME", "cn=CMP-QME,ou=extranet,o=groups", "prod", $reportType);
				  $ret = generateReport($email, "Cambridge", "cn=CMP-Cambridge,ou=extranet,o=groups", "prod", $reportType);
				  $ret = generateReport($email, "GIO", "cn=CMP-GIO,ou=extranet,o=groups", "prod", $reportType);
				  $ret = generateReport($email, "WGB", "cn=CMP-WGB,ou=extranet,o=groups", "prod", $reportType);
		  
		      ?>

				  </form>
  </div>
  </div>
  </div>

  <?php


}
}

?>

</div>
</div>

</body>

</html> 
