
GlorifiedBanking.SQLQuery( "CREATE TABLE IF NOT EXISTS `gb_players`( `SteamID` VARCHAR(17) NOT NULL, `Balance` BIGINT(64) NOT NULL, PRIMARY KEY( `SteamID` ) )" )

local startingBalance = GlorifiedBanking.Config.STARTING_BALANCE
hook.Add( "PlayerInitialSpawn", "GlorifiedBanking.SQLPlayer.PlayerInitialSpawn", function( ply )
    if not ply.GlorifiedBanking then ply.GlorifiedBanking = {} end
    GlorifiedBanking.SQLQuery( "SELECT * FROM `gb_players` WHERE `SteamID` = '" .. ply:SteamID() .. "' LIMIT 1", function( queryResult )
        if queryResult and next( queryResult ) != nil then
            ply.GlorifiedBanking.Balance = queryResult[1]["Balance"]
        else
            GlorifiedBanking.SQLQuery( "INSERT INTO `gb_players`( `SteamID`, `Balance` ) VALUES ( '" .. ply:SteamID() .. "', " .. startingBalance .. " )" )
            ply.GlorifiedBanking.Balance = startingBalance
        end
    end )
end )

function GlorifiedBanking.SetPlayerBalance( ply, balance )
    if not balance or not isnumber( balance ) then return end
    if not ply.GlorifiedBanking then ply.GlorifiedBanking = {} end
    GlorifiedBanking.SQLQuery( "UPDATE `players` SET `Balance` = " .. balance .. " WHERE `SteamID` = '" .. ply:SteamID() .. "'" )
    ply.GlorifiedBanking.Balance = balance
end

function GlorifiedBanking.GetPlayerBalance( ply )
    if not ply.GlorifiedBanking then ply.GlorifiedBanking = {} end
    return ply.GlorifiedBanking.Balance or 0
end

function GlorifiedBanking.AddPlayerBalance( ply, addAmount )
    GlorifiedBanking.SetPlayerBalance( ply, GlorifiedBanking.GetPlayerBalance( ply ) + addAmount )
end

function GlorifiedBanking.RemovePlayerBalance( ply, removeAmount )
    GlorifiedBanking.SetPlayerBalance( ply, math.Clamp( GlorifiedBanking.GetPlayerBalance( ply ) - addAmount, 0 ) )
end

function GlorifiedBanking.CanPlayerAfford( ply, affordAmount )
    return GlorifiedBanking.GetPlayerBalance( ply ) >= affordAmount
end

function GlorifiedBanking.WithdrawAmount( ply, withdrawAmount )
    if GlorifiedBanking.CanPlayerAfford( ply, withdrawAmount ) then
        ply:addMoney( withdrawAmount )
        GlorifiedBanking.RemovePlayerBalance( ply, withdrawAmount )
    end
end

function GlorifiedBanking.DepositAmount( ply, depositAmount )
    if ply:canAfford( depositAmount ) then
        ply:addMoney( -depositAmount )
        GlorifiedBanking.AddPlayerBalance( ply, depositAmount )
    end
end

function GlorifiedBanking.TransferAmount( ply, receiver, transferAmount )
    if GlorifiedBanking.CanPlayerAfford( ply, transferAmount ) then
        GlorifiedBanking.RemovePlayerBalance( ply, transferAmount )
        GlorifiedBanking.AddPlayerBalance( receiver, transferAmount )
    end
end

local plyMeta = FindMetaTable( "Player" )
function plyMeta:SetBankBalance( balance )
    GlorifiedBanking.SetPlayerBalance( self, balance )
end

function plyMeta:GetBankBalance()
    return GlorifiedBanking.GetPlayerBalance( self )
end

function plyMeta:AddBankBalance( addAmount )
    GlorifiedBanking.AddPlayerBalance( self, addAmount )
end

function plyMeta:RemoveBankBalance( removeAmount )
    GlorifiedBanking.RemovePlayerBalance( self, removeAmount )
end

function plyMeta:CanAffordBank( affordAmount )
    return GlorifiedBanking.CanPlayerAfford( self, affordAmount )
end

function plyMeta:WithdrawFromBank( withdrawAmount )
    return GlorifiedBanking.WithdrawAmount( self, withdrawAmount )
end

function plyMeta:DepositToBank( depositAmount )
    return GlorifiedBanking.DepositAmount( self, depositAmount )
end

function plyMeta:TransferBankMoney( receiver, transferAmount )
    return GlorifiedBanking.TransferAmount( self, receiver, transferAmount )
end