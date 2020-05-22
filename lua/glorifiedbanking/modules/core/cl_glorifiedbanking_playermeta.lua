
function GlorifiedBanking.GetPlayerBalance()
    return LocalPlayer():GetNW2Int( "GlorifiedBanking.Balance" ) or 0
end

function GlorifiedBanking.CanPlayerAfford( affordAmount )
    return GlorifiedBanking.GetPlayerBalance() >= affordAmount
end

local plyMeta = FindMetaTable( "Player" )
function plyMeta:GetBankBalance()
    return GlorifiedBanking.GetPlayerBalance()
end

function plyMeta:CanAffordBank( affordAmount )
    return GlorifiedBanking.CanPlayerAfford( affordAmount )
end