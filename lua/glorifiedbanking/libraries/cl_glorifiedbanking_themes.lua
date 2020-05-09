GlorifiedBanking.Themes = {}
local registeredThemes = {}
local selectedTheme = cookie.GetString("GlorifiedBanking.Theme", "Dark")

function GlorifiedBanking.Themes.Register(id, name, data)
    if not registeredThemes[id] then
        registeredThemes[id] = {}
    end

    registeredThemes[id].DisplayName = name
    registeredThemes[id].Data = data
end

function GlorifiedBanking.Themes.Get(id)
    return registeredThemes[id] or registeredThemes["Dark"] or false
end

function GlorifiedBanking.Themes.GetCurrent()
    return GlorifiedBanking.Themes.Get(selectedTheme)
end

function GlorifiedBanking.Themes.Select(id)
    if registeredThemes[id] then
        cookie.Set("GlorifiedBanking.Theme", tostring(id))
        selectedTheme = tostring(id)
    end
end