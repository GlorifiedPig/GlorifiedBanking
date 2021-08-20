
GlorifiedBanking = GlorifiedBanking or {
    Config = {},
    Version = "3.2.2"
}

print( "[GlorifiedBanking] This server is running version " .. GlorifiedBanking.Version .. "." )

--[[
    GlorifiedInclude - A library for including files & folders with ease.
    © 2020 GlorifiedInclude Developers

    Please read usage guide @ https://github.com/GlorifiedPig/glorifiedinclude/blob/master/README.md

    Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
    The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
]]--

local giVersion = 1.4

if not GlorifiedInclude or GlorifiedInclude.Version < giVersion then
    GlorifiedInclude = {
        Version = giVersion,
        Realm = {
            Server = 0,
            Client = 1,
            Shared = 2
        }
    }

    local isAddon = debug.getinfo( 1, "S" ).short_src[1] == "a"
    local include = include
    local AddCSLuaFile = AddCSLuaFile
    local SERVER = SERVER

    local GlorifiedInclude_Realm = GlorifiedInclude.Realm

    local includedFiles = {}

    function GlorifiedInclude.IncludeFile( fileName, realm, forceInclude, calledFromFolder, printName )
        if isAddon == false and not calledFromFolder then fileName = GM.FolderName .. "/gamemode/" .. fileName end
        if not forceInclude and includedFiles[fileName] then return end
        includedFiles[fileName] = true

        if realm == GlorifiedInclude_Realm.Shared or fileName:find( "sh_" ) then
            if printName then
                print( printName .. " > Including SH file '" .. fileName .. "'" )
            end
            if SERVER then AddCSLuaFile( fileName ) end
            include( fileName )
        elseif realm == GlorifiedInclude_Realm.Server or ( SERVER and fileName:find( "sv_" ) ) then
            if printName then
                print( printName .. " > Including SV file '" .. fileName .. "'" )
            end
            include( fileName )
        elseif realm == GlorifiedInclude_Realm.Client or fileName:find( "cl_" ) then
            if printName then
                print( printName .. " > Including CL file '" .. fileName .. "'" )
            end
            if SERVER then AddCSLuaFile( fileName )
            else include( fileName ) end
        end
    end

    function GlorifiedInclude.IncludeFolder( folderName, ignoreFiles, ignoreFolders, forceInclude, printName )
        if not isAddon then folderName = GM.FolderName .. "/gamemode/" .. folderName end

        if string.Right( folderName, 1 ) ~= "/" then folderName = folderName .. "/" end

        local filesInFolder, foldersInFolder = file.Find( folderName .. "*", "LUA" )

        if ignoreFiles ~= true then
            for _, v in ipairs( filesInFolder ) do
                GlorifiedInclude.IncludeFile( folderName .. v, nil, forceInclude, true, printName )
            end
        end

        if ignoreFolders ~= true then
            for _, v in ipairs( foldersInFolder ) do
                GlorifiedInclude.IncludeFolder( folderName .. v .. "/", ignoreFiles, ignoreFolders, forceInclude, printName )
            end
        end
    end
end

--[[
    -- Common practice would be to put all your includes here, for example:
        GlorifiedInclude.IncludeFolder( "modules/" )
        GlorifiedInclude.IncludeFile( "sh_config.lua" )
    -- Remember that files load in the order you include them in.
]]--

local function gbIncludeFile( fileName ) GlorifiedInclude.IncludeFile( fileName, nil, nil, nil, "GlorifiedBanking" ) end
local function gbIncludeFolder( folderName ) GlorifiedInclude.IncludeFolder( folderName, nil, nil, nil, "GlorifiedBanking" ) end
gbIncludeFile( "glorifiedbanking/sh_glorifiedbanking_compatibility.lua" )
local function IncludeGBFiles()
    gbIncludeFile( "glorifiedbanking/sv_glorifiedbanking_config.lua" )
    gbIncludeFile( "glorifiedbanking/sh_glorifiedbanking_config.lua")
    gbIncludeFolder( "glorifiedbanking/libraries/" )
    gbIncludeFolder( "glorifiedbanking/localization/" )
    gbIncludeFile( "glorifiedbanking/themes/cl_glorifiedbanking_dark.lua" )
    gbIncludeFolder( "glorifiedbanking/themes/" )
    gbIncludeFolder( "glorifiedbanking/modules/sql/" )
    gbIncludeFolder( "glorifiedbanking/modules/" )
    hook.Run( "GlorifiedBanking.FinishedLoading" )
end

hook.Add( GlorifiedBanking.HookRunName, "GlorifiedBanking.AutoIncluder.IncludeGBFiles", IncludeGBFiles )