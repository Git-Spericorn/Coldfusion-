<!DOCTYPE html>
<html>
<head>
	<title></title>
	<title>FantasyNation.com</title>
	<meta name="viewport" content="width=device-width, initial-scale=1.0">
	<link rel="stylesheet" type="text/css" href="/assets/css/all.min.css">
	<link rel="stylesheet" type="text/css" href="/assets/css/bootstrap.min.css">
	<link rel="stylesheet" type="text/css" href="/assets/css/style.css?key=<cfoutput>#application.cacheKey#</cfoutput>">
	<script type="text/javascript" src="/assets/js/jquery.min.js"></script>
	<script src="/assets/js/popper.min.js"></script>
	<script type="text/javascript" src="/assets/js/bootstrap.min.js"></script>
	<cfif structKeyExists(cgi, 'SCRIPT_NAME') and cgi.SCRIPT_NAME neq '/login.cfm' >
		<script>
			$(document).ready(function() {
				$('[name=rediretLoc]').val(location.href);
			});
		</script>
	</cfif>
</head>
<body class="offlinePageBody">
	<cfset local.heading = 'Login' >
	<cfif structKeyExists(url, 'for') and url.for eq 'MFL' >
		<cfset local.heading = 'MFL Login' >
	</cfif>
	<cfset local.location = '/' >
	<cfif structKeyExists(url,'isRanker') and url.isRanker eq 1 >
		<cfset local.location = '/ranker/' >
	</cfif>
	<cfif (not structKeyExists(url, 'for')) or url.for neq 'MFL' >
		<cfif structKeyExists(session,'userId') >
			<cflocation url="#local.location#" addtoken="false" >
		</cfif>
	</cfif>
	<cfif structKeyExists(form, 'loginBtn') >
		<cfset local.errorMsg = '' >
		<cfif not(structKeyExists(form, 'userName') and len(trim(form.userName))) >
			<cfset local.errorMsg = 'Username is required<br>' >
		</cfif>
		<cfif not(structKeyExists(form, 'password') and len(trim(form.password))) >
			<cfset local.errorMsg = 'Password is required' >
		</cfif>
		<cfif not len(local.errorMsg) >
			<cfset local.qLoginCheck = createObject('component','cfc.user').getUsrLgnDtls(email = trim(form.userName),password = form.password) >
			<cfif not local.qLoginCheck.recordCount >
				<cfset local.errorMsg = 'Invalid credentials' >
			<cfelse>
				<cfif local.qLoginCheck.isVerified eq 1 >
					<cfset session.userName = '#local.qLoginCheck.Firstname# #local.qLoginCheck.Lastname#' >
					<cfset session.userId = local.qLoginCheck.BIndex >
					<cfset local.location = '/' >
					<cfif structKeyExists(form, 'rediretLoc') and len(trim(form.rediretLoc)) >
						<cfset local.location = trim(form.rediretLoc) >
					<cfelseif structKeyExists(url,'isRanker') and url.isRanker eq 1 >
						<cfset local.location = '/ranker/' >
					</cfif>
					<cflocation url="#local.location#" addtoken="false" >
				<cfelse>
					<cfset local.errorMsg = 'You are not verified' >
				</cfif>
			</cfif>
		</cfif>
	</cfif>
		<cfoutput>
			<header>
				<nav class="nav-bar bg-white">
					<div class="container-fluid">
						<div class="navbar-header">
							<a class="navbar-brand" href="/">
								<img src="/assets/images/300x60_r.png">
							</a>
						</div>
					</div>
				</nav>
			</header>
			<section class="d-flex justify-content-center align-items-center login-content">
				<div class="container">
					<div class="row">
						<div class="col-md-12">
							<div class="form-container pt-5">
								<cfif structKeyExists(cgi, 'SCRIPT_NAME') and fileExists(expandPath('/include/loginContent#cgi.SCRIPT_NAME#')) >
									<cfinclude template="/include/loginContent#cgi.SCRIPT_NAME#" >
								</cfif>
								<cfif structKeyExists(local,"errorMsg") and len(local.errorMsg) >
									<div class="col-12 text-danger alert alert-danger">#local.errorMsg#</div>
								</cfif>
								<form method="post" action="" class="form-horizontal">
									<cfif structKeyExists(url, 'for') and url.for eq 'MFL' >
										<input type="text" name="UsernameT" style="width: 0;height: 0;border: none;padding: 0;margin: 0;">
										<input type="password" value="" style="width: 0;height: 0;border: none;padding: 0;margin: 0;">
									</cfif>
									<input type="hidden" name="rediretLoc" value="">
									<div class="row">
										<div class="col-12 form-group">
											<h3>#local.heading#</h3>
										</div>
									</div>
									<div class="form-row">
										<div class="col-12 form-group">
											<input type="text" data-val="true" class="form-control" name="userName" placeholder="Email">
										</div>
										<div class="col-12 form-group">
											<input type="password" data-val="true" class="form-control" name="password" placeholder="Password">
										</div>
										<div class="col-12 form-group ">
											<p class="text-right"><a class="text-secondary" href="/forgot-password/">Forgot Password</a></p>
										</div>
										<div class="col-12 form-group">
											<button type="submit" name="loginBtn" class="btn btn-default btn-warning col-12 text-white">LOG IN</button>
										</div>
										<div class="col-12 form-group ">
											<p class="text-right text-secondary">If you don't have an Account - <a class="font-weight-bold font-italic" href="<cfif structKeyExists(url, 'isRanker') >/ranker</cfif>/signup/">Create an Account</a></p>
										</div>
									</div>
								</form>
							</div>
						</div>
					</div>
				</div>
			</section>
			<cfinclude template="/include/footerCommon.cfm" >
		</cfoutput>
</body>
</html>