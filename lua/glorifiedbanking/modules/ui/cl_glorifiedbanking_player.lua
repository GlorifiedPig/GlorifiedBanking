
local PANEL = {}

function PANEL:AddPlayer(ply, balance)
    self.Player = ply
    self.Balance = balance

    self.Avatar = vgui.Create("GlorifiedBanking.CircleAvatar", self)

    self.SetBalance = vgui.Create("DButton", self)
    self.SetBalance:SetText("")
    self.SetBalance.Color = Color(255, 255, 255)
    self.SetBalance.Paint = function(s, w, h)
        s.Color = GlorifiedBanking.UI.LerpColor(FrameTime() * 10, s.Color, s:IsHovered() and self.Theme.Data.Colors.playersMenuSetButtonBackgroundHoverCol or self.Theme.Data.Colors.playersMenuSetButtonBackgroundCol)

        draw.RoundedBox(h * .22, 0, 0, w, h, s.Color)
        draw.SimpleText(i18n.GetPhrase("gbSetBalance"), "GlorifiedBanking.AdminMenu.PlayerSetBalance", w / 2, h / 2, self.Theme.Data.Colors.playersMenuButtonTextCol, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    self.SetBalance.DoClick = function(s)
        if IsValid(GlorifiedBanking.UI.BalancePopup) then return end

        GlorifiedBanking.UI.BalancePopup = vgui.Create("GlorifiedBanking.BalancePopup")
        GlorifiedBanking.UI.BalancePopup.Player = self.Player
    end

    self.ResetBalance = vgui.Create("DButton", self)
    self.ResetBalance:SetText("")
    self.ResetBalance.Color = Color(255, 255, 255)
    self.ResetBalance.Paint = function(s, w, h)
        s.Color = GlorifiedBanking.UI.LerpColor(FrameTime() * 10, s.Color, s:IsHovered() and self.Theme.Data.Colors.playersMenuResetButtonBackgroundHoverCol or self.Theme.Data.Colors.playersMenuResetButtonBackgroundCol)

        draw.RoundedBox(h * .22, 0, 0, w, h, s.Color)
        draw.SimpleText(i18n.GetPhrase("gbResetBalance"), "GlorifiedBanking.AdminMenu.PlayerSetBalance", w / 2, h / 2, self.Theme.Data.Colors.playersMenuButtonTextCol, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    self.ViewTransactions = vgui.Create("DButton", self)
    self.ViewTransactions:SetText("")
    self.ViewTransactions.Color = Color(255, 255, 255)
    self.ViewTransactions.Paint = function(s, w, h)
        s.Color = GlorifiedBanking.UI.LerpColor(FrameTime() * 10, s.Color, s:IsHovered() and self.Theme.Data.Colors.playersMenuTransactionsButtonBackgroundHoverCol or self.Theme.Data.Colors.playersMenuTransactionsButtonBackgroundCol)

        draw.RoundedBox(h * .22, 0, 0, w, h, s.Color)
        draw.SimpleText(i18n.GetPhrase("gbViewTransactions"), "GlorifiedBanking.AdminMenu.PlayerSetBalance", w / 2, h / 2, self.Theme.Data.Colors.playersMenuButtonTextCol, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    local function drawPlayerInfo(playerno, x, containerh, align)
        local centerh = containerh / 2
        local spacing = containerh * .1

        draw.SimpleText(self.Player:Name(), "GlorifiedBanking.AdminMenu.LogPlayerInfo", x, centerh - spacing, self.Theme.Data.Colors.logsMenuLogPlayerNameTextCol, align, TEXT_ALIGN_CENTER)
        draw.SimpleText(self.Player:SteamID(), "GlorifiedBanking.AdminMenu.LogPlayerInfo", x, centerh + spacing, self.Theme.Data.Colors.logsMenuLogPlayerSteamIDTextCol, align, TEXT_ALIGN_CENTER)
    end

    function self:Paint(w, h)
        draw.RoundedBox(h * .1, 0, 0, w, h, self.Theme.Data.Colors.logsMenuLogBackgroundCol)

        drawPlayerInfo(1, h * .77, h, TEXT_ALIGN_LEFT)

        draw.SimpleText(GlorifiedBanking.FormatMoney(self.Balance), "GlorifiedBanking.AdminMenu.LogMoney", w * .95, h / 2, self.Theme.Data.Colors.logsMenuLogInfoTextCol, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
    end
end

function PANEL:PerformLayout(w, h)
    local avatarsize = h * .65

    self.Avatar:SetSize(avatarsize, avatarsize)
    self.Avatar:SetMaskSize(avatarsize * .5)
    self.Avatar:SetPos(h * .08, h * .18)
    self.Avatar:SetSteamID(self.Player:SteamID64(), avatarsize)

    self.SetBalance:SetSize(w * .12, h * .4)
    self.SetBalance:SetPos(w * .3, h * .3)

    self.ResetBalance:SetSize(w * .14, h * .4)
    self.ResetBalance:SetPos(w * .43, h * .3)

    self.ViewTransactions:SetSize(w * .13, h * .4)
    self.ViewTransactions:SetPos(w * .58, h * .3)
end

vgui.Register("GlorifiedBanking.Player", PANEL, "Panel")
