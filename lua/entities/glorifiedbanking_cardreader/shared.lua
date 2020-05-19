
ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Glorified Card Reader"
ENT.Category = "GlorifiedBanking"
ENT.Author = "Tom.bat"
ENT.Spawnable = true
ENT.AdminOnly = true

--Set up the network vars
function ENT:SetupDataTables()
    self:NetworkVar("Int", 0, "TransactionAmount")

    if SERVER then
        self:SetTransactionAmount(0)
    end
end

--Use entity ownership to get the merchant user
function ENT:GetMerchant()
    local owner = self.Getowning_ent and self:Getowning_ent()
    if owner then return end

    owner = self:CPPIGetOwner()
end
