
GlorifiedBanking.LockdownEnabled = false

function GlorifiedBanking.ToggleLockdown()
    GlorifiedBanking.LockdownEnabled = !GlorifiedBanking.LockdownEnabled
end

function GlorifiedBanking.SetLockdownStatus( lockdownStatus )
    GlorifiedBanking.LockdownEnabled = lockdownStatus
end