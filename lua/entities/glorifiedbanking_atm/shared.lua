ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Glorified ATM"
ENT.Category = "GlorifiedBanking"
ENT.Author = "Tom.bat"
ENT.Spawnable = true
ENT.AdminOnly = true

function ENT:SetupDataTables()
    self:NetworkVar("Int", 0, "ScreenID")

    if SERVER then
        self:SetScreenID(0)
    end
end