 
<html>
<head>

<style type="text/css">
<!--
@import url("./style.css");
-->
</style>
<title>OES Testing User Management Utility</title>

<SCRIPT TYPE="text/javascript">

			function saveRecord() {

				alert("This is a test");
			}

	</script>

</head>
<body>

<script type="text/javascript">
function download() {

  var env = document.getElementById('searchEnv');

  window.location = "?searchEnv=" + env.value + "&dwnList=download&searchFunction=Download";
}
</script>

<br><br>
<h1 align="center">OES Testing User Management Utility</h1>
<br><br>

<p>

<?php

ini_set("memory_limit","22M");

error_reporting(0);

// Agent codes

$agentCodes = array("04", "08", "09", "12", "21", "27");

// Environments

$testEnv = "ou=test,ou=employers,o=communities";
$devEnv = "ou=dev,ou=employers,o=communities";
$intEnv = "ou=int,ou=employers,o=communities";
$svtEnv = "ou=svt,ou=employers,o=communities";
$prdaEnv = "ou=proda,ou=employers,o=communities";
$trngEnv = "ou=trng,ou=employers,o=communities";


//Setup query strings

$searchFunction="";
$searchWen="";
$searchRegistered="";
$searchAgent="";
$basedn="";

$saveDN="";
$savePassword="";
$saveResetPassword="";
$saveRegistered="";
$dwnList="";



if(isset($_GET["searchFunction"])) {

	if ($_GET["searchFunction"] != "") {

		$searchFunction = $_GET["searchFunction"];
	}
} else {

        $searchFunction = "";
}

if(isset($_GET["searchWen"])) {

	if ($_GET["searchWen"] != "") {

		$searchWen = $_GET["searchWen"];
	}
} else {
        $searchWen = "";
}

if( isset( $_GET["searchRegistered"] ) ) {

	if ($_GET["searchRegistered"] != "----") {

		$searchRegistered = $_GET["searchRegistered"];
	}
	
} else {

        $searchRegistered = "";
}

if( isset( $_GET["searchAgent"] ) ) {

	if ($_GET["searchAgent"] != "----") {

			$searchAgent = $_GET["searchAgent"];
	}
} else {
        $searchAgent = "";
}


if(isset($_GET["searchEnv"])) {

	if ($_GET["searchEnv"] != "") {

		$searchEnv = $_GET["searchEnv"];

		if ($_GET["searchEnv"] == "test"){
			$basedn = $testEnv;
		}
		if ($_GET["searchEnv"] == "dev"){
			$basedn = $devEnv;
		}
		if ($_GET["searchEnv"] == "int"){
			$basedn = $intEnv;
		}
        if ($_GET["searchEnv"] == "svt"){
			$basedn = $svtEnv;
		}
		if ($_GET["searchEnv"] == "proda"){
			$basedn = $prdaEnv;
		}
		if ($_GET["searchEnv"] == "trng"){
			$basedn = $trngEnv;
		}
	}
} else {
        $basedn = "";
	$searchEnv = "";		
}

if(isset($_GET["saveDN"])) {

	if ($_GET["saveDN"] != "") {

		$saveDN = $_GET["saveDN"];
	}
} else {

        $saveDN = "";
}

if(isset($_GET["savePassword"])) {

	if ($_GET["savePassword"] != "") {

		$savePassword = $_GET["savePassword"];
	}
} else {

        $savePassword = "";
}

if(isset($_GET["saveResetPassword"])) {

	if ($_GET["saveResetPassword"] != "") {

		$saveResetPassword = $_GET["saveResetPassword"];
	}
} else {

        $saveResetPassword = "";
}

if(isset($_GET["saveRegistered"])) {

	if ($_GET["saveRegistered"] != "") {

		$saveRegistered = $_GET["saveRegistered"];
	}
} else {

        $saveRegistered = "";
}

if(isset($_GET["dwnList"])) {

	if ($_GET["dwnList"] != "") {

		$dwnList = $_GET["dwnList"];
	}
} else {
  $dwnList = "";
}


?>



<?php

/* Declaration LDAP variables*/ 

if ($_GET["searchEnv"] == "proda" || $_GET["searchEnv"] == "trng") {


  $ldaprdn  = 'cn=oesuserman,o=admin';     // ldap rdn or dn
  $ldappass = '3AkazZA';  // associated password

  $attributes = array("cn","description", "accesscardnumber", "auvwaorrregistered", "auvwaorrinsurercode");
  $server_name="ldboesldap.services.workcover.vic.gov.au"; 
  $port="389"; 



} else {

$ldaprdn  = 'cn=oesuserman,o=sa';     // ldap rdn or dn
$ldappass = '3AkazZA';  // associated password

$attributes = array("cn","description", "accesscardnumber", "auvwaorrregistered", "auvwaorrinsurercode");
$server_name="testldboesldap.services.workcover.vic.gov.au"; 
$port="389"; 

}

// Main program logic

if ($searchFunction == "query" || $searchFunction == "" ) {

  if ($searchFunction != "download") {

	clearFiles();
	queryDir();

  }

} else if ($searchFunction == "save") {

	saveRecord();

} else if ($dwnList == "download") {

	download();
}

function clearFiles() {

$dir = opendir ("."); 
        while (false !== ($file = readdir($dir))) { 
                if (strpos($file, '.csv',1)) { 
                    unlink($file);
                } 
        }


}

function queryDir() {

	global $ldaprdn, $ldappass, $attributes, $server_name, $port, $basedn, $searchWen, $searchRegistered, $searchAgent, $searchEnv, $searchWen, $searchRegistered, $agentCodes;

	?>
	
	<form>
	
	<table summery="Search Paramaters">
	<caption>Select Query Parameters</caption>
	<tr class="odd">
	<th scope="col">Environment</th><th scope="col">WEN</th><th scope="col">Registered</th><th scope="col">Agent Code</th><th scope="col"></th>
	</tr>
	
	<tbody>
	<tr class="odd">
	<td scope="col">	
		<select name=searchEnv id=searchEnv>
	
			<option value="----">----</option>
			<option <?php if ($searchEnv == "test") { echo "SELECTED"; }; ?> value="test">UAT</option>
			<option <?php if ($searchEnv == "dev") { echo "SELECTED"; }; ?> value="dev">DEV</option>
			<option <?php if ($searchEnv == "int") { echo "SELECTED"; }; ?> value="int">INT</option>
            <option <?php if ($searchEnv == "svt") { echo "SELECTED"; }; ?> value="svt">SVT</option>
			<option <?php if ($searchEnv == "trng") { echo "SELECTED"; }; ?> value="trng">TRNG</option>
			<option <?php if ($searchEnv == "proda") { echo "SELECTED"; }; ?> value="proda">PRODA</option>
		</select>
		<input type=button name="searchFunction" value="Download" onClick="javascript:download();">
	</td>
	<td scope="col"><input name=searchWen type=text value="<?php if ($searchWen != "") { echo $searchWen; } else {echo "*";} ?>"></input></td>
	<td scope="col">	
		<select name=searchRegistered>
			<option value="----">----</option>
			<option <?php if ($searchRegistered == "false") { echo "SELECTED"; }; ?> value="false">false</option>
			<option <?php if ($searchRegistered == "true") { echo "SELECTED"; }; ?> value="true">true</option>
		</select></td>
	<td scope="col">
	<select name=searchAgent>
		<option value="----">----</option>
	
		<?php
		foreach ($agentCodes as $value) {
		
			if ($value == $searchAgent) {
		
				echo "<option SELECTED value=\"".$value."\">".$value."</option>";
			} else {
		
				echo "<option value=\"".$value."\">".$value."</option>";
			}
		
		}
	
		?>
		</select></td>
	<input type="hidden" name="searchFunction" value="query"></input>
	</td>
	<td scope="col"><input type=submit name="Search" value="Search"></td>
	
	</tr>
	
	</tbody>
	</table>
	
	</form>
	
	<br>


	<?php



	if ($basedn != "") {

		if ($searchWen != "" || $searchRegistered != "" || $searchAgent != "") {
		

			$paramCount = 0;
			$query = "";
		
			if ($searchWen != "") {
		
                                $query= $query."(cn=".$searchWen.")";
				$paramCount= $paramCount + 1;
			} 
		
			if ($searchAgent != ""){
			
					$query = $query."(auvwaorrinsurercode=".$searchAgent.")";
					$paramCount= $paramCount + 1;
			} 
		
			if ($searchRegistered != ""){
		
				$query = $query."(auvwaorrregistered=".$searchRegistered.")";
				$paramCount= $paramCount + 1;
			} 
		
		
			if ($paramCount > 1) {
			
				$query = "(&".$query.")";
		
			}
			
			
			// connect to ldap server
			$ds = ldap_connect($server_name, $port)
			or die("Could not connect to LDAP server.");
			
			if ($ds) {
			
				// Set search limit to 100 enmployers
				ldap_set_option($ds, LDAP_OPT_SIZELIMIT, 500);
		
				// binding to ldap server
				$ldapbind = ldap_bind($ds, $ldaprdn, $ldappass);
				
				
				// verify binding
				if ($ldapbind) {
				

                                        echo "<!--";
					echo "<br>basedn:$basedn";
                                        echo "<br>query:$query";
					echo "-->";

					$sr=ldap_search($ds, $basedn, $query, $attributes);
					
					$info = ldap_get_entries($ds, $sr);
				
				
					if ($info["count"] > 0) {
				
						if ($info["count"] = 500) {
		
							echo "<p>Note: Query result will only show the first 500 Employers returned";
		
						}
						
						echo "<table summary=\"Query Results\">";
						echo "<caption>Query Results</caption>";
						echo "<tr class=\"odd\">";
						echo "<th scope=\"col\"><font size=2>WEN</font></th>";
						echo "<th scope=\"col\"><font size=2>Company Name</font></th>";
						echo "<th scope=\"col\"><font size=2>Agent Code</font></th>";
						echo "<th scope=\"col\"><font size=2>Last Known Password</font></th>";
						echo "<th scope=\"col\"><font size=2>Reset Password</font></th>";
						echo "<th scope=\"col\"><font size=2>Registered</font></th>";
						echo "<th scope=\"col\"><font size=2>Save</font></th>";
						echo "</tr><tbody>";
						
						for ($i=0; $i<$info["count"]; $i++) {
		
							if ($info[$i]["cn"][0] == "") {
		
								$i = 499;
							} else {
					
							echo "<tr class=\"odd\"><form>";
							echo "<input type=\"hidden\" name=\"searchFunction\" value=\"save\"></input>";
							echo "<input type=\"hidden\" name=\"searchEnv\" value=\"".$searchEnv."\"></input>";
							echo "<input type=\"hidden\" name=\"searchWen\" value=\"".$searchWen."\"></input>";
							echo "<input type=\"hidden\" name=\"searchRegistered\" value=\"".$searchRegistered."\"></input>";
							echo "<input type=\"hidden\" name=\"searchAgent\" value=\"".$searchAgent."\"></input>";
							echo "<input type=\"hidden\" name=\"saveDN\" value=".$info[$i]["dn"]."></input>";
							echo "<td scope=\"col\"><font size=2>".$info[$i]["cn"][0]."</font></td>";
							echo "<td scope=\"col\"><font size=2>".$info[$i]["description"][0]."</font></td>";
							echo "<td scope=\"col\"><font size=2>".$info[$i]["auvwaorrinsurercode"][0]."</font></td>";
							echo "<td scope=\"col\"><font size=2><input type=text name=savePassword value=\"".$info[$i]["accesscardnumber"][0]."\"></input>  </font></td>";
							echo "<td scope=\"col\"><input title\"Password will be reset to last know password\" type=checkbox name=\"saveResetPassword\"></input></td>";
							echo "<td scope=\"col\"><SELECT name=saveRegistered>";
							if ($info[$i]["auvwaorrregistered"][0] != "true") {
								echo "<option SELECTED value=\"false\">false</option>";
								echo "<option value=\"true\">true</option>";
							} else {
								echo "<option value=\"false\">false</option>";
								echo "<option SELECTED value=\"true\">true</option>";
							}
							echo "</SELECT></td>";
							echo "<td scope=\"col\"><input type=\"submit\" value=\"Save\"></td>";
							echo "</form></tr>";
							}
						}
					
						echo "</tbody></table>";
					
						ldap_close($ds);
					} else {
						echo "<p>No Employers found. Please try again";
					}
				
				} else {
					echo "LDAP bind failed...";
				}
			
			}
		} else {
			echo "<p>Please select at least one Query Parameter";
		}
	
	} else {
	
		echo "<p> Please select and environment";
	}

}

function saveRecord() {

	global $ldaprdn, $ldappass, $attributes, $server_name, $port, $basedn, $saveDN, $savePassword, $saveResetPassword, $saveRegistered, $searchEnv, $searchWen, $searchRegistered, $searchAgent;

echo "This is a test";

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

			$entry["auvwaorrregistered"][0] = $saveRegistered;
	
			$entry["accessCardnumber"][0] = $savePassword;

			if ($saveResetPassword == "on") {

				$entry["userPassword"][0] = $savePassword;

			}			

			$saveResult = ldap_modify($ds, $saveDN, $entry);

			if($saveResult == "TRUE") {

				if ($saveRegistered != "") {

					$statusSaveRegistered = $saveRegistered;
				}

				echo "<table summary=\"Save Results\">";
				echo "<caption>Save Result</caption>";
				echo "<tr class=\"odd\">";
				echo "<th scope=\"col\">Successfully Saved</th>";
				echo "<th scope=\"col\"><form>";
				echo "<input type=\"hidden\" name=\"searchFunction\" value=\"query\"></input>";
				echo "<input type=\"hidden\" name=\"searchEnv\" value=\"".$searchEnv."\"></input>";
				echo "<input type=\"hidden\" name=\"searchWen\" value=\"".$searchWen."\"></input>";
				echo "<input type=\"hidden\" name=\"searchRegistered\" value=\"".$searchRegistered."\"></input>";
				echo "<input type=\"hidden\" name=\"searchAgent\" value=\"".$searchAgent."\"></input>";
				echo "<input type=submit value=\"Back to Search\"></form></th>";
				echo "</tr><tbody>";
				echo "</tbody></table>";
			
				echo "<br><br>";
			
			
				echo "<table summary=\"Save Details\">";
				echo "<caption>Save Details</caption>";
				echo "<tr class=\"odd\">";


				echo "<th scope=\"col\">".$saveDN."</th>";
				echo "<th scope=\"col\"></th>";
				echo "<tr class=\"odd\">";
				echo "<th scope=\"col\">Last Know Password</th>";
				echo "<th scope=\"col\">".$savePassword."</th>";
				echo "</tr>";	
				echo "<tr class=\"odd\">";
				echo "<th scope=\"col\">Registered</th>";
				echo "<th scope=\"col\">".$statusSaveRegistered."</th>";
				echo "</tr>";

				if ($saveResetPassword == "on") {
					echo "<tr class=\"odd\">";
					echo "<th scope=\"col\">Password Reset</th>";
					echo "<th scope=\"col\">Yes</th>";
					echo "</tr>";
				}	
								
				echo "</tbody></table>";


			} else { echo "Saved Failed...Please try again"; }


		} else { echo "LDAP bind failed..."; }
			
	}

}

function download() {

	global $ldaprdn, $ldappass, $attributes, $server_name, $port, $basedn, $saveDN, $savePassword, $saveResetPassword, $saveRegistered, $searchEnv, $searchWen, $searchRegistered, $searchAgent;

	// connect to ldap server
	$ds = ldap_connect($server_name, $port)
	or die("Could not connect to LDAP server.");

	$attributes = array("cn","description", "accesscardnumber", "auvwaorrregistered", "auvwaorrinsurercode");
	
	if ($ds) {
	
		// Set search limit to get all employers
		ldap_set_option($ds, LDAP_OPT_SIZELIMIT, 300000);

		// binding to ldap server
		$ldapbind = ldap_bind($ds, $ldaprdn, $ldappass);
				
		// verify binding
		if ($ldapbind) {

			$sr=ldap_search($ds, $basedn, "(objectClass=user)", $attributes );
			
			$info = ldap_get_entries($ds, $sr);
		
		
			if ($info["count"] > 0) {

			      // Create file for download

			      $myFile = "AllEmployers_".$searchEnv. "_".date(ihdmy). ".csv";
			      $fh = fopen($myFile, 'w') or die("can't open file");

			      fwrite($fh, "Username| Legal Name| Insurer Code|Last Known Password|Registered\n");	

			      for ($i=0; $i<$info["count"]; $i++) {

				$userEntry = $info[$i]["cn"][0] . "|". $info[$i]["description"][0]."|".$info[$i]["auvwaorrinsurercode"][0]."|".$info[$i]["accesscardnumber"][0]."|";

				if ($info[$i]["auvwaorrregistered"][0] != "true") {
					$userEntry = $userEntry."FALSE";				
				} else {
					$userEntry = $userEntry."TRUE";
				}
				      
				fwrite($fh, $userEntry."\n");			

			      }



				echo "<table summary=\"Download User List\">";
				echo "<caption>Download User List</caption>";
				echo "<tr class=\"odd\">";
				echo "<th scope=\"col\">Successfully Produced File for ".$searchEnv."</th>";
				echo "<th scope=\"col\"><A HREF=".$myFile.">Download</a></th>";
				echo "<tr/>";

				echo "<th colspan=2 scope=\"col\"><form>";
				echo "<input type=\"hidden\" name=\"searchFunction\" value=\"query\"></input>";
				echo "<input type=\"hidden\" name=\"searchEnv\" value=\"".$searchEnv."\"></input>";
				echo "<input type=\"hidden\" name=\"searchWen\" value=\"".$searchWen."\"></input>";
				echo "<input type=\"hidden\" name=\"searchRegistered\" value=\"".$searchRegistered."\"></input>";
				echo "<input type=\"hidden\" name=\"searchAgent\" value=\"".$searchAgent."\"></input>";
				echo "<input type=submit value=\"Back to Search\"></form></th>";

				echo "</tbody></table>";



			} 

			fclose($fh);

			} else { echo "Failed to produce file....please try again"; }


	} else { echo "LDAP bind failed..."; }
			

}

?>

<br><br><br>

<p align=center>v0.5
</body>
</html>

