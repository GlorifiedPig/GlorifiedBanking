
function glorifiedbanking.registerPhrase( languageId, phraseId, phrase )
    return i18n.registerPhrase( languageId, glorifiedbanking.IDENTIFIER .. phraseId, phrase )
end

function glorifiedbanking.registerPhrases( languageId, phrases )
    for phraseId, phrase in pairs( phrases ) do
        glorifiedbanking.registerPhrase( languageId, phraseId, phrase )
    end
end

function glorifiedbanking.getPhrase( phraseId, ... )
    return i18n.getPhrase( glorifiedbanking.IDENTIFIER .. phraseId, ... )
end