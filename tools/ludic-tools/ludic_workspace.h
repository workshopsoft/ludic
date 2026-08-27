/* ============================================================================
 * ludic_workspace.h — many documents, one project.
 *
 * Ludic programs are multi-file: `import "rules.ludic"` splices a fragment into
 * whichever `game`/`module` file pulled it in. An imported fragment is NOT a
 * standalone program — it has no `game` block — so running the compiler on it
 * directly is meaningless. This layer keeps that straight: it knows which files
 * form a compilation unit, which file is its root, and it resolves a name
 * against the whole unit rather than one buffer.
 * ==========================================================================*/
#ifndef LUDIC_WORKSPACE_H
#define LUDIC_WORKSPACE_H

#include "ludic_index.h"
#include <dirent.h>
#include <limits.h>
#include <sys/stat.h>
#include <unistd.h>

/* ---------- paths & URIs --------------------------------------------------*/
static char* lw_readfile(const char* path, long* out_n){
    FILE* f = fopen(path, "rb"); if (!f) return 0;
    fseek(f, 0, SEEK_END); long n = ftell(f); fseek(f, 0, SEEK_SET);
    char* b = malloc(n + 1);
    if (fread(b, 1, n, f) != (size_t)n){ fclose(f); free(b); return 0; }
    b[n] = 0; fclose(f);
    if (out_n) *out_n = n;
    return b;
}
static int lw_hex(int c){ return c >= '0' && c <= '9' ? c - '0' : (c | 32) >= 'a' && (c | 32) <= 'f' ? (c | 32) - 'a' + 10 : -1; }
static char* lw_uri_to_path(const char* uri){
    if (strncmp(uri, "file://", 7)) return strdup(uri);
    const char* s = uri + 7;
    /* file://host/path is not something an editor sends for local files */
    char* out = malloc(strlen(s) + 1); int j = 0;
    for (int i = 0; s[i]; ){
        if (s[i] == '%' && lw_hex(s[i+1]) >= 0 && lw_hex(s[i+2]) >= 0){
            out[j++] = (char)(lw_hex(s[i+1]) * 16 + lw_hex(s[i+2])); i += 3;
        } else out[j++] = s[i++];
    }
    out[j] = 0;
    return out;
}
static char* lw_path_to_uri(const char* path){
    static const char* safe = "-_.~/abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    size_t cap = strlen(path) * 3 + 16;
    char* out = malloc(cap);
    strcpy(out, "file://");
    int j = 7;
    for (int i = 0; path[i]; i++){
        unsigned char c = (unsigned char)path[i];
        if (strchr(safe, c)) out[j++] = c;
        else j += sprintf(out + j, "%%%02X", c);
    }
    out[j] = 0;
    return out;
}
static char* lw_dirname(const char* p){
    char* d = strdup(p); char* s = strrchr(d, '/');
    if (s) *s = 0; else { free(d); d = strdup("."); }
    return d;
}
static char* lw_join(const char* dir, const char* rel){
    if (rel[0] == '/') return strdup(rel);
    size_t n = strlen(dir) + strlen(rel) + 2;
    char* p = malloc(n); snprintf(p, n, "%s/%s", dir, rel);
    char real[PATH_MAX];
    if (realpath(p, real)){ free(p); return strdup(real); }
    return p;
}
static int lw_ends(const char* s, const char* suf){
    size_t a = strlen(s), b = strlen(suf);
    return a >= b && !strcmp(s + a - b, suf);
}

/* ---------- Markdown ------------------------------------------------------
 * Fenced Ludic inside prose is real Ludic and deserves the same treatment. The
 * trick that makes it free: copy the document and blank out every byte that is
 * not inside a ```ludic fence. Offsets, lines and columns still match the file
 * on disk exactly, so every feature built on top — highlighting, hover,
 * go-to-definition, diagnostics — works on a .md without knowing about it. */
static char* lw_scrub_markdown(const char* src){
    char* out = strdup(src);
    int i = 0, n = (int)strlen(src);
    while (i < n){
        int ls = i, le = i;
        while (le < n && src[le] != '\n') le++;
        int ind = 0; while (ls + ind < le && src[ls + ind] == ' ') ind++;
        int j = ls + ind; char m = j < le ? src[j] : 0;
        int run = 0; while (j + run < le && src[j + run] == m) run++;
        int fenced = (m == '`' || m == '~') && run >= 3;
        int info = j + run;
        int is_ludic = 0;
        if (fenced){
            int k = info; while (k < le && (src[k] == ' ' || src[k] == '\t')) k++;
            is_ludic = (le - k >= 5) && !strncasecmp(src + k, "ludic", 5) &&
                       (le - k == 5 || src[k+5] == ' ' || src[k+5] == '\t' || src[k+5] == '\r');
        }
        /* blank the fence line itself either way */
        for (int k = ls; k < le; k++) out[k] = ' ';
        i = le < n ? le + 1 : n;
        if (!fenced) continue;
        /* inside a fence: keep the body only when the info string says ludic */
        while (i < n){
            int bs = i, be = i;
            while (be < n && src[be] != '\n') be++;
            int bi = 0; while (bs + bi < be && src[bs + bi] == ' ') bi++;
            int cj = bs + bi, crun = 0;
            while (cj + crun < be && src[cj + crun] == m) crun++;
            int only = 1;
            for (int k = cj + crun; k < be; k++) if (src[k] != ' ' && src[k] != '\r'){ only = 0; break; }
            if (crun >= run && only){
                for (int k = bs; k < be; k++) out[k] = ' ';
                i = be < n ? be + 1 : n;
                break;
            }
            if (!is_ludic) for (int k = bs; k < be; k++) out[k] = ' ';
            i = be < n ? be + 1 : n;
        }
    }
    return out;
}

/* ---------- documents -----------------------------------------------------*/
static void ldoc_settext(LDoc* D, char* raw){
    if (D->text != D->raw) free(D->text);
    free(D->raw);
    D->raw = raw;
    D->text = D->is_markdown ? lw_scrub_markdown(raw) : raw;
}
static void ldoc_reindex(LDoc* D){
    lud_lex_free(&D->lex);
    lud_lex(&D->lex, D->text);
    ldoc_match_braces(D);
    ldoc_parse(D);
    free(D->cls);
    D->cls = calloc(D->lex.n + 1, 1);
}
static LDoc* lw_new_doc(const char* path, char* text){
    LDoc* D = calloc(1, sizeof(LDoc));
    char real[PATH_MAX];
    D->path = realpath(path, real) ? strdup(real) : strdup(path);
    D->uri = lw_path_to_uri(D->path);
    D->is_markdown = lw_ends(D->path, ".md") || lw_ends(D->path, ".markdown");
    ldoc_settext(D, text);
    ldoc_reindex(D);
    return D;
}
static void lw_add(LIndex* X, LDoc* D){
    if (X->n >= X->cap){ X->cap = X->cap ? X->cap * 2 : 32; X->d = realloc(X->d, X->cap * sizeof(LDoc*)); }
    X->d[X->n++] = D;
}
static LDoc* lw_by_path(LIndex* X, const char* path){
    char real[PATH_MAX];
    const char* p = realpath(path, real) ? real : path;
    for (int i = 0; i < X->n; i++) if (!strcmp(X->d[i]->path, p)) return X->d[i];
    return 0;
}
static LDoc* lw_by_uri(LIndex* X, const char* uri){
    char* p = lw_uri_to_path(uri);
    LDoc* D = lw_by_path(X, p);
    if (!D) for (int i = 0; i < X->n; i++) if (!strcmp(X->d[i]->uri, uri)){ D = X->d[i]; break; }
    free(p);
    return D;
}
/* Load a file into the index if it is not there yet. */
static LDoc* lw_ensure(LIndex* X, const char* path){
    LDoc* D = lw_by_path(X, path);
    if (D) return D;
    char* text = lw_readfile(path, 0);
    if (!text) return 0;
    D = lw_new_doc(path, text);
    lw_add(X, D);
    return D;
}

/* Walk the workspace once at startup so that go-to-definition works across
 * files the editor has never opened. Skips the usual noise directories. */
static void lw_scan(LIndex* X, const char* dir, int depth){
    if (depth > 8) return;
    DIR* d = opendir(dir); if (!d) return;
    struct dirent* e;
    while ((e = readdir(d))){
        if (e->d_name[0] == '.') continue;
        if (!strcmp(e->d_name, "build") || !strcmp(e->d_name, "node_modules") ||
            !strcmp(e->d_name, "target") || !strcmp(e->d_name, "out")) continue;
        char p[PATH_MAX]; snprintf(p, sizeof(p), "%s/%s", dir, e->d_name);
        struct stat st; if (stat(p, &st)) continue;
        if (S_ISDIR(st.st_mode)) lw_scan(X, p, depth + 1);
        else if (lw_ends(e->d_name, ".ludic")) lw_ensure(X, p);
    }
    closedir(d);
}

/* ---------- compilation units --------------------------------------------
 * `related` = every document that shares a compilation unit with D: the unit
 * root that (transitively) imports D, plus everything that root imports. */
static void lw_imports_of(LIndex* X, LDoc* D, LDoc** out, int* n, int max){
    for (int i = 0; i < D->nimport; i++){
        char* dir = lw_dirname(D->path);
        char* full = lw_join(dir, D->imports[i]);
        free(dir);
        LDoc* I = lw_ensure(X, full);
        free(full);
        if (!I) continue;
        int seen = 0; for (int k = 0; k < *n; k++) if (out[k] == I) seen = 1;
        if (seen || *n >= max) continue;
        out[(*n)++] = I;
        lw_imports_of(X, I, out, n, max);
    }
}
static int lw_related(LIndex* X, LDoc* D, LDoc** out, int max){
    int n = 0;
    if (!D) return 0;
    out[n++] = D;
    lw_imports_of(X, D, out, &n, max);
    /* pull in any unit root that reaches D, and that root's other imports */
    for (int i = 0; i < X->n && n < max; i++){
        LDoc* R = X->d[i];
        if (!R->is_unit || R == D) continue;
        LDoc* reach[128]; int rn = 0;
        lw_imports_of(X, R, reach, &rn, 128);
        int hits = 0; for (int k = 0; k < rn; k++) if (reach[k] == D) hits = 1;
        if (!hits) continue;
        int seen = 0; for (int k = 0; k < n; k++) if (out[k] == R) seen = 1;
        if (!seen && n < max) out[n++] = R;
        for (int k = 0; k < rn && n < max; k++){
            int s2 = 0; for (int q = 0; q < n; q++) if (out[q] == reach[k]) s2 = 1;
            if (!s2) out[n++] = reach[k];
        }
    }
    return n;
}
/* The file `ludicc` should actually be pointed at when checking D. */
static LDoc* lw_unit_root(LIndex* X, LDoc* D){
    if (!D || D->is_markdown) return 0;
    if (D->is_unit) return D;
    LDoc* rel[128]; int n = lw_related(X, D, rel, 128);
    /* a `game` beats a `module`: it is the one that actually compiles */
    for (int i = 0; i < n; i++) if (rel[i]->is_unit && !rel[i]->is_module && !rel[i]->is_markdown) return rel[i];
    for (int i = 0; i < n; i++) if (rel[i]->is_unit && !rel[i]->is_markdown) return rel[i];
    return 0;
}

/* ---------- name resolution ----------------------------------------------*/
static int lsym_is_toplevel(int kind){
    switch (kind){
        case LS_COMPONENT: case LS_ARCHETYPE: case LS_CONST: case LS_VAR:
        case LS_FN: case LS_EXTERN: case LS_SYSTEM: case LS_UI: case LS_WIDGET:
        case LS_SCENE: case LS_LAYER: case LS_UNIT:
            return 1;
        default: return 0;
    }
}
static int lsym_is_local(int kind){
    return kind == LS_LOCAL || kind == LS_PARAM || kind == LS_QUERYVAR || kind == LS_STATE;
}
/* The innermost local binding of `name` visible at byte offset `off`. */
static int lw_find_local(LDoc* D, const char* name, int off){
    int best = -1;
    for (int i = 0; i < D->nsym; i++){
        LSym* s = &D->sym[i];
        if (!lsym_is_local(s->kind) || strcmp(s->name, name)) continue;
        if (off < s->body_start || off > s->body_end) continue;
        if (best < 0 || s->body_start >= D->sym[best].body_start) best = i;
    }
    return best;
}
static int lw_find_top(LIndex* X, LDoc* D, const char* name, LDoc** owner){
    LDoc* rel[128]; int n = lw_related(X, D, rel, 128);
    for (int i = 0; i < n; i++)
        for (int k = 0; k < rel[i]->nsym; k++)
            if (lsym_is_toplevel(rel[i]->sym[k].kind) && !strcmp(rel[i]->sym[k].name, name)){
                *owner = rel[i]; return k;
            }
    /* fall back to the whole workspace — better a cross-unit jump than none */
    for (int i = 0; i < X->n; i++)
        for (int k = 0; k < X->d[i]->nsym; k++)
            if (lsym_is_toplevel(X->d[i]->sym[k].kind) && !strcmp(X->d[i]->sym[k].name, name)){
                *owner = X->d[i]; return k;
            }
    return -1;
}
/* The component a dotted receiver has, e.g. `p` in `p.x` when p came from a
 * query binding or a typed parameter. Returns the component symbol or -1. */
static int lw_receiver_component(LIndex* X, LDoc* D, int dot_tok, LDoc** owner){
    int recv = ltok_prev_sig(&D->lex, dot_tok);
    if (recv < 0 || D->lex.v[recv].kind != LT_ID) return -1;
    char name[96]; ltok_text(&D->lex, recv, name, sizeof(name));
    int l = lw_find_local(D, name, D->lex.v[recv].start);
    const char* ty = 0;
    if (l >= 0) ty = D->sym[l].type;
    else {
        LDoc* o; int t = lw_find_top(X, D, name, &o);
        if (t >= 0) ty = o->sym[t].type;
    }
    if (!ty || !ty[0]) return -1;
    return lw_find_top(X, D, ty, owner);
}

/* ---------- semantic classification --------------------------------------*/
static int lw_first_on_line(LDoc* D, int tok){
    int p = ltok_prev_sig(&D->lex, tok);
    return p < 0 || D->lex.v[p].line != D->lex.v[tok].line;
}
static int lw_in_ui_body(LDoc* D, int off){
    for (int i = 0; i < D->nsym; i++)
        if (D->sym[i].kind == LS_UI && off > D->sym[i].body_start && off < D->sym[i].body_end) return 1;
    return 0;
}
static void lw_classify(LIndex* X, LDoc* D){
    if (!D->cls) D->cls = calloc(D->lex.n + 1, 1);
    for (int i = 0; i < D->lex.n; i++){
        const LTok* t = &D->lex.v[i];
        int c = SC_NONE;
        switch (t->kind){
            case LT_COMMENT: c = SC_COMMENT; break;
            case LT_STR: case LT_CHAR: c = SC_STRING; break;
            case LT_INT: case LT_FLOAT: c = SC_NUMBER; break;
            case LT_BOOL: case LT_KW: c = SC_KEYWORD; break;
            case LT_TYPE: c = SC_TYPE; break;
            case LT_PHASE: c = SC_PHASE; break;
            case LT_ANNO: c = SC_ANNOTATION; break;
            case LT_OP: c = SC_OPERATOR; break;
            case LT_ID: c = SC_UNKNOWN; break;
            default: c = SC_NONE; break;
        }
        if (t->kind != LT_ID){ D->cls[i] = (unsigned char)c; continue; }

        char name[96]; ltok_text(&D->lex, i, name, sizeof(name));

        /* 1. the token IS a declaration's name */
        int decl = -1;
        for (int s = 0; s < D->nsym; s++) if (D->sym[s].tok == i){ decl = s; break; }
        if (decl >= 0){
            switch (D->sym[decl].kind){
                case LS_COMPONENT: c = SC_COMPONENT; break;
                case LS_ARCHETYPE: c = SC_ARCHETYPE; break;
                case LS_FIELD:     c = SC_FIELD; break;
                case LS_CONST:     c = SC_CONST; break;
                case LS_VAR:       c = SC_MODVAR; break;
                case LS_FN: case LS_EXTERN: c = SC_FUNCTION; break;
                case LS_SYSTEM:    c = SC_SYSTEM; break;
                case LS_UI:        c = SC_UI; break;
                case LS_WIDGET:    c = SC_CONST; break;   /* UI_Foo is a handle */
                case LS_SCENE:     c = SC_SCENE; break;
                case LS_LAYER:     c = SC_LAYER; break;
                case LS_PARAM:     c = SC_PARAM; break;
                case LS_QUERYVAR: case LS_LOCAL: case LS_STATE: c = SC_VARIABLE; break;
                case LS_UNIT:      c = SC_UI; break;
                default: c = SC_UNKNOWN;
            }
            D->cls[i] = (unsigned char)c; continue;
        }

        /* 2. member access: `p.x` */
        int prev = ltok_prev_sig(&D->lex, i);
        if (prev >= 0 && ltok_is(&D->lex, prev, ".")){ D->cls[i] = SC_FIELD; continue; }

        int next = ltok_next_sig(&D->lex, i);
        int followed_by_eq = next >= 0 && ltok_is(&D->lex, next, "=");

        /* 3. inside a `ui` block a bare word is a widget type and `k=` a prop —
         *    and those names (text, image, size) collide with builtins, so this
         *    has to be decided before the builtin table is consulted. */
        if (lw_in_ui_body(D, t->start)){
            if (followed_by_eq){ D->cls[i] = SC_PROP; continue; }
            if (lw_first_on_line(D, i) || (prev >= 0 && (ltok_is(&D->lex, prev, "{") || ltok_is(&D->lex, prev, "}")))){
                D->cls[i] = lud_in(LUDIC_WIDGETS, name) ? SC_WIDGET : SC_UI; continue;
            }
        }

        /* 4. a local binding in scope */
        int l = lw_find_local(D, name, t->start);
        if (l >= 0){ D->cls[i] = D->sym[l].kind == LS_PARAM ? SC_PARAM : SC_VARIABLE; continue; }

        /* 5. a declaration somewhere in the compilation unit */
        LDoc* owner = 0; int top = lw_find_top(X, D, name, &owner);
        if (top >= 0){
            switch (owner->sym[top].kind){
                case LS_COMPONENT: c = SC_COMPONENT; break;
                case LS_ARCHETYPE: c = SC_ARCHETYPE; break;
                case LS_CONST:     c = SC_CONST; break;
                case LS_VAR:       c = SC_MODVAR; break;
                case LS_FN: case LS_EXTERN: c = SC_FUNCTION; break;
                case LS_SYSTEM:    c = SC_SYSTEM; break;
                case LS_UI:        c = SC_UI; break;
                case LS_WIDGET:    c = SC_CONST; break;
                case LS_SCENE:     c = SC_SCENE; break;
                case LS_LAYER:     c = SC_LAYER; break;
                default: c = SC_UNKNOWN;
            }
            D->cls[i] = (unsigned char)c; continue;
        }

        /* 6. the runtime surface */
        if (lud_lookup(LUDIC_BUILTINS, name) || lud_lookup(LUDIC_INTRINSICS, name)){ D->cls[i] = SC_BUILTIN; continue; }

        /* 7. a record field initialiser: `Pos = { x = 10 }` */
        if (followed_by_eq){ D->cls[i] = SC_FIELD; continue; }

        D->cls[i] = SC_UNKNOWN;
    }
}
#endif /* LUDIC_WORKSPACE_H */
