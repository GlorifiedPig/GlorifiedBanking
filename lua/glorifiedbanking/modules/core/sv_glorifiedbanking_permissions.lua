
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

local logsPermDefaults = GlorifiedBanking.Config.PERMISSION_DEFAULTS["glorifiedbanking_openlogs"]
GlorifiedBanking.RegisterPermission( "glorifiedbanking_openlogs", logsPermDefaults["minAccess"], logsPermDefaults["usergroups"], logsPermDefaults["description"] )