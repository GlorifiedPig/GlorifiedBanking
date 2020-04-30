
if not GlorifiedBanking.Config.INTEREST_ENABLED then return end

function GlorifiedBanking.GetInterestFromAmount( bal )
    return math.Round( ( bal / 100 ) * GlorifiedBanking.Config.INTEREST_PERCENTAGE )
end

function GlorifiedBanking.ApplyPlayerInterest( ply )
    local interestAmount = GlorifiedBanking.GetInterestFromAmount( GlorifiedBanking.GetPlayerBalance( ply ) )
    GlorifiedBanking.AddPlayerBalance( ply, interestAmount )
    DarkRP.notify( ply, NOTIFY_GENERIC, 5, i18n.GetPhrase( "gbInterestReceived", DarkRP.formatMoney( interestAmount ) ) )
    hook.Run( "GlorifiedBanking.PlayerInterestReceived", ply, interestAmount ) -- ply, interestAmount
end

hook.Add( "InitPostEntity", "GlorifiedBanking.Interest.InitPostEntity", function()
    timer.Create( "GlorifiedBanking.InterestTimer", GlorifiedBanking.Config.INTEREST_TIMER, 0, function()
        for k, v in pairs( player.GetAll() ) do
            GlorifiedBanking.ApplyPlayerInterest( v )
        end
    end )
end )