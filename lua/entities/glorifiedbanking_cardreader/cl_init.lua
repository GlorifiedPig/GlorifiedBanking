
include("shared.lua")

local imgui = GlorifiedBanking.imgui

ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

local padpos = Vector(0, 0, 30)
local padangles = Angle(270, 180, 0)
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
                        print("Pressed key: " .. tostring(i * 3 + j + 1))
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

function ENT:Think()
    if not self.LocalPlayer then self.LocalPlayer = LocalPlayer() end
end


local scrw, scrh = 530, 702
function ENT:DrawScreenBackground()
    surface.SetDrawColor(color_white)
    surface.DrawRect(0, 0, scrw, scrh)
end

local screenpos = Vector(-2.65, 4.41, .69)
local screenang = Angle(0, 0, 5.5)
function ENT:DrawScreen()
    if imgui.Entity3D2D(self, screenpos, screenang, 0.01, 250, 200) then
        self:DrawScreenBackground()

        imgui.End3D2D()
    end
end

function ENT:DrawTranslucent()
    self:DrawModel()

    if not self.LocalPlayer then return end
    if self.LocalPlayer:GetPos():DistToSqr(self:GetPos()) > 1000 * 1000 then return end

    self:DrawScreen()
end
