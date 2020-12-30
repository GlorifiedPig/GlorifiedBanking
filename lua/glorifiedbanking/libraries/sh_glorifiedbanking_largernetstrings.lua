
if not net.WriteLargeString then
    function net.WriteLargeString( largeString )
        local compressedString = util.Compress( largeString )
        local byteCount = string.len( compressedString )
        net.WriteUInt( byteCount, 16 )
        net.WriteData( compressedString, byteCount )
    end
end

if not net.WriteTableAsString then
    function net.WriteTableAsString( tbl )
        net.WriteLargeString( util.TableToJSON( tbl or {} ) )
    end
end

if not net.ReadLargeString then
    function net.ReadLargeString()
        local byteCount = net.ReadUInt( 16 )
        return util.Decompress( net.ReadData( byteCount ) )
    end
end

if not net.ReadTableAsString then
    function net.ReadTableAsString()
        return util.JSONToTable( net.ReadLargeString() )
    end
end