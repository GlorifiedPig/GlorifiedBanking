if not GlorifiedBanking.Config.DROP_MONEY_ON_DEATH then return end

hook.Add( "PlayerDeath", "GlorifiedBanking.DropMoneyOnDeath.PlayerDeath", function( ply )
    GlorifiedBanking.RemovePlayerBalance( ply, GlorifiedBanking.Config.DROP_MONEY_ON_DEATH_AMOUNT )
    DarkRP.notify( ply, NOTIFY_ERROR, 5, i18n.GetPhrase( "gbDropMoneyOnDeath", GlorifiedBanking.Config.DROP_MONEY_ON_DEATH_AMOUNT ) )
end )