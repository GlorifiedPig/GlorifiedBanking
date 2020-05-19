
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
    self:SetModel("models/props_lab/huladoll.mdl")
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

    GlorifiedBanking.Notify(sender, NOTIFY_GENERIC, 5, i18n.GetPhrase("gbPaidByCard", receiver:Name(), GlorifiedBanking.FormatMoney(amount)))
    GlorifiedBanking.Notify(merchant, NOTIFY_GENERIC, 5, i18n.GetPhrase("gbPaidByCardReceive", sender:Name(), GlorifiedBanking.FormatMoney(amount)))

    GlorifiedBanking.TransferAmount(sender, merchant, amount)
end
