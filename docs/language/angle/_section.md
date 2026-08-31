---
id: angle
title: Angle
order: 15
---

An auto-wrapping angle in radians, so you never juggle <code>% TAU</code> by hand. Every <code>Angle.*</code> result is normalized into <code>[-pi, pi)</code>, which makes <code>diff</code> the shortest signed rotation between two headings and <code>lerp</code> turn the short way around. Build from degrees with <code>Angle.from_degrees</code> (read back with <code>to_degrees</code>), take <code>sin</code> / <code>cos</code>, combine with <code>add</code>, and normalize any raw value with <code>wrap</code>. It builds on the deterministic fixed-point <code>Math.*</code> trig, so results are bit-identical on every platform. Arguments are positional; angles are <code>fixed</code> radians. Spliced in only when a program mentions <code>Angle.*</code>.
