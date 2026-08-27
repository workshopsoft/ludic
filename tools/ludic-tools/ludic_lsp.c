/* ============================================================================
 * ludic-lsp — the Ludic language server.
 *
 * Speaks LSP 3.17 over stdio, so it is the IDE-agnostic half of this toolchain:
 * VS Code, JetBrains, Neovim, Helix, Emacs, Sublime and Zed all drive the same
 * binary, and an editor nobody has written a plugin for yet still gets
 * completion, diagnostics, hover and formatting by pointing at it.
 *
 * It answers structural questions itself (from ludic_index.h, which keeps
 * parsing after an error the way a compiler must not), and defers questions of
 * correctness to `ludicc` — the compiler stays the single source of truth about
 * whether a program is valid.
 *
 * Markdown is a first-class input: a ```ludic fence in a .md gets the same
 * highlighting, hover and diagnostics as a .ludic file.
 * ==========================================================================*/
#define _GNU_SOURCE
#include "ludic_workspace.h"
#include "ludic_fmt.h"
#include "ludic_json.h"
#include <signal.h>

/* ---------- server state --------------------------------------------------*/
static LIndex  X;
static char*   g_ludicc     = 0;      /* path to the compiler, if we found one */
static int     g_indent     = 2;
static int     g_compiler_diags = 1;
static int     g_shutdown   = 0;
static int     g_utf8_positions = 0;  /* the client accepted utf-8 offsets      */
static FILE*   g_log        = 0;

static void lg(const char* fmt, ...){
    if (!g_log) return;
    va_list ap; va_start(ap, fmt); vfprintf(g_log, fmt, ap); va_end(ap);
    fputc('\n', g_log); fflush(g_log);
}

/* ---------- framing -------------------------------------------------------*/
static void send_raw(const char* body){
    printf("Content-Length: %zu\r\n\r\n%s", strlen(body), body);
    fflush(stdout);
}
static void send_result(JVal* id, const char* result_json){
    JSB s = {0};
    jsb_puts(&s, "{\"jsonrpc\":\"2.0\",\"id\":");
    if (!id) jsb_puts(&s, "null");
    else if (id->t == JSTR) jsb_str(&s, id->s);
    else jsb_putf(&s, "%ld", (long)id->num);
    jsb_puts(&s, ",\"result\":");
    jsb_puts(&s, result_json && *result_json ? result_json : "null");
    jsb_puts(&s, "}");
    send_raw(s.b); free(s.b);
}
static void send_notify(const char* method, const char* params_json){
    JSB s = {0};
    jsb_puts(&s, "{\"jsonrpc\":\"2.0\",\"method\":");
    jsb_str(&s, method);
    jsb_puts(&s, ",\"params\":");
    jsb_puts(&s, params_json ? params_json : "null");
    jsb_puts(&s, "}");
    send_raw(s.b); free(s.b);
}
/* Read one Content-Length framed message. NULL at EOF. */
static char* read_message(void){
    char line[8192];
    long len = -1;
    for (;;){
        if (!fgets(line, sizeof(line), stdin)) return 0;
        if (line[0] == '\r' || line[0] == '\n') break;
        if (!strncasecmp(line, "Content-Length:", 15)) len = strtol(line + 15, 0, 10);
    }
    if (len <= 0) return 0;
    char* buf = malloc(len + 1);
    long got = 0;
    while (got < len){
        size_t r = fread(buf + got, 1, len - got, stdin);
        if (!r) break;
        got += r;
    }
    buf[got] = 0;
    return buf;
}

/* ---------- position helpers ---------------------------------------------*/
static int pos_char(LDoc* D, int off){
    if (g_utf8_positions){
        int line = ldoc_line_of(D, off);
        return off - D->lex.linestart[line];
    }
    return ldoc_col_of(D, off);
}
static void put_pos(JSB* s, LDoc* D, int off){
    jsb_putf(s, "{\"line\":%d,\"character\":%d}", ldoc_line_of(D, off), pos_char(D, off));
}
static void put_range(JSB* s, LDoc* D, int a, int b){
    jsb_puts(s, "{\"start\":"); put_pos(s, D, a);
    jsb_puts(s, ",\"end\":");   put_pos(s, D, b);
    jsb_puts(s, "}");
}
static void put_location(JSB* s, LDoc* D, int a, int b){
    jsb_puts(s, "{\"uri\":"); jsb_str(s, D->uri);
    jsb_puts(s, ",\"range\":"); put_range(s, D, a, b);
    jsb_puts(s, "}");
}

/* ---------- diagnostics ---------------------------------------------------*/
typedef struct { LDoc* doc; LDiag* v; int n, cap; } DiagSet;
static void diag_add(DiagSet* ds, LDoc* D, int line, int col, int endline, int endcol, int sev, const char* msg){
    if (ds->n >= ds->cap){ ds->cap = ds->cap ? ds->cap * 2 : 16; ds->v = realloc(ds->v, ds->cap * sizeof(LDiag)); }
    LDiag* d = &ds->v[ds->n++];
    memset(d, 0, sizeof(*d));
    d->line = line; d->col = col; d->endline = endline; d->endcol = endcol; d->severity = sev;
    snprintf(d->msg, sizeof(d->msg), "%s", msg);
    snprintf(d->path, sizeof(d->path), "%s", D->path);
}
/* Structural problems we can see without the compiler, cheaply, on every
 * keystroke: unbalanced delimiters and unterminated literals. */
static void diag_structural(LDoc* D, DiagSet* ds){
    int stack[512], top = 0;
    for (int i = 0; i < D->lex.n; i++){
        const LTok* t = &D->lex.v[i];
        if (t->bad){
            const char* m = t->kind == LT_STR  ? "unterminated string literal"
                          : t->kind == LT_CHAR ? "unterminated character literal"
                          : "unexpected character";
            diag_add(ds, D, ldoc_line_of(D, t->start), pos_char(D, t->start),
                         ldoc_line_of(D, t->end), pos_char(D, t->end), 1, m);
            continue;
        }
        if (t->kind != LT_OP || ltok_len(t) != 1) continue;
        char c = D->text[t->start];
        if (c == '{' || c == '(' || c == '['){ if (top < 512) stack[top++] = i; }
        else if (c == '}' || c == ')' || c == ']'){
            if (!top){
                char m[64]; snprintf(m, sizeof(m), "unmatched '%c'", c);
                diag_add(ds, D, ldoc_line_of(D, t->start), pos_char(D, t->start),
                             ldoc_line_of(D, t->end), pos_char(D, t->end), 1, m);
            } else {
                int o = stack[--top];
                char oc = D->text[D->lex.v[o].start];
                char want = oc == '{' ? '}' : oc == '(' ? ')' : ']';
                if (want != c){
                    char m[80]; snprintf(m, sizeof(m), "expected '%c' to close '%c', found '%c'", want, oc, c);
                    diag_add(ds, D, ldoc_line_of(D, t->start), pos_char(D, t->start),
                                 ldoc_line_of(D, t->end), pos_char(D, t->end), 1, m);
                }
            }
        }
    }
    for (int k = 0; k < top; k++){
        const LTok* t = &D->lex.v[stack[k]];
        char m[64]; snprintf(m, sizeof(m), "unclosed '%c'", D->text[t->start]);
        diag_add(ds, D, ldoc_line_of(D, t->start), pos_char(D, t->start),
                     ldoc_line_of(D, t->end), pos_char(D, t->end), 1, m);
    }
}

/* Ask the compiler. `ludicc --fmt` runs lex + parse + validate and stops before
 * codegen, which is exactly the checking pass we want and costs milliseconds.
 * A fragment (an imported file with no `game` block) is not a program on its
 * own, so we check the unit root that pulls it in and let the file paths in the
 * compiler's own output route each error back to the right buffer. */
static void diag_compiler(LDoc* D, DiagSet* ds){
    if (!g_ludicc || !g_compiler_diags) return;
    /* A .md is Ludic only inside its fences; the file as a whole is prose, and
     * handing it to the compiler yields errors about the prose. The fences are
     * still checked structurally, which is as far as a fragment can be checked
     * anyway — most of them are deliberately incomplete snippets. */
    if (D->is_markdown) return;
    LDoc* root = lw_unit_root(&X, D);
    if (!root) root = D->is_unit ? D : 0;
    if (!root) return;
    /* Paths reach us from URIs the editor sends, and they end up in a shell
     * command. A quote in a path would let a filename run something; refuse
     * rather than escape, since no real Ludic file needs one. */
    if (strchr(root->path, '\'') || strchr(g_ludicc, '\'')) return;

    /* the compiler reads from disk; an unsaved buffer would be checked stale */
    char cmd[PATH_MAX * 2 + 64];
    snprintf(cmd, sizeof(cmd), "'%s' '%s' --fmt -o /dev/null 2>&1", g_ludicc, root->path);
    FILE* p = popen(cmd, "r");
    if (!p) return;
    char line[4096];
    char msg[512]; msg[0] = 0;
    int have = 0, lineno = 0;
    while (fgets(line, sizeof(line), p)){
        size_t n = strlen(line);
        while (n && (line[n-1] == '\n' || line[n-1] == '\r')) line[--n] = 0;
        int ln;
        char rest[1024];
        if (sscanf(line, "ludicc: error: line %d: %1023[^\n]", &ln, rest) == 2){
            if (have){ diag_add(ds, root, lineno - 1, 0, lineno - 1, 200, 1, msg); }
            lineno = ln; snprintf(msg, sizeof(msg), "%s", rest); have = 1;
            continue;
        }
        /* the follow-up line names the file the error is really in */
        char path[1024];
        if (have && sscanf(line, " %1023[^:]:%d |", path, &ln) == 2){
            LDoc* target = lw_ensure(&X, path);
            if (!target) target = root;
            int l0 = ln - 1;
            int end = 200;
            if (l0 >= 0 && l0 < target->lex.nline){
                int s0 = target->lex.linestart[l0];
                int e0 = (l0 + 1 < target->lex.nline) ? target->lex.linestart[l0+1] - 1 : (int)strlen(target->text);
                end = pos_char(target, e0 > s0 ? e0 : s0);
            }
            diag_add(ds, target, l0, 0, l0, end, 1, msg);
            have = 0; msg[0] = 0;
            continue;
        }
        if (!have && !strncmp(line, "ludicc: ", 8) && !strstr(line, "error: line")){
            diag_add(ds, root, 0, 0, 0, 0, 1, line + 8);
        }
    }
    if (have) diag_add(ds, root, lineno - 1, 0, lineno - 1, 200, 1, msg);
    pclose(p);
}

/* Publish for every document that got a diagnostic, and clear the rest.
 *
 * Markdown gets none. A fence in prose is a snippet — `system Move { … }` with
 * an elision mark, or a body shown without its enclosing `game` block — so
 * almost every "error" found there is the documentation doing its job. The
 * useful half of the server still applies to fences: highlighting, hover,
 * completion, go-to-definition and formatting are never wrong on a snippet. */
static void publish_diagnostics(LDoc* D){
    DiagSet ds = {0};
    if (!D->is_markdown) diag_structural(D, &ds);
    /* only bother the compiler when the buffer itself parses — otherwise we are
     * reporting the same brace twice, in two different dialects */
    int structural = ds.n;
    if (!structural) diag_compiler(D, &ds);

    /* Every document that has a diagnostic now, plus every document that had
     * one last time — otherwise fixing an error in an imported file leaves its
     * marker on screen forever, because nothing would ever publish an empty
     * list for that file again. */
    LDoc* touched[128]; int nt = 0;
    touched[nt++] = D;
    for (int i = 0; i < ds.n; i++){
        LDoc* T = lw_by_path(&X, ds.v[i].path);
        if (!T) continue;
        int seen = 0; for (int k = 0; k < nt; k++) if (touched[k] == T) seen = 1;
        if (!seen && nt < 128) touched[nt++] = T;
    }
    for (int i = 0; i < X.n && nt < 128; i++){
        if (!X.d[i]->had_diags) continue;
        int seen = 0; for (int k = 0; k < nt; k++) if (touched[k] == X.d[i]) seen = 1;
        if (!seen) touched[nt++] = X.d[i];
    }
    for (int k = 0; k < nt; k++){
        LDoc* T = touched[k];
        T->had_diags = 0;
        JSB s = {0};
        jsb_puts(&s, "{\"uri\":"); jsb_str(&s, T->uri);
        jsb_puts(&s, ",\"diagnostics\":[");
        int first = 1;
        for (int i = 0; i < ds.n; i++){
            if (strcmp(ds.v[i].path, T->path)) continue;
            if (!first) jsb_putc(&s, ',');
            first = 0;
            T->had_diags = 1;
            jsb_putf(&s, "{\"range\":{\"start\":{\"line\":%d,\"character\":%d},\"end\":{\"line\":%d,\"character\":%d}}",
                     ds.v[i].line < 0 ? 0 : ds.v[i].line, ds.v[i].col,
                     ds.v[i].endline < 0 ? 0 : ds.v[i].endline, ds.v[i].endcol);
            jsb_putf(&s, ",\"severity\":%d,\"source\":\"ludic\",\"message\":", ds.v[i].severity);
            jsb_str(&s, ds.v[i].msg);
            jsb_putc(&s, '}');
        }
        jsb_puts(&s, "]}");
        send_notify("textDocument/publishDiagnostics", s.b);
        free(s.b);
    }
    free(ds.v);
}

/* ---------- semantic tokens ----------------------------------------------*/
/* The legend, in the order the client will index into. */
static const char* STOK_TYPES[] = {
    "keyword","type","struct","class","namespace","function","parameter",
    "variable","property","enumMember","number","string","comment","operator",
    "decorator", 0
};
enum { STM_DECL = 1, STM_READONLY = 2, STM_DEFLIB = 4 };
static const char* STOK_MODS[] = { "declaration","readonly","defaultLibrary", 0 };

static int sem_type_of(int cls, int* mods){
    *mods = 0;
    switch (cls){
        case SC_KEYWORD:    return 0;
        case SC_TYPE:       *mods = STM_DEFLIB; return 1;
        case SC_COMPONENT:  return 2;
        case SC_ARCHETYPE:  return 3;
        case SC_SCENE:      return 4;
        case SC_LAYER:      return 4;
        case SC_UI:         return 3;
        case SC_WIDGET:     *mods = STM_DEFLIB; return 3;
        case SC_SYSTEM:     return 5;
        case SC_FUNCTION:   return 5;
        case SC_BUILTIN:    *mods = STM_DEFLIB; return 5;
        case SC_PARAM:      return 6;
        case SC_VARIABLE:   return 7;
        case SC_MODVAR:     return 7;
        case SC_CONST:      *mods = STM_READONLY; return 7;
        case SC_PROP:       return 8;
        case SC_FIELD:      return 8;
        case SC_PHASE:      *mods = STM_READONLY | STM_DEFLIB; return 9;
        case SC_NUMBER:     return 10;
        case SC_STRING:     return 11;
        case SC_COMMENT:    return 12;
        case SC_OPERATOR:   return 13;
        case SC_ANNOTATION: return 14;
        default:            return -1;
    }
}
static char* semantic_tokens(LDoc* D, int from_line, int to_line){
    lw_classify(&X, D);
    JSB s = {0};
    jsb_puts(&s, "{\"data\":[");
    int prev_line = 0, prev_char = 0, first = 1;
    for (int i = 0; i < D->lex.n; i++){
        const LTok* t = &D->lex.v[i];
        if (t->kind == LT_NL || t->kind == LT_EOF) continue;
        if (t->line < from_line || (to_line >= 0 && t->line > to_line)) continue;
        int mods; int ty = sem_type_of(D->cls[i], &mods);
        if (ty < 0) continue;
        int line = t->line;
        int ch = pos_char(D, t->start);
        int len = g_utf8_positions ? ltok_len(t) : lutf16_len(D->text + t->start, ltok_len(t));
        if (len <= 0) continue;
        int dl = line - prev_line;
        int dc = dl ? ch : ch - prev_char;
        if (!first) jsb_putc(&s, ',');
        first = 0;
        jsb_putf(&s, "%d,%d,%d,%d,%d", dl, dc, len, ty, mods);
        prev_line = line; prev_char = ch;
    }
    jsb_puts(&s, "]}");
    return s.b;
}

/* ---------- symbol presentation ------------------------------------------*/
static int lsp_symbol_kind(int k){
    switch (k){                                  /* LSP SymbolKind numbers    */
        case LS_UNIT:      return 2;             /* Module                    */
        case LS_COMPONENT: return 23;            /* Struct                    */
        case LS_FIELD:     return 8;             /* Field                     */
        case LS_ARCHETYPE: return 5;             /* Class                     */
        case LS_CONST:     return 14;            /* Constant                  */
        case LS_VAR:       return 13;            /* Variable                  */
        case LS_FN:        return 12;            /* Function                  */
        case LS_EXTERN:    return 12;
        case LS_SYSTEM:    return 6;             /* Method                    */
        case LS_UI:        return 5;
        case LS_WIDGET:    return 14;
        case LS_SCENE:     return 3;             /* Namespace                 */
        case LS_LAYER:     return 3;
        case LS_PARAM:     return 13;
        case LS_LOCAL:     return 13;
        case LS_QUERYVAR:  return 13;
        case LS_STATE:     return 22;            /* EnumMember                */
        case LS_IMPORT:    return 2;
        default:           return 13;
    }
}
static int sym_is_outline(int k){
    switch (k){
        case LS_UNIT: case LS_COMPONENT: case LS_FIELD: case LS_ARCHETYPE:
        case LS_CONST: case LS_VAR: case LS_FN: case LS_EXTERN: case LS_SYSTEM:
        case LS_UI: case LS_WIDGET: case LS_SCENE: case LS_LAYER:
            return 1;
        default: return 0;
    }
}
/* DocumentSymbol is a tree; emit children of `parent` recursively. */
static void put_doc_symbols(JSB* s, LDoc* D, int parent){
    int first = 1;
    jsb_putc(s, '[');
    for (int i = 0; i < D->nsym; i++){
        LSym* y = &D->sym[i];
        if (y->parent != parent || !sym_is_outline(y->kind) || !y->name[0]) continue;
        if (!first) jsb_putc(s, ',');
        first = 0;
        jsb_puts(s, "{\"name\":"); jsb_str(s, y->name);
        jsb_puts(s, ",\"detail\":"); jsb_str(s, y->detail);
        jsb_putf(s, ",\"kind\":%d,\"range\":", lsp_symbol_kind(y->kind));
        int a = y->start, b = y->end;
        if (y->body_end > y->end && y->body_start >= y->start){ a = y->start; b = y->body_end; }
        put_range(s, D, a, b);
        jsb_puts(s, ",\"selectionRange\":"); put_range(s, D, y->start, y->end);
        jsb_puts(s, ",\"children\":");
        put_doc_symbols(s, D, i);
        jsb_putc(s, '}');
    }
    jsb_putc(s, ']');
}

/* ---------- hover ---------------------------------------------------------*/
static void hover_markdown(JSB* s, const char* code, const char* doc){
    JSB m = {0};
    jsb_puts(&m, "```ludic\n");
    jsb_puts(&m, code);
    jsb_puts(&m, "\n```");
    if (doc && *doc){ jsb_puts(&m, "\n\n"); jsb_puts(&m, doc); }
    jsb_puts(s, "{\"contents\":{\"kind\":\"markdown\",\"value\":");
    jsb_str(s, m.b);
    jsb_puts(s, "}}");
    free(m.b);
}

/* ---------- completion ----------------------------------------------------*/
enum { CI_TEXT = 1, CI_METHOD = 2, CI_FUNCTION = 3, CI_FIELD = 5, CI_VARIABLE = 6,
       CI_CLASS = 7, CI_PROPERTY = 10, CI_UNIT = 11, CI_VALUE = 12, CI_ENUM = 13,
       CI_KEYWORD = 14, CI_SNIPPET = 15, CI_CONSTANT = 21, CI_STRUCT = 22, CI_EVENT = 23 };

typedef struct { JSB* s; int first; } CompOut;
static void comp_item(CompOut* c, const char* label, int kind, const char* detail, const char* doc, const char* insert){
    if (!c->first) jsb_putc(c->s, ',');
    c->first = 0;
    jsb_puts(c->s, "{\"label\":"); jsb_str(c->s, label);
    jsb_putf(c->s, ",\"kind\":%d", kind);
    if (detail && *detail){ jsb_puts(c->s, ",\"detail\":"); jsb_str(c->s, detail); }
    if (doc && *doc){
        jsb_puts(c->s, ",\"documentation\":{\"kind\":\"markdown\",\"value\":");
        jsb_str(c->s, doc);
        jsb_putc(c->s, '}');
    }
    if (insert && *insert){
        jsb_puts(c->s, ",\"insertText\":"); jsb_str(c->s, insert);
        jsb_puts(c->s, ",\"insertTextFormat\":2");
    }
    jsb_putc(c->s, '}');
}
static void comp_words(CompOut* c, const char** words, int kind, const char* detail){
    for (int i = 0; words[i]; i++) comp_item(c, words[i], kind, detail, 0, 0);
}
static void comp_builtins(CompOut* c){
    for (int i = 0; LUDIC_BUILTINS[i].name; i++)
        comp_item(c, LUDIC_BUILTINS[i].name, CI_FUNCTION, LUDIC_BUILTINS[i].sig, LUDIC_BUILTINS[i].doc, 0);
    for (int i = 0; LUDIC_INTRINSICS[i].name; i++)
        comp_item(c, LUDIC_INTRINSICS[i].name, CI_FUNCTION, LUDIC_INTRINSICS[i].sig, LUDIC_INTRINSICS[i].doc, 0);
}
static int comp_kind_of(int symkind){
    switch (symkind){
        case LS_COMPONENT: return CI_STRUCT;
        case LS_ARCHETYPE: return CI_CLASS;
        case LS_CONST:     return CI_CONSTANT;
        case LS_VAR:       return CI_VARIABLE;
        case LS_FN: case LS_EXTERN: return CI_FUNCTION;
        case LS_SYSTEM:    return CI_EVENT;
        case LS_UI:        return CI_CLASS;
        case LS_WIDGET:    return CI_CONSTANT;
        case LS_SCENE:     return CI_UNIT;
        case LS_LAYER:     return CI_UNIT;
        case LS_FIELD:     return CI_FIELD;
        default:           return CI_VARIABLE;
    }
}
/* Everything the compilation unit declares, plus the locals in scope here.
 * `types_only` is for the positions where nothing but a component or archetype
 * can appear — a query's term list, a `spawn`, a type annotation — and there a
 * local variable is not a candidate at all. */
static void comp_scope(CompOut* c, LDoc* D, int off, int types_only){
    if (!types_only)
        for (int i = 0; i < D->nsym; i++){
            LSym* y = &D->sym[i];
            if (!lsym_is_local(y->kind)) continue;
            if (off < y->body_start || off > y->body_end) continue;
            comp_item(c, y->name, CI_VARIABLE, y->detail[0] ? y->detail : y->type, 0, 0);
        }
    LDoc* rel[128]; int n = lw_related(&X, D, rel, 128);
    for (int i = 0; i < n; i++)
        for (int k = 0; k < rel[i]->nsym; k++){
            LSym* y = &rel[i]->sym[k];
            if (!lsym_is_toplevel(y->kind) || y->kind == LS_UNIT) continue;
            if (types_only && !(y->kind == LS_COMPONENT || y->kind == LS_ARCHETYPE)) continue;
            comp_item(c, y->name, comp_kind_of(y->kind), y->detail, y->doc, 0);
        }
}

/* ---------- URI/doc plumbing ---------------------------------------------*/
static LDoc* doc_of(JVal* msg){
    const char* uri = jstr(jpath(msg, "params.textDocument.uri"), 0);
    if (!uri) return 0;
    LDoc* D = lw_by_uri(&X, uri);
    if (D) return D;
    char* path = lw_uri_to_path(uri);
    D = lw_ensure(&X, path);
    free(path);
    return D;
}
static int off_of(JVal* msg, LDoc* D, const char* base){
    char kl[128], kc[128];
    snprintf(kl, sizeof(kl), "%s.line", base);
    snprintf(kc, sizeof(kc), "%s.character", base);
    int line = jint(jpath(msg, kl), 0), ch = jint(jpath(msg, kc), 0);
    if (g_utf8_positions){
        if (line < 0 || line >= D->lex.nline) return 0;
        int s0 = D->lex.linestart[line];
        int e0 = (line + 1 < D->lex.nline) ? D->lex.linestart[line + 1] : (int)strlen(D->text);
        int off = s0 + ch;
        return off > e0 ? e0 : off;
    }
    return ldoc_offset_of(D, line, ch);
}

/* ---------- request handlers ---------------------------------------------*/
static void on_initialize(JVal* msg, JVal* id){
    JVal* root = jpath(msg, "params.rootUri");
    if (root && root->t == JSTR) X.root = lw_uri_to_path(root->s);
    else {
        JVal* folders = jpath(msg, "params.workspaceFolders");
        JVal* f0 = jat(folders, 0);
        const char* u = jstr(jget(f0, "uri"), 0);
        if (u) X.root = lw_uri_to_path(u);
    }
    /* the client may prefer plain byte offsets; take it if offered, it is both
     * cheaper and exactly what our lexer already produces */
    JVal* enc = jpath(msg, "params.capabilities.general.positionEncodings");
    if (enc) for (int i = 0; i < enc->n; i++){
        const char* e = jstr(jat(enc, i), "");
        if (!strcmp(e, "utf-8")){ g_utf8_positions = 1; break; }
    }
    JVal* init = jpath(msg, "params.initializationOptions");
    const char* cc = jstr(jget(init, "compilerPath"), 0);
    if (cc && *cc){ free(g_ludicc); g_ludicc = strdup(cc); }
    if (jget(init, "indentSize")) g_indent = jint(jget(init, "indentSize"), 2);
    if (jget(init, "compilerDiagnostics")) g_compiler_diags = jbool(jget(init, "compilerDiagnostics"), 1);

    /* find the compiler if nobody told us where it is */
    if (!g_ludicc && X.root){
        char p[PATH_MAX];
        snprintf(p, sizeof(p), "%s/build/ludicc", X.root);
        if (!access(p, X_OK)) g_ludicc = strdup(p);
    }
    if (!g_ludicc && !access("build/ludicc", X_OK)) g_ludicc = strdup("build/ludicc");

    if (X.root) lw_scan(&X, X.root, 0);
    lg("initialize root=%s compiler=%s docs=%d", X.root ? X.root : "-", g_ludicc ? g_ludicc : "-", X.n);

    JSB s = {0};
    jsb_puts(&s, "{\"capabilities\":{");
    jsb_puts(&s, "\"positionEncoding\":");
    jsb_str(&s, g_utf8_positions ? "utf-8" : "utf-16");
    jsb_puts(&s, ",\"textDocumentSync\":{\"openClose\":true,\"change\":1,\"save\":{\"includeText\":false}}");
    jsb_puts(&s, ",\"documentSymbolProvider\":true");
    jsb_puts(&s, ",\"workspaceSymbolProvider\":true");
    jsb_puts(&s, ",\"definitionProvider\":true");
    jsb_puts(&s, ",\"declarationProvider\":true");
    jsb_puts(&s, ",\"referencesProvider\":true");
    jsb_puts(&s, ",\"documentHighlightProvider\":true");
    jsb_puts(&s, ",\"hoverProvider\":true");
    jsb_puts(&s, ",\"renameProvider\":{\"prepareProvider\":true}");
    jsb_puts(&s, ",\"documentFormattingProvider\":true");
    jsb_puts(&s, ",\"documentRangeFormattingProvider\":true");
    jsb_puts(&s, ",\"foldingRangeProvider\":true");
    jsb_puts(&s, ",\"documentLinkProvider\":{\"resolveProvider\":false}");
    jsb_puts(&s, ",\"inlayHintProvider\":true");
    jsb_puts(&s, ",\"completionProvider\":{\"triggerCharacters\":[\".\",\"@\",\"[\",\" \"],\"resolveProvider\":false}");
    jsb_puts(&s, ",\"signatureHelpProvider\":{\"triggerCharacters\":[\"(\",\",\"]}");
    jsb_puts(&s, ",\"semanticTokensProvider\":{\"legend\":{\"tokenTypes\":[");
    for (int i = 0; STOK_TYPES[i]; i++){ if (i) jsb_putc(&s, ','); jsb_str(&s, STOK_TYPES[i]); }
    jsb_puts(&s, "],\"tokenModifiers\":[");
    for (int i = 0; STOK_MODS[i]; i++){ if (i) jsb_putc(&s, ','); jsb_str(&s, STOK_MODS[i]); }
    jsb_puts(&s, "]},\"full\":true,\"range\":true}");
    jsb_puts(&s, "},\"serverInfo\":{\"name\":\"ludic-lsp\",\"version\":\"1.0.0\"}}");
    send_result(id, s.b);
    free(s.b);
}

static void on_document_symbol(JVal* msg, JVal* id){
    LDoc* D = doc_of(msg);
    if (!D){ send_result(id, "[]"); return; }
    JSB s = {0};
    put_doc_symbols(&s, D, -1);
    send_result(id, s.b);
    free(s.b);
}

static void on_workspace_symbol(JVal* msg, JVal* id){
    const char* q = jstr(jpath(msg, "params.query"), "");
    JSB s = {0}; jsb_putc(&s, '[');
    int first = 1;
    for (int i = 0; i < X.n; i++){
        LDoc* D = X.d[i];
        for (int k = 0; k < D->nsym; k++){
            LSym* y = &D->sym[k];
            if (!sym_is_outline(y->kind) || !y->name[0]) continue;
            if (*q && !strcasestr(y->name, q)) continue;
            if (!first) jsb_putc(&s, ',');
            first = 0;
            jsb_puts(&s, "{\"name\":"); jsb_str(&s, y->name);
            jsb_putf(&s, ",\"kind\":%d,\"location\":", lsp_symbol_kind(y->kind));
            put_location(&s, D, y->start, y->end);
            if (D->unit[0]){ jsb_puts(&s, ",\"containerName\":"); jsb_str(&s, D->unit); }
            jsb_putc(&s, '}');
        }
    }
    jsb_putc(&s, ']');
    send_result(id, s.b);
    free(s.b);
}

/* What does this exact token refer to? Every feature that needs to know two
 * occurrences are the same thing — go-to-definition, find-usages, rename,
 * highlight — goes through here, so they cannot disagree with each other. */
static int resolve_tok(LDoc* D, int tok, LDoc** owner, int* symidx){
    *owner = 0; *symidx = -1;
    if (tok < 0) return -1;
    if (D->lex.v[tok].kind != LT_ID && D->lex.v[tok].kind != LT_STR) return -1;
    char name[96]; ltok_text(&D->lex, tok, name, sizeof(name));

    /* The token may BE a declaration's name — a component, a field, a
     * parameter, a query binding. Those resolve to themselves, which is what
     * makes hover work on the left-hand side of `for (a, b) in query [...]`
     * where the binding is not yet inside its own scope. */
    for (int i = 0; i < D->nsym; i++)
        if (D->sym[i].tok == tok){ *owner = D; *symidx = i; return tok; }

    /* a member: resolve through the receiver's component */
    int prev = ltok_prev_sig(&D->lex, tok);
    if (prev >= 0 && ltok_is(&D->lex, prev, ".")){
        LDoc* co = 0;
        int comp = lw_receiver_component(&X, D, prev, &co);
        if (comp >= 0 && co){
            for (int i = 0; i < co->nsym; i++)
                if (co->sym[i].kind == LS_FIELD && co->sym[i].parent == comp && !strcmp(co->sym[i].name, name)){
                    *owner = co; *symidx = i; return tok;
                }
        }
        return tok;
    }
    int l = lw_find_local(D, name, D->lex.v[tok].start);
    if (l >= 0){ *owner = D; *symidx = l; return tok; }
    LDoc* o = 0; int t = lw_find_top(&X, D, name, &o);
    if (t >= 0){ *owner = o; *symidx = t; return tok; }
    return tok;
}
static int resolve_at(LDoc* D, int off, LDoc** owner, int* symidx){
    return resolve_tok(D, ldoc_tok_at(D, off), owner, symidx);
}
/* Occurrences of one symbol, found by resolving each candidate token rather
 * than by matching text. It is the difference between renaming a component
 * field `x` and renaming every `x` in the project. */
typedef void (*OccFn)(void* ctx, LDoc* T, int tok);
static void for_each_occurrence(LDoc* from, LDoc* target_doc, int target_sym, OccFn fn, void* ctx){
    char want[96];
    lcpy(want, sizeof(want), target_doc->text + target_doc->sym[target_sym].start,
         target_doc->sym[target_sym].end - target_doc->sym[target_sym].start);

    /* A local binding cannot be referred to from another file, so there is no
     * reason to walk the unit for one. */
    LDoc* single[1] = { from };
    LDoc* rel[128];
    int n;
    if (lsym_is_local(target_doc->sym[target_sym].kind)){ rel[0] = single[0]; n = 1; }
    else n = lw_related(&X, from, rel, 128);

    for (int i = 0; i < n; i++){
        LDoc* T = rel[i];
        for (int k = 0; k < T->lex.n; k++){
            if (T->lex.v[k].kind != LT_ID) continue;
            char w[96]; ltok_text(&T->lex, k, w, sizeof(w));
            if (strcmp(w, want)) continue;               /* cheap filter first */
            LDoc* o = 0; int sy = -1;
            resolve_tok(T, k, &o, &sy);
            if (o == target_doc && sy == target_sym) fn(ctx, T, k);
        }
    }
}

static void on_definition(JVal* msg, JVal* id){
    LDoc* D = doc_of(msg);
    if (!D){ send_result(id, "null"); return; }
    int off = off_of(msg, D, "params.position");
    /* an import string jumps to the file */
    int tok = ldoc_tok_at(D, off);
    if (tok >= 0 && D->lex.v[tok].kind == LT_STR){
        int p = ltok_prev_sig(&D->lex, tok);
        if (p >= 0 && ltok_is(&D->lex, p, "import")){
            char rel[512]; ltok_text(&D->lex, tok, rel, sizeof(rel));
            int n = (int)strlen(rel); if (n >= 2){ memmove(rel, rel + 1, n - 2); rel[n-2] = 0; }
            char* dir = lw_dirname(D->path);
            char* full = lw_join(dir, rel); free(dir);
            LDoc* T = lw_ensure(&X, full); free(full);
            if (T){ JSB s = {0}; put_location(&s, T, 0, 0); send_result(id, s.b); free(s.b); return; }
        }
    }
    LDoc* owner = 0; int sym = -1;
    resolve_at(D, off, &owner, &sym);
    if (!owner || sym < 0){ send_result(id, "null"); return; }
    JSB s = {0};
    put_location(&s, owner, owner->sym[sym].start, owner->sym[sym].end);
    send_result(id, s.b);
    free(s.b);
}

static void on_hover(JVal* msg, JVal* id){
    LDoc* D = doc_of(msg);
    if (!D){ send_result(id, "null"); return; }
    int off = off_of(msg, D, "params.position");
    int tok = ldoc_tok_at(D, off);
    if (tok < 0){ send_result(id, "null"); return; }
    char name[128]; ltok_text(&D->lex, tok, name, sizeof(name));

    LDoc* owner = 0; int sym = -1;
    resolve_at(D, off, &owner, &sym);
    JSB s = {0};
    if (owner && sym >= 0){
        LSym* y = &owner->sym[sym];
        char code[320];
        snprintf(code, sizeof(code), "%s", y->detail[0] ? y->detail : y->name);
        char doc[768];
        snprintf(doc, sizeof(doc), "%s", y->doc);
        if (owner != D){
            size_t n = strlen(doc);
            snprintf(doc + n, sizeof(doc) - n, "%s_declared in %s_", n ? "\n\n" : "", strrchr(owner->path, '/') ? strrchr(owner->path, '/') + 1 : owner->path);
        }
        hover_markdown(&s, code, doc);
        send_result(id, s.b); free(s.b); return;
    }
    const LBuiltin* bi = lud_lookup(LUDIC_BUILTINS, name);
    const char* origin = "runtime builtin — provided by `rt_` in runtime/native";
    if (!bi){ bi = lud_lookup(LUDIC_INTRINSICS, name); origin = "compiler intrinsic — lowers straight to libc / the OS"; }
    if (bi){
        char doc[768]; snprintf(doc, sizeof(doc), "%s\n\n_%s_", bi->doc, origin);
        hover_markdown(&s, bi->sig, doc);
        send_result(id, s.b); free(s.b); return;
    }
    if (D->lex.v[tok].kind == LT_PHASE){
        hover_markdown(&s, name, "A system phase. Each frame runs `Input` -> `FixedUpdate` -> `Update` -> `LateUpdate` -> `Render`; `Start` runs once at boot.");
        send_result(id, s.b); free(s.b); return;
    }
    if (D->lex.v[tok].kind == LT_TYPE){
        static const struct { const char* n; const char* d; } TY[] = {
            {"int","32-bit integer."},
            {"fixed","Q16.16 fixed-point. `fx(i)` widens an int, `flr(f)` truncates back."},
            {"bool","Boolean."},
            {"entity","An entity handle. `self()` gives the one the current query is on."},
            {"str","A string literal."},
            {"ptr","A raw pointer — the runtime's floor, not for game code."},
            {"void","No value."},
            {0,0}
        };
        for (int i = 0; TY[i].n; i++) if (!strcmp(TY[i].n, name)){
            hover_markdown(&s, name, TY[i].d);
            send_result(id, s.b); free(s.b); return;
        }
    }
    free(s.b);
    send_result(id, "null");
}

/* ---------- references, highlight, rename --------------------------------*/
typedef struct { JSB* s; int first; int mode; const char* newname; LDoc* cur; } OccOut;
enum { OCC_LOCATION, OCC_HIGHLIGHT };

static void occ_emit(void* ctx, LDoc* T, int tok){
    OccOut* o = (OccOut*)ctx;
    if (o->mode == OCC_HIGHLIGHT && T != o->cur) return;
    if (!o->first) jsb_putc(o->s, ',');
    o->first = 0;
    if (o->mode == OCC_HIGHLIGHT){
        jsb_puts(o->s, "{\"range\":");
        put_range(o->s, T, T->lex.v[tok].start, T->lex.v[tok].end);
        jsb_puts(o->s, ",\"kind\":1}");
    } else {
        put_location(o->s, T, T->lex.v[tok].start, T->lex.v[tok].end);
    }
}

static void refs_common(JVal* msg, JVal* id, int mode){
    LDoc* D = doc_of(msg);
    if (!D){ send_result(id, "[]"); return; }
    int off = off_of(msg, D, "params.position");
    LDoc* owner = 0; int sym = -1;
    int tok = resolve_at(D, off, &owner, &sym);
    if (tok < 0 || !owner || sym < 0){ send_result(id, "[]"); return; }
    JSB s = {0}; jsb_putc(&s, '[');
    OccOut o = { &s, 1, mode, 0, D };
    for_each_occurrence(D, owner, sym, occ_emit, &o);
    jsb_putc(&s, ']');
    send_result(id, s.b); free(s.b);
}
static void on_references(JVal* msg, JVal* id){ refs_common(msg, id, OCC_LOCATION); }
static void on_document_highlight(JVal* msg, JVal* id){ refs_common(msg, id, OCC_HIGHLIGHT); }

static void on_prepare_rename(JVal* msg, JVal* id){
    LDoc* D = doc_of(msg);
    if (!D){ send_result(id, "null"); return; }
    int off = off_of(msg, D, "params.position");
    LDoc* owner = 0; int sym = -1;
    int tok = resolve_at(D, off, &owner, &sym);
    /* Refusing beats renaming the wrong thing: if we cannot say what a name
     * refers to, we cannot say which occurrences of it mean the same name. */
    if (tok < 0 || !owner || sym < 0 || D->lex.v[tok].kind != LT_ID){ send_result(id, "null"); return; }
    JSB s = {0};
    jsb_puts(&s, "{\"range\":");
    put_range(&s, D, D->lex.v[tok].start, D->lex.v[tok].end);
    jsb_puts(&s, ",\"placeholder\":");
    { char w[96]; ltok_text(&D->lex, tok, w, sizeof(w)); jsb_str(&s, w); }
    jsb_putc(&s, '}');
    send_result(id, s.b); free(s.b);
}

/* Rename collects per-file edit lists, because the LSP workspace edit is keyed
 * by URI and a symbol can occur in several files of one unit. */
typedef struct { LDoc* doc; JSB edits; int first; } FileEdits;
typedef struct { FileEdits f[64]; int n; const char* newname; } RenameOut;

static void rename_collect(void* ctx, LDoc* T, int tok){
    RenameOut* r = (RenameOut*)ctx;
    FileEdits* fe = 0;
    for (int i = 0; i < r->n; i++) if (r->f[i].doc == T) fe = &r->f[i];
    if (!fe){
        if (r->n >= 64) return;
        fe = &r->f[r->n++];
        memset(fe, 0, sizeof(*fe));
        fe->doc = T; fe->first = 1;
    }
    if (!fe->first) jsb_putc(&fe->edits, ',');
    fe->first = 0;
    jsb_puts(&fe->edits, "{\"range\":");
    put_range(&fe->edits, T, T->lex.v[tok].start, T->lex.v[tok].end);
    jsb_puts(&fe->edits, ",\"newText\":");
    jsb_str(&fe->edits, r->newname);
    jsb_putc(&fe->edits, '}');
}

static void on_rename(JVal* msg, JVal* id){
    LDoc* D = doc_of(msg);
    const char* newname = jstr(jpath(msg, "params.newName"), 0);
    if (!D || !newname || !*newname){ send_result(id, "null"); return; }
    int off = off_of(msg, D, "params.position");
    LDoc* owner = 0; int sym = -1;
    int tok = resolve_at(D, off, &owner, &sym);
    if (tok < 0 || !owner || sym < 0){ send_result(id, "null"); return; }

    RenameOut r; memset(&r, 0, sizeof(r)); r.newname = newname;
    for_each_occurrence(D, owner, sym, rename_collect, &r);

    JSB s = {0};
    jsb_puts(&s, "{\"changes\":{");
    for (int i = 0; i < r.n; i++){
        if (i) jsb_putc(&s, ',');
        jsb_str(&s, r.f[i].doc->uri);
        jsb_putc(&s, ':');
        jsb_putc(&s, '[');
        jsb_puts(&s, r.f[i].edits.b ? r.f[i].edits.b : "");
        jsb_putc(&s, ']');
        free(r.f[i].edits.b);
    }
    jsb_puts(&s, "}}");
    send_result(id, s.b); free(s.b);
}

static void on_formatting(JVal* msg, JVal* id, int ranged){
    LDoc* D = doc_of(msg);
    if (!D){ send_result(id, "null"); return; }
    int tab = jint(jpath(msg, "params.options.tabSize"), g_indent);
    if (tab < 1 || tab > 8) tab = g_indent;
    char* out = D->is_markdown ? ludic_format_markdown(D->raw, tab) : ludic_format(D->raw, tab);
    /* A whole-document replacement is the honest edit: the formatter's unit of
     * work is the file, and a partial rewrite could not fix indentation that
     * depends on lines outside the range. Range formatting therefore formats
     * the document too — every editor accepts that, and it never surprises. */
    (void)ranged;
    int nline = D->lex.nline;
    int endline = nline > 0 ? nline - 1 : 0;
    int endchar = 0;
    {
        int s0 = nline ? D->lex.linestart[endline] : 0;
        int e0 = (int)strlen(D->text);
        endchar = g_utf8_positions ? e0 - s0 : lutf16_len(D->text + s0, e0 - s0);
    }
    JSB s = {0};
    jsb_putf(&s, "[{\"range\":{\"start\":{\"line\":0,\"character\":0},\"end\":{\"line\":%d,\"character\":%d}},\"newText\":", endline, endchar);
    jsb_str(&s, out);
    jsb_puts(&s, "}]");
    send_result(id, s.b);
    free(s.b); free(out);
}

static void on_folding(JVal* msg, JVal* id){
    LDoc* D = doc_of(msg);
    if (!D){ send_result(id, "[]"); return; }
    JSB s = {0}; jsb_putc(&s, '['); int first = 1;
    for (int i = 0; i < D->lex.n; i++){
        const LTok* t = &D->lex.v[i];
        if (t->kind != LT_OP || ltok_len(t) != 1 || D->text[t->start] != '{') continue;
        int m = D->match[i];
        if (m < 0) continue;
        int a = t->line, b = D->lex.v[m].line;
        if (b <= a) continue;
        if (!first) jsb_putc(&s, ',');
        first = 0;
        jsb_putf(&s, "{\"startLine\":%d,\"endLine\":%d,\"kind\":\"region\"}", a, b - 1);
    }
    /* runs of comment lines fold as one block */
    for (int i = 0; i < D->lex.n; ){
        if (D->lex.v[i].kind != LT_COMMENT || !lw_first_on_line(D, i)){ i++; continue; }
        int a = D->lex.v[i].line, last = a, j = i;
        while (j < D->lex.n){
            if (D->lex.v[j].kind == LT_NL){ j++; continue; }
            if (D->lex.v[j].kind == LT_COMMENT && lw_first_on_line(D, j) && D->lex.v[j].line <= last + 1){ last = D->lex.v[j].line; j++; continue; }
            break;
        }
        if (last > a){
            if (!first) jsb_putc(&s, ',');
            first = 0;
            jsb_putf(&s, "{\"startLine\":%d,\"endLine\":%d,\"kind\":\"comment\"}", a, last);
        }
        i = j;
    }
    jsb_putc(&s, ']');
    send_result(id, s.b); free(s.b);
}

static void on_document_link(JVal* msg, JVal* id){
    LDoc* D = doc_of(msg);
    if (!D){ send_result(id, "[]"); return; }
    JSB s = {0}; jsb_putc(&s, '['); int first = 1;
    for (int i = 0; i < D->lex.n; i++){
        if (D->lex.v[i].kind != LT_STR) continue;
        int p = ltok_prev_sig(&D->lex, i);
        if (p < 0 || !ltok_is(&D->lex, p, "import")) continue;
        char rel[512]; ltok_text(&D->lex, i, rel, sizeof(rel));
        int n = (int)strlen(rel); if (n >= 2){ memmove(rel, rel + 1, n - 2); rel[n-2] = 0; }
        char* dir = lw_dirname(D->path);
        char* full = lw_join(dir, rel); free(dir);
        char* uri = lw_path_to_uri(full);
        if (!first) jsb_putc(&s, ',');
        first = 0;
        jsb_puts(&s, "{\"range\":");
        put_range(&s, D, D->lex.v[i].start + 1, D->lex.v[i].end - 1);
        jsb_puts(&s, ",\"target\":"); jsb_str(&s, uri); jsb_putc(&s, '}');
        free(uri); free(full);
    }
    jsb_putc(&s, ']');
    send_result(id, s.b); free(s.b);
}

/* Query bindings read `for (p, v) in query [Pos, Vel]` — the types are one
 * lookup away but invisible at the use site, so show them inline. */
static void on_inlay_hint(JVal* msg, JVal* id){
    LDoc* D = doc_of(msg);
    if (!D){ send_result(id, "[]"); return; }
    JSB s = {0}; jsb_putc(&s, '['); int first = 1;
    for (int i = 0; i < D->nsym; i++){
        LSym* y = &D->sym[i];
        if (y->kind != LS_QUERYVAR || !y->type[0]) continue;
        if (!first) jsb_putc(&s, ',');
        first = 0;
        char label[128]; snprintf(label, sizeof(label), ": %s", y->type);
        jsb_puts(&s, "{\"position\":"); put_pos(&s, D, y->end);
        jsb_puts(&s, ",\"label\":"); jsb_str(&s, label);
        jsb_puts(&s, ",\"kind\":1,\"paddingLeft\":false}");
    }
    jsb_putc(&s, ']');
    send_result(id, s.b); free(s.b);
}

static void on_signature_help(JVal* msg, JVal* id){
    LDoc* D = doc_of(msg);
    if (!D){ send_result(id, "null"); return; }
    int off = off_of(msg, D, "params.position");
    /* walk out to the call we are inside */
    int depth = 0, callee = -1, arg = 0;
    for (int i = D->lex.n - 1; i >= 0; i--){
        const LTok* t = &D->lex.v[i];
        if (t->start >= off) continue;
        if (t->kind != LT_OP || ltok_len(t) != 1) continue;
        char c = D->text[t->start];
        if (c == ')') depth++;
        else if (c == '('){
            if (depth == 0){ callee = ltok_prev_sig(&D->lex, i);
                for (int k = i + 1; k < D->lex.n && D->lex.v[k].start < off; k++)
                    if (ltok_is(&D->lex, k, ",")) arg++;
                break; }
            depth--;
        }
    }
    if (callee < 0 || D->lex.v[callee].kind != LT_ID){ send_result(id, "null"); return; }
    char name[128]; ltok_text(&D->lex, callee, name, sizeof(name));
    const char* sig = 0; const char* doc = "";
    const LBuiltin* bi = lud_lookup(LUDIC_BUILTINS, name);
    if (!bi) bi = lud_lookup(LUDIC_INTRINSICS, name);
    if (bi){ sig = bi->sig; doc = bi->doc; }
    else {
        LDoc* o = 0; int t = lw_find_top(&X, D, name, &o);
        if (t >= 0 && (o->sym[t].kind == LS_FN || o->sym[t].kind == LS_EXTERN)){ sig = o->sym[t].detail; doc = o->sym[t].doc; }
    }
    if (!sig){ send_result(id, "null"); return; }
    JSB s = {0};
    jsb_puts(&s, "{\"signatures\":[{\"label\":"); jsb_str(&s, sig);
    if (doc && *doc){ jsb_puts(&s, ",\"documentation\":"); jsb_str(&s, doc); }
    jsb_putf(&s, "}],\"activeSignature\":0,\"activeParameter\":%d}", arg);
    send_result(id, s.b); free(s.b);
}

static void on_completion(JVal* msg, JVal* id){
    LDoc* D = doc_of(msg);
    if (!D){ send_result(id, "[]"); return; }
    int off = off_of(msg, D, "params.position");
    JSB s = {0};
    jsb_puts(&s, "{\"isIncomplete\":false,\"items\":[");
    CompOut c = { &s, 1 };

    /* what comes immediately before the cursor decides everything */
    int tok = -1;
    for (int i = D->lex.n - 1; i >= 0; i--){
        int k = D->lex.v[i].kind;
        if (k == LT_NL || k == LT_EOF || k == LT_COMMENT) continue;
        if (D->lex.v[i].end <= off){ tok = i; break; }
    }
    /* skip the partial word being typed */
    int anchor = tok;
    if (anchor >= 0 && D->lex.v[anchor].kind == LT_ID && D->lex.v[anchor].end >= off) anchor = ltok_prev_sig(&D->lex, anchor);

    /* Inside an unclosed `[` we are listing query terms, where the only things
     * that can appear are components and archetypes — including after a comma,
     * which is why this is a scan rather than a look at the previous token. */
    int in_query_terms = 0;
    {
        int depth = 0;
        for (int i = anchor; i >= 0; i--){
            const LTok* t = &D->lex.v[i];
            if (t->kind != LT_OP || ltok_len(t) != 1) continue;
            char ch = D->text[t->start];
            if (ch == ']') depth++;
            else if (ch == '['){ if (!depth){ in_query_terms = 1; break; } depth--; }
            else if (ch == '{' || ch == '}') break;   /* left the clause */
        }
    }

    int done = 0;
    if (in_query_terms){ comp_scope(&c, D, off, 1); done = 1; }
    else if (anchor >= 0){
        /* member access: only that component's fields */
        if (ltok_is(&D->lex, anchor, ".")){
            LDoc* co = 0;
            int comp = lw_receiver_component(&X, D, anchor, &co);
            if (comp >= 0 && co){
                for (int i = 0; i < co->nsym; i++)
                    if (co->sym[i].kind == LS_FIELD && co->sym[i].parent == comp)
                        comp_item(&c, co->sym[i].name, CI_FIELD, co->sym[i].detail, co->sym[i].doc, 0);
            }
            done = 1;
        }
        else if (ltok_is(&D->lex, anchor, "phase")){ comp_words(&c, LUDIC_PHASES, CI_ENUM, "system phase"); done = 1; }
        else if (ltok_is(&D->lex, anchor, ":") || ltok_is(&D->lex, anchor, "->")){
            comp_words(&c, LUDIC_TYPES, CI_KEYWORD, "built-in type");
            comp_scope(&c, D, off, 1);
            done = 1;
        }
        else if (ltok_is(&D->lex, anchor, "spawn")){ comp_scope(&c, D, off, 1); done = 1; }
        else if (ltok_is(&D->lex, anchor, "enter")){
            LDoc* rel[128]; int n = lw_related(&X, D, rel, 128);
            for (int i = 0; i < n; i++)
                for (int k = 0; k < rel[i]->nsym; k++)
                    if (rel[i]->sym[k].kind == LS_SCENE)
                        comp_item(&c, rel[i]->sym[k].name, CI_UNIT, rel[i]->sym[k].detail, rel[i]->sym[k].doc, 0);
            done = 1;
        }
        else if (D->lex.v[anchor].kind == LT_OP && ltok_len(&D->lex.v[anchor]) == 1 && D->text[D->lex.v[anchor].start] == '@'){
            comp_item(&c, "deterministic", CI_KEYWORD, "@deterministic", "Marks a system as reproducible given the same inputs.", 0);
            done = 1;
        }
    }
    if (!done && lw_in_ui_body(D, off)){
        comp_words(&c, LUDIC_WIDGETS, CI_CLASS, "widget");
        comp_words(&c, LUDIC_WIDGET_PROPS, CI_PROPERTY, "widget property");
    }
    if (!done){
        comp_words(&c, LUDIC_KW_DECL, CI_KEYWORD, "declaration");
        comp_words(&c, LUDIC_KW_STMT, CI_KEYWORD, "statement");
        comp_words(&c, LUDIC_KW_CLAUSE, CI_KEYWORD, "clause");
        comp_words(&c, LUDIC_TYPES, CI_KEYWORD, "built-in type");
        comp_builtins(&c);
        comp_scope(&c, D, off, 0);
        /* the shapes people actually type */
        comp_item(&c, "handler", CI_SNIPPET, "handler … phase … { }", "A system with a phase and a body.",
                  "system ${1:Name} phase ${2|Start,Input,FixedUpdate,Update,LateUpdate,Render|} {\n  $0\n}");
        comp_item(&c, "system+query", CI_SNIPPET, "handler … query … { }", "A system that runs once per matching entity.",
                  "system ${1:Name} phase ${2|Update,FixedUpdate,LateUpdate,Render,Input|}\n  query (${3:p}) [${4:Pos}]\n{\n  $0\n}");
        comp_item(&c, "property", CI_SNIPPET, "property … { }", "A component with typed fields.",
                  "component ${1:Name} { ${2:x}: ${3:int} = ${4:0} }");
        comp_item(&c, "model", CI_SNIPPET, "archetype … { }", "An entity kind bundling components.",
                  "archetype ${1:Name} {\n  ${2:Pos}\n}");
        comp_item(&c, "for-query", CI_SNIPPET, "for (…) in query […] { }", "Iterate matching entities.",
                  "for (${1:p}) in query [${2:Pos}] {\n  $0\n}");
        comp_item(&c, "scene", CI_SNIPPET, "scene … { layer … }", "A scene with one layer.",
                  "scene ${1:Name} {\n  on enter { $2 }\n  layer ${3:Main} {\n    $0\n  }\n}");
    }
    jsb_puts(&s, "]}");
    send_result(id, s.b);
    free(s.b);
}

/* ---------- document lifecycle -------------------------------------------*/
static void refresh(LDoc* D){ ldoc_reindex(D); lw_classify(&X, D); }

static void on_did_open(JVal* msg){
    const char* uri = jstr(jpath(msg, "params.textDocument.uri"), 0);
    const char* text = jstr(jpath(msg, "params.textDocument.text"), 0);
    if (!uri) return;
    char* path = lw_uri_to_path(uri);
    LDoc* D = lw_by_path(&X, path);
    if (!D){ D = lw_new_doc(path, strdup(text ? text : "")); lw_add(&X, D); }
    else if (text) ldoc_settext(D, strdup(text));
    free(path);
    D->open = 1;
    D->version = jint(jpath(msg, "params.textDocument.version"), 0);
    refresh(D);
    publish_diagnostics(D);
}
static void on_did_change(JVal* msg){
    LDoc* D = doc_of(msg);
    if (!D) return;
    JVal* changes = jpath(msg, "params.contentChanges");
    JVal* last = jat(changes, changes ? changes->n - 1 : 0);
    const char* text = jstr(jget(last, "text"), 0);
    if (!text) return;
    ldoc_settext(D, strdup(text));
    D->version = jint(jpath(msg, "params.textDocument.version"), D->version + 1);
    refresh(D);
    /* structural feedback only while typing; the compiler waits for a save,
     * because it reads the file from disk and would otherwise report the
     * previous save's errors against the current buffer */
    DiagSet ds = {0};
    if (!D->is_markdown) diag_structural(D, &ds);
    JSB s = {0};
    jsb_puts(&s, "{\"uri\":"); jsb_str(&s, D->uri);
    jsb_puts(&s, ",\"diagnostics\":[");
    D->had_diags = ds.n > 0;
    for (int i = 0; i < ds.n; i++){
        if (i) jsb_putc(&s, ',');
        jsb_putf(&s, "{\"range\":{\"start\":{\"line\":%d,\"character\":%d},\"end\":{\"line\":%d,\"character\":%d}},\"severity\":%d,\"source\":\"ludic\",\"message\":",
                 ds.v[i].line, ds.v[i].col, ds.v[i].endline, ds.v[i].endcol, ds.v[i].severity);
        jsb_str(&s, ds.v[i].msg);
        jsb_putc(&s, '}');
    }
    jsb_puts(&s, "]}");
    send_notify("textDocument/publishDiagnostics", s.b);
    free(s.b); free(ds.v);
}
static void on_did_save(JVal* msg){
    LDoc* D = doc_of(msg);
    if (!D) return;
    const char* text = jstr(jpath(msg, "params.text"), 0);
    if (text) ldoc_settext(D, strdup(text));
    else { char* disk = lw_readfile(D->path, 0); if (disk) ldoc_settext(D, disk); }
    refresh(D);
    publish_diagnostics(D);
}
static void on_did_close(JVal* msg){
    LDoc* D = doc_of(msg);
    if (!D) return;
    D->open = 0;
    char* disk = lw_readfile(D->path, 0);
    if (disk){ ldoc_settext(D, disk); refresh(D); }
}

/* ---------- dispatch ------------------------------------------------------*/
static void handle(JVal* msg){
    const char* method = jstr(jget(msg, "method"), 0);
    JVal* id = jget(msg, "id");
    if (!method) return;
    lg("<- %s", method);

    if (!strcmp(method, "initialize")){ on_initialize(msg, id); return; }
    if (!strcmp(method, "initialized")) return;
    if (!strcmp(method, "shutdown")){ g_shutdown = 1; send_result(id, "null"); return; }
    if (!strcmp(method, "exit")){ exit(g_shutdown ? 0 : 1); }

    if (!strcmp(method, "textDocument/didOpen")){ on_did_open(msg); return; }
    if (!strcmp(method, "textDocument/didChange")){ on_did_change(msg); return; }
    if (!strcmp(method, "textDocument/didSave")){ on_did_save(msg); return; }
    if (!strcmp(method, "textDocument/didClose")){ on_did_close(msg); return; }
    if (!strcmp(method, "workspace/didChangeConfiguration")){
        JVal* cfg = jpath(msg, "params.settings.ludic");
        const char* cc = jstr(jget(cfg, "compilerPath"), 0);
        if (cc && *cc){ free(g_ludicc); g_ludicc = strdup(cc); }
        if (jget(cfg, "indentSize")) g_indent = jint(jget(cfg, "indentSize"), g_indent);
        if (jget(cfg, "compilerDiagnostics")) g_compiler_diags = jbool(jget(cfg, "compilerDiagnostics"), 1);
        return;
    }
    if (!strcmp(method, "workspace/didChangeWatchedFiles")){
        JVal* ch = jpath(msg, "params.changes");
        for (int i = 0; ch && i < ch->n; i++){
            const char* u = jstr(jget(jat(ch, i), "uri"), 0);
            if (!u) continue;
            char* p = lw_uri_to_path(u);
            LDoc* D = lw_by_path(&X, p);
            if (D && !D->open){ char* disk = lw_readfile(p, 0); if (disk){ ldoc_settext(D, disk); refresh(D); } }
            else if (!D) lw_ensure(&X, p);
            free(p);
        }
        return;
    }

    if (!strcmp(method, "textDocument/documentSymbol")){ on_document_symbol(msg, id); return; }
    if (!strcmp(method, "workspace/symbol")){ on_workspace_symbol(msg, id); return; }
    if (!strcmp(method, "textDocument/definition") ||
        !strcmp(method, "textDocument/declaration") ||
        !strcmp(method, "textDocument/typeDefinition")){ on_definition(msg, id); return; }
    if (!strcmp(method, "textDocument/hover")){ on_hover(msg, id); return; }
    if (!strcmp(method, "textDocument/references")){ on_references(msg, id); return; }
    if (!strcmp(method, "textDocument/documentHighlight")){ on_document_highlight(msg, id); return; }
    if (!strcmp(method, "textDocument/prepareRename")){ on_prepare_rename(msg, id); return; }
    if (!strcmp(method, "textDocument/rename")){ on_rename(msg, id); return; }
    if (!strcmp(method, "textDocument/formatting")){ on_formatting(msg, id, 0); return; }
    if (!strcmp(method, "textDocument/rangeFormatting")){ on_formatting(msg, id, 1); return; }
    if (!strcmp(method, "textDocument/foldingRange")){ on_folding(msg, id); return; }
    if (!strcmp(method, "textDocument/documentLink")){ on_document_link(msg, id); return; }
    if (!strcmp(method, "textDocument/inlayHint")){ on_inlay_hint(msg, id); return; }
    if (!strcmp(method, "textDocument/signatureHelp")){ on_signature_help(msg, id); return; }
    if (!strcmp(method, "textDocument/completion")){ on_completion(msg, id); return; }
    if (!strcmp(method, "textDocument/semanticTokens/full") ||
        !strcmp(method, "textDocument/semanticTokens/range")){
        LDoc* D = doc_of(msg);
        if (!D){ send_result(id, "null"); return; }
        int from = 0, to = -1;
        JVal* r = jpath(msg, "params.range");
        if (r){ from = jint(jpath(msg, "params.range.start.line"), 0); to = jint(jpath(msg, "params.range.end.line"), -1); }
        char* out = semantic_tokens(D, from, to);
        send_result(id, out);
        free(out);
        return;
    }

    /* an unknown request still needs an answer, or the client hangs */
    if (id) send_result(id, "null");
}

static const char* USAGE =
"ludic-lsp — the Ludic language server (LSP 3.17 over stdio)\n"
"\n"
"usage: ludic-lsp [--stdio] [--compiler PATH] [--log FILE] [--no-compiler-diagnostics]\n"
"\n"
"Editors normally launch this themselves. --stdio is accepted and ignored;\n"
"stdio is the only transport.\n";

int main(int argc, char** argv){
    signal(SIGPIPE, SIG_IGN);
    for (int i = 1; i < argc; i++){
        if (!strcmp(argv[i], "--compiler") && i + 1 < argc) g_ludicc = strdup(argv[++i]);
        else if (!strcmp(argv[i], "--log") && i + 1 < argc) g_log = fopen(argv[++i], "w");
        else if (!strcmp(argv[i], "--no-compiler-diagnostics")) g_compiler_diags = 0;
        else if (!strcmp(argv[i], "--indent") && i + 1 < argc) g_indent = atoi(argv[++i]);
        else if (!strcmp(argv[i], "--stdio")) ;
        else if (!strcmp(argv[i], "-h") || !strcmp(argv[i], "--help")){ fputs(USAGE, stdout); return 0; }
        else if (!strcmp(argv[i], "--version")){ puts("ludic-lsp 1.0.0"); return 0; }
    }
    for (;;){
        char* raw = read_message();
        if (!raw) break;
        JVal* msg = jparse(raw);
        handle(msg);
        jfree(msg);
        free(raw);
    }
    return 0;
}
