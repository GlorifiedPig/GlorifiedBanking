
GlorifiedBanking.HookRunName = "DarkRPFinishedLoading" -- Which hook should we start loading GlorifiedBanking files in?

function GlorifiedBanking.CanWalletAfford( ply, amount )
    return ply:canAfford( amount )
end

function GlorifiedBanking.FormatMoney( amount )
    return DarkRP.formatMoney( tonumber( amount ) )
end

function GlorifiedBanking.GetEntOwner( ent )
    local owner = ent:CPPIGetOwner()
    if owner then return owner end
    return ent.Getowning_ent and ent:Getowning_ent()
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

    function GlorifiedBanking.SetEntOwner( ent, ply )
        if ent.Setowning_ent then ent:Setowning_ent(ply) end
        ent:CPPISetOwner(ply)
    end
else
    function GlorifiedBanking.Notify( msgType, time, message )
        notification.AddLegacy( message, msgType, time )
    end
end

hook.Add("playerBoughtCustomEntity", "GlorifiedBanking.Compatability.playerBoughtCustomEntity", function(ply, entTbl, ent, price)
    if ent:GetClass() == "glorifiedbanking_cardreader" then ent:SetMerchant(ply) end
end)
