
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

--[[ Other Options ]]--
    GlorifiedBanking.Config.LAST_ACTION_TIMEOUT = false -- How long should we wait after an action on the ATM before timing out the user? False to disable.
    GlorifiedBanking.Config.SALARY_TO_BANK = true -- Should the player's salary get transferred to his bank account?
    GlorifiedBanking.Config.STARTING_BALANCE = 5000 -- How much money to start with in the player's bank account?
    GlorifiedBanking.Config.DROP_MONEY_ON_DEATH = false -- Whether or not money should be dropped on death.
    GlorifiedBanking.Config.DROP_MONEY_ON_DEATH_AMOUNT = 500 -- If the above is set to true, how much should the player drop on death?
--[[ End Other Options ]]--

--[[ Permissions Settings ]]--
    GlorifiedBanking.Config.CAMI_PERMISSION_DEFAULTS = {
        ["glorifiedbanking_openadminpanel"] = {
            MinAccess = "admin",
            Description = "Determines whether or not the player can open the GlorifiedBanking admin panel."
        },
        ["glorifiedbanking_togglelockdown"] = {
            MinAccess = "admin",
            Description = "Permission for which usergroups are able to enable/disable lockdown mode."
        },
        ["glorifiedbanking_restorebackups"] = {
            MinAccess = "superadmin",
            Description = "Permission for which usergroups are able to restore to a previous backup."
        },
        ["glorifiedbanking_placeatms"] = {
            MinAccess = "superadmin",
            Description = "Permission to place and remove ATMs with the toolgun around the map."
        },
        ["glorifiedbanking_setplayerbalance"] = {
            MinAccess = "superadmin",
            Description = "Permission to set player's balances in the admin panel."
        },
    }
--[[ End Permissions Settings ]]--