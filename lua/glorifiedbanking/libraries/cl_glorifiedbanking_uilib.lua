
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

function GlorifiedBanking.UI.StartCutOut(areaDraw)
    render.ClearStencil()
    render.SetStencilEnable(true)
    render.SetStencilCompareFunction(STENCIL_ALWAYS)
    render.SetStencilPassOperation(STENCIL_REPLACE)
    render.SetStencilFailOperation(STENCIL_KEEP)
    render.SetStencilZFailOperation(STENCIL_KEEP)

    render.SetStencilWriteMask(1)
    render.SetStencilTestMask(1)
    render.SetStencilReferenceValue(1)

    render.OverrideColorWriteEnable(true, false)

    areaDraw()

    render.OverrideColorWriteEnable(false, false)

    render.SetStencilCompareFunction(STENCIL_EQUAL)
end

function GlorifiedBanking.UI.EndCutOut()
    render.SetStencilEnable(false)
end
