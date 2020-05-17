
local PANEL = {}

function PANEL:Init()
    self.Theme = self:GetParent().Theme

    self.TopBar = vgui.Create("Panel", self)
    self.TopBar.Theme = self:GetParent().Theme
    self.TopBar.Paint = function(s, w, h)
        draw.SimpleText(i18n.GetPhrase("gbPlayersOnline", 20), "GlorifiedBanking.AdminMenu.TransactionTypeSelect", w * .024, h * .46, self.Theme.Data.Colors.logsMenuTransactionTypeTextCol, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end

    self.ScrollPanel = vgui.Create("GlorifiedBanking.ScrollPanel", self)

    self.Players = {}
    for i = 1, 20 do
        self.Players[i] = vgui.Create("GlorifiedBanking.Player", self.ScrollPanel)
        self.Players[i].Theme = self.Theme
        self.Players[i]:AddPlayer(LocalPlayer(), math.random(100, 10000000))
    end
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
