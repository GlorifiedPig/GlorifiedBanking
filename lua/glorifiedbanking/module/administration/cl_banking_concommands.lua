
local HasAdminAccess = false

local function requestAdminCommand()
    local player = LocalPlayer()

    local canRun, message = hook.Call( "glorifiedBanking.playerCanRunCommand", nil, player, command )

    if not canRun then
        if message then
            print( glorifiedBanking.IDENTIFIER .. " | you cannot execute the command " .. command )
        end
    end

    CAMI.PlayerHasAccess( player, glorifiedBanking.privilege.CAMI_CAN_USE_ADMIN_COMMANDS, function( hasAccess )
        HasAdminAccess = hasAccess
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
                nick = "glorifiedBanking_addbalance " .. nick

                table.insert( tbl, nick )
            end
        end

        return tbl
    end

    concommand.Add( "glorifiedBanking_addbalance", function( ply, cmd, args )
        if args == nil or args[1] == nil or args[2] == nil then
            print("Usage: glorifiedBanking_addbalance <player> <amount>")
            return
        end

        local nick = args[1]
        nick = string.lower( nick )

        local amount = tonumber( args[2] )

        for k, v in pairs( player.GetAll() ) do
            if string.find( string.lower( v:Nick() ), nick ) then
                net.Start( "glorifiedBanking_Admin_AddBankBalance" )
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
                nick = "glorifiedBanking_removebalance " .. nick

                table.insert( tbl, nick )
            end
        end

        return tbl
    end

    concommand.Add( "glorifiedBanking_removebalance", function( ply, cmd, args )
        if args == nil or args[1] == nil or args[2] == nil then
            print("Usage: glorifiedBanking_removebalance <player> <amount>")
            return
        end

        local nick = args[1]
        nick = string.lower( nick )

        local amount = tonumber( args[2] )

        for k, v in pairs( player.GetAll() ) do
            if string.find( string.lower( v:Nick() ), nick ) then
                net.Start( "glorifiedBanking_Admin_RemoveBankBalance" )
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
                nick = "glorifiedBanking_getbalance " .. nick

                table.insert( tbl, nick )
            end
        end

        return tbl
    end

    concommand.Add( "glorifiedBanking_getbalance", function( ply, cmd, args )
        if args == nil or args[1] == nil then
            print("Usage: glorifiedBanking_getbalance <player>")
            return
        end

        local nick = args[1]
        nick = string.lower( nick )

        for k, v in pairs( player.GetAll() ) do
            if string.find( string.lower( v:Nick() ), nick ) then
                net.Start( "glorifiedBanking_Admin_GetBankBalance" )
                net.WriteEntity( v )
                net.SendToServer()

                timer.Simple( ply:Ping() / 1000 + 0.1, function()
                    net.Receive( "glorifiedBanking_Admin_GetBankBalanceReceive", function()
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
