
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include( "shared.lua" )

util.AddNetworkString( "glorifiedBanking_ToggleATMPanel" )

function ENT:Initialize()
	self:SetModel( "models/atm.mdl" )
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

	net.Start( "glorifiedBanking_ToggleATMPanel" )
	net.WriteEntity( self )
	net.Send( activator )
end
