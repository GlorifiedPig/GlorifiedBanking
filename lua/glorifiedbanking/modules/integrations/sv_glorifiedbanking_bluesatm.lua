
function GlorifiedBanking.ImportSteamIDFromBluesATM( steamid, balance )
    if steamid == "BOT" then return end
    GlorifiedBanking.SQLQuery( "REPLACE INTO `gb_players`( `SteamID`, `Balance` ) VALUES ( '" .. steamid .. "', " .. balance .. " ) LIMIT 1 ", function()
        local ply = player.GetBySteamID( steamid )

        if ply and ply:IsPlayer() then
            ply.GlorifiedBanking.Balance = balance
            ply:SetNWInt( "GlorifiedBanking.Balance", balance )
        end
    end )
end

concommand.Add( "glorifiedbanking_importbluesdata", function( ply )
    if ply == NULL or ply:IsSuperAdmin() then
        if BATM then
            if BATM.Config.UseMySQL == false then
                if sql.TableExists( "batm_personal_accounts" ) then
                    local accountDataTbl = sql.Query( "SELECT * FROM `batm_personal_accounts`" )
                    for k, v in ipairs( accountDataTbl ) do
                        local steamid = util.SteamIDFrom64( v["steamid"] )
                        local balance = util.JSONToTable( v["accountinfo"] )["balance"]

                        GlorifiedBanking.ImportSteamIDFromBluesATM( steamid, balance )
                    end
                    print( "[GlorifiedBanking] SQLite data found, conversion success!" )
                else
                    print( "[GlorifiedBanking] No Blue's ATM data for SQLite found. Conversion failed." )
                end
            else
                -- uses mysql
            end
        else
            print( "[GlorifiedBanking] Blue's ATM not found on the server. Conversion failed." )
        end
    end
end )