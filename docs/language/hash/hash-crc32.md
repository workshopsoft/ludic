---
id: hash-crc32
name: Hash.crc32
category: hash
kind: namespace-method
tokens: Hash.crc32
sig: Hash.crc32(s) -> int
tip: CRC-32 checksum for corruption detection.
order: 3
ns: Hash
member: crc32
---

The <a href="https://en.wikipedia.org/wiki/Cyclic_redundancy_check">CRC-32</a> checksum of a string's bytes — the standard IEEE 802.3 variant (reflected polynomial <code>0xEDB88320</code>), the same one used by zip, gzip and PNG. Its well-known check value: <code>Hash.crc32("123456789")</code> is <code>0xCBF43926</code>. Use it to catch accidental corruption in a save file, downloaded asset, or config blob: store the checksum alongside the data and compare on load. It detects damage, not tampering — an attacker can trivially forge a matching CRC, so it is not a security check (see the section note).

Parameters:
- `s` — the string (bytes) to checksum

```ludic
program Checksum {
  entry {
    let data = "save:level=3;coins=120"
    let ck = Hash.crc32(data)     # store this next to the save; recompute on load
    print(ck)
    print(Hash.crc32(data) == ck)  # 1 — unchanged data checks out
  }
}
```
