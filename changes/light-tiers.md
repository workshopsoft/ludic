bump: minor
type: feat
**Lighting render-quality tiers (#49).** The 2D light pass gains the tiers 3-4
from the original proposal, all on the same deterministic accumulation core:
`Light.spot` cone/flashlight lights (direction + spread), a `Light.falloff`
exponent (linear → quadratic → …), `Light.soft` soft shadows (occluder edges
fade through a penumbra), `Light.gel` colour cookies (centre → rim tint),
normal-mapped surfaces via `Light.normal` + `Light.height` (surfaces shade by
facing, N·L), and a `Light.time_of_day` day/night ambient ramp. The engine
lighting system consumes matching optional `Light2D` fields
(`direction`/`spread`/`falloff`/`softness`/`gel`) too. Every tier is integer +
Q16.16 fixed, so scenes light identically on every run and headless.
