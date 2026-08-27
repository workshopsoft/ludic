/* ============================================================================
 * ludic-fmt — the Ludic formatter, as a plain CLI.
 *
 * Editors call this through the language server, but CI and pre-commit hooks
 * want a binary they can run:
 *
 *   ludic-fmt a.ludic b.ludic        print the formatted text
 *   ludic-fmt -w examples           rewrite every .ludic under examples/
 *   ludic-fmt --check .             exit 1 if anything is unformatted
 *   ludic-fmt LANGUAGE.md -w        reformat the ```ludic fences in a document
 *   cat x.ludic | ludic-fmt -       filter mode, for editors without LSP
 * ==========================================================================*/
#include "ludic_fmt.h"
#include <dirent.h>
#include <sys/stat.h>
#include <limits.h>

static int g_write = 0, g_check = 0, g_indent = 2, g_quiet = 0;
static int g_changed = 0, g_failed = 0;

static char* slurp(FILE* f){
    FSB s = {0};
    char buf[65536]; size_t n;
    while ((n = fread(buf, 1, sizeof(buf), f)) > 0) fsb_add(&s, buf, n);
    if (!s.b){ s.b = malloc(1); s.b[0] = 0; }
    return s.b;
}
static int is_md(const char* p){
    size_t n = strlen(p);
    return (n > 3 && !strcmp(p + n - 3, ".md")) || (n > 9 && !strcmp(p + n - 9, ".markdown"));
}
static int is_ludic(const char* p){
    size_t n = strlen(p);
    return n > 6 && !strcmp(p + n - 6, ".ludic");
}

static void do_file(const char* path){
    FILE* f = fopen(path, "rb");
    if (!f){ fprintf(stderr, "ludic-fmt: cannot open %s\n", path); g_failed = 1; return; }
    char* src = slurp(f); fclose(f);
    char* out = is_md(path) ? ludic_format_markdown(src, g_indent) : ludic_format(src, g_indent);
    int same = !strcmp(src, out);
    if (g_check){
        if (!same){ g_changed = 1; if (!g_quiet) printf("%s\n", path); }
    } else if (g_write){
        if (!same){
            FILE* w = fopen(path, "wb");
            if (!w){ fprintf(stderr, "ludic-fmt: cannot write %s\n", path); g_failed = 1; }
            else { fwrite(out, 1, strlen(out), w); fclose(w); if (!g_quiet) fprintf(stderr, "formatted %s\n", path); }
            g_changed = 1;
        }
    } else {
        fwrite(out, 1, strlen(out), stdout);
    }
    free(src); free(out);
}
static void do_dir(const char* dir, int depth){
    if (depth > 16) return;
    DIR* d = opendir(dir);
    if (!d){ fprintf(stderr, "ludic-fmt: cannot open %s\n", dir); g_failed = 1; return; }
    struct dirent* e;
    while ((e = readdir(d))){
        if (e->d_name[0] == '.') continue;
        if (!strcmp(e->d_name, "build") || !strcmp(e->d_name, "node_modules")) continue;
        char p[PATH_MAX]; snprintf(p, sizeof(p), "%s/%s", dir, e->d_name);
        struct stat st; if (stat(p, &st)) continue;
        if (S_ISDIR(st.st_mode)) do_dir(p, depth + 1);
        else if (is_ludic(p)) do_file(p);
    }
    closedir(d);
}

static const char* USAGE =
"ludic-fmt — format Ludic source\n"
"\n"
"usage: ludic-fmt [options] [file|dir ...]\n"
"       ludic-fmt -            read stdin, write stdout\n"
"\n"
"options:\n"
"  -w, --write        rewrite files in place\n"
"      --check        list unformatted files; exit 1 if any (implies no output)\n"
"      --indent N     spaces per level (default 2)\n"
"  -q, --quiet        no per-file chatter\n"
"  -h, --help         this text\n"
"\n"
"Directories are walked for *.ludic. A .md/.markdown file has the body of every\n"
"```ludic fence formatted and the prose left alone.\n";

int main(int argc, char** argv){
    const char* files[4096]; int nf = 0;
    for (int i = 1; i < argc; i++){
        const char* a = argv[i];
        if (!strcmp(a, "-w") || !strcmp(a, "--write")) g_write = 1;
        else if (!strcmp(a, "--check") || !strcmp(a, "-l")) g_check = 1;
        else if (!strcmp(a, "-q") || !strcmp(a, "--quiet")) g_quiet = 1;
        else if (!strcmp(a, "--indent") && i + 1 < argc) g_indent = atoi(argv[++i]);
        else if (!strcmp(a, "-h") || !strcmp(a, "--help")){ fputs(USAGE, stdout); return 0; }
        else if (a[0] == '-' && a[1] && strcmp(a, "-")){ fprintf(stderr, "ludic-fmt: unknown option %s\n", a); return 2; }
        else if (nf < 4096) files[nf++] = a;
    }
    if (g_indent < 1 || g_indent > 8) g_indent = 2;

    if (nf == 0 || (nf == 1 && !strcmp(files[0], "-"))){
        char* src = slurp(stdin);
        char* out = ludic_format(src, g_indent);
        fwrite(out, 1, strlen(out), stdout);
        free(src); free(out);
        return 0;
    }
    for (int i = 0; i < nf; i++){
        struct stat st;
        if (stat(files[i], &st)){ fprintf(stderr, "ludic-fmt: no such file %s\n", files[i]); g_failed = 1; continue; }
        if (S_ISDIR(st.st_mode)) do_dir(files[i], 0);
        else do_file(files[i]);
    }
    if (g_failed) return 2;
    return (g_check && g_changed) ? 1 : 0;
}
