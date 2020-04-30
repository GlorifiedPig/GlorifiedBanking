
if not GlorifiedBanking.Config.SALARY_TO_BANK then return end

hook.Add( "playerGetSalary", "GlorifiedBanking.SalaryToBank.playerGetSalary", function( ply, amount )
    GlorifiedBanking.AddPlayerBalance( ply, amount )
    return false, "Your salary of " .. DarkRP.formatMoney( amount ) .. " was transferred to your bank.", 0
    -- Be sure to override the default message and return a salary of $0 so the player doesn't receive money on top of their initial salary.
end )