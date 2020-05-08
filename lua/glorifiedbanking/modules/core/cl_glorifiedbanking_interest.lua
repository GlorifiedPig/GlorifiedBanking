
if not GlorifiedBanking.Config.INTEREST_ENABLED then return end

function GlorifiedBanking.GetInterestFromAmount( bal, usergroup )
    if usergroup and GlorifiedBanking.Config.USERGROUP_SPECIFIC_INTERESTS[usergroup] then
        return math.Round( ( bal / 100 ) * GlorifiedBanking.Config.USERGROUP_SPECIFIC_INTERESTS[usergroup] )
    else
        return math.Round( ( bal / 100 ) * GlorifiedBanking.Config.DEFAULT_INTEREST_PERCENTAGE )
    end
end

function GlorifiedBanking.GetPlayerInterestAmount()
    return GlorifiedBanking.GetInterestFromAmount( GlorifiedBanking.GetPlayerBalance(), LocalPlayer():GetUserGroup() )
end