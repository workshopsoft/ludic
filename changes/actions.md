bump: minor
type: feature
**Actions and reducers.** `action PickUp { item: int }` is a typed record of something that
happened; `reducer Bag on PickUp(b: mut Bag, a: PickUp) { ... }`, in the module that owns the state,
says what it means for that one state - a reducer takes exactly its state and the action, and a
second state is refused; `dispatch PickUp { item: 7 }` queues one from anywhere. The queue is drained
at the end of every phase of the frame loop, after every phase of ludic.base's `core_tick_all`, and
where a program calls `drain_actions()`: in dispatch order, each action's reducers in the order of
their states' names, an action a reducer dispatches queued behind (a queue still growing after 64
rounds stops the program, naming the action). `ludic deps` reports `widest_function` - the most
states any function or entry point of the program takes - and `--check` ratchets it.
