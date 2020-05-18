
local PANEL = {}

local logStruct = {
    type = "Deposit",
    time = "19:05:16",
    date = "14/04/2020",
    amount = "$10,000,000",
    username = "Tom.bat",
    steamid = "STEAM_0:0:127595314"
}

local logStructForTransfers = {
    type = "Transfer",
    time = "19:05:16",
    date = "14/04/2020",
    amount = "$10,000,000",
    username = "Tom.bat",
    steamid = "STEAM_0:0:127595314",
    username2 = "GlorifiedPig",
    steamid2 = "STEAM_0:0:56521306",
}

function PANEL:Init()
    self.Theme = self:GetParent().Theme

    self.TopBar = vgui.Create("Panel", self)
    self.TopBar.Theme = self:GetParent().Theme
    self.TopBar.Paint = function(s, w, h)
        draw.SimpleText(i18n.GetPhrase("gbTransactionType"), "GlorifiedBanking.AdminMenu.TransactionTypeSelect", self.Back and w * .06 or w * .024, h * .46, self.Theme.Data.Colors.logsMenuTransactionTypeTextCol, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end

    self.TransactionTypeSelect = vgui.Create("GlorifiedBanking.Dropdown", self.TopBar)

    self.TransactionTypeSelect:AddChoice(i18n.GetPhrase("gbTypeAll"))
    self.TransactionTypeSelect:AddChoice(i18n.GetPhrase("gbTypeWithdrawals"))
    self.TransactionTypeSelect:AddChoice(i18n.GetPhrase("gbTypeDeposits"))
    self.TransactionTypeSelect:AddChoice(i18n.GetPhrase("gbTypeTransfers"))
    self.TransactionTypeSelect:ChooseOptionID(1)

    self.TransactionTypeSelect.OnSelect = function(s, index, value, data)
        s:SizeToContents()
    end

    self.ScrollPanel = vgui.Create("GlorifiedBanking.ScrollPanel", self)

    self.Paginator = vgui.Create("GlorifiedBanking.Paginator", self)
    self.Paginator:SetupPaginator(100)

    self.Logs = {}
    timer.Simple(0, function()
        if self.SteamID then return end

        for i = 1, 20 do
            self.Logs[i] = vgui.Create("GlorifiedBanking.Log", self.ScrollPanel)
            self.Logs[i].Theme = self.Theme
            self.Logs[i]:AddData(math.random(1, 2) == 1 and logStruct or logStructForTransfers)
        end
    end)
end

function PANEL:SetSteamID(steamid)
    self.SteamID = steamid

    self.Back = vgui.Create("DButton", self.TopBar)
    self.Back:SetText("")

    self.Back.Color = self.Theme.Data.Colors.adminMenuNavbarItemCol
    self.Back.Paint = function(s, w, h)
        s.Color = GlorifiedBanking.UI.LerpColor(FrameTime() * 5, s.Color, s:IsHovered() and self.Theme.Data.Colors.logsMenuBackButtonHoverCol or self.Theme.Data.Colors.logsMenuBackButtonCol)

        local iconSize = h * .8
        surface.SetDrawColor(s.Color)
        surface.SetMaterial(self.Theme.Data.Materials.chevron)
        surface.DrawTexturedRectRotated(w / 2, h / 2, iconSize, iconSize, 180)
    end

    self.Back.DoClick = function(s)
        self:AlphaTo(0, 0.15, 0, function(anim, panel)
            self:Remove()

            local menuPanel = self:GetParent()
            menuPanel.Page = vgui.Create("GlorifiedBanking.Players", menuPanel)
            menuPanel.Page:Dock(FILL)
            menuPanel.Page:SetAlpha(0)
            menuPanel.Page:AlphaTo(255, 0.15)
        end)
    end

    local oldDraw = self.TopBar.Paint
    self.TopBar.Paint = function(s, w, h)
        oldDraw(s, w, h)
        draw.SimpleText(i18n.GetPhrase("gbTransactionLogsFor", steamid), "GlorifiedBanking.AdminMenu.TransactionTypeSelect", w - w * .024, h * .46, self.Theme.Data.Colors.logsMenuTransactionTypeTextCol, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
    end
end

function PANEL:PerformLayout(w, h)
    self.TopBar:SetSize(w, h * .05)
    self.TopBar:Dock(TOP)

    local topOffset = 0
    if IsValid(self.Back) then
        self.Back:SetSize(h * .032, h * .032)
        self.Back:SetPos(w * .018,  h * .011)

        topOffset = h * .032 + w * .002
    end

    surface.SetFont("GlorifiedBanking.AdminMenu.TransactionTypeSelect")
    topOffset = topOffset + surface.GetTextSize(i18n.GetPhrase("gbTransactionType"))

    self.TransactionTypeSelect:SetSize(w * .1, h * .032)
    self.TransactionTypeSelect:SetPos(topOffset + w * .035,  h * .011)
    self.TransactionTypeSelect:SizeToContents()

    self.ScrollPanel:Dock(FILL)
    self.ScrollPanel:DockPadding(0, 0, w * .013, 0)

    if IsValid(self.Paginator) then
        self.Paginator:SetSize(w, h * .07)
        self.Paginator:Dock(BOTTOM)
    end

    local logh = h * .08
    local logmarginx, logmarginy = w * .026, h * .008
    for k,v in ipairs(self.Logs) do
        v:SetHeight(logh)
        v:Dock(TOP)
        v:DockMargin(logmarginx, logmarginy, logmarginx, logmarginy)
    end
end

vgui.Register("GlorifiedBanking.Logs", PANEL, "Panel")
