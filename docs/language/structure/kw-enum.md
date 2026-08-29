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

An <code>enum</code> gives names to a set of related integer values so a magic-number space — a menu selection, a game mode, a machine state — reads as names instead of bare literals. Variants number themselves from `0` in declaration order, and you access one as `Name.Variant`, which is a compile-time `int` usable anywhere an int is: in `match` patterns, comparisons, and assignments. Ludic has no distinct enum runtime type yet — an enum value lives in an ordinary `int` or `var` and is saved with it — so `enum` is best understood as a readable naming layer over `int`.

```ludic
program BattleMenu {
  enum Action { Attack, Guard, Item, Flee }

  var current_action: int = Action.Attack

  handler ChooseAction phase Input {
    let pressed = Input.key()
    if pressed == 'a' { current_action = Action.Attack }
    if pressed == 'g' { current_action = Action.Guard }
    if pressed == 'f' { current_action = Action.Flee }
  }

  handler DrawWorld phase Render {
    Screen.clear(Color.MidnightBlue)
    match current_action {
      Action.Attack => Screen.draw_text(x: 8, y: 8, text: "ATTACK", color: Color.Crimson, scale: 2)
      Action.Guard  => Screen.draw_text(x: 8, y: 8, text: "GUARD", color: Color.White, scale: 2)
      _             => Screen.draw_text(x: 8, y: 8, text: "FLEE", color: Color.Gold, scale: 2)
    }
    Screen.show()
  }
}
```
