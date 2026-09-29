---
id: kw-bind
name: bind
category: structure
kind: keyword
tokens: bind
sig: bind Port { member: function_name, ... }
tip: The program's answers to a port: one function per member.
order: 60
---

<code>bind</code> answers a <code>port</code>: each member names a function of the member's type. It is written once, where the program is put together, and it is the only code that knows both the asking module and the one that answers.

```ludic
# doc-check: skip — a module spans files
bind ClockWorld { rest_scale: party_rest_scale }
```
