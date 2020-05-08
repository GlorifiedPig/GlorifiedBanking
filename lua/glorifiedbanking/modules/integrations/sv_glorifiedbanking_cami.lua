
GlorifiedBanking.CAMI = {
    Privileges = {
        OpenLogs = {
            Name = "glorifiedbanking_openlogs",
            MinAccess = "admin",
            Description = "Determines whether or not the player can open the GlorifiedBanking logs panel."
        }
    }
}

CAMI.RegisterPrivilege( GlorifiedBanking.CAMI.Privileges.OpenLogs )