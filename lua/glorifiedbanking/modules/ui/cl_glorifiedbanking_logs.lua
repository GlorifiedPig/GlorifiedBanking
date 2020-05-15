
local PANEL = {}

local logStruct = {
    type = "Withdrawal",
    time = "19:05:16",
    date = "14/04/2020",
    amount = "-$10,000,000",
    username = "Tom.bat",
    steamid = "STEAM:0:123123123",
    username2 = "Tom.bat",
    steamid2 = "STEAM:0:123123123",
}

local logStructForTransfers = {
    type = "Transfer",
    time = "19:05:16",
    date = "14/04/2020",
    amount = "-$10,000,000",
    username = "Tom.bat",
    steamid = "STEAM:0:123123123"
}

function PANEL:Init()
    self.Theme = self:GetParent().Theme

    self.TopBar = vgui.Create("Panel", self)
    self.TopBar.Paint = function(s, w, h)
        draw.SimpleText("Transaction Type", "GlorifiedBanking.AdminMenu.TransactionTypeSelect", w * .024, h / 2, self.Theme.Data.Colors.logsMenuTransactionTypeTextCol, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end

    self.ScrollPanel = vgui.Create("GlorifiedBanking.ScrollPanel", self)

    self.Paginator = vgui.Create("GlorifiedBanking.Paginator", self)

    self.Logs = {}
    for i = 1, 20 do
        self.Logs[i] = vgui.Create("GlorifiedBanking.Log", self.ScrollPanel)
        self.Logs[i].Data = math.Rand(1, 2) == 1 and logStruct or logStructForTransfers
        self.Logs[i].Theme = self.Theme
    end
end

function PANEL:PerformLayout(w, h)
    self.TopBar:SetSize(w, h * .04)
    self.TopBar:Dock(TOP)

    self.ScrollPanel:Dock(FILL)
    self.ScrollPanel:DockPadding(0, 0, w * .013, 0)

    self.Paginator:SetSize(w, h * .1)
    self.Paginator:Dock(BOTTOM)

    local logh = h * .09
    local logmarginx, logmarginy = w * .026, h * .008
    for k,v in ipairs(self.Logs) do
        v:SetHeight(logh)
        v:Dock(TOP)
        v:DockMargin(logmarginx, logmarginy, logmarginx, logmarginy)
    end
end

vgui.Register("GlorifiedBanking.Logs", PANEL, "Panel")
