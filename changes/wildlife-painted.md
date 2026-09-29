bump: minor
type: feature
**`ludic.wildlife`: a map may paint where a species lives.** Two new `WildlifeWorld` members, both with
defaults that change nothing: `habitat_in(sp, x, z)` answers 1 inside a species' painted habitat, 0
outside and -1 where the map paints none (the kind's rule stands), and `range_at(sp, k, r)` fills the
map's k-th painted range, which is set out as painted and draws no dice. Spots, ranges, fills and
newcomers keep to the paint (`wildlife_habitat_of`, `wildlife_find_spot_of`), never under water.
