
if not GlorifiedBanking.Config.SUPPORT_BLOGS then return end

local WITHDRAWAL_MODULE = GAS.Logging:MODULE()

WITHDRAWAL_MODULE.Category = "GlorifiedBanking"
WITHDRAWAL_MODULE.Name = "Withdrawals"
WITHDRAWAL_MODULE.Color = Color( 0, 255, 0 )

WITHDRAWAL_MODULE:SETUP( function()
    WITHDRAWAL_MODULE:Hook( "GlorifiedBanking.PlayerWithdrawal", "withdrawal", function( ply, withdrawalAmount )
        WITHDRAWAL_MODULE:LogPhrase( "player_withdrawal", GAS.Logging:FormatPlayer( ply ), GAS.Logging:Highlight( "Withdrew " .. DarkRP.formatMoney( withdrawalAmount ) ) )
    end )
end )

GAS.Logging:AddModule( WITHDRAWAL_MODULE )

local DEPOSIT_MODULE = GAS.Logging:MODULE()

DEPOSIT_MODULE.Category = "GlorifiedBanking"
DEPOSIT_MODULE.Name = "Deposits"
DEPOSIT_MODULE.Color = Color( 255, 0, 0 )

DEPOSIT_MODULE:SETUP( function()
    DEPOSIT_MODULE:Hook( "GlorifiedBanking.PlayerDeposit", "deposit", function( ply, depositAmount )
        DEPOSIT_MODULE:LogPhrase( "player_deposited", GAS.Logging:FormatPlayer( ply ), GAS.Logging:Highlight( "Deposited " .. DarkRP.formatMoney( depositAmount ) ) )
    end )
end )

GAS.Logging:AddModule( DEPOSIT_MODULE )

local TRANSFER_MODULE = GAS.Logging:MODULE()

TRANSFER_MODULE.Category = "GlorifiedBanking"
TRANSFER_MODULE.Name = "Transfers"
TRANSFER_MODULE.Color = Color( 0, 0, 255 )

TRANSFER_MODULE:SETUP( function()
    TRANSFER_MODULE:Hook( "GlorifiedBanking.PlayerTransfer", "transfer", function( ply, receiver, transferAmount )
        TRANSFER_MODULE:LogPhrase( "player_transferred", GAS.Logging:FormatPlayer( ply ), GAS.Logging:Highlight( "Transferred " .. DarkRP.formatMoney( transferAmount ) .. " to " .. GAS.Logging:FormatPlayer( receiver ) ) )
    end )
end )

GAS.Logging:AddModule( TRANSFER_MODULE )