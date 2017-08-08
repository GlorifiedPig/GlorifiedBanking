
glorifiedbanking = glorifiedbanking or {
    config = {},

    IDENTIFIER = "glorifiedbanking",
    NICE_NAME = "GlorifiedBanking"
}

local function findInFolder( currentFolder, ignoreFolder )
    local files, folders = file.Find( currentFolder .. "*", "LUA" )

    if not ignoreFolder then
    	for _, File in ipairs( files ) do
    		if File:find( "sh_" ) then
    			if SERVER then AddCSLuaFile( currentFolder .. File ) end
    			include( currentFolder .. File )
    		end
    	end

        for _, File in pairs( files ) do
    		if SERVER and File:find( "sv_" ) then
    			include( currentFolder .. File )
    		elseif File:find( "cl_" ) then
    			if SERVER then AddCSLuaFile( currentFolder .. File )
    			else include( currentFolder .. File ) end
    		end
    	end
    end

    for _, folder in ipairs( folders ) do
    	findInFolder( currentFolder .. folder .. "/" )
    end
end

findInFolder( "glorifiedbanking/" )