# GlorifiedBanking

## Documentation

### Functions

`GlorifiedBanking.GetPlayerBalance( ply )`
* Gets the player's balance. You can also use `ply:GetBankBalance()`

| Argument                  | Description   |
| -------------             | ------------- |
| player :: Player          | The player whose balance you want to get. |

| Returns                  | Description   |
| -------------             | ------------- |
| balance :: number          | The balance of the specified player. |
---
`GlorifiedBanking.SetPlayerBalance( ply, balance )`
* Set the player's balance. You can also use `ply:SetBankBalance( balance )`

| Argument                  | Description   |
| -------------             | ------------- |
| player :: Player          | The player whose balance you want to set. |
| balance :: number          | The new balance you want to set the player's bank to. |
---
`GlorifiedBanking.AddPlayerBalance( ply, addAmount )`
* Adds to the player's balance. You can also use `ply:AddBankBalance( addAmount )`

| Argument                  | Description   |
| -------------             | ------------- |
| player :: Player          | The player whose balance you want to add to. |
| addAmount :: number          | The amount you want to add to the player's bank account. |
---
`GlorifiedBanking.RemovePlayerBalance( ply, removeAmount )`
* Removes from the player's balance. You can also use `ply:RemoveBankBalance( removeAmount )`

| Argument                  | Description   |
| -------------             | ------------- |
| player :: Player          | The player whose balance you want to remove from. |
| removeAmount :: number          | The amount you want to remove from the player's bank account. |
---
`GlorifiedBanking.CanPlayerAfford( ply, affordAmount )`
* Checks if the player's bank account can afford said amount. You can also use `ply:CanAffordBank( affordAmount )`

| Argument                  | Description   |
| -------------             | ------------- |
| player :: Player          | The player whose balance you want to check. |
| affordAmount :: number          | The amount you want to check if the player can afford. |

| Returns                  | Description   |
| -------------             | ------------- |
| canAfford :: boolean          | Whether or not the player can afford the specified amount. |
---
`GlorifiedBanking.WithdrawAmount( ply, withdrawAmount )`
* Withdraws from the player's bank account into their wallet. You can also use `ply:WithdrawFromBank( withdrawAmount )`

| Argument                  | Description   |
| -------------             | ------------- |
| player :: Player          | The player whose balance you want to withdraw from. |
| withdrawAmount :: number          | The amount you want to withdraw. |
---
`GlorifiedBanking.DepositAmount( ply, depositAmount )`
* Deposits from the player's wallet into their bank account. You can also use `ply:DepositToBank( depositAmount )`

| Argument                  | Description   |
| -------------             | ------------- |
| player :: Player          | The player whose balance you want to deposit. |
| withdrawAmount :: number          | The amount you want to deposit. |
---
`GlorifiedBanking.TransferAmount( ply, receiver, transferAmount )`
* Transfers from one player's bank account to another's. You can also use `ply:TransferBankMoney( receiver, transferAmount )`

| Argument                  | Description   |
| -------------             | ------------- |
| player :: Player          | The player whose balance you want to transfer. |
| receiver :: Player          | The player who receives the transfer. |
| transferAmount :: number          | The amount you want to transfer. |
---
`GlorifiedBanking.GetPlayerInterestAmount( ply )`
* Returns how much the player receives in interest.

| Argument                  | Description   |
| -------------             | ------------- |
| player :: Player          | The player whose interest amount you want to check. |

| Returns                  | Description   |
| -------------             | ------------- |
| interestAmount :: number          | The amount the player receives in interest. |

### Hooks

`GlorifiedBanking.PlayerBalanceUpdated( ply, oldBalance, newBalance )`

| Argument                  | Description   |
| -------------             | ------------- |
| player :: Player          | The player whose bank balance was updated. |
| oldBalance :: number          | The old bank balance before it was updated. |
| newBalance :: number          | The new bank balance after the update. |
---
`GlorifiedBanking.PlayerWithdrawal( ply, withdrawalAmount )`

| Argument                  | Description   |
| -------------             | ------------- |
| player :: Player          | The player who withdrawed from his bank. |
| withdrawalAmount :: number          | The amount that was withdrawn. |
---
`GlorifiedBanking.PlayerDeposit( ply, depositAmount )`

| Argument                  | Description   |
| -------------             | ------------- |
| player :: Player          | The player who deposited to his bank. |
| depositAmount :: number          | The amount that was deposited. |
---
`GlorifiedBanking.PlayerTransfer( ply, receiver, transferAmount )`

| Argument                  | Description   |
| -------------             | ------------- |
| player :: Player          | The player who transferred an amount to another player. |
| receiver :: Player          | The player who received the tranfer. |
| transferAmount :: number          | The amount that was transferred. |
---
`GlorifiedBanking.PlayerInterestReceived( ply, interestAmount )`

| Argument                  | Description   |
| -------------             | ------------- |
| player :: Player          | The player who received their interest. |
| interestAmount :: number          | The amount they received in interest. |

### Console Commands
- `glorifiedbanking_admin` - Opens the admin user interface.
- `glorifiedbanking_logs` - Opens the log viewer for admins.