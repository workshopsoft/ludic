/* ============================================================================
 * ludic_index.h — an error-tolerant model of a Ludic workspace.
 *
 * The compiler's parser is the wrong tool for an editor: it stops at the first
 * error and it splices imports into one flat program. A language server needs
 * the opposite — keep going after a syntax error (a file being typed into is
 * broken most of the time), keep every file separate, and remember where each
 * name came from so it can be jumped to, renamed and completed.
 *
 * So this is a second, deliberately shallow reader of the same grammar. It
 * recognises declarations and bindings and records their spans; it does not
 * type-check. Ground-truth errors still come from `ludicc` itself (see
 * ludic_lsp.c) — this layer supplies structure, not judgement.
 * ==========================================================================*/
#ifndef LUDIC_INDEX_H
#define LUDIC_INDEX_H

#include "ludic_syntax.h"
#include <stdarg.h>

/* ---------- symbol kinds --------------------------------------------------*/
enum {
    LS_UNIT, LS_COMPONENT, LS_FIELD, LS_ARCHETYPE, LS_CONST, LS_VAR,
    LS_FN, LS_PARAM, LS_EXTERN, LS_SYSTEM, LS_UI, LS_WIDGET, LS_SCENE,
    LS_LAYER, LS_LOCAL, LS_QUERYVAR, LS_STATE, LS_IMPORT
};

/* semantic classes, one per token — the source for semantic highlighting */
enum {
    SC_NONE, SC_KEYWORD, SC_TYPE, SC_COMPONENT, SC_ARCHETYPE, SC_SCENE,
    SC_LAYER, SC_UI, SC_WIDGET, SC_PROP, SC_FIELD, SC_SYSTEM, SC_FUNCTION,
    SC_BUILTIN, SC_PARAM, SC_VARIABLE, SC_CONST, SC_MODVAR, SC_PHASE,
    SC_NUMBER, SC_STRING, SC_COMMENT, SC_OPERATOR, SC_ANNOTATION, SC_UNKNOWN
};

typedef struct {
    int kind;
    char name[96];
    char type[96];      /* declared type; for a query var, its component      */
    char detail[224];   /* one-line signature, shown in hover and outlines    */
    char doc[640];      /* the comment block sitting directly above           */
    int  tok;           /* token index of the NAME                            */
    int  start, end;    /* byte span of the name                              */
    int  body_start, body_end;  /* span the symbol governs (a block, or the
                                 * whole file for a top-level declaration)     */
    int  parent;        /* enclosing symbol index, -1 at the top level        */
    int  exported;
} LSym;

typedef struct {
    int line, col, endline, endcol, severity;   /* 1 = error, 2 = warning     */
    char msg[512];
    char path[1024];    /* empty = this document                              */
} LDiag;

typedef struct LDoc {
    char* path;         /* filesystem path                                    */
    char* uri;          /* file:// URI                                        */
    char* raw;          /* the buffer exactly as the editor has it             */
    char* text;         /* what the lexer sees: `raw`, or — for Markdown — a
                         * copy with every byte outside a ```ludic fence blanked
                         * out, so offsets still line up with the real file     */
    int   version;
    int   open;         /* the editor holds it (so `text` beats the disk)     */
    int   is_markdown;  /* a .md file: only its ```ludic fences are Ludic     */
    LLex  lex;
    int*  match;        /* per token: matching brace/bracket token, else -1   */
    unsigned char* cls; /* per token: semantic class                          */
    LSym* sym; int nsym, symcap;
    char** imports; int nimport;
    int   had_diags;    /* we published a non-empty list for it last time     */
    int   is_unit;      /* declares `game` or `module`                        */
    int   is_module;
    char  unit[96];
} LDoc;

typedef struct {
    LDoc** d; int n, cap;
    char*  root;        /* workspace root directory                           */
} LIndex;

/* ---------- small helpers -------------------------------------------------*/
static void lsym_reserve(LDoc* D){
    if (D->nsym >= D->symcap){ D->symcap = D->symcap ? D->symcap * 2 : 128; D->sym = realloc(D->sym, D->symcap * sizeof(LSym)); }
}
static void lcpy(char* dst, int cap, const char* s, int n){
    if (n >= cap) n = cap - 1; if (n < 0) n = 0;
    memcpy(dst, s, n); dst[n] = 0;
}
static void lcatf(char* dst, int cap, const char* fmt, ...){
    int used = (int)strlen(dst); if (used >= cap - 1) return;
    va_list ap; va_start(ap, fmt); vsnprintf(dst + used, cap - used, fmt, ap); va_end(ap);
}

/* ---------- positions -----------------------------------------------------
 * LSP counts characters in UTF-16 code units by default. Ludic source is UTF-8
 * and string literals really do carry non-ASCII (the language ships a Unicode
 * TrueType path), so the conversion is not optional. */
static int lutf16_len(const char* s, int nbytes){
    int u = 0;
    for (int i = 0; i < nbytes; ){
        unsigned char c = (unsigned char)s[i];
        if (c < 0x80){ i += 1; u += 1; }
        else if (c < 0xE0){ i += 2; u += 1; }
        else if (c < 0xF0){ i += 3; u += 1; }
        else { i += 4; u += 2; }        /* astral planes are a surrogate pair */
    }
    return u;
}
static int ldoc_line_of(const LDoc* D, int off){
    int lo = 0, hi = D->lex.nline - 1;
    while (lo < hi){ int mid = (lo + hi + 1) / 2; if (D->lex.linestart[mid] <= off) lo = mid; else hi = mid - 1; }
    return lo;
}
static int ldoc_col_of(const LDoc* D, int off){
    int line = ldoc_line_of(D, off);
    return lutf16_len(D->text + D->lex.linestart[line], off - D->lex.linestart[line]);
}
static int ldoc_offset_of(const LDoc* D, int line, int character){
    if (line < 0) return 0;
    if (line >= D->lex.nline) return (int)strlen(D->text);
    int off = D->lex.linestart[line];
    int end = (line + 1 < D->lex.nline) ? D->lex.linestart[line + 1] : (int)strlen(D->text);
    int u = 0;
    while (off < end && u < character){
        unsigned char c = (unsigned char)D->text[off];
        if (c < 0x80){ off += 1; u += 1; }
        else if (c < 0xE0){ off += 2; u += 1; }
        else if (c < 0xF0){ off += 3; u += 1; }
        else { off += 4; u += 2; }
    }
    return off;
}
/* The token the cursor is on. A caret sitting exactly between two tokens
 * belongs to the one it is *inside*; only when it is inside none of them does
 * the token ending there win — otherwise `st.|guard` resolves to the dot. */
static int ldoc_tok_at(const LDoc* D, int off){
    int touching = -1;
    for (int i = 0; i < D->lex.n; i++){
        const LTok* t = &D->lex.v[i];
        if (t->kind == LT_NL || t->kind == LT_EOF) continue;
        if (off >= t->start && off < t->end) return i;
        if (off == t->end && touching < 0) touching = i;
        if (t->start > off) break;
    }
    return touching;
}

/* ---------- brace matching ------------------------------------------------*/
static void ldoc_match_braces(LDoc* D){
    free(D->match);
    D->match = malloc(sizeof(int) * (D->lex.n + 1));
    for (int i = 0; i < D->lex.n; i++) D->match[i] = -1;
    int stack[512], top = 0;
    for (int i = 0; i < D->lex.n; i++){
        const LTok* t = &D->lex.v[i];
        if (t->kind != LT_OP || ltok_len(t) != 1) continue;
        char c = D->text[t->start];
        if (c == '{' || c == '(' || c == '['){ if (top < 512) stack[top++] = i; }
        else if (c == '}' || c == ')' || c == ']'){
            if (top > 0){ int o = stack[--top]; D->match[o] = i; D->match[i] = o; }
        }
    }
}

/* ---------- doc comments --------------------------------------------------
 * The comment block immediately above a declaration is its documentation —
 * the convention the runtime and examples already follow. */
static void ldoc_collect_doc(LDoc* D, int decl_tok, char* out, int cap){
    out[0] = 0;
    int line = D->lex.v[decl_tok].line;
    /* walk backwards over comment-only lines */
    int first = -1;
    for (int i = decl_tok - 1; i >= 0; i--){
        const LTok* t = &D->lex.v[i];
        if (t->kind == LT_NL) continue;
        if (t->kind != LT_COMMENT) break;
        if (t->line >= line) break;                 /* trailing, not leading  */
        /* the comment must own its line */
        int p = ltok_prev_sig(&D->lex, i);
        if (p >= 0 && D->lex.v[p].line == t->line) break;
        if (t->line < line - 1 && first >= 0) break;/* a blank line ends it   */
        if (first >= 0 && D->lex.v[first].line != t->line + 1) break;
        first = i; line = t->line;
    }
    if (first < 0) return;
    for (int i = first; i < decl_tok; i++){
        const LTok* t = &D->lex.v[i];
        if (t->kind != LT_COMMENT) continue;
        int s = t->start + 1;                        /* skip '#'              */
        while (s < t->end && (D->text[s] == ' ' || D->text[s] == '\t' || D->text[s] == '#' || D->text[s] == '*')) s++;
        int used = (int)strlen(out);
        int n = t->end - s;
        if (used + n + 2 >= cap) break;
        memcpy(out + used, D->text + s, n); out[used + n] = '\n'; out[used + n + 1] = 0;
    }
}

/* ---------- the shallow parser -------------------------------------------*/
typedef struct { LDoc* D; int i; } LP;

static int lp_kind(LP* p){ return p->i < p->D->lex.n ? p->D->lex.v[p->i].kind : LT_EOF; }
static int lp_is(LP* p, const char* s){ return ltok_is(&p->D->lex, p->i, s); }
static void lp_skipnl(LP* p){ while (p->i < p->D->lex.n && (lp_kind(p) == LT_NL || lp_kind(p) == LT_COMMENT)) p->i++; }
static void lp_adv(LP* p){ if (p->i < p->D->lex.n) p->i++; lp_skipnl(p); }
static char* lp_word(LP* p, char* buf, int cap){
    buf[0] = 0;
    if (p->i < p->D->lex.n) lcpy(buf, cap, p->D->text + p->D->lex.v[p->i].start, ltok_len(&p->D->lex.v[p->i]));
    return buf;
}
/* Consume an identifier-ish token, returning its index (or -1). */
static int lp_name(LP* p){
    int k = lp_kind(p);
    if (k == LT_ID || k == LT_TYPE || k == LT_PHASE || k == LT_KW || k == LT_BOOL){ int t = p->i; lp_adv(p); return t; }
    return -1;
}
static int lsym_add(LDoc* D, int kind, int nametok, int parent){
    lsym_reserve(D);
    LSym* s = &D->sym[D->nsym];
    memset(s, 0, sizeof(*s));
    s->kind = kind; s->tok = nametok; s->parent = parent;
    if (nametok >= 0){
        const LTok* t = &D->lex.v[nametok];
        s->start = t->start; s->end = t->end;
        lcpy(s->name, sizeof(s->name), D->text + t->start, ltok_len(t));
    }
    s->body_start = 0; s->body_end = (int)strlen(D->text);
    return D->nsym++;
}
/* Skip a balanced group starting at the current opener; leaves p after it. */
static void lp_skip_group(LP* p){
    int m = (p->i < p->D->lex.n) ? p->D->match[p->i] : -1;
    if (m < 0){ lp_adv(p); return; }
    p->i = m + 1; lp_skipnl(p);
}
/* Read `name: Type` pairs inside the parentheses at p->i, recording params. */
static void lp_params(LP* p, int owner, int kind, char* sig, int sigcap){
    if (!lp_is(p, "(")) return;
    int close = p->D->match[p->i];
    lcatf(sig, sigcap, "(");
    lp_adv(p);
    int first = 1;
    while (p->i < p->D->lex.n && (close < 0 || p->i < close)){
        if (lp_is(p, ")")) break;
        if (lp_is(p, ",")){ lp_adv(p); continue; }
        int nt = lp_name(p); if (nt < 0){ lp_adv(p); continue; }
        char ty[96]; ty[0] = 0;
        if (lp_is(p, ":")){ lp_adv(p); int tt = lp_name(p); if (tt >= 0) lcpy(ty, sizeof(ty), p->D->text + p->D->lex.v[tt].start, ltok_len(&p->D->lex.v[tt])); }
        int s = lsym_add(p->D, kind, nt, owner);
        lcpy(p->D->sym[s].type, sizeof(p->D->sym[s].type), ty, (int)strlen(ty));
        lcatf(sig, sigcap, "%s%s: %s", first ? "" : ", ", p->D->sym[s].name, ty[0] ? ty : "?");
        first = 0;
    }
    if (close >= 0) p->i = close + 1;
    lp_skipnl(p);
    lcatf(sig, sigcap, ")");
}
/* `[Pos, Vel, {Enemy}]` — bind the listed components to the named variables in
 * order, skipping {Tag} terms, which filter without binding. */
static void lp_query_terms(LP* p, int owner, int* vars, int nvars, int scope_start, int scope_end){
    if (!lp_is(p, "[")) return;
    int close = p->D->match[p->i];
    lp_adv(p);
    int bind = 0;
    while (p->i < p->D->lex.n && (close < 0 || p->i < close)){
        if (lp_is(p, "]")) break;
        if (lp_is(p, ",")){ lp_adv(p); continue; }
        if (lp_is(p, "{")){                                   /* a filter term */
            int cb = p->D->match[p->i]; lp_adv(p);
            int nt = lp_name(p); (void)nt;
            if (cb >= 0) p->i = cb + 1; else lp_adv(p);
            lp_skipnl(p); continue;
        }
        int nt = lp_name(p); if (nt < 0){ lp_adv(p); continue; }
        if (bind < nvars && vars[bind] >= 0){
            int s = lsym_add(p->D, LS_QUERYVAR, vars[bind], owner);
            lcpy(p->D->sym[s].type, sizeof(p->D->sym[s].type), p->D->text + p->D->lex.v[nt].start, ltok_len(&p->D->lex.v[nt]));
            p->D->sym[s].body_start = scope_start; p->D->sym[s].body_end = scope_end;
            lcatf(p->D->sym[s].detail, sizeof(p->D->sym[s].detail), "%s: %s  (query binding)", p->D->sym[s].name, p->D->sym[s].type);
        }
        bind++;
    }
    if (close >= 0) p->i = close + 1;
    lp_skipnl(p);
    if (lp_is(p, "where")) lp_adv(p);   /* the condition is ordinary expression */
}
/* `(a, b)` variable list before `in query` / after the `query` clause. */
static int lp_varlist(LP* p, int* out, int max){
    int n = 0;
    if (!lp_is(p, "(")) return 0;
    int close = p->D->match[p->i];
    lp_adv(p);
    while (p->i < p->D->lex.n && (close < 0 || p->i < close)){
        if (lp_is(p, ")")) break;
        if (lp_is(p, ",")){ lp_adv(p); continue; }
        int nt = lp_name(p); if (nt < 0){ lp_adv(p); continue; }
        if (n < max) out[n++] = nt;
    }
    if (close >= 0) p->i = close + 1;
    lp_skipnl(p);
    return n;
}

static void lp_block(LP* p, int owner, int scope_end);

/* statements — we only care about what BINDS a name or opens a scope */
static void lp_stmt(LP* p, int owner, int scope_end){
    LDoc* D = p->D;
    if (lp_is(p, "let")){
        lp_adv(p); int nt = lp_name(p); if (nt < 0) return;
        char ty[96]; ty[0] = 0;
        if (lp_is(p, ":")){ lp_adv(p); int tt = lp_name(p); if (tt >= 0) lcpy(ty, sizeof(ty), D->text + D->lex.v[tt].start, ltok_len(&D->lex.v[tt])); }
        int s = lsym_add(D, LS_LOCAL, nt, owner);
        lcpy(D->sym[s].type, sizeof(D->sym[s].type), ty, (int)strlen(ty));
        D->sym[s].body_start = D->lex.v[nt].start; D->sym[s].body_end = scope_end;
        return;
    }
    if (lp_is(p, "for")){
        lp_adv(p);
        if (lp_is(p, "(")){                       /* for (a, b) in query [...] */
            int vars[16]; int nv = lp_varlist(p, vars, 16);
            if (lp_is(p, "in")) lp_adv(p);
            if (lp_is(p, "query")) lp_adv(p);
            int body_end = scope_end;
            /* the loop body is the next {...}; bindings live there */
            lp_query_terms(p, owner, vars, nv, D->lex.v[p->i < D->lex.n ? p->i : D->lex.n - 1].start, body_end);
            return;
        }
        int nt = lp_name(p);                      /* for i in a .. b           */
        if (nt >= 0){
            int s = lsym_add(D, LS_LOCAL, nt, owner);
            lcpy(D->sym[s].type, sizeof(D->sym[s].type), "int", 3);
            D->sym[s].body_start = D->lex.v[nt].start; D->sym[s].body_end = scope_end;
        }
        return;
    }
    if (lp_is(p, "state")){                       /* machine { state Idle = 0 {…} } */
        lp_adv(p); int nt = lp_name(p);
        if (nt >= 0) lsym_add(D, LS_STATE, nt, owner);
        return;
    }
    lp_adv(p);
}

static void lp_block(LP* p, int owner, int scope_end){
    if (!lp_is(p, "{")) return;
    int close = p->D->match[p->i];
    int end = close >= 0 ? p->D->lex.v[close].start : scope_end;
    lp_adv(p);
    while (p->i < p->D->lex.n && lp_kind(p) != LT_EOF){
        if (close >= 0 && p->i >= close) break;
        if (lp_is(p, "}")) break;
        if (lp_is(p, "{")){ lp_block(p, owner, end); continue; }
        int before = p->i;
        lp_stmt(p, owner, end);
        if (p->i == before) lp_adv(p);
    }
    if (close >= 0) p->i = close + 1; else lp_adv(p);
    lp_skipnl(p);
}

/* `panel id=Root w=288 { … }` — each id= mints a UI_<Name> handle. */
static void lp_widget(LP* p, int owner, int uisym){
    LDoc* D = p->D;
    int type_tok = lp_name(p); if (type_tok < 0) return;
    while (p->i < D->lex.n && lp_kind(p) == LT_ID && ltok_is(&D->lex, ltok_next_sig(&D->lex, p->i) < 0 ? p->i : ltok_next_sig(&D->lex, p->i), "=")){
        int key = p->i; char kb[64]; lcpy(kb, sizeof(kb), D->text + D->lex.v[key].start, ltok_len(&D->lex.v[key]));
        lp_adv(p);                                   /* key */
        if (lp_is(p, "=")) lp_adv(p);                /* '='  */
        if (!strcmp(kb, "id")){
            int nt = lp_name(p);
            if (nt >= 0){
                int s = lsym_add(D, LS_WIDGET, nt, uisym);
                snprintf(D->sym[s].name, sizeof(D->sym[s].name), "UI_%.*s",
                         ltok_len(&D->lex.v[nt]), D->text + D->lex.v[nt].start);
                lcatf(D->sym[s].detail, sizeof(D->sym[s].detail), "%s widget handle",
                      (const char*)(D->text + D->lex.v[type_tok].start));
                lcpy(D->sym[s].type, sizeof(D->sym[s].type), "int", 3);
            }
        } else {
            /* skip one value expression: stop at the next `key=` or at a brace */
            while (p->i < D->lex.n && lp_kind(p) != LT_EOF && !lp_is(p, "{") && !lp_is(p, "}")){
                if (lp_is(p, "(") || lp_is(p, "[")){ lp_skip_group(p); continue; }
                int nx = ltok_next_sig(&D->lex, p->i);
                if (lp_kind(p) == LT_ID && nx >= 0 && ltok_is(&D->lex, nx, "=")) break;
                lp_adv(p);
            }
        }
    }
    if (lp_is(p, "{")){
        int close = D->match[p->i];
        lp_adv(p);
        while (p->i < D->lex.n && lp_kind(p) != LT_EOF && !lp_is(p, "}")){
            if (close >= 0 && p->i >= close) break;
            int before = p->i;
            lp_widget(p, owner, uisym);
            if (p->i == before) lp_adv(p);
        }
        if (close >= 0) p->i = close + 1; else lp_adv(p);
        lp_skipnl(p);
    }
}

/* one top-level declaration */
static void lp_decl(LP* p, int parent){
    LDoc* D = p->D;
    char w[96]; lp_word(p, w, sizeof(w));
    int decl_tok = p->i;

    if (!strcmp(w, "import")){
        lp_adv(p);
        if (lp_kind(p) == LT_STR){
            const LTok* t = &D->lex.v[p->i];
            int n = ltok_len(t) - 2; if (n < 0) n = 0;
            char* rel = malloc(n + 1); memcpy(rel, D->text + t->start + 1, n); rel[n] = 0;
            D->imports = realloc(D->imports, (D->nimport + 1) * sizeof(char*));
            D->imports[D->nimport++] = rel;
            int s = lsym_add(D, LS_IMPORT, p->i, parent);
            lcpy(D->sym[s].name, sizeof(D->sym[s].name), rel, (int)strlen(rel));
            lp_adv(p);
        }
        return;
    }
    if (!strcmp(w, "component") || !strcmp(w, "archetype")){
        int is_comp = !strcmp(w, "component");
        lp_adv(p); int nt = lp_name(p); if (nt < 0) return;
        int s = lsym_add(D, is_comp ? LS_COMPONENT : LS_ARCHETYPE, nt, parent);
        ldoc_collect_doc(D, decl_tok, D->sym[s].doc, sizeof(D->sym[s].doc));
        while (lp_kind(p) == LT_ANNO) lp_adv(p);
        snprintf(D->sym[s].detail, sizeof(D->sym[s].detail), "%s %s {",
                 is_comp ? "component" : "archetype", D->sym[s].name);
        if (!lp_is(p, "{")) return;
        int close = D->match[p->i];
        D->sym[s].body_start = D->lex.v[p->i].start;
        D->sym[s].body_end = close >= 0 ? D->lex.v[close].end : (int)strlen(D->text);
        lp_adv(p);
        int first = 1;
        while (p->i < D->lex.n && lp_kind(p) != LT_EOF && !lp_is(p, "}")){
            if (close >= 0 && p->i >= close) break;
            if (lp_is(p, ",")){ lp_adv(p); continue; }
            int ft = lp_name(p); if (ft < 0){ lp_adv(p); continue; }
            if (is_comp){
                int f = lsym_add(D, LS_FIELD, ft, s);
                if (lp_is(p, ":")){
                    lp_adv(p); int tt = lp_name(p);
                    if (tt >= 0) lcpy(D->sym[f].type, sizeof(D->sym[f].type), D->text + D->lex.v[tt].start, ltok_len(&D->lex.v[tt]));
                }
                lcatf(D->sym[f].detail, sizeof(D->sym[f].detail), "%s.%s: %s", D->sym[s].name, D->sym[f].name, D->sym[f].type);
                if (lp_is(p, "=")){ lp_adv(p); while (p->i < D->lex.n && !lp_is(p, ",") && !lp_is(p, "}") && lp_kind(p) != LT_EOF){ if (lp_is(p, "(") || lp_is(p, "{") || lp_is(p, "[")) lp_skip_group(p); else lp_adv(p); } }
                lcatf(D->sym[s].detail, sizeof(D->sym[s].detail), "%s %s: %s", first ? "" : ",", D->sym[f].name, D->sym[f].type);
            } else {
                lcatf(D->sym[s].detail, sizeof(D->sym[s].detail), "%s %.*s", first ? "" : ",",
                      ltok_len(&D->lex.v[ft]), D->text + D->lex.v[ft].start);
            }
            first = 0;
        }
        lcatf(D->sym[s].detail, sizeof(D->sym[s].detail), " }");
        if (close >= 0) p->i = close + 1; else lp_adv(p);
        lp_skipnl(p);
        return;
    }
    if (!strcmp(w, "const") || !strcmp(w, "var")){
        int kind = !strcmp(w, "const") ? LS_CONST : LS_VAR;
        lp_adv(p); int nt = lp_name(p); if (nt < 0) return;
        int s = lsym_add(D, kind, nt, parent);
        ldoc_collect_doc(D, decl_tok, D->sym[s].doc, sizeof(D->sym[s].doc));
        if (lp_is(p, ":")){ lp_adv(p); int tt = lp_name(p); if (tt >= 0) lcpy(D->sym[s].type, sizeof(D->sym[s].type), D->text + D->lex.v[tt].start, ltok_len(&D->lex.v[tt])); }
        lcatf(D->sym[s].detail, sizeof(D->sym[s].detail), "%s %s: %s", w, D->sym[s].name, D->sym[s].type);
        while (p->i < D->lex.n && lp_kind(p) != LT_NL && lp_kind(p) != LT_EOF){
            if (lp_is(p, "(") || lp_is(p, "{") || lp_is(p, "[")) lp_skip_group(p); else p->i++;
        }
        lp_skipnl(p);
        return;
    }
    if (!strcmp(w, "extern")){
        lp_adv(p); if (lp_is(p, "fn")) lp_adv(p);
        int nt = lp_name(p); if (nt < 0) return;
        int s = lsym_add(D, LS_EXTERN, nt, parent);
        ldoc_collect_doc(D, decl_tok, D->sym[s].doc, sizeof(D->sym[s].doc));
        char sig[224]; snprintf(sig, sizeof(sig), "extern fn %s", D->sym[s].name);
        lp_params(p, s, LS_PARAM, sig, sizeof(sig));
        if (lp_is(p, "->")){ lp_adv(p); int tt = lp_name(p); if (tt >= 0){ lcpy(D->sym[s].type, sizeof(D->sym[s].type), D->text + D->lex.v[tt].start, ltok_len(&D->lex.v[tt])); lcatf(sig, sizeof(sig), " -> %s", D->sym[s].type); } }
        lcpy(D->sym[s].detail, sizeof(D->sym[s].detail), sig, (int)strlen(sig));
        while (p->i < D->lex.n && lp_kind(p) != LT_NL && lp_kind(p) != LT_EOF) p->i++;
        lp_skipnl(p);
        return;
    }
    if (!strcmp(w, "fn") || !strcmp(w, "pure") || !strcmp(w, "export")){
        int exported = !strcmp(w, "export");
        if (!strcmp(w, "pure") || exported){ lp_adv(p); if (lp_is(p, "pure")) lp_adv(p); }
        if (lp_is(p, "fn")) lp_adv(p);
        int nt = lp_name(p); if (nt < 0) return;
        int s = lsym_add(D, LS_FN, nt, parent);
        D->sym[s].exported = exported;
        ldoc_collect_doc(D, decl_tok, D->sym[s].doc, sizeof(D->sym[s].doc));
        char sig[224]; snprintf(sig, sizeof(sig), "%sfn %s", exported ? "export " : "", D->sym[s].name);
        lp_params(p, s, LS_PARAM, sig, sizeof(sig));
        if (lp_is(p, "->")){ lp_adv(p); int tt = lp_name(p); if (tt >= 0) lcpy(D->sym[s].type, sizeof(D->sym[s].type), D->text + D->lex.v[tt].start, ltok_len(&D->lex.v[tt])); }
        lcatf(sig, sizeof(sig), " -> %s", D->sym[s].type[0] ? D->sym[s].type : "void");
        lcpy(D->sym[s].detail, sizeof(D->sym[s].detail), sig, (int)strlen(sig));
        /* contracts sit between the signature and the body */
        while (lp_is(p, "requires") || lp_is(p, "ensures") || lp_is(p, "invariant") || lp_is(p, "effects")){
            lp_adv(p);
            while (p->i < D->lex.n && lp_kind(p) != LT_NL && lp_kind(p) != LT_EOF && !lp_is(p, "{")){
                if (lp_is(p, "(") || lp_is(p, "[")) lp_skip_group(p); else p->i++;
            }
            lp_skipnl(p);
        }
        if (lp_is(p, "{")){
            int close = D->match[p->i];
            D->sym[s].body_start = D->lex.v[p->i].start;
            D->sym[s].body_end = close >= 0 ? D->lex.v[close].end : (int)strlen(D->text);
            /* params are visible for the whole body */
            for (int q = 0; q < D->nsym; q++) if (D->sym[q].parent == s && D->sym[q].kind == LS_PARAM){
                D->sym[q].body_start = D->sym[s].body_start; D->sym[q].body_end = D->sym[s].body_end;
            }
            lp_block(p, s, D->sym[s].body_end);
        }
        return;
    }
    if (!strcmp(w, "system") || !strcmp(w, "edge")){
        if (!strcmp(w, "edge")){ lp_adv(p); if (!lp_is(p, "system")) return; }
        lp_adv(p);
        int nt = lp_name(p); if (nt < 0) return;
        int s = lsym_add(D, LS_SYSTEM, nt, parent);
        ldoc_collect_doc(D, decl_tok, D->sym[s].doc, sizeof(D->sym[s].doc));
        lcpy(D->sym[s].type, sizeof(D->sym[s].type), "Update", 6);
        while (lp_kind(p) == LT_ANNO) lp_adv(p);
        int vars[16]; int nv = 0; int have_query = 0;
        for (;;){
            if (lp_is(p, "phase")){ lp_adv(p); int tt = lp_name(p); if (tt >= 0) lcpy(D->sym[s].type, sizeof(D->sym[s].type), D->text + D->lex.v[tt].start, ltok_len(&D->lex.v[tt])); }
            else if (lp_is(p, "query")){ lp_adv(p); have_query = 1; nv = lp_varlist(p, vars, 16); break; }
            else if (lp_is(p, "reads") || lp_is(p, "writes") || lp_is(p, "uses") || lp_is(p, "effects")){ lp_adv(p); if (lp_is(p, "[")) lp_skip_group(p); }
            else if (lp_is(p, "needs")){ lp_adv(p); lp_name(p); if (lp_is(p, "[")) lp_skip_group(p); }
            else break;
            lp_skipnl(p);
        }
        lcatf(D->sym[s].detail, sizeof(D->sym[s].detail), "system %s phase %s", D->sym[s].name, D->sym[s].type);
        /* find the body first, so query bindings can be scoped to it */
        int body_open = p->i;
        if (have_query){
            int save = p->i;
            /* the query terms come before the body */
            int scan = p->i;
            while (scan < D->lex.n && !ltok_is(&D->lex, scan, "{") && D->lex.v[scan].kind != LT_EOF) scan++;
            int close = (scan < D->lex.n) ? D->match[scan] : -1;
            int bs = (scan < D->lex.n) ? D->lex.v[scan].start : 0;
            int be = close >= 0 ? D->lex.v[close].end : (int)strlen(D->text);
            p->i = save;
            lp_query_terms(p, s, vars, nv, bs, be);
            body_open = p->i;
        }
        (void)body_open;
        if (lp_is(p, "{")){
            int close = D->match[p->i];
            D->sym[s].body_start = D->lex.v[p->i].start;
            D->sym[s].body_end = close >= 0 ? D->lex.v[close].end : (int)strlen(D->text);
            lp_block(p, s, D->sym[s].body_end);
        }
        return;
    }
    if (!strcmp(w, "ui")){
        lp_adv(p); int nt = lp_name(p); if (nt < 0) return;
        int s = lsym_add(D, LS_UI, nt, parent);
        ldoc_collect_doc(D, decl_tok, D->sym[s].doc, sizeof(D->sym[s].doc));
        lcatf(D->sym[s].detail, sizeof(D->sym[s].detail), "ui %s", D->sym[s].name);
        /* the block name is a handle too */
        { int h = lsym_add(D, LS_WIDGET, nt, s);
          snprintf(D->sym[h].name, sizeof(D->sym[h].name), "UI_%s", D->sym[s].name);
          lcpy(D->sym[h].type, sizeof(D->sym[h].type), "int", 3);
          lcatf(D->sym[h].detail, sizeof(D->sym[h].detail), "root handle of ui %s", D->sym[s].name); }
        if (lp_is(p, "{")){
            int close = D->match[p->i];
            D->sym[s].body_start = D->lex.v[p->i].start;
            D->sym[s].body_end = close >= 0 ? D->lex.v[close].end : (int)strlen(D->text);
            lp_adv(p);
            while (p->i < D->lex.n && lp_kind(p) != LT_EOF && !lp_is(p, "}")){
                if (close >= 0 && p->i >= close) break;
                int before = p->i;
                lp_widget(p, s, s);
                if (p->i == before) lp_adv(p);
            }
            if (close >= 0) p->i = close + 1; else lp_adv(p);
            lp_skipnl(p);
        }
        return;
    }
    if (!strcmp(w, "scene")){
        lp_adv(p); int nt = lp_name(p); if (nt < 0) return;
        int s = lsym_add(D, LS_SCENE, nt, parent);
        ldoc_collect_doc(D, decl_tok, D->sym[s].doc, sizeof(D->sym[s].doc));
        int start = 0;
        if (lp_is(p, "start")){ start = 1; lp_adv(p); }
        lcatf(D->sym[s].detail, sizeof(D->sym[s].detail), "scene %s%s", D->sym[s].name, start ? " start" : "");
        if (lp_is(p, "{")){
            int close = D->match[p->i];
            D->sym[s].body_start = D->lex.v[p->i].start;
            D->sym[s].body_end = close >= 0 ? D->lex.v[close].end : (int)strlen(D->text);
            lp_adv(p);
            while (p->i < D->lex.n && lp_kind(p) != LT_EOF && !lp_is(p, "}")){
                if (close >= 0 && p->i >= close) break;
                int before = p->i;
                if (lp_is(p, "on")){ lp_adv(p); lp_name(p); lp_block(p, s, D->sym[s].body_end); }
                else if (lp_is(p, "layer")){
                    lp_adv(p); int lt = lp_name(p);
                    int ls = lt >= 0 ? lsym_add(D, LS_LAYER, lt, s) : -1;
                    if (ls >= 0) lcatf(D->sym[ls].detail, sizeof(D->sym[ls].detail), "layer %s of scene %s", D->sym[ls].name, D->sym[s].name);
                    if (lp_is(p, "{")){
                        int lc = D->match[p->i];
                        if (ls >= 0){ D->sym[ls].body_start = D->lex.v[p->i].start; D->sym[ls].body_end = lc >= 0 ? D->lex.v[lc].end : D->sym[s].body_end; }
                        lp_adv(p);
                        while (p->i < D->lex.n && lp_kind(p) != LT_EOF && !lp_is(p, "}")){
                            if (lc >= 0 && p->i >= lc) break;
                            int b2 = p->i; lp_decl(p, ls >= 0 ? ls : s);
                            if (p->i == b2) lp_adv(p);
                        }
                        if (lc >= 0) p->i = lc + 1; else lp_adv(p);
                        lp_skipnl(p);
                    }
                } else lp_adv(p);
                if (p->i == before) lp_adv(p);
            }
            if (close >= 0) p->i = close + 1; else lp_adv(p);
            lp_skipnl(p);
        }
        return;
    }
    lp_adv(p);
}

static void ldoc_parse(LDoc* D){
    D->nsym = 0;
    for (int i = 0; i < D->nimport; i++) free(D->imports[i]);
    free(D->imports); D->imports = 0; D->nimport = 0;
    D->is_unit = 0; D->is_module = 0; D->unit[0] = 0;

    LP p = { D, 0 };
    lp_skipnl(&p);
    while (lp_is(&p, "import")) { lp_decl(&p, -1); lp_skipnl(&p); }
    int unit_parent = -1;
    if (lp_is(&p, "game") || lp_is(&p, "module")){
        D->is_module = lp_is(&p, "module");
        D->is_unit = 1;
        lp_adv(&p);
        int nt = lp_name(&p);
        if (nt >= 0){
            unit_parent = lsym_add(D, LS_UNIT, nt, -1);
            lcpy(D->unit, sizeof(D->unit), D->sym[unit_parent].name, (int)strlen(D->sym[unit_parent].name));
            lcatf(D->sym[unit_parent].detail, sizeof(D->sym[unit_parent].detail), "%s %s", D->is_module ? "module" : "game", D->unit);
        }
        if (lp_is(&p, "{")){
            int close = D->match[p.i];
            if (unit_parent >= 0){
                D->sym[unit_parent].body_start = D->lex.v[p.i].start;
                D->sym[unit_parent].body_end = close >= 0 ? D->lex.v[close].end : (int)strlen(D->text);
            }
            lp_adv(&p);
            while (p.i < D->lex.n && lp_kind(&p) != LT_EOF && !lp_is(&p, "}")){
                if (close >= 0 && p.i >= close) break;
                int before = p.i; lp_decl(&p, unit_parent);
                if (p.i == before) lp_adv(&p);
            }
        }
        return;
    }
    /* A fragment: an imported file is a bare list of declarations. */
    while (p.i < D->lex.n && lp_kind(&p) != LT_EOF){
        int before = p.i; lp_decl(&p, -1);
        if (p.i == before) lp_adv(&p);
    }
}
#endif /* LUDIC_INDEX_H */
