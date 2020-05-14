
local function minClamp( num, minimum )
    return math.max( minimum, num )
end

-- A few validation checks just in case anything slips through.
local function ValidationChecks( ply, balance )
    return not ( GlorifiedBanking.LockdownEnabled
    or not balance
    or balance == nil
    or balance < 0
    or not ply:IsValid()
    or ply:IsBot()
    or not ply:IsFullyAuthenticated()
    or not ply:IsConnected() )
end

function GlorifiedBanking.SetPlayerBalance( ply, balance )
    if not ValidationChecks( ply, balance ) then return end -- Always validate before doing important functions to keep things secure.
    balance = tonumber( balance ) -- Make sure to convert "500" to 500, just in case some function provides a string for whatever reason.
    if not ply.GlorifiedBanking then ply.GlorifiedBanking = {} end -- Initialize the player's GlorifiedBanking table if it doesn't already exist.
    balance = math.Round( balance ) -- Make sure the balance is always rounded to an integer, we don't want floats slipping through.
    balance = minClamp( balance, 0 ) -- Make sure the balance never goes below zero.
    hook.Run( "GlorifiedBanking.PlayerBalanceUpdated", ply, GlorifiedBanking.GetPlayerBalance( ply ), balance ) -- Args are ply, oldBalance and then newBalance. Documented in the markdown file.
    GlorifiedBanking.SQL.Query( "UPDATE `gb_players` SET `Balance` = " .. balance .. " WHERE `SteamID` = '" .. ply:SteamID() .. "'" ) -- Update the player's SQL data.
    ply.GlorifiedBanking.Balance = balance -- Cache the balance for easier usage elsewhere without the need to call another SQL query.
    ply:SetNWInt( "GlorifiedBanking.Balance", balance ) -- Set the networked balance so we don't have to include it in the net messages later.
end

function GlorifiedBanking.GetPlayerBalance( ply )
    if not ply.GlorifiedBanking then ply.GlorifiedBanking = {} end -- Initialize the player's GlorifiedBanking table if it doesn't already exist.
    return ply.GlorifiedBanking.Balance or 0 -- Be sure to return zero if the "Balance" variable is nil.
end

function GlorifiedBanking.AddPlayerBalance( ply, addAmount )
    if not ValidationChecks( ply, addAmount ) then return end -- Always validate before doing important functions to keep things secure.
    addAmount = tonumber( addAmount ) -- Make sure to convert "500" to 500, just in case some function provides a string for whatever reason.
    GlorifiedBanking.SetPlayerBalance( ply, GlorifiedBanking.GetPlayerBalance( ply ) + addAmount )
end

function GlorifiedBanking.RemovePlayerBalance( ply, removeAmount )
    if not ValidationChecks( ply, removeAmount ) then return end -- Always validate before doing important functions to keep things secure.
    removeAmount = tonumber( removeAmount ) -- Make sure to convert "500" to 500, just in case some function provides a string for whatever reason.
    removeAmount = minClamp( removeAmount, 0 ) -- Make sure we don't remove into a negative number as that would cause major consequences, always clamp to zero.
    GlorifiedBanking.SetPlayerBalance( ply, GlorifiedBanking.GetPlayerBalance( ply ) - removeAmount, 0 )
end

function GlorifiedBanking.CanPlayerAfford( ply, affordAmount )
    return GlorifiedBanking.GetPlayerBalance( ply ) >= affordAmount
end

function GlorifiedBanking.WithdrawAmount( ply, withdrawAmount )
    if not ValidationChecks( ply, withdrawAmount ) then return end -- Always validate before doing important functions to keep things secure.
    if GlorifiedBanking.CanPlayerAfford( ply, withdrawAmount ) then
        GlorifiedBanking.AddCash( ply, withdrawAmount )
        GlorifiedBanking.RemovePlayerBalance( ply, withdrawAmount )
        GlorifiedBanking.LogWithdrawal( ply, withdrawAmount )
        hook.Run( "GlorifiedBanking.PlayerWithdrawal", ply, withdrawAmount ) -- Calls upon withdrawal with the args ( ply, withdrawAmount ).
    end
end

function GlorifiedBanking.DepositAmount( ply, depositAmount )
    if not ValidationChecks( ply, depositAmount ) then return end -- Always validate before doing important functions to keep things secure.
    if GlorifiedBanking.CanWalletAfford( ply, depositAmount ) then
        GlorifiedBanking.RemoveCash( ply, depositAmount )
        GlorifiedBanking.AddPlayerBalance( ply, depositAmount )
        GlorifiedBanking.LogDeposit( ply, depositAmount )
        hook.Run( "GlorifiedBanking.PlayerDeposit", ply, depositAmount ) -- Calls upon deposit with the args ( ply, depositAmount ).
    end
end

function GlorifiedBanking.TransferAmount( ply, receiver, transferAmount )
    if not ValidationChecks( ply, transferAmount ) then return end -- Always validate before doing important functions to keep things secure.
    if GlorifiedBanking.CanPlayerAfford( ply, transferAmount ) then
        GlorifiedBanking.RemovePlayerBalance( ply, transferAmount )
        GlorifiedBanking.AddPlayerBalance( receiver, transferAmount )
        GlorifiedBanking.LogTransfer( ply, receiver, transferAmount )
        hook.Run( "GlorifiedBanking.PlayerTransfer", ply, receiver, transferAmount ) -- Calls upon transfer with the args ( ply, receiver, transferAmount ).
    end
end

-- Below are just meta functions in case people prefer using ply:GetBankBalance() over GlorifiedBanking.GetBankBalance( ply ).
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