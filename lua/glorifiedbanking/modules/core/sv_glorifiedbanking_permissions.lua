
GlorifiedBanking.Permissions = {}

function GlorifiedBanking.HasPermission( ply, permission, callbackFunc )
    if CAMI then return CAMI.PlayerHasAccess( ply, permission, callbackFunc ) end
    return ply:IsSuperAdmin() or table.HasValue( GlorifiedBanking.Permissions[permission], ply:GetUserGroup() )
end

function GlorifiedBanking.RegisterPermission( permission, minAccess, usergroups, description )
    local permissionTable = {
        Name = permission,
        MinAccess = minAccess,
        Description = description
    }

    if CAMI then CAMI.RegisterPrivilege( permissionTable ) end
    permissionTable[Name] = nil
    permissionTable[Usergroups] = usergroups
    GlorifiedBanking.Permissions[permission] = permissionTable
end

GlorifiedBanking.RegisterPermission( "glorifiedbanking_openlogs", "admin", { "admin", "superadmin" }, "Determines whether or not the player can open the GlorifiedBanking logs panel." )