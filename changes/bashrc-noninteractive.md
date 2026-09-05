bump: patch
type: fix
The installer also covers a non-login interactive `bash` — the shell most Linux
terminal emulators start, which reads only `~/.bashrc`. That file is now created
when it is missing (its presence changes nothing else about how bash starts),
while `~/.bash_profile` is still only appended to when it already exists, since
creating that one would stop bash reading `~/.profile`.
