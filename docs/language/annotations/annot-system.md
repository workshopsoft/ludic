---
id: annot-system
name: @System
category: annotations
kind: annotation
tokens: @System
sig: "@System(Phase) function name() { … }"
tip: Register a prebuilt binary module's system with the host at load, per phase.
order: 62
---

<code>@System(Phase)</code> marks a function in a prebuilt binary module (one compiled with <code>--emit-module</code>) as a runtime-registered system. The module carries a load-time constructor that hands each such function to the host through <code>ludic_register_system</code>, and the host's frame loop calls it every <code>Phase</code> after its own handlers — the runtime, escape-hatch counterpart of the compile-time <code>@EngineSystem</code>. The compiler supplies the function's address (Ludic source cannot take one). This is how a closed-source or other-language module contributes systems over the reflection C-ABI; source packages that compile into the consumer should prefer <code>@EngineSystem</code>. Phases are <code>Input</code>, <code>FixedUpdate</code>, <code>Update</code>, <code>LateUpdate</code> and <code>Render</code>.

```ludic
program ManaModule {
  function module_init() -> void { world_register_prop("Mana", 2) }   # register a component at load

  @System(Update) function mana_regen() -> void {                     # runs every Update in the host
    let M = world_prop_id("Mana")
    let e = world_query_next(M, 0)
    if e >= 0 { world_set(e, M, 0, world_get(e, M, 0) + 1) }
  }
}
```
