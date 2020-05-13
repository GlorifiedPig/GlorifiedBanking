
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

function ENT:InsertCard(ply)
    self:SetCurrentUser(ply)
    self:SetScreenID(3)
    ply:StripWeapon("glorifiedbanking_card")

    net.Start( "GlorifiedBanking.SendAnimation" )
     net.WriteEntity(self)
     net.WriteUInt(GB_ANIM_CARD_IN, 3)
    net.SendPVS(self:GetPos())
end

function ENT:RemoveCard()
    local ply = self:GetCurrentUser()
    if IsValid(ply) then
        ply:Give("glorifiedbanking_card")
    end

    self:SetCurrentUser(NULL)
    self:SetScreenID(1)

    net.Start( "GlorifiedBanking.SendAnimation" )
     net.WriteEntity(self)
     net.WriteUInt(GB_ANIM_CARD_OUT, 3)
    net.SendPVS(self:GetPos())
end
