
local bankBalance = 0
local affordableDeposit = false

net.Receive( "GlorifiedBanking_UpdateBankBalanceReceive", function()
    bankBalance = net.ReadInt( 32 )
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
	WithdrawFrame:SetTitle( "Withdraw Cash" )
	WithdrawFrame:SetDraggable( false )
	WithdrawFrame:ShowCloseButton( false )
	WithdrawFrame:Center()
	WithdrawFrame:MakePopup()
    WithdrawFrame.Paint = function( self, w, h )
	    draw.RoundedBox( 0, 0, 0, w, h, glorifiedbanking.config.DERMA_BACKGROUND_COLOR_SUBSECTION )
        draw.OutlinedBox( 0, 0, w, h, 2, Color( 0, 0, 0 ) )
    end

	surface.SetFont( "DermaDefault" )
	local disbandMessage = "How much would you like to withdraw?"
	local textW, textH = surface.GetTextSize( disbandMessage )
	local disbandLabel = vgui.Create( "DLabel", WithdrawFrame )
	disbandLabel:SetText( disbandMessage )
	disbandLabel:SetFont( "DermaDefault" )
	disbandLabel:SizeToContents()
	disbandLabel:SetPos( boxW / 2 - textW / 2, 30 )

    local withdrawText = vgui.Create( "DTextEntry", WithdrawFrame )
    withdrawText:SetText( "Amount" )
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
                    net.WriteInt( withdrawAmount, 32 )
                    net.SendToServer()
                    WithdrawFrame:Close()
                    Frame:Close()
                    notification.AddLegacy("You have successfully withdrawn $" .. string.Comma( withdrawText:GetText() ), NOTIFY_GENERIC, 5)
                    surface.PlaySound("buttons/button14.wav")
                elseif affordableWithdraw and withdrawAmount > glorifiedbanking.config.MAX_WITHDRAWAL then
                    WithdrawFrame:Close()
                    Frame:Close()
                    notification.AddLegacy("You cannot withdraw more than $" .. string.Comma( glorifiedbanking.config.MAX_WITHDRAWAL ) .. " at a time.", NOTIFY_ERROR, 5)
                    surface.PlaySound("buttons/button2.wav")
                elseif !affordableWithdraw then
                    WithdrawFrame:Close()
                    Frame:Close()
                    notification.AddLegacy("You cannot afford that!", NOTIFY_ERROR, 5)
                    surface.PlaySound("buttons/button2.wav")
                else
                    WithdrawFrame:Close()
                    Frame:Close()
                    notification.AddLegacy("An unknown error occured.", NOTIFY_ERROR, 5)
                    surface.PlaySound("buttons/button2.wav")
                end
            end )
        else
            WithdrawFrame:Close()
            Frame:Close()
            notification.AddLegacy("Please insert a valid number.", NOTIFY_ERROR, 5)
            surface.PlaySound("buttons/button2.wav")
        end
    end
    withdrawText.OnEnter = function()
        DoWithdraw()
    end

	local withdraw = vgui.Create( "DButton", WithdrawFrame )
    withdraw:SetTextColor( Color( 255, 255, 255 ) )
	withdraw:SetText("Withdraw")
	withdraw:SetSize( 80, 20 )
	withdraw:SetPos( boxW / 2 - 40 / 2 - 22 - 80 / 2, 75 )
	withdraw.DoClick = function()
        DoWithdraw()
	end
    withdraw.Paint = function( self, w, h )
	    draw.RoundedBox( 0, 0, 0, w, h, glorifiedbanking.config.DERMA_BUTTON_COLOUR )
        draw.OutlinedBox( 0, 0, w, h, 2, Color( 0, 0, 0 ) )
    end

    local cancelButton = vgui.Create( "DButton", WithdrawFrame )
    cancelButton:SetTextColor( Color( 255, 255, 255 ) )
	cancelButton:SetText("Cancel")
	cancelButton:SetSize( 80, 20 )
	cancelButton:SetPos( boxW / 2 - 40 / 2 - 22 + 80 / 2, 75 )
	cancelButton.DoClick = function()
        WithdrawFrame:Close()
    end
    cancelButton.Paint = function( self, w, h )
	    draw.RoundedBox( 0, 0, 0, w, h, glorifiedbanking.config.DERMA_BUTTON_COLOUR )
        draw.OutlinedBox( 0, 0, w, h, 2, Color( 0, 0, 0 ) )
    end
end

local function OpenDepositPanel()
    local ply = LocalPlayer()

    local boxW, boxH = 450, 115
	local DepositFrame = vgui.Create( "DFrame" )
	DepositFrame:SetSize( boxW, boxH )
	DepositFrame:SetTitle( "Deposit Cash" )
	DepositFrame:SetDraggable( false )
	DepositFrame:ShowCloseButton( false )
	DepositFrame:Center()
	DepositFrame:MakePopup()
    DepositFrame.Paint = function( self, w, h )
	    draw.RoundedBox( 0, 0, 0, w, h, glorifiedbanking.config.DERMA_BACKGROUND_COLOR_SUBSECTION )
        draw.OutlinedBox( 0, 0, w, h, 2, Color( 0, 0, 0 ) )
    end

	surface.SetFont( "DermaDefault" )
	local disbandMessage = "How much would you like to deposit?"
	local textW, textH = surface.GetTextSize( disbandMessage )
	local disbandLabel = vgui.Create( "DLabel", DepositFrame )
	disbandLabel:SetText( disbandMessage )
	disbandLabel:SetFont( "DermaDefault" )
	disbandLabel:SizeToContents()
	disbandLabel:SetPos( boxW / 2 - textW / 2, 30 )

    local depositText = vgui.Create( "DTextEntry", DepositFrame )
    depositText:SetText( "Amount" )
    depositText:SetSize( 100, 20 )
    depositText:SetPos( boxW / 2 - 100 / 2, 50 )
    local function DoDeposit()
        local depositAmount = tonumber( depositText:GetText() )
        if isnumber( depositAmount ) then
            depositAmount = math.abs( tonumber( depositText:GetText() ) )

            net.Start( "GlorifiedBanking_IsAffordableDeposit" )
            net.WriteInt( depositAmount, 32 )
            net.SendToServer()

            timer.Simple( ply:Ping() / 1000 + 0.1, function()
                if affordableDeposit and depositAmount <= glorifiedbanking.config.MAX_DEPOSIT then
                    net.Start( "GlorifiedBanking_UpdateDeposit" )
                    net.WriteInt( depositAmount, 32 )
                    net.SendToServer()
                    DepositFrame:Close()
                    Frame:Close()
                    notification.AddLegacy("You have successfully deposited $" .. string.Comma( depositText:GetText() ), NOTIFY_GENERIC, 5)
                    surface.PlaySound("buttons/button14.wav")
                elseif affordableDeposit and depositAmount > glorifiedbanking.config.MAX_DEPOSIT then
                    DepositFrame:Close()
                    Frame:Close()
                    notification.AddLegacy("You cannot deposit more than $" .. string.Comma( glorifiedbanking.config.MAX_DEPOSIT ) .. " at a time.", NOTIFY_ERROR, 5)
                    surface.PlaySound("buttons/button2.wav")
                elseif !affordableDeposit then
                    DepositFrame:Close()
                    Frame:Close()
                    notification.AddLegacy("You cannot afford that!", NOTIFY_ERROR, 5)
                    surface.PlaySound("buttons/button2.wav")
                else
                    DepositFrame:Close()
                    Frame:Close()
                    notification.AddLegacy("An unknown error occured.", NOTIFY_ERROR, 5)
                    surface.PlaySound("buttons/button2.wav")
                end
            end)
        else
            DepositFrame:Close()
            Frame:Close()
            notification.AddLegacy("Please insert a valid number.", NOTIFY_ERROR, 5)
            surface.PlaySound("buttons/button2.wav")
        end
    end
    depositText.OnEnter = function()
        DoDeposit()
    end

	local deposit = vgui.Create( "DButton", DepositFrame )
    deposit:SetTextColor( Color( 255, 255, 255 ) )
	deposit:SetText("Deposit")
	deposit:SetSize( 80, 20 )
	deposit:SetPos( boxW / 2 - 40 / 2 - 22 - 80 / 2, 75 )
	deposit.DoClick = function()
        DoDeposit()
	end
    deposit.Paint = function( self, w, h )
	    draw.RoundedBox( 0, 0, 0, w, h, glorifiedbanking.config.DERMA_BUTTON_COLOUR )
        draw.OutlinedBox( 0, 0, w, h, 2, Color( 0, 0, 0 ) )
    end

    local cancelButton = vgui.Create( "DButton", DepositFrame )
    cancelButton:SetTextColor( Color( 255, 255, 255 ) )
	cancelButton:SetText("Cancel")
	cancelButton:SetSize( 80, 20 )
	cancelButton:SetPos( boxW / 2 - 40 / 2 - 22 + 80 / 2, 75 )
	cancelButton.DoClick = function()
        DepositFrame:Close()
    end
    cancelButton.Paint = function( self, w, h )
	    draw.RoundedBox( 0, 0, 0, w, h, glorifiedbanking.config.DERMA_BUTTON_COLOUR )
        draw.OutlinedBox( 0, 0, w, h, 2, Color( 0, 0, 0 ) )
    end
end

local function OpenTransferPanel()
    local ply = LocalPlayer()

    local boxW, boxH = 450, 142
	local TransferFrame = vgui.Create( "DFrame" )
	TransferFrame:SetSize( boxW, boxH )
	TransferFrame:SetTitle( "Transfer Cash" )
	TransferFrame:SetDraggable( false )
	TransferFrame:ShowCloseButton( false )
	TransferFrame:Center()
	TransferFrame:MakePopup()
    TransferFrame.Paint = function( self, w, h )
	    draw.RoundedBox( 0, 0, 0, w, h, glorifiedbanking.config.DERMA_BACKGROUND_COLOR_SUBSECTION )
        draw.OutlinedBox( 0, 0, w, h, 2, Color( 0, 0, 0 ) )
    end

	surface.SetFont( "DermaDefault" )
	local disbandMessage = "How much would you like to transfer?"
	local textW, textH = surface.GetTextSize( disbandMessage )
	local disbandLabel = vgui.Create( "DLabel", TransferFrame )
	disbandLabel:SetText( disbandMessage )
	disbandLabel:SetFont( "DermaDefault" )
	disbandLabel:SizeToContents()
	disbandLabel:SetPos( boxW / 2 - textW / 2, 30 )

    local PlayerComboBox = vgui.Create( "DComboBox", TransferFrame )
    PlayerComboBox:SetSize( 115, 20 )
    PlayerComboBox:SetPos( boxW / 2 - 115 / 2, 75 )
    PlayerComboBox:SetValue( "Player List" )
    for k, v in pairs( player.GetAll() ) do
        if v == ply then continue end
		PlayerComboBox:AddChoice( v:Nick(), v:SteamID64() )
	end

	local selectedNick, selectedID = PlayerComboBox:GetSelected()

    PlayerComboBox.OnSelect = function( panel, index, value )
        selectedNick, selectedID = PlayerComboBox:GetSelected()
    end

    local transferText = vgui.Create( "DTextEntry", TransferFrame )
    transferText:SetText( "Amount" )
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
                Frame:Close()
                notification.AddLegacy("Please select a valid player.", NOTIFY_ERROR, 5)
                surface.PlaySound("buttons/button2.wav")
                return
            end

            timer.Simple( ply:Ping() / 1000 + 0.1, function()
                if affordableTransfer and transferAmount <= glorifiedbanking.config.MAX_TRANSFER then
                    net.Start( "GlorifiedBanking_UpdateTransfer" )
                    net.WriteInt( transferAmount, 32 )
                    net.WriteEntity( transferringPlayer )
                    net.SendToServer()
                    TransferFrame:Close()
                    Frame:Close()
                    notification.AddLegacy("You have successfully transferred $" .. string.Comma( tostring( transferAmount ) ) .. " to " .. transferringPlayer:Nick(), NOTIFY_GENERIC, 5)
                    surface.PlaySound("buttons/button14.wav")
                elseif affordableTransfer and transferAmount > glorifiedbanking.config.MAX_TRANSFER then
                    TransferFrame:Close()
                    Frame:Close()
                    notification.AddLegacy("You cannot transfer more than $" .. string.Comma( glorifiedbanking.config.MAX_TRANSFER ) .. " at a time.", NOTIFY_ERROR, 5)
                    surface.PlaySound("buttons/button2.wav")
                elseif !affordableTransfer then
                    TransferFrame:Close()
                    Frame:Close()
                    notification.AddLegacy("You cannot afford that!", NOTIFY_ERROR, 5)
                    surface.PlaySound("buttons/button2.wav")
                else
                    TransferFrame:Close()
                    Frame:Close()
                    notification.AddLegacy("An unknown error occured.", NOTIFY_ERROR, 5)
                    surface.PlaySound("buttons/button2.wav")
                end
            end )
        else
            TransferFrame:Close()
            Frame:Close()
            notification.AddLegacy("Please insert a valid number.", NOTIFY_ERROR, 5)
            surface.PlaySound("buttons/button2.wav")
        end
    end
    transferText.OnEnter = function()
        DoTransfer()
    end

	local transfer = vgui.Create( "DButton", TransferFrame )
    transfer:SetTextColor( Color( 255, 255, 255 ) )
	transfer:SetText("Transfer")
	transfer:SetSize( 80, 20 )
	transfer:SetPos( boxW / 2 - 40 / 2 - 22 - 80 / 2, 100 )
	transfer.DoClick = function()
        DoTransfer()
	end
    transfer.Paint = function( self, w, h )
	    draw.RoundedBox( 0, 0, 0, w, h, glorifiedbanking.config.DERMA_BUTTON_COLOUR )
        draw.OutlinedBox( 0, 0, w, h, 2, Color( 0, 0, 0 ) )
    end

    local cancelButton = vgui.Create( "DButton", TransferFrame )
    cancelButton:SetTextColor( Color( 255, 255, 255 ) )
	cancelButton:SetText("Cancel")
	cancelButton:SetSize( 80, 20 )
	cancelButton:SetPos( boxW / 2 - 40 / 2 - 22 + 80 / 2, 100 )
	cancelButton.DoClick = function()
        TransferFrame:Close()
    end
    cancelButton.Paint = function( self, w, h )
	    draw.RoundedBox( 0, 0, 0, w, h, glorifiedbanking.config.DERMA_BUTTON_COLOUR )
        draw.OutlinedBox( 0, 0, w, h, 2, Color( 0, 0, 0 ) )
    end
end

local function OpenBankingPanel()
    net.Start( "GlorifiedBanking_UpdateBankBalance" )
    net.SendToServer()

    local ply = LocalPlayer()

    Frame = vgui.Create( "DFrame" )
    Frame:SetTitle( "Automated Teller Machine (ATM)" )
    Frame:SetSize( 500, 220 )
    Frame:ShowCloseButton( false )
    Frame:Center()
    Frame:MakePopup()
    Frame.Init = function()
		self.startTime = SysTime()
	end
    Frame.Paint = function( self, w, h )
        Derma_DrawBackgroundBlur( self, self.startTime )
	    draw.RoundedBox( 0, 0, 0, w, h, glorifiedbanking.config.DERMA_BACKGROUND_COLOR )
        draw.OutlinedBox( 0, 0, w, h, 2, Color( 0, 0, 0 ) )
    end

    timer.Simple( ply:Ping() / 1000 + 0.1, function()
        Frame:ShowCloseButton( true )
        surface.SetFont( "DermaDefault" )
        local atmW, atmH = surface.GetTextSize( "Welcome to the Automated Teller Machine (ATM)!" )
        local balW, balH = surface.GetTextSize( "Current Balance: $" .. string.Comma( bankBalance ) )

        local ATMLabel = vgui.Create( "DLabel", Frame )
		ATMLabel:SetPos( 500 / 2 - atmW / 2, 35 )
		ATMLabel:SetText( "Welcome to the Automated Teller Machine (ATM)!" )
        ATMLabel:SizeToContents()

		local BalanceLabel = vgui.Create( "DLabel", Frame )
		BalanceLabel:SetPos( 500 / 2 - balW / 2, 50 )
		BalanceLabel:SetText( "Current Balance: $" .. string.Comma( bankBalance ) )
        BalanceLabel:SizeToContents()

        local WithdrawButton = vgui.Create( "DButton", Frame )
        WithdrawButton:SetText( "Withdraw" )
        WithdrawButton:SetTextColor( Color( 255, 255, 255 ) )
        WithdrawButton:SetPos( 25, 80 )
        WithdrawButton:SetSize( 200, 50 )
        WithdrawButton.Paint = function( self, w, h )
	      draw.RoundedBox( 0, 0, 0, w, h, glorifiedbanking.config.DERMA_BUTTON_COLOUR )
          draw.OutlinedBox( 0, 0, w, h, 2, Color( 0, 0, 0 ) )
        end
        WithdrawButton.DoClick = function()
          OpenWithdrawPanel()
        end

        local DepositButton = vgui.Create( "DButton", Frame )
        DepositButton:SetText( "Deposit" )
        DepositButton:SetTextColor( Color( 255, 255, 255 ) )
        DepositButton:SetPos( 275, 80 )
        DepositButton:SetSize( 200, 50 )
        DepositButton.Paint = function( self, w, h )
	      draw.RoundedBox( 0, 0, 0, w, h, glorifiedbanking.config.DERMA_BUTTON_COLOUR )
          draw.OutlinedBox( 0, 0, w, h, 2, Color( 0, 0, 0 ) )
        end
        DepositButton.DoClick = function()
          OpenDepositPanel()
        end


        local TransferButton = vgui.Create( "DButton", Frame )
        TransferButton:SetText( "Transfer" )
        TransferButton:SetTextColor( Color( 255, 255, 255 ) )
        TransferButton:SetPos( 25, 150 )
        TransferButton:SetSize( 450, 50 )
        TransferButton.Paint = function( self, w, h )
	      draw.RoundedBox( 0, 0, 0, w, h, glorifiedbanking.config.DERMA_BUTTON_COLOUR )
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