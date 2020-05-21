
if SERVER then
    --[[local function chunkstring( str, number )
        local output = {}
        local strsize = string.len( str )
        local chunksTaken = 0
        local chunksToTake = math.ceil( strsize / number )
        for i = 1, chunksToTake do
            if chunksTaken == chunksToTake - 1 then
                table.insert( output, string.sub( str, chunksTaken * number ) )
            else
                table.insert( output, string.sub( str, chunksTaken * number, i * number ) )
            end
            chunksTaken = chunksTaken + 1
        end
        return output
    end

    function net.WriteLargeString( largeString )
        local chunksToSend = math.ceil( string.len( largeString ) / 2000 )
        local chunksTbl = chunkstring( largeString, 2000 )
        net.WriteUInt( chunksToSend, 8 ) -- send how many chunks we are supposed to be receiving for an appropriate clientsided for loop {{ user_id sha256 key }}
        for i = 1, chunksToSend do
            net.WriteData( util.Compress( chunksTbl[i] ), 16008 ) -- 2000 max chars * 8 + 8 for bytecount
        end
    end]]--

    function net.WriteLargeString( largeString )
        local byteCount = ( string.len( largeString ) * 8 ) + 8
        net.WriteUInt( byteCount, 16 )
        net.WriteData( util.Compress( largeString ), byteCount )
    end
else
    --[[function net.ReadLargeString()
        local largeString = ""
        local chunksToReceive = net.ReadUInt( 8 )
        for i = 1, chunksToReceive do
            largeString = largeString .. util.Decompress( net.ReadData( 16008 ) )
        end
        return largeString
    end]]--

    function net.ReadLargeString()
        local byteCount = net.ReadUInt( 16 )
        return util.Decompress( net.ReadData( byteCount ) )
    end
end