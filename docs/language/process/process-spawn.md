---
id: process-spawn
name: Process.spawn
category: process
kind: namespace-method
tokens: Process.spawn
sig: Process.spawn(path, args) -> int
tip: Start a program; never blocks.
order: 0
ns: Process
member: spawn
---

Starts the program at <code>path</code> with the arguments in <code>args</code> (a <code>[]string</code>; the child's <code>argv[0]</code> is <code>path</code>) and returns a handle <code>&gt;= 0</code> straight away, or <code>-1</code> when the program could not be started — a missing file, a file that is not executable, or all 16 handles in use.

No shell is involved, so every argument reaches the child exactly as written: spaces, quotes and <code>$</code> are not interpreted. The child inherits this process's environment and working directory. On Windows the arguments are joined into one command line quoted so the child's C runtime splits it back into the same list, the path and arguments cross as UTF-8 and are converted to UTF-16, and the child is started without a console window (a GUI program is unaffected; a console program runs hidden). Use an absolute path: there is no <code>PATH</code> search.

```ludic
program Demo {
  entry {
    let h = Process.spawn("/bin/sh", ["-c", "exit 3"])
    print(h >= 0)
  }
}
```

See <a href="process-poll.html"><code>Process.poll</code></a> for the exit code.
