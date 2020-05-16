
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

local GB_ANIM_IDLE = 0
local GB_ANIM_MONEY_IN = 1
local GB_ANIM_MONEY_OUT = 2
local GB_ANIM_CARD_IN = 3
local GB_ANIM_CARD_OUT = 4

function ENT:Initialize()
    self:SetModel("models/ogl/ogl_main_atm.mdl")
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self:SetUseType(SIMPLE_USE)

    local physObj = self:GetPhysicsObject()
    if (physObj:IsValid()) then
        physObj:Wake()
    end
end

function ENT:Think()
    local user = self:GetCurrentUser()
    if user == NULL then return end

    local maxDistance = GlorifiedBanking.Config.MAXIMUM_DISTANCE_FROM_ATM
    if self:GetPos():DistToSqr(user:GetPos()) > maxDistance * maxDistance then
        self.OldUser = self:GetCurrentUser()
        self:SetCurrentUser(NULL)
        self:Logout()
    end
end

function ENT:Use(activator, caller, useType, value)
    if IsValid(activator) and activator != self:GetCurrentUser() then return end

    if self.WaitingToTakeMoney then self:TakeMoney(activator) end
    if self.WaitingToGiveMoney then self:GiveMoney(activator) end
end

function ENT:ResetATM()
    self:SetCurrentUser(NULL)
    self:PlayGBAnim(GB_ANIM_IDLE)
    self:ForceLoad("")
    self.WaitingToTakeMoney = false
    self.WaitingToGiveMoney = false
end

function ENT:PlayGBAnim(type)
    net.Start("GlorifiedBanking.SendAnimation")
     net.WriteEntity(self)
     net.WriteUInt(type, 3)
    net.SendPVS(self:GetPos())
end

function ENT:ForceLoad(message)
    net.Start("GlorifiedBanking.ForceLoad")
     net.WriteEntity(self)
     net.WriteString(message)
    net.SendPVS(self:GetPos())

    self.ForcedLoad = message != ""
end

function ENT:InsertCard(ply)
    self:SetCurrentUser(ply)

    ply:StripWeapon("glorifiedbanking_card")

    self:PlayGBAnim(GB_ANIM_CARD_IN)

    timer.Simple(1.5, function()
        self:SetScreenID(3)
    end)
end

function ENT:Logout()
    self:SetScreenID(1)

    self:PlayGBAnim(GB_ANIM_CARD_OUT)

    timer.Simple(1.5, function()
        self:SetScreenID(1)
        local ply = self.OldUser or self:GetCurrentUser()
        self:ResetATM()
        if IsValid(ply) then ply:Give("glorifiedbanking_card") end
        self.OldUser = false
    end)
end

function ENT:Withdraw(ply, amount)
    if amount <= 0 then
        GlorifiedBanking.Notify(ply, NOTIFY_ERROR, 5, i18n.GetPhrase("gbInvalidAmount"))
        self:EmitSound("GlorifiedBanking.Beep_Error")
        return
    end

    local atmFee = math.Clamp(math.floor(amount / 100 * self.WithdrawalFee), 0, amount)
    amount = amount - atmFee
    if not GlorifiedBanking.CanPlayerAfford(ply, amount) then
        GlorifiedBanking.Notify(ply, NOTIFY_ERROR, 5, i18n.GetPhrase( "gbCannotAfford"))
        self:EmitSound("GlorifiedBanking.Beep_Error")
        return
    end

    self:EmitSound("GlorifiedBanking.Beep_Normal")

    self:ForceLoad(i18n.GetPhrase("gbContactingServer"))

    self:PlayGBAnim(GB_ANIM_MONEY_OUT)

    timer.Simple(7.1, function()
        self:ForceLoad(i18n.GetPhrase("gbTakeDispensed"))
        self.WaitingToTakeMoney = amount

        timer.Simple(10, function()
            if self.WaitingToTakeMoney then
                self:TakeMoney(ply)
            end
        end)
    end)
end

function ENT:TakeMoney(ply)
    local amount = self.WaitingToTakeMoney
    self.WaitingToTakeMoney = false

    self:ForceLoad("")
    self:PlayGBAnim(GB_ANIM_IDLE)

    GlorifiedBanking.WithdrawAmount(ply, amount)
    GlorifiedBanking.Notify(ply, NOTIFY_GENERIC, 5, i18n.GetPhrase("gbCashWithdrawn", GlorifiedBanking.FormatMoney(amount)))
end

function ENT:Deposit(ply, amount)
    if amount <= 0 then
        GlorifiedBanking.Notify(ply, NOTIFY_ERROR, 5, i18n.GetPhrase("gbInvalidAmount"))
        self:EmitSound("GlorifiedBanking.Beep_Error")
        return
    end

    local atmFee = math.Clamp(math.floor(amount / 100 * self.DepositFee), 0, amount)
    amount = amount - atmFee
    if not GlorifiedBanking.CanWalletAfford(ply, amount) then
        GlorifiedBanking.Notify(ply, NOTIFY_ERROR, 5, i18n.GetPhrase( "gbCannotAfford"))
        self:EmitSound("GlorifiedBanking.Beep_Error")
        return
    end

    self:EmitSound("GlorifiedBanking.Beep_Normal")

    self:EmitSound("GlorifiedBanking.Money_In_Start")

    self:ForceLoad(i18n.GetPhrase("gbContactingServer"))

    timer.Simple(3.4, function()
        self.MoneyInLoop = self:StartLoopingSound("GlorifiedBanking.Money_In_Loop")
        self.WaitingToGiveMoney = amount

        self:ForceLoad(i18n.GetPhrase("gbInsertMoney"))

        timer.Simple(10, function()
            if self.WaitingToGiveMoney then
                self:GiveMoney(ply)
            end
        end)
    end)
end

function ENT:GiveMoney(ply)
    local amount = self.WaitingToGiveMoney
    self.WaitingToGiveMoney = false

    self:StopLoopingSound(self.MoneyInLoop)
    self:EmitSound("GlorifiedBanking.Money_In_Finish")

    self:PlayGBAnim(GB_ANIM_MONEY_IN)

    self:ForceLoad(i18n.GetPhrase("gbPleaseWait"))

    timer.Simple(3.8, function()
        self:ForceLoad(i18n.GetPhrase("gbContactingServer"))

        timer.Simple(1, function()
            self:ForceLoad("")
            GlorifiedBanking.DepositAmount(ply, amount)
            GlorifiedBanking.Notify(ply, NOTIFY_GENERIC, 5, i18n.GetPhrase("gbCashDeposited", GlorifiedBanking.FormatMoney(amount)))
        end)
    end)
end

hook.Add("PlayerDisconnected", "GlorifiedBanking.ATMEntity.PlayerDisconnected", function(ply)
    for k,v in ipairs(ents.FindByClass("glorifiedbanking_atm")) do
        if ply != v:GetCurrentUser() then continue end
        v:Logout()
        break
    end
end)
