bump: minor
type: feat
`[a, b, c]` list literals build a slice in place; the first element fixes the element type, later elements must match, and `[]` is an error (use `new []T`). Tables of records read as `[Row { … }, Row { … }]`.
