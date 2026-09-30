bump: minor
type: feat
**`ludic.anim` plays animation graphs held as data: no game animates in code.** `AnimSets` grows from states, choices
and edges into what a game needs for every motion: **state machines** with nested sub graphs (and exit states), any-state
edges, conditions over float, int, bool and trigger parameters and over clip time (exit time), a fade per edge with a curve
(linear, ease, custom points), priorities and interrupt rules; **blend spaces** (`AnimBlendSpaces`), 1D and 2D with exact
weights over a triangulation made once, for locomotion, aiming and driving; **layers** - override and additive - through bone
**masks** (`AnimMasks`) with weights driven by parameters; **sync groups** and clip **markers** so feet stay together;
**clip events** (`AnimClips`) as facts gameplay and audio drain, each firing once per pass of its time, windows with
begin, end and cancel; **root motion** as a per-clip option, reported through `anim_root_take` or the `AnimRoot` port with the
body held in place; **skeletons** (`AnimSkeletons`) with canonical bone names, a root and a level of detail (update rate by
distance, layers skipped far away). Gameplay speaks to a graph only through parameters
(`anim_set_param`, `anim_set_bool`, `anim_set_int`, `anim_trigger`, `anim_request` by actor number). `anim_validate`
returns the problems a studio can show: unknown clips, bones a mask names that the rig lacks, unreachable states,
degenerate blend spaces, cycles. A tick allocates nothing (the heap is held still in a test). Sets written before keep
working unchanged. The package's `studio.lres` names everything a graph editor needs.
