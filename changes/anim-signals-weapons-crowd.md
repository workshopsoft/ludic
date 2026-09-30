bump: minor
type: feat
ludic.weapons declares `weapons.armed` (0/1 while a weapon is in hand, so an upper-body layer weighted by it is off once holstered), `weapons.held_kind` (the held class's row order plus one, 0 unarmed) and the text source `weapons.hold` (the class's `hold` name, to request by name). ludic.crowd declares `crowd.variant` (`crowd_anim_variant`): a stable 0..1 per ped from its uid, look seed and the world seed, for a graph's idle choice bands. Both READMEs document the sources.
