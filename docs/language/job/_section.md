---
id: job
title: Job
order: 37
---

Background work that stays out of the frame. A <code>Job</code> is a future — a handle to a result that lands later. Kick one off with <code>Job.run</code> (a background compute that advances a little each <code>Job.pump</code> and finishes after enough frames, so heavy work never hitches) or <code>Job.defer</code> (a future you resolve yourself with <code>Job.fulfill</code> / <code>Job.fail</code>). Poll it with <code>done</code> / <code>ok</code> / <code>failed</code> / <code>cancelled</code>, read <code>result</code> / <code>error</code>, and always collect on the main thread — a Job must never touch the ECS world directly. The scheduler is deterministic and cooperative, so the same jobs and the same budget reproduce byte-for-byte, every run and every target. For work that should use every core now, <code>Job.parallel_for(count, fn work, ctx)</code> runs <code>work(i, ctx)</code> across a pool of real OS threads and returns when all of it is done; a worker computes on what it was handed and never changes the world. Arguments are positional. Spliced in only when a program mentions <code>Job.*</code>.
