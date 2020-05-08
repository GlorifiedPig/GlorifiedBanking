
GlorifiedBanking.Config.SQL_TYPE = "mysqloo" -- 'sqlite' or 'mysqloo'
GlorifiedBanking.Config.SQL_DETAILS = {
    [ "host" ] = "localhost",
    [ "user" ] = "root",
    [ "pass" ] = "",
    [ "database" ] = "glorifiedbanking",
    [ "port" ] = 3306
}
GlorifiedBanking.Config.STARTING_BALANCE = 5000 -- How much money to start with in the player's bank account?

GlorifiedBanking.Config.INTEREST_ENABLED = true -- Should interest be enabled or not?
GlorifiedBanking.Config.INTEREST_TIMER = 20 -- How often should the player receive interest?
GlorifiedBanking.Config.INTEREST_MAX = 50000 -- What's the maximum amount a player can receive in interest?
GlorifiedBanking.Config.DEFAULT_INTEREST_PERCENTAGE = 0.1 -- What % should the player get for interest per x seconds?
GlorifiedBanking.Config.USERGROUP_SPECIFIC_INTERESTS = { -- What % should certain usergroups receive for interest?
    ["donator"] = 0.2,
    ["superadmin"] = 1
}

GlorifiedBanking.Config.SALARY_TO_BANK = true -- Should the player's salary get transferred to his bank account?