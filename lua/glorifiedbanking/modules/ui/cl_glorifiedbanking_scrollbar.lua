
local PANEL = {}

function PANEL:Init()
    self:SetHideButtons(true)

    self.btnGrip.Color = Color(255, 255, 255)
    self.btnGrip.Paint = function(s, w, h)
        s.Color = GlorifiedBanking.UI.LerpColor(FrameTime() * 15, s.Color, s:IsHovered() and self.Theme.Data.Colors.scrollBarHoverCol or self.Theme.Data.Colors.scrollBarCol)
        draw.RoundedBox(w * .46, 0, 0, w, h, s.Color)
    end
end

function PANEL:Paint(w, h) end

function PANEL:SetEnabled(b)
    if not b then
        self.Offset = 0
        self:SetScroll(0)
        self.HasChanged = true
    end

    self:SetMouseInputEnabled(b)

    self:SetVisible(b)

    if self.Enabled ~= b then
        self:GetParent():InvalidateLayout()

        if self:GetParent().OnScrollbarAppear then
            self:GetParent():OnScrollbarAppear()
        end
    end

    self.Enabled = b
end

function PANEL:GetEnabled()
    return self.Enabled
end

function PANEL:Value()
    return self.Pos
end

function PANEL:BarScale()
    if self.BarSize == 0 then return 1 end

    return self.BarSize / (self.CanvasSize + self.BarSize)
end

function PANEL:SetUp(_barSize_, _canvasSize_)
    self.BarSize = _barSize_
    self.CanvasSize = math.max(_canvasSize_ - _barSize_, 1)

    self:SetEnabled(_canvasSize_ > _barSize_)

    self:InvalidateLayout()
end

function PANEL:OnMouseWheeled(dlta)
    if not self:IsVisible() then return false end

    return self:AddScroll(dlta * -2)
end

function PANEL:AddScroll(dlta)
    local oldScroll = self:GetScroll()

    dlta = dlta * 25
    self:SetScroll(oldScroll + dlta)

    return oldScroll ~= self:GetScroll()
end

function PANEL:SetScroll(scrll)
    if not self.Enabled then self.Scroll = 0 return end

    self.Scroll = math.Clamp(scrll, 0, self.CanvasSize + 75)

    self:InvalidateLayout()

    local func = self:GetParent().OnVScroll
    if func then
        func(self:GetParent(), self:GetOffset())
    else
        self:GetParent():InvalidateLayout()
    end
end

function PANEL:LimitScroll()
    if self.Scroll < 0 or self.Scroll > self.CanvasSize then
        self.Scroll = math.Clamp(self.Scroll, -75, self.CanvasSize + 75)
    end
end

function PANEL:AnimateTo(scrll, length, delay, ease)
    local anim = self:NewAnimation(length, delay, ease)
    anim.StartPos = self.Scroll
    anim.TargetPos = scrll
    anim.Think = function(animtable, pnl, fraction)
        pnl:SetScroll(Lerp(fraction, animtable.StartPos, anim.TargetPos))
    end
end

function PANEL:GetScroll()
    if not self.Enabled then self.Scroll = 0 end
    return self.Scroll
end

function PANEL:GetOffset()
    if not self.Enabled then return 0 end
    return self.Scroll * -1
end

function PANEL:Think() end

function PANEL:OnMousePressed()
    local y = select(2, self:CursorPos())

    local pageSize = self.BarSize

    if y > self.btnGrip.y then
        self:SetScroll(self:GetScroll() + pageSize)
    else
        self:SetScroll(self:GetScroll() - pageSize)
    end
end

function PANEL:OnMouseReleased()
    self.Dragging = false
    self.DraggingCanvas = nil
    self:MouseCapture(false)

    self.btnGrip.Depressed = false
end

function PANEL:OnCursorMoved(x, y)
    if not self.Enabled or not self.Dragging then return end

    y = select(2, self:ScreenToLocal(0, gui.MouseY()))

    y = y - self.HoldPos

    local trackSize = self:GetTall() - self.btnGrip:GetTall()
    y = y / trackSize

    self:SetScroll(math.Clamp(y * self.CanvasSize, 0, self.CanvasSize))
end

function PANEL:Grip()
    if not self.Enabled or self.BarSize == 0 then return end

    self:MouseCapture(true)
    self.Dragging = true

    local y = select(2, self.btnGrip:ScreenToLocal(0, gui.MouseY()))
    self.HoldPos = y

    self.btnGrip.Depressed = true
end

function PANEL:PerformLayout(w, h)
    self:LimitScroll()

    local scroll = self:GetScroll() / self.CanvasSize
    local barSize = math.max(self:BarScale() * self:GetTall(), 10)
    local track = self:GetTall() - barSize
    track = track + 1

    scroll = scroll * track

    local barStart = math.max(scroll, 0)
    local barEnd = math.min(scroll + barSize, self:GetTall())

    self.btnGrip:SetPos(0, barStart)
    self.btnGrip:SetSize(w, barEnd - barStart)
end

vgui.Register("GlorifiedBanking.ScrollBar", PANEL, "DVScrollBar")
