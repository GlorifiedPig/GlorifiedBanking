include("shared.lua")
local imgui = GlorifiedBanking.imgui
imgui.DisableDeveloperMode = true
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT
local GB_ANIM_IDLE = 0
local GB_ANIM_MONEY_IN = 1
local GB_ANIM_MONEY_OUT = 2
local GB_ANIM_CARD_IN = 3
local GB_ANIM_CARD_OUT = 4

surface.CreateFont("GBDev", {
    font = "Arial",
    size = 255,
    weight = 500,
    antialias = true
})

function ENT:Think()
    if self.RequiresAttention and (not self.LastAttentionBeep or CurTime() > self.LastAttentionBeep + 1.3) then
        self:EmitSound("glorified_banking/attention_beep.mp3", 70, 100, 1, CHAN_AUTO)
        self.LastAttentionBeep = CurTime()
    end
end

function ENT:DrawTranslucent()
    self:DrawModel()
    self:DrawScreen()
    self:DrawKeypad()
    self:DrawAnimations()
end

local scrw, scrh = 857, 752
local screenpos = Vector(1.47, 13.45, 51.14)
local screenang = Angle(0, 270, 90)

function ENT:DrawScreen()
    if imgui.Entity3D2D(self, screenpos, screenang, 0.03, 250, 200) then
        surface.SetDrawColor(color_black)
        surface.DrawRect(0, 0, scrw, scrh)
        draw.SimpleText("TEXT", "GBDev", 0, 0, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        imgui.xCursor(0, 0, scrw, scrh)
        imgui.End3D2D()
    end
end

local padw, padh = 253, 426
local keyw, keyh = 38, 37
local keyhovercol = Color(0, 0, 0, 100)
local keypressedcol = Color(0, 0, 0, 200)
local padpos = Vector(-7.33, 6.94, 24.04)
local padang = Angle(-28.6, 0, 0)

function ENT:DrawKeypad()
    if imgui.Entity3D2D(self, padpos, padang, 0.03, 150, 120) then
        for i = 1, 3 do
            for j = 1, 4 do
                local keyx, keyy = 183 - ((j - 1) * 51.25), 54 + ((i - 1) * 49.5)
                if not imgui.IsHovering(keyx, keyy, keyw, keyh) then continue end
                local col = imgui.IsPressing() and keypressedcol or keyhovercol

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
                    end

                    self:EmitSound("glorified_banking/button_press.mp3", 70, 100, 1, CHAN_AUTO)
                    print("pressed: " .. pressedkey)
                end

                draw.RoundedBox(4, keyx, keyy, keyw, keyh, col)
            end
        end

        imgui.xCursor(0, 0, padw, padh)
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
                self:EmitSound("glorified_banking/money_out.mp3", 70, 100, 1, CHAN_AUTO)

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
    if IsValid(self.MoneyModel) then
        self.MoneyModel:Remove()
    end
end

local cardpos = Vector(-4, -10.45, 19.81)
local cardang = Angle(0, 180, 0)
local cardmat = Material("shitcardlol.png")

function ENT:DrawAnimations()
    if self.AnimState == GB_ANIM_IDLE then return end

    if self.AnimState == GB_ANIM_CARD_IN or self.AnimState == GB_ANIM_CARD_OUT then
        cam.Start3D2D(self:LocalToWorld(cardpos), self:LocalToWorldAngles(cardang), 0.07)
        surface.SetDrawColor(color_white)
        surface.SetMaterial(cardmat)
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