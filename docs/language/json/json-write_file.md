---
id: json-write_file
name: Json.write_file
category: json
kind: namespace-method
tokens: Json.write_file
sig: Json.write_file(value, path) -> bool
tip: Write a value tree to a file as JSON, keeping nothing.
order: 5
ns: Json
member: write_file
---

Writes the tree as the same text <a href="json-encode"><code>Json.encode</code></a> would give, straight to <code>path</code>: to <code>path.tmp</code> first and then renamed over it, as <code>Fs.write_text</code> does, so a crash mid-write leaves the previous file whole. The text is built in a buffer the runtime keeps and grows only for a document bigger than any before, so a game can save as often as it likes and hold nothing more for it - where <code>Json.encode</code> hands back a string of its own every time. False when the file cannot be written.

```ludic
program Save {
  entry {
    let o = Value.object()
    Value.put(o, "day", Value.int(3))
    let path = Os.temp_dir() + "/save_doc.json"
    print(Json.write_file(o, path))
    Fs.remove(path)
  }
}
```
