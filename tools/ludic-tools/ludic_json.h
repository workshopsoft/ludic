/* ============================================================================
 * ludic_json.h — just enough JSON for LSP, and no dependencies.
 *
 * The rest of this toolchain is C with no third-party libraries, and the
 * language server should not be the thing that drags a package manager into a
 * project whose whole premise is a self-contained native pipeline. This is a
 * recursive-descent reader and an escaping writer; nothing more.
 * ==========================================================================*/
#ifndef LUDIC_JSON_H
#define LUDIC_JSON_H

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdarg.h>
#include <math.h>

enum { JNULL, JBOOL, JNUM, JSTR, JARR, JOBJ };

typedef struct JVal JVal;
struct JVal {
    int t;
    double num;
    int b;
    char* s;            /* JSTR: decoded UTF-8                                */
    JVal** kids; char** keys; int n, cap;
};

static JVal* jnew(int t){ JVal* v = calloc(1, sizeof(JVal)); v->t = t; return v; }
static void jfree(JVal* v){
    if (!v) return;
    for (int i = 0; i < v->n; i++){ jfree(v->kids[i]); free(v->keys ? v->keys[i] : 0); }
    free(v->kids); free(v->keys); free(v->s); free(v);
}
static void jpush(JVal* v, const char* key, JVal* kid){
    if (v->n >= v->cap){
        v->cap = v->cap ? v->cap * 2 : 8;
        v->kids = realloc(v->kids, v->cap * sizeof(JVal*));
        v->keys = realloc(v->keys, v->cap * sizeof(char*));
    }
    v->keys[v->n] = key ? strdup(key) : 0;
    v->kids[v->n++] = kid;
}

static void jskip(const char** p){ while (**p == ' ' || **p == '\t' || **p == '\n' || **p == '\r') (*p)++; }
static JVal* jparse_at(const char** p);

static void jutf8(char** o, unsigned cp){
    if (cp < 0x80) *(*o)++ = (char)cp;
    else if (cp < 0x800){ *(*o)++ = (char)(0xC0 | (cp >> 6)); *(*o)++ = (char)(0x80 | (cp & 63)); }
    else if (cp < 0x10000){ *(*o)++ = (char)(0xE0 | (cp >> 12)); *(*o)++ = (char)(0x80 | ((cp >> 6) & 63)); *(*o)++ = (char)(0x80 | (cp & 63)); }
    else { *(*o)++ = (char)(0xF0 | (cp >> 18)); *(*o)++ = (char)(0x80 | ((cp >> 12) & 63)); *(*o)++ = (char)(0x80 | ((cp >> 6) & 63)); *(*o)++ = (char)(0x80 | (cp & 63)); }
}
static char* jparse_string(const char** p){
    if (**p != '"') return 0;
    (*p)++;
    const char* s = *p;
    size_t cap = strlen(s) + 1;
    char* out = malloc(cap); char* o = out;
    while (**p && **p != '"'){
        if (**p == '\\'){
            (*p)++;
            char c = **p; (*p)++;
            switch (c){
                case 'n': *o++ = '\n'; break;
                case 't': *o++ = '\t'; break;
                case 'r': *o++ = '\r'; break;
                case 'b': *o++ = '\b'; break;
                case 'f': *o++ = '\f'; break;
                case 'u': {
                    unsigned cp = (unsigned)strtoul((char[5]){ (*p)[0], (*p)[1], (*p)[2], (*p)[3], 0 }, 0, 16);
                    *p += 4;
                    if (cp >= 0xD800 && cp < 0xDC00 && (*p)[0] == '\\' && (*p)[1] == 'u'){
                        unsigned lo = (unsigned)strtoul((char[5]){ (*p)[2], (*p)[3], (*p)[4], (*p)[5], 0 }, 0, 16);
                        *p += 6;
                        cp = 0x10000 + ((cp - 0xD800) << 10) + (lo - 0xDC00);
                    }
                    jutf8(&o, cp);
                    break;
                }
                default: *o++ = c;
            }
        } else *o++ = *(*p)++;
    }
    if (**p == '"') (*p)++;
    *o = 0;
    return out;
}
static JVal* jparse_at(const char** p){
    jskip(p);
    char c = **p;
    if (c == '{'){
        (*p)++; JVal* v = jnew(JOBJ);
        for (;;){
            jskip(p);
            if (**p == '}'){ (*p)++; break; }
            char* k = jparse_string(p);
            jskip(p); if (**p == ':') (*p)++;
            JVal* kid = jparse_at(p);
            jpush(v, k ? k : "", kid);
            free(k);
            jskip(p);
            if (**p == ',') (*p)++;
            else if (**p == '}'){ (*p)++; break; }
            else if (!**p) break;
        }
        return v;
    }
    if (c == '['){
        (*p)++; JVal* v = jnew(JARR);
        for (;;){
            jskip(p);
            if (**p == ']'){ (*p)++; break; }
            jpush(v, 0, jparse_at(p));
            jskip(p);
            if (**p == ',') (*p)++;
            else if (**p == ']'){ (*p)++; break; }
            else if (!**p) break;
        }
        return v;
    }
    if (c == '"'){ JVal* v = jnew(JSTR); v->s = jparse_string(p); return v; }
    if (!strncmp(*p, "true", 4)){ *p += 4; JVal* v = jnew(JBOOL); v->b = 1; return v; }
    if (!strncmp(*p, "false", 5)){ *p += 5; JVal* v = jnew(JBOOL); v->b = 0; return v; }
    if (!strncmp(*p, "null", 4)){ *p += 4; return jnew(JNULL); }
    { char* end; double d = strtod(*p, &end); if (end != *p){ *p = end; JVal* v = jnew(JNUM); v->num = d; return v; } }
    (*p)++;                                       /* unparsable: step past it */
    return jnew(JNULL);
}
static JVal* jparse(const char* text){ const char* p = text; return jparse_at(&p); }

static JVal* jget(JVal* v, const char* key){
    if (!v || v->t != JOBJ) return 0;
    for (int i = 0; i < v->n; i++) if (v->keys[i] && !strcmp(v->keys[i], key)) return v->kids[i];
    return 0;
}
static JVal* jat(JVal* v, int i){ return (v && i >= 0 && i < v->n) ? v->kids[i] : 0; }
static const char* jstr(JVal* v, const char* def){ return (v && v->t == JSTR && v->s) ? v->s : def; }
static int jint(JVal* v, int def){ return (v && v->t == JNUM) ? (int)v->num : def; }
static int jbool(JVal* v, int def){ return v ? (v->t == JBOOL ? v->b : (v->t == JNUM ? v->num != 0 : def)) : def; }
/* dotted lookup: jpath(msg, "params.textDocument.uri") */
static JVal* jpath(JVal* v, const char* path){
    char buf[256]; snprintf(buf, sizeof(buf), "%s", path);
    char* save = 0;
    for (char* tok = strtok_r(buf, ".", &save); tok; tok = strtok_r(0, ".", &save)){
        v = jget(v, tok);
        if (!v) return 0;
    }
    return v;
}

/* ---------- writing -------------------------------------------------------*/
typedef struct { char* b; size_t n, cap; } JSB;
static void jsb_ensure(JSB* s, size_t add){
    if (s->n + add + 1 > s->cap){ s->cap = (s->n + add + 1) * 2; s->b = realloc(s->b, s->cap); }
}
static void jsb_add(JSB* s, const char* z, size_t l){ jsb_ensure(s, l); memcpy(s->b + s->n, z, l); s->n += l; s->b[s->n] = 0; }
static void jsb_puts(JSB* s, const char* z){ jsb_add(s, z, strlen(z)); }
static void jsb_putc(JSB* s, char c){ jsb_add(s, &c, 1); }
static void jsb_putf(JSB* s, const char* fmt, ...){
    char tmp[1024];
    va_list ap; va_start(ap, fmt);
    int n = vsnprintf(tmp, sizeof(tmp), fmt, ap);
    va_end(ap);
    if (n < (int)sizeof(tmp)){ jsb_add(s, tmp, n); return; }
    char* big = malloc(n + 1);
    va_start(ap, fmt); vsnprintf(big, n + 1, fmt, ap); va_end(ap);
    jsb_add(s, big, n); free(big);
}
/* Escape a UTF-8 string as a JSON string literal, quotes included. */
static void jsb_str(JSB* s, const char* z){
    jsb_putc(s, '"');
    if (!z) z = "";
    for (const unsigned char* p = (const unsigned char*)z; *p; p++){
        switch (*p){
            case '"':  jsb_puts(s, "\\\""); break;
            case '\\': jsb_puts(s, "\\\\"); break;
            case '\n': jsb_puts(s, "\\n"); break;
            case '\r': jsb_puts(s, "\\r"); break;
            case '\t': jsb_puts(s, "\\t"); break;
            default:
                if (*p < 0x20) jsb_putf(s, "\\u%04x", *p);
                else jsb_putc(s, (char)*p);
        }
    }
    jsb_putc(s, '"');
}
static void jsb_kv_str(JSB* s, const char* k, const char* v){ jsb_str(s, k); jsb_putc(s, ':'); jsb_str(s, v); }
static void jsb_kv_int(JSB* s, const char* k, long v){ jsb_str(s, k); jsb_putf(s, ":%ld", v); }
static void jsb_kv_bool(JSB* s, const char* k, int v){ jsb_str(s, k); jsb_puts(s, v ? ":true" : ":false"); }
#endif /* LUDIC_JSON_H */
