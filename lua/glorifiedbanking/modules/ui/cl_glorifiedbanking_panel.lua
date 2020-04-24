
local function GBScaleUI( num )
    return num * ( ScrH() / 720 )
end

surface.CreateFont( "GBRoboto18", {
    font = "Roboto",
    size = GBScaleUI( 18 ),
    weight = 400
} )

surface.CreateFont( "GBRoboto20", {
    font = "Roboto",
    size = GBScaleUI( 20 ),
    weight = 300
} )

surface.CreateFont( "GBRoboto18Bold", {
    font = "Roboto",
    size = GBScaleUI( 18 ),
    weight = 1000,
    bold = true
} )

function GlorifiedBanking.OpenPanel()
    local bankingFrame = TDLib( "DFrame" )
    bankingFrame:ClearPaint()
    bankingFrame:Background( GlorifiedBanking.Config.GRADIENT_ONE )
    bankingFrame:Gradient( GlorifiedBanking.Config.GRADIENT_TWO )
    bankingFrame:SetSize( GBScaleUI( 400 ), GBScaleUI( 550 ) )
    bankingFrame:ShowCloseButton( false )
    bankingFrame:SetDraggable( false )
    bankingFrame:SetTitle( "" )
    bankingFrame:Center()
    bankingFrame:MakePopup()
    bankingFrame:FadeIn( 0.75 )

    local closeButton = TDLib( "DButton", bankingFrame )
    closeButton:ClearPaint()
    closeButton:Background( Color( 255, 255, 255, 0 ) )
    closeButton:Outline( Color( 255, 255, 255 ), 2 )
    closeButton:CircleHover( Color( 255, 255, 255, 25 ) )
    closeButton:SetText( "X" )
    closeButton:SetFont( "GBRoboto18Bold" )
    closeButton:SetSize( GBScaleUI( 24 ), GBScaleUI( 24 ) )
    closeButton:SetTextColor( Color( 255, 255, 255 ) )
    closeButton:SetPos( bankingFrame:GetWide() - GBScaleUI( 24 ) - 8, 8 )
    closeButton.DoClick = function()
        bankingFrame:Close()
    end

    local titleLabel = TDLib( "DLabel", bankingFrame )
    titleLabel:SetFont( "GBRoboto20" )
    titleLabel:SetText( GlorifiedBanking.Config.MAIN_PANEL_TITLE )
    titleLabel:SetTextColor( Color( 255, 255, 255 ) )
    titleLabel:SetPos( 10, 10 )
    titleLabel:SizeToContents()

    local userAvatar = TDLib( "DPanel", bankingFrame )
    userAvatar:CircleAvatar()
    userAvatar:SetPlayer( LocalPlayer(), 156 )
    userAvatar:SetSize( 156, 156 )
    userAvatar:CenterHorizontal( 0.5 )
    userAvatar:CenterVertical( 0.2 )
end

concommand.Add( "gbpanel", function() GlorifiedBanking.OpenPanel() end )