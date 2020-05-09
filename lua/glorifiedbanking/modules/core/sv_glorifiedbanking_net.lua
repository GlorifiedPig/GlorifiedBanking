
util.AddNetworkString( "GlorifiedBanking.WithdrawalRequested" )
util.AddNetworkString( "GlorifiedBanking.DepositRequested" )

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

net.Receive( "GlorifiedBanking.WithdrawalRequested", function( len, ply )
    local amount = net.ReadUInt( 32 )
    if isnumber( amount ) == false
    or ply:IsBot()
    or not ply:IsPlayer()
    or not ply:Alive()
    or not ply:IsFullyAuthenticated()
    or not ply:IsConnected()
    or ply:IsTimingOut()
    or DistanceToClosestATM( ply ) >= 500
    or amount <= 0
    or GlorifiedBanking.CanPlayerAfford( ply, amount ) != true then return end
    GlorifiedBanking.WithdrawAmount( ply, amount )
end )

net.Receive( "GlorifiedBanking.DepositRequested", function( len, ply )
    local amount = net.ReadUInt( 32 )
    if isnumber( amount ) == false
    or ply:IsBot()
    or not ply:IsPlayer()
    or not ply:Alive()
    or not ply:IsFullyAuthenticated()
    or not ply:IsConnected()
    or ply:IsTimingOut()
    or DistanceToClosestATM( ply ) >= 500
    or amount <= 0
    or ply:canAfford( amount ) != true then return end
    GlorifiedBanking.DepositAmount( ply, amount )
end )