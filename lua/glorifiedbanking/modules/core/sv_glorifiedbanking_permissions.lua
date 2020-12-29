
function GlorifiedBanking.HasPermission( ply, permission, callbackFunc )
    return CAMI.PlayerHasAccess( ply, permission, callbackFunc ) or ply:IsSuperAdmin()
end

function GlorifiedBanking.RegisterPermission( permission, minAccess, description )
    CAMI.RegisterPrivilege( {
        Name = permission,
        MinAccess = minAccess,
        Description = description
    } )
end

for k, v in pairs( GlorifiedBanking.Config.CAMI_PERMISSION_DEFAULTS ) do
    GlorifiedBanking.RegisterPermission( k, v.MinAccess, v.Description )
end