---
id: date
title: Date
order: 6
---

Calendar days on the proleptic Gregorian calendar (UTC). A <code>Date</code> is stored as a plain <code>int</code>: the count of days since 1970-01-01, so shifting a date by whole days is ordinary integer arithmetic and two dates subtract to a day count. Build one with <code>Date.new</code>, read its parts with <code>year</code>/<code>month</code>/<code>day</code>/<code>weekday</code>. Every operation is deterministic integer math — no leap seconds, no timezone, no floating point.
