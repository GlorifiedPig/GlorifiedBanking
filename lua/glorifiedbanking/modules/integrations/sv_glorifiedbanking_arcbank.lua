GlorifiedBanking.ARCBank = {}

concommand.Add("glorifiedbanking_importarcdata", function(ply)
	if IsValid(ply) and not ply:IsSuperAdmin() then
		ply:ChatPrint("You must be a SuperAdmin to run this command.")
		return false
	end

	local function notify(msg)
		if IsValid(ply) then
			ply:ChatPrint(msg)
			print("[GlorifiedBanking][Command] " .. msg)
		else
			print("[GlorifiedBanking] " .. msg)
		end
	end

	if not ARCBank then
		notify("ARCBank wasn't loaded.")
	end

	if ARCBank.MySQL.EnableMySQL then
		notify("Importing from MySQL")
		notify("This will lag the server, since we're going to use blocking DB calls.")
		GlorifiedBanking.ARCBank.ImportFromSQL(notify)
	end
end)

function GlorifiedBanking.ARCBank.ImportFromSQL(notify)
	require("mysqloo")
	if not mysqloo then notify("Failed to load MySQLOO for the ARCBank data importer, are you sure it is installed?") end

	local ARCDB = mysqloo.connect(
		ARCBank.MySQL.Host,
        ARCBank.MySQL.Username,
        ARCBank.MySQL.Password,
        ARCBank.MySQL.DatabaseName,
		tonumber(ARCBank.MySQL.DatabasePort)
	)
	ARCDB:connect()

	local accounts = {}
	local owners = {}
	local groups = {}
	local perPage = 2000

	local query = ARCDB:query("SELECT COUNT(*) as `count` FROM ((SELECT account FROM `arcbank_accounts`) UNION (SELECT account FROM `arcbank_accounts_unused`)) AS `sq`")
	query:start()
	query:wait()
	local count = query:getData()[1].count

	local pages = math.ceil(count / perPage)
	local last = 0
	notify(("Parsing %s pages"):format(pages))

	for page = 0, pages do
		local perc = math.ceil((page / pages) * 100)
		if (perc ~= last) and (perc ~= 100 or page == pages) then
			last = perc
			notify(("Fetching Accounts: %s%%"):format(perc))
		end

		local accQuery = ARCDB:query("(SELECT account, name, owner, rank, (rank >= " .. ARCBANK_GROUPACCOUNTS_ .. " AND rank <= " .. ARCBANK_GROUPACCOUNTS_PREMIUM .. ") as `group`, 0 as money FROM `arcbank_accounts`) UNION (SELECT account, name, owner, rank, (rank >= " .. ARCBANK_GROUPACCOUNTS_ .. " AND rank <= " .. ARCBANK_GROUPACCOUNTS_PREMIUM .. ") as `group`, money FROM `arcbank_accounts_unused`) LIMIT " .. perPage .. (page ~= 0 and (" OFFSET " .. (page * perPage)) or ""))
		accQuery:start()
		accQuery:wait()
		local data = accQuery:getData()
		for _, account in ipairs(data) do
			accounts[account.account] = account.money
			owners[account.account] = {[account.owner] = account.money}
			groups[account.account] = account.group
		end
	end

	notify("Accounts Loaded, fetching group members.")

	query = ARCDB:query("SELECT COUNT(*) as `count` FROM ((SELECT account FROM arcbank_groups) UNION (SELECT account FROM arcbank_groups_unused)) AS `sq`")
	query:start()
	query:wait()
	count = query:getData()[1].count
	pages = math.ceil(count / perPage)
	last = 0
	notify(("Parsing %s pages"):format(pages))

	for page = 0, pages do
		local perc = math.ceil((page / pages) * 100)
		if (perc ~= last) and (perc ~= 100 or page == pages) then
			last = perc
			notify(("Fetching Account Members: %s%%"):format(perc))
		end

		local accQuery = ARCDB:query("(SELECT account, user FROM `arcbank_groups`) UNION (SELECT account, user FROM `arcbank_groups_unused`) LIMIT " .. perPage .. (page ~= 0 and (" OFFSET " .. (page * perPage)) or ""))
		accQuery:start()
		accQuery:wait()
		local data = accQuery:getData()
		for _, group in ipairs(data) do
			if owners[group.account] == nil then
				notify(("WARNING! %s wasn't defined when searching group members!"):format(group.account))
			else
				owners[group.account][group.user] = 0
			end
		end
	end

	notify("Group Members Loaded, fetching log entries.")

	query = ARCDB:query("SELECT COUNT(*) as `count` FROM arcbank_log")
	query:start()
	query:wait()
	count = query:getData()[1].count
	pages = math.ceil(count / perPage)
	last = 0
	notify(("Parsing %s pages"):format(pages))

	for page = 0, pages do
		local perc = math.ceil((page / pages) * 100)
		if (perc ~= last) and (perc ~= 100 or page == pages) then
			last = perc
			notify(("Fetching Log: %s%%"):format(perc))
		end

		local logQuery = ARCDB:query("SELECT account1 as `account`, user1 as `user`, moneydiff as `diff` FROM arcbank_log ORDER BY transaction_id ASC LIMIT " .. perPage .. (page ~= 0 and (" OFFSET " .. (page * perPage)) or ""))
		logQuery:start()
		logQuery:wait()
		local data = logQuery:getData()
		for _, log in ipairs(data) do
			if accounts[log.account] ~= nil and owners[log.account] ~= nil then
				accounts[log.account] = (accounts[log.account] ~= nil and accounts[log.account] or 0) + log.diff

				if owners[log.account][log.user] ~= nil then
					owners[log.account][log.user] = owners[log.account][log.user] + log.diff
				end
			end
		end
	end

	-- We don't need to know overdrawn status.
	-- for accountId, amt in pairs(accounts) do
	-- 	if amt < 0 then
	-- 		notify(("%s is overdrawn (%s)"):format(accountId, amt))
	-- 	end
	-- end

	-- for accountid, data in pairs(owners) do
	-- 	for steamid, amt in pairs(data) do
	-- 		if amt < 0 then
	-- 			notify(("%s withdrew more than they deposited (%s)"):format(steamid, amt))
	-- 		end
	-- 	end
	-- end

	local newAccounts = {}
	for accountId, data in pairs(owners) do
		local account = {
			available = accounts[accountId] and accounts[accountId] or 0,
			owners = owners[accountId] and owners[accountId] or {BOT = 0},
			group = tobool(groups[accountId] ~= nil and groups[accountId] or table.Count(owners[accountId]) ~= 1)
		}

		if not account.group then
			local owner
			for own, _ in pairs(account.owners) do
				owner = own
				break
			end

			newAccounts[owner] = newAccounts[owner] or {}
			newAccounts[owner][accountId] = account.available
		else
			local allChanges = 0
			for owner, change in pairs(account.owners) do
				if change > 0 then
					allChanges = allChanges + change
				end
			end
			if allChanges ~= 0 and account.available > 0 then
				for owner, change in pairs(account.owners) do
					local perc = change / allChanges
					newAccounts[owner] = newAccounts[owner] or {}
					newAccounts[owner][accountId] = (account.available * perc)
				end
			end
		end
	end

	for steamid, playerAccounts in pairs(newAccounts) do
		local refund = 0
		for accountId, amount in pairs(playerAccounts) do
			refund = refund + amount
		end
		refund = math.floor(refund)

		if refund <= 0 then
			notify(("%s doesn't haved enough banked money for a new account (%s$)"):format(steamid, refund))
		elseif steamid ~= "BOT" then
			local sid = util.SteamIDTo64(steamid)
			sid = GlorifiedBanking.SQL.EscapeString(sid)
			GlorifiedBanking.SQL.Query("REPLACE INTO gb_players (`SteamID`, `Balance`) VALUES ('" .. sid .. "', " .. refund .. ")", function()
				local ply = player.GetBySteamID(steamid)
				if IsValid(ply) and ply:IsPlayer() then
		            ply.GlorifiedBanking.Balance = refund
            		ply:SetNW2Int("GlorifiedBanking.Balance", refund)
        		end
			end)
		end
	end
end
