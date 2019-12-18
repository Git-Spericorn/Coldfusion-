<cfcomponent displayname="espn" >

	<cffunction name="login" access="public" >
		<cfargument name="userName" required="true" >
		<cfargument name="password" required="true" >
		<cfargument name="userId" required="true" >

		<cfset local.returnVal = structNew() >
		<cfset local.returnVal.status = 0 >
		<cftry>
			<cfset local.conversationId = '83f00be8-ec99-499b-a37a-a68e86eb7f28' >
			<cfhttp url="https://registerdisney.go.com/jgc/v6/client/ESPN-ONESITE.WEB-PROD/api-key?langPref=en-US" method="options" >
				<cfhttpparam type="header" name="Access-Control-Request-Method" value="POST" >
				<cfhttpparam type="header" name="Access-Control-Request-Headers" value="cache-control,content-type,conversation-id,correlation-id,expires,pragma" >
				<cfhttpparam type="header" name="Origin" value="https://cdn.registerdisney.go.com" >
			</cfhttp>
			<cfset local.correlationId = cfhttp.Responseheader['correlation-id'] >
			<cfhttp url="https://registerdisney.go.com/jgc/v6/client/ESPN-ONESITE.WEB-PROD/api-key?langPref=en-US" method="POST" >
				<cfhttpparam type="header" name="Referer" value="https://cdn.registerdisney.go.com/v2/ESPN-ONESITE.WEB-PROD/en-US?include=config,l10n,js,html&scheme=http&postMessageOrigin=http%3A%2F%2Fwww.espn.com%2Flogin%2F&cookieDomain=www.espn.com&config=PROD&logLevel=LOG&topHost=www.espn.com&cssOverride=https%3A%2F%2Fsecure.espncdn.com%2Fcombiner%2Fc%3Fcss%3Ddisneyid%2Fcore.css&responderPage=https%3A%2F%2Fwww.espn.com%2Flogin%2Fresponder%2F&buildId=16388ed5943" >
				<cfhttpparam type="header" name="Content-Type" value="" >
				<cfhttpparam type="header" name="" value="application/json" >
				<cfhttpparam type="header" name="conversation-id" value="#local.conversationId#" >
				<cfhttpparam type="header" name="correlation-id" value="#local.correlationId#" >
			</cfhttp>
			<cfset local.apiKey =  cfhttp.Responseheader['api-key'] >
			<cfhttp url="https://ha.registerdisney.go.com/jgc/v6/client/ESPN-ONESITE.WEB-PROD/guest/login?langPref=en-US HTTP/1.1" method="options" >
				<cfhttpparam type="header" name="Access-Control-Request-Method" value="POST" >
				<cfhttpparam type="header" name="Access-Control-Request-Headers" value="authorization,cache-control,content-type,conversation-id,correlation-id,expires,pragma" >
				<cfhttpparam type="header" name="Origin" value="https://cdn.registerdisney.go.com" >
			</cfhttp>
			<cfhttp url="https://ha.registerdisney.go.com/jgc/v6/client/ESPN-ONESITE.WEB-PROD/guest/login?langPref=en-US" method="POST" >
				<cfhttpparam type="header" name="Referer" value="https://cdn.registerdisney.go.com/v2/ESPN-ONESITE.WEB-PROD/en-US?include=config,l10n,js,html&scheme=http&postMessageOrigin=http%3A%2F%2Fwww.espn.com%2Flogin%2F&cookieDomain=www.espn.com&config=PROD&logLevel=LOG&topHost=www.espn.com&cssOverride=https%3A%2F%2Fsecure.espncdn.com%2Fcombiner%2Fc%3Fcss%3Ddisneyid%2Fcore.css&responderPage=https%3A%2F%2Fwww.espn.com%2Flogin%2Fresponder%2F&buildId=16388ed5943" >
				<cfhttpparam type="header" name="Content-Type" value="application/json" >
				<cfhttpparam type="header" name="Authorization" value="APIKEY #local.apiKey#" >
				<cfhttpparam type="header" name="correlation-id" value="#local.correlationId#" >
				<cfhttpparam type="header" name="conversation-id" value="#local.conversationId#" >
				<cfhttpparam type="header" name="Origin" value="https://cdn.registerdisney.go.com" >
				<cfhttpparam type="body" name="body" value='{"loginValue":"#arguments.userName#","password":"#arguments.password#"}' >
			</cfhttp>
			<cfset local.loginDetails = deserializeJSON(cfhttp.fileContent) >
			<cfif structKeyExists(local.loginDetails, 'data') >
				<cfset local.returnVal.status = 1 >
				<cfquery name="local.qCheckAccount" datasource="commish" >
					select * from espnCreds
					where swid = <cfqueryparam value="#local.loginDetails.data.profile.swid#" cfsqltype="cf_sql_varchar" >
				</cfquery>
				<cfif local.qCheckAccount.recordCount >
					<cfif local.qCheckAccount.userId eq arguments.userId >
						<cfquery name="local.qUpdate" datasource="commish" >
							update espnCreds
							set userName = <cfqueryparam value="#arguments.userName#" cfsqltype="cf_sql_nvarchar" >
							,espnName = <cfqueryparam value="#local.loginDetails.data.displayName.displayName#" cfsqltype="cf_sql_nvarchar" >
							,espnS2 = <cfqueryparam value="#urlDecode(local.loginDetails.data.s2)#" cfsqltype="cf_sql_nvarchar" >
							where swid = <cfqueryparam value="#local.loginDetails.data.profile.swid#" cfsqltype="cf_sql_varchar" >
						</cfquery>
					<cfelse>
						<cfset local.returnVal.status = 0 >
						<cfset local.returnVal.errorMsg = 'Account already exists with another user' >
					</cfif>
					<cfset local.returnVal.id = local.qCheckAccount.espnId >
				<cfelse>
					<cfquery result="local.qInsert" datasource="commish" >
						insert into espnCreds(userId,name,espnName,swid,espnS2)
						values(
							<cfqueryparam value="#arguments.userId#" cfsqltype="cf_sql_integer" >,
							<cfqueryparam value="#arguments.userName#" cfsqltype="cf_sql_nvarchar" >,
							<cfqueryparam value="#local.loginDetails.data.displayName.displayName#" cfsqltype="cf_sql_nvarchar" >,
							<cfqueryparam value="#local.loginDetails.data.profile.swid#" cfsqltype="cf_sql_varchar" >,
							<cfqueryparam value="#urlDecode(local.loginDetails.data.s2)#" cfsqltype="cf_sql_nvarchar" >
						)
					</cfquery>
					<cfset local.returnVal.id = local.qInsert.generatedKey >
				</cfif>
			<cfelse>
				<cfset local.returnVal.errorMsg = 'Invalid credentials' >
			</cfif>
		<cfcatch>
			<cfset local.returnVal.errorMsg = 'Connection Error' >
		</cfcatch>
		</cftry>
		<cfreturn local.returnVal >
	</cffunction>

	<cffunction name="getLeagueData" access="public" >
		<cfargument name="id" required="true" type="numeric" >
		<cfargument name="userId" required="true" type="numeric" >

		<cfset local.accountDetails = getESPNAccounts(espnId = arguments.id,userId = arguments.userId) >

		<cfhttp url="http://fan.api.espn.com/apis/v2/fans/#local.accountDetails.swid#?displayEvents=true&displayNow=true&displayRecs=true&displayHiddenPrefs=true&recLimit=5" >
			<cfhttpparam type="cookie" name="espn_s2" value="#local.accountDetails.espnS2#" >
			<cfhttpparam type="cookie" name="SWID" value="#local.accountDetails.swid#" >
		</cfhttp>

		<cfset local.userData = deserializeJSON(cfhttp.fileContent) >
		<cfquery name="local.qGetUserLeagues" datasource="commish" >
			select ContestID,Registeredby,Registered from contests
			where Registered like <cfqueryparam value="%#arguments.userId#%" cfsqltype="cf_sql_varchar" >
			and ContestType = <cfqueryparam value="5" cfsqltype="cf_sql_integer" >
		</cfquery>
		<cfset local.leagueQuery = queryNew('leagueId,name,url,season,gameId,status,regValue','VarChar,VarChar,VarChar,Integer,Integer,Bit,VarChar') >
		<cfloop array="#local.userData.preferences#" index="local.index" >
			<cfif isDefined('local.index.metaData.entry.groups') >
				<cfset queryAddRow(local.leagueQuery) >
				<cfset querySetCell(local.leagueQuery,'leagueId',local.index.metaData.entry.groups[1].groupId) >
				<cfset querySetCell(local.leagueQuery,'name',local.index.metaData.entry.groups[1].groupName) >
				<cfset querySetCell(local.leagueQuery,'url',local.index.metaData.entry.groups[1].href) >
				<cfset querySetCell(local.leagueQuery,'season',local.index.metaData.entry.seasonId) >
				<cfset querySetCell(local.leagueQuery,'gameId',local.index.metaData.entry.gameId) >
				<cfset querySetCell(local.leagueQuery,'regValue','#local.index.metaData.entry.groups[1].groupId#_#local.index.metaData.entry.gameId#_#local.index.metaData.entry.seasonId#') >
				<cfset local.status = 0 >
				<cfquery name="local.qLeagueChk" dbtype="query" >
					select * from qGetUserLeagues
					where ContestID = #local.index.metaData.entry.groups[1].groupId#
				</cfquery>
				<cfif local.qLeagueChk.recordCount and listFindNoCase(local.qLeagueChk.Registered,arguments.userId) >
					<cfset local.status = 1 >
				</cfif>
				<cfset querySetCell(local.leagueQuery,'status',local.status) >
			</cfif>
		</cfloop>
		<cfreturn {'status':1,'data':local.leagueQuery} >

	</cffunction>

	<cffunction name="getESPNAccounts" access="public" >
		<cfargument name="espnId" required="false" type="numeric" >
		<cfargument name="userId" required="false" type="numeric" >

		<cfquery name="local.qGetAccountDtls" datasource="commish" >
			select * from tblESPNlogin
			where 1 = 1
			<cfif structKeyExists(arguments, 'espnId') >
				and espnId = <cfqueryparam value="#arguments.espnId#" cfsqltype="cf_sql_integer" >
			</cfif>
			<cfif structKeyExists(arguments, 'userId') >
				and userId = <cfqueryparam value="#arguments.userId#" cfsqltype="cf_sql_integer" >
			</cfif>
		</cfquery>
		<cfreturn local.qGetAccountDtls >
	</cffunction>

	<cffunction name="registerLeague" access="public" >
		<cfargument name="data" required="true" type="string" >
		<cfargument name="id" required="true" type="numeric" >
		<cfargument name="userId" required="true" type="numeric" >

		<cfset local.returnVal = structNew() >
		<cfset local.returnVal.status = 0 >
		<cfset local.gameLinks = {1:'ffl',2:'flb'} >
		<cfset local.data = structNew() >
		<cftry>
			<cfset local.lgeArr = listToArray(arguments.data,'_') >
			<cfif arrayLen(local.lgeArr) eq 3 >
				<cfset local.data.leagueId = local.lgeArr[1] >
				<cfset local.data.gameId = local.lgeArr[2] >
				<cfset local.data.year = local.lgeArr[3] >
			</cfif>
			<cfset local.accountDetails = getESPNAccounts(espnId = arguments.id,userId = arguments.userId) >
			<cfquery name="local.qContestCheck" datasource="commish" >
				select * from tblContests
				where ContestID = <cfqueryparam value="#local.data.leagueID#" cfsqltype="cf_sql_varchar" >
				and ContestType = <cfqueryparam value="5" cfsqltype="cf_sql_integer" >
			</cfquery>
			<cfif local.qContestCheck.recordCount >
				<cfset local.registered = local.qContestCheck.Registered >
				<cfif not listFindNoCase(local.registered, arguments.userId) >
					<cfset local.registered = listAppend(local.registered, arguments.userId) >
				</cfif>
				<cfquery name="qUpdateContest" datasource="commish" >
					UPDATE tblContests
					SET Registered = <cfqueryparam value="#local.registered#" cfsqltype="cf_sql_varchar" >
					WHERE CIndex = <cfqueryparam value="#local.qContestCheck.CIndex#" cfsqltype="cf_sql_integer" >
				</cfquery>
				<cfset local.returnVal.status = 1 >
				<cfset local.returnVal.leagueName = local.qContestCheck.Contestname >
				<cfset local.returnVal.season = local.qContestCheck.ContestYear >
				<cfset local.contestIndex = local.qContestCheck.CIndex >
				<cfset local.startWeek = local.qContestCheck.startWeek >
				<cfset local.endWeek = local.qContestCheck.endWeek >
				<cfset local.season = local.qContestCheck.contestyear >
			<cfelse>
				<cfhttp url="http://fantasy.espn.com/apis/v3/games/#local.gameLinks[local.data.gameId]#/seasons/#local.data.year#/segments/0/leagues/#local.data.leagueId#?view=mMatchupScore&view=mScore	board&view=mStatus&view=mSettings&view=mTeam&view=mPendingTransactions&view=modular&view=mNav" >
					<cfhttpparam type="cookie" name="espn_s2" value="#local.accountDetails.espnS2#" >
					<cfhttpparam type="cookie" name="SWID" value="#local.accountDetails.swid#" >
				</cfhttp>
				<cfif isDefined('cfhttp.Responseheader.Status_Code') and cfhttp.Responseheader.Status_Code neq 200 >
					<cfset refreshAccessCookie(espnId = arguments.id) >
					<cfreturn registerLeague(data = local.data,espnId = arguments.id,userId = arguments.userId) >
				</cfif>
				<cfset local.fileContent = deserializeJSON(cfhttp.fileContent) >

				<cfhttp url="http://fan.api.espn.com/apis/v2/fans/#local.accountDetails.swid#?displayEvents=true&displayNow=true&displayRecs=true&displayHiddenPrefs=true&recLimit=5" >
					<cfhttpparam type="cookie" name="espn_s2" value="#local.accountDetails.espnS2#" >
					<cfhttpparam type="cookie" name="SWID" value="#local.accountDetails.swid#" >
				</cfhttp>
				<cfset local.userData = deserializeJSON(cfhttp.fileContent) >

				<cfset local.returnVal.leagueName = local.fileContent.settings.name >
				<cfset local.returnVal.season = local.fileContent.seasonId >
				<cfset local.status = 0 >
				<cfif structKeyExists(local.fileContent, 'id') >
					<cfset local.status = 1 >
				<cfelse>
					<cfif isDefined('local.fileContent.details[1].message') >
						<cfset local.returnVal.errorMsg = local.fileContent.details[1].message >
					</cfif>
				</cfif>
				<cfif local.status >
					<cfset local.rosterSize = 0 >
					<cfif isDefined('local.fileContent.settings.rosterSettings.lineupSlotCounts') >
						<cfloop collection="#local.fileContent.settings.rosterSettings.lineupSlotCounts#" item="local.item" >
							<cfset local.rosterSize = local.rosterSize + local.fileContent.settings.rosterSettings.lineupSlotCounts[local.item] >
						</cfloop>
					</cfif>					
				</cfif>
				<cfset local.returnVal.status = 1 >
			</cfif>
		<cfcatch>
			<cfset local.returnVal.errorMsg = 'Connection Error' >
		</cfcatch>
		</cftry>
		<cfreturn local.returnVal >
	</cffunction>

	<cffunction name="refreshAccessCookie" access="private" >
		<cfargument name="espnId" required="true" type="numeric" >

		<cfset local.accountDetails = getESPNAccounts(espnId = arguments.espnId) >
		<cfset local.qLogin = login(userName = local.accountDetails.userName,password = local.accountDetails.password) >
	</cffunction>

</cfcomponent>