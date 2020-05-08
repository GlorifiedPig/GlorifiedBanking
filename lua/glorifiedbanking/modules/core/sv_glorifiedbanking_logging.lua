
GlorifiedBanking.SQLQuery( "CREATE TABLE IF NOT EXISTS `gb_withdrawals` ( `Date` TIMESTAMP NOT NULL , `SteamID` VARCHAR(32) NOT NULL , `WithdrawAmount` BIGINT(64) NOT NULL )" )
GlorifiedBanking.SQLQuery( "CREATE TABLE IF NOT EXISTS `gb_deposits` ( `Date` TIMESTAMP NOT NULL , `SteamID` VARCHAR(32) NOT NULL , `DepositAmount` BIGINT(64) NOT NULL )" )
GlorifiedBanking.SQLQuery( "CREATE TABLE IF NOT EXISTS `gb_transfers` ( `Date` TIMESTAMP NOT NULL , `SteamID` VARCHAR(32) NOT NULL , `ReceiverSteamID` VARCHAR(32) NOT NULL , `TransferAmount` BIGINT(64) NOT NULL )" )

GlorifiedBanking.Logs = GlorifiedBanking.Logs or {
    Withdrawals = {},
    Deposits = {},
    Transfers = {}
}

GlorifiedBanking.SQLQuery( "SELECT * FROM `gb_withdrawals`", function( queryResult ) GlorifiedBanking.Logs.Withdrawals = queryResult end )
GlorifiedBanking.SQLQuery( "SELECT * FROM `gb_deposits`", function( queryResult ) GlorifiedBanking.Logs.Deposits = queryResult end )
GlorifiedBanking.SQLQuery( "SELECT * FROM `gb_transfers`", function( queryResult ) GlorifiedBanking.Logs.Transfers = queryResult end )

function GlorifiedBanking.LogWithdrawal( ply, withdrawAmount )
    GlorifiedBanking.SQLQuery( "INSERT INTO `gb_withdrawals`( `Date`, `SteamID`, `WithdrawAmount` ) VALUES ( '" .. os.time() .. "', '" .. ply:SteamID() .. "', " .. withdrawAmount .. " )" )
    table.insert( GlorifiedBanking.Logs.Withdrawals, {
        ["Date"] = os.time(),
        ["SteamID"] = ply:SteamID(),
        ["WithdrawAmount"] = withdrawAmount
    } )
end

function GlorifiedBanking.LogDeposit( ply, depositAmount )
    GlorifiedBanking.SQLQuery( "INSERT INTO `gb_deposits`( `Date`, `SteamID`, `DepositAmount` ) VALUES ( '" .. os.time() .. "', '" .. ply:SteamID() .. "', " .. depositAmount .. " )" )
    table.insert( GlorifiedBanking.Logs.Deposits, {
        ["Date"] = os.time(),
        ["SteamID"] = ply:SteamID(),
        ["DepositAmount"] = depositAmount
    } )
end

function GlorifiedBanking.LogTransfer( ply, receiver, transferAmount )
    GlorifiedBanking.SQLQuery( "INSERT INTO `gb_deposits`( `Date`, `SteamID`, `ReceiverSteamID`, `TransferAmount` ) VALUES ( '" .. os.time() .. "', '" .. ply:SteamID() .. "', '" .. receiver:SteamID() .. "', " .. transferAmount .. " )" )
    table.insert( GlorifiedBanking.Logs.Transfers, {
        ["Date"] = os.time(),
        ["SteamID"] = ply:SteamID(),
        ["ReceiverSteamID"] = receiver:SteamID(),
        ["TransferAmount"] = transferAmount
    } )
end

util.AddNetworkString( "GlorifiedBanking.PlayerOpenedLogs" )
concommand.Add( "glorifiedbanking_logs", function( ply )
    if ply:IsSuperAdmin() or CAMI.PlayerHasAccess( "glorifiedbanking_openlogs" ) then
        -- To the person reading this code: this is going to be changed to work with a colossal table probably when I figure out how to network it more efficiently
        GlorifiedBanking.SQLQuery( "SELECT * FROM `gb_withdrawals` WHERE ( `Date` > DATE_SUB( now(), INTERVAL 1 WEEK ) )", function( withdrawalQuery )
            GlorifiedBanking.SQLQuery( "SELECT * FROM `gb_deposits` WHERE ( `Date` > DATE_SUB( now(), INTERVAL 1 WEEK ) )", function( depositQuery )
                GlorifiedBanking.SQLQuery( "SELECT * FROM `gb_transfers` WHERE ( `Date` > DATE_SUB( now(), INTERVAL 1 WEEK ) )", function( transferQuery )
                    net.Start( "GlorifiedBanking.PlayerOpenedLogs" )
                    net.WriteLargeString( util.TableToJSON( depositQuery ) )
                    net.WriteLargeString( util.TableToJSON( withdrawalQuery ) )
                    net.WriteLargeString( util.TableToJSON( transferQuery ) )
                    net.Send( ply )
                end )
            end )
        end )
    end
end )