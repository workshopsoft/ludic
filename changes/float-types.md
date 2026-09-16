bump: minor
type: feat
`float` and `double`: IEEE floating point with ordinary operators, so renderer math reads
`a * b + c` instead of `f_add(f_mul(a, b), c)`.
- Decimal literals take their type from context (`let s: float = 0.1` is exactly 0.1), and
  stay `fixed` elsewhere, so existing programs keep their meaning.
- `int`/`long` promote; `float(x)`, `double(x)`, `int(x)`, `long(x)` and `fixed(x)` convert.
- `floats(n)` / `doubles(n)` buffers; float fields, globals, constants and parameters.
- `Math.*` computes in float when given one; `string`/`print`/interpolation write the
  shortest round-tripping decimal; `float_bits` / `float_from_bits` expose the IEEE pattern.
- `@deterministic` code may not use floats (it is now checked).
