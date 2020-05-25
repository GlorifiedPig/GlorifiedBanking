
function GlorifiedBanking.GetPlayerBalance()
    return LocalPlayer():GetNW2Int( "GlorifiedBanking.Balance" ) or 0
end

function GlorifiedBanking.CanPlayerAfford( affordAmount )
    local numberedAffordAmount = tonumber( affordAmount )
    if numberedAffordAmount != nil then
        return GlorifiedBanking.GetPlayerBalance( ply ) >= numberedAffordAmount
    end
end

local plyMeta = FindMetaTable( "Player" )
function plyMeta:GetBankBalance()
    return GlorifiedBanking.GetPlayerBalance()
end

function plyMeta:CanAffordBank( affordAmount )
    return GlorifiedBanking.CanPlayerAfford( affordAmount )
end