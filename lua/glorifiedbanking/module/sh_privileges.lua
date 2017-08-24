
glorifiedBanking.privilege = {
    CAMI_CAN_USE_ADMIN_COMMANDS = "glorifiedBanking_hasAdminPrivileges"
}

CAMI.RegisterPrivilege {
    Name = glorifiedBanking.privilege.CAMI_CAN_USE_ADMIN_COMMANDS,
    MinAccess = glorifiedBanking.config.ADMIN_INHERIT_MINIMUM
}
