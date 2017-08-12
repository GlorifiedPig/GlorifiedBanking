
hook.Add( "glorifiedbanking.playerHasAdminPrivileges", "glorifiedbanking", function( ply )

    if !ply:IsPlayer() or ply == nil then return end
    if ply:GetUsergroup() == nil then return end

    if !glorifiedbanking.config.ADMIN_USERGROUPS[ ply:GetUserGroup() ] then
        return true
    else
        return false, "You need to be a higher rank to do that!"
    end

end )