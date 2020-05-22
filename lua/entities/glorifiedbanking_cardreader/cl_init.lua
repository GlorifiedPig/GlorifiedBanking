
include("shared.lua")

local imgui = GlorifiedBanking.imgui

--Localise the theme data
local theme = GlorifiedBanking.Themes.GetCurrent()
hook.Add("GlorifiedBanking.ThemeUpdated", "GlorifiedBanking.ATMEntity.ThemeUpdated", function(newTheme)
    theme = newTheme
end)

ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

function ENT:Think()
    if not self.LocalPlayer then self.LocalPlayer = LocalPlayer() end
    self.IsMerchant = self.LocalPlayer == self:GetMerchant()
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
    surface.SetDrawColor(theme.Data.Colors.readerBgCol)
    surface.DrawRect(0, 0, scrw, scrh)

    draw.RoundedBox(12, scrw * .05, 28, scrw * .9, 100, theme.Data.Colors.readerHeaderBgCol)
    draw.RoundedBox(2, scrw * .05, 77, scrw * .9, 4, theme.Data.Colors.readerHeaderLineCol)

    draw.SimpleText(i18n.GetPhrase("gbSystemNameCaps"), "GlorifiedBanking.ReaderEntity.HeaderTop", scrw * .5, 55, theme.Data.Colors.readerHeaderTextCol, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    draw.SimpleText(i18n.GetPhrase("gbCardReader"), "GlorifiedBanking.ReaderEntity.HeaderBottom", scrw * .5, 100, theme.Data.Colors.readerHeaderTextCol, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
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
