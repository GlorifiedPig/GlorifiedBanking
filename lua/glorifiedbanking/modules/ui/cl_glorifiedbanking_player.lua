
local PANEL = {}

function PANEL:AddPlayer(ply, balance)
    self.Player = ply
    self.Balance = balance

    self.Avatar = vgui.Create("GlorifiedBanking.CircleAvatar", self)

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
    local avatarpadx, avatarpady = h * .08, h * .18

    self.Avatar:SetSize(avatarsize, avatarsize)
    self.Avatar:SetMaskSize(avatarsize * .5)
    self.Avatar:SetPos(avatarpadx, avatarpady)
    self.Avatar:SetSteamID(self.Player:SteamID64(), avatarsize)
end

vgui.Register("GlorifiedBanking.Player", PANEL, "Panel")
