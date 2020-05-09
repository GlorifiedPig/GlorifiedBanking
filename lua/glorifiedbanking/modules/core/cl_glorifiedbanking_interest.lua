
if not GlorifiedBanking.Config.INTEREST_ENABLED then return end

-- This function is noted properly in sv_glorifiedbanking_interest.lua
function GlorifiedBanking.GetPlayerInterestAmount()
    local customFunc = GlorifiedBanking.Config.INTEREST_AMOUNT_CUSTOMFUNC
    local percentage = GlorifiedBanking.Config.DEFAULT_INTEREST_PERCENTAGE
    if customFunc then
        local customFuncReturn = customFunc( LocalPlayer() )
        if customFuncReturn and customFuncReturn != nil and customFuncReturn != 0 then
            percentage = customFuncReturn
        end
    end
    return math.Round( ( GlorifiedBanking.GetPlayerBalance() / 100 ) * percentage )
end