---
id: json-free_all
name: Json.free_all
category: json
kind: namespace-method
tokens: Json.free_all
sig: Json.free_all(value) -> void
tip: Give back a parsed tree whole, strings and keys included.
order: 4
ns: Json
member: free_all
---

<a href="json-free"><code>Json.free</code></a> and every string value and object key the parser made as well: for a reader that copied whatever it keeps (<code>s[0 .. len(s)]</code>), so the whole document goes. A text read, parsed and let go this way leaves nothing behind.

```ludic
program FreeAll {
  entry {
    let doc = Json.parse("{\"name\": \"camp\"}")
    let s = value_as_str(value_get(doc, "name"))
    let name = s[0 .. len(s)]
    Json.free_all(doc)
    print(name)
  }
}
```
