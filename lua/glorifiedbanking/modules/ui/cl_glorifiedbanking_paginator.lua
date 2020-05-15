
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

function PANEL:OnPageSelected(no)
    print("Selected page: " .. no)
end

function PANEL:SelectPage(no)
    if no < 1 or no > self.PageCount then return end

    self.SelectedPage = no

    local buttonNo = (no - 2 > 0 and self.PageCount > 10) and no - 2 or 1
    for k,v in ipairs(self.Buttons) do
        if not tonumber(v.Text) then continue end

        v.Text = tostring(buttonNo)
        v.DoClick = function(s)
            self:SelectPage(buttonNo)
        end

        v.Selected = no == buttonNo
        buttonNo = buttonNo + 1
    end

    self:OnPageSelected(no)
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

    btn.BackgroundColour = Color(0, 0, 0, 0)
    btn.Paint = function(s, w, h)
        if drawbg then
            s.BackgroundColour = GlorifiedBanking.UI.LerpColor(FrameTime() * 10, s.BackgroundColour, s:IsHovered() and self.Theme.Data.Colors.paginatorArrowButtonBackgroundHoverCol or self.Theme.Data.Colors.paginatorArrowButtonBackgroundCol)
        else
            s.BackgroundColour = GlorifiedBanking.UI.LerpColor(FrameTime() * 10, s.BackgroundColour, s.Selected and self.Theme.Data.Colors.paginatorNumberButtonSelectedBackgroundCol or s:IsHovered() and self.Theme.Data.Colors.paginatorNumberButtonBackgroundHoverCol or self.Theme.Data.Colors.paginatorNumberButtonBackgroundCol)
        end

        draw.RoundedBox(h * .15, 0, 0, w, h, s.BackgroundColour)
        draw.SimpleText(s.Text, "GlorifiedBanking.AdminMenu.PaginatorButton", w / 2, h / 2, self.Theme.Data.Colors.paginatorButtonTextCol, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    return btn
end

function PANEL:SetupPaginator(itemcount)
    self:ClearButtons()

    self.ItemCount = itemcount
    self.PageCount = math.floor(itemcount / self.ItemsPerPage)

    if self.PageCount <= 1 then
        self:Remove()
        return
    end

    if self.PageCount > 10 then
        self.Buttons[1] = self:CreatePageButton("<<", true, function(s)
            self:SelectPage(1)
        end)
    end

    self.Buttons[#self.Buttons + 1] = self:CreatePageButton("<", true, function(s)
        self:SelectPage(self.SelectedPage - 1)
    end)

    for i = 1, math.min(self.PageCount, 10) do
        self.Buttons[#self.Buttons + 1] = self:CreatePageButton(tostring(i), false, function(s)
            self:SelectPage(i)
        end)
    end

    self.Buttons[#self.Buttons + 1] = self:CreatePageButton(">", true, function(s)
        self:SelectPage(self.SelectedPage + 1)
    end)

    if self.PageCount > 10 then
        self.Buttons[#self.Buttons + 1] = self:CreatePageButton(">>", true, function(s)
            self:SelectPage(self.PageCount)
        end)
    end

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
