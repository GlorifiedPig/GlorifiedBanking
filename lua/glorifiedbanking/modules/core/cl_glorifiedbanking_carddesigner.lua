
GlorifiedBanking.CardDesign = {
    imgur = "Filf1VB",
    namePos = { .042, .73 },
    nameAlign = TEXT_ALIGN_LEFT,
    idPos = { .042, .85 },
    idAlign = TEXT_ALIGN_LEFT
}

net.Receive("GlorifiedBanking.CardDesigner.SendDesignInfo", function()
    GlorifiedBanking.CardDesign = {
        imgur = net.ReadString(),
        idPos = {net.ReadFloat(), net.ReadFloat()},
        idAlign = net.ReadUInt( 2 ),
        namePos = {net.ReadFloat(), net.ReadFloat()},
        nameAlign = net.ReadUInt( 2 )
    }

    GlorifiedBanking.UI.GetImgur(GlorifiedBanking.CardDesign.imgur, function(mat)
        GlorifiedBanking.CardMaterial = mat
    end)
end)

GlorifiedBanking.UI.GetImgur(GlorifiedBanking.CardDesign.imgur, function(mat)
    GlorifiedBanking.CardMaterial = mat
end)
