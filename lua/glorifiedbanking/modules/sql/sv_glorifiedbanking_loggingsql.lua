
GlorifiedBanking.SQLQuery( "CREATE TABLE IF NOT EXISTS `gb_withdrawals` ( `Date` TIMESTAMP NOT NULL , `SteamID` VARCHAR(32) NOT NULL , `WithdrawAmount` BIGINT(64) NOT NULL )" )
GlorifiedBanking.SQLQuery( "CREATE TABLE IF NOT EXISTS `gb_deposits` ( `Date` TIMESTAMP NOT NULL , `SteamID` VARCHAR(32) NOT NULL , `DepositAmount` BIGINT(64) NOT NULL )" )
GlorifiedBanking.SQLQuery( "CREATE TABLE IF NOT EXISTS `gb_transfers` ( `Date` TIMESTAMP NOT NULL , `SteamID` VARCHAR(32) NOT NULL , `ReceiverSteamID` VARCHAR(32) NOT NULL , `TransferAmount` BIGINT(64) NOT NULL )" )

function GlorifiedBanking.LogWithdrawalSQL( ply, withdrawAmount )
    GlorifiedBanking.SQLQuery( "INSERT INTO `gb_withdrawals`( `Date`, `SteamID`, `WithdrawAmount` ) VALUES ( '" .. os.time() .. "', '" .. ply:SteamID() .. "', " .. withdrawAmount .. " )" )
end

function GlorifiedBanking.LogDepositSQL( ply, depositAmount )
    GlorifiedBanking.SQLQuery( "INSERT INTO `gb_deposits`( `Date`, `SteamID`, `DepositAmount` ) VALUES ( '" .. os.time() .. "', '" .. ply:SteamID() .. "', " .. depositAmount .. " )" )
end

function GlorifiedBanking.LogTransferSQL( ply, receiver, transferAmount )
    GlorifiedBanking.SQLQuery( "INSERT INTO `gb_deposits`( `Date`, `SteamID`, `ReceiverSteamID`, `TransferAmount` ) VALUES ( '" .. os.time() .. "', '" .. ply:SteamID() .. "', '" .. receiver:SteamID() .. "', " .. transferAmount .. " )" )
end