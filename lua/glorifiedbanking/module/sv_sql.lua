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