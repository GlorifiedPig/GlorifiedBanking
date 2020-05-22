
include("shared.lua")

local imgui = GlorifiedBanking.imgui

ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

function ENT:Think()
    if not self.LocalPlayer then self.LocalPlayer = LocalPlayer() end
end

function ENT:DrawTranslucent()
    self:DrawModel()

    if not self.LocalPlayer then return end
    if self.LocalPlayer:GetPos():DistToSqr(self:GetPos()) > 1000 * 1000 then return end

    self:DrawScreen()
end

local screenpos = Vector(-2.65, 4.41, .69)
local screenang = Angle(0, 0, 5.5)
function ENT:DrawScreen()
    if imgui.Entity3D2D(self, screenpos, screenang, 0.01, 250, 200) then
        self:DrawScreenBackground()
        self:DrawKeypad()

        imgui.End3D2D()
    end
end

local scrw, scrh = 530, 702
function ENT:DrawScreenBackground()
    surface.SetDrawColor(color_black)
    surface.DrawRect(0, 0, scrw, scrh)
end

local keyx, keyy = 120, 220
local keyw, keyh = 90, 90
local keyspacing = 10
function ENT:DrawKeypad()
    for i = 0, 2 do
        for j = 0, 3 do
            local x, y = keyx + (keyw + keyspacing) * i, keyy + (keyh + keyspacing) * j
            if imgui.IsHovering(x, y, keyw, keyh) then
                surface.SetDrawColor(Color(100, 100, 100))

                if imgui.IsPressed() then
                    print("Pressed key: " .. tostring(j * 3 + i + 1))
                end
            else
                surface.SetDrawColor(color_white or Color(100, 100, 100))
            end

            surface.DrawRect(x, y, keyw, keyh)
        end
    end
end
