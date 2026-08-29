/* ============================================================================
 * ludic-highlight.js — the Ludic syntax highlighter for the docs site.
 *
 * GENERATED FILE — do not edit by hand. The symbol tables below (keywords,
 * types, phases, namespace methods, builtins, annotations and their one-line
 * tips + anchors) are produced by tools/docgen/gen.py from the per-symbol
 * source files in docs/language/**. Add a symbol there and it is recognized,
 * colored, tipped and linked here automatically — nothing to maintain twice.
 *
 * Beyond coloring, every token the language defines becomes a link into the API
 * Reference (api.html): hover a keyword, a Screen.* call, a named color, a
 * builtin or a type and it points at the entry that explains it. Your own
 * symbols (functions, entities, fields) stay plain.
 * ========================================================================== */
(function (global) {
  "use strict";

  const SYMBOLS = /*__SYMBOLS__*/{};
  const KEYWORDS   = SYMBOLS.keywords    || {};
  const TYPES      = SYMBOLS.types       || {};
  const PHASES     = SYMBOLS.phases      || {};
  const BUILTINS   = SYMBOLS.builtins    || {};
  const NSMETHODS  = SYMBOLS.nsmethods   || {};
  const ANNOTS     = SYMBOLS.annotations || {};
  const TIPS       = SYMBOLS.tips        || {};
  const NAMESPACES = new Set(SYMBOLS.namespaces || []);
  const COLORS_ANCHOR = SYMBOLS.colors_anchor || "colors";
  const ANNOT_ANCHOR  = SYMBOLS.annotations_anchor || "annotations";

  function esc(s) {
    return s.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;");
  }
  const isIdStart = c => /[A-Za-z_]/.test(c);
  const isId = c => /[A-Za-z0-9_]/.test(c);

  function link(href, tip, inner) {
    const t = tip ? ' title="' + esc(tip) + '"' : "";
    return '<a class="tok" href="' + href + '"' + t + ">" + inner + "</a>";
  }

  function highlight(src) {
    let out = "", i = 0;
    const n = src.length;
    while (i < n) {
      const c = src[i];
      // comment
      if (c === "#") {
        let j = i; while (j < n && src[j] !== "\n") j++;
        out += '<span class="t-com">' + esc(src.slice(i, j)) + "</span>";
        i = j; continue;
      }
      // string / char / interpolation (backtick)
      if (c === '"' || c === "'" || c === "`") {
        const q = c; let j = i + 1;
        while (j < n && src[j] !== q) { if (src[j] === "\\") j++; j++; }
        j = Math.min(j + 1, n);
        out += '<span class="t-str">' + esc(src.slice(i, j)) + "</span>";
        i = j; continue;
      }
      // annotation @Name
      if (c === "@") {
        let j = i + 1; while (j < n && isId(src[j])) j++;
        const at = src.slice(i, j);
        const anchor = ANNOTS[at] || ANNOT_ANCHOR;
        const tip = TIPS[at] || "A compile-time annotation.";
        out += link("api.html#" + anchor, tip,
          '<span class="t-annot">' + esc(at) + "</span>");
        i = j; continue;
      }
      // number (incl 0x hex)
      if (/[0-9]/.test(c)) {
        let j = i; while (j < n && /[0-9a-fA-FxX._]/.test(src[j])) j++;
        out += '<span class="t-num">' + esc(src.slice(i, j)) + "</span>";
        i = j; continue;
      }
      // identifier / keyword / type / namespace.member / builtin
      if (isIdStart(c)) {
        let j = i; while (j < n && isId(src[j])) j++;
        const word = src.slice(i, j);

        // Namespace.member  (Screen.fill_rectangle, Color.Crimson, …)
        if (NAMESPACES.has(word) && src[j] === "." && j + 1 < n && isIdStart(src[j + 1])) {
          let k = j + 1; while (k < n && isId(src[k])) k++;
          const member = src.slice(j + 1, k);
          const key = word + "." + member;
          let href, tip;
          if (word === "Color") {
            href = "api.html#" + COLORS_ANCHOR; tip = "Named color " + key + ".";
          } else {
            href = "api.html#" + (NSMETHODS[key] || (word.toLowerCase() + "-" + member));
            tip = TIPS[key] || key;
          }
          const inner = '<span class="t-type">' + word + '</span><span class="t-punc">.</span><span class="t-fn">' + esc(member) + "</span>";
          out += link(href, tip, inner);
          i = k; continue;
        }

        let k2 = j; while (k2 < n && src[k2] === " ") k2++;
        const callish = src[k2] === "(";
        if (KEYWORDS[word]) {
          out += link("api.html#" + KEYWORDS[word], TIPS[word], '<span class="t-key">' + word + "</span>");
        } else if (BUILTINS[word] && callish) {
          out += link("api.html#" + BUILTINS[word], TIPS[word], '<span class="t-fn">' + word + "</span>");
        } else if (TYPES[word]) {
          out += link("api.html#" + TYPES[word], TIPS[word] || ("The " + word + " type."), '<span class="t-type">' + word + "</span>");
        } else if (PHASES[word]) {
          out += link("api.html#" + PHASES[word], "The " + word + " phase.", '<span class="t-type">' + word + "</span>");
        } else if (callish) {
          out += '<span class="t-fn">' + esc(word) + "</span>";
        } else {
          out += esc(word);
        }
        i = j; continue;
      }
      // punctuation
      if (/[{}\[\]()=<>+\-*\/%,.:;!&|~]/.test(c)) {
        out += '<span class="t-punc">' + esc(c) + "</span>";
        i++; continue;
      }
      out += esc(c); i++;
    }
    return out;
  }

  function highlightAll() {
    document.querySelectorAll('pre[data-lang="ludic"]').forEach(pre => {
      pre.innerHTML = highlight(pre.textContent);
    });
  }

  global.Ludic = { highlight, highlightAll, SYMBOLS };
})(window);
