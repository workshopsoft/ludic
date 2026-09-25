---
id: kw-enum
name: enum
category: structure
kind: keyword
tokens: enum
sig: enum Name { A, B, C }
tip: A named set of integer constants — names for a magic-number space.
order: 50
---

An <code>enum</code> gives names to a set of related integer values so a magic-number space — a menu selection, a game mode, a machine state — reads as names instead of bare literals. Variants number themselves from `0` in declaration order, and you access one as `Name.Variant`, which is a compile-time `int` usable anywhere an int is: in `match` patterns, comparisons, and assignments. When every variant is a bare name, an enum value lives in an ordinary `int` or `var` and is saved with it, so a plain `enum` is best understood as a zero-cost naming layer over `int`.

## Tagged unions — variants with payloads

A variant may also carry a **payload**, written as a parenthesized list of types after its name. Doing so turns the whole enum into a *tagged union*: a value is now one of several shapes, each with its own data, and the type remembers which.

```ludic
enum Tile { Empty, Wall, Door(int), Portal(int, int) }
```

You **construct** a variant by name — `Door(3)`, `Portal(x, y)`, or bare `Empty` for a payload-less one — and store or pass it as a value of the enum's type (`let t: Tile = Door(3)`). Each value is a small boxed record: a tag naming the variant, plus its payload.

You take one apart with <code>match</code>, binding the payload names in each arm:

```ludic
function walk_cost(t: Tile) -> int {
  match t {
    Empty        => { return 1 }
    Wall         => { return 0 }
    Door(n)      => { return 10 + n }   # n is the door's int payload
    Portal(x, y) => { return x + y }    # both fields bound in this arm
  }
}
```

A tagged `match` must be **exhaustive**: it either handles every variant or ends with a `_` catch-all. Leaving a variant out is a compile-time error (`match on Tile is not exhaustive: variant Door is unhandled`), so adding a new variant surfaces every site that must learn about it. Constructor and pattern arities are checked the same way. A plain (all-bare) enum keeps its compile-time-ordinal `Name.Variant` form and is unaffected.

```ludic
program BattleMenu {
  enum Action { Attack, Guard, Item, Flee }

  state BattleMenuState {
    current_action: int = Action.Attack
  }

  handler ChooseAction(battle_menu_st: mut BattleMenuState) phase Input {
    let pressed = Input.key()
    if pressed == 'a' { battle_menu_st.current_action = Action.Attack }
    if pressed == 'g' { battle_menu_st.current_action = Action.Guard }
    if pressed == 'f' { battle_menu_st.current_action = Action.Flee }
  }

  handler DrawWorld(battle_menu_st: BattleMenuState) phase Render {
    Screen.clear(Color.MidnightBlue)
    match battle_menu_st.current_action {
      Action.Attack => Screen.draw_text(x: 8, y: 8, text: "ATTACK", color: Color.Crimson, scale: 2)
      Action.Guard  => Screen.draw_text(x: 8, y: 8, text: "GUARD", color: Color.White, scale: 2)
      _             => Screen.draw_text(x: 8, y: 8, text: "FLEE", color: Color.Gold, scale: 2)
    }
    Screen.show()
  }
}
```
