
hook.Add( "DatabaseInitialized", glorifiedMap.IDENTIFIER, function()
    MySQLite.query( [[
        CREATE TABLE IF NOT EXISTS glorifiedbanking_player_balance (
            player_id INTEGER NOT NULL PRIMARY KEY,
            balance INTEGER NOT NULL ]] .. glorifiedBanking.config.DEFAULT_BANK_BALANCE .. [[
        )
    ]] )
end )

function glorifiedBanking.storePlayerBalance( player, balance, callback )
    MySQLite.query( string.format(
        "UPDATE glorifiedbanking_player_balance SET balance = %i WHERE player_id = %i",
        balance,
        player:AccountID()
    ), callback )
end

function glorifiedBanking.retrievePlayerBalance( player, callback )
    MySQLite.queryValue( [[SELECT balance FROM glorifiedbanking_player_balance WHERE player_id = ]] .. player:AccountID(), function( balance )
        if balance then
            callback( balance )

            return
        end

        MySQLite.query( string.format( [[INSERT INTO glorifiedbanking_player_balance (player_id, balance) (%i, %i)]], player:AccountID(), glorifiedBanking.config.DEFAULT_BANK_BALANCE ), function()
            callback( glorifiedBanking.config.DEFAULT_BANK_BALANCE )
        end )
    end )
end
