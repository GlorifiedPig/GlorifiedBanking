glorifiedBanking.config.TOTAL_ATMS = glorifiedBanking.config.TOTAL_ATMS or 0

local function CheckATMCount()
	local atmDataFile = "glorifiedBanking/data.txt"

	if file.Exists( atmDataFile, "DATA" ) then
		local atmData = util.JSONToTable( file.Read( atmDataFile, "DATA" ) )

		glorifiedBanking.config.TOTAL_ATMS = atmData.ATMCount
	else
		return
	end
end

local function SaveATMData( positive, amount )
	if not file.IsDir( "glorifiedBanking", "DATA" ) then
			file.CreateDir( "glorifiedBanking", "DATA" )
			local atmDataFile = "glorifiedBanking/data.txt"

			local data = {
				ATMCount = amount
			}

			file.Write( atmDataFile, util.TableToJSON( data ) )
		else
			local atmDataFile = "glorifiedBanking/data.txt"

			if file.Exists( atmDataFile, "DATA" ) then
				local atmData = util.JSONToTable( file.Read( atmDataFile, "DATA" ) )
				local TempATMCount = atmData.ATMCount

				local data = {}

				if positive then
					data = {
						ATMCount = TempATMCount + amount
					}
				else
					data = {
						ATMCount = TempATMCount - amount
					}
				end

				file.Write( atmDataFile, util.TableToJSON( data ) )
			else
				local atmDataFile = "glorifiedBanking/data.txt"

				local data = {
					ATMCount = amount
				}

				file.Write( atmDataFile, util.TableToJSON( data ) )
			end
		end

		CheckATMCount()
end

concommand.Add( "atms_save", function( ply )
	local amount = 0
	if( ply:IsAdmin() ) then
		if not file.IsDir( "glorifiedBanking", "DATA" ) then
			file.CreateDir( "glorifiedBanking", "DATA" )
			file.CreateDir( "glorifiedBanking/atms", "DATA" )
			CheckATMCount()
			for k, v in pairs( ents.FindByClass( "glorifiedBanking_atm" ) ) do
				glorifiedBanking.config.TOTAL_ATMS = glorifiedBanking.config.TOTAL_ATMS + 1
				amount = amount + 1

				local atmDataFile = "glorifiedBanking/atms/atm_" .. glorifiedBanking.config.TOTAL_ATMS .. ".txt"

				if file.Exists( atmDataFile, "DATA" ) then repeat
					glorifiedBanking.config.TOTAL_ATMS = glorifiedBanking.config.TOTAL_ATMS + 1
					atmDataFile = "glorifiedBanking/atms/atm_" .. glorifiedBanking.config.TOTAL_ATMS .. ".txt"
				until
					file.Exists( atmDataFile, "DATA" ) == false
				end

				local data = {
					Position = v:GetLocalPos(),
					Angle = v:GetLocalAngles(),
					Map = tostring( game.GetMap() )
				}

				file.Write( atmDataFile, util.TableToJSON( data ) )
			end
			ply:PrintMessage( HUD_PRINTTALK, "File does not exist for this map, creating new one for map '" .. tostring( game.GetMap() ) .. "'." )
			SaveATMData( true, amount )
		else
			local validMap = true

			for k, v in pairs( file.Find( "glorifiedBanking/atms/atm_*.txt", "DATA" ) ) do
				local atmDataFile = "glorifiedBanking/atms/" .. v

				local map
				if file.Exists( atmDataFile, "DATA" ) then
					local atmData = util.JSONToTable( file.Read( atmDataFile, "DATA" ) )
					map = atmData.Map
				else
					return
				end

				if map == game.GetMap() then
					ply:PrintMessage( HUD_PRINTTALK, "Please use atms_reset before creating a new file!" )
					validMap = false
					return
				end
			end

			if validMap then
				CheckATMCount()
				for k, v in pairs( ents.FindByClass( "glorifiedBanking_atm" ) ) do
					glorifiedBanking.config.TOTAL_ATMS = glorifiedBanking.config.TOTAL_ATMS + 1
					amount = amount + 1

					local atmDataFile = "glorifiedBanking/atms/atm_" .. glorifiedBanking.config.TOTAL_ATMS .. ".txt"

					if file.Exists( atmDataFile, "DATA" ) then repeat
						glorifiedBanking.config.TOTAL_ATMS = glorifiedBanking.config.TOTAL_ATMS + 1
						atmDataFile = "glorifiedBanking/atms/atm_" .. glorifiedBanking.config.TOTAL_ATMS .. ".txt"
					until
						file.Exists( atmDataFile, "DATA" ) == false
					end

					local data = {
						Position = v:GetLocalPos(),
						Angle = v:GetLocalAngles(),
						Map = tostring( game.GetMap() )
					}

					file.Write( atmDataFile, util.TableToJSON( data ) )
				end
				ply:PrintMessage( HUD_PRINTTALK, "File does not exist for this map, creating new one for map '" .. tostring( game.GetMap() ) .. "'." )
				SaveATMData( true, amount )
			end
		end
	else
		ply:PrintMessage( HUD_PRINTTALK, "You are not an administrator!" )
	end
end )

concommand.Add( "atms_reset", function( ply )
	local amount = 0
	if( ply:IsAdmin() ) then
		if file.Exists( "glorifiedBanking", "DATA" ) then
			CheckATMCount()
			for k, v in pairs( file.Find( "glorifiedBanking/atms/atm_*.txt", "DATA" ) ) do
				local atmDataFile = "glorifiedBanking/atms/" .. v

				local map

				if file.Exists( atmDataFile, "DATA" ) then
					local atmData = util.JSONToTable( file.Read( atmDataFile, "DATA" ) )
					map = atmData.Map
				else
					continue
				end

				if map != game.GetMap() then continue end

				glorifiedBanking.config.TOTAL_ATMS = glorifiedBanking.config.TOTAL_ATMS - 1
				amount = amount + 1

				file.Delete( "glorifiedBanking/atms/" .. v )
			end
			ply:PrintMessage( HUD_PRINTTALK, "Successfully deleted ATM data files for map '" .. game.GetMap() .. "'. Please reset your server." )
			SaveATMData( false, amount )
		else
			ply:PrintMessage( HUD_PRINTTALK, "ATM file does not exist." )
		end
	else
		ply:PrintMessage( HUD_PRINTTALK, "You are not an administrator!" )
	end
end )

local function SpawnATMs()
	local id = 0

	for k, v in pairs( file.Find( "glorifiedBanking/atms/atm_*.txt", "DATA" ) ) do
		id = id + 1

		local atmDataFile = "glorifiedBanking/atms/" .. v

		local pos
		local ang
		local map

		if file.Exists( atmDataFile, "DATA" ) then
			local atmData = util.JSONToTable( file.Read( atmDataFile, "DATA" ) )
			pos = atmData.Position
			ang = atmData.Angle
			map = atmData.Map
		else
			return
		end

		if map != game.GetMap() then continue end

		local ATMEnt = ents.Create( "glorifiedBanking_atm" )

		ATMEnt:SetPos( Vector( pos ) )
		ATMEnt:SetAngles( ang )
		ATMEnt:Spawn()
	end
end
hook.Add( "Initialize", "glorifiedBanking_InitATMs", SpawnATMs )
