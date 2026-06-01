<!-- START header -->
<div id="topsection"><div class="innertube">

<div id="header">
	<h1 id="logo">	
		<a href="http://www.worksafe.vic.gov.au/" target="_blank" title="Work Safe Victoria, Victorian WorkCover Authority">
			<img src="images/logo.gif" height="64" width="354" border="0" alt="WorkSafe Victoria, Victorian WorkCover Authority"/>
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
			<?php if($_SESSION['user'] == "valid") { ?> <li> <?php echo $_SESSION['username']; ?> </li> <li><a href="#" onclick="document.logoutForm.submit();">Logout</a> </li> <?php } ?>
			<li><?php echo $version; ?></li>
			<li><?php echo $_SESSION['env'] ?></li>
			
		</ul>
	</div>


	<!-- Start Menu -->
	
<div id="menu">
<ul>
	<li>Extranet Group Management
	<ul>		
	</ul>
	</li>
</div>

	<!-- End Menu -->
	
</div>

<br>
<!-- END #header --> 


</div>



