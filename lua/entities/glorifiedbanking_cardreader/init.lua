
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
