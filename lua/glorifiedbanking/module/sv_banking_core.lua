--[[ VERY IMPORTANT NOTICE:
ONLY USE THESE FUNCTIONS ON SERVERSIDE FILES! YOU WILL FUCK EVERYTHING UP IF YOU DO THEM ON CLIENTSIDE FILES!  ]]--

local NetStrings = {
    -- updating bank balance
    "GlorifiedBanking_UpdateBankBalance",
    "GlorifiedBanking_UpdateBankBalanceReceive",

    -- update withdrawals
    "GlorifiedBanking_UpdateWithdrawal",

    -- info from deposit
    "GlorifiedBanking_IsAffordableDeposit",
    "GlorifiedBanking_UpdateDeposit",

    -- update a transfer
    "GlorifiedBanking_UpdateTransfer",

    -- send a notification to the client
    "GlorifiedBanking_Notification",

    -- administration netstrings
    "GlorifiedBanking_Admin_AddBankBalance",
    "GlorifiedBanking_Admin_RemoveBankBalance",
    "GlorifiedBanking_Admin_GetBankBalance",

    -- all "receive" netstrings
    "GlorifiedBanking_IsAffordableDepositReceive",
    "GlorifiedBanking_Admin_GetBankBalanceReceive"
}

for k, v in pairs( NetStrings ) do
    util.AddNetworkString( v )
end

hook.Add( "PlayerInitialSpawn", "GlorifiedBanking_Banking_InitialSpawnCheck", function( ply )
    if ply:GetPData( "GlorifiedBanking_BankBalance" ) == NIL or ply:GetPData( "GlorifiedBanking_BankBalance") == NULL then
        ply:SetPData( "GlorifiedBanking_BankBalance", 100 )
    end
end)

local plyMeta = FindMetaTable( "Player" )

function plyMeta:GetBankBalance()
    return tonumber( self:GetPData( "GlorifiedBanking_BankBalance" ) )
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
    if self:CanAffordWalletAmount( amt ) and amt <= glorifiedbanking.config.MAX_DEPOSIT then
        self:addMoney( -amt )
        self:SetPData( "GlorifiedBanking_BankBalance", self:GetBankBalance() + amt )
    end
end

function plyMeta:RemoveBankBalance( amt )
    if self:CanAffordBankAmount( amt ) and amt <= glorifiedbanking.config.MAX_WITHDRAWAL then
        self:addMoney( amt )
        self:SetPData( "GlorifiedBanking_BankBalance", self:GetPData( "GlorifiedBanking_BankBalance" ) - amt )
    end
end

function plyMeta:ForceAddBankBalance( amt )
    self:SetPData( "GlorifiedBanking_BankBalance", self:GetBankBalance() + amt )
end

function plyMeta:ForceRemoveBankBalance( amt )
    self:SetPData( "GlorifiedBanking_BankBalance", self:GetPData( "GlorifiedBanking_BankBalance" ) - amt )
end

function plyMeta:TransferBankBalance( amt, player2 )
    if self:CanAffordBankAmount( amt ) and amt <= glorifiedbanking.config.MAX_TRANSFER then
        self:ForceRemoveBankBalance( amt )
        player2:ForceAddBankBalance( amt )
    end
end

net.Receive( "GlorifiedBanking_UpdateBankBalance", function( len, ply )
    local bankBal = ply:GetBankBalance()

    net.Start( "GlorifiedBanking_UpdateBankBalanceReceive" )
    net.WriteUInt( bankBal, 32 )
    net.Send( ply )
end )

net.Receive( "GlorifiedBanking_IsAffordableDeposit", function( len, ply )
    local amount = net.ReadUInt( 32 )
    local canAffordW = ply:CanAffordWalletAmount( amount )

    net.Start( "GlorifiedBanking_IsAffordableDepositReceive" )
    net.WriteBool( canAffordW )
    net.Send( ply )
end )

net.Receive( "GlorifiedBanking_UpdateDeposit", function( len, ply )
    local amount = net.ReadUInt( 32 )

    ply:AddBankBalance( tonumber( amount ) )
end )

net.Receive( "GlorifiedBanking_UpdateWithdrawal", function( len, ply )
    local amount = net.ReadUInt( 32 )

    ply:RemoveBankBalance( amount )
end )

net.Receive( "GlorifiedBanking_UpdateTransfer", function( len, ply )
    local amount = net.ReadUInt( 32 )
    local player2 = net.ReadEntity()

    net.Start( "GlorifiedBanking_Notification" )
    net.WriteString( "You have received " .. DarkRP.formatMoney( amount ) .. " from " .. ply:Nick()  .. "." )
    net.WriteBool( false )
    net.Send( player2 )

    ply:TransferBankBalance( tonumber( amount ), player2 )
end )

net.Receive( "GlorifiedBanking_Admin_AddBankBalance", function( len, ply )
    local amount = net.ReadUInt( 32 )
    local player2 = net.ReadEntity()

    net.Start( "GlorifiedBanking_Notification" )
    net.WriteString( "You have given " .. DarkRP.formatMoney( amount ) .. " to " .. player2:Nick()  .. "." )
    net.WriteBool( false )
    net.Send( ply )

    net.Start( "GlorifiedBanking_Notification" )
    net.WriteString( "You have been given " .. DarkRP.formatMoney( amount ) .. " from administrator " .. ply:Nick()  .. "." )
    net.WriteBool( false )
    net.Send( player2 )

    player2:ForceAddBankBalance( amount )
end )

net.Receive( "GlorifiedBanking_Admin_RemoveBankBalance", function( len, ply )
    local amount = net.ReadUInt( 32 )
    local player2 = net.ReadEntity()

    net.Start( "GlorifiedBanking_Notification" )
    net.WriteString( "You have removed " .. DarkRP.formatMoney( amount ) .. " from " .. player2:Nick()  .. "'s account." )
    net.WriteBool( false )
    net.Send( ply )

    net.Start( "GlorifiedBanking_Notification" )
    net.WriteString( DarkRP.formatMoney( amount ) .. " has been removed from your account by administrator " .. ply:Nick()  .. "." )
    net.WriteBool( true )
    net.Send( player2 )

    player2:ForceRemoveBankBalance( amount )
end )

net.Receive( "GlorifiedBanking_Admin_GetBankBalance", function( len, ply )
    local player2 = net.ReadEntity()

    net.Start( "GlorifiedBanking_Admin_GetBankBalanceReceive" )
    net.WriteUInt( player2:GetBankBalance(), 32 )
    net.Send( ply )
end )