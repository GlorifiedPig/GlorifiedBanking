--[[ Important Notice:
Only use the following functions serverside. If you need to do it clientside, please make sure to use a Net Message with UInts instead
of regular Ints. Also be sure that it is not exploitable.]]--

local NetStrings = {
    -- updating bank balance
    "glorifiedBanking_UpdateBankBalance",
    "glorifiedBanking_UpdateBankBalanceReceive",

    -- update withdrawals
    "glorifiedBanking_UpdateWithdrawal",

    -- info from deposit
    "glorifiedBanking_IsAffordableDeposit",
    "glorifiedBanking_UpdateDeposit",

    -- update a transfer
    "glorifiedBanking_UpdateTransfer",

    -- send a notification to the client
    "glorifiedBanking_Notification",

    -- administration netstrings
    "glorifiedBanking_Admin_AddBankBalance",
    "glorifiedBanking_Admin_RemoveBankBalance",
    "glorifiedBanking_Admin_GetBankBalance",

    -- all "receive" netstrings
    "glorifiedBanking_IsAffordableDepositReceive",
    "glorifiedBanking_Admin_GetBankBalanceReceive"
}

for k, v in pairs( NetStrings ) do
    util.AddNetworkString( v )
end

hook.Add( "PlayerInitialSpawn", "glorifiedBanking_Banking_InitialSpawnCheck", function( ply )
    if ply:GetPData( "glorifiedBanking_BankBalance" ) == NIL or ply:GetPData( "glorifiedBanking_BankBalance") == NULL then
        ply:SetPData( "glorifiedBanking_BankBalance", 100 )
    end
end)

local plyMeta = FindMetaTable( "Player" )

function plyMeta:GetBankBalance()
    return tonumber( self:GetPData( "glorifiedBanking_BankBalance" ) )
end

function plyMeta:CanAffordBankAmount( amt )
    local bankAmount = self:GetBankBalance()

    if bankAmount >= amt then
        return true
    else
        return false
    end
end

function plyMeta:CanAffordWalletAmount( amt )
    return self:canAfford( amt )
end

function plyMeta:AddBankBalance( amt )
    if self:CanAffordWalletAmount( amt ) and amt <= glorifiedBanking.config.MAX_DEPOSIT then
        self:addMoney( -amt )
        self:SetPData( "glorifiedBanking_BankBalance", self:GetBankBalance() + amt )
    end
end

function plyMeta:RemoveBankBalance( amt )
    if self:CanAffordBankAmount( amt ) and amt <= glorifiedBanking.config.MAX_WITHDRAWAL then
        self:addMoney( amt )
        self:SetPData( "glorifiedBanking_BankBalance", self:GetPData( "glorifiedBanking_BankBalance" ) - amt )
    end
end

function plyMeta:ForceAddBankBalance( amt )
    self:SetPData( "glorifiedBanking_BankBalance", self:GetBankBalance() + amt )
end

function plyMeta:ForceRemoveBankBalance( amt )
    self:SetPData( "glorifiedBanking_BankBalance", self:GetPData( "glorifiedBanking_BankBalance" ) - amt )
end

function plyMeta:TransferBankBalance( amt, player2 )
    if self:CanAffordBankAmount( amt ) and amt <= glorifiedBanking.config.MAX_TRANSFER then
        self:ForceRemoveBankBalance( amt )
        player2:ForceAddBankBalance( amt )
    end
end

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
