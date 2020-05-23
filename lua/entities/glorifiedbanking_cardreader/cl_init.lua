
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
    self.IsMerchant = true--self.LocalPlayer == self:GetMerchant()
end

local scrw, scrh = 530, 702
--Button press/submit button press method for amount entry
ENT.Screens[1].onEnterPressed = function(self, amount)
    self.KeyPadBuffer = ""

end

ENT.Screens[1].drawFunction = function(self, data) --Amount entry screen
    draw.RoundedBox(10, scrw * .05, 140, scrw * .9, 80, theme.Data.Colors.readerEntryBgCol)

    local keypadContent = self:GetKeypadContent()
    local entered = keypadContent > 0
    draw.SimpleText(entered and GlorifiedBanking.FormatMoney(keypadContent) or i18n.GetPhrase("gbEnterAmount"), entered and "GlorifiedBanking.ReaderEntity.EnteredAmount" or "GlorifiedBanking.ReaderEntity.EnterAmount", scrw * .5, 180, entered and theme.Data.Colors.readerEntryEnterTextCol or theme.Data.Colors.readerEntryEnterEmptyTextCol, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

    return self:DrawKeypad()
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
        local screenID = self:GetScreenID()
        local currentScreen = self.Screens[screenID]

        self:DrawScreenBackground()
        local hovering = currentScreen.drawFunction(self, self.ScreenData)

        --if not currentScreen.hideCursor and self.LocalPlayer == self:GetCurrentUser() and  not self.ForcedLoad and imgui.IsHovering(0, 0, scrw, scrh) then
        --    local mx, my = imgui.CursorPos()

        --    surface.SetDrawColor(color_white)
        --    surface.SetMaterial(hovering and theme.Data.Materials.cursorHover or theme.Data.Materials.cursor)
        --    surface.DrawTexturedRect(hovering and mx - 12 or mx, my, 45, 45)
        --end

        imgui.End3D2D()
    end
end

function ENT:DrawScreenBackground()
    surface.SetDrawColor(theme.Data.Colors.readerBgCol)
    surface.DrawRect(0, 0, scrw, scrh)

    draw.RoundedBox(12, scrw * .05, 28, scrw * .9, 100, theme.Data.Colors.readerHeaderBgCol)
    draw.RoundedBox(2, scrw * .05, 77, scrw * .9, 4, theme.Data.Colors.readerHeaderLineCol)

    draw.SimpleText(i18n.GetPhrase("gbSystemNameCaps"), "GlorifiedBanking.ReaderEntity.HeaderTop", scrw * .5, 55, theme.Data.Colors.readerHeaderTextCol, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    draw.SimpleText(i18n.GetPhrase("gbCardReader"), "GlorifiedBanking.ReaderEntity.HeaderBottom", scrw * .5, 100, theme.Data.Colors.readerHeaderTextCol, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

local keyx, keyy = 98, 235
local keyw, keyh = 98, 98
local keyspacing = 20
function ENT:DrawKeypad()
    local hovering = false

    for i = 0, 2 do
        for j = 0, 3 do
            local x, y = keyx + (keyw + keyspacing) * i, keyy + (keyh + keyspacing) * j
            local keyNo = j * 3 + i + 1
            local key = (keyNo == 10 and "#") or (keyNo == 11 and "0") or (keyNo == 12 and "*") or tostring(keyNo)

            if imgui.IsHovering(x, y, keyw, keyh) then
                if imgui.IsPressed() then
                    self:PressKey(key)
                end

                draw.RoundedBox(8, x, y, keyw, keyh, theme.Data.Colors.readerKeyBgHoverCol)
            else
                draw.RoundedBox(8, x, y, keyw, keyh, theme.Data.Colors.readerKeyBgCol)
            end

            draw.SimpleText(key, "GlorifiedBanking.ReaderEntity.KeyNumber", x + keyw / 2, y + keyh * .47, theme.Data.Colors.readerKeyTextCol, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
    end

    return hovering
end

--Keypad management code
ENT.KeyPadBuffer = ""
function ENT:PressKey(key)
    if not self.IsMerchant then return end

    if key == "#" then
        self.KeyPadBuffer = ""
        return
    end

    local curScreen = self.Screens[self:GetScreenID()]

    if key == "*" then
        if not curScreen.onEnterPressed then return end
        curScreen.onEnterPressed(self, self:GetKeypadContent())
        return
    end

    if #self.KeyPadBuffer > 13 then return end

    self.KeyPadBuffer = self.KeyPadBuffer .. key
end

--Keypad content getter
function ENT:GetKeypadContent()
    return #self.KeyPadBuffer > 0 and tonumber(self.KeyPadBuffer) or 0
end
