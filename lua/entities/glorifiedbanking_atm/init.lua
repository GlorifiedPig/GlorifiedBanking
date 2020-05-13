
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

local GB_ANIM_IDLE = 0
local GB_ANIM_MONEY_IN = 1
local GB_ANIM_MONEY_OUT = 2
local GB_ANIM_CARD_IN = 3
local GB_ANIM_CARD_OUT = 4

function ENT:Initialize()
    self:SetModel("models/ogl/ogl_main_atm.mdl")
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)

    local physObj = self:GetPhysicsObject()
    if (physObj:IsValid()) then
        physObj:Wake()
    end
end

function ENT:Think()
    local user = self:GetCurrentUser()
    if user == NULL then return end

    local maxDistance = GlorifiedBanking.Config.MAXIMUM_DISTANCE_FROM_ATM
    if self:GetPos():DistToSqr(user:GetPos()) > maxDistance * maxDistance then
        self:Logout()
    end
end

function ENT:InsertCard(ply)
    self:SetCurrentUser(ply)

    ply:StripWeapon("glorifiedbanking_card")

    net.Start("GlorifiedBanking.SendAnimation")
     net.WriteEntity(self)
     net.WriteUInt(GB_ANIM_CARD_IN, 3)
    net.SendPVS(self:GetPos())

    timer.Simple(1.5, function()
        self:SetScreenID(3)
    end)
end

function ENT:Logout()
    self:SetScreenID(1)

    net.Start("GlorifiedBanking.SendAnimation")
     net.WriteEntity(self)
     net.WriteUInt(GB_ANIM_CARD_OUT, 3)
    net.SendPVS(self:GetPos())

    timer.Simple(1.5, function()
        local ply = self:GetCurrentUser()
        if IsValid(ply) then ply:Give("glorifiedbanking_card") end

        self:SetCurrentUser(NULL)

        net.Start("GlorifiedBanking.SendAnimation")
         net.WriteEntity(self)
         net.WriteUInt(GB_ANIM_IDLE, 3)
        net.SendPVS(self:GetPos())
    end)
end

hook.Add("PlayerDisconnected", "GlorifiedBanking.ATMEntity.PlayerDisconnected", function(ply)
    for k,v in ipairs(ents.FindByClass("glorifiedbanking_atm")) do
        if ply != v:GetCurrentUser() then continue end
        v:Logout()
        break
    end
end)
