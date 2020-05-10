
function GlorifiedBanking.HasPermission( ply, permission, callbackFunc )
    return CAMI.PlayerHasAccess( ply, permission, callbackFunc )
end

function GlorifiedBanking.RegisterPermission( permission, minAccess, description )
    CAMI.RegisterPrivilege( {
        Name = permission,
        MinAccess = minAccess,
        Description = description
    } )
end

local logsPermDefaults = GlorifiedBanking.Config.CAMI_PERMISSION_DEFAULTS["glorifiedbanking_openlogs"]
GlorifiedBanking.RegisterPermission( "glorifiedbanking_openlogs", logsPermDefaults.MinAccess, logsPermDefaults.Description )