
hook.Add( "glorifiedBanking.playerHasAdminPrivileges", "glorifiedBanking", function( ply )

    if !ply:IsPlayer() or ply == nil then return end
    if ply:GetUsergroup() == nil then return end

    if !glorifiedBanking.config.ADMIN_USERGROUPS[ ply:GetUserGroup() ] then
        return true
    else
        return false, "You need to be a higher rank to do that!"
    end

end )
