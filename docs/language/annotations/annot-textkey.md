---
id: annot-textkey
name: @TextKey
category: annotations
kind: annotation
tokens: @TextKey
sig: @TextKey("steps") registry StepKinds of StepKind from "steps.lres"
tip: The prefix of a registry's derived text keys, in place of its name in snake case.
order: 73
---

A registry's <code>@Text</code> fields are keyed <code>&lt;registry&gt;.&lt;row&gt;.&lt;field&gt;</code>, the registry's name in snake case (<code>GearKinds</code> is <code>gear_kinds</code>). <code>@TextKey("steps")</code> names the prefix instead, so its rows' keys are <code>steps.&lt;row&gt;.&lt;field&gt;</code>. Every derived key is checked against the source language's <code>.po</code> (LANGUAGE.md, Text keys).
