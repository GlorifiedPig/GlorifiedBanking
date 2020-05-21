
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

        x = math.Clamp(x, 0, ScrW() - self:GetWide())
        y = math.Clamp(y, 0, ScrH() - self:GetTall())

        self:SetPos(x, y)
    end
end

function PANEL:OnMousePressed()
    self.Dragging = { gui.MouseX() - self.x, gui.MouseY() - self.y }
    self:MouseCapture( true )
end

function PANEL:OnMouseReleased()
    self.Dragging = nil
    self:MouseCapture( false )
end

vgui.Register("GlorifiedBanking.DraggableLabel", PANEL, "DLabel")
