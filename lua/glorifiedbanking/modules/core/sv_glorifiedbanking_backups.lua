
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
    GlorifiedBanking.SQL.Query( "SELECT * FROM `gb_players`", function( queryResult )
        if not queryResult then return end
        cookie.Set( "GlorifiedBanking.LastBackup", os.time() )
        GlorifiedBanking.LastBackup = os.time()
        file.Write( GlorifiedBanking.Config.BACKUPS_FOLDER_NAME .. "/gb_backup_" .. os.time() .. ".txt", util.Compress( util.TableToJSON( queryResult ) ) )
        DeleteOldBackups()
    end )
end

function GlorifiedBanking.ReadBackupFile( fileTime )
    local readFile = file.Read( GlorifiedBanking.Config.BACKUPS_FOLDER_NAME .. "/gb_backup_" .. fileTime .. ".txt" )
    if readFile then
        readFile = util.Decompress( readFile )
        readFile = util.JSONToTable( readFile )
    end
    return readFile
end

function GlorifiedBanking.LoadBackupFile( fileTime )
    local readFile = GlorifiedBanking.ReadBackupFile( fileTime )
    if readFile then
        GlorifiedBanking.SQL.Query( "DELETE FROM `gb_players`", function()
            for k, v in pairs( readFile ) do
                GlorifiedBanking.SQL.Query( "INSERT INTO `gb_players`( `SteamID`, `Balance` ) VALUES ( '" .. v["SteamID"] .. "', " .. v["Balance"] .. " ) ")
            end
            print( "[GlorifiedBanking] Loaded backup number " .. fileTime .. "." )
        end )
    end
end

hook.Add( "InitPostEntity", "GlorifiedBanking.Backups.InitPostEntity", function()
    timer.Create( "GlorifiedBanking.BackupEnsureTimer", 60, 0, function()
        -- Multiply by 3600 so that we can convert hours to seconds.
        if os.time() >= GlorifiedBanking.LastBackup + ( GlorifiedBanking.Config.BACKUP_FREQUENCY * 3600 ) then
            GlorifiedBanking.CreateNewBackupFile()
        end
    end )
end )