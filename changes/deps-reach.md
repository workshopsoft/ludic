bump: minor
type: feat
**`ludic deps` sees through fn values, and lists the widest functions.** A step list or a registry of
fn values takes no state and still reaches every state its steps take; `widest_reach` is the most
states any function can come to - by a call, a `fn f` it writes, or a global holding fn values it
reads - reported beside `widest_function` with how many of them it does not take itself
(`the widest reach: app_boot (src/app/boot.ludic:30), 72 states (72 through calls and fn values it
does not take)`). `--widest N` lists the N functions that take the most states with what each
reaches; `--reach N` orders them by reach. A baseline written before this has no `widest_reach` and
does not hold it until it is rewritten.
