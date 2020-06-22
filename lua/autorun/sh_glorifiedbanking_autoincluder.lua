
--[[
    Script Ownership:
    {{ user_id }}
    Version: {{ script_version_name }}
]]--

GlorifiedBanking = GlorifiedBanking or {
    Config = {},
    Version = "2.5.7"
}

print( "[GlorifiedBanking] This server is running version " .. GlorifiedBanking.Version .. "." )
local IsAddon = true -- Set this to 'true' if you're running from an addon, set to 'false' if you're running from a gamemode.

--[[
    GlorifiedInclude - A library for including files & folders with ease.
    © 2020 GlorifiedInclude Developers

    Please read usage guide @ https://github.com/GlorifiedPig/glorifiedinclude/blob/master/README.md

    Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
    The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
]]--

local giVersion = 1.2

if not GlorifiedInclude or GlorifiedInclude.Version < giVersion then

    GlorifiedInclude = {
        Version = giVersion,
        Realm = {
            Server = 0,
            Client = 1,
            Shared = 2
        }
    }

    local _include = include
    local _AddCSLuaFile = AddCSLuaFile
    local _SERVER = SERVER

    local _GlorifiedInclude_Realm = GlorifiedInclude.Realm

    local includedFiles = {}
    function GlorifiedInclude.IncludeFile( fileName, realm, forceInclude, calledFromFolder, printName )
        if IsAddon == false and not calledFromFolder then fileName = GM.FolderName .. "/gamemode/" .. fileName end
        if not forceInclude and includedFiles[fileName] then return end
        includedFiles[fileName] = true

        if realm == _GlorifiedInclude_Realm.Shared or fileName:find( "sh_" ) then
            if _SERVER then _AddCSLuaFile( fileName ) end
            _include( fileName )
            if printName then
                print( printName .. " > Included SH file '" .. fileName .. "'" )
            end
        elseif realm == _GlorifiedInclude_Realm.Server or ( _SERVER and fileName:find( "sv_" ) ) then
            _include( fileName )
            if printName then
                print( printName .. " > Included SV file '" .. fileName .. "'" )
            end
        elseif realm == _GlorifiedInclude_Realm.Client or fileName:find( "cl_" ) then
            if _SERVER then _AddCSLuaFile( fileName )
            else _include( fileName ) end
            if printName then
                print( printName .. " > Included CL file '" .. fileName .. "'" )
            end
        end
    end

    function GlorifiedInclude.IncludeFolder( folderName, ignoreFiles, ignoreFolders, forceInclude, printName )
        if IsAddon == false then folderName = GM.FolderName .. "/gamemode/" .. folderName end

        if string.Right( folderName, 1 ) != "/" then folderName = folderName .. "/" end

        local filesInFolder, foldersInFolder = file.Find( folderName .. "*", "LUA" )

        if forceInclude == nil then forceInclude = false end

        if ignoreFiles != true then
            for k, v in ipairs( filesInFolder ) do
                GlorifiedInclude.IncludeFile( folderName .. v, nil, forceInclude, true, printName )
            end
        end

        if ignoreFolders != true then
            for k, v in ipairs( foldersInFolder ) do
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

hook.Add("libgmodstore_init", "GlorifiedBanking.AutoIncluder.InitLibGModStore",function()
    libgmodstore:InitScript( 7140, "GlorifiedBanking", {
        version = "{{ script_version_name }}",
        licensee = "{{ user_id }}"
    } )
end)
