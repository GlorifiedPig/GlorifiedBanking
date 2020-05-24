
ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Glorified Card Reader"
ENT.Category = "GlorifiedBanking"
ENT.Author = "Tom.bat"
ENT.Spawnable = true
ENT.AdminOnly = true

--Set up the network vars
function ENT:SetupDataTables()
    self:NetworkVar("Int", 0, "ScreenID")
    self:NetworkVar("Int", 1, "TransactionAmount")

    if SERVER then
        self:SetScreenID(1)
        self:SetTransactionAmount(0)
    end
end

--Use entity ownership to get the merchant user
function ENT:GetMerchant()
    local owner = self:CPPIGetOwner()
    if owner then return owner end

    return self.Getowning_ent and self:Getowning_ent()
end

--Define all of our possible screens
ENT.Screens = {
    [1] = {}, --Amount entry screen
    [2] = {}, --Payment screen
    [3] = {} --Loading screen
}
