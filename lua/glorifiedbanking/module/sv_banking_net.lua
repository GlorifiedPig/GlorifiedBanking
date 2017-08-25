
net.Receive( "glorifiedBanking_UpdateBankBalance", function( len, ply )
    local bankBal = ply:GetBankBalance()

    net.Start( "glorifiedBanking_UpdateBankBalanceReceive" )
    net.WriteUInt( bankBal, 32 )
    net.Send( ply )
end )

net.Receive( "glorifiedBanking_IsAffordableDeposit", function( len, ply )
    local amount = net.ReadUInt( 32 )
    local canAffordW = ply:CanAffordWalletAmount( amount )

    net.Start( "glorifiedBanking_IsAffordableDepositReceive" )
    net.WriteBool( canAffordW )
    net.Send( ply )
end )

net.Receive( "glorifiedBanking_UpdateDeposit", function( len, ply )
    local amount = net.ReadUInt( 32 )

    ply:AddBankBalance( tonumber( amount ) )
end )

net.Receive( "glorifiedBanking_UpdateWithdrawal", function( len, ply )
    local amount = net.ReadUInt( 32 )

    ply:RemoveBankBalance( amount )
end )

net.Receive( "glorifiedBanking_UpdateTransfer", function( len, ply )
    local amount = tonumber( math.abs( net.ReadInt( 32 ) ) )
    local player2 = net.ReadEntity()

    if !ply:CanAffordBankAmount(amount) then return end

    net.Start( "glorifiedBanking_Notification" )
    net.WriteString( glorifiedBanking.getPhrase( "receivedMoney", DarkRP.formatMoney( amount ), ply:Nick() ) )
    net.WriteBool( false )
    net.Send( player2 )

    ply:TransferBankBalance( tonumber( amount ), player2 )
end )

net.Receive( "glorifiedBanking_Admin_AddBankBalance", function( len, ply )
    local amount = net.ReadUInt( 32 )
    local player2 = net.ReadEntity()

    if !ply:IsAdmin() then return end -- Temporary admin check to fix network exploits

    net.Start( "glorifiedBanking_Notification" )
    net.WriteString( glorifiedBanking.getPhrase("givenMoney", DarkRP.formatMoney(amount), player2:Nick()))
    net.WriteBool( false )
    net.Send( ply )

    net.Start( "glorifiedBanking_Notification" )
    net.WriteString( glorifiedBanking.getPhrase( "givenFromAdmin", DarkRP.formatMoney( amount ), ply:Nick() ) )
    net.WriteBool( false )
    net.Send( player2 )

    player2:ForceAddBankBalance( amount )
end )

net.Receive( "glorifiedBanking_Admin_RemoveBankBalance", function( len, ply )
    local amount = net.ReadUInt( 32 )
    local player2 = net.ReadEntity()

    if !ply:IsAdmin() then return end -- Temporary admin check to fix network exploits

    net.Start( "glorifiedBanking_Notification" )
    net.WriteString( glorifiedBanking.getPhrase("removedMoney", DarkRP.formatMoney(amount), player2:Nick()))
    net.WriteBool( false )
    net.Send( ply )

    net.Start( "glorifiedBanking_Notification" )
    net.WriteString(glorifiedBanking.getPhrase("removedFromAdmin", DarkRP.formatMoney( amount ), ply:Nick()))
    net.WriteBool( true )
    net.Send( player2 )

    player2:ForceRemoveBankBalance( amount )
end )

net.Receive( "glorifiedBanking_Admin_GetBankBalance", function( len, ply )
    local player2 = net.ReadEntity()

    if !ply:IsAdmin() then return end -- Temporary admin check to fix network exploits

    net.Start( "glorifiedBanking_Admin_GetBankBalanceReceive" )
    net.WriteUInt( player2:GetBankBalance(), 32 )
    net.Send( ply )
end )
