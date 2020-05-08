
if not GlorifiedBanking.Config.INTEREST_ENABLED then return end

function GlorifiedBanking.GetPlayerInterestAmount( ply )
    local customFunc = GlorifiedBanking.Config.INTEREST_AMOUNT_CUSTOMFUNC
    local percentage = GlorifiedBanking.Config.DEFAULT_INTEREST_PERCENTAGE
    if customFunc then
        local customFuncReturn = customFunc( ply )
        if customFuncReturn and customFuncReturn != nil and customFuncReturn != 0 then
            percentage = customFuncReturn
        end
    end
    return math.Round( ( GlorifiedBanking.GetPlayerBalance( ply ) / 100 ) * percentage )
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