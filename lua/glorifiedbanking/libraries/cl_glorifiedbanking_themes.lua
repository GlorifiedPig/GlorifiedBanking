
GlorifiedBanking.Themes = {}

local registeredThemes = {}
local defaultTheme = "Dark"
local selectedTheme

function GlorifiedBanking.Themes.Register( id, name, data )
    if not registeredThemes[id] then
        registeredThemes[id] = {}
    end

    registeredThemes[id].DisplayName = name
    registeredThemes[id].Data = id == defaultTheme and data or table.Merge( GlorifiedBanking.Themes.Get( defaultTheme ).Data, data )
end

function GlorifiedBanking.Themes.Get( id )
    return registeredThemes[id] or registeredThemes[defaultTheme] or false
end

function GlorifiedBanking.Themes.GetCurrent()
    return GlorifiedBanking.Themes.Get( selectedTheme )
end

function GlorifiedBanking.Themes.GetAll()
    return registeredThemes
end

function GlorifiedBanking.Themes.GetByName( name )
    local returnedTheme = registeredThemes[defaultTheme]
    for k, v in pairs( registeredThemes ) do
        if v.DisplayName == name then returnedTheme = v break end
    end
    return returnedTheme
end

function GlorifiedBanking.Themes.GenerateFonts()
    for k, v in pairs( GlorifiedBanking.Themes.GetCurrent().Data.Fonts ) do
        if isfunction(v.size) then
            v.size = v.size()
        end

        surface.CreateFont( "GlorifiedBanking." .. k, v )
    end
end

function GlorifiedBanking.Themes.Select( id )
    if registeredThemes[id] then
        GlorifiedBanking.Themes.GenerateFonts()

        cookie.Set( "GlorifiedBanking.Theme", tostring( id ) )
        selectedTheme = tostring( id )

        hook.Run( "GlorifiedBanking.ThemeUpdated", GlorifiedBanking.Themes.GetCurrent() )
    end
end

hook.Add( "OnScreenSizeChanged", "GlorifiedBanking.Themes.OnScreenSizeChanged", function()
    GlorifiedBanking.Themes.GenerateFonts()
end )

hook.Add("InitPostEntity", "GlorifiedBanking.Themes.InitPostEntity", function()
    GlorifiedBanking.Themes.Select( cookie.GetString( "GlorifiedBanking.Theme", defaultTheme ) )
end )

concommand.Add( "glorifiedbanking_theme", function( ply, args )
    if ply != LocalPlayer() then return end
    local theme = string.lower( args[1] )
    GlorifiedBanking.Themes.Select( theme )
end )