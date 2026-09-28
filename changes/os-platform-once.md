bump: patch
type: fix
**`Os.platform()` and `Os.arch()` allocate nothing after the first call.** Each call malloc'd an
8 KB `uname` buffer and let it go, and a game asks the platform every frame in places (a launcher's
wait, an update panel, a renderer's present). The buffer is made once and kept.
