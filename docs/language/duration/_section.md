---
id: duration
title: Duration
order: 6
---

Spans of real time, measured in whole seconds and carried in a plain <code>int</code> — so a duration adds, subtracts and compares with the ordinary operators (<code>Duration.minutes(5) + Duration.seconds(30)</code>, <code>away &gt; Duration.hours(3)</code>). The constructors build a span from a unit; the <code>as_*</code> readers convert a span back to whole units (truncating toward zero). Integer-only, so no floating-point drift.
