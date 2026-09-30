---
id: annot-machine
name: @Machine
category: annotations
kind: annotation
tokens: @Machine
sig: @Machine(Deer.mood) registry DeerSteps of DeerStep from "deer_steps.lres"
tip: A registry of a state machine's transitions over an enum field of a table's rows: the compiler writes its reducers and tick.
order: 84
---

<code>@Machine(Record.field)</code> marks a registry as the transitions of a state machine over that enum field of the records a state's <code>Table&lt;Record&gt;</code> holds. The registry's record has <code>from</code> and <code>to</code> (the enum's variants), <code>on</code> (an action's name, or <code>""</code> for a transition the tick asks), and a <code>guard</code> and an <code>enter</code> taking the row first. The start is the field's default. The compiler writes a row reducer for each action an <code>on</code> names and, for the guard-only transitions, <code>&lt;registry&gt;_tick</code>; each takes the first transition from the row's state whose guard passes, sets the field and runs <code>enter</code>. Nothing else writes the field. A state never reached, a state with no way out, an <code>on</code> naming no action (or one with no <code>@Target</code>), a self-transition with no guard and a second way out behind an unguarded first on one trigger are compile errors.

```ludic
# doc-check: skip — a fragment: the record, the table's state and the functions are elsewhere
property DeerStep {
  from: Mood = Mood.Calm
  to: Mood = Mood.Calm
  on: string = ""
  guard: fn(Row<Deer>, Herd) -> bool = null
  enter: fn(Row<Deer>, Herd) -> void = null
}
@Machine(Deer.mood) registry DeerSteps of DeerStep from "deer_steps.lres"
```
