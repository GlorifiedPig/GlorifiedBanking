
local function GBScaleUI( num )
    return num * ( ScrH() / 720 )
end

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

surface.CreateFont( "GBRoboto18Bold", {
    font = "Roboto",
    size = GBScaleUI( 18 ),
    weight = 1000,
    bold = true
} )

function GlorifiedBanking.OpenPanel()
    local requestedClose = false
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
    bankingFrame:On( "Think", function()
        if requestedClose then return end
        if input.IsKeyDown( KEY_ESCAPE ) then
            bankingFrame:AlphaTo( 1, 0.75 )
            timer.Simple( 0.75, function()
                bankingFrame:Close()
            end )
            RunConsoleCommand( "cancelselect" )
            requestedClose = true
            return
        end
    end )

    local paintPanel = TDLib( "DPanel", bankingFrame )
    paintPanel:SetSize( bankingFrame:GetWide(), bankingFrame:GetTall() )
    paintPanel:ClearPaint()
    paintPanel.Paint = function( self, w, h )
        draw.RoundedBox( 0, 0, 40, w, 1, Color( 255, 255, 255 ) )
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
        bankingFrame:AlphaTo( 1, 0.75 )
        timer.Simple( 0.75, function()
            bankingFrame:Close()
        end )
        requestedClose = true
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
    userAvatar:CenterVertical( 0.22 )
end

concommand.Add( "gbpanel", function() GlorifiedBanking.OpenPanel() end )