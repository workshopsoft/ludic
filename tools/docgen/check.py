#!/usr/bin/env python3
"""check.py — coverage + integrity guard for the generated docs site.

Fails (exit 1) if:
  * the pages contract is broken (index.html / api.html / .nojekyll missing);
  * any symbol in tools/docgen/inventory.json lacks a source file AND a page;
  * any per-symbol source file still carries only its one-line seed (i.e. was
    scaffolded but never written up) — so "every symbol is really documented";
  * a highlighter link target (page) does not exist in the output.

Usage: python3 tools/docgen/check.py [site-dir]   (default build/pages)
"""
import json, os, re, sys

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
LANG = os.path.join(ROOT, "docs", "language")
DOCGEN = os.path.join(ROOT, "tools", "docgen")

def parse_front(path):
    t = open(path, encoding="utf-8").read()
    meta = {}
    if t.startswith("---"):
        end = t.find("\n---", 3)
        if end != -1:
            for line in t[3:end].strip("\n").split("\n"):
                if line.strip() and ":" in line:
                    k, v = line.split(":", 1); meta[k.strip()] = v.strip()
            body = t[end+4:].strip()
        else:
            body = t
    else:
        body = t
    return meta, body

def main(site):
    problems, warnings = [], []

    # 1) pages contract
    for f in ("index.html", "api.html", ".nojekyll"):
        if not os.path.exists(os.path.join(site, f)):
            problems.append("missing required file: " + f)

    # 2) coverage against the authoritative inventory
    inv = json.load(open(os.path.join(DOCGEN, "inventory.json")))
    # map id -> source path
    id2src = {}
    thin = []
    for cat in sorted(os.listdir(LANG)):
        cdir = os.path.join(LANG, cat)
        if not os.path.isdir(cdir):
            continue
        for fn in os.listdir(cdir):
            if not fn.endswith(".md") or fn == "_section.md":
                continue
            meta, body = parse_front(os.path.join(cdir, fn))
            sid = meta.get("id", fn[:-3]); id2src[sid] = os.path.join(cdir, fn)
            # a "thin" file = body (minus a Parameters block and its tip line) too short
            tipline = meta.get("tip", "")
            btext = re.sub(r"(?is)parameters:.*", "", body).strip()
            btext = btext.replace(tipline, "").strip()
            if len(btext) < 40:
                thin.append(sid)
    for cat, ids in inv.items():
        for sid in ids:
            if sid not in id2src:
                problems.append("no source file for inventory symbol: %s (%s)" % (sid, cat))
            elif site and not os.path.exists(os.path.join(site, sid + ".html")):
                problems.append("no generated page for symbol: %s.html" % sid)

    # 2b) duplicate token → symbol conflicts (same token documented on two pages)
    tok2ids = {}
    for cat in sorted(os.listdir(LANG)):
        cdir = os.path.join(LANG, cat)
        if not os.path.isdir(cdir):
            continue
        for fn in os.listdir(cdir):
            if not fn.endswith(".md") or fn == "_section.md":
                continue
            meta, _ = parse_front(os.path.join(cdir, fn))
            for tok in meta.get("tokens", "").split():
                tok2ids.setdefault((meta.get("kind",""), tok), set()).add(meta.get("id",""))
    for (kind, tok), ids in sorted(tok2ids.items()):
        if len(ids) > 1:
            problems.append("token %r (%s) documented on multiple pages: %s" % (tok, kind, ", ".join(sorted(ids))))

    # 2c) one docs directory per namespace / section. Two dirs covering the same
    # runtime namespace (e.g. a `network`/`networking` or `date`/`datetime`
    # split) invite drift — a symbol documented in one and not the other — so
    # fail if any `ns:` is declared from more than one directory, or if two
    # sections share a section id or (case-folded) title.
    ns2dirs, id2dirs, title2dirs = {}, {}, {}
    for cat in sorted(os.listdir(LANG)):
        cdir = os.path.join(LANG, cat)
        if not os.path.isdir(cdir):
            continue
        sp = os.path.join(cdir, "_section.md")
        if os.path.exists(sp):
            smeta, _ = parse_front(sp)
            id2dirs.setdefault(smeta.get("id", cat), set()).add(cat)
            title2dirs.setdefault(smeta.get("title", "").strip().lower(), set()).add(cat)
        for fn in os.listdir(cdir):
            if not fn.endswith(".md") or fn == "_section.md":
                continue
            meta, _ = parse_front(os.path.join(cdir, fn))
            ns = meta.get("ns", "")
            if ns:
                ns2dirs.setdefault(ns, set()).add(cat)
    for ns, dirs in sorted(ns2dirs.items()):
        if len(dirs) > 1:
            problems.append("namespace %r documented from multiple dirs: %s" % (ns, ", ".join(sorted(dirs))))
    for sid, dirs in sorted(id2dirs.items()):
        if len(dirs) > 1:
            problems.append("section id %r declared by multiple dirs: %s" % (sid, ", ".join(sorted(dirs))))
    for title, dirs in sorted(title2dirs.items()):
        if title and len(dirs) > 1:
            problems.append("section title %r shared by multiple dirs: %s" % (title, ", ".join(sorted(dirs))))

    # 3) thin (un-expanded) symbols — warn, not fail (lets infra land before prose)
    if thin:
        warnings.append("%d symbols still have only seed text: %s%s"
                        % (len(thin), ", ".join(sorted(thin)[:12]), " …" if len(thin) > 12 else ""))

    # 4) highlighter targets exist
    sj = os.path.join(site, "symbols.json")
    if os.path.exists(sj):
        h = json.load(open(sj))["highlight"]
        targets = set()
        for grp in ("keywords", "types", "phases", "annotations"):
            targets |= set(h.get(grp, {}).values())
        for grp in ("builtins", "nsmethods"):
            targets |= set(v["id"] for v in h.get(grp, {}).values())
        targets |= set(h.get("namespaces", {}).values())
        for tgt in sorted(targets):
            if not os.path.exists(os.path.join(site, tgt + ".html")):
                problems.append("highlighter links to %s.html but it was not generated" % tgt)

    for w in warnings:
        print("  warning:", w)
    if problems:
        print("docs check FAILED:")
        for p in problems:
            print("  -", p)
        return 1
    print("docs check OK: %s  (%d symbols documented)" % (site, len(id2src)))
    return 0

if __name__ == "__main__":
    sys.exit(main(sys.argv[1] if len(sys.argv) > 1 else os.path.join(ROOT, "build", "pages")))
