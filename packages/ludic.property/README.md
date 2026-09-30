# ludic.property

Housing and businesses: kinds of property (an interior map, garage, storage and upgrade slots), the sites a
map holds, upgrades, ownership per player (buy, sell, rent, trade), access lists, interiors that get an
instance id per visit, storage of items and vehicles, and passive income and business loops (supply, produce,
sell) as a `@Machine` with timers. Uses [`ludic.base`](../ludic.base/README.md) and nothing else. Money,
interior loading, items and vehicles are all ports; nothing here names an apartment, a shop or a product.

```ludic
import "ludic.property"
```

(The module is `ludic_property`; its verbs are `realty_*`, since `property` is a keyword.)

## The data

| Registry | Prefix | A row is |
| --- | --- | --- |
| `PropertyKinds` | `PRK_` | a kind: `interior` (the key of the map the inside lives on) and `interiors` (more maps of a multi-map interior, floors 1, 2...), the `spawn_*` inside, `instanced`, `garage_slots`, `storage_slots`, `upgrade_slots`, `guests_max`, `sell_pct` (permille back on a sale), `buyable` / `rentable`, `grace_days`, `raidable` and `raid_cooldown`, `income_day`, and the `business` loop it runs |
| `Properties` | (per map) | a site: `@PerMap`, `maps/<map>/properties.lres` - the entrance `x` `y` `z` `yaw`, `kind`, `price`, `rent` a game day, `district`, and where a retrieved vehicle appears |
| `PropertyUpgrades` | `PRU_` | an upgrade: `kinds` it fits, `price`, `slots` it uses, `requires`, `garage` / `storage` slots added, `income_pct`, `produce_pct`, and an `interior` variant that replaces the kind's map |
| `BusinessLoops` | `BIZ_` | a loop: `supply_max` / `supply_price` / `supply_batch` / `supply_per_unit`, `make_secs`, `stock_max`, `unit_value`, `sell_secs`, `upkeep_day` |

The kinds, upgrades and loops are open, append-only registries saved by key (so order is free); `def` them in
code or `def PropertyKinds from "kinds.lres"`. A site names its kind by constant (`kind: PRK_HOUSE`). The
interior is named by a map key: a map the game's maps root holds, loaded through the port.

```
harbor/properties.lres:
flat_1  { name: "Flat one", kind: PRK_FLAT, x: 10.0, z: 20.0, yaw: 90.0, price: 10000, rent: 100, district: "Old Town" }
house_1 { kind: PRK_HOUSE, x: 100.0, z: 50.0, price: 80000, garage_x: 104.0, garage_z: 52.0, garage_yaw: 45.0 }
```

## Ports

```ludic
export port RealtyWorld {   # defaulted: this machine owns the world; nobody is anyone's crew or friend
  authority: fn() -> bool;  same_crew: fn(int, int) -> bool;  friends: fn(int, int) -> bool
}
export port RealtyPurse {   # defaulted: money is no object
  spend: fn(int, int) -> bool          # (who, n); false and nothing taken when it is not there
  earn: fn(int, int) -> void
}
export port RealtyLoad {    # defaulted: loads always work, nothing is placed
  load: fn(int, string, int) -> bool                             # (instance, map, floor)
  unload: fn(int) -> void
  enter: fn(int, int, int, float, float, float, float) -> void   # (who, instance, floor, x, y, z, yaw)
  leave: fn(int, int, float, float, float, float) -> void        # (who, instance, x, y, z, yaw): at the door
}
export port RealtyStash {   # defaulted: a stack holds 9999, the carry has and takes everything
  stack_limit: fn(int) -> int;  take: fn(int, int, int) -> bool;  give: fn(int, int, int) -> int
  park: fn(int, int) -> bool;  unpark: fn(int, int, float, float, float) -> bool
}
```

The package takes money only through `RealtyPurse`, moves no player and loads no map (the game does, told by
`RealtyLoad`), and never touches an item or a vehicle - the game's `take` / `give` / `park` / `unpark` do.

## Ownership

`realty_buy(sites, who, key)` (and `realty_rent`) take the loaded map's site by key: it must exist, its kind
must be buyable (or rentable), and nobody else may hold it. `realty_sell(who, map, key)` gives back `sell_pct`
of what was paid and spent on upgrades (and any income left uncollected); it refuses while the property holds
items or vehicles, and sends whoever is inside out. `realty_trade(from, to, map, key, price)` has `to` pay
`from` through the purse, moves the deed, clears the guests and sends everyone out. `realty_upgrade` checks the
kind, the requirements, a free slot and the price.

**Rent** is taken a game day at a time from the ticks' hours. A day it cannot be paid is a `RENT_DUE` fact with
the days behind; past the kind's `grace_days` the property is taken back (`EVICTED`, with how much it held, which
is lost) and everyone inside goes out. Paying again clears the debt; buying what you rent converts it.

## Access

Who may come in: the owner and those invited by name (`realty_invite`, up to the kind's `guests_max`), then by
the owner's mode - `REALTY_OWNER`, `_CREW`, `_FRIENDS` (asked through `RealtyWorld.same_crew` / `.friends`) or
`_PUBLIC`. Storage and the garage are for the owner and whoever may use it (invited, crew or friends by mode),
never merely the public.

## Interiors, an instance each

`realty_enter(sites, who, key)` returns an instance id: a NEW id when nobody is inside, the live one when someone
is, so every visit has its own copy of the interior and a guest lands in the owner's. `RealtyLoad.load(instance,
map, floor)` is called the first time (false refuses the visit), then `enter` places the player. The instance
remembers the door it came from: `realty_leave(who)` calls `leave` with it and, when the last player is out,
`unload` and an `INSTANCE_CLOSED` fact. A kind that is not `instanced` is the shared world, instance 0.

A multi-map interior is one instance over several maps: `realty_go_floor(who, floor)` (0 is `interior`, 1.. are
`interiors`) loads that map for the instance the first time anyone goes, then places the player.

## Storage, the garage, raids

`realty_store(who, map, key, item, n)` / `realty_fetch` move items through `RealtyStash.take` / `give` into slots
(one kind per slot, at most `stack_limit` each, at most the kind's slots plus its upgrades'). `realty_park` /
`realty_retrieve(sites, who, key, vehicle)` fill and empty the garage slots; a retrieved vehicle appears at the
site's garage spawn. `realty_raid(raider, map, key, pct)` (for `raidable` kinds) takes a share of every stack, of the
income waiting, the stock and the supplies, returns the total for the game to hand the raider, and starts a
cooldown in game hours.

## Passive income and business loops

`income_day` builds up an income per game day (plus upgrades' `income_pct`) on every owned property;
`realty_collect` takes it through the purse. A kind with a `business` loop runs it as a **`@Machine`**
(`HoldingSteps`, [`steps.lres`](steps.lres)) over `Holding.phase`:

```
Idle --make--> Producing --fills--> Full
Producing --runs_dry--> Idle
Idle | Producing | Full --HoldingSell--> Selling --paid--> Idle
```

Supplies are bought in batches (`realty_buy_supply`, through the purse); while Producing the tick turns
`supply_per_unit` supplies into a unit every `make_secs` (faster by the upgrades' `produce_pct`); a full shelf
waits for a sale run (`realty_sell_stock` dispatches `HoldingSell`), which takes `sell_secs` and pays
`units * unit_value` (plus income upgrades) to the owner through the purse. Upkeep (`upkeep_day`) is taken each game day; a
missed day is a fact, and the game decides what it costs. The timers run in `realty_tick`; the machine only decides.
A sale run in flight is stock again after a load.

## Verbs

| | |
| --- | --- |
| `realty_buy`, `realty_rent`, `realty_end_rent`, `realty_sell`, `realty_trade`, `realty_upgrade` | ownership |
| `realty_set_access`, `realty_invite`, `realty_uninvite`, `realty_can_enter`, `realty_can_use`, `realty_access`, `realty_guest_count` | access |
| `realty_enter`, `realty_leave`, `realty_go_floor`, `realty_inside`, `realty_inside_key`, `realty_instances`, `realty_occupants` | interiors |
| `realty_store`, `realty_fetch`, `realty_item_count`, `realty_stacks_used`, `realty_park`, `realty_retrieve`, `realty_vehicle_count`, `realty_vehicle_at`, `realty_raid` | storage |
| `realty_buy_supply`, `realty_sell_stock`, `realty_collect`, `realty_supply`, `realty_stock`, `realty_biz_phase`, `realty_sell_left`, `realty_income_waiting` | the business |
| `realty_owner`, `realty_rented`, `realty_has_upgrade`, `realty_overdue`, `realty_garage_slots`, `realty_storage_slots`, `realty_count`, `realty_map_at`, `realty_key_at`, `realty_owner_at`, `realty_count_of`, `realty_nth_of` | who has what |
| `realty_tick`, `realty_reset`, `realty_save`, `realty_load`, `realty_snapshot`, `realty_apply_snapshot`, `realty_system()` | the system (`PH_SIMULATE`, key `"realty"`) |

A verb that says no returns false (or -1) and leaves `realty_why()` = one of `REALTY_NO_SITE`, `_NO_HOLDING`,
`_NOT_FOR_SALE`, `_TAKEN`, `_OWNED`, `_NOT_OWNER`, `_BROKE`, `_NOT_HOST`, `_NO_ACCESS`, `_INSIDE`, `_NOT_INSIDE`,
`_LOAD_FAILED`, `_FULL`, `_NOT_EMPTY`, `_BAD_UPGRADE`, `_NEEDS`, `_COOLDOWN`, `_NOT_RAIDABLE`, `_NO_BUSINESS`,
`_NOTHING`, `_BAD_FLOOR`, with a `REFUSED` fact.

## Facts

`realty_facts()` is a `Queue<RealtyFact { what, who, other, map, key, index, amount, instance, floor, reason }>`:
`BOUGHT`, `SOLD`, `RENTED`, `RENT_PAID`, `RENT_DUE`, `EVICTED`, `TRADED`, `UPGRADED`, `ENTERED`, `LEFT`,
`INSTANCE_OPENED`, `INSTANCE_CLOSED`, `FLOOR`, `ACCESS`, `INVITED`, `UNINVITED`, `STORED`, `FETCHED`, `PARKED`,
`RETRIEVED`, `RAIDED`, `INCOME`, `SUPPLIED`, `PRODUCED`, `STOCK_FULL`, `STARVED`, `SELL_STARTED`, `SOLD_STOCK`,
`UPKEEP`, `REFUSED` (`REALTY_` prefixed). `who` is the actor, `other` the owner (or the target of an invite or
trade), each self-contained so a host can put it on the wire as it is.

## Multiplayer: the host owns the deeds

Ownership is **host-authoritative**. A verb that changes who owns what, what is stored or what a business holds, called
where the world is not owned (`RealtyWorld.authority()` false: a guest), changes nothing there and is **asked of the
host**: it dispatches the `@Net` action `RealtyAsk { who, kind, hm, hk, a, b }` (`RASK_*` says which verb). A site is
named on the wire by the hashes of its map and of its key (a string does not go on the wire, and a site is data on every
machine); the host finds it among the holdings and in the loaded map's `Properties`. The asks travel through the
`NetActions` port the game binds to its session (ludic.net's `netact_*`). The host checks one (`realty_ask_ok`: it owns
the world, the kind exists, and `RealtyWorld.allow_ask(sender, who)` says the machine that sent it plays that player) and
reduces it by calling the very verb the guest called, so every rule and every reason is the host's; on the guest the verb
returns `false` (`-1`) and makes no fact. `realty_apply_ask` is the same thing for a game that carries asks some other
way. Nothing is predicted (a deed is no guess a guest can take back): the host sends what happened, the facts (each one
complete) for a change, and `realty_snapshot()` - the same text as the save section - when a player joins; a guest calls
`realty_apply_snapshot(text)`. The tick runs only where the world is owned, so rent,
income and production never run twice. A player's id is the game's persistent account id. A site's ownership is
keyed by `(map, key)`, both data, so it is the same on every machine; the save is by key, so a kind or upgrade
moved in its registry is found again. Instances are not saved: after a load nobody is inside.

## Tests

`ludic test packages/ludic.property`: sites and kinds, buying (taken, not for sale, broke), a guest's every verb asked of the host over a fake wire (the site named by hashes, another player's ask refused),
selling and its share, rent by the day with grace and eviction, trading, upgrades (kind, requires, slots,
variant interior), access by mode and invitation, instances (new id, joined, closed, refused load, shared),
floor to floor, ejection on sale, storage limits, the garage and its spawn, raids and cooldown, passive income,
the business machine end to end, upkeep, facts, the save and a guest's snapshot.
