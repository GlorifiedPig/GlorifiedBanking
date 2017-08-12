
local HasAdminAccess = false

local function requestAdminCommand()
    local ply = LocalPlayer()

    local canUseCommand, message = hook.Call( "glorifiedbanking.playerHasAdminPrivileges", nil, ply )

    if !canUseCommand then return print( message ) end

    CAMI.PlayerHasAccess( ply, glorifiedbanking.privilege.CAMI_CAN_USE_ADMIN_COMMANDS, function( hasAccess )
        if hasAccess then
            HasAdminAccess = true
        else
            HasAdminAccess = false
        end
    end )
end

requestAdminCommand()

if HasAdminAccess then
    local function AutoCompleteAddBankBalance( cmd, stringargs )
        stringargs = string.Trim( stringargs )
        stringargs = string.lower( stringargs )

        local tbl = {}

        for k, v in pairs( player.GetAll() ) do
            local nick = v:Nick()
            if string.find( string.lower( nick ), stringargs ) then
                nick = "\"" .. nick .. "\""
                nick = "glorifiedbanking_addbalance " .. nick

                table.insert( tbl, nick )
            end
        end

        return tbl
    end

    concommand.Add( "glorifiedbanking_addbalance", function( ply, cmd, args )
        if args == nil or args[1] == nil or args[2] == nil then
            print("Usage: glorifiedbanking_addbalance <player> <amount>")
            return
        end

        local nick = args[1]
        nick = string.lower( nick )

        local amount = tonumber( args[2] )

        for k, v in pairs( player.GetAll() ) do
            if string.find( string.lower( v:Nick() ), nick ) then
                net.Start( "GlorifiedBanking_Admin_AddBankBalance" )
                net.WriteUInt( amount, 32 )
                net.WriteEntity( v )
                net.SendToServer()
                
                return
            end
        end

        print( "Could not find player." )
    end, AutoCompleteAddBankBalance )

    local function AutoCompleteRemoveBankBalance( cmd, stringargs )
        stringargs = string.Trim( stringargs )
        stringargs = string.lower( stringargs )

        local tbl = {}

        for k, v in pairs( player.GetAll() ) do
            local nick = v:Nick()
            if string.find( string.lower( nick ), stringargs ) then
                nick = "\"" .. nick .. "\""
                nick = "glorifiedbanking_removebalance " .. nick

                table.insert( tbl, nick )
            end
        end

        return tbl
    end

    concommand.Add( "glorifiedbanking_removebalance", function( ply, cmd, args )
        if args == nil or args[1] == nil or args[2] == nil then
            print("Usage: glorifiedbanking_removebalance <player> <amount>")
            return
        end

        local nick = args[1]
        nick = string.lower( nick )

        local amount = tonumber( args[2] )

        for k, v in pairs( player.GetAll() ) do
            if string.find( string.lower( v:Nick() ), nick ) then
                net.Start( "GlorifiedBanking_Admin_RemoveBankBalance" )
                net.WriteUInt( amount, 32 )
                net.WriteEntity( v )
                net.SendToServer()
                
                return
            end
        end

        print( "Could not find player." )
    end, AutoCompleteRemoveBankBalance )

    local function AutoCompleteGetBankBalance( cmd, stringargs )
        stringargs = string.Trim( stringargs )
        stringargs = string.lower( stringargs )

        local tbl = {}

        for k, v in pairs( player.GetAll() ) do
            local nick = v:Nick()
            if string.find( string.lower( nick ), stringargs ) then
                nick = "\"" .. nick .. "\""
                nick = "glorifiedbanking_getbalance " .. nick

                table.insert( tbl, nick )
            end
        end

        return tbl
    end

    concommand.Add( "glorifiedbanking_getbalance", function( ply, cmd, args )
        if args == nil or args[1] == nil then
            print("Usage: glorifiedbanking_getbalance <player>")
            return
        end

        local nick = args[1]
        nick = string.lower( nick )

        for k, v in pairs( player.GetAll() ) do
            if string.find( string.lower( v:Nick() ), nick ) then
                net.Start( "GlorifiedBanking_Admin_GetBankBalance" )
                net.WriteEntity( v )
                net.SendToServer()

                timer.Simple( ply:Ping() / 1000 + 0.1, function()
                    net.Receive( "GlorifiedBanking_Admin_GetBankBalanceReceive", function()
                        local amount = net.ReadUInt( 32 )

                        print( v:Nick() .. "'s bank balance is $" .. DarkRP.formatMoney( amount ) .. "." )
                    end )
                end )
                
                return
            end
        end

        print( "Could not find player." )
    end, AutoCompleteGetBankBalance )
end