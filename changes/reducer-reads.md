bump: minor
type: feat
**A reducer may read other states.** `reducer Wallet on Buy(w: mut Wallet, s: Shop, a: Buy)` writes
its own state and reads the ones declared between it and the action, supplied by the drain like its
own. What only becomes known inside the drain - a value another reducer just set, the map in play,
where the save lives - no longer has to be faked into the action, and a verb that reads several
systems while it changes one is a reducer instead of an act. A second state to WRITE is still
refused, now with the way out in the message (`examples/actions/reads.ludic`).
