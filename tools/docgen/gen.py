#!/usr/bin/env python3
"""gen.py — the Ludic documentation generator (v2).

Single source of truth:
  docs/language/<category>/<id>.md   one file per symbol (front-matter + body)
  docs/language/<category>/_section.md   section title/blurb/order
  docs/language/colors/palette.json  the named-color palette
  docs/site/site.json                landing-page messaging
  docs/site/snippets/*.ludic         real programs shown on the landing page

Outputs (into --out, default build/pages) — the whole pages-branch payload:
  index.html            the landing page
  api.html              the reference index, with fuzzy search
  <id>.html             ONE page per symbol (kw-handler.html, screen-clear.html…)
  ns-<name>.html        one overview page per namespace (Screen/Color/Input/…)
  ludic-highlight.js    the highlighter — its symbol tables, tips, per-item link
                        targets, per-parameter anchors and hover-card data all
                        generated from the sources above
  symbols.json          the machine-readable index (drives search + hover cards)
  .nojekyll

Every keyword/type/phase/builtin/namespace-method/annotation/operator/color is
addressable by its own page; named parameters and named colors are addressable
by anchor. Python standard library only.
"""
import json, os, html, re, argparse

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
ASSETS = os.path.join(os.path.dirname(os.path.abspath(__file__)), "assets")
LANG = os.path.join(ROOT, "docs", "language")
SITE = os.path.join(ROOT, "docs", "site")
HEADER_OFFSET = 84  # sticky nav height; used for scroll-margin

def esc(s): return html.escape(s or "", quote=False)
def escattr(s): return html.escape(s or "", quote=True)

def fill(tmpl, mapping):
    for k, v in mapping.items():
        tmpl = tmpl.replace("@@" + k + "@@", str(v))
    return tmpl

# ---------------------------------------------------------------------------
# parsing
# ---------------------------------------------------------------------------
FENCE = re.compile(r"```ludic\n(.*?)\n```", re.S)
PARAM = re.compile(r"^-\s*`?(\w+)`?\s*[—-]+\s*(.*)$")

def parse_doc(path):
    text = open(path, encoding="utf-8").read()
    meta, body = {}, text
    if text.startswith("---"):
        end = text.find("\n---", 3)
        if end != -1:
            for line in text[3:end].strip("\n").split("\n"):
                if line.strip() and ":" in line:
                    k, v = line.split(":", 1)
                    meta[k.strip()] = v.strip()
            body = text[end + 4:].lstrip("\n")
    return meta, body

def codeify(s):
    return re.sub(r"`([^`]+)`", r"<code>\1</code>", s)

def split_body(body):
    examples = FENCE.findall(body)
    body = FENCE.sub("", body)
    # pull out a "Parameters:" block
    params, keep = [], []
    lines = body.split("\n")
    i, n = 0, len(lines)
    while i < n:
        if lines[i].strip().lower().startswith("parameters:"):
            i += 1
            while i < n and lines[i].strip():
                m = PARAM.match(lines[i].strip())
                if m:
                    params.append({"name": m.group(1), "desc": codeify(m.group(2).strip())})
                i += 1
        else:
            keep.append(lines[i]); i += 1
    desc = "\n".join(keep).strip()
    paras = [codeify(p.strip()) for p in re.split(r"\n\s*\n", desc) if p.strip()]
    return "</p><p>".join(paras), examples, params

def load_sections():
    sections = []
    for cat in sorted(os.listdir(LANG)):
        cdir = os.path.join(LANG, cat)
        if not os.path.isdir(cdir):
            continue
        smeta, sblurb = {}, ""
        sp = os.path.join(cdir, "_section.md")
        if os.path.exists(sp):
            smeta, sbody = parse_doc(sp)
            sblurb = codeify(sbody.strip())
        entries = []
        for fn in sorted(os.listdir(cdir)):
            if not fn.endswith(".md") or fn == "_section.md":
                continue
            meta, body = parse_doc(os.path.join(cdir, fn))
            desc, examples, params = split_body(body)
            meta["desc_html"] = desc
            meta["examples"] = examples
            meta["params"] = params
            meta["tokens_list"] = meta.get("tokens", "").split()
            meta["related_list"] = meta.get("related", "").split()
            entries.append(meta)
        entries.sort(key=lambda e: (int(e.get("order", 999)), e.get("name", "")))
        sections.append({"id": smeta.get("id", cat), "title": smeta.get("title", cat.title()),
                         "order": int(smeta.get("order", 999)), "blurb": sblurb,
                         "cat": cat, "entries": entries})
    sections.sort(key=lambda s: (s["order"], s["title"]))
    return sections

# ---------------------------------------------------------------------------
# symbol model for the highlighter + search + cards
# ---------------------------------------------------------------------------
def ns_page(nsname): return "ns-" + nsname.lower()

def build_symbols(sections, palette):
    sym = {"keywords": {}, "types": {}, "phases": {}, "builtins": {},
           "nsmethods": {}, "annotations": {}, "namespaces": {}, "tips": {},
           "cards": {}, "colors_page": "ns-color"}
    items = {}          # id -> full record for search
    for s in sections:
        for e in s["entries"]:
            eid = e["id"]; kind = e.get("kind", ""); tip = e.get("tip", "")
            page = eid + ".html"
            items[eid] = {"id": eid, "name": e.get("name", ""), "sig": e.get("sig", ""),
                          "kind": kind, "category": s["id"], "section": s["title"],
                          "tip": tip, "page": page}
            sym["cards"][eid] = {"name": e.get("name",""), "sig": e.get("sig",""),
                                 "tip": tip, "kind": kind, "page": page, "section": s["title"]}
            for tok in e["tokens_list"]:
                if kind == "keyword":   sym["keywords"][tok] = eid
                elif kind == "type":    sym["types"][tok] = eid
                elif kind == "phase":   sym["phases"][tok] = eid
                elif kind == "builtin":
                    sym["builtins"][tok] = {"id": eid, "params": [p["name"] for p in e["params"]]}
                elif kind == "namespace-method":
                    sym["nsmethods"][tok] = {"id": eid, "params": [p["name"] for p in e["params"]]}
                elif kind == "annotation":
                    sym["annotations"][tok] = eid
                if tip: sym["tips"][tok] = tip
    # namespaces: Screen/Input/Random/Map from ns methods, plus Color
    nsnames = set()
    for tok in sym["nsmethods"]:
        if "." in tok: nsnames.add(tok.split(".", 1)[0])
    nsnames.add("Color")
    for nn in sorted(nsnames):
        sym["namespaces"][nn] = ns_page(nn)
        sym["cards"][ns_page(nn)] = {"name": nn, "sig": nn + ".*", "kind": "namespace",
                                     "tip": NS_TIP.get(nn, ""), "page": ns_page(nn) + ".html",
                                     "section": "Namespaces"}
    return sym, items

NS_TIP = {"Screen": "The 2D drawing surface.", "Color": "The named color palette.",
          "Input": "Reading the keyboard.", "Random": "The seeded, deterministic RNG.",
          "Map": "The character-grid tilemap."}

# ---------------------------------------------------------------------------
# shared chrome
# ---------------------------------------------------------------------------
def nav_html(cfg, active=None):
    out = []
    for n in cfg["nav_links"]:
        cls = 'class="nav-cta" ' if n.get("href") == "api.html" else ""
        out.append('<a %shref="%s">%s</a>' % (cls, n["href"], esc(n["label"])))
    return "".join(out)

def head_html(title, desc, css_file):
    css = open(os.path.join(ASSETS, css_file)).read()
    return fill("""<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>@@TITLE@@</title>
<meta name="description" content="@@DESC@@">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Space+Grotesk:wght@400;500;600;700&family=JetBrains+Mono:wght@400;500;700&display=swap" rel="stylesheet">
<style>
@@CSS@@
</style>
</head>""", {"TITLE": esc(title), "DESC": escattr(desc), "CSS": css})

def topbar(cfg):
    return ('<header class="nav"><div class="wrap nav-in">'
            '<a class="brand" href="index.html"><span class="logo">L</span> %s</a>'
            '<nav class="nav-links">%s</nav></div></header>') % (esc(cfg["brand"]), nav_html(cfg))

# ---------------------------------------------------------------------------
# per-item page
# ---------------------------------------------------------------------------
def render_params(e):
    if not e["params"]:
        return ""
    rows = "".join(
        '<div class="param" id="param-%s"><code class="pname">%s</code>'
        '<span class="pdesc">%s</span></div>' % (p["name"], esc(p["name"]), p["desc"])
        for p in e["params"])
    return '<div class="params"><h2>Parameters</h2>%s</div>' % rows

def render_examples(e):
    if not e["examples"]:
        return ""
    blocks = "".join('<pre data-lang="ludic">%s</pre>' % esc(code) for code in e["examples"])
    return '<div class="examples"><h2>Example</h2>%s</div>' % blocks

def render_related(e, items):
    rel = [r for r in e["related_list"] if r in items]
    if not rel:
        return ""
    links = "".join('<a class="rel" href="%s.html">%s</a>' % (r, esc(items[r]["name"])) for r in rel)
    return '<div class="related"><h2>Related</h2><div class="rel-row">%s</div></div>' % links

def item_page(e, section, cfg, items):
    kindlabel = {"namespace-method": "method", "builtin": "function"}.get(e.get("kind",""), e.get("kind",""))
    body = fill("""@@TOPBAR@@
<main class="wrap item">
  <div class="crumbs"><a href="api.html">API Reference</a> <span>›</span> <a href="@@SECHREF@@">@@SECTION@@</a> <span>›</span> <span class="here">@@NAME@@</span></div>
  <div class="item-head">
    <span class="kind-badge kind-@@KIND@@">@@KINDLABEL@@</span>
    <h1 id="top">@@NAME@@</h1>
  </div>
  <code class="sig">@@SIG@@</code>
  <div class="desc"><p>@@DESC@@</p></div>
  @@PARAMS@@
  @@EXAMPLES@@
  @@RELATED@@
  <a class="back" href="api.html">← All symbols</a>
</main>
<script src="ludic-highlight.js"></script>
<script>Ludic.highlightAll(); Ludic.installCards(); Ludic.flashTarget();</script>
</body></html>""", {
        "TOPBAR": topbar(cfg),
        "SECHREF": "ns-" + section["cat"] + ".html" if section["cat"] in ("screen","input","random","map") else "api.html#" + section["id"],
        "SECTION": esc(section["title"]),
        "NAME": esc(e.get("name","")),
        "KIND": e.get("kind","").replace("namespace-method","method"),
        "KINDLABEL": esc(kindlabel),
        "SIG": esc(e.get("sig","")),
        "DESC": e.get("desc_html","") or esc(e.get("tip","")),
        "PARAMS": render_params(e),
        "EXAMPLES": render_examples(e),
        "RELATED": render_related(e, items),
    })
    return head_html(e.get("name","") + " — Ludic", e.get("tip",""), "item.css") + "\n<body>\n" + body

# ---------------------------------------------------------------------------
# namespace overview pages
# ---------------------------------------------------------------------------
def ns_overview_page(nsname, section, cfg):
    rows = ""
    for e in section["entries"]:
        rows += ('<a class="ns-method" href="%s.html"><code class="nm-sig">%s</code>'
                 '<span class="nm-tip">%s</span></a>') % (e["id"], esc(e.get("sig","")), esc(e.get("tip","")))
    body = fill("""@@TOPBAR@@
<main class="wrap item">
  <div class="crumbs"><a href="api.html">API Reference</a> <span>›</span> <span class="here">@@NAME@@</span></div>
  <div class="item-head"><span class="kind-badge kind-namespace">namespace</span><h1 id="top">@@NAME@@</h1></div>
  <p class="ns-blurb">@@BLURB@@</p>
  <div class="ns-methods">@@ROWS@@</div>
  <a class="back" href="api.html">← All symbols</a>
</main>
<script src="ludic-highlight.js"></script>
<script>Ludic.installCards(); Ludic.flashTarget();</script>
</body></html>""", {"TOPBAR": topbar(cfg), "NAME": esc(nsname), "BLURB": section["blurb"], "ROWS": rows})
    return head_html(nsname + " — Ludic", NS_TIP.get(nsname,""), "item.css") + "\n<body>\n" + body

def color_page(palette, cfg):
    groups = ""
    for grp in palette["groups"]:
        sw = ""
        for col in grp["colors"]:
            h = col["hex"]; nm = col["name"]; aid = nm.lower()
            sw += ('<div class="swatch" id="%s"><span class="chip" style="background:#%s"></span>'
                   '<span class="cname">Color.%s</span><span class="chex">#%s</span></div>'
                   ) % (aid, h, esc(nm), h)
        groups += '<div class="swatch-group"><h3>%s</h3><div class="swatch-row">%s</div></div>' % (esc(grp["name"]), sw)
    body = fill("""@@TOPBAR@@
<main class="wrap item">
  <div class="crumbs"><a href="api.html">API Reference</a> <span>›</span> <span class="here">Color</span></div>
  <div class="item-head"><span class="kind-badge kind-namespace">namespace</span><h1 id="top">Color</h1></div>
  <p class="ns-blurb">@@BLURB@@ Every <code>Color.Name</code> lowers to a plain <code>0xRRGGBB</code> integer at compile time — no runtime cost. @@COUNT@@ names are built in.</p>
  @@GROUPS@@
  <a class="back" href="api.html">← All symbols</a>
</main>
<script src="ludic-highlight.js"></script>
<script>Ludic.installCards(); Ludic.flashTarget();</script>
</body></html>""", {"TOPBAR": topbar(cfg), "BLURB": "The named color palette.",
                     "COUNT": palette["count"], "GROUPS": groups})
    return head_html("Color — Ludic", "The Ludic named-color palette.", "item.css") + "\n<body>\n" + body

# ---------------------------------------------------------------------------
# api index with fuzzy search
# ---------------------------------------------------------------------------
def api_index(sections, cfg):
    cards = ""
    for s in sections:
        if s["cat"] == "colors":
            cards += ('<section class="idx-sec" data-sec="%s"><h2 id="%s">%s</h2>'
                      '<p class="sec-blurb">%s</p><div class="idx-grid">'
                      '<a class="idx-item" href="ns-color.html" data-name="Color" data-tip="The named color palette.">'
                      '<code>Color</code><span>The named color palette (221 names).</span></a></div></section>'
                      ) % (s["id"], s["id"], esc(s["title"]), s["blurb"])
            continue
        rows = ""
        for e in s["entries"]:
            rows += ('<a class="idx-item" href="%s.html" data-name="%s" data-tip="%s"><code>%s</code><span>%s</span></a>'
                     ) % (e["id"], escattr(e.get("name","")), escattr(e.get("tip","")),
                          esc(e.get("name","")), esc(e.get("tip","")))
        cards += ('<section class="idx-sec" data-sec="%s"><h2 id="%s">%s</h2>'
                  '<p class="sec-blurb">%s</p><div class="idx-grid">%s</div></section>'
                  ) % (s["id"], s["id"], esc(s["title"]), s["blurb"], rows)
    body = fill("""@@TOPBAR@@
<main class="wrap ref">
  <div class="ref-intro">
    <div class="kicker">Reference</div>
    <h1>API Reference</h1>
    <p>Every keyword, type, phase, builtin, namespace method, annotation and color in Ludic — each on its own page. Search, or browse by section. In any code sample across this site, hover a token for a summary and click to jump to its page.</p>
    <input id="search" class="search" type="search" placeholder="Search symbols…  (e.g. handler, fill_rectangle, @Sync)" autocomplete="off" autofocus>
    <div id="noresults" class="noresults" hidden>No symbols match.</div>
  </div>
  @@CARDS@@
</main>
<script src="ludic-highlight.js"></script>
<script>Ludic.installCards(); Ludic.installSearch();</script>
</body></html>""", {"TOPBAR": topbar(cfg), "CARDS": cards})
    return head_html("Ludic — API Reference", "The complete Ludic API Reference: every keyword, type, builtin, namespace, annotation and color, each on its own page, with fuzzy search.", "item.css") + "\n<body>\n" + body

# ---------------------------------------------------------------------------
# landing page (data-driven, unchanged structure; highlighter now deep-links)
# ---------------------------------------------------------------------------
def read_snippet(rel): return open(os.path.join(ROOT, rel), encoding="utf-8").read().rstrip("\n")

def render_index(cfg):
    css = open(os.path.join(ASSETS, "site.css")).read()
    hero = cfg["hero"]
    navlinks = nav_html(cfg)
    hero_code = esc(read_snippet(hero["snippet"]))
    stages = ""
    for st in hero["pipeline"]:
        hl = " hl" if st == "ludicc" else ""
        stages += '<span class="stage%s">%s</span>' % (hl, esc(st))
        if st != hero["pipeline"][-1]: stages += '<span class="arrow">→</span>'
    feats = "".join('<div class="feat reveal"><div class="ico">%s</div><h3>%s</h3><p>%s</p></div>'
                    % (c["icon"], c["title"], c["html"]) for c in cfg["features"]["cards"])
    phil = cfg["philosophy"]
    phil_paras = "".join("<p>%s</p>" % p for p in phil["paras"])
    phil_stats = "".join('<div class="stat"><div class="big">%s</div><div class="lbl">%s</div></div>'
                         % (s["big"], esc(s["lbl"])) for s in phil["stats"])
    start = cfg["start"]
    steps = "".join('<div class="step reveal"><div class="n">%d</div><div><h4>%s</h4><p>%s</p></div></div>'
                    % (i, s["title"], s["html"]) for i, s in enumerate(start["steps"], 1))
    term = ""
    for t in start["terminal"]:
        if t.get("blank"): term += "\n"
        elif "comment" in t: term += '<span class="t-com"># %s</span>\n' % esc(t["comment"])
        elif "cmd" in t: term += '<span class="prompt">$</span> %s\n' % esc(t["cmd"])
        elif "out" in t: term += '<span class="out">%s</span>\n' % esc(t["out"])
    ed = cfg["editors"]
    eds = "".join('<div class="ed"><span class="k">◆</span> %s</div>' % esc(x) for x in ed["list"])
    samples = [{"name": s["name"], "label": s["label"], "note": s["note"], "code": read_snippet(s["file"])}
               for s in cfg["showcase"]["samples"]]
    footlinks = "".join('<a href="%s">%s</a>' % (n["href"], esc(n["label"])) for n in cfg["nav_links"])
    footlinks += '<a href="%s">Source ↗</a>' % cfg["repo_url"]
    m = cfg["meta"]
    tmpl = open(os.path.join(ASSETS, "index.tmpl.html")).read()
    return pct(tmpl, dict(
        css=css, brand=esc(cfg["brand"]), tagline=esc(cfg["tagline"]), repo=cfg["repo_url"],
        title=esc(m["title"]), desc=escattr(m["description"]), ogt=esc(m["og_title"]), ogd=escattr(m["og_description"]),
        navlinks=navlinks, pill=esc(hero["pill"]), title_pre=esc(hero["title_pre"]), title_accent=esc(hero["title_accent"]),
        lead=hero["lead"], pcta_h=hero["primary_cta"]["href"], pcta_l=esc(hero["primary_cta"]["label"]),
        scta_h=hero["secondary_cta"]["href"], scta_l=esc(hero["secondary_cta"]["label"]),
        hero_name=esc(hero["snippet_name"]), hero_code=hero_code, stages=stages, pipenote=hero["pipeline_note"],
        feat_kicker=esc(cfg["features"]["kicker"]), feat_title=esc(cfg["features"]["title"]), feat_intro=cfg["features"]["intro"], feats=feats,
        sc_kicker=esc(cfg["showcase"]["kicker"]), sc_title=esc(cfg["showcase"]["title"]), sc_intro=cfg["showcase"]["intro"],
        phil_kicker=esc(phil["kicker"]), phil_title=esc(phil["title"]), phil_paras=phil_paras, phil_stats=phil_stats,
        start_kicker=esc(start["kicker"]), start_title=esc(start["title"]), start_intro=esc(start["intro"]),
        steps=steps, term_name=esc(start["terminal_name"]), term=term,
        ed_kicker=esc(ed["kicker"]), ed_title=esc(ed["title"]), ed_intro=ed["intro"], eds=eds, ed_note=ed["note"],
        footlinks=footlinks, samples=json.dumps(samples),
    ))

def pct(tmpl, mapping):
    return re.sub(r"%\((\w+)\)s", lambda mm: mapping[mm.group(1)], tmpl)

# ---------------------------------------------------------------------------
def render_highlighter(symbols):
    tmpl = open(os.path.join(ASSETS, "ludic-highlight.tmpl.js")).read()
    return tmpl.replace("/*__SYMBOLS__*/{}", json.dumps(symbols, ensure_ascii=False))

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--out", default=os.path.join(ROOT, "build", "pages"))
    args = ap.parse_args()
    out = args.out
    os.makedirs(out, exist_ok=True)

    sections = load_sections()
    palette = json.load(open(os.path.join(LANG, "colors", "palette.json")))
    symbols, items = build_symbols(sections, palette)
    cfg = json.load(open(os.path.join(SITE, "site.json")))

    W = lambda name, content: open(os.path.join(out, name), "w").write(content)

    # per-item pages
    npages = 0
    for s in sections:
        if s["cat"] == "colors":
            continue
        for e in s["entries"]:
            W(e["id"] + ".html", item_page(e, s, cfg, items)); npages += 1
    # namespace overview pages
    by_cat = {s["cat"]: s for s in sections}
    for nsname, cat in (("Screen","screen"),("Input","input"),("Random","random"),("Map","map")):
        if cat in by_cat:
            W(ns_page(nsname) + ".html", ns_overview_page(nsname, by_cat[cat], cfg)); npages += 1
    W("ns-color.html", color_page(palette, cfg)); npages += 1
    # index + landing + assets
    W("api.html", api_index(sections, cfg))
    W("index.html", render_index(cfg))
    W("ludic-highlight.js", render_highlighter(symbols))
    W("symbols.json", json.dumps({"items": items, "highlight": symbols}, indent=2, ensure_ascii=False))
    W(".nojekyll", "")

    n_entries = sum(len(s["entries"]) for s in sections)
    print("docs generated -> %s" % out)
    print("  sections: %d   symbols: %d   colors: %d   item pages: %d"
          % (len(sections), n_entries, palette["count"], npages))
    print("  highlighter: %d kw / %d type / %d phase / %d builtin / %d ns-method / %d annot / %d ns"
          % (len(symbols["keywords"]), len(symbols["types"]), len(symbols["phases"]),
             len(symbols["builtins"]), len(symbols["nsmethods"]), len(symbols["annotations"]),
             len(symbols["namespaces"])))

if __name__ == "__main__":
    main()
