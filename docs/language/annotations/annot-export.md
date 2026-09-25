---
id: annot-export
name: @export
category: annotations
kind: annotation
tokens: @export
sig: @export function name(…) -> R
tip: Expose a function as a native symbol so a host can call it.
order: 3
---

<code>@export</code> makes a <code>function</code> visible outside the module as a plain native symbol, so a host program or another linked object can call it by name. Without it, functions are internal to the compiled unit; with it, the emitted symbol is externally linkable, which is how Ludic hands entry points to a runtime seam or a foreign caller. It is the outbound counterpart to <code>extern function</code>, which pulls a foreign symbol in. Keep exported signatures to POD scalars and pointers, since they cross a native ABI boundary where Ludic's richer types do not apply.

```ludic
program ScoreModule {
  state ScoreModuleState {
    running_total: int = 0
  }

  @export function add_points(score_module_st: mut ScoreModuleState, amount: int) -> int {      # callable from a native host
    score_module_st.running_total = score_module_st.running_total + amount
    return score_module_st.running_total
  }

  entry (score_module_st: mut ScoreModuleState) {
    print(add_points(score_module_st, 10))                           # 10
    print(add_points(score_module_st, 5))                            # 15
  }
}
```
