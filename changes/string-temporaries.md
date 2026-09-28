bump: patch
type: fix
**A string made in the middle of an expression is freed once it has been used.** `a + "/" + b` made
`a + "/"`, copied it and kept it for ever; a template made one such piece per hole, plus each
number's text; and a side of `==` built only to be compared stayed too. The compiler now frees each
of those as soon as the next `+`, the comparison or `print` has read it, and `string(n)` hands back
the start of what it allocated so its text can be freed at all. A string held anywhere - a
variable, an argument, a function's result - is left alone. A loop of 20,000 template builds grew
2.9 MB and now grows 0 (`examples/lang/string_temps.ludic`).
