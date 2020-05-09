
GlorifiedBanking.LastBackup = cookie.GetNumber( "GlorifiedBanking.LastBackup", os.time() )

local function EnsureBackupDirectories()
    if not file.Exists( GlorifiedBanking.Config.BACKUPS_FOLDER_NAME, "DATA" ) then
        file.CreateDir( GlorifiedBanking.Config.BACKUPS_FOLDER_NAME )
    end
end

local function DeleteOldBackups()
    EnsureBackupDirectories()
    local fileTbl = file.Find( GlorifiedBanking.Config.BACKUPS_FOLDER_NAME .. "/*.txt", "DATA", "dateasc" )
    local fileCount = table.Count( fileTbl )
    if fileCount <= GlorifiedBanking.Config.MAX_BACKUPS then return end
    local deleteCount = fileCount - GlorifiedBanking.Config.MAX_BACKUPS
    for i = 1, deleteCount do
        file.Delete( GlorifiedBanking.Config.BACKUPS_FOLDER_NAME .. "/" .. fileTbl[i] )
    end
end

function GlorifiedBanking.CreateNewBackupFile()
    EnsureBackupDirectories()
    GlorifiedBanking.SQLQuery( "SELECT * FROM `gb_players`", function( queryResult )
        if not queryResult then return end
        cookie.Set( "GlorifiedBanking.LastBackup", os.time() )
        GlorifiedBanking.LastBackup = os.time()
        file.Write( GlorifiedBanking.Config.BACKUPS_FOLDER_NAME .. "/gb_backup_" .. os.time() .. ".txt", util.Compress( util.TableToJSON( queryResult ) ) )
        DeleteOldBackups()
    end )
end

hook.Add( "InitPostEntity", "GlorifiedBanking.Backups.InitPostEntity", function()
    timer.Create( "GlorifiedBanking.BackupEnsureTimer", 60, 0, function()
        -- Multiply by 3600 so that we can convert hours to seconds.
        if os.time() >= GlorifiedBanking.LastBackup + ( GlorifiedBanking.Config.BACKUP_FREQUENCY * 3600 ) then
            GlorifiedBanking.CreateNewBackupFile()
        end
    end )
end )