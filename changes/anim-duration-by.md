bump: minor
type: feat
ludic.anim: `AnimStateDef.duration_by` names a parameter of seconds and plays the state's clip over that time (rate = clip length / seconds, off while the parameter is 0 or less), so a reload clip ends with the magazine whatever the weapon's reload time: a `weapons.RELOAD_STARTED` row with `also: "reload_time"` feeds it. The graph checks the parameter exists (`anim.unknown_param`) and ludic.anim's studio.lres binds the field (`node_duration_by`).
