
if not GlorifiedBanking.Config.INTEREST_ENABLED then return end

function GlorifiedBanking.GetInterestFromAmount( bal )
    return ( bal / 100 ) * GlorifiedBanking.Config.INTEREST_PERCENTAGE
end

function GlorifiedBanking.ApplyPlayerInterest( ply )
    GlorifiedBanking.AddPlayerBalance( ply, GlorifiedBanking.GetInterestFromAmount( GlorifiedBanking.GetPlayerBalance( ply ) ) )
    DarkRP.notify( ply, NOTIFY_GENERIC, 5, "You received " .. DarkRP.formatMoney( GlorifiedBanking.GetInterestFromAmount( GlorifiedBanking.GetPlayerBalance( ply ) ) ) .. " in interest." )
end

hook.Add( "InitPostEntity", "GlorifiedBanking.Interest.InitPostEntity", function()
    timer.Create( "GlorifiedBanking.InterestTimer", GlorifiedBanking.Config.INTEREST_TIMER, 0, function()
        for k, v in pairs( player.GetAll() ) do
            GlorifiedBanking.ApplyPlayerInterest( v )
        end
    end )
end )