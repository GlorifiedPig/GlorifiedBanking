
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include( "shared.lua" )

util.AddNetworkString( "GlorifiedBanking_ToggleATMPanel" )

function ENT:Initialize()
	self:SetModel( "models/props/de_nuke/equipment1.mdl" )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	self:SetUseType( SIMPLE_USE )
 
    local phys = self:GetPhysicsObject()
	if ( phys:IsValid())  then
		phys:Wake()
	end
end
 
function ENT:Use( activator, caller, useType )
	if !self:IsValid() then return end
	net.Start( "GlorifiedBanking_ToggleATMPanel" )
	net.Send( activator )
end