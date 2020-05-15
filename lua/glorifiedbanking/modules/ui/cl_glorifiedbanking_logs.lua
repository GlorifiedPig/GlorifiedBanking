
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
        draw.SimpleText(i18n.GetPhrase("gbTransactionType"), "GlorifiedBanking.AdminMenu.TransactionTypeSelect", w * .024, h / 2, self.Theme.Data.Colors.logsMenuTransactionTypeTextCol, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
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

    self.Logs = {}
    for i = 1, 20 do
        self.Logs[i] = vgui.Create("GlorifiedBanking.Log", self.ScrollPanel)
        self.Logs[i].Theme = self.Theme
        self.Logs[i]:AddData(math.random(1, 2) == 1 and logStruct or logStructForTransfers)
    end
end

function PANEL:PerformLayout(w, h)
    self.TopBar:SetSize(w, h * .04)
    self.TopBar:Dock(TOP)

    surface.SetFont("GlorifiedBanking.AdminMenu.TransactionTypeSelect")
    local dropx = surface.GetTextSize(i18n.GetPhrase("gbTransactionType"))

    self.TransactionTypeSelect:SetSize(w * .1, h * .032)
    self.TransactionTypeSelect:SetPos(w * .024 + dropx + w * .01,  h * .008)
    self.TransactionTypeSelect:SizeToContents()

    self.ScrollPanel:Dock(FILL)
    self.ScrollPanel:DockPadding(0, 0, w * .013, 0)

    self.Paginator:SetSize(w, h * .05)
    self.Paginator:Dock(BOTTOM)

    local logh = h * .08
    local logmarginx, logmarginy = w * .026, h * .008
    for k,v in ipairs(self.Logs) do
        v:SetHeight(logh)
        v:Dock(TOP)
        v:DockMargin(logmarginx, logmarginy, logmarginx, logmarginy)
    end
end

vgui.Register("GlorifiedBanking.Logs", PANEL, "Panel")
