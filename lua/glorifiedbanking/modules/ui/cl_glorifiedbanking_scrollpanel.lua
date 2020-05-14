
local PANEL = {}

function PANEL:Init()
    function self.VBar:Paint(w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 100))
    end

    function self.VBar.btnUp:Paint(w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(200, 100, 0))
    end

    function self.VBar.btnDown:Paint(w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(200, 100, 0))
    end

    function self.VBar.btnGrip:Paint(w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(100, 200, 0))
    end
end

vgui.Register("GlorifiedBanking.ScrollPanel", PANEL, "DScrollPanel")
