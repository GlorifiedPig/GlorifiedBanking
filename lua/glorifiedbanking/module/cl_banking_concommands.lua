
local HasAdminAccess = false

local function requestAdminCommand()
    local ply = LocalPlayer()

    local canUseCommand, message = hook.Call( "glorifiedbanking.playerHasAdminPrivileges", nil, ply )

    if !canUseCommand then return print( message ) end

    CAMI.PlayerHasAccess( ply, glorifiedbanking.privilege.CAMI_CAN_USE_ADMIN_COMMANDS, function( hasAccess )
        if hasAccess then
            HasAdminAccess = true
        else
            HasAdminAccess = false
        end
    end )
end

concommand.Add( "glorifiedbanking_testaccess", function( ply )
    requestAdminCommand()
    
    print(HasAdminAccess)
end )