
local PANEL = {}

function PANEL:Init()
    self:SetSize(ScrH() * .6, ScrH() * .6)
    self:Center()
    self:MakePopup()

    self.Theme = GlorifiedBanking.Themes.GetCurrent()

    self.Close = vgui.Create("DButton", self)
    self.Close:SetText("")

    self.Close.DoClick = function(s)
        self:Remove()
    end

    self.Close.Color = Color(255, 255, 255)
    self.Close.Paint = function(s, w, h)
        local iconSize = h * .5

        s.Color = GlorifiedBanking.UI.LerpColor(FrameTime() * 5, s.Color, s:IsHovered() and self.Theme.Data.Colors.adminMenuCloseButtonHoverCol or self.Theme.Data.Colors.adminMenuCloseButtonCol)

        surface.SetDrawColor(s.Color)
        surface.SetMaterial(self.Theme.Data.Materials.close)
        surface.DrawTexturedRect(w / 2 - iconSize / 2, h / 2 - iconSize / 2, iconSize, iconSize)
    end

    self.Entry = vgui.Create("DTextEntry", self)
    self.Entry:SetValue("Filf1VB")
    self.Entry:SetFont("GlorifiedBanking.AdminMenu.SetBalanceEntry")
    self.Entry:SetUpdateOnType(true)

    self.Entry.OnValueChange = function(s, value)
        GlorifiedBanking.UI.GetImgur(value, function(mat)
            self.CardMaterial = mat
        end)
    end

    local ply = LocalPlayer()
    local cardName = ply:Name()
    local id = ply:SteamID64():sub(-16)
    cardID  = id:sub(1, 4)

    for i = 4, 15, 4 do
        cardID = cardID .. " " .. id:sub(i, i + 3)
    end

    self.CardPreview = vgui.Create("Panel", self)
    self.CardPreview.Paint = function(s, w, h)
        surface.SetDrawColor(color_white)
        surface.SetMaterial(self.CardMaterial or self.Theme.Data.Materials.bankCard)
        surface.DrawTexturedRect(0, 0, w, h)

        draw.SimpleText(cardID, "GlorifiedBanking.CardDesigner.CardInfo", w * .032, h * .73, self.Theme.Data.Colors.cardNumberTextCol)
        draw.SimpleText(cardName, "GlorifiedBanking.CardDesigner.CardInfo", w * .032, h * .85, self.Theme.Data.Colors.cardNameTextCol)
    end

    self.Save = vgui.Create("DButton", self)
    self.Save:SetText("")

    self.Save.Color = Color(255, 255, 255)
    self.Save.Paint = function(s, w, h)
        s.Color = GlorifiedBanking.UI.LerpColor(FrameTime() * 10, s.Color, s:IsHovered() and self.Theme.Data.Colors.setBalanceButtonBackgroundHoverCol or self.Theme.Data.Colors.setBalanceButtonBackgroundCol)

        draw.RoundedBox(h * .08, 0, 0, w, h, s.Color)
        draw.SimpleText(i18n.GetPhrase("gbSave"), "GlorifiedBanking.AdminMenu.SetBalanceButton", w / 2, h * .43, self.Theme.Data.Colors.setBalanceButtonTextCol, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    self.Save.DoClick = function(s)

    end

    self.Reset = vgui.Create("DButton", self)
    self.Reset:SetText("")

    self.Reset.Color = Color(255, 255, 255)
    self.Reset.Paint = function(s, w, h)
        s.Color = GlorifiedBanking.UI.LerpColor(FrameTime() * 10, s.Color, s:IsHovered() and self.Theme.Data.Colors.resetBalanceNoButtonBackgroundHoverCol or self.Theme.Data.Colors.resetBalanceNoButtonBackgroundCol)

        draw.RoundedBox(h * .08, 0, 0, w, h, s.Color)
        draw.SimpleText(i18n.GetPhrase("gbResetDefaults"), "GlorifiedBanking.AdminMenu.SetBalanceButton", w / 2, h * .43, self.Theme.Data.Colors.setBalanceButtonTextCol, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    self.Reset.DoClick = function(s)
        self.Entry:SetValue("Filf1VB")
        self.Save:DoClick()
    end
end

function PANEL:PerformLayout(w, h)
    self.Close:SetSize(h * .06, h * .06)
    self.Close:SetPos(w - h * .06, 0)

    self.Entry:SetSize(w * .97, h * .06)
    self.Entry:SetPos(w * .015, h * .12)

    local cardh = h * .55
    local cardw = (1008 / 576) * cardh
    self.CardPreview:SetSize(cardw, cardh)
    self.CardPreview:SetPos((w - cardw) * .5, h * .225)

    self.Save:SetSize(w * .97, h * .07)
    self.Save:SetPos(w * .015, h * .82)

    self.Reset:SetSize(w * .97, h * .07)
    self.Reset:SetPos(w * .015, h * .91)
end

function PANEL:Paint(w, h)
    draw.RoundedBox(6, 0, 0, w, h, self.Theme.Data.Colors.adminMenuBackgroundCol)
    draw.RoundedBoxEx(6, 0, 0, w, h * .06, self.Theme.Data.Colors.adminMenuNavbarBackgroundCol, true, true)

    draw.SimpleText(i18n.GetPhrase("gbCardDesigner"), "GlorifiedBanking.AdminMenu.SetBalanceTitle", w * .013, h * .028, self.Theme.Data.Colors.adminMenuNavbarItemCol, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    draw.SimpleText(i18n.GetPhrase("gbEnterImgur"), "GlorifiedBanking.AdminMenu.SetBalanceDescription", w * .013, h * .07, self.Theme.Data.Colors.adminMenuNavbarItemCol)
end

vgui.Register("GlorifiedBanking.CardDesigner", PANEL, "EditablePanel")

if not IsValid(LocalPlayer()) then return end

if IsValid(GlorifiedBanking.UI.CardDesigner) then
    GlorifiedBanking.UI.CardDesigner:Remove()
    GlorifiedBanking.UI.CardDesigner = nil
end

GlorifiedBanking.UI.CardDesigner = vgui.Create("GlorifiedBanking.CardDesigner")
