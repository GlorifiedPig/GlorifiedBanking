
GlorifiedBanking.SQL.Query( "CREATE TABLE IF NOT EXISTS `gb_logs` ( `Date` INT(32) NOT NULL , `Type` VARCHAR(16) NOT NULL , `SteamID` VARCHAR(32) NOT NULL , `ReceiverSteamID` VARCHAR(32) , `Amount` BIGINT(64) NOT NULL )" )

GlorifiedBanking.Logs = GlorifiedBanking.Logs or {}

GlorifiedBanking.SQL.Query( "SELECT * FROM `gb_logs`", function( queryResult ) if queryResult then GlorifiedBanking.Logs = queryResult end end )

function GlorifiedBanking.LogWithdrawal( ply, withdrawAmount )
    GlorifiedBanking.SQL.Query( "INSERT INTO `gb_logs`( `Date`, `Type`, `SteamID`, `Amount` ) VALUES ( " .. os.time() .. ", 'Withdrawal', '" .. ply:SteamID64() .. "', " .. withdrawAmount .. " )" )
    table.insert( GlorifiedBanking.Logs, {
        ["Date"] = os.time(),
        ["Type"] = "Withdrawal",
        ["SteamID"] = ply:SteamID64(),
        ["Amount"] = withdrawAmount
    } )
end

function GlorifiedBanking.LogDeposit( ply, depositAmount )
    GlorifiedBanking.SQL.Query( "INSERT INTO `gb_logs`( `Date`, `Type`, `SteamID`, `Amount` ) VALUES ( " .. os.time() .. ", 'Deposit', '" .. ply:SteamID64() .. "', " .. depositAmount .. " )" )
    table.insert( GlorifiedBanking.Logs, {
        ["Date"] = os.time(),
        ["Type"] = "Deposit",
        ["SteamID"] = ply:SteamID64(),
        ["Amount"] = depositAmount
    } )
end

function GlorifiedBanking.LogTransfer( ply, receiver, transferAmount )
    GlorifiedBanking.SQL.Query( "INSERT INTO `gb_logs`( `Date`, `Type`, `SteamID`, `ReceiverSteamID`, `Amount` ) VALUES ( " .. os.time() .. ", 'Transfer', '" .. ply:SteamID64() .. "', '" .. receiver:SteamID64() .. "', " .. transferAmount .. " )" )
    table.insert( GlorifiedBanking.Logs, {
        ["Date"] = os.time(),
        ["Type"] = "Transfer",
        ["SteamID"] = ply:SteamID64(),
        ["ReceiverSteamID"] = receiver:SteamID64(),
        ["Amount"] = transferAmount
    } )
end

util.AddNetworkString( "GlorifiedBanking.PlayerOpenedLogs" )
concommand.Add( "glorifiedbanking_logs", function( ply )
    if ply:IsSuperAdmin() or CAMI.PlayerHasAccess( "glorifiedbanking_openlogs" ) then
        GlorifiedBanking.SQL.Query( "SELECT * FROM `gb_logs` LIMIT 750", function( queryResult )
            net.Start( "GlorifiedBanking.PlayerOpenedLogs" )
            net.WriteTableAsString( queryResult )
            net.Send( ply )
        end )
    end
end )