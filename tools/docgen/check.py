#!/usr/bin/env python3
"""check.py — sanity-check a generated docs site before it is published.

Verifies:
  * the pages-server contract: index.html + .nojekyll exist at the root;
  * api.html and ludic-highlight.js are present;
  * every anchor the highlighter links to actually exists in api.html
    (so no code-snippet token points at a missing entry).

Usage: python3 tools/docgen/check.py <site-dir>
Exit code 1 on any failure.
"""
import json, os, re, sys

def main(site):
    problems = []
    need = ["index.html", "api.html", "ludic-highlight.js", ".nojekyll", "symbols.json"]
    for f in need:
        if not os.path.exists(os.path.join(site, f)):
            problems.append(f"missing required file: {f}")
    if os.path.exists(os.path.join(site, "symbols.json")) and os.path.exists(os.path.join(site, "api.html")):
        sym = json.load(open(os.path.join(site, "symbols.json")))
        ids = set(re.findall(r'id="([^"]+)"', open(os.path.join(site, "api.html")).read()))
        anchors = set()
        for grp in ("keywords", "types", "phases", "builtins", "nsmethods", "annotations"):
            anchors |= set(sym.get(grp, {}).values())
        anchors.add(sym.get("colors_anchor", "colors"))
        anchors.add(sym.get("annotations_anchor", "annotations"))
        for a in sorted(anchors):
            if a not in ids:
                problems.append(f"highlighter links to #{a} but api.html has no such anchor")
    if problems:
        print("docs check FAILED:")
        for p in problems:
            print("  -", p)
        return 1
    print("docs check OK:", site)
    return 0

if __name__ == "__main__":
    sys.exit(main(sys.argv[1] if len(sys.argv) > 1 else "build/pages"))
