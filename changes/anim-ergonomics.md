bump: minor
type: feat
**Animation ergonomics (#48).** An ergonomic layer over the engine-owned
SpriteAnim/Motion systems: `Anim.clip` registers named spritesheet clips and
`Anim.play(entity, "run")` plays one (or `Anim.play(entity, fps, frames, mode)`
directly); `Anim.on_frame` / `Anim.fired` arm and read frame events (the engine
flags the tick a clip lands on a frame, gameplay reacts); `Motion.to` starts a
value tween over the Motion component in one call. New fluent, engine-advanced
`Tween` handles — `Tween.to` / `Tween.chain` / `Tween.delay` build a sequence,
`Tween.value` / `Tween.done` / `Tween.parallel` / `Tween.stop` read and control
it — advanced each Update tick by an engine-owned system. All integer and
deterministic, so animation and motion reproduce exactly under replay/lockstep.
