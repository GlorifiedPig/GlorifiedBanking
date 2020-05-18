
--[[
    This file contains a lot of validation and authentication checks.
    Some of them may seem unnecessary, but it's never worth taking chances with an addon based purely around the server's economy.
    Extra validation checks are held on the actual player meta functions in the sv_glorifiedbanking_playermeta.lua file.
]]--

util.AddNetworkString( "GlorifiedBanking.WithdrawalRequested" )
util.AddNetworkString( "GlorifiedBanking.DepositRequested" )
util.AddNetworkString( "GlorifiedBanking.TransferRequested" )

util.AddNetworkString( "GlorifiedBanking.SendAnimation" )
util.AddNetworkString( "GlorifiedBanking.CardInserted" )
util.AddNetworkString( "GlorifiedBanking.Logout" )
util.AddNetworkString( "GlorifiedBanking.ChangeScreen" )
util.AddNetworkString( "GlorifiedBanking.ForceLoad" )

util.AddNetworkString( "GlorifiedBanking.AdminPanel.SetPlayerBalance" )

util.AddNetworkString( "GlorifiedBanking.SendTransactionData" )

local function PlayerAuthChecks( ply )
    return not ( not ply:IsValid()
    or ply:IsBot()
    or not ply:IsFullyAuthenticated()
    or not ply:IsConnected() )
end

local function ATMDistanceChecks( ply, atmEntity )
    local maxDistance = GlorifiedBanking.Config.MAXIMUM_DISTANCE_FROM_ATM
    return atmEntity:GetPos():DistToSqr( ply:GetPos() ) <= maxDistance * maxDistance
end

local function ValidationChecks( ply, balance, atmEntity )
    return not ( GlorifiedBanking.LockdownEnabled
    or not balance
    or balance == nil
    or balance < 0
    or not PlayerAuthChecks( ply )
    or atmEntity:GetClass() != "glorifiedbanking_atm"
    or atmEntity.ForcedLoad
    or not ATMDistanceChecks( ply, atmEntity ) )
end

net.Receive( "GlorifiedBanking.WithdrawalRequested", function( len, ply )
    local amount = net.ReadUInt( 32 )
    local atmEntity = net.ReadEntity()
    if not ValidationChecks( ply, amount, atmEntity ) then return end

    atmEntity:Withdraw(ply, amount)
end )

net.Receive( "GlorifiedBanking.DepositRequested", function( len, ply )
    local amount = net.ReadUInt( 32 )
    local atmEntity = net.ReadEntity()
    if not ValidationChecks( ply, amount, atmEntity ) then return end

    atmEntity:Deposit(ply, amount)
end )

net.Receive( "GlorifiedBanking.TransferRequested", function( len, ply )
    local amount = net.ReadUInt( 32 )
    local atmEntity = net.ReadEntity()
    if not ValidationChecks( ply, amount, atmEntity ) then return end
    local receiver = net.ReadEntity()
    if not PlayerAuthChecks( receiver ) then return end

    atmEntity:Transfer( ply, receiver, amount )
end )

net.Receive( "GlorifiedBanking.CardInserted", function( len, ply )
    local atmEntity = net.ReadEntity()
    if not GlorifiedBanking.LockdownEnabled
    and atmEntity:GetClass() == "glorifiedbanking_atm"
    and atmEntity:GetCurrentUser() == NULL
    and ply:GetActiveWeapon():GetClass() == "glorifiedbanking_card"
    and PlayerAuthChecks( ply )
    and ATMDistanceChecks( ply, atmEntity ) then
        atmEntity:InsertCard( ply )
    end
end )

net.Receive( "GlorifiedBanking.Logout", function( len, ply )
    local atmEntity = net.ReadEntity()
    if atmEntity:GetClass() == "glorifiedbanking_atm"
    and atmEntity:GetCurrentUser() == ply then
        if atmEntity.ForcedLoad then
            atmEntity:EmitSound("GlorifiedBanking.Beep_Error")
            return
        end

        atmEntity:Logout()
        atmEntity:EmitSound("GlorifiedBanking.Beep_Normal")
    end
end )

net.Receive( "GlorifiedBanking.ChangeScreen", function( len, ply )
    local newScreen = net.ReadUInt(4)
    local atmEntity = net.ReadEntity()
    if atmEntity:GetClass() == "glorifiedbanking_atm"
    and atmEntity:GetCurrentUser() == ply
    and atmEntity.Screens[ newScreen ] then
        if atmEntity.ForcedLoad then
            atmEntity:EmitSound("GlorifiedBanking.Beep_Error")
            return
        end

        atmEntity:SetScreenID( newScreen )
        atmEntity:EmitSound("GlorifiedBanking.Beep_Normal")
        atmEntity.LastAction = CurTime()
    end
end )

net.Receive( "GlorifiedBanking.AdminPanel.SetPlayerBalance", function( len, ply )
    if GlorifiedBanking.HasPermission( ply, "glorifiedbanking_setplayerbalance" ) then
        local plySteamID = net.ReadString()
        local newBalance = net.ReadUInt( 32 )
        GlorifiedBanking.SetPlayerBalanceBySteamID( plySteamID, newBalance )
    end
end )

function GlorifiedBanking.SendTransactionData( ply )
    GlorifiedBanking.SQL.Query( "SELECT * FROM `gb_withdrawals` WHERE `SteamID` = '" .. ply:SteamID() .. "' LIMIT 50", function( withdrawalQuery )
        GlorifiedBanking.SQL.Query( "SELECT * FROM `gb_deposits` WHERE `SteamID` = '" .. ply:SteamID() .. "' LIMIT 50", function( depositQuery )
            GlorifiedBanking.SQL.Query( "SELECT * FROM `gb_transfers` WHERE `SteamID` = '" .. ply:SteamID() .. "' LIMIT 20", function( transferQuery )
                net.Start( "GlorifiedBanking.SendTransactionData" )
                net.WriteLargeString( util.TableToJSON( withdrawalQuery ) )
                net.WriteLargeString( util.TableToJSON( depositQuery ) )
                net.WriteLargeString( util.TableToJSON( transferQuery ) )
                net.Send( ply )
            end )
        end )
    end )
end
