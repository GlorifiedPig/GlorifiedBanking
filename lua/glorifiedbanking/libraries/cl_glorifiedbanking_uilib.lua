
GlorifiedBanking.UI = {}

local lerp = Lerp
function GlorifiedBanking.UI.LerpColor( t, from, to )
    local col = Color( 0, 0, 0 )

    col.r = lerp( t, from.r, to.r )
    col.g = lerp( t, from.g, to.g )
    col.b = lerp( t, from.b, to.b )
    col.a = lerp( t, from.a, to.a )

    return col
end