
include("shared.lua")

local imgui = GlorifiedBanking.imgui
imgui.DisableDeveloperMode = true

--Enums for animations
local GB_ANIM_IDLE = 0
local GB_ANIM_MONEY_IN = 1
local GB_ANIM_MONEY_OUT = 2
local GB_ANIM_CARD_IN = 3
local GB_ANIM_CARD_OUT = 4

--Localise the theme data
local theme = GlorifiedBanking.Themes.GetCurrent()
hook.Add("GlorifiedBanking.ThemeUpdated", "GlorifiedBanking.ATMEntity.ThemeUpdated", function(newTheme)
    theme = newTheme
end)

--Transaction log networking
net.Receive("GlorifiedBanking.ChangeScreen.SendLogs", function()
    local ent = net.ReadEntity()
    if not IsValid(ent) then return end

    local data = util.JSONToTable(net.ReadLargeString())

    for k,v in ipairs(data) do
        v.Amount = GlorifiedBanking.FormatMoney(v.Amount)
        v.Date = os.date("%d/%m/%y - %H:%M", v.Date)

        if v.ReceiverSteamID then
            v.Username = v.SteamID
        end

        v.MoneyColor = (v.Type == "Deposit" and theme.Data.Colors.transactionListEntryMoneyPositiveCol) or (v.Type == "Transfer" and v.ReceiverSteamID and theme.Data.Colors.transactionListEntryMoneyPositiveCol) or theme.Data.Colors.transactionListEntryMoneyNegativeCol
    end

    ent.ScreenData.Transactions = table.Copy(data)
end)

ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

--Check for the required screen data here
ENT.CurrentUsername = ""
ENT.ScreenData = {}
function ENT:Think()
    if not self.LocalPlayer then self.LocalPlayer = LocalPlayer() end

    if self.RequiresAttention and (not self.LastAttentionBeep or CurTime() > self.LastAttentionBeep + 1.25) then
        self:EmitSound("GlorifiedBanking.Beep_Attention")
        self.LastAttentionBeep = CurTime()
    end

    local currentUser = self:GetCurrentUser()
    local currentScreen = self.Screens[self:GetScreenID()]

    if currentUser != NULL then
        self.CurrentUsername = currentUser:Name()
    end

    if currentScreen.loggedIn and currentUser == NULL then
        self.ShouldDrawCurrentScreen = false
        return
    end

    if currentScreen.requiredData then
        if self.ScreenData then
            for k, v in ipairs(currentScreen.requiredData) do
                if self.ScreenData[k] then continue end
                self.ShouldDrawCurrentScreen = false
                return
            end
        else
            self.ShouldDrawCurrentScreen = false
            return
        end
    end

    self.ShouldDrawCurrentScreen = true
end

--Insert card method, used by the SWEP for future card reading entities
function ENT:InsertCard()
    if self:GetCurrentUser() != NULL then
        GlorifiedBanking.Notify(NOTIFY_ERROR, 5, gbi18n.GetPhrase("gbCardAtmInUse"))
        return
    end

    net.Start("GlorifiedBanking.CardInserted")
     net.WriteEntity(self)
    net.SendToServer()
end

--Loading screen manager
ENT.OldScreenID = 0
ENT.OldScreenData = {}
function ENT:OnScreenChange(name, old, new)
    self.OldScreenID = old
    self.OldScreenData = table.Copy(self.ScreenData)
    self.ScreenData = {}

    timer.Simple(1.2, function() --Minimum load time of 1.2 seconds to let the full anim play
        self.OldScreenID = 0
        self.OldScreenData = {}
        self.KeyPadBuffer = ""
    end)
end

--Main draw hook
function ENT:DrawTranslucent()
    self:DrawModel()

    if not self.LocalPlayer then return end
    if self.LocalPlayer:GetPos():DistToSqr(self:GetPos()) > 1000 * 1000 then return end

    self:DrawScreen()
    self:DrawKeypad()
    self:DrawSign()

    self:DrawAnimations()
end

--Draw the background of the screen and navbar
local scrw, scrh = 1286, 1129
local windoww, windowh = scrw-60, scrh-188
local windowx, windowy = 30, 158
local centerx, centery = windowx + windoww * .5, windowy + windowh * .5
function ENT:DrawScreenBackground(showExit, backPage)
    local hovering = false

    surface.SetDrawColor(theme.Data.Colors.backgroundCol)
    surface.DrawRect(0, 0, scrw, scrh)

    draw.RoundedBox(8, 10, 10, 100, 100, theme.Data.Colors.logoBackgroundCol)
    surface.SetDrawColor(theme.Data.Colors.logoCol)
    surface.SetMaterial(theme.Data.Materials.logoSmall)
    surface.DrawTexturedRect(15, 15, 90, 90)

    if backPage and backPage > 0 then
        if (imgui.IsHovering(scrw-220, 10, 100, 100)) then
            hovering = true
            draw.RoundedBox(8, scrw-220, 10, 100, 100, theme.Data.Colors.backBackgroundHoverCol)

            if imgui.IsPressed() then
                net.Start("GlorifiedBanking.ChangeScreen")
                 net.WriteUInt(3, 4)
                 net.WriteEntity(self)
                net.SendToServer()
            end
        else
            draw.RoundedBox(8, scrw-220, 10, 100, 100, theme.Data.Colors.backBackgroundCol)
        end
        surface.SetDrawColor(theme.Data.Colors.backCol)
        surface.SetMaterial(theme.Data.Materials.back)
        surface.DrawTexturedRect(scrw-205, 25, 70, 70)
    end

    if showExit then
        if imgui.IsHovering(scrw-110, 10, 100, 100) then
            hovering = true
            draw.RoundedBox(8, scrw-110, 10, 100, 100, theme.Data.Colors.exitBackgroundHoverCol)

            if imgui.IsPressed() then
                net.Start("GlorifiedBanking.Logout")
                 net.WriteEntity(self)
                net.SendToServer()
            end
        else
            draw.RoundedBox(8, scrw-110, 10, 100, 100, theme.Data.Colors.exitBackgroundCol)
        end
        surface.SetDrawColor(theme.Data.Colors.exitCol)
        surface.SetMaterial(theme.Data.Materials.exit)
        surface.DrawTexturedRect(scrw-95, 25, 70, 70)
    end

    draw.SimpleText(string.upper(gbi18n.GetPhrase("gbSystemName")), "GlorifiedBanking.ATMEntity.Title", 125, 110, theme.Data.Colors.titleTextCol, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)

    draw.RoundedBox(6, 0, 120, scrw, 10, theme.Data.Colors.titleBarCol)

    surface.SetDrawColor(theme.Data.Colors.innerBoxBackgroundCol)
    surface.DrawRect(windowx, windowy, windoww, windowh)

    draw.RoundedBox(2, windowx, windowy, windoww, 4, theme.Data.Colors.innerBoxBorderCol)
    draw.RoundedBox(2, windowx, windowy + windowh - 4, windoww, 4, theme.Data.Colors.innerBoxBorderCol)

    return hovering
end

--Force load networking
net.Receive("GlorifiedBanking.ForceLoad", function()
    local ent = net.ReadEntity()
    local reason = net.ReadString()

    ent.ForcedLoad = reason != ""
    ent.ForcedLoadReason = reason
end)

--Draw the loading screen + animate it
ENT.LoadingScreenX = -scrw
ENT.LoadingScreenH = 300
function ENT:DrawLoadingScreen()
    if self.ForcedLoad or not self.ShouldDrawCurrentScreen or self.OldScreenID > 0 then
        self.LoadingScreenX = Lerp(FrameTime() * 8, self.LoadingScreenX, 30)

        if self.LoadingScreenX > 18 then
            self.LoadingScreenH = Lerp(FrameTime() * 8, self.LoadingScreenH, windowh)
        end
    else
        self.LoadingScreenH = Lerp(FrameTime() * 8, self.LoadingScreenH, 300)

        if self.LoadingScreenH < 320 then
            self.LoadingScreenX = Lerp(FrameTime() * 8, self.LoadingScreenX, -scrw)
        end
    end

    if self.LoadingScreenX < -(scrw - 40) then return end

    if self.OldScreenID > 0 and self.Screens[self.OldScreenID] and self.OldScreenData then
        self.Screens[self.OldScreenID].drawFunction(self, self.OldScreenData)
    end

    GlorifiedBanking.UI.StartCutOut(function()
        surface.SetDrawColor(color_white)
        surface.DrawRect(0, 0, scrw, scrh)
    end)

    local y = centery - self.LoadingScreenH / 2

    surface.SetDrawColor(theme.Data.Colors.loadingScreenBackgroundCol)
    surface.DrawRect(self.LoadingScreenX, y, windoww, self.LoadingScreenH)

    draw.RoundedBox(2, self.LoadingScreenX, y, windoww, 4, theme.Data.Colors.loadingScreenBorderCol)
    draw.RoundedBox(2, self.LoadingScreenX, y + self.LoadingScreenH - 4, windoww, 4, theme.Data.Colors.loadingScreenBorderCol)

    surface.SetDrawColor(theme.Data.Colors.loadingScreenSpinnerCol)
    surface.SetMaterial(theme.Data.Materials.circle)

    local animprog = CurTime() * 2.5
    surface.DrawTexturedRect(self.LoadingScreenX + windoww / 2 - 80, centery - 60 + math.sin(animprog + 1) * 20, 40, 40)
    surface.DrawTexturedRect(self.LoadingScreenX + windoww / 2 - 20, centery - 60 + math.sin(animprog + .5) * 20, 40, 40)
    surface.DrawTexturedRect(self.LoadingScreenX + windoww / 2 + 40, centery - 60 + math.sin(animprog) * 20, 40, 40)

    draw.SimpleText(self.ForcedLoad and self.ForcedLoadReason or gbi18n.GetPhrase("gbLoading"), "GlorifiedBanking.ATMEntity.Loading", self.LoadingScreenX + windoww / 2, centery + 50, theme.Data.Colors.loadingScreenTextCol, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

    GlorifiedBanking.UI.EndCutOut()
end

--Manage the idle screen slideshow globally rather than per-entity
local idleScreenSlideID = 1
local idleScreenSlideScale = 1
local idleScreenOldSlideAlpha = 0
local idleScreenOldSlideID = 1
hook.Add("PostRender", "GlorifiedBanking.ATMEntity.PostRender", function()
    idleScreenSlideScale = idleScreenSlideScale + FrameTime() * .01

    if idleScreenSlideScale > 1.15 then
        idleScreenOldSlideID = idleScreenSlideID
        idleScreenSlideID = idleScreenSlideID == #theme.Data.Materials.idleSlideshow and 1 or idleScreenSlideID + 1
        idleScreenSlideScale = 1
        idleScreenOldSlideAlpha = 255
    end

    if idleScreenOldSlideAlpha > 0 then
        idleScreenOldSlideAlpha = idleScreenOldSlideAlpha - FrameTime() * 80
    end
end)

--Define all of our screen drawing functions
ENT.Screens[1].drawFunction = function(self, data) --Idle screen
    GlorifiedBanking.UI.StartCutOut(function()
        surface.SetDrawColor(color_white)
        surface.DrawRect(windowx, windowy + 4, windoww, windowh - 8)
    end)

    surface.SetDrawColor(theme.Data.Colors.idleScreenSlideshowCol)
    surface.SetMaterial(theme.Data.Materials.idleSlideshow[idleScreenSlideID])

    local slidew, slideh = windoww * idleScreenSlideScale, windowh * idleScreenSlideScale
    surface.DrawTexturedRect(centerx - slidew * .5, centery - slideh * .5, slidew, slideh)

    if idleScreenOldSlideAlpha > 0 then
        surface.SetDrawColor(ColorAlpha(theme.Data.Colors.idleScreenSlideshowCol, idleScreenOldSlideAlpha))
        surface.SetMaterial(theme.Data.Materials.idleSlideshow[idleScreenOldSlideID])

        slidew, slideh = windoww * 1.15, windowh * 1.15
        surface.DrawTexturedRect(centerx - slidew * .5, centery - slideh * .5, slidew, slideh)
    end

    GlorifiedBanking.UI.EndCutOut()

    local msgw, msgh = windoww * .6, windowh * .2
    draw.RoundedBox(12, windowx + (windoww-msgw) * .5, windowy + (windowh-msgh) * .5, msgw, msgh, theme.Data.Colors.idleScreenMessageBackgroundCol)

    local linew, lineh = msgw * .8, 4
    local liney = windowy + windowh * .5 - 2
    draw.SimpleText(gbi18n.GetPhrase("gbEnterCard"), "GlorifiedBanking.ATMEntity.EnterCard", centerx, liney - 55, theme.Data.Colors.loadingScreenTextCol, TEXT_ALIGN_CENTER)

    draw.RoundedBox(2,  windowx + (windoww-linew) * .5, liney, linew, lineh, theme.Data.Colors.idleScreenSeperatorCol)
    draw.SimpleText(gbi18n.GetPhrase("gbToContinue"), "GlorifiedBanking.ATMEntity.EnterCardSmall", centerx, liney + 8, theme.Data.Colors.loadingScreenTextCol, TEXT_ALIGN_CENTER)
end

ENT.Screens[2].drawFunction = function(self, data) --Lockdown screen
    local msgw, msgh = windoww * .95, 100
    draw.RoundedBoxEx(8, windowx + (windoww-msgw) * .5, windowy + 35, msgw, msgh, theme.Data.Colors.lockdownMessageBackgroundCol, false, false, true, true)
    draw.RoundedBox(2, windowx + (windoww-msgw) * .5, windowy + 35, msgw, 4, theme.Data.Colors.lockdownMessageLineCol)
    draw.DrawText(gbi18n.GetPhrase("gbAtmDisabled"), "GlorifiedBanking.ATMEntity.Lockdown", centerx, windowy + 45, theme.Data.Colors.lockdownTextCol, TEXT_ALIGN_CENTER)

    msgh = 50
    draw.RoundedBoxEx(8, windowx + (windoww-msgw) * .5, windowy + windowh - 80, msgw, msgh, theme.Data.Colors.lockdownMessageBackgroundCol, false, false, true, true)
    draw.RoundedBox(2, windowx + (windoww-msgw) * .5, windowy + windowh - 80, msgw, 4, theme.Data.Colors.lockdownMessageLineCol)

    local iconsize = 30

    surface.SetFont("GlorifiedBanking.ATMEntity.LockdownSmall")
    local contenty = windowy + windowh - 73
    local contentw = iconsize + 10 + surface.GetTextSize(gbi18n.GetPhrase("gbBackShortly"))

    surface.SetDrawColor(theme.Data.Colors.lockdownWarningIconCol)
    surface.SetMaterial(theme.Data.Materials.warning)
    surface.DrawTexturedRect(centerx - contentw * .5, contenty + 5, iconsize, iconsize)

    draw.SimpleText(gbi18n.GetPhrase("gbBackShortly"), "GlorifiedBanking.ATMEntity.LockdownSmall", centerx + contentw * .5, contenty, theme.Data.Colors.lockdownTextCol, TEXT_ALIGN_RIGHT)

    iconsize = 400
    surface.SetDrawColor(theme.Data.Colors.lockdownIconCol)
    surface.SetMaterial(theme.Data.Materials.lockdown)
    surface.DrawTexturedRect(centerx - iconsize * .5, centery - iconsize * .5, iconsize, iconsize)
end

local menuButtons = {
    {
        name = gbi18n.GetPhrase("gbMenuWithdraw"),
        pressFunc = function(self)
            net.Start("GlorifiedBanking.ChangeScreen")
             net.WriteUInt(4, 4)
             net.WriteEntity(self)
            net.SendToServer()
        end
    },
    {
        name = gbi18n.GetPhrase("gbMenuDeposit"),
        pressFunc = function(self)
            net.Start("GlorifiedBanking.ChangeScreen")
             net.WriteUInt(5, 4)
             net.WriteEntity(self)
            net.SendToServer()
        end
    },
    {
        name = gbi18n.GetPhrase("gbMenuTransfer"),
        pressFunc = function(self)
            net.Start("GlorifiedBanking.ChangeScreen")
             net.WriteUInt(6, 4)
             net.WriteEntity(self)
            net.SendToServer()
        end
    },
    {
        name = gbi18n.GetPhrase("gbMenuTransactions"),
        pressFunc = function(self)
            net.Start("GlorifiedBanking.ChangeScreen")
             net.WriteUInt(7, 4)
             net.WriteEntity(self)
            net.SendToServer()
        end
    }
}

ENT.Screens[3].drawFunction = function(self, data) --Main Menu
    surface.SetFont("GlorifiedBanking.ATMEntity.WelcomeBack")
    local contenty = windowy + 150
    local iconsize = 32
    local text = gbi18n.GetPhrase("gbWelcomeBack", string.upper(self.CurrentUsername))
    local contentw = iconsize + 6 + surface.GetTextSize(text)

    surface.SetDrawColor(theme.Data.Colors.menuUserIconCol)
    surface.SetMaterial(theme.Data.Materials.user)
    surface.DrawTexturedRect(centerx - contentw * .5, contenty + 5, iconsize, iconsize)

    draw.SimpleText(text, "GlorifiedBanking.ATMEntity.WelcomeBack", centerx + contentw * .5, contenty, theme.Data.Colors.menuUserTextCol, TEXT_ALIGN_RIGHT)

    contentw = contentw + 15
    draw.RoundedBox(2, windowx + (windoww-contentw) * .5, contenty + 42, contentw, 4, theme.Data.Colors.menuUserUnderlineCol)

    local hovering = false

    local btnw, btnh = windoww * .95, 100
    local btnspacing = 30
    local btnx, btny = windowx + (windoww-btnw) * .5, 40 + windowy + (windowh - ((#menuButtons * btnh) + #menuButtons * btnspacing)) * .5

    for k,v in ipairs(menuButtons) do
        if imgui.IsHovering(btnx, btny, btnw, btnh) then
            hovering = true
            draw.RoundedBoxEx(8, btnx, btny, btnw, btnh, theme.Data.Colors.menuButtonHoverCol, true, true)
            draw.RoundedBox(2, btnx, btny + btnh - 4, btnw, 4, theme.Data.Colors.menuButtonUnderlineCol)

            if imgui.IsPressed() then
                v.pressFunc(self)
            end
        else
            draw.RoundedBox(8, btnx, btny, btnw, btnh, theme.Data.Colors.menuButtonBackgroundCol)
        end

        draw.SimpleText(v.name, "GlorifiedBanking.ATMEntity.MenuButton", btnx + btnw * .5, btny + btnh * .5, theme.Data.Colors.menuButtonTextCol, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

        btny = btny + btnh + btnspacing
    end

    return hovering
end

local function drawTypeAmountScreen(self, topHint, buttonText, buttonIcon, bottomHint, disclaimer, onPress)
    surface.SetFont("GlorifiedBanking.ATMEntity.AccountBalance")
    local contenty = windowy + 110
    local iconsize = 46
    local text

    if self:GetCurrentUser() != self.LocalPlayer then
        text = gbi18n.GetPhrase("gbAccountBalance", gbi18n.GetPhrase("gbHidden"))
    else
        text = gbi18n.GetPhrase("gbAccountBalance", GlorifiedBanking.FormatMoney(GlorifiedBanking.GetPlayerBalance()))
    end

    local contentw = iconsize + 12 + surface.GetTextSize(text)

    surface.SetDrawColor(theme.Data.Colors.balanceIconCol)
    surface.SetMaterial(theme.Data.Materials.money)
    surface.DrawTexturedRect(centerx - contentw * .5, contenty + 5, iconsize, iconsize)

    draw.SimpleText(text, "GlorifiedBanking.ATMEntity.AccountBalance", centerx + contentw * .5, contenty, theme.Data.Colors.balanceTextCol, TEXT_ALIGN_RIGHT)

    contentw = contentw + 15
    draw.RoundedBox(2, windowx + (windoww-contentw) * .5, contenty + 52, contentw, 4, theme.Data.Colors.balanceUnderlineCol)

    local msgw, msgh = windoww * .95, 60
    local msgy = centery - 203
    draw.RoundedBoxEx(8, centerx - msgw * .5, msgy, msgw, msgh, theme.Data.Colors.transactionMessageBackgroundCol, false, false, true, true)
    draw.RoundedBox(2, windowx + (windoww-msgw) * .5, msgy, msgw, 4, theme.Data.Colors.transactionMessageLineCol)
    draw.SimpleText(topHint, "GlorifiedBanking.ATMEntity.TransactionHint", centerx, msgy + 10, theme.Data.Colors.transactionTextCol, TEXT_ALIGN_CENTER)

    msgh = 46
    msgy = centery + 160
    draw.RoundedBoxEx(8, centerx - msgw * .5, msgy - 7, msgw, msgh, theme.Data.Colors.transactionMessageBackgroundCol, false, false, true, true)
    draw.RoundedBox(2, centerx - msgw * .5, msgy - 7, msgw, 4, theme.Data.Colors.transactionMessageLineCol)

    iconsize = 25

    surface.SetFont("GlorifiedBanking.ATMEntity.TransactionFee")
    contentw = iconsize + 10 + surface.GetTextSize(bottomHint)

    surface.SetDrawColor(theme.Data.Colors.transactionWarningIconCol)
    surface.SetMaterial(theme.Data.Materials.warning)
    surface.DrawTexturedRect(centerx - contentw * .5, msgy + 5, iconsize, iconsize)

    draw.SimpleText(bottomHint, "GlorifiedBanking.ATMEntity.TransactionFee", centerx + contentw * .5, msgy, theme.Data.Colors.transactionTextCol, TEXT_ALIGN_RIGHT)

    msgy = windowy + windowh - 40
    iconsize = 20

    surface.SetFont("GlorifiedBanking.ATMEntity.TransactionDisclaimer")
    contentw = iconsize + 6 + surface.GetTextSize(disclaimer)

    surface.SetDrawColor(theme.Data.Colors.transactionWarningIconCol)
    surface.SetMaterial(theme.Data.Materials.warning)
    surface.DrawTexturedRect(centerx - contentw * .5, msgy + 4, iconsize, iconsize)

    draw.SimpleText(disclaimer, "GlorifiedBanking.ATMEntity.TransactionDisclaimer", centerx + contentw * .5, msgy, theme.Data.Colors.transactionTextCol, TEXT_ALIGN_RIGHT)

    msgy, msgh = centery + 35, 110
    draw.RoundedBox(8, centerx - msgw * .5, msgy - 10, msgw, msgh, theme.Data.Colors.transactionButtonOutlineCol)

    msgw, msgh = windoww * .93, 90
    local hovering = false

    local amount = self:GetKeypadContent()
    if imgui.IsHovering(centerx - msgw * .5, msgy, msgw, msgh) then
        hovering = true
        draw.RoundedBox(6, centerx - msgw * .5, msgy, msgw, msgh, theme.Data.Colors.transactionButtonHoverCol)

        if imgui.IsPressed() then
            onPress(self, amount)
        end
    else
        draw.RoundedBox(6, centerx - msgw * .5, msgy, msgw, msgh, theme.Data.Colors.transactionButtonBackgroundCol)
    end

    iconsize = 38

    surface.SetFont("GlorifiedBanking.ATMEntity.TransactionButton")
    contentw = iconsize + 15 + surface.GetTextSize(buttonText)

    msgy = msgy + 14
    surface.SetDrawColor(theme.Data.Colors.transactionIconCol)
    surface.SetMaterial(buttonIcon)
    surface.DrawTexturedRect(centerx - contentw * .5, msgy + 12, iconsize, iconsize)
    draw.SimpleText(buttonText, "GlorifiedBanking.ATMEntity.TransactionButton", centerx + contentw * .5, msgy, theme.Data.Colors.transactionTextCol, TEXT_ALIGN_RIGHT)

    msgw, msgh, msgy =  windoww * .95, 80, centery - 115
    draw.RoundedBox(8, centerx - msgw * .5, msgy - 10, msgw, msgh, theme.Data.Colors.transactionEntryOutlineCol)
    msgw, msgh = windoww * .93, 60
    draw.RoundedBox(6, centerx - msgw * .5, msgy, msgw, msgh, theme.Data.Colors.transactionEntryBackgroundCol)

    draw.SimpleText(amount > 0 and GlorifiedBanking.FormatMoney(amount) or gbi18n.GetPhrase("gbTransactionTypeAmount"), "GlorifiedBanking.ATMEntity.TransactionEntry", centerx, msgy + msgh / 2 - 3, amount > 0 and theme.Data.Colors.transactionEntryTextPopulatedCol or theme.Data.Colors.transactionEntryTextCol, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

    return hovering
end

--Button press/submit button press method for withdrawals
ENT.Screens[4].onEnterPressed = function(self, amount)
    self.KeyPadBuffer = ""

    net.Start("GlorifiedBanking.WithdrawalRequested")
     net.WriteUInt(amount, 32)
     net.WriteEntity(self)
    net.SendToServer()
end

ENT.Screens[4].drawFunction = function(self, data) --Withdrawal screen
    return drawTypeAmountScreen(
        self,
        gbi18n.GetPhrase("gbWithdrawAmount"),
        gbi18n.GetPhrase("gbMenuWithdraw"),
        theme.Data.Materials.transaction,
        self:GetWithdrawalFee() > 0 and gbi18n.GetPhrase("gbWithdrawalHasFee", self:GetWithdrawalFee()) or gbi18n.GetPhrase("gbWithdrawalFree"),
        gbi18n.GetPhrase("gbWithdrawalDisclaimer"),
        self.Screens[4].onEnterPressed
    )
end

--Button press/submit button press method for deposits
ENT.Screens[5].onEnterPressed = function(self, amount)
    self.KeyPadBuffer = ""

    net.Start("GlorifiedBanking.DepositRequested")
     net.WriteUInt(amount, 32)
     net.WriteEntity(self)
    net.SendToServer()
end

ENT.Screens[5].drawFunction = function(self, data) --Deposit screen
    return drawTypeAmountScreen(
        self,
        gbi18n.GetPhrase("gbDepositAmount"),
        gbi18n.GetPhrase("gbMenuDeposit"),
        theme.Data.Materials.transaction,
        self:GetDepositFee() > 0 and gbi18n.GetPhrase("gbDepositHasFee", self:GetDepositFee()) or gbi18n.GetPhrase("gbDepositFree"),
        gbi18n.GetPhrase("gbDepositDisclaimer"),
        self.Screens[5].onEnterPressed
    )
end

ENT.Screens[6].onEnterPressed = function(self, amount)
    if not IsValid(self.ScreenData.selected) then
        GlorifiedBanking.Notify(NOTIFY_ERROR, 5, gbi18n.GetPhrase("gbSelectPlayer"))
        self:EmitSound("GlorifiedBanking.Beep_Error")
        return
    end

    net.Start("GlorifiedBanking.TransferRequested")
        net.WriteUInt(amount, 32)
        net.WriteEntity(self)
        net.WriteEntity(self.ScreenData.selected)
    net.SendToServer()
end

ENT.Screens[6].drawFunction = function(self, data) --Transfer screen
    surface.SetFont("GlorifiedBanking.ATMEntity.AccountBalance")
    local contenty = windowy + 25
    local iconsize = 46
    local text

    if self:GetCurrentUser() != self.LocalPlayer then
        text = gbi18n.GetPhrase("gbAccountBalance", gbi18n.GetPhrase("gbHidden"))
    else
        text = gbi18n.GetPhrase("gbAccountBalance", GlorifiedBanking.FormatMoney(GlorifiedBanking.GetPlayerBalance()))
    end

    local contentw = iconsize + 12 + surface.GetTextSize(text)

    surface.SetDrawColor(theme.Data.Colors.balanceIconCol)
    surface.SetMaterial(theme.Data.Materials.money)
    surface.DrawTexturedRect(centerx - contentw * .5, contenty + 5, iconsize, iconsize)

    draw.SimpleText(text, "GlorifiedBanking.ATMEntity.AccountBalance", centerx + contentw * .5, contenty, theme.Data.Colors.balanceTextCol, TEXT_ALIGN_RIGHT)

    contentw = contentw + 15
    draw.RoundedBox(2, windowx + (windoww-contentw) * .5, contenty + 50, contentw, 4, theme.Data.Colors.menuUserUnderlineCol)

    local msgw, msgh = windoww * .95, 46
    local msgy = windowy + windowh - 79

    draw.RoundedBoxEx(8, centerx - msgw * .5, msgy - 7, msgw, msgh, theme.Data.Colors.transactionMessageBackgroundCol, false, false, true, true)
    draw.RoundedBox(2, centerx - msgw * .5, msgy - 7, msgw, 4, theme.Data.Colors.transactionMessageLineCol)

    iconsize = 25

    surface.SetFont("GlorifiedBanking.ATMEntity.TransactionFee")
    local hintText = self:GetTransferFee() > 0 and gbi18n.GetPhrase("gbTransferHasFee", self:GetTransferFee()) or gbi18n.GetPhrase("gbTransferFree")
    contentw = iconsize + 10 + surface.GetTextSize(hintText)

    surface.SetDrawColor(theme.Data.Colors.transactionWarningIconCol)
    surface.SetMaterial(theme.Data.Materials.warning)
    surface.DrawTexturedRect(centerx - contentw * .5, msgy + 5, iconsize, iconsize)

    draw.SimpleText(hintText, "GlorifiedBanking.ATMEntity.TransactionFee", centerx + contentw * .5, msgy, theme.Data.Colors.transactionTextCol, TEXT_ALIGN_RIGHT)

    msgw, msgh = windoww * .95, 110
    msgy = windowy + windowh - 205

    draw.RoundedBox(8, centerx - msgw * .5, msgy - 10, msgw, msgh, theme.Data.Colors.transactionButtonOutlineCol)

    msgw, msgh = windoww * .93, 90
    local hovering = false

    local amount = self:GetKeypadContent()
    if imgui.IsHovering(centerx - msgw * .5, msgy, msgw, msgh) then
        hovering = true
        draw.RoundedBox(6, centerx - msgw * .5, msgy, msgw, msgh, theme.Data.Colors.transactionButtonHoverCol)

        if imgui.IsPressed() then
            self.Screens[6].onEnterPressed(self, amount)
        end
    else
        draw.RoundedBox(6, centerx - msgw * .5, msgy, msgw, msgh, theme.Data.Colors.transactionButtonBackgroundCol)
    end

    iconsize = 38

    surface.SetFont("GlorifiedBanking.ATMEntity.TransactionButton")
    local buttonText = gbi18n.GetPhrase("gbMenuTransfer")
    contentw = iconsize + 15 + surface.GetTextSize(buttonText)

    msgy = msgy + 14
    surface.SetDrawColor(theme.Data.Colors.transactionIconCol)
    surface.SetMaterial(theme.Data.Materials.transfer)
    surface.DrawTexturedRect(centerx - contentw * .5, msgy + 12, iconsize, iconsize)
    draw.SimpleText(buttonText, "GlorifiedBanking.ATMEntity.TransactionButton", centerx + contentw * .5, msgy, theme.Data.Colors.transactionTextCol, TEXT_ALIGN_RIGHT)

    msgw, msgh, msgy = windoww * .95, 80, windowy + windowh - 305
    draw.RoundedBox(8, centerx - msgw * .5, msgy - 10, msgw, msgh, theme.Data.Colors.transactionEntryOutlineCol)
    msgw, msgh = windoww * .93, 60
    draw.RoundedBox(6, centerx - msgw * .5, msgy, msgw, msgh, theme.Data.Colors.transactionEntryBackgroundCol)

    draw.SimpleText(amount > 0 and GlorifiedBanking.FormatMoney(amount) or gbi18n.GetPhrase("gbTransactionTypeAmount"), "GlorifiedBanking.ATMEntity.TransactionEntry", centerx, msgy + msgh / 2 - 3, amount > 0 and theme.Data.Colors.transactionEntryTextPopulatedCol or theme.Data.Colors.transactionEntryTextCol, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

    local listw, listh = windoww * .95, 505
    local listx, listy = centerx - listw * .5, windowy + 100

    draw.RoundedBox(6, listx, listy, listw, listh, theme.Data.Colors.transferListBackgroundCol)

    if not data.players then
        data.players = player.GetHumans()

        for k,v in ipairs(data.players) do
            if v == self.LocalPlayer then table.remove(data.players, k) break end
        end
    end

    if not data.offset then data.offset = 0 end

    GlorifiedBanking.UI.StartCutOut(function()
        surface.SetDrawColor(color_white)
        surface.DrawRect(listx, listy, listw, listh)
    end)

    local plycount = #data.players
    local showscroll = plycount > 4

    local plyw, plyh = showscroll and listw * .90 or listw * .96, listh * .2
    local plyx, plyy = listx + listw * .02

    for k,v in ipairs(data.players) do
        if not IsValid(v) then table.remove(data.players, k) continue end

        plyy = data.offset + listy + 24 + (plyh + 16) * (k - 1)

        if plyy + plyh < listy then continue end
        if plyy > listy + listh then break end

        if imgui.IsHovering(plyx, plyy, plyw, plyh) then
            hovering = true
            draw.RoundedBox(6, plyx, plyy, plyw, plyh, theme.Data.Colors.transferListPlayerBackgroundHoverCol)

            if imgui.IsPressed() then
                data.selected = v
            end
        else
            draw.RoundedBox(6, plyx, plyy, plyw, plyh, theme.Data.Colors.transferListPlayerBackgroundCol)
        end

        iconsize = 80
        surface.SetDrawColor(theme.Data.Colors.transferListPlayerIconCol)
        surface.SetMaterial(theme.Data.Materials.player)
        surface.DrawTexturedRect(plyx + 20, plyy + 11, iconsize, iconsize)

        draw.SimpleText(v:Name(), "GlorifiedBanking.ATMEntity.TransferPlayerName", plyx + 35 + iconsize, plyy + plyh / 2, theme.Data.Colors.transferListPlayerNameCol, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

        if data.selected == v then
            iconsize = 60
            surface.SetDrawColor(theme.Data.Colors.transferListPlayerCheckCol)
            surface.SetMaterial(theme.Data.Materials.check)
            surface.DrawTexturedRect(plyx + plyw - 80, plyy + 22, iconsize, iconsize)
        end

    end

    GlorifiedBanking.UI.EndCutOut()

    if not showscroll then return hovering end

    iconsize = 60
    local arrowx = listx + listw - iconsize / 2 - 16
    local arrowhoverx = listx + listw - iconsize - 10

    if imgui.IsHovering(arrowhoverx, listy + 45 - iconsize / 2, iconsize, iconsize) then
        hovering = true
        surface.SetDrawColor(theme.Data.Colors.transferListArrowIconHoverCol)

        if imgui.IsPressing() then
            data.offset = math.min(data.offset + FrameTime() * 350, 0)
        end
    else
        surface.SetDrawColor(theme.Data.Colors.transferListArrowIconCol)
    end

    surface.SetMaterial(theme.Data.Materials.chevron)
    surface.DrawTexturedRectRotated(arrowx, listy + 45, iconsize, iconsize, 90)

    if imgui.IsHovering(arrowhoverx, listy + listh - iconsize - 15, iconsize, iconsize) then
        hovering = true
        surface.SetDrawColor(theme.Data.Colors.transferListArrowIconHoverCol)

        if imgui.IsPressing() then
            data.offset = math.max(data.offset - FrameTime() * 350, -((plycount - 4) * (plyh + 16) + 8))
        end
    else
        surface.SetDrawColor(theme.Data.Colors.transferListArrowIconCol)
    end

    surface.SetMaterial(theme.Data.Materials.chevron)
    surface.DrawTexturedRectRotated(arrowx, listy + listh - iconsize / 2 - 15, iconsize, iconsize, 270)

    return hovering
end

ENT.Screens[7].drawFunction = function(self, data) --Transactions screen
    surface.SetFont("GlorifiedBanking.ATMEntity.AccountBalance")
    local contenty = windowy + 15
    local iconsize = 46
    local text

    if self:GetCurrentUser() != self.LocalPlayer then
        text = gbi18n.GetPhrase("gbAccountBalance", gbi18n.GetPhrase("gbHidden"))
    else
        text = gbi18n.GetPhrase("gbAccountBalance", GlorifiedBanking.FormatMoney(GlorifiedBanking.GetPlayerBalance()))
    end

    local contentw = iconsize + 12 + surface.GetTextSize(text)

    surface.SetDrawColor(theme.Data.Colors.balanceIconCol)
    surface.SetMaterial(theme.Data.Materials.money)
    surface.DrawTexturedRect(centerx - contentw * .5, contenty + 5, iconsize, iconsize)

    draw.SimpleText(text, "GlorifiedBanking.ATMEntity.AccountBalance", centerx + contentw * .5, contenty, theme.Data.Colors.balanceTextCol, TEXT_ALIGN_RIGHT)

    contentw = contentw + 15
    draw.RoundedBox(2, windowx + (windoww-contentw) * .5, contenty + 50, contentw, 4, theme.Data.Colors.menuUserUnderlineCol)

    local listw, listh = windoww * .95, windowh * .87
    local listx, listy = centerx - listw / 2, windowy + 90

    draw.RoundedBox(8, listx, listy, listw, listh, theme.Data.Colors.transferListBackgroundCol)

    local entryw, entryh = listw * .98, listh * .07
    local entryx, entryy = centerx - entryw / 2, listy + 10
    draw.RoundedBoxEx(6, entryx, entryy, entryw, entryh, theme.Data.Colors.transactionListHeaderCol, true, true)
    draw.RoundedBox(2, entryx, entryy + entryh - 4, entryw, 4, theme.Data.Colors.transactionListHeaderUnderlineCol)

    local texty = entryy + 2
    draw.SimpleText(gbi18n.GetPhrase("gbTransactionsTime"), "GlorifiedBanking.ATMEntity.TransactionHeader", entryx + 10, texty, theme.Data.Colors.transactionListEntryTextCol)
    draw.SimpleText(gbi18n.GetPhrase("gbTransactionsType"), "GlorifiedBanking.ATMEntity.TransactionHeader", entryx + 250, texty, theme.Data.Colors.transactionListEntryTextCol)
    draw.SimpleText(gbi18n.GetPhrase("gbTransactionsUsers"), "GlorifiedBanking.ATMEntity.TransactionHeader", entryx + 500, texty, theme.Data.Colors.transactionListEntryTextCol)
    draw.SimpleText(gbi18n.GetPhrase("gbTransactionsTotal"), "GlorifiedBanking.ATMEntity.TransactionHeader", entryx + 880, texty, theme.Data.Colors.transactionListEntryTextCol)

    if not data.Transactions then
        draw.SimpleText(gbi18n.GetPhrase("gbHidden"), "GlorifiedBanking.ATMEntity.TransactionHidden", listx + listw / 2, listy + listh / 2, theme.Data.Colors.transactionListHiddenTextCol, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        return
    end

    entryy = entryy + entryh + 10
    entryh = entryh * 1.2

    local boxh = entryh * .8
    local boxoffset = entryh * .1
    local entrycentrey = entryh * .5

    for k,v in ipairs(data.Transactions) do
        draw.RoundedBox(10, entryx, entryy, entryw, entryh, theme.Data.Colors.transactionListEntryCol)

        draw.RoundedBox(8, entryx + 10, entryy + boxoffset, 220, boxh, theme.Data.Colors.transactionListEntryTextBackgroundCol)
        draw.SimpleText(v.Date, "GlorifiedBanking.ATMEntity.TransactionDetail", entryx + 15, entryy + entrycentrey, theme.Data.Colors.transactionListEntryTextCol, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

        draw.RoundedBox(8, entryx + 250, entryy + boxoffset, 230, boxh, theme.Data.Colors.transactionListEntryTextBackgroundCol)
        draw.SimpleText(v.Type, "GlorifiedBanking.ATMEntity.TransactionDetail", entryx + 255, entryy + entrycentrey, theme.Data.Colors.transactionListEntryTextCol, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

        draw.RoundedBox(8, entryx + 500, entryy + boxoffset, 360, boxh, theme.Data.Colors.transactionListEntryTextBackgroundCol)
        draw.SimpleText(v.User or "N/A", "GlorifiedBanking.ATMEntity.TransactionDetail", entryx + 505, entryy + entrycentrey, theme.Data.Colors.transactionListEntryTextCol, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

        draw.RoundedBox(8, entryx + 880, entryy + boxoffset, 252, boxh, theme.Data.Colors.transactionListEntryTextBackgroundCol)
        draw.SimpleText(v.Amount, "GlorifiedBanking.ATMEntity.TransactionMoney", entryx + 885, entryy + entrycentrey, v.MoneyColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

        entryy = entryy + entryh + 5
    end
end

--Draw the current screen
local screenpos = Vector(1.47, 13.46, 51.16)
local screenang = Angle(0, 270, 90)
function ENT:DrawScreen()
    if imgui.Entity3D2D(self, screenpos, screenang, 0.02, 250, 200) then
        local screenID = self:GetScreenID()
        local currentScreen = self.Screens[screenID]

        local hovering = self:DrawScreenBackground(currentScreen.loggedIn, currentScreen.previousPage)
        if self.ShouldDrawCurrentScreen and self.OldScreenID == 0 then
            hovering = currentScreen.drawFunction(self, self.ScreenData) or hovering
        end

        self:DrawLoadingScreen()

        if not currentScreen.hideCursor and self.LocalPlayer == self:GetCurrentUser() and  not self.ForcedLoad and imgui.IsHovering(0, 0, scrw, scrh) then
            local mx, my = imgui.CursorPos()

            surface.SetDrawColor(color_white)
            surface.SetMaterial(hovering and theme.Data.Materials.cursorHover or theme.Data.Materials.cursor)
            surface.DrawTexturedRect(hovering and mx - 12 or mx, my, 45, 45)
        end

        imgui.End3D2D()
    end
end

--Keypad management code
ENT.KeyPadBuffer = ""
function ENT:PressKey(key)
    if self:GetCurrentUser() != self.LocalPlayer then return end
    self:EmitSound("GlorifiedBanking.Key_Press")

    if key == "*" then
        self.KeyPadBuffer = ""
        return
    end

    local curScreen = self.Screens[self:GetScreenID()]
    if not curScreen.takesKeyInput then return end

    if key == "#" then
        if not curScreen.onEnterPressed then return end
        curScreen.onEnterPressed(self, self:GetKeypadContent())
        return
    end

    if #self.KeyPadBuffer > 13 then return end

    self.KeyPadBuffer = self.KeyPadBuffer .. key
end

--Keypad content getter
function ENT:GetKeypadContent()
    return #self.KeyPadBuffer > 0 and tonumber(self.KeyPadBuffer) or 0
end

--Numpad shortcuts
local buttons = {
    [KEY_PAD_0] = "0",
    [KEY_PAD_1] = "1",
    [KEY_PAD_2] = "2",
    [KEY_PAD_3] = "3",
    [KEY_PAD_4] = "4",
    [KEY_PAD_5] = "5",
    [KEY_PAD_6] = "6",
    [KEY_PAD_7] = "7",
    [KEY_PAD_8] = "8",
    [KEY_PAD_9] = "9",
    [KEY_PAD_MINUS] = "*",
    [KEY_PAD_ENTER] = "#"
}

hook.Add("PlayerButtonDown", "GlorifiedBanking.ATMEntity.PlayerButtonDown", function(ply, btn)
    if ply != LocalPlayer() then return end
    if not buttons[btn] then return end

    local tr = ply:GetEyeTraceNoCursor()
    if not tr.Hit then return end
    if tr.Entity:GetClass() != "glorifiedbanking_atm" then return end

    if not tr.Entity.IsHoveringKeypad then return end
    tr.Entity:PressKey(buttons[btn])
end)

--Draw the keypad button hover and cursor
local padw, padh = 253, 204
local keyw, keyh = 38, 37
local padpos = Vector(-7.33, 6.94, 24.04)
local padang = Angle(-28.6, 0, 0)
function ENT:DrawKeypad()
    self.IsHoveringKeypad = false

    if imgui.Entity3D2D(self, padpos, padang, 0.03, 150, 120) then
        if imgui.IsHovering(0, 0, padw, padh) then
            self.IsHoveringKeypad = true
        else
            imgui.End3D2D()
            return
        end

        for i = 1, 3 do
            for j = 1, 4 do
                local keyx, keyy = 183 - ((j - 1) * 51.25), 54 + ((i - 1) * 49.5)

                if not imgui.IsHovering(keyx, keyy, keyw, keyh) then continue end

                draw.RoundedBox(4, keyx, keyy, keyw, keyh, imgui.IsPressing() and theme.Data.Colors.keyPressedCol or theme.Data.Colors.keyHoverCol)

                if imgui.IsPressed() then
                    local pressedkey = i + (j - 1) * 3
                    if pressedkey == 10 then
                        pressedkey = "*"
                    elseif pressedkey == 11 then
                        pressedkey = "0"
                    elseif pressedkey == 12 then
                        pressedkey = "#"
                    end

                    self:PressKey(tostring(pressedkey))
                end
            end
        end

        imgui.xCursor(0, 0, padw, padh)

        imgui.End3D2D()
    end
end

--Draw the sign above the ATM
local signpos = Vector(-8.3, 14.5, 71.3)
local signang = Angle(0, 270, 90)
local signw, signh = 553, 162
function ENT:DrawSign()
    cam.Start3D2D(self:LocalToWorld(signpos), self:LocalToWorldAngles(signang), 0.05)
        surface.SetDrawColor(theme.Data.Colors.signBackgroundCol)
        surface.DrawRect(0, 0, signw, signh)
        local text = self:GetSignText()
        draw.SimpleText(text, #text > 9 and "GlorifiedBanking.ATMEntity.SignTextSmall" or "GlorifiedBanking.ATMEntity.SignTextLarge", signw / 2, signh * .46, theme.Data.Colors.signTextCol, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    cam.End3D2D()
end

--Animation setup method
local moneyinpos = Vector(-7, 4.5, 19.37)
local moneyoutpos = Vector(-10, 4.5, 19.37)
local moneyang = Angle(0, 270, 0)
function ENT:PlayGBAnim(type, skipsound)
    if type == GB_ANIM_CARD_IN then
        self.CardPos = 60
        self:EmitSound("GlorifiedBanking.Card_Insert")
    end

    if type == GB_ANIM_CARD_OUT then
        self.CardPos = 0
        self:EmitSound("GlorifiedBanking.Card_Remove")
    end

    if type == GB_ANIM_MONEY_IN or type == GB_ANIM_MONEY_OUT then
        self.MoneyPos = Vector()

        if type == GB_ANIM_MONEY_IN then
            self.MoneyPos:Set(moneyoutpos)
        else
            if not skipsound then
                self:EmitSound("GlorifiedBanking.Money_Out")

                timer.Simple(5.9, function()
                    if not IsValid(self) then return end
                    self:PlayGBAnim(GB_ANIM_MONEY_OUT, true)

                    timer.Simple(1.2, function()
                        self.RequiresAttention = true
                    end)
                end)

                return
            end

            self.MoneyPos:Set(moneyinpos)
        end

        if not IsValid(self.MoneyModel) then self.MoneyModel = ClientsideModel("models/props/cs_assault/Money.mdl") end
        self.MoneyModel:SetPos(self:LocalToWorld(self.MoneyPos))
        self.MoneyModel:SetAngles(self:LocalToWorldAngles(moneyang))
    else
        if IsValid(self.MoneyModel) then
            timer.Simple(0, function()
                self.MoneyModel:Remove()
            end)
        end
    end

    self.AnimState = type
end

--Animation networking
net.Receive("GlorifiedBanking.SendAnimation", function()
    local ent = net.ReadEntity()
    ent:PlayGBAnim(net.ReadUInt(3))
    ent.RequiresAttention = false
end)

--Cleanup money clientside ent
function ENT:OnRemove()
    if IsValid(self.MoneyModel) then
        self.MoneyModel:Remove()
    end
end

--Draw the playing animation
local cardpos = Vector(-4, -10.45, 19.81)
local cardang = Angle(0, 180, 0)
function ENT:DrawAnimations()
    if self.AnimState == GB_ANIM_IDLE then return end

    if self.AnimState == GB_ANIM_CARD_IN or self.AnimState == GB_ANIM_CARD_OUT then
        cam.Start3D2D(self:LocalToWorld(cardpos), self:LocalToWorldAngles(cardang), 0.07)
            surface.SetDrawColor(color_white)
            surface.SetMaterial(GlorifiedBanking.CardMaterial)
            surface.DrawTexturedRect(self.CardPos, 0, 70, 40)
        cam.End3D2D()

        if self.AnimState == GB_ANIM_CARD_IN then
            self.CardPos = self.CardPos - FrameTime() * 50
        else
            self.CardPos = math.min(self.CardPos + FrameTime() * 250, 60)
        end

        if self.CardPos < 0 then
            self.AnimState = GB_ANIM_IDLE
        end
    end

    if self.AnimState == GB_ANIM_MONEY_IN or self.AnimState == GB_ANIM_MONEY_OUT then
        if not IsValid(self.MoneyModel) then
            self:PlayGBAnim(self.AnimState)
            return
        end

        self.MoneyModel:SetAngles(self:LocalToWorldAngles(moneyang))
        self.MoneyModel:SetPos(self:LocalToWorld(self.MoneyPos))

        if self.AnimState == GB_ANIM_MONEY_IN then
            self.MoneyPos[1] = self.MoneyPos[1] + FrameTime()
        else
            self.MoneyPos[1] = math.max(self.MoneyPos[1] - FrameTime() * 10, moneyoutpos[1])
        end

        if self.AnimState == GB_ANIM_MONEY_IN and self.MoneyPos[1] > moneyinpos[1] then
            self:PlayGBAnim(GB_ANIM_IDLE)
        end
    end
end
