
surface.CreateFont( "VerdanaCustom", {
    font = "Verdana",
    size = 13,
    weight = 500,
} )

local bankBalance = 0
local affordableDeposit = false

net.Receive( "GlorifiedBanking_UpdateBankBalanceReceive", function()
    bankBalance = net.ReadUInt( 32 )
end )

net.Receive( "GlorifiedBanking_IsAffordableDepositReceive", function()
    affordableDeposit = net.ReadBool()
end )

net.Receive( "GlorifiedBanking_Notification", function()
    local text = net.ReadString()
    local errorMessage = net.ReadBool()

    if errorMessage then
        notification.AddLegacy( text, NOTIFY_ERROR, 5)
        surface.PlaySound( "buttons/button2.wav" )
    else
        notification.AddLegacy( text, NOTIFY_GENERIC, 5)
        surface.PlaySound( "buttons/button14.wav" )
    end
end )

local function OpenWithdrawPanel()
    local ply = LocalPlayer()

    local boxW, boxH = 450, 115
	local WithdrawFrame = vgui.Create( "DFrame" )
	WithdrawFrame:SetSize( boxW, boxH )
	WithdrawFrame:SetTitle( glorifiedbanking.getPhrase("withdrawalTitle") )
	WithdrawFrame:SetDraggable( false )
	WithdrawFrame:ShowCloseButton( false )
	WithdrawFrame:SetPos( ScrW() / 2 - boxW / 2, ScrH() )
	WithdrawFrame:MakePopup()
    WithdrawFrame.Init = function( self )
        self.finishedAnimation = false
    end
    WithdrawFrame.Think = function( self, w, h )
        if self.finishedAnimation then return end
        if WithdrawFrame.y == ScrH() then
            WithdrawFrame:MoveTo( ScrW() / 2 - boxW / 2, ScrH() / 2 - boxH / 2, 0.5 )
            self.finishedAnimation = true
        end
    end
    WithdrawFrame.OnClose = function( self )
        WithdrawFrame:MoveTo( ScrW() / 2 - boxW / 2, ScrH(), 0.5, 0, -1, function()
            WithdrawFrame:Close()
        end )

        return false
    end
    WithdrawFrame.Paint = function( self, w, h )
	    draw.RoundedBox( 0, 0, 0, w, h, glorifiedbanking.config.DERMA_BACKGROUND_COLOR_SUBSECTION )
        draw.OutlinedBox( 0, 0, w, h, 2, Color( 0, 0, 0 ) )
    end

	surface.SetFont( "VerdanaCustom" )
	local disbandMessage = glorifiedbanking.getPhrase("withdrawAmount")
	local textW, textH = surface.GetTextSize( disbandMessage )
	local disbandLabel = vgui.Create( "DLabel", WithdrawFrame )
	disbandLabel:SetText( disbandMessage )
	disbandLabel:SetFont( "VerdanaCustom" )
	disbandLabel:SizeToContents()
	disbandLabel:SetPos( boxW / 2 - textW / 2, 30 )

    local withdrawText = vgui.Create( "DTextEntry", WithdrawFrame )
    withdrawText:SetFont( "VerdanaCustom" )
    withdrawText:SetText( glorifiedbanking.getPhrase("amount") )
    withdrawText:SetSize( 100, 20 )
    withdrawText:SetPos( boxW / 2 - 100 / 2, 50 )
    local function DoWithdraw()
        local withdrawAmount = tonumber( withdrawText:GetText() )
        if isnumber( withdrawAmount ) then
            local affordableWithdraw = false

            withdrawAmount = math.abs( tonumber( withdrawText:GetText() ) )

            if withdrawAmount <= bankBalance then
                affordableWithdraw = true
            else
                affordableWithdraw = false
            end

            timer.Simple( ply:Ping() / 1000 + 0.1, function()
                if affordableWithdraw and withdrawAmount <= glorifiedbanking.config.MAX_WITHDRAWAL then
                    net.Start( "GlorifiedBanking_UpdateWithdrawal" )
                    net.WriteUInt( withdrawAmount, 32 )
                    net.SendToServer()
                    WithdrawFrame:MoveTo( ScrW() / 2 - boxW / 2, ScrH(), 0.5, 0, -1, function()
                        WithdrawFrame:Close()
                    end )
                    Frame:MoveTo( ScrW() / 2 - boxW / 2, ScrH(), 0.5, 0, -1, function()
                        Frame:Close()
                    end )
                    notification.AddLegacy(glorifiedbanking.getPhrase("withdrawSuccess", DarkRP.formatMoney( withdrawAmount )), NOTIFY_GENERIC, 5)
                    surface.PlaySound("buttons/button14.wav")
                elseif affordableWithdraw and withdrawAmount > glorifiedbanking.config.MAX_WITHDRAWAL then
                    WithdrawFrame:MoveTo( ScrW() / 2 - boxW / 2, ScrH(), 0.5, 0, -1, function()
                        WithdrawFrame:Close()
                    end )
                    Frame:MoveTo( ScrW() / 2 - boxW / 2, ScrH(), 0.5, 0, -1, function()
                        Frame:Close()
                    end )
                    notification.AddLegacy(glorifiedbanking.getPhrase("withdrawCannotMoreThan", DarkRP.formatMoney( glorifiedbanking.config.MAX_WITHDRAWAL )), NOTIFY_ERROR, 5)
                    surface.PlaySound("buttons/button2.wav")
                elseif !affordableWithdraw then
                    WithdrawFrame:MoveTo( ScrW() / 2 - boxW / 2, ScrH(), 0.5, 0, -1, function()
                        WithdrawFrame:Close()
                    end )
                    Frame:MoveTo( ScrW() / 2 - boxW / 2, ScrH(), 0.5, 0, -1, function()
                        Frame:Close()
                    end )
                    notification.AddLegacy(glorifiedbanking.getPhrase("cannotafford"), NOTIFY_ERROR, 5)
                    surface.PlaySound("buttons/button2.wav")
                else
                    WithdrawFrame:MoveTo( ScrW() / 2 - boxW / 2, ScrH(), 0.5, 0, -1, function()
                        WithdrawFrame:Close()
                    end )
                    Frame:MoveTo( ScrW() / 2 - boxW / 2, ScrH(), 0.5, 0, -1, function()
                        Frame:Close()
                    end )
                    notification.AddLegacy(glorifiedbanking.getPhrase("error"), NOTIFY_ERROR, 5)
                    surface.PlaySound("buttons/button2.wav")
                end
            end )
        else
            WithdrawFrame:MoveTo( ScrW() / 2 - boxW / 2, ScrH(), 0.5, 0, -1, function()
                WithdrawFrame:Close()
            end )
            Frame:MoveTo( ScrW() / 2 - boxW / 2, ScrH(), 0.5, 0, -1, function()
                Frame:Close()
            end )
            notification.AddLegacy(glorifiedbanking.getPhrase("validnumber", NOTIFY_ERROR, 5))
            surface.PlaySound("buttons/button2.wav")
        end
    end
    withdrawText.OnEnter = function()
        DoWithdraw()
    end

	local withdraw = vgui.Create( "DButton", WithdrawFrame )
    withdraw:SetFont( "VerdanaCustom" )
    withdraw:SetTextColor( Color( 255, 255, 255 ) )
	withdraw:SetText(glorifiedbanking.getPhrase("withdrawal"))
	withdraw:SetSize( 80, 20 )
	withdraw:SetPos( boxW / 2 - 40 / 2 - 22 - 80 / 2, 75 )
	withdraw.DoClick = function()
        DoWithdraw()
	end
    withdraw.Init = function( self )
            self.RecentHover = false
            self.LerpedButtonValueR = glorifiedbanking.config.DERMA_BUTTON_COLOUR.r
            self.LerpedButtonValueG = glorifiedbanking.config.DERMA_BUTTON_COLOUR.g
            self.LerpedButtonValueB = glorifiedbanking.config.DERMA_BUTTON_COLOUR.b
        end
    withdraw.Paint = function( self, w, h )
        local c = glorifiedbanking.config.DERMA_BUTTON_COLOUR

        if !self:IsHovered() then
            if self.RecentHover then
                self.LerpedButtonValueR = Lerp( FrameTime() * 7, self.LerpedButtonValueR, c.r )
                self.LerpedButtonValueG = Lerp( FrameTime() * 7, self.LerpedButtonValueG, c.g )
                self.LerpedButtonValueB = Lerp( FrameTime() * 7, self.LerpedButtonValueB, c.b )

                draw.RoundedBox( 0, 0, 0, w, h, Color( self.LerpedButtonValueR, self.LerpedButtonValueG, self.LerpedButtonValueB, c.a ) )
                    
                if self.LerpedButtonValueR == c.r and self.LerpedButtonValueG == c.g and self.LerpedButtonValueB == c.b then
                    self.RecentHover = false
                end
            else
                self.LerpedButtonValueR = c.r
                self.LerpedButtonValueG = c.g
                self.LerpedButtonValueB = c.b

                draw.RoundedBox( 0, 0, 0, w, h, c )
            end
        else
            self.LerpedButtonValueR = Lerp( FrameTime() * 7, self.LerpedButtonValueR, 255 )
            self.LerpedButtonValueG = Lerp( FrameTime() * 7, self.LerpedButtonValueG, 255 )
            self.LerpedButtonValueB = Lerp( FrameTime() * 7, self.LerpedButtonValueB, 255 )
            draw.RoundedBox( 0, 0, 0, w, h, Color( self.LerpedButtonValueR, self.LerpedButtonValueG, self.LerpedButtonValueB, c.a ) )

            self.RecentHover = true
        end

        draw.OutlinedBox( 0, 0, w, h, 2, Color( 0, 0, 0 ) )
    end

    local cancelButton = vgui.Create( "DButton", WithdrawFrame )
    cancelButton:SetFont( "VerdanaCustom" )
    cancelButton:SetTextColor( Color( 255, 255, 255 ) )
	cancelButton:SetText(glorifiedbanking.getPhrase("cancel"))
	cancelButton:SetSize( 80, 20 )
	cancelButton:SetPos( boxW / 2 - 40 / 2 - 22 + 80 / 2, 75 )
	cancelButton.DoClick = function()
        WithdrawFrame:MoveTo( ScrW() / 2 - boxW / 2, ScrH(), 0.5, 0, -1, function()
            WithdrawFrame:Close()
        end )
    end
    cancelButton.Init = function( self )
            self.RecentHover = false
            self.LerpedButtonValueR = glorifiedbanking.config.DERMA_BUTTON_COLOUR.r
            self.LerpedButtonValueG = glorifiedbanking.config.DERMA_BUTTON_COLOUR.g
            self.LerpedButtonValueB = glorifiedbanking.config.DERMA_BUTTON_COLOUR.b
        end
    cancelButton.Paint = function( self, w, h )
        local c = glorifiedbanking.config.DERMA_BUTTON_COLOUR

        if !self:IsHovered() then
            if self.RecentHover then
                self.LerpedButtonValueR = Lerp( FrameTime() * 7, self.LerpedButtonValueR, c.r )
                self.LerpedButtonValueG = Lerp( FrameTime() * 7, self.LerpedButtonValueG, c.g )
                self.LerpedButtonValueB = Lerp( FrameTime() * 7, self.LerpedButtonValueB, c.b )

                draw.RoundedBox( 0, 0, 0, w, h, Color( self.LerpedButtonValueR, self.LerpedButtonValueG, self.LerpedButtonValueB, c.a ) )
                    
                if self.LerpedButtonValueR == c.r and self.LerpedButtonValueG == c.g and self.LerpedButtonValueB == c.b then
                    self.RecentHover = false
                end
            else
                self.LerpedButtonValueR = c.r
                self.LerpedButtonValueG = c.g
                self.LerpedButtonValueB = c.b

                draw.RoundedBox( 0, 0, 0, w, h, c )
            end
        else
            self.LerpedButtonValueR = Lerp( FrameTime() * 7, self.LerpedButtonValueR, 255 )
            self.LerpedButtonValueG = Lerp( FrameTime() * 7, self.LerpedButtonValueG, 255 )
            self.LerpedButtonValueB = Lerp( FrameTime() * 7, self.LerpedButtonValueB, 255 )
            draw.RoundedBox( 0, 0, 0, w, h, Color( self.LerpedButtonValueR, self.LerpedButtonValueG, self.LerpedButtonValueB, c.a ) )

            self.RecentHover = true
        end

        draw.OutlinedBox( 0, 0, w, h, 2, Color( 0, 0, 0 ) )
    end
end

local function OpenDepositPanel()
    local ply = LocalPlayer()

    local boxW, boxH = 450, 115
	local DepositFrame = vgui.Create( "DFrame" )
	DepositFrame:SetSize( boxW, boxH )
	DepositFrame:SetTitle( glorifiedbanking.getPhrase("depositTitle") )
	DepositFrame:SetDraggable( false )
	DepositFrame:ShowCloseButton( false )
	DepositFrame:SetPos( ScrW() / 2 - boxW / 2, ScrH() )
	DepositFrame:MakePopup()
    DepositFrame.Init = function( self )
        self.finishedAnimation = false
    end
    DepositFrame.Think = function( self, w, h )
        if self.finishedAnimation then return end
        if DepositFrame.y == ScrH() then
            DepositFrame:MoveTo( ScrW() / 2 - boxW / 2, ScrH() / 2 - boxH / 2, 0.5 )
            self.finishedAnimation = true
        end
    end
    DepositFrame.OnClose = function( self )
        DepositFrame:MoveTo( ScrW() / 2 - boxW / 2, ScrH(), 0.5, 0, -1, function()
            DepositFrame:Close()
        end )

        return false
    end
    DepositFrame.Paint = function( self, w, h )
	    draw.RoundedBox( 0, 0, 0, w, h, glorifiedbanking.config.DERMA_BACKGROUND_COLOR_SUBSECTION )
        draw.OutlinedBox( 0, 0, w, h, 2, Color( 0, 0, 0 ) )
    end

	surface.SetFont( "VerdanaCustom" )
	local disbandMessage = glorifiedbanking.getPhrase("depositAmount")
	local textW, textH = surface.GetTextSize( disbandMessage )
	local disbandLabel = vgui.Create( "DLabel", DepositFrame )
	disbandLabel:SetText( disbandMessage )
	disbandLabel:SetFont( "VerdanaCustom" )
	disbandLabel:SizeToContents()
	disbandLabel:SetPos( boxW / 2 - textW / 2, 30 )

    local depositText = vgui.Create( "DTextEntry", DepositFrame )
    depositText:SetFont( "VerdanaCustom" )
    depositText:SetText( glorifiedbanking.getPhrase( "amount" ) )
    depositText:SetSize( 100, 20 )
    depositText:SetPos( boxW / 2 - 100 / 2, 50 )
    local function DoDeposit()
        local depositAmount = tonumber( depositText:GetText() )
        if isnumber( depositAmount ) then
            depositAmount = math.abs( tonumber( depositText:GetText() ) )

            net.Start( "GlorifiedBanking_IsAffordableDeposit" )
            net.WriteUInt( depositAmount, 32 )
            net.SendToServer()

            timer.Simple( ply:Ping() / 1000 + 0.1, function()
                if affordableDeposit and depositAmount <= glorifiedbanking.config.MAX_DEPOSIT then
                    net.Start( "GlorifiedBanking_UpdateDeposit" )
                    net.WriteUInt( depositAmount, 32 )
                    net.SendToServer()
                    DepositFrame:MoveTo( ScrW() / 2 - boxW / 2, ScrH(), 0.5, 0, -1, function()
                        DepositFrame:Close()
                    end )
                    Frame:MoveTo( ScrW() / 2 - boxW / 2, ScrH(), 0.5, 0, -1, function()
                        Frame:Close()
                    end )
                    notification.AddLegacy(glorifiedbanking.getPhrase("depositSuccess", DarkRP.formatMoney( depositAmount )), NOTIFY_GENERIC, 5)
                    surface.PlaySound("buttons/button14.wav")
                elseif affordableDeposit and depositAmount > glorifiedbanking.config.MAX_DEPOSIT then
                    DepositFrame:MoveTo( ScrW() / 2 - boxW / 2, ScrH(), 0.5, 0, -1, function()
                        DepositFrame:Close()
                    end )
                    Frame:MoveTo( ScrW() / 2 - boxW / 2, ScrH(), 0.5, 0, -1, function()
                        Frame:Close()
                    end )
                    notification.AddLegacy(glorifiedbanking.getPhrase("depositCannotMoreThan", DarkRP.formatMoney( glorifiedbanking.config.MAX_DEPOSIT )) , NOTIFY_ERROR, 5)
                    surface.PlaySound("buttons/button2.wav")
                elseif !affordableDeposit then
                    DepositFrame:MoveTo( ScrW() / 2 - boxW / 2, ScrH(), 0.5, 0, -1, function()
                        DepositFrame:Close()
                    end )
                    Frame:MoveTo( ScrW() / 2 - boxW / 2, ScrH(), 0.5, 0, -1, function()
                        Frame:Close()
                    end )
                    notification.AddLegacy(glorifiedbanking.getPhrase("cannotafford"), NOTIFY_ERROR, 5)
                    surface.PlaySound("buttons/button2.wav")
                else
                    DepositFrame:MoveTo( ScrW() / 2 - boxW / 2, ScrH(), 0.5, 0, -1, function()
                        DepositFrame:Close()
                    end )
                    Frame:MoveTo( ScrW() / 2 - boxW / 2, ScrH(), 0.5, 0, -1, function()
                        Frame:Close()
                    end )
                    notification.AddLegacy(glorifiedbanking.getPhrase("error"), NOTIFY_ERROR, 5)
                    surface.PlaySound("buttons/button2.wav")
                end
            end)
        else
            DepositFrame:MoveTo( ScrW() / 2 - boxW / 2, ScrH(), 0.5, 0, -1, function()
                DepositFrame:Close()
            end )
            Frame:MoveTo( ScrW() / 2 - boxW / 2, ScrH(), 0.5, 0, -1, function()
                Frame:Close()
            end )
            notification.AddLegacy(glorifiedbanking.getPhrase("validnumber"), NOTIFY_ERROR, 5)
            surface.PlaySound("buttons/button2.wav")
        end
    end
    depositText.OnEnter = function()
        DoDeposit()
    end

	local deposit = vgui.Create( "DButton", DepositFrame )
    deposit:SetFont( "VerdanaCustom" )
    deposit:SetTextColor( Color( 255, 255, 255 ) )
	deposit:SetText(glorifiedbanking.getPhrase("deposit"))
	deposit:SetSize( 80, 20 )
	deposit:SetPos( boxW / 2 - 40 / 2 - 22 - 80 / 2, 75 )
	deposit.DoClick = function()
        DoDeposit()
	end
    deposit.Init = function( self )
            self.RecentHover = false
            self.LerpedButtonValueR = glorifiedbanking.config.DERMA_BUTTON_COLOUR.r
            self.LerpedButtonValueG = glorifiedbanking.config.DERMA_BUTTON_COLOUR.g
            self.LerpedButtonValueB = glorifiedbanking.config.DERMA_BUTTON_COLOUR.b
        end
    deposit.Paint = function( self, w, h )
        local c = glorifiedbanking.config.DERMA_BUTTON_COLOUR

        if !self:IsHovered() then
            if self.RecentHover then
                self.LerpedButtonValueR = Lerp( FrameTime() * 7, self.LerpedButtonValueR, c.r )
                self.LerpedButtonValueG = Lerp( FrameTime() * 7, self.LerpedButtonValueG, c.g )
                self.LerpedButtonValueB = Lerp( FrameTime() * 7, self.LerpedButtonValueB, c.b )

                draw.RoundedBox( 0, 0, 0, w, h, Color( self.LerpedButtonValueR, self.LerpedButtonValueG, self.LerpedButtonValueB, c.a ) )
                    
                if self.LerpedButtonValueR == c.r and self.LerpedButtonValueG == c.g and self.LerpedButtonValueB == c.b then
                    self.RecentHover = false
                end
            else
                self.LerpedButtonValueR = c.r
                self.LerpedButtonValueG = c.g
                self.LerpedButtonValueB = c.b

                draw.RoundedBox( 0, 0, 0, w, h, c )
            end
        else
            self.LerpedButtonValueR = Lerp( FrameTime() * 7, self.LerpedButtonValueR, 255 )
            self.LerpedButtonValueG = Lerp( FrameTime() * 7, self.LerpedButtonValueG, 255 )
            self.LerpedButtonValueB = Lerp( FrameTime() * 7, self.LerpedButtonValueB, 255 )
            draw.RoundedBox( 0, 0, 0, w, h, Color( self.LerpedButtonValueR, self.LerpedButtonValueG, self.LerpedButtonValueB, c.a ) )

            self.RecentHover = true
        end

        draw.OutlinedBox( 0, 0, w, h, 2, Color( 0, 0, 0 ) )
    end

    local cancelButton = vgui.Create( "DButton", DepositFrame )
    cancelButton:SetFont( "VerdanaCustom" )
    cancelButton:SetTextColor( Color( 255, 255, 255 ) )
	cancelButton:SetText(glorifiedbanking.getPhrase("cancel"))
	cancelButton:SetSize( 80, 20 )
	cancelButton:SetPos( boxW / 2 - 40 / 2 - 22 + 80 / 2, 75 )
	cancelButton.DoClick = function()
        DepositFrame:MoveTo( ScrW() / 2 - boxW / 2, ScrH(), 0.5, 0, -1, function()
            DepositFrame:Close()
        end )
    end
    cancelButton.Init = function( self )
            self.RecentHover = false
            self.LerpedButtonValueR = glorifiedbanking.config.DERMA_BUTTON_COLOUR.r
            self.LerpedButtonValueG = glorifiedbanking.config.DERMA_BUTTON_COLOUR.g
            self.LerpedButtonValueB = glorifiedbanking.config.DERMA_BUTTON_COLOUR.b
        end
    cancelButton.Paint = function( self, w, h )
        local c = glorifiedbanking.config.DERMA_BUTTON_COLOUR

        if !self:IsHovered() then
            if self.RecentHover then
                self.LerpedButtonValueR = Lerp( FrameTime() * 7, self.LerpedButtonValueR, c.r )
                self.LerpedButtonValueG = Lerp( FrameTime() * 7, self.LerpedButtonValueG, c.g )
                self.LerpedButtonValueB = Lerp( FrameTime() * 7, self.LerpedButtonValueB, c.b )

                draw.RoundedBox( 0, 0, 0, w, h, Color( self.LerpedButtonValueR, self.LerpedButtonValueG, self.LerpedButtonValueB, c.a ) )
                    
                if self.LerpedButtonValueR == c.r and self.LerpedButtonValueG == c.g and self.LerpedButtonValueB == c.b then
                    self.RecentHover = false
                end
            else
                self.LerpedButtonValueR = c.r
                self.LerpedButtonValueG = c.g
                self.LerpedButtonValueB = c.b

                draw.RoundedBox( 0, 0, 0, w, h, c )
            end
        else
            self.LerpedButtonValueR = Lerp( FrameTime() * 7, self.LerpedButtonValueR, 255 )
            self.LerpedButtonValueG = Lerp( FrameTime() * 7, self.LerpedButtonValueG, 255 )
            self.LerpedButtonValueB = Lerp( FrameTime() * 7, self.LerpedButtonValueB, 255 )
            draw.RoundedBox( 0, 0, 0, w, h, Color( self.LerpedButtonValueR, self.LerpedButtonValueG, self.LerpedButtonValueB, c.a ) )

            self.RecentHover = true
        end

        draw.OutlinedBox( 0, 0, w, h, 2, Color( 0, 0, 0 ) )
    end
end

local function OpenTransferPanel()
    local ply = LocalPlayer()

    local boxW, boxH = 450, 142
	local TransferFrame = vgui.Create( "DFrame" )
	TransferFrame:SetSize( boxW, boxH )
	TransferFrame:SetTitle( glorifiedbanking.getPhrase("transferTitle") )
	TransferFrame:SetDraggable( false )
	TransferFrame:ShowCloseButton( false )
	TransferFrame:SetPos( ScrW() / 2 - boxW / 2, ScrH() )
	TransferFrame:MakePopup()
    TransferFrame.Init = function( self )
        self.finishedAnimation = false
    end
    TransferFrame.Think = function( self, w, h )
        if self.finishedAnimation then return end
        if TransferFrame.y == ScrH() then
            TransferFrame:MoveTo( ScrW() / 2 - boxW / 2, ScrH() / 2 - boxH / 2, 0.5 )
            self.finishedAnimation = true
        end
    end
    TransferFrame.OnClose = function( self )
        TransferFrame:MoveTo( ScrW() / 2 - boxW / 2, ScrH(), 0.5, 0, -1, function()
            TransferFrame:Close()
        end )

        return false
    end
    TransferFrame.Paint = function( self, w, h )
	    draw.RoundedBox( 0, 0, 0, w, h, glorifiedbanking.config.DERMA_BACKGROUND_COLOR_SUBSECTION )
        draw.OutlinedBox( 0, 0, w, h, 2, Color( 0, 0, 0 ) )
    end

	surface.SetFont( "VerdanaCustom" )
	local disbandMessage = glorifiedbanking.getPhrase("transferAmount")
	local textW, textH = surface.GetTextSize( disbandMessage )
	local disbandLabel = vgui.Create( "DLabel", TransferFrame )
	disbandLabel:SetText( disbandMessage )
	disbandLabel:SetFont( "VerdanaCustom" )
	disbandLabel:SizeToContents()
	disbandLabel:SetPos( boxW / 2 - textW / 2, 30 )

    local PlayerComboBox = vgui.Create( "DComboBox", TransferFrame )
    PlayerComboBox:SetFont( "VerdanaCustom" )
    PlayerComboBox:SetSize( 115, 20 )
    PlayerComboBox:SetPos( boxW / 2 - 115 / 2, 75 )
    PlayerComboBox:SetValue( glorifiedbanking.getPhrase("playerList") )
    for k, v in pairs( player.GetAll() ) do
        if v == ply then continue end
		PlayerComboBox:AddChoice( v:Nick(), v:SteamID64() )
	end

	local selectedNick, selectedID = PlayerComboBox:GetSelected()

    PlayerComboBox.OnSelect = function( panel, index, value )
        selectedNick, selectedID = PlayerComboBox:GetSelected()
    end

    local transferText = vgui.Create( "DTextEntry", TransferFrame )
    transferText:SetFont( "VerdanaCustom" )
    transferText:SetText( glorifiedbanking.getPhrase("amount") )
    transferText:SetSize( 100, 20 )
    transferText:SetPos( boxW / 2 - 100 / 2, 50 )
    local function DoTransfer()
        local transferAmount = tonumber( transferText:GetText() )
        if isnumber( transferAmount ) then
            local affordableTransfer = false

            transferAmount = math.abs( tonumber( transferText:GetText() ) )

            if transferAmount <= bankBalance then
                affordableTransfer = true
            else
                affordableTransfer = false
            end

            local transferringPlayer = player.GetBySteamID64( selectedID )
            print( selectedID )

            if isbool( transferringPlayer ) or transferringPlayer == nil then
                TransferFrame:Close()
                Frame:MoveTo( ScrW() / 2 - boxW / 2, ScrH(), 0.5, 0, -1, function()
                    Frame:Close()
                end )
                notification.AddLegacy(glorifiedbanking.getPhrase("validplayer"), NOTIFY_ERROR, 5)
                surface.PlaySound("buttons/button2.wav")
                return
            end

            timer.Simple( ply:Ping() / 1000 + 0.1, function()
                if affordableTransfer and transferAmount <= glorifiedbanking.config.MAX_TRANSFER then
                    net.Start( "GlorifiedBanking_UpdateTransfer" )
                    net.WriteInt( transferAmount, 32 )
                    net.WriteEntity( transferringPlayer )
                    net.SendToServer()
                    TransferFrame:MoveTo( ScrW() / 2 - boxW / 2, ScrH(), 0.5, 0, -1, function()
                        TransferFrame:Close()
                    end )
                    Frame:MoveTo( ScrW() / 2 - boxW / 2, ScrH(), 0.5, 0, -1, function()
                        Frame:Close()
                    end )
                    notification.AddLegacy(glorifiedbanking.getPhrase("transferSuccess", DarkRP.formatMoney( transferAmount ), transferringPlayer:Nick()), NOTIFY_GENERIC, 5)
                    surface.PlaySound("buttons/button14.wav")
                elseif affordableTransfer and transferAmount > glorifiedbanking.config.MAX_TRANSFER then
                    TransferFrame:MoveTo( ScrW() / 2 - boxW / 2, ScrH(), 0.5, 0, -1, function()
                        TransferFrame:Close()
                    end )
                    Frame:MoveTo( ScrW() / 2 - boxW / 2, ScrH(), 0.5, 0, -1, function()
                        Frame:Close()
                    end )
                    notification.AddLegacy(glorifiedbanking.getPhrase("transferCannotMoreThan", DarkRP.formatMoney( glorifiedbanking.config.MAX_TRANSFER )), NOTIFY_ERROR, 5)
                    surface.PlaySound("buttons/button2.wav")
                elseif !affordableTransfer then
                    TransferFrame:MoveTo( ScrW() / 2 - boxW / 2, ScrH(), 0.5, 0, -1, function()
                        TransferFrame:Close()
                    end )
                    Frame:MoveTo( ScrW() / 2 - boxW / 2, ScrH(), 0.5, 0, -1, function()
                        Frame:Close()
                    end )
                    notification.AddLegacy(glorifiedbanking.getPhrase("cannotafford"), NOTIFY_ERROR, 5)
                    surface.PlaySound("buttons/button2.wav")
                else
                    TransferFrame:MoveTo( ScrW() / 2 - boxW / 2, ScrH(), 0.5, 0, -1, function()
                        TransferFrame:Close()
                    end )
                    Frame:MoveTo( ScrW() / 2 - boxW / 2, ScrH(), 0.5, 0, -1, function()
                        Frame:Close()
                    end )
                    notification.AddLegacy(glorifiedbanking.getPhrase("error"), NOTIFY_ERROR, 5)
                    surface.PlaySound("buttons/button2.wav")
                end
            end )
        else
            TransferFrame:MoveTo( ScrW() / 2 - boxW / 2, ScrH(), 0.5, 0, -1, function()
                TransferFrame:Close()
            end )
            Frame:MoveTo( ScrW() / 2 - boxW / 2, ScrH(), 0.5, 0, -1, function()
                Frame:Close()
            end )
            notification.AddLegacy(glorifiedbanking.getPhrase("validnumber"), NOTIFY_ERROR, 5)
            surface.PlaySound("buttons/button2.wav")
        end
    end
    transferText.OnEnter = function()
        DoTransfer()
    end

	local transfer = vgui.Create( "DButton", TransferFrame )
    transfer:SetFont( "VerdanaCustom" )
    transfer:SetTextColor( Color( 255, 255, 255 ) )
	transfer:SetText(glorifiedbanking.getPhrase("transfer"))
	transfer:SetSize( 80, 20 )
	transfer:SetPos( boxW / 2 - 40 / 2 - 22 - 80 / 2, 100 )
	transfer.DoClick = function()
        DoTransfer()
	end
    transfer.Init = function( self )
            self.RecentHover = false
            self.LerpedButtonValueR = glorifiedbanking.config.DERMA_BUTTON_COLOUR.r
            self.LerpedButtonValueG = glorifiedbanking.config.DERMA_BUTTON_COLOUR.g
            self.LerpedButtonValueB = glorifiedbanking.config.DERMA_BUTTON_COLOUR.b
        end
    transfer.Paint = function( self, w, h )
        local c = glorifiedbanking.config.DERMA_BUTTON_COLOUR

        if !self:IsHovered() then
            if self.RecentHover then
                self.LerpedButtonValueR = Lerp( FrameTime() * 7, self.LerpedButtonValueR, c.r )
                self.LerpedButtonValueG = Lerp( FrameTime() * 7, self.LerpedButtonValueG, c.g )
                self.LerpedButtonValueB = Lerp( FrameTime() * 7, self.LerpedButtonValueB, c.b )

                draw.RoundedBox( 0, 0, 0, w, h, Color( self.LerpedButtonValueR, self.LerpedButtonValueG, self.LerpedButtonValueB, c.a ) )
                    
                if self.LerpedButtonValueR == c.r and self.LerpedButtonValueG == c.g and self.LerpedButtonValueB == c.b then
                    self.RecentHover = false
                end
            else
                self.LerpedButtonValueR = c.r
                self.LerpedButtonValueG = c.g
                self.LerpedButtonValueB = c.b

                draw.RoundedBox( 0, 0, 0, w, h, c )
            end
        else
            self.LerpedButtonValueR = Lerp( FrameTime() * 7, self.LerpedButtonValueR, 255 )
            self.LerpedButtonValueG = Lerp( FrameTime() * 7, self.LerpedButtonValueG, 255 )
            self.LerpedButtonValueB = Lerp( FrameTime() * 7, self.LerpedButtonValueB, 255 )
            draw.RoundedBox( 0, 0, 0, w, h, Color( self.LerpedButtonValueR, self.LerpedButtonValueG, self.LerpedButtonValueB, c.a ) )

            self.RecentHover = true
        end

        draw.OutlinedBox( 0, 0, w, h, 2, Color( 0, 0, 0 ) )
    end

    local cancelButton = vgui.Create( "DButton", TransferFrame )
    cancelButton:SetFont( "VerdanaCustom" )
    cancelButton:SetTextColor( Color( 255, 255, 255 ) )
	cancelButton:SetText(glorifiedbanking.getPhrase("cancel"))
	cancelButton:SetSize( 80, 20 )
	cancelButton:SetPos( boxW / 2 - 40 / 2 - 22 + 80 / 2, 100 )
	cancelButton.DoClick = function()
        TransferFrame:MoveTo( ScrW() / 2 - boxW / 2, ScrH(), 0.5, 0, -1, function()
            TransferFrame:Close()
        end )
    end
    cancelButton.Init = function( self )
            self.RecentHover = false
            self.LerpedButtonValueR = glorifiedbanking.config.DERMA_BUTTON_COLOUR.r
            self.LerpedButtonValueG = glorifiedbanking.config.DERMA_BUTTON_COLOUR.g
            self.LerpedButtonValueB = glorifiedbanking.config.DERMA_BUTTON_COLOUR.b
        end
    cancelButton.Paint = function( self, w, h )
        local c = glorifiedbanking.config.DERMA_BUTTON_COLOUR

        if !self:IsHovered() then
            if self.RecentHover then
                self.LerpedButtonValueR = Lerp( FrameTime() * 7, self.LerpedButtonValueR, c.r )
                self.LerpedButtonValueG = Lerp( FrameTime() * 7, self.LerpedButtonValueG, c.g )
                self.LerpedButtonValueB = Lerp( FrameTime() * 7, self.LerpedButtonValueB, c.b )

                draw.RoundedBox( 0, 0, 0, w, h, Color( self.LerpedButtonValueR, self.LerpedButtonValueG, self.LerpedButtonValueB, c.a ) )
                    
                if self.LerpedButtonValueR == c.r and self.LerpedButtonValueG == c.g and self.LerpedButtonValueB == c.b then
                    self.RecentHover = false
                end
            else
                self.LerpedButtonValueR = c.r
                self.LerpedButtonValueG = c.g
                self.LerpedButtonValueB = c.b

                draw.RoundedBox( 0, 0, 0, w, h, c )
            end
        else
            self.LerpedButtonValueR = Lerp( FrameTime() * 7, self.LerpedButtonValueR, 255 )
            self.LerpedButtonValueG = Lerp( FrameTime() * 7, self.LerpedButtonValueG, 255 )
            self.LerpedButtonValueB = Lerp( FrameTime() * 7, self.LerpedButtonValueB, 255 )
            draw.RoundedBox( 0, 0, 0, w, h, Color( self.LerpedButtonValueR, self.LerpedButtonValueG, self.LerpedButtonValueB, c.a ) )

            self.RecentHover = true
        end

        draw.OutlinedBox( 0, 0, w, h, 2, Color( 0, 0, 0 ) )
    end
end

local function OpenBankingPanel()
    net.Start( "GlorifiedBanking_UpdateBankBalance" )
    net.SendToServer()

    local ply = LocalPlayer()

    local boxW, boxH = 500, 220
    Frame = vgui.Create( "DFrame" )
    Frame:SetTitle( glorifiedbanking.getPhrase( "atmText" ) )
    Frame:SetSize( boxW, boxH )
    Frame:SetDeleteOnClose( false )
    Frame:ShowCloseButton( false )
    Frame:SetPos( ScrW() / 2 - boxW / 2, ScrH() )
    Frame:MakePopup()
    Frame.Init = function( self )
        self.finishedAnimation = false
        self.startTime = SysTime()
    end
    Frame.Think = function( self, w, h )
        if self.finishedAnimation then return end

        if Frame.y == ScrH() then
            Frame:MoveTo( ScrW() / 2 - boxW / 2, ScrH() / 2 - boxH / 2, 0.5 )
            self.finishedAnimation = true
        end
    end
    Frame.OnClose = function( self )
        Frame:SetVisible( true )

        Frame:MoveTo( ScrW() / 2 - boxW / 2, ScrH(), 0.5, 0, -1, function()
            Frame:Close()
            Frame:SetVisible( false )
        end )
    end
    Frame.Paint = function( self, w, h )
        Derma_DrawBackgroundBlur( self, self.startTime )
	    draw.RoundedBox( 0, 0, 0, w, h, glorifiedbanking.config.DERMA_BACKGROUND_COLOR )
        draw.OutlinedBox( 0, 0, w, h, 2, Color( 0, 0, 0 ) )
    end

    timer.Simple( ply:Ping() / 1000 + 0.1, function()
        Frame:ShowCloseButton( true )
        surface.SetFont( "VerdanaCustom" )
        local atmW, atmH = surface.GetTextSize( glorifiedbanking.getPhrase( "welcome" ) )
        local balW, balH = surface.GetTextSize( glorifiedbanking.getPhrase( "curBalance" , DarkRP.formatMoney( bankBalance )))

        local ATMLabel = vgui.Create( "DLabel", Frame )
        ATMLabel:SetFont( "VerdanaCustom" )
		ATMLabel:SetPos( 500 / 2 - atmW / 2, 35 )
		ATMLabel:SetText( glorifiedbanking.getPhrase( "welcome" ) )
        ATMLabel:SizeToContents()

		local BalanceLabel = vgui.Create( "DLabel", Frame )
        BalanceLabel:SetFont( "VerdanaCustom" )
		BalanceLabel:SetPos( 500 / 2 - balW / 2, 50 )
		BalanceLabel:SetText( glorifiedbanking.getPhrase( "curBalance" , DarkRP.formatMoney( bankBalance )) )
        BalanceLabel:SizeToContents()

        local WithdrawButton = vgui.Create( "DButton", Frame )
        WithdrawButton:SetFont( "VerdanaCustom" )
        WithdrawButton:SetText( glorifiedbanking.getPhrase("withdrawal") )
        WithdrawButton:SetTextColor( Color( 255, 255, 255 ) )
        WithdrawButton:SetPos( 25, 80 )
        WithdrawButton:SetSize( 200, 50 )
        WithdrawButton.Init = function( self )
            self.RecentHover = false
            self.LerpedButtonValueR = glorifiedbanking.config.DERMA_BUTTON_COLOUR.r
            self.LerpedButtonValueG = glorifiedbanking.config.DERMA_BUTTON_COLOUR.g
            self.LerpedButtonValueB = glorifiedbanking.config.DERMA_BUTTON_COLOUR.b
        end
        WithdrawButton.Paint = function( self, w, h )
            local c = glorifiedbanking.config.DERMA_BUTTON_COLOUR

            if !self:IsHovered() then
                if self.RecentHover then
                    self.LerpedButtonValueR = Lerp( FrameTime() * 7, self.LerpedButtonValueR, c.r )
                    self.LerpedButtonValueG = Lerp( FrameTime() * 7, self.LerpedButtonValueG, c.g )
                    self.LerpedButtonValueB = Lerp( FrameTime() * 7, self.LerpedButtonValueB, c.b )

                    draw.RoundedBox( 0, 0, 0, w, h, Color( self.LerpedButtonValueR, self.LerpedButtonValueG, self.LerpedButtonValueB, c.a ) )
                    
                    if self.LerpedButtonValueR == c.r and self.LerpedButtonValueG == c.g and self.LerpedButtonValueB == c.b then
                        self.RecentHover = false
                    end
                else
                    self.LerpedButtonValueR = c.r
                    self.LerpedButtonValueG = c.g
                    self.LerpedButtonValueB = c.b

                    draw.RoundedBox( 0, 0, 0, w, h, c )
                end
            else
                self.LerpedButtonValueR = Lerp( FrameTime() * 7, self.LerpedButtonValueR, 255 )
                self.LerpedButtonValueG = Lerp( FrameTime() * 7, self.LerpedButtonValueG, 255 )
                self.LerpedButtonValueB = Lerp( FrameTime() * 7, self.LerpedButtonValueB, 255 )
                draw.RoundedBox( 0, 0, 0, w, h, Color( self.LerpedButtonValueR, self.LerpedButtonValueG, self.LerpedButtonValueB, c.a ) )

                self.RecentHover = true
            end

            draw.OutlinedBox( 0, 0, w, h, 2, Color( 0, 0, 0 ) )
        end
        WithdrawButton.DoClick = function()
          OpenWithdrawPanel()
        end

        local DepositButton = vgui.Create( "DButton", Frame )
        DepositButton:SetFont( "VerdanaCustom" )
        DepositButton:SetText( glorifiedbanking.getPhrase("deposit") )
        DepositButton:SetTextColor( Color( 255, 255, 255 ) )
        DepositButton:SetPos( 275, 80 )
        DepositButton:SetSize( 200, 50 )
        DepositButton.Init = function( self )
            self.RecentHover = false
            self.LerpedButtonValueR = glorifiedbanking.config.DERMA_BUTTON_COLOUR.r
            self.LerpedButtonValueG = glorifiedbanking.config.DERMA_BUTTON_COLOUR.g
            self.LerpedButtonValueB = glorifiedbanking.config.DERMA_BUTTON_COLOUR.b
        end
        DepositButton.Paint = function( self, w, h )
            local c = glorifiedbanking.config.DERMA_BUTTON_COLOUR

            if !self:IsHovered() then
                if self.RecentHover then
                    self.LerpedButtonValueR = Lerp( FrameTime() * 7, self.LerpedButtonValueR, c.r )
                    self.LerpedButtonValueG = Lerp( FrameTime() * 7, self.LerpedButtonValueG, c.g )
                    self.LerpedButtonValueB = Lerp( FrameTime() * 7, self.LerpedButtonValueB, c.b )

                    draw.RoundedBox( 0, 0, 0, w, h, Color( self.LerpedButtonValueR, self.LerpedButtonValueG, self.LerpedButtonValueB, c.a ) )
                    
                    if self.LerpedButtonValueR == c.r and self.LerpedButtonValueG == c.g and self.LerpedButtonValueB == c.b then
                        self.RecentHover = false
                    end
                else
                    self.LerpedButtonValueR = c.r
                    self.LerpedButtonValueG = c.g
                    self.LerpedButtonValueB = c.b

                    draw.RoundedBox( 0, 0, 0, w, h, c )
                end
            else
                self.LerpedButtonValueR = Lerp( FrameTime() * 7, self.LerpedButtonValueR, 255 )
                self.LerpedButtonValueG = Lerp( FrameTime() * 7, self.LerpedButtonValueG, 255 )
                self.LerpedButtonValueB = Lerp( FrameTime() * 7, self.LerpedButtonValueB, 255 )
                draw.RoundedBox( 0, 0, 0, w, h, Color( self.LerpedButtonValueR, self.LerpedButtonValueG, self.LerpedButtonValueB, c.a ) )

                self.RecentHover = true
            end

            draw.OutlinedBox( 0, 0, w, h, 2, Color( 0, 0, 0 ) )
        end
        DepositButton.DoClick = function()
          OpenDepositPanel()
        end


        local TransferButton = vgui.Create( "DButton", Frame )
        TransferButton:SetFont( "VerdanaCustom" )
        TransferButton:SetText( glorifiedbanking.getPhrase("transfer") )
        TransferButton:SetTextColor( Color( 255, 255, 255 ) )
        TransferButton:SetPos( 25, 150 )
        TransferButton:SetSize( 450, 50 )
        TransferButton.Init = function( self )
            self.RecentHover = false
            self.LerpedButtonValueR = glorifiedbanking.config.DERMA_BUTTON_COLOUR.r
            self.LerpedButtonValueG = glorifiedbanking.config.DERMA_BUTTON_COLOUR.g
            self.LerpedButtonValueB = glorifiedbanking.config.DERMA_BUTTON_COLOUR.b
        end
        TransferButton.Paint = function( self, w, h )
            local c = glorifiedbanking.config.DERMA_BUTTON_COLOUR

            if !self:IsHovered() then
                if self.RecentHover then
                    self.LerpedButtonValueR = Lerp( FrameTime() * 7, self.LerpedButtonValueR, c.r )
                    self.LerpedButtonValueG = Lerp( FrameTime() * 7, self.LerpedButtonValueG, c.g )
                    self.LerpedButtonValueB = Lerp( FrameTime() * 7, self.LerpedButtonValueB, c.b )

                    draw.RoundedBox( 0, 0, 0, w, h, Color( self.LerpedButtonValueR, self.LerpedButtonValueG, self.LerpedButtonValueB, c.a ) )
                    
                    if self.LerpedButtonValueR == c.r and self.LerpedButtonValueG == c.g and self.LerpedButtonValueB == c.b then
                        self.RecentHover = false
                    end
                else
                    self.LerpedButtonValueR = c.r
                    self.LerpedButtonValueG = c.g
                    self.LerpedButtonValueB = c.b

                    draw.RoundedBox( 0, 0, 0, w, h, c )
                end
            else
                self.LerpedButtonValueR = Lerp( FrameTime() * 7, self.LerpedButtonValueR, 255 )
                self.LerpedButtonValueG = Lerp( FrameTime() * 7, self.LerpedButtonValueG, 255 )
                self.LerpedButtonValueB = Lerp( FrameTime() * 7, self.LerpedButtonValueB, 255 )
                draw.RoundedBox( 0, 0, 0, w, h, Color( self.LerpedButtonValueR, self.LerpedButtonValueG, self.LerpedButtonValueB, c.a ) )

                self.RecentHover = true
            end

            draw.OutlinedBox( 0, 0, w, h, 2, Color( 0, 0, 0 ) )
        end
        TransferButton.DoClick = function()
            OpenTransferPanel()
        end
    end)
end

net.Receive( "GlorifiedBanking_ToggleATMPanel", function()
    OpenBankingPanel()
end )