bump: minor
type: feature
**`ludic.devlink`: verbs are declared by whoever owns them, with their argument shapes.** A game or any
package adds a verb with `def DevVerbs goto { args: "x:float z:float yaw:float?", run: fn goto_verb }`
(`DevVerbs`, `DevCall` and the `dv_*` readers and reply writers are `ludic.base`'s, so a mechanic needs nothing
but `ludic.base`). Devlink reads each request against the shape (`int`, `float`, `string`, `bool`, `?` for
optional; a wrong one is `err bad_args "bad arguments: goto x:float z:float yaw:float?"`) and a verb that takes
a while answers later by id through `late`. `hello` keeps its six v1 values (the verb list now includes the
declared verbs) and adds a seventh with every declared verb's shape: `"goto x:float z:float yaw:float?;weather key:string"`.

**Breaking for a game that binds `DevlinkWorld`:** `teleport`, `load_map`, `map_state`, `set_time` and
`set_weather` are gone; `goto`, `map_load`, `time` and `weather` are now verbs the game declares. The core
verbs (`hello`, `ping`, `cam_*`, `shot`, `pause`, `resume`, `step`, `ui_*`) stay in devlink.
