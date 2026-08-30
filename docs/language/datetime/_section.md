---
id: datetime
title: DateTime
order: 6
---

Instants on the wall-clock timeline (UTC), stored as a plain <code>int</code>: the count of seconds since 1970-01-01, matching <code>Time.now</code>. Build one with <code>DateTime.from</code>, shift it by a <code>Duration</code> with <code>DateTime.add</code>, and pull it apart with the <code>year</code>/<code>month</code>/<code>day</code>/<code>hour</code>/<code>minute</code>/<code>second</code> readers. Deterministic integer math throughout; v1 is UTC-only with no leap seconds, and assumes instants at or after 1970.
