concommand.Add( "atms_save", function( ply )
	if( ply:IsAdmin() ) then
		if not file.IsDir( "glorifiedbanking", "DATA" ) then
			local n = 0
			file.CreateDir( "glorifiedbanking", "DATA" )
			file.CreateDir( "glorifiedbanking/atms", "DATA" )
			for k, v in pairs( ents.FindByClass( "glorifiedbanking_atm" ) ) do
				n = n + 1
				
				local atmDataFile = "glorifiedbanking/atms/atm_" .. n .. ".txt"

				local data = {
					Position = v:GetLocalPos(),
					Angle = v:GetLocalAngles()
				}

				file.Write( atmDataFile, util.TableToJSON( data ) )
			end
			ply:PrintMessage( HUD_PRINTTALK, "File does not exist, creating one now." )
		else
			ply:PrintMessage( HUD_PRINTTALK, "Please use atms_reset before creating a new file!" )
		end
	else
		ply:PrintMessage( HUD_PRINTTALK, "You are not an administrator!" )
	end
end )

concommand.Add( "atms_reset", function( ply )
	if( ply:IsAdmin() ) then
		if file.Exists( "glorifiedbanking", "DATA" ) then
			for k, v in pairs( file.Find( "glorifiedbanking/atms/atm_*.txt", "DATA" ) ) do
				file.Delete( "glorifiedbanking/atms/" .. v )
			end
			file.Delete( "glorifiedbanking/atms" )
			file.Delete( "glorifiedbanking" )
			ply:PrintMessage( HUD_PRINTTALK, "Successfully deleted ATM data files. Please reset your server." )
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
	end

	for i = 1, id do
		local atmDataFile = "glorifiedbanking/atms/atm_" .. i .. ".txt"

		local pos
		local ang

		if file.Exists( atmDataFile, "DATA" ) then
			local atmData = util.JSONToTable( file.Read( atmDataFile, "DATA" ) )
			pos = atmData.Position
			ang = atmData.Angle
		else
			return
		end

		local ATMEnt = ents.Create( "glorifiedbanking_atm" )

		ATMEnt:SetPos( Vector( pos ) )
		ATMEnt:SetAngles( ang )
		ATMEnt:Spawn()
	end
end
hook.Add( "Initialize", "glorifiedbanking_InitATMs", SpawnATMs )