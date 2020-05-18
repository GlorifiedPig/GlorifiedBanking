
local PANEL = {}

function PANEL:Init()
    net.Start("GlorifiedBanking.AdminPanel.PlayerListOpened")
    net.SendToServer()

    self.Theme = self:GetParent().Theme

    self.TopBar = vgui.Create("Panel", self)
    self.TopBar.Theme = self:GetParent().Theme
    self.TopBar.Paint = function(s, w, h)
        draw.SimpleText(i18n.GetPhrase("gbPlayersOnline", #self.Players), "GlorifiedBanking.AdminMenu.TransactionTypeSelect", w * .024, h * .46, self.Theme.Data.Colors.logsMenuTransactionTypeTextCol, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end

    self.ScrollPanel = vgui.Create("GlorifiedBanking.ScrollPanel", self)

    self.Players = {}
end

function PANEL:AddPlayer(ply)
    local playerid = #self.Players

    self.Players[playerid] = vgui.Create("GlorifiedBanking.Player", self.ScrollPanel)
    self.Players[playerid].Theme = self.Theme
    self.Players[playerid]:AddPlayer(ply, ply.Balance)
end

function PANEL:ResetPlayers()
    self.ScrollPanel:Clear()
    table.Empty(self.Players)
end

function PANEL:PerformLayout(w, h)
    self.TopBar:SetSize(w, h * .05)
    self.TopBar:Dock(TOP)

    self.ScrollPanel:Dock(FILL)
    self.ScrollPanel:DockMargin(0, 0, 0, h * .02)
    self.ScrollPanel:DockPadding(0, 0, w * .013, 0)

    local plyh = h * .08
    local plymarginx, plymarginy = w * .026, h * .008
    for k,v in ipairs(self.Players) do
        v:SetHeight(plyh)
        v:Dock(TOP)
        v:DockMargin(plymarginx, plymarginy, plymarginx, plymarginy)
    end
end

vgui.Register("GlorifiedBanking.Players", PANEL, "Panel")

net.Receive("GlorifiedBanking.AdminPanel.PlayerListOpened.SendInfo", function()
    local players = util.JSONToTable(net.ReadLargeString())
    if not players then return end

    local panel = GlorifiedBanking.UI.AdminMenu.Page
    if not panel.ResetPlayers then return end

    panel:ResetPlayers()

    for k,v in ipairs(players) do
        panel:AddPlayer(v)
    end
end)
