
include("shared.lua")

local imgui = GlorifiedBanking.imgui
imgui.DisableDeveloperMode = true

ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

local padpos = Vector(0, 0, 30)
local padangles = Angle(90, 0, 0)
local keyw, keyh = 50, 50
local keyspacing = 10
function ENT:DrawKeypad()
    if imgui.Entity3D2D(self, padpos, padangles, 0.03, 150, 100) then
        for i = 0, 3 do
            for j = 0, 2 do
                local x, y = (keyw + keyspacing) * i, (keyh + keyspacing) * j
                if imgui.IsHovering(x, y, keyw, keyh) then
                    surface.SetDrawColor(Color(100, 100, 100))

                    if imgui.IsPressed() then
                        print("Pressed key: " .. tostring(i * 3 + j))
                    end
                else
                    surface.SetDrawColor(color_white or Color(100, 100, 100))
                end

                surface.DrawRect(x, y, keyw, keyh)
            end
        end

        imgui.End3D2D()
    end
end

function ENT:DrawTranslucent()
    self:DrawModel()

    self:DrawKeypad()
end
