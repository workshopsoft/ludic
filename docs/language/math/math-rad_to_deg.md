---
id: math-rad_to_deg
name: Math.rad_to_deg
category: math
kind: namespace-method
tokens: Math.rad_to_deg
sig: Math.rad_to_deg(radians) -> fixed
tip: Convert radians to degrees.
order: 19
ns: Math
member: rad_to_deg
---

Converts an angle from radians to degrees (multiplying by <code>180/pi</code>) — the inverse of <code>Math.deg_to_rad</code>. Use it to present an internally-radians angle in the degrees a player or designer expects, for a HUD readout or a debug overlay.

```ludic
program Demo {
  handler Step phase Update {
    let heading_deg = Math.rad_to_deg(heading)
  }
}
```
