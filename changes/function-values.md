bump: minor
type: feat
**Functions are values (L2).** `fn(int, float) -> bool` is a type, `fn name` is any top-level
function's value (it used to be only a thread worker's address), and a call through a local, a
global, a record field, a slice element, a parameter or a result of a function type is an
indirect call. Two different function types do not mix, a call through one checks its argument
count, and a value may be `null`. A registry can hold behaviour and a package can take
callbacks. `Job.parallel_for` still checks that its worker takes (int, pointer) and returns
nothing. `ludic-dev selfhost-build` now says why it failed instead of exiting 1 silently.
