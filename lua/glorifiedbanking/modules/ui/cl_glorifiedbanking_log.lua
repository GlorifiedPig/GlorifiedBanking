
local PANEL = {}

function PANEL:AddData(data)
    data.SteamID64 = util.SteamIDTo64(data.SteamID)
    if data.ReceiverSteamID then data.ReceiverSteamID64 = util.SteamIDTo64(data.ReceiverSteamID) end

    data.Time = os.date("%H:%M:%S", data.Date)
    data.Date = os.date("%d/%m/%Y", data.Date)

    data.Username = ""
    data.ReceiverUsername = ""

    data.Amount = GlorifiedBanking.FormatMoney(data.Amount)

    self.Data = data

    steamworks.RequestPlayerInfo(data.SteamID64, function(name)
        self.Data.Username = name
    end)

    if data.ReceiverSteamID then
        steamworks.RequestPlayerInfo(data.ReceiverSteamID64, function(name)
            self.Data.ReceiverUsername = name
        end)
    end

    self.Avatar = vgui.Create("GlorifiedBanking.CircleAvatar", self)
    if data.ReceiverSteamID then self.Avatar2 = vgui.Create("GlorifiedBanking.CircleAvatar", self) end

    local function drawInfo(containerw, infoy)
        surface.SetFont("GlorifiedBanking.AdminMenu.LogInfoBold")
        local infow = surface.GetTextSize(i18n.GetPhrase("gbLogInfoType"))
        infow = infow + surface.GetTextSize(i18n.GetPhrase("gbLogInfoTime"))
        infow = infow + surface.GetTextSize(i18n.GetPhrase("gbLogInfoDate"))

        surface.SetFont("GlorifiedBanking.AdminMenu.LogInfo")
        infow = infow + surface.GetTextSize(self.Data.Type)
        infow = infow + surface.GetTextSize(self.Data.Time)
        infow = infow + surface.GetTextSize(self.Data.Date)

        infow = infow + containerw * .03

        local infox = containerw / 2 - infow / 2
        infox = infox + draw.SimpleText(i18n.GetPhrase("gbLogInfoType"), "GlorifiedBanking.AdminMenu.LogInfoBold", infox, infoy, self.Theme.Data.Colors.logsMenuLogInfoTextCol, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        infox = infox + draw.SimpleText(self.Data.Type, "GlorifiedBanking.AdminMenu.LogInfo", infox, infoy, self.Theme.Data.Colors.logsMenuLogInfoTextCol, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        infox = infox + containerw * .015

        infox = infox + draw.SimpleText(i18n.GetPhrase("gbLogInfoTime"), "GlorifiedBanking.AdminMenu.LogInfoBold", infox, infoy, self.Theme.Data.Colors.logsMenuLogInfoTextCol, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        infox = infox + draw.SimpleText(self.Data.Time, "GlorifiedBanking.AdminMenu.LogInfo", infox, infoy, self.Theme.Data.Colors.logsMenuLogInfoTextCol, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        infox = infox + containerw * .015

        infox = infox + draw.SimpleText(i18n.GetPhrase("gbLogInfoDate"), "GlorifiedBanking.AdminMenu.LogInfoBold", infox, infoy, self.Theme.Data.Colors.logsMenuLogInfoTextCol, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        infox = infox + draw.SimpleText(self.Data.Date, "GlorifiedBanking.AdminMenu.LogInfo", infox, infoy, self.Theme.Data.Colors.logsMenuLogInfoTextCol, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end

    local function drawPlayerInfo(playerno, x, containerh, align)
        local centerh = containerh / 2
        local spacing = containerh * .1

        draw.SimpleText(playerno == 1 and self.Data.Username or self.Data.ReceiverUsername, "GlorifiedBanking.AdminMenu.LogPlayerInfo", x, centerh - spacing, self.Theme.Data.Colors.logsMenuLogPlayerNameTextCol, align, TEXT_ALIGN_CENTER)
        draw.SimpleText(playerno == 1 and self.Data.SteamID or self.Data.ReceiverSteamID, "GlorifiedBanking.AdminMenu.LogPlayerInfo", x, centerh + spacing, self.Theme.Data.Colors.logsMenuLogPlayerSteamIDTextCol, align, TEXT_ALIGN_CENTER)
    end

    function self:Paint(w, h)
        draw.RoundedBox(h * .1, 0, 0, w, h, self.Theme.Data.Colors.logsMenuLogBackgroundCol)

        drawPlayerInfo(1, h * .77, h, TEXT_ALIGN_LEFT)
        drawInfo(w, h / 2)

        draw.SimpleText(self.Data.Amount, "GlorifiedBanking.AdminMenu.LogMoney", w * .99, h / 2, self.Data.Type == "Withdrawal" and self.Theme.Data.Colors.logsMenuLogMoneyNegativeTextCol or self.Theme.Data.Colors.logsMenuLogMoneyPositiveTextCol, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
    end

    if self.Data.Type != "Transfer" then return end

    function self:Paint(w, h)
        draw.RoundedBox(h * .1, 0, 0, w, h, self.Theme.Data.Colors.logsMenuLogBackgroundCol)

        drawPlayerInfo(1, h * .77, h, TEXT_ALIGN_LEFT)
        drawPlayerInfo(2, w - h * .82, h, TEXT_ALIGN_RIGHT)
        drawInfo(w, h * .7)

        draw.SimpleText(self.Data.Amount, "GlorifiedBanking.AdminMenu.LogMoney", w / 2, h * .3, self.Theme.Data.Colors.logsMenuLogPlayerNameTextCol, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
end

function PANEL:PerformLayout(w, h)
    if IsValid(self.Avatar) then
        local avatarsize = h * .65
        local avatarpadx, avatarpady = h * .08, h * .18

        self.Avatar:SetSize(avatarsize, avatarsize)
        self.Avatar:SetMaskSize(avatarsize * .5)
        self.Avatar:SetPos(avatarpadx, avatarpady)
        self.Avatar:SetSteamID(self.Data.SteamID64, avatarsize)

        if IsValid(self.Avatar2) then
            self.Avatar2:SetSize(avatarsize, avatarsize)
            self.Avatar2:SetMaskSize(avatarsize * .5)
            self.Avatar2:SetPos(w - avatarpadx - avatarsize, avatarpady)
            self.Avatar2:SetSteamID(self.Data.ReceiverSteamID64, avatarsize)
        end
    end
end

vgui.Register("GlorifiedBanking.Log", PANEL, "Panel")
