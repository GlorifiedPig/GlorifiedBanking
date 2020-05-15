
local PANEL = {}

function PANEL:Paint(w, h)
    draw.RoundedBox(h * .13, 0, 0, w, h, self.Theme.Data.Colors.logsMenuLogBackgroundCol)
end

vgui.Register("GlorifiedBanking.Log", PANEL, "Panel")
