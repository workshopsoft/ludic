# ludic.inventory

A pack: a count per kind of item. The game names the kinds and says how many of each fit; the
package keeps the counts, refuses what does not fit, and reports every change. Uses
[`ludic.base`](../ludic.base/README.md) and nothing else.

```ludic
import "ludic.inventory"
```

A kind is the game's number for an item (its place in the game's item table). The game hands the
package each kind's NAME with `inv_config(keys)`, and the save is by name - `{"counts": {"wood":
3}}` - so a game can add, remove or reorder its items without a migration; a name the build no
longer knows is dropped on load.

## The port

```ludic
export port PackRules {
  stack_limit: fn(int) -> int = ...   # how many of a kind fit (unbound: no limit)
}
```

The game fills it once, where it is put together: `bind PackRules { stack_limit: fn gear_stack }`.

## API

| | |
| --- | --- |
| `bind PackRules { ... }`, `inv_config(keys)` | the port (a declaration), and the kinds by name (the pack starts empty) |
| `inv_add(it, n) -> int` | as many of `n` as there is room for; returns how many went in |
| `inv_take(it, n) -> bool` | all `n` or none |
| `inv_set(it, n)` | a count outright, room or not (a starting kit, a correction, the network's word); never below 0 |
| `inv_clear()` | everything gone, silently |
| `inv_count(it)`, `inv_has(it, n)`, `inv_room(it)`, `inv_limit(it)`, `inv_total()`, `inv_kinds()` | what the game asks; a kind out of range counts 0 and has no room |
| `inv_changes() -> Queue<ItemChanged>` | the facts: `{ item, before, after }`, one per change, none for a no-op or a load |
| `inv_system() -> System` | `"inventory"`, `PH_COMMIT`: reset, and its save section (`inv_save`, `inv_load`) |

## Tests

```bash
ludic build packages/ludic.inventory/tests/inventory_test.ludic --headless -o /tmp/inventory_test && /tmp/inventory_test
```
