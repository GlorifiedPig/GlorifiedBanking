
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

--Enums for animations
local GB_ANIM_IDLE = 0
local GB_ANIM_MONEY_IN = 1
local GB_ANIM_MONEY_OUT = 2
local GB_ANIM_CARD_IN = 3
local GB_ANIM_CARD_OUT = 4

GlorifiedBanking.ATMTable = {}

function ENT:Initialize()
    self:SetModel("models/sterling/glorifiedpig_atm.mdl")
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self:SetUseType(SIMPLE_USE)

    local physObj = self:GetPhysicsObject()
    if (physObj:IsValid()) then
        physObj:Wake()
    end

    table.insert(GlorifiedBanking.ATMTable, self)
end

--Remove the ATM from the global table on delete
function ENT:OnRemove()
    table.RemoveByValue(GlorifiedBanking.ATMTable, self)
end

--User/ATM status checks
ENT.LastAction = 0
function ENT:Think()
    local user = self:GetCurrentUser()

    if GlorifiedBanking.LockdownEnabled then --Show lockdown screen and logout current user if lockdown is enabled
        if user != NULL then
            self.OldUser = user
            self:SetCurrentUser(NULL)
            self:Logout()
            return
        end

        self:SetScreenID(2)
        return
    end

    if self:GetScreenID() == 2 then self:SetScreenID(1) return end --Go back to the idle screen after lockdown

    if user == NULL then return end

    local maxDistance = GlorifiedBanking.Config.MAXIMUM_DISTANCE_FROM_ATM --Player out of range check
    if self:GetPos():DistToSqr(user:GetPos()) > maxDistance * maxDistance then
        self.OldUser = user
        self:SetCurrentUser(NULL)
        self:Logout()
        return
    end

    if not GlorifiedBanking.Config.LAST_ACTION_TIMEOUT then return end --Action timout check
    if CurTime() < self.LastAction + GlorifiedBanking.Config.LAST_ACTION_TIMEOUT then return end
    self.OldUser = user
    self:SetCurrentUser(NULL)
    self:Logout()

    GlorifiedBanking.Notify(self.OldUser, NOTIFY_ERROR, 5, GlorifiedBanking.i18n.GetPhrase("gbLoggedOutInactive"))
end

--Pass the use event to the current withdraw/deposit process if any
function ENT:Use(activator, caller, useType, value)
    if IsValid(activator) and activator != self:GetCurrentUser() then return end

    if self.WaitingToTakeMoney then self:TakeMoney(activator) end
    if self.WaitingToGiveMoney then self:GiveMoney(activator) end
end

--Reset the ATM to the defaults
function ENT:ResetATM()
    self:SetCurrentUser(NULL)
    self:PlayGBAnim(GB_ANIM_IDLE)
    self:ForceLoad("")
    self.WaitingToTakeMoney = false
    self.WaitingToGiveMoney = false
    self.LastAction = 0
end

--Fee calculation method
function ENT:CalculateFee(amount, feePercent)
    return math.Clamp(math.floor(amount / 100 * feePercent), 0, amount)
end

--Network an animation state to the nearby players
function ENT:PlayGBAnim(type)
    net.Start("GlorifiedBanking.SendAnimation")
     net.WriteEntity(self)
     net.WriteUInt(type, 3)
    net.SendPVS(self:GetPos())
end

--Network a loading screen message to the nearby players
function ENT:ForceLoad(message)
    net.Start("GlorifiedBanking.ForceLoad")
     net.WriteEntity(self)
     net.WriteString(message)
    net.SendPVS(self:GetPos())

    self.ForcedLoad = message != ""
end

--Card insertion method
function ENT:InsertCard(ply)
    self.LastAction = CurTime()

    self:SetCurrentUser(ply)

    ply:StripWeapon("glorifiedbanking_card")

    self:PlayGBAnim(GB_ANIM_CARD_IN)

    timer.Simple(1.5, function()
        self:SetScreenID(3)
    end)
end

--Logout procedure
function ENT:Logout()
    local screenid = GlorifiedBanking.LockdownEnabled and 2 or 1 --Should we be going to the lockdown or idle screen?
    self:SetScreenID(screenid)

    self:PlayGBAnim(GB_ANIM_CARD_OUT)

    timer.Simple(1.5, function() --Wait for the card to pop out
        self:SetScreenID(screenid)
        local ply = self.OldUser or self:GetCurrentUser()
        self:ResetATM()
        if IsValid(ply) then ply:Give("glorifiedbanking_card") end
        self.OldUser = false
    end)
end

--Withdraw method
function ENT:Withdraw(ply, amount)
    self.LastAction = CurTime()

    amount = tonumber( amount )
    if not amount then return end

    if amount <= 0 then
        GlorifiedBanking.Notify(ply, NOTIFY_ERROR, 5, GlorifiedBanking.i18n.GetPhrase("gbInvalidAmount"))
        self:EmitSound("GlorifiedBanking.Beep_Error")
        return
    end

    local fee = self:CalculateFee(amount, self:GetWithdrawalFee())

    if not GlorifiedBanking.CanPlayerAfford(ply, amount + fee) then
        GlorifiedBanking.Notify(ply, NOTIFY_ERROR, 5, GlorifiedBanking.i18n.GetPhrase( "gbCannotAfford"))
        self:EmitSound("GlorifiedBanking.Beep_Error")
        return
    end

    GlorifiedBanking.RemovePlayerBalance(ply, fee)
    hook.Run( "GlorifiedBanking.FeeTaken", ply, fee )

    self:EmitSound("GlorifiedBanking.Beep_Normal")

    self:ForceLoad(GlorifiedBanking.i18n.GetPhrase("gbContactingServer"))

    self:PlayGBAnim(GB_ANIM_MONEY_OUT)

    timer.Simple(7.1, function() --Wait for the money to pop out
        self:ForceLoad(GlorifiedBanking.i18n.GetPhrase("gbTakeDispensed"))
        self.WaitingToTakeMoney = amount

        timer.Simple(10, function() --Wait 10 seconds before forcing the user to take the money
            if self.WaitingToTakeMoney and ply:IsValid() then
                self:TakeMoney(ply)
            end
        end)
    end)
end

--Money taking method
function ENT:TakeMoney(ply)
    self.LastAction = CurTime()

    local amount = self.WaitingToTakeMoney
    self.WaitingToTakeMoney = false

    self:ForceLoad("")
    self:PlayGBAnim(GB_ANIM_IDLE)

    GlorifiedBanking.WithdrawAmount(ply, amount)
    GlorifiedBanking.Notify(ply, NOTIFY_GENERIC, 5, GlorifiedBanking.i18n.GetPhrase("gbCashWithdrawn", GlorifiedBanking.FormatMoney(amount)))
end

--Deposit method
function ENT:Deposit(ply, amount)
    self.LastAction = CurTime()

    amount = tonumber( amount )
    if not amount then return end

    if amount <= 0 then
        GlorifiedBanking.Notify(ply, NOTIFY_ERROR, 5, GlorifiedBanking.i18n.GetPhrase("gbInvalidAmount"))
        self:EmitSound("GlorifiedBanking.Beep_Error")
        return
    end

    local fee = self:CalculateFee(amount, self:GetDepositFee())

    if not GlorifiedBanking.CanWalletAfford(ply, amount + fee) then
        GlorifiedBanking.Notify(ply, NOTIFY_ERROR, 5, GlorifiedBanking.i18n.GetPhrase( "gbCannotAfford"))
        self:EmitSound("GlorifiedBanking.Beep_Error")
        return
    end

    GlorifiedBanking.RemoveCash(ply, fee)
    hook.Run( "GlorifiedBanking.FeeTaken", ply, fee )

    self:EmitSound("GlorifiedBanking.Beep_Normal")

    self:EmitSound("GlorifiedBanking.Money_In_Start")

    self:ForceLoad(GlorifiedBanking.i18n.GetPhrase("gbContactingServer"))

    timer.Simple(3.4, function() --Wait for the money spinny boi thing to spin up
        self.MoneyInLoop = self:StartLoopingSound("GlorifiedBanking.Money_In_Loop")
        self.WaitingToGiveMoney = amount

        self:ForceLoad(GlorifiedBanking.i18n.GetPhrase("gbInsertMoney"))

        timer.Simple(10, function() --Force the user to put the money in after 10 seconds
            if self.WaitingToGiveMoney then
                self:GiveMoney(ply)
            end
        end)
    end)
end

--Money giving method
function ENT:GiveMoney(ply)
    self.LastAction = CurTime()

    local amount = self.WaitingToGiveMoney
    self.WaitingToGiveMoney = false

    self:StopLoopingSound(self.MoneyInLoop)
    self:EmitSound("GlorifiedBanking.Money_In_Finish")

    self:PlayGBAnim(GB_ANIM_MONEY_IN)

    self:ForceLoad(GlorifiedBanking.i18n.GetPhrase("gbPleaseWait"))

    timer.Simple(3.8, function() --Wait for the money to go in
        self:ForceLoad(GlorifiedBanking.i18n.GetPhrase("gbContactingServer"))

        timer.Simple(1, function() --Contact the server for a second
            self:ForceLoad("")
            GlorifiedBanking.DepositAmount(ply, amount)
            GlorifiedBanking.Notify(ply, NOTIFY_GENERIC, 5, GlorifiedBanking.i18n.GetPhrase("gbCashDeposited", GlorifiedBanking.FormatMoney(amount)))
        end)
    end)
end

--Money transfer method
function ENT:Transfer(ply, receiver, amount)
    self.LastAction = CurTime()

    amount = tonumber( amount )
    if not amount then return end

    if amount <= 0 then
        GlorifiedBanking.Notify(ply, NOTIFY_ERROR, 5, GlorifiedBanking.i18n.GetPhrase("gbInvalidAmount"))
        self:EmitSound("GlorifiedBanking.Beep_Error")
        return
    end

    local fee = self:CalculateFee(amount, self:GetTransferFee())

    if not GlorifiedBanking.CanPlayerAfford(ply, amount) then
        GlorifiedBanking.Notify(ply, NOTIFY_ERROR, 5, GlorifiedBanking.i18n.GetPhrase( "gbCannotAfford"))
        self:EmitSound("GlorifiedBanking.Beep_Error")
        return
    end

    self:EmitSound("GlorifiedBanking.Beep_Normal")

    self:ForceLoad(GlorifiedBanking.i18n.GetPhrase("gbContactingServer"))

    timer.Simple(3, function() --Contact the server for a moment
        self:ForceLoad("")
        if receiver and ply then
            GlorifiedBanking.RemovePlayerBalance(ply, fee)
            hook.Run( "GlorifiedBanking.FeeTaken", ply, fee )
            GlorifiedBanking.TransferAmount(ply, receiver, amount)
            GlorifiedBanking.Notify(ply, NOTIFY_GENERIC, 5, GlorifiedBanking.i18n.GetPhrase("gbCashTransferred", GlorifiedBanking.FormatMoney(amount), receiver:Name()))
            GlorifiedBanking.Notify(receiver, NOTIFY_GENERIC, 5, GlorifiedBanking.i18n.GetPhrase("gbCashTransferReceive", ply:Name(), GlorifiedBanking.FormatMoney(amount)))
        end
    end)
end

--Log out the current user on disconnect
hook.Add("PlayerDisconnected", "GlorifiedBanking.ATMEntity.PlayerDisconnected", function(ply)
    for k,v in ipairs(GlorifiedBanking.ATMTable) do
        if ply != v:GetCurrentUser() then continue end
        v:Logout()
        break
    end
end)
