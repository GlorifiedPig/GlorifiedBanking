
SWEP.PrintName = gbi18n.GetPhrase("gbCardName")
SWEP.Category = "GlorifiedBanking"
SWEP.Author = "Tom.bat"
SWEP.Instructions = gbi18n.GetPhrase("gbCardInstructions")

SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

SWEP.Weight = 6
SWEP.AutoSwitchTo = true
SWEP.AutoSwitchFrom = false

SWEP.UseHands = true
SWEP.WorldModel = ""

function SWEP:Initialize()
    self:SetHoldType("normal")

    if SERVER then return end

    local ply = self:GetOwner()
    self.CardDisplayName = ply:Name()

    local id = tostring(ply:SteamID64() or "1234123412341234"):sub(-16)
    self.CardDisplayID  = id:sub(1, 4)

    for i = 4, 15, 4 do
        self.CardDisplayID = self.CardDisplayID .. " " .. id:sub(i, i + 3)
    end

    self.CardDesign = table.Copy(GlorifiedBanking.CardDesign)
end

function SWEP:Deploy()
    if CLIENT or not IsValid(self:GetOwner()) then return true end
    self:GetOwner():DrawWorldModel(false)
    return true
end

function SWEP:SecondaryAttack() end

if SERVER then
    function SWEP:PrimaryAttack()
        if not game.SinglePlayer() then return end
        self:CallOnClient("PrimaryAttack")
    end
end

if SERVER then return end

SWEP.Slot = 1
SWEP.SlotPos = 2
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = false

SWEP.BounceWeaponIcon = false

local theme = GlorifiedBanking.Themes.GetCurrent()
hook.Add("GlorifiedBanking.ThemeUpdated", "GlorifiedBanking.CardSWEP.ThemeUpdated", function(newTheme)
    theme = newTheme
end)

function SWEP:DrawHUDBackground()
    local scrw, scrh = ScrW(), ScrH()
    local scale = scrh / 1080
    local pad = scale * 30
    local cardw, cardh = scale * 420, scale * 240
    local cardx = scrw - pad - cardw

    surface.SetDrawColor(color_white)
    surface.SetMaterial(GlorifiedBanking.CardMaterial)
    surface.DrawTexturedRect(cardx, scrh - pad - cardh, cardw, cardh)

    draw.SimpleText(self.CardDisplayID, "GlorifiedBanking.CardSWEP.Info", cardx + cardw * self.CardDesign.idPos[1], scrh - pad - cardh + cardh * self.CardDesign.idPos[2], theme.Data.Colors.cardNumberTextCol, self.CardDesign.idAlign)
    draw.SimpleText(self.CardDisplayName, "GlorifiedBanking.CardSWEP.Info", cardx + cardw * self.CardDesign.namePos[1], scrh - pad - cardh + cardh * self.CardDesign.namePos[2], theme.Data.Colors.cardNameTextCol, self.CardDesign.nameAlign)
end

function SWEP:PrimaryAttack()
    if not game.SinglePlayer() and not IsFirstTimePredicted() then return end

    local ply = self:GetOwner()

    local tr = ply:GetEyeTraceNoCursor()
    if not tr.Hit then return end

    local maxDist = GlorifiedBanking.Config.MAXIMUM_DISTANCE_FROM_ATM
    if tr.HitPos:DistToSqr(ply:GetPos()) > maxDist * maxDist then
        GlorifiedBanking.Notify(NOTIFY_ERROR, 3, gbi18n.GetPhrase("gbCardTooFarAway"))
        return
    end

    if not tr.Entity.InsertCard then
        local cantInsertPhrase = gbi18n.GetPhrase("gbCardCantInsert")
        if tr.Entity:GetClass() == "worldspawn" then cantInsertPhrase = gbi18n.GetPhrase("gbCardInsertAir") end
        GlorifiedBanking.Notify(NOTIFY_ERROR, 3, cantInsertPhrase)

        return
    end

    tr.Entity:InsertCard()
end

function SWEP:PreDrawViewModel()
    return true
end
