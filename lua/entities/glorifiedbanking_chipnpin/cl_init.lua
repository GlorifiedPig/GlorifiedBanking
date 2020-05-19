
include("shared.lua")

local imgui = GlorifiedBanking.imgui
imgui.DisableDeveloperMode = true

ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

function ENT:DrawKeypad()
    if imgui.Start3D2D(Vector(980, -83, -79), Angle(0, 270, 90), 0.1, 200, 150) then
        surface.SetDrawColor(255, 255, 255)
        surface.DrawRect(0, 0, 100, 100)

        imgui.End3D2D()
    end
end

function ENT:DrawTranslucent()
    self:DrawModel()

    self:DrawKeypad()
end
