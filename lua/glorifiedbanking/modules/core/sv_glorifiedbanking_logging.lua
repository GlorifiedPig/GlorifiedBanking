
GlorifiedBanking.SQL.Query( "CREATE TABLE IF NOT EXISTS `gb_logs` ( `Date` TIMESTAMP NOT NULL , `Type` VARCHAR(16) NOT NULL , `SteamID` VARCHAR(32) NOT NULL , `ReceiverSteamID` VARCHAR(32) DEFAULT(NULL) , `Amount` BIGINT(64) NOT NULL )" )

GlorifiedBanking.Logs = GlorifiedBanking.Logs or {}

GlorifiedBanking.SQL.Query( "SELECT * FROM `gb_logs`", function( queryResult ) GlorifiedBanking.Logs = queryResult end )

function GlorifiedBanking.LogWithdrawal( ply, withdrawAmount )
    GlorifiedBanking.SQL.Query( "INSERT INTO `gb_logs`( `Date`, `Type`, `SteamID`, `Amount` ) VALUES ( '" .. os.time() .. "', 'Withdrawal', '" .. ply:SteamID() .. "', " .. withdrawAmount .. " )" )
    table.insert( GlorifiedBanking.Logs, {
        ["Date"] = os.time(),
        ["Type"] = "Withdrawal",
        ["SteamID"] = ply:SteamID(),
        ["ReceiverSteamID"] = NULL,
        ["Amount"] = withdrawAmount
    } )
end

function GlorifiedBanking.LogDeposit( ply, depositAmount )
    GlorifiedBanking.SQL.Query( "INSERT INTO `gb_logs`( `Date`, `Type`, `SteamID`, `Amount` ) VALUES ( '" .. os.time() .. "', 'Deposit', '" .. ply:SteamID() .. "', " .. depositAmount .. " )" )
    table.insert( GlorifiedBanking.Logs, {
        ["Date"] = os.time(),
        ["Type"] = "Deposit",
        ["SteamID"] = ply:SteamID(),
        ["ReceiverSteamID"] = NULL,
        ["Amount"] = depositAmount
    } )
end

function GlorifiedBanking.LogTransfer( ply, receiver, transferAmount )
    GlorifiedBanking.SQL.Query( "INSERT INTO `gb_logs`( `Date`, `Type`, `SteamID`, `ReceiverSteamID`, `Amount` ) VALUES ( '" .. os.time() .. "', 'Transfer', '" .. ply:SteamID() .. "', '" .. receiver:SteamID() .. "', " .. transferAmount .. " )" )
    table.insert( GlorifiedBanking.Logs, {
        ["Date"] = os.time(),
        ["Type"] = "Transfer",
        ["SteamID"] = ply:SteamID(),
        ["ReceiverSteamID"] = receiver:SteamID(),
        ["Amount"] = transferAmount
    } )
end

util.AddNetworkString( "GlorifiedBanking.PlayerOpenedLogs" )
concommand.Add( "glorifiedbanking_logs", function( ply )
    if ply:IsSuperAdmin() or CAMI.PlayerHasAccess( "glorifiedbanking_openlogs" ) then
        GlorifiedBanking.SQL.Query( "SELECT * FROM `gb_logs` LIMIT 750", function( queryResult )
            net.Start( "GlorifiedBanking.PlayerOpenedLogs" )
            net.WriteLargeString( util.TableToJSON( queryResult ) )
            net.Send( ply )
        end )
    end
end )