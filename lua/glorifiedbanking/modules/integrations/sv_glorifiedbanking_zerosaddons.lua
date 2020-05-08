
if not GlorifiedBanking.Config.SUPPORT_ZEROS_ADDONS then return end

if zwf and zwf.f and zwf.f.GiveMoney then
    local oldzwffunc = zwf.f.GiveMoney
    function zwf.f.GiveMoney( ply, money )
        if money >= 0 then
            GlorifiedBanking.AddPlayerBalance( ply, money )
        else
            oldzwffunc( ply, money )
        end
    end
end

if zrmine and zrmine.f and zrmine.f.GiveMoney then
    local oldzrminefunc = zrmine.f.GiveMoney
    function zrmine.f.GiveMoney( ply, money )
        if money >= 0 then
            GlorifiedBanking.AddPlayerBalance( ply, money )
        else
            oldzrminefunc( ply, money )
        end
    end
end

if ztm and ztm.f and ztm.f.GiveMoney then
    local oldztmfunc = ztm.f.GiveMoney
    function ztm.f.GiveMoney( ply, money )
        if money >= 0 then
            GlorifiedBanking.AddPlayerBalance( ply, money )
        else
            oldztmfunc( ply, money )
        end
    end
end