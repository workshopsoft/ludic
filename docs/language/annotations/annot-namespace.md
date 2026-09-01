---
id: annot-namespace
name: @Namespace
category: annotations
kind: annotation
tokens: @Namespace
sig: "@Namespace(Name) function name_method(…) -> T { … }"
tip: Let a package provide a Name.method(…) namespace that dispatches to name_method.
order: 61
---

<code>@Namespace(Name)</code> registers <code>Name</code> as a namespace a package provides, so a caller can write <code>Name.method(…)</code> and the compiler dispatches it to the bare function <code>name_method(…)</code> (the namespace lowercased, an underscore, then the method). It is the package-declarable form of the built-in <code>Foo.*</code> stdlib namespaces (<code>Regex.*</code>, <code>Grid.*</code>, …): a third-party package ships the same call shape without editing the compiler. The alias goes through the same generic call path the core namespaces use and preserves the target function's return type; it only applies after every built-in namespace, so it never shadows a core one. Mark each function that backs a method (the registration is idempotent — one mark is enough to open the namespace, but marking each provider documents the surface).

```ludic
program NamespaceDemo {
  @Namespace(Coach) function coach_bonus() -> int { return 99 }
  @Namespace(Coach) function coach_double(n: int) -> int { return n + n }

  entry {
    print(Coach.bonus())        # 99  — dispatches to coach_bonus
    print(Coach.double(21))     # 42  — dispatches to coach_double
  }
}
```
