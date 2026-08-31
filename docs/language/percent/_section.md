---
id: percent
title: Percent
order: 16
---

A value clamped to <code>[0, 1]</code> — health fractions, volumes, and the <code>t</code> of an interpolation, without stray values slipping below 0 or above 1. <code>Percent.clamp</code> pins any <code>fixed</code> into range; <code>Percent.of</code> forms a clamped ratio <code>num / den</code>; <code>Percent.lerp</code> interpolates <code>a..b</code> by a clamped <code>t</code>; and <code>Percent.apply</code> scales a value by a clamped fraction. Every operation is deterministic fixed-point. Arguments are positional. Spliced in only when a program mentions <code>Percent.*</code>.
