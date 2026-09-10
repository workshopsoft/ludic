bump: patch
type: perf
**Ground cover stops re-growing itself.** Walking a streamed world hitched, and the
hitch got worse the longer you played. Measured in the Maroon Lake game, with a new hitch
report rather than guessed at.

**The chunk cache had a cliff, not a slope.** A stream cached 4096 chunks and then
stopped remembering: past that the chunk was generated, used for one frame and thrown
away, so every ring walk regenerated it, for the rest of the session. It arrives after
enough of the map has been walked — six evictions' worth over seven kilometres, so an
ordinary session reaches it — and it is the point where cover starts visibly re-growing
as you turn. `stream_evict` now drops the half of the cache nobody has asked for in the
longest time (chunks carry the walk that last wanted them) and rebuilds the index over
what is left. Over a 7 km traversal: generation total **9073 ms → 2230 ms**, the worst
single frame's generation **11.4 ms → 3.1 ms**, median frame 10.8 → 9.0 ms. With a cache
deliberately sized to saturate early, the same run goes from 2748 frames generating to
1548, and from a 13.3 ms median to 9.2. `R3D_NOEVICT` restores the old behaviour for
comparison, `R3D_STREAM_CAP=<n>` sets the cache size.

The other half of that hitch was in the game's own cover generator, and went with it to
the Maroon Lake game's repository: its candidates were paying for a second noise field, four
height samples and a path distance before the drift field that rules out most of the
meadow — 2341 µs → 518 µs per chunk, bit-identical output. Worth repeating in any
generator: a `stream_fill` is called for tens of thousands of candidates per chunk, so
the order of its tests is most of its cost.

**The hitch report** (`R3D_PROF=1`) is what found both. It prints the slowest frames of
the run with what was in each: CPU versus GPU wait, cover generated, instance bytes
uploaded, the game's own tick, and the renderer phase that took longest. Alongside it,
per-chunk generation cost by stream and band, a census of what the caches hold, and a
stutter figure — the frame time a run spent beyond 1.2x its own median — because a mean
cannot show a hitch and a maximum is one unlucky frame.

It also found two content bugs in the game it was measured on, which is the report doing
its job: a cover stream whose placement rule never fires still pays full generation cost,
and the census makes that visible — 3364 cached chunks holding zero instances.
