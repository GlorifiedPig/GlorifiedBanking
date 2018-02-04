
surface.CreateFont( "VerdanaCustom", {
    font = "Verdana",
    size = 16,
    weight = 500,
} )

surface.CreateFont( "VerdanaCustom2", {
    font = "Verdana",
    size = 20,
    bold = true,
    weight = 500,
} )

surface.CreateFont( "VerdanaCustom3", {
    font = "Verdana",
    size = 35,
    bold = true,
    weight = 500,
} )

surface.CreateFont( "VerdanaCustom4", {
    font = "Verdana",
    size = 30,
    bold = true,
    weight = 500,
} )

surface.CreateFont( "VerdanaCustomHuge", {
    font = "Verdana",
    size = 42,
    bold = true,
    weight = 500,
} )

local bankBalance = 0
local affordableDeposit = false
local atmEntity

net.Receive( "glorifiedBanking_UpdateBankBalanceReceive", function()
    bankBalance = net.ReadUInt( 32 )
end )

net.Receive( "glorifiedBanking_IsAffordableDepositReceive", function()
    affordableDeposit = net.ReadBool()
end )

net.Receive( "glorifiedBanking_Notification", function()
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
	WithdrawFrame:SetTitle( glorifiedBanking.getPhrase("withdrawalTitle") )
	WithdrawFrame:SetDraggable( false )
	WithdrawFrame:ShowCloseButton( false )
	WithdrawFrame:SetPos( ScrW() / 2 - boxW / 2, ScrH() )
	WithdrawFrame:MakePopup()
    WithdrawFrame.Init = function( self )
        self.finishedAnimation = false
    end
    WithdrawFrame.Think = function( self, w, h )
        if !Frame:IsVisible() then
            self:Close()

            return
        end

        if input.IsKeyDown( KEY_ESCAPE ) then
            if !self.finishedCloseAnimation then
                self:Close()
                RunConsoleCommand( "cancelselect" )
            end

            return
        end

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
	    draw.RoundedBox( 0, 0, 0, w, h, glorifiedBanking.config.DERMA_BACKGROUND_COLOR_SUBSECTION )
        draw.OutlinedBox( 0, 0, w, h, 2, Color( 55, 55, 55 ) )
    end

	surface.SetFont( "VerdanaCustom" )
	local disbandMessage = glorifiedBanking.getPhrase("withdrawAmount")
	local textW, textH = surface.GetTextSize( disbandMessage )
	local disbandLabel = vgui.Create( "DLabel", WithdrawFrame )
    disbandLabel:SetText( disbandMessage )
    disbandLabel:SetTextColor( Color( 0, 0, 0 ) )
    disbandLabel:SetFont( "VerdanaCustom" )
	disbandLabel:SizeToContents()
	disbandLabel:SetPos( boxW / 2 - textW / 2, 30 )

    local withdrawText = vgui.Create( "DTextEntry", WithdrawFrame )
    withdrawText:SetFont( "VerdanaCustom" )
    withdrawText:SetText( glorifiedBanking.getPhrase("amount") )
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
                if affordableWithdraw and withdrawAmount <= glorifiedBanking.config.MAX_WITHDRAWAL then
                    net.Start( "glorifiedBanking_UpdateWithdrawal" )
                    net.WriteUInt( withdrawAmount, 32 )
                    net.SendToServer()
                    WithdrawFrame:MoveTo( ScrW() / 2 - boxW / 2, ScrH(), 0.5, 0, -1, function()
                        WithdrawFrame:Close()
                    end )
                    Frame:MoveTo( ScrW() / 2 - boxW / 2, ScrH(), 0.5, 0, -1, function()
                        Frame:Close()
                    end )
                    notification.AddLegacy(glorifiedBanking.getPhrase("withdrawSuccess", DarkRP.formatMoney( withdrawAmount )), NOTIFY_GENERIC, 5)
                    surface.PlaySound("buttons/button14.wav")
                elseif affordableWithdraw and withdrawAmount > glorifiedBanking.config.MAX_WITHDRAWAL then
                    WithdrawFrame:MoveTo( ScrW() / 2 - boxW / 2, ScrH(), 0.5, 0, -1, function()
                        WithdrawFrame:Close()
                    end )
                    Frame:MoveTo( ScrW() / 2 - boxW / 2, ScrH(), 0.5, 0, -1, function()
                        Frame:Close()
                    end )
                    notification.AddLegacy(glorifiedBanking.getPhrase("withdrawCannotMoreThan", DarkRP.formatMoney( glorifiedBanking.config.MAX_WITHDRAWAL )), NOTIFY_ERROR, 5)
                    surface.PlaySound("buttons/button2.wav")
                elseif !affordableWithdraw then
                    WithdrawFrame:MoveTo( ScrW() / 2 - boxW / 2, ScrH(), 0.5, 0, -1, function()
                        WithdrawFrame:Close()
                    end )
                    Frame:MoveTo( ScrW() / 2 - boxW / 2, ScrH(), 0.5, 0, -1, function()
                        Frame:Close()
                    end )
                    notification.AddLegacy(glorifiedBanking.getPhrase("cannotafford"), NOTIFY_ERROR, 5)
                    surface.PlaySound("buttons/button2.wav")
                else
                    WithdrawFrame:MoveTo( ScrW() / 2 - boxW / 2, ScrH(), 0.5, 0, -1, function()
                        WithdrawFrame:Close()
                    end )
                    Frame:MoveTo( ScrW() / 2 - boxW / 2, ScrH(), 0.5, 0, -1, function()
                        Frame:Close()
                    end )
                    notification.AddLegacy(glorifiedBanking.getPhrase("error"), NOTIFY_ERROR, 5)
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
            notification.AddLegacy(glorifiedBanking.getPhrase("validnumber"), NOTIFY_ERROR, 5)
            surface.PlaySound("buttons/button2.wav")
        end
    end
    withdrawText.OnEnter = function()
        DoWithdraw()
    end

	local withdraw = vgui.Create( "DButton", WithdrawFrame )
    withdraw:SetFont( "VerdanaCustom" )
    withdraw:SetTextColor( Color( 0, 0, 0 ) )
	withdraw:SetText(glorifiedBanking.getPhrase("withdrawal"))
	withdraw:SetSize( 80, 20 )
	withdraw:SetPos( boxW / 2 - 40 / 2 - 22 - 80 / 2 - 5, 75 )
	withdraw.DoClick = function()
        DoWithdraw()
	end
    withdraw.Init = function( self )
            self.RecentHover = false
            self.LerpedButtonValueR = glorifiedBanking.config.DERMA_BUTTON_COLOUR.r
            self.LerpedButtonValueG = glorifiedBanking.config.DERMA_BUTTON_COLOUR.g
            self.LerpedButtonValueB = glorifiedBanking.config.DERMA_BUTTON_COLOUR.b
        end
    withdraw.Paint = function( self, w, h )
        local c = glorifiedBanking.config.DERMA_BUTTON_COLOUR

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
        elseif self:IsHovered() && !self:IsDown() then
            self.LerpedButtonValueR = Lerp( FrameTime() * 7, self.LerpedButtonValueR, 255 )
            self.LerpedButtonValueG = Lerp( FrameTime() * 7, self.LerpedButtonValueG, 255 )
            self.LerpedButtonValueB = Lerp( FrameTime() * 7, self.LerpedButtonValueB, 255 )
            draw.RoundedBox( 0, 0, 0, w, h, Color( self.LerpedButtonValueR, self.LerpedButtonValueG, self.LerpedButtonValueB, c.a ) )

            self.RecentHover = true
        else
            self.LerpedButtonValueR = Lerp( FrameTime() * 7, self.LerpedButtonValueR, glorifiedBanking.config.DERMA_ONCLICK_COLOUR.r )
            self.LerpedButtonValueG = Lerp( FrameTime() * 7, self.LerpedButtonValueG, glorifiedBanking.config.DERMA_ONCLICK_COLOUR.g )
            self.LerpedButtonValueB = Lerp( FrameTime() * 7, self.LerpedButtonValueB, glorifiedBanking.config.DERMA_ONCLICK_COLOUR.b )
            draw.RoundedBox( 0, 0, 0, w, h, Color( self.LerpedButtonValueR, self.LerpedButtonValueG, self.LerpedButtonValueB, c.a ) )

               self.RecentHover = true
        end

        draw.OutlinedBox( 0, 0, w, h, 2, Color( 55, 55, 55 ) )
    end

    local cancelButton = vgui.Create( "DButton", WithdrawFrame )
    cancelButton:SetFont( "VerdanaCustom" )
    cancelButton:SetTextColor( Color( 0, 0, 0 ) )
	cancelButton:SetText(glorifiedBanking.getPhrase("cancel"))
	cancelButton:SetSize( 80, 20 )
	cancelButton:SetPos( boxW / 2 - 40 / 2 - 22 + 80 / 2 + 5, 75 )
	cancelButton.DoClick = function()
        WithdrawFrame:MoveTo( ScrW() / 2 - boxW / 2, ScrH(), 0.5, 0, -1, function()
            WithdrawFrame:Close()
        end )
    end
    cancelButton.Init = function( self )
            self.RecentHover = false
            self.LerpedButtonValueR = glorifiedBanking.config.DERMA_BUTTON_COLOUR.r
            self.LerpedButtonValueG = glorifiedBanking.config.DERMA_BUTTON_COLOUR.g
            self.LerpedButtonValueB = glorifiedBanking.config.DERMA_BUTTON_COLOUR.b
        end
    cancelButton.Paint = function( self, w, h )
        local c = glorifiedBanking.config.DERMA_BUTTON_COLOUR

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
        elseif self:IsHovered() && !self:IsDown() then
            self.LerpedButtonValueR = Lerp( FrameTime() * 7, self.LerpedButtonValueR, 255 )
            self.LerpedButtonValueG = Lerp( FrameTime() * 7, self.LerpedButtonValueG, 255 )
            self.LerpedButtonValueB = Lerp( FrameTime() * 7, self.LerpedButtonValueB, 255 )
            draw.RoundedBox( 0, 0, 0, w, h, Color( self.LerpedButtonValueR, self.LerpedButtonValueG, self.LerpedButtonValueB, c.a ) )

            self.RecentHover = true
        else
            self.LerpedButtonValueR = Lerp( FrameTime() * 7, self.LerpedButtonValueR, glorifiedBanking.config.DERMA_ONCLICK_COLOUR.r )
            self.LerpedButtonValueG = Lerp( FrameTime() * 7, self.LerpedButtonValueG, glorifiedBanking.config.DERMA_ONCLICK_COLOUR.g )
            self.LerpedButtonValueB = Lerp( FrameTime() * 7, self.LerpedButtonValueB, glorifiedBanking.config.DERMA_ONCLICK_COLOUR.b )
            draw.RoundedBox( 0, 0, 0, w, h, Color( self.LerpedButtonValueR, self.LerpedButtonValueG, self.LerpedButtonValueB, c.a ) )

               self.RecentHover = true
        end

        draw.OutlinedBox( 0, 0, w, h, 2, Color( 55, 55, 55 ) )
    end
end

local function OpenDepositPanel()
    local ply = LocalPlayer()

    local boxW, boxH = 450, 115
	local DepositFrame = vgui.Create( "DFrame" )
	DepositFrame:SetSize( boxW, boxH )
	DepositFrame:SetTitle( glorifiedBanking.getPhrase("depositTitle") )
	DepositFrame:SetDraggable( false )
	DepositFrame:ShowCloseButton( false )
	DepositFrame:SetPos( ScrW() / 2 - boxW / 2, ScrH() )
	DepositFrame:MakePopup()
    DepositFrame.Init = function( self )
        self.finishedAnimation = false
    end
    DepositFrame.Think = function( self, w, h )
        if !Frame:IsVisible() then
            self:Close()

            return
        end

        if input.IsKeyDown( KEY_ESCAPE ) then
            if !self.finishedCloseAnimation then
                self:Close()
                RunConsoleCommand( "cancelselect" )
            end

            return
        end

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
	    draw.RoundedBox( 0, 0, 0, w, h, glorifiedBanking.config.DERMA_BACKGROUND_COLOR_SUBSECTION )
        draw.OutlinedBox( 0, 0, w, h, 2, Color( 55, 55, 55 ) )
    end

	surface.SetFont( "VerdanaCustom" )
	local disbandMessage = glorifiedBanking.getPhrase("depositAmount")
	local textW, textH = surface.GetTextSize( disbandMessage )
	local disbandLabel = vgui.Create( "DLabel", DepositFrame )
    disbandLabel:SetText( disbandMessage )
    disbandLabel:SetTextColor( Color( 0, 0, 0 ) )
	disbandLabel:SetFont( "VerdanaCustom" )
	disbandLabel:SizeToContents()
	disbandLabel:SetPos( boxW / 2 - textW / 2, 30 )

    local depositText = vgui.Create( "DTextEntry", DepositFrame )
    depositText:SetFont( "VerdanaCustom" )
    depositText:SetText( glorifiedBanking.getPhrase( "amount" ) )
    depositText:SetSize( 100, 20 )
    depositText:SetPos( boxW / 2 - 100 / 2, 50 )
    local function DoDeposit()
        local depositAmount = tonumber( depositText:GetText() )
        if isnumber( depositAmount ) then
            depositAmount = math.abs( tonumber( depositText:GetText() ) )

            net.Start( "glorifiedBanking_IsAffordableDeposit" )
            net.WriteUInt( depositAmount, 32 )
            net.SendToServer()

            timer.Simple( ply:Ping() / 1000 + 0.1, function()
                if affordableDeposit and depositAmount <= glorifiedBanking.config.MAX_DEPOSIT then
                    net.Start( "glorifiedBanking_UpdateDeposit" )
                    net.WriteUInt( depositAmount, 32 )
                    net.SendToServer()
                    DepositFrame:MoveTo( ScrW() / 2 - boxW / 2, ScrH(), 0.5, 0, -1, function()
                        DepositFrame:Close()
                    end )
                    Frame:MoveTo( ScrW() / 2 - boxW / 2, ScrH(), 0.5, 0, -1, function()
                        Frame:Close()
                    end )
                    notification.AddLegacy(glorifiedBanking.getPhrase("depositSuccess", DarkRP.formatMoney( depositAmount )), NOTIFY_GENERIC, 5)
                    surface.PlaySound("buttons/button14.wav")
                elseif affordableDeposit and depositAmount > glorifiedBanking.config.MAX_DEPOSIT then
                    DepositFrame:MoveTo( ScrW() / 2 - boxW / 2, ScrH(), 0.5, 0, -1, function()
                        DepositFrame:Close()
                    end )
                    Frame:MoveTo( ScrW() / 2 - boxW / 2, ScrH(), 0.5, 0, -1, function()
                        Frame:Close()
                    end )
                    notification.AddLegacy(glorifiedBanking.getPhrase("depositCannotMoreThan", DarkRP.formatMoney( glorifiedBanking.config.MAX_DEPOSIT ) ), NOTIFY_ERROR, 5)
                    surface.PlaySound("buttons/button2.wav")
                elseif !affordableDeposit then
                    DepositFrame:MoveTo( ScrW() / 2 - boxW / 2, ScrH(), 0.5, 0, -1, function()
                        DepositFrame:Close()
                    end )
                    Frame:MoveTo( ScrW() / 2 - boxW / 2, ScrH(), 0.5, 0, -1, function()
                        Frame:Close()
                    end )
                    notification.AddLegacy(glorifiedBanking.getPhrase("cannotafford"), NOTIFY_ERROR, 5)
                    surface.PlaySound("buttons/button2.wav")
                else
                    DepositFrame:MoveTo( ScrW() / 2 - boxW / 2, ScrH(), 0.5, 0, -1, function()
                        DepositFrame:Close()
                    end )
                    Frame:MoveTo( ScrW() / 2 - boxW / 2, ScrH(), 0.5, 0, -1, function()
                        Frame:Close()
                    end )
                    notification.AddLegacy(glorifiedBanking.getPhrase("error"), NOTIFY_ERROR, 5)
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
            notification.AddLegacy(glorifiedBanking.getPhrase("validnumber"), NOTIFY_ERROR, 5)
            surface.PlaySound("buttons/button2.wav")
        end
    end
    depositText.OnEnter = function()
        DoDeposit()
    end

	local deposit = vgui.Create( "DButton", DepositFrame )
    deposit:SetFont( "VerdanaCustom" )
    deposit:SetTextColor( Color( 0, 0, 0 ) )
	deposit:SetText(glorifiedBanking.getPhrase("deposit"))
	deposit:SetSize( 80, 20 )
	deposit:SetPos( boxW / 2 - 40 / 2 - 22 - 80 / 2 - 5, 75 )
	deposit.DoClick = function()
        DoDeposit()
	end
    deposit.Init = function( self )
            self.RecentHover = false
            self.LerpedButtonValueR = glorifiedBanking.config.DERMA_BUTTON_COLOUR.r
            self.LerpedButtonValueG = glorifiedBanking.config.DERMA_BUTTON_COLOUR.g
            self.LerpedButtonValueB = glorifiedBanking.config.DERMA_BUTTON_COLOUR.b
        end
    deposit.Paint = function( self, w, h )
        local c = glorifiedBanking.config.DERMA_BUTTON_COLOUR

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
        elseif self:IsHovered() && !self:IsDown() then
            self.LerpedButtonValueR = Lerp( FrameTime() * 7, self.LerpedButtonValueR, 255 )
            self.LerpedButtonValueG = Lerp( FrameTime() * 7, self.LerpedButtonValueG, 255 )
            self.LerpedButtonValueB = Lerp( FrameTime() * 7, self.LerpedButtonValueB, 255 )
            draw.RoundedBox( 0, 0, 0, w, h, Color( self.LerpedButtonValueR, self.LerpedButtonValueG, self.LerpedButtonValueB, c.a ) )

            self.RecentHover = true
        else
            self.LerpedButtonValueR = Lerp( FrameTime() * 7, self.LerpedButtonValueR, glorifiedBanking.config.DERMA_ONCLICK_COLOUR.r )
            self.LerpedButtonValueG = Lerp( FrameTime() * 7, self.LerpedButtonValueG, glorifiedBanking.config.DERMA_ONCLICK_COLOUR.g )
            self.LerpedButtonValueB = Lerp( FrameTime() * 7, self.LerpedButtonValueB, glorifiedBanking.config.DERMA_ONCLICK_COLOUR.b )
            draw.RoundedBox( 0, 0, 0, w, h, Color( self.LerpedButtonValueR, self.LerpedButtonValueG, self.LerpedButtonValueB, c.a ) )

               self.RecentHover = true
        end

        draw.OutlinedBox( 0, 0, w, h, 2, Color( 55, 55, 55 ) )
    end

    local cancelButton = vgui.Create( "DButton", DepositFrame )
    cancelButton:SetFont( "VerdanaCustom" )
    cancelButton:SetTextColor( Color( 0, 0, 0 ) )
	cancelButton:SetText(glorifiedBanking.getPhrase("cancel"))
	cancelButton:SetSize( 80, 20 )
	cancelButton:SetPos( boxW / 2 - 40 / 2 - 22 + 80 / 2 + 5, 75 )
	cancelButton.DoClick = function()
        DepositFrame:MoveTo( ScrW() / 2 - boxW / 2, ScrH(), 0.5, 0, -1, function()
            DepositFrame:Close()
        end )
    end
    cancelButton.Init = function( self )
            self.RecentHover = false
            self.LerpedButtonValueR = glorifiedBanking.config.DERMA_BUTTON_COLOUR.r
            self.LerpedButtonValueG = glorifiedBanking.config.DERMA_BUTTON_COLOUR.g
            self.LerpedButtonValueB = glorifiedBanking.config.DERMA_BUTTON_COLOUR.b
        end
    cancelButton.Paint = function( self, w, h )
        local c = glorifiedBanking.config.DERMA_BUTTON_COLOUR

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
        elseif self:IsHovered() && !self:IsDown() then
            self.LerpedButtonValueR = Lerp( FrameTime() * 7, self.LerpedButtonValueR, 255 )
            self.LerpedButtonValueG = Lerp( FrameTime() * 7, self.LerpedButtonValueG, 255 )
            self.LerpedButtonValueB = Lerp( FrameTime() * 7, self.LerpedButtonValueB, 255 )
            draw.RoundedBox( 0, 0, 0, w, h, Color( self.LerpedButtonValueR, self.LerpedButtonValueG, self.LerpedButtonValueB, c.a ) )

            self.RecentHover = true
        else
            self.LerpedButtonValueR = Lerp( FrameTime() * 7, self.LerpedButtonValueR, glorifiedBanking.config.DERMA_ONCLICK_COLOUR.r )
            self.LerpedButtonValueG = Lerp( FrameTime() * 7, self.LerpedButtonValueG, glorifiedBanking.config.DERMA_ONCLICK_COLOUR.g )
            self.LerpedButtonValueB = Lerp( FrameTime() * 7, self.LerpedButtonValueB, glorifiedBanking.config.DERMA_ONCLICK_COLOUR.b )
            draw.RoundedBox( 0, 0, 0, w, h, Color( self.LerpedButtonValueR, self.LerpedButtonValueG, self.LerpedButtonValueB, c.a ) )

               self.RecentHover = true
        end

        draw.OutlinedBox( 0, 0, w, h, 2, Color( 55, 55, 55 ) )
    end
end

local function OpenTransferPanel()
    local ply = LocalPlayer()

    local boxW, boxH = 450, 142
	local TransferFrame = vgui.Create( "DFrame" )
	TransferFrame:SetSize( boxW, boxH )
	TransferFrame:SetTitle( glorifiedBanking.getPhrase("transferTitle") )
	TransferFrame:SetDraggable( false )
	TransferFrame:ShowCloseButton( false )
	TransferFrame:SetPos( ScrW() / 2 - boxW / 2, ScrH() )
	TransferFrame:MakePopup()
    TransferFrame.Init = function( self )
        self.finishedAnimation = false
    end
    TransferFrame.Think = function( self, w, h )
        if !Frame:IsVisible() then
            self:Close()

            return
        end

        if input.IsKeyDown( KEY_ESCAPE ) then
            if !self.finishedCloseAnimation then
                self:Close()
                RunConsoleCommand( "cancelselect" )
            end

            return
        end

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
	    draw.RoundedBox( 0, 0, 0, w, h, glorifiedBanking.config.DERMA_BACKGROUND_COLOR_SUBSECTION )
        draw.OutlinedBox( 0, 0, w, h, 2, Color( 55, 55, 55 ) )
    end

	surface.SetFont( "VerdanaCustom" )
	local disbandMessage = glorifiedBanking.getPhrase("transferAmount")
	local textW, textH = surface.GetTextSize( disbandMessage )
    local disbandLabel = vgui.Create( "DLabel", TransferFrame )
    disbandLabel:SetText( disbandMessage )
    disbandLabel:SetTextColor( Color( 0, 0, 0 ) )
	disbandLabel:SetFont( "VerdanaCustom" )
	disbandLabel:SizeToContents()
	disbandLabel:SetPos( boxW / 2 - textW / 2, 30 )

    local PlayerComboBox = vgui.Create( "DComboBox", TransferFrame )
    PlayerComboBox:SetFont( "VerdanaCustom" )
    PlayerComboBox:SetSize( 115, 20 )
    PlayerComboBox:SetPos( boxW / 2 - 115 / 2, 75 )
    PlayerComboBox:SetValue( glorifiedBanking.getPhrase("playerList") )
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
    transferText:SetText( glorifiedBanking.getPhrase("amount") )
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
                notification.AddLegacy(glorifiedBanking.getPhrase("validplayer"), NOTIFY_ERROR, 5)
                surface.PlaySound("buttons/button2.wav")
                return
            end

            timer.Simple( ply:Ping() / 1000 + 0.1, function()
                if affordableTransfer and transferAmount <= glorifiedBanking.config.MAX_TRANSFER then
                    net.Start( "glorifiedBanking_UpdateTransfer" )
                    net.WriteInt( transferAmount, 32 )
                    net.WriteEntity( transferringPlayer )
                    net.SendToServer()
                    TransferFrame:MoveTo( ScrW() / 2 - boxW / 2, ScrH(), 0.5, 0, -1, function()
                        TransferFrame:Close()
                    end )
                    Frame:MoveTo( ScrW() / 2 - boxW / 2, ScrH(), 0.5, 0, -1, function()
                        Frame:Close()
                    end )
                    notification.AddLegacy(glorifiedBanking.getPhrase("transferSuccess", DarkRP.formatMoney( transferAmount ), transferringPlayer:Nick()), NOTIFY_GENERIC, 5)
                    surface.PlaySound("buttons/button14.wav")
                elseif affordableTransfer and transferAmount > glorifiedBanking.config.MAX_TRANSFER then
                    TransferFrame:MoveTo( ScrW() / 2 - boxW / 2, ScrH(), 0.5, 0, -1, function()
                        TransferFrame:Close()
                    end )
                    Frame:MoveTo( ScrW() / 2 - boxW / 2, ScrH(), 0.5, 0, -1, function()
                        Frame:Close()
                    end )
                    notification.AddLegacy(glorifiedBanking.getPhrase("transferCannotMoreThan", DarkRP.formatMoney( glorifiedBanking.config.MAX_TRANSFER )), NOTIFY_ERROR, 5)
                    surface.PlaySound("buttons/button2.wav")
                elseif !affordableTransfer then
                    TransferFrame:MoveTo( ScrW() / 2 - boxW / 2, ScrH(), 0.5, 0, -1, function()
                        TransferFrame:Close()
                    end )
                    Frame:MoveTo( ScrW() / 2 - boxW / 2, ScrH(), 0.5, 0, -1, function()
                        Frame:Close()
                    end )
                    notification.AddLegacy(glorifiedBanking.getPhrase("cannotafford"), NOTIFY_ERROR, 5)
                    surface.PlaySound("buttons/button2.wav")
                else
                    TransferFrame:MoveTo( ScrW() / 2 - boxW / 2, ScrH(), 0.5, 0, -1, function()
                        TransferFrame:Close()
                    end )
                    Frame:MoveTo( ScrW() / 2 - boxW / 2, ScrH(), 0.5, 0, -1, function()
                        Frame:Close()
                    end )
                    notification.AddLegacy(glorifiedBanking.getPhrase("error"), NOTIFY_ERROR, 5)
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
            notification.AddLegacy(glorifiedBanking.getPhrase("validnumber"), NOTIFY_ERROR, 5)
            surface.PlaySound("buttons/button2.wav")
        end
    end
    transferText.OnEnter = function()
        DoTransfer()
    end

	local transfer = vgui.Create( "DButton", TransferFrame )
    transfer:SetFont( "VerdanaCustom" )
    transfer:SetTextColor( Color( 0, 0, 0 ) )
	transfer:SetText(glorifiedBanking.getPhrase("transfer"))
	transfer:SetSize( 80, 20 )
	transfer:SetPos( boxW / 2 - 40 / 2 - 22 - 80 / 2 - 5, 100 )
	transfer.DoClick = function()
        DoTransfer()
	end
    transfer.Init = function( self )
            self.RecentHover = false
            self.LerpedButtonValueR = glorifiedBanking.config.DERMA_BUTTON_COLOUR.r
            self.LerpedButtonValueG = glorifiedBanking.config.DERMA_BUTTON_COLOUR.g
            self.LerpedButtonValueB = glorifiedBanking.config.DERMA_BUTTON_COLOUR.b
        end
    transfer.Paint = function( self, w, h )
        local c = glorifiedBanking.config.DERMA_BUTTON_COLOUR

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
        elseif self:IsHovered() && !self:IsDown() then
            self.LerpedButtonValueR = Lerp( FrameTime() * 7, self.LerpedButtonValueR, 255 )
            self.LerpedButtonValueG = Lerp( FrameTime() * 7, self.LerpedButtonValueG, 255 )
            self.LerpedButtonValueB = Lerp( FrameTime() * 7, self.LerpedButtonValueB, 255 )
            draw.RoundedBox( 0, 0, 0, w, h, Color( self.LerpedButtonValueR, self.LerpedButtonValueG, self.LerpedButtonValueB, c.a ) )

            self.RecentHover = true
        else
            self.LerpedButtonValueR = Lerp( FrameTime() * 7, self.LerpedButtonValueR, glorifiedBanking.config.DERMA_ONCLICK_COLOUR.r )
            self.LerpedButtonValueG = Lerp( FrameTime() * 7, self.LerpedButtonValueG, glorifiedBanking.config.DERMA_ONCLICK_COLOUR.g )
            self.LerpedButtonValueB = Lerp( FrameTime() * 7, self.LerpedButtonValueB, glorifiedBanking.config.DERMA_ONCLICK_COLOUR.b )
            draw.RoundedBox( 0, 0, 0, w, h, Color( self.LerpedButtonValueR, self.LerpedButtonValueG, self.LerpedButtonValueB, c.a ) )

               self.RecentHover = true
        end

        draw.OutlinedBox( 0, 0, w, h, 2, Color( 55, 55, 55 ) )
    end

    local cancelButton = vgui.Create( "DButton", TransferFrame )
    cancelButton:SetFont( "VerdanaCustom" )
    cancelButton:SetTextColor( Color( 0, 0, 0 ) )
	cancelButton:SetText(glorifiedBanking.getPhrase("cancel"))
	cancelButton:SetSize( 80, 20 )
	cancelButton:SetPos( boxW / 2 - 40 / 2 - 22 + 80 / 2 + 5, 100 )
	cancelButton.DoClick = function()
        TransferFrame:MoveTo( ScrW() / 2 - boxW / 2, ScrH(), 0.5, 0, -1, function()
            TransferFrame:Close()
        end )
    end
    cancelButton.Init = function( self )
            self.RecentHover = false
            self.LerpedButtonValueR = glorifiedBanking.config.DERMA_BUTTON_COLOUR.r
            self.LerpedButtonValueG = glorifiedBanking.config.DERMA_BUTTON_COLOUR.g
            self.LerpedButtonValueB = glorifiedBanking.config.DERMA_BUTTON_COLOUR.b
        end
    cancelButton.Paint = function( self, w, h )
        local c = glorifiedBanking.config.DERMA_BUTTON_COLOUR

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
        elseif self:IsHovered() && !self:IsDown() then
            self.LerpedButtonValueR = Lerp( FrameTime() * 7, self.LerpedButtonValueR, 255 )
            self.LerpedButtonValueG = Lerp( FrameTime() * 7, self.LerpedButtonValueG, 255 )
            self.LerpedButtonValueB = Lerp( FrameTime() * 7, self.LerpedButtonValueB, 255 )
            draw.RoundedBox( 0, 0, 0, w, h, Color( self.LerpedButtonValueR, self.LerpedButtonValueG, self.LerpedButtonValueB, c.a ) )

            self.RecentHover = true
        else
            self.LerpedButtonValueR = Lerp( FrameTime() * 7, self.LerpedButtonValueR, glorifiedBanking.config.DERMA_ONCLICK_COLOUR.r )
            self.LerpedButtonValueG = Lerp( FrameTime() * 7, self.LerpedButtonValueG, glorifiedBanking.config.DERMA_ONCLICK_COLOUR.g )
            self.LerpedButtonValueB = Lerp( FrameTime() * 7, self.LerpedButtonValueB, glorifiedBanking.config.DERMA_ONCLICK_COLOUR.b )
            draw.RoundedBox( 0, 0, 0, w, h, Color( self.LerpedButtonValueR, self.LerpedButtonValueG, self.LerpedButtonValueB, c.a ) )

               self.RecentHover = true
        end

        draw.OutlinedBox( 0, 0, w, h, 2, Color( 55, 55, 55 ) )
    end
end

local function OpenBankingPanel()
    net.Start( "glorifiedBanking_UpdateBankBalance" )
    net.SendToServer()

    local ply = LocalPlayer()

    local boxW, boxH = 350, 450
    Frame = vgui.Create( "DFrame" )
    Frame:SetTitle( "" )
    Frame:SetSize( boxW, boxH )
    Frame:SetDeleteOnClose( false )
    Frame:ShowCloseButton( false )
    Frame:SetPos( ScrW() / 2 - boxW / 2, ScrH() )
    Frame:MakePopup()
    Frame.Init = function( self )
        self.finishedAnimation = false
        self.finishedCloseAnimation = false
        self.startTime = SysTime()
    end
    Frame.Think = function( self, w, h )
        if !atmEntity:IsValid() or ply:GetPos():Distance( atmEntity:GetPos() ) > 100 or !ply:Alive() then
            if !self.finishedCloseAnimation then
                Frame:Close()
            end

            return
        end

        if input.IsKeyDown( KEY_ESCAPE ) then
            if !self.finishedCloseAnimation then
                Frame:Close()
                RunConsoleCommand( "cancelselect" )
            end

            return
        end

        if self.finishedAnimation then return end

        if Frame.y == ScrH() then
            Frame:MoveTo( ScrW() / 2 - boxW / 2, ScrH() / 2 - boxH / 2, 0.5 )
            self.finishedAnimation = true
        end
    end
    Frame.OnClose = function( self )
        if self.finishedCloseAnimation then return end

        Frame:SetVisible( true )

        Frame:MoveTo( ScrW() / 2 - boxW / 2, ScrH(), 0.5, 0, -1, function()
            Frame:Close()
            Frame:SetVisible( false )
        end )

        self.finishedCloseAnimation = true
    end
    Frame.Paint = function( self, w, h )
        Derma_DrawBackgroundBlur( self, self.startTime )
        draw.RoundedBox( 0, 0, 0, w, h, glorifiedBanking.config.DERMA_BACKGROUND_COLOR )
        draw.RoundedBox( 0, 0, 0, w, 150, glorifiedBanking.config.DEMA_BACKGROUND_SECONDARY_COLOR )

        draw.RoundedBox( 0, 0, 205, w - 15, 1, Color( 0, 0, 0, 185 ) )
    end

    timer.Simple( ply:Ping() / 1000 + 0.1, function()
        local CloseButton = vgui.Create( "DButton", Frame )
        CloseButton:SetFont( "VerdanaCustom2" )
        CloseButton:SetText( "X" )
        CloseButton:SetTextColor( Color( 0, 0, 0 ) )
        CloseButton:SetPos( boxW - 45, 5 )
        CloseButton:SetSize( 35, 20 )
        CloseButton.Paint = function( self, w, h )
            draw.RoundedBox( 0, 0, 0, w, h, glorifiedBanking.config.DERMA_CLOSE_BUTTON_COLOR )
        end
        CloseButton.DoClick = function()
            Frame:Close()
        end

        surface.SetFont( "VerdanaCustom" )
        --local atmW, atmH = surface.GetTextSize( glorifiedBanking.getPhrase( "welcome" ) )
        if( string.len( LocalPlayer():Nick() ) < 15 ) then
            surface.SetFont( "VerdanaCustomHuge" )
        elseif( string.len( LocalPlayer():Nick() ) < 23 ) then
            surface.SetFont( "VerdanaCustom4" )
        else
            surface.SetFont( "VerdanaCustom2" )
        end
        local playerNickW, playerNickH = surface.GetTextSize( LocalPlayer():Nick() )
        surface.SetFont( "VerdanaCustom2" )
        local balW, balH = surface.GetTextSize( glorifiedBanking.getPhrase( "curBalance" ) )
        surface.SetFont( "VerdanaCustom3" )
        local bankBalW, bankBalH = surface.GetTextSize( DarkRP.formatMoney( bankBalance ) )

		--ATMLabel:SetText( glorifiedBanking.getPhrase( "welcome" ) )

        local playerNickLabel = vgui.Create( "DLabel", Frame )
        if( string.len( LocalPlayer():Nick() ) < 15 ) then
            playerNickLabel:SetFont( "VerdanaCustomHuge" )
        elseif( string.len( LocalPlayer():Nick() ) < 23 ) then
            playerNickLabel:SetFont( "VerdanaCustom4" )
        else
            playerNickLabel:SetFont( "VerdanaCustom2" )
        end
        playerNickLabel:SetTextColor( Color( 255, 255, 255 ) )
		playerNickLabel:SetPos( boxW / 2 - playerNickW / 2, 50 )
		playerNickLabel:SetText( LocalPlayer():Nick() )
        playerNickLabel:SizeToContents()

        local BalancePanel = vgui.Create( "DPanel", Frame )
        BalancePanel:SetPos( boxW / 2 - 235 / 2, 105 )
        BalancePanel:SetSize( 235, 65 )
        BalancePanel.Paint = function( self, w, h )
            draw.RoundedBox( 0, 0, 0, w, h, glorifiedBanking.config.DERMA_BACKGROUND_COLOR_SUBSECTION )
            draw.OutlinedBox( 0, 0, w, h, 2, Color( 55, 55, 55 ) )
        end

        local BalanceLabel = vgui.Create( "DLabel", BalancePanel )
        BalanceLabel:SetFont( "VerdanaCustom2" )
		BalanceLabel:SetPos( 235 / 2 - balW / 2, 5 )
        BalanceLabel:SetText( glorifiedBanking.getPhrase( "curBalance" ) )
        BalanceLabel:SetTextColor( Color( 0, 0, 0 ) )
        BalanceLabel:SizeToContents()

        local BalanceMoneyLabel = vgui.Create( "DLabel", BalancePanel )
        BalanceMoneyLabel:SetFont( "VerdanaCustom3" )
		BalanceMoneyLabel:SetPos( 235 / 2 - bankBalW / 2, 25 )
        BalanceMoneyLabel:SetText( DarkRP.formatMoney( bankBalance ) )
        BalanceMoneyLabel:SetTextColor( Color( 0, 0, 0 ) )
        BalanceMoneyLabel:SizeToContents()

        local actionsLabel = vgui.Create( "DLabel", Frame )
        actionsLabel:SetFont( "VerdanaCustom" )
        actionsLabel:SetTextColor( Color( 0, 0, 0 ) )
		actionsLabel:SetPos( 15, 185 )
		actionsLabel:SetText( "ACTIONS" )
        actionsLabel:SizeToContents()

        local WithdrawButton = vgui.Create( "DButton", Frame )
        WithdrawButton:SetFont( "VerdanaCustom" )
        WithdrawButton:SetText( glorifiedBanking.getPhrase("withdrawal") )
        WithdrawButton:SetTextColor( Color( 0, 0, 0 ) )
        WithdrawButton:SetPos( boxW / 2 - 200 / 2, 230 )
        WithdrawButton:SetFont( "VerdanaCustom2" )
        WithdrawButton:SetSize( 200, 50 )
        WithdrawButton.Init = function( self )
            self.RecentHover = false
            self.LerpedButtonValueR = glorifiedBanking.config.DERMA_BUTTON_COLOUR.r
            self.LerpedButtonValueG = glorifiedBanking.config.DERMA_BUTTON_COLOUR.g
            self.LerpedButtonValueB = glorifiedBanking.config.DERMA_BUTTON_COLOUR.b
        end
        WithdrawButton.Paint = function( self, w, h )
            local c = glorifiedBanking.config.DERMA_BUTTON_COLOUR

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
            elseif self:IsHovered() && !self:IsDown() then
                self.LerpedButtonValueR = Lerp( FrameTime() * 7, self.LerpedButtonValueR, 255 )
                self.LerpedButtonValueG = Lerp( FrameTime() * 7, self.LerpedButtonValueG, 255 )
                self.LerpedButtonValueB = Lerp( FrameTime() * 7, self.LerpedButtonValueB, 255 )
                draw.RoundedBox( 0, 0, 0, w, h, Color( self.LerpedButtonValueR, self.LerpedButtonValueG, self.LerpedButtonValueB, c.a ) )

                self.RecentHover = true
            else
                self.LerpedButtonValueR = Lerp( FrameTime() * 7, self.LerpedButtonValueR, glorifiedBanking.config.DERMA_ONCLICK_COLOUR.r )
                self.LerpedButtonValueG = Lerp( FrameTime() * 7, self.LerpedButtonValueG, glorifiedBanking.config.DERMA_ONCLICK_COLOUR.g )
                self.LerpedButtonValueB = Lerp( FrameTime() * 7, self.LerpedButtonValueB, glorifiedBanking.config.DERMA_ONCLICK_COLOUR.b )
                draw.RoundedBox( 0, 0, 0, w, h, Color( self.LerpedButtonValueR, self.LerpedButtonValueG, self.LerpedButtonValueB, c.a ) )

                self.RecentHover = true
            end

            draw.OutlinedBox( 0, 0, w, h, 2, Color( 55, 55, 55 ) )
        end
        WithdrawButton.DoClick = function()
          OpenWithdrawPanel()
        end

        local DepositButton = vgui.Create( "DButton", Frame )
        DepositButton:SetFont( "VerdanaCustom" )
        DepositButton:SetText( glorifiedBanking.getPhrase("deposit") )
        DepositButton:SetTextColor( Color( 0, 0, 0 ) )
        DepositButton:SetPos( boxW / 2 - 200 / 2, 295 )
        DepositButton:SetSize( 200, 50 )
        DepositButton:SetFont( "VerdanaCustom2" )
        DepositButton.Init = function( self )
            self.RecentHover = false
            self.LerpedButtonValueR = glorifiedBanking.config.DERMA_BUTTON_COLOUR.r
            self.LerpedButtonValueG = glorifiedBanking.config.DERMA_BUTTON_COLOUR.g
            self.LerpedButtonValueB = glorifiedBanking.config.DERMA_BUTTON_COLOUR.b
        end
        DepositButton.Paint = function( self, w, h )
            local c = glorifiedBanking.config.DERMA_BUTTON_COLOUR

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
            elseif self:IsHovered() && !self:IsDown() then
                self.LerpedButtonValueR = Lerp( FrameTime() * 7, self.LerpedButtonValueR, 255 )
                self.LerpedButtonValueG = Lerp( FrameTime() * 7, self.LerpedButtonValueG, 255 )
                self.LerpedButtonValueB = Lerp( FrameTime() * 7, self.LerpedButtonValueB, 255 )
                draw.RoundedBox( 0, 0, 0, w, h, Color( self.LerpedButtonValueR, self.LerpedButtonValueG, self.LerpedButtonValueB, c.a ) )

                self.RecentHover = true
            else
                self.LerpedButtonValueR = Lerp( FrameTime() * 7, self.LerpedButtonValueR, glorifiedBanking.config.DERMA_ONCLICK_COLOUR.r )
                self.LerpedButtonValueG = Lerp( FrameTime() * 7, self.LerpedButtonValueG, glorifiedBanking.config.DERMA_ONCLICK_COLOUR.g )
                self.LerpedButtonValueB = Lerp( FrameTime() * 7, self.LerpedButtonValueB, glorifiedBanking.config.DERMA_ONCLICK_COLOUR.b )
                draw.RoundedBox( 0, 0, 0, w, h, Color( self.LerpedButtonValueR, self.LerpedButtonValueG, self.LerpedButtonValueB, c.a ) )

                self.RecentHover = true
            end

            draw.OutlinedBox( 0, 0, w, h, 2, Color( 55, 55, 55 ) )
        end
        DepositButton.DoClick = function()
          OpenDepositPanel()
        end


        local TransferButton = vgui.Create( "DButton", Frame )
        TransferButton:SetFont( "VerdanaCustom" )
        TransferButton:SetText( glorifiedBanking.getPhrase("transfer") )
        TransferButton:SetTextColor( Color( 0, 0, 0 ) )
        TransferButton:SetPos( boxW / 2 - 200 / 2, 360 )
        TransferButton:SetSize( 200, 50 )
        TransferButton:SetFont( "VerdanaCustom2" )
        TransferButton.Init = function( self )
            self.RecentHover = false
            self.LerpedButtonValueR = glorifiedBanking.config.DERMA_BUTTON_COLOUR.r
            self.LerpedButtonValueG = glorifiedBanking.config.DERMA_BUTTON_COLOUR.g
            self.LerpedButtonValueB = glorifiedBanking.config.DERMA_BUTTON_COLOUR.b
        end
        TransferButton.Paint = function( self, w, h )
            local c = glorifiedBanking.config.DERMA_BUTTON_COLOUR

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
            elseif self:IsHovered() && !self:IsDown() then
                self.LerpedButtonValueR = Lerp( FrameTime() * 7, self.LerpedButtonValueR, 255 )
                self.LerpedButtonValueG = Lerp( FrameTime() * 7, self.LerpedButtonValueG, 255 )
                self.LerpedButtonValueB = Lerp( FrameTime() * 7, self.LerpedButtonValueB, 255 )
                draw.RoundedBox( 0, 0, 0, w, h, Color( self.LerpedButtonValueR, self.LerpedButtonValueG, self.LerpedButtonValueB, c.a ) )

                self.RecentHover = true
            else
                self.LerpedButtonValueR = Lerp( FrameTime() * 7, self.LerpedButtonValueR, glorifiedBanking.config.DERMA_ONCLICK_COLOUR.r )
                self.LerpedButtonValueG = Lerp( FrameTime() * 7, self.LerpedButtonValueG, glorifiedBanking.config.DERMA_ONCLICK_COLOUR.g )
                self.LerpedButtonValueB = Lerp( FrameTime() * 7, self.LerpedButtonValueB, glorifiedBanking.config.DERMA_ONCLICK_COLOUR.b )
                draw.RoundedBox( 0, 0, 0, w, h, Color( self.LerpedButtonValueR, self.LerpedButtonValueG, self.LerpedButtonValueB, c.a ) )

                self.RecentHover = true
            end

            draw.OutlinedBox( 0, 0, w, h, 2, Color( 55, 55, 55 ) )
        end
        TransferButton.DoClick = function()
            OpenTransferPanel()
        end
    end)
end

net.Receive( "glorifiedBanking_ToggleATMPanel", function()
    atmEntity = net.ReadEntity()
    OpenBankingPanel()
end )
