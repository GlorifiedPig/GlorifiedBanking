# GlorifiedBanking

## Documentation

### Functions

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

### Console Commands
- `glorifiedbanking_admin` - Opens the admin user interface.
- `glorifiedbanking_sqlviewer` - Opens the admin SQL table viewer for the GlorifiedBanking database.