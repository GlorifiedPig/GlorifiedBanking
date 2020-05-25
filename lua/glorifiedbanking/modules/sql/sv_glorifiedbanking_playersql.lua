
GlorifiedBanking.SQL.Query( "CREATE TABLE IF NOT EXISTS `gb_players`( `SteamID` VARCHAR(32) NOT NULL, `Balance` BIGINT(64) NOT NULL, `LastName` VARCHAR(64) DEFAULT '' , PRIMARY KEY( `SteamID` ) )" )

local startingBalance = GlorifiedBanking.Config.STARTING_BALANCE
hook.Add( "PlayerInitialSpawn", "GlorifiedBanking.SQLPlayer.PlayerInitialSpawn", function( ply )
    if ply:IsBot() then return end
    if not ply.GlorifiedBanking then ply.GlorifiedBanking = {} end
    GlorifiedBanking.SQL.Query( "SELECT * FROM `gb_players` WHERE `SteamID` = '" .. ply:SteamID64() .. "' LIMIT 1", function( queryResult )
        if queryResult and table.IsEmpty( queryResult ) == false then
            ply.GlorifiedBanking.Balance = queryResult[1]["Balance"]
            ply:SetNW2Int( "GlorifiedBanking.Balance", queryResult[1]["Balance"] )
            GlorifiedBanking.SQL.Query( "UPDATE `gb_players` SET `LastName` = '" .. GlorifiedBanking.SQL.EscapeString( ply:Nick() ) .. "' WHERE `SteamID` = '" .. ply:SteamID64() .. "'" )
        else
            ply.GlorifiedBanking.Balance = startingBalance
            ply:SetNW2Int( "GlorifiedBanking.Balance", startingBalance )
            GlorifiedBanking.SQL.Query( "INSERT INTO `gb_players`( `SteamID`, `Balance`, `LastName` ) VALUES ( '" .. ply:SteamID64() .. "', '" .. startingBalance .. "', '" .. GlorifiedBanking.SQL.EscapeString( ply:Nick() ) .. "' )" ) -- {{ user_id | 25 }}
        end
    end )
end )

-- This command is intensive, don't spam it!
concommand.Add( "glorifiedbanking_sqlsidto64", function( ply )
    if ply == NULL or ply:IsSuperAdmin() then
        GlorifiedBanking.SQL.Query( "SELECT * FROM `gb_players` WHERE LEFT( `SteamID`, 5 ) = 'STEAM'", function( queryResult )
            local isSQLite = GlorifiedBanking.SQL.GetType() == "sqlite"
            if isSQLite == "sqlite" then sql.Begin() end
            for k, v in pairs( queryResult ) do
                local plySteamID = v["SteamID"]
                local plySteamID64 = util.SteamIDTo64( plySteamID )
                GlorifiedBanking.SQL.Query( "SELECT * FROM `gb_players` WHERE `SteamID` = '" .. plySteamID64 .. "'", function( queryResult2 )
                    if queryResult2 and table.IsEmpty( queryResult2 ) == false then
                        GlorifiedBanking.SQL.Query( "UPDATE `gb_players` SET `Balance` = '" .. v["Balance"] .. "' WHERE `SteamID` = '" .. plySteamID64 .. "'" )
                    else
                        GlorifiedBanking.SQL.Query( "UPDATE `gb_players` SET `SteamID` = '" .. plySteamID64 .. "' WHERE `SteamID` = '" .. plySteamID .. "'" )
                    end
                    GlorifiedBanking.SQL.Query( "DELETE FROM `gb_players` WHERE `SteamID` = '" .. plySteamID .. "'" )
                end )
            end
            GlorifiedBanking.SQL.Query( "DROP TABLE `gb_logs`" )
            if isSQLite == "sqlite" then sql.Commit() end
            print( "[GlorifiedBanking] Database structure converted. Please restart your server." )
        end )
    end
end )