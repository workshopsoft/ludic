---
id: dict-new
name: Dict.new
category: dict
kind: namespace-method
tokens: Dict.new
sig: Dict.new() -> Dict
tip: Create an empty string-keyed map.
order: 0
ns: Dict
member: new
---

Creates an empty <code>Dict</code> mapping string keys to <code>int</code> values. Fill it with <code>Dict.set</code> and read it back with <code>Dict.get</code>.

```ludic
program Demo {
  handler Step phase Update {
    let bank = Dict.new()
  }
}
```
