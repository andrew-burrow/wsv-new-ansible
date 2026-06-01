<?php

function dispMenu() {

if ($_SESSION['roles'] == "Admin") {

?>

<div id="leftcolumn">

<div class="innertube">
<SCRIPT language="JavaScript">
	function submitEnv(strEnv)
	{
		document.changeEnv.env.value = strEnv;
		document.changeEnv.submit();
	}
	function submitFunction(strFunction)
	{		
		document.functionForm.appFunction.value = strFunction;
		document.functionForm.submit();
	}
</SCRIPT>
<form name="functionForm" method="post" action="">
	<input id=appFunction type=hidden name=appFunction>
</form>
<form name="changeEnv" method="post" action="">
	<input id=env type=hidden name=env>
</form>


<div class="arrowlistmenu">

<h3 class="headerbar">Environment</h3>

<ul>
<li align="center">
	<select id="envSelect" onChange="submitEnv(options[selectedIndex].value);">
		<option value="DEV" <?php if ($_SESSION["env"] == "DEV") echo "SELECTED"; ?>>Development</option>
		<option value="TEST" <?php if ($_SESSION["env"] == "TEST") echo "SELECTED"; ?>>Test</option>
		<option value="PROD" <?php if ($_SESSION["env"] == "PROD") echo "SELECTED"; ?>>Production</option>
	</select>
</li>
</ul>


</div>


<div class="arrowlistmenu">

<h3 class="headerbar">Function</h3>
<ul>
<!-- <li><a href="javascript:submitFunction('todo');">Create Place</a></li>
<li><a href="javascript:submitFunction('todo');">Create Page</a></li>
<li><a href="javascript:submitFunction('todo');">Create Role</a></li>
<li><a href="javascript:submitFunction('todo');">Manage Place</a></li>
<li><a href="javascript:submitFunction('todo');">Manage Page</a></li>
<li><a href="javascript:submitFunction('todo');">Manage Roles</a></li>
<li><a href="javascript:submitFunction('todo');">Create Company</a></li> -->
<li><a href="javascript:submitFunction('consolidateUsers');">Consolidate Users</a></li>
<li><a href="javascript:submitFunction('manageCompany');">Manage Comapny</a></li>
<li><a href="javascript:submitFunction('migrateApplication');">Migrate Legacy Applications</a></li>

</ul>


</div>

<div class="arrowlistmenu">

<h3 class="headerbar">Reports</h3>
<ul>
<li><a href="javascript:submitFunction('agentReport');">Agent Role report</a></li>
<li><a href="javascript:submitFunction('todo');">Panel Firm Role Report</a></li>
<li><a href="javascript:submitFunction('todo');">Worksafe Role Report</a></li>
</ul>


</div>

</div>


</div>




<?php 

} else if ($_SESSION['roles'] == "Reporter") {

?>

<div id="leftcolumn">

<div class="innertube">
<SCRIPT language="JavaScript">
	function submitEnv(strEnv)
	{
		document.changeEnv.env.value = strEnv;
		document.changeEnv.submit();
	}
	function submitFunction(strFunction)
	{		
		document.functionForm.appFunction.value = strFunction;
		document.functionForm.submit();
	}
</SCRIPT>
<form name="functionForm" method="post" action="">
	<input id=appFunction type=hidden name=appFunction>
</form>
<form name="changeEnv" method="post" action="">
	<input id=env type=hidden name=env>
</form>

<div class="arrowlistmenu">

<h3 class="headerbar">Reports</h3>
<ul>
<li><a href="javascript:submitFunction('agentReport');">Agent Role report</a></li>
<li><a href="javascript:submitFunction('todo');">Panel Firm Role Report</a></li>
<li><a href="javascript:submitFunction('todo');">Worksafe Role Report</a></li>

</ul>


</div>

</div>


</div>


<?php 

} else {

?>

You dont have any roles! <?php echo $_SESSION['roles'] ?>

<?php

}

}

?> 
