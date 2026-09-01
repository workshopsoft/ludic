---
id: base64-decode
name: Base64.decode
category: base64
kind: namespace-method
tokens: Base64.decode
sig: Base64.decode(src: string) -> string
tip: Decode standard base64 text to bytes.
order: 1
ns: Base64
member: decode
---

Decodes base64 <code>src</code> to the bytes it represents, returned as a NUL-terminated string. ASCII whitespace is ignored and <code>=</code> padding ends the stream. For binary payloads that may contain a NUL byte, decode into a sized buffer at the runtime level and track the returned length instead.
