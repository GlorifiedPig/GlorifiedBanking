
--[[
    GlorifiedPig's Localization & Internationalization Library
    © 2020 GlorifiedPig
    Please read usage guide @ https://github.com/GlorifiedPig/gmod-i18n
    Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
    The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
]]--

local i18nVersion = 1.1

if not i18n or i18n.Version < i18nVersion then
    i18n = {
        Version = i18nVersion
    }

    local language = GetConVar( "gmod_language" )
    local registeredPhrases = {}

    function i18n.RegisterPhrase( languageIdentifier, phraseId, text )
        if not registeredPhrases[languageIdentifier] then registeredPhrases[languageIdentifier] = {} end
        registeredPhrases[languageIdentifier][phraseId] = text
    end

    function i18n.RegisterPhrases( languageIdentifier, phraseTbl )
        for k, v in pairs( phraseTbl ) do
            i18n.RegisterPhrase( languageIdentifier, k, v )
        end
    end

    function i18n.GetPhrase( phraseIdentifier, ... )
        local phraseLanguage = registeredPhrases[language:GetString()] or registeredPhrases["en"]
        local finalPhrase = registeredPhrases["en"][phraseIdentifier]
        if phraseLanguage[phraseIdentifier] then finalPhrase = phraseLanguage[phraseIdentifier] end

        return table.Count( { ... } ) > 0 and string.format( finalPhrase, ... ) or finalPhrase
    end
end