---
id: fn-arg_count
name: arg_count
category: builtins
kind: builtin
tokens: arg_count
sig: arg_count() -> int
tip: The number of command-line arguments, counting the program name.
order: 50
---

Returns how many command-line arguments the program received, including the program name at index <code>0</code>. So a program run with no user arguments reports <code>1</code>, and each added argument raises the count by one. Use it to validate that the required arguments were supplied and to bound the index you pass to <code>arg</code>. It takes no arguments and is the natural companion to <code>arg</code> when building command-line tools.

```ludic
program PrintAllArgs {
  handler ListArgs phase Start {
    print(arg_count())
    for index in 0 .. arg_count() {
      print(arg(index))
    }
  }
}
```
