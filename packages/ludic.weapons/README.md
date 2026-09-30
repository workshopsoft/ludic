# ludic.weapons

Firearms and throwables as data. Weapons (their class, fire modes, rate, damage with a range falloff, spread that
blooms and recovers, a recoil pattern, hitscan or a body in flight, penetration, the magazine and reload times),
ammo types, attachments that change stats, skins and loadouts are rows; a shooter's guns, reserve and weapon wheel
are its state; shooting is verbs (trigger, fire, reload, switch, attach). The world - the aim ray, a raycast, a
sweep, who is near a blast - is asked through ports, damage goes out through a port (ludic.vitals binds it in a
line), and every shot, hit, kill and reload is a fact. The spread and the recoil jitter come from a dice seeded
by the shot, so a guest and the host draw the same shot; in a party the host validates what the guest fired.
Uses [`ludic.base`](../ludic.base/README.md) and nothing else.

```ludic
import "ludic.weapons"
```

The game fills open registries, usually from resource files: `def Weapons from "weapons.lres"`, and likewise
`WeaponClasses`, `AmmoTypes`, `Attachments`, `WeaponSkins`, `Loadouts`. Lengths are metres, angles degrees, times
seconds, rates rounds a minute; a yaw of 0 faces +z. A damage type is the game's number (ludic.vitals'
`DamageTypes` row, when it answers the damage port; `@Ref(DamageTypes)` is an unresolved warning where the game
has no such table). **No motion is written here:** every `clip_*` of a weapon (fire, ADS fire, charge, reload,
reload empty, shell start/shell/end, empty, equip, holster, inspect, all `@Clip` against its `model`) and a class's
`hold` is a name the animation layer plays (ludic.anim: a clip from Blender or Mixamo, or a state of the game's
animation graph); the facts carry the one that goes with each act and how long it takes.

## Data

```ludic
Weapon { key, name, icon, class, ammo, ammo_alt, kind, model, muzzle, eject, mount_*, clip_*, modes, burst_count,
         burst_gap, rate, charge_time, charge_min, ammo_per_shot, damage, damage_type, pellets, range, falloff,
         pen, pen_loss, max_pierce, spread, bloom, bloom_max, spread_recovery, spread_delay, stances, move_spread,
         ads_spread, recoil, recoil_loop, recoil_scale, recoil_jitter, recoil_recovery, recoil_delay, recoil_reset,
         ads_recoil, speed, gravity, drag, life, radius, fuse, impact, bounce, cook, blast_radius, blast_damage,
         blast_inner, blast_pow, blast_zone, mag_size, chamber, reload_tactical, reload_empty, reload_each,
         reload_start, reload_end, equip_time, holster_time, move_mult, zoom, ads_time, ads_move, noise, slots,
         attach, skin }
WeaponClass { key, name, wheel, hold, move_mult, ads_move, equip_time, holster_time, slots, auto_reload, melee }
AmmoType    { key, name, icon, damage_mult, pen_mult, speed_mult, spread_mult, range_mult, blast_add, damage_type,
              tracer, max_carry, pickup, effects }          AmmoEffect { kind, magnitude, seconds, chance, bonus, label }
Attachment  { key, name, icon, slot, weapons, classes, model, mount, mods, group, ammo, grant_mode, silenced, light, price }
                                                            AttachmentMod { stat, mode, value }
WeaponSkin  { key, name, weapons, classes, tint, tints, albedo, normal, mask, material, rarity, price }
Loadout     { key, name, items, equip }                     LoadoutItem { weapon, reserve, attachments, skin }
```

```
carbine {
  class: WCLASS_RIFLE, ammo: AMMO_STD, kind: WKIND_HITSCAN, modes: [WMODE_AUTO, WMODE_BURST, WMODE_SEMI]
  rate: 650.0, damage: 22.0, damage_type: DTYPE_BULLET, range: 150.0
  falloff: [{ range: 20.0, mult: 1.0 }, { range: 80.0, mult: 0.6 }, { range: 150.0, mult: 0.35 }]
  spread: 0.6, bloom: 0.25, bloom_max: 3.0, spread_recovery: 6.0, spread_delay: 0.12, move_spread: 1.8, ads_spread: 0.5
  stances: [{ stance: WSTANCE_CROUCH, spread: 0.7, recoil: 0.8 }, { stance: WSTANCE_AIR, spread: 2.5 }]
  recoil: [{ pitch: 0.6, yaw: 0.1 }, { pitch: 0.8, yaw: -0.15 }, { pitch: 0.9, yaw: 0.2 }], recoil_loop: 1
  mag_size: 30, chamber: false, reload_tactical: 2.0, reload_empty: 2.6, zoom: 1.4
  model: "weapons/carbine.glb", muzzle: "muzzle", mount_sight: "rail_top", mount_muzzle: "muzzle"
  clip_fire: "carbine_fire", clip_reload: "carbine_reload", clip_reload_empty: "carbine_reload_empty", clip_equip: "carbine_equip"
}
```

- **Fire modes**: `WMODE_SEMI` a round a press (a press a moment before the rate allows is kept for
  `WEAPONS_BUFFER`), `_BURST` `burst_count` rounds a press `burst_gap` apart, `_AUTO` at the rate while held,
  `_CHARGE` held to charge over `charge_time` and fired on the release, damage and speed from `charge_min` to 1.
  `modes` is the order `weapons_cycle_mode` walks; an attachment may add one (`grant_mode`). The rate is exact
  over a run of frames (the carry between ticks is kept while a gun keeps firing).
- **Damage and range**: `damage` times the ammo's `damage_mult` and the attachments, times the **falloff** at the
  distance (linear between the points, flat before the first and past the last; none past `range`). An
  attachment that adds range stretches the whole curve. `pellets` rounds leave by a cone each.
- **Spread** is a cone half-angle: `(spread + bloom) x stance x (1 + (move_spread - 1) x speed) x (ads_spread in the sights)
  x the ammo's spread_mult`. Each shot adds `bloom` up to `bloom_max`; after `spread_delay` without a shot it comes back
  at `spread_recovery` a second. The game tells stance, speed (0..1) and the sights: `weapons_set_stance`,
  `_set_motion`, `_set_ads`.
- **Recoil** is the kick the aim carries (degrees, pitch up and yaw right), numbers the camera adds - never
  a bone: shot `n` takes the pattern's row `n` (from `recoil_loop` on, after the last), times the recoil stat, the stance
  and the sights, plus `recoil_jitter` from the shot's dice. `weapons_recoil_pitch/yaw` is what is still there,
  recovering at `recoil_recovery` after `recoil_delay`; idle for `recoil_reset` and the pattern starts over. Each FIRED
  fact carries the kick it added.
- **Hitscan or a body in flight**: `WKIND_HITSCAN` is a ray; `_PROJECTILE` and `_THROWN` leave the muzzle for the
  point the aim ray reaches, at `speed` (times the charge), falling by `gravity` with `drag`, and go off on contact
  (`impact`) or at their `fuse` (a thrown one bounces by `bounce` meanwhile; `cook` has a held charge burn the fuse) or
  when `life` is up. A blast hurts every body within `blast_radius` (not behind cover): full damage inside
  `blast_inner`, falling to 0 at the edge by `blast_pow` (1 linear, 2 faster); the thrower is hurt too. A thrown
  weapon's stock is its ammo reserve: the next one is a reload.
- **Penetration**: a ray has `pen` power; each body or surface it reaches costs `WeaponsWorld.pierce_cost(actor,
  material)` (negative stops it), a round that still has power goes on with `pen_loss` of its damage gone, at most `max_pierce`
  times. Bodies that are not hostile are passed through.
- **Magazine**: `mag_size` (with attachments); a tactical reload on a hitscan weapon with `chamber` leaves one up the
  spout, so it holds one more; `reload_tactical`/`reload_empty` seconds times the reload stat; `reload_each` loads shell by shell
  (`reload_start`, each `reload_tactical`, `reload_end`; firing stops it). An empty trigger is a WP_EMPTY fact once a press and,
  for a class with `auto_reload`, starts the reload.

## Attachments stack

1. **One part to a slot** (`WSLOT_MUZZLE`, `_BARREL`, `_SIGHT`, `_GRIP`, `_MAG`, `_STOCK`, `_LASER`, `_SKIN`): fitting one to an
   occupied slot replaces what was there (a DETACHED then an ATTACHED fact). A part of the same non-zero `group`
   in another slot gives way too (a laser and a flashlight).
2. **A stat is `(base + every add) x (every multiplier)`**, over the fitted parts, then held to `WEAPON_MOD_MIN` (0.1) .. `WEAPON_MOD_MAX` (4)
   times its base (a base of 0 is left alone). The ammo's multiplier then applies to damage, range, speed, penetration
   and spread. Stats: damage, rate, range, spread, bloom, recoil, spread recovery, recoil recovery, mag size, reload (a
   multiplier on the times), equip, zoom, ADS time, move (multiplier), projectile speed, noise, penetration.
3. **Fit**: a part names weapons, classes or neither (any weapon that offers the slot); the weapon offers the slots of
   its class and its own `slots`. `weapons_attach` says `WP_OK`, `WP_NO_SLOT` or `WP_NOT_COMPATIBLE`.
4. **A part with an `ammo`** loads that round (the magazine goes back to the reserve); a smaller magazine returns
   its excess to the reserve; a mode that is no longer offered gives way to the first.

## Shooters, the wheel, loadouts

`weapons_add(actor, persist)` makes a shooter; `weapons_give(h, weapon)` a gun (loaded, default parts fitted, the
weapon's skin on); `weapons_give_loadout(h, loadout)` a set with its parts, skins, reserve and the one to draw;
`weapons_equip(h, gun)` draws one (the old gun's holster time plus the new one's equip time, during which nothing
fires). The wheel has `WEAPONS_WHEEL` places (the class's `wheel`): `weapons_switch_slot(h, place)` draws the gun last
drawn there (or the next in the place, when that place is already in hand), `weapons_cycle(h, dir)` walks all of them.
Ammo is a reserve per `AmmoTypes` row (`weapons_ammo_add` up to the type's `max_carry`); a gun loads one of its weapon's
ammo types (`weapons_set_ammo_type`). Skins: `weapons_set_skin` (the skin's weapons/classes, or any).

## API

| | |
| --- | --- |
| `weapons_add(actor, persist) -> h`, `_remove`, `_of(actor)`, `_actor(h)`, `_count()` | the shooters |
| `weapons_give(h, weapon) -> gun`, `_take(h, gun)`, `_give_loadout(h, loadout)`, `_gun_of(h, weapon)`, `_gun_count`, `_gun_slots` | the inventory |
| `weapons_equip(h, gun) -> why`, `_holster`, `_switch_slot(h, place)`, `_cycle(h, dir)`, `_wheel_count/_wheel_gun/_wheel_slot` | in hand and the wheel |
| `weapons_trigger(h, down)`, `_fire_at(h, ox, oy, oz, dx, dy, dz) -> why` | the trigger (turned into rounds by the mode, along the port's aim) and one round along a ray the caller gives |
| `weapons_reload(h) -> why`, `_cancel_reload` | |
| `weapons_attach(h, gun, part) -> why`, `_detach(h, gun, slot)`, `_attached`, `_set_skin`, `_set_ammo_type`, `_cycle_mode`, `_set_mode` | |
| `weapons_ammo`, `_ammo_add`, `_ammo_set` | the reserve |
| `weapons_set_stance`, `_set_motion`, `_set_ads` | what the game tells |
| `weapons_current`, `_weapon_of`, `_mag`, `_mag_size`, `_capacity`, `_ammo_type`, `_mode`, `_skin`, `_stat(h, gun, stat)`, `_damage_at(h, gun, dist)`, `_spread`, `_recoil_pitch`, `_recoil_yaw`, `_ads`, `_zoom`, `_move_mult`, `_charge`, `_busy`, `_reloading`, `_equipping`, `_shots`, `_time`, `_projectile_count` | what the game and a stats screen ask |
| `weapons_shot_seed(world_seed, actor, shot_no)` | the dice of one shot |
| `weapons_run(dt)`, `weapons_reset()`, `weapons_save()`, `weapons_load(v, version)`, `weapons_system()` | `"weapons"`, `PH_SIMULATE` |

`why` is `WP_OK`, `_NO_SHOOTER`, `_NO_GUN`, `_BUSY`, `_FULL`, `_NO_AMMO`, `_NOT_COMPATIBLE`, `_NO_SLOT`, `_CANT`, `_NOT_HOST`,
`_NOT_HELD`, `_STALE`, `_TOO_FAST`, `_BAD_ORIGIN`.

## Facts

`weapons_facts() -> Queue<WeaponFact>`: `{ what, shooter, actor, gun, weapon, ammo, target, zone, shot_no, seed, damage, dist,
spread, kick_pitch, kick_yaw, noise, amount, time, material, crit, killed, predicted, remote, x y z, dx dy dz, clip }`.

| | |
| --- | --- |
| `WP_FIRED` | a round left (seed, spread, noise, the kick, clip, the aim ray); `WP_HIT` a round reached a body (`target`, `zone`, `damage`, `dist`) or the world (`target` -1, `material`, x y z, d the surface normal); `WP_KILLED` the hit took its target out of the fight |
| `WP_RELOAD_STARTED` (clip, time), `WP_RELOADED` (amount), `WP_EMPTY` (clip), `WP_CHARGING` (clip, time to full) | the act, with the clip to play and how long it takes |
| `WP_EQUIPPED`, `WP_HOLSTERED` (clip, time), `WP_ATTACHED`, `WP_DETACHED` (zone: slot, ammo: the part), `WP_MODE`, `WP_SKIN`, `WP_GIVEN`, `WP_TAKEN`, `WP_AMMO` | the inventory |
| `WP_PROJECTILE` (id in `shot_no`, x y z, d its velocity), `WP_PROJECTILE_END` (zone: `WP_END_HIT`, `_EXPIRED`, `_FUSE`), `WP_EXPLODED` (amount: radius, target: how many reached) | bodies in flight |
| `WP_REFUSED` (zone: why), `WP_CONFIRMED`, `WP_CORRECTED` | a verb not allowed; the host's answer to a guest's shot |

A fact made by a guest's own shot is `predicted`; one from another machine's shot shown here is `remote`.

## The ports

```ludic
export port WeaponsWorld { aim_x/y/z, aim_dx/dy/dz, muzzle_x/y/z, can_fire, cast, sweep, hit_actor, hit_zone, hit_material,
                           hit_nx/ny/nz, pierce_cost, hostile, find, body_x/y/z, blocked, origin_ok, rewind, restore }
export port WeaponsDamage { hurt: fn(victim, attacker, amount, type, zone) -> float, alive: fn(actor) -> bool }
export port WeaponsEffects { apply: fn(target, source, kind, magnitude, seconds, bonus, label) -> void }
```

`cast(ox, oy, oz, dx, dy, dz, max, ignore)` returns the distance to the first hit, or -1, and the `hit_*` readers answer
for that cast (`hit_actor` -1 is the world); `sweep(ax, ay, az, bx, by, bz, radius, ignore)` returns the fraction of the
segment reached. The game answers them with ludic.physics' queries (or its own); none of it allocates. `aim_*` is the
ray from the camera through the crosshair (ludic.aim), `muzzle_*` where a body leaves. `WeaponsDamage` is bound to
ludic.vitals in one line (`bind WeaponsDamage { hurt: fn vitals_weapon_hurt, alive: fn vitals_actor_standing }`);
`WeaponsEffects.apply` has the shape of ludic.abilities' `apply`, so one function (the game's glue to ludic.effects)
binds both, and an ammo type's `effects` are applied, by their `chance`, to a body that was hurt. Every member has a
default: unbound, a shooter aims along +z from the origin and nothing is hit.

## Multiplayer: the host validates the shot

Solo and host resolve a shot for real (`weapons_set_role(WEAPONS_SOLO | _HOST | _GUEST)`; every machine is given
the match's `weapons_seed` by the host). A guest's own shot is predicted:

1. **The guest fires at once**: the magazine, the flash, the recoil, the spread and a *picture* of the hit (HIT
   facts `predicted`, bodies in flight as cosmetic ones) all happen on the guest, from the seed
   `weapons_shot_seed(match seed, actor, shot number)`. Nothing is hurt: the damage port is never called on a guest.
   The shot is queued on `weapons_outbox()` as a `ShotRequest { actor, gun, weapon, shot_no, seed, stamp, aim ray, spread, charge }`;
   `stamp` is the time on the host's clock (the game estimates it from ludic.net's round trip, `weapons_time` is this
   package's own).
2. **The host checks** with `weapons_host_fire(request) -> why`: the shooter holds that gun, it is not busy, it has the
   round, the shot number is new (`WP_STALE`), the rate allows it within a slack (`WP_TOO_FAST`; `weapons_config`), the
   world lets the actor fire and says the aim origin is near where the actor is (`origin_ok`: `WP_BAD_ORIGIN`).
3. **The host derives the seed itself** from the shot number, so a guest cannot pick a lucky one, and holds the claimed
   spread to the most the weapon can have in any stance.
4. **Lag compensation**: `WeaponsWorld.rewind(stamp)` (the stamp held to `weapons_config`'s `max_rewind` of now) puts the
   bodies back where the guest saw them, the round is resolved for real through the damage port, `restore()` puts them
   back. The game answers those two with the positions it keeps a short history of.
5. **The answers**: a `ShotConfirm { actor, shot_no, accepted, why, mag, reserve }` on `weapons_confirms()` for the owner
   (`weapons_net_confirm` sets its magazine right: a refusal or a different count is a `WP_CORRECTED` fact, and rounds
   still unanswered are accounted for), and the host's own facts: its `WP_FIRED` (seed, spread, shot number, the ray) is
   what the game relays to the *other* guests, who show it with `weapons_net_fired(...)` (a mirror shooter: flash, tracer,
   impacts, a picture of a body in flight; nothing spent, nothing hurt). The host's `WP_HIT` / `WP_KILLED` are the kill feed.
6. **Inventory** reaches guests as `weapons_snapshot(h, out)` / `weapons_apply_snapshot(actor, data, n)` (guns, parts,
   skin, the hand, the reserve; stale ones dropped; the owner's own magazine is left alone while its shots are
   unanswered). The owner's other intents (reload, switch, attach, mode) are the game's own messages: it sends them to the
   host, which runs the same verb, and the snapshot brings the truth back.

The package sends nothing: the game puts the outbox, the confirms, the facts and the snapshots on its wire (ludic.net).
Floats in the cone are the platform's; host and guest draw the same numbers from the same seed, and what the host
resolves is the only thing that hurts anyone, so an ulp between machines is a pixel of tracer, not a desync.

## Save

Section `weapons`, version 1: each persisting shooter by the game's number with its guns (weapon, loaded round, mode,
skin and every fitted part, all by key, and the magazine), the gun in hand, the shots fired and the reserve by ammo key.
A key the game no longer has is skipped. What is in flight, a reload in progress, the recoil and the bloom are not saved.

## Tests

```bash
ludic test packages/ludic.weapons
```

Attachments stacking (adds before multipliers, clamps, one to a slot, groups, compatibility, slots), the falloff and
its stretch, semi/burst/auto/charge and the rate, the empty click, spread and bloom and their recovery by stance/speed/
sights/ammo, recoil pattern, loop, scale and recovery, the same seed making the same shot, pellets in their cone,
penetration through a wall and bodies, rockets (drop, blast falloff, cover) and thrown charges (charge, cook, bounce,
fuse), reloads (tactical, empty, shell by shell), the wheel and equip times, ammo types, skins, loadouts, the party
model (prediction, the host's checks and rewind, the confirm, remote shots, snapshots), the save, and a long firefight
that makes nothing new.

## Signals

The facts and values an animation graph (or a sound bank) can listen to, by name and without glue, are declared in `signals.ludic` as `SignalSources` (`ludic.base`): weapons.RELOAD_STARTED, weapons.FIRED, weapons.ads, and more. A game writes `AnimBindings` rows naming them (`ludic.anim`). They read the fact queue without draining it.
