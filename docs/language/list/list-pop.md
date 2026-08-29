---
id: list-pop
name: List.pop
category: list
kind: namespace-method
tokens: List.pop
sig: List.pop(s) -> T
tip: Remove and return the last element.
order: 5
ns: List
member: pop
---

Removes the final element of <code>s</code> and returns it, shortening the slice by one. Together with <code>List.push</code> this makes a slice work as a stack: push to add, pop to take the most recent back off. The slice must be non-empty. Use it to unwind a history, process a work list, or undo the last action.

Parameters:
- `s` — a non-empty slice

```ludic
program UndoStack {
  var history: []int = new []int

  handler Undo phase Update {
    if List.len(history) > 0 {
      let last_action = List.pop(history)
    }
  }
}
```
