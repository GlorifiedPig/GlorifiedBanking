
GlorifiedBanking.HookRunName = "DarkRPFinishedLoading" -- Which hook should we start loading GlorifiedBanking files in?

function GlorifiedBanking.CanAfford( ply, amount )
    return ply:canAfford( amount )
end

function GlorifiedBanking.FormatMoney( amount )
    return DarkRP.formatMoney( amount )
end

if SERVER then
    function GlorifiedBanking.AddCash( ply, amount )
        return ply:addMoney( amount )
    end

    function GlorifiedBanking.RemoveCash( ply, amount )
        return ply:addMoney( -amount )
    end
end