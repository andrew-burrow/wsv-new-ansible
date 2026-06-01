 <?php

function loadUsers($env, $context, $surname, $givenName) {

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
	  $html =  '
		  <select id="sourceUserDN" SIZE=10 onclick="do_loadUserAtts();">'.$allUserSelect.'</select>
	  
	  ';

} else {

  $html =  "Unable to find user";

}

    $objResponse = new xajaxResponse();
    
    $objResponse->assign("userListContainer","innerHTML", "html");
    
    //return the  xajaxResponse object
    return $objResponse;


}

function loadUserAtts($env, $userDN) {

include_once('ldap2.php');

$attributes = array("cn", "dn", "email");

$query = "(cn=*)";
 
$userInfo = ldapSearch($env, $query, $userDN, $attributes);
 

if ($userInfo["count"] > 0) {
	
    for ($i=0; $i<$userInfo["count"]; $i++) {

	    $userInfo[$i]["dn"] = $userCN;
	    $userInfo[$i]["groupMembership"][0] = $userGroups;
	    $userInfo[$i]["email"][0] = $userEmail;


	    $tbodyHtml = $tbodyHtml."<tr><td>UserName</td><td>".$userDN."</td><td><input id=migrateCN type=checkbox /></td></tr>";
	    $tbodyHtml = $tbodyHtml."<tr><td>eMail</td><td>".$userEmail."</td><td><input id=migrateEmail type=checkbox /></td></tr>";
	    



    }

	  $html = '
		<table summary="Source User Attributes">
			    <caption>Source User</caption>
			    <thead>
				    <tr>
					    <th scope="col">Attribute</th>
					    <th scope="col">Value</th>
					    <th scope="col">Migrate</th>
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
    
    $objResponse->assign("sourceUserAtts","innerHTML", $html);
    
    //return the  xajaxResponse object
    return $objResponse;


}




function consolidateUsers() {

?>

<div id="contentwrapper">
<div id="contentcolumn">
<div class="innertube">

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
			<td colspan=3 align=center><input type="submit" name="submit" tabindex="4" value="Search >" onclick="do_loadUsers(); return false;" class="button"></td>
		    </tr>
		    <tr>
			  <td align=center colspan=4><div id=userListContainer></div></td>
		    </tr>

	    </tbody>
    </table>
<br>
<br>

<div id="sourceUserAtts"></div>


</div>
</div>
</div>

<?php

}

?>