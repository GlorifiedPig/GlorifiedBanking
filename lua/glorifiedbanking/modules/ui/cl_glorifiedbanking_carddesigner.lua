
local PANEL = {}

local defId = "Filf1VB"
local defNameX, defNameY = .042, .73
local defIdX, defIdY = .042, .85

function PANEL:Init()
    self:SetSize(ScrH() * .6, ScrH() * .6)
    self:Center()
    self:MakePopup()

    self.Theme = GlorifiedBanking.Themes.GetCurrent()

    self.Close = vgui.Create("DButton", self)
    self.Close:SetText("")

    self.Close.DoClick = function(s)
        self:Remove()
    end

    self.Close.Color = Color(255, 255, 255)
    self.Close.Paint = function(s, w, h)
        local iconSize = h * .5

        s.Color = GlorifiedBanking.UI.LerpColor(FrameTime() * 5, s.Color, s:IsHovered() and self.Theme.Data.Colors.adminMenuCloseButtonHoverCol or self.Theme.Data.Colors.adminMenuCloseButtonCol)

        surface.SetDrawColor(s.Color)
        surface.SetMaterial(self.Theme.Data.Materials.close)
        surface.DrawTexturedRect(w / 2 - iconSize / 2, h / 2 - iconSize / 2, iconSize, iconSize)
    end

    self.Entry = vgui.Create("DTextEntry", self)
    self.Entry:SetValue(defId)
    self.Entry:SetFont("GlorifiedBanking.AdminMenu.SetBalanceEntry")
    self.Entry:SetUpdateOnType(true)

    self.Entry.OnValueChange = function(s, value)
        GlorifiedBanking.UI.GetImgur(value, function(mat)
            self.CardMaterial = mat
        end)
    end

    self.CardPreview = vgui.Create("Panel", self)
    self.CardPreview.Paint = function(s, w, h)
        surface.SetDrawColor(color_white)
        surface.SetMaterial(self.CardMaterial or GlorifiedBanking.CardMaterial)
        surface.DrawTexturedRect(0, 0, w, h)
    end

    local ply = LocalPlayer()
    local id = ply:SteamID64():sub(-16)
    local cardID = id:sub(1, 4)
    for i = 4, 15, 4 do
        cardID = cardID .. " " .. id:sub(i, i + 3)
    end

    self.CardPreview.CardID = vgui.Create("GlorifiedBanking.DraggableLabel", self.CardPreview)
    self.CardPreview.CardID:SetText(cardID)
    self.CardPreview.CardID:SetFont("GlorifiedBanking.CardDesigner.CardInfo")
    self.CardPreview.CardID:SetTextColor(self.Theme.Data.Colors.cardNumberTextCol)
    self.CardPreview.CardID:SizeToContents()
    self.CardPreview.CardID.Pos = {defIdX, defIdY}

    function self.CardPreview.CardID:OnDropped(x, y)
        local pw, ph = self:GetParent():GetSize()
        self.Pos = {x / pw, y / ph}
    end

    self.CardPreview.CardName = vgui.Create("GlorifiedBanking.DraggableLabel", self.CardPreview)
    self.CardPreview.CardName:SetText(ply:Name())
    self.CardPreview.CardName:SetFont("GlorifiedBanking.CardDesigner.CardInfo")
    self.CardPreview.CardName:SetTextColor(self.Theme.Data.Colors.cardNameTextCol)
    self.CardPreview.CardName:SizeToContents()
    self.CardPreview.CardName.Pos = {defNameX, defNameY}

    function self.CardPreview.CardName:OnDropped(x, y)
        local pw, ph = self:GetParent():GetSize()
        self.Pos = {x / pw, y / ph}
    end

    self.Save = vgui.Create("DButton", self)
    self.Save:SetText("")

    self.Save.Color = Color(255, 255, 255)
    self.Save.Paint = function(s, w, h)
        s.Color = GlorifiedBanking.UI.LerpColor(FrameTime() * 10, s.Color, s:IsHovered() and self.Theme.Data.Colors.setBalanceButtonBackgroundHoverCol or self.Theme.Data.Colors.setBalanceButtonBackgroundCol)

        draw.RoundedBox(h * .08, 0, 0, w, h, s.Color)
        draw.SimpleText(i18n.GetPhrase("gbSave"), "GlorifiedBanking.AdminMenu.SetBalanceButton", w / 2, h * .43, self.Theme.Data.Colors.setBalanceButtonTextCol, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    self.Save.DoClick = function(s)
        local parentWide = self.CardPreview:GetWide()

        local idCenterPos = (self.CardPreview.CardID:GetPos() + self.CardPreview.CardID:GetWide() / 2) / parentWide
        local idAlign = (idCenterPos > .4 and idCenterPos < .6) and 2 or idCenterPos > .6 and 1 or 0

        local nameCenterPos = (self.CardPreview.CardName:GetPos() + (self.CardPreview.CardName:GetWide() / 2)) / parentWide
        local nameAlign = (nameCenterPos > .4 and nameCenterPos < .6) and 1 or nameCenterPos > .6 and 2 or 0

        net.Start( "GlorifiedBanking.CardDesigner.SendDesignInfo" )
         net.WriteString( self.Entry:GetValue() )
         net.WriteFloat( self.CardPreview.CardID.Pos[1] )
         net.WriteFloat( self.CardPreview.CardID.Pos[2] )
         net.WriteUInt( nameAlign, 2)
         net.WriteFloat( self.CardPreview.CardName.Pos[1] )
         net.WriteFloat( self.CardPreview.CardName.Pos[2] )
         net.WriteUInt( idAlign, 2 )
        net.Send( recipients )

        self:Remove()
    end

    self.Reset = vgui.Create("DButton", self)
    self.Reset:SetText("")

    self.Reset.Color = Color(255, 255, 255)
    self.Reset.Paint = function(s, w, h)
        s.Color = GlorifiedBanking.UI.LerpColor(FrameTime() * 10, s.Color, s:IsHovered() and self.Theme.Data.Colors.resetBalanceNoButtonBackgroundHoverCol or self.Theme.Data.Colors.resetBalanceNoButtonBackgroundCol)

        draw.RoundedBox(h * .08, 0, 0, w, h, s.Color)
        draw.SimpleText(i18n.GetPhrase("gbResetDefaults"), "GlorifiedBanking.AdminMenu.SetBalanceButton", w / 2, h * .43, self.Theme.Data.Colors.setBalanceButtonTextCol, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    self.Reset.DoClick = function(s)
        self.Entry:SetValue(defId)
        self:ResetText()
    end
end

function PANEL:ResetText()
    local cardw, cardh = self.CardPreview:GetSize()
    self.CardPreview.CardID:SetPos(cardw * defNameX, cardh * defNameY)
    self.CardPreview.CardID.Pos = {defNameX, defNameY}

    self.CardPreview.CardName:SetPos(cardw * defIdX, cardh * defIdY)
    self.CardPreview.CardID.Pos = {defIdX, defIdY}
end

function PANEL:PerformLayout(w, h)
    self.Close:SetSize(h * .06, h * .06)
    self.Close:SetPos(w - h * .06, 0)

    self.Entry:SetSize(w * .97, h * .06)
    self.Entry:SetPos(w * .015, h * .12)

    local cardh = h * .55
    local cardw = 420 / 240 * cardh
    self.CardPreview:SetSize(cardw, cardh)
    self.CardPreview:SetPos((w - cardw) * .5, h * .225)

    self:ResetText()

    self.Save:SetSize(w * .97, h * .07)
    self.Save:SetPos(w * .015, h * .82)

    self.Reset:SetSize(w * .97, h * .07)
    self.Reset:SetPos(w * .015, h * .91)
end

function PANEL:Paint(w, h)
    draw.RoundedBox(6, 0, 0, w, h, self.Theme.Data.Colors.adminMenuBackgroundCol)
    draw.RoundedBoxEx(6, 0, 0, w, h * .06, self.Theme.Data.Colors.adminMenuNavbarBackgroundCol, true, true)

    draw.SimpleText(i18n.GetPhrase("gbCardDesigner"), "GlorifiedBanking.AdminMenu.SetBalanceTitle", w * .013, h * .028, self.Theme.Data.Colors.adminMenuNavbarItemCol, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    draw.SimpleText(i18n.GetPhrase("gbEnterImgur"), "GlorifiedBanking.AdminMenu.SetBalanceDescription", w * .013, h * .07, self.Theme.Data.Colors.adminMenuNavbarItemCol)
end

vgui.Register("GlorifiedBanking.CardDesigner", PANEL, "EditablePanel")

if not IsValid(LocalPlayer()) then return end

if IsValid(GlorifiedBanking.UI.CardDesigner) then
    GlorifiedBanking.UI.CardDesigner:Remove()
    GlorifiedBanking.UI.CardDesigner = nil
end

GlorifiedBanking.UI.CardDesigner = vgui.Create("GlorifiedBanking.CardDesigner")
