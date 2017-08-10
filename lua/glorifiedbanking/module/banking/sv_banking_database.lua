glorifiedbanking.config.TOTAL_ATMS = glorifiedbanking.config.TOTAL_ATMS or 0

local function CheckATMCount()
	local atmDataFile = "glorifiedbanking/data.txt"

	if file.Exists( atmDataFile, "DATA" ) then
		local atmData = util.JSONToTable( file.Read( atmDataFile, "DATA" ) )

		glorifiedbanking.config.TOTAL_ATMS = atmData.ATMCount
	else
		return
	end
end

local function SaveATMData( positive, amount )
	if not file.IsDir( "glorifiedbanking", "DATA" ) then
			file.CreateDir( "glorifiedbanking", "DATA" )
			local atmDataFile = "glorifiedbanking/data.txt"

			local data = {
				ATMCount = amount
			}

			file.Write( atmDataFile, util.TableToJSON( data ) )
		else
			local atmDataFile = "glorifiedbanking/data.txt"

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
				local atmDataFile = "glorifiedbanking/data.txt"

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
		if not file.IsDir( "glorifiedbanking", "DATA" ) then
			file.CreateDir( "glorifiedbanking", "DATA" )
			file.CreateDir( "glorifiedbanking/atms", "DATA" )
			CheckATMCount()
			for k, v in pairs( ents.FindByClass( "glorifiedbanking_atm" ) ) do
				glorifiedbanking.config.TOTAL_ATMS = glorifiedbanking.config.TOTAL_ATMS + 1
				amount = amount + 1
				
				local atmDataFile = "glorifiedbanking/atms/atm_" .. glorifiedbanking.config.TOTAL_ATMS .. ".txt"

				if file.Exists( atmDataFile, "DATA" ) then repeat
					glorifiedbanking.config.TOTAL_ATMS = glorifiedbanking.config.TOTAL_ATMS + 1
					atmDataFile = "glorifiedbanking/atms/atm_" .. glorifiedbanking.config.TOTAL_ATMS .. ".txt"
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

			for k, v in pairs( file.Find( "glorifiedbanking/atms/atm_*.txt", "DATA" ) ) do
				local atmDataFile = "glorifiedbanking/atms/" .. v

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
				for k, v in pairs( ents.FindByClass( "glorifiedbanking_atm" ) ) do
					glorifiedbanking.config.TOTAL_ATMS = glorifiedbanking.config.TOTAL_ATMS + 1
					amount = amount + 1
					
					local atmDataFile = "glorifiedbanking/atms/atm_" .. glorifiedbanking.config.TOTAL_ATMS .. ".txt"

					if file.Exists( atmDataFile, "DATA" ) then repeat
						glorifiedbanking.config.TOTAL_ATMS = glorifiedbanking.config.TOTAL_ATMS + 1
						atmDataFile = "glorifiedbanking/atms/atm_" .. glorifiedbanking.config.TOTAL_ATMS .. ".txt"
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
		if file.Exists( "glorifiedbanking", "DATA" ) then
			CheckATMCount()
			for k, v in pairs( file.Find( "glorifiedbanking/atms/atm_*.txt", "DATA" ) ) do
				local atmDataFile = "glorifiedbanking/atms/" .. v

				local map

				if file.Exists( atmDataFile, "DATA" ) then
					local atmData = util.JSONToTable( file.Read( atmDataFile, "DATA" ) )
					map = atmData.Map
				else
					continue
				end

				if map != game.GetMap() then continue end

				glorifiedbanking.config.TOTAL_ATMS = glorifiedbanking.config.TOTAL_ATMS - 1
				amount = amount + 1

				file.Delete( "glorifiedbanking/atms/" .. v )
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

	for k, v in pairs( file.Find( "glorifiedbanking/atms/atm_*.txt", "DATA" ) ) do
		id = id + 1

		local atmDataFile = "glorifiedbanking/atms/" .. v

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

		local ATMEnt = ents.Create( "glorifiedbanking_atm" )

		ATMEnt:SetPos( Vector( pos ) )
		ATMEnt:SetAngles( ang )
		ATMEnt:Spawn()
	end
end
hook.Add( "Initialize", "glorifiedbanking_InitATMs", SpawnATMs )