
if not GlorifiedBanking.Config.SALARY_TO_BANK then return end

hook.Add( "playerGetSalary", "GlorifiedBanking.SalaryToBank.playerGetSalary", function( ply, amount )
    GlorifiedBanking.AddPlayerBalance( ply, amount )
    return false, GlorifiedBanking.i18n.GetPhrase( "gbSalaryToBank", GlorifiedBanking.FormatMoney( amount ) ), 0
    -- Be sure to override the default message and return a salary of $0 so the player doesn't receive wallet cash on top of their initial salary.
end )
