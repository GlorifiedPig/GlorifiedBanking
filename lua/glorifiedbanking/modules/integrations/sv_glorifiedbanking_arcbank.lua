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
	local perPage = 600

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
			owners[account.account] = {total = account.money, [account.owner] = account.money}
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

	-- PrintTable(accounts)
	-- PrintTable(owners)
end
