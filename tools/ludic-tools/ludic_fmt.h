/* ============================================================================
 * ludic_fmt.h — the canonical Ludic formatter.
 *
 * This is deliberately NOT `ludicc --fmt`. The compiler's printer walks the AST
 * after import splicing, so it drops every comment and inlines every imported
 * file into whichever file you pointed it at — fine for inspecting what the
 * compiler saw, catastrophic as an editor's "format on save".
 *
 * This formatter works on the token stream instead:
 *   - comments and blank lines survive, because they are tokens;
 *   - nothing is ever dropped or reordered, because every token is re-emitted
 *     in order — the only freedom taken is the whitespace between them;
 *   - lines are re-indented and respaced but never joined or split, so the
 *     author keeps control of line structure and a format-on-save never
 *     rewrites a file out from under someone mid-edit.
 * ==========================================================================*/
#ifndef LUDIC_FMT_H
#define LUDIC_FMT_H

#include "ludic_syntax.h"

typedef struct { char* b; size_t n, cap; } FSB;
static void fsb_ensure(FSB* s, size_t add){
    if (s->n + add + 1 > s->cap){ s->cap = (s->n + add + 1) * 2; s->b = realloc(s->b, s->cap); }
}
static void fsb_add(FSB* s, const char* z, size_t l){ fsb_ensure(s, l); memcpy(s->b + s->n, z, l); s->n += l; s->b[s->n] = 0; }
static void fsb_puts(FSB* s, const char* z){ fsb_add(s, z, strlen(z)); }
static void fsb_putc(FSB* s, char c){ fsb_add(s, &c, 1); }
static void fsb_indent(FSB* s, int n){ for (int i = 0; i < n; i++) fsb_putc(s, ' '); }

/* Can this token be one side of a member access? */
static int lud_name_like(int kind){
    return kind == LT_ID || kind == LT_KW || kind == LT_TYPE || kind == LT_PHASE || kind == LT_BOOL;
}
/* A '.' hugs an operand, a closing bracket, and another dot — the last so that
 * a run of dots stays a run of dots instead of being spaced into pieces. */
static int lud_dot_tight(const LLex* L, const LTok* t){
    if (lud_name_like(t->kind)) return 1;
    if (t->kind != LT_OP) return 0;
    int n = ltok_len(t);
    char c0 = L->src[t->start];
    if (n == 1 && (c0 == ')' || c0 == ']' || c0 == '.')) return 1;
    if (n == 2 && c0 == '.' && L->src[t->start + 1] == '.') return 1;
    return 0;
}

/* Is the token at index i a unary '-' / '!' rather than a binary operator?
 * Unary iff nothing that can end an operand precedes it. */
static int fmt_is_unary(const LLex* L, int i){
    const LTok* t = &L->v[i];
    if (t->kind != LT_OP) return 0;
    int n = ltok_len(t);
    if (!(n == 1 && (L->src[t->start] == '-' || L->src[t->start] == '!'))) return 0;
    int p = ltok_prev_sig(L, i);
    if (p < 0) return 1;
    const LTok* pt = &L->v[p];
    switch (pt->kind){
        case LT_ID: case LT_INT: case LT_FLOAT: case LT_STR: case LT_CHAR:
        case LT_BOOL: case LT_TYPE: case LT_PHASE:
            return 0;
        case LT_OP: {
            char c = L->src[pt->start];
            /* a closing bracket ends an operand; every other operator does not */
            return !(ltok_len(pt) == 1 && (c == ')' || c == ']' || c == '}'));
        }
        default: return 1;   /* keyword, annotation, comment: operand starts here */
    }
}

/* Whitespace between the previous emitted token (prev) and the current one. */
static int fmt_space_before(const LLex* L, int prev, int cur){
    if (prev < 0) return 0;
    const LTok* p = &L->v[prev];
    const LTok* c = &L->v[cur];
    const char* src = L->src;
    int plen = ltok_len(p), clen = ltok_len(c);
    char p0 = src[p->start], c0 = src[c->start];
    int p1 = (plen == 1), c1 = (clen == 1);

    /* An error token is bytes we did not understand. Whatever spacing it had
     * is the only spacing we can justify, so it is preserved verbatim. */
    if (p->kind == LT_ERR || c->kind == LT_ERR) return c->start - p->end;

    /* nothing hugs a closer, a separator or a member dot from the left */
    if (c1 && (c0 == ')' || c0 == ']' || c0 == ',' || c0 == ':' || c0 == ';')) return 0;
    /* `.` binds tight only when it really is member access — `a.b`. A lone dot
     * next to a brace is something else (or a typo) and gets normal spacing. */
    if (c1 && c0 == '.' && c->kind == LT_OP && lud_dot_tight(L, p)) return 0;
    if (p1 && p0 == '.' && p->kind == LT_OP && lud_dot_tight(L, c)) return 0;
    /* nothing hugs an opener from the right */
    if (p1 && (p0 == '(' || p0 == '[') && p->kind == LT_OP) return 0;
    /* a unary sign binds to its operand */
    if (p->kind == LT_OP && fmt_is_unary(L, prev)) return 0;
    /* @anno(args) */
    if (p->kind == LT_ANNO && c1 && c0 == '(') return 0;

    if (c1 && c0 == '(' && c->kind == LT_OP){
        /* `fn move(` and `clear(` hug; `if (`, `return (`, `x * (` do not */
        switch (p->kind){
            case LT_ID: case LT_TYPE: case LT_PHASE: return 0;
            case LT_OP: return !(p1 && (p0 == ')' || p0 == ']'));
            default: return 1;
        }
    }
    return 1;
}

/* Clause keywords hang under the declaration they qualify: a system's
 * `phase`/`query` lines and a function's contract lines are indented one level
 * past the `system`/`fn` they belong to, with the body brace back at the
 * declaration's own level. Every example in the tree is written that way. */
static int fmt_is_clause_word(const LLex* L, int i){
    static const char* CLAUSES[] = { "phase","query","reads","writes","needs","uses",
                                     "requires","ensures","invariant","effects", 0 };
    if (i < 0 || i >= L->n || L->v[i].kind != LT_KW) return 0;
    char b[32]; ltok_text(L, i, b, sizeof(b));
    return lud_in(CLAUSES, b);
}

/* One pass over the token stream, re-emitting it with canonical whitespace.
 *
 * Two carve-outs keep the result idiomatic rather than merely uniform:
 *   - a run of two or more spaces is preserved verbatim, so hand-aligned
 *     columns (`const R_DIR:   int = 0`) and deliberately set-off trailing
 *     comments survive a format-on-save;
 *   - `id=Root` inside a `ui` block and `{Enemy}` inside a query stay tight,
 *     because those are the spellings the language documents and uses.
 */
static char* ludic_format(const char* src, int indent_width){
    LLex L; lud_lex(&L, src);
    FSB o = {0};
    /* One entry per open brace, holding the indent level to return to. Every
     * brace opened on the same line shares that line's level, so a line like
     * `if a { if b { if c {` steps in by ONE level, not three — and the line
     * that closes them all lands back where it started. */
    int stack[512]; int hang[512]; int sp = 0;
    int cur = 0;
    int open = 0;        /* unclosed ( or [ : the author owns the alignment    */
    int brack = 0;       /* unclosed [ only: query-term context                */
    int ui_depth = -1;   /* brace depth just outside the innermost `ui` block  */
    int pending_blank = 0;
    int wrote_any = 0;
    int prev_line_had_comment = 0;

    int i = 0;
    while (i < L.n && L.v[i].kind != LT_EOF){
        int a = i;
        while (i < L.n && L.v[i].kind != LT_NL && L.v[i].kind != LT_EOF) i++;
        int b = i;                       /* [a,b) are this line's tokens      */
        if (i < L.n && L.v[i].kind == LT_NL) i++;

        if (a == b){                     /* a blank line                      */
            if (wrote_any) pending_blank = 1;
            continue;
        }

        /* ---- where does this line start? --------------------------------- */
        int line_level = cur;
        {   /* leading closers belong to the level of the line that opened them */
            int tsp = sp, t = a;
            while (t < b && L.v[t].kind == LT_OP && ltok_len(&L.v[t]) == 1 && src[L.v[t].start] == '}'){
                if (tsp > 0) line_level = stack[--tsp];
                t++;
            }
        }
        /* Original column of this line, for the cases where the author's
         * alignment is the only sensible answer. */
        int orig_ind = 0;
        for (int k = L.linestart[L.v[a].line]; k < L.v[a].start; k++) orig_ind += (src[k] == '\t') ? 4 : 1;

        /* A comment on its own line, indented past its block and following a
         * line that itself ended in a comment, is the continuation of that
         * comment — a column the author chose, not stray indentation. */
        int comment_run = (L.v[a].kind == LT_COMMENT && b == a + 1 && prev_line_had_comment);

        int ind;
        if (open > 0 || (sp > 0 && hang[sp - 1])){
            /* Inside an unclosed call, query, or a brace that was opened with
             * content trailing it, the author is aligning to a column the
             * formatter cannot see. Leave those lines exactly as written. */
            int ls = L.linestart[L.v[a].line];
            ind = 0;
            for (int k = ls; k < L.v[a].start; k++) ind += (src[k] == '\t') ? 4 : 1;
        } else {
            ind = line_level * indent_width + (fmt_is_clause_word(&L, a) ? indent_width : 0);
            if (comment_run && orig_ind > ind) ind = orig_ind;
        }

        if (pending_blank && wrote_any) fsb_putc(&o, '\n');
        pending_blank = 0;
        fsb_indent(&o, ind);

        /* ---- the tokens --------------------------------------------------- */
        int prev = -1;
        int line_brack = brack, line_ui_open = (ui_depth >= 0 && sp > ui_depth);
        for (int t = a; t < b; t++){
            const LTok* tk = &L.v[t];
            int gap = (prev >= 0) ? tk->start - L.v[prev].end : 0;
            int want;

            if (tk->kind == LT_COMMENT){
                want = (prev >= 0) ? 2 : 0;         /* set a trailing comment off */
            } else {
                want = fmt_space_before(&L, prev, t);
                /* a query's {Tag} filter is one word, not a record literal */
                if (line_brack > 0){
                    if (tk->kind == LT_OP && ltok_len(tk) == 1 && src[tk->start] == '}') want = 0;
                    if (prev >= 0 && L.v[prev].kind == LT_OP && ltok_len(&L.v[prev]) == 1 && src[L.v[prev].start] == '{') want = 0;
                }
                /* widget props are written k=v */
                if (line_ui_open){
                    int eq_here = tk->kind == LT_OP && ltok_len(tk) == 1 && src[tk->start] == '=';
                    int eq_prev = prev >= 0 && L.v[prev].kind == LT_OP &&
                                  ltok_len(&L.v[prev]) == 1 && src[L.v[prev].start] == '=';
                    if (eq_here || eq_prev) want = 0;
                }
            }
            /* hand alignment wins over the canonical single space */
            if (gap >= 2 && want >= 1){ if (gap > 60) gap = 60; want = gap; }
            if (want < 0) want = 0;
            for (int k = 0; k < want; k++) fsb_putc(&o, ' ');
            fsb_add(&o, src + tk->start, ltok_len(tk));
            prev = t;

            if (tk->kind == LT_OP && ltok_len(tk) == 1){
                char c = src[tk->start];
                if (c == '[') line_brack++;
                else if (c == ']'){ line_brack--; if (line_brack < 0) line_brack = 0; }
            }
        }
        fsb_putc(&o, '\n');
        wrote_any = 1;
        prev_line_had_comment = (prev >= 0 && L.v[prev].kind == LT_COMMENT);

        /* ---- carry the nesting into the next line ------------------------- */
        if (ltok_is(&L, a, "ui") && L.v[a].kind == LT_KW && ui_depth < 0) ui_depth = sp;
        {
            int level = cur;
            for (int t = a; t < b; t++){
                const LTok* tk = &L.v[t];
                if (tk->kind != LT_OP || ltok_len(tk) != 1) continue;
                char c = src[tk->start];
                if (c == '{'){
                    if (sp < 512){
                        int nxt = ltok_next_sig(&L, t);
                        stack[sp] = line_level;
                        hang[sp] = (nxt >= 0 && nxt < b);   /* content follows on this line */
                        sp++;
                    }
                    level = line_level + 1;
                }
                else if (c == '}'){ if (sp > 0) level = stack[--sp]; }
                else if (c == '(' || c == '['){ open++; if (c == '[') brack++; }
                else if (c == ')' || c == ']'){ open--; if (open < 0) open = 0; if (c == ']'){ brack--; if (brack < 0) brack = 0; } }
            }
            cur = level;
        }
        if (ui_depth >= 0 && sp <= ui_depth) ui_depth = -1;
    }
    lud_lex_free(&L);
    if (!o.b) { o.b = malloc(1); o.b[0] = 0; }
    return o.b;
}

/* ---------- markdown ------------------------------------------------------
 * Fenced Ludic in prose is still Ludic. This rewrites the body of every
 * ```ludic fence in a Markdown document and leaves the prose untouched, so
 * LANGUAGE.md and README.md can be kept honest by the same formatter as the
 * source tree. Fence indentation (a fence inside a list item) is preserved.  */
static int md_fence_at(const char* s, int i, int* fence_len, int* info_at, char* marker){
    int j = i, n = 0;
    while (s[j] == ' ') j++;                    /* leading indent            */
    char m = s[j];
    if (m != '`' && m != '~') return 0;
    while (s[j] == m){ j++; n++; }
    if (n < 3) return 0;
    *fence_len = n; *info_at = j; *marker = m;
    return 1;
}
static int md_info_is_ludic(const char* s, int at){
    while (s[at] == ' ' || s[at] == '\t') at++;
    if (strncasecmp(s + at, "ludic", 5)) return 0;
    char after = s[at + 5];
    return after == 0 || after == '\n' || after == ' ' || after == '\t' || after == '\r';
}
static char* ludic_format_markdown(const char* src, int indent_width){
    FSB o = {0};
    int i = 0;
    while (src[i]){
        int ls = i;                                  /* line start           */
        int le = ls; while (src[le] && src[le] != '\n') le++;
        int flen, info, indent = 0; char marker;
        while (src[ls + indent] == ' ') indent++;
        if (md_fence_at(src, ls, &flen, &info, &marker) && md_info_is_ludic(src, info)){
            /* copy the opening fence line verbatim */
            fsb_add(&o, src + ls, le - ls + (src[le] ? 1 : 0));
            i = src[le] ? le + 1 : le;
            /* gather the body up to the closing fence */
            int bs = i;
            int be = bs;
            for (;;){
                if (!src[be]) break;
                int ps = be, pe = ps; while (src[pe] && src[pe] != '\n') pe++;
                int clen, cinfo; char cmark;
                if (md_fence_at(src, ps, &clen, &cinfo, &cmark) && cmark == marker && clen >= flen){
                    int only = 1;
                    for (int k = cinfo; k < pe; k++) if (src[k] != ' ' && src[k] != '\r'){ only = 0; break; }
                    if (only) break;
                }
                be = src[pe] ? pe + 1 : pe;
            }
            /* de-indent the body, format it, re-indent it */
            FSB body = {0};
            for (int p = bs; p < be; ){
                int q = p; while (src[q] && src[q] != '\n') q++;
                int skip = 0; while (skip < indent && p + skip < q && src[p + skip] == ' ') skip++;
                fsb_add(&body, src + p + skip, q - (p + skip));
                fsb_putc(&body, '\n');
                p = src[q] ? q + 1 : q;
            }
            char* f = ludic_format(body.b ? body.b : "", indent_width);
            for (char* p = f; *p; ){
                char* q = strchr(p, '\n'); if (!q) q = p + strlen(p);
                if (q > p) fsb_indent(&o, indent);
                fsb_add(&o, p, q - p);
                fsb_putc(&o, '\n');
                p = *q ? q + 1 : q;
            }
            free(f); free(body.b);
            i = be;
            continue;
        }
        fsb_add(&o, src + ls, le - ls + (src[le] ? 1 : 0));
        i = src[le] ? le + 1 : le;
    }
    if (!o.b){ o.b = malloc(1); o.b[0] = 0; }
    return o.b;
}
#endif /* LUDIC_FMT_H */
