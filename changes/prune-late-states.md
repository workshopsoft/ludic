bump: patch
type: fix
**`ludic migrate state --prune` keeps a state declared after a plain parameter, and a parameter named twice is refused.**
A function like `home_keep(r: Records, save_st: mut Save)` was taken to lack `save_st`, and the
prune gave it a second one at the front (`home_keep(save_st: mut Save, r: Records, save_st: mut
Save)`) - which `ludic build --check` let through and clang then refused. The migration now counts a
state anywhere in the list as declared, and the checker refuses a function that names two parameters
alike (`add names two parameters n`).
