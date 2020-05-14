
ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Glorified ATM"
ENT.Category = "GlorifiedBanking"
ENT.Author = "Tom.bat"
ENT.Spawnable = true
ENT.AdminOnly = true

ENT.WithdrawalFee = 50
ENT.DepositFee = 80
ENT.TransferFee = 0

function ENT:SetupDataTables()
    self:NetworkVar("Int", 0, "ScreenID")
    self:NetworkVar("Entity", 0, "CurrentUser")

    if SERVER then
        self:SetScreenID(1)
        self:SetCurrentUser(NULL)
    else
        self:NetworkVarNotify("ScreenID", self.OnScreenChange)
    end
end

ENT.Screens = {}
ENT.Screens[1] = { --Idle screen
    drawFunction = function(self, data)
        local centerx, centery = windowx + windoww * .5, windowy + windowh * .5

        render.ClearStencil()
        render.SetStencilEnable(true)
        render.SetStencilCompareFunction(STENCIL_ALWAYS)
        render.SetStencilPassOperation(STENCIL_REPLACE)
        render.SetStencilFailOperation(STENCIL_KEEP)
        render.SetStencilZFailOperation(STENCIL_KEEP)

        render.SetStencilWriteMask(1)
        render.SetStencilTestMask(1)
        render.SetStencilReferenceValue(1)

        render.OverrideColorWriteEnable(true, false)

        surface.SetDrawColor(color_white)
        surface.DrawRect(windowx, windowy + 4, windoww, windowh - 8)

        render.OverrideColorWriteEnable(false, false)

        render.SetStencilCompareFunction(STENCIL_EQUAL)

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

        render.SetStencilEnable(false)

        local msgw, msgh = windoww * .6, windowh * .2
        draw.RoundedBox(12, windowx + (windoww-msgw) * .5, windowy + (windowh-msgh) * .5, msgw, msgh, theme.Data.Colors.idleScreenMessageBackgroundCol)

        local linew, lineh = msgw * .8, 4
        local liney = windowy + windowh * .5 - 2
        draw.SimpleText(i18n.GetPhrase("gbEnterCard"), "GlorifiedBanking.ATMEntity.EnterCard", centerx, liney - 55, theme.Data.Colors.loadingScreenTextCol, TEXT_ALIGN_CENTER)

        draw.RoundedBox(2,  windowx + (windoww-linew) * .5, liney, linew, lineh, theme.Data.Colors.idleScreenSeperatorCol)
        draw.SimpleText(i18n.GetPhrase("gbToContinue"), "GlorifiedBanking.ATMEntity.EnterCardSmall", centerx, liney + 8, theme.Data.Colors.loadingScreenTextCol, TEXT_ALIGN_CENTER)
    end
}

ENT.Screens[2] = { --Lockdown screen
    drawFunction = function(self, data)
        local centerx, centery = windowx + windoww * .5, windowy + windowh * .5

        local msgw, msgh = windoww * .95, 100
        draw.RoundedBoxEx(8, windowx + (windoww-msgw) * .5, windowy + 35, msgw, msgh, theme.Data.Colors.lockdownMessageBackgroundCol, false, false, true, true)
        draw.RoundedBox(2, windowx + (windoww-msgw) * .5, windowy + 35, msgw, 4, theme.Data.Colors.lockdownMessageLineCol)
        draw.DrawText(i18n.GetPhrase("gbAtmDisabled"), "GlorifiedBanking.ATMEntity.Lockdown", centerx, windowy + 45, theme.Data.Colors.lockdownTextCol, TEXT_ALIGN_CENTER)

        msgh = 50
        draw.RoundedBoxEx(8, windowx + (windoww-msgw) * .5, windowy + windowh - 80, msgw, msgh, theme.Data.Colors.lockdownMessageBackgroundCol, false, false, true, true)
        draw.RoundedBox(2, windowx + (windoww-msgw) * .5, windowy + windowh - 80, msgw, 4, theme.Data.Colors.lockdownMessageLineCol)

        local iconsize = 30

        surface.SetFont("GlorifiedBanking.ATMEntity.LockdownSmall")
        local contenty = windowy + windowh - 73
        local contentw = iconsize + 10 + surface.GetTextSize(i18n.GetPhrase("gbBackShortly"))

        surface.SetDrawColor(theme.Data.Colors.lockdownWarningIconCol)
        surface.SetMaterial(theme.Data.Materials.warning)
        surface.DrawTexturedRect(centerx - contentw * .5, contenty + 5, iconsize, iconsize)

        draw.SimpleText(i18n.GetPhrase("gbBackShortly"), "GlorifiedBanking.ATMEntity.LockdownSmall", centerx + contentw * .5, contenty, theme.Data.Colors.lockdownTextCol, TEXT_ALIGN_RIGHT)

        iconsize = 400
        surface.SetDrawColor(theme.Data.Colors.lockdownIconCol)
        surface.SetMaterial(theme.Data.Materials.lockdown)
        surface.DrawTexturedRect(centerx - iconsize * .5, centery - iconsize * .5, iconsize, iconsize)
    end
}

local menuButtons = {
    {
        name = i18n.GetPhrase("gbMenuWithdraw"),
        pressFunc = function(self, data)
        end
    },
    {
        name = i18n.GetPhrase("gbMenuDeposit"),
        pressFunc = function(self, data)
        end
    },
    {
        name = i18n.GetPhrase("gbMenuTransfer"),
        pressFunc = function(self, data)
        end
    },
    {
        name = i18n.GetPhrase("gbMenuTransactions"),
        pressFunc = function(self, data)
        end
    },
    {
        name = i18n.GetPhrase("gbMenuSettings"),
        pressFunc = function(self, data)
        end
    }
}

ENT.Screens[3] = { --Main Menu
    loggedIn = true,
    drawFunction = function(self, data)
        local centerx = windowx + windoww * .5, windowy + windowh * .5

        surface.SetFont("GlorifiedBanking.ATMEntity.WelcomeBack")
        local contenty = windowy + 100
        local iconsize = 32
        local text = i18n.GetPhrase("gbWelcomeBack", string.upper(self.CurrentUsername))
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
            else
                draw.RoundedBox(8, btnx, btny, btnw, btnh, theme.Data.Colors.menuButtonBackgroundCol)
            end

            draw.SimpleText(v.name, "GlorifiedBanking.ATMEntity.MenuButton", btnx + btnw * .5, btny + btnh * .5, theme.Data.Colors.menuButtonTextCol, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

            btny = btny + btnh + btnspacing
        end

        return hovering
    end
}

local function drawTypeAmountScreen(self, topHint, buttonText, buttonIcon, bottomHint, disclaimer, onPress)
    local centerx, centery = windowx + windoww * .5, windowy + windowh * .5

        local msgw, msgh = windoww * .95, 60
        local msgy = centery - 203
        draw.RoundedBoxEx(8, centerx - msgw * .5, msgy, msgw, msgh, theme.Data.Colors.transactionMessageBackgroundCol, false, false, true, true)
        draw.RoundedBox(2, windowx + (windoww-msgw) * .5, msgy, msgw, 4, theme.Data.Colors.lockdownMessageLineCol)
        draw.SimpleText(topHint, "GlorifiedBanking.ATMEntity.TransactionHint", centerx, msgy + 10, theme.Data.Colors.transactionTextCol, TEXT_ALIGN_CENTER)

        msgh = 46
        msgy = centery + 160
        draw.RoundedBoxEx(8, centerx - msgw * .5, msgy - 7, msgw, msgh, theme.Data.Colors.transactionMessageBackgroundCol, false, false, true, true)
        draw.RoundedBox(2, centerx - msgw * .5, msgy - 7, msgw, 4, theme.Data.Colors.lockdownMessageLineCol)

        local iconsize = 25

        surface.SetFont("GlorifiedBanking.ATMEntity.TransactionFee")
        local contentw = iconsize + 10 + surface.GetTextSize(bottomHint)

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

        local amount = #self.KeyPadBuffer > 0 and tonumber(self.KeyPadBuffer) or 0
        if imgui.IsHovering(centerx - msgw * .5, msgy, msgw, msgh) then
            hovering = true
            draw.RoundedBox(6, centerx - msgw * .5, msgy, msgw, msgh, theme.Data.Colors.transactionButtonHoverCol)

            if imgui.IsPressed() then
                onPress(amount)
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

        draw.SimpleText(amount > 0 and GlorifiedBanking.FormatMoney(amount) or i18n.GetPhrase("gbTransactionTypeAmount"), "GlorifiedBanking.ATMEntity.TransactionEntry", centerx, msgy + msgh / 2 - 3, amount > 0 and theme.Data.Colors.transactionEntryTextPopulatedCol or theme.Data.Colors.transactionEntryTextCol, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

        return hovering
end

ENT.Screens[4] = { --Withdrawal screen
    loggedIn = true,
    previousPage = 3,
    takesKeyInput = true,
    drawFunction = function(self, data)
        return drawTypeAmountScreen(
            self,
            i18n.GetPhrase("gbWithdrawAmount"),
            i18n.GetPhrase("gbMenuWithdraw"),
            theme.Data.Materials.transaction,
            self.WithdrawalFee > 0 and i18n.GetPhrase("gbWithdrawalHasFee", self.WithdrawalFee) or i18n.GetPhrase("gbWithdrawalFree"),
            i18n.GetPhrase("gbWithdrawalDisclaimer"),
            function(amount)
            end
        )
    end
}

ENT.Screens[5] = { --Deposit screen
    loggedIn = true,
    previousPage = 3,
    takesKeyInput = true,
    drawFunction = function(self, data)
        return drawTypeAmountScreen(
            self,
            i18n.GetPhrase("gbDepositAmount"),
            i18n.GetPhrase("gbMenuDeposit"),
            theme.Data.Materials.transaction,
            self.DepositFee > 0 and i18n.GetPhrase("gbDepositHasFee", self.DepositFee) or i18n.GetPhrase("gbDepositFree"),
            i18n.GetPhrase("gbDepositDisclaimer"),
            function(amount)
            end
        )
    end
}
