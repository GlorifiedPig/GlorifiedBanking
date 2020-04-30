
GlorifiedBanking.SQLQuery( "CREATE TABLE IF NOT EXISTS `gb_players`( `SteamID` VARCHAR(32) NOT NULL, `Balance` BIGINT(64) NOT NULL, PRIMARY KEY( `SteamID` ) )" )

local startingBalance = GlorifiedBanking.Config.STARTING_BALANCE
hook.Add( "PlayerInitialSpawn", "GlorifiedBanking.SQLPlayer.PlayerInitialSpawn", function( ply )
    if not ply.GlorifiedBanking then ply.GlorifiedBanking = {} end
    GlorifiedBanking.SQLQuery( "SELECT * FROM `gb_players` WHERE `SteamID` = '" .. ply:SteamID() .. "' LIMIT 1", function( queryResult )
        if queryResult and table.IsEmpty( queryResult ) == false then
            ply.GlorifiedBanking.Balance = queryResult[1]["Balance"]
        else
            GlorifiedBanking.SQLQuery( "INSERT INTO `gb_players`( `SteamID`, `Balance` ) VALUES ( '" .. ply:SteamID() .. "', " .. startingBalance .. " )" )
            ply.GlorifiedBanking.Balance = startingBalance
        end
    end )
end )