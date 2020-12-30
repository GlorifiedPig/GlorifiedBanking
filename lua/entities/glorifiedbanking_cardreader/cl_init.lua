
include("shared.lua")

local imgui = GlorifiedBanking.imgui

--Localise the theme data
local theme = GlorifiedBanking.Themes.GetCurrent()
hook.Add("GlorifiedBanking.ThemeUpdated", "GlorifiedBanking.ReaderEntity.ThemeUpdated", function(newTheme)
    theme = newTheme
end)

ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

function ENT:Think()
    if not self.LocalPlayer then self.LocalPlayer = LocalPlayer() end
    self.IsMerchant = self.LocalPlayer == self:GetMerchant()
end

function ENT:InsertCard()
    if self:GetScreenID() ~= 3 then return end

    net.Start("GlorifiedBanking.CardReader.PayMerchant")
     net.WriteEntity(self)
    net.SendToServer()

    return GlorifiedBanking.CanPlayerAfford(self:GetTransactionAmount())
end

local scrw, scrh = 623, 702
--Button press/submit button press method for amount entry
ENT.Screens[1].onEnterPressed = function(self, amount)
    self.KeyPadBuffer = ""

    net.Start("GlorifiedBanking.CardReader.StartTransaction")
     net.WriteUInt(amount, 64)
     net.WriteEntity(self)
    net.SendToServer()
end

ENT.Screens[1].drawFunction = function(self) --Amount entry screen
    draw.RoundedBox(10, scrw * .05, 140, scrw * .9, 80, theme.Data.Colors.readerEntryBgCol)

    local keypadContent = self:GetKeypadContent()
    local entered = keypadContent > 0
    draw.SimpleText(entered and GlorifiedBanking.FormatMoney(keypadContent) or GlorifiedBanking.i18n.GetPhrase("gbEnterAmount"), entered and "GlorifiedBanking.ReaderEntity.EnteredAmount" or "GlorifiedBanking.ReaderEntity.EnterAmount", scrw * .5, 180, entered and theme.Data.Colors.readerEntryEnterTextCol or theme.Data.Colors.readerEntryEnterEmptyTextCol, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

    return self:DrawKeypad()
end

ENT.Screens[2].drawFunction = function(self) --Transaction confirm screen
    local hovering = false

    if imgui.IsHovering(scrw * .05, 140, scrw * .9, 80) then
        hovering = true
        draw.RoundedBox(12, scrw * .05, 140, scrw * .9, 80, theme.Data.Colors.readerBackBgHoverCol)

        if imgui.IsPressed() then
            net.Start("GlorifiedBanking.CardReader.BackToMenu")
             net.WriteEntity(self)
            net.SendToServer()
        end
    else
        draw.RoundedBox(12, scrw * .05, 140, scrw * .9, 80, theme.Data.Colors.readerBackBgCol)
    end

    draw.SimpleText(GlorifiedBanking.i18n.GetPhrase("gbBack"), "GlorifiedBanking.ReaderEntity.Back", scrw * .5, 177, theme.Data.Colors.readerBackTextCol, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

    surface.SetDrawColor(theme.Data.Colors.readerBackIconCol)
    surface.SetMaterial(theme.Data.Materials.chevron)
    surface.DrawTexturedRectRotated(60, 180, 45, 45, 180)

    draw.SimpleText(GlorifiedBanking.i18n.GetPhrase("gbPaymentOf"), "GlorifiedBanking.ReaderEntity.PaymentTo", scrw * .5, 290, theme.Data.Colors.readerPayAmountTextCol, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

    draw.RoundedBoxEx(12, scrw * .05, 320, scrw * .9, 100, theme.Data.Colors.readerPayAmountBgCol, true, true)
    draw.RoundedBox(2, scrw * .05, 416, scrw * .9, 4, theme.Data.Colors.readerPayAmountUnderlineCol)
    draw.SimpleText(GlorifiedBanking.FormatMoney(self:GetTransactionAmount() or -1), "GlorifiedBanking.ReaderEntity.TransactionAmount", scrw * .5, 368, theme.Data.Colors.readerPayAmountTextCol, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

    local merchant = self:GetMerchant()
    draw.SimpleText(GlorifiedBanking.i18n.GetPhrase("gbToAccount", merchant and string.upper(merchant:Name()) or "N/a"), "GlorifiedBanking.ReaderEntity.PaymentRecipient", scrw * .5, 440, theme.Data.Colors.readerPayAmountTextCol, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

    draw.RoundedBox(12, scrw * .05, 540, scrw * .9, 140, theme.Data.Colors.readerConfirmOuterBgCol)

    if imgui.IsHovering(scrw * .075, 550, scrw * .85, 120) then
        hovering = true
        draw.RoundedBox(10, scrw * .075, 550, scrw * .85, 120, theme.Data.Colors.readerConfirmBgHoverCol)

        if imgui.IsPressed() then
            net.Start("GlorifiedBanking.CardReader.ConfirmTransaction")
             net.WriteEntity(self)
            net.SendToServer()
        end
    else
        draw.RoundedBox(10, scrw * .075, 550, scrw * .85, 120, theme.Data.Colors.readerConfirmBgCol)
    end

    local iconsize = 55

    surface.SetFont("GlorifiedBanking.ReaderEntity.ConfirmTransaction")
    local width = iconsize + 20 + surface.GetTextSize(GlorifiedBanking.i18n.GetPhrase("gbConfirm"))

    surface.SetDrawColor(theme.Data.Colors.readerBackIconCol)
    surface.SetMaterial(theme.Data.Materials.transfer)
    surface.DrawTexturedRect(scrw * .5 - width * .5, 585, iconsize, iconsize)

    draw.SimpleText(GlorifiedBanking.i18n.GetPhrase("gbConfirm"), "GlorifiedBanking.ReaderEntity.ConfirmTransaction", scrw * .5 + width * .5, 610, theme.Data.Colors.readerConfirmTextCol, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)

    return hovering
end

ENT.Screens[3].drawFunction = function(self) --Present payment device screen
    local hovering = false

    surface.SetDrawColor(theme.Data.Colors.readerBgCol)
    surface.DrawRect(0, 0, scrw, scrh)

    if imgui.IsHovering(scrw * .05, scrh - 110, scrw * .9, 80) then
        hovering = true
        draw.RoundedBox(12, scrw * .05, scrh - 110, scrw * .9, 80, theme.Data.Colors.readerBackBgHoverCol)

        if imgui.IsPressed() then
            net.Start("GlorifiedBanking.CardReader.BackToMenu")
             net.WriteEntity(self)
            net.SendToServer()
        end
    else
        draw.RoundedBox(12, scrw * .05, scrh - 110, scrw * .9, 80, theme.Data.Colors.readerBackBgCol)
    end

    draw.SimpleText(GlorifiedBanking.i18n.GetPhrase("gbCancel"), "GlorifiedBanking.ReaderEntity.Back", scrw * .5, scrh - 72, theme.Data.Colors.readerBackTextCol, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

    surface.SetDrawColor(theme.Data.Colors.readerBackIconCol)
    surface.SetMaterial(theme.Data.Materials.chevron)
    surface.DrawTexturedRectRotated(60, scrh - 70, 45, 45, 180)

    draw.DrawText(GlorifiedBanking.i18n.GetPhrase("gbPleasePresent"), "GlorifiedBanking.ReaderEntity.PresentDevice", scrw * .5, scrh * .5 - 70, theme.Data.Colors.readerLoadingTextCol, TEXT_ALIGN_CENTER)

    return hovering
end

ENT.Screens[4].drawFunction = function(self) --Loading screen
    surface.SetDrawColor(theme.Data.Colors.readerBgCol)
    surface.DrawRect(0, 0, scrw, scrh)

    surface.SetDrawColor(theme.Data.Colors.readerLoadingSpinnerCol)
    surface.SetMaterial(theme.Data.Materials.loading)
    surface.DrawTexturedRectRotated(scrw * .5, scrh * .5 - 50, 200, 200, -CurTime() * 100)

    draw.SimpleText(GlorifiedBanking.i18n.GetPhrase("gbReaderLoading"), "GlorifiedBanking.ReaderEntity.Loading", scrw * .5, scrh * .5 + 100, theme.Data.Colors.readerLoadingTextCol, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

function ENT:DrawTranslucent()
    self:DrawModel()

    if not self.LocalPlayer then return end
    if self.LocalPlayer:GetPos():DistToSqr(self:GetPos()) > 1000 * 1000 then return end

    self:DrawScreen()
end

local screenpos = Vector(.44, -3.79, 7.31)
local screenang = Angle(0, 90, 90)
function ENT:DrawScreen()
    if imgui.Entity3D2D(self, screenpos, screenang, 0.01215, 150, 120) then
        local screenID = self:GetScreenID()
        local currentScreen = self.Screens[screenID]

        self:DrawScreenBackground()
        currentScreen.drawFunction(self)

        imgui.End3D2D()
    end
end

function ENT:DrawScreenBackground()
    surface.SetDrawColor(theme.Data.Colors.readerBgCol)
    surface.DrawRect(0, 0, scrw, scrh)

    draw.RoundedBox(12, scrw * .05, 28, scrw * .9, 100, theme.Data.Colors.readerHeaderBgCol)
    draw.RoundedBox(2, scrw * .05, 77, scrw * .9, 4, theme.Data.Colors.readerHeaderLineCol)

    draw.SimpleText(GlorifiedBanking.i18n.GetPhrase("gbSystemNameCaps"), "GlorifiedBanking.ReaderEntity.HeaderTop", scrw * .5, 55, theme.Data.Colors.readerHeaderTextCol, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    draw.SimpleText(GlorifiedBanking.i18n.GetPhrase("gbCardReader"), "GlorifiedBanking.ReaderEntity.HeaderBottom", scrw * .5, 100, theme.Data.Colors.readerHeaderTextCol, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

local keyx, keyy = 144, 235
local keyw, keyh = 98, 98
local keyspacing = 20
function ENT:DrawKeypad()
    local hovering = false

    for i = 0, 2 do
        for j = 0, 3 do
            local x, y = keyx + (keyw + keyspacing) * i, keyy + (keyh + keyspacing) * j
            local keyNo = j * 3 + i + 1
            local key = (keyNo == 10 and "#") or (keyNo == 11 and "0") or (keyNo == 12 and "*") or tostring(keyNo)

            local keyHovered = imgui.IsHovering(x, y, keyw, keyh)
            hovering = keyHovered or hovering

            if keyHovered and imgui.IsPressed() then
                self:PressKey(key)
            end

            if keyNo < 10 or keyNo == 11 then
                draw.RoundedBox(8, x, y, keyw, keyh, keyHovered and theme.Data.Colors.readerKeyBgHoverCol or theme.Data.Colors.readerKeyBgCol)
                draw.SimpleText(key, "GlorifiedBanking.ReaderEntity.KeyNumber", x + keyw / 2, y + keyh * .47, theme.Data.Colors.readerKeyTextCol, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                continue
            end

            local iconsize = keyw * .7
            local iconoff = (keyw - iconsize) / 2

            if keyNo == 10 then
                draw.RoundedBox(8, x, y, keyw, keyh, keyHovered and theme.Data.Colors.readerKeyCancelBgHoverCol or theme.Data.Colors.readerKeyCancelBgCol)

                surface.SetDrawColor(theme.Data.Colors.readerKeyIconCol)
                surface.SetMaterial(theme.Data.Materials.close)
                surface.DrawTexturedRect(x + iconoff, y + iconoff, iconsize, iconsize)

                continue
            end

            draw.RoundedBox(8, x, y, keyw, keyh, keyHovered and theme.Data.Colors.readerKeySubmitBgHoverCol or theme.Data.Colors.readerKeySubmitBgCol)

            surface.SetDrawColor(theme.Data.Colors.readerKeyIconCol)
            surface.SetMaterial(theme.Data.Materials.check)
            surface.DrawTexturedRect(x + iconoff, y + iconoff, iconsize, iconsize)
        end
    end

    return hovering
end

--Keypad management code
ENT.KeyPadBuffer = ""
function ENT:PressKey(key)
    if not self.IsMerchant then return end

    self:EmitSound("GlorifiedBanking.Beep_Reader_Normal")

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

    if #self.KeyPadBuffer > 8 then return end

    self.KeyPadBuffer = self.KeyPadBuffer .. key
end

--Keypad content getter
function ENT:GetKeypadContent()
    return #self.KeyPadBuffer > 0 and tonumber(self.KeyPadBuffer) or 0
end
