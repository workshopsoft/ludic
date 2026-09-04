/* ============================================================================
 * ludic-highlight.js — the Ludic syntax highlighter + docs interactions.
 *
 * GENERATED FILE — do not edit by hand. The symbol tables below (keywords,
 * types, phases, namespace methods + their parameter labels, builtins,
 * annotations, namespaces, one-line tips, per-item page targets and hover-card
 * data) are produced by tools/docgen/gen.py from the per-symbol source files in
 * docs/language/**. Add a symbol there and it is recognized, colored, tipped,
 * linked and card-previewed here automatically.
 *
 * In any code sample: every keyword/type/builtin/annotation links to its own
 * page; `Screen.fill_rectangle` links `Screen` → the namespace page and
 * `fill_rectangle` → the method page, separately; a named argument like
 * `width:` links to that parameter on the method's page; `Color.Charcoal`
 * links `Color` and `Charcoal` separately. Hovering any of them shows a summary
 * card pulled from the real API data.
 * ========================================================================== */
(function (global) {
  "use strict";

  const S = /*__SYMBOLS__*/{};
  const KEYWORDS = S.keywords || {}, TYPES = S.types || {}, PHASES = S.phases || {};
  const BUILTINS = S.builtins || {}, NSMETHODS = S.nsmethods || {}, ANNOTS = S.annotations || {};
  const NAMESPACES = S.namespaces || {}, TIPS = S.tips || {}, CARDS = S.cards || {};

  function esc(s){ return s.replace(/&/g,"&amp;").replace(/</g,"&lt;").replace(/>/g,"&gt;"); }
  const isIdStart = c => /[A-Za-z_]/.test(c);
  const isId = c => /[A-Za-z0-9_]/.test(c);

  function link(href, id, tip, inner){
    const t = tip ? ' title="'+esc(tip).replace(/"/g,"&quot;")+'"' : "";
    const d = id ? ' data-id="'+id+'"' : "";
    return '<a class="tok" href="'+href+'"'+d+t+'>'+inner+'</a>';
  }

  function highlight(src){
    let out = "", i = 0; const n = src.length;
    const stack = [];          // call-context stack for named-parameter linking
    let pending = null;        // ctx to push at the next "("
    const nextNonSpace = j => { while (j < n && src[j] === " ") j++; return j; };

    while (i < n){
      const c = src[i];
      if (c === "#"){ let j=i; while(j<n && src[j]!=="\n") j++; out+='<span class="t-com">'+esc(src.slice(i,j))+'</span>'; i=j; continue; }
      if (c === '"' || c === "'" || c === "`"){ const q=c; let j=i+1; while(j<n && src[j]!==q){ if(src[j]==="\\") j++; j++; } j=Math.min(j+1,n); out+='<span class="t-str">'+esc(src.slice(i,j))+'</span>'; i=j; continue; }
      if (c === "@"){ let j=i+1; while(j<n && isId(src[j])) j++; const at=src.slice(i,j); const id=ANNOTS[at];
        if (id) out += link(id+".html", id, TIPS[at]||"A compile-time annotation.", '<span class="t-annot">'+esc(at)+'</span>');
        else out += '<span class="t-annot">'+esc(at)+'</span>';
        i=j; continue; }
      if (/[0-9]/.test(c)){ let j=i; while(j<n && /[0-9a-fA-FxX._]/.test(src[j])) j++; out+='<span class="t-num">'+esc(src.slice(i,j))+'</span>'; i=j; continue; }

      if (isIdStart(c)){
        let j=i; while(j<n && isId(src[j])) j++; const word=src.slice(i,j);

        // Namespace.member — link the two halves separately
        if (NAMESPACES[word] && src[j]==="." && j+1<n && isIdStart(src[j+1])){
          let k=j+1; while(k<n && isId(src[k])) k++; const member=src.slice(j+1,k);
          const nsId=NAMESPACES[word];
          out += link(nsId+".html", nsId, TIPS[word]||(word+" namespace"), '<span class="t-type">'+word+'</span>');
          out += '<span class="t-punc">.</span>';
          if (word === "Color"){
            out += link("ns-color.html#"+member.toLowerCase(), "", "Named color "+word+"."+member+".", '<span class="t-fn">'+esc(member)+'</span>');
          } else {
            const key=word+"."+member, m=NSMETHODS[key];
            if (m){
              out += link(m.id+".html", m.id, TIPS[key]||key, '<span class="t-fn">'+esc(member)+'</span>');
              if (src[nextNonSpace(k)]==="(") pending = {page:m.id, params:new Set(m.params||[])};
            } else out += '<span class="t-fn">'+esc(member)+'</span>';
          }
          i=k; continue;
        }

        const ns = nextNonSpace(j);
        const callish = src[ns] === "(";
        const labelish = src[ns] === ":";
        const top = stack.length ? stack[stack.length-1] : null;

        if (KEYWORDS[word]){
          out += link(KEYWORDS[word]+".html", KEYWORDS[word], TIPS[word], '<span class="t-key">'+word+'</span>');
        } else if (BUILTINS[word] && callish){
          const b=BUILTINS[word];
          out += link(b.id+".html", b.id, TIPS[word], '<span class="t-fn">'+word+'</span>');
          pending = {page:b.id, params:new Set(b.params||[])};
        } else if (labelish && top && top.params.has(word)){
          out += link(top.page+".html#param-"+word, "", "parameter: "+word, '<span class="t-arg">'+word+'</span>');
        } else if (TYPES[word]){
          out += link(TYPES[word]+".html", TYPES[word], TIPS[word]||("The "+word+" type."), '<span class="t-type">'+word+'</span>');
        } else if (PHASES[word]){
          out += link(PHASES[word]+".html", PHASES[word], TIPS[word]||("The "+word+" phase."), '<span class="t-type">'+word+'</span>');
        } else if (callish){
          out += '<span class="t-fn">'+esc(word)+'</span>';
        } else {
          out += esc(word);
        }
        i=j; continue;
      }

      if (c === "("){ stack.push(pending); pending=null; out+='<span class="t-punc">(</span>'; i++; continue; }
      if (c === ")"){ stack.pop(); out+='<span class="t-punc">)</span>'; i++; continue; }
      if (/[{}\[\]=<>+\-*\/%,.:;!&|~]/.test(c)){ out+='<span class="t-punc">'+esc(c)+'</span>'; i++; continue; }
      out += esc(c); i++;
    }
    return out;
  }

  function highlightAll(){
    document.querySelectorAll('pre[data-lang="ludic"]').forEach(pre => { pre.innerHTML = highlight(pre.textContent); });
  }

  /* ---- tooltip cards: click a token to open; click the card to open the ---
     ---- page in a new tab; click outside (or Escape) to close ------------- */
  let cardEl = null, cardAnchor = null;
  function ensureCard(){
    if (cardEl) return cardEl;
    cardEl = document.createElement("div"); cardEl.className = "hovercard"; cardEl.hidden = true;
    cardEl.addEventListener("click", () => {
      const h = cardEl.dataset.href; if (h) window.open(h, "_blank", "noopener");
    });
    document.body.appendChild(cardEl); return cardEl;
  }
  function positionCard(a){
    const el = cardEl, r = a.getBoundingClientRect();
    const cw = el.offsetWidth, ch = el.offsetHeight;
    let left = r.left, top = r.bottom + 8;
    if (left + cw > window.innerWidth - 12) left = window.innerWidth - cw - 12;
    if (left < 12) left = 12;
    if (top + ch > window.innerHeight - 12) top = r.top - ch - 8;
    el.style.left = Math.max(12,left) + "px"; el.style.top = Math.max(12,top) + "px";
  }
  function showCard(a){
    const id = a.getAttribute("data-id"); if (!id) return;
    const c = CARDS[id]; if (!c) return;
    const el = ensureCard();
    el.innerHTML = '<div class="hc-top"><span class="kind-badge kind-'+(c.kind||"").replace("namespace-method","method")+'">'
      + (c.kind||"").replace("namespace-method","method") + '</span><span class="hc-name">'+esc(c.name||"")+'</span></div>'
      + (c.sig ? '<code class="hc-sig">'+esc(c.sig)+'</code>' : "")
      + '<div class="hc-tip">'+esc(c.tip||"")+'</div>'
      + '<div class="hc-foot">'+esc(c.section||"")+' · open in new tab ↗</div>';
    el.dataset.href = a.getAttribute("href") || "";
    el.hidden = false; cardAnchor = a; positionCard(a);
  }
  function hideCard(){ if (cardEl){ cardEl.hidden = true; cardAnchor = null; } }
  function installCards(){
    document.addEventListener("click", e => {
      const a = e.target.closest && e.target.closest("a.tok[data-id]");
      if (a){ e.preventDefault(); showCard(a); return; }               // token -> open card
      if (cardEl && !cardEl.hidden && !(e.target.closest && e.target.closest(".hovercard"))) hideCard(); // outside -> close
    });
    document.addEventListener("keydown", e => { if (e.key === "Escape") hideCard(); });
    window.addEventListener("resize", hideCard);
    window.addEventListener("scroll", () => {
      if (cardEl && !cardEl.hidden && cardAnchor){
        const r = cardAnchor.getBoundingClientRect();
        if (r.bottom < 0 || r.top > window.innerHeight) hideCard(); else positionCard(cardAnchor);
      }
    }, {passive:true});
  }

  /* ---- flash the scrolled-to target ------------------------------------- */
  function flash(el){ if (!el) return; el.classList.remove("flash"); void el.offsetWidth; el.classList.add("flash"); }
  function flashTarget(){
    const go = () => {
      // Only a deep link gets a flash. The old fallback flashed the page title
      // on every plain visit, which points at nothing the reader was looking for.
      const h = location.hash ? decodeURIComponent(location.hash.slice(1)) : "";
      if (h) flash(document.getElementById(h));
    };
    if (document.readyState !== "loading") go(); else document.addEventListener("DOMContentLoaded", go);
    window.addEventListener("hashchange", () => { const el = document.getElementById(decodeURIComponent(location.hash.slice(1))); flash(el); });
  }

  /* ---- fuzzy search on the API index ------------------------------------ */
  function subseq(q, s){ let i=0; for (let k=0;k<s.length && i<q.length;k++) if (s[k]===q[i]) i++; return i===q.length; }
  function installSearch(){
    const box = document.getElementById("search"); if (!box) return;
    const items = [...document.querySelectorAll(".idx-item")];
    const secs = [...document.querySelectorAll(".idx-sec")];
    const none = document.getElementById("noresults");
    const run = () => {
      const q = box.value.trim().toLowerCase();
      let shown = 0;
      items.forEach(it => {
        const name = (it.getAttribute("data-name")||"").toLowerCase();
        const tip = (it.getAttribute("data-tip")||"").toLowerCase();
        const hit = !q || name.includes(q) || tip.includes(q) || subseq(q, name);
        it.style.display = hit ? "" : "none"; if (hit) shown++;
      });
      secs.forEach(sec => { const any = [...sec.querySelectorAll(".idx-item")].some(i=>i.style.display!=="none"); sec.style.display = any ? "" : "none"; });
      if (none) none.hidden = shown !== 0;
    };
    box.addEventListener("input", run);
    box.addEventListener("keydown", e => { if (e.key === "Enter"){ const first = items.find(i=>i.style.display!=="none"); if (first) location.href = first.getAttribute("href"); } });
  }

  /* ---- mobile nav toggle (auto-wired on every page) ------------------- */
  function initNav(){
    document.querySelectorAll(".nav-toggle").forEach(btn => {
      btn.addEventListener("click", () => {
        const h = btn.closest("header.nav"); if (!h) return;
        const open = h.classList.toggle("open");
        btn.setAttribute("aria-expanded", open ? "true" : "false");
      });
    });
    document.querySelectorAll("header.nav .nav-links a").forEach(a => {
      a.addEventListener("click", () => {
        const h = a.closest("header.nav");
        if (h){ h.classList.remove("open"); const b = h.querySelector(".nav-toggle"); if (b) b.setAttribute("aria-expanded","false"); }
      });
    });
  }
  if (document.readyState !== "loading") initNav(); else document.addEventListener("DOMContentLoaded", initNav);

  global.Ludic = { highlight, highlightAll, installCards, flashTarget, installSearch, initNav, SYMBOLS: S };
})(window);
