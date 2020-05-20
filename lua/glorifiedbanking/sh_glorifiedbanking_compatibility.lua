
GlorifiedBanking.HookRunName = "DarkRPFinishedLoading" -- Which hook should we start loading GlorifiedBanking files in?

function GlorifiedBanking.CanWalletAfford( ply, amount )
    return ply:canAfford( amount )
end

function GlorifiedBanking.FormatMoney( amount )
    return DarkRP.formatMoney( tonumber( amount ) )
end

if SERVER then
    function GlorifiedBanking.AddCash( ply, amount )
        return ply:addMoney( amount )
    end

    function GlorifiedBanking.RemoveCash( ply, amount )
        return ply:addMoney( -amount )
    end

    function GlorifiedBanking.Notify( ply, msgType, time, message )
        DarkRP.notify( ply, msgType, time, message )
    end
else
    function GlorifiedBanking.Notify( msgType, time, message )
        notification.AddLegacy( message, msgType, time )
    end
end