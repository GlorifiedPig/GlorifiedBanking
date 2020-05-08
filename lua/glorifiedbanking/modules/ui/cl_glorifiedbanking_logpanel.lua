
function GlorifiedBanking.OpenLogPanel( logTbl )
    local logFrame = vgui.Create( "DFrame" )
    logFrame:SetSize( 640, 480 )
    logFrame:Center()
    logFrame:SetTitle( "GlorifiedBanking Logs" )
    logFrame:SetDraggable( false )
    logFrame:MakePopup()

    local logPropertySheet = vgui.Create( "DPropertySheet", logFrame )
    logPropertySheet:Dock( FILL )

    local logWithdrawalsSheet = vgui.Create( "DListView", logPropertySheet )
    logWithdrawalsSheet:Dock( FILL )
    logWithdrawalsSheet:AddColumn( "Date" )
    logWithdrawalsSheet:AddColumn( "SteamID" )
    logWithdrawalsSheet:AddColumn( "Withdraw Amount" )
    for k, v in pairs( logTbl.Withdrawals ) do
        logWithdrawalsSheet:AddLine( v["Date"], v["SteamID"], v["WithdrawAmount"] )
    end

    local logDepositsSheet = vgui.Create( "DListView", logPropertySheet )
    logDepositsSheet:Dock( FILL )
    logDepositsSheet:AddColumn( "Date" )
    logDepositsSheet:AddColumn( "SteamID" )
    logDepositsSheet:AddColumn( "Deposit Amount" )
    for k, v in pairs( logTbl.Deposits ) do
        logDepositsSheet:AddLine( v["Date"], v["SteamID"], v["DepositAmount"] )
    end

    local logTransfersSheet = vgui.Create( "DListView", logPropertySheet )
    logTransfersSheet:Dock( FILL )
    logTransfersSheet:AddColumn( "Date" )
    logTransfersSheet:AddColumn( "SteamID" )
    logTransfersSheet:AddColumn( "Receiver SteamID" )
    logTransfersSheet:AddColumn( "Transfer Amount" )
    for k, v in pairs( logTbl.Transfers ) do
        logTransfersSheet:AddLine( v["Date"], v["SteamID"], v["ReceiverSteamID"], v["TransferAmount"] )
    end

    logPropertySheet:AddSheet( "Withdrawals", logWithdrawalsSheet, "icon16/arrow_in.png" )
    logPropertySheet:AddSheet( "Deposits", logDepositsSheet, "icon16/arrow_out.png" )
    logPropertySheet:AddSheet( "Transfers", logTransfersSheet, "icon16/arrow_right.png" )
end

net.Receive( "GlorifiedBanking.PlayerOpenedLogs", function()
    local logTbl = {}
    logTbl.Withdrawals = util.JSONToTable( net.ReadLargeString() )
    logTbl.Deposits = util.JSONToTable( net.ReadLargeString() )
    logTbl.Transfers = util.JSONToTable( net.ReadLargeString() )
    PrintTable(logTbl.Withdrawals)
    GlorifiedBanking.OpenLogPanel( logTbl )
end )