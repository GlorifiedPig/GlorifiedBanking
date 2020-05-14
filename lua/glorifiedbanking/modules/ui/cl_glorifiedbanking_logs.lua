
local PANEL = {}

local logStruct= {
    type = "Withdrawal",
    time = "19:05:16",
    date = "14/04/2020",
    amount = "-$10,000,000",
    username = "Tom.bat",
    steamid = "STEAM:0:123123123",
    username2 = "Tom.bat",
    steamid2 = "STEAM:0:123123123",
}

local logStructForTransfers = {
    type = "Transfer",
    time = "19:05:16",
    date = "14/04/2020",
    amount = "-$10,000,000",
    username = "Tom.bat",
    steamid = "STEAM:0:123123123"
}

function PANEL:Init()
    self.Logs = {}
end

function PANEL:PerformLayout(w, h)
    for k,v in ipairs(self.Logs) do
        v:Dock(TOP)
    end
end

vgui.Register("GlorifiedBanking.Logs", PANEL, "DScrollPanel")
