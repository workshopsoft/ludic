---
id: fn-serialize
name: serialize / apply
category: networking
kind: builtin
tokens: serialize apply
sig: serialize(e, buf) -> int   apply(e, buf, len)
tip: Compiler-generated per-model replication of @Sync fields.
order: 4
---

Generated from the ECS schema per model: <code>serialize</code> writes an entity's <code>@Sync</code> fields into <code>buf</code> and returns the length; <code>apply</code> folds received bytes back onto an entity. Together they are the replication substrate the sugar builds on.
