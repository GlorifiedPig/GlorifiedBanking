
--[[
    This file contains a lot of validation and authentication checks.
    Some of them may seem unnecessary, but it's never worth taking chances with an addon based purely around the server's economy.
    Extra validation checks are held on the actual player meta functions in the sv_glorifiedbanking_playermeta.lua file.
]]--

util.AddNetworkString( "GlorifiedBanking.WithdrawalRequested" )
util.AddNetworkString( "GlorifiedBanking.DepositRequested" )
util.AddNetworkString( "GlorifiedBanking.TransferRequested" )

util.AddNetworkString( "GlorifiedBanking.SendAnimation" )
util.AddNetworkString( "GlorifiedBanking.CardInserted" )
util.AddNetworkString( "GlorifiedBanking.Logout" )
util.AddNetworkString( "GlorifiedBanking.ChangeScreen" )
util.AddNetworkString( "GlorifiedBanking.ChangeScreen.SendLogs" )
util.AddNetworkString( "GlorifiedBanking.ForceLoad" )

util.AddNetworkString( "GlorifiedBanking.AdminPanel.OpenAdminPanel" )
util.AddNetworkString( "GlorifiedBanking.AdminPanel.SetPlayerBalance" )
util.AddNetworkString( "GlorifiedBanking.AdminPanel.SetLockdownStatus" )
util.AddNetworkString( "GlorifiedBanking.AdminPanel.PlayerListOpened" )
util.AddNetworkString( "GlorifiedBanking.AdminPanel.PlayerListOpened.SendInfo" )
util.AddNetworkString( "GlorifiedBanking.AdminPanel.RequestLogUpdate" )
util.AddNetworkString( "GlorifiedBanking.AdminPanel.RequestLogUpdate.SendInfo" )

util.AddNetworkString( "GlorifiedBanking.CardDesigner.UpdateDesign" )
util.AddNetworkString( "GlorifiedBanking.CardDesigner.SendDesignInfo" )
util.AddNetworkString( "GlorifiedBanking.CardDesigner.OpenCardDesigner" )

util.AddNetworkString( "GlorifiedBanking.CardReader.StartTransaction" )
util.AddNetworkString( "GlorifiedBanking.CardReader.BackToMenu" )
util.AddNetworkString( "GlorifiedBanking.CardReader.ConfirmTransaction" )
util.AddNetworkString( "GlorifiedBanking.CardReader.PayMerchant" )


local function PlayerAuthChecks( ply )
    return not ( not ply:IsValid()
    or ply:IsBot()
    or not ply:IsFullyAuthenticated()
    or not ply:IsConnected() )
end

local function ATMDistanceChecks( ply, atmEntity )
    local maxDistance = GlorifiedBanking.Config.MAXIMUM_DISTANCE_FROM_ATM
    return atmEntity:GetPos():DistToSqr( ply:GetPos() ) <= maxDistance * maxDistance
end

local function ValidationChecks( ply, balance, atmEntity )
    return not ( GlorifiedBanking.LockdownEnabled
    or not balance
    or balance == nil
    or balance < 0
    or not PlayerAuthChecks( ply )
    or not IsValid( atmEntity )
    or ( atmEntity:GetClass() != "glorifiedbanking_atm" and atmEntity:GetClass() != "glorifiedbanking_cardreader" )
    or atmEntity.ForcedLoad
    or not ATMDistanceChecks( ply, atmEntity ) )
end

net.Receive( "GlorifiedBanking.WithdrawalRequested", function( len, ply )
    local amount = net.ReadUInt( 32 )
    local atmEntity = net.ReadEntity()
    if not ValidationChecks( ply, amount, atmEntity ) then return end

    atmEntity:Withdraw( ply, amount )
end )

net.Receive( "GlorifiedBanking.DepositRequested", function( len, ply )
    local amount = net.ReadUInt( 32 )
    local atmEntity = net.ReadEntity()
    if not ValidationChecks( ply, amount, atmEntity ) then return end

    atmEntity:Deposit( ply, amount )
end )

net.Receive( "GlorifiedBanking.TransferRequested", function( len, ply )
    local amount = net.ReadUInt( 32 )
    local atmEntity = net.ReadEntity()
    if not ValidationChecks( ply, amount, atmEntity ) then return end
    local receiver = net.ReadEntity()
    if not PlayerAuthChecks( receiver ) then return end

    atmEntity:Transfer( ply, receiver, amount )
end )

net.Receive( "GlorifiedBanking.CardInserted", function( len, ply )
    local atmEntity = net.ReadEntity()
    if not GlorifiedBanking.LockdownEnabled
    and atmEntity:GetClass() == "glorifiedbanking_atm"
    and atmEntity:GetCurrentUser() == NULL
    and IsValid(ply:GetActiveWeapon())
    and ply:GetActiveWeapon():GetClass() == "glorifiedbanking_card"
    and PlayerAuthChecks( ply )
    and ATMDistanceChecks( ply, atmEntity ) then
        atmEntity:InsertCard( ply )
    end
end )

net.Receive( "GlorifiedBanking.Logout", function( len, ply )
    local atmEntity = net.ReadEntity()
    if atmEntity:GetClass() == "glorifiedbanking_atm"
    and atmEntity:GetCurrentUser() == ply then
        if atmEntity.ForcedLoad then
            atmEntity:EmitSound("GlorifiedBanking.Beep_Error")
            return
        end

        atmEntity:Logout()
        atmEntity:EmitSound("GlorifiedBanking.Beep_Normal")
    end
end )

net.Receive( "GlorifiedBanking.ChangeScreen", function( len, ply )
    local newScreen = net.ReadUInt( 4 )
    local atmEntity = net.ReadEntity()
    if atmEntity:GetClass() == "glorifiedbanking_atm"
    and atmEntity:GetCurrentUser() == ply
    and atmEntity.Screens[newScreen] then
        if atmEntity.ForcedLoad then
            atmEntity:EmitSound( "GlorifiedBanking.Beep_Error" )
            return
        end

        atmEntity:SetScreenID( newScreen )
        atmEntity:EmitSound( "GlorifiedBanking.Beep_Normal" )
        atmEntity.LastAction = CurTime()

        if newScreen == 7 then -- Is this screen the transaction history screen?
            GlorifiedBanking.SQL.Query( "SELECT * FROM `gb_logs` WHERE `SteamID` = '" .. ply:SteamID64() .. "' OR `ReceiverSteamID` = '" .. ply:SteamID64() .. "' ORDER BY `Date` DESC LIMIT 10", function( queryResult )
                timer.Simple( .5, function()
                    net.Start( "GlorifiedBanking.ChangeScreen.SendLogs" )
                    net.WriteEntity( atmEntity )
                    net.WriteTableAsString( queryResult )
                    net.Send( ply )
                end )
            end )
        end
    end
end )

net.Receive( "GlorifiedBanking.CardReader.StartTransaction", function( len, ply )
    local amount = net.ReadUInt( 32 )
    local readerEntity = net.ReadEntity()

    if not ValidationChecks( ply, amount, readerEntity ) then return end
    if readerEntity:GetClass() != "glorifiedbanking_cardreader" then return end
    if ply != readerEntity:GetMerchant() then return end

    if amount <= 0 then
        readerEntity:EmitSound("GlorifiedBanking.Beep_Reader_Error")
        GlorifiedBanking.Notify(ply, NOTIFY_ERROR, 5, GlorifiedBanking.i18n.GetPhrase("gbInvalidAmount"))
        return
    end

    readerEntity:EmitSound("GlorifiedBanking.Beep_Reader_Normal")

    readerEntity:SetTransactionAmount( amount )
    readerEntity:SetScreenID( 2 )
end )

net.Receive( "GlorifiedBanking.CardReader.BackToMenu", function( len, ply )
    local readerEntity = net.ReadEntity()

    if not ATMDistanceChecks( ply, readerEntity ) then return end
    if readerEntity:GetClass() != "glorifiedbanking_cardreader" then return end

    if readerEntity:GetScreenID() == 3 then
        if (ply != readerEntity.Client and ply != readerEntity:GetMerchant()) then
            readerEntity:EmitSound("GlorifiedBanking.Beep_Reader_Error")
            GlorifiedBanking.Notify(ply, NOTIFY_ERROR, 5, GlorifiedBanking.i18n.GetPhrase("gbCantCancelOthers"))
            return
        end
    else
        if ply != readerEntity:GetMerchant() then
            readerEntity:EmitSound("GlorifiedBanking.Beep_Reader_Error")
            GlorifiedBanking.Notify(ply, NOTIFY_ERROR, 5, GlorifiedBanking.i18n.GetPhrase("gbOnlyMerchantCancel"))
            return
        end
    end

    readerEntity:EmitSound("GlorifiedBanking.Beep_Reader_Normal")

    readerEntity:SetTransactionAmount( 0 )
    readerEntity:SetScreenID( 1 )
end )

net.Receive( "GlorifiedBanking.CardReader.ConfirmTransaction", function( len, ply )
    local readerEntity = net.ReadEntity()

    if not ATMDistanceChecks( ply, readerEntity ) then return end
    if readerEntity:GetClass() != "glorifiedbanking_cardreader" then return end
    if ply == readerEntity:GetMerchant() then
        readerEntity:EmitSound("GlorifiedBanking.Beep_Reader_Error")
        GlorifiedBanking.Notify(ply, NOTIFY_ERROR, 5, GlorifiedBanking.i18n.GetPhrase("gbCantPaySelf"))
        return
    end

    readerEntity:EmitSound("GlorifiedBanking.Beep_Reader_Normal")

    readerEntity:SetScreenID( 3 )
    readerEntity.Client = ply
end )

net.Receive( "GlorifiedBanking.CardReader.PayMerchant", function( len, ply )
    local readerEntity = net.ReadEntity()

    if not ATMDistanceChecks( ply, readerEntity ) then return end
    if readerEntity:GetClass() != "glorifiedbanking_cardreader" then return end
    if readerEntity:GetScreenID() != 3 then return end

    if ply:GetActiveWeapon():GetClass() != "glorifiedbanking_card" and not (GlorifiedBanking.Config.SUPPORT_GSMARTWATCH and ply:IsUsingSmartWatch()) then
        readerEntity:EmitSound("GlorifiedBanking.Beep_Reader_Error")
        GlorifiedBanking.Notify(ply, NOTIFY_ERROR, 5, GlorifiedBanking.i18n.GetPhrase("gbNeedCard"))
        return
    end

    if ply != readerEntity.Client then
        readerEntity:EmitSound("GlorifiedBanking.Beep_Reader_Error")
        GlorifiedBanking.Notify(ply, NOTIFY_ERROR, 5, GlorifiedBanking.i18n.GetPhrase("gbCantPayOther"))
        return
    end

    readerEntity:EmitSound("GlorifiedBanking.Beep_Reader_Normal")

    readerEntity:Transfer(ply)
end)

net.Receive( "GlorifiedBanking.AdminPanel.SetPlayerBalance", function( len, ply )
    if GlorifiedBanking.HasPermission( ply, "glorifiedbanking_setplayerbalance" ) then
        local plySteamID = net.ReadString()
        local newBalance = net.ReadUInt( 32 )
        GlorifiedBanking.SetPlayerBalanceBySteamID( plySteamID, newBalance )
    end
end )

net.Receive( "GlorifiedBanking.AdminPanel.SetLockdownStatus", function( len, ply )
    if GlorifiedBanking.HasPermission( ply, "glorifiedbanking_togglelockdown" ) then
        local newStatus = net.ReadBool()
        GlorifiedBanking.SetLockdownStatus( newStatus )
    end
end )

net.Receive( "GlorifiedBanking.AdminPanel.PlayerListOpened", function( len, ply )
    if GlorifiedBanking.HasPermission( ply, "glorifiedbanking_openadminpanel" ) then
        local playerList = {}
        for k, v in ipairs( player.GetAll() ) do
            playerList[v:UserID()] = GlorifiedBanking.GetPlayerBalance( v )
        end

        net.Start( "GlorifiedBanking.AdminPanel.PlayerListOpened.SendInfo" )
        net.WriteTableAsString( playerList )
        net.Send( ply )
    end
end )

-- Please forgive me lord, this will be rewritten.
net.Receive( "GlorifiedBanking.AdminPanel.RequestLogUpdate", function( len, ply )
    if GlorifiedBanking.HasPermission( ply, "glorifiedbanking_openadminpanel" ) then
        local pageNumber = GlorifiedBanking.SQL.EscapeString( tostring( net.ReadUInt( 16 ) ) )
        local itemLimit = GlorifiedBanking.SQL.EscapeString( tostring( net.ReadUInt( 6 ) ) )
        local filter = GlorifiedBanking.SQL.EscapeString( net.ReadString() )
        local filterSteamID = GlorifiedBanking.SQL.EscapeString( net.ReadString() )
        if filter != "All" and filter != "Withdrawal" and filter != "Deposit" and filter != "Transfer" then return end
        local query = "SELECT * FROM `gb_logs` "

        if filter != "All" then
            query = query .. "WHERE `Type` = '" .. filter .. "' AND "
        end

        if filterSteamID != "NONE" then
            query = query .. (filter == "All" and "WHERE" or "") .. "`SteamID` = '" .. filterSteamID .. "' AND "
        end

        if string.sub( query, -4 ) == "AND " then query = string.sub( query, 1, -5 ) end

        local offset = pageNumber == 1 and 0 or (pageNumber - 1) * itemLimit
        query = query .. "ORDER BY `Date` DESC LIMIT " .. itemLimit .. " OFFSET " .. offset

        GlorifiedBanking.SQL.Query( query, function( queryResult )
            GlorifiedBanking.SQL.Query( "SELECT COUNT(*) FROM gb_logs;", function( rowCount )
                net.Start( "GlorifiedBanking.AdminPanel.RequestLogUpdate.SendInfo" )
                net.WriteTableAsString( queryResult )
                net.WriteUInt(rowCount[1]["COUNT(*)"], 32)
                net.Send( ply )
            end )
        end )
    end
end )

net.Receive( "GlorifiedBanking.CardDesigner.UpdateDesign", function( len, ply )
    if GlorifiedBanking.HasPermission( ply, "glorifiedbanking_changecarddesign" ) then
        GlorifiedBanking.SetCardDesign(
            net.ReadString(), -- Imgur ID
            net.ReadFloat(), -- ID info
            net.ReadFloat(),
            net.ReadUInt( 2 ),
            net.ReadFloat(), -- Name info
            net.ReadFloat(),
            net.ReadUInt( 2 )
        )

        GlorifiedBanking.SendCardDesign( player.GetAll() )
    end
end)

concommand.Add( "glorifiedbanking_admin", function( ply )
    if not IsValid( ply ) then return end
    if GlorifiedBanking.HasPermission( ply, "glorifiedbanking_openadminpanel" ) then
        net.Start( "GlorifiedBanking.AdminPanel.OpenAdminPanel" )
        net.WriteBool( GlorifiedBanking.LockdownEnabled )
        net.WriteBool( GlorifiedBanking.HasPermission( ply, "glorifiedbanking_setplayerbalance" ) )
        net.Send( ply )
    end
end )

concommand.Add( "glorifiedbanking_carddesigner", function( ply )
    if not IsValid( ply ) then return end
    if GlorifiedBanking.HasPermission( ply, "glorifiedbanking_changecarddesign" ) then
        net.Start( "GlorifiedBanking.CardDesigner.OpenCardDesigner" )
        net.Send( ply )
    end
end )
