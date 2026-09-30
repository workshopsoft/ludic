bump: minor
type: feature
**`ludic.anim`: a clip's planned length; `ludic.base`: where a signal source's words come from.**
`AnimClipInfo` gains `@Unit("s") duration: float` (0: unknown), the length a clip is planned to have before
it is authored; the studio's graph simulation and problems read it (`clip_duration: "duration"` in
ludic.anim's studio.lres) and the runtime ignores it, since the real clip's own length wins once it exists.
`SignalSource` gains `words: string`, `"Registry.field"` entries comma separated, naming the table the words
of a fact or text source come from; `ludic.cars` (the seat `state_*` fields) and `ludic.weapons` (the class
`clip_*` fields and `hold`) fill it, so a studio can check by-name bindings without the game running.
