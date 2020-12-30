
--[[
    GlorifiedPersistentEnts - A library to make persistent entities painless for specific addons
    Read more @ https://github.com/GlorifiedPig/gpe
]]--

local gpeVersion = 1.4

if not GlorifiedPersistentEnts or not gpeVersion or not GlorifiedPersistentEnts.Version or GlorifiedPersistentEnts.Version < gpeVersion then
    GlorifiedPersistentEnts = {
        Version = giVersion,
        EntClasses = {},
        ShutdownCalled = false
    }

    sql.Query( "CREATE TABLE IF NOT EXISTS `gpe` ( `Class` VARCHAR(48) NOT NULL , `Map` VARCHAR(64) NOT NULL , `PosInfo` JSON NOT NULL, `NetworkVars` JSON )" )

    function GlorifiedPersistentEnts.SaveEntityData( ent )
        if not GlorifiedPersistentEnts.EntClasses[ent:GetClass()] then return end

        local entData = {}
        entData.Class = ent:GetClass()
        entData.Map = game.GetMap()
        entData.PosInfo = util.TableToJSON( {
            Pos = ent:GetPos(),
            Angles = ent:GetAngles()
        } )
        entData.NetworkVars = util.TableToJSON( ent:GetNetworkVars() )

        if ent.GPE_EntID != nil then
            sql.Query( "UPDATE `gpe` SET `PosInfo` = '" .. entData.PosInfo .. "', `NetworkVars` = '" .. entData.NetworkVars .. "' WHERE `RowID` = " .. ent.GPE_EntID )
        else
            sql.Query( "INSERT INTO `gpe` ( `Class`, `Map`, `PosInfo`, `NetworkVars` ) VALUES ( '" .. entData.Class .. "', '" .. entData.Map .. "', '" .. entData.PosInfo .. "', '" .. entData.NetworkVars .. "' )" )
            local lastRowID = sql.Query( "SELECT last_insert_rowid() AS last_insert" )[1].last_insert
            ent.GPE_EntID = lastRowID
        end
    end

    function GlorifiedPersistentEnts.RemoveEntityFromDB( ent )
        if not GlorifiedPersistentEnts.EntClasses[ent:GetClass()] then return end
        if ent.GPE_EntID != nil then
            print( "[GlorifiedPersistentEnts] Deleted Entity ID " .. ent.GPE_EntID .. " from GPE table" )
            sql.Query( "DELETE FROM `gpe` WHERE `RowID` = " .. ent.GPE_EntID )
            SafeRemoveEntity( ent )
        end
    end

    function GlorifiedPersistentEnts.ClearDataByClass( class )
        print( "[GlorifiedPersistentEnts] Cleared GPE table" )
        sql.Query( "DELETE FROM `gpe` WHERE `Class` = '" .. class .. "'")
        for k, v in pairs( ents.FindByClass( class ) ) do
            SafeRemoveEntity( v )
        end
    end

    function GlorifiedPersistentEnts.LoadEntities()
        local queryResult = sql.Query( "SELECT * FROM `gpe`" )
        if queryResult == nil or not istable( queryResult ) then return end
        for k, v in pairs( queryResult ) do
            if v["Map"] != game.GetMap() then continue end
            local gpeEntityInfo = util.JSONToTable( v["PosInfo"] )
            local gpeEntity = ents.Create( v["Class"] )
            gpeEntity:SetPos( gpeEntityInfo.Pos )
            gpeEntity:SetAngles( gpeEntityInfo.Angles )
            gpeEntity:Spawn()
            if gpeEntity:GetPhysicsObject():IsValid() then
                gpeEntity:GetPhysicsObject():EnableMotion( false )
            end
            gpeEntity.GPE_EntID = k

            local networkVars = util.JSONToTable( v["NetworkVars"] )
            for k2, v2 in pairs( networkVars ) do
                if not isfunction( gpeEntity["Set" .. k2] ) then continue end
                gpeEntity["Set" .. k2]( gpeEntity, v2 )
            end
        end
    end

    function GlorifiedPersistentEnts.AddEntClassToTable( entClass )
        GlorifiedPersistentEnts.EntClasses[entClass] = true
    end

    hook.Add( "OnPhysgunFreeze", "GPE.OnPhysgunFreeze", function( wep, physObj, ent, ply )
        if GlorifiedPersistentEnts.EntClasses[ent:GetClass()] then
            GlorifiedPersistentEnts.SaveEntityData( ent )
        end
    end )

    hook.Add( "PhysgunDrop", "GPE.PhysgunDrop", function( ply, ent )
        if GlorifiedPersistentEnts.EntClasses[ent:GetClass()] then
            GlorifiedPersistentEnts.SaveEntityData( ent )
        end
    end )

    hook.Add( "PlayerSpawnedSENT", "GPE.PlayerSpawnedSENT", function( ply, ent )
        if GlorifiedPersistentEnts.EntClasses[ent:GetClass()] then
            GlorifiedPersistentEnts.SaveEntityData( ent )
        end
    end )

    hook.Add( "InitPostEntity", "GPE.InitPostEntity", GlorifiedPersistentEnts.LoadEntities )
    hook.Add( "PostCleanupMap", "GPE.PostCleanupMap", GlorifiedPersistentEnts.LoadEntities )

    concommand.Add( "gpe_removeents", function( ply )
        if ply == NULL or ply:IsSuperAdmin() then
            print( "[GlorifiedPersistentEnts] Cleared GPE table." )
            sql.Query( "DELETE FROM `gpe`")
            for k, v in pairs( GlorifiedPersistentEnts.EntClasses ) do
                for k2, v2 in pairs( ents.FindByClass( k ) ) do
                    SafeRemoveEntity( v2 )
                end
            end
        end
    end )

    concommand.Add( "gpe_removeent", function( ply )
        if IsValid( ply ) and ply:IsSuperAdmin() then
            local lookingAtEnt = ply:GetEyeTrace().Entity
            if IsValid( lookingAtEnt ) and GlorifiedPersistentEnts.EntClasses[lookingAtEnt:GetClass()] then
                GlorifiedPersistentEnts.RemoveEntityFromDB( lookingAtEnt )
            end
        end
    end )

    concommand.Add( "gpe_saveents", function( ply )
        if ply == NULL or ply:IsSuperAdmin() then
            print( "[GlorifiedPersistentEnts] Saved all GPE entities." )
            for k, v in pairs( GlorifiedPersistentEnts.EntClasses ) do
                for k2, v2 in pairs( ents.FindByClass( k ) ) do
                    GlorifiedPersistentEnts.SaveEntityData( v2 )
                end
            end
        end
    end )

    hook.Add( "ShutDown", "GlorifiedPersistentEnts.ServerShutdown", function()
        GlorifiedPersistentEnts.ShutdownCalled = true
    end )

    hook.Add( "EntityRemoved", "GlorifiedPersistentEnts.EntityRemoved", function( ent )
        if GlorifiedPersistentEnts.ShutdownCalled then return end
        if IsValid( ent ) and GlorifiedPersistentEnts.EntClasses[ent:GetClass()] then
            GlorifiedPersistentEnts.RemoveEntityFromDB( ent )
        end
    end )
end

GlorifiedPersistentEnts.AddEntClassToTable( "glorifiedbanking_atm" )