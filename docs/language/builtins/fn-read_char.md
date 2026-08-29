---
id: fn-read_char
name: read_char
category: builtins
kind: builtin
tokens: read_char
sig: read_char() -> int
tip: Read one byte from standard input, or -1 at end of input.
order: 24
---

Reads a single byte from standard input and returns its value, or <code>-1</code> when the input has ended. It is the foundation for headless, pipe-driven runs: a test or tool can feed the program a stream of bytes and process them one at a time, looping until <code>read_char</code> returns <code>-1</code>. Compare the byte against character literals such as <code>'a'</code> to interpret it. It takes no arguments and advances through the input on each call.

```ludic
program CountInputBytes {
  handler DrainInput phase Start {
    var byte_count: int = 0
    var next_byte = read_char()
    while next_byte != -1 {
      byte_count = byte_count + 1
      next_byte = read_char()
    }
    print(byte_count)
  }
}
```
