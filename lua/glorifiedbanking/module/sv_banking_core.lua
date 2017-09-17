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

for k, v in ipairs( NetStrings ) do
    util.AddNetworkString( v )
end

hook.Add( "PlayerInitialSpawn", "glorifiedBanking_Banking_InitialSpawnCheck", function( player )
    player.glorifiedBankingBalance = glorifiedBanking.config.DEFAULT_BANK_BALANCE

    glorifiedBanking.retrievePlayerBalance( player, function( balance )
        if IsValid( player ) then
            player.glorifiedBankingBalance = balance
        end
    end )
end )

local plyMeta = FindMetaTable( "Player" )

function plyMeta:GetBankBalance()
    return self.glorifiedBankingBalance or glorifiedBanking.config.DEFAULT_BANK_BALANCE
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

function plyMeta:SetBankBalance( balance )
    glorifiedBanking.storePlayerBalance( self, balance, function()
        self.glorifiedBankingBalance = balance
    end )
end

function plyMeta:AddBankBalance( amt )
    if self:CanAffordWalletAmount( amt ) and amt <= glorifiedBanking.config.MAX_DEPOSIT then
        self:addMoney( -amt )
        self:SetBankBalance( self:GetBankBalance() + amt )
    end
end

function plyMeta:RemoveBankBalance( amt )
    if self:CanAffordBankAmount( amt ) and amt <= glorifiedBanking.config.MAX_WITHDRAWAL then
        self:addMoney( amt )
        self:SetBankBalance( self:GetBankBalance() - amt )
    end
end

function plyMeta:ForceAddBankBalance( amt )
    self:SetBankBalance( self:GetBankBalance() + amt )
end

function plyMeta:ForceRemoveBankBalance( amt )
    self:SetBankBalance( self:GetBankBalance() - amt )
end

function plyMeta:TransferBankBalance( amt, player2 )
    if self:CanAffordBankAmount( amt ) and amt <= glorifiedBanking.config.MAX_TRANSFER then
        self:ForceRemoveBankBalance( amt )
        player2:ForceAddBankBalance( amt )
    end
end

