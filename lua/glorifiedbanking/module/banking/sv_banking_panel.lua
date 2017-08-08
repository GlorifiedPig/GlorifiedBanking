--[[ VERY IMPORTANT NOTICE:
ONLY USE THESE FUNCTIONS ON SERVERSIDE FILES! YOU WILL FUCK EVERYTHING UP IF YOU DO THEM ON CLIENTSIDE FILES!  ]]--

util.AddNetworkString( "GlorifiedBanking_UpdateBankBalance" )
util.AddNetworkString( "GlorifiedBanking_UpdateBankBalanceReceive" )
util.AddNetworkString( "GlorifiedBanking_IsAffordableWithdraw" )
util.AddNetworkString( "GlorifiedBanking_IsAffordableWithdrawReceive" )
util.AddNetworkString( "GlorifiedBanking_UpdateWithdrawal" )
util.AddNetworkString( "GlorifiedBanking_IsAffordableDeposit" )
util.AddNetworkString( "GlorifiedBanking_IsAffordableDepositReceive" )
util.AddNetworkString( "GlorifiedBanking_UpdateDeposit" )

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
    if self:CanAffordWalletAmount( amt ) and amt <= 100000 then
        self:addMoney( -amt )
        self:SetPData( "GlorifiedBanking_BankBalance", self:GetBankBalance() + amt )
    end
end

function plyMeta:RemoveBankBalance( amt )
    if self:CanAffordBankAmount( amt ) and amt <= 100000 then
        self:addMoney( amt )
        self:SetPData( "GlorifiedBanking_BankBalance", self:GetPData( "GlorifiedBanking_BankBalance" ) - amt )
    end
end

function plyMeta:ForceAddMoneyBank( amt )
    self:SetPData( "GlorifiedBanking_BankBalance", self:GetBankBalance() + amt )
end

net.Receive( "GlorifiedBanking_UpdateBankBalance", function( len, ply )
    local bankBal = ply:GetBankBalance()

    net.Start( "GlorifiedBanking_UpdateBankBalanceReceive" )
    net.WriteInt( bankBal, 32 )
    net.Send( ply )
end )

net.Receive( "GlorifiedBanking_IsAffordableWithdraw", function( len, ply )
    local amount = net.ReadInt( 32 )
    local canAffordB = ply:CanAffordBankAmount( amount )

    net.Start( "GlorifiedBanking_IsAffordableWithdrawReceive" )
    net.WriteBool( canAffordB )
    net.Send( ply )
end )

net.Receive( "GlorifiedBanking_UpdateWithdrawal", function( len, ply )
    local amount = net.ReadInt( 32 )

    ply:RemoveBankBalance( amount )
end )

net.Receive( "GlorifiedBanking_IsAffordableDeposit", function( len, ply )
    local amount = net.ReadInt( 32 )
    local canAffordW = ply:CanAffordWalletAmount( amount )

    net.Start( "GlorifiedBanking_IsAffordableDepositReceive" )
    net.WriteBool( canAffordW )
    net.Send( ply )
end )

net.Receive( "GlorifiedBanking_UpdateDeposit", function( len, ply )
    local amount = net.ReadInt( 32 )

    ply:AddBankBalance( tonumber( amount ) )
end )