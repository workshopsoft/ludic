---
id: uuid-to_text
name: Uuid.to_text
category: uuid
kind: namespace-method
tokens: Uuid.to_text
sig: Uuid.to_text(id) -> string
tip: The canonical text form of a UUID.
order: 7
ns: Uuid
member: to_text
---

Returns the canonical 36-character text form of <code>id</code>. Because this library already represents every UUID as its canonical lowercase text, <code>to_text</code> is the identity function — it exists so intent is explicit at the point where a UUID is turned into a string for display, storage, or a wire payload, and so code stays correct if the internal representation ever changes to a packed 128-bit value.

Parameters:
- `id` — the UUID to render

```ludic
program ToText {
  entry {
    let id = Uuid.new()
    print(len(Uuid.to_text(id)))   # 36
  }
}
```
