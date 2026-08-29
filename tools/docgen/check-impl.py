#!/usr/bin/env python3
"""Docs coverage, anchored to the implementation — not a hand-kept list.

The failure mode this prevents: you add a feature to the language and forget to
document it. Nobody notices until someone goes looking for the docs that were
never written. So the set of things that MUST have a doc page is read straight
from the implementation, and every one is required to have a page (and every
namespace-method page is required to correspond to something real):

  * namespace methods   selfhost/emit_expr.ludic `emit_ns_call` + the
                        `is_<ns>_ns` predicates it delegates to (Math/Text/List)
  * keywords            tools/ludic-tools/ludic_syntax.h  LUDIC_KW_* (minus
                        LUDIC_KW_RESERVED, which is not-yet-implemented)
  * primitive types     ludic_syntax.h  LUDIC_TYPES
  * phases              ludic_syntax.h  LUDIC_PHASES

Coverage means: the symbol appears in the `tokens:` of some docs/language page.
For namespace methods that page is docs/language/<ns>/<ns>-<method>.md with
token `<Ns>.<method>`. Run: python3 tools/docgen/check-impl.py
"""
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
LANG = os.path.join(ROOT, "docs", "language")
problems = []


def read(*parts):
    with open(os.path.join(ROOT, *parts), encoding="utf-8") as fh:
        return fh.read()


def fn_body(text, name):
    """The source of `function <name>` up to the next top-level `function ` (or EOF)."""
    m = re.search(r"^function %s\b" % re.escape(name), text, re.M)
    if not m:
        return ""
    rest = text[m.end():]
    nxt = re.search(r"^function ", rest, re.M)
    return text[m.start(): m.end() + (nxt.start() if nxt else len(rest))]


def all_selfhost_source():
    src = ""
    d = os.path.join(ROOT, "selfhost")
    for fn in sorted(os.listdir(d)):
        if fn.endswith(".ludic"):
            src += read("selfhost", fn) + "\n"
    return src


def compiler_ns_methods():
    """{Namespace: set(method)} the compiler actually dispatches on."""
    expr = read("selfhost", "emit_expr.ludic")
    body = fn_body(expr, "emit_ns_call")
    if not body:
        problems.append("emit_ns_call not found in selfhost/emit_expr.ludic")
        return {}
    allsrc = all_selfhost_source()
    result = {}
    # each `if (ns == "X")` opens a block that runs to the next such marker
    chunks = re.split(r'if \(ns == "', body)
    for chunk in chunks[1:]:
        mn = re.match(r'(\w+)"', chunk)
        if not mn:
            continue
        ns = mn.group(1)
        methods = set(re.findall(r'meth == "([A-Za-z_][A-Za-z0-9_]*)"', chunk))
        if not methods:
            # delegated form: `if is_<ns>_ns(meth) { return emit_<ns>_ns(...) }`
            pm = re.search(r"is_(\w+)_ns\(meth\)", chunk)
            if pm:
                pred = fn_body(allsrc, "is_%s_ns" % pm.group(1))
                methods = set(re.findall(r'meth == "([A-Za-z_][A-Za-z0-9_]*)"', pred))
        if methods:
            result.setdefault(ns, set()).update(methods)
    return result


def documented():
    """(tokens set, {(ns, member): id} for namespace-method pages)."""
    tokens = set()
    nsmethods = {}
    for cat in sorted(os.listdir(LANG)):
        cdir = os.path.join(LANG, cat)
        if not os.path.isdir(cdir):
            continue
        for fn in os.listdir(cdir):
            if not fn.endswith(".md") or fn == "_section.md":
                continue
            meta = {}
            for line in read("docs", "language", cat, fn).split("\n"):
                m = re.match(r"^(\w+):\s*(.*)$", line)
                if m:
                    meta[m.group(1)] = m.group(2).strip()
                if line.strip() == "---" and meta:
                    break
            tokens.update(meta.get("tokens", "").split())
            if meta.get("kind") == "namespace-method" and meta.get("ns") and meta.get("member"):
                nsmethods[(meta["ns"], meta["member"])] = meta.get("id", fn[:-3])
    return tokens, nsmethods


def vocab_sets():
    h = read("tools", "ludic-tools", "ludic_syntax.h")

    def clist(name):
        m = re.search(r"\b" + name + r"\s*\[\s*\]\s*=\s*\{(.*?)\}\s*;", h, re.S)
        if not m:
            problems.append("ludic_syntax.h: %s not found" % name)
            return set()
        return set(re.findall(r'"([^"]+)"', m.group(1)))

    reserved = clist("LUDIC_KW_RESERVED")
    keywords = (clist("LUDIC_KW_DECL") | clist("LUDIC_KW_CLAUSE")
                | clist("LUDIC_KW_STMT")) - reserved
    return keywords, clist("LUDIC_TYPES"), clist("LUDIC_PHASES")


def main():
    ns_impl = compiler_ns_methods()
    tokens, ns_doc = documented()

    # 1) every implemented namespace method has a page with the right token
    for ns, methods in sorted(ns_impl.items()):
        for meth in sorted(methods):
            page = os.path.join(LANG, ns.lower(), "%s-%s.md" % (ns.lower(), meth))
            if (ns, meth) not in ns_doc:
                problems.append("undocumented %s.%s — add %s (tokens: %s.%s)"
                                % (ns, meth, os.path.relpath(page, ROOT), ns, meth))
            elif "%s.%s" % (ns, meth) not in tokens:
                problems.append("%s.%s documented but its page lacks that `tokens:` entry" % (ns, meth))

    # 2) every documented namespace method corresponds to real dispatch
    for (ns, meth), sid in sorted(ns_doc.items()):
        if meth not in ns_impl.get(ns, set()):
            problems.append("stale doc %s: %s.%s is not dispatched by the compiler" % (sid, ns, meth))

    # 3) every implemented keyword / type / phase is documented
    keywords, types, phases = vocab_sets()
    for label, names in (("keyword", keywords), ("type", types), ("phase", phases)):
        for n in sorted(names):
            if n not in tokens:
                problems.append("undocumented %s: %s (no docs/language page lists it in `tokens:`)" % (label, n))

    n = sum(len(v) for v in ns_impl.values())
    if problems:
        print("docs-vs-implementation drift:", file=sys.stderr)
        for p in problems:
            print("  -", p, file=sys.stderr)
        return 1
    print("docs cover the implementation: %d namespace methods, %d keywords, %d types, %d phases"
          % (n, len(keywords), len(types), len(phases)))
    return 0


if __name__ == "__main__":
    sys.exit(main())
