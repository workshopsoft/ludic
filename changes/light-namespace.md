bump: minor
type: feat
2D lighting — the `Light.*` namespace: a deterministic software light-accumulation pass over the framebuffer. `Light.ambient` modulates the scene toward a tint (night/cave mood), `Light.point` adds a radial glow with linear falloff clamped per channel, and `Light.occlude`/`Light.clear_occluders` cast hard shadows by blocking a light's rays against rectangular occluders. Integer + Q16.16 fixed, so a scene lights identically every run and in a headless render.
