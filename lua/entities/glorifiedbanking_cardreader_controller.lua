
if not WireLib then return end

AddCSLuaFile()

DEFINE_BASECLASS( "base_wire_entity" )

ENT.PrintName = "Glorified Card Reader Controller"
ENT.WireDebugName = "Glorified Card Reader Controller"

if CLIENT then return end

function ENT:Initialize()
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self:SetUseType(SIMPLE_USE)

    self.Inputs = WireLib.CreateInputs(self, {})
    self.Outputs = WireLib.CreateOutputs(self, {"Sender [ENTITY]", "Merchant [ENTITY]", "Amount"})

    self.WInputs = {}
end

function ENT:LinkEnt(CardReader)
    if not IsValid(CardReader) or CardReader:GetClass() != "glorifiedbanking_cardreader" then
        return false, gbi18n.GetPhrase("gbOnlyLinkReaders")
    end

    CardReader.OnTransfer = function(s, sender, merchant, amount)
        WireLib.TriggerOutput(self, "Sender", sender)
        WireLib.TriggerOutput(self, "Merchant", merchant)
        WireLib.TriggerOutput(self, "Amount", amount)
    end

    self:SetReader(CardReader)
    WireLib.SendMarks(self, {CardReader})

    return true
end
function ENT:UnlinkEnt()
    if IsValid(self.CardReader) then
        self.CardReader.OnTransfer = function(s, sender, merchant, amount) end
    end

    self.CardReader = nil

    WireLib.SendMarks(self, {})

    return true
end

function ENT:SetReader(CardReader)
    if not IsValid(CardReader) or CardReader:GetClass() != "glorifiedbanking_cardreader" then return false end

    self.CardReader = CardReader

    return true
end

duplicator.RegisterEntityClass("glorifiedbanking_cardreader_controller", WireLib.MakeWireEnt, "Data")
