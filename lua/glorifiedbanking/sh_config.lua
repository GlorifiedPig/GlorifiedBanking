
--[[ MAIN CONFIGURATION --]]
    glorifiedBanking.config.CONFIGURER_CONFIG_ENABLED = true -- [Temporarily Disabled] If this is enabled, you use the in-game configurer. Changing the configs below will be pointless.

    glorifiedBanking.config.MAX_WITHDRAWAL = 100000 -- The maximum amount you can withdraw.
    glorifiedBanking.config.MAX_DEPOSIT = 100000 -- The maximum amount you can deposit.
    glorifiedBanking.config.MAX_TRANSFER = 100000 -- The maximum amount you can transfer.

    glorifiedBanking.config.SALARY_TO_BANK = true -- Whether or not your salary should go to your bank instead of wallet.

--[[ INTEREST CONFIGURATION ]]--
    glorifiedBanking.config.INTEREST_ENABLED = true -- Whether or not to enable the interest system.
    glorifiedBanking.config.INTEREST_TIMER = 15 -- The amount of time in minutes where interest is given.
    glorifiedBanking.config.INTEREST_AMOUNT = 0.1 -- The PERCENTAGE amount your balance increases. Defaults to 0.1% (1/1000).
    glorifiedBanking.config.MAX_INTEREST_AMOUNT = 10000 -- The maximum amount you can get per interest increase.

--[[ 3D2D CONFIGURATION ]]--
    glorifiedBanking.config.ATM_3D2D_COLOUR = Color( 0, 155, 0, 255 ) -- The 3D2D Colour of the "ATM Machine" text.
    glorifiedBanking.config.ATM_3D2D_COLOUR_DOLLAR = Color( 0, 255, 0, 255 ) -- The 3D2D Colour of the rotating dollar on top of the ATM.

    glorifiedBanking.config.ATM_3D2D_ROTATION_SPEED = 0 -- The rotation speed of the floating dollar sign.

--[[ DERMA CONFIGURATION ]]--
    glorifiedBanking.config.DERMA_BACKGROUND_COLOR = Color( 255, 255, 255, 255 ) -- The default colour of the background on the Derma menu.
    glorifiedBanking.config.DEMA_BACKGROUND_SECONDARY_COLOR = Color( 0, 190, 255 ) -- The top colour of the Derma menu.
    glorifiedBanking.config.DERMA_BACKGROUND_COLOR_SUBSECTION = Color( 255, 255, 255, 255 ) -- The default colour on the Withdrawal, Deposit and Transfer section.
    glorifiedBanking.config.DERMA_BUTTON_COLOUR = Color( 185, 185, 185, 35 ) -- The default button colours of the ATM menu. We suggest you keep the alpha value as low as possible.
    glorifiedBanking.config.DERMA_ONCLICK_COLOUR = Color( 55, 55, 55 ) -- The colour that is lerped to when the button is clicked.
    glorifiedBanking.config.DERMA_CLOSE_BUTTON_COLOR = Color( 255, 0, 0 ) -- The close button colour.

--[[ ADMINISTRATION CONFIGURATION ]]--
    glorifiedBanking.config.ADMIN_INHERIT_MINIMUM = "superadmin" -- The minimum rank requirement (inherits from "x") to be able to use administrative commands.
    glorifiedBanking.config.ADMIN_USERGROUPS = {
        -- All the usergroups that are able to use administrative commands. Group must inherit from 'superadmin'
        "superadmin",
        "owner"
    }

--[[ MYSQL CONFIGURATION ]]--
    glorifiedBanking.config.MYSQL_ENABLE = false -- Whether or not to enable MySQL. Please be sure you have the libmysql.dll and MySQLOO installed.

    glorifiedBanking.config.MYSQL_DATABASE_HOST = "127.0.0.1"
    glorifiedBanking.config.MYSQL_DATABASE_USERNAME = "root"
    glorifiedBanking.config.MYSQL_DATABASE_PASSWORD = ""
    glorifiedBanking.config.MYSQL_DATABASE_NAME = "glorifiedBankingDatabase"
    glorifiedBanking.config.MYSQL_DATABASE_PORT = 3306
