bump: minor
type: feature
**`ludic.render3d`: a ground layer's `wade`.** `GroundLayer` / `GroundFill` have a `wade` - the deepest water, in
metres, a layer grows in - so a map keeps its meadow tufts and flowers out of its lakes from the row itself
(`ground_water_depth` says how deep a plane's water is over a point). Default 1000 (grows anywhere), so a row that
says nothing grows as before; a solid or shoreline layer (cattails, mussels) leaves it.
