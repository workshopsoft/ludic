---
id: process-poll
name: Process.poll
category: process
kind: namespace-method
tokens: Process.poll
sig: Process.poll(handle) -> int
tip: -1 while running, else the exit code.
order: 1
ns: Process
member: poll
---

Returns <code>-1</code> while the child is still running and its exit code once it has ended; it never waits. The code is kept, so asking again gives the same answer until <a href="process-free.html"><code>Process.free</code></a>.

A child ended by a signal (macOS) answers <code>128</code> plus the signal number, as a shell reports it — <code>137</code> after <a href="process-kill.html"><code>Process.kill</code></a>, on both platforms. On Windows the code is the child's DWORD exit code as an <code>int</code>, so a crash such as <code>0xC0000005</code> arrives as a negative number (test for <code>!= 0</code>, not <code>&gt; 0</code>); a code of <code>0xFFFFFFFF</code> is reported as <code>255</code> so that <code>-1</code> always means "still running". A handle that is not one answers <code>255</code>.

```ludic
program Demo {
  var game: int = -1
  handler Watch phase Update {
    if game >= 0 {
      let code = Process.poll(handle: game)
      if code >= 0 or code < -1 {
        if code != 0 { print("the game crashed") }
        Process.free(handle: game)
        game = -1
      }
    }
  }
}
```
