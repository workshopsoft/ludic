---
id: promise
title: Promise
order: 38
---

Combine several <code>Job</code> futures and resolve the group on the main thread. <code>Promise.all</code> succeeds once every member has, <code>Promise.race</code> once the first does; both return an ordinary job handle you poll like any other. For a loading screen, <code>Promise.count_done</code> over the same handles is the bar's numerator and <code>len</code> the denominator, and <code>Promise.all_done</code> is the ready check. Ludic has no closures, so progress is polled rather than chained through a <code>then</code> callback. Build the handle list with <code>new []int</code> + <code>push</code>. Spliced in only when a program mentions <code>Promise.*</code>.
