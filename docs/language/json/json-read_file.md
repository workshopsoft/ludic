---
id: json-read_file
name: Json.read_file
category: json
kind: namespace-method
tokens: Json.read_file
sig: Json.read_file(path: string) -> Value
tip: Parse a JSON file, giving its text back.
order: 6
ns: Json
member: read_file
---

Reads the file, parses it, and frees the file text, so the tree's strings are its own and no whole file is kept per read. Returns null when the file cannot be read.
