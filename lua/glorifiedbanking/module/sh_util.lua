
function glorifiedBanking.registerPhrase( languageId, phraseId, phrase )
    return i18n.registerPhrase( languageId, glorifiedBanking.IDENTIFIER .. phraseId, phrase )
end

function glorifiedBanking.registerPhrases( languageId, phrases )
    for phraseId, phrase in pairs( phrases ) do
        glorifiedBanking.registerPhrase( languageId, phraseId, phrase )
    end
end

function glorifiedBanking.getPhrase( phraseId, ... )
    return i18n.getPhrase( glorifiedBanking.IDENTIFIER .. phraseId, ... )
end
