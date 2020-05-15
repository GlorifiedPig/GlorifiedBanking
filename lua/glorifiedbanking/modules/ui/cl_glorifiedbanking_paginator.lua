
local PANEL = {}

function PANEL:Init()
    self.Theme = self:GetParent().Theme

    self.ItemsPerPage = 20
    self.ItemCountSelector = vgui.Create("GlorifiedBanking.Dropdown", self)

    self.ItemCountSelector:SetSortItems(false)

    self.ItemCountSelector:AddChoice("5")
    self.ItemCountSelector:AddChoice("10")
    self.ItemCountSelector:AddChoice("20")
    self.ItemCountSelector:AddChoice("50")
    self.ItemCountSelector:ChooseOptionID(4)

    self.Buttons = {}
end

function PANEL:Paint(w, h)
    draw.SimpleText(i18n.GetPhrase("gbItemsPerPage"), "GlorifiedBanking.AdminMenu.PaginatorPerPage", w * .024, h * .42, self.Theme.Data.Colors.logsMenuTransactionTypeTextCol, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
end

function PANEL:ClearButtons()
    for k,v in ipairs(self.Buttons) do
        v:Remove()
    end
end

function PANEL:SetupPaginator(itemcount)
    self:ClearButtons()
end

function PANEL:PerformLayout(w, h)
    surface.SetFont("GlorifiedBanking.AdminMenu.PaginatorPerPage")
    local dropx = surface.GetTextSize(i18n.GetPhrase("gbItemsPerPage"))

    self.ItemCountSelector:SetSize(10, h * .8)
    self.ItemCountSelector:SetPos(w * .024 + dropx + w * .01, h * .18)
    self.ItemCountSelector:SizeToContents()
end

vgui.Register("GlorifiedBanking.Paginator", PANEL, "Panel")
