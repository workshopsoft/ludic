# ludic.wallet

Money carried, in whole units: earned, spent only when it is there, lost when a cost happens
anyway, and every change reported. Uses [`ludic.base`](../ludic.base/README.md) and nothing
else. Prices, reputation and what a thing costs are the game's; the wallet only holds the money.

```ludic
import "ludic.wallet"
```

No ports: the wallet asks the world nothing.

## API

| | |
| --- | --- |
| `wallet_money()`, `wallet_can(n)` | what is there, and whether `n` is |
| `wallet_earn(n)` | add |
| `wallet_spend(n) -> bool` | only what is there: false, and nothing spent, when it is not |
| `wallet_lose(n)` | a cost that happens whether or not it can be paid (a rescue); never below zero |
| `wallet_set(n)` | exactly `n` (a starting purse, a correction, the network's word) |
| `wallet_changes() -> Queue<MoneyChanged>` | the facts: `{ before, after }`, one per change |
| `wallet_system() -> System` | `"wallet"`, `PH_COMMIT`: reset, and its save section (`wallet_save`, `wallet_load`) |

## Tests

```bash
ludic build packages/ludic.wallet/tests/wallet_test.ludic --headless -o /tmp/wallet_test && /tmp/wallet_test
```
