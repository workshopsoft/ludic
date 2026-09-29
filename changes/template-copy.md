bump: patch
type: fix
**A template of one string hole is a new string.** `` `{s}` `` was `s` itself (`str()` passes a string
through), so code that wrote it as a copy kept a pointer it then freed - ludic.ui's rule text named
whatever reused the bytes. It now copies, where a template with any other part already made a new
string; `str(s)` still passes through. No template in the game or the packages had a string as its lone hole.
