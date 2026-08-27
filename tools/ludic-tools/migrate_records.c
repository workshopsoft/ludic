/* migrate_records.c — one-time migration for Rule A (named fields use ':').
 * Records appear ONLY inside `spawn` blocks, so we track spawn context and, for
 * every single '=' inside one:
 *   - '=' followed by '{'  is a component init `Comp = { … }`  -> delete it (`Comp { … }`)
 *   - otherwise            is a field binding `field = value`  -> rewrite to ':'
 * A '=' at a real boundary is a pure re-spelling; the driver's IR-identity check
 * (migrated program compiles to the same IR) is the proof.
 * usage: migrate_records <file>  -> migrated source to stdout
 */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "ludic_syntax.h"

int main(int argc, char** argv){
    if (argc < 2){ fprintf(stderr, "usage: migrate_records <file>\n"); return 2; }
    FILE* f = fopen(argv[1], "rb");
    if (!f){ fprintf(stderr, "cannot open %s\n", argv[1]); return 2; }
    fseek(f, 0, SEEK_END); long n = ftell(f); fseek(f, 0, SEEK_SET);
    char* src = malloc(n + 1); fread(src, 1, n, f); src[n] = 0; fclose(f);

    LLex L; lud_lex(&L, src);
    char* rep = calloc(L.n, 1);   /* '=' -> ':' */
    char* del = calloc(L.n, 1);   /* drop the '=' (component init) */

    int sp_stack[1024]; int bp = 0; int spawn_active = 0; int pendingSpawn = 0;
    for (int i = 0; i < L.n; i++){
        int k = L.v[i].kind; if (k == LT_EOF) break;
        if (k == LT_NL || k == LT_COMMENT) continue;
        if (k == LT_KW && ltok_is(&L, i, "spawn")) pendingSpawn = 1;
        int op1 = (k == LT_OP && ltok_len(&L.v[i]) == 1);
        char c0 = L.src[L.v[i].start];
        if (op1 && c0 == '{'){
            if (bp < 1024){ sp_stack[bp] = (pendingSpawn || spawn_active > 0) ? 1 : 0; if (sp_stack[bp]) spawn_active++; bp++; }
            pendingSpawn = 0;
        } else if (op1 && c0 == '}'){
            if (bp > 0){ bp--; if (sp_stack[bp] && spawn_active > 0) spawn_active--; }
        } else if (op1 && c0 == '='){
            if (spawn_active > 0){
                int nx = ltok_next_sig(&L, i);
                if (nx >= 0 && L.v[nx].kind == LT_OP && ltok_len(&L.v[nx]) == 1 && L.src[L.v[nx].start] == '{') del[i] = 1;
                else rep[i] = 1;
            }
        }
    }

    /* map flags onto byte positions so the rebuild can peek one char ahead */
    char* repb = calloc(n + 1, 1); char* delb = calloc(n + 1, 1);
    for (int i = 0; i < L.n; i++){ if (rep[i]) repb[L.v[i].start] = 1; if (del[i]) delb[L.v[i].start] = 1; }
    for (int b = 0; b < n; ){
        if (repb[b]){ putchar(':'); b++; continue; }              /* '=' -> ':' */
        if (delb[b]){ b++; if (b < n && src[b] == ' ') b++; continue; }  /* drop '=' and one space */
        if (src[b] == ' ' && b + 1 < n && repb[b + 1]){ b++; continue; } /* drop the space before ':' -> `field: v` */
        putchar(src[b]); b++;
    }
    free(repb); free(delb);
    lud_lex_free(&L); free(rep); free(del); free(src);
    return 0;
}
