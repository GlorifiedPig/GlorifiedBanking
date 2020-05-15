
local PANEL = {}

local lerp = Lerp
local function lerpColor(t, from, to)
    local col = Color(0, 0, 0)

    col.r = lerp(t, from.r, to.r)
    col.g = lerp(t, from.g, to.g)
    col.b =  lerp(t, from.b, to.b)

    return col
end
function PANEL:Init()
    self.Theme = self:GetParent().Theme

    self.VBar:SetHideButtons(true)

    function self.VBar:Paint(w, h) end

    self.VBar.btnGrip.Color = Color(255, 255, 255)
    self.VBar.btnGrip.Paint = function(s, w, h)
        s.Color = lerpColor(FrameTime() * 15, s.Color, s:IsHovered() and self.Theme.Data.Colors.scrollBarHoverCol or self.Theme.Data.Colors.scrollBarCol)
        draw.RoundedBox(w, 0, 0, w, h, s.Color)
    end
end

function PANEL:PerformLayout(w, h)
    if not (w or h) then return end

    self.VBar:SetWidth(w * .018)
    self.VBar:Dock(RIGHT)

    self:Rebuild()

    self.VBar:SetUp(h, self.pnlCanvas:GetTall())

    if self.VBar.Enabled then w = w - self.VBar:GetWide() end

    self.pnlCanvas:SetPos(0, self.VBar:GetOffset())
    self.pnlCanvas:SetWide(w)

    self:Rebuild()

    if h != self.pnlCanvas:GetTall() then
        self.VBar:SetScroll(self.VBar:GetScroll())
    end
end

vgui.Register("GlorifiedBanking.ScrollPanel", PANEL, "DScrollPanel")
