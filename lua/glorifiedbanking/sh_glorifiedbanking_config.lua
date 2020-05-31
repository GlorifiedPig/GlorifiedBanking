
--[[ Addon Integrations ]]--
    GlorifiedBanking.Config.SUPPORT_ZEROS_ADDONS = false -- If you have any of Zero's addons on your server, you can choose for your income to go to your bank with this option.
    GlorifiedBanking.Config.SUPPORT_BLOGS = false -- Set this to true if you'd like to log withdrawals, deposits and transfers via bLogs.
    GlorifiedBanking.Config.SUPPORT_GSMARTWATCH = false -- Set this to true if you'd like to allow payment via smart watch.
--[[ End Addon Integrations ]]--

--[[ Interest Settings ]]--
    GlorifiedBanking.Config.INTEREST_ENABLED = true -- Should interest be enabled or not?
    GlorifiedBanking.Config.INTEREST_TIMER = 120 -- How often should the player receive interest? This amount is in seconds.
    GlorifiedBanking.Config.INTEREST_MAX = 10000 -- What's the maximum amount a player can receive in interest?
    GlorifiedBanking.Config.DEFAULT_INTEREST_PERCENTAGE = 0.1 -- What % should the player get for interest per x seconds? Set to 0 to disable interest for normal players.
    GlorifiedBanking.Config.INTEREST_AMOUNT_CUSTOMFUNC = function( ply ) -- Special function to return different interest for certain players.
        local specialGroups = {
            ["donator"] = 0.2,
            ["superadmin"] = 1
        }
        if specialGroups[ply:GetUserGroup()] then return specialGroups[ply:GetUserGroup()] end
    end
--[[ End Interest Settings ]]--

--[[ Other Config ]]--
    GlorifiedBanking.Config.CARD_PAYMENT_FEE = 0 --Percentage fee (0-100) taken from transactions done via card readers.
    GlorifiedBanking.Config.MAXIMUM_DISTANCE_FROM_ATM = 250 -- What is the maximum distance for the validation checks on the ATMs?
--[[ End Other Config ]]--
