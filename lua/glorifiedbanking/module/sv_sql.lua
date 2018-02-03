if !glorifiedBanking.config.MYSQL_ENABLE then return end

local MySQLOO = require("mysqloo")

GBANKINGDB = mysqloo.connect( glorifiedBanking.config.MYSQL_DATABASE_HOST, glorifiedBanking.config.MYSQL_DATABASE_USERNAME, glorifiedBanking.config.MYSQL_DATABASE_PASSWORD, glorifiedBanking.config.MYSQL_DATABASE_NAME, glorifiedBanking.config.MYSQL_DATABASE_PORT )

function ConnectGBankingDB()
    print( "[GlorifiedBanking] Connecting to SQL..." )

    GBANKINGDB.onConnected = function()
        print( "[GlorifiedBanking] Successfully connected to SQL database." )
    end

    GBANKINGDB.onConnectionFailed = function()
        print( "[GlorifiedBanking] Connection to database failed." )
    end

    GBANKINGDB:connect()
end

ConnectGBankingDB()

local function ValidateGBankingDB()
    if( GBANKINGDB:status() != mysqloo.DATABASE_CONNECTED ) then
        ConnectGBankingDB()
    end
end

timer.Create( "VALIDATE_GBANKING_DB", 10, 0, ValidateGBankingDB )

function AddPlayerGBD( id )
    local query = GBANKINGDB:query( "INSERT INTO users VALUES('', '" .. id .. "');" )

    query.onSuccess = function()
        print( "[GlorifiedBanking] New player added to SQL database." )
    end
    query.onError = function()
        print( "[GlorifiedBanking] Error adding new player to SQL database!" )
    end

    query:start()
end

hook.Add( "PlayerInitialSpawn", "GBanking_DB_PlayerInitialSpawn", function( ply )
    AddPlayer( ply:SteamID() )
end )