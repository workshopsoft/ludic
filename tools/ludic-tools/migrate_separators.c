/* sepfix.c — one-time migration for Rule B: insert `;` at statement boundaries
 * that are currently spelled with only whitespace. Reuses the toolchain lexer.
 *
 * A boundary is inserted between two significant, same-line tokens prev,cur when
 *   - we are at paren/bracket depth 0 (not inside a call's args or an index), AND
 *   - we are NOT inside a `ui` block (widget props are `k=v`, space-separated,
 *     and the parser does not skip newlines between them), AND
 *   - prev can END an operand/statement, AND cur can START a statement.
 * Inserting `;` (which the lexer maps to a newline token) at a REAL boundary is
 * a semantic no-op under today's permissive parser — the IR-identity check in
 * the driver is the proof. Wrong insertions change the IR and are rejected.
 *
 * usage: sepfix <in.ludic>   -> writes migrated source to stdout
 */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "ludic_syntax.h"

static const char* STMT_START[] = {
    "let","return","if","when","while","for","spawn","despawn",
    "match","machine","become","enter","break","continue", 0
};

static int ender(const LLex* L, int i){
    const LTok* t = &L->v[i];
    switch (t->kind){
        case LT_ID: case LT_INT: case LT_FLOAT: case LT_STR: case LT_CHAR:
        case LT_BOOL: case LT_TYPE: case LT_PHASE: return 1;
        case LT_OP: {
            if (ltok_len(t) != 1) return 0;
            char c = L->src[t->start];
            if (c == ']'){
                /* `]` closing an empty `[]` is a slice-TYPE marker (`[]Node`),
                 * not an operand end — the type name that follows continues it. */
                int p = ltok_prev_sig(L, i);
                if (p >= 0 && L->v[p].kind == LT_OP && ltok_len(&L->v[p]) == 1 && L->src[L->v[p].start] == '[') return 0;
                return 1;
            }
            return (c == ')' || c == '}'); }
        case LT_KW: { char b[32]; ltok_text(L, i, b, sizeof b);
            return !strcmp(b, "break") || !strcmp(b, "continue"); }
        default: return 0;
    }
}
static int starter(const LLex* L, int i){
    const LTok* t = &L->v[i];
    if (t->kind == LT_ID || t->kind == LT_INT || t->kind == LT_FLOAT ||
        t->kind == LT_STR || t->kind == LT_CHAR || t->kind == LT_BOOL) return 1;
    if (t->kind == LT_KW){ char b[32]; ltok_text(L, i, b, sizeof b); return lud_in(STMT_START, b); }
    return 0;   /* an operator never starts a statement here */
}

int main(int argc, char** argv){
    if (argc < 2){ fprintf(stderr, "usage: sepfix <file>\n"); return 2; }
    FILE* f = fopen(argv[1], "rb");
    if (!f){ fprintf(stderr, "sepfix: cannot open %s\n", argv[1]); return 2; }
    fseek(f, 0, SEEK_END); long n = ftell(f); fseek(f, 0, SEEK_SET);
    char* src = malloc(n + 1); fread(src, 1, n, f); src[n] = 0; fclose(f);

    LLex L; lud_lex(&L, src);

    /* insert[k] = 1 means: emit a ';' immediately after token k's bytes */
    char* insert = calloc(L.n, 1);

    int paren = 0;              /* unclosed ( or [ */
    /* ui suppression: brace depth stack, marking which open braces are ui/widget */
    int ui_stack[512]; int bp = 0; int ui_active = 0;
    int pendingUiOpen = 0;     /* saw `ui` or a widget word; the next { is a ui brace */

    int prev = -1;             /* previous significant token index */
    for (int i = 0; i < L.n; i++){
        int k = L.v[i].kind;
        if (k == LT_EOF) break;
        if (k == LT_NL || k == LT_COMMENT) continue;

        char c0 = L.src[L.v[i].start];
        int op1 = (k == LT_OP && ltok_len(&L.v[i]) == 1);

        /* track ui context by the `ui` KEYWORD only — it brackets the whole
         * widget tree via its root brace, so every nested widget brace is
         * already inside ui_active. (Do NOT key off widget words like col/row/
         * image/label: those are also ordinary variable names, and matching them
         * would wrongly suppress real statement boundaries.) */
        if (k == LT_KW && ltok_is(&L, i, "ui")) pendingUiOpen = 1;

        if (op1 && c0 == '{'){
            if (bp < 512){ ui_stack[bp] = pendingUiOpen; bp++; if (pendingUiOpen) ui_active++; }
            pendingUiOpen = 0;
        } else if (op1 && c0 == '}'){
            if (bp > 0){ bp--; if (ui_stack[bp]) { if (ui_active) ui_active--; } }
        } else if (op1 && (c0 == '(' || c0 == '[')){ paren++; if (getenv("SEPFIX_TRACE")) fprintf(stderr, "  L%d '%c' -> paren=%d\n", L.v[i].line + 1, c0, paren); }
        else if (op1 && (c0 == ')' || c0 == ']')){ if (paren > 0) paren--; if (getenv("SEPFIX_TRACE")) fprintf(stderr, "  L%d '%c' -> paren=%d\n", L.v[i].line + 1, c0, paren); }

        /* candidate boundary between prev and this token */
        if (prev >= 0 && paren == 0 && !ui_active &&
            L.v[prev].line == L.v[i].line &&
            ender(&L, prev) && starter(&L, i)){
            insert[prev] = 1;
        }
        prev = i;
    }

    if (getenv("SEPFIX_DEBUG")) fprintf(stderr, "END STATE %s: paren=%d ui_active=%d bp=%d\n", argv[1], paren, ui_active, bp);

    /* rebuild: copy bytes, dropping in ';' right after any token flagged */
    for (int i = 0, t = 0; i < n; ){
        /* find if a token ends exactly at i and is flagged */
        putchar(src[i]);
        i++;
        /* emit ';' after the last byte of a flagged token */
        for (; t < L.n; t++){
            if (L.v[t].end == i && insert[t]){ putchar(';'); break; }
            if (L.v[t].end > i) break;
        }
    }
    lud_lex_free(&L); free(insert); free(src);
    return 0;
}
