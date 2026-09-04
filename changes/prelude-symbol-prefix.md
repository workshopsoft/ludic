bump: patch
type: fix
Hand-written runtime preludes (string, Os.*, Fs.*, Crypto.*, …) now live under their own `@lp_` symbol prefix, so a user `function` named `is_ws`, `str_eq`, `path_join` and the like no longer collides with them at link time.
