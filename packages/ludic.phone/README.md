# ludic.phone

An in-world phone, as a framework on [`ludic.ui`](../ludic.ui/): a home screen of **apps the game lists as rows**,
and the built-in apps - contacts, messages, jobs, map (GPS), internet (shop), settings, camera, notifications -
as `ludic.ui` components with stories for the studio. The phone itself is a machine (**away, raised, in an app**), work
it by key or pad. What it shows of the game - the jobs, the waypoint, the shop's rows, the clock - it asks through ports;
what the player did - called someone, pressed a message's button, bought something, took a photo - comes out as facts the
game routes (a call to whatever handles missions, a purchase to the shop). Nothing in it names a game, and it never
starts a mission, takes money or opens a camera itself.

```ludic
import "ludic.phone"
```

Its module line is `module ludic_phone uses ludic_base, ludic_ui`: the mechanic contract of
[`ludic.base`](../ludic.base/README.md) (ports for questions, a queue for facts, verbs for changes, its own save section)
plus the UI it draws with.

## The data

Three open registries, filled with `def PhoneApps from "data/phone.lres"` and the like:

| Registry (prefix) | Record | What a row is |
| --- | --- | --- |
| `PhoneApps` (`PAPP`) | `PhoneApp` | an app on the home screen: `icon` (`@Asset("png")`), `title` (`@Text`), `component` (what opens), `order`, `badge` (`none`, `messages`, `jobs`, `notifications`: the count on its icon) |
| `PhoneBook` (`PBOK`) | `PhoneContact` | someone in the book: `name`, `portrait`, `call` (the game's word for what a call does) and its `arg`, `order`, `known` (in the book from the start), `text` (can be texted) |
| `PhoneOptions` (`POPT`) | `PhoneOption` | a setting the settings app lists: `label`, `kind` (`toggle` or `choice`), `choices`, `options` (names), `initial`. Saved by position, so `@AppendOnly` |

```
messages { component: "PhoneMessages", order: 10, badge: "messages" }
contacts { component: "PhoneContacts", order: 20 }
garage   { component: "GarageApp", order: 90 }          # the game's own app
```

```
ann      { call: "job.offer", arg: "ann", order: 2 }
dispatch { call: "dispatch.call", order: 1, text: false }
```

`component` is one of the phone's own (`PhoneContacts`, `PhoneMessages`, `PhoneJobs`, `PhoneMap`, `PhoneShop`,
`PhoneSettings`, `PhoneCamera`, `PhoneNotifications`), or a game's, which fills the slot of `PhoneScreen` (wrap
`PhoneScreen` in a component of your own and give `<slot name="app"/>` the template that shows yours; ask
`phone_app_component` which app is open). The game can turn an app off with the `app_enabled` port; the home screen
follows within a frame.

## The phone

A machine over `PhoneMode { Away, Raised, App }`:

| verb | does |
| --- | --- |
| `phone_raise`, `phone_lower`, `phone_toggle` | up from away (when `can_raise` says it may), away from anywhere, the phone key |
| `phone_open_app(row)`, `phone_open_key(key)`, `phone_open_shown(i)` | into an app - from away too: the phone comes up into it - or from one app to another |
| `phone_home` | out of an app, to the home screen |
| `phone_back` | out of an open thread, then out of the app, then away |

While it is up (`phone_captures_input`) the game should not walk, aim or fire. A phone that is up when `can_raise`
turns false (a fight starts) goes away by itself. `phone_slide` runs 0 to 1 over a quarter of a second for the screen to
ease by. **Input** is a port polled once a frame, one press a step, however long it is held:
`PhoneInput { toggle, back, home }` - bind a key and a pad button to each; `ludic.ui`'s own focus (the d-pad, A to
press, B for Escape) works the screens, and each app's first control takes the focus.

## The ports

Every member has an answer for a game that binds nothing (no jobs, no shop, no waypoints), so the phone always shows.

```ludic
export port PhoneWorld {
  clock: fn() -> string             # "14:05" for the status bar
  minutes: fn() -> int              # the game's minute, stamped on each message
  signal: fn() -> int               # 0 to 4 bars
  battery: fn() -> int              # 0 to 100
  app_enabled: fn(string) -> bool   # is this app on the phone now?
  can_raise: fn() -> bool           # may the phone come up?
  can_call: fn(string) -> bool      # may this contact be called now?
  money: fn() -> int                # shown in the shop
}
export port PhoneJobs { count, title(i), info(i), state(i), press(i) }     # state: 0 offered, 1 taken, 2 ready to hand in
export port PhoneMap { count, name(i), active, set(i), set_here, clear, distance }
export port PhoneShop { count, name(i), category(i), price(i), available(i), buy(i) -> bool }
export port PhoneInput { toggle, back, home }
```

The lists the game owns (jobs, places, shop rows) are asked once a tick while their app is open and handed to the
component again only when their numbers move; a function bound to a port that builds a string every call allocates
every frame, so bind ones that return strings the game keeps (an `intern`ed one, a `StrTable`'s).

## Facts

`phone_facts(st)` is a `Queue<PhoneFact>` (`what`, `idx`, `key`, `verb`, `arg`, `to`), drained by the game in a later phase:

| `what` | when |
| --- | --- |
| `PHONE_RAISED`, `PHONE_LOWERED` | the phone came up, or was put away |
| `PHONE_APP_OPENED`, `PHONE_APP_CLOSED` | an app (`idx` its row, `key`) |
| `PHONE_CALL` | a contact was called: `key`, `verb` (the row's `call`) and `arg`. **Route it** to whatever handles missions or a dispatcher, or to a chat |
| `PHONE_MESSAGE_OUT` | the player sent a message: `key` the thread, `arg` the text. Delivering it is the game's |
| `PHONE_MESSAGE_IN` | a message arrived (`key` the thread) |
| `PHONE_ACTION` | the player pressed a button on a message: `key` the thread, `verb` and `arg` of the message |
| `PHONE_CAMERA`, `PHONE_PHOTO` | the camera app wants the game's viewfinder; take the photo (`arg` `selfie`) |
| `PHONE_WAYPOINT` | a waypoint was set at place `idx`, dropped here (-2) or cleared (-1) |
| `PHONE_JOB`, `PHONE_BUY` | a job was pressed (`idx`); a shop row was bought (`idx`, `key` its name, `arg` `ok` or `no`) |
| `PHONE_SETTING` | an option changed (`idx`, `key`, `to` its value) |
| `PHONE_NOTIFIED` | a toast came up |

## Messages, contacts and toasts

- `phone_receive(thread, name, text, action, arg, label)`: a message from the game or another player. A thread is a
  contact's key or whoever the game names (a player, a number); the newest thread is first. Unread until the player opens
  the thread, and a toast - unless they are looking at it. `action` with `label` makes a button on it.
- `phone_send(thread, text)` / `phone_send_open(text)`: the player's own, kept and said as a fact.
- `phone_contact_add(key)`, `phone_contact_add_dyn(key, name, call, arg)`, `phone_contact_remove(key)`: who is in the
  book (a row marked `known: false` until the game introduces it; one the game makes up as it goes).
- `phone_call(i)`, `phone_text(i)`: the i-th in the book called, or texted (the messages app on their thread).
- `phone_notify(title, body, icon, kind)`: a toast for four seconds, even with the phone away (at most four at a time),
  and a line in the notifications app until read (leaving that app reads them).

## The components

Each is `Name.ludic`, `Name.xml`, `Name.lss` and `Name.stories.lres` in `ui/`:

| Component | What it is | Takes |
| --- | --- | --- |
| `PhoneScreen` | toasts, and while up a frame with the status bar, the home screen or the open app, back / home / away keys, and a slot for the game's own app | nothing (it reads the phone's state and hands each part its share) |
| `PhoneStatus` | clock, signal bars, battery, unread count | `clock`, `signal`, `battery`, `unread` |
| `PhoneHome` | a grid of apps with their counts | `apps` `[{key, title, icon, badge}]` |
| `PhoneContacts` | the book: Call, and Text where allowed | `items` `[{name, portrait, text}]` |
| `PhoneMessages` | threads, and a conversation with a field to answer in and a button on a message | `threads`, `thread`, `open`, `name` |
| `PhoneJobs` | the game's jobs with their state | `items` `[{title, info, state}]` |
| `PhoneMap` | the places, the waypoint and its distance, a pin here, clear | `places`, `active`, `distance` |
| `PhoneShop` | shop rows with price and a buy button that is off when it cannot be afforded | `items`, `money` |
| `PhoneSettings` | the options: switches and choices | `items` |
| `PhoneCamera` | open the game's camera, the shutter, the selfie | nothing |
| `PhoneNotifications` | what toasts said, newest first | `items` |
| `PhoneToasts` | the cards that come up | `items` |

A game shows it like any screen: `ui_show("PhoneScreen", null, 0.0, 0.0, w, h)`, once `phone_tick` has run for the
frame; `PhoneScreen` lets the pointer through everywhere but the phone and its toasts.

**Words.** The package's own words are text keys, `t('phone.contacts.call')` and the like (37 of them). A game with a
`lang` line copies the entries of [`lang/phone.en.po`](lang/phone.en.po) into its source `.po`. The game's own words - the
apps' titles, the contacts' names, the options' labels - are the rows' `@Text` fields.

**Theming.** Colours are variables, `--ph-accent`, `--ph-ink`, `--ph-panel`, `--ph-card`, `--ph-line`, `--ph-text`,
`--ph-muted`, `--ph-good`, `--ph-bad` and `--ph-gap`, defined in `ui/theme.lss` and read by every part with a fallback, so
one part's story looks right on its own. A game restyles with its own sheet (`<PhoneScreen class="mine"/>` and
`.mine { --ph-accent: #6cf }`).

## API

| | |
| --- | --- |
| `phone_tick(t)`, `phone_reset()`, `phone_system() -> System` | once a frame; `"phone"`, `PH_PRESENT` with its save section (`phone_save`, `phone_load`): the messages and threads, the book (which rows are in it, and the added ones), the option values |
| `phone_mode()`, `phone_is_away()`, `_is_raised()`, `_in_app()`, `phone_captures_input()`, `phone_slide()`, `phone_app()`, `phone_app_key()`, `phone_app_component()`, `phone_app_builtin()` | where the phone is |
| `phone_app_count()`, `phone_app_at(i)`, `phone_app_find(key)`, `phone_badge(app)` | the home screen |
| `phone_contact_count()`, `_contact_at(i)`, `_contact_key(c)`, `_contact_name(c)` | the book |
| `phone_thread_count()`, `_thread_key(t)`, `_thread_unread(t)`, `phone_unread()`, `phone_thread_open(t)`, `phone_open_thread()`, `phone_message_count(t)`, `phone_message_press(n)` | threads |
| `phone_toast_count()`, `_toast_dismiss(i)`, `phone_notes_count()`, `_notes_unread()`, `_notes_read_all()`, `_notes_clear()` | toasts and notifications |
| `phone_job_press(i)`, `phone_place_press(i)`, `phone_place_here()`, `phone_place_clear()`, `phone_shop_buy(i)`, `phone_camera_open()`, `phone_photo(selfie)` | the game's apps |
| `phone_option_count()`, `_option_value(i)`, `_option_on(i)`, `_option_set(i, v)`, `_option_press(i)`, `phone_option_find(key)` | options |
| `phone_facts() -> Queue<PhoneFact>` | the facts |

## Tests

```bash
ludic test packages/ludic.phone
```

`phone_test` runs against a fake game (apps, a book and options from rows, fake ports): the machine and the world's
leave, the slide, the keys by edges, the home screen and its counts, the book and calls, threads, messages and their
buttons, toasts, jobs, map and shop, options, the save, and `PhoneScreen` and each app driven through `ludic.ui` (a
press leaves a fact).
