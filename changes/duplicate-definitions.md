bump: minor
type: feat
**A name is defined once, for every kind of declaration.** Two functions with one name were
already an error; two `var`s or `const`s (or an enum and a const), or two `property` / `event`
records, kept the first definition silently. A game lost months to it: two files both said
`KEY_LEFT`, one meaning an arrow key's code and one a binding slot, and the menus read the slot.
They are now an error that names both files and lines. `examples/rejected/` holds the two cases,
checked by a new `reject_case` in the test runner (an example the compiler must refuse).
