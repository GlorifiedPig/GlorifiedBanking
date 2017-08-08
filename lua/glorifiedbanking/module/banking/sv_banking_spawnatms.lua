glorifiedbanking.config.TOTAL_ATMS = 0

concommand.Add( "atms_save", function( ply )
	if( ply:IsAdmin() ) then
		if not file.IsDir( "glorifiedbanking", "DATA" ) then
			file.CreateDir( "glorifiedbanking", "DATA" )
			file.CreateDir( "glorifiedbanking/atms", "DATA" )
			for k, v in pairs( ents.FindByClass( "glorifiedbanking_atm" ) ) do
				glorifiedbanking.config.TOTAL_ATMS = glorifiedbanking.config.TOTAL_ATMS + 1
				
				local atmDataFile = "glorifiedbanking/atms/atm_" .. glorifiedbanking.config.TOTAL_ATMS .. ".txt"

				local data = {
					Position = v:GetLocalPos(),
					Angle = v:GetLocalAngles(),
					Map = tostring( game.GetMap() )
				}

				file.Write( atmDataFile, util.TableToJSON( data ) )
			end
			ply:PrintMessage( HUD_PRINTTALK, "File does not exist for this map, creating new one for map '" .. tostring( game.GetMap() ) .. "'." )
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
				for k, v in pairs( ents.FindByClass( "glorifiedbanking_atm" ) ) do
					glorifiedbanking.config.TOTAL_ATMS = glorifiedbanking.config.TOTAL_ATMS + 1
					
					local atmDataFile = "glorifiedbanking/atms/atm_" .. glorifiedbanking.config.TOTAL_ATMS .. ".txt"

					local data = {
						Position = v:GetLocalPos(),
						Angle = v:GetLocalAngles(),
						Map = tostring( game.GetMap() )
					}

					file.Write( atmDataFile, util.TableToJSON( data ) )
				end
				ply:PrintMessage( HUD_PRINTTALK, "File does not exist for this map, creating new one for map '" .. tostring( game.GetMap() ) .. "'." )
			end
		end
	else
		ply:PrintMessage( HUD_PRINTTALK, "You are not an administrator!" )
	end
end )

concommand.Add( "atms_reset", function( ply )
	if( ply:IsAdmin() ) then
		if file.Exists( "glorifiedbanking", "DATA" ) then
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

				file.Delete( "glorifiedbanking/atms/" .. v )
				glorifiedbanking.config.TOTAL_ATMS = glorifiedbanking.config.TOTAL_ATMS - 1 
			end
			ply:PrintMessage( HUD_PRINTTALK, "Successfully deleted ATM data files for map '" .. game.GetMap() .. "'. Please reset your server." )
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