<?php

function dispLogin() {

	global $loginStatus;


	?>
	<form class="none" name="loginForm" method="post" action="">
	
	
		<table align="center" width="450px" border="2" cellpadding="0" cellspacing="0">
			<tr>
				<td colspan=2 align="center"><br><b>Login with your Enterprise Username and Password.</b><br><br></td>

			</tr>
			<!--  Entry fields -->
			<tr>
				<td align="right">Username</td>
				<td><input align="right" type="text" name="username" maxlength="30" tabindex="1" value=""> 
				</td>
			</tr>
			<tr>
				<td align="right" nowrap>Password:</td>
				<td ><input type="password" name="password" maxlength="12" tabindex="2" value="">
				</td>
			</tr>
			<tr>
				 <td class="white">&nbsp</td>
				 <td >&nbsp; <?php if ($loginStatus != "") { echo $loginStatus; } ?></td>
			</tr>
			<tr>
				 <td class="white">&nbsp</td>
				<td class="white"><br><span class="indent"> <input type="submit" name="method" tabindex="4" value="Login >" class="button"> </span></td>
			</tr>
	
		</table>
	</form>
			
	


	<?php

}


function ldapLogin() {

	global $username, $userPassword, $loginStatus;

	// Build username - search through Internal and TAC

	$ldaprdn  = "cn=".$username.",ou=internal,o=vwa";
	
	// connect to ldap server
	//$ldapconn = ldap_connect("172.29.2.141")
	$ldapconn = ldap_connect("ldbenldap.services.workcover.vic.gov.au")
	or die("Could not connect to LDAP server.");
	
	if ($ldapconn) {
	
		// binding to ldap server
		$ldapbind = ldap_bind($ldapconn, $ldaprdn, $userPassword);

		if (!$ldapbind) {
		    //Try TAC container
		    $ldaprdn  = "cn=".$username.",ou=TAC,o=vwa";
		    $ldapbind = ldap_bind($ldapconn, $ldaprdn, $userPassword);

		}

                if (!$ldapbind) {
                    //Try External container
                    $ldaprdn  = "cn=".$username.",ou=External,o=vwa";
                    $ldapbind = ldap_bind($ldapconn, $ldaprdn, $userPassword);

                }

		
		// verify binding
		if ($ldapbind) {
	
			//Check group membership
			$attributes = array("groupmembership", "mail", "cn");

			$sr=ldap_read($ldapconn, $ldaprdn, "(objectClass=*)", $attributes);
			
			$info = ldap_get_entries($ldapconn, $sr);
		
			if ($info["count"] > 0) {
  
				$_SESSION['userEmail'] = $info[0]["mail"][0];
				$_SESSION['username'] = $info[0]["CN"][0];
		
				for ($i=0; $i<$info[0]["groupmembership"]["count"]; $i++) {
					
					if ($info[0]["groupmembership"][$i] == "cn=ROL-GROUPMAN-ADMIN,ou=GROUPS,o=VWA") {

						$groupStatus = "member";
						$_SESSION['roles'] = "Admin";

					} else if ($info[0]["groupmembership"][$i] == "cn=ROL-GROUPMAN-REPORTER,ou=GROUPS,o=VWA") {

						$groupStatus = "member";
						$_SESSION['roles'] = "Reporter";
					}
				}
			}

			if ($groupStatus == "member") {

				$_SESSION['user'] = "valid";
				
				mainLogic();
		
			} else {

				$loginStatus = "You do not have access to use this application. Please see the Help Desk to arrange access.";

				dispLogin();
			}

		} else {
	
			$loginStatus = "Login Failed. Please try again";

			dispLogin();
		}

	ldap_close($ldapconn);
	
	}

}

?> 
