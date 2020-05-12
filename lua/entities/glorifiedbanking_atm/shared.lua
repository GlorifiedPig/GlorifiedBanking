
ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Glorified ATM"
ENT.Category = "GlorifiedBanking"
ENT.Author = "Tom.bat"
ENT.Spawnable = true
ENT.AdminOnly = true

ENT.WithdrawalFee = 0
ENT.DepositFee = 0
ENT.TransferFee = 0

function ENT:SetupDataTables()
    self:NetworkVar("Int", 0, "ScreenID")
    self:NetworkVar("Entity", 0, "CurrentUser")

    if SERVER then
        self:SetScreenID(1)
        self:SetCurrentUser(player.GetAll()[1]) --Temporairily set the current user to the first player on the server
    end
end
