---
id: hash
title: Hash
order: 6
---

Fast, non-cryptographic hashing for everyday game needs: turning string IDs into integer handles, mixing a few numbers into one deterministic seed, and checksumming data to catch corruption. Every function is plain 32-bit integer arithmetic with a defined byte order and fixed constants, so a given input hashes to exactly the same value on every platform and every run — the guarantee that makes it safe for procedural generation and lockstep networking. Results are 32-bit and print as signed integers. Arguments are positional.

Not for security. These hashes are fast and reversible — never use them for passwords, tokens, or tamper-proofing. For secure hashing reach for the cryptography library instead.
