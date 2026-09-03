---
id: fx
title: Fx
order: 46
---

Engine-owned transient effects. A game asks for a burst of sparks or a floating number and the engine owns the rest: it moves and ages them every Update, draws them every Render after the sprites (through the camera, shake and clip), and drops them when they expire. Nothing is an entity, so a hit effect needs no component, model, handler or draw call. Velocities and lifetimes come from the seeded RNG, so a replay produces the same sparks.
