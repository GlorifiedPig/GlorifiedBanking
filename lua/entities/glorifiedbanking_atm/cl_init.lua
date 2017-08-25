
include( "shared.lua" )

surface.CreateFont( "RobotoHuge", {
	font = "Roboto",
	size = 50,
	weight = 1000,
	shadow = true,
} )

surface.CreateFont( "BudgetLabelHuge", {
	font = "BudgetLabel",
	size = 200,
	weight = 1000,
	shadow = false,
} )

ENT.lastTime = 0
ENT.rotate = 0

function ENT:drawText( Pos, Angles )
	local Ang = Angle( -Angles.r, Angles.y + 90, Angles.p )

	Ang:RotateAroundAxis( Ang:Forward(), 90 )
	Ang:RotateAroundAxis( Ang:Right(), 270 )

	cam.Start3D2D( Pos + Ang:Up() * 8 + Ang:Forward() * -14.2 + Ang:Right() * -59, Ang, 0.11 )
		draw.WordBox( 0, 0, 0, glorifiedBanking.getPhrase( "atmMachine" ), "RobotoHuge", Color( 55, 55, 55, 155 ), glorifiedBanking.config.ATM_3D2D_COLOUR )
	cam.End3D2D()
end

function ENT:drawSymbol( Pos, Angles )
    local Ang2 = Angle( -Angles2.r, Angles.y + 90, Angles2.p )
	local Ang3 = Angle( -Angles2.r, Angles.y - 90, Angles2.p )

	Ang2:RotateAroundAxis( Ang2:Forward(), 90 )
	Ang2:RotateAroundAxis( Ang2:Right(), self.rotate )

	Ang3:RotateAroundAxis( Ang3:Forward(), 90 )
	Ang3:RotateAroundAxis( Ang3:Right(), self.rotate )

	cam.Start3D2D( Pos2 + Ang2:Up() + Ang2:Forward() * -5 + Ang2:Right() * -117, Ang2, 0.17 )
		draw.SimpleText( "$", "BudgetLabelHuge", 0, 0, glorifiedBanking.config.ATM_3D2D_COLOUR_DOLLAR, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
	cam.End3D2D()

	cam.Start3D2D( Pos2 + Ang3:Up() + Ang3:Forward() * -5 + Ang3:Right() * -117, Ang3, 0.17 )
		draw.SimpleText( "$", "BudgetLabelHuge", 0, 0, glorifiedBanking.config.ATM_3D2D_COLOUR_DOLLAR, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
	cam.End3D2D()
end

function ENT:Draw()
    self:DrawModel()

	local Pos = self:GetPos()
	local Angles = self:GetAngles()

    self.rotate = self.rotate - ( 50 * ( self.lastTime - SysTime() ) )
	self.lastTime = SysTime()

    -- First 3D2D ("ATM Machine" text)
    self:drawText( Pos, Angles )

    -- Second 3D2D (Floating Dollar Sign)
    self:drawSymbol( Pos, Angles )
end
