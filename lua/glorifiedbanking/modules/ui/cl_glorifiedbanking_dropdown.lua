
local PANEL = {}

function PANEL:Init()
    self.Theme = self:GetParent().Theme

    self.DropButton:SetVisible(false)

    self:SetFont("GlorifiedBanking.AdminMenu.Dropdown")
    self:SetColor(self.Theme.Data.Colors.dropdownSelectedTextCol)

    self.BackgroundColour = Color(0, 0, 0)
end

function PANEL:Paint(w, h)
    self.BackgroundColour = GlorifiedBanking.UI.LerpColor(FrameTime() * 10, self.BackgroundColour, self:IsHovered() and self.Theme.Data.Colors.dropdownBackgroundHoverCol or self.Theme.Data.Colors.dropdownBackgroundCol)

    draw.RoundedBox(h * .2, 0, 0, w, h, self.BackgroundColour)
end

vgui.Register("GlorifiedBanking.Dropdown", PANEL, "DComboBox")
