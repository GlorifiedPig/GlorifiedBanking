
ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Glorified ATM"
ENT.Category = "GlorifiedBanking"
ENT.Author = "Tom.bat"
ENT.Spawnable = true
ENT.AdminOnly = true

function ENT:SetupDataTables()
    self:NetworkVar("Int", 0, "ScreenID")
    self:NetworkVar("Int", 1, "WithdrawalFee")
    self:NetworkVar("Int", 2, "DepositFee")
    self:NetworkVar("Int", 3, "TransferFee")
    self:NetworkVar("String", 0, "SignText")
    self:NetworkVar("Entity", 0, "CurrentUser")

    if SERVER then
        self:SetScreenID(1)
        self:SetCurrentUser(NULL)
        self:SetWithdrawalFee(0)
        self:SetDepositFee(0)
        self:SetTransferFee(0)
        self:SetSignText("ATM")
    else
        self:NetworkVarNotify("ScreenID", self.OnScreenChange)
    end
end

ENT.Screens = {
    [1] = {}, --Idle screen
    [2] = {}, --Lockdown screen
    [3] = { --Main Menu
        loggedIn = true
    },
    [4] = { --Withdrawal screen
        loggedIn = true,
        previousPage = 3,
        takesKeyInput = true
    },
    [5] = { --Deposit screen
        loggedIn = true,
        previousPage = 3,
        takesKeyInput = true
    },
    [6] = { --Transfer screen
        loggedIn = true,
        previousPage = 3,
        takesKeyInput = true
    },
    [7] = { --Transactions screen
        loggedIn = true,
        previousPage = 3,
        takesKeyInput = true
    }
}
