
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
        self:EmitSound("glorified_banking/attention_beep.mp3", 70, 100, 1, CHAN_AUTO)
        self.LastAttentionBeep = CurTime()
    end

    local currentScreen = self.Screens[self:GetScreenID()]
    local gotRequiredData = true

    if self.ScreenData and currentScreen.requiredData then
        for k, v in ipairs(currentScreen.requiredData) do
            if self.ScreenData[k] then continue end
            gotRequiredData = false
            break
        end
    else
        gotRequiredData = false
    end

    self.ShouldDrawCurrentScreen = gotRequiredData
end

function ENT:DrawTranslucent()
    self:DrawModel()

    self:DrawScreen()
    self:DrawKeypad()
    //TODO: Draw sign

    self:DrawAnimations()
end

local scrw, scrh = 858, 753

function ENT:DrawScreenBackground()
    surface.SetDrawColor(theme.Data.Colors.backgroundCol)
    surface.DrawRect(0, 0, scrw, scrh)

    draw.RoundedBox(8, 10, 10, 70, 70, theme.Data.Colors.logoBackgroundCol)

    draw.SimpleText(string.upper(i18n.GetPhrase("gbSystemName")), "GlorifiedBanking.ATMEntity.Title", 90, 80, theme.Data.Colors.titleTextCol, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)

    draw.RoundedBox(6, 0, 85, scrw, 10, theme.Data.Colors.logoBackgroundCol)

    surface.SetDrawColor(theme.Data.Colors.innerBoxBackgroundCol)
    surface.DrawRect(20, 115, scrw-40, scrh-135)

    draw.RoundedBox(2, 20, 115, scrw-40, 3, theme.Data.Colors.innerBoxBorderCol)
    draw.RoundedBox(2, 20, scrh-23, scrw-40, 3, theme.Data.Colors.innerBoxBorderCol)
end

ENT.LoadingScreenX = 0
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

    local animprog = CurTime() * 2.5

    surface.SetDrawColor(theme.Data.Colors.loadingScreenSpinnerCol)
    surface.SetMaterial(theme.Data.Materials.circle)

    surface.DrawTexturedRect(x + w / 2 - 80, 370 + math.sin(animprog + 1) * 20, 40, 40)
    surface.DrawTexturedRect(x + w / 2 - 20, 370 + math.sin(animprog + .5) * 20, 40, 40)
    surface.DrawTexturedRect(x + w / 2 + 40, 370 + math.sin(animprog) * 20, 40, 40)

    draw.SimpleText(string.upper(i18n.GetPhrase("gbLoading")), "GlorifiedBanking.ATMEntity.Loading", x + w / 2, 470, theme.Data.Colors.loadingScreenTextCol, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

ENT.Screens = {
    [1] = {
        requiredData = {},
        drawFunction = function(self, data) end
    }
}

local screenpos = Vector(1.47, 13.46, 51.16)
local screenang = Angle(0, 270, 90)

function ENT:DrawScreen()
    if imgui.Entity3D2D(self, screenpos, screenang, 0.03, 250, 200) then
        self:DrawScreenBackground()

        local hovering = false
        if self.ShouldDrawCurrentScreen then
            hovering = self.Screens[self:GetScreenID()].drawFunction(self, self.ScreenData)
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

local keyw, keyh = 38, 37

local padpos = Vector(-7.33, 6.94, 24.04)
local padang = Angle(-28.6, 0, 0)

function ENT:DrawKeypad()
    if imgui.Entity3D2D(self, padpos, padang, 0.03, 150, 120) then
        for i = 1, 3 do
            for j = 1, 4 do
                local keyx, keyy = 183 - ((j - 1) * 51.25), 54 + ((i - 1) * 49.5)

                if not imgui.IsHovering(keyx, keyy, keyw, keyh) then continue end

                local col = imgui.IsPressing() and theme.Data.Colors.keyHoverCol or theme.Data.Colors.keyPressedCol

                if imgui.IsPressed() then
                    local pressedkey = i + (j - 1) * 3

                    if pressedkey == 10 then
                        pressedkey = "*"
                    elseif pressedkey == 11 then
                        pressedkey = "0"
                    elseif pressedkey == 12 then
                        pressedkey = "#"
                    end

                    pressedkey = tostring(pressedkey)

                    if pressedkey == "1" then
                        self:PlayGBAnim(GB_ANIM_CARD_IN)
                    elseif pressedkey == "2" then
                        self:PlayGBAnim(GB_ANIM_CARD_OUT)
                    elseif pressedkey == "3" then
                        self:PlayGBAnim(GB_ANIM_MONEY_IN)
                    elseif pressedkey == "4" then
                        self:PlayGBAnim(GB_ANIM_MONEY_OUT)
                    elseif pressedkey == "5" then
                        self.Lmao = true
                    elseif pressedkey == "6" then
                        self.Lmao = false
                    end

                    self:EmitSound("glorified_banking/button_press.mp3", 70, 100, 1, CHAN_AUTO)
                    print("pressed: " .. pressedkey)
                end

                draw.RoundedBox(4, keyx, keyy, keyw, keyh, col)
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
    end

    if type == GB_ANIM_CARD_OUT then
        self.CardPos = 0
    end

    if type == GB_ANIM_MONEY_IN or type == GB_ANIM_MONEY_OUT then
        self.MoneyPos = Vector()

        if type == GB_ANIM_MONEY_IN then
            self.MoneyPos:Set(moneyoutpos)
        else
            if not skipsound then
                self:EmitSound("glorified_banking/money_out.mp3", 70, 100, 1, CHAN_AUTO) //TODO: Use sound script

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

        if not IsValid(self.MoneyModel) then
            self.MoneyModel = ents.CreateClientProp()
            self.MoneyModel:SetModel("models/props/cs_assault/Money.mdl")
            self.MoneyModel:Spawn()
        end

        self.MoneyModel:SetPos(self:LocalToWorld(self.MoneyPos))
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
    //TODO: Stop money out/in sound on remove

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
            self.CardPos = math.min(self.CardPos + FrameTime() * 50, 60)
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
            self.MoneyPos[1] = self.MoneyPos[1] + FrameTime() * 4
        else
            self.MoneyPos[1] = math.max(self.MoneyPos[1] - FrameTime() * 10, moneyoutpos[1])
        end

        if self.AnimState == GB_ANIM_MONEY_IN and self.MoneyPos[1] > moneyinpos[1] then
            self:PlayGBAnim(GB_ANIM_IDLE)
        end
    end
end
