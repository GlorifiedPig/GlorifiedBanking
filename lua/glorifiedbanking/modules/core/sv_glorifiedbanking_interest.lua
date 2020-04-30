
if not GlorifiedBanking.Config.INTEREST_ENABLED then return end

function GlorifiedBanking.GetInterestFromAmount( bal )
    return ( bal / 100 ) * GlorifiedBanking.Config.INTEREST_PERCENTAGE
end

local function AddInterestBalance( ply )
    GlorifiedBanking.AddPlayerBalance( ply, GlorifiedBanking.GetInterestFromAmount( GlorifiedBanking.GetPlayerBalance( ply ) ) )
end

function GlorifiedBanking.ApplyPlayerInterest( ply )
    if istable( ply ) then
        for k, v in pairs( ply ) do AddInterestBalance( ply ) end
    elseif ply:IsPlayer() then
        AddInterestBalance( ply )
    end

    DarkRP.notify( ply, NOTIFY_GENERIC, 5, "You received " .. DarkRP.formatMoney( GlorifiedBanking.GetInterestFromAmount( GlorifiedBanking.GetPlayerBalance( ply ) ) ) .. " in interest." )
end

hook.Add( "InitPostEntity", "GlorifiedBanking.Interest.InitPostEntity", function()
    timer.Create( "GlorifiedBanking.InterestTimer", GlorifiedBanking.Config.INTEREST_TIMER, 0, function()
        GlorifiedBanking.ApplyPlayerInterest( player.GetAll() )
    end )
end )