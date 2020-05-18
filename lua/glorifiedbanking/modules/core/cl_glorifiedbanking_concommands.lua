
concommand.Add( "glorifiedbanking_theme", function( ply, args )
    if ply != LocalPlayer() then return end
    local theme = string.lower( args[1] )
    GlorifiedBanking.Themes.Select( theme )
end )