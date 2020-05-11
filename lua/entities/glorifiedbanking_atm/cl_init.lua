
include("shared.lua")

local imgui = GlorifiedBanking.imgui
imgui.DisableDeveloperMode = true

local GB_ANIM_IDLE = 0
local GB_ANIM_MONEY_IN = 1
local GB_ANIM_MONEY_OUT = 2
local GB_ANIM_CARD_IN = 3
local GB_ANIM_CARD_OUT = 4

local theme = GlorifiedBanking.Themes.GetCurrent()
hook.Add("GlorifiedBanking.ThemeUpdated", "GlorifiedBanking.ATMEntity.ThemeUpdated", function(newTheme)
    theme = newTheme
end)

ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

function ENT:Think()
    if self.RequiresAttention and (not self.LastAttentionBeep or CurTime() > self.LastAttentionBeep + 1.25) then
        self:EmitSound("GlorifiedBanking.Beep_Attention")
        self.LastAttentionBeep = CurTime()
    end

    local currentScreen = self.Screens[self:GetScreenID()]
    local gotRequiredData = true

    if currentScreen.requiredData then
        if self.ScreenData then
            for k, v in ipairs(currentScreen.requiredData) do
                if self.ScreenData[k] then continue end
                gotRequiredData = false
                break
            end
        else
            gotRequiredData = false
        end
    end

    self.ShouldDrawCurrentScreen = gotRequiredData
end

function ENT:DrawTranslucent()
    self:DrawModel()

    self:DrawScreen()
    self:DrawKeypad()
    --TODO: Draw sign

    self:DrawAnimations()
end

local scrw, scrh = 858, 753

function ENT:DrawScreenBackground(showExit, backPage)
    local hovering = false

    surface.SetDrawColor(theme.Data.Colors.backgroundCol)
    surface.DrawRect(0, 0, scrw, scrh)

    draw.RoundedBox(8, 10, 10, 70, 70, theme.Data.Colors.logoBackgroundCol)
    surface.SetDrawColor(theme.Data.Colors.logoCol)
    surface.SetMaterial(theme.Data.Materials.logoSmall)
    surface.DrawTexturedRect(15, 15, 60, 60)

    if backPage and backPage > 0 then
        if (imgui.IsHovering(scrw-160, 10, 70, 70)) then
            hovering = true
            draw.RoundedBox(8, scrw-160, 10, 70, 70, theme.Data.Colors.backBackgroundHoverCol)
        else
            draw.RoundedBox(8, scrw-160, 10, 70, 70, theme.Data.Colors.backBackgroundCol)
        end
        surface.SetDrawColor(theme.Data.Colors.backCol)
        surface.SetMaterial(theme.Data.Materials.back)
        surface.DrawTexturedRect(scrw-150, 20, 50, 50)
    end

    if showExit then
        if (imgui.IsHovering(scrw-80, 10, 70, 70)) then
            hovering = true
            draw.RoundedBox(8, scrw-80, 10, 70, 70, theme.Data.Colors.exitBackgroundHoverCol)
        else
            draw.RoundedBox(8, scrw-80, 10, 70, 70, theme.Data.Colors.exitBackgroundCol)
        end
        surface.SetDrawColor(theme.Data.Colors.exitCol)
        surface.SetMaterial(theme.Data.Materials.exit)
        surface.DrawTexturedRect(scrw-70, 20, 50, 50)
    end

    draw.SimpleText(string.upper(i18n.GetPhrase("gbSystemName")), "GlorifiedBanking.ATMEntity.Title", 90, 80, theme.Data.Colors.titleTextCol, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)

    draw.RoundedBox(6, 0, 85, scrw, 10, theme.Data.Colors.titleBarCol)

    surface.SetDrawColor(theme.Data.Colors.innerBoxBackgroundCol)
    surface.DrawRect(20, 115, scrw-40, scrh-135)

    draw.RoundedBox(2, 20, 115, scrw-40, 3, theme.Data.Colors.innerBoxBorderCol)
    draw.RoundedBox(2, 20, scrh-23, scrw-40, 3, theme.Data.Colors.innerBoxBorderCol)

    return hovering
end

ENT.LoadingScreenX = -scrw
ENT.LoadingScreenH = 220

function ENT:DrawLoadingScreen(shouldShow)
    shouldShow = self.Lmao

    if shouldShow then
        self.LoadingScreenX = Lerp(FrameTime() * 5, self.LoadingScreenX, 20)

        if self.LoadingScreenX > 18 then
            self.LoadingScreenH = Lerp(FrameTime() * 6, self.LoadingScreenH, scrh-135)
        end
    else
        self.LoadingScreenH = Lerp(FrameTime() * 5, self.LoadingScreenH, 220)

        if self.LoadingScreenH < 225 then
            self.LoadingScreenX = Lerp(FrameTime() * 5, self.LoadingScreenX, -scrw)
        end
    end

    local w, h = scrw - 40, self.LoadingScreenH
    local x, y = self.LoadingScreenX, 310 - self.LoadingScreenH / 2 + 114

    if self.LoadingScreenX < -(scrw - 20) then return end

    surface.SetDrawColor(theme.Data.Colors.loadingScreenBackgroundCol)
    surface.DrawRect(x, y, w, h)

    draw.RoundedBox(2, x, y, w, 3, theme.Data.Colors.loadingScreenBorderCol)
    draw.RoundedBox(2, x, y + h - 3, w, 3, theme.Data.Colors.loadingScreenBorderCol)

    surface.SetDrawColor(theme.Data.Colors.loadingScreenSpinnerCol)
    surface.SetMaterial(theme.Data.Materials.circle)

    local animprog = CurTime() * 2.5
    surface.DrawTexturedRect(x + w / 2 - 80, 370 + math.sin(animprog + 1) * 20, 40, 40)
    surface.DrawTexturedRect(x + w / 2 - 20, 370 + math.sin(animprog + .5) * 20, 40, 40)
    surface.DrawTexturedRect(x + w / 2 + 40, 370 + math.sin(animprog) * 20, 40, 40)

    draw.SimpleText(i18n.GetPhrase("gbLoading"), "GlorifiedBanking.ATMEntity.Loading", x + w / 2, 470, theme.Data.Colors.loadingScreenTextCol, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

ENT.Screens = {
    [1] = { 
        drawFunction = function(self, data)
            draw.RoundedBox(6, 190, 360, 480, 120, theme.Data.Colors.idleScreenMessageBackgroundCol)

            draw.SimpleText(i18n.GetPhrase("gbEnterCard"), "GlorifiedBanking.ATMEntity.EnterCard", 430, 380, theme.Data.Colors.loadingScreenTextCol, TEXT_ALIGN_CENTER)
            draw.RoundedBox(2, 250, 418, 360, 3, theme.Data.Colors.idleScreenSeperatorCol)
            draw.SimpleText(i18n.GetPhrase("gbToContinue"), "GlorifiedBanking.ATMEntity.EnterCardSmall", 430, 420, theme.Data.Colors.loadingScreenTextCol, TEXT_ALIGN_CENTER)
        end
    }
}

local screenpos = Vector(1.47, 13.46, 51.16)
local screenang = Angle(0, 270, 90)

function ENT:DrawScreen()
    if imgui.Entity3D2D(self, screenpos, screenang, 0.03, 250, 200) then
        local currentScreen = self.Screens[self:GetScreenID()]

        local hovering = self:DrawScreenBackground(currentScreen.loggedIn, currentScreen.previousPage)

        if self.ShouldDrawCurrentScreen then
            hovering = hovering or currentScreen.drawFunction(self, self.ScreenData)
        end

        local clippingState = DisableClipping(false)
        self:DrawLoadingScreen(hasRequiredData)
        DisableClipping(clippingState)

        if imgui.IsHovering(0, 0, scrw, scrh) then
            local mx, my = imgui.CursorPos()

            surface.SetDrawColor(color_white)
            surface.SetMaterial(hovering and theme.Data.Materials.cursorHover or theme.Data.Materials.cursor)
            surface.DrawTexturedRect(hovering and mx - 12 or mx, my, 30, 30)
        end

        imgui.End3D2D()
    end
end

function ENT:PressKey(key)
    if key == "1" then
        self:PlayGBAnim(GB_ANIM_CARD_IN)
    elseif key == "2" then
        self:PlayGBAnim(GB_ANIM_CARD_OUT)
    elseif key == "3" then
        self:PlayGBAnim(GB_ANIM_MONEY_IN)
    elseif key == "4" then
        self:PlayGBAnim(GB_ANIM_MONEY_OUT)
    elseif key == "5" then
        self.Lmao = true
    elseif key == "6" then
        self.Lmao = false
    end

    self:EmitSound("GlorifiedBanking.Beep_Normal")
    print("pressed: " .. key)
end

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
    [KEY_PAD_MULTIPLY] = "*",
    [KEY_PAD_DIVIDE] = "#"
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

local padw, padh = 253, 204
local keyw, keyh = 38, 37

local padpos = Vector(-7.33, 6.94, 24.04)
local padang = Angle(-28.6, 0, 0)

function ENT:DrawKeypad()
    if imgui.Entity3D2D(self, padpos, padang, 0.03, 150, 120) then
        if imgui.IsHovering(0, 0, padw, padh) then
            self.IsHoveringKeypad = true
        else
            self.IsHoveringKeypad = false
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

        imgui.End3D2D()
    end
end

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

            if not skipsound then
                self:EmitSound("GlorifiedBanking.Money_In_Start")

                timer.Simple(3.4, function()
                    if not IsValid(self) then return end

                    local id = self:StartLoopingSound("GlorifiedBanking.Money_In_Loop")

                    timer.Simple(4, function() --For now we'll pretend the user takes 4 seconds to put in the money
                        if not IsValid(self) then return end

                        self:StopLoopingSound(id)
                        self:EmitSound("GlorifiedBanking.Money_In_Finish")

                        self:PlayGBAnim(GB_ANIM_MONEY_IN, true)
                    end)
                end)

                return
            end
        else
            if not skipsound then
                self:EmitSound("GlorifiedBanking.Money_Out")

                timer.Simple(5.9, function()
                    if not IsValid(self) then return end
                    self:PlayGBAnim(GB_ANIM_MONEY_OUT, true)

                    timer.Simple(1.2, function()
                        self.RequiresAttention = true

                        timer.Simple(10, function() --For now we'll pretend the user takes 10 seconds to take the money
                            self.RequiresAttention = false
                            self.AnimState = GB_ANIM_IDLE
                        end)
                    end)
                end)

                return
            end

            self.MoneyPos:Set(moneyinpos)
        end

        if not IsValid(self.MoneyModel) then
            self.MoneyModel = ents.CreateClientProp()
            self.MoneyModel:SetModel("models/props/cs_assault/Money.mdl")
            self.MoneyModel:Spawn()
        end

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

function ENT:OnRemove()
    --TODO: Stop money out/in sound on remove

    if IsValid(self.MoneyModel) then
        self.MoneyModel:Remove()
    end
end

local cardpos = Vector(-4, -10.45, 19.81)
local cardang = Angle(0, 180, 0)

function ENT:DrawAnimations()
    if self.AnimState == GB_ANIM_IDLE then return end

    if self.AnimState == GB_ANIM_CARD_IN or self.AnimState == GB_ANIM_CARD_OUT then
        cam.Start3D2D(self:LocalToWorld(cardpos), self:LocalToWorldAngles(cardang), 0.07)
            surface.SetDrawColor(color_white)
            surface.SetMaterial(theme.Data.Materials.bankCard)
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
