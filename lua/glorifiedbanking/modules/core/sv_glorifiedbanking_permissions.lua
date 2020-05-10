
GlorifiedBanking.Permissions = {}

function GlorifiedBanking.HasPermission( ply, permission, callbackFunc )
    if CAMI then return CAMI.PlayerHasAccess( ply, permission, callbackFunc ) end
    return ply:IsSuperAdmin() or table.HasValue( GlorifiedBanking.Permissions[permission], ply:GetUserGroup() )
end

function GlorifiedBanking.RegisterPermission( permission, minAccess, usergroups, description )
    CAMI.RegisterPrivilege( {
        Name = permission,
        MinAccess = minAccess,
        Description = description
    } )

    GlorifiedBanking.Permissions[permission] = {
        MinAccess = minAccess,
        Usergroups = usergroups,
        Description = description
    }
end

local logsPermDefaults = GlorifiedBanking.Config.PERMISSION_DEFAULTS["glorifiedbanking_openlogs"]
GlorifiedBanking.RegisterPermission( "glorifiedbanking_openlogs", logsPermDefaults.minAccess, logsPermDefaults.usergroups, logsPermDefaults.description )