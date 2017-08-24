
glorifiedBanking.config.CONFIGURER_CONFIG_ENABLED = true -- [Temporarily Disabled] If this is enabled, you use the in-game configurer. Changing the configs below will be pointless.

glorifiedBanking.config.MAX_WITHDRAWAL = 100000 -- The maximum amount you can withdraw.
glorifiedBanking.config.MAX_DEPOSIT = 100000 -- The maximum amount you can deposit.
glorifiedBanking.config.MAX_TRANSFER = 100000 -- The maximum amount you can transfer.

glorifiedBanking.config.ATM_3D2D_COLOUR = Color( 0, 155, 0, 255 ) -- The 3D2D Colour of the "ATM Machine" text.
glorifiedBanking.config.ATM_3D2D_COLOUR_DOLLAR = Color( 0, 255, 0, 255 ) -- The 3D2D Colour of the rotating dollar on top of the ATM.

glorifiedBanking.config.ATM_3D2D_ROTATION_SPEED = 0 -- The rotation speed of the floating dollar sign.

glorifiedBanking.config.DERMA_BACKGROUND_COLOR = Color( 0, 0, 0, 150 ) -- The default colour of the background on the Derma menu.
glorifiedBanking.config.DERMA_BACKGROUND_COLOR_SUBSECTION = Color( 35, 35, 35, 255 ) -- The default colour on the Withdrawal, Deposit and Transfer section.
glorifiedBanking.config.DERMA_BUTTON_COLOUR = Color( 155, 155, 155, 35 ) -- The default button colours of the ATM menu. We suggest you keep the alpha value as low as possible.

glorifiedBanking.config.DERMA_ONCLICK_COLOUR = Color( 55, 55, 255 ) -- The colour that is lerped to when the button is clicked.

glorifiedBanking.config.ADMIN_INHERIT_MINIMUM = "superadmin" -- The minimum rank requirement (inherits from "x") to be able to use administrative commands.

-- All the usergroups that are able to use administrative commands. Group must inherit from 'superadmin'
glorifiedBanking.config.ADMIN_USERGROUPS = {
    "superadmin",
    "owner"
}
