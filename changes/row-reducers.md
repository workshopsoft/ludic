bump: minor
type: feat
**A reducer on a table's row** (phase 27.3). An action names one row of a ludic.base `Table<T>` by
its handle, in a field marked `@Target`, and `reducer Deer in Herd.deer on Spook(r: mut Row<Deer>,
n: Noise, a: Spook)` runs once, for that row alone (the table may sit down a path, `WildState.w.tab`).

- **The drain resolves the handle** (`tb_row`) and hands the reducer a `Row<T>` (new in ludic.base:
  `tb`, `row`, `h`, `rec`) that it keeps, one per row reducer, filled in place: a targeted action
  allocates nothing. A stale handle runs nothing; `LUDIC_ACTIONS_LOG=1` prints a line for it. Row
  reducers order among an action's reducers by their state's name, then the table's path.
- **The row goes no further**, checked at compile time: a row reducer reaches `r.rec` and `r.h`, not
  `r.tb` or `r.row`; it does not assign, store, copy or hand on the row except to a `@RowVerb` (a
  function of the record's own module taking `Row<T>` first); a field marked `@Column` (a table
  column mirrors it) is written only by a verb; only the module owning the state declares a row
  reducer; states between the row and the action are read. `mut` is allowed on a `Row<T>` parameter.
- **`ludic schema`'s code section** gains `row_reducers` (`record`, `table`, `state`, `action`,
  `target`, `predicted`, `net`, `module`, `at`) and `row_verbs` (`name`, `record`, `module`, `at`),
  and every action its `target`; row reducers are not listed under `reducers`. `ludic deps` names a
  row reducer `reducer Deer in Herd.deer on Spook`; ludic-lsp's outline does too.
- Examples `actions/rows`; rejects for a missing `@Target`, two of them, a `@Column` write, reaching
  the table, a row handed to a non-verb, a table that is not one, the parameter shape, a second
  state written, a verb with no row, and a reducer outside the state's module. `@Predicted`, `@Net`
  and `@Broadcast` on actions and row reducers are later steps of phase 27.
