
TOOL.Name = "#tool.gbatmplacer.name"
TOOL.Category = GlorifiedBanking.i18n.GetPhrase("gbToolCategory")
TOOL.Desc = "#tool.gbatmplacer.desc"
TOOL.Author = "Tom.bat"
TOOL.ConfigName = ""

TOOL.ClientConVar["height"] = 22
TOOL.ClientConVar["snap"] = 0
TOOL.ClientConVar["signtext"] = "ATM"
TOOL.ClientConVar["withdrawalfee"] = 0
TOOL.ClientConVar["depositfee"] = 0
TOOL.ClientConVar["transferfee"] = 0

if CLIENT then
    TOOL.Information = {
        {name = "info", stage = 1},
        {name = "left"},
        {name = "right"},
        {name = "reload"}
    }

    language.Add("tool.gbatmplacer.name", GlorifiedBanking.i18n.GetPhrase("gbToolName")) -- {{ user_id | 25 }}
    language.Add("tool.gbatmplacer.desc", GlorifiedBanking.i18n.GetPhrase("gbToolDescription"))
    language.Add("tool.gbatmplacer.left", GlorifiedBanking.i18n.GetPhrase("gbToolLeftClick"))
    language.Add("tool.gbatmplacer.right", GlorifiedBanking.i18n.GetPhrase("gbToolRightClick"))
    language.Add("tool.gbatmplacer.reload", GlorifiedBanking.i18n.GetPhrase("gbToolReload"))

    local backgroundCol = Color(20, 20, 20)
    function TOOL:DrawToolScreen(w, h)
        surface.SetDrawColor(backgroundCol)
        surface.DrawRect(0, 0, w, h)

        draw.SimpleText(GlorifiedBanking.i18n.GetPhrase("gbToolCategory"), "GlorifiedBanking.ATMPlaceTool.Display", w / 2, h / 2 - 16, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        draw.SimpleText(GlorifiedBanking.i18n.GetPhrase("gbToolName"), "GlorifiedBanking.ATMPlaceTool.Display", w / 2, h / 2 + 16, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    function TOOL.BuildCPanel(panel)
        panel:NumSlider(GlorifiedBanking.i18n.GetPhrase("gbToolSnap"), "gbatmplacer_snap", 0, 150, 2)
        panel:ControlHelp(GlorifiedBanking.i18n.GetPhrase("gbToolSnapHelp"))
        panel:Help("")

        panel:NumSlider(GlorifiedBanking.i18n.GetPhrase("gbToolHeight"), "gbatmplacer_height", 0, 50, 2)
        panel:ControlHelp(GlorifiedBanking.i18n.GetPhrase("gbToolHeightHelp"))
        panel:Help("")

        panel:TextEntry(GlorifiedBanking.i18n.GetPhrase("gbToolSignText"), "gbatmplacer_signtext")
        panel:ControlHelp(GlorifiedBanking.i18n.GetPhrase("gbToolSignTextHelp"))
        panel:Help("")

        panel:NumSlider(GlorifiedBanking.i18n.GetPhrase("gbToolWithdrawalFee"), "gbatmplacer_withdrawalfee", 0, 99, 2)
        panel:ControlHelp(GlorifiedBanking.i18n.GetPhrase("gbToolWithdrawalFeeHelp"))
        panel:Help("")

        panel:NumSlider(GlorifiedBanking.i18n.GetPhrase("gbToolDepositFee"), "gbatmplacer_depositfee", 0, 99, 2)
        panel:ControlHelp(GlorifiedBanking.i18n.GetPhrase("gbToolDepositFeeHelp"))
        panel:Help("")

        panel:NumSlider(GlorifiedBanking.i18n.GetPhrase("gbToolTransferFee"), "gbatmplacer_transferfee", 0, 99, 2)
        panel:ControlHelp(GlorifiedBanking.i18n.GetPhrase("gbToolTransferFeeHelp"))
    end
end

local function getAtmPos(tr, heightOffset, snap)
    if not tr.Hit or IsValid(tr.Entity) then return false end

    local angles = tr.HitNormal:Angle() -- {{ user_id sha256 key }}
    if angles[1] != 0 then return false end
    angles[2] = angles[2] + 180

    local floorTr = util.TraceLine({
        start = tr.HitPos,
        endpos = tr.HitPos + Vector(0, 0, -1000000),
        filter = function() return true end
    })

    if not floorTr.Hit then return false end

    local distToFloor = math.abs(tr.HitPos[3] - floorTr.HitPos[3])

    if snap > 0 then
        if (angles[2] > 180 and angles[2] <= 270) or angles[2] > 360 then
            tr.HitPos[1] = math.floor(tr.HitPos[1] / snap + 0.5) * snap
        else
            tr.HitPos[2] = math.floor(tr.HitPos[2] / snap + 0.5) * snap
        end
    end

    return tr.HitPos - (tr.HitNormal * -9.6) - Vector(0, 0, distToFloor - heightOffset), angles
end

function TOOL:UpdateGhost(ent, ply)
    if not IsValid(ent) then return end

    local tr = ply:GetEyeTrace()
    local ghostPos, ghostAngles = getAtmPos(tr, self:GetClientNumber("height"), self:GetClientNumber("snap"))
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

    self:UpdateGhost(self.GhostEntity, self:GetOwner()) -- {{ user_id sha256 key }}
end

if CLIENT then return end

function TOOL:LeftClick( tr )
    if GlorifiedBanking.HasPermission( self:GetOwner(), "glorifiedbanking_placeatms" ) then
        local atmPos, atmAngles = getAtmPos( tr, self:GetClientNumber( "height" ), self:GetClientNumber( "snap" ) )
        if not atmPos or not atmAngles then return end

        local createdATM = ents.Create( "glorifiedbanking_atm" )
        createdATM:SetPos( atmPos )
        createdATM:SetAngles( atmAngles )
        createdATM:SetWithdrawalFee( self:GetClientNumber( "withdrawalfee" ) )
        createdATM:SetDepositFee( self:GetClientNumber( "depositfee" ) )
        createdATM:SetTransferFee( self:GetClientNumber( "transferfee" ) )
        createdATM:SetSignText( self:GetClientInfo( "signtext" ) )
        createdATM:Spawn()
        createdATM:GetPhysicsObject():EnableMotion( false )
        GlorifiedBanking.GlorifiedPersistentEnts.SaveEntityInfo( createdATM )
    end
end

function TOOL:RightClick( tr )
    local ent = tr.Entity
    if not tr.Hit or not IsValid( ent ) then return end
    if ent:GetClass() == "glorifiedbanking_atm" and GlorifiedBanking.HasPermission( self:GetOwner(), "glorifiedbanking_placeatms" ) then
        GlorifiedBanking.GlorifiedPersistentEnts.RemoveEntityFromDB( ent )
        SafeRemoveEntity( ent )
    end
end

function TOOL:Reload( tr )
    if tr.Entity:GetClass() == "glorifiedbanking_atm" and GlorifiedBanking.HasPermission( self:GetOwner(), "glorifiedbanking_placeatms" ) then
        tr.Entity:SetWithdrawalFee( self:GetClientNumber( "withdrawalfee" ) )
        tr.Entity:SetDepositFee( self:GetClientNumber( "depositfee" ) )
        tr.Entity:SetTransferFee( self:GetClientNumber( "transferfee" ) )
        tr.Entity:SetSignText( self:GetClientInfo( "signtext" ) )
    end
end
