bump: patch
type: feat
ludic.anim's studio.lres binds the rig of a graph (`rig_table: "AnimSkeletons"`, `rig_ref: "skeleton"`, `rig_file: "model"`, `rig_node: "root"`, `clip_pattern: "{prefix}_{clip}"`): the studio's animation preview and graph tools play each graph on the skeleton its own `skeleton` names, in every game that uses the package, with no entry of the game's own. Needs a studio with `rig_ref`.
