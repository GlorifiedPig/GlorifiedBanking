
local PANEL = {}

function PANEL:AddData(data)
    self.Data = data

    self.Avatar = vgui.Create("GlorifiedBanking.CircleAvatar", self)
    if data.type == "Transfer" then self.Avatar2 = vgui.Create("GlorifiedBanking.CircleAvatar", self) end

    local function drawInfo(containerw, infoy)
        surface.SetFont("GlorifiedBanking.AdminMenu.LogInfoBold")
        local infow = surface.GetTextSize(i18n.GetPhrase("gbLogInfoType"))
        infow = infow + surface.GetTextSize(i18n.GetPhrase("gbLogInfoTime"))
        infow = infow + surface.GetTextSize(i18n.GetPhrase("gbLogInfoDate"))

        surface.SetFont("GlorifiedBanking.AdminMenu.LogInfo")
        infow = infow + surface.GetTextSize(self.Data.type)
        infow = infow + surface.GetTextSize(self.Data.time)
        infow = infow + surface.GetTextSize(self.Data.date)

        infow = infow + containerw * .03

        local infox = containerw / 2 - infow / 2
        infox = infox + draw.SimpleText(i18n.GetPhrase("gbLogInfoType"), "GlorifiedBanking.AdminMenu.LogInfoBold", infox, infoy, self.Theme.Data.Colors.logsMenuLogInfoTextCol, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        infox = infox + draw.SimpleText(self.Data.type, "GlorifiedBanking.AdminMenu.LogInfo", infox, infoy, self.Theme.Data.Colors.logsMenuLogInfoTextCol, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        infox = infox + containerw * .015

        infox = infox + draw.SimpleText(i18n.GetPhrase("gbLogInfoTime"), "GlorifiedBanking.AdminMenu.LogInfoBold", infox, infoy, self.Theme.Data.Colors.logsMenuLogInfoTextCol, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        infox = infox + draw.SimpleText(self.Data.time, "GlorifiedBanking.AdminMenu.LogInfo", infox, infoy, self.Theme.Data.Colors.logsMenuLogInfoTextCol, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        infox = infox + containerw * .015

        infox = infox + draw.SimpleText(i18n.GetPhrase("gbLogInfoDate"), "GlorifiedBanking.AdminMenu.LogInfoBold", infox, infoy, self.Theme.Data.Colors.logsMenuLogInfoTextCol, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        infox = infox + draw.SimpleText(self.Data.date, "GlorifiedBanking.AdminMenu.LogInfo", infox, infoy, self.Theme.Data.Colors.logsMenuLogInfoTextCol, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end

    local function drawPlayerInfo(playerno, x, containerh, align)
        local centerh = containerh / 2
        local spacing = containerh * .1

        draw.SimpleText(playerno == 1 and self.Data.username or self.Data.username2, "GlorifiedBanking.AdminMenu.LogPlayerInfo", x, centerh - spacing, self.Theme.Data.Colors.logsMenuLogPlayerNameTextCol, align, TEXT_ALIGN_CENTER)
        draw.SimpleText(playerno == 1 and self.Data.steamid or self.Data.steamid2, "GlorifiedBanking.AdminMenu.LogPlayerInfo", x, centerh + spacing, self.Theme.Data.Colors.logsMenuLogPlayerSteamIDTextCol, align, TEXT_ALIGN_CENTER)
    end

    function self:Paint(w, h)
        draw.RoundedBox(h * .1, 0, 0, w, h, self.Theme.Data.Colors.logsMenuLogBackgroundCol)

        drawPlayerInfo(1, h * .77, h, TEXT_ALIGN_LEFT)
        drawInfo(w, h / 2)

        draw.SimpleText(self.Data.amount, "GlorifiedBanking.AdminMenu.LogMoney", w * .95, h / 2, self.Data.type == "Withdrawal" and self.Theme.Data.Colors.logsMenuLogMoneyNegativeTextCol or self.Theme.Data.Colors.logsMenuLogMoneyPositiveTextCol, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
    end

    if self.Data.type != "Transfer" then return end

    function self:Paint(w, h)
        draw.RoundedBox(h * .1, 0, 0, w, h, self.Theme.Data.Colors.logsMenuLogBackgroundCol)

        drawPlayerInfo(1, h * .77, h, TEXT_ALIGN_LEFT)
        drawPlayerInfo(2, w - h * .82, h, TEXT_ALIGN_RIGHT)
        drawInfo(w, h * .7)

        draw.SimpleText(self.Data.amount, "GlorifiedBanking.AdminMenu.LogMoney", w / 2, h * .3, self.Theme.Data.Colors.logsMenuLogPlayerNameTextCol, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
end

function PANEL:PerformLayout(w, h)
    if IsValid(self.Avatar) then
        local avatarsize = h * .65
        local avatarpadx, avatarpady = h * .08, h * .18

        self.Avatar:SetSize(avatarsize, avatarsize)
        self.Avatar:SetMaskSize(avatarsize * .5)
        self.Avatar:SetPos(avatarpadx, avatarpady)
        self.Avatar:SetSteamID(util.SteamIDTo64(self.Data.steamid), avatarsize)

        if IsValid(self.Avatar2) then
            self.Avatar2:SetSize(avatarsize, avatarsize)
            self.Avatar2:SetMaskSize(avatarsize * .5)
            self.Avatar2:SetPos(w - avatarpadx - avatarsize, avatarpady)
            self.Avatar2:SetSteamID(util.SteamIDTo64(self.Data.steamid2), avatarsize)
        end
    end
end

vgui.Register("GlorifiedBanking.Log", PANEL, "Panel")
