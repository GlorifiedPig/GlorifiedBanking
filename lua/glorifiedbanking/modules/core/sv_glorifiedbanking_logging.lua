
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

local function chunkstring( str, number )
    local output = {}
    local strsize = string.len( str )
    local chunksTaken = 0
    local chunksToTake = math.ceil( strsize / number )
    for i = 1, chunksToTake do
        if chunksTaken == chunksToTake - 1 then
            table.insert( output, string.sub( str, chunksTaken * number ) )
        else
            table.insert( output, string.sub( str, chunksTaken * number, i * number ) )
        end
        chunksTaken = chunksTaken + 1
    end
    return output
end

util.AddNetworkString( "GlorifiedBanking.PlayerOpenedLogs" )
concommand.Add( "glorifiedbanking_logs", function( ply )
    if ply:IsSuperAdmin() or CAMI.PlayerHasAccess( "glorifiedbanking_openlogs" ) then
        local logsJSON = GlorifiedBanking.Logs
        logsJSON = tostring( util.TableToJSON( logsJSON ) )

        -- send 2000 chars of the table at a time to prevent going over the 64kb buffer
        local chunksToSend = math.ceil( string.len( logsJSON ) / 2000 )
        local chunksTbl = chunkstring( logsJSON, 2000 )

        net.Start( "GlorifiedBanking.PlayerOpenedLogs" )
        net.WriteUInt( chunksToSend, 8 ) -- send how many chunks we are supposed to be receiving for an appropriate clientsided for loop
        for i = 1, chunksToSend do
            net.WriteData( util.Compress( chunksTbl[i] ), 16008 ) -- 2000 max chars * 8 + 8 for bytecount
        end
        net.Send( ply )
    end
end )