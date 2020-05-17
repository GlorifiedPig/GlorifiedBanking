
local PANEL = {}

function PANEL:Init()
    self.Theme = self:GetParent().Theme

    self.Buttons = {}
    self.SelectedTab = 0
end

function PANEL:PerformLayout(w, h)
    surface.SetFont("GlorifiedBanking.AdminMenu.NavbarItem")

    for k,v in ipairs(self.Buttons) do
        v:SetSize((v.Text == "X" and w * .055) or (v.Text == "LOCK" and w * .28) or surface.GetTextSize(v.Text) + w * .06, h)
        v:Dock(v.DockType)
    end
end

local lerp = Lerp

function PANEL:AddItem(name, dockType, onClick)
    local button = vgui.Create("DButton", self)
    button.Text = name
    button.DockType = dockType

    local btnID = #self.Buttons + 1
    button.DoClick = function(s)
        if self:SelectTab(btnID) then return end
        onClick(s)
    end

    button:SetText("")
    button.Color = self.Theme.Data.Colors.adminMenuNavbarItemCol

    if name == "X" then
        button.Paint = function(s, w, h)
            local iconSize = h * .4

            s.Color = GlorifiedBanking.UI.LerpColor(FrameTime() * 5, s.Color, s:IsHovered() and self.Theme.Data.Colors.adminMenuCloseButtonHoverCol or self.Theme.Data.Colors.adminMenuCloseButtonCol)

            surface.SetDrawColor(s.Color)
            surface.SetMaterial(self.Theme.Data.Materials.close)
            surface.DrawTexturedRect(w / 2 - iconSize / 2, h / 2 - iconSize / 2, iconSize, iconSize)
         end
    elseif name == "LOCK" then
        button.Paint = function(s, w, h)
            s.Color = GlorifiedBanking.UI.LerpColor(FrameTime() * 5, s.Color, button.Selected and self.Theme.Data.Colors.adminMenuNavbarSelectedItemCol or self.Theme.Data.Colors.adminMenuNavbarItemCol)

            draw.SimpleText(i18n.GetPhrase("gbAdminMenuLockdown"), "GlorifiedBanking.AdminMenu.NavbarItem", w / 2, h / 2, s.Color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
    else
        button.UnderlineY = 0

        button.Paint = function(s, w, h)
            local underlineh = math.Round(h * .06)

            s.UnderlineY = lerp(FrameTime() * 13, s.UnderlineY, (button.Selected or s:IsHovered()) and 0 or underlineh)
            s.Color = GlorifiedBanking.UI.LerpColor(FrameTime() * 5, s.Color, button.Selected and self.Theme.Data.Colors.adminMenuNavbarSelectedItemCol or self.Theme.Data.Colors.adminMenuNavbarItemCol)

            local underliney = math.Round(h - underlineh + s.UnderlineY)

            surface.SetDrawColor(s.Color)
            surface.DrawRect(0, underliney, w, underlineh)

            draw.SimpleText(s.Text, "GlorifiedBanking.AdminMenu.NavbarItem", w / 2, underliney / 2, s.Color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
    end

    self.Buttons[btnID] = button
end

function PANEL:SelectTab(id)
    if self.SelectedTab == id then return true end
    if not self.Buttons[id] then return true end
    if self.Buttons[id].Text == "LOCK" then return false end

    for k,v in ipairs(self.Buttons) do
        v.Selected = k == id
    end

    self.SelectedTab = id
end

function PANEL:Paint(w, h)
    draw.RoundedBoxEx(6, 0, 0, w, h, self.Theme.Data.Colors.adminMenuNavbarBackgroundCol, true, true, false, false)
end

vgui.Register("GlorifiedBanking.AdminNavbar", PANEL, "Panel")
