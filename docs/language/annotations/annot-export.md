---
id: annot-export
name: @export
category: annotations
kind: annotation
tokens: @export
sig: @export fn name(…) -> R
tip: Expose a function as a C-ABI symbol so a host can call it.
order: 3
---

<code>@export</code> makes a <code>fn</code> visible outside the module as a plain C-ABI symbol, so a host program or another linked object can call it by name. Without it, functions are internal to the compiled unit; with it, the emitted symbol is externally linkable, which is how Ludic hands entry points to a runtime seam or a foreign caller. It is the outbound counterpart to <code>extern fn</code>, which pulls a foreign symbol in. Keep exported signatures to POD scalars and pointers, since they cross a C boundary where Ludic's richer types do not apply.

```ludic
program ScoreModule {
  var running_total: int = 0

  @export fn add_points(amount: int) -> int {      # callable from a C-ABI host
    running_total = running_total + amount
    return running_total
  }

  entry {
    print(add_points(10))                           # 10
    print(add_points(5))                            # 15
  }
}
```
