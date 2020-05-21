
local PANEL = {}

function PANEL:Init()
    self:SetMouseInputEnabled(true)
end

function PANEL:Think()
    if self.Dragging then
        local mousex = math.Clamp(gui.MouseX(), 1, ScrW() - 1)
        local mousey = math.Clamp(gui.MouseY(), 1, ScrH() - 1)

        local x = mousex - self.Dragging[1]
        local y = mousey - self.Dragging[2]

        local parentw, parenty = self:GetParent():GetSize()

        x = math.Clamp(x, 0, parentw - self:GetWide())
        y = math.Clamp(y, 0, parenty - self:GetTall())

        self:SetPos(x, y)
    end
end

function PANEL:OnMousePressed()
    self.Dragging = {gui.MouseX() - self.x, gui.MouseY() - self.y}
    self:MouseCapture(true)
end

function PANEL:OnMouseReleased()
    self.Dragging = nil
    self:MouseCapture(false)

    self:OnDropped(self:GetPos())
end

function PANEL:OnDropped(x, y) end

vgui.Register("GlorifiedBanking.DraggableLabel", PANEL, "DLabel")
