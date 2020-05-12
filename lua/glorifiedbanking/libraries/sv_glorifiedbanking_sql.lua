
GlorifiedBanking.SQL = {}
if GlorifiedBanking.Config.SQL_TYPE == "mysqloo" then
    require( "mysqloo" )

    if mysqloo then
        local connectionDetails = GlorifiedBanking.Config.SQL_DETAILS
        GlorifiedBanking.SQL.Database = mysqloo.connect( connectionDetails[ "host" ], connectionDetails[ "user" ], connectionDetails[ "pass" ], connectionDetails[ "database" ], connectionDetails[ "port" ] )
        function GlorifiedBanking.SQL.Database:onConnected() print( "[GlorifiedBanking] MySQL database connected, MySQLOO version " .. mysqloo.VERSION .. "." ) end
        function GlorifiedBanking.SQL.Database:onConnectionFailed( error ) print( "[GlorifiedBanking] MySQL database connection failed:\n" .. error ) end
        GlorifiedBanking.SQL.Database:connect()
    end
end

function GlorifiedBanking.SQL.EscapeString( string )
    if GlorifiedBanking.SQL.Database then
        return GlorifiedBanking.SQL.Database:escape( string )
    else
        return sql.SQLStr( string )
    end
end

function GlorifiedBanking.SQL.ThrowError( error )
    print( "[GlorifiedBanking] An error occurred while trying to perform an SQL query:\n" .. error .. "\n" )
    -- To-do: Make a table with all errors stored.
end

function GlorifiedBanking.SQL.Query( sqlQuery, successFunc )
    if GlorifiedBanking.Config.SQL_TYPE == "mysqloo" and mysqloo then
        local query = GlorifiedBanking.SQL.Database:query( sqlQuery )
        if successFunc then
            function query:onSuccess( queryData )
                successFunc( queryData )
            end
        end
        function query:onError( error ) GlorifiedBanking.SQL.ThrowError( error ) end
        query:start()
    else
        local queryData = sql.Query( sqlQuery )
        if successFunc then successFunc( queryData ) end
    end
end