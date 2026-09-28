---
id: json-free
name: Json.free
category: json
kind: namespace-method
tokens: Json.free
sig: Json.free(value) -> void
tip: Give back a parsed tree's nodes; its strings stay.
order: 3
ns: Json
member: free
---

Gives back every node and list of a tree <a href="json-parse"><code>Json.parse</code></a> made, once what it describes has been built. Ludic has no garbage collector, so a tree read and dropped is otherwise kept for as long as the program runs. The tree's strings stay, because a reader may keep a name it took out of it; when nothing was kept, <a href="json-free_all"><code>Json.free_all</code></a> gives those back too. Only for a parsed tree: one put together by hand may share a node or hold a literal.

```ludic
program Free {
  entry {
    let doc = Json.parse("{\"hp\": 3}")
    let hp = value_as_int(value_get(doc, "hp"))
    Json.free(doc)
    print(hp)
  }
}
```
