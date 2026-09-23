bump: minor
type: feat
**A `numbers float` file is strict about where its numbers come from.** Two rules, both found
converting a renderer and a game from float bits in an `int` to real floats:

- A decimal literal takes the kind of what it meets. `factor == 0.0` against a `fixed` parameter,
  `half(3.0)` into a `fixed` one and `var z: fixed = -1.5` are `fixed` literals there, rather
  than a `fixed` and a `float` that do not mix.
- A computed integer never becomes a float implicitly. `count < limit` with an `int` on one side
  and a `float` on the other is an error that asks for `float(x)`: in a file whose numbers are
  floats, an `int` meeting one is almost always raw bits, and promoting it compares the bits as a
  number. It caught a uniform fed an integer as float bits, and a test comparing a tint's bits
  with its value. Integer constants still promote, and `float(x)` is always allowed.
