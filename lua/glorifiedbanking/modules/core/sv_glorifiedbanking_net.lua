
--[[
    This file contains a lot of validation and authentication checks.
    Some of them may seem unnecessary, but it's never worth taking chances with an addon based purely around the server's economy.
    Extra validation checks are held on the actual player meta functions in the sv_glorifiedbanking_playermeta.lua file.
]]--

util.AddNetworkString( "GlorifiedBanking.WithdrawalRequested" )
util.AddNetworkString( "GlorifiedBanking.DepositRequested" )
util.AddNetworkString( "GlorifiedBanking.SendTransactionData" )

local function DistanceToClosestATM( ply )
    local plyPos = ply:GetPos()
    local closestDistance
    for k, v in pairs( ents.FindByClass( "glorifiedbanking_atm" ) ) do
        if not v:IsValid() then continue end
        local atmPos = v:GetPos()
        local distance = plyPos:Distance( atmPos )
        if closestDistance == nil or distance <= closestDistance then
            closestDistance = distance
        end
    end
    return closestDistance
end

local function ValidationChecks( ply, balance )
    return not ( GlorifiedBanking.LockdownEnabled
    or not balance
    or balance == nil
    or balance < 0
    or not ply:IsValid()
    or ply:IsBot()
    or not ply:IsFullyAuthenticated()
    or not ply:IsConnected()
    or DistanceToClosestATM( ply ) >= 500 )
end

net.Receive( "GlorifiedBanking.WithdrawalRequested", function( len, ply )
    local amount = net.ReadUInt( 32 )
    if ValidationChecks( ply, amount ) then return end
    GlorifiedBanking.WithdrawAmount( ply, amount )
end )

net.Receive( "GlorifiedBanking.DepositRequested", function( len, ply )
    local amount = net.ReadUInt( 32 )
    if ValidationChecks( ply, amount ) then return end
    GlorifiedBanking.DepositAmount( ply, amount )
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