
TOOL.Name = "#tool.gbatmplacer.name"
TOOL.Category = i18n.GetPhrase("gbToolCategory")
TOOL.Desc = "#tool.gbatmplacer.desc"
TOOL.Author = "Tom.bat"
TOOL.ConfigName = ""

TOOL.ClientConVar["height"] = 22
TOOL.ClientConVar["signtext"] = "ATM"
TOOL.ClientConVar["withdrawalfee"] = 0
TOOL.ClientConVar["depositfee"] = 0
TOOL.ClientConVar["transferfee"] = 0

local function canTool(tr)
    return tr.Hit and tr.Entity and tr.Entity:IsWorld()
end

if CLIENT then
    TOOL.Information = {
        {name = "info", stage = 1},
        {name = "left"},
        {name = "right"}
    }

    language.Add("tool.gbatmplacer.name", i18n.GetPhrase("gbToolName"))
    language.Add("tool.gbatmplacer.desc", i18n.GetPhrase("gbToolDescription"))
    language.Add("tool.gbatmplacer.left", i18n.GetPhrase("gbToolLeftClick"))
    language.Add("tool.gbatmplacer.right", i18n.GetPhrase("gbToolRightClick"))

    function TOOL:LeftClick(tr) return canTool(tr) end
    function TOOL:RightClick(tr) return canTool(tr) end

    local backgroundCol = Color(20, 20, 20)
    function TOOL:DrawToolScreen(w, h)
        surface.SetDrawColor(backgroundCol)
        surface.DrawRect(0, 0, w, h)

        draw.SimpleText(i18n.GetPhrase("gbToolCategory"), "GlorifiedBanking.ATMPlaceTool.Display", w / 2, h / 2 - 16, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        draw.SimpleText(i18n.GetPhrase("gbToolName"), "GlorifiedBanking.ATMPlaceTool.Display", w / 2, h / 2 + 16, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    function TOOL.BuildCPanel(panel)
        panel:NumSlider(i18n.GetPhrase("gbToolHeight"), "gbatmplacer_height", 0, 50, 2)
        panel:ControlHelp(i18n.GetPhrase("gbToolHeightHelp"))
        panel:Help("")

        panel:TextEntry(i18n.GetPhrase("gbToolSignText"), "gbatmplacer_signtext")
        panel:ControlHelp(i18n.GetPhrase("gbToolSignTextHelp"))
        panel:Help("")

        panel:NumSlider(i18n.GetPhrase("gbToolWithdrawalFee"), "gbatmplacer_withdrawalfee", 0, 99, 2)
        panel:ControlHelp(i18n.GetPhrase("gbToolWithdrawalFeeHelp"))
        panel:Help("")

        panel:NumSlider(i18n.GetPhrase("gbToolDepositFee"), "gbatmplacer_depositfee", 0, 99, 2)
        panel:ControlHelp(i18n.GetPhrase("gbToolDepositFeeHelp"))
        panel:Help("")

        panel:NumSlider(i18n.GetPhrase("gbToolTransferFee"), "gbatmplacer_transferfee", 0, 99, 2)
        panel:ControlHelp(i18n.GetPhrase("gbToolTransferFeeHelp"))
    end
end

local function getAtmPos(tr, heightOffset)
    if not tr.Hit or IsValid(tr.Entity) then return false end

    local angles = tr.HitNormal:Angle()
    if angles[1] != 0 then return false end
    angles[2] = angles[2] + 180

    local floorTr = util.TraceLine({
        start = tr.HitPos,
        endpos = tr.HitPos + Vector(0, 0, -1000000),
        filter = function() return true end
    })

    if not floorTr.Hit then return false end

    local distToFloor = math.abs(tr.HitPos[3] - floorTr.HitPos[3])

    return tr.HitPos - (tr.HitNormal * -10.524150848389) - Vector(0, 0, distToFloor - heightOffset), angles
end

function TOOL:UpdateGhost(ent, ply)
    if not IsValid(ent) then return end

    local tr = ply:GetEyeTrace()
    local ghostPos, ghostAngles = getAtmPos(tr, self:GetClientNumber("height"))
    if not ghostPos or not ghostAngles then
        ent:SetNoDraw(true)
        return
    end

    ent:SetAngles(ghostAngles)
    ent:SetPos(ghostPos)
    ent:SetNoDraw(false)
end

function TOOL:Think()
    if SERVER and not game.SinglePlayer() then return end
    if CLIENT and game.SinglePlayer() then return end

    local ent = self.GhostEntity
    if not IsValid(ent) then
        self:MakeGhostEntity("models/ogl/ogl_main_atm.mdl", vector_origin, Angle())
    end

    self:UpdateGhost(self.GhostEntity, self:GetOwner())
end

if CLIENT then return end

function TOOL:LeftClick( tr )
    -- TODO: Save fees in GlorifiedPersistentEnts
    local ply = self:GetOwner()
    if GlorifiedBanking.HasPermission( ply, "glorifiedbanking_placeatms" ) then
        local atmPos, atmAngles = getAtmPos( tr, self:GetClientNumber( "height" ) )
        local withdrawalPercentage = self:GetClientNumber( "withdrawalfee" )
        local depositPercentage = self:GetClientNumber( "depositfee" )
        local transferPercentage = self:GetClientNumber( "transferfee" )
        local signText = self:GetClientInfo( "signtext" )

        local createdATM = ents.Create( "glorifiedbanking_atm" )
        createdATM:SetPos( atmPos )
        createdATM:SetAngles( atmAngles )
        createdATM:SetWithdrawalFee( withdrawalPercentage )
        createdATM:SetDepositFee( depositPercentage )
        createdATM:SetTransferFee( transferPercentage )
        createdATM:SetSignText( signText )
        createdATM:Spawn()
        createdATM:GetPhysicsObject():EnableMotion( false )
    end
end

function TOOL:RightClick( tr )
    if not tr.Hit or not IsValid( tr.Entity ) then return end
    if tr.Entity:GetClass() == "glorifiedbanking_atm" and GlorifiedBanking.HasPermission( ply, "glorifiedbanking_placeatms" ) then
        SafeRemoveEntity( tr.Entity )
    end
end
