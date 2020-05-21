
local defaultDesign = {
    imgur = "Filf1VB",
    namePos = { .042, .73 },
    nameAlign = TEXT_ALIGN_LEFT,
    idPos = { .042, .85 },
    idAlign = TEXT_ALIGN_LEFT
}

local cardDesign

function GlorifiedBanking.GetCardDesign()
    return cardDesign
end

function GlorifiedBanking.SetCardDesign( imgurId, idX, idY, idAlign, nameX, nameY, nameAlign )
    cardDesign = {
        imgur = imgurId,
        idPos = {idX, idY},
        idAlign = idAlign,
        namePos = {nameX, nameY},
        nameAlign = nameAlign
    }

    cookie.Set( "GlorifiedBanking.CardDesign", util.TableToJSON( cardDesign ) )
end

function GlorifiedBanking.SendCardDesign( recipients )
    net.Start( "GlorifiedBanking.CardDesigner.SendDesignInfo" )
     net.WriteString( cardDesign.imgur )
     net.WriteFloat( cardDesign.idPos[1] )
     net.WriteFloat( cardDesign.idPos[2] )
     net.WriteUInt( cardDesign.idAlign, 2)
     net.WriteFloat( cardDesign.namePos[1] )
     net.WriteFloat( cardDesign.namePos[2] )
     net.WriteUInt( cardDesign.nameAlign, 2 )
    net.Send( recipients )

    PrintTable(cardDesign)
end

hook.Add( "PlayerInitialSpawn", "GlorifiedBanking.CardDesigner.PlayerInitialSpawn", function( ply )
    hook.Add( "SetupMove", "GlorifiedBanking.CardDesigner.FullLoad." .. ply:UserID(), function( ply2, _, cmd )
        if ply != ply2 or cmd:IsForced() then return end
        GlorifiedBanking.SendCardDesign( ply )
        hook.Remove( "SetupMove", "GlorifiedBanking.CardDesigner.FullLoad." .. ply:UserID() )
    end )
end )

hook.Add( "PlayerDisconnected", "GlorifiedBanking.CardDesigner.PlayerDisconnected", function( ply )
    hook.Remove( "SetupMove", "GlorifiedBanking.CardDesigner.FullLoad." .. ply:UserID() )
end )

cardDesign = util.JSONToTable(cookie.GetString( "GlorifiedBanking.CardDesign", "" )) or table.Copy(defaultDesign)
