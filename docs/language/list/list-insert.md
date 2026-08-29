---
id: list-insert
name: List.insert
category: list
kind: namespace-method
tokens: List.insert
sig: List.insert(s, i, v) -> void
tip: Insert an element at an index, shifting the rest up.
order: 10
ns: List
member: insert
---

Inserts <code>v</code> at index <code>i</code>, moving the elements at and after <code>i</code> one place toward the end and growing the backing buffer if needed. Use it to keep a list ordered as you build it, or to splice an item into the middle. Appending is cheaper with <code>List.push</code>.

```ludic
program Demo {
  handler Step phase Update {
    List.insert(queue, 0, next_id)   # push to the front
  }
}
```
