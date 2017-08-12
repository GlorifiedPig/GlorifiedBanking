
glorifiedbanking.privilege = {
    CAMI_CAN_USE_ADMIN_COMMANDS = "glorifiedbanking_hasAdminPrivileges"
}

CAMI.RegisterPrivilege {
    Name = glorifiedbanking.privilege.CAMI_CAN_USE_ADMIN_COMMANDS,
    MinAccess = "superadmin"
}