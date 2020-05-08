
if not GlorifiedBanking.Config.INTEREST_ENABLED then return end

function GlorifiedBanking.GetInterestFromAmount( bal, usergroup )
    if usergroup and GlorifiedBanking.Config.USERGROUP_SPECIFIC_INTERESTS[usergroup] then
        return math.Round( ( bal / 100 ) * GlorifiedBanking.Config.USERGROUP_SPECIFIC_INTERESTS[usergroup] )
    else
        return math.Round( ( bal / 100 ) * GlorifiedBanking.Config.DEFAULT_INTEREST_PERCENTAGE )
    end
end

function GlorifiedBanking.GetPlayerInterestAmount( ply )
    return GlorifiedBanking.GetInterestFromAmount( GlorifiedBanking.GetPlayerBalance( ply ), ply:GetUserGroup() )
end

function GlorifiedBanking.ApplyPlayerInterest( ply )
    local interestAmount = GlorifiedBanking.GetPlayerInterestAmount( ply )
    if interestAmount == 0 then return end
    interestAmount = math.Clamp( interestAmount, 0, GlorifiedBanking.Config.INTEREST_MAX )
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