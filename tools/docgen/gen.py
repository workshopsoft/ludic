#!/usr/bin/env python3
"""gen.py — the Ludic documentation generator.

Single source of truth:
  docs/language/<category>/<id>.md   one file per keyword / type / builtin /
                                     namespace method / operator / annotation
  docs/language/<category>/_section.md   section title + blurb + order
  docs/language/colors/palette.json  the named-color palette (from palette.py)
  docs/site/site.json                landing-page messaging (hero, features, …)
  docs/site/snippets/*.ludic         the code snippets shown on the landing page

Outputs (into --out, default build/pages) — the whole pages-branch payload:
  api.html            the full API Reference, one entry per symbol
  index.html          the landing page (hero + showcase from real .ludic files)
  ludic-highlight.js  the highlighter, its symbol tables generated from the above
  symbols.json        the machine-readable symbol index (also useful to editors)
  .nojekyll

Nothing here is hand-maintained twice: add a symbol file and it appears in the
reference, is recognized + tipped + linked in every snippet, and lands in
symbols.json — automatically. Zero third-party dependencies (stdlib only).
"""
import json, os, html, re, sys, argparse

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
ASSETS = os.path.join(os.path.dirname(os.path.abspath(__file__)), "assets")
LANG = os.path.join(ROOT, "docs", "language")
SITE = os.path.join(ROOT, "docs", "site")

def esc(s): return html.escape(s, quote=False)

def fill(tmpl, mapping):
    """Placeholder substitution that never collides with % or { } in CSS/JS."""
    for k, v in mapping.items():
        tmpl = tmpl.replace("@@" + k + "@@", str(v))
    return tmpl

def pct(tmpl, mapping):
    """Substitute only %(name)s markers; leave bare % (CSS 100%, code % 2) alone.
    Replacement values are inserted literally and never re-scanned."""
    return re.sub(r"%\((\w+)\)s", lambda m: mapping[m.group(1)], tmpl)

# ---------------------------------------------------------------------------
# front-matter + body parsing (no yaml dependency)
# ---------------------------------------------------------------------------
def parse_doc(path):
    text = open(path, encoding="utf-8").read()
    meta, body = {}, text
    if text.startswith("---"):
        end = text.find("\n---", 3)
        if end != -1:
            fm = text[3:end].strip("\n")
            body = text[end + 4:].lstrip("\n")
            for line in fm.split("\n"):
                if not line.strip() or ":" not in line:
                    continue
                k, v = line.split(":", 1)
                meta[k.strip()] = v.strip()
    return meta, body

FENCE = re.compile(r"```ludic\n(.*?)\n```", re.S)

def split_body(body):
    """Return (description_html, [examples]) — fences pulled out as examples."""
    examples = FENCE.findall(body)
    desc = FENCE.sub("", body).strip()
    # author convenience: `code` -> <code>code</code> (leaves existing tags alone)
    desc = re.sub(r"`([^`]+)`", r"<code>\1</code>", desc)
    paras = [p.strip() for p in re.split(r"\n\s*\n", desc) if p.strip()]
    desc_html = "</p><p>".join(paras)
    return desc_html, examples

# ---------------------------------------------------------------------------
# load the symbol model
# ---------------------------------------------------------------------------
def load_sections():
    sections = []
    for cat in sorted(os.listdir(LANG)):
        cdir = os.path.join(LANG, cat)
        if not os.path.isdir(cdir):
            continue
        smeta, sblurb = {}, ""
        secpath = os.path.join(cdir, "_section.md")
        if os.path.exists(secpath):
            smeta, sbody = parse_doc(secpath)
            sblurb = re.sub(r"`([^`]+)`", r"<code>\1</code>", sbody.strip())
        entries = []
        for fn in os.listdir(cdir):
            if not fn.endswith(".md") or fn == "_section.md":
                continue
            meta, body = parse_doc(os.path.join(cdir, fn))
            desc, examples = split_body(body)
            meta["desc_html"] = desc
            meta["examples"] = examples
            meta["tokens_list"] = meta.get("tokens", "").split() if meta.get("tokens") else []
            entries.append(meta)
        entries.sort(key=lambda e: (int(e.get("order", 999)), e.get("name", "")))
        sections.append({
            "id": smeta.get("id", cat),
            "title": smeta.get("title", cat.title()),
            "order": int(smeta.get("order", 999)),
            "blurb": sblurb,
            "entries": entries,
        })
    sections.sort(key=lambda s: (s["order"], s["title"]))
    return sections

# ---------------------------------------------------------------------------
# build the highlighter symbol tables from the model
# ---------------------------------------------------------------------------
def build_symbols(sections):
    sym = {"keywords": {}, "types": {}, "phases": {}, "builtins": {},
           "nsmethods": {}, "annotations": {}, "tips": {},
           "namespaces": [], "colors_anchor": "colors", "annotations_anchor": "annotations"}
    namespaces = set()
    for s in sections:
        for e in s["entries"]:
            kind = e.get("kind", "")
            anchor = e["id"]
            tip = e.get("tip", "")
            for tok in e["tokens_list"]:
                if kind == "keyword":
                    sym["keywords"][tok] = anchor
                elif kind == "type":
                    sym["types"][tok] = anchor
                elif kind == "phase":
                    sym["phases"][tok] = anchor
                elif kind == "builtin":
                    sym["builtins"][tok] = anchor
                elif kind == "namespace-method":
                    sym["nsmethods"][tok] = anchor
                    if "." in tok:
                        namespaces.add(tok.split(".", 1)[0])
                elif kind == "annotation":
                    sym["annotations"][tok] = anchor
                if tip:
                    sym["tips"][tok] = tip
        if s["id"] == "colors":
            sym["colors_anchor"] = "colors"
        if s["id"] == "annotations":
            sym["annotations_anchor"] = "annotations"
    namespaces.add("Color")  # Color.* is recognized and linked to the palette
    sym["namespaces"] = sorted(namespaces)
    return sym

# ---------------------------------------------------------------------------
# render the API Reference
# ---------------------------------------------------------------------------
def render_entry(e):
    ex = ""
    for code in e.get("examples", []):
        ex += '<pre data-lang="ludic" class="ex">' + esc(code) + "</pre>"
    desc = e.get("desc_html", "")
    return (
      '<div class="entry" id="{id}">'
      '<div class="entry-head"><h3>{name}</h3><a class="anchor" href="#{id}">#</a></div>'
      '<code class="sig">{sig}</code>'
      '<p>{desc}</p>{ex}</div>'
    ).format(id=e["id"], name=esc(e.get("name", "")), sig=esc(e.get("sig", "")),
             desc=desc, ex=ex)

def render_palette(palette):
    out = ['<div class="swatches">']
    for grp in palette["groups"]:
        out.append('<div class="swatch-group"><h4>' + esc(grp["name"]) + '</h4><div class="swatch-row">')
        for col in grp["colors"]:
            h = col["hex"]
            out.append(
              '<div class="swatch"><span class="chip" style="background:#{h}"></span>'
              '<span class="cname">Color.{n}</span><span class="chex">#{h}</span></div>'
              .format(h=h, n=esc(col["name"])))
        out.append("</div></div>")
    out.append("</div>")
    return "\n".join(out)

def render_section(s, palette):
    if s["id"] == "colors":
        body = render_palette(palette)
    else:
        body = "\n".join(render_entry(e) for e in s["entries"])
    return ('<section class="ref-sec" id="{id}"><h2>{title}</h2>'
            '<p class="sec-blurb">{blurb}</p>{body}</section>').format(
            id=s["id"], title=esc(s["title"]), blurb=s["blurb"], body=body)

def render_api(sections, palette, cfg):
    css = open(os.path.join(ASSETS, "api.css")).read()
    nav = '<nav class="side">' + "".join(
        '<a href="#{i}">{t}</a>'.format(i=s["id"], t=esc(s["title"])) for s in sections) + "</nav>"
    content = "\n".join(render_section(s, palette) for s in sections)
    navlinks = "".join(
        '<a {cls}href="{h}">{l}</a>'.format(
            h=n["href"], l=esc(n["label"]),
            cls='class="nav-cta" ' if n.get("href") == "api.html" else "")
        for n in cfg["nav_links"])
    tmpl = """<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Ludic — API Reference</title>
<meta name="description" content="The complete Ludic API Reference: every keyword, type, builtin, the Screen/Color/Input/Random/Map namespaces, and the full named-color palette.">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Space+Grotesk:wght@400;500;600;700&family=JetBrains+Mono:wght@400;500;700&display=swap" rel="stylesheet">
<style>
@@CSS@@
</style>
</head>
<body>
<header class="nav">
  <div class="wrap nav-in">
    <a class="brand" href="index.html"><span class="logo">L</span> @@BRAND@@</a>
    <nav class="nav-links">@@NAVLINKS@@</nav>
  </div>
</header>
<div class="wrap ref-layout">
  @@NAV@@
  <main class="ref-main">
    <div class="ref-intro">
      <div class="kicker">Reference</div>
      <h1>API Reference</h1>
      <p>Every keyword, type, builtin, namespace and color in Ludic. In any code sample across this site, hover a token and click to jump straight to its entry here.</p>
    </div>
    @@CONTENT@@
  </main>
</div>
<script src="ludic-highlight.js"></script>
<script>
Ludic.highlightAll();
const secs = [...document.querySelectorAll('.ref-sec')];
const navlinks = [...document.querySelectorAll('.side a')];
const spy = new IntersectionObserver((entries)=>{
  entries.forEach(e=>{ if(e.isIntersecting){
    navlinks.forEach(a=>a.classList.toggle('active', a.getAttribute('href')==='#'+e.target.id));
  }});
},{rootMargin:'-10% 0px -80% 0px'});
secs.forEach(s=>spy.observe(s));
</script>
</body>
</html>
"""
    return fill(tmpl, dict(CSS=css, BRAND=esc(cfg["brand"]), NAVLINKS=navlinks, NAV=nav, CONTENT=content))

# ---------------------------------------------------------------------------
# render the landing page
# ---------------------------------------------------------------------------
def read_snippet(rel):
    return open(os.path.join(ROOT, rel), encoding="utf-8").read().rstrip("\n")

def render_index(cfg):
    css = open(os.path.join(ASSETS, "site.css")).read()
    hero = cfg["hero"]
    navlinks = "".join(
        '<a {cls}href="{h}">{l}</a>'.format(
            h=n["href"], l=esc(n["label"]),
            cls='class="nav-cta" ' if n.get("href") == "api.html" else "")
        for n in cfg["nav_links"])
    # hero snippet
    hero_code = esc(read_snippet(hero["snippet"]))
    # pipeline
    stages = ""
    for st in hero["pipeline"]:
        hl = " hl" if st == "ludicc" else ""
        stages += '<span class="stage%s">%s</span>' % (hl, esc(st))
        if st != hero["pipeline"][-1]:
            stages += '<span class="arrow">→</span>'
    # features
    feats = ""
    for c in cfg["features"]["cards"]:
        feats += ('<div class="feat reveal"><div class="ico">%s</div>'
                  '<h3>%s</h3><p>%s</p></div>') % (c["icon"], c["title"], c["html"])
    # philosophy
    phil = cfg["philosophy"]
    phil_paras = "".join("<p>%s</p>" % p for p in phil["paras"])
    phil_stats = "".join('<div class="stat"><div class="big">%s</div><div class="lbl">%s</div></div>'
                         % (s["big"], esc(s["lbl"])) for s in phil["stats"])
    # get-started steps + terminal
    start = cfg["start"]
    steps = ""
    for i, s in enumerate(start["steps"], 1):
        steps += ('<div class="step reveal"><div class="n">%d</div>'
                  '<div><h4>%s</h4><p>%s</p></div></div>') % (i, s["title"], s["html"])
    term = ""
    for t in start["terminal"]:
        if t.get("blank"):
            term += "\n"
        elif "comment" in t:
            term += '<span class="t-com"># %s</span>\n' % esc(t["comment"])
        elif "cmd" in t:
            term += '<span class="prompt">$</span> %s\n' % esc(t["cmd"])
        elif "out" in t:
            term += '<span class="out">%s</span>\n' % esc(t["out"])
    # editors
    ed = cfg["editors"]
    eds = "".join('<div class="ed"><span class="k">◆</span> %s</div>' % esc(x) for x in ed["list"])
    # showcase samples -> JS array, code read from real files
    samples = []
    for s in cfg["showcase"]["samples"]:
        samples.append({"name": s["name"], "label": s["label"],
                        "note": s["note"], "code": read_snippet(s["file"])})
    samples_json = json.dumps(samples)
    # footer links
    footlinks = "".join('<a href="%s">%s</a>' % (n["href"], esc(n["label"])) for n in cfg["nav_links"])
    footlinks += '<a href="%s">Source ↗</a>' % cfg["repo_url"]
    m = cfg["meta"]

    tmpl = """<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>%(title)s</title>
<meta name="description" content="%(desc)s">
<meta property="og:title" content="%(ogt)s">
<meta property="og:description" content="%(ogd)s">
<meta property="og:type" content="website">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Space+Grotesk:wght@400;500;600;700&family=JetBrains+Mono:wght@400;500;700&display=swap" rel="stylesheet">
<style>
%(css)s
</style>
</head>
<body>
<header class="nav">
  <div class="wrap nav-in">
    <a class="brand" href="#top"><span class="logo">L</span> %(brand)s</a>
    <nav class="nav-links">%(navlinks)s
      <a class="nav-cta" href="%(repo)s">Source ↗</a>
    </nav>
  </div>
</header>

<a id="top"></a>
<section class="hero">
  <div class="wrap hero-grid">
    <div>
      <span class="pill"><span class="dot"></span> %(pill)s</span>
      <h1>%(title_pre)s <span class="accent">%(title_accent)s</span></h1>
      <p class="lead">%(lead)s</p>
      <div class="cta-row">
        <a class="btn btn-primary" href="%(pcta_h)s">%(pcta_l)s</a>
        <a class="btn btn-ghost" href="%(scta_h)s">%(scta_l)s</a>
      </div>
    </div>
    <div class="code-card reveal">
      <div class="code-top">
        <span class="tl r"></span><span class="tl y"></span><span class="tl g"></span>
        <span class="code-name">%(hero_name)s</span>
      </div>
      <pre data-lang="ludic">%(hero_code)s</pre>
    </div>
  </div>
  <div class="wrap" style="margin-top:52px">
    <div class="pipeline reveal">%(stages)s</div>
    <p style="text-align:center;color:var(--muted);font-size:13.5px;margin:14px 0 0">%(pipenote)s</p>
  </div>
</section>

<section id="features">
  <div class="wrap">
    <div class="sec-head reveal">
      <div class="kicker">%(feat_kicker)s</div>
      <h2>%(feat_title)s</h2>
      <p>%(feat_intro)s</p>
    </div>
    <div class="feat-grid">%(feats)s</div>
  </div>
</section>

<section id="showcase" style="padding-top:24px">
  <div class="wrap">
    <div class="sec-head reveal">
      <div class="kicker">%(sc_kicker)s</div>
      <h2>%(sc_title)s</h2>
      <p>%(sc_intro)s</p>
    </div>
    <div class="tabs reveal" id="tabs"></div>
    <div id="panels"></div>
    <div class="showcase-note reveal"><span class="b">↳</span><span id="note"></span></div>
  </div>
</section>

<section style="padding-top:24px">
  <div class="wrap">
    <div class="banner reveal">
      <div>
        <div class="kicker" style="color:var(--blue)">%(phil_kicker)s</div>
        <h2>%(phil_title)s</h2>
        %(phil_paras)s
      </div>
      <div class="stat-row">%(phil_stats)s</div>
    </div>
  </div>
</section>

<section id="start">
  <div class="wrap">
    <div class="sec-head reveal">
      <div class="kicker">%(start_kicker)s</div>
      <h2>%(start_title)s</h2>
      <p>%(start_intro)s</p>
    </div>
    <div class="steps">
      <div>%(steps)s</div>
      <div class="term reveal">
        <div class="code-top">
          <span class="tl r"></span><span class="tl y"></span><span class="tl g"></span>
          <span class="code-name">%(term_name)s</span>
        </div>
<pre>%(term)s</pre>
      </div>
    </div>
  </div>
</section>

<section id="editors" style="padding-top:24px">
  <div class="wrap">
    <div class="sec-head reveal">
      <div class="kicker">%(ed_kicker)s</div>
      <h2>%(ed_title)s</h2>
      <p>%(ed_intro)s</p>
    </div>
    <div class="editors reveal">%(eds)s</div>
    <p style="margin-top:22px;color:var(--muted);font-size:14.5px">%(ed_note)s</p>
  </div>
</section>

<footer>
  <div class="wrap foot-in">
    <div>
      <div class="brand" style="margin-bottom:8px"><span class="logo">L</span> %(brand)s</div>
      <div class="muted">%(tagline)s</div>
    </div>
    <nav class="foot-links">%(footlinks)s</nav>
  </div>
</footer>

<script src="ludic-highlight.js"></script>
<script>
Ludic.highlightAll();
const SAMPLES = %(samples)s;
const tabsEl = document.getElementById("tabs");
const panelsEl = document.getElementById("panels");
const noteEl = document.getElementById("note");
SAMPLES.forEach((s, idx)=>{
  const t = document.createElement("button");
  t.className = "tab" + (idx===0 ? " active" : "");
  t.textContent = s.label;
  t.onclick = ()=>select(idx);
  tabsEl.appendChild(t);
  const card = document.createElement("div");
  card.className = "code-card panel-code" + (idx===0 ? " active" : "");
  card.innerHTML =
    '<div class="code-top"><span class="tl r"></span><span class="tl y"></span><span class="tl g"></span><span class="code-name">'
    + s.name + '</span></div><pre>' + Ludic.highlight(s.code) + '</pre>';
  panelsEl.appendChild(card);
});
function select(idx){
  [...tabsEl.children].forEach((t,i)=>t.classList.toggle("active", i===idx));
  [...panelsEl.children].forEach((p,i)=>p.classList.toggle("active", i===idx));
  noteEl.textContent = SAMPLES[idx].note;
}
noteEl.textContent = SAMPLES[0].note;
const io = new IntersectionObserver((entries)=>{
  entries.forEach(e=>{ if(e.isIntersecting){ e.target.classList.add("in"); io.unobserve(e.target); } });
},{threshold:.12});
document.querySelectorAll(".reveal").forEach(el=>io.observe(el));
</script>
</body>
</html>
"""
    return pct(tmpl, dict(
        css=css, brand=esc(cfg["brand"]), tagline=esc(cfg["tagline"]), repo=cfg["repo_url"],
        title=esc(m["title"]), desc=esc(m["description"]), ogt=esc(m["og_title"]), ogd=esc(m["og_description"]),
        navlinks=navlinks,
        pill=esc(hero["pill"]), title_pre=esc(hero["title_pre"]), title_accent=esc(hero["title_accent"]),
        lead=hero["lead"], pcta_h=hero["primary_cta"]["href"], pcta_l=esc(hero["primary_cta"]["label"]),
        scta_h=hero["secondary_cta"]["href"], scta_l=esc(hero["secondary_cta"]["label"]),
        hero_name=esc(hero["snippet_name"]), hero_code=hero_code, stages=stages, pipenote=hero["pipeline_note"],
        feat_kicker=esc(cfg["features"]["kicker"]), feat_title=esc(cfg["features"]["title"]),
        feat_intro=cfg["features"]["intro"], feats=feats,
        sc_kicker=esc(cfg["showcase"]["kicker"]), sc_title=esc(cfg["showcase"]["title"]),
        sc_intro=cfg["showcase"]["intro"],
        phil_kicker=esc(phil["kicker"]), phil_title=esc(phil["title"]), phil_paras=phil_paras, phil_stats=phil_stats,
        start_kicker=esc(start["kicker"]), start_title=esc(start["title"]), start_intro=esc(start["intro"]),
        steps=steps, term_name=esc(start["terminal_name"]), term=term,
        ed_kicker=esc(cfg["editors"]["kicker"]), ed_title=esc(cfg["editors"]["title"]),
        ed_intro=cfg["editors"]["intro"], eds=eds, ed_note=cfg["editors"]["note"],
        footlinks=footlinks, samples=samples_json,
    ))

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
    symbols = build_symbols(sections)
    cfg = json.load(open(os.path.join(SITE, "site.json")))

    open(os.path.join(out, "api.html"), "w").write(render_api(sections, palette, cfg))
    open(os.path.join(out, "index.html"), "w").write(render_index(cfg))
    open(os.path.join(out, "ludic-highlight.js"), "w").write(render_highlighter(symbols))
    open(os.path.join(out, "symbols.json"), "w").write(json.dumps(symbols, indent=2, ensure_ascii=False))
    open(os.path.join(out, ".nojekyll"), "w").write("")

    n_entries = sum(len(s["entries"]) for s in sections)
    print("docs generated -> %s" % out)
    print("  sections: %d   symbols: %d   colors: %d"
          % (len(sections), n_entries, palette["count"]))
    print("  highlighter tokens: %d kw / %d type / %d builtin / %d ns-method / %d annot"
          % (len(symbols["keywords"]), len(symbols["types"]), len(symbols["builtins"]),
             len(symbols["nsmethods"]), len(symbols["annotations"])))

if __name__ == "__main__":
    main()
