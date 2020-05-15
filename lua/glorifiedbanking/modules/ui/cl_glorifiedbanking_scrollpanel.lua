
local PANEL = {}

function PANEL:Init()
    self.Theme = self:GetParent().Theme

    self.scrollDelta = 0
    self.scrollReturnWait = 0

    self.VBar:Remove()
    self.VBar = vgui.Create("GlorifiedBanking.ScrollBar", self)
    self.VBar.Theme = self.Theme

    self:InvalidateLayout(true)
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

function PANEL:Think()
    if not self.lastThink then self.lastThink = CurTime() end
    local elapsed = CurTime() - self.lastThink
    self.lastThink = CurTime()

    if self.scrollDelta > 0 then
        self.VBar:OnMouseWheeled(self.scrollDelta / 1)

        if self.VBar.Scroll >= 0 then
            self.scrollDelta = self.scrollDelta - 10 * elapsed
        end
        if self.scrollDelta < 0 then self.scrollDelta = 0 end
    elseif self.scrollDelta < 0 then
        self.VBar:OnMouseWheeled(self.scrollDelta / 1)

        if self.VBar.Scroll <= self.VBar.CanvasSize then
            self.scrollDelta = self.scrollDelta + 10 * elapsed
        end
        if self.scrollDelta > 0 then self.scrollDelta = 0 end
    end

    if self.scrollReturnWait >= 1 then
        if self.VBar.Scroll < 0 then
            if self.VBar.Scroll <= -75 and self.scrollDelta > 0 then self.scrollDelta = self.scrollDelta / 2 end

            self.scrollDelta = self.scrollDelta + (self.VBar.Scroll / 1500 - 0.01) * 100 * elapsed

        elseif self.VBar.Scroll > self.VBar.CanvasSize then
            if self.VBar.Scroll >= self.VBar.CanvasSize + 75 and self.scrollDelta < 0 then self.scrollDelta = self.scrollDelta / 2 end

            self.scrollDelta = self.scrollDelta + ((self.VBar.Scroll - self.VBar.CanvasSize) / 1500 + 0.01) * 100 * elapsed
        end
    else
        self.scrollReturnWait = self.scrollReturnWait + 10 * elapsed
    end
end

function PANEL:OnMouseWheeled(delta)
    if (delta > 0 and self.VBar.Scroll <= self.VBar.CanvasSize * 0.005) or
            (delta < 0 and self.VBar.Scroll >= self.VBar.CanvasSize * 0.995) then
        self.scrollDelta = self.scrollDelta + delta / 10
        return
    end

    self.scrollDelta = delta / 2
    self.scrollReturnWait = 0
end

function PANEL:OnVScroll(iOffset)
    self.pnlCanvas:SetPos(0, iOffset)
end

function PANEL:ScrollToChild(panel)
    self:PerformLayout()

    local x, y = self.pnlCanvas:GetChildPosition(panel)
    local w, h = panel:GetSize()

    y = y + h * 0.5;
    y = y - self:GetTall() * 0.5;

    self.VBar:AnimateTo(y, 0.5, 0, 0.5);
end

vgui.Register("GlorifiedBanking.ScrollPanel", PANEL, "DScrollPanel")
