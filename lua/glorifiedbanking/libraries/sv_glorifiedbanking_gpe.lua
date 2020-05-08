
if !SERVER then return end

local GlorifiedPersistentEnts = {
    TableName = "GlorifiedBanking",
    Identifier = "GlorifiedBanking", -- NO SPACES!
    EntClasses = {
        "glorifiedbanking_atm"
    }
}

sql.Query( "CREATE TABLE IF NOT EXISTS `" .. GlorifiedPersistentEnts.TableName .. "` ( `Class` VARCHAR(48) NOT NULL , `Map` VARCHAR(64) NOT NULL , `PosInfo` JSON NOT NULL )" )

function GlorifiedPersistentEnts.SaveEntityInfo( ent )
    if table.HasValue( GlorifiedPersistentEnts.EntClasses, ent:GetClass() ) == false then return end
    local posInfoJSON = {
        Pos = ent:GetPos(),
        Angles = ent:GetAngles()
    }
    posInfoJSON = util.TableToJSON( posInfoJSON )
    if ent.EntID != nil then
        sql.Query( "UPDATE `" .. GlorifiedPersistentEnts.TableName .. "` SET `PosInfo` = '" .. posInfoJSON .. "' WHERE `RowID` = " .. ent.EntID )
    else
        sql.Query( "INSERT INTO `" .. GlorifiedPersistentEnts.TableName .. "` (`Class`, `Map`, `PosInfo`) VALUES ('" .. ent:GetClass() .. "', '" .. game.GetMap() .. "', '" .. posInfoJSON .. "')" )
        local lastRowID = sql.Query( "SELECT last_insert_rowid() AS last_insert" )[1].last_insert
        ent.EntID = lastRowID
    end
end

function GlorifiedPersistentEnts.RemoveEntityFromDB( ent )
    if table.HasValue( GlorifiedPersistentEnts.EntClasses, ent:GetClass() ) == false then return end
    if ent.EntID != nil then
        sql.Query( "DELETE FROM `" .. GlorifiedPersistentEnts.TableName .. "` WHERE `RowID` = " .. ent.EntID )
    end
end

function GlorifiedPersistentEnts.LoadEntities()
    local queryResults = sql.Query( "SELECT * FROM `" .. GlorifiedPersistentEnts.TableName .. "`" )
    if queryResults == nil || istable( queryResults ) == false then return end
    for k, v in pairs( queryResults ) do
        if v["Map"] != game.GetMap() then continue end
        local gpeEntityInfo = util.JSONToTable( v["PosInfo"] )
        local gpeEntity = ents.Create( v["Class"] )
        gpeEntity:SetPos( gpeEntityInfo.Pos )
        gpeEntity:SetAngles( gpeEntityInfo.Angles )
        gpeEntity:Spawn()
        if gpeEntity:GetPhysicsObject():IsValid() then
            gpeEntity:GetPhysicsObject():EnableMotion( false )
        end
        gpeEntity.EntID = k
    end
end

hook.Add( "OnPhysgunFreeze", GlorifiedPersistentEnts.Identifier .. ".GPE.OnPhysgunFreeze", function( wep, physObj, ent, ply )
    if table.HasValue( GlorifiedPersistentEnts.EntClasses, ent:GetClass() ) then
        GlorifiedPersistentEnts.SaveEntityInfo( ent )
    end
end )

hook.Add( "PhysgunDrop", GlorifiedPersistentEnts.Identifier .. ".GPE.PhysgunDrop", function( ply, ent )
    if table.HasValue( GlorifiedPersistentEnts.EntClasses, ent:GetClass() ) then
        GlorifiedPersistentEnts.SaveEntityInfo( ent )
    end
end )

hook.Add( "OnEntityCreated", GlorifiedPersistentEnts.Identifier .. ".GPE.OnEntityCreated", function( ent )
    if table.HasValue( GlorifiedPersistentEnts.EntClasses, ent:GetClass() ) then
        timer.Simple( 0, function() GlorifiedPersistentEnts.SaveEntityInfo( ent ) end )
    end
end )

hook.Add( "InitPostEntity", GlorifiedPersistentEnts.Identifier .. ".GPE.InitPostEntity", GlorifiedPersistentEnts.LoadEntities )

concommand.Add( GlorifiedPersistentEnts.Identifier .. "removeents", function( ply )
    if ply == nil || ply:IsSuperAdmin() then
        print( "[GlorifiedPersistentEnts] Cleared table `" .. GlorifiedPersistentEnts.TableName .. "`" )
        sql.Query( "DELETE FROM `" .. GlorifiedPersistentEnts.TableName .. "`")
        for k, v in pairs( GlorifiedPersistentEnts.EntClasses ) do
            for k2, v2 in pairs( ents.FindByClass( v ) ) do
                SafeRemoveEntity( v2 )
            end
        end
    end
end )

concommand.Add( GlorifiedPersistentEnts.Identifier .. "removeent", function( ply )
    if ply == nil || ply:IsSuperAdmin() then
        local lookingAtEnt = ply:GetEyeTrace().Entity
        if lookingAtEnt:IsValid() && table.HasValue( GlorifiedPersistentEnts.EntClasses, lookingAtEnt:GetClass() ) then
            print( "[GlorifiedPersistentEnts] Deleted Entity ID " .. lookingAtEnt.EntID .. " from table `" .. GlorifiedPersistentEnts.TableName .. "`" )
            sql.Query( "DELETE FROM `" .. GlorifiedPersistentEnts.TableName .. "` WHERE `RowID` = " .. lookingAtEnt.EntID )
            SafeRemoveEntity( lookingAtEnt )
        end
    end
end )