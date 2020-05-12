
--[[ SQL Configuration ]]--
    GlorifiedBanking.Config.SQL_TYPE = "mysqloo" -- 'sqlite' or 'mysqloo'
    GlorifiedBanking.Config.SQL_DETAILS = {
        [ "host" ] = "localhost",
        [ "user" ] = "root",
        [ "pass" ] = "",
        [ "database" ] = "glorifiedbanking",
        [ "port" ] = 3306
    }
--[[ End SQL Configuration ]]--

--[[ Backup System Configuration ]]--
    GlorifiedBanking.Config.BACKUPS_ENABLED = true -- Should the backup system be enabled?
    GlorifiedBanking.Config.BACKUP_FREQUENCY = 1 -- How often should backups occur in hours?
    GlorifiedBanking.Config.MAX_BACKUPS = 10 -- What are the maximum amount of backups allowed before old ones start getting deleted?
    GlorifiedBanking.Config.BACKUPS_FOLDER_NAME = "glorifiedbanking_backups" -- What should the file name in the data folder be?
--[[ End Backup System Configuration ]]--