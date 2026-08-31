---
id: testing
title: Testing
order: 34
---

A built-in testing framework in the spirit of Go's <code>go test</code>: tests live next to the code, run with one command, and report pass/fail — no harness to wire up. A <a href="kw-test"><code>test "name" { … }</code></a> block is discovered automatically and run by a synthetic entry point that prints <code>ok   - name</code> or <code>FAIL - name</code> for each, a <code>== N passed, M failed ==</code> summary, and exits non-zero if anything failed (so CI and the <code>bin/x</code> runner catch it). Inside a test, the <code>expect</code>, <code>expect_eq</code> and <code>expect_near</code> assertions check a condition and, on failure, print <code>file:line: … failed (got …, want …)</code> and mark the test failed — without aborting, so one run reports every failure. <code>expect_near</code> takes a tolerance, which is what fixed-point and accumulated-integer game math need. Everything is deterministic and compiles to a native binary, so a suite runs in the same C-free toolchain as the rest of Ludic. Coverage instrumentation is a planned follow-up. Related: <a href="kw-function"><code>function</code></a>, <a href="fn-print"><code>print</code></a>.
