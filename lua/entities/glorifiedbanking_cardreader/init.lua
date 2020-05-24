
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
    self:SetModel("models/ogl/ogl_chip.mdl")
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self:SetUseType(SIMPLE_USE)

    local physObj = self:GetPhysicsObject()
    if (physObj:IsValid()) then
        physObj:Wake()
    end
end

--Merchant setter, use in a hook when buying entities if the merchant isn't setting
function ENT:SetMerchant(ply)
    if self.Setowning_ent then
        self:Setowning_ent(ply)
    end
    self:CPPISetOwner(ply)
end

--Transer money method, the main function of the card reader
function ENT:Transfer(sender)
    local merchant = self:GetMerchant()
    if not IsValid(merchant) then return end
    if sender == merchant then return end

    local amount = self:GetTransactionAmount(0)
    if amount <= 0 then
        GlorifiedBanking.Notify(sender, NOTIFY_ERROR, 5, i18n.GetPhrase("gbInvalidAmount"))
        return
    end

    local fee = math.Clamp(math.floor(amount / 100 * GlorifiedBanking.Config.CARD_PAYMENT_FEE), 0, amount)

    if not GlorifiedBanking.CanPlayerAfford(sender, amount) then
        GlorifiedBanking.Notify(sender, NOTIFY_ERROR, 5, i18n.GetPhrase( "gbCannotAfford"))
        return
    end

    GlorifiedBanking.RemovePlayerBalance(sender, fee)
    hook.Run("GlorifiedBanking.FeeTaken", sender, fee)

    self:SetScreenID(3)

    timer.Simple(3, function() --Wait while we contact the server
        if not IsValid(self) then return end

        self:SetTransactionAmount(0)
        self:SetScreenID(1)

        GlorifiedBanking.TransferAmount(sender, merchant, amount)
        GlorifiedBanking.Notify(sender, NOTIFY_GENERIC, 5, i18n.GetPhrase("gbPaidByCard", merchant:Name(), GlorifiedBanking.FormatMoney(amount)))
        GlorifiedBanking.Notify(merchant, NOTIFY_GENERIC, 5, i18n.GetPhrase("gbPaidByCardReceive", sender:Name(), GlorifiedBanking.FormatMoney(amount)))
    end)
end
