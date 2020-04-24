
local function GBScaleUI( num )
    return num * ( ScrH() / 720 )
end

surface.CreateFont( "GBRoboto14", {
    font = "Roboto",
    size = GBScaleUI( 14 ),
    weight = 400
} )

surface.CreateFont( "GBRoboto18", {
    font = "Roboto",
    size = GBScaleUI( 18 ),
    weight = 400
} )

surface.CreateFont( "GBRoboto22", {
    font = "Roboto",
    size = GBScaleUI( 22 ),
    weight = 300
} )

surface.CreateFont( "GBRoboto38", {
    font = "Roboto",
    size = GBScaleUI( 38 ),
    weight = 300
} )

surface.CreateFont( "GBRoboto18Bold", {
    font = "Roboto",
    size = GBScaleUI( 18 ),
    weight = 1000,
    bold = true
} )

surface.CreateFont( "GBRoboto48", {
    font = "Roboto",
    size = GBScaleUI( 48 )
} )

function GlorifiedBanking.OpenPanel()
    local requestedClose = false
    local bankingFrame = TDLib( "DFrame" )
    bankingFrame:ClearPaint()
    bankingFrame:Background( GlorifiedBanking.Config.GRADIENT_ONE )
    bankingFrame:Gradient( GlorifiedBanking.Config.GRADIENT_TWO )
    bankingFrame:SetSize( GBScaleUI( 400 ), GBScaleUI( 500 ) )
    bankingFrame:ShowCloseButton( false )
    bankingFrame:SetDraggable( false )
    bankingFrame:SetTitle( "" )
    bankingFrame:Center()
    bankingFrame:MakePopup()
    bankingFrame:FadeIn( 0.75 )
    bankingFrame:On( "Think", function()
        if requestedClose then return end
        if input.IsKeyDown( KEY_ESCAPE ) then
            requestedClose = true
            bankingFrame:AlphaTo( 1, 0.75 )
            timer.Simple( 0.75, function()
                if !bankingFrame then return end
                bankingFrame:Close()
            end )
            RunConsoleCommand( "cancelselect" )
            return
        end
    end )

    local paintPanel = TDLib( "DPanel", bankingFrame )
    paintPanel:SetSize( bankingFrame:GetWide(), bankingFrame:GetTall() )
    paintPanel:ClearPaint()
    paintPanel.Paint = function( self, w, h )
        draw.RoundedBox( 0, 0, 40, w, 1, Color( 200, 200, 200 ) )
        draw.SimpleText( i18n.GetPhrase( "gbActions" ), "GBRoboto14", 5, h / 2.24 )
        draw.RoundedBox( 0, 0, h / 2.07, w - 37, 1, Color( 255, 255, 255 ) )
    end

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
    closeButton:On( "DoClick", function()
        requestedClose = true
        bankingFrame:AlphaTo( 1, 0.75 )
        timer.Simple( 0.75, function()
            if !bankingFrame then return end
            bankingFrame:Close()
        end )
    end )

    local titleLabel = TDLib( "DLabel", bankingFrame )
    titleLabel:SetFont( "GBRoboto22" )
    titleLabel:SetText( GlorifiedBanking.Config.MAIN_PANEL_TITLE )
    titleLabel:SetTextColor( Color( 255, 255, 255 ) )
    titleLabel:SetPos( 10, 10 )
    titleLabel:SizeToContents()

    local userAvatar = TDLib( "DPanel", bankingFrame )
    userAvatar:CircleAvatar()
    userAvatar:SetPlayer( LocalPlayer(), 128 )
    userAvatar:SetSize( 128, 128 )
    userAvatar:CenterHorizontal( 0.5 )
    userAvatar:CenterVertical( 0.24 )

    local balanceLabel = TDLib( "DLabel", bankingFrame )
    balanceLabel:SetFont( "GBRoboto38" )
    balanceLabel:SetText( "$1,000,000,000" )
    balanceLabel:SetTextColor( Color( 255, 255, 255 ) )
    balanceLabel:SizeToContents()
    balanceLabel:CenterHorizontal( 0.5 )
    balanceLabel:CenterVertical( 0.41 )

    local withdrawButton = TDLib( "DButton", bankingFrame )
    withdrawButton:ClearPaint()
    withdrawButton:Background( Color( 255, 255, 255, 0 ) )
    withdrawButton:Outline( Color( 255, 255, 255 ), 2 )
    withdrawButton:CircleHover( Color( 255, 255, 255, 25 ) )
    withdrawButton:SetText( i18n.GetPhrase( "gbWithdraw" ) )
    withdrawButton:SetFont( "GBRoboto48" )
    withdrawButton:SetSize( GBScaleUI( bankingFrame:GetWide() - 72 ), GBScaleUI( 72 ) )
    withdrawButton:SetTextColor( Color( 255, 255, 255 ) )
    withdrawButton:CenterHorizontal()
    withdrawButton:CenterVertical( 0.58 )

    local depositButton = TDLib( "DButton", bankingFrame )
    depositButton:ClearPaint()
    depositButton:Background( Color( 255, 255, 255, 0 ) )
    depositButton:Outline( Color( 255, 255, 255 ), 2 )
    depositButton:CircleHover( Color( 255, 255, 255, 25 ) )
    depositButton:SetText( i18n.GetPhrase( "gbDeposit" ) )
    depositButton:SetFont( "GBRoboto48" )
    depositButton:SetSize( GBScaleUI( bankingFrame:GetWide() - 72 ), GBScaleUI( 72 ) )
    depositButton:SetTextColor( Color( 255, 255, 255 ) )
    depositButton:CenterHorizontal()
    depositButton:CenterVertical( 0.74 )

    local transferButton = TDLib( "DButton", bankingFrame )
    transferButton:ClearPaint()
    transferButton:Background( Color( 255, 255, 255, 0 ) )
    transferButton:Outline( Color( 255, 255, 255 ), 2 )
    transferButton:CircleHover( Color( 255, 255, 255, 25 ) )
    transferButton:SetText( i18n.GetPhrase( "gbTransfer" ) )
    transferButton:SetFont( "GBRoboto48" )
    transferButton:SetSize( GBScaleUI( bankingFrame:GetWide() - 72 ), GBScaleUI( 72 ) )
    transferButton:SetTextColor( Color( 255, 255, 255 ) )
    transferButton:CenterHorizontal()
    transferButton:CenterVertical( 0.9 )
end

concommand.Add( "gbpanel", function() GlorifiedBanking.OpenPanel() end )