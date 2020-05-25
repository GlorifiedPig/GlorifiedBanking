
function GlorifiedBanking.ImportSteamIDFromBluesATM( steamid, balance )
    if steamid == "BOT" then return end
    GlorifiedBanking.SQL.Query( "REPLACE INTO `gb_players`( `SteamID`, `Balance` ) VALUES ( '" .. steamid .. "', '" .. balance .. "' )", function()
        local ply = player.GetBySteamID( steamid )

        if ply and ply:IsPlayer() then
            ply.GlorifiedBanking.Balance = balance
            ply:SetNW2Int( "GlorifiedBanking.Balance", balance )
        end
    end )
end

concommand.Add( "glorifiedbanking_importbluesdata", function( ply )
    if ply == NULL or ply:IsSuperAdmin() and BATM then
        if BATM.Config.UseMySQL == false then
            if sql.TableExists( "batm_personal_accounts" ) then
                local accountDataTbl = sql.Query( "SELECT * FROM `batm_personal_accounts`" )
                for k, v in ipairs( accountDataTbl ) do
                    local steamid = v["steamid"]
                    local balance = util.JSONToTable( v["accountinfo"] )["balance"]

                    GlorifiedBanking.ImportSteamIDFromBluesATM( steamid, balance )
                end
                print( "[GlorifiedBanking] SQLite data found, conversion success. Please uninstall Blue's ATM and restart your server." )
            else
                print( "[GlorifiedBanking] No Blue's ATM data for SQLite found. Conversion failed." )
            end
        else
            require( "mysqloo" )
            if not mysqloo then print( "[GlorifiedBanking] Failed to load MySQLOO for the Blue's ATM data importer, are you sure it is installed?" ) end
            local BATMDB = mysqloo.connect( BATM.Config.MySQLDetails.host,
                BATM.Config.MySQLDetails.username,
                BATM.Config.MySQLDetails.password,
                BATM.Config.MySQLDetails.databasename,
            tonumber( BATM.Config.MySQLDetails.port ) )

            function BATMDB:onConnected()
                local query = BATMDB:query( "SELECT * FROM `batm_personal_accounts`" )

                function query:onSuccess( queryData )
                    for k, v in ipairs( queryData ) do
                        local steamid = v["steamid"]
                        local balance = util.JSONToTable( v["accountinfo"] )["balance"]

                        GlorifiedBanking.ImportSteamIDFromBluesATM( steamid, balance )
                    end
                    print( "[GlorifiedBanking] MySQL data found, conversion success. Please uninstall Blue's ATM and restart your server." )
                end

                function query:onError()
                    print( "[GlorifiedBanking] Error in MySQL for Blue's ATM data importer. Conversion failed." )
                end

            query:start()
                query:wait()
            end
            BATM:connect()
            BATM:wait()
        end
    else
        print( "[GlorifiedBanking] Blue's ATM not found on the server. Conversion failed." )
    end
end )