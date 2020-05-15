
local PANEL = {}

function PANEL:Init()
    self.Theme = self:GetParent().Theme

    self.DropButton:SetVisible(false)

    self:SetFont("GlorifiedBanking.AdminMenu.Dropdown")
    self:SetColor(self.Theme.Data.Colors.dropdownSelectedTextCol)
end

function PANEL:Paint(w, h)
    surface.SetFont("GlorifiedBanking.AdminMenu.Dropdown")

    draw.RoundedBox(h * .2, 0, 0, w, h, self.Theme.Data.Colors.dropdownBackgroundCol)
end

vgui.Register("GlorifiedBanking.Dropdown", PANEL, "DComboBox")
