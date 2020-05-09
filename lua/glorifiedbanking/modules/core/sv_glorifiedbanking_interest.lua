
if not GlorifiedBanking.Config.INTEREST_ENABLED then return end

-- Make this a function in the GlorifiedBanking table so it can be easily accessed for display purposes, for example.
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
    local interestAmount = GlorifiedBanking.GetPlayerInterestAmount( ply ) -- Fetch the player's interest amount from the above function.
    if interestAmount <= 0 or not ply:IsValid() or not ply:IsPlayer() or ply:IsBot() then return end -- A few validation checks.
    interestAmount = math.Clamp( interestAmount, 0, GlorifiedBanking.Config.INTEREST_MAX ) -- Clamp to make sure it doesn't go below zero and doesn't go above the maximum interest amount.
    GlorifiedBanking.AddPlayerBalance( ply, interestAmount ) -- Add the actual interest amount to the player's balance.
    DarkRP.notify( ply, NOTIFY_GENERIC, 5, i18n.GetPhrase( "gbInterestReceived", DarkRP.formatMoney( interestAmount ) ) ) -- Notify the player that they have received their interest.
    hook.Run( "GlorifiedBanking.PlayerInterestReceived", ply, interestAmount ) -- Calls upon interest received with the args ( ply, interestAmount ).
end

hook.Add( "InitPostEntity", "GlorifiedBanking.Interest.InitPostEntity", function()
    timer.Create( "GlorifiedBanking.InterestTimer", GlorifiedBanking.Config.INTEREST_TIMER, 0, function()
        for k, v in pairs( player.GetAll() ) do
            GlorifiedBanking.ApplyPlayerInterest( v )
        end
    end )
end )