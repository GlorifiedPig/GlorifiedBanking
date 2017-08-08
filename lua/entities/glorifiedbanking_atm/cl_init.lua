
include( "shared.lua" )

function ENT:Draw()
    self:DrawModel()
	
	-- First 3D2D ("ATM Machine" text)
	local Pos = self:GetPos()
    local Angles = self:GetAngles()
	local Ang = Angle( -Angles.r, Angles.y + 90, Angles.p )

	Ang:RotateAroundAxis( Ang:Forward(), 90 )
	Ang:RotateAroundAxis( Ang:Right(), 270 )

	cam.Start3D2D( Pos + Ang:Up() * 7.8 + Ang:Forward() * -12.5 + Ang:Right() * -59, Ang, 0.23 )
		draw.WordBox( 0, 0, 0, "ATM Machine", "Trebuchet24", Color( 55, 55, 55, 155 ), Color( 0, 155, 0, 255 ) )
	cam.End3D2D()

	-- Second 3D2D (Floating Dollar Sign)
	self.lastTime = self.lastTime or 0
	self.rotate = self.rotate or 270
	
	self.rotate = self.rotate - ( 50 * ( self.lastTime - SysTime() ) )
	self.lastTime = SysTime()

	local Pos2 = self:GetPos()
	local Angles2 = self:GetAngles()
	local Ang2 = Angle( -Angles2.r, Angles.y + 90, Angles2.p )
	local Ang3 = Angle( -Angles2.r, Angles.y - 90, Angles2.p )

	Ang2:RotateAroundAxis( Ang2:Forward(), 90 )
	Ang2:RotateAroundAxis( Ang2:Right(), self.rotate )

	Ang3:RotateAroundAxis( Ang3:Forward(), 90 )
	Ang3:RotateAroundAxis( Ang3:Right(), self.rotate )

	cam.Start3D2D( Pos2 + Ang2:Up() + Ang2:Forward() * -5 + Ang2:Right() * -117, Ang2, 1 )
		draw.SimpleText( "$", "Trebuchet24", 0, 0, Color( 0, 255, 0, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
	cam.End3D2D()

	cam.Start3D2D( Pos2 + Ang3:Up() + Ang3:Forward() * -5 + Ang3:Right() * -117, Ang3, 1 )
		draw.SimpleText( "$", "Trebuchet24", 0, 0, Color( 0, 255, 0, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
	cam.End3D2D()
end