bump: patch
type: fix
**`Http.text` and `Http.header` return copies.** They handed back the handle's own buffer (and on macOS the
response object's string), which `Http.free` then released: a text read before the free and used after it
was garbage or empty - maroon-lake's map list wrote a 0-byte maps.json. Each call now returns a string that
is the caller's to keep. Read a body once per response.
