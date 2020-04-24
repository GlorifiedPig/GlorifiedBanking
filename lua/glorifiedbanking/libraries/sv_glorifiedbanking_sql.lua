
if GlorifiedBanking.Config.SQL_TYPE == "mysqloo" then
    require( "mysqloo" )

    if mysqloo then
        local connectionDetails = GlorifiedBanking.Config.SQL_DETAILS
        GlorifiedBanking.SQLDatabase = mysqloo.connect( connectionDetails[ "host" ], connectionDetails[ "user" ], connectionDetails[ "pass" ], connectionDetails[ "database" ], connectionDetails[ "port" ] )
        function GlorifiedBanking.SQLDatabase:onConnected() print( "[GlorifiedBanking] MySQL database connected, MySQLOO version " .. mysqloo.VERSION .. "." ) end
        function GlorifiedBanking.SQLDatabase:onConnectionFailed( error ) print( "[GlorifiedBanking] MySQL database connection failed:\n" .. error ) end
        GlorifiedBanking.SQLDatabase:connect()
    end
end

function GlorifiedBanking.SQLThrowError( error )
    print( "[GlorifiedBanking] An error occurred while trying to perform an SQL query:\n" .. error .. "\n" )
    -- To-do: Make a table with all errors stored.
end

function GlorifiedBanking.SQLQuery( sqlQuery, successFunc )
    if GlorifiedBanking.Config.SQL_TYPE == "mysqloo" and mysqloo then
        local query = GlorifiedBanking.SQLDatabase:query( sqlQuery )
        if successFunc then
            function query:onSuccess( returnedQuery, data )
                successFunc( data )
            end
        end
        function query:onError( error ) GlorifiedBanking.SQLThrowError( error ) end
        query:start()
    else
        local queryData = sql.Query( sqlQuery )
        if successFunc then successFunc( queryData ) end
    end
end

GlorifiedBanking.SQLQuery( "CREATE TABLE IF NOT EXISTS `gb_players`( `SteamID` VARCHAR(17) NOT NULL, `Balance` BIGINT(64) NOT NULL, PRIMARY KEY( `SteamID` ) )" )