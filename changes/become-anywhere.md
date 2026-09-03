bump: patch
type: fix
`become Scene` now works from an `@On(Event)` listener, a global handler, or a plain function (#91). Code outside a scene's own layers cannot know the leaving scene at compile time, so the compiler emits `@L_scene_leave()` — a dispatch on the live scene id that runs its `on exit` — and calls it there. Previously a listener's `become` reused the last emitted handler's scene (or crashed), and a global handler's `become` skipped the leaving scene's `on exit` entirely.
