/* ============================================================================
 * ludic_syntax.h — the lexical layer shared by every Ludic editor tool.
 *
 * One lexer, one vocabulary. `ludic-fmt`, `ludic-lsp` and the generated
 * TextMate grammar all read their keyword/builtin/type tables from here, so an
 * addition to the language shows up in every editor at once instead of drifting
 * across six hand-maintained copies.
 *
 * Unlike the compiler's lexer (compiler/ludicc.c) this one is written for
 * editors: it keeps comments, keeps newlines, records byte spans for every
 * token, and never exits on bad input — a stray character becomes an LT_ERR
 * token and lexing continues, because a file being typed into is malformed most
 * of the time.
 * ==========================================================================*/
#ifndef LUDIC_SYNTAX_H
#define LUDIC_SYNTAX_H

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

/* ---------- token kinds ---------------------------------------------------*/
enum {
    LT_EOF, LT_NL, LT_COMMENT,
    LT_ID,        /* a plain identifier                                       */
    LT_KW,        /* a reserved word (see KEYWORDS)                           */
    LT_TYPE,      /* a built-in type name: int fixed bool entity str ptr void  */
    LT_PHASE,     /* Start Input FixedUpdate Update LateUpdate Render          */
    LT_BOOL,      /* true false                                               */
    LT_INT, LT_FLOAT, LT_STR, LT_CHAR,
    LT_ANNO,      /* @deterministic — the '@' and the name as one token        */
    LT_OP,
    LT_ERR
};

typedef struct {
    int kind;
    int start, end;   /* byte offsets into the source buffer                   */
    int line;         /* 0-based                                               */
    int bad;          /* set on an unterminated string / stray character       */
} LTok;

typedef struct {
    LTok* v; int n, cap;
    const char* src;
    int* linestart; int nline, caplin;
} LLex;

/* ---------- the vocabulary ------------------------------------------------*/
/* Reserved words, grouped so editors can colour them differently. The groups
 * mirror the compiler's parser: anything parse_decl() dispatches on is a
 * declaration keyword, anything stmt() dispatches on is a statement keyword. */
static const char* LUDIC_KW_DECL[] = {
    "program","import","property","model","enum","ui",
    "const","var","fn","extern","handler","entry", 0
};
static const char* LUDIC_KW_CLAUSE[] = {
    "phase","query","on", 0
};
/* Documented design targets the self-hosted parser does not accept yet. Kept
 * out of the highlighted vocabulary (they would read as working keywords) until
 * they are implemented; check-vocabulary.py verifies the lists above are a
 * subset of what selfhost/parse*.ludic actually dispatches on. */
static const char* LUDIC_KW_RESERVED[] = {
    "scene","layer","start", 0
};
static const char* LUDIC_KW_STMT[] = {
    "let","return","if","else","while","for","in","spawn","despawn",
    "enable","disable","match","machine","state","become","where",
    "and","or","not","break","continue","new", 0
};
static const char* LUDIC_TYPES[] = {
    "int","fixed","bool","entity","str","ptr","void", 0
};
static const char* LUDIC_PHASES[] = {
    "Start","Input","FixedUpdate","Update","LateUpdate","Render", 0
};
static const char* LUDIC_WIDGETS[] = {
    "panel","col","row","label","button","image","spacer", 0
};
static const char* LUDIC_WIDGET_PROPS[] = {
    "id","text","skin","image","align","w","h","pad","gap","size","font",
    "inset","grow","bg","fg","border","focus","x","y", 0
};

/* A builtin is a name the runtime provides (`clear(c)` -> rt_clear). An
 * intrinsic is a name the compiler lowers directly to libc/OS. Editors treat
 * both as "standard library", but the signatures differ, so they stay apart. */
typedef struct { const char* name; const char* sig; const char* doc; } LBuiltin;

static const LBuiltin LUDIC_BUILTINS[] = {
 {"min","min(a: int, b: int) -> int","Smaller of two integers."},
 {"max","max(a: int, b: int) -> int","Larger of two integers."},
 {"abs","abs(a: int) -> int","Absolute value."},
 {"clamp","clamp(v: int, lo: int, hi: int) -> int","Constrain v to [lo, hi]."},
 {"seed","seed(i: int)","Seed the deterministic RNG."},
 {"rng_range","rng_range(lo: int, hi: int) -> int","Deterministic integer in [lo, hi]."},
 {"rng_chance","rng_chance(pct: int) -> bool","True pct% of the time, deterministically."},
 {"fx","fx(i: int) -> fixed","Widen an int to Q16.16 fixed-point."},
 {"flr","flr(f: fixed) -> int","Truncate a fixed-point value toward zero."},
 {"map_size","map_size(w: int, h: int)","Set the tilemap dimensions."},
 {"map_row","map_row(y: int, row: str)","Fill one tilemap row from a string."},
 {"tile","tile(x: int, y: int) -> int","Tile code at a map cell."},
 {"clear","clear(color: int)","Clear the framebuffer to a 0xRRGGBB colour."},
 {"present","present()","Push the framebuffer to the window (or out.ppm when headless)."},
 {"fill_rect","fill_rect(x: int, y: int, w: int, h: int, color: int)","Filled rectangle."},
 {"frame_rect","frame_rect(x: int, y: int, w: int, h: int, color: int)","One-pixel rectangle outline."},
 {"put_px","put_px(x: int, y: int, color: int)","Write a single pixel."},
 {"text","text(x: int, y: int, s: str, color: int, scale: int)","Draw text with the built-in 5x7 bitmap font."},
 {"text_int","text_int(x: int, y: int, n: int, color: int, scale: int)","Draw an integer with the 5x7 bitmap font."},
 {"font_load","font_load(path: str) -> int","Load a TrueType .ttf/.ttc; returns a font id."},
 {"text_ttf","text_ttf(font: int, x: int, y: int, utf8: str, color: int, px: int)","Draw UTF-8 text with a TrueType font."},
 {"text_w","text_w(font: int, utf8: str, px: int) -> int","Advance width of the string, in pixels."},
 {"text_h","text_h(font: int, px: int) -> int","Line height of the font, in pixels."},
 {"image_load","image_load(path: str) -> int","Decode a PNG into an image id."},
 {"draw_image","draw_image(id: int, x: int, y: int)","Blit an image at its natural size."},
 {"draw_image_scaled","draw_image_scaled(id: int, x: int, y: int, w: int, h: int)","Blit an image stretched to w x h."},
 {"draw_9slice","draw_9slice(id: int, x: int, y: int, w: int, h: int, inset: int)","Nine-slice an image across a w x h box."},
 {"png_load","png_load(path: str) -> int","Decode a PNG as a 16x16 sprite sheet; returns the first sprite id."},
 {"sprites_load","sprites_load(path: str)","Load the sprite sheet used by draw_sprite."},
 {"draw_sprite","draw_sprite(id: int, x: int, y: int)","Blit a sprite."},
 {"draw_sprite_scaled","draw_sprite_scaled(id: int, x: int, y: int, scale: int)","Blit a sprite at an integer scale."},
 {"ui_build","ui_build()","Construct every declared `ui` tree (loads skins and images)."},
 {"ui_open","ui_open(id: int)","Make a ui tree active and focus its first button."},
 {"ui_tick","ui_tick(key: int)","Feed a key to the UI: w/s move focus, space/enter activate."},
 {"ui_render","ui_render()","Lay out and draw the active ui tree."},
 {"ui_clicked","ui_clicked(id: int) -> bool","True on the frame a widget was activated."},
 {"ui_set_text","ui_set_text(id: int, s: str)","Replace a widget's text."},
 {"ui_set_int","ui_set_int(id: int, n: int)","Replace a widget's text with a number."},
 {"ui_focus","ui_focus(id: int)","Move keyboard focus to a widget."},
 {"ui_focused","ui_focused() -> int","Id of the focused widget."},
 {"ui_visible","ui_visible(id: int, on: bool)","Show or hide a widget subtree."},
 {"key","key() -> int","Key code pressed this frame, 0 if none."},
 {"reg","reg(i: int) -> int","Read one of the 64 integer resources shared by systems."},
 {"set_reg","set_reg(i: int, v: int)","Write one of the 64 integer resources."},
 {"self","self() -> entity","The entity of the innermost query loop."},
 {"save","save()","Write a binary snapshot of the whole ECS world."},
 {"load","load() -> bool","Restore the snapshot; false if there is none."},
 {"status","status(s: str)","Set the one-line status message."},
 {"print_int","print_int(i: int)","Print an integer to stdout."},
 {"quit","quit()","Stop the frame loop and exit."},
 {0,0,0}
};

static const LBuiltin LUDIC_INTRINSICS[] = {
 {"mem_alloc","mem_alloc(n: int) -> ptr","Allocate n bytes (malloc)."},
 {"mem_realloc","mem_realloc(p: ptr, n: int) -> ptr","Resize a block to n bytes, preserving its contents (realloc)."},
 {"os_argc","os_argc() -> int","Number of command-line arguments, argv[0] included."},
 {"os_arg","os_arg(i: int) -> str","The i-th command-line argument."},
 {"file_stderr","file_stderr() -> ptr","The standard error stream, for file_write."},
 {"mem_free","mem_free(p: ptr)","Release an allocation."},
 {"mem_copy","mem_copy(dst: ptr, src: ptr, n: int)","memcpy."},
 {"mem_set","mem_set(p: ptr, byte: int, n: int)","memset."},
 {"peek8","peek8(p: ptr, off: int) -> int","Read one byte."},
 {"poke8","poke8(p: ptr, off: int, v: int)","Write one byte."},
 {"peek32","peek32(p: ptr, off: int) -> int","Read a 32-bit word."},
 {"poke32","poke32(p: ptr, off: int, v: int)","Write a 32-bit word."},
 {"peekp","peekp(p: ptr, off: int) -> ptr","Read a pointer-sized word."},
 {"pokep","pokep(p: ptr, off: int, v: ptr)","Write a pointer-sized word."},
 {"peekf","peekf(p: ptr, off: int) -> fixed","Read a fixed-point word."},
 {"pokef","pokef(p: ptr, off: int, v: fixed)","Write a fixed-point word."},
 {"ptr_add","ptr_add(p: ptr, off: int) -> ptr","Offset a pointer by bytes."},
 {"ptr_null","ptr_null() -> ptr","The null pointer."},
 {"ptr_is_null","ptr_is_null(p: ptr) -> bool","Null test."},
 {"as_fixed","as_fixed(i: int) -> fixed","Reinterpret an int as fixed (no conversion)."},
 {"as_int","as_int(f: fixed) -> int","Reinterpret a fixed as int (no conversion)."},
 {"file_open","file_open(path: str, mode: str) -> ptr","fopen."},
 {"file_read","file_read(f: ptr, buf: ptr, n: int) -> int","fread."},
 {"file_write","file_write(f: ptr, buf: ptr, n: int) -> int","fwrite."},
 {"file_seek","file_seek(f: ptr, off: int, whence: int) -> int","fseek."},
 {"file_tell","file_tell(f: ptr) -> int","ftell."},
 {"file_close","file_close(f: ptr)","fclose."},
 {"read_byte","read_byte() -> int","Read one byte from stdin, -1 at EOF."},
 {"write_byte","write_byte(b: int)","Write one byte to stdout."},
 {"print_str","print_str(s: str)","Write a string to stdout."},
 {"str_len","str_len(s: str) -> int","Length of a string in bytes."},
 {"os_exit","os_exit(code: int)","Terminate the process."},
 {"os_time","os_time() -> int","Seconds since the epoch."},
 {"is_windowed","is_windowed() -> bool","True when the build has a window."},
 {"game_title","game_title() -> str","The name from the `game` declaration."},
 {"win_open","win_open(title: str, w: int, h: int, scale: int)","Open the platform window."},
 {"win_poll","win_poll() -> int","Pump the event queue; returns a key code."},
 {"win_present","win_present(px: ptr, w: int, h: int)","Blit a framebuffer to the window."},
 {"win_running","win_running() -> bool","False once the window has been closed."},
 {"win_close","win_close()","Close the platform window."},
 {0,0,0}
};

static int lud_in(const char** set, const char* s){
    for (int i = 0; set[i]; i++) if (!strcmp(set[i], s)) return 1;
    return 0;
}
static const LBuiltin* lud_lookup(const LBuiltin* t, const char* s){
    for (int i = 0; t[i].name; i++) if (!strcmp(t[i].name, s)) return &t[i];
    return 0;
}
static int lud_is_keyword(const char* s){
    return lud_in(LUDIC_KW_DECL, s) || lud_in(LUDIC_KW_CLAUSE, s) || lud_in(LUDIC_KW_STMT, s);
}

/* ---------- lexing --------------------------------------------------------*/
static void ltok_push(LLex* L, int kind, int start, int end, int line, int bad){
    if (L->n >= L->cap){ L->cap = L->cap ? L->cap * 2 : 512; L->v = realloc(L->v, L->cap * sizeof(LTok)); }
    L->v[L->n++] = (LTok){ kind, start, end, line, bad };
}
static void lline_push(LLex* L, int off){
    if (L->nline >= L->caplin){ L->caplin = L->caplin ? L->caplin * 2 : 256; L->linestart = realloc(L->linestart, L->caplin * sizeof(int)); }
    L->linestart[L->nline++] = off;
}

static const char* LUDIC_OPS2[] = { "->","+=","-=","*=","/=","==","!=","<=",">=","&&","||","..","=>", 0 };

/* Lex the whole buffer. Comments and newlines are kept — the formatter needs
 * both, and a highlighter needs the comments. */
static void lud_lex(LLex* L, const char* src){
    memset(L, 0, sizeof(*L));
    L->src = src;
    lline_push(L, 0);
    int i = 0, line = 0;
    while (src[i]){
        char c = src[i];
        if (c == '\n'){ ltok_push(L, LT_NL, i, i + 1, line, 0); i++; line++; lline_push(L, i); continue; }
        if (c == ' ' || c == '\t' || c == '\r'){ i++; continue; }
        if (c == '#'){ int s = i; while (src[i] && src[i] != '\n') i++; ltok_push(L, LT_COMMENT, s, i, line, 0); continue; }
        if (c == '"'){
            int s = i; i++; int bad = 0;
            while (src[i] && src[i] != '"' && src[i] != '\n'){ if (src[i] == '\\' && src[i+1]) i += 2; else i++; }
            if (src[i] == '"') i++; else bad = 1;
            ltok_push(L, LT_STR, s, i, line, bad); continue;
        }
        if (c == '\''){
            int s = i; i++; int bad = 0;
            if (src[i] == '\\' && src[i+1]) i += 2; else if (src[i] && src[i] != '\n') i++;
            if (src[i] == '\'') i++; else bad = 1;
            ltok_push(L, LT_CHAR, s, i, line, bad); continue;
        }
        if (isdigit((unsigned char)c)){
            int s = i;
            if (c == '0' && (src[i+1] == 'x' || src[i+1] == 'X')){
                i += 2; while (isxdigit((unsigned char)src[i])) i++;
                ltok_push(L, LT_INT, s, i, line, 0); continue;
            }
            while (isdigit((unsigned char)src[i])) i++;
            if (src[i] == '.' && isdigit((unsigned char)src[i+1])){
                i++; while (isdigit((unsigned char)src[i])) i++;
                ltok_push(L, LT_FLOAT, s, i, line, 0); continue;
            }
            ltok_push(L, LT_INT, s, i, line, 0); continue;
        }
        /* @name is one token: an annotation reads as a unit, and the formatter
         * must never put a space between the sigil and the name. */
        if (c == '@' && (isalpha((unsigned char)src[i+1]) || src[i+1] == '_')){
            int s = i; i++; while (isalnum((unsigned char)src[i]) || src[i] == '_') i++;
            ltok_push(L, LT_ANNO, s, i, line, 0); continue;
        }
        if (isalpha((unsigned char)c) || c == '_'){
            int s = i; while (isalnum((unsigned char)src[i]) || src[i] == '_') i++;
            int len = i - s; char w[128];
            if (len < (int)sizeof(w)){ memcpy(w, src + s, len); w[len] = 0; } else { w[0] = 0; }
            int k = LT_ID;
            if (!strcmp(w, "true") || !strcmp(w, "false")) k = LT_BOOL;
            else if (lud_in(LUDIC_TYPES, w)) k = LT_TYPE;
            else if (lud_in(LUDIC_PHASES, w)) k = LT_PHASE;
            else if (lud_is_keyword(w)) k = LT_KW;
            ltok_push(L, k, s, i, line, 0); continue;
        }
        {
            int matched = 0;
            for (int k = 0; LUDIC_OPS2[k]; k++)
                if (src[i] == LUDIC_OPS2[k][0] && src[i+1] == LUDIC_OPS2[k][1]){
                    ltok_push(L, LT_OP, i, i + 2, line, 0); i += 2; matched = 1; break;
                }
            if (matched) continue;
        }
        if (c == ';'){ ltok_push(L, LT_OP, i, i + 1, line, 0); i++; continue; }
        if (strchr("+-*/%<>=(){}[],:.!@", c)){ ltok_push(L, LT_OP, i, i + 1, line, 0); i++; continue; }
        /* Anything else is an error token — but a whole UTF-8 character's worth
         * at a time. Splitting a multi-byte character into one token per byte
         * would let a consumer that re-emits tokens (the formatter) put spaces
         * inside it and corrupt the file. */
        {
            unsigned char u = (unsigned char)c;
            int len = u < 0x80 ? 1 : u < 0xE0 ? 2 : u < 0xF0 ? 3 : 4;
            for (int k = 1; k < len; k++) if (!src[i + k] || ((unsigned char)src[i + k] & 0xC0) != 0x80){ len = k; break; }
            ltok_push(L, LT_ERR, i, i + len, line, 1); i += len;
        }
    }
    ltok_push(L, LT_EOF, i, i, line, 0);
}
static void lud_lex_free(LLex* L){ free(L->v); free(L->linestart); memset(L, 0, sizeof(*L)); }

/* ---------- helpers over the token stream --------------------------------*/
static int ltok_len(const LTok* t){ return t->end - t->start; }
static int ltok_is(const LLex* L, int i, const char* s){
    if (i < 0 || i >= L->n) return 0;
    const LTok* t = &L->v[i]; int n = ltok_len(t);
    return (int)strlen(s) == n && !strncmp(L->src + t->start, s, n);
}
/* Copy a token's text into a caller buffer; returns buf. */
static char* ltok_text(const LLex* L, int i, char* buf, int cap){
    const LTok* t = &L->v[i]; int n = ltok_len(t);
    if (n >= cap) n = cap - 1;
    memcpy(buf, L->src + t->start, n); buf[n] = 0; return buf;
}
/* Index of the next token that is not a newline or comment, or -1. */
static int ltok_next_sig(const LLex* L, int i){
    for (int j = i + 1; j < L->n; j++){
        int k = L->v[j].kind;
        if (k != LT_NL && k != LT_COMMENT) return j;
    }
    return -1;
}
static int ltok_prev_sig(const LLex* L, int i){
    for (int j = i - 1; j >= 0; j--){
        int k = L->v[j].kind;
        if (k != LT_NL && k != LT_COMMENT) return j;
    }
    return -1;
}
#endif /* LUDIC_SYNTAX_H */
