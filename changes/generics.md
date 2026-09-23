bump: minor
type: feature
**Generic records and functions.** `property Pool<T> { items: []T }`, `function first<T>(xs: []T)
-> T` and `function map<T, U>(xs: []T, f: fn(T) -> U) -> []U`; a type writes an instance as
`Pool<Thing>`, nested as deep as needed. A call's type arguments come from its arguments, or from
the declared type its result is written into, and are refused with the parameter named when
neither says. Each instance is compiled once as an ordinary record or function. `ludic-fmt` keeps
`Pool<Thing>` together while still spacing `a < b`.
