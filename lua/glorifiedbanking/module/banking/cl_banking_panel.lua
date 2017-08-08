
local bankBalance = 0
local affordableDeposit = false

net.Receive( "GlorifiedBanking_UpdateBankBalanceReceive", function()
    bankBalance = net.ReadInt( 32 )
end )

net.Receive( "GlorifiedBanking_IsAffordableDepositReceive", function()
    affordableDeposit = net.ReadBool()
end )

local function OpenWithdrawPanel()
    local boxW, boxH = 450, 115
	local WithdrawFrame = vgui.Create( "DFrame" )
	WithdrawFrame:SetSize( boxW, boxH )
	WithdrawFrame:SetTitle( "Withdrawal Box" )
	WithdrawFrame:SetDraggable( false )
	WithdrawFrame:ShowCloseButton( false )
	WithdrawFrame:Center()
	WithdrawFrame:MakePopup()
    WithdrawFrame.Paint = function( self, w, h )
	    draw.RoundedBox( 0, 0, 0, w, h, Color( 25, 25, 25, 225 ) )
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

	local withdraw = vgui.Create( "DButton", WithdrawFrame )
    withdraw:SetTextColor( Color( 255, 255, 255 ) )
	withdraw:SetText("Withdraw")
	withdraw:SetSize( 80, 20 )
	withdraw:SetPos( boxW / 2 - 40 / 2 - 22, 75 )
	withdraw.DoClick = function()
        local withdrawAmount = tonumber( withdrawText:GetText() )
        if isnumber( withdrawAmount ) then
            local affordableWithdraw = false

            if withdrawAmount <= bankBalance then
                affordableWithdraw = true
            else
                affordableWithdraw = false
            end

            timer.Simple(0.2, function()
                if affordableWithdraw and withdrawAmount <= 100000 then
                    net.Start( "GlorifiedBanking_UpdateWithdrawal" )
                    net.WriteInt( withdrawAmount, 32 )
                    net.SendToServer()
                    WithdrawFrame:Close()
                    Frame:Close()
                    notification.AddLegacy("You have successfully withdrawn $" .. string.Comma( withdrawText:GetText() ), NOTIFY_GENERIC, 5)
                    surface.PlaySound("buttons/button14.wav")
                elseif affordableWithdraw and withdrawAmount > 100000 then
                    WithdrawFrame:Close()
                    Frame:Close()
                    notification.AddLegacy("You cannot withdraw more than $100,000 at a time.", NOTIFY_ERROR, 5)
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
    withdraw.Paint = function( self, w, h )
	    draw.RoundedBox( 0, 0, 0, w, h, Color( 41, 128, 185, 250 ) )
        draw.OutlinedBox( 0, 0, w, h, 2, Color( 0, 0, 0 ) )
    end
end

local function OpenDepositPanel()
    local boxW, boxH = 450, 115
	local DepositFrame = vgui.Create( "DFrame" )
	DepositFrame:SetSize( boxW, boxH )
	DepositFrame:SetTitle( "Deposit Box" )
	DepositFrame:SetDraggable( false )
	DepositFrame:ShowCloseButton( false )
	DepositFrame:Center()
	DepositFrame:MakePopup()
    DepositFrame.Paint = function( self, w, h )
	    draw.RoundedBox( 0, 0, 0, w, h, Color( 25, 25, 25, 225 ) )
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

	local deposit = vgui.Create( "DButton", DepositFrame )
    deposit:SetTextColor( Color( 255, 255, 255 ) )
	deposit:SetText("Deposit")
	deposit:SetSize( 80, 20 )
	deposit:SetPos( boxW / 2 - 40 / 2 - 22, 75 )
	deposit.DoClick = function()
        local depositAmount = tonumber( depositText:GetText() )
        if isnumber( depositAmount ) then
            net.Start( "GlorifiedBanking_IsAffordableDeposit" )
            net.SendToServer()

            timer.Simple(0.2, function()
                if affordableDeposit and depositAmount <= 100000 then
                    net.Start( "GlorifiedBanking_UpdateDeposit" )
                    net.WriteInt( depositAmount, 32 )
                    net.SendToServer()
                    DepositFrame:Close()
                    Frame:Close()
                    notification.AddLegacy("You have successfully deposited $" .. string.Comma( depositText:GetText() ), NOTIFY_GENERIC, 5)
                    surface.PlaySound("buttons/button14.wav")
                elseif affordableDeposit and depositAmount > 100000 then
                    DepositFrame:Close()
                    Frame:Close()
                    notification.AddLegacy("You cannot deposit more than $100,000 at a time.", NOTIFY_ERROR, 5)
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
    deposit.Paint = function( self, w, h )
	    draw.RoundedBox( 0, 0, 0, w, h, Color( 41, 128, 185, 250 ) )
        draw.OutlinedBox( 0, 0, w, h, 2, Color( 0, 0, 0 ) )
    end
end

local function OpenTransferPanel()
    -- not finished yet
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
	    draw.RoundedBox( 0, 0, 0, w, h, Color( 0, 0, 0, 150 ) )
        draw.OutlinedBox( 0, 0, w, h, 2, Color( 0, 0, 0 ) )
    end

    timer.Simple( 0.5, function()
        Frame:ShowCloseButton( true )

        local DLabel = vgui.Create( "DLabel", Frame )
		DLabel:SetPos( 150, 25 )
		DLabel:SetSize(250, 25)
		DLabel:SetText( "Welcome to the Automated Teller Machine (ATM)!" )

		local DLabel = vgui.Create( "DLabel", Frame )
		DLabel:SetPos( 185, 30 )
		DLabel:SetSize(300, 45)
		DLabel:SetText( "Current Balance: $" .. string.Comma( bankBalance ) )

        local Button = vgui.Create( "DButton", Frame )
        Button:SetText( "Withdraw" )
        Button:SetTextColor( Color( 255, 255, 255 ) )
        Button:SetPos( 25, 80 )
        Button:SetSize( 200, 50 )
        Button.Paint = function( self, w, h )
	      draw.RoundedBox( 0, 0, 0, w, h, Color( 41, 128, 185, 250 ) )
          draw.OutlinedBox( 0, 0, w, h, 2, Color( 0, 0, 0 ) )
        end
        Button.DoClick = function()
          OpenWithdrawPanel()
        end

        local Button = vgui.Create( "DButton", Frame )
        Button:SetText( "Deposit" )
        Button:SetTextColor( Color( 255, 255, 255 ) )
        Button:SetPos( 275, 80 )
        Button:SetSize( 200, 50 )
        Button.Paint = function( self, w, h )
	      draw.RoundedBox( 0, 0, 0, w, h, Color( 41, 128, 185, 250 ) )
          draw.OutlinedBox( 0, 0, w, h, 2, Color( 0, 0, 0 ) )
        end
        Button.DoClick = function()
          OpenDepositPanel()
        end


        local Button = vgui.Create( "DButton", Frame )
        Button:SetText( "Transfer" )
        Button:SetTextColor( Color( 255, 255, 255 ) )
        Button:SetPos( 25, 150 )
        Button:SetSize( 450, 50 )
        Button.Paint = function( self, w, h )
	      draw.RoundedBox( 0, 0, 0, w, h, Color( 41, 128, 185, 250 ) )
          draw.OutlinedBox( 0, 0, w, h, 2, Color( 0, 0, 0 ) )
        end
        Button.DoClick = function()
          -- do transfer shit
        end
    end)
end

net.Receive( "GlorifiedBanking_ToggleATMPanel", function()
    OpenBankingPanel()
end )