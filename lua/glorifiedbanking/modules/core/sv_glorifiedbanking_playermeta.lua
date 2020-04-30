
function GlorifiedBanking.SetPlayerBalance( ply, balance )
    if not balance or not isnumber( balance ) then return end
    if not ply.GlorifiedBanking then ply.GlorifiedBanking = {} end
    balance = math.Round( balance )
    hook.Run( "GlorifiedBanking.PlayerBalanceUpdated", ply, GlorifiedBanking.GetPlayerBalance( ply ), balance ) -- ply, oldBalance, newBalance
    GlorifiedBanking.SQLQuery( "UPDATE `gb_players` SET `Balance` = " .. balance .. " WHERE `SteamID` = '" .. ply:SteamID() .. "'" )
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
        GlorifiedBanking.LogWithdrawalSQL( ply, withdrawAmount )
        hook.Run( "GlorifiedBanking.PlayerWithdrawal", ply, withdrawAmount ) -- ply, withdrawAmount
    end
end

function GlorifiedBanking.DepositAmount( ply, depositAmount )
    if ply:canAfford( depositAmount ) then
        ply:addMoney( -depositAmount )
        GlorifiedBanking.AddPlayerBalance( ply, depositAmount )
        GlorifiedBanking.LogDepositSQL( ply, depositAmount )
        hook.Run( "GlorifiedBanking.PlayerDeposit", ply, depositAmount ) -- ply, depositAmount
    end
end

function GlorifiedBanking.TransferAmount( ply, receiver, transferAmount )
    if GlorifiedBanking.CanPlayerAfford( ply, transferAmount ) then
        GlorifiedBanking.RemovePlayerBalance( ply, transferAmount )
        GlorifiedBanking.AddPlayerBalance( receiver, transferAmount )
        GlorifiedBanking.LogTransferSQL( ply, receiver, transferAmount )
        hook.Run( "GlorifiedBanking.PlayerTransfer", ply, receiver, transferAmount ) -- ply, receiver, transferAmount
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
    GlorifiedBanking.WithdrawAmount( self, withdrawAmount )
end

function plyMeta:DepositToBank( depositAmount )
    GlorifiedBanking.DepositAmount( self, depositAmount )
end

function plyMeta:TransferBankMoney( receiver, transferAmount )
    GlorifiedBanking.TransferAmount( self, receiver, transferAmount )
end