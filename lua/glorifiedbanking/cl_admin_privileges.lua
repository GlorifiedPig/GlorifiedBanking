
hook.Add( "glorifiedbanking.playerHasAdminPrivileges", "glorifiedbanking", function( ply )

    print(ply:GetUserGroup())

    if !glorifiedbanking.config.ADMIN_USERGROUPS[ ply:GetUserGroup() ] then
        return true
    else
        return false, "You need to be a higher rank to do that!"
    end

end )