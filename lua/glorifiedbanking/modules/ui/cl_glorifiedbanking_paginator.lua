
local PANEL = {}

function PANEL:Init()
    self.Theme = self:GetParent().Theme

    self.ItemsPerPage = 20
    self.ItemCount = 1000
    self.PageCount = 0
    self.SelectedPage = 0

    self.ItemCountSelector = vgui.Create("GlorifiedBanking.Dropdown", self)

    self.ItemCountSelector:SetSortItems(false)

    self.ItemCountSelector:AddChoice(5)
    self.ItemCountSelector:AddChoice(10)
    self.ItemCountSelector:AddChoice(20)
    self.ItemCountSelector:AddChoice(50)
    self.ItemCountSelector:ChooseOptionID(3)

    self.ItemCountSelector.OnSelect = function(s, index, value, data)
        s:SizeToContents()

        self.ItemsPerPage = value
        self:SetupPaginator(self.ItemCount)
    end

    self.Buttons = {}
end

function PANEL:Paint(w, h)
    draw.SimpleText(i18n.GetPhrase("gbItemsPerPage"), "GlorifiedBanking.AdminMenu.PaginatorPerPage", w * .024, h * .48, self.Theme.Data.Colors.logsMenuTransactionTypeTextCol, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
end

function PANEL:SelectPage(no)
    if no < 1 or no > self.PageCount then return end

    self.SelectedPage = no

    for k,v in ipairs(self.Buttons) do
        v.Selected = v.Text == tostring(no)
    end

    print("Selected page: " .. no)
end

function PANEL:ClearButtons()
    for k,v in ipairs(self.Buttons) do
        v:Remove()
        self.Buttons[k] = nil
    end
end

function PANEL:CreatePageButton(text, drawbg, onClick)
    local btn = vgui.Create("DButton", self)

    btn.Text = text
    btn:SetText("")
    btn.DoClick = onClick

    btn.Paint = function(s, w, h)
        if drawbg then
            draw.RoundedBox(h * .2, 0, 0, w, h, s.Selected and self.Theme.Data.Colors.paginatorButtonSelectedBackgroundCol or self.Theme.Data.Colors.paginatorButtonBackgroundCol)
        else
            if s.Selected then
                draw.RoundedBox(h * .2, 0, 0, w, h, self.Theme.Data.Colors.paginatorButtonSelectedBackgroundCol)
            end
        end

        draw.SimpleText(text, "GlorifiedBanking.AdminMenu.PaginatorButton", w / 2, h / 2, self.Theme.Data.Colors.paginatorButtonTextCol, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    return btn
end

function PANEL:SetupPaginator(itemcount)
    self:ClearButtons()

    self.ItemCount = itemcount
    self.PageCount = math.floor(itemcount / self.ItemsPerPage)
    self.SelectedPage = 0

    self.Buttons[1] = self:CreatePageButton("<<", true, function(s)
        self:SelectPage(1)
    end)

    self.Buttons[2] = self:CreatePageButton("<", true, function(s)
        self:SelectPage(self.SelectedPage - 1)
    end)

    for i = 1, math.min(self.PageCount, 10) do
        self.Buttons[i + 2] = self:CreatePageButton(tostring(i), false, function(s)
            self:SelectPage(i)
        end)
    end

    local btncount = #self.Buttons

    self.Buttons[btncount + 1] = self:CreatePageButton(">", true, function(s)
        self:SelectPage(self.SelectedPage + 1)
    end)

    self.Buttons[btncount + 2] = self:CreatePageButton(">>", true, function(s)
        self:SelectPage(self.PageCount)
    end)

    self:SelectPage(1)
end

function PANEL:PerformLayout(w, h)
    surface.SetFont("GlorifiedBanking.AdminMenu.PaginatorPerPage")
    local dropx = surface.GetTextSize(i18n.GetPhrase("gbItemsPerPage"))

    self.ItemCountSelector:SetSize(10, h * .8)
    self.ItemCountSelector:SetPos(w * .024 + dropx + w * .008, h * .3)
    self.ItemCountSelector:SizeToContents()

    local btncount = #self.Buttons
    local btnsize = w * .034
    local btnx, btny = w / 2 - (btncount * btnsize + (btncount * w * .005)) / 2, h * .27

    for k,v in ipairs(self.Buttons) do
        v:SetSize(btnsize, btnsize)
        v:SetPos(btnx, btny)

        btnx = btnx + btnsize + w * .005
    end
end

vgui.Register("GlorifiedBanking.Paginator", PANEL, "Panel")
