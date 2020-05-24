
local PANEL = {}

function PANEL:Init()
    self:SetSize(ScrH() * .4, ScrH() * .18)
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
    self.Entry:SetValue("0")
    self.Entry:SetFont("GlorifiedBanking.AdminMenu.SetBalanceEntry")
    self.Entry:SetNumeric(true)

    self.Enter = vgui.Create("DButton", self)
    self.Enter:SetText("")

    self.Enter.Color = Color(255, 255, 255)
    self.Enter.Paint = function(s, w, h)
        s.Color = GlorifiedBanking.UI.LerpColor(FrameTime() * 10, s.Color, s:IsHovered() and self.Theme.Data.Colors.setBalanceButtonBackgroundHoverCol or self.Theme.Data.Colors.setBalanceButtonBackgroundCol)

        draw.RoundedBox(h * .1, 0, 0, w, h, s.Color)
        draw.SimpleText(i18n.GetPhrase("gbEnter"), "GlorifiedBanking.AdminMenu.SetBalanceButton", w / 2, h * .43, self.Theme.Data.Colors.setBalanceButtonTextCol, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    self.Enter.DoClick = function(s)
        if not self.SteamID then return end
        if tonumber(self.Entry:GetValue()) < 0 then
            GlorifiedBanking.Notify(NOTIFY_ERROR, 3, i18n.GetPhrase("gbCantHaveNegative"))
            return
        end

        net.Start("GlorifiedBanking.AdminPanel.SetPlayerBalance")
         net.WriteString(self.SteamID)
         net.WriteUInt(self.Entry:GetValue(), 32)
        net.SendToServer()

        net.Start("GlorifiedBanking.AdminPanel.PlayerListOpened")
        net.SendToServer()

        self:Remove()
    end

    timer.Simple(0, function()
        if self.Username then return end
        steamworks.RequestPlayerInfo(self.SteamID, function(name)
            self.Username = name
        end)
    end)
end

function PANEL:PerformLayout(w, h)
    self.Close:SetSize(h * .18, h * .18)
    self.Close:SetPos(w - h * .18, 0)

    self.Entry:SetSize(w * .95, h * .2)
    self.Entry:SetPos(w * .025, h * .4)

    self.Enter:SetSize(w * .95, h * .2)
    self.Enter:SetPos(w * .025, h * .73)
end

function PANEL:Think()
    self:MoveToFront()
end

function PANEL:Paint(w, h)
    draw.RoundedBox(6, 0, 0, w, h, self.Theme.Data.Colors.adminMenuBackgroundCol)
    draw.RoundedBoxEx(6, 0, 0, w, h * .18, self.Theme.Data.Colors.adminMenuNavbarBackgroundCol, true, true)

    draw.SimpleText(i18n.GetPhrase("gbSetBalance"), "GlorifiedBanking.AdminMenu.SetBalanceTitle", w * .021, h * .08, self.Theme.Data.Colors.adminMenuNavbarItemCol, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    draw.SimpleText(i18n.GetPhrase("gbEnterBalance", self.Username and self.Username or self.SteamID or "undefined"), "GlorifiedBanking.AdminMenu.SetBalanceDescription", w * .021, h * .23, self.Theme.Data.Colors.adminMenuNavbarItemCol)
end

vgui.Register("GlorifiedBanking.BalancePopup", PANEL, "EditablePanel")
