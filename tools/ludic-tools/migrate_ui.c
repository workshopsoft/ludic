/* migrate_ui.c — one-time migration for Rule A in `ui` blocks: widget props go
 * from `key=value` to `key: value`. Every '=' inside a `ui` block is a prop
 * separator (values are expressions, never contain a top-level '='), so we track
 * ui context (armed by the `ui` keyword's root brace) and rewrite each '=' to a
 * ':' with canonical spacing (`id: Root`). The driver's IR-identity check proves
 * it is a pure re-spelling (the parser builds the same E_FINIT nodes).
 * usage: migrate_ui <file>  -> migrated source to stdout
 */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "ludic_syntax.h"

int main(int argc, char** argv){
    if (argc < 2){ fprintf(stderr, "usage: migrate_ui <file>\n"); return 2; }
    FILE* f = fopen(argv[1], "rb");
    if (!f){ fprintf(stderr, "cannot open %s\n", argv[1]); return 2; }
    fseek(f, 0, SEEK_END); long n = ftell(f); fseek(f, 0, SEEK_SET);
    char* src = malloc(n + 1); fread(src, 1, n, f); src[n] = 0; fclose(f);

    LLex L; lud_lex(&L, src);
    char* repb = calloc(n + 1, 1);   /* byte position of a '=' to rewrite as ':' */

    int ui_stack[1024]; int bp = 0; int ui_active = 0; int pendingUi = 0;
    for (int i = 0; i < L.n; i++){
        int k = L.v[i].kind; if (k == LT_EOF) break;
        if (k == LT_NL || k == LT_COMMENT) continue;
        if (k == LT_KW && ltok_is(&L, i, "ui")) pendingUi = 1;
        int op1 = (k == LT_OP && ltok_len(&L.v[i]) == 1);
        char c0 = L.src[L.v[i].start];
        if (op1 && c0 == '{'){
            if (bp < 1024){ ui_stack[bp] = (pendingUi || ui_active > 0) ? 1 : 0; if (ui_stack[bp]) ui_active++; bp++; }
            pendingUi = 0;
        } else if (op1 && c0 == '}'){
            if (bp > 0){ bp--; if (ui_stack[bp] && ui_active > 0) ui_active--; }
        } else if (op1 && c0 == '=' && ui_active > 0){
            repb[L.v[i].start] = 1;
        }
    }

    for (int b = 0; b < n; ){
        if (repb[b]){                                   /* '=' -> ': ' with a single trailing space */
            putchar(':'); b++;
            if (b < n && src[b] != ' ' && src[b] != '\n') putchar(' ');
            continue;
        }
        if (src[b] == ' ' && b + 1 < n && repb[b + 1]){ b++; continue; }  /* drop the space before ':' */
        putchar(src[b]); b++;
    }
    lud_lex_free(&L); free(repb); free(src);
    return 0;
}
