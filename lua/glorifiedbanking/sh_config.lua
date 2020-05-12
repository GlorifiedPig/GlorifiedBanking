
--[[ Addon Integrations ]]--
    GlorifiedBanking.Config.SUPPORT_ZEROS_ADDONS = false -- If you have any of Zero's addons on your server, you can choose for your income to go to your bank with this option.
    GlorifiedBanking.Config.SUPPORT_BLOGS = false -- Set this to true if you'd like to log withdrawals, deposits and transfers via bLogs.
--[[ End Addon Integrations ]]--

--[[ Other Options ]]--
    GlorifiedBanking.Config.SALARY_TO_BANK = true -- Should the player's salary get transferred to his bank account?
    GlorifiedBanking.Config.STARTING_BALANCE = 5000 -- How much money to start with in the player's bank account?
    GlorifiedBanking.Config.DROP_MONEY_ON_DEATH = false -- Whether or not money should be dropped on death.
    GlorifiedBanking.Config.DROP_MONEY_ON_DEATH_AMOUNT = 500 -- If the above is set to true, how much should the player drop on death?
--[[ End Other Options ]]--

--[[ Interest Settings ]]--
    GlorifiedBanking.Config.INTEREST_ENABLED = true -- Should interest be enabled or not?
    GlorifiedBanking.Config.INTEREST_TIMER = 20 -- How often should the player receive interest?
    GlorifiedBanking.Config.INTEREST_MAX = 50000 -- What's the maximum amount a player can receive in interest?
    GlorifiedBanking.Config.DEFAULT_INTEREST_PERCENTAGE = 0.1 -- What % should the player get for interest per x seconds? Set to 0 to disable interest for normal players.
    GlorifiedBanking.Config.INTEREST_AMOUNT_CUSTOMFUNC = function( ply ) -- Special function to return different interest for certain players.
        local specialGroups = {
            ["donator"] = 0.2,
            ["superadmin"] = 1
        }
        if specialGroups[ply:GetUserGroup()] then return specialGroups[ply:GetUserGroup()] end
    end
--[[ End Interest Settings ]]--

--[[ Permissions Settings ]]--
    GlorifiedBanking.Config.CAMI_PERMISSION_DEFAULTS = {
        ["glorifiedbanking_openlogs"] = {
            MinAccess = "admin",
            Description = "Determines whether or not the player can open the GlorifiedBanking logs panel."
        }
    }
--[[ End Permissions Settings ]]--