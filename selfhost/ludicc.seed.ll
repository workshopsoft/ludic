; Ludic (self-hosted) -> LLVM IR
declare i32 @printf(ptr, ...)
declare ptr @malloc(i64)
declare ptr @realloc(ptr, i64)
declare void @free(ptr)
declare ptr @fopen(ptr, ptr)
declare i64 @fread(ptr, i64, i64, ptr)
declare i64 @fwrite(ptr, i64, i64, ptr)
declare i32 @fseek(ptr, i64, i32)
declare i64 @ftell(ptr)
declare i32 @fclose(ptr)
declare void @exit(i32)
declare i32 @system(ptr)
declare ptr @getenv(ptr)
declare ptr @memcpy(ptr, ptr, i64)
declare ptr @memset(ptr, i32, i64)
declare i64 @strlen(ptr)
declare i32 @getchar()
declare i32 @putchar(i32)
declare i64 @time(ptr)
declare void @win_open(i32, i32, i32, ptr)
declare i32 @win_poll()
declare void @win_present(ptr, i32, i32)
declare i32 @win_running()
declare void @win_close()
@__stderrp = external global ptr
@.fmt_str = private unnamed_addr constant [3 x i8] c"%s\00"
@.fmt_int = private unnamed_addr constant [4 x i8] c"%d\0A\00"
@L_argc = internal global i32 0
@L_argv = internal global ptr null
@.gametitle = private unnamed_addr constant [9 x i8] c"SelfHost\00"
%LSlice = type { ptr, i32, i32 }
%Str_Buf = type { ptr, i32, i32 }
%Str_Node = type { i32, ptr, i32, ptr, ptr, ptr, ptr, ptr, i32 }
%Str_Tok = type { i32, ptr, i32, i32 }
%Str_Val = type { ptr, ptr }
@g_toks = internal global ptr null
@g_pi = internal global i32 0
@g_prog = internal global ptr null
@g_g_game_name = internal global ptr null
@g_loaded_paths = internal global ptr null
@g_cur_dir = internal global ptr null
@g_head = internal global ptr null
@g_code = internal global ptr null
@g_falloc = internal global ptr null
@g_ll_t = internal global i32 0
@g_ll_lbl = internal global i32 0
@g_ll_str = internal global i32 0
@g_loc_name = internal global ptr null
@g_loc_reg = internal global ptr null
@g_loc_ty = internal global ptr null
@g_nloc = internal global i32 0
@g_brk_lbl = internal global ptr null
@g_cnt_lbl = internal global ptr null
@g_nloop = internal global i32 0
@g_ret_ty = internal global ptr null
@g_g_term = internal global i32 0
@g_self_stk = internal global ptr null
@g_nself = internal global i32 0
@g_mach_stk = internal global ptr null
@g_nmach = internal global i32 0
@g_g_addr_ty = internal global ptr null
@g_g_intrin_ok = internal global i32 0
@g_g_windowed = internal global i32 0
@g_g_iok = internal global i32 0
@g_uiw = internal global ptr null
@g_uiw_parent = internal global ptr null
@g_ui_roots = internal global ptr null
@.str0 = private unnamed_addr constant [3 x i8] c"rb\00"
@.str1 = private unnamed_addr constant [28 x i8] c"ludicc(self): parse error: \00"
@.str2 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str3 = private unnamed_addr constant [20 x i8] c"expected identifier\00"
@.str4 = private unnamed_addr constant [2 x i8] c"[\00"
@.str5 = private unnamed_addr constant [2 x i8] c"]\00"
@.str6 = private unnamed_addr constant [2 x i8] c"(\00"
@.str7 = private unnamed_addr constant [2 x i8] c")\00"
@.str8 = private unnamed_addr constant [2 x i8] c",\00"
@.str9 = private unnamed_addr constant [2 x i8] c")\00"
@.str10 = private unnamed_addr constant [5 x i8] c"true\00"
@.str11 = private unnamed_addr constant [6 x i8] c"false\00"
@.str12 = private unnamed_addr constant [4 x i8] c"new\00"
@.str13 = private unnamed_addr constant [2 x i8] c"(\00"
@.str14 = private unnamed_addr constant [2 x i8] c")\00"
@.str15 = private unnamed_addr constant [20 x i8] c"expected expression\00"
@.str16 = private unnamed_addr constant [2 x i8] c".\00"
@.str17 = private unnamed_addr constant [2 x i8] c"[\00"
@.str18 = private unnamed_addr constant [2 x i8] c"]\00"
@.str19 = private unnamed_addr constant [2 x i8] c"(\00"
@.str20 = private unnamed_addr constant [2 x i8] c"-\00"
@.str21 = private unnamed_addr constant [2 x i8] c"-\00"
@.str22 = private unnamed_addr constant [4 x i8] c"not\00"
@.str23 = private unnamed_addr constant [4 x i8] c"not\00"
@.str24 = private unnamed_addr constant [2 x i8] c"*\00"
@.str25 = private unnamed_addr constant [2 x i8] c"/\00"
@.str26 = private unnamed_addr constant [2 x i8] c"%\00"
@.str27 = private unnamed_addr constant [2 x i8] c"+\00"
@.str28 = private unnamed_addr constant [2 x i8] c"-\00"
@.str29 = private unnamed_addr constant [2 x i8] c"<\00"
@.str30 = private unnamed_addr constant [3 x i8] c"<=\00"
@.str31 = private unnamed_addr constant [2 x i8] c">\00"
@.str32 = private unnamed_addr constant [3 x i8] c">=\00"
@.str33 = private unnamed_addr constant [3 x i8] c"==\00"
@.str34 = private unnamed_addr constant [3 x i8] c"!=\00"
@.str35 = private unnamed_addr constant [4 x i8] c"and\00"
@.str36 = private unnamed_addr constant [4 x i8] c"and\00"
@.str37 = private unnamed_addr constant [3 x i8] c"or\00"
@.str38 = private unnamed_addr constant [3 x i8] c"or\00"
@.str39 = private unnamed_addr constant [2 x i8] c"{\00"
@.str40 = private unnamed_addr constant [2 x i8] c"}\00"
@.str41 = private unnamed_addr constant [2 x i8] c":\00"
@.str42 = private unnamed_addr constant [2 x i8] c",\00"
@.str43 = private unnamed_addr constant [2 x i8] c"}\00"
@.str44 = private unnamed_addr constant [2 x i8] c"{\00"
@.str45 = private unnamed_addr constant [2 x i8] c"}\00"
@.str46 = private unnamed_addr constant [2 x i8] c"}\00"
@.str47 = private unnamed_addr constant [5 x i8] c"cur=\00"
@.str48 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str49 = private unnamed_addr constant [43 x i8] c"expected newline or ';' between statements\00"
@.str50 = private unnamed_addr constant [2 x i8] c"}\00"
@.str51 = private unnamed_addr constant [4 x i8] c"let\00"
@.str52 = private unnamed_addr constant [2 x i8] c":\00"
@.str53 = private unnamed_addr constant [2 x i8] c"=\00"
@.str54 = private unnamed_addr constant [7 x i8] c"return\00"
@.str55 = private unnamed_addr constant [2 x i8] c"}\00"
@.str56 = private unnamed_addr constant [3 x i8] c"if\00"
@.str57 = private unnamed_addr constant [5 x i8] c"else\00"
@.str58 = private unnamed_addr constant [3 x i8] c"if\00"
@.str59 = private unnamed_addr constant [5 x i8] c"when\00"
@.str60 = private unnamed_addr constant [6 x i8] c"while\00"
@.str61 = private unnamed_addr constant [4 x i8] c"for\00"
@.str62 = private unnamed_addr constant [2 x i8] c"(\00"
@.str63 = private unnamed_addr constant [3 x i8] c"..\00"
@.str64 = private unnamed_addr constant [6 x i8] c"spawn\00"
@.str65 = private unnamed_addr constant [8 x i8] c"machine\00"
@.str66 = private unnamed_addr constant [2 x i8] c"{\00"
@.str67 = private unnamed_addr constant [2 x i8] c"}\00"
@.str68 = private unnamed_addr constant [2 x i8] c"=\00"
@.str69 = private unnamed_addr constant [2 x i8] c"}\00"
@.str70 = private unnamed_addr constant [7 x i8] c"become\00"
@.str71 = private unnamed_addr constant [6 x i8] c"enter\00"
@.str72 = private unnamed_addr constant [8 x i8] c"despawn\00"
@.str73 = private unnamed_addr constant [6 x i8] c"break\00"
@.str74 = private unnamed_addr constant [9 x i8] c"continue\00"
@.str75 = private unnamed_addr constant [6 x i8] c"match\00"
@.str76 = private unnamed_addr constant [2 x i8] c"{\00"
@.str77 = private unnamed_addr constant [2 x i8] c"}\00"
@.str78 = private unnamed_addr constant [2 x i8] c",\00"
@.str79 = private unnamed_addr constant [3 x i8] c"=>\00"
@.str80 = private unnamed_addr constant [2 x i8] c"{\00"
@.str81 = private unnamed_addr constant [2 x i8] c"}\00"
@.str82 = private unnamed_addr constant [2 x i8] c"=\00"
@.str83 = private unnamed_addr constant [3 x i8] c"+=\00"
@.str84 = private unnamed_addr constant [3 x i8] c"-=\00"
@.str85 = private unnamed_addr constant [3 x i8] c"*=\00"
@.str86 = private unnamed_addr constant [3 x i8] c"/=\00"
@.str87 = private unnamed_addr constant [2 x i8] c"{\00"
@.str88 = private unnamed_addr constant [2 x i8] c"}\00"
@.str89 = private unnamed_addr constant [2 x i8] c":\00"
@.str90 = private unnamed_addr constant [2 x i8] c"=\00"
@.str91 = private unnamed_addr constant [2 x i8] c",\00"
@.str92 = private unnamed_addr constant [2 x i8] c"}\00"
@.str93 = private unnamed_addr constant [2 x i8] c":\00"
@.str94 = private unnamed_addr constant [2 x i8] c"=\00"
@.str95 = private unnamed_addr constant [2 x i8] c":\00"
@.str96 = private unnamed_addr constant [2 x i8] c"=\00"
@.str97 = private unnamed_addr constant [2 x i8] c"(\00"
@.str98 = private unnamed_addr constant [2 x i8] c")\00"
@.str99 = private unnamed_addr constant [2 x i8] c":\00"
@.str100 = private unnamed_addr constant [2 x i8] c",\00"
@.str101 = private unnamed_addr constant [2 x i8] c")\00"
@.str102 = private unnamed_addr constant [5 x i8] c"void\00"
@.str103 = private unnamed_addr constant [3 x i8] c"->\00"
@.str104 = private unnamed_addr constant [1 x i8] c"\00"
@.str105 = private unnamed_addr constant [2 x i8] c"@\00"
@.str106 = private unnamed_addr constant [7 x i8] c"export\00"
@.str107 = private unnamed_addr constant [2 x i8] c"(\00"
@.str108 = private unnamed_addr constant [2 x i8] c"(\00"
@.str109 = private unnamed_addr constant [2 x i8] c")\00"
@.str110 = private unnamed_addr constant [7 x i8] c"import\00"
@.str111 = private unnamed_addr constant [29 x i8] c"expected \22path\22 after import\00"
@.str112 = private unnamed_addr constant [7 x i8] c"struct\00"
@.str113 = private unnamed_addr constant [5 x i8] c"enum\00"
@.str114 = private unnamed_addr constant [9 x i8] c"property\00"
@.str115 = private unnamed_addr constant [6 x i8] c"model\00"
@.str116 = private unnamed_addr constant [8 x i8] c"handler\00"
@.str117 = private unnamed_addr constant [3 x i8] c"ui\00"
@.str118 = private unnamed_addr constant [4 x i8] c"var\00"
@.str119 = private unnamed_addr constant [6 x i8] c"const\00"
@.str120 = private unnamed_addr constant [3 x i8] c"fn\00"
@.str121 = private unnamed_addr constant [7 x i8] c"extern\00"
@.str122 = private unnamed_addr constant [6 x i8] c"entry\00"
@.str123 = private unnamed_addr constant [21 x i8] c"expected declaration\00"
@.str124 = private unnamed_addr constant [20 x i8] c"cannot open import \00"
@.str125 = private unnamed_addr constant [1 x i8] c"\00"
@.str126 = private unnamed_addr constant [26 x i8] c"runtime/native/core.ludic\00"
@.str127 = private unnamed_addr constant [6 x i8] c"Ludic\00"
@.str128 = private unnamed_addr constant [7 x i8] c"import\00"
@.str129 = private unnamed_addr constant [8 x i8] c"program\00"
@.str130 = private unnamed_addr constant [2 x i8] c"{\00"
@.str131 = private unnamed_addr constant [2 x i8] c"}\00"
@.str132 = private unnamed_addr constant [2 x i8] c"{\00"
@.str133 = private unnamed_addr constant [2 x i8] c"}\00"
@.str134 = private unnamed_addr constant [2 x i8] c":\00"
@.str135 = private unnamed_addr constant [2 x i8] c"=\00"
@.str136 = private unnamed_addr constant [2 x i8] c",\00"
@.str137 = private unnamed_addr constant [2 x i8] c"}\00"
@.str138 = private unnamed_addr constant [2 x i8] c"[\00"
@.str139 = private unnamed_addr constant [2 x i8] c"[\00"
@.str140 = private unnamed_addr constant [2 x i8] c"]\00"
@.str141 = private unnamed_addr constant [7 x i8] c"Update\00"
@.str142 = private unnamed_addr constant [2 x i8] c"@\00"
@.str143 = private unnamed_addr constant [2 x i8] c"(\00"
@.str144 = private unnamed_addr constant [2 x i8] c"(\00"
@.str145 = private unnamed_addr constant [2 x i8] c")\00"
@.str146 = private unnamed_addr constant [6 x i8] c"phase\00"
@.str147 = private unnamed_addr constant [6 x i8] c"reads\00"
@.str148 = private unnamed_addr constant [7 x i8] c"writes\00"
@.str149 = private unnamed_addr constant [6 x i8] c"query\00"
@.str150 = private unnamed_addr constant [2 x i8] c"(\00"
@.str151 = private unnamed_addr constant [2 x i8] c"(\00"
@.str152 = private unnamed_addr constant [2 x i8] c")\00"
@.str153 = private unnamed_addr constant [2 x i8] c",\00"
@.str154 = private unnamed_addr constant [2 x i8] c")\00"
@.str155 = private unnamed_addr constant [2 x i8] c"[\00"
@.str156 = private unnamed_addr constant [2 x i8] c"]\00"
@.str157 = private unnamed_addr constant [2 x i8] c"{\00"
@.str158 = private unnamed_addr constant [2 x i8] c"}\00"
@.str159 = private unnamed_addr constant [2 x i8] c",\00"
@.str160 = private unnamed_addr constant [2 x i8] c"]\00"
@.str161 = private unnamed_addr constant [6 x i8] c"where\00"
@.str162 = private unnamed_addr constant [2 x i8] c"(\00"
@.str163 = private unnamed_addr constant [2 x i8] c")\00"
@.str164 = private unnamed_addr constant [2 x i8] c",\00"
@.str165 = private unnamed_addr constant [2 x i8] c")\00"
@.str166 = private unnamed_addr constant [2 x i8] c"{\00"
@.str167 = private unnamed_addr constant [2 x i8] c"}\00"
@.str168 = private unnamed_addr constant [2 x i8] c",\00"
@.str169 = private unnamed_addr constant [2 x i8] c"}\00"
@.str170 = private unnamed_addr constant [2 x i8] c"{\00"
@.str171 = private unnamed_addr constant [2 x i8] c"}\00"
@.str172 = private unnamed_addr constant [2 x i8] c",\00"
@.str173 = private unnamed_addr constant [2 x i8] c"}\00"
@.str174 = private unnamed_addr constant [2 x i8] c"{\00"
@.str175 = private unnamed_addr constant [2 x i8] c"}\00"
@.str176 = private unnamed_addr constant [2 x i8] c",\00"
@.str177 = private unnamed_addr constant [2 x i8] c"}\00"
@.str178 = private unnamed_addr constant [2 x i8] c"(\00"
@.str179 = private unnamed_addr constant [2 x i8] c")\00"
@.str180 = private unnamed_addr constant [2 x i8] c":\00"
@.str181 = private unnamed_addr constant [2 x i8] c",\00"
@.str182 = private unnamed_addr constant [2 x i8] c")\00"
@.str183 = private unnamed_addr constant [5 x i8] c"void\00"
@.str184 = private unnamed_addr constant [3 x i8] c"->\00"
@.str185 = private unnamed_addr constant [2 x i8] c"=\00"
@.str186 = private unnamed_addr constant [2 x i8] c":\00"
@.str187 = private unnamed_addr constant [2 x i8] c":\00"
@.str188 = private unnamed_addr constant [2 x i8] c"{\00"
@.str189 = private unnamed_addr constant [2 x i8] c"}\00"
@.str190 = private unnamed_addr constant [2 x i8] c"}\00"
@.str191 = private unnamed_addr constant [2 x i8] c"{\00"
@.str192 = private unnamed_addr constant [2 x i8] c"}\00"
@.str193 = private unnamed_addr constant [3 x i8] c"%t\00"
@.str194 = private unnamed_addr constant [3 x i8] c"  \00"
@.str195 = private unnamed_addr constant [11 x i8] c" = alloca \00"
@.str196 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str197 = private unnamed_addr constant [3 x i8] c"%t\00"
@.str198 = private unnamed_addr constant [4 x i8] c"int\00"
@.str199 = private unnamed_addr constant [5 x i8] c"bool\00"
@.str200 = private unnamed_addr constant [6 x i8] c"fixed\00"
@.str201 = private unnamed_addr constant [4 x i8] c"i32\00"
@.str202 = private unnamed_addr constant [5 x i8] c"void\00"
@.str203 = private unnamed_addr constant [5 x i8] c"void\00"
@.str204 = private unnamed_addr constant [4 x i8] c"ptr\00"
@.str205 = private unnamed_addr constant [6 x i8] c"%Str_\00"
@.str206 = private unnamed_addr constant [6 x i8] c"%Cmp_\00"
@.str207 = private unnamed_addr constant [4 x i8] c"int\00"
@.str208 = private unnamed_addr constant [6 x i8] c"@.str\00"
@.str209 = private unnamed_addr constant [35 x i8] c" = private unnamed_addr constant [\00"
@.str210 = private unnamed_addr constant [10 x i8] c" x i8] c\22\00"
@.str211 = private unnamed_addr constant [6 x i8] c"\5C00\22\0A\00"
@.str212 = private unnamed_addr constant [3 x i8] c"  \00"
@.str213 = private unnamed_addr constant [35 x i8] c" = getelementptr inbounds i8, ptr \00"
@.str214 = private unnamed_addr constant [7 x i8] c", i32 \00"
@.str215 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str216 = private unnamed_addr constant [4 x i8] c"ptr\00"
@.str217 = private unnamed_addr constant [5 x i8] c"null\00"
@.str218 = private unnamed_addr constant [2 x i8] c"0\00"
@.str219 = private unnamed_addr constant [2 x i8] c"-\00"
@.str220 = private unnamed_addr constant [2 x i8] c"-\00"
@.str221 = private unnamed_addr constant [4 x i8] c"ptr\00"
@.str222 = private unnamed_addr constant [5 x i8] c"null\00"
@.str223 = private unnamed_addr constant [2 x i8] c"0\00"
@.str224 = private unnamed_addr constant [34 x i8] c"; Ludic (self-hosted) -> LLVM IR\0A\00"
@.str225 = private unnamed_addr constant [31 x i8] c"declare i32 @printf(ptr, ...)\0A\00"
@.str226 = private unnamed_addr constant [26 x i8] c"declare ptr @malloc(i64)\0A\00"
@.str227 = private unnamed_addr constant [32 x i8] c"declare ptr @realloc(ptr, i64)\0A\00"
@.str228 = private unnamed_addr constant [25 x i8] c"declare void @free(ptr)\0A\00"
@.str229 = private unnamed_addr constant [30 x i8] c"declare ptr @fopen(ptr, ptr)\0A\00"
@.str230 = private unnamed_addr constant [40 x i8] c"declare i64 @fread(ptr, i64, i64, ptr)\0A\00"
@.str231 = private unnamed_addr constant [41 x i8] c"declare i64 @fwrite(ptr, i64, i64, ptr)\0A\00"
@.str232 = private unnamed_addr constant [35 x i8] c"declare i32 @fseek(ptr, i64, i32)\0A\00"
@.str233 = private unnamed_addr constant [25 x i8] c"declare i64 @ftell(ptr)\0A\00"
@.str234 = private unnamed_addr constant [26 x i8] c"declare i32 @fclose(ptr)\0A\00"
@.str235 = private unnamed_addr constant [25 x i8] c"declare void @exit(i32)\0A\00"
@.str236 = private unnamed_addr constant [26 x i8] c"declare i32 @system(ptr)\0A\00"
@.str237 = private unnamed_addr constant [26 x i8] c"declare ptr @getenv(ptr)\0A\00"
@.str238 = private unnamed_addr constant [36 x i8] c"declare ptr @memcpy(ptr, ptr, i64)\0A\00"
@.str239 = private unnamed_addr constant [36 x i8] c"declare ptr @memset(ptr, i32, i64)\0A\00"
@.str240 = private unnamed_addr constant [26 x i8] c"declare i64 @strlen(ptr)\0A\00"
@.str241 = private unnamed_addr constant [24 x i8] c"declare i32 @getchar()\0A\00"
@.str242 = private unnamed_addr constant [27 x i8] c"declare i32 @putchar(i32)\0A\00"
@.str243 = private unnamed_addr constant [24 x i8] c"declare i64 @time(ptr)\0A\00"
@.str244 = private unnamed_addr constant [44 x i8] c"declare void @win_open(i32, i32, i32, ptr)\0A\00"
@.str245 = private unnamed_addr constant [25 x i8] c"declare i32 @win_poll()\0A\00"
@.str246 = private unnamed_addr constant [42 x i8] c"declare void @win_present(ptr, i32, i32)\0A\00"
@.str247 = private unnamed_addr constant [28 x i8] c"declare i32 @win_running()\0A\00"
@.str248 = private unnamed_addr constant [27 x i8] c"declare void @win_close()\0A\00"
@.str249 = private unnamed_addr constant [34 x i8] c"@__stderrp = external global ptr\0A\00"
@.str250 = private unnamed_addr constant [61 x i8] c"@.fmt_str = private unnamed_addr constant [3 x i8] c\22%s\5C00\22\0A\00"
@.str251 = private unnamed_addr constant [64 x i8] c"@.fmt_int = private unnamed_addr constant [4 x i8] c\22%d\5C0A\5C00\22\0A\00"
@.str252 = private unnamed_addr constant [33 x i8] c"@L_argc = internal global i32 0\0A\00"
@.str253 = private unnamed_addr constant [36 x i8] c"@L_argv = internal global ptr null\0A\00"
@.str254 = private unnamed_addr constant [46 x i8] c"@.gametitle = private unnamed_addr constant [\00"
@.str255 = private unnamed_addr constant [10 x i8] c" x i8] c\22\00"
@.str256 = private unnamed_addr constant [6 x i8] c"\5C00\22\0A\00"
@.str257 = private unnamed_addr constant [34 x i8] c"%LSlice = type { ptr, i32, i32 }\0A\00"
@.str258 = private unnamed_addr constant [6 x i8] c"%Str_\00"
@.str259 = private unnamed_addr constant [11 x i8] c" = type { \00"
@.str260 = private unnamed_addr constant [4 x i8] c"i32\00"
@.str261 = private unnamed_addr constant [3 x i8] c", \00"
@.str262 = private unnamed_addr constant [4 x i8] c" }\0A\00"
@.str263 = private unnamed_addr constant [4 x i8] c"@g_\00"
@.str264 = private unnamed_addr constant [20 x i8] c" = internal global \00"
@.str265 = private unnamed_addr constant [2 x i8] c" \00"
@.str266 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str267 = private unnamed_addr constant [32 x i8] c"member access on non-aggregate \00"
@.str268 = private unnamed_addr constant [15 x i8] c"no such field \00"
@.str269 = private unnamed_addr constant [3 x i8] c"  \00"
@.str270 = private unnamed_addr constant [27 x i8] c" = getelementptr inbounds \00"
@.str271 = private unnamed_addr constant [7 x i8] c", ptr \00"
@.str272 = private unnamed_addr constant [14 x i8] c", i32 0, i32 \00"
@.str273 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str274 = private unnamed_addr constant [21 x i8] c"indexing a non-slice\00"
@.str275 = private unnamed_addr constant [3 x i8] c"  \00"
@.str276 = private unnamed_addr constant [40 x i8] c" = getelementptr inbounds %LSlice, ptr \00"
@.str277 = private unnamed_addr constant [16 x i8] c", i32 0, i32 0\0A\00"
@.str278 = private unnamed_addr constant [3 x i8] c"  \00"
@.str279 = private unnamed_addr constant [18 x i8] c" = load ptr, ptr \00"
@.str280 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str281 = private unnamed_addr constant [3 x i8] c"  \00"
@.str282 = private unnamed_addr constant [27 x i8] c" = getelementptr inbounds \00"
@.str283 = private unnamed_addr constant [7 x i8] c", ptr \00"
@.str284 = private unnamed_addr constant [7 x i8] c", i32 \00"
@.str285 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str286 = private unnamed_addr constant [9 x i8] c"ptr_null\00"
@.str287 = private unnamed_addr constant [10 x i8] c"mem_alloc\00"
@.str288 = private unnamed_addr constant [12 x i8] c"mem_realloc\00"
@.str289 = private unnamed_addr constant [6 x i8] c"peek8\00"
@.str290 = private unnamed_addr constant [6 x i8] c"poke8\00"
@.str291 = private unnamed_addr constant [12 x i8] c"ptr_is_null\00"
@.str292 = private unnamed_addr constant [10 x i8] c"file_open\00"
@.str293 = private unnamed_addr constant [10 x i8] c"file_read\00"
@.str294 = private unnamed_addr constant [11 x i8] c"file_write\00"
@.str295 = private unnamed_addr constant [10 x i8] c"file_seek\00"
@.str296 = private unnamed_addr constant [10 x i8] c"file_tell\00"
@.str297 = private unnamed_addr constant [11 x i8] c"file_close\00"
@.str298 = private unnamed_addr constant [10 x i8] c"print_str\00"
@.str299 = private unnamed_addr constant [10 x i8] c"print_int\00"
@.str300 = private unnamed_addr constant [8 x i8] c"os_argc\00"
@.str301 = private unnamed_addr constant [7 x i8] c"os_arg\00"
@.str302 = private unnamed_addr constant [8 x i8] c"os_exit\00"
@.str303 = private unnamed_addr constant [12 x i8] c"file_stderr\00"
@.str304 = private unnamed_addr constant [10 x i8] c"os_system\00"
@.str305 = private unnamed_addr constant [10 x i8] c"os_getenv\00"
@.str306 = private unnamed_addr constant [4 x i8] c"shl\00"
@.str307 = private unnamed_addr constant [4 x i8] c"shr\00"
@.str308 = private unnamed_addr constant [5 x i8] c"band\00"
@.str309 = private unnamed_addr constant [4 x i8] c"bor\00"
@.str310 = private unnamed_addr constant [5 x i8] c"bxor\00"
@.str311 = private unnamed_addr constant [5 x i8] c"bnot\00"
@.str312 = private unnamed_addr constant [7 x i8] c"peek32\00"
@.str313 = private unnamed_addr constant [7 x i8] c"poke32\00"
@.str314 = private unnamed_addr constant [3 x i8] c"  \00"
@.str315 = private unnamed_addr constant [4 x i8] c" = \00"
@.str316 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str317 = private unnamed_addr constant [9 x i8] c"ptr_null\00"
@.str318 = private unnamed_addr constant [5 x i8] c"null\00"
@.str319 = private unnamed_addr constant [4 x i8] c"ptr\00"
@.str320 = private unnamed_addr constant [10 x i8] c"mem_alloc\00"
@.str321 = private unnamed_addr constant [10 x i8] c"zext i32 \00"
@.str322 = private unnamed_addr constant [8 x i8] c" to i64\00"
@.str323 = private unnamed_addr constant [22 x i8] c"call ptr @malloc(i64 \00"
@.str324 = private unnamed_addr constant [2 x i8] c")\00"
@.str325 = private unnamed_addr constant [4 x i8] c"ptr\00"
@.str326 = private unnamed_addr constant [12 x i8] c"mem_realloc\00"
@.str327 = private unnamed_addr constant [10 x i8] c"zext i32 \00"
@.str328 = private unnamed_addr constant [8 x i8] c" to i64\00"
@.str329 = private unnamed_addr constant [23 x i8] c"call ptr @realloc(ptr \00"
@.str330 = private unnamed_addr constant [7 x i8] c", i64 \00"
@.str331 = private unnamed_addr constant [2 x i8] c")\00"
@.str332 = private unnamed_addr constant [4 x i8] c"ptr\00"
@.str333 = private unnamed_addr constant [6 x i8] c"peek8\00"
@.str334 = private unnamed_addr constant [14 x i8] c"load i8, ptr \00"
@.str335 = private unnamed_addr constant [9 x i8] c"zext i8 \00"
@.str336 = private unnamed_addr constant [8 x i8] c" to i32\00"
@.str337 = private unnamed_addr constant [4 x i8] c"int\00"
@.str338 = private unnamed_addr constant [6 x i8] c"poke8\00"
@.str339 = private unnamed_addr constant [11 x i8] c"trunc i32 \00"
@.str340 = private unnamed_addr constant [7 x i8] c" to i8\00"
@.str341 = private unnamed_addr constant [12 x i8] c"  store i8 \00"
@.str342 = private unnamed_addr constant [7 x i8] c", ptr \00"
@.str343 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str344 = private unnamed_addr constant [2 x i8] c"0\00"
@.str345 = private unnamed_addr constant [5 x i8] c"void\00"
@.str346 = private unnamed_addr constant [12 x i8] c"ptr_is_null\00"
@.str347 = private unnamed_addr constant [13 x i8] c"icmp eq ptr \00"
@.str348 = private unnamed_addr constant [7 x i8] c", null\00"
@.str349 = private unnamed_addr constant [9 x i8] c"zext i1 \00"
@.str350 = private unnamed_addr constant [8 x i8] c" to i32\00"
@.str351 = private unnamed_addr constant [5 x i8] c"bool\00"
@.str352 = private unnamed_addr constant [10 x i8] c"file_open\00"
@.str353 = private unnamed_addr constant [21 x i8] c"call ptr @fopen(ptr \00"
@.str354 = private unnamed_addr constant [7 x i8] c", ptr \00"
@.str355 = private unnamed_addr constant [2 x i8] c")\00"
@.str356 = private unnamed_addr constant [4 x i8] c"ptr\00"
@.str357 = private unnamed_addr constant [10 x i8] c"file_read\00"
@.str358 = private unnamed_addr constant [11 x i8] c"file_write\00"
@.str359 = private unnamed_addr constant [10 x i8] c"zext i32 \00"
@.str360 = private unnamed_addr constant [8 x i8] c" to i64\00"
@.str361 = private unnamed_addr constant [7 x i8] c"@fread\00"
@.str362 = private unnamed_addr constant [11 x i8] c"file_write\00"
@.str363 = private unnamed_addr constant [8 x i8] c"@fwrite\00"
@.str364 = private unnamed_addr constant [10 x i8] c"call i64 \00"
@.str365 = private unnamed_addr constant [6 x i8] c"(ptr \00"
@.str366 = private unnamed_addr constant [14 x i8] c", i64 1, i64 \00"
@.str367 = private unnamed_addr constant [7 x i8] c", ptr \00"
@.str368 = private unnamed_addr constant [2 x i8] c")\00"
@.str369 = private unnamed_addr constant [11 x i8] c"trunc i64 \00"
@.str370 = private unnamed_addr constant [8 x i8] c" to i32\00"
@.str371 = private unnamed_addr constant [4 x i8] c"int\00"
@.str372 = private unnamed_addr constant [10 x i8] c"file_seek\00"
@.str373 = private unnamed_addr constant [10 x i8] c"sext i32 \00"
@.str374 = private unnamed_addr constant [8 x i8] c" to i64\00"
@.str375 = private unnamed_addr constant [21 x i8] c"call i32 @fseek(ptr \00"
@.str376 = private unnamed_addr constant [7 x i8] c", i64 \00"
@.str377 = private unnamed_addr constant [7 x i8] c", i32 \00"
@.str378 = private unnamed_addr constant [2 x i8] c")\00"
@.str379 = private unnamed_addr constant [4 x i8] c"int\00"
@.str380 = private unnamed_addr constant [10 x i8] c"file_tell\00"
@.str381 = private unnamed_addr constant [21 x i8] c"call i64 @ftell(ptr \00"
@.str382 = private unnamed_addr constant [2 x i8] c")\00"
@.str383 = private unnamed_addr constant [11 x i8] c"trunc i64 \00"
@.str384 = private unnamed_addr constant [8 x i8] c" to i32\00"
@.str385 = private unnamed_addr constant [4 x i8] c"int\00"
@.str386 = private unnamed_addr constant [11 x i8] c"file_close\00"
@.str387 = private unnamed_addr constant [24 x i8] c"  call i32 @fclose(ptr \00"
@.str388 = private unnamed_addr constant [3 x i8] c")\0A\00"
@.str389 = private unnamed_addr constant [2 x i8] c"0\00"
@.str390 = private unnamed_addr constant [5 x i8] c"void\00"
@.str391 = private unnamed_addr constant [10 x i8] c"print_str\00"
@.str392 = private unnamed_addr constant [50 x i8] c"  call i32 (ptr, ...) @printf(ptr @.fmt_str, ptr \00"
@.str393 = private unnamed_addr constant [3 x i8] c")\0A\00"
@.str394 = private unnamed_addr constant [2 x i8] c"0\00"
@.str395 = private unnamed_addr constant [5 x i8] c"void\00"
@.str396 = private unnamed_addr constant [10 x i8] c"print_int\00"
@.str397 = private unnamed_addr constant [50 x i8] c"  call i32 (ptr, ...) @printf(ptr @.fmt_int, i32 \00"
@.str398 = private unnamed_addr constant [3 x i8] c")\0A\00"
@.str399 = private unnamed_addr constant [2 x i8] c"0\00"
@.str400 = private unnamed_addr constant [5 x i8] c"void\00"
@.str401 = private unnamed_addr constant [8 x i8] c"os_argc\00"
@.str402 = private unnamed_addr constant [22 x i8] c"load i32, ptr @L_argc\00"
@.str403 = private unnamed_addr constant [4 x i8] c"int\00"
@.str404 = private unnamed_addr constant [7 x i8] c"os_arg\00"
@.str405 = private unnamed_addr constant [22 x i8] c"load ptr, ptr @L_argv\00"
@.str406 = private unnamed_addr constant [24 x i8] c"getelementptr ptr, ptr \00"
@.str407 = private unnamed_addr constant [7 x i8] c", i32 \00"
@.str408 = private unnamed_addr constant [15 x i8] c"load ptr, ptr \00"
@.str409 = private unnamed_addr constant [4 x i8] c"str\00"
@.str410 = private unnamed_addr constant [8 x i8] c"os_exit\00"
@.str411 = private unnamed_addr constant [23 x i8] c"  call void @exit(i32 \00"
@.str412 = private unnamed_addr constant [3 x i8] c")\0A\00"
@.str413 = private unnamed_addr constant [15 x i8] c"  unreachable\0A\00"
@.str414 = private unnamed_addr constant [2 x i8] c"0\00"
@.str415 = private unnamed_addr constant [5 x i8] c"void\00"
@.str416 = private unnamed_addr constant [12 x i8] c"file_stderr\00"
@.str417 = private unnamed_addr constant [25 x i8] c"load ptr, ptr @__stderrp\00"
@.str418 = private unnamed_addr constant [4 x i8] c"ptr\00"
@.str419 = private unnamed_addr constant [10 x i8] c"os_system\00"
@.str420 = private unnamed_addr constant [22 x i8] c"call i32 @system(ptr \00"
@.str421 = private unnamed_addr constant [2 x i8] c")\00"
@.str422 = private unnamed_addr constant [4 x i8] c"int\00"
@.str423 = private unnamed_addr constant [10 x i8] c"os_getenv\00"
@.str424 = private unnamed_addr constant [22 x i8] c"call ptr @getenv(ptr \00"
@.str425 = private unnamed_addr constant [2 x i8] c")\00"
@.str426 = private unnamed_addr constant [4 x i8] c"str\00"
@.str427 = private unnamed_addr constant [5 x i8] c"bnot\00"
@.str428 = private unnamed_addr constant [9 x i8] c"xor i32 \00"
@.str429 = private unnamed_addr constant [5 x i8] c", -1\00"
@.str430 = private unnamed_addr constant [4 x i8] c"int\00"
@.str431 = private unnamed_addr constant [4 x i8] c"shl\00"
@.str432 = private unnamed_addr constant [4 x i8] c"shr\00"
@.str433 = private unnamed_addr constant [5 x i8] c"band\00"
@.str434 = private unnamed_addr constant [4 x i8] c"bor\00"
@.str435 = private unnamed_addr constant [5 x i8] c"bxor\00"
@.str436 = private unnamed_addr constant [4 x i8] c"shl\00"
@.str437 = private unnamed_addr constant [4 x i8] c"shr\00"
@.str438 = private unnamed_addr constant [5 x i8] c"lshr\00"
@.str439 = private unnamed_addr constant [5 x i8] c"band\00"
@.str440 = private unnamed_addr constant [4 x i8] c"and\00"
@.str441 = private unnamed_addr constant [4 x i8] c"bor\00"
@.str442 = private unnamed_addr constant [3 x i8] c"or\00"
@.str443 = private unnamed_addr constant [5 x i8] c"bxor\00"
@.str444 = private unnamed_addr constant [4 x i8] c"xor\00"
@.str445 = private unnamed_addr constant [6 x i8] c" i32 \00"
@.str446 = private unnamed_addr constant [3 x i8] c", \00"
@.str447 = private unnamed_addr constant [4 x i8] c"int\00"
@.str448 = private unnamed_addr constant [7 x i8] c"peek32\00"
@.str449 = private unnamed_addr constant [3 x i8] c"  \00"
@.str450 = private unnamed_addr constant [36 x i8] c" = getelementptr inbounds i32, ptr \00"
@.str451 = private unnamed_addr constant [7 x i8] c", i32 \00"
@.str452 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str453 = private unnamed_addr constant [15 x i8] c"load i32, ptr \00"
@.str454 = private unnamed_addr constant [4 x i8] c"int\00"
@.str455 = private unnamed_addr constant [7 x i8] c"poke32\00"
@.str456 = private unnamed_addr constant [3 x i8] c"  \00"
@.str457 = private unnamed_addr constant [36 x i8] c" = getelementptr inbounds i32, ptr \00"
@.str458 = private unnamed_addr constant [7 x i8] c", i32 \00"
@.str459 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str460 = private unnamed_addr constant [13 x i8] c"  store i32 \00"
@.str461 = private unnamed_addr constant [7 x i8] c", ptr \00"
@.str462 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str463 = private unnamed_addr constant [2 x i8] c"0\00"
@.str464 = private unnamed_addr constant [5 x i8] c"void\00"
@.str465 = private unnamed_addr constant [2 x i8] c"0\00"
@.str466 = private unnamed_addr constant [5 x i8] c"void\00"
@.str467 = private unnamed_addr constant [9 x i8] c"mem_free\00"
@.str468 = private unnamed_addr constant [9 x i8] c"mem_copy\00"
@.str469 = private unnamed_addr constant [8 x i8] c"mem_set\00"
@.str470 = private unnamed_addr constant [8 x i8] c"ptr_add\00"
@.str471 = private unnamed_addr constant [10 x i8] c"read_byte\00"
@.str472 = private unnamed_addr constant [11 x i8] c"write_byte\00"
@.str473 = private unnamed_addr constant [8 x i8] c"str_len\00"
@.str474 = private unnamed_addr constant [8 x i8] c"os_time\00"
@.str475 = private unnamed_addr constant [6 x i8] c"peekf\00"
@.str476 = private unnamed_addr constant [6 x i8] c"pokef\00"
@.str477 = private unnamed_addr constant [9 x i8] c"as_fixed\00"
@.str478 = private unnamed_addr constant [7 x i8] c"as_int\00"
@.str479 = private unnamed_addr constant [6 x i8] c"peekp\00"
@.str480 = private unnamed_addr constant [6 x i8] c"pokep\00"
@.str481 = private unnamed_addr constant [12 x i8] c"is_windowed\00"
@.str482 = private unnamed_addr constant [11 x i8] c"game_title\00"
@.str483 = private unnamed_addr constant [9 x i8] c"win_open\00"
@.str484 = private unnamed_addr constant [9 x i8] c"win_poll\00"
@.str485 = private unnamed_addr constant [12 x i8] c"win_present\00"
@.str486 = private unnamed_addr constant [12 x i8] c"win_running\00"
@.str487 = private unnamed_addr constant [10 x i8] c"win_close\00"
@.str488 = private unnamed_addr constant [9 x i8] c"mem_free\00"
@.str489 = private unnamed_addr constant [23 x i8] c"  call void @free(ptr \00"
@.str490 = private unnamed_addr constant [3 x i8] c")\0A\00"
@.str491 = private unnamed_addr constant [2 x i8] c"0\00"
@.str492 = private unnamed_addr constant [5 x i8] c"void\00"
@.str493 = private unnamed_addr constant [9 x i8] c"mem_copy\00"
@.str494 = private unnamed_addr constant [10 x i8] c"zext i32 \00"
@.str495 = private unnamed_addr constant [8 x i8] c" to i64\00"
@.str496 = private unnamed_addr constant [24 x i8] c"  call ptr @memcpy(ptr \00"
@.str497 = private unnamed_addr constant [7 x i8] c", ptr \00"
@.str498 = private unnamed_addr constant [7 x i8] c", i64 \00"
@.str499 = private unnamed_addr constant [3 x i8] c")\0A\00"
@.str500 = private unnamed_addr constant [2 x i8] c"0\00"
@.str501 = private unnamed_addr constant [5 x i8] c"void\00"
@.str502 = private unnamed_addr constant [8 x i8] c"mem_set\00"
@.str503 = private unnamed_addr constant [10 x i8] c"zext i32 \00"
@.str504 = private unnamed_addr constant [8 x i8] c" to i64\00"
@.str505 = private unnamed_addr constant [24 x i8] c"  call ptr @memset(ptr \00"
@.str506 = private unnamed_addr constant [7 x i8] c", i32 \00"
@.str507 = private unnamed_addr constant [7 x i8] c", i64 \00"
@.str508 = private unnamed_addr constant [3 x i8] c")\0A\00"
@.str509 = private unnamed_addr constant [2 x i8] c"0\00"
@.str510 = private unnamed_addr constant [5 x i8] c"void\00"
@.str511 = private unnamed_addr constant [8 x i8] c"ptr_add\00"
@.str512 = private unnamed_addr constant [3 x i8] c"  \00"
@.str513 = private unnamed_addr constant [35 x i8] c" = getelementptr inbounds i8, ptr \00"
@.str514 = private unnamed_addr constant [7 x i8] c", i32 \00"
@.str515 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str516 = private unnamed_addr constant [4 x i8] c"ptr\00"
@.str517 = private unnamed_addr constant [10 x i8] c"read_byte\00"
@.str518 = private unnamed_addr constant [20 x i8] c"call i32 @getchar()\00"
@.str519 = private unnamed_addr constant [4 x i8] c"int\00"
@.str520 = private unnamed_addr constant [11 x i8] c"write_byte\00"
@.str521 = private unnamed_addr constant [25 x i8] c"  call i32 @putchar(i32 \00"
@.str522 = private unnamed_addr constant [3 x i8] c")\0A\00"
@.str523 = private unnamed_addr constant [2 x i8] c"0\00"
@.str524 = private unnamed_addr constant [5 x i8] c"void\00"
@.str525 = private unnamed_addr constant [8 x i8] c"str_len\00"
@.str526 = private unnamed_addr constant [22 x i8] c"call i64 @strlen(ptr \00"
@.str527 = private unnamed_addr constant [2 x i8] c")\00"
@.str528 = private unnamed_addr constant [11 x i8] c"trunc i64 \00"
@.str529 = private unnamed_addr constant [8 x i8] c" to i32\00"
@.str530 = private unnamed_addr constant [4 x i8] c"int\00"
@.str531 = private unnamed_addr constant [8 x i8] c"os_time\00"
@.str532 = private unnamed_addr constant [25 x i8] c"call i64 @time(ptr null)\00"
@.str533 = private unnamed_addr constant [11 x i8] c"trunc i64 \00"
@.str534 = private unnamed_addr constant [8 x i8] c" to i32\00"
@.str535 = private unnamed_addr constant [4 x i8] c"int\00"
@.str536 = private unnamed_addr constant [6 x i8] c"peekf\00"
@.str537 = private unnamed_addr constant [3 x i8] c"  \00"
@.str538 = private unnamed_addr constant [36 x i8] c" = getelementptr inbounds i32, ptr \00"
@.str539 = private unnamed_addr constant [7 x i8] c", i32 \00"
@.str540 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str541 = private unnamed_addr constant [15 x i8] c"load i32, ptr \00"
@.str542 = private unnamed_addr constant [6 x i8] c"fixed\00"
@.str543 = private unnamed_addr constant [6 x i8] c"pokef\00"
@.str544 = private unnamed_addr constant [3 x i8] c"  \00"
@.str545 = private unnamed_addr constant [36 x i8] c" = getelementptr inbounds i32, ptr \00"
@.str546 = private unnamed_addr constant [7 x i8] c", i32 \00"
@.str547 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str548 = private unnamed_addr constant [13 x i8] c"  store i32 \00"
@.str549 = private unnamed_addr constant [7 x i8] c", ptr \00"
@.str550 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str551 = private unnamed_addr constant [2 x i8] c"0\00"
@.str552 = private unnamed_addr constant [5 x i8] c"void\00"
@.str553 = private unnamed_addr constant [6 x i8] c"peekp\00"
@.str554 = private unnamed_addr constant [3 x i8] c"  \00"
@.str555 = private unnamed_addr constant [36 x i8] c" = getelementptr inbounds ptr, ptr \00"
@.str556 = private unnamed_addr constant [7 x i8] c", i32 \00"
@.str557 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str558 = private unnamed_addr constant [15 x i8] c"load ptr, ptr \00"
@.str559 = private unnamed_addr constant [4 x i8] c"ptr\00"
@.str560 = private unnamed_addr constant [6 x i8] c"pokep\00"
@.str561 = private unnamed_addr constant [3 x i8] c"  \00"
@.str562 = private unnamed_addr constant [36 x i8] c" = getelementptr inbounds ptr, ptr \00"
@.str563 = private unnamed_addr constant [7 x i8] c", i32 \00"
@.str564 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str565 = private unnamed_addr constant [13 x i8] c"  store ptr \00"
@.str566 = private unnamed_addr constant [7 x i8] c", ptr \00"
@.str567 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str568 = private unnamed_addr constant [2 x i8] c"0\00"
@.str569 = private unnamed_addr constant [5 x i8] c"void\00"
@.str570 = private unnamed_addr constant [9 x i8] c"as_fixed\00"
@.str571 = private unnamed_addr constant [6 x i8] c"fixed\00"
@.str572 = private unnamed_addr constant [7 x i8] c"as_int\00"
@.str573 = private unnamed_addr constant [4 x i8] c"int\00"
@.str574 = private unnamed_addr constant [12 x i8] c"is_windowed\00"
@.str575 = private unnamed_addr constant [2 x i8] c"1\00"
@.str576 = private unnamed_addr constant [5 x i8] c"bool\00"
@.str577 = private unnamed_addr constant [2 x i8] c"0\00"
@.str578 = private unnamed_addr constant [5 x i8] c"bool\00"
@.str579 = private unnamed_addr constant [11 x i8] c"game_title\00"
@.str580 = private unnamed_addr constant [12 x i8] c"@.gametitle\00"
@.str581 = private unnamed_addr constant [4 x i8] c"str\00"
@.str582 = private unnamed_addr constant [9 x i8] c"win_poll\00"
@.str583 = private unnamed_addr constant [21 x i8] c"call i32 @win_poll()\00"
@.str584 = private unnamed_addr constant [4 x i8] c"int\00"
@.str585 = private unnamed_addr constant [12 x i8] c"win_running\00"
@.str586 = private unnamed_addr constant [24 x i8] c"call i32 @win_running()\00"
@.str587 = private unnamed_addr constant [5 x i8] c"bool\00"
@.str588 = private unnamed_addr constant [9 x i8] c"win_open\00"
@.str589 = private unnamed_addr constant [27 x i8] c"  call void @win_open(i32 \00"
@.str590 = private unnamed_addr constant [7 x i8] c", i32 \00"
@.str591 = private unnamed_addr constant [7 x i8] c", i32 \00"
@.str592 = private unnamed_addr constant [7 x i8] c", ptr \00"
@.str593 = private unnamed_addr constant [3 x i8] c")\0A\00"
@.str594 = private unnamed_addr constant [2 x i8] c"0\00"
@.str595 = private unnamed_addr constant [5 x i8] c"void\00"
@.str596 = private unnamed_addr constant [12 x i8] c"win_present\00"
@.str597 = private unnamed_addr constant [30 x i8] c"  call void @win_present(ptr \00"
@.str598 = private unnamed_addr constant [7 x i8] c", i32 \00"
@.str599 = private unnamed_addr constant [7 x i8] c", i32 \00"
@.str600 = private unnamed_addr constant [3 x i8] c")\0A\00"
@.str601 = private unnamed_addr constant [2 x i8] c"0\00"
@.str602 = private unnamed_addr constant [5 x i8] c"void\00"
@.str603 = private unnamed_addr constant [10 x i8] c"win_close\00"
@.str604 = private unnamed_addr constant [26 x i8] c"  call void @win_close()\0A\00"
@.str605 = private unnamed_addr constant [2 x i8] c"0\00"
@.str606 = private unnamed_addr constant [5 x i8] c"void\00"
@.str607 = private unnamed_addr constant [2 x i8] c"0\00"
@.str608 = private unnamed_addr constant [5 x i8] c"void\00"
@.str609 = private unnamed_addr constant [4 x i8] c"min\00"
@.str610 = private unnamed_addr constant [4 x i8] c"max\00"
@.str611 = private unnamed_addr constant [4 x i8] c"abs\00"
@.str612 = private unnamed_addr constant [6 x i8] c"clamp\00"
@.str613 = private unnamed_addr constant [4 x i8] c"abs\00"
@.str614 = private unnamed_addr constant [14 x i8] c"icmp slt i32 \00"
@.str615 = private unnamed_addr constant [4 x i8] c", 0\00"
@.str616 = private unnamed_addr constant [12 x i8] c"sub i32 0, \00"
@.str617 = private unnamed_addr constant [11 x i8] c"select i1 \00"
@.str618 = private unnamed_addr constant [7 x i8] c", i32 \00"
@.str619 = private unnamed_addr constant [7 x i8] c", i32 \00"
@.str620 = private unnamed_addr constant [4 x i8] c"int\00"
@.str621 = private unnamed_addr constant [4 x i8] c"min\00"
@.str622 = private unnamed_addr constant [4 x i8] c"max\00"
@.str623 = private unnamed_addr constant [4 x i8] c"slt\00"
@.str624 = private unnamed_addr constant [4 x i8] c"max\00"
@.str625 = private unnamed_addr constant [4 x i8] c"sgt\00"
@.str626 = private unnamed_addr constant [6 x i8] c"icmp \00"
@.str627 = private unnamed_addr constant [6 x i8] c" i32 \00"
@.str628 = private unnamed_addr constant [3 x i8] c", \00"
@.str629 = private unnamed_addr constant [11 x i8] c"select i1 \00"
@.str630 = private unnamed_addr constant [7 x i8] c", i32 \00"
@.str631 = private unnamed_addr constant [7 x i8] c", i32 \00"
@.str632 = private unnamed_addr constant [4 x i8] c"int\00"
@.str633 = private unnamed_addr constant [14 x i8] c"icmp slt i32 \00"
@.str634 = private unnamed_addr constant [3 x i8] c", \00"
@.str635 = private unnamed_addr constant [11 x i8] c"select i1 \00"
@.str636 = private unnamed_addr constant [7 x i8] c", i32 \00"
@.str637 = private unnamed_addr constant [7 x i8] c", i32 \00"
@.str638 = private unnamed_addr constant [14 x i8] c"icmp sgt i32 \00"
@.str639 = private unnamed_addr constant [3 x i8] c", \00"
@.str640 = private unnamed_addr constant [11 x i8] c"select i1 \00"
@.str641 = private unnamed_addr constant [7 x i8] c", i32 \00"
@.str642 = private unnamed_addr constant [7 x i8] c", i32 \00"
@.str643 = private unnamed_addr constant [4 x i8] c"int\00"
@.str644 = private unnamed_addr constant [15 x i8] c"getelementptr \00"
@.str645 = private unnamed_addr constant [18 x i8] c", ptr null, i32 1\00"
@.str646 = private unnamed_addr constant [14 x i8] c"ptrtoint ptr \00"
@.str647 = private unnamed_addr constant [8 x i8] c" to i64\00"
@.str648 = private unnamed_addr constant [22 x i8] c"unknown struct in new\00"
@.str649 = private unnamed_addr constant [6 x i8] c"%Str_\00"
@.str650 = private unnamed_addr constant [22 x i8] c"call ptr @malloc(i64 \00"
@.str651 = private unnamed_addr constant [2 x i8] c")\00"
@.str652 = private unnamed_addr constant [3 x i8] c"  \00"
@.str653 = private unnamed_addr constant [32 x i8] c" = getelementptr inbounds %Str_\00"
@.str654 = private unnamed_addr constant [7 x i8] c", ptr \00"
@.str655 = private unnamed_addr constant [14 x i8] c", i32 0, i32 \00"
@.str656 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str657 = private unnamed_addr constant [2 x i8] c"0\00"
@.str658 = private unnamed_addr constant [4 x i8] c"ptr\00"
@.str659 = private unnamed_addr constant [5 x i8] c"null\00"
@.str660 = private unnamed_addr constant [9 x i8] c"  store \00"
@.str661 = private unnamed_addr constant [2 x i8] c" \00"
@.str662 = private unnamed_addr constant [7 x i8] c", ptr \00"
@.str663 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str664 = private unnamed_addr constant [8 x i8] c"%LSlice\00"
@.str665 = private unnamed_addr constant [22 x i8] c"call ptr @malloc(i64 \00"
@.str666 = private unnamed_addr constant [2 x i8] c")\00"
@.str667 = private unnamed_addr constant [3 x i8] c"  \00"
@.str668 = private unnamed_addr constant [40 x i8] c" = getelementptr inbounds %LSlice, ptr \00"
@.str669 = private unnamed_addr constant [16 x i8] c", i32 0, i32 0\0A\00"
@.str670 = private unnamed_addr constant [23 x i8] c"  store ptr null, ptr \00"
@.str671 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str672 = private unnamed_addr constant [3 x i8] c"  \00"
@.str673 = private unnamed_addr constant [40 x i8] c" = getelementptr inbounds %LSlice, ptr \00"
@.str674 = private unnamed_addr constant [16 x i8] c", i32 0, i32 1\0A\00"
@.str675 = private unnamed_addr constant [20 x i8] c"  store i32 0, ptr \00"
@.str676 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str677 = private unnamed_addr constant [3 x i8] c"  \00"
@.str678 = private unnamed_addr constant [40 x i8] c" = getelementptr inbounds %LSlice, ptr \00"
@.str679 = private unnamed_addr constant [16 x i8] c", i32 0, i32 2\0A\00"
@.str680 = private unnamed_addr constant [20 x i8] c"  store i32 0, ptr \00"
@.str681 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str682 = private unnamed_addr constant [3 x i8] c"  \00"
@.str683 = private unnamed_addr constant [40 x i8] c" = getelementptr inbounds %LSlice, ptr \00"
@.str684 = private unnamed_addr constant [14 x i8] c", i32 0, i32 \00"
@.str685 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str686 = private unnamed_addr constant [15 x i8] c"load i32, ptr \00"
@.str687 = private unnamed_addr constant [4 x i8] c"int\00"
@.str688 = private unnamed_addr constant [15 x i8] c"load i32, ptr \00"
@.str689 = private unnamed_addr constant [15 x i8] c"load i32, ptr \00"
@.str690 = private unnamed_addr constant [14 x i8] c"icmp sge i32 \00"
@.str691 = private unnamed_addr constant [3 x i8] c", \00"
@.str692 = private unnamed_addr constant [5 x i8] c"grow\00"
@.str693 = private unnamed_addr constant [4 x i8] c"put\00"
@.str694 = private unnamed_addr constant [9 x i8] c"  br i1 \00"
@.str695 = private unnamed_addr constant [10 x i8] c", label %\00"
@.str696 = private unnamed_addr constant [10 x i8] c", label %\00"
@.str697 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str698 = private unnamed_addr constant [3 x i8] c":\0A\00"
@.str699 = private unnamed_addr constant [9 x i8] c"mul i32 \00"
@.str700 = private unnamed_addr constant [4 x i8] c", 2\00"
@.str701 = private unnamed_addr constant [13 x i8] c"icmp eq i32 \00"
@.str702 = private unnamed_addr constant [4 x i8] c", 0\00"
@.str703 = private unnamed_addr constant [11 x i8] c"select i1 \00"
@.str704 = private unnamed_addr constant [14 x i8] c", i32 8, i32 \00"
@.str705 = private unnamed_addr constant [10 x i8] c"zext i32 \00"
@.str706 = private unnamed_addr constant [8 x i8] c" to i64\00"
@.str707 = private unnamed_addr constant [9 x i8] c"mul i64 \00"
@.str708 = private unnamed_addr constant [3 x i8] c", \00"
@.str709 = private unnamed_addr constant [15 x i8] c"load ptr, ptr \00"
@.str710 = private unnamed_addr constant [23 x i8] c"call ptr @realloc(ptr \00"
@.str711 = private unnamed_addr constant [7 x i8] c", i64 \00"
@.str712 = private unnamed_addr constant [2 x i8] c")\00"
@.str713 = private unnamed_addr constant [13 x i8] c"  store ptr \00"
@.str714 = private unnamed_addr constant [7 x i8] c", ptr \00"
@.str715 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str716 = private unnamed_addr constant [13 x i8] c"  store i32 \00"
@.str717 = private unnamed_addr constant [7 x i8] c", ptr \00"
@.str718 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str719 = private unnamed_addr constant [13 x i8] c"  br label %\00"
@.str720 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str721 = private unnamed_addr constant [3 x i8] c":\0A\00"
@.str722 = private unnamed_addr constant [15 x i8] c"load ptr, ptr \00"
@.str723 = private unnamed_addr constant [3 x i8] c"  \00"
@.str724 = private unnamed_addr constant [27 x i8] c" = getelementptr inbounds \00"
@.str725 = private unnamed_addr constant [7 x i8] c", ptr \00"
@.str726 = private unnamed_addr constant [7 x i8] c", i32 \00"
@.str727 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str728 = private unnamed_addr constant [9 x i8] c"  store \00"
@.str729 = private unnamed_addr constant [2 x i8] c" \00"
@.str730 = private unnamed_addr constant [7 x i8] c", ptr \00"
@.str731 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str732 = private unnamed_addr constant [9 x i8] c"add i32 \00"
@.str733 = private unnamed_addr constant [4 x i8] c", 1\00"
@.str734 = private unnamed_addr constant [13 x i8] c"  store i32 \00"
@.str735 = private unnamed_addr constant [7 x i8] c", ptr \00"
@.str736 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str737 = private unnamed_addr constant [2 x i8] c"0\00"
@.str738 = private unnamed_addr constant [5 x i8] c"void\00"
@.str739 = private unnamed_addr constant [6 x i8] c"load \00"
@.str740 = private unnamed_addr constant [7 x i8] c", ptr \00"
@.str741 = private unnamed_addr constant [4 x i8] c"i32\00"
@.str742 = private unnamed_addr constant [13 x i8] c"icmp ne i32 \00"
@.str743 = private unnamed_addr constant [4 x i8] c", 0\00"
@.str744 = private unnamed_addr constant [9 x i8] c"zext i1 \00"
@.str745 = private unnamed_addr constant [8 x i8] c" to i32\00"
@.str746 = private unnamed_addr constant [13 x i8] c"  store i32 \00"
@.str747 = private unnamed_addr constant [7 x i8] c", ptr \00"
@.str748 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str749 = private unnamed_addr constant [3 x i8] c"sc\00"
@.str750 = private unnamed_addr constant [6 x i8] c"scend\00"
@.str751 = private unnamed_addr constant [4 x i8] c"and\00"
@.str752 = private unnamed_addr constant [9 x i8] c"  br i1 \00"
@.str753 = private unnamed_addr constant [10 x i8] c", label %\00"
@.str754 = private unnamed_addr constant [10 x i8] c", label %\00"
@.str755 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str756 = private unnamed_addr constant [9 x i8] c"  br i1 \00"
@.str757 = private unnamed_addr constant [10 x i8] c", label %\00"
@.str758 = private unnamed_addr constant [10 x i8] c", label %\00"
@.str759 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str760 = private unnamed_addr constant [3 x i8] c":\0A\00"
@.str761 = private unnamed_addr constant [13 x i8] c"icmp ne i32 \00"
@.str762 = private unnamed_addr constant [4 x i8] c", 0\00"
@.str763 = private unnamed_addr constant [9 x i8] c"zext i1 \00"
@.str764 = private unnamed_addr constant [8 x i8] c" to i32\00"
@.str765 = private unnamed_addr constant [13 x i8] c"  store i32 \00"
@.str766 = private unnamed_addr constant [7 x i8] c", ptr \00"
@.str767 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str768 = private unnamed_addr constant [13 x i8] c"  br label %\00"
@.str769 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str770 = private unnamed_addr constant [3 x i8] c":\0A\00"
@.str771 = private unnamed_addr constant [15 x i8] c"load i32, ptr \00"
@.str772 = private unnamed_addr constant [5 x i8] c"bool\00"
@.str773 = private unnamed_addr constant [2 x i8] c"<\00"
@.str774 = private unnamed_addr constant [4 x i8] c"slt\00"
@.str775 = private unnamed_addr constant [3 x i8] c"<=\00"
@.str776 = private unnamed_addr constant [4 x i8] c"sle\00"
@.str777 = private unnamed_addr constant [2 x i8] c">\00"
@.str778 = private unnamed_addr constant [4 x i8] c"sgt\00"
@.str779 = private unnamed_addr constant [3 x i8] c">=\00"
@.str780 = private unnamed_addr constant [4 x i8] c"sge\00"
@.str781 = private unnamed_addr constant [3 x i8] c"==\00"
@.str782 = private unnamed_addr constant [3 x i8] c"eq\00"
@.str783 = private unnamed_addr constant [3 x i8] c"ne\00"
@.str784 = private unnamed_addr constant [2 x i8] c"<\00"
@.str785 = private unnamed_addr constant [3 x i8] c"<=\00"
@.str786 = private unnamed_addr constant [2 x i8] c">\00"
@.str787 = private unnamed_addr constant [3 x i8] c">=\00"
@.str788 = private unnamed_addr constant [3 x i8] c"==\00"
@.str789 = private unnamed_addr constant [3 x i8] c"!=\00"
@.str790 = private unnamed_addr constant [2 x i8] c"+\00"
@.str791 = private unnamed_addr constant [4 x i8] c"add\00"
@.str792 = private unnamed_addr constant [2 x i8] c"-\00"
@.str793 = private unnamed_addr constant [4 x i8] c"sub\00"
@.str794 = private unnamed_addr constant [2 x i8] c"*\00"
@.str795 = private unnamed_addr constant [4 x i8] c"mul\00"
@.str796 = private unnamed_addr constant [2 x i8] c"/\00"
@.str797 = private unnamed_addr constant [5 x i8] c"sdiv\00"
@.str798 = private unnamed_addr constant [5 x i8] c"srem\00"
@.str799 = private unnamed_addr constant [6 x i8] c"fixed\00"
@.str800 = private unnamed_addr constant [9 x i8] c"shl i32 \00"
@.str801 = private unnamed_addr constant [5 x i8] c", 16\00"
@.str802 = private unnamed_addr constant [4 x i8] c"and\00"
@.str803 = private unnamed_addr constant [3 x i8] c"or\00"
@.str804 = private unnamed_addr constant [6 x i8] c"fixed\00"
@.str805 = private unnamed_addr constant [6 x i8] c"fixed\00"
@.str806 = private unnamed_addr constant [6 x i8] c"icmp \00"
@.str807 = private unnamed_addr constant [6 x i8] c" i32 \00"
@.str808 = private unnamed_addr constant [3 x i8] c", \00"
@.str809 = private unnamed_addr constant [9 x i8] c"zext i1 \00"
@.str810 = private unnamed_addr constant [8 x i8] c" to i32\00"
@.str811 = private unnamed_addr constant [5 x i8] c"bool\00"
@.str812 = private unnamed_addr constant [2 x i8] c"*\00"
@.str813 = private unnamed_addr constant [10 x i8] c"sext i32 \00"
@.str814 = private unnamed_addr constant [8 x i8] c" to i64\00"
@.str815 = private unnamed_addr constant [10 x i8] c"sext i32 \00"
@.str816 = private unnamed_addr constant [8 x i8] c" to i64\00"
@.str817 = private unnamed_addr constant [9 x i8] c"mul i64 \00"
@.str818 = private unnamed_addr constant [3 x i8] c", \00"
@.str819 = private unnamed_addr constant [10 x i8] c"ashr i64 \00"
@.str820 = private unnamed_addr constant [5 x i8] c", 16\00"
@.str821 = private unnamed_addr constant [11 x i8] c"trunc i64 \00"
@.str822 = private unnamed_addr constant [8 x i8] c" to i32\00"
@.str823 = private unnamed_addr constant [6 x i8] c"fixed\00"
@.str824 = private unnamed_addr constant [2 x i8] c"/\00"
@.str825 = private unnamed_addr constant [10 x i8] c"sext i32 \00"
@.str826 = private unnamed_addr constant [8 x i8] c" to i64\00"
@.str827 = private unnamed_addr constant [9 x i8] c"shl i64 \00"
@.str828 = private unnamed_addr constant [5 x i8] c", 16\00"
@.str829 = private unnamed_addr constant [10 x i8] c"sext i32 \00"
@.str830 = private unnamed_addr constant [8 x i8] c" to i64\00"
@.str831 = private unnamed_addr constant [10 x i8] c"sdiv i64 \00"
@.str832 = private unnamed_addr constant [3 x i8] c", \00"
@.str833 = private unnamed_addr constant [11 x i8] c"trunc i64 \00"
@.str834 = private unnamed_addr constant [8 x i8] c" to i32\00"
@.str835 = private unnamed_addr constant [6 x i8] c"fixed\00"
@.str836 = private unnamed_addr constant [6 x i8] c" i32 \00"
@.str837 = private unnamed_addr constant [3 x i8] c", \00"
@.str838 = private unnamed_addr constant [6 x i8] c"fixed\00"
@.str839 = private unnamed_addr constant [6 x i8] c" i32 \00"
@.str840 = private unnamed_addr constant [3 x i8] c", \00"
@.str841 = private unnamed_addr constant [4 x i8] c"int\00"
@.str842 = private unnamed_addr constant [5 x i8] c"self\00"
@.str843 = private unnamed_addr constant [2 x i8] c"0\00"
@.str844 = private unnamed_addr constant [7 x i8] c"entity\00"
@.str845 = private unnamed_addr constant [15 x i8] c"load i32, ptr \00"
@.str846 = private unnamed_addr constant [7 x i8] c"entity\00"
@.str847 = private unnamed_addr constant [4 x i8] c"key\00"
@.str848 = private unnamed_addr constant [21 x i8] c"load i32, ptr @L_key\00"
@.str849 = private unnamed_addr constant [4 x i8] c"int\00"
@.str850 = private unnamed_addr constant [5 x i8] c"save\00"
@.str851 = private unnamed_addr constant [23 x i8] c"  call void @L_save()\0A\00"
@.str852 = private unnamed_addr constant [2 x i8] c"0\00"
@.str853 = private unnamed_addr constant [5 x i8] c"void\00"
@.str854 = private unnamed_addr constant [9 x i8] c"ui_build\00"
@.str855 = private unnamed_addr constant [25 x i8] c"  call void @ui_build()\0A\00"
@.str856 = private unnamed_addr constant [2 x i8] c"0\00"
@.str857 = private unnamed_addr constant [5 x i8] c"void\00"
@.str858 = private unnamed_addr constant [5 x i8] c"load\00"
@.str859 = private unnamed_addr constant [19 x i8] c"call i32 @L_load()\00"
@.str860 = private unnamed_addr constant [5 x i8] c"bool\00"
@.str861 = private unnamed_addr constant [5 x i8] c"quit\00"
@.str862 = private unnamed_addr constant [31 x i8] c"  store i32 0, ptr @L_running\0A\00"
@.str863 = private unnamed_addr constant [2 x i8] c"0\00"
@.str864 = private unnamed_addr constant [5 x i8] c"void\00"
@.str865 = private unnamed_addr constant [4 x i8] c"len\00"
@.str866 = private unnamed_addr constant [5 x i8] c"push\00"
@.str867 = private unnamed_addr constant [3 x i8] c"fx\00"
@.str868 = private unnamed_addr constant [9 x i8] c"shl i32 \00"
@.str869 = private unnamed_addr constant [5 x i8] c", 16\00"
@.str870 = private unnamed_addr constant [6 x i8] c"fixed\00"
@.str871 = private unnamed_addr constant [4 x i8] c"flr\00"
@.str872 = private unnamed_addr constant [10 x i8] c"ashr i32 \00"
@.str873 = private unnamed_addr constant [5 x i8] c", 16\00"
@.str874 = private unnamed_addr constant [4 x i8] c"int\00"
@.str875 = private unnamed_addr constant [4 x i8] c"rt_\00"
@.str876 = private unnamed_addr constant [18 x i8] c"unknown function \00"
@.str877 = private unnamed_addr constant [3 x i8] c"  \00"
@.str878 = private unnamed_addr constant [2 x i8] c"0\00"
@.str879 = private unnamed_addr constant [5 x i8] c"void\00"
@.str880 = private unnamed_addr constant [4 x i8] c" = \00"
@.str881 = private unnamed_addr constant [6 x i8] c"call \00"
@.str882 = private unnamed_addr constant [6 x i8] c" @fn_\00"
@.str883 = private unnamed_addr constant [2 x i8] c"(\00"
@.str884 = private unnamed_addr constant [3 x i8] c", \00"
@.str885 = private unnamed_addr constant [2 x i8] c" \00"
@.str886 = private unnamed_addr constant [3 x i8] c")\0A\00"
@.str887 = private unnamed_addr constant [2 x i8] c"0\00"
@.str888 = private unnamed_addr constant [4 x i8] c"int\00"
@.str889 = private unnamed_addr constant [4 x i8] c"int\00"
@.str890 = private unnamed_addr constant [6 x i8] c"fixed\00"
@.str891 = private unnamed_addr constant [5 x i8] c"bool\00"
@.str892 = private unnamed_addr constant [4 x i8] c"str\00"
@.str893 = private unnamed_addr constant [4 x i8] c"int\00"
@.str894 = private unnamed_addr constant [6 x i8] c"load \00"
@.str895 = private unnamed_addr constant [10 x i8] c", ptr @g_\00"
@.str896 = private unnamed_addr constant [4 x i8] c"int\00"
@.str897 = private unnamed_addr constant [20 x i8] c"unknown identifier \00"
@.str898 = private unnamed_addr constant [4 x i8] c"int\00"
@.str899 = private unnamed_addr constant [2 x i8] c"-\00"
@.str900 = private unnamed_addr constant [12 x i8] c"sub i32 0, \00"
@.str901 = private unnamed_addr constant [4 x i8] c"int\00"
@.str902 = private unnamed_addr constant [13 x i8] c"icmp eq i32 \00"
@.str903 = private unnamed_addr constant [4 x i8] c", 0\00"
@.str904 = private unnamed_addr constant [9 x i8] c"zext i1 \00"
@.str905 = private unnamed_addr constant [8 x i8] c" to i32\00"
@.str906 = private unnamed_addr constant [5 x i8] c"bool\00"
@.str907 = private unnamed_addr constant [23 x i8] c"cannot emit expression\00"
@.str908 = private unnamed_addr constant [2 x i8] c"0\00"
@.str909 = private unnamed_addr constant [4 x i8] c"int\00"
@.str910 = private unnamed_addr constant [9 x i8] c"  store \00"
@.str911 = private unnamed_addr constant [2 x i8] c" \00"
@.str912 = private unnamed_addr constant [7 x i8] c", ptr \00"
@.str913 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str914 = private unnamed_addr constant [2 x i8] c"0\00"
@.str915 = private unnamed_addr constant [4 x i8] c"int\00"
@.str916 = private unnamed_addr constant [19 x i8] c"assign to unknown \00"
@.str917 = private unnamed_addr constant [4 x i8] c"@g_\00"
@.str918 = private unnamed_addr constant [22 x i8] c"bad assignment target\00"
@.str919 = private unnamed_addr constant [2 x i8] c"=\00"
@.str920 = private unnamed_addr constant [6 x i8] c"load \00"
@.str921 = private unnamed_addr constant [7 x i8] c", ptr \00"
@.str922 = private unnamed_addr constant [4 x i8] c"add\00"
@.str923 = private unnamed_addr constant [3 x i8] c"-=\00"
@.str924 = private unnamed_addr constant [4 x i8] c"sub\00"
@.str925 = private unnamed_addr constant [3 x i8] c"*=\00"
@.str926 = private unnamed_addr constant [4 x i8] c"mul\00"
@.str927 = private unnamed_addr constant [3 x i8] c"/=\00"
@.str928 = private unnamed_addr constant [5 x i8] c"sdiv\00"
@.str929 = private unnamed_addr constant [6 x i8] c" i32 \00"
@.str930 = private unnamed_addr constant [3 x i8] c", \00"
@.str931 = private unnamed_addr constant [13 x i8] c"icmp ne i32 \00"
@.str932 = private unnamed_addr constant [4 x i8] c", 0\00"
@.str933 = private unnamed_addr constant [5 x i8] c"then\00"
@.str934 = private unnamed_addr constant [5 x i8] c"else\00"
@.str935 = private unnamed_addr constant [6 x i8] c"ifend\00"
@.str936 = private unnamed_addr constant [9 x i8] c"  br i1 \00"
@.str937 = private unnamed_addr constant [10 x i8] c", label %\00"
@.str938 = private unnamed_addr constant [10 x i8] c", label %\00"
@.str939 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str940 = private unnamed_addr constant [9 x i8] c"  br i1 \00"
@.str941 = private unnamed_addr constant [10 x i8] c", label %\00"
@.str942 = private unnamed_addr constant [10 x i8] c", label %\00"
@.str943 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str944 = private unnamed_addr constant [3 x i8] c":\0A\00"
@.str945 = private unnamed_addr constant [13 x i8] c"  br label %\00"
@.str946 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str947 = private unnamed_addr constant [3 x i8] c":\0A\00"
@.str948 = private unnamed_addr constant [13 x i8] c"  br label %\00"
@.str949 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str950 = private unnamed_addr constant [3 x i8] c":\0A\00"
@.str951 = private unnamed_addr constant [6 x i8] c"wcond\00"
@.str952 = private unnamed_addr constant [6 x i8] c"wbody\00"
@.str953 = private unnamed_addr constant [5 x i8] c"wend\00"
@.str954 = private unnamed_addr constant [13 x i8] c"  br label %\00"
@.str955 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str956 = private unnamed_addr constant [3 x i8] c":\0A\00"
@.str957 = private unnamed_addr constant [13 x i8] c"icmp ne i32 \00"
@.str958 = private unnamed_addr constant [4 x i8] c", 0\00"
@.str959 = private unnamed_addr constant [9 x i8] c"  br i1 \00"
@.str960 = private unnamed_addr constant [10 x i8] c", label %\00"
@.str961 = private unnamed_addr constant [10 x i8] c", label %\00"
@.str962 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str963 = private unnamed_addr constant [3 x i8] c":\0A\00"
@.str964 = private unnamed_addr constant [13 x i8] c"  br label %\00"
@.str965 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str966 = private unnamed_addr constant [3 x i8] c":\0A\00"
@.str967 = private unnamed_addr constant [4 x i8] c"i32\00"
@.str968 = private unnamed_addr constant [4 x i8] c"i32\00"
@.str969 = private unnamed_addr constant [4 x i8] c"int\00"
@.str970 = private unnamed_addr constant [6 x i8] c"fcond\00"
@.str971 = private unnamed_addr constant [6 x i8] c"fbody\00"
@.str972 = private unnamed_addr constant [6 x i8] c"fcont\00"
@.str973 = private unnamed_addr constant [5 x i8] c"fend\00"
@.str974 = private unnamed_addr constant [13 x i8] c"  br label %\00"
@.str975 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str976 = private unnamed_addr constant [3 x i8] c":\0A\00"
@.str977 = private unnamed_addr constant [15 x i8] c"load i32, ptr \00"
@.str978 = private unnamed_addr constant [14 x i8] c"icmp slt i32 \00"
@.str979 = private unnamed_addr constant [3 x i8] c", \00"
@.str980 = private unnamed_addr constant [9 x i8] c"  br i1 \00"
@.str981 = private unnamed_addr constant [10 x i8] c", label %\00"
@.str982 = private unnamed_addr constant [10 x i8] c", label %\00"
@.str983 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str984 = private unnamed_addr constant [3 x i8] c":\0A\00"
@.str985 = private unnamed_addr constant [13 x i8] c"  br label %\00"
@.str986 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str987 = private unnamed_addr constant [3 x i8] c":\0A\00"
@.str988 = private unnamed_addr constant [15 x i8] c"load i32, ptr \00"
@.str989 = private unnamed_addr constant [9 x i8] c"add i32 \00"
@.str990 = private unnamed_addr constant [4 x i8] c", 1\00"
@.str991 = private unnamed_addr constant [4 x i8] c"i32\00"
@.str992 = private unnamed_addr constant [13 x i8] c"  br label %\00"
@.str993 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str994 = private unnamed_addr constant [3 x i8] c":\0A\00"
@.str995 = private unnamed_addr constant [8 x i8] c"%retval\00"
@.str996 = private unnamed_addr constant [17 x i8] c"  br label %ret\0A\00"
@.str997 = private unnamed_addr constant [2 x i8] c"_\00"
@.str998 = private unnamed_addr constant [5 x i8] c"mend\00"
@.str999 = private unnamed_addr constant [2 x i8] c"0\00"
@.str1000 = private unnamed_addr constant [13 x i8] c"icmp eq i32 \00"
@.str1001 = private unnamed_addr constant [3 x i8] c", \00"
@.str1002 = private unnamed_addr constant [7 x i8] c"or i1 \00"
@.str1003 = private unnamed_addr constant [3 x i8] c", \00"
@.str1004 = private unnamed_addr constant [6 x i8] c"mbody\00"
@.str1005 = private unnamed_addr constant [5 x i8] c"marm\00"
@.str1006 = private unnamed_addr constant [9 x i8] c"  br i1 \00"
@.str1007 = private unnamed_addr constant [10 x i8] c", label %\00"
@.str1008 = private unnamed_addr constant [10 x i8] c", label %\00"
@.str1009 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str1010 = private unnamed_addr constant [3 x i8] c":\0A\00"
@.str1011 = private unnamed_addr constant [13 x i8] c"  br label %\00"
@.str1012 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str1013 = private unnamed_addr constant [3 x i8] c":\0A\00"
@.str1014 = private unnamed_addr constant [13 x i8] c"  br label %\00"
@.str1015 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str1016 = private unnamed_addr constant [3 x i8] c":\0A\00"
@.str1017 = private unnamed_addr constant [2 x i8] c"0\00"
@.str1018 = private unnamed_addr constant [4 x i8] c"ptr\00"
@.str1019 = private unnamed_addr constant [5 x i8] c"null\00"
@.str1020 = private unnamed_addr constant [13 x i8] c"  br label %\00"
@.str1021 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str1022 = private unnamed_addr constant [13 x i8] c"  br label %\00"
@.str1023 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str1024 = private unnamed_addr constant [22 x i8] c"cannot emit statement\00"
@.str1025 = private unnamed_addr constant [36 x i8] c"@L_running = internal global i32 1\0A\00"
@.str1026 = private unnamed_addr constant [32 x i8] c"@L_key = internal global i32 0\0A\00"
@.str1027 = private unnamed_addr constant [33 x i8] c"@L_entc = internal global i32 0\0A\00"
@.str1028 = private unnamed_addr constant [29 x i8] c"@L_alive = internal global [\00"
@.str1029 = private unnamed_addr constant [25 x i8] c" x i32] zeroinitializer\0A\00"
@.str1030 = private unnamed_addr constant [28 x i8] c"@L_kind = internal global [\00"
@.str1031 = private unnamed_addr constant [25 x i8] c" x i32] zeroinitializer\0A\00"
@.str1032 = private unnamed_addr constant [32 x i8] c"@L_freelist = internal global [\00"
@.str1033 = private unnamed_addr constant [25 x i8] c" x i32] zeroinitializer\0A\00"
@.str1034 = private unnamed_addr constant [34 x i8] c"@L_freen = internal global i32 0\0A\00"
@.str1035 = private unnamed_addr constant [6 x i8] c"%Cmp_\00"
@.str1036 = private unnamed_addr constant [11 x i8] c" = type { \00"
@.str1037 = private unnamed_addr constant [4 x i8] c"i32\00"
@.str1038 = private unnamed_addr constant [3 x i8] c", \00"
@.str1039 = private unnamed_addr constant [4 x i8] c" }\0A\00"
@.str1040 = private unnamed_addr constant [4 x i8] c"@S_\00"
@.str1041 = private unnamed_addr constant [21 x i8] c" = internal global [\00"
@.str1042 = private unnamed_addr constant [9 x i8] c" x %Cmp_\00"
@.str1043 = private unnamed_addr constant [19 x i8] c"] zeroinitializer\0A\00"
@.str1044 = private unnamed_addr constant [4 x i8] c"@H_\00"
@.str1045 = private unnamed_addr constant [21 x i8] c" = internal global [\00"
@.str1046 = private unnamed_addr constant [24 x i8] c" x i8] zeroinitializer\0A\00"
@.str1047 = private unnamed_addr constant [39 x i8] c"define void @L_reset(i32 %e) {\0Aentry:\0A\00"
@.str1048 = private unnamed_addr constant [3 x i8] c"%h\00"
@.str1049 = private unnamed_addr constant [3 x i8] c"  \00"
@.str1050 = private unnamed_addr constant [28 x i8] c" = getelementptr inbounds [\00"
@.str1051 = private unnamed_addr constant [16 x i8] c" x i8], ptr @H_\00"
@.str1052 = private unnamed_addr constant [17 x i8] c", i32 0, i32 %e\0A\00"
@.str1053 = private unnamed_addr constant [19 x i8] c"  store i8 0, ptr \00"
@.str1054 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str1055 = private unnamed_addr constant [32 x i8] c"  %k = getelementptr inbounds [\00"
@.str1056 = private unnamed_addr constant [37 x i8] c" x i32], ptr @L_kind, i32 0, i32 %e\0A\00"
@.str1057 = private unnamed_addr constant [37 x i8] c"  store i32 0, ptr %k\0A  ret void\0A}\0A\0A\00"
@.str1058 = private unnamed_addr constant [32 x i8] c"define i32 @L_alloc() {\0Aentry:\0A\00"
@.str1059 = private unnamed_addr constant [32 x i8] c"  %fn = load i32, ptr @L_freen\0A\00"
@.str1060 = private unnamed_addr constant [30 x i8] c"  %has = icmp sgt i32 %fn, 0\0A\00"
@.str1061 = private unnamed_addr constant [42 x i8] c"  br i1 %has, label %reuse, label %fresh\0A\00"
@.str1062 = private unnamed_addr constant [8 x i8] c"reuse:\0A\00"
@.str1063 = private unnamed_addr constant [25 x i8] c"  %fn1 = sub i32 %fn, 1\0A\00"
@.str1064 = private unnamed_addr constant [32 x i8] c"  store i32 %fn1, ptr @L_freen\0A\00"
@.str1065 = private unnamed_addr constant [33 x i8] c"  %fp = getelementptr inbounds [\00"
@.str1066 = private unnamed_addr constant [43 x i8] c" x i32], ptr @L_freelist, i32 0, i32 %fn1\0A\00"
@.str1067 = private unnamed_addr constant [27 x i8] c"  %re = load i32, ptr %fp\0A\00"
@.str1068 = private unnamed_addr constant [18 x i8] c"  br label %done\0A\00"
@.str1069 = private unnamed_addr constant [8 x i8] c"fresh:\0A\00"
@.str1070 = private unnamed_addr constant [31 x i8] c"  %ec = load i32, ptr @L_entc\0A\00"
@.str1071 = private unnamed_addr constant [25 x i8] c"  %ec1 = add i32 %ec, 1\0A\00"
@.str1072 = private unnamed_addr constant [31 x i8] c"  store i32 %ec1, ptr @L_entc\0A\00"
@.str1073 = private unnamed_addr constant [18 x i8] c"  br label %done\0A\00"
@.str1074 = private unnamed_addr constant [7 x i8] c"done:\0A\00"
@.str1075 = private unnamed_addr constant [49 x i8] c"  %e = phi i32 [ %re, %reuse ], [ %ec, %fresh ]\0A\00"
@.str1076 = private unnamed_addr constant [30 x i8] c"  call void @L_reset(i32 %e)\0A\00"
@.str1077 = private unnamed_addr constant [33 x i8] c"  %ap = getelementptr inbounds [\00"
@.str1078 = private unnamed_addr constant [38 x i8] c" x i32], ptr @L_alive, i32 0, i32 %e\0A\00"
@.str1079 = private unnamed_addr constant [24 x i8] c"  store i32 1, ptr %ap\0A\00"
@.str1080 = private unnamed_addr constant [17 x i8] c"  ret i32 %e\0A}\0A\0A\00"
@.str1081 = private unnamed_addr constant [45 x i8] c"define void @L_free_entity(i32 %e) {\0Aentry:\0A\00"
@.str1082 = private unnamed_addr constant [33 x i8] c"  %ap = getelementptr inbounds [\00"
@.str1083 = private unnamed_addr constant [38 x i8] c" x i32], ptr @L_alive, i32 0, i32 %e\0A\00"
@.str1084 = private unnamed_addr constant [24 x i8] c"  store i32 0, ptr %ap\0A\00"
@.str1085 = private unnamed_addr constant [30 x i8] c"  call void @L_reset(i32 %e)\0A\00"
@.str1086 = private unnamed_addr constant [32 x i8] c"  %fn = load i32, ptr @L_freen\0A\00"
@.str1087 = private unnamed_addr constant [33 x i8] c"  %fp = getelementptr inbounds [\00"
@.str1088 = private unnamed_addr constant [42 x i8] c" x i32], ptr @L_freelist, i32 0, i32 %fn\0A\00"
@.str1089 = private unnamed_addr constant [25 x i8] c"  store i32 %e, ptr %fp\0A\00"
@.str1090 = private unnamed_addr constant [25 x i8] c"  %fn1 = add i32 %fn, 1\0A\00"
@.str1091 = private unnamed_addr constant [32 x i8] c"  store i32 %fn1, ptr @L_freen\0A\00"
@.str1092 = private unnamed_addr constant [15 x i8] c"  ret void\0A}\0A\0A\00"
@.str1093 = private unnamed_addr constant [4 x i8] c"i32\00"
@.str1094 = private unnamed_addr constant [4 x i8] c"i32\00"
@.str1095 = private unnamed_addr constant [2 x i8] c"0\00"
@.str1096 = private unnamed_addr constant [6 x i8] c"qcond\00"
@.str1097 = private unnamed_addr constant [6 x i8] c"qbody\00"
@.str1098 = private unnamed_addr constant [6 x i8] c"qnext\00"
@.str1099 = private unnamed_addr constant [5 x i8] c"qend\00"
@.str1100 = private unnamed_addr constant [13 x i8] c"  br label %\00"
@.str1101 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str1102 = private unnamed_addr constant [3 x i8] c":\0A\00"
@.str1103 = private unnamed_addr constant [15 x i8] c"load i32, ptr \00"
@.str1104 = private unnamed_addr constant [22 x i8] c"load i32, ptr @L_entc\00"
@.str1105 = private unnamed_addr constant [14 x i8] c"icmp slt i32 \00"
@.str1106 = private unnamed_addr constant [3 x i8] c", \00"
@.str1107 = private unnamed_addr constant [9 x i8] c"  br i1 \00"
@.str1108 = private unnamed_addr constant [10 x i8] c", label %\00"
@.str1109 = private unnamed_addr constant [10 x i8] c", label %\00"
@.str1110 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str1111 = private unnamed_addr constant [3 x i8] c":\0A\00"
@.str1112 = private unnamed_addr constant [15 x i8] c"load i32, ptr \00"
@.str1113 = private unnamed_addr constant [3 x i8] c"  \00"
@.str1114 = private unnamed_addr constant [28 x i8] c" = getelementptr inbounds [\00"
@.str1115 = private unnamed_addr constant [35 x i8] c" x i32], ptr @L_alive, i32 0, i32 \00"
@.str1116 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str1117 = private unnamed_addr constant [15 x i8] c"load i32, ptr \00"
@.str1118 = private unnamed_addr constant [13 x i8] c"icmp ne i32 \00"
@.str1119 = private unnamed_addr constant [4 x i8] c", 0\00"
@.str1120 = private unnamed_addr constant [3 x i8] c"qa\00"
@.str1121 = private unnamed_addr constant [9 x i8] c"  br i1 \00"
@.str1122 = private unnamed_addr constant [10 x i8] c", label %\00"
@.str1123 = private unnamed_addr constant [10 x i8] c", label %\00"
@.str1124 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str1125 = private unnamed_addr constant [3 x i8] c":\0A\00"
@.str1126 = private unnamed_addr constant [2 x i8] c"0\00"
@.str1127 = private unnamed_addr constant [3 x i8] c"  \00"
@.str1128 = private unnamed_addr constant [28 x i8] c" = getelementptr inbounds [\00"
@.str1129 = private unnamed_addr constant [34 x i8] c" x i32], ptr @L_kind, i32 0, i32 \00"
@.str1130 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str1131 = private unnamed_addr constant [15 x i8] c"load i32, ptr \00"
@.str1132 = private unnamed_addr constant [13 x i8] c"icmp eq i32 \00"
@.str1133 = private unnamed_addr constant [3 x i8] c", \00"
@.str1134 = private unnamed_addr constant [3 x i8] c"  \00"
@.str1135 = private unnamed_addr constant [28 x i8] c" = getelementptr inbounds [\00"
@.str1136 = private unnamed_addr constant [16 x i8] c" x i8], ptr @H_\00"
@.str1137 = private unnamed_addr constant [14 x i8] c", i32 0, i32 \00"
@.str1138 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str1139 = private unnamed_addr constant [14 x i8] c"load i8, ptr \00"
@.str1140 = private unnamed_addr constant [12 x i8] c"icmp ne i8 \00"
@.str1141 = private unnamed_addr constant [4 x i8] c", 0\00"
@.str1142 = private unnamed_addr constant [3 x i8] c"qt\00"
@.str1143 = private unnamed_addr constant [9 x i8] c"  br i1 \00"
@.str1144 = private unnamed_addr constant [10 x i8] c", label %\00"
@.str1145 = private unnamed_addr constant [10 x i8] c", label %\00"
@.str1146 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str1147 = private unnamed_addr constant [3 x i8] c":\0A\00"
@.str1148 = private unnamed_addr constant [3 x i8] c"  \00"
@.str1149 = private unnamed_addr constant [28 x i8] c" = getelementptr inbounds [\00"
@.str1150 = private unnamed_addr constant [9 x i8] c" x %Cmp_\00"
@.str1151 = private unnamed_addr constant [11 x i8] c"], ptr @S_\00"
@.str1152 = private unnamed_addr constant [14 x i8] c", i32 0, i32 \00"
@.str1153 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str1154 = private unnamed_addr constant [4 x i8] c"ptr\00"
@.str1155 = private unnamed_addr constant [13 x i8] c"  store ptr \00"
@.str1156 = private unnamed_addr constant [7 x i8] c", ptr \00"
@.str1157 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str1158 = private unnamed_addr constant [13 x i8] c"icmp ne i32 \00"
@.str1159 = private unnamed_addr constant [4 x i8] c", 0\00"
@.str1160 = private unnamed_addr constant [3 x i8] c"qw\00"
@.str1161 = private unnamed_addr constant [9 x i8] c"  br i1 \00"
@.str1162 = private unnamed_addr constant [10 x i8] c", label %\00"
@.str1163 = private unnamed_addr constant [10 x i8] c", label %\00"
@.str1164 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str1165 = private unnamed_addr constant [3 x i8] c":\0A\00"
@.str1166 = private unnamed_addr constant [13 x i8] c"  br label %\00"
@.str1167 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str1168 = private unnamed_addr constant [3 x i8] c":\0A\00"
@.str1169 = private unnamed_addr constant [15 x i8] c"load i32, ptr \00"
@.str1170 = private unnamed_addr constant [9 x i8] c"add i32 \00"
@.str1171 = private unnamed_addr constant [4 x i8] c", 1\00"
@.str1172 = private unnamed_addr constant [4 x i8] c"i32\00"
@.str1173 = private unnamed_addr constant [13 x i8] c"  br label %\00"
@.str1174 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str1175 = private unnamed_addr constant [3 x i8] c":\0A\00"
@.str1176 = private unnamed_addr constant [25 x i8] c"spawn: unknown property \00"
@.str1177 = private unnamed_addr constant [3 x i8] c"  \00"
@.str1178 = private unnamed_addr constant [28 x i8] c" = getelementptr inbounds [\00"
@.str1179 = private unnamed_addr constant [16 x i8] c" x i8], ptr @H_\00"
@.str1180 = private unnamed_addr constant [14 x i8] c", i32 0, i32 \00"
@.str1181 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str1182 = private unnamed_addr constant [19 x i8] c"  store i8 1, ptr \00"
@.str1183 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str1184 = private unnamed_addr constant [3 x i8] c"  \00"
@.str1185 = private unnamed_addr constant [28 x i8] c" = getelementptr inbounds [\00"
@.str1186 = private unnamed_addr constant [9 x i8] c" x %Cmp_\00"
@.str1187 = private unnamed_addr constant [11 x i8] c"], ptr @S_\00"
@.str1188 = private unnamed_addr constant [14 x i8] c", i32 0, i32 \00"
@.str1189 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str1190 = private unnamed_addr constant [3 x i8] c"  \00"
@.str1191 = private unnamed_addr constant [32 x i8] c" = getelementptr inbounds %Cmp_\00"
@.str1192 = private unnamed_addr constant [7 x i8] c", ptr \00"
@.str1193 = private unnamed_addr constant [14 x i8] c", i32 0, i32 \00"
@.str1194 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str1195 = private unnamed_addr constant [2 x i8] c"0\00"
@.str1196 = private unnamed_addr constant [4 x i8] c"ptr\00"
@.str1197 = private unnamed_addr constant [5 x i8] c"null\00"
@.str1198 = private unnamed_addr constant [9 x i8] c"  store \00"
@.str1199 = private unnamed_addr constant [2 x i8] c" \00"
@.str1200 = private unnamed_addr constant [7 x i8] c", ptr \00"
@.str1201 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str1202 = private unnamed_addr constant [3 x i8] c"  \00"
@.str1203 = private unnamed_addr constant [32 x i8] c" = getelementptr inbounds %Cmp_\00"
@.str1204 = private unnamed_addr constant [7 x i8] c", ptr \00"
@.str1205 = private unnamed_addr constant [14 x i8] c", i32 0, i32 \00"
@.str1206 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str1207 = private unnamed_addr constant [9 x i8] c"  store \00"
@.str1208 = private unnamed_addr constant [2 x i8] c" \00"
@.str1209 = private unnamed_addr constant [7 x i8] c", ptr \00"
@.str1210 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str1211 = private unnamed_addr constant [20 x i8] c"call i32 @L_alloc()\00"
@.str1212 = private unnamed_addr constant [3 x i8] c"  \00"
@.str1213 = private unnamed_addr constant [28 x i8] c" = getelementptr inbounds [\00"
@.str1214 = private unnamed_addr constant [34 x i8] c" x i32], ptr @L_kind, i32 0, i32 \00"
@.str1215 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str1216 = private unnamed_addr constant [13 x i8] c"  store i32 \00"
@.str1217 = private unnamed_addr constant [7 x i8] c", ptr \00"
@.str1218 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str1219 = private unnamed_addr constant [32 x i8] c"  call void @L_free_entity(i32 \00"
@.str1220 = private unnamed_addr constant [3 x i8] c")\0A\00"
@.str1221 = private unnamed_addr constant [5 x i8] c"void\00"
@.str1222 = private unnamed_addr constant [17 x i8] c"  br label %ret\0A\00"
@.str1223 = private unnamed_addr constant [17 x i8] c"ret:\0A  ret void\0A\00"
@.str1224 = private unnamed_addr constant [18 x i8] c"define void @sys_\00"
@.str1225 = private unnamed_addr constant [13 x i8] c"() {\0Aentry:\0A\00"
@.str1226 = private unnamed_addr constant [4 x i8] c"}\0A\0A\00"
@.str1227 = private unnamed_addr constant [18 x i8] c"  call void @sys_\00"
@.str1228 = private unnamed_addr constant [4 x i8] c"()\0A\00"
@.str1229 = private unnamed_addr constant [49 x i8] c"define i32 @main(i32 %argc, ptr %argv) {\0Aentry:\0A\00"
@.str1230 = private unnamed_addr constant [32 x i8] c"  store i32 %argc, ptr @L_argc\0A\00"
@.str1231 = private unnamed_addr constant [32 x i8] c"  store ptr %argv, ptr @L_argv\0A\00"
@.str1232 = private unnamed_addr constant [8 x i8] c"rt_init\00"
@.str1233 = private unnamed_addr constant [27 x i8] c"  call void @fn_rt_init()\0A\00"
@.str1234 = private unnamed_addr constant [6 x i8] c"Start\00"
@.str1235 = private unnamed_addr constant [18 x i8] c"  br label %loop\0A\00"
@.str1236 = private unnamed_addr constant [7 x i8] c"loop:\0A\00"
@.str1237 = private unnamed_addr constant [25 x i8] c"load i32, ptr @L_running\00"
@.str1238 = private unnamed_addr constant [13 x i8] c"icmp ne i32 \00"
@.str1239 = private unnamed_addr constant [4 x i8] c", 0\00"
@.str1240 = private unnamed_addr constant [11 x i8] c"rt_running\00"
@.str1241 = private unnamed_addr constant [26 x i8] c"call i32 @fn_rt_running()\00"
@.str1242 = private unnamed_addr constant [13 x i8] c"icmp ne i32 \00"
@.str1243 = private unnamed_addr constant [4 x i8] c", 0\00"
@.str1244 = private unnamed_addr constant [8 x i8] c"and i1 \00"
@.str1245 = private unnamed_addr constant [3 x i8] c", \00"
@.str1246 = private unnamed_addr constant [9 x i8] c"  br i1 \00"
@.str1247 = private unnamed_addr constant [28 x i8] c", label %body, label %done\0A\00"
@.str1248 = private unnamed_addr constant [9 x i8] c"  br i1 \00"
@.str1249 = private unnamed_addr constant [28 x i8] c", label %body, label %done\0A\00"
@.str1250 = private unnamed_addr constant [7 x i8] c"body:\0A\00"
@.str1251 = private unnamed_addr constant [8 x i8] c"rt_poll\00"
@.str1252 = private unnamed_addr constant [23 x i8] c"call i32 @fn_rt_poll()\00"
@.str1253 = private unnamed_addr constant [13 x i8] c"  store i32 \00"
@.str1254 = private unnamed_addr constant [14 x i8] c", ptr @L_key\0A\00"
@.str1255 = private unnamed_addr constant [6 x i8] c"Input\00"
@.str1256 = private unnamed_addr constant [12 x i8] c"FixedUpdate\00"
@.str1257 = private unnamed_addr constant [7 x i8] c"Update\00"
@.str1258 = private unnamed_addr constant [11 x i8] c"LateUpdate\00"
@.str1259 = private unnamed_addr constant [7 x i8] c"Render\00"
@.str1260 = private unnamed_addr constant [18 x i8] c"  br label %loop\0A\00"
@.str1261 = private unnamed_addr constant [7 x i8] c"done:\0A\00"
@.str1262 = private unnamed_addr constant [12 x i8] c"rt_shutdown\00"
@.str1263 = private unnamed_addr constant [31 x i8] c"  call void @fn_rt_shutdown()\0A\00"
@.str1264 = private unnamed_addr constant [15 x i8] c"  ret i32 0\0A}\0A\00"
@.str1265 = private unnamed_addr constant [25 x i8] c"call i32 @fn_rt_reg(i32 \00"
@.str1266 = private unnamed_addr constant [2 x i8] c")\00"
@.str1267 = private unnamed_addr constant [6 x i8] c"smend\00"
@.str1268 = private unnamed_addr constant [13 x i8] c"icmp eq i32 \00"
@.str1269 = private unnamed_addr constant [3 x i8] c", \00"
@.str1270 = private unnamed_addr constant [6 x i8] c"sbody\00"
@.str1271 = private unnamed_addr constant [5 x i8] c"sarm\00"
@.str1272 = private unnamed_addr constant [9 x i8] c"  br i1 \00"
@.str1273 = private unnamed_addr constant [10 x i8] c", label %\00"
@.str1274 = private unnamed_addr constant [10 x i8] c", label %\00"
@.str1275 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str1276 = private unnamed_addr constant [3 x i8] c":\0A\00"
@.str1277 = private unnamed_addr constant [13 x i8] c"  br label %\00"
@.str1278 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str1279 = private unnamed_addr constant [3 x i8] c":\0A\00"
@.str1280 = private unnamed_addr constant [13 x i8] c"  br label %\00"
@.str1281 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str1282 = private unnamed_addr constant [3 x i8] c":\0A\00"
@.str1283 = private unnamed_addr constant [27 x i8] c"'become' outside a machine\00"
@.str1284 = private unnamed_addr constant [18 x i8] c"become: no state \00"
@.str1285 = private unnamed_addr constant [31 x i8] c"  call void @fn_rt_setreg(i32 \00"
@.str1286 = private unnamed_addr constant [7 x i8] c", i32 \00"
@.str1287 = private unnamed_addr constant [3 x i8] c")\0A\00"
@.str1288 = private unnamed_addr constant [4 x i8] c"%io\00"
@.str1289 = private unnamed_addr constant [3 x i8] c"  \00"
@.str1290 = private unnamed_addr constant [14 x i8] c" = call i64 @\00"
@.str1291 = private unnamed_addr constant [6 x i8] c"(ptr \00"
@.str1292 = private unnamed_addr constant [14 x i8] c", i64 1, i64 \00"
@.str1293 = private unnamed_addr constant [11 x i8] c", ptr %f)\0A\00"
@.str1294 = private unnamed_addr constant [8 x i8] c"@L_entc\00"
@.str1295 = private unnamed_addr constant [2 x i8] c"4\00"
@.str1296 = private unnamed_addr constant [9 x i8] c"@L_freen\00"
@.str1297 = private unnamed_addr constant [2 x i8] c"4\00"
@.str1298 = private unnamed_addr constant [21 x i8] c"  %nalive = mul i64 \00"
@.str1299 = private unnamed_addr constant [5 x i8] c", 4\0A\00"
@.str1300 = private unnamed_addr constant [9 x i8] c"@L_alive\00"
@.str1301 = private unnamed_addr constant [8 x i8] c"%nalive\00"
@.str1302 = private unnamed_addr constant [12 x i8] c"@L_freelist\00"
@.str1303 = private unnamed_addr constant [8 x i8] c"%nalive\00"
@.str1304 = private unnamed_addr constant [8 x i8] c"@L_kind\00"
@.str1305 = private unnamed_addr constant [8 x i8] c"%nalive\00"
@.str1306 = private unnamed_addr constant [4 x i8] c"@g_\00"
@.str1307 = private unnamed_addr constant [2 x i8] c"4\00"
@.str1308 = private unnamed_addr constant [5 x i8] c"%csz\00"
@.str1309 = private unnamed_addr constant [3 x i8] c"  \00"
@.str1310 = private unnamed_addr constant [37 x i8] c" = ptrtoint ptr getelementptr (%Cmp_\00"
@.str1311 = private unnamed_addr constant [17 x i8] c", ptr null, i32 \00"
@.str1312 = private unnamed_addr constant [10 x i8] c") to i64\0A\00"
@.str1313 = private unnamed_addr constant [4 x i8] c"@S_\00"
@.str1314 = private unnamed_addr constant [4 x i8] c"@H_\00"
@.str1315 = private unnamed_addr constant [70 x i8] c"@.sav_path = private unnamed_addr constant [10 x i8] c\22ludic.sav\5C00\22\0A\00"
@.str1316 = private unnamed_addr constant [60 x i8] c"@.sav_wb = private unnamed_addr constant [3 x i8] c\22wb\5C00\22\0A\00"
@.str1317 = private unnamed_addr constant [60 x i8] c"@.sav_rb = private unnamed_addr constant [3 x i8] c\22rb\5C00\22\0A\00"
@.str1318 = private unnamed_addr constant [14 x i8] c"rt_save_state\00"
@.str1319 = private unnamed_addr constant [14 x i8] c"rt_load_state\00"
@.str1320 = private unnamed_addr constant [32 x i8] c"define void @L_save() {\0Aentry:\0A\00"
@.str1321 = private unnamed_addr constant [54 x i8] c"  %f = call ptr @fopen(ptr @.sav_path, ptr @.sav_wb)\0A\00"
@.str1322 = private unnamed_addr constant [31 x i8] c"  %bad = icmp eq ptr %f, null\0A\00"
@.str1323 = private unnamed_addr constant [41 x i8] c"  br i1 %bad, label %out, label %go\0Ago:\0A\00"
@.str1324 = private unnamed_addr constant [7 x i8] c"fwrite\00"
@.str1325 = private unnamed_addr constant [39 x i8] c"  call void @fn_rt_save_state(ptr %f)\0A\00"
@.str1326 = private unnamed_addr constant [68 x i8] c"  %c = call i32 @fclose(ptr %f)\0A  br label %out\0Aout:\0A  ret void\0A}\0A\0A\00"
@.str1327 = private unnamed_addr constant [31 x i8] c"define i32 @L_load() {\0Aentry:\0A\00"
@.str1328 = private unnamed_addr constant [54 x i8] c"  %f = call ptr @fopen(ptr @.sav_path, ptr @.sav_rb)\0A\00"
@.str1329 = private unnamed_addr constant [31 x i8] c"  %bad = icmp eq ptr %f, null\0A\00"
@.str1330 = private unnamed_addr constant [60 x i8] c"  br i1 %bad, label %miss, label %go\0Amiss:\0A  ret i32 0\0Ago:\0A\00"
@.str1331 = private unnamed_addr constant [6 x i8] c"fread\00"
@.str1332 = private unnamed_addr constant [39 x i8] c"  call void @fn_rt_load_state(ptr %f)\0A\00"
@.str1333 = private unnamed_addr constant [48 x i8] c"  %c = call i32 @fclose(ptr %f)\0A  ret i32 1\0A}\0A\0A\00"
@.str1334 = private unnamed_addr constant [6 x i8] c"panel\00"
@.str1335 = private unnamed_addr constant [4 x i8] c"col\00"
@.str1336 = private unnamed_addr constant [4 x i8] c"row\00"
@.str1337 = private unnamed_addr constant [6 x i8] c"label\00"
@.str1338 = private unnamed_addr constant [7 x i8] c"button\00"
@.str1339 = private unnamed_addr constant [6 x i8] c"image\00"
@.str1340 = private unnamed_addr constant [7 x i8] c"spacer\00"
@.str1341 = private unnamed_addr constant [3 x i8] c"id\00"
@.str1342 = private unnamed_addr constant [31 x i8] c"  call void @fn_rt_ui_set(i32 \00"
@.str1343 = private unnamed_addr constant [7 x i8] c", i32 \00"
@.str1344 = private unnamed_addr constant [7 x i8] c", i32 \00"
@.str1345 = private unnamed_addr constant [3 x i8] c")\0A\00"
@.str1346 = private unnamed_addr constant [2 x i8] c"w\00"
@.str1347 = private unnamed_addr constant [2 x i8] c"h\00"
@.str1348 = private unnamed_addr constant [2 x i8] c"x\00"
@.str1349 = private unnamed_addr constant [2 x i8] c"y\00"
@.str1350 = private unnamed_addr constant [4 x i8] c"pad\00"
@.str1351 = private unnamed_addr constant [4 x i8] c"gap\00"
@.str1352 = private unnamed_addr constant [3 x i8] c"bg\00"
@.str1353 = private unnamed_addr constant [3 x i8] c"fg\00"
@.str1354 = private unnamed_addr constant [7 x i8] c"border\00"
@.str1355 = private unnamed_addr constant [5 x i8] c"grow\00"
@.str1356 = private unnamed_addr constant [5 x i8] c"font\00"
@.str1357 = private unnamed_addr constant [5 x i8] c"size\00"
@.str1358 = private unnamed_addr constant [6 x i8] c"inset\00"
@.str1359 = private unnamed_addr constant [6 x i8] c"focus\00"
@.str1360 = private unnamed_addr constant [33 x i8] c"  call void @fn_rt_ui_reset(i32 \00"
@.str1361 = private unnamed_addr constant [3 x i8] c")\0A\00"
@.str1362 = private unnamed_addr constant [2 x i8] c"1\00"
@.str1363 = private unnamed_addr constant [3 x i8] c"id\00"
@.str1364 = private unnamed_addr constant [5 x i8] c"text\00"
@.str1365 = private unnamed_addr constant [39 x i8] c"  call void @fn_rt_ui_static_text(i32 \00"
@.str1366 = private unnamed_addr constant [7 x i8] c", ptr \00"
@.str1367 = private unnamed_addr constant [3 x i8] c")\0A\00"
@.str1368 = private unnamed_addr constant [5 x i8] c"skin\00"
@.str1369 = private unnamed_addr constant [6 x i8] c"image\00"
@.str1370 = private unnamed_addr constant [32 x i8] c"call i32 @fn_rt_image_load(ptr \00"
@.str1371 = private unnamed_addr constant [2 x i8] c")\00"
@.str1372 = private unnamed_addr constant [5 x i8] c"skin\00"
@.str1373 = private unnamed_addr constant [6 x i8] c"align\00"
@.str1374 = private unnamed_addr constant [7 x i8] c"center\00"
@.str1375 = private unnamed_addr constant [4 x i8] c"end\00"
@.str1376 = private unnamed_addr constant [2 x i8] c"1\00"
@.str1377 = private unnamed_addr constant [34 x i8] c"define void @ui_build() {\0Aentry:\0A\00"
@.str1378 = private unnamed_addr constant [15 x i8] c"  ret void\0A}\0A\0A\00"
@.str1379 = private unnamed_addr constant [3 x i8] c", \00"
@.str1380 = private unnamed_addr constant [7 x i8] c" %arg_\00"
@.str1381 = private unnamed_addr constant [5 x i8] c"void\00"
@.str1382 = private unnamed_addr constant [20 x i8] c"  %retval = alloca \00"
@.str1383 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str1384 = private unnamed_addr constant [9 x i8] c"  store \00"
@.str1385 = private unnamed_addr constant [7 x i8] c" %arg_\00"
@.str1386 = private unnamed_addr constant [7 x i8] c", ptr \00"
@.str1387 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str1388 = private unnamed_addr constant [17 x i8] c"  br label %ret\0A\00"
@.str1389 = private unnamed_addr constant [6 x i8] c"ret:\0A\00"
@.str1390 = private unnamed_addr constant [5 x i8] c"void\00"
@.str1391 = private unnamed_addr constant [12 x i8] c"  ret void\0A\00"
@.str1392 = private unnamed_addr constant [6 x i8] c"load \00"
@.str1393 = private unnamed_addr constant [14 x i8] c", ptr %retval\00"
@.str1394 = private unnamed_addr constant [7 x i8] c"  ret \00"
@.str1395 = private unnamed_addr constant [2 x i8] c" \00"
@.str1396 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str1397 = private unnamed_addr constant [8 x i8] c"define \00"
@.str1398 = private unnamed_addr constant [6 x i8] c" @fn_\00"
@.str1399 = private unnamed_addr constant [2 x i8] c"(\00"
@.str1400 = private unnamed_addr constant [12 x i8] c") {\0Aentry:\0A\00"
@.str1401 = private unnamed_addr constant [4 x i8] c"}\0A\0A\00"
@.str1402 = private unnamed_addr constant [4 x i8] c"int\00"
@.str1403 = private unnamed_addr constant [24 x i8] c"  %retval = alloca i32\0A\00"
@.str1404 = private unnamed_addr constant [32 x i8] c"  store i32 %argc, ptr @L_argc\0A\00"
@.str1405 = private unnamed_addr constant [32 x i8] c"  store ptr %argv, ptr @L_argv\0A\00"
@.str1406 = private unnamed_addr constant [28 x i8] c"  store i32 0, ptr %retval\0A\00"
@.str1407 = private unnamed_addr constant [17 x i8] c"  br label %ret\0A\00"
@.str1408 = private unnamed_addr constant [6 x i8] c"ret:\0A\00"
@.str1409 = private unnamed_addr constant [22 x i8] c"load i32, ptr %retval\00"
@.str1410 = private unnamed_addr constant [11 x i8] c"  ret i32 \00"
@.str1411 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str1412 = private unnamed_addr constant [49 x i8] c"define i32 @main(i32 %argc, ptr %argv) {\0Aentry:\0A\00"
@.str1413 = private unnamed_addr constant [3 x i8] c"}\0A\00"
@.str1414 = private unnamed_addr constant [3 x i8] c"wb\00"
@.str1415 = private unnamed_addr constant [7 x i8] c".ludic\00"
@.str1416 = private unnamed_addr constant [2 x i8] c"/\00"
@.str1417 = private unnamed_addr constant [6 x i8] c"ludic\00"
@.str1418 = private unnamed_addr constant [11 x i8] c"--windowed\00"
@.str1419 = private unnamed_addr constant [11 x i8] c"--headless\00"
@.str1420 = private unnamed_addr constant [12 x i8] c"--emit-llvm\00"
@.str1421 = private unnamed_addr constant [6 x i8] c"--fmt\00"
@.str1422 = private unnamed_addr constant [13 x i8] c"--save-temps\00"
@.str1423 = private unnamed_addr constant [6 x i8] c"--run\00"
@.str1424 = private unnamed_addr constant [3 x i8] c"-o\00"
@.str1425 = private unnamed_addr constant [31 x i8] c"ludicc: ignoring unknown flag \00"
@.str1426 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str1427 = private unnamed_addr constant [90 x i8] c"usage: ludicc <file.ludic> [-o out] [--windowed|--headless] [--emit-llvm] [--save-temps]\0A\00"
@.str1428 = private unnamed_addr constant [27 x i8] c"ludicc: cannot open input\0A\00"
@.str1429 = private unnamed_addr constant [16 x i8] c"/tmp/ludic-run-\00"
@.str1430 = private unnamed_addr constant [10 x i8] c"mkdir -p \00"
@.str1431 = private unnamed_addr constant [4 x i8] c".ll\00"
@.str1432 = private unnamed_addr constant [25 x i8] c"ludicc: cannot write IR\0A\00"
@.str1433 = private unnamed_addr constant [9 x i8] c"LUDIC_CC\00"
@.str1434 = private unnamed_addr constant [6 x i8] c"clang\00"
@.str1435 = private unnamed_addr constant [11 x i8] c"LUDIC_HOME\00"
@.str1436 = private unnamed_addr constant [27 x i8] c" -O2 -Wno-override-module \00"
@.str1437 = private unnamed_addr constant [24 x i8] c"runtime/native/cocoa.ll\00"
@.str1438 = private unnamed_addr constant [2 x i8] c" \00"
@.str1439 = private unnamed_addr constant [42 x i8] c" -framework Cocoa -Wl,-rpath,@loader_path\00"
@.str1440 = private unnamed_addr constant [5 x i8] c" -o \00"
@.str1441 = private unnamed_addr constant [7 x i8] c"rm -f \00"
@.str1442 = private unnamed_addr constant [21 x i8] c"ludicc: link failed\0A\00"
define i32 @fn_streq(ptr %arg_a, ptr %arg_b) {
entry:
  %retval = alloca i32
  %t0 = alloca ptr
  %t1 = alloca ptr
  %t2 = alloca i32
  %t9 = alloca i32
  %t15 = alloca i32
  store ptr %arg_a, ptr %t0
  store ptr %arg_b, ptr %t1
  store i32 0, ptr %t2
  br label %wcond0
wcond0:
  %t3 = icmp ne i32 1, 0
  br i1 %t3, label %wbody1, label %wend2
wbody1:
  %t4 = load ptr, ptr %t0
  %t5 = load i32, ptr %t2
  %t6 = getelementptr inbounds i8, ptr %t4, i32 %t5
  %t7 = load i8, ptr %t6
  %t8 = zext i8 %t7 to i32
  store i32 %t8, ptr %t9
  %t10 = load ptr, ptr %t1
  %t11 = load i32, ptr %t2
  %t12 = getelementptr inbounds i8, ptr %t10, i32 %t11
  %t13 = load i8, ptr %t12
  %t14 = zext i8 %t13 to i32
  store i32 %t14, ptr %t15
  %t16 = load i32, ptr %t9
  %t17 = load i32, ptr %t15
  %t18 = icmp ne i32 %t16, %t17
  %t19 = zext i1 %t18 to i32
  %t20 = icmp ne i32 %t19, 0
  br i1 %t20, label %then3, label %ifend5
then3:
  store i32 0, ptr %retval
  br label %ret
ifend5:
  %t21 = load i32, ptr %t9
  %t22 = icmp eq i32 %t21, 0
  %t23 = zext i1 %t22 to i32
  %t24 = icmp ne i32 %t23, 0
  br i1 %t24, label %then6, label %ifend8
then6:
  store i32 1, ptr %retval
  br label %ret
ifend8:
  %t25 = load i32, ptr %t2
  %t26 = add i32 %t25, 1
  store i32 %t26, ptr %t2
  br label %wcond0
wend2:
  store i32 0, ptr %retval
  br label %ret
ret:
  %t27 = load i32, ptr %retval
  ret i32 %t27
}

define i32 @fn_slen(ptr %arg_s) {
entry:
  %retval = alloca i32
  %t0 = alloca ptr
  %t1 = alloca i32
  store ptr %arg_s, ptr %t0
  store i32 0, ptr %t1
  br label %wcond0
wcond0:
  %t2 = load ptr, ptr %t0
  %t3 = load i32, ptr %t1
  %t4 = getelementptr inbounds i8, ptr %t2, i32 %t3
  %t5 = load i8, ptr %t4
  %t6 = zext i8 %t5 to i32
  %t7 = icmp ne i32 %t6, 0
  %t8 = zext i1 %t7 to i32
  %t9 = icmp ne i32 %t8, 0
  br i1 %t9, label %wbody1, label %wend2
wbody1:
  %t10 = load i32, ptr %t1
  %t11 = add i32 %t10, 1
  store i32 %t11, ptr %t1
  br label %wcond0
wend2:
  %t12 = load i32, ptr %t1
  store i32 %t12, ptr %retval
  br label %ret
ret:
  %t13 = load i32, ptr %retval
  ret i32 %t13
}

define ptr @fn_substr(ptr %arg_src, i32 %arg_start, i32 %arg_n) {
entry:
  %retval = alloca ptr
  %t0 = alloca ptr
  %t1 = alloca i32
  %t2 = alloca i32
  %t7 = alloca ptr
  %t8 = alloca i32
  store ptr %arg_src, ptr %t0
  store i32 %arg_start, ptr %t1
  store i32 %arg_n, ptr %t2
  %t3 = load i32, ptr %t2
  %t4 = add i32 %t3, 1
  %t5 = zext i32 %t4 to i64
  %t6 = call ptr @malloc(i64 %t5)
  store ptr %t6, ptr %t7
  store i32 0, ptr %t8
  br label %wcond0
wcond0:
  %t9 = load i32, ptr %t8
  %t10 = load i32, ptr %t2
  %t11 = icmp slt i32 %t9, %t10
  %t12 = zext i1 %t11 to i32
  %t13 = icmp ne i32 %t12, 0
  br i1 %t13, label %wbody1, label %wend2
wbody1:
  %t14 = load ptr, ptr %t7
  %t15 = load i32, ptr %t8
  %t16 = load ptr, ptr %t0
  %t17 = load i32, ptr %t1
  %t18 = load i32, ptr %t8
  %t19 = add i32 %t17, %t18
  %t20 = getelementptr inbounds i8, ptr %t16, i32 %t19
  %t21 = load i8, ptr %t20
  %t22 = zext i8 %t21 to i32
  %t23 = getelementptr inbounds i8, ptr %t14, i32 %t15
  %t24 = trunc i32 %t22 to i8
  store i8 %t24, ptr %t23
  %t25 = load i32, ptr %t8
  %t26 = add i32 %t25, 1
  store i32 %t26, ptr %t8
  br label %wcond0
wend2:
  %t27 = load ptr, ptr %t7
  %t28 = load i32, ptr %t2
  %t29 = getelementptr inbounds i8, ptr %t27, i32 %t28
  %t30 = trunc i32 0 to i8
  store i8 %t30, ptr %t29
  %t31 = load ptr, ptr %t7
  store ptr %t31, ptr %retval
  br label %ret
ret:
  %t32 = load ptr, ptr %retval
  ret ptr %t32
}

define i32 @fn_char_is_digit(i32 %arg_c) {
entry:
  %retval = alloca i32
  %t0 = alloca i32
  %t1 = alloca i32
  store i32 %arg_c, ptr %t0
  %t2 = load i32, ptr %t0
  %t3 = icmp sge i32 %t2, 48
  %t4 = zext i1 %t3 to i32
  %t5 = icmp ne i32 %t4, 0
  %t6 = zext i1 %t5 to i32
  store i32 %t6, ptr %t1
  br i1 %t5, label %sc0, label %scend1
sc0:
  %t7 = load i32, ptr %t0
  %t8 = icmp sle i32 %t7, 57
  %t9 = zext i1 %t8 to i32
  %t10 = icmp ne i32 %t9, 0
  %t11 = zext i1 %t10 to i32
  store i32 %t11, ptr %t1
  br label %scend1
scend1:
  %t12 = load i32, ptr %t1
  store i32 %t12, ptr %retval
  br label %ret
ret:
  %t13 = load i32, ptr %retval
  ret i32 %t13
}

define i32 @fn_char_is_alpha(i32 %arg_c) {
entry:
  %retval = alloca i32
  %t0 = alloca i32
  %t1 = alloca i32
  %t14 = alloca i32
  store i32 %arg_c, ptr %t0
  %t2 = load i32, ptr %t0
  %t3 = icmp sge i32 %t2, 65
  %t4 = zext i1 %t3 to i32
  %t5 = icmp ne i32 %t4, 0
  %t6 = zext i1 %t5 to i32
  store i32 %t6, ptr %t1
  br i1 %t5, label %sc0, label %scend1
sc0:
  %t7 = load i32, ptr %t0
  %t8 = icmp sle i32 %t7, 90
  %t9 = zext i1 %t8 to i32
  %t10 = icmp ne i32 %t9, 0
  %t11 = zext i1 %t10 to i32
  store i32 %t11, ptr %t1
  br label %scend1
scend1:
  %t12 = load i32, ptr %t1
  %t13 = icmp ne i32 %t12, 0
  br i1 %t13, label %then2, label %ifend4
then2:
  store i32 1, ptr %retval
  br label %ret
ifend4:
  %t15 = load i32, ptr %t0
  %t16 = icmp sge i32 %t15, 97
  %t17 = zext i1 %t16 to i32
  %t18 = icmp ne i32 %t17, 0
  %t19 = zext i1 %t18 to i32
  store i32 %t19, ptr %t14
  br i1 %t18, label %sc5, label %scend6
sc5:
  %t20 = load i32, ptr %t0
  %t21 = icmp sle i32 %t20, 122
  %t22 = zext i1 %t21 to i32
  %t23 = icmp ne i32 %t22, 0
  %t24 = zext i1 %t23 to i32
  store i32 %t24, ptr %t14
  br label %scend6
scend6:
  %t25 = load i32, ptr %t14
  %t26 = icmp ne i32 %t25, 0
  br i1 %t26, label %then7, label %ifend9
then7:
  store i32 1, ptr %retval
  br label %ret
ifend9:
  %t27 = load i32, ptr %t0
  %t28 = icmp eq i32 %t27, 95
  %t29 = zext i1 %t28 to i32
  store i32 %t29, ptr %retval
  br label %ret
ret:
  %t30 = load i32, ptr %retval
  ret i32 %t30
}

define i32 @fn_char_is_alnum(i32 %arg_c) {
entry:
  %retval = alloca i32
  %t0 = alloca i32
  %t1 = alloca i32
  store i32 %arg_c, ptr %t0
  %t2 = load i32, ptr %t0
  %t3 = call i32 @fn_char_is_alpha(i32 %t2)
  %t4 = icmp ne i32 %t3, 0
  %t5 = zext i1 %t4 to i32
  store i32 %t5, ptr %t1
  br i1 %t4, label %scend1, label %sc0
sc0:
  %t6 = load i32, ptr %t0
  %t7 = call i32 @fn_char_is_digit(i32 %t6)
  %t8 = icmp ne i32 %t7, 0
  %t9 = zext i1 %t8 to i32
  store i32 %t9, ptr %t1
  br label %scend1
scend1:
  %t10 = load i32, ptr %t1
  store i32 %t10, ptr %retval
  br label %ret
ret:
  %t11 = load i32, ptr %retval
  ret i32 %t11
}

define ptr @fn_itoa(i32 %arg_v) {
entry:
  %retval = alloca ptr
  %t0 = alloca i32
  %t7 = alloca ptr
  %t15 = alloca i32
  %t17 = alloca i32
  %t26 = alloca ptr
  %t27 = alloca i32
  %t44 = alloca i32
  %t53 = alloca ptr
  %t54 = alloca i32
  %t60 = alloca i32
  store i32 %arg_v, ptr %t0
  %t1 = load i32, ptr %t0
  %t2 = icmp eq i32 %t1, 0
  %t3 = zext i1 %t2 to i32
  %t4 = icmp ne i32 %t3, 0
  br i1 %t4, label %then0, label %ifend2
then0:
  %t5 = zext i32 2 to i64
  %t6 = call ptr @malloc(i64 %t5)
  store ptr %t6, ptr %t7
  %t8 = load ptr, ptr %t7
  %t9 = getelementptr inbounds i8, ptr %t8, i32 0
  %t10 = trunc i32 48 to i8
  store i8 %t10, ptr %t9
  %t11 = load ptr, ptr %t7
  %t12 = getelementptr inbounds i8, ptr %t11, i32 1
  %t13 = trunc i32 0 to i8
  store i8 %t13, ptr %t12
  %t14 = load ptr, ptr %t7
  store ptr %t14, ptr %retval
  br label %ret
ifend2:
  store i32 0, ptr %t15
  %t16 = load i32, ptr %t0
  store i32 %t16, ptr %t17
  %t18 = load i32, ptr %t17
  %t19 = icmp slt i32 %t18, 0
  %t20 = zext i1 %t19 to i32
  %t21 = icmp ne i32 %t20, 0
  br i1 %t21, label %then3, label %ifend5
then3:
  store i32 1, ptr %t15
  %t22 = load i32, ptr %t17
  %t23 = sub i32 0, %t22
  store i32 %t23, ptr %t17
  br label %ifend5
ifend5:
  %t24 = zext i32 16 to i64
  %t25 = call ptr @malloc(i64 %t24)
  store ptr %t25, ptr %t26
  store i32 0, ptr %t27
  br label %wcond6
wcond6:
  %t28 = load i32, ptr %t17
  %t29 = icmp sgt i32 %t28, 0
  %t30 = zext i1 %t29 to i32
  %t31 = icmp ne i32 %t30, 0
  br i1 %t31, label %wbody7, label %wend8
wbody7:
  %t32 = load ptr, ptr %t26
  %t33 = load i32, ptr %t27
  %t34 = load i32, ptr %t17
  %t35 = srem i32 %t34, 10
  %t36 = add i32 48, %t35
  %t37 = getelementptr inbounds i8, ptr %t32, i32 %t33
  %t38 = trunc i32 %t36 to i8
  store i8 %t38, ptr %t37
  %t39 = load i32, ptr %t17
  %t40 = sdiv i32 %t39, 10
  store i32 %t40, ptr %t17
  %t41 = load i32, ptr %t27
  %t42 = add i32 %t41, 1
  store i32 %t42, ptr %t27
  br label %wcond6
wend8:
  %t43 = load i32, ptr %t27
  store i32 %t43, ptr %t44
  %t45 = load i32, ptr %t15
  %t46 = icmp ne i32 %t45, 0
  br i1 %t46, label %then9, label %ifend11
then9:
  %t47 = load i32, ptr %t44
  %t48 = add i32 %t47, 1
  store i32 %t48, ptr %t44
  br label %ifend11
ifend11:
  %t49 = load i32, ptr %t44
  %t50 = add i32 %t49, 1
  %t51 = zext i32 %t50 to i64
  %t52 = call ptr @malloc(i64 %t51)
  store ptr %t52, ptr %t53
  store i32 0, ptr %t54
  %t55 = load i32, ptr %t15
  %t56 = icmp ne i32 %t55, 0
  br i1 %t56, label %then12, label %ifend14
then12:
  %t57 = load ptr, ptr %t53
  %t58 = getelementptr inbounds i8, ptr %t57, i32 0
  %t59 = trunc i32 45 to i8
  store i8 %t59, ptr %t58
  store i32 1, ptr %t54
  br label %ifend14
ifend14:
  store i32 0, ptr %t60
  br label %wcond15
wcond15:
  %t61 = load i32, ptr %t60
  %t62 = load i32, ptr %t27
  %t63 = icmp slt i32 %t61, %t62
  %t64 = zext i1 %t63 to i32
  %t65 = icmp ne i32 %t64, 0
  br i1 %t65, label %wbody16, label %wend17
wbody16:
  %t66 = load ptr, ptr %t53
  %t67 = load i32, ptr %t54
  %t68 = load i32, ptr %t60
  %t69 = add i32 %t67, %t68
  %t70 = load ptr, ptr %t26
  %t71 = load i32, ptr %t27
  %t72 = sub i32 %t71, 1
  %t73 = load i32, ptr %t60
  %t74 = sub i32 %t72, %t73
  %t75 = getelementptr inbounds i8, ptr %t70, i32 %t74
  %t76 = load i8, ptr %t75
  %t77 = zext i8 %t76 to i32
  %t78 = getelementptr inbounds i8, ptr %t66, i32 %t69
  %t79 = trunc i32 %t77 to i8
  store i8 %t79, ptr %t78
  %t80 = load i32, ptr %t60
  %t81 = add i32 %t80, 1
  store i32 %t81, ptr %t60
  br label %wcond15
wend17:
  %t82 = load ptr, ptr %t53
  %t83 = load i32, ptr %t44
  %t84 = getelementptr inbounds i8, ptr %t82, i32 %t83
  %t85 = trunc i32 0 to i8
  store i8 %t85, ptr %t84
  %t86 = load ptr, ptr %t53
  store ptr %t86, ptr %retval
  br label %ret
ret:
  %t87 = load ptr, ptr %retval
  ret ptr %t87
}

define ptr @fn_buf_new() {
entry:
  %retval = alloca ptr
  %t6 = alloca ptr
  %t0 = getelementptr %Str_Buf, ptr null, i32 1
  %t1 = ptrtoint ptr %t0 to i64
  %t2 = call ptr @malloc(i64 %t1)
  %t3 = getelementptr inbounds %Str_Buf, ptr %t2, i32 0, i32 0
  store ptr null, ptr %t3
  %t4 = getelementptr inbounds %Str_Buf, ptr %t2, i32 0, i32 1
  store i32 0, ptr %t4
  %t5 = getelementptr inbounds %Str_Buf, ptr %t2, i32 0, i32 2
  store i32 0, ptr %t5
  store ptr %t2, ptr %t6
  %t7 = load ptr, ptr %t6
  %t8 = getelementptr inbounds %Str_Buf, ptr %t7, i32 0, i32 2
  store i32 256, ptr %t8
  %t9 = load ptr, ptr %t6
  %t10 = getelementptr inbounds %Str_Buf, ptr %t9, i32 0, i32 0
  %t11 = load ptr, ptr %t6
  %t12 = getelementptr inbounds %Str_Buf, ptr %t11, i32 0, i32 2
  %t13 = load i32, ptr %t12
  %t14 = zext i32 %t13 to i64
  %t15 = call ptr @malloc(i64 %t14)
  store ptr %t15, ptr %t10
  %t16 = load ptr, ptr %t6
  %t17 = getelementptr inbounds %Str_Buf, ptr %t16, i32 0, i32 1
  store i32 0, ptr %t17
  %t18 = load ptr, ptr %t6
  store ptr %t18, ptr %retval
  br label %ret
ret:
  %t19 = load ptr, ptr %retval
  ret ptr %t19
}

define void @fn_buf_ensure(ptr %arg_b, i32 %arg_extra) {
entry:
  %t0 = alloca ptr
  %t1 = alloca i32
  store ptr %arg_b, ptr %t0
  store i32 %arg_extra, ptr %t1
  %t2 = load ptr, ptr %t0
  %t3 = getelementptr inbounds %Str_Buf, ptr %t2, i32 0, i32 1
  %t4 = load i32, ptr %t3
  %t5 = load i32, ptr %t1
  %t6 = add i32 %t4, %t5
  %t7 = add i32 %t6, 1
  %t8 = load ptr, ptr %t0
  %t9 = getelementptr inbounds %Str_Buf, ptr %t8, i32 0, i32 2
  %t10 = load i32, ptr %t9
  %t11 = icmp sle i32 %t7, %t10
  %t12 = zext i1 %t11 to i32
  %t13 = icmp ne i32 %t12, 0
  br i1 %t13, label %then0, label %ifend2
then0:
  br label %ret
ifend2:
  br label %wcond3
wcond3:
  %t14 = load ptr, ptr %t0
  %t15 = getelementptr inbounds %Str_Buf, ptr %t14, i32 0, i32 1
  %t16 = load i32, ptr %t15
  %t17 = load i32, ptr %t1
  %t18 = add i32 %t16, %t17
  %t19 = add i32 %t18, 1
  %t20 = load ptr, ptr %t0
  %t21 = getelementptr inbounds %Str_Buf, ptr %t20, i32 0, i32 2
  %t22 = load i32, ptr %t21
  %t23 = icmp sgt i32 %t19, %t22
  %t24 = zext i1 %t23 to i32
  %t25 = icmp ne i32 %t24, 0
  br i1 %t25, label %wbody4, label %wend5
wbody4:
  %t26 = load ptr, ptr %t0
  %t27 = getelementptr inbounds %Str_Buf, ptr %t26, i32 0, i32 2
  %t28 = load ptr, ptr %t0
  %t29 = getelementptr inbounds %Str_Buf, ptr %t28, i32 0, i32 2
  %t30 = load i32, ptr %t29
  %t31 = mul i32 %t30, 2
  store i32 %t31, ptr %t27
  br label %wcond3
wend5:
  %t32 = load ptr, ptr %t0
  %t33 = getelementptr inbounds %Str_Buf, ptr %t32, i32 0, i32 0
  %t34 = load ptr, ptr %t0
  %t35 = getelementptr inbounds %Str_Buf, ptr %t34, i32 0, i32 0
  %t36 = load ptr, ptr %t35
  %t37 = load ptr, ptr %t0
  %t38 = getelementptr inbounds %Str_Buf, ptr %t37, i32 0, i32 2
  %t39 = load i32, ptr %t38
  %t40 = zext i32 %t39 to i64
  %t41 = call ptr @realloc(ptr %t36, i64 %t40)
  store ptr %t41, ptr %t33
  br label %ret
ret:
  ret void
}

define void @fn_buf_putc(ptr %arg_b, i32 %arg_c) {
entry:
  %t0 = alloca ptr
  %t1 = alloca i32
  store ptr %arg_b, ptr %t0
  store i32 %arg_c, ptr %t1
  %t2 = load ptr, ptr %t0
  call void @fn_buf_ensure(ptr %t2, i32 1)
  %t3 = load ptr, ptr %t0
  %t4 = getelementptr inbounds %Str_Buf, ptr %t3, i32 0, i32 0
  %t5 = load ptr, ptr %t4
  %t6 = load ptr, ptr %t0
  %t7 = getelementptr inbounds %Str_Buf, ptr %t6, i32 0, i32 1
  %t8 = load i32, ptr %t7
  %t9 = load i32, ptr %t1
  %t10 = getelementptr inbounds i8, ptr %t5, i32 %t8
  %t11 = trunc i32 %t9 to i8
  store i8 %t11, ptr %t10
  %t12 = load ptr, ptr %t0
  %t13 = getelementptr inbounds %Str_Buf, ptr %t12, i32 0, i32 1
  %t14 = load ptr, ptr %t0
  %t15 = getelementptr inbounds %Str_Buf, ptr %t14, i32 0, i32 1
  %t16 = load i32, ptr %t15
  %t17 = add i32 %t16, 1
  store i32 %t17, ptr %t13
  br label %ret
ret:
  ret void
}

define void @fn_buf_puts(ptr %arg_b, ptr %arg_s) {
entry:
  %t0 = alloca ptr
  %t1 = alloca ptr
  %t2 = alloca i32
  store ptr %arg_b, ptr %t0
  store ptr %arg_s, ptr %t1
  store i32 0, ptr %t2
  br label %wcond0
wcond0:
  %t3 = load ptr, ptr %t1
  %t4 = load i32, ptr %t2
  %t5 = getelementptr inbounds i8, ptr %t3, i32 %t4
  %t6 = load i8, ptr %t5
  %t7 = zext i8 %t6 to i32
  %t8 = icmp ne i32 %t7, 0
  %t9 = zext i1 %t8 to i32
  %t10 = icmp ne i32 %t9, 0
  br i1 %t10, label %wbody1, label %wend2
wbody1:
  %t11 = load ptr, ptr %t0
  %t12 = load ptr, ptr %t1
  %t13 = load i32, ptr %t2
  %t14 = getelementptr inbounds i8, ptr %t12, i32 %t13
  %t15 = load i8, ptr %t14
  %t16 = zext i8 %t15 to i32
  call void @fn_buf_putc(ptr %t11, i32 %t16)
  %t17 = load i32, ptr %t2
  %t18 = add i32 %t17, 1
  store i32 %t18, ptr %t2
  br label %wcond0
wend2:
  br label %ret
ret:
  ret void
}

define void @fn_buf_puti(ptr %arg_b, i32 %arg_n) {
entry:
  %t0 = alloca ptr
  %t1 = alloca i32
  store ptr %arg_b, ptr %t0
  store i32 %arg_n, ptr %t1
  %t2 = load ptr, ptr %t0
  %t3 = load i32, ptr %t1
  %t4 = call ptr @fn_itoa(i32 %t3)
  call void @fn_buf_puts(ptr %t2, ptr %t4)
  br label %ret
ret:
  ret void
}

define ptr @fn_buf_str(ptr %arg_b) {
entry:
  %retval = alloca ptr
  %t0 = alloca ptr
  store ptr %arg_b, ptr %t0
  %t1 = load ptr, ptr %t0
  %t2 = getelementptr inbounds %Str_Buf, ptr %t1, i32 0, i32 0
  %t3 = load ptr, ptr %t2
  %t4 = load ptr, ptr %t0
  %t5 = getelementptr inbounds %Str_Buf, ptr %t4, i32 0, i32 1
  %t6 = load i32, ptr %t5
  %t7 = getelementptr inbounds i8, ptr %t3, i32 %t6
  %t8 = trunc i32 0 to i8
  store i8 %t8, ptr %t7
  %t9 = load ptr, ptr %t0
  %t10 = getelementptr inbounds %Str_Buf, ptr %t9, i32 0, i32 0
  %t11 = load ptr, ptr %t10
  store ptr %t11, ptr %retval
  br label %ret
ret:
  %t12 = load ptr, ptr %retval
  ret ptr %t12
}

define ptr @fn_read_file(ptr %arg_path) {
entry:
  %retval = alloca ptr
  %t0 = alloca ptr
  %t3 = alloca ptr
  %t14 = alloca i32
  %t22 = alloca ptr
  store ptr %arg_path, ptr %t0
  %t1 = load ptr, ptr %t0
  %t2 = call ptr @fopen(ptr %t1, ptr @.str0)
  store ptr %t2, ptr %t3
  %t4 = load ptr, ptr %t3
  %t5 = icmp eq ptr %t4, null
  %t6 = zext i1 %t5 to i32
  %t7 = icmp ne i32 %t6, 0
  br i1 %t7, label %then0, label %ifend2
then0:
  store ptr null, ptr %retval
  br label %ret
ifend2:
  %t8 = load ptr, ptr %t3
  %t9 = sext i32 0 to i64
  %t10 = call i32 @fseek(ptr %t8, i64 %t9, i32 2)
  %t11 = load ptr, ptr %t3
  %t12 = call i64 @ftell(ptr %t11)
  %t13 = trunc i64 %t12 to i32
  store i32 %t13, ptr %t14
  %t15 = load ptr, ptr %t3
  %t16 = sext i32 0 to i64
  %t17 = call i32 @fseek(ptr %t15, i64 %t16, i32 0)
  %t18 = load i32, ptr %t14
  %t19 = add i32 %t18, 1
  %t20 = zext i32 %t19 to i64
  %t21 = call ptr @malloc(i64 %t20)
  store ptr %t21, ptr %t22
  %t23 = load ptr, ptr %t3
  %t24 = load ptr, ptr %t22
  %t25 = load i32, ptr %t14
  %t26 = zext i32 %t25 to i64
  %t27 = call i64 @fread(ptr %t24, i64 1, i64 %t26, ptr %t23)
  %t28 = trunc i64 %t27 to i32
  %t29 = load ptr, ptr %t22
  %t30 = load i32, ptr %t14
  %t31 = getelementptr inbounds i8, ptr %t29, i32 %t30
  %t32 = trunc i32 0 to i8
  store i8 %t32, ptr %t31
  %t33 = load ptr, ptr %t3
  call i32 @fclose(ptr %t33)
  %t34 = load ptr, ptr %t22
  store ptr %t34, ptr %retval
  br label %ret
ret:
  %t35 = load ptr, ptr %retval
  ret ptr %t35
}

define i32 @fn_cstr_len(ptr %arg_s) {
entry:
  %retval = alloca i32
  %t0 = alloca ptr
  %t1 = alloca i32
  store ptr %arg_s, ptr %t0
  store i32 0, ptr %t1
  br label %wcond0
wcond0:
  %t2 = load ptr, ptr %t0
  %t3 = load i32, ptr %t1
  %t4 = getelementptr inbounds i8, ptr %t2, i32 %t3
  %t5 = load i8, ptr %t4
  %t6 = zext i8 %t5 to i32
  %t7 = icmp ne i32 %t6, 0
  %t8 = zext i1 %t7 to i32
  %t9 = icmp ne i32 %t8, 0
  br i1 %t9, label %wbody1, label %wend2
wbody1:
  %t10 = load i32, ptr %t1
  %t11 = add i32 %t10, 1
  store i32 %t11, ptr %t1
  br label %wcond0
wend2:
  %t12 = load i32, ptr %t1
  store i32 %t12, ptr %retval
  br label %ret
ret:
  %t13 = load i32, ptr %retval
  ret i32 %t13
}

define ptr @fn_node(i32 %arg_kind) {
entry:
  %retval = alloca ptr
  %t0 = alloca i32
  %t13 = alloca ptr
  store i32 %arg_kind, ptr %t0
  %t1 = getelementptr %Str_Node, ptr null, i32 1
  %t2 = ptrtoint ptr %t1 to i64
  %t3 = call ptr @malloc(i64 %t2)
  %t4 = getelementptr inbounds %Str_Node, ptr %t3, i32 0, i32 0
  store i32 0, ptr %t4
  %t5 = getelementptr inbounds %Str_Node, ptr %t3, i32 0, i32 1
  store ptr null, ptr %t5
  %t6 = getelementptr inbounds %Str_Node, ptr %t3, i32 0, i32 2
  store i32 0, ptr %t6
  %t7 = getelementptr inbounds %Str_Node, ptr %t3, i32 0, i32 3
  store ptr null, ptr %t7
  %t8 = getelementptr inbounds %Str_Node, ptr %t3, i32 0, i32 4
  store ptr null, ptr %t8
  %t9 = getelementptr inbounds %Str_Node, ptr %t3, i32 0, i32 5
  store ptr null, ptr %t9
  %t10 = getelementptr inbounds %Str_Node, ptr %t3, i32 0, i32 6
  store ptr null, ptr %t10
  %t11 = getelementptr inbounds %Str_Node, ptr %t3, i32 0, i32 7
  store ptr null, ptr %t11
  %t12 = getelementptr inbounds %Str_Node, ptr %t3, i32 0, i32 8
  store i32 0, ptr %t12
  store ptr %t3, ptr %t13
  %t14 = load ptr, ptr %t13
  %t15 = getelementptr inbounds %Str_Node, ptr %t14, i32 0, i32 0
  %t16 = load i32, ptr %t0
  store i32 %t16, ptr %t15
  %t17 = load ptr, ptr %t13
  %t18 = getelementptr inbounds %Str_Node, ptr %t17, i32 0, i32 7
  %t19 = getelementptr %LSlice, ptr null, i32 1
  %t20 = ptrtoint ptr %t19 to i64
  %t21 = call ptr @malloc(i64 %t20)
  %t22 = getelementptr inbounds %LSlice, ptr %t21, i32 0, i32 0
  store ptr null, ptr %t22
  %t23 = getelementptr inbounds %LSlice, ptr %t21, i32 0, i32 1
  store i32 0, ptr %t23
  %t24 = getelementptr inbounds %LSlice, ptr %t21, i32 0, i32 2
  store i32 0, ptr %t24
  store ptr %t21, ptr %t18
  %t25 = load ptr, ptr %t13
  store ptr %t25, ptr %retval
  br label %ret
ret:
  %t26 = load ptr, ptr %retval
  ret ptr %t26
}

define void @fn_tok_push(i32 %arg_kind, ptr %arg_text, i32 %arg_ival, i32 %arg_line) {
entry:
  %t0 = alloca i32
  %t1 = alloca ptr
  %t2 = alloca i32
  %t3 = alloca i32
  %t11 = alloca ptr
  store i32 %arg_kind, ptr %t0
  store ptr %arg_text, ptr %t1
  store i32 %arg_ival, ptr %t2
  store i32 %arg_line, ptr %t3
  %t4 = getelementptr %Str_Tok, ptr null, i32 1
  %t5 = ptrtoint ptr %t4 to i64
  %t6 = call ptr @malloc(i64 %t5)
  %t7 = getelementptr inbounds %Str_Tok, ptr %t6, i32 0, i32 0
  store i32 0, ptr %t7
  %t8 = getelementptr inbounds %Str_Tok, ptr %t6, i32 0, i32 1
  store ptr null, ptr %t8
  %t9 = getelementptr inbounds %Str_Tok, ptr %t6, i32 0, i32 2
  store i32 0, ptr %t9
  %t10 = getelementptr inbounds %Str_Tok, ptr %t6, i32 0, i32 3
  store i32 0, ptr %t10
  store ptr %t6, ptr %t11
  %t12 = load ptr, ptr %t11
  %t13 = getelementptr inbounds %Str_Tok, ptr %t12, i32 0, i32 0
  %t14 = load i32, ptr %t0
  store i32 %t14, ptr %t13
  %t15 = load ptr, ptr %t11
  %t16 = getelementptr inbounds %Str_Tok, ptr %t15, i32 0, i32 1
  %t17 = load ptr, ptr %t1
  store ptr %t17, ptr %t16
  %t18 = load ptr, ptr %t11
  %t19 = getelementptr inbounds %Str_Tok, ptr %t18, i32 0, i32 2
  %t20 = load i32, ptr %t2
  store i32 %t20, ptr %t19
  %t21 = load ptr, ptr %t11
  %t22 = getelementptr inbounds %Str_Tok, ptr %t21, i32 0, i32 3
  %t23 = load i32, ptr %t3
  store i32 %t23, ptr %t22
  %t24 = load ptr, ptr @g_toks
  %t25 = getelementptr inbounds %LSlice, ptr %t24, i32 0, i32 1
  %t26 = getelementptr inbounds %LSlice, ptr %t24, i32 0, i32 2
  %t27 = getelementptr inbounds %LSlice, ptr %t24, i32 0, i32 0
  %t28 = load i32, ptr %t25
  %t29 = load i32, ptr %t26
  %t30 = icmp sge i32 %t28, %t29
  br i1 %t30, label %grow0, label %put1
grow0:
  %t31 = mul i32 %t29, 2
  %t32 = icmp eq i32 %t29, 0
  %t33 = select i1 %t32, i32 8, i32 %t31
  %t34 = getelementptr ptr, ptr null, i32 1
  %t35 = ptrtoint ptr %t34 to i64
  %t36 = zext i32 %t33 to i64
  %t37 = mul i64 %t36, %t35
  %t38 = load ptr, ptr %t27
  %t39 = call ptr @realloc(ptr %t38, i64 %t37)
  store ptr %t39, ptr %t27
  store i32 %t33, ptr %t26
  br label %put1
put1:
  %t40 = load ptr, ptr %t11
  %t41 = load ptr, ptr %t27
  %t42 = getelementptr inbounds ptr, ptr %t41, i32 %t28
  store ptr %t40, ptr %t42
  %t43 = add i32 %t28, 1
  store i32 %t43, ptr %t25
  br label %ret
ret:
  ret void
}

define i32 @fn_two_at(ptr %arg_src, i32 %arg_i, i32 %arg_a, i32 %arg_b) {
entry:
  %retval = alloca i32
  %t0 = alloca ptr
  %t1 = alloca i32
  %t2 = alloca i32
  %t3 = alloca i32
  %t4 = alloca i32
  store ptr %arg_src, ptr %t0
  store i32 %arg_i, ptr %t1
  store i32 %arg_a, ptr %t2
  store i32 %arg_b, ptr %t3
  %t5 = load ptr, ptr %t0
  %t6 = load i32, ptr %t1
  %t7 = getelementptr inbounds i8, ptr %t5, i32 %t6
  %t8 = load i8, ptr %t7
  %t9 = zext i8 %t8 to i32
  %t10 = load i32, ptr %t2
  %t11 = icmp eq i32 %t9, %t10
  %t12 = zext i1 %t11 to i32
  %t13 = icmp ne i32 %t12, 0
  %t14 = zext i1 %t13 to i32
  store i32 %t14, ptr %t4
  br i1 %t13, label %sc0, label %scend1
sc0:
  %t15 = load ptr, ptr %t0
  %t16 = load i32, ptr %t1
  %t17 = add i32 %t16, 1
  %t18 = getelementptr inbounds i8, ptr %t15, i32 %t17
  %t19 = load i8, ptr %t18
  %t20 = zext i8 %t19 to i32
  %t21 = load i32, ptr %t3
  %t22 = icmp eq i32 %t20, %t21
  %t23 = zext i1 %t22 to i32
  %t24 = icmp ne i32 %t23, 0
  %t25 = zext i1 %t24 to i32
  store i32 %t25, ptr %t4
  br label %scend1
scend1:
  %t26 = load i32, ptr %t4
  store i32 %t26, ptr %retval
  br label %ret
ret:
  %t27 = load i32, ptr %retval
  ret i32 %t27
}

define i32 @fn_is_op1(i32 %arg_c) {
entry:
  %retval = alloca i32
  %t0 = alloca i32
  %t1 = alloca i32
  %t2 = alloca i32
  %t3 = alloca i32
  %t4 = alloca i32
  %t41 = alloca i32
  %t42 = alloca i32
  %t63 = alloca i32
  %t64 = alloca i32
  %t65 = alloca i32
  %t94 = alloca i32
  %t95 = alloca i32
  %t96 = alloca i32
  %t97 = alloca i32
  %t134 = alloca i32
  store i32 %arg_c, ptr %t0
  %t5 = load i32, ptr %t0
  %t6 = icmp eq i32 %t5, 43
  %t7 = zext i1 %t6 to i32
  %t8 = icmp ne i32 %t7, 0
  %t9 = zext i1 %t8 to i32
  store i32 %t9, ptr %t4
  br i1 %t8, label %scend1, label %sc0
sc0:
  %t10 = load i32, ptr %t0
  %t11 = icmp eq i32 %t10, 45
  %t12 = zext i1 %t11 to i32
  %t13 = icmp ne i32 %t12, 0
  %t14 = zext i1 %t13 to i32
  store i32 %t14, ptr %t4
  br label %scend1
scend1:
  %t15 = load i32, ptr %t4
  %t16 = icmp ne i32 %t15, 0
  %t17 = zext i1 %t16 to i32
  store i32 %t17, ptr %t3
  br i1 %t16, label %scend3, label %sc2
sc2:
  %t18 = load i32, ptr %t0
  %t19 = icmp eq i32 %t18, 42
  %t20 = zext i1 %t19 to i32
  %t21 = icmp ne i32 %t20, 0
  %t22 = zext i1 %t21 to i32
  store i32 %t22, ptr %t3
  br label %scend3
scend3:
  %t23 = load i32, ptr %t3
  %t24 = icmp ne i32 %t23, 0
  %t25 = zext i1 %t24 to i32
  store i32 %t25, ptr %t2
  br i1 %t24, label %scend5, label %sc4
sc4:
  %t26 = load i32, ptr %t0
  %t27 = icmp eq i32 %t26, 47
  %t28 = zext i1 %t27 to i32
  %t29 = icmp ne i32 %t28, 0
  %t30 = zext i1 %t29 to i32
  store i32 %t30, ptr %t2
  br label %scend5
scend5:
  %t31 = load i32, ptr %t2
  %t32 = icmp ne i32 %t31, 0
  %t33 = zext i1 %t32 to i32
  store i32 %t33, ptr %t1
  br i1 %t32, label %scend7, label %sc6
sc6:
  %t34 = load i32, ptr %t0
  %t35 = icmp eq i32 %t34, 37
  %t36 = zext i1 %t35 to i32
  %t37 = icmp ne i32 %t36, 0
  %t38 = zext i1 %t37 to i32
  store i32 %t38, ptr %t1
  br label %scend7
scend7:
  %t39 = load i32, ptr %t1
  %t40 = icmp ne i32 %t39, 0
  br i1 %t40, label %then8, label %ifend10
then8:
  store i32 1, ptr %retval
  br label %ret
ifend10:
  %t43 = load i32, ptr %t0
  %t44 = icmp eq i32 %t43, 60
  %t45 = zext i1 %t44 to i32
  %t46 = icmp ne i32 %t45, 0
  %t47 = zext i1 %t46 to i32
  store i32 %t47, ptr %t42
  br i1 %t46, label %scend12, label %sc11
sc11:
  %t48 = load i32, ptr %t0
  %t49 = icmp eq i32 %t48, 62
  %t50 = zext i1 %t49 to i32
  %t51 = icmp ne i32 %t50, 0
  %t52 = zext i1 %t51 to i32
  store i32 %t52, ptr %t42
  br label %scend12
scend12:
  %t53 = load i32, ptr %t42
  %t54 = icmp ne i32 %t53, 0
  %t55 = zext i1 %t54 to i32
  store i32 %t55, ptr %t41
  br i1 %t54, label %scend14, label %sc13
sc13:
  %t56 = load i32, ptr %t0
  %t57 = icmp eq i32 %t56, 61
  %t58 = zext i1 %t57 to i32
  %t59 = icmp ne i32 %t58, 0
  %t60 = zext i1 %t59 to i32
  store i32 %t60, ptr %t41
  br label %scend14
scend14:
  %t61 = load i32, ptr %t41
  %t62 = icmp ne i32 %t61, 0
  br i1 %t62, label %then15, label %ifend17
then15:
  store i32 1, ptr %retval
  br label %ret
ifend17:
  %t66 = load i32, ptr %t0
  %t67 = icmp eq i32 %t66, 40
  %t68 = zext i1 %t67 to i32
  %t69 = icmp ne i32 %t68, 0
  %t70 = zext i1 %t69 to i32
  store i32 %t70, ptr %t65
  br i1 %t69, label %scend19, label %sc18
sc18:
  %t71 = load i32, ptr %t0
  %t72 = icmp eq i32 %t71, 41
  %t73 = zext i1 %t72 to i32
  %t74 = icmp ne i32 %t73, 0
  %t75 = zext i1 %t74 to i32
  store i32 %t75, ptr %t65
  br label %scend19
scend19:
  %t76 = load i32, ptr %t65
  %t77 = icmp ne i32 %t76, 0
  %t78 = zext i1 %t77 to i32
  store i32 %t78, ptr %t64
  br i1 %t77, label %scend21, label %sc20
sc20:
  %t79 = load i32, ptr %t0
  %t80 = icmp eq i32 %t79, 123
  %t81 = zext i1 %t80 to i32
  %t82 = icmp ne i32 %t81, 0
  %t83 = zext i1 %t82 to i32
  store i32 %t83, ptr %t64
  br label %scend21
scend21:
  %t84 = load i32, ptr %t64
  %t85 = icmp ne i32 %t84, 0
  %t86 = zext i1 %t85 to i32
  store i32 %t86, ptr %t63
  br i1 %t85, label %scend23, label %sc22
sc22:
  %t87 = load i32, ptr %t0
  %t88 = icmp eq i32 %t87, 125
  %t89 = zext i1 %t88 to i32
  %t90 = icmp ne i32 %t89, 0
  %t91 = zext i1 %t90 to i32
  store i32 %t91, ptr %t63
  br label %scend23
scend23:
  %t92 = load i32, ptr %t63
  %t93 = icmp ne i32 %t92, 0
  br i1 %t93, label %then24, label %ifend26
then24:
  store i32 1, ptr %retval
  br label %ret
ifend26:
  %t98 = load i32, ptr %t0
  %t99 = icmp eq i32 %t98, 91
  %t100 = zext i1 %t99 to i32
  %t101 = icmp ne i32 %t100, 0
  %t102 = zext i1 %t101 to i32
  store i32 %t102, ptr %t97
  br i1 %t101, label %scend28, label %sc27
sc27:
  %t103 = load i32, ptr %t0
  %t104 = icmp eq i32 %t103, 93
  %t105 = zext i1 %t104 to i32
  %t106 = icmp ne i32 %t105, 0
  %t107 = zext i1 %t106 to i32
  store i32 %t107, ptr %t97
  br label %scend28
scend28:
  %t108 = load i32, ptr %t97
  %t109 = icmp ne i32 %t108, 0
  %t110 = zext i1 %t109 to i32
  store i32 %t110, ptr %t96
  br i1 %t109, label %scend30, label %sc29
sc29:
  %t111 = load i32, ptr %t0
  %t112 = icmp eq i32 %t111, 44
  %t113 = zext i1 %t112 to i32
  %t114 = icmp ne i32 %t113, 0
  %t115 = zext i1 %t114 to i32
  store i32 %t115, ptr %t96
  br label %scend30
scend30:
  %t116 = load i32, ptr %t96
  %t117 = icmp ne i32 %t116, 0
  %t118 = zext i1 %t117 to i32
  store i32 %t118, ptr %t95
  br i1 %t117, label %scend32, label %sc31
sc31:
  %t119 = load i32, ptr %t0
  %t120 = icmp eq i32 %t119, 58
  %t121 = zext i1 %t120 to i32
  %t122 = icmp ne i32 %t121, 0
  %t123 = zext i1 %t122 to i32
  store i32 %t123, ptr %t95
  br label %scend32
scend32:
  %t124 = load i32, ptr %t95
  %t125 = icmp ne i32 %t124, 0
  %t126 = zext i1 %t125 to i32
  store i32 %t126, ptr %t94
  br i1 %t125, label %scend34, label %sc33
sc33:
  %t127 = load i32, ptr %t0
  %t128 = icmp eq i32 %t127, 46
  %t129 = zext i1 %t128 to i32
  %t130 = icmp ne i32 %t129, 0
  %t131 = zext i1 %t130 to i32
  store i32 %t131, ptr %t94
  br label %scend34
scend34:
  %t132 = load i32, ptr %t94
  %t133 = icmp ne i32 %t132, 0
  br i1 %t133, label %then35, label %ifend37
then35:
  store i32 1, ptr %retval
  br label %ret
ifend37:
  %t135 = load i32, ptr %t0
  %t136 = icmp eq i32 %t135, 33
  %t137 = zext i1 %t136 to i32
  %t138 = icmp ne i32 %t137, 0
  %t139 = zext i1 %t138 to i32
  store i32 %t139, ptr %t134
  br i1 %t138, label %scend39, label %sc38
sc38:
  %t140 = load i32, ptr %t0
  %t141 = icmp eq i32 %t140, 64
  %t142 = zext i1 %t141 to i32
  %t143 = icmp ne i32 %t142, 0
  %t144 = zext i1 %t143 to i32
  store i32 %t144, ptr %t134
  br label %scend39
scend39:
  %t145 = load i32, ptr %t134
  %t146 = icmp ne i32 %t145, 0
  br i1 %t146, label %then40, label %ifend42
then40:
  store i32 1, ptr %retval
  br label %ret
ifend42:
  store i32 0, ptr %retval
  br label %ret
ret:
  %t147 = load i32, ptr %retval
  ret i32 %t147
}

define void @fn_lex(ptr %arg_src) {
entry:
  %t0 = alloca ptr
  %t7 = alloca i32
  %t8 = alloca i32
  %t11 = alloca i32
  %t22 = alloca i32
  %t32 = alloca i32
  %t33 = alloca i32
  %t60 = alloca i32
  %t87 = alloca i32
  %t91 = alloca ptr
  %t92 = alloca i32
  %t93 = alloca i32
  %t125 = alloca i32
  %t127 = alloca i32
  %t176 = alloca i32
  %t191 = alloca i32
  %t228 = alloca i32
  %t246 = alloca i32
  %t259 = alloca i32
  %t260 = alloca i32
  %t266 = alloca i32
  %t281 = alloca i32
  %t304 = alloca i32
  %t305 = alloca i32
  %t333 = alloca i32
  %t334 = alloca i32
  %t366 = alloca i32
  %t367 = alloca i32
  %t368 = alloca i32
  %t405 = alloca i32
  %t414 = alloca i32
  %t415 = alloca i32
  store ptr %arg_src, ptr %t0
  %t1 = getelementptr %LSlice, ptr null, i32 1
  %t2 = ptrtoint ptr %t1 to i64
  %t3 = call ptr @malloc(i64 %t2)
  %t4 = getelementptr inbounds %LSlice, ptr %t3, i32 0, i32 0
  store ptr null, ptr %t4
  %t5 = getelementptr inbounds %LSlice, ptr %t3, i32 0, i32 1
  store i32 0, ptr %t5
  %t6 = getelementptr inbounds %LSlice, ptr %t3, i32 0, i32 2
  store i32 0, ptr %t6
  store ptr %t3, ptr @g_toks
  store i32 0, ptr %t7
  store i32 1, ptr %t8
  %t9 = load ptr, ptr %t0
  %t10 = call i32 @fn_slen(ptr %t9)
  store i32 %t10, ptr %t11
  br label %wcond0
wcond0:
  %t12 = load i32, ptr %t7
  %t13 = load i32, ptr %t11
  %t14 = icmp slt i32 %t12, %t13
  %t15 = zext i1 %t14 to i32
  %t16 = icmp ne i32 %t15, 0
  br i1 %t16, label %wbody1, label %wend2
wbody1:
  %t17 = load ptr, ptr %t0
  %t18 = load i32, ptr %t7
  %t19 = getelementptr inbounds i8, ptr %t17, i32 %t18
  %t20 = load i8, ptr %t19
  %t21 = zext i8 %t20 to i32
  store i32 %t21, ptr %t22
  %t23 = load i32, ptr %t22
  %t24 = icmp eq i32 %t23, 10
  %t25 = zext i1 %t24 to i32
  %t26 = icmp ne i32 %t25, 0
  br i1 %t26, label %then3, label %ifend5
then3:
  %t27 = load i32, ptr %t8
  call void @fn_tok_push(i32 4, ptr null, i32 0, i32 %t27)
  %t28 = load i32, ptr %t8
  %t29 = add i32 %t28, 1
  store i32 %t29, ptr %t8
  %t30 = load i32, ptr %t7
  %t31 = add i32 %t30, 1
  store i32 %t31, ptr %t7
  br label %wcond0
ifend5:
  %t34 = load i32, ptr %t22
  %t35 = icmp eq i32 %t34, 32
  %t36 = zext i1 %t35 to i32
  %t37 = icmp ne i32 %t36, 0
  %t38 = zext i1 %t37 to i32
  store i32 %t38, ptr %t33
  br i1 %t37, label %scend7, label %sc6
sc6:
  %t39 = load i32, ptr %t22
  %t40 = icmp eq i32 %t39, 9
  %t41 = zext i1 %t40 to i32
  %t42 = icmp ne i32 %t41, 0
  %t43 = zext i1 %t42 to i32
  store i32 %t43, ptr %t33
  br label %scend7
scend7:
  %t44 = load i32, ptr %t33
  %t45 = icmp ne i32 %t44, 0
  %t46 = zext i1 %t45 to i32
  store i32 %t46, ptr %t32
  br i1 %t45, label %scend9, label %sc8
sc8:
  %t47 = load i32, ptr %t22
  %t48 = icmp eq i32 %t47, 13
  %t49 = zext i1 %t48 to i32
  %t50 = icmp ne i32 %t49, 0
  %t51 = zext i1 %t50 to i32
  store i32 %t51, ptr %t32
  br label %scend9
scend9:
  %t52 = load i32, ptr %t32
  %t53 = icmp ne i32 %t52, 0
  br i1 %t53, label %then10, label %ifend12
then10:
  %t54 = load i32, ptr %t7
  %t55 = add i32 %t54, 1
  store i32 %t55, ptr %t7
  br label %wcond0
ifend12:
  %t56 = load i32, ptr %t22
  %t57 = icmp eq i32 %t56, 35
  %t58 = zext i1 %t57 to i32
  %t59 = icmp ne i32 %t58, 0
  br i1 %t59, label %then13, label %ifend15
then13:
  br label %wcond16
wcond16:
  %t61 = load i32, ptr %t7
  %t62 = load i32, ptr %t11
  %t63 = icmp slt i32 %t61, %t62
  %t64 = zext i1 %t63 to i32
  %t65 = icmp ne i32 %t64, 0
  %t66 = zext i1 %t65 to i32
  store i32 %t66, ptr %t60
  br i1 %t65, label %sc19, label %scend20
sc19:
  %t67 = load ptr, ptr %t0
  %t68 = load i32, ptr %t7
  %t69 = getelementptr inbounds i8, ptr %t67, i32 %t68
  %t70 = load i8, ptr %t69
  %t71 = zext i8 %t70 to i32
  %t72 = icmp ne i32 %t71, 10
  %t73 = zext i1 %t72 to i32
  %t74 = icmp ne i32 %t73, 0
  %t75 = zext i1 %t74 to i32
  store i32 %t75, ptr %t60
  br label %scend20
scend20:
  %t76 = load i32, ptr %t60
  %t77 = icmp ne i32 %t76, 0
  br i1 %t77, label %wbody17, label %wend18
wbody17:
  %t78 = load i32, ptr %t7
  %t79 = add i32 %t78, 1
  store i32 %t79, ptr %t7
  br label %wcond16
wend18:
  br label %wcond0
ifend15:
  %t80 = load i32, ptr %t22
  %t81 = icmp eq i32 %t80, 34
  %t82 = zext i1 %t81 to i32
  %t83 = icmp ne i32 %t82, 0
  br i1 %t83, label %then21, label %ifend23
then21:
  %t84 = load i32, ptr %t7
  %t85 = add i32 %t84, 1
  store i32 %t85, ptr %t7
  %t86 = load i32, ptr %t7
  store i32 %t86, ptr %t87
  %t88 = load i32, ptr %t11
  %t89 = zext i32 %t88 to i64
  %t90 = call ptr @malloc(i64 %t89)
  store ptr %t90, ptr %t91
  store i32 0, ptr %t92
  br label %wcond24
wcond24:
  %t94 = load i32, ptr %t7
  %t95 = load i32, ptr %t11
  %t96 = icmp slt i32 %t94, %t95
  %t97 = zext i1 %t96 to i32
  %t98 = icmp ne i32 %t97, 0
  %t99 = zext i1 %t98 to i32
  store i32 %t99, ptr %t93
  br i1 %t98, label %sc27, label %scend28
sc27:
  %t100 = load ptr, ptr %t0
  %t101 = load i32, ptr %t7
  %t102 = getelementptr inbounds i8, ptr %t100, i32 %t101
  %t103 = load i8, ptr %t102
  %t104 = zext i8 %t103 to i32
  %t105 = icmp ne i32 %t104, 34
  %t106 = zext i1 %t105 to i32
  %t107 = icmp ne i32 %t106, 0
  %t108 = zext i1 %t107 to i32
  store i32 %t108, ptr %t93
  br label %scend28
scend28:
  %t109 = load i32, ptr %t93
  %t110 = icmp ne i32 %t109, 0
  br i1 %t110, label %wbody25, label %wend26
wbody25:
  %t111 = load ptr, ptr %t0
  %t112 = load i32, ptr %t7
  %t113 = getelementptr inbounds i8, ptr %t111, i32 %t112
  %t114 = load i8, ptr %t113
  %t115 = zext i8 %t114 to i32
  %t116 = icmp eq i32 %t115, 92
  %t117 = zext i1 %t116 to i32
  %t118 = icmp ne i32 %t117, 0
  br i1 %t118, label %then29, label %else30
then29:
  %t119 = load ptr, ptr %t0
  %t120 = load i32, ptr %t7
  %t121 = add i32 %t120, 1
  %t122 = getelementptr inbounds i8, ptr %t119, i32 %t121
  %t123 = load i8, ptr %t122
  %t124 = zext i8 %t123 to i32
  store i32 %t124, ptr %t125
  %t126 = load i32, ptr %t125
  store i32 %t126, ptr %t127
  %t128 = load i32, ptr %t125
  %t129 = icmp eq i32 %t128, 110
  %t130 = zext i1 %t129 to i32
  %t131 = icmp ne i32 %t130, 0
  br i1 %t131, label %then32, label %ifend34
then32:
  store i32 10, ptr %t127
  br label %ifend34
ifend34:
  %t132 = load i32, ptr %t125
  %t133 = icmp eq i32 %t132, 116
  %t134 = zext i1 %t133 to i32
  %t135 = icmp ne i32 %t134, 0
  br i1 %t135, label %then35, label %ifend37
then35:
  store i32 9, ptr %t127
  br label %ifend37
ifend37:
  %t136 = load i32, ptr %t125
  %t137 = icmp eq i32 %t136, 48
  %t138 = zext i1 %t137 to i32
  %t139 = icmp ne i32 %t138, 0
  br i1 %t139, label %then38, label %ifend40
then38:
  store i32 0, ptr %t127
  br label %ifend40
ifend40:
  %t140 = load ptr, ptr %t91
  %t141 = load i32, ptr %t92
  %t142 = load i32, ptr %t127
  %t143 = getelementptr inbounds i8, ptr %t140, i32 %t141
  %t144 = trunc i32 %t142 to i8
  store i8 %t144, ptr %t143
  %t145 = load i32, ptr %t92
  %t146 = add i32 %t145, 1
  store i32 %t146, ptr %t92
  %t147 = load i32, ptr %t7
  %t148 = add i32 %t147, 2
  store i32 %t148, ptr %t7
  br label %ifend31
else30:
  %t149 = load ptr, ptr %t91
  %t150 = load i32, ptr %t92
  %t151 = load ptr, ptr %t0
  %t152 = load i32, ptr %t7
  %t153 = getelementptr inbounds i8, ptr %t151, i32 %t152
  %t154 = load i8, ptr %t153
  %t155 = zext i8 %t154 to i32
  %t156 = getelementptr inbounds i8, ptr %t149, i32 %t150
  %t157 = trunc i32 %t155 to i8
  store i8 %t157, ptr %t156
  %t158 = load i32, ptr %t92
  %t159 = add i32 %t158, 1
  store i32 %t159, ptr %t92
  %t160 = load i32, ptr %t7
  %t161 = add i32 %t160, 1
  store i32 %t161, ptr %t7
  br label %ifend31
ifend31:
  br label %wcond24
wend26:
  %t162 = load i32, ptr %t7
  %t163 = add i32 %t162, 1
  store i32 %t163, ptr %t7
  %t164 = load ptr, ptr %t91
  %t165 = load i32, ptr %t92
  %t166 = getelementptr inbounds i8, ptr %t164, i32 %t165
  %t167 = trunc i32 0 to i8
  store i8 %t167, ptr %t166
  %t168 = load ptr, ptr %t91
  %t169 = load i32, ptr %t8
  call void @fn_tok_push(i32 2, ptr %t168, i32 0, i32 %t169)
  br label %wcond0
ifend23:
  %t170 = load i32, ptr %t22
  %t171 = icmp eq i32 %t170, 39
  %t172 = zext i1 %t171 to i32
  %t173 = icmp ne i32 %t172, 0
  br i1 %t173, label %then41, label %ifend43
then41:
  %t174 = load i32, ptr %t7
  %t175 = add i32 %t174, 1
  store i32 %t175, ptr %t7
  store i32 0, ptr %t176
  %t177 = load ptr, ptr %t0
  %t178 = load i32, ptr %t7
  %t179 = getelementptr inbounds i8, ptr %t177, i32 %t178
  %t180 = load i8, ptr %t179
  %t181 = zext i8 %t180 to i32
  %t182 = icmp eq i32 %t181, 92
  %t183 = zext i1 %t182 to i32
  %t184 = icmp ne i32 %t183, 0
  br i1 %t184, label %then44, label %else45
then44:
  %t185 = load ptr, ptr %t0
  %t186 = load i32, ptr %t7
  %t187 = add i32 %t186, 1
  %t188 = getelementptr inbounds i8, ptr %t185, i32 %t187
  %t189 = load i8, ptr %t188
  %t190 = zext i8 %t189 to i32
  store i32 %t190, ptr %t191
  %t192 = load i32, ptr %t191
  %t193 = icmp eq i32 %t192, 110
  %t194 = zext i1 %t193 to i32
  %t195 = icmp ne i32 %t194, 0
  br i1 %t195, label %then47, label %ifend49
then47:
  store i32 10, ptr %t176
  br label %ifend49
ifend49:
  %t196 = load i32, ptr %t191
  %t197 = icmp eq i32 %t196, 116
  %t198 = zext i1 %t197 to i32
  %t199 = icmp ne i32 %t198, 0
  br i1 %t199, label %then50, label %ifend52
then50:
  store i32 9, ptr %t176
  br label %ifend52
ifend52:
  %t200 = load i32, ptr %t191
  %t201 = icmp eq i32 %t200, 48
  %t202 = zext i1 %t201 to i32
  %t203 = icmp ne i32 %t202, 0
  br i1 %t203, label %then53, label %ifend55
then53:
  store i32 0, ptr %t176
  br label %ifend55
ifend55:
  %t204 = load i32, ptr %t7
  %t205 = add i32 %t204, 2
  store i32 %t205, ptr %t7
  br label %ifend46
else45:
  %t206 = load ptr, ptr %t0
  %t207 = load i32, ptr %t7
  %t208 = getelementptr inbounds i8, ptr %t206, i32 %t207
  %t209 = load i8, ptr %t208
  %t210 = zext i8 %t209 to i32
  store i32 %t210, ptr %t176
  %t211 = load i32, ptr %t7
  %t212 = add i32 %t211, 1
  store i32 %t212, ptr %t7
  br label %ifend46
ifend46:
  %t213 = load ptr, ptr %t0
  %t214 = load i32, ptr %t7
  %t215 = getelementptr inbounds i8, ptr %t213, i32 %t214
  %t216 = load i8, ptr %t215
  %t217 = zext i8 %t216 to i32
  %t218 = icmp eq i32 %t217, 39
  %t219 = zext i1 %t218 to i32
  %t220 = icmp ne i32 %t219, 0
  br i1 %t220, label %then56, label %ifend58
then56:
  %t221 = load i32, ptr %t7
  %t222 = add i32 %t221, 1
  store i32 %t222, ptr %t7
  br label %ifend58
ifend58:
  %t223 = load i32, ptr %t176
  %t224 = load i32, ptr %t8
  call void @fn_tok_push(i32 1, ptr null, i32 %t223, i32 %t224)
  br label %wcond0
ifend43:
  %t225 = load i32, ptr %t22
  %t226 = call i32 @fn_char_is_digit(i32 %t225)
  %t227 = icmp ne i32 %t226, 0
  br i1 %t227, label %then59, label %ifend61
then59:
  %t229 = load i32, ptr %t22
  %t230 = icmp eq i32 %t229, 48
  %t231 = zext i1 %t230 to i32
  %t232 = icmp ne i32 %t231, 0
  %t233 = zext i1 %t232 to i32
  store i32 %t233, ptr %t228
  br i1 %t232, label %sc62, label %scend63
sc62:
  %t234 = load ptr, ptr %t0
  %t235 = load i32, ptr %t7
  %t236 = add i32 %t235, 1
  %t237 = getelementptr inbounds i8, ptr %t234, i32 %t236
  %t238 = load i8, ptr %t237
  %t239 = zext i8 %t238 to i32
  %t240 = icmp eq i32 %t239, 120
  %t241 = zext i1 %t240 to i32
  %t242 = icmp ne i32 %t241, 0
  %t243 = zext i1 %t242 to i32
  store i32 %t243, ptr %t228
  br label %scend63
scend63:
  %t244 = load i32, ptr %t228
  %t245 = icmp ne i32 %t244, 0
  br i1 %t245, label %then64, label %ifend66
then64:
  store i32 0, ptr %t246
  %t247 = load i32, ptr %t7
  %t248 = add i32 %t247, 2
  store i32 %t248, ptr %t7
  br label %wcond67
wcond67:
  %t249 = load i32, ptr %t7
  %t250 = load i32, ptr %t11
  %t251 = icmp slt i32 %t249, %t250
  %t252 = zext i1 %t251 to i32
  %t253 = icmp ne i32 %t252, 0
  br i1 %t253, label %wbody68, label %wend69
wbody68:
  %t254 = load ptr, ptr %t0
  %t255 = load i32, ptr %t7
  %t256 = getelementptr inbounds i8, ptr %t254, i32 %t255
  %t257 = load i8, ptr %t256
  %t258 = zext i8 %t257 to i32
  store i32 %t258, ptr %t259
  store i32 0, ptr %t260
  %t261 = load i32, ptr %t259
  %t262 = call i32 @fn_char_is_digit(i32 %t261)
  %t263 = icmp ne i32 %t262, 0
  br i1 %t263, label %then70, label %else71
then70:
  %t264 = load i32, ptr %t259
  %t265 = sub i32 %t264, 48
  store i32 %t265, ptr %t260
  br label %ifend72
else71:
  %t267 = load i32, ptr %t259
  %t268 = icmp sge i32 %t267, 97
  %t269 = zext i1 %t268 to i32
  %t270 = icmp ne i32 %t269, 0
  %t271 = zext i1 %t270 to i32
  store i32 %t271, ptr %t266
  br i1 %t270, label %sc73, label %scend74
sc73:
  %t272 = load i32, ptr %t259
  %t273 = icmp sle i32 %t272, 102
  %t274 = zext i1 %t273 to i32
  %t275 = icmp ne i32 %t274, 0
  %t276 = zext i1 %t275 to i32
  store i32 %t276, ptr %t266
  br label %scend74
scend74:
  %t277 = load i32, ptr %t266
  %t278 = icmp ne i32 %t277, 0
  br i1 %t278, label %then75, label %else76
then75:
  %t279 = load i32, ptr %t259
  %t280 = sub i32 %t279, 87
  store i32 %t280, ptr %t260
  br label %ifend77
else76:
  %t282 = load i32, ptr %t259
  %t283 = icmp sge i32 %t282, 65
  %t284 = zext i1 %t283 to i32
  %t285 = icmp ne i32 %t284, 0
  %t286 = zext i1 %t285 to i32
  store i32 %t286, ptr %t281
  br i1 %t285, label %sc78, label %scend79
sc78:
  %t287 = load i32, ptr %t259
  %t288 = icmp sle i32 %t287, 70
  %t289 = zext i1 %t288 to i32
  %t290 = icmp ne i32 %t289, 0
  %t291 = zext i1 %t290 to i32
  store i32 %t291, ptr %t281
  br label %scend79
scend79:
  %t292 = load i32, ptr %t281
  %t293 = icmp ne i32 %t292, 0
  br i1 %t293, label %then80, label %else81
then80:
  %t294 = load i32, ptr %t259
  %t295 = sub i32 %t294, 55
  store i32 %t295, ptr %t260
  br label %ifend82
else81:
  br label %wend69
ifend82:
  br label %ifend77
ifend77:
  br label %ifend72
ifend72:
  %t296 = load i32, ptr %t246
  %t297 = mul i32 %t296, 16
  %t298 = load i32, ptr %t260
  %t299 = add i32 %t297, %t298
  store i32 %t299, ptr %t246
  %t300 = load i32, ptr %t7
  %t301 = add i32 %t300, 1
  store i32 %t301, ptr %t7
  br label %wcond67
wend69:
  %t302 = load i32, ptr %t246
  %t303 = load i32, ptr %t8
  call void @fn_tok_push(i32 1, ptr null, i32 %t302, i32 %t303)
  br label %wcond0
ifend66:
  store i32 0, ptr %t304
  br label %wcond83
wcond83:
  %t306 = load i32, ptr %t7
  %t307 = load i32, ptr %t11
  %t308 = icmp slt i32 %t306, %t307
  %t309 = zext i1 %t308 to i32
  %t310 = icmp ne i32 %t309, 0
  %t311 = zext i1 %t310 to i32
  store i32 %t311, ptr %t305
  br i1 %t310, label %sc86, label %scend87
sc86:
  %t312 = load ptr, ptr %t0
  %t313 = load i32, ptr %t7
  %t314 = getelementptr inbounds i8, ptr %t312, i32 %t313
  %t315 = load i8, ptr %t314
  %t316 = zext i8 %t315 to i32
  %t317 = call i32 @fn_char_is_digit(i32 %t316)
  %t318 = icmp ne i32 %t317, 0
  %t319 = zext i1 %t318 to i32
  store i32 %t319, ptr %t305
  br label %scend87
scend87:
  %t320 = load i32, ptr %t305
  %t321 = icmp ne i32 %t320, 0
  br i1 %t321, label %wbody84, label %wend85
wbody84:
  %t322 = load i32, ptr %t304
  %t323 = mul i32 %t322, 10
  %t324 = load ptr, ptr %t0
  %t325 = load i32, ptr %t7
  %t326 = getelementptr inbounds i8, ptr %t324, i32 %t325
  %t327 = load i8, ptr %t326
  %t328 = zext i8 %t327 to i32
  %t329 = sub i32 %t328, 48
  %t330 = add i32 %t323, %t329
  store i32 %t330, ptr %t304
  %t331 = load i32, ptr %t7
  %t332 = add i32 %t331, 1
  store i32 %t332, ptr %t7
  br label %wcond83
wend85:
  %t335 = load i32, ptr %t7
  %t336 = load i32, ptr %t11
  %t337 = icmp slt i32 %t335, %t336
  %t338 = zext i1 %t337 to i32
  %t339 = icmp ne i32 %t338, 0
  %t340 = zext i1 %t339 to i32
  store i32 %t340, ptr %t334
  br i1 %t339, label %sc88, label %scend89
sc88:
  %t341 = load ptr, ptr %t0
  %t342 = load i32, ptr %t7
  %t343 = getelementptr inbounds i8, ptr %t341, i32 %t342
  %t344 = load i8, ptr %t343
  %t345 = zext i8 %t344 to i32
  %t346 = icmp eq i32 %t345, 46
  %t347 = zext i1 %t346 to i32
  %t348 = icmp ne i32 %t347, 0
  %t349 = zext i1 %t348 to i32
  store i32 %t349, ptr %t334
  br label %scend89
scend89:
  %t350 = load i32, ptr %t334
  %t351 = icmp ne i32 %t350, 0
  %t352 = zext i1 %t351 to i32
  store i32 %t352, ptr %t333
  br i1 %t351, label %sc90, label %scend91
sc90:
  %t353 = load ptr, ptr %t0
  %t354 = load i32, ptr %t7
  %t355 = add i32 %t354, 1
  %t356 = getelementptr inbounds i8, ptr %t353, i32 %t355
  %t357 = load i8, ptr %t356
  %t358 = zext i8 %t357 to i32
  %t359 = call i32 @fn_char_is_digit(i32 %t358)
  %t360 = icmp ne i32 %t359, 0
  %t361 = zext i1 %t360 to i32
  store i32 %t361, ptr %t333
  br label %scend91
scend91:
  %t362 = load i32, ptr %t333
  %t363 = icmp ne i32 %t362, 0
  br i1 %t363, label %then92, label %ifend94
then92:
  %t364 = load i32, ptr %t7
  %t365 = add i32 %t364, 1
  store i32 %t365, ptr %t7
  store i32 0, ptr %t366
  store i32 1, ptr %t367
  br label %wcond95
wcond95:
  %t369 = load i32, ptr %t7
  %t370 = load i32, ptr %t11
  %t371 = icmp slt i32 %t369, %t370
  %t372 = zext i1 %t371 to i32
  %t373 = icmp ne i32 %t372, 0
  %t374 = zext i1 %t373 to i32
  store i32 %t374, ptr %t368
  br i1 %t373, label %sc98, label %scend99
sc98:
  %t375 = load ptr, ptr %t0
  %t376 = load i32, ptr %t7
  %t377 = getelementptr inbounds i8, ptr %t375, i32 %t376
  %t378 = load i8, ptr %t377
  %t379 = zext i8 %t378 to i32
  %t380 = call i32 @fn_char_is_digit(i32 %t379)
  %t381 = icmp ne i32 %t380, 0
  %t382 = zext i1 %t381 to i32
  store i32 %t382, ptr %t368
  br label %scend99
scend99:
  %t383 = load i32, ptr %t368
  %t384 = icmp ne i32 %t383, 0
  br i1 %t384, label %wbody96, label %wend97
wbody96:
  %t385 = load i32, ptr %t366
  %t386 = mul i32 %t385, 10
  %t387 = load ptr, ptr %t0
  %t388 = load i32, ptr %t7
  %t389 = getelementptr inbounds i8, ptr %t387, i32 %t388
  %t390 = load i8, ptr %t389
  %t391 = zext i8 %t390 to i32
  %t392 = sub i32 %t391, 48
  %t393 = add i32 %t386, %t392
  store i32 %t393, ptr %t366
  %t394 = load i32, ptr %t367
  %t395 = mul i32 %t394, 10
  store i32 %t395, ptr %t367
  %t396 = load i32, ptr %t7
  %t397 = add i32 %t396, 1
  store i32 %t397, ptr %t7
  br label %wcond95
wend97:
  %t398 = load i32, ptr %t304
  %t399 = shl i32 %t398, 16
  %t400 = load i32, ptr %t366
  %t401 = shl i32 %t400, 16
  %t402 = load i32, ptr %t367
  %t403 = sdiv i32 %t401, %t402
  %t404 = add i32 %t399, %t403
  store i32 %t404, ptr %t405
  %t406 = load i32, ptr %t405
  %t407 = load i32, ptr %t8
  call void @fn_tok_push(i32 6, ptr null, i32 %t406, i32 %t407)
  br label %wcond0
ifend94:
  %t408 = load i32, ptr %t304
  %t409 = load i32, ptr %t8
  call void @fn_tok_push(i32 1, ptr null, i32 %t408, i32 %t409)
  br label %wcond0
ifend61:
  %t410 = load i32, ptr %t22
  %t411 = call i32 @fn_char_is_alpha(i32 %t410)
  %t412 = icmp ne i32 %t411, 0
  br i1 %t412, label %then100, label %ifend102
then100:
  %t413 = load i32, ptr %t7
  store i32 %t413, ptr %t414
  br label %wcond103
wcond103:
  %t416 = load i32, ptr %t7
  %t417 = load i32, ptr %t11
  %t418 = icmp slt i32 %t416, %t417
  %t419 = zext i1 %t418 to i32
  %t420 = icmp ne i32 %t419, 0
  %t421 = zext i1 %t420 to i32
  store i32 %t421, ptr %t415
  br i1 %t420, label %sc106, label %scend107
sc106:
  %t422 = load ptr, ptr %t0
  %t423 = load i32, ptr %t7
  %t424 = getelementptr inbounds i8, ptr %t422, i32 %t423
  %t425 = load i8, ptr %t424
  %t426 = zext i8 %t425 to i32
  %t427 = call i32 @fn_char_is_alnum(i32 %t426)
  %t428 = icmp ne i32 %t427, 0
  %t429 = zext i1 %t428 to i32
  store i32 %t429, ptr %t415
  br label %scend107
scend107:
  %t430 = load i32, ptr %t415
  %t431 = icmp ne i32 %t430, 0
  br i1 %t431, label %wbody104, label %wend105
wbody104:
  %t432 = load i32, ptr %t7
  %t433 = add i32 %t432, 1
  store i32 %t433, ptr %t7
  br label %wcond103
wend105:
  %t434 = load ptr, ptr %t0
  %t435 = load i32, ptr %t414
  %t436 = load i32, ptr %t7
  %t437 = load i32, ptr %t414
  %t438 = sub i32 %t436, %t437
  %t439 = call ptr @fn_substr(ptr %t434, i32 %t435, i32 %t438)
  %t440 = load i32, ptr %t8
  call void @fn_tok_push(i32 0, ptr %t439, i32 0, i32 %t440)
  br label %wcond0
ifend102:
  %t441 = load i32, ptr %t22
  %t442 = icmp eq i32 %t441, 59
  %t443 = zext i1 %t442 to i32
  %t444 = icmp ne i32 %t443, 0
  br i1 %t444, label %then108, label %ifend110
then108:
  %t445 = load i32, ptr %t8
  call void @fn_tok_push(i32 4, ptr null, i32 0, i32 %t445)
  %t446 = load i32, ptr %t7
  %t447 = add i32 %t446, 1
  store i32 %t447, ptr %t7
  br label %wcond0
ifend110:
  %t448 = load ptr, ptr %t0
  %t449 = load i32, ptr %t7
  %t450 = call i32 @fn_two_at(ptr %t448, i32 %t449, i32 45, i32 62)
  %t451 = icmp ne i32 %t450, 0
  br i1 %t451, label %then111, label %ifend113
then111:
  %t452 = load ptr, ptr %t0
  %t453 = load i32, ptr %t7
  %t454 = call ptr @fn_substr(ptr %t452, i32 %t453, i32 2)
  %t455 = load i32, ptr %t8
  call void @fn_tok_push(i32 3, ptr %t454, i32 0, i32 %t455)
  %t456 = load i32, ptr %t7
  %t457 = add i32 %t456, 2
  store i32 %t457, ptr %t7
  br label %wcond0
ifend113:
  %t458 = load ptr, ptr %t0
  %t459 = load i32, ptr %t7
  %t460 = call i32 @fn_two_at(ptr %t458, i32 %t459, i32 61, i32 62)
  %t461 = icmp ne i32 %t460, 0
  br i1 %t461, label %then114, label %ifend116
then114:
  %t462 = load ptr, ptr %t0
  %t463 = load i32, ptr %t7
  %t464 = call ptr @fn_substr(ptr %t462, i32 %t463, i32 2)
  %t465 = load i32, ptr %t8
  call void @fn_tok_push(i32 3, ptr %t464, i32 0, i32 %t465)
  %t466 = load i32, ptr %t7
  %t467 = add i32 %t466, 2
  store i32 %t467, ptr %t7
  br label %wcond0
ifend116:
  %t468 = load ptr, ptr %t0
  %t469 = load i32, ptr %t7
  %t470 = call i32 @fn_two_at(ptr %t468, i32 %t469, i32 61, i32 61)
  %t471 = icmp ne i32 %t470, 0
  br i1 %t471, label %then117, label %ifend119
then117:
  %t472 = load ptr, ptr %t0
  %t473 = load i32, ptr %t7
  %t474 = call ptr @fn_substr(ptr %t472, i32 %t473, i32 2)
  %t475 = load i32, ptr %t8
  call void @fn_tok_push(i32 3, ptr %t474, i32 0, i32 %t475)
  %t476 = load i32, ptr %t7
  %t477 = add i32 %t476, 2
  store i32 %t477, ptr %t7
  br label %wcond0
ifend119:
  %t478 = load ptr, ptr %t0
  %t479 = load i32, ptr %t7
  %t480 = call i32 @fn_two_at(ptr %t478, i32 %t479, i32 33, i32 61)
  %t481 = icmp ne i32 %t480, 0
  br i1 %t481, label %then120, label %ifend122
then120:
  %t482 = load ptr, ptr %t0
  %t483 = load i32, ptr %t7
  %t484 = call ptr @fn_substr(ptr %t482, i32 %t483, i32 2)
  %t485 = load i32, ptr %t8
  call void @fn_tok_push(i32 3, ptr %t484, i32 0, i32 %t485)
  %t486 = load i32, ptr %t7
  %t487 = add i32 %t486, 2
  store i32 %t487, ptr %t7
  br label %wcond0
ifend122:
  %t488 = load ptr, ptr %t0
  %t489 = load i32, ptr %t7
  %t490 = call i32 @fn_two_at(ptr %t488, i32 %t489, i32 60, i32 61)
  %t491 = icmp ne i32 %t490, 0
  br i1 %t491, label %then123, label %ifend125
then123:
  %t492 = load ptr, ptr %t0
  %t493 = load i32, ptr %t7
  %t494 = call ptr @fn_substr(ptr %t492, i32 %t493, i32 2)
  %t495 = load i32, ptr %t8
  call void @fn_tok_push(i32 3, ptr %t494, i32 0, i32 %t495)
  %t496 = load i32, ptr %t7
  %t497 = add i32 %t496, 2
  store i32 %t497, ptr %t7
  br label %wcond0
ifend125:
  %t498 = load ptr, ptr %t0
  %t499 = load i32, ptr %t7
  %t500 = call i32 @fn_two_at(ptr %t498, i32 %t499, i32 62, i32 61)
  %t501 = icmp ne i32 %t500, 0
  br i1 %t501, label %then126, label %ifend128
then126:
  %t502 = load ptr, ptr %t0
  %t503 = load i32, ptr %t7
  %t504 = call ptr @fn_substr(ptr %t502, i32 %t503, i32 2)
  %t505 = load i32, ptr %t8
  call void @fn_tok_push(i32 3, ptr %t504, i32 0, i32 %t505)
  %t506 = load i32, ptr %t7
  %t507 = add i32 %t506, 2
  store i32 %t507, ptr %t7
  br label %wcond0
ifend128:
  %t508 = load ptr, ptr %t0
  %t509 = load i32, ptr %t7
  %t510 = call i32 @fn_two_at(ptr %t508, i32 %t509, i32 43, i32 61)
  %t511 = icmp ne i32 %t510, 0
  br i1 %t511, label %then129, label %ifend131
then129:
  %t512 = load ptr, ptr %t0
  %t513 = load i32, ptr %t7
  %t514 = call ptr @fn_substr(ptr %t512, i32 %t513, i32 2)
  %t515 = load i32, ptr %t8
  call void @fn_tok_push(i32 3, ptr %t514, i32 0, i32 %t515)
  %t516 = load i32, ptr %t7
  %t517 = add i32 %t516, 2
  store i32 %t517, ptr %t7
  br label %wcond0
ifend131:
  %t518 = load ptr, ptr %t0
  %t519 = load i32, ptr %t7
  %t520 = call i32 @fn_two_at(ptr %t518, i32 %t519, i32 45, i32 61)
  %t521 = icmp ne i32 %t520, 0
  br i1 %t521, label %then132, label %ifend134
then132:
  %t522 = load ptr, ptr %t0
  %t523 = load i32, ptr %t7
  %t524 = call ptr @fn_substr(ptr %t522, i32 %t523, i32 2)
  %t525 = load i32, ptr %t8
  call void @fn_tok_push(i32 3, ptr %t524, i32 0, i32 %t525)
  %t526 = load i32, ptr %t7
  %t527 = add i32 %t526, 2
  store i32 %t527, ptr %t7
  br label %wcond0
ifend134:
  %t528 = load ptr, ptr %t0
  %t529 = load i32, ptr %t7
  %t530 = call i32 @fn_two_at(ptr %t528, i32 %t529, i32 42, i32 61)
  %t531 = icmp ne i32 %t530, 0
  br i1 %t531, label %then135, label %ifend137
then135:
  %t532 = load ptr, ptr %t0
  %t533 = load i32, ptr %t7
  %t534 = call ptr @fn_substr(ptr %t532, i32 %t533, i32 2)
  %t535 = load i32, ptr %t8
  call void @fn_tok_push(i32 3, ptr %t534, i32 0, i32 %t535)
  %t536 = load i32, ptr %t7
  %t537 = add i32 %t536, 2
  store i32 %t537, ptr %t7
  br label %wcond0
ifend137:
  %t538 = load ptr, ptr %t0
  %t539 = load i32, ptr %t7
  %t540 = call i32 @fn_two_at(ptr %t538, i32 %t539, i32 47, i32 61)
  %t541 = icmp ne i32 %t540, 0
  br i1 %t541, label %then138, label %ifend140
then138:
  %t542 = load ptr, ptr %t0
  %t543 = load i32, ptr %t7
  %t544 = call ptr @fn_substr(ptr %t542, i32 %t543, i32 2)
  %t545 = load i32, ptr %t8
  call void @fn_tok_push(i32 3, ptr %t544, i32 0, i32 %t545)
  %t546 = load i32, ptr %t7
  %t547 = add i32 %t546, 2
  store i32 %t547, ptr %t7
  br label %wcond0
ifend140:
  %t548 = load ptr, ptr %t0
  %t549 = load i32, ptr %t7
  %t550 = call i32 @fn_two_at(ptr %t548, i32 %t549, i32 46, i32 46)
  %t551 = icmp ne i32 %t550, 0
  br i1 %t551, label %then141, label %ifend143
then141:
  %t552 = load ptr, ptr %t0
  %t553 = load i32, ptr %t7
  %t554 = call ptr @fn_substr(ptr %t552, i32 %t553, i32 2)
  %t555 = load i32, ptr %t8
  call void @fn_tok_push(i32 3, ptr %t554, i32 0, i32 %t555)
  %t556 = load i32, ptr %t7
  %t557 = add i32 %t556, 2
  store i32 %t557, ptr %t7
  br label %wcond0
ifend143:
  %t558 = load i32, ptr %t22
  %t559 = call i32 @fn_is_op1(i32 %t558)
  %t560 = icmp ne i32 %t559, 0
  br i1 %t560, label %then144, label %ifend146
then144:
  %t561 = load ptr, ptr %t0
  %t562 = load i32, ptr %t7
  %t563 = call ptr @fn_substr(ptr %t561, i32 %t562, i32 1)
  %t564 = load i32, ptr %t8
  call void @fn_tok_push(i32 3, ptr %t563, i32 0, i32 %t564)
  %t565 = load i32, ptr %t7
  %t566 = add i32 %t565, 1
  store i32 %t566, ptr %t7
  br label %wcond0
ifend146:
  %t567 = load i32, ptr %t7
  %t568 = add i32 %t567, 1
  store i32 %t568, ptr %t7
  br label %wcond0
wend2:
  %t569 = load i32, ptr %t8
  call void @fn_tok_push(i32 5, ptr null, i32 0, i32 %t569)
  br label %ret
ret:
  ret void
}

define ptr @fn_cur() {
entry:
  %retval = alloca ptr
  %t0 = load ptr, ptr @g_toks
  %t1 = getelementptr inbounds %LSlice, ptr %t0, i32 0, i32 0
  %t2 = load ptr, ptr %t1
  %t3 = load i32, ptr @g_pi
  %t4 = getelementptr inbounds ptr, ptr %t2, i32 %t3
  %t5 = load ptr, ptr %t4
  store ptr %t5, ptr %retval
  br label %ret
ret:
  %t6 = load ptr, ptr %retval
  ret ptr %t6
}

define ptr @fn_pk(i32 %arg_o) {
entry:
  %retval = alloca ptr
  %t0 = alloca i32
  store i32 %arg_o, ptr %t0
  %t1 = load ptr, ptr @g_toks
  %t2 = getelementptr inbounds %LSlice, ptr %t1, i32 0, i32 0
  %t3 = load ptr, ptr %t2
  %t4 = load i32, ptr @g_pi
  %t5 = load i32, ptr %t0
  %t6 = add i32 %t4, %t5
  %t7 = getelementptr inbounds ptr, ptr %t3, i32 %t6
  %t8 = load ptr, ptr %t7
  store ptr %t8, ptr %retval
  br label %ret
ret:
  %t9 = load ptr, ptr %retval
  ret ptr %t9
}

define i32 @fn_is_op(ptr %arg_v) {
entry:
  %retval = alloca i32
  %t0 = alloca ptr
  %t7 = alloca ptr
  %t8 = alloca i32
  store ptr %arg_v, ptr %t0
  %t1 = load ptr, ptr @g_toks
  %t2 = getelementptr inbounds %LSlice, ptr %t1, i32 0, i32 0
  %t3 = load ptr, ptr %t2
  %t4 = load i32, ptr @g_pi
  %t5 = getelementptr inbounds ptr, ptr %t3, i32 %t4
  %t6 = load ptr, ptr %t5
  store ptr %t6, ptr %t7
  %t9 = load ptr, ptr %t7
  %t10 = getelementptr inbounds %Str_Tok, ptr %t9, i32 0, i32 0
  %t11 = load i32, ptr %t10
  %t12 = icmp eq i32 %t11, 3
  %t13 = zext i1 %t12 to i32
  %t14 = icmp ne i32 %t13, 0
  %t15 = zext i1 %t14 to i32
  store i32 %t15, ptr %t8
  br i1 %t14, label %sc0, label %scend1
sc0:
  %t16 = load ptr, ptr %t7
  %t17 = getelementptr inbounds %Str_Tok, ptr %t16, i32 0, i32 1
  %t18 = load ptr, ptr %t17
  %t19 = load ptr, ptr %t0
  %t20 = call i32 @fn_streq(ptr %t18, ptr %t19)
  %t21 = icmp ne i32 %t20, 0
  %t22 = zext i1 %t21 to i32
  store i32 %t22, ptr %t8
  br label %scend1
scend1:
  %t23 = load i32, ptr %t8
  store i32 %t23, ptr %retval
  br label %ret
ret:
  %t24 = load i32, ptr %retval
  ret i32 %t24
}

define i32 @fn_is_id(ptr %arg_v) {
entry:
  %retval = alloca i32
  %t0 = alloca ptr
  %t7 = alloca ptr
  %t8 = alloca i32
  store ptr %arg_v, ptr %t0
  %t1 = load ptr, ptr @g_toks
  %t2 = getelementptr inbounds %LSlice, ptr %t1, i32 0, i32 0
  %t3 = load ptr, ptr %t2
  %t4 = load i32, ptr @g_pi
  %t5 = getelementptr inbounds ptr, ptr %t3, i32 %t4
  %t6 = load ptr, ptr %t5
  store ptr %t6, ptr %t7
  %t9 = load ptr, ptr %t7
  %t10 = getelementptr inbounds %Str_Tok, ptr %t9, i32 0, i32 0
  %t11 = load i32, ptr %t10
  %t12 = icmp eq i32 %t11, 0
  %t13 = zext i1 %t12 to i32
  %t14 = icmp ne i32 %t13, 0
  %t15 = zext i1 %t14 to i32
  store i32 %t15, ptr %t8
  br i1 %t14, label %sc0, label %scend1
sc0:
  %t16 = load ptr, ptr %t7
  %t17 = getelementptr inbounds %Str_Tok, ptr %t16, i32 0, i32 1
  %t18 = load ptr, ptr %t17
  %t19 = load ptr, ptr %t0
  %t20 = call i32 @fn_streq(ptr %t18, ptr %t19)
  %t21 = icmp ne i32 %t20, 0
  %t22 = zext i1 %t21 to i32
  store i32 %t22, ptr %t8
  br label %scend1
scend1:
  %t23 = load i32, ptr %t8
  store i32 %t23, ptr %retval
  br label %ret
ret:
  %t24 = load i32, ptr %retval
  ret i32 %t24
}

define i32 @fn_is_kw(ptr %arg_v) {
entry:
  %retval = alloca i32
  %t0 = alloca ptr
  store ptr %arg_v, ptr %t0
  %t1 = load ptr, ptr %t0
  %t2 = call i32 @fn_is_id(ptr %t1)
  store i32 %t2, ptr %retval
  br label %ret
ret:
  %t3 = load i32, ptr %retval
  ret i32 %t3
}

define void @fn_perr(ptr %arg_msg) {
entry:
  %t0 = alloca ptr
  %t2 = alloca ptr
  store ptr %arg_msg, ptr %t0
  %t1 = load ptr, ptr @__stderrp
  store ptr %t1, ptr %t2
  %t3 = load ptr, ptr %t2
  %t4 = zext i32 27 to i64
  %t5 = call i64 @fwrite(ptr @.str1, i64 1, i64 %t4, ptr %t3)
  %t6 = trunc i64 %t5 to i32
  %t7 = load ptr, ptr %t2
  %t8 = load ptr, ptr %t0
  %t9 = load ptr, ptr %t0
  %t10 = call i32 @fn_slen(ptr %t9)
  %t11 = zext i32 %t10 to i64
  %t12 = call i64 @fwrite(ptr %t8, i64 1, i64 %t11, ptr %t7)
  %t13 = trunc i64 %t12 to i32
  %t14 = load ptr, ptr %t2
  %t15 = zext i32 1 to i64
  %t16 = call i64 @fwrite(ptr @.str2, i64 1, i64 %t15, ptr %t14)
  %t17 = trunc i64 %t16 to i32
  call void @exit(i32 1)
  unreachable
ret:
  ret void
}

define void @fn_eat_op(ptr %arg_v) {
entry:
  %t0 = alloca ptr
  store ptr %arg_v, ptr %t0
  %t1 = load ptr, ptr %t0
  %t2 = call i32 @fn_is_op(ptr %t1)
  %t3 = icmp eq i32 %t2, 0
  %t4 = zext i1 %t3 to i32
  %t5 = icmp ne i32 %t4, 0
  br i1 %t5, label %then0, label %ifend2
then0:
  %t6 = load ptr, ptr %t0
  call void @fn_perr(ptr %t6)
  br label %ifend2
ifend2:
  %t7 = load i32, ptr @g_pi
  %t8 = add i32 %t7, 1
  store i32 %t8, ptr @g_pi
  br label %ret
ret:
  ret void
}

define ptr @fn_eat_id() {
entry:
  %retval = alloca ptr
  %t6 = alloca ptr
  %t0 = load ptr, ptr @g_toks
  %t1 = getelementptr inbounds %LSlice, ptr %t0, i32 0, i32 0
  %t2 = load ptr, ptr %t1
  %t3 = load i32, ptr @g_pi
  %t4 = getelementptr inbounds ptr, ptr %t2, i32 %t3
  %t5 = load ptr, ptr %t4
  store ptr %t5, ptr %t6
  %t7 = load ptr, ptr %t6
  %t8 = getelementptr inbounds %Str_Tok, ptr %t7, i32 0, i32 0
  %t9 = load i32, ptr %t8
  %t10 = icmp ne i32 %t9, 0
  %t11 = zext i1 %t10 to i32
  %t12 = icmp ne i32 %t11, 0
  br i1 %t12, label %then0, label %ifend2
then0:
  call void @fn_perr(ptr @.str3)
  br label %ifend2
ifend2:
  %t13 = load i32, ptr @g_pi
  %t14 = add i32 %t13, 1
  store i32 %t14, ptr @g_pi
  %t15 = load ptr, ptr %t6
  %t16 = getelementptr inbounds %Str_Tok, ptr %t15, i32 0, i32 1
  %t17 = load ptr, ptr %t16
  store ptr %t17, ptr %retval
  br label %ret
ret:
  %t18 = load ptr, ptr %retval
  ret ptr %t18
}

define void @fn_skipnl() {
entry:
  br label %wcond0
wcond0:
  %t0 = load ptr, ptr @g_toks
  %t1 = getelementptr inbounds %LSlice, ptr %t0, i32 0, i32 0
  %t2 = load ptr, ptr %t1
  %t3 = load i32, ptr @g_pi
  %t4 = getelementptr inbounds ptr, ptr %t2, i32 %t3
  %t5 = load ptr, ptr %t4
  %t6 = getelementptr inbounds %Str_Tok, ptr %t5, i32 0, i32 0
  %t7 = load i32, ptr %t6
  %t8 = icmp eq i32 %t7, 4
  %t9 = zext i1 %t8 to i32
  %t10 = icmp ne i32 %t9, 0
  br i1 %t10, label %wbody1, label %wend2
wbody1:
  %t11 = load i32, ptr @g_pi
  %t12 = add i32 %t11, 1
  store i32 %t12, ptr @g_pi
  br label %wcond0
wend2:
  br label %ret
ret:
  ret void
}

define ptr @fn_ptype() {
entry:
  %retval = alloca ptr
  %t5 = alloca ptr
  %t11 = alloca ptr
  %t18 = alloca i32
  %t0 = call i32 @fn_is_op(ptr @.str4)
  %t1 = icmp ne i32 %t0, 0
  br i1 %t1, label %then0, label %ifend2
then0:
  %t2 = load i32, ptr @g_pi
  %t3 = add i32 %t2, 1
  store i32 %t3, ptr @g_pi
  call void @fn_eat_op(ptr @.str5)
  %t4 = call ptr @fn_ptype()
  store ptr %t4, ptr %t5
  %t6 = load ptr, ptr %t5
  %t7 = call i32 @fn_slen(ptr %t6)
  %t8 = add i32 %t7, 3
  %t9 = zext i32 %t8 to i64
  %t10 = call ptr @malloc(i64 %t9)
  store ptr %t10, ptr %t11
  %t12 = load ptr, ptr %t11
  %t13 = getelementptr inbounds i8, ptr %t12, i32 0
  %t14 = trunc i32 91 to i8
  store i8 %t14, ptr %t13
  %t15 = load ptr, ptr %t11
  %t16 = getelementptr inbounds i8, ptr %t15, i32 1
  %t17 = trunc i32 93 to i8
  store i8 %t17, ptr %t16
  store i32 0, ptr %t18
  br label %wcond3
wcond3:
  %t19 = load ptr, ptr %t5
  %t20 = load i32, ptr %t18
  %t21 = getelementptr inbounds i8, ptr %t19, i32 %t20
  %t22 = load i8, ptr %t21
  %t23 = zext i8 %t22 to i32
  %t24 = icmp ne i32 %t23, 0
  %t25 = zext i1 %t24 to i32
  %t26 = icmp ne i32 %t25, 0
  br i1 %t26, label %wbody4, label %wend5
wbody4:
  %t27 = load ptr, ptr %t11
  %t28 = load i32, ptr %t18
  %t29 = add i32 2, %t28
  %t30 = load ptr, ptr %t5
  %t31 = load i32, ptr %t18
  %t32 = getelementptr inbounds i8, ptr %t30, i32 %t31
  %t33 = load i8, ptr %t32
  %t34 = zext i8 %t33 to i32
  %t35 = getelementptr inbounds i8, ptr %t27, i32 %t29
  %t36 = trunc i32 %t34 to i8
  store i8 %t36, ptr %t35
  %t37 = load i32, ptr %t18
  %t38 = add i32 %t37, 1
  store i32 %t38, ptr %t18
  br label %wcond3
wend5:
  %t39 = load ptr, ptr %t11
  %t40 = load i32, ptr %t18
  %t41 = add i32 2, %t40
  %t42 = getelementptr inbounds i8, ptr %t39, i32 %t41
  %t43 = trunc i32 0 to i8
  store i8 %t43, ptr %t42
  %t44 = load ptr, ptr %t11
  store ptr %t44, ptr %retval
  br label %ret
ifend2:
  %t45 = call ptr @fn_eat_id()
  store ptr %t45, ptr %retval
  br label %ret
ret:
  %t46 = load ptr, ptr %retval
  ret ptr %t46
}

define ptr @fn_expr() {
entry:
  %retval = alloca ptr
  %t0 = call ptr @fn_p_or()
  store ptr %t0, ptr %retval
  br label %ret
ret:
  %t1 = load ptr, ptr %retval
  ret ptr %t1
}

define void @fn_args_call(ptr %arg_call) {
entry:
  %t0 = alloca ptr
  store ptr %arg_call, ptr %t0
  call void @fn_eat_op(ptr @.str6)
  call void @fn_skipnl()
  br label %wcond0
wcond0:
  %t1 = call i32 @fn_is_op(ptr @.str7)
  %t2 = icmp eq i32 %t1, 0
  %t3 = zext i1 %t2 to i32
  %t4 = icmp ne i32 %t3, 0
  br i1 %t4, label %wbody1, label %wend2
wbody1:
  %t5 = load ptr, ptr %t0
  %t6 = getelementptr inbounds %Str_Node, ptr %t5, i32 0, i32 7
  %t7 = load ptr, ptr %t6
  %t8 = getelementptr inbounds %LSlice, ptr %t7, i32 0, i32 1
  %t9 = getelementptr inbounds %LSlice, ptr %t7, i32 0, i32 2
  %t10 = getelementptr inbounds %LSlice, ptr %t7, i32 0, i32 0
  %t11 = load i32, ptr %t8
  %t12 = load i32, ptr %t9
  %t13 = icmp sge i32 %t11, %t12
  br i1 %t13, label %grow3, label %put4
grow3:
  %t14 = mul i32 %t12, 2
  %t15 = icmp eq i32 %t12, 0
  %t16 = select i1 %t15, i32 8, i32 %t14
  %t17 = getelementptr ptr, ptr null, i32 1
  %t18 = ptrtoint ptr %t17 to i64
  %t19 = zext i32 %t16 to i64
  %t20 = mul i64 %t19, %t18
  %t21 = load ptr, ptr %t10
  %t22 = call ptr @realloc(ptr %t21, i64 %t20)
  store ptr %t22, ptr %t10
  store i32 %t16, ptr %t9
  br label %put4
put4:
  %t23 = call ptr @fn_expr()
  %t24 = load ptr, ptr %t10
  %t25 = getelementptr inbounds ptr, ptr %t24, i32 %t11
  store ptr %t23, ptr %t25
  %t26 = add i32 %t11, 1
  store i32 %t26, ptr %t8
  call void @fn_skipnl()
  %t27 = call i32 @fn_is_op(ptr @.str8)
  %t28 = icmp ne i32 %t27, 0
  br i1 %t28, label %then5, label %ifend7
then5:
  %t29 = load i32, ptr @g_pi
  %t30 = add i32 %t29, 1
  store i32 %t30, ptr @g_pi
  call void @fn_skipnl()
  br label %ifend7
ifend7:
  br label %wcond0
wend2:
  call void @fn_eat_op(ptr @.str9)
  br label %ret
ret:
  ret void
}

define ptr @fn_p_primary() {
entry:
  %retval = alloca ptr
  %t6 = alloca ptr
  %t14 = alloca ptr
  %t30 = alloca ptr
  %t46 = alloca ptr
  %t67 = alloca ptr
  %t79 = alloca ptr
  %t93 = alloca ptr
  %t99 = alloca ptr
  %t113 = alloca ptr
  %t0 = load ptr, ptr @g_toks
  %t1 = getelementptr inbounds %LSlice, ptr %t0, i32 0, i32 0
  %t2 = load ptr, ptr %t1
  %t3 = load i32, ptr @g_pi
  %t4 = getelementptr inbounds ptr, ptr %t2, i32 %t3
  %t5 = load ptr, ptr %t4
  store ptr %t5, ptr %t6
  %t7 = load ptr, ptr %t6
  %t8 = getelementptr inbounds %Str_Tok, ptr %t7, i32 0, i32 0
  %t9 = load i32, ptr %t8
  %t10 = icmp eq i32 %t9, 1
  %t11 = zext i1 %t10 to i32
  %t12 = icmp ne i32 %t11, 0
  br i1 %t12, label %then0, label %ifend2
then0:
  %t13 = call ptr @fn_node(i32 30)
  store ptr %t13, ptr %t14
  %t15 = load ptr, ptr %t14
  %t16 = getelementptr inbounds %Str_Node, ptr %t15, i32 0, i32 2
  %t17 = load ptr, ptr %t6
  %t18 = getelementptr inbounds %Str_Tok, ptr %t17, i32 0, i32 2
  %t19 = load i32, ptr %t18
  store i32 %t19, ptr %t16
  %t20 = load i32, ptr @g_pi
  %t21 = add i32 %t20, 1
  store i32 %t21, ptr @g_pi
  %t22 = load ptr, ptr %t14
  store ptr %t22, ptr %retval
  br label %ret
ifend2:
  %t23 = load ptr, ptr %t6
  %t24 = getelementptr inbounds %Str_Tok, ptr %t23, i32 0, i32 0
  %t25 = load i32, ptr %t24
  %t26 = icmp eq i32 %t25, 6
  %t27 = zext i1 %t26 to i32
  %t28 = icmp ne i32 %t27, 0
  br i1 %t28, label %then3, label %ifend5
then3:
  %t29 = call ptr @fn_node(i32 40)
  store ptr %t29, ptr %t30
  %t31 = load ptr, ptr %t30
  %t32 = getelementptr inbounds %Str_Node, ptr %t31, i32 0, i32 2
  %t33 = load ptr, ptr %t6
  %t34 = getelementptr inbounds %Str_Tok, ptr %t33, i32 0, i32 2
  %t35 = load i32, ptr %t34
  store i32 %t35, ptr %t32
  %t36 = load i32, ptr @g_pi
  %t37 = add i32 %t36, 1
  store i32 %t37, ptr @g_pi
  %t38 = load ptr, ptr %t30
  store ptr %t38, ptr %retval
  br label %ret
ifend5:
  %t39 = load ptr, ptr %t6
  %t40 = getelementptr inbounds %Str_Tok, ptr %t39, i32 0, i32 0
  %t41 = load i32, ptr %t40
  %t42 = icmp eq i32 %t41, 2
  %t43 = zext i1 %t42 to i32
  %t44 = icmp ne i32 %t43, 0
  br i1 %t44, label %then6, label %ifend8
then6:
  %t45 = call ptr @fn_node(i32 31)
  store ptr %t45, ptr %t46
  %t47 = load ptr, ptr %t46
  %t48 = getelementptr inbounds %Str_Node, ptr %t47, i32 0, i32 1
  %t49 = load ptr, ptr %t6
  %t50 = getelementptr inbounds %Str_Tok, ptr %t49, i32 0, i32 1
  %t51 = load ptr, ptr %t50
  store ptr %t51, ptr %t48
  %t52 = load i32, ptr @g_pi
  %t53 = add i32 %t52, 1
  store i32 %t53, ptr @g_pi
  %t54 = load ptr, ptr %t46
  store ptr %t54, ptr %retval
  br label %ret
ifend8:
  %t55 = load ptr, ptr %t6
  %t56 = getelementptr inbounds %Str_Tok, ptr %t55, i32 0, i32 0
  %t57 = load i32, ptr %t56
  %t58 = icmp eq i32 %t57, 0
  %t59 = zext i1 %t58 to i32
  %t60 = icmp ne i32 %t59, 0
  br i1 %t60, label %then9, label %ifend11
then9:
  %t61 = load ptr, ptr %t6
  %t62 = getelementptr inbounds %Str_Tok, ptr %t61, i32 0, i32 1
  %t63 = load ptr, ptr %t62
  %t64 = call i32 @fn_streq(ptr %t63, ptr @.str10)
  %t65 = icmp ne i32 %t64, 0
  br i1 %t65, label %then12, label %ifend14
then12:
  %t66 = call ptr @fn_node(i32 32)
  store ptr %t66, ptr %t67
  %t68 = load ptr, ptr %t67
  %t69 = getelementptr inbounds %Str_Node, ptr %t68, i32 0, i32 2
  store i32 1, ptr %t69
  %t70 = load i32, ptr @g_pi
  %t71 = add i32 %t70, 1
  store i32 %t71, ptr @g_pi
  %t72 = load ptr, ptr %t67
  store ptr %t72, ptr %retval
  br label %ret
ifend14:
  %t73 = load ptr, ptr %t6
  %t74 = getelementptr inbounds %Str_Tok, ptr %t73, i32 0, i32 1
  %t75 = load ptr, ptr %t74
  %t76 = call i32 @fn_streq(ptr %t75, ptr @.str11)
  %t77 = icmp ne i32 %t76, 0
  br i1 %t77, label %then15, label %ifend17
then15:
  %t78 = call ptr @fn_node(i32 32)
  store ptr %t78, ptr %t79
  %t80 = load ptr, ptr %t79
  %t81 = getelementptr inbounds %Str_Node, ptr %t80, i32 0, i32 2
  store i32 0, ptr %t81
  %t82 = load i32, ptr @g_pi
  %t83 = add i32 %t82, 1
  store i32 %t83, ptr @g_pi
  %t84 = load ptr, ptr %t79
  store ptr %t84, ptr %retval
  br label %ret
ifend17:
  %t85 = load ptr, ptr %t6
  %t86 = getelementptr inbounds %Str_Tok, ptr %t85, i32 0, i32 1
  %t87 = load ptr, ptr %t86
  %t88 = call i32 @fn_streq(ptr %t87, ptr @.str12)
  %t89 = icmp ne i32 %t88, 0
  br i1 %t89, label %then18, label %ifend20
then18:
  %t90 = load i32, ptr @g_pi
  %t91 = add i32 %t90, 1
  store i32 %t91, ptr @g_pi
  %t92 = call ptr @fn_node(i32 39)
  store ptr %t92, ptr %t93
  %t94 = load ptr, ptr %t93
  %t95 = getelementptr inbounds %Str_Node, ptr %t94, i32 0, i32 1
  %t96 = call ptr @fn_ptype()
  store ptr %t96, ptr %t95
  %t97 = load ptr, ptr %t93
  store ptr %t97, ptr %retval
  br label %ret
ifend20:
  %t98 = call ptr @fn_node(i32 33)
  store ptr %t98, ptr %t99
  %t100 = load ptr, ptr %t99
  %t101 = getelementptr inbounds %Str_Node, ptr %t100, i32 0, i32 1
  %t102 = load ptr, ptr %t6
  %t103 = getelementptr inbounds %Str_Tok, ptr %t102, i32 0, i32 1
  %t104 = load ptr, ptr %t103
  store ptr %t104, ptr %t101
  %t105 = load i32, ptr @g_pi
  %t106 = add i32 %t105, 1
  store i32 %t106, ptr @g_pi
  %t107 = load ptr, ptr %t99
  store ptr %t107, ptr %retval
  br label %ret
ifend11:
  %t108 = call i32 @fn_is_op(ptr @.str13)
  %t109 = icmp ne i32 %t108, 0
  br i1 %t109, label %then21, label %ifend23
then21:
  %t110 = load i32, ptr @g_pi
  %t111 = add i32 %t110, 1
  store i32 %t111, ptr @g_pi
  call void @fn_skipnl()
  %t112 = call ptr @fn_expr()
  store ptr %t112, ptr %t113
  call void @fn_skipnl()
  call void @fn_eat_op(ptr @.str14)
  %t114 = load ptr, ptr %t113
  store ptr %t114, ptr %retval
  br label %ret
ifend23:
  call void @fn_perr(ptr @.str15)
  %t115 = call ptr @fn_node(i32 30)
  store ptr %t115, ptr %retval
  br label %ret
ret:
  %t116 = load ptr, ptr %retval
  ret ptr %t116
}

define ptr @fn_p_postfix() {
entry:
  %retval = alloca ptr
  %t1 = alloca ptr
  %t8 = alloca ptr
  %t21 = alloca ptr
  %t32 = alloca ptr
  %t0 = call ptr @fn_p_primary()
  store ptr %t0, ptr %t1
  br label %wcond0
wcond0:
  %t2 = icmp ne i32 1, 0
  br i1 %t2, label %wbody1, label %wend2
wbody1:
  %t3 = call i32 @fn_is_op(ptr @.str16)
  %t4 = icmp ne i32 %t3, 0
  br i1 %t4, label %then3, label %else4
then3:
  %t5 = load i32, ptr @g_pi
  %t6 = add i32 %t5, 1
  store i32 %t6, ptr @g_pi
  %t7 = call ptr @fn_node(i32 35)
  store ptr %t7, ptr %t8
  %t9 = load ptr, ptr %t8
  %t10 = getelementptr inbounds %Str_Node, ptr %t9, i32 0, i32 4
  %t11 = load ptr, ptr %t1
  store ptr %t11, ptr %t10
  %t12 = load ptr, ptr %t8
  %t13 = getelementptr inbounds %Str_Node, ptr %t12, i32 0, i32 1
  %t14 = call ptr @fn_eat_id()
  store ptr %t14, ptr %t13
  %t15 = load ptr, ptr %t8
  store ptr %t15, ptr %t1
  br label %ifend5
else4:
  %t16 = call i32 @fn_is_op(ptr @.str17)
  %t17 = icmp ne i32 %t16, 0
  br i1 %t17, label %then6, label %else7
then6:
  %t18 = load i32, ptr @g_pi
  %t19 = add i32 %t18, 1
  store i32 %t19, ptr @g_pi
  %t20 = call ptr @fn_node(i32 36)
  store ptr %t20, ptr %t21
  %t22 = load ptr, ptr %t21
  %t23 = getelementptr inbounds %Str_Node, ptr %t22, i32 0, i32 4
  %t24 = load ptr, ptr %t1
  store ptr %t24, ptr %t23
  %t25 = load ptr, ptr %t21
  %t26 = getelementptr inbounds %Str_Node, ptr %t25, i32 0, i32 5
  %t27 = call ptr @fn_expr()
  store ptr %t27, ptr %t26
  call void @fn_eat_op(ptr @.str18)
  %t28 = load ptr, ptr %t21
  store ptr %t28, ptr %t1
  br label %ifend8
else7:
  %t29 = call i32 @fn_is_op(ptr @.str19)
  %t30 = icmp ne i32 %t29, 0
  br i1 %t30, label %then9, label %else10
then9:
  %t31 = call ptr @fn_node(i32 34)
  store ptr %t31, ptr %t32
  %t33 = load ptr, ptr %t32
  %t34 = getelementptr inbounds %Str_Node, ptr %t33, i32 0, i32 4
  %t35 = load ptr, ptr %t1
  store ptr %t35, ptr %t34
  %t36 = load ptr, ptr %t32
  call void @fn_args_call(ptr %t36)
  %t37 = load ptr, ptr %t32
  store ptr %t37, ptr %t1
  br label %ifend11
else10:
  br label %wend2
ifend11:
  br label %ifend8
ifend8:
  br label %ifend5
ifend5:
  br label %wcond0
wend2:
  %t38 = load ptr, ptr %t1
  store ptr %t38, ptr %retval
  br label %ret
ret:
  %t39 = load ptr, ptr %retval
  ret ptr %t39
}

define ptr @fn_p_unary() {
entry:
  %retval = alloca ptr
  %t5 = alloca ptr
  %t17 = alloca ptr
  %t0 = call i32 @fn_is_op(ptr @.str20)
  %t1 = icmp ne i32 %t0, 0
  br i1 %t1, label %then0, label %ifend2
then0:
  %t2 = load i32, ptr @g_pi
  %t3 = add i32 %t2, 1
  store i32 %t3, ptr @g_pi
  %t4 = call ptr @fn_node(i32 38)
  store ptr %t4, ptr %t5
  %t6 = load ptr, ptr %t5
  %t7 = getelementptr inbounds %Str_Node, ptr %t6, i32 0, i32 1
  store ptr @.str21, ptr %t7
  %t8 = load ptr, ptr %t5
  %t9 = getelementptr inbounds %Str_Node, ptr %t8, i32 0, i32 4
  %t10 = call ptr @fn_p_unary()
  store ptr %t10, ptr %t9
  %t11 = load ptr, ptr %t5
  store ptr %t11, ptr %retval
  br label %ret
ifend2:
  %t12 = call i32 @fn_is_id(ptr @.str22)
  %t13 = icmp ne i32 %t12, 0
  br i1 %t13, label %then3, label %ifend5
then3:
  %t14 = load i32, ptr @g_pi
  %t15 = add i32 %t14, 1
  store i32 %t15, ptr @g_pi
  %t16 = call ptr @fn_node(i32 38)
  store ptr %t16, ptr %t17
  %t18 = load ptr, ptr %t17
  %t19 = getelementptr inbounds %Str_Node, ptr %t18, i32 0, i32 1
  store ptr @.str23, ptr %t19
  %t20 = load ptr, ptr %t17
  %t21 = getelementptr inbounds %Str_Node, ptr %t20, i32 0, i32 4
  %t22 = call ptr @fn_p_unary()
  store ptr %t22, ptr %t21
  %t23 = load ptr, ptr %t17
  store ptr %t23, ptr %retval
  br label %ret
ifend5:
  %t24 = call ptr @fn_p_postfix()
  store ptr %t24, ptr %retval
  br label %ret
ret:
  %t25 = load ptr, ptr %retval
  ret ptr %t25
}

define ptr @fn_mkbin(ptr %arg_op, ptr %arg_l, ptr %arg_r) {
entry:
  %retval = alloca ptr
  %t0 = alloca ptr
  %t1 = alloca ptr
  %t2 = alloca ptr
  %t4 = alloca ptr
  store ptr %arg_op, ptr %t0
  store ptr %arg_l, ptr %t1
  store ptr %arg_r, ptr %t2
  %t3 = call ptr @fn_node(i32 37)
  store ptr %t3, ptr %t4
  %t5 = load ptr, ptr %t4
  %t6 = getelementptr inbounds %Str_Node, ptr %t5, i32 0, i32 1
  %t7 = load ptr, ptr %t0
  store ptr %t7, ptr %t6
  %t8 = load ptr, ptr %t4
  %t9 = getelementptr inbounds %Str_Node, ptr %t8, i32 0, i32 4
  %t10 = load ptr, ptr %t1
  store ptr %t10, ptr %t9
  %t11 = load ptr, ptr %t4
  %t12 = getelementptr inbounds %Str_Node, ptr %t11, i32 0, i32 5
  %t13 = load ptr, ptr %t2
  store ptr %t13, ptr %t12
  %t14 = load ptr, ptr %t4
  store ptr %t14, ptr %retval
  br label %ret
ret:
  %t15 = load ptr, ptr %retval
  ret ptr %t15
}

define ptr @fn_p_mul() {
entry:
  %retval = alloca ptr
  %t1 = alloca ptr
  %t2 = alloca i32
  %t3 = alloca i32
  %t26 = alloca ptr
  %t0 = call ptr @fn_p_unary()
  store ptr %t0, ptr %t1
  br label %wcond0
wcond0:
  %t4 = call i32 @fn_is_op(ptr @.str24)
  %t5 = icmp ne i32 %t4, 0
  %t6 = zext i1 %t5 to i32
  store i32 %t6, ptr %t3
  br i1 %t5, label %scend4, label %sc3
sc3:
  %t7 = call i32 @fn_is_op(ptr @.str25)
  %t8 = icmp ne i32 %t7, 0
  %t9 = zext i1 %t8 to i32
  store i32 %t9, ptr %t3
  br label %scend4
scend4:
  %t10 = load i32, ptr %t3
  %t11 = icmp ne i32 %t10, 0
  %t12 = zext i1 %t11 to i32
  store i32 %t12, ptr %t2
  br i1 %t11, label %scend6, label %sc5
sc5:
  %t13 = call i32 @fn_is_op(ptr @.str26)
  %t14 = icmp ne i32 %t13, 0
  %t15 = zext i1 %t14 to i32
  store i32 %t15, ptr %t2
  br label %scend6
scend6:
  %t16 = load i32, ptr %t2
  %t17 = icmp ne i32 %t16, 0
  br i1 %t17, label %wbody1, label %wend2
wbody1:
  %t18 = load ptr, ptr @g_toks
  %t19 = getelementptr inbounds %LSlice, ptr %t18, i32 0, i32 0
  %t20 = load ptr, ptr %t19
  %t21 = load i32, ptr @g_pi
  %t22 = getelementptr inbounds ptr, ptr %t20, i32 %t21
  %t23 = load ptr, ptr %t22
  %t24 = getelementptr inbounds %Str_Tok, ptr %t23, i32 0, i32 1
  %t25 = load ptr, ptr %t24
  store ptr %t25, ptr %t26
  %t27 = load i32, ptr @g_pi
  %t28 = add i32 %t27, 1
  store i32 %t28, ptr @g_pi
  %t29 = load ptr, ptr %t26
  %t30 = load ptr, ptr %t1
  %t31 = call ptr @fn_p_unary()
  %t32 = call ptr @fn_mkbin(ptr %t29, ptr %t30, ptr %t31)
  store ptr %t32, ptr %t1
  br label %wcond0
wend2:
  %t33 = load ptr, ptr %t1
  store ptr %t33, ptr %retval
  br label %ret
ret:
  %t34 = load ptr, ptr %retval
  ret ptr %t34
}

define ptr @fn_p_add() {
entry:
  %retval = alloca ptr
  %t1 = alloca ptr
  %t2 = alloca i32
  %t19 = alloca ptr
  %t0 = call ptr @fn_p_mul()
  store ptr %t0, ptr %t1
  br label %wcond0
wcond0:
  %t3 = call i32 @fn_is_op(ptr @.str27)
  %t4 = icmp ne i32 %t3, 0
  %t5 = zext i1 %t4 to i32
  store i32 %t5, ptr %t2
  br i1 %t4, label %scend4, label %sc3
sc3:
  %t6 = call i32 @fn_is_op(ptr @.str28)
  %t7 = icmp ne i32 %t6, 0
  %t8 = zext i1 %t7 to i32
  store i32 %t8, ptr %t2
  br label %scend4
scend4:
  %t9 = load i32, ptr %t2
  %t10 = icmp ne i32 %t9, 0
  br i1 %t10, label %wbody1, label %wend2
wbody1:
  %t11 = load ptr, ptr @g_toks
  %t12 = getelementptr inbounds %LSlice, ptr %t11, i32 0, i32 0
  %t13 = load ptr, ptr %t12
  %t14 = load i32, ptr @g_pi
  %t15 = getelementptr inbounds ptr, ptr %t13, i32 %t14
  %t16 = load ptr, ptr %t15
  %t17 = getelementptr inbounds %Str_Tok, ptr %t16, i32 0, i32 1
  %t18 = load ptr, ptr %t17
  store ptr %t18, ptr %t19
  %t20 = load i32, ptr @g_pi
  %t21 = add i32 %t20, 1
  store i32 %t21, ptr @g_pi
  %t22 = load ptr, ptr %t19
  %t23 = load ptr, ptr %t1
  %t24 = call ptr @fn_p_mul()
  %t25 = call ptr @fn_mkbin(ptr %t22, ptr %t23, ptr %t24)
  store ptr %t25, ptr %t1
  br label %wcond0
wend2:
  %t26 = load ptr, ptr %t1
  store ptr %t26, ptr %retval
  br label %ret
ret:
  %t27 = load ptr, ptr %retval
  ret ptr %t27
}

define ptr @fn_p_cmp() {
entry:
  %retval = alloca ptr
  %t1 = alloca ptr
  %t2 = alloca i32
  %t3 = alloca i32
  %t4 = alloca i32
  %t5 = alloca i32
  %t6 = alloca i32
  %t47 = alloca ptr
  %t0 = call ptr @fn_p_add()
  store ptr %t0, ptr %t1
  br label %wcond0
wcond0:
  %t7 = call i32 @fn_is_op(ptr @.str29)
  %t8 = icmp ne i32 %t7, 0
  %t9 = zext i1 %t8 to i32
  store i32 %t9, ptr %t6
  br i1 %t8, label %scend4, label %sc3
sc3:
  %t10 = call i32 @fn_is_op(ptr @.str30)
  %t11 = icmp ne i32 %t10, 0
  %t12 = zext i1 %t11 to i32
  store i32 %t12, ptr %t6
  br label %scend4
scend4:
  %t13 = load i32, ptr %t6
  %t14 = icmp ne i32 %t13, 0
  %t15 = zext i1 %t14 to i32
  store i32 %t15, ptr %t5
  br i1 %t14, label %scend6, label %sc5
sc5:
  %t16 = call i32 @fn_is_op(ptr @.str31)
  %t17 = icmp ne i32 %t16, 0
  %t18 = zext i1 %t17 to i32
  store i32 %t18, ptr %t5
  br label %scend6
scend6:
  %t19 = load i32, ptr %t5
  %t20 = icmp ne i32 %t19, 0
  %t21 = zext i1 %t20 to i32
  store i32 %t21, ptr %t4
  br i1 %t20, label %scend8, label %sc7
sc7:
  %t22 = call i32 @fn_is_op(ptr @.str32)
  %t23 = icmp ne i32 %t22, 0
  %t24 = zext i1 %t23 to i32
  store i32 %t24, ptr %t4
  br label %scend8
scend8:
  %t25 = load i32, ptr %t4
  %t26 = icmp ne i32 %t25, 0
  %t27 = zext i1 %t26 to i32
  store i32 %t27, ptr %t3
  br i1 %t26, label %scend10, label %sc9
sc9:
  %t28 = call i32 @fn_is_op(ptr @.str33)
  %t29 = icmp ne i32 %t28, 0
  %t30 = zext i1 %t29 to i32
  store i32 %t30, ptr %t3
  br label %scend10
scend10:
  %t31 = load i32, ptr %t3
  %t32 = icmp ne i32 %t31, 0
  %t33 = zext i1 %t32 to i32
  store i32 %t33, ptr %t2
  br i1 %t32, label %scend12, label %sc11
sc11:
  %t34 = call i32 @fn_is_op(ptr @.str34)
  %t35 = icmp ne i32 %t34, 0
  %t36 = zext i1 %t35 to i32
  store i32 %t36, ptr %t2
  br label %scend12
scend12:
  %t37 = load i32, ptr %t2
  %t38 = icmp ne i32 %t37, 0
  br i1 %t38, label %wbody1, label %wend2
wbody1:
  %t39 = load ptr, ptr @g_toks
  %t40 = getelementptr inbounds %LSlice, ptr %t39, i32 0, i32 0
  %t41 = load ptr, ptr %t40
  %t42 = load i32, ptr @g_pi
  %t43 = getelementptr inbounds ptr, ptr %t41, i32 %t42
  %t44 = load ptr, ptr %t43
  %t45 = getelementptr inbounds %Str_Tok, ptr %t44, i32 0, i32 1
  %t46 = load ptr, ptr %t45
  store ptr %t46, ptr %t47
  %t48 = load i32, ptr @g_pi
  %t49 = add i32 %t48, 1
  store i32 %t49, ptr @g_pi
  %t50 = load ptr, ptr %t47
  %t51 = load ptr, ptr %t1
  %t52 = call ptr @fn_p_add()
  %t53 = call ptr @fn_mkbin(ptr %t50, ptr %t51, ptr %t52)
  store ptr %t53, ptr %t1
  br label %wcond0
wend2:
  %t54 = load ptr, ptr %t1
  store ptr %t54, ptr %retval
  br label %ret
ret:
  %t55 = load ptr, ptr %retval
  ret ptr %t55
}

define ptr @fn_p_and() {
entry:
  %retval = alloca ptr
  %t1 = alloca ptr
  %t0 = call ptr @fn_p_cmp()
  store ptr %t0, ptr %t1
  br label %wcond0
wcond0:
  %t2 = call i32 @fn_is_id(ptr @.str35)
  %t3 = icmp ne i32 %t2, 0
  br i1 %t3, label %wbody1, label %wend2
wbody1:
  %t4 = load i32, ptr @g_pi
  %t5 = add i32 %t4, 1
  store i32 %t5, ptr @g_pi
  %t6 = load ptr, ptr %t1
  %t7 = call ptr @fn_p_cmp()
  %t8 = call ptr @fn_mkbin(ptr @.str36, ptr %t6, ptr %t7)
  store ptr %t8, ptr %t1
  br label %wcond0
wend2:
  %t9 = load ptr, ptr %t1
  store ptr %t9, ptr %retval
  br label %ret
ret:
  %t10 = load ptr, ptr %retval
  ret ptr %t10
}

define ptr @fn_p_or() {
entry:
  %retval = alloca ptr
  %t1 = alloca ptr
  %t0 = call ptr @fn_p_and()
  store ptr %t0, ptr %t1
  br label %wcond0
wcond0:
  %t2 = call i32 @fn_is_id(ptr @.str37)
  %t3 = icmp ne i32 %t2, 0
  br i1 %t3, label %wbody1, label %wend2
wbody1:
  %t4 = load i32, ptr @g_pi
  %t5 = add i32 %t4, 1
  store i32 %t5, ptr @g_pi
  %t6 = load ptr, ptr %t1
  %t7 = call ptr @fn_p_and()
  %t8 = call ptr @fn_mkbin(ptr @.str38, ptr %t6, ptr %t7)
  store ptr %t8, ptr %t1
  br label %wcond0
wend2:
  %t9 = load ptr, ptr %t1
  store ptr %t9, ptr %retval
  br label %ret
ret:
  %t10 = load ptr, ptr %retval
  ret ptr %t10
}

define ptr @fn_record() {
entry:
  %retval = alloca ptr
  %t1 = alloca ptr
  %t6 = alloca ptr
  call void @fn_eat_op(ptr @.str39)
  %t0 = call ptr @fn_node(i32 41)
  store ptr %t0, ptr %t1
  br label %wcond0
wcond0:
  %t2 = icmp ne i32 1, 0
  br i1 %t2, label %wbody1, label %wend2
wbody1:
  call void @fn_skipnl()
  %t3 = call i32 @fn_is_op(ptr @.str40)
  %t4 = icmp ne i32 %t3, 0
  br i1 %t4, label %then3, label %ifend5
then3:
  br label %wend2
ifend5:
  %t5 = call ptr @fn_node(i32 42)
  store ptr %t5, ptr %t6
  %t7 = load ptr, ptr %t6
  %t8 = getelementptr inbounds %Str_Node, ptr %t7, i32 0, i32 1
  %t9 = call ptr @fn_eat_id()
  store ptr %t9, ptr %t8
  call void @fn_eat_op(ptr @.str41)
  %t10 = load ptr, ptr %t6
  %t11 = getelementptr inbounds %Str_Node, ptr %t10, i32 0, i32 4
  %t12 = call ptr @fn_expr()
  store ptr %t12, ptr %t11
  %t13 = load ptr, ptr %t1
  %t14 = getelementptr inbounds %Str_Node, ptr %t13, i32 0, i32 7
  %t15 = load ptr, ptr %t14
  %t16 = getelementptr inbounds %LSlice, ptr %t15, i32 0, i32 1
  %t17 = getelementptr inbounds %LSlice, ptr %t15, i32 0, i32 2
  %t18 = getelementptr inbounds %LSlice, ptr %t15, i32 0, i32 0
  %t19 = load i32, ptr %t16
  %t20 = load i32, ptr %t17
  %t21 = icmp sge i32 %t19, %t20
  br i1 %t21, label %grow6, label %put7
grow6:
  %t22 = mul i32 %t20, 2
  %t23 = icmp eq i32 %t20, 0
  %t24 = select i1 %t23, i32 8, i32 %t22
  %t25 = getelementptr ptr, ptr null, i32 1
  %t26 = ptrtoint ptr %t25 to i64
  %t27 = zext i32 %t24 to i64
  %t28 = mul i64 %t27, %t26
  %t29 = load ptr, ptr %t18
  %t30 = call ptr @realloc(ptr %t29, i64 %t28)
  store ptr %t30, ptr %t18
  store i32 %t24, ptr %t17
  br label %put7
put7:
  %t31 = load ptr, ptr %t6
  %t32 = load ptr, ptr %t18
  %t33 = getelementptr inbounds ptr, ptr %t32, i32 %t19
  store ptr %t31, ptr %t33
  %t34 = add i32 %t19, 1
  store i32 %t34, ptr %t16
  %t35 = call i32 @fn_is_op(ptr @.str42)
  %t36 = icmp ne i32 %t35, 0
  br i1 %t36, label %then8, label %ifend10
then8:
  %t37 = load i32, ptr @g_pi
  %t38 = add i32 %t37, 1
  store i32 %t38, ptr @g_pi
  br label %ifend10
ifend10:
  br label %wcond0
wend2:
  call void @fn_eat_op(ptr @.str43)
  %t39 = load ptr, ptr %t1
  store ptr %t39, ptr %retval
  br label %ret
ret:
  %t40 = load ptr, ptr %retval
  ret ptr %t40
}

define ptr @fn_block() {
entry:
  %retval = alloca ptr
  %t1 = alloca ptr
  %t37 = alloca i32
  %t45 = alloca ptr
  call void @fn_skipnl()
  call void @fn_eat_op(ptr @.str44)
  %t0 = call ptr @fn_node(i32 7)
  store ptr %t0, ptr %t1
  br label %wcond0
wcond0:
  %t2 = icmp ne i32 1, 0
  br i1 %t2, label %wbody1, label %wend2
wbody1:
  call void @fn_skipnl()
  %t3 = call i32 @fn_is_op(ptr @.str45)
  %t4 = icmp ne i32 %t3, 0
  br i1 %t4, label %then3, label %ifend5
then3:
  br label %wend2
ifend5:
  %t5 = load ptr, ptr %t1
  %t6 = getelementptr inbounds %Str_Node, ptr %t5, i32 0, i32 7
  %t7 = load ptr, ptr %t6
  %t8 = getelementptr inbounds %LSlice, ptr %t7, i32 0, i32 1
  %t9 = getelementptr inbounds %LSlice, ptr %t7, i32 0, i32 2
  %t10 = getelementptr inbounds %LSlice, ptr %t7, i32 0, i32 0
  %t11 = load i32, ptr %t8
  %t12 = load i32, ptr %t9
  %t13 = icmp sge i32 %t11, %t12
  br i1 %t13, label %grow6, label %put7
grow6:
  %t14 = mul i32 %t12, 2
  %t15 = icmp eq i32 %t12, 0
  %t16 = select i1 %t15, i32 8, i32 %t14
  %t17 = getelementptr ptr, ptr null, i32 1
  %t18 = ptrtoint ptr %t17 to i64
  %t19 = zext i32 %t16 to i64
  %t20 = mul i64 %t19, %t18
  %t21 = load ptr, ptr %t10
  %t22 = call ptr @realloc(ptr %t21, i64 %t20)
  store ptr %t22, ptr %t10
  store i32 %t16, ptr %t9
  br label %put7
put7:
  %t23 = call ptr @fn_stmt()
  %t24 = load ptr, ptr %t10
  %t25 = getelementptr inbounds ptr, ptr %t24, i32 %t11
  store ptr %t23, ptr %t25
  %t26 = add i32 %t11, 1
  store i32 %t26, ptr %t8
  %t27 = load ptr, ptr @g_toks
  %t28 = getelementptr inbounds %LSlice, ptr %t27, i32 0, i32 0
  %t29 = load ptr, ptr %t28
  %t30 = load i32, ptr @g_pi
  %t31 = getelementptr inbounds ptr, ptr %t29, i32 %t30
  %t32 = load ptr, ptr %t31
  %t33 = getelementptr inbounds %Str_Tok, ptr %t32, i32 0, i32 0
  %t34 = load i32, ptr %t33
  %t35 = icmp eq i32 %t34, 4
  %t36 = zext i1 %t35 to i32
  store i32 %t36, ptr %t37
  %t38 = call i32 @fn_is_op(ptr @.str46)
  %t39 = icmp ne i32 %t38, 0
  br i1 %t39, label %then8, label %ifend10
then8:
  store i32 1, ptr %t37
  br label %ifend10
ifend10:
  %t40 = load i32, ptr %t37
  %t41 = icmp eq i32 %t40, 0
  %t42 = zext i1 %t41 to i32
  %t43 = icmp ne i32 %t42, 0
  br i1 %t43, label %then11, label %ifend13
then11:
  %t44 = load ptr, ptr @__stderrp
  store ptr %t44, ptr %t45
  %t46 = load ptr, ptr %t45
  %t47 = zext i32 4 to i64
  %t48 = call i64 @fwrite(ptr @.str47, i64 1, i64 %t47, ptr %t46)
  %t49 = trunc i64 %t48 to i32
  %t50 = load ptr, ptr @g_toks
  %t51 = getelementptr inbounds %LSlice, ptr %t50, i32 0, i32 0
  %t52 = load ptr, ptr %t51
  %t53 = load i32, ptr @g_pi
  %t54 = getelementptr inbounds ptr, ptr %t52, i32 %t53
  %t55 = load ptr, ptr %t54
  %t56 = getelementptr inbounds %Str_Tok, ptr %t55, i32 0, i32 1
  %t57 = load ptr, ptr %t56
  %t58 = icmp eq ptr %t57, null
  %t59 = zext i1 %t58 to i32
  %t60 = icmp eq i32 %t59, 0
  %t61 = zext i1 %t60 to i32
  %t62 = icmp ne i32 %t61, 0
  br i1 %t62, label %then14, label %ifend16
then14:
  %t63 = load ptr, ptr %t45
  %t64 = load ptr, ptr @g_toks
  %t65 = getelementptr inbounds %LSlice, ptr %t64, i32 0, i32 0
  %t66 = load ptr, ptr %t65
  %t67 = load i32, ptr @g_pi
  %t68 = getelementptr inbounds ptr, ptr %t66, i32 %t67
  %t69 = load ptr, ptr %t68
  %t70 = getelementptr inbounds %Str_Tok, ptr %t69, i32 0, i32 1
  %t71 = load ptr, ptr %t70
  %t72 = load ptr, ptr @g_toks
  %t73 = getelementptr inbounds %LSlice, ptr %t72, i32 0, i32 0
  %t74 = load ptr, ptr %t73
  %t75 = load i32, ptr @g_pi
  %t76 = getelementptr inbounds ptr, ptr %t74, i32 %t75
  %t77 = load ptr, ptr %t76
  %t78 = getelementptr inbounds %Str_Tok, ptr %t77, i32 0, i32 1
  %t79 = load ptr, ptr %t78
  %t80 = call i32 @fn_slen(ptr %t79)
  %t81 = zext i32 %t80 to i64
  %t82 = call i64 @fwrite(ptr %t71, i64 1, i64 %t81, ptr %t63)
  %t83 = trunc i64 %t82 to i32
  br label %ifend16
ifend16:
  %t84 = load ptr, ptr %t45
  %t85 = zext i32 1 to i64
  %t86 = call i64 @fwrite(ptr @.str48, i64 1, i64 %t85, ptr %t84)
  %t87 = trunc i64 %t86 to i32
  %t88 = load ptr, ptr @g_toks
  %t89 = getelementptr inbounds %LSlice, ptr %t88, i32 0, i32 0
  %t90 = load ptr, ptr %t89
  %t91 = load i32, ptr @g_pi
  %t92 = getelementptr inbounds ptr, ptr %t90, i32 %t91
  %t93 = load ptr, ptr %t92
  %t94 = getelementptr inbounds %Str_Tok, ptr %t93, i32 0, i32 3
  %t95 = load i32, ptr %t94
  %t96 = add i32 7770000, %t95
  call i32 (ptr, ...) @printf(ptr @.fmt_int, i32 %t96)
  call void @fn_perr(ptr @.str49)
  br label %ifend13
ifend13:
  br label %wcond0
wend2:
  call void @fn_eat_op(ptr @.str50)
  %t97 = load ptr, ptr %t1
  store ptr %t97, ptr %retval
  br label %ret
ret:
  %t98 = load ptr, ptr %retval
  ret ptr %t98
}

define ptr @fn_stmt() {
entry:
  %retval = alloca ptr
  %t6 = alloca ptr
  %t21 = alloca ptr
  %t48 = alloca ptr
  %t49 = alloca i32
  %t81 = alloca ptr
  %t89 = alloca i32
  %t112 = alloca ptr
  %t128 = alloca ptr
  %t147 = alloca ptr
  %t152 = alloca ptr
  %t177 = alloca ptr
  %t181 = alloca i32
  %t186 = alloca ptr
  %t188 = alloca ptr
  %t200 = alloca ptr
  %t243 = alloca ptr
  %t256 = alloca ptr
  %t271 = alloca ptr
  %t300 = alloca ptr
  %t308 = alloca ptr
  %t342 = alloca ptr
  %t392 = alloca ptr
  %t393 = alloca i32
  %t394 = alloca i32
  %t395 = alloca i32
  %t396 = alloca i32
  %t424 = alloca ptr
  %t445 = alloca ptr
  %t0 = load ptr, ptr @g_toks
  %t1 = getelementptr inbounds %LSlice, ptr %t0, i32 0, i32 0
  %t2 = load ptr, ptr %t1
  %t3 = load i32, ptr @g_pi
  %t4 = getelementptr inbounds ptr, ptr %t2, i32 %t3
  %t5 = load ptr, ptr %t4
  store ptr %t5, ptr %t6
  %t7 = load ptr, ptr %t6
  %t8 = getelementptr inbounds %Str_Tok, ptr %t7, i32 0, i32 0
  %t9 = load i32, ptr %t8
  %t10 = icmp eq i32 %t9, 0
  %t11 = zext i1 %t10 to i32
  %t12 = icmp ne i32 %t11, 0
  br i1 %t12, label %then0, label %ifend2
then0:
  %t13 = load ptr, ptr %t6
  %t14 = getelementptr inbounds %Str_Tok, ptr %t13, i32 0, i32 1
  %t15 = load ptr, ptr %t14
  %t16 = call i32 @fn_streq(ptr %t15, ptr @.str51)
  %t17 = icmp ne i32 %t16, 0
  br i1 %t17, label %then3, label %ifend5
then3:
  %t18 = load i32, ptr @g_pi
  %t19 = add i32 %t18, 1
  store i32 %t19, ptr @g_pi
  %t20 = call ptr @fn_node(i32 10)
  store ptr %t20, ptr %t21
  %t22 = load ptr, ptr %t21
  %t23 = getelementptr inbounds %Str_Node, ptr %t22, i32 0, i32 1
  %t24 = call ptr @fn_eat_id()
  store ptr %t24, ptr %t23
  %t25 = call i32 @fn_is_op(ptr @.str52)
  %t26 = icmp ne i32 %t25, 0
  br i1 %t26, label %then6, label %ifend8
then6:
  %t27 = load i32, ptr @g_pi
  %t28 = add i32 %t27, 1
  store i32 %t28, ptr @g_pi
  %t29 = load ptr, ptr %t21
  %t30 = getelementptr inbounds %Str_Node, ptr %t29, i32 0, i32 3
  %t31 = call ptr @fn_ptype()
  store ptr %t31, ptr %t30
  br label %ifend8
ifend8:
  %t32 = call i32 @fn_is_op(ptr @.str53)
  %t33 = icmp ne i32 %t32, 0
  br i1 %t33, label %then9, label %ifend11
then9:
  %t34 = load i32, ptr @g_pi
  %t35 = add i32 %t34, 1
  store i32 %t35, ptr @g_pi
  %t36 = load ptr, ptr %t21
  %t37 = getelementptr inbounds %Str_Node, ptr %t36, i32 0, i32 4
  %t38 = call ptr @fn_expr()
  store ptr %t38, ptr %t37
  br label %ifend11
ifend11:
  %t39 = load ptr, ptr %t21
  store ptr %t39, ptr %retval
  br label %ret
ifend5:
  %t40 = load ptr, ptr %t6
  %t41 = getelementptr inbounds %Str_Tok, ptr %t40, i32 0, i32 1
  %t42 = load ptr, ptr %t41
  %t43 = call i32 @fn_streq(ptr %t42, ptr @.str54)
  %t44 = icmp ne i32 %t43, 0
  br i1 %t44, label %then12, label %ifend14
then12:
  %t45 = load i32, ptr @g_pi
  %t46 = add i32 %t45, 1
  store i32 %t46, ptr @g_pi
  %t47 = call ptr @fn_node(i32 15)
  store ptr %t47, ptr %t48
  %t50 = load ptr, ptr @g_toks
  %t51 = getelementptr inbounds %LSlice, ptr %t50, i32 0, i32 0
  %t52 = load ptr, ptr %t51
  %t53 = load i32, ptr @g_pi
  %t54 = getelementptr inbounds ptr, ptr %t52, i32 %t53
  %t55 = load ptr, ptr %t54
  %t56 = getelementptr inbounds %Str_Tok, ptr %t55, i32 0, i32 0
  %t57 = load i32, ptr %t56
  %t58 = icmp ne i32 %t57, 4
  %t59 = zext i1 %t58 to i32
  %t60 = icmp ne i32 %t59, 0
  %t61 = zext i1 %t60 to i32
  store i32 %t61, ptr %t49
  br i1 %t60, label %sc15, label %scend16
sc15:
  %t62 = call i32 @fn_is_op(ptr @.str55)
  %t63 = icmp eq i32 %t62, 0
  %t64 = zext i1 %t63 to i32
  %t65 = icmp ne i32 %t64, 0
  %t66 = zext i1 %t65 to i32
  store i32 %t66, ptr %t49
  br label %scend16
scend16:
  %t67 = load i32, ptr %t49
  %t68 = icmp ne i32 %t67, 0
  br i1 %t68, label %then17, label %ifend19
then17:
  %t69 = load ptr, ptr %t48
  %t70 = getelementptr inbounds %Str_Node, ptr %t69, i32 0, i32 4
  %t71 = call ptr @fn_expr()
  store ptr %t71, ptr %t70
  br label %ifend19
ifend19:
  %t72 = load ptr, ptr %t48
  store ptr %t72, ptr %retval
  br label %ret
ifend14:
  %t73 = load ptr, ptr %t6
  %t74 = getelementptr inbounds %Str_Tok, ptr %t73, i32 0, i32 1
  %t75 = load ptr, ptr %t74
  %t76 = call i32 @fn_streq(ptr %t75, ptr @.str56)
  %t77 = icmp ne i32 %t76, 0
  br i1 %t77, label %then20, label %ifend22
then20:
  %t78 = load i32, ptr @g_pi
  %t79 = add i32 %t78, 1
  store i32 %t79, ptr @g_pi
  %t80 = call ptr @fn_node(i32 12)
  store ptr %t80, ptr %t81
  %t82 = load ptr, ptr %t81
  %t83 = getelementptr inbounds %Str_Node, ptr %t82, i32 0, i32 4
  %t84 = call ptr @fn_expr()
  store ptr %t84, ptr %t83
  %t85 = load ptr, ptr %t81
  %t86 = getelementptr inbounds %Str_Node, ptr %t85, i32 0, i32 5
  %t87 = call ptr @fn_block()
  store ptr %t87, ptr %t86
  %t88 = load i32, ptr @g_pi
  store i32 %t88, ptr %t89
  call void @fn_skipnl()
  %t90 = call i32 @fn_is_id(ptr @.str57)
  %t91 = icmp ne i32 %t90, 0
  br i1 %t91, label %then23, label %else24
then23:
  %t92 = load i32, ptr @g_pi
  %t93 = add i32 %t92, 1
  store i32 %t93, ptr @g_pi
  call void @fn_skipnl()
  %t94 = call i32 @fn_is_id(ptr @.str58)
  %t95 = icmp ne i32 %t94, 0
  br i1 %t95, label %then26, label %else27
then26:
  %t96 = load ptr, ptr %t81
  %t97 = getelementptr inbounds %Str_Node, ptr %t96, i32 0, i32 6
  %t98 = call ptr @fn_stmt()
  store ptr %t98, ptr %t97
  br label %ifend28
else27:
  %t99 = load ptr, ptr %t81
  %t100 = getelementptr inbounds %Str_Node, ptr %t99, i32 0, i32 6
  %t101 = call ptr @fn_block()
  store ptr %t101, ptr %t100
  br label %ifend28
ifend28:
  br label %ifend25
else24:
  %t102 = load i32, ptr %t89
  store i32 %t102, ptr @g_pi
  br label %ifend25
ifend25:
  %t103 = load ptr, ptr %t81
  store ptr %t103, ptr %retval
  br label %ret
ifend22:
  %t104 = load ptr, ptr %t6
  %t105 = getelementptr inbounds %Str_Tok, ptr %t104, i32 0, i32 1
  %t106 = load ptr, ptr %t105
  %t107 = call i32 @fn_streq(ptr %t106, ptr @.str59)
  %t108 = icmp ne i32 %t107, 0
  br i1 %t108, label %then29, label %ifend31
then29:
  %t109 = load i32, ptr @g_pi
  %t110 = add i32 %t109, 1
  store i32 %t110, ptr @g_pi
  %t111 = call ptr @fn_node(i32 12)
  store ptr %t111, ptr %t112
  %t113 = load ptr, ptr %t112
  %t114 = getelementptr inbounds %Str_Node, ptr %t113, i32 0, i32 4
  %t115 = call ptr @fn_expr()
  store ptr %t115, ptr %t114
  %t116 = load ptr, ptr %t112
  %t117 = getelementptr inbounds %Str_Node, ptr %t116, i32 0, i32 5
  %t118 = call ptr @fn_block()
  store ptr %t118, ptr %t117
  %t119 = load ptr, ptr %t112
  store ptr %t119, ptr %retval
  br label %ret
ifend31:
  %t120 = load ptr, ptr %t6
  %t121 = getelementptr inbounds %Str_Tok, ptr %t120, i32 0, i32 1
  %t122 = load ptr, ptr %t121
  %t123 = call i32 @fn_streq(ptr %t122, ptr @.str60)
  %t124 = icmp ne i32 %t123, 0
  br i1 %t124, label %then32, label %ifend34
then32:
  %t125 = load i32, ptr @g_pi
  %t126 = add i32 %t125, 1
  store i32 %t126, ptr @g_pi
  %t127 = call ptr @fn_node(i32 13)
  store ptr %t127, ptr %t128
  %t129 = load ptr, ptr %t128
  %t130 = getelementptr inbounds %Str_Node, ptr %t129, i32 0, i32 4
  %t131 = call ptr @fn_expr()
  store ptr %t131, ptr %t130
  %t132 = load ptr, ptr %t128
  %t133 = getelementptr inbounds %Str_Node, ptr %t132, i32 0, i32 5
  %t134 = call ptr @fn_block()
  store ptr %t134, ptr %t133
  %t135 = load ptr, ptr %t128
  store ptr %t135, ptr %retval
  br label %ret
ifend34:
  %t136 = load ptr, ptr %t6
  %t137 = getelementptr inbounds %Str_Tok, ptr %t136, i32 0, i32 1
  %t138 = load ptr, ptr %t137
  %t139 = call i32 @fn_streq(ptr %t138, ptr @.str61)
  %t140 = icmp ne i32 %t139, 0
  br i1 %t140, label %then35, label %ifend37
then35:
  %t141 = load i32, ptr @g_pi
  %t142 = add i32 %t141, 1
  store i32 %t142, ptr @g_pi
  %t143 = call i32 @fn_is_op(ptr @.str62)
  %t144 = icmp ne i32 %t143, 0
  br i1 %t144, label %then38, label %ifend40
then38:
  %t145 = call ptr @fn_parse_query_for()
  store ptr %t145, ptr %retval
  br label %ret
ifend40:
  %t146 = call ptr @fn_node(i32 14)
  store ptr %t146, ptr %t147
  %t148 = load ptr, ptr %t147
  %t149 = getelementptr inbounds %Str_Node, ptr %t148, i32 0, i32 1
  %t150 = call ptr @fn_eat_id()
  store ptr %t150, ptr %t149
  %t151 = call ptr @fn_eat_id()
  store ptr %t151, ptr %t152
  %t153 = load ptr, ptr %t147
  %t154 = getelementptr inbounds %Str_Node, ptr %t153, i32 0, i32 4
  %t155 = call ptr @fn_expr()
  store ptr %t155, ptr %t154
  call void @fn_eat_op(ptr @.str63)
  %t156 = load ptr, ptr %t147
  %t157 = getelementptr inbounds %Str_Node, ptr %t156, i32 0, i32 5
  %t158 = call ptr @fn_expr()
  store ptr %t158, ptr %t157
  %t159 = load ptr, ptr %t147
  %t160 = getelementptr inbounds %Str_Node, ptr %t159, i32 0, i32 6
  %t161 = call ptr @fn_block()
  store ptr %t161, ptr %t160
  %t162 = load ptr, ptr %t147
  store ptr %t162, ptr %retval
  br label %ret
ifend37:
  %t163 = load ptr, ptr %t6
  %t164 = getelementptr inbounds %Str_Tok, ptr %t163, i32 0, i32 1
  %t165 = load ptr, ptr %t164
  %t166 = call i32 @fn_streq(ptr %t165, ptr @.str64)
  %t167 = icmp ne i32 %t166, 0
  br i1 %t167, label %then41, label %ifend43
then41:
  %t168 = call ptr @fn_parse_spawn()
  store ptr %t168, ptr %retval
  br label %ret
ifend43:
  %t169 = load ptr, ptr %t6
  %t170 = getelementptr inbounds %Str_Tok, ptr %t169, i32 0, i32 1
  %t171 = load ptr, ptr %t170
  %t172 = call i32 @fn_streq(ptr %t171, ptr @.str65)
  %t173 = icmp ne i32 %t172, 0
  br i1 %t173, label %then44, label %ifend46
then44:
  %t174 = load i32, ptr @g_pi
  %t175 = add i32 %t174, 1
  store i32 %t175, ptr @g_pi
  %t176 = call ptr @fn_node(i32 24)
  store ptr %t176, ptr %t177
  %t178 = load ptr, ptr %t177
  %t179 = getelementptr inbounds %Str_Node, ptr %t178, i32 0, i32 4
  %t180 = call ptr @fn_expr()
  store ptr %t180, ptr %t179
  call void @fn_skipnl()
  call void @fn_eat_op(ptr @.str66)
  store i32 0, ptr %t181
  br label %wcond47
wcond47:
  %t182 = icmp ne i32 1, 0
  br i1 %t182, label %wbody48, label %wend49
wbody48:
  call void @fn_skipnl()
  %t183 = call i32 @fn_is_op(ptr @.str67)
  %t184 = icmp ne i32 %t183, 0
  br i1 %t184, label %then50, label %ifend52
then50:
  br label %wend49
ifend52:
  %t185 = call ptr @fn_eat_id()
  store ptr %t185, ptr %t186
  %t187 = call ptr @fn_node(i32 25)
  store ptr %t187, ptr %t188
  %t189 = load ptr, ptr %t188
  %t190 = getelementptr inbounds %Str_Node, ptr %t189, i32 0, i32 1
  %t191 = call ptr @fn_eat_id()
  store ptr %t191, ptr %t190
  %t192 = call i32 @fn_is_op(ptr @.str68)
  %t193 = icmp ne i32 %t192, 0
  br i1 %t193, label %then53, label %else54
then53:
  %t194 = load i32, ptr @g_pi
  %t195 = add i32 %t194, 1
  store i32 %t195, ptr @g_pi
  %t196 = load ptr, ptr %t188
  %t197 = getelementptr inbounds %Str_Node, ptr %t196, i32 0, i32 5
  %t198 = call ptr @fn_expr()
  store ptr %t198, ptr %t197
  br label %ifend55
else54:
  %t199 = call ptr @fn_node(i32 30)
  store ptr %t199, ptr %t200
  %t201 = load ptr, ptr %t200
  %t202 = getelementptr inbounds %Str_Node, ptr %t201, i32 0, i32 2
  %t203 = load i32, ptr %t181
  store i32 %t203, ptr %t202
  %t204 = load ptr, ptr %t188
  %t205 = getelementptr inbounds %Str_Node, ptr %t204, i32 0, i32 5
  %t206 = load ptr, ptr %t200
  store ptr %t206, ptr %t205
  br label %ifend55
ifend55:
  call void @fn_skipnl()
  %t207 = load ptr, ptr %t188
  %t208 = getelementptr inbounds %Str_Node, ptr %t207, i32 0, i32 4
  %t209 = call ptr @fn_block()
  store ptr %t209, ptr %t208
  %t210 = load ptr, ptr %t177
  %t211 = getelementptr inbounds %Str_Node, ptr %t210, i32 0, i32 7
  %t212 = load ptr, ptr %t211
  %t213 = getelementptr inbounds %LSlice, ptr %t212, i32 0, i32 1
  %t214 = getelementptr inbounds %LSlice, ptr %t212, i32 0, i32 2
  %t215 = getelementptr inbounds %LSlice, ptr %t212, i32 0, i32 0
  %t216 = load i32, ptr %t213
  %t217 = load i32, ptr %t214
  %t218 = icmp sge i32 %t216, %t217
  br i1 %t218, label %grow56, label %put57
grow56:
  %t219 = mul i32 %t217, 2
  %t220 = icmp eq i32 %t217, 0
  %t221 = select i1 %t220, i32 8, i32 %t219
  %t222 = getelementptr ptr, ptr null, i32 1
  %t223 = ptrtoint ptr %t222 to i64
  %t224 = zext i32 %t221 to i64
  %t225 = mul i64 %t224, %t223
  %t226 = load ptr, ptr %t215
  %t227 = call ptr @realloc(ptr %t226, i64 %t225)
  store ptr %t227, ptr %t215
  store i32 %t221, ptr %t214
  br label %put57
put57:
  %t228 = load ptr, ptr %t188
  %t229 = load ptr, ptr %t215
  %t230 = getelementptr inbounds ptr, ptr %t229, i32 %t216
  store ptr %t228, ptr %t230
  %t231 = add i32 %t216, 1
  store i32 %t231, ptr %t213
  %t232 = load i32, ptr %t181
  %t233 = add i32 %t232, 1
  store i32 %t233, ptr %t181
  br label %wcond47
wend49:
  call void @fn_eat_op(ptr @.str69)
  %t234 = load ptr, ptr %t177
  store ptr %t234, ptr %retval
  br label %ret
ifend46:
  %t235 = load ptr, ptr %t6
  %t236 = getelementptr inbounds %Str_Tok, ptr %t235, i32 0, i32 1
  %t237 = load ptr, ptr %t236
  %t238 = call i32 @fn_streq(ptr %t237, ptr @.str70)
  %t239 = icmp ne i32 %t238, 0
  br i1 %t239, label %then58, label %ifend60
then58:
  %t240 = load i32, ptr @g_pi
  %t241 = add i32 %t240, 1
  store i32 %t241, ptr @g_pi
  %t242 = call ptr @fn_node(i32 26)
  store ptr %t242, ptr %t243
  %t244 = load ptr, ptr %t243
  %t245 = getelementptr inbounds %Str_Node, ptr %t244, i32 0, i32 1
  %t246 = call ptr @fn_eat_id()
  store ptr %t246, ptr %t245
  %t247 = load ptr, ptr %t243
  store ptr %t247, ptr %retval
  br label %ret
ifend60:
  %t248 = load ptr, ptr %t6
  %t249 = getelementptr inbounds %Str_Tok, ptr %t248, i32 0, i32 1
  %t250 = load ptr, ptr %t249
  %t251 = call i32 @fn_streq(ptr %t250, ptr @.str71)
  %t252 = icmp ne i32 %t251, 0
  br i1 %t252, label %then61, label %ifend63
then61:
  %t253 = load i32, ptr @g_pi
  %t254 = add i32 %t253, 1
  store i32 %t254, ptr @g_pi
  %t255 = call ptr @fn_node(i32 26)
  store ptr %t255, ptr %t256
  %t257 = load ptr, ptr %t256
  %t258 = getelementptr inbounds %Str_Node, ptr %t257, i32 0, i32 1
  %t259 = call ptr @fn_eat_id()
  store ptr %t259, ptr %t258
  %t260 = load ptr, ptr %t256
  %t261 = getelementptr inbounds %Str_Node, ptr %t260, i32 0, i32 2
  store i32 1, ptr %t261
  %t262 = load ptr, ptr %t256
  store ptr %t262, ptr %retval
  br label %ret
ifend63:
  %t263 = load ptr, ptr %t6
  %t264 = getelementptr inbounds %Str_Tok, ptr %t263, i32 0, i32 1
  %t265 = load ptr, ptr %t264
  %t266 = call i32 @fn_streq(ptr %t265, ptr @.str72)
  %t267 = icmp ne i32 %t266, 0
  br i1 %t267, label %then64, label %ifend66
then64:
  %t268 = load i32, ptr @g_pi
  %t269 = add i32 %t268, 1
  store i32 %t269, ptr @g_pi
  %t270 = call ptr @fn_node(i32 23)
  store ptr %t270, ptr %t271
  %t272 = load ptr, ptr %t271
  %t273 = getelementptr inbounds %Str_Node, ptr %t272, i32 0, i32 4
  %t274 = call ptr @fn_expr()
  store ptr %t274, ptr %t273
  %t275 = load ptr, ptr %t271
  store ptr %t275, ptr %retval
  br label %ret
ifend66:
  %t276 = load ptr, ptr %t6
  %t277 = getelementptr inbounds %Str_Tok, ptr %t276, i32 0, i32 1
  %t278 = load ptr, ptr %t277
  %t279 = call i32 @fn_streq(ptr %t278, ptr @.str73)
  %t280 = icmp ne i32 %t279, 0
  br i1 %t280, label %then67, label %ifend69
then67:
  %t281 = load i32, ptr @g_pi
  %t282 = add i32 %t281, 1
  store i32 %t282, ptr @g_pi
  %t283 = call ptr @fn_node(i32 17)
  store ptr %t283, ptr %retval
  br label %ret
ifend69:
  %t284 = load ptr, ptr %t6
  %t285 = getelementptr inbounds %Str_Tok, ptr %t284, i32 0, i32 1
  %t286 = load ptr, ptr %t285
  %t287 = call i32 @fn_streq(ptr %t286, ptr @.str74)
  %t288 = icmp ne i32 %t287, 0
  br i1 %t288, label %then70, label %ifend72
then70:
  %t289 = load i32, ptr @g_pi
  %t290 = add i32 %t289, 1
  store i32 %t290, ptr @g_pi
  %t291 = call ptr @fn_node(i32 18)
  store ptr %t291, ptr %retval
  br label %ret
ifend72:
  %t292 = load ptr, ptr %t6
  %t293 = getelementptr inbounds %Str_Tok, ptr %t292, i32 0, i32 1
  %t294 = load ptr, ptr %t293
  %t295 = call i32 @fn_streq(ptr %t294, ptr @.str75)
  %t296 = icmp ne i32 %t295, 0
  br i1 %t296, label %then73, label %ifend75
then73:
  %t297 = load i32, ptr @g_pi
  %t298 = add i32 %t297, 1
  store i32 %t298, ptr @g_pi
  %t299 = call ptr @fn_node(i32 19)
  store ptr %t299, ptr %t300
  %t301 = load ptr, ptr %t300
  %t302 = getelementptr inbounds %Str_Node, ptr %t301, i32 0, i32 4
  %t303 = call ptr @fn_expr()
  store ptr %t303, ptr %t302
  call void @fn_skipnl()
  call void @fn_eat_op(ptr @.str76)
  br label %wcond76
wcond76:
  %t304 = icmp ne i32 1, 0
  br i1 %t304, label %wbody77, label %wend78
wbody77:
  call void @fn_skipnl()
  %t305 = call i32 @fn_is_op(ptr @.str77)
  %t306 = icmp ne i32 %t305, 0
  br i1 %t306, label %then79, label %ifend81
then79:
  br label %wend78
ifend81:
  %t307 = call ptr @fn_node(i32 20)
  store ptr %t307, ptr %t308
  br label %wcond82
wcond82:
  %t309 = icmp ne i32 1, 0
  br i1 %t309, label %wbody83, label %wend84
wbody83:
  %t310 = load ptr, ptr %t308
  %t311 = getelementptr inbounds %Str_Node, ptr %t310, i32 0, i32 7
  %t312 = load ptr, ptr %t311
  %t313 = getelementptr inbounds %LSlice, ptr %t312, i32 0, i32 1
  %t314 = getelementptr inbounds %LSlice, ptr %t312, i32 0, i32 2
  %t315 = getelementptr inbounds %LSlice, ptr %t312, i32 0, i32 0
  %t316 = load i32, ptr %t313
  %t317 = load i32, ptr %t314
  %t318 = icmp sge i32 %t316, %t317
  br i1 %t318, label %grow85, label %put86
grow85:
  %t319 = mul i32 %t317, 2
  %t320 = icmp eq i32 %t317, 0
  %t321 = select i1 %t320, i32 8, i32 %t319
  %t322 = getelementptr ptr, ptr null, i32 1
  %t323 = ptrtoint ptr %t322 to i64
  %t324 = zext i32 %t321 to i64
  %t325 = mul i64 %t324, %t323
  %t326 = load ptr, ptr %t315
  %t327 = call ptr @realloc(ptr %t326, i64 %t325)
  store ptr %t327, ptr %t315
  store i32 %t321, ptr %t314
  br label %put86
put86:
  %t328 = call ptr @fn_expr()
  %t329 = load ptr, ptr %t315
  %t330 = getelementptr inbounds ptr, ptr %t329, i32 %t316
  store ptr %t328, ptr %t330
  %t331 = add i32 %t316, 1
  store i32 %t331, ptr %t313
  %t332 = call i32 @fn_is_op(ptr @.str78)
  %t333 = icmp ne i32 %t332, 0
  br i1 %t333, label %then87, label %ifend89
then87:
  %t334 = load i32, ptr @g_pi
  %t335 = add i32 %t334, 1
  store i32 %t335, ptr @g_pi
  call void @fn_skipnl()
  br label %wcond82
ifend89:
  br label %wend84
wend84:
  call void @fn_eat_op(ptr @.str79)
  call void @fn_skipnl()
  %t336 = call i32 @fn_is_op(ptr @.str80)
  %t337 = icmp ne i32 %t336, 0
  br i1 %t337, label %then90, label %else91
then90:
  %t338 = load ptr, ptr %t308
  %t339 = getelementptr inbounds %Str_Node, ptr %t338, i32 0, i32 4
  %t340 = call ptr @fn_block()
  store ptr %t340, ptr %t339
  br label %ifend92
else91:
  %t341 = call ptr @fn_node(i32 7)
  store ptr %t341, ptr %t342
  %t343 = load ptr, ptr %t342
  %t344 = getelementptr inbounds %Str_Node, ptr %t343, i32 0, i32 7
  %t345 = load ptr, ptr %t344
  %t346 = getelementptr inbounds %LSlice, ptr %t345, i32 0, i32 1
  %t347 = getelementptr inbounds %LSlice, ptr %t345, i32 0, i32 2
  %t348 = getelementptr inbounds %LSlice, ptr %t345, i32 0, i32 0
  %t349 = load i32, ptr %t346
  %t350 = load i32, ptr %t347
  %t351 = icmp sge i32 %t349, %t350
  br i1 %t351, label %grow93, label %put94
grow93:
  %t352 = mul i32 %t350, 2
  %t353 = icmp eq i32 %t350, 0
  %t354 = select i1 %t353, i32 8, i32 %t352
  %t355 = getelementptr ptr, ptr null, i32 1
  %t356 = ptrtoint ptr %t355 to i64
  %t357 = zext i32 %t354 to i64
  %t358 = mul i64 %t357, %t356
  %t359 = load ptr, ptr %t348
  %t360 = call ptr @realloc(ptr %t359, i64 %t358)
  store ptr %t360, ptr %t348
  store i32 %t354, ptr %t347
  br label %put94
put94:
  %t361 = call ptr @fn_stmt()
  %t362 = load ptr, ptr %t348
  %t363 = getelementptr inbounds ptr, ptr %t362, i32 %t349
  store ptr %t361, ptr %t363
  %t364 = add i32 %t349, 1
  store i32 %t364, ptr %t346
  %t365 = load ptr, ptr %t308
  %t366 = getelementptr inbounds %Str_Node, ptr %t365, i32 0, i32 4
  %t367 = load ptr, ptr %t342
  store ptr %t367, ptr %t366
  br label %ifend92
ifend92:
  %t368 = load ptr, ptr %t300
  %t369 = getelementptr inbounds %Str_Node, ptr %t368, i32 0, i32 7
  %t370 = load ptr, ptr %t369
  %t371 = getelementptr inbounds %LSlice, ptr %t370, i32 0, i32 1
  %t372 = getelementptr inbounds %LSlice, ptr %t370, i32 0, i32 2
  %t373 = getelementptr inbounds %LSlice, ptr %t370, i32 0, i32 0
  %t374 = load i32, ptr %t371
  %t375 = load i32, ptr %t372
  %t376 = icmp sge i32 %t374, %t375
  br i1 %t376, label %grow95, label %put96
grow95:
  %t377 = mul i32 %t375, 2
  %t378 = icmp eq i32 %t375, 0
  %t379 = select i1 %t378, i32 8, i32 %t377
  %t380 = getelementptr ptr, ptr null, i32 1
  %t381 = ptrtoint ptr %t380 to i64
  %t382 = zext i32 %t379 to i64
  %t383 = mul i64 %t382, %t381
  %t384 = load ptr, ptr %t373
  %t385 = call ptr @realloc(ptr %t384, i64 %t383)
  store ptr %t385, ptr %t373
  store i32 %t379, ptr %t372
  br label %put96
put96:
  %t386 = load ptr, ptr %t308
  %t387 = load ptr, ptr %t373
  %t388 = getelementptr inbounds ptr, ptr %t387, i32 %t374
  store ptr %t386, ptr %t388
  %t389 = add i32 %t374, 1
  store i32 %t389, ptr %t371
  br label %wcond76
wend78:
  call void @fn_eat_op(ptr @.str81)
  %t390 = load ptr, ptr %t300
  store ptr %t390, ptr %retval
  br label %ret
ifend75:
  br label %ifend2
ifend2:
  %t391 = call ptr @fn_expr()
  store ptr %t391, ptr %t392
  %t397 = call i32 @fn_is_op(ptr @.str82)
  %t398 = icmp ne i32 %t397, 0
  %t399 = zext i1 %t398 to i32
  store i32 %t399, ptr %t396
  br i1 %t398, label %scend98, label %sc97
sc97:
  %t400 = call i32 @fn_is_op(ptr @.str83)
  %t401 = icmp ne i32 %t400, 0
  %t402 = zext i1 %t401 to i32
  store i32 %t402, ptr %t396
  br label %scend98
scend98:
  %t403 = load i32, ptr %t396
  %t404 = icmp ne i32 %t403, 0
  %t405 = zext i1 %t404 to i32
  store i32 %t405, ptr %t395
  br i1 %t404, label %scend100, label %sc99
sc99:
  %t406 = call i32 @fn_is_op(ptr @.str84)
  %t407 = icmp ne i32 %t406, 0
  %t408 = zext i1 %t407 to i32
  store i32 %t408, ptr %t395
  br label %scend100
scend100:
  %t409 = load i32, ptr %t395
  %t410 = icmp ne i32 %t409, 0
  %t411 = zext i1 %t410 to i32
  store i32 %t411, ptr %t394
  br i1 %t410, label %scend102, label %sc101
sc101:
  %t412 = call i32 @fn_is_op(ptr @.str85)
  %t413 = icmp ne i32 %t412, 0
  %t414 = zext i1 %t413 to i32
  store i32 %t414, ptr %t394
  br label %scend102
scend102:
  %t415 = load i32, ptr %t394
  %t416 = icmp ne i32 %t415, 0
  %t417 = zext i1 %t416 to i32
  store i32 %t417, ptr %t393
  br i1 %t416, label %scend104, label %sc103
sc103:
  %t418 = call i32 @fn_is_op(ptr @.str86)
  %t419 = icmp ne i32 %t418, 0
  %t420 = zext i1 %t419 to i32
  store i32 %t420, ptr %t393
  br label %scend104
scend104:
  %t421 = load i32, ptr %t393
  %t422 = icmp ne i32 %t421, 0
  br i1 %t422, label %then105, label %ifend107
then105:
  %t423 = call ptr @fn_node(i32 11)
  store ptr %t423, ptr %t424
  %t425 = load ptr, ptr %t424
  %t426 = getelementptr inbounds %Str_Node, ptr %t425, i32 0, i32 1
  %t427 = load ptr, ptr @g_toks
  %t428 = getelementptr inbounds %LSlice, ptr %t427, i32 0, i32 0
  %t429 = load ptr, ptr %t428
  %t430 = load i32, ptr @g_pi
  %t431 = getelementptr inbounds ptr, ptr %t429, i32 %t430
  %t432 = load ptr, ptr %t431
  %t433 = getelementptr inbounds %Str_Tok, ptr %t432, i32 0, i32 1
  %t434 = load ptr, ptr %t433
  store ptr %t434, ptr %t426
  %t435 = load i32, ptr @g_pi
  %t436 = add i32 %t435, 1
  store i32 %t436, ptr @g_pi
  %t437 = load ptr, ptr %t424
  %t438 = getelementptr inbounds %Str_Node, ptr %t437, i32 0, i32 4
  %t439 = load ptr, ptr %t392
  store ptr %t439, ptr %t438
  %t440 = load ptr, ptr %t424
  %t441 = getelementptr inbounds %Str_Node, ptr %t440, i32 0, i32 5
  %t442 = call ptr @fn_expr()
  store ptr %t442, ptr %t441
  %t443 = load ptr, ptr %t424
  store ptr %t443, ptr %retval
  br label %ret
ifend107:
  %t444 = call ptr @fn_node(i32 16)
  store ptr %t444, ptr %t445
  %t446 = load ptr, ptr %t445
  %t447 = getelementptr inbounds %Str_Node, ptr %t446, i32 0, i32 4
  %t448 = load ptr, ptr %t392
  store ptr %t448, ptr %t447
  %t449 = load ptr, ptr %t445
  store ptr %t449, ptr %retval
  br label %ret
ret:
  %t450 = load ptr, ptr %retval
  ret ptr %t450
}

define ptr @fn_parse_struct() {
entry:
  %retval = alloca ptr
  %t3 = alloca ptr
  %t11 = alloca ptr
  %t0 = load i32, ptr @g_pi
  %t1 = add i32 %t0, 1
  store i32 %t1, ptr @g_pi
  %t2 = call ptr @fn_node(i32 0)
  store ptr %t2, ptr %t3
  %t4 = load ptr, ptr %t3
  %t5 = getelementptr inbounds %Str_Node, ptr %t4, i32 0, i32 1
  %t6 = call ptr @fn_eat_id()
  store ptr %t6, ptr %t5
  call void @fn_skipnl()
  call void @fn_eat_op(ptr @.str87)
  br label %wcond0
wcond0:
  %t7 = icmp ne i32 1, 0
  br i1 %t7, label %wbody1, label %wend2
wbody1:
  call void @fn_skipnl()
  %t8 = call i32 @fn_is_op(ptr @.str88)
  %t9 = icmp ne i32 %t8, 0
  br i1 %t9, label %then3, label %ifend5
then3:
  br label %wend2
ifend5:
  %t10 = call ptr @fn_node(i32 1)
  store ptr %t10, ptr %t11
  %t12 = load ptr, ptr %t11
  %t13 = getelementptr inbounds %Str_Node, ptr %t12, i32 0, i32 1
  %t14 = call ptr @fn_eat_id()
  store ptr %t14, ptr %t13
  call void @fn_eat_op(ptr @.str89)
  %t15 = load ptr, ptr %t11
  %t16 = getelementptr inbounds %Str_Node, ptr %t15, i32 0, i32 3
  %t17 = call ptr @fn_ptype()
  store ptr %t17, ptr %t16
  %t18 = call i32 @fn_is_op(ptr @.str90)
  %t19 = icmp ne i32 %t18, 0
  br i1 %t19, label %then6, label %ifend8
then6:
  %t20 = load i32, ptr @g_pi
  %t21 = add i32 %t20, 1
  store i32 %t21, ptr @g_pi
  %t22 = load ptr, ptr %t11
  %t23 = getelementptr inbounds %Str_Node, ptr %t22, i32 0, i32 4
  %t24 = call ptr @fn_expr()
  store ptr %t24, ptr %t23
  br label %ifend8
ifend8:
  %t25 = load ptr, ptr %t3
  %t26 = getelementptr inbounds %Str_Node, ptr %t25, i32 0, i32 7
  %t27 = load ptr, ptr %t26
  %t28 = getelementptr inbounds %LSlice, ptr %t27, i32 0, i32 1
  %t29 = getelementptr inbounds %LSlice, ptr %t27, i32 0, i32 2
  %t30 = getelementptr inbounds %LSlice, ptr %t27, i32 0, i32 0
  %t31 = load i32, ptr %t28
  %t32 = load i32, ptr %t29
  %t33 = icmp sge i32 %t31, %t32
  br i1 %t33, label %grow9, label %put10
grow9:
  %t34 = mul i32 %t32, 2
  %t35 = icmp eq i32 %t32, 0
  %t36 = select i1 %t35, i32 8, i32 %t34
  %t37 = getelementptr ptr, ptr null, i32 1
  %t38 = ptrtoint ptr %t37 to i64
  %t39 = zext i32 %t36 to i64
  %t40 = mul i64 %t39, %t38
  %t41 = load ptr, ptr %t30
  %t42 = call ptr @realloc(ptr %t41, i64 %t40)
  store ptr %t42, ptr %t30
  store i32 %t36, ptr %t29
  br label %put10
put10:
  %t43 = load ptr, ptr %t11
  %t44 = load ptr, ptr %t30
  %t45 = getelementptr inbounds ptr, ptr %t44, i32 %t31
  store ptr %t43, ptr %t45
  %t46 = add i32 %t31, 1
  store i32 %t46, ptr %t28
  %t47 = call i32 @fn_is_op(ptr @.str91)
  %t48 = icmp ne i32 %t47, 0
  br i1 %t48, label %then11, label %ifend13
then11:
  %t49 = load i32, ptr @g_pi
  %t50 = add i32 %t49, 1
  store i32 %t50, ptr @g_pi
  br label %ifend13
ifend13:
  br label %wcond0
wend2:
  call void @fn_eat_op(ptr @.str92)
  %t51 = load ptr, ptr %t3
  store ptr %t51, ptr %retval
  br label %ret
ret:
  %t52 = load ptr, ptr %retval
  ret ptr %t52
}

define ptr @fn_parse_var() {
entry:
  %retval = alloca ptr
  %t3 = alloca ptr
  %t0 = load i32, ptr @g_pi
  %t1 = add i32 %t0, 1
  store i32 %t1, ptr @g_pi
  %t2 = call ptr @fn_node(i32 2)
  store ptr %t2, ptr %t3
  %t4 = load ptr, ptr %t3
  %t5 = getelementptr inbounds %Str_Node, ptr %t4, i32 0, i32 1
  %t6 = call ptr @fn_eat_id()
  store ptr %t6, ptr %t5
  call void @fn_eat_op(ptr @.str93)
  %t7 = load ptr, ptr %t3
  %t8 = getelementptr inbounds %Str_Node, ptr %t7, i32 0, i32 3
  %t9 = call ptr @fn_ptype()
  store ptr %t9, ptr %t8
  %t10 = call i32 @fn_is_op(ptr @.str94)
  %t11 = icmp ne i32 %t10, 0
  br i1 %t11, label %then0, label %ifend2
then0:
  %t12 = load i32, ptr @g_pi
  %t13 = add i32 %t12, 1
  store i32 %t13, ptr @g_pi
  %t14 = load ptr, ptr %t3
  %t15 = getelementptr inbounds %Str_Node, ptr %t14, i32 0, i32 4
  %t16 = call ptr @fn_expr()
  store ptr %t16, ptr %t15
  br label %ifend2
ifend2:
  %t17 = load ptr, ptr %t3
  store ptr %t17, ptr %retval
  br label %ret
ret:
  %t18 = load ptr, ptr %retval
  ret ptr %t18
}

define ptr @fn_parse_const() {
entry:
  %retval = alloca ptr
  %t3 = alloca ptr
  %t0 = load i32, ptr @g_pi
  %t1 = add i32 %t0, 1
  store i32 %t1, ptr @g_pi
  %t2 = call ptr @fn_node(i32 3)
  store ptr %t2, ptr %t3
  %t4 = load ptr, ptr %t3
  %t5 = getelementptr inbounds %Str_Node, ptr %t4, i32 0, i32 1
  %t6 = call ptr @fn_eat_id()
  store ptr %t6, ptr %t5
  call void @fn_eat_op(ptr @.str95)
  %t7 = load ptr, ptr %t3
  %t8 = getelementptr inbounds %Str_Node, ptr %t7, i32 0, i32 3
  %t9 = call ptr @fn_ptype()
  store ptr %t9, ptr %t8
  call void @fn_eat_op(ptr @.str96)
  %t10 = load ptr, ptr %t3
  %t11 = getelementptr inbounds %Str_Node, ptr %t10, i32 0, i32 4
  %t12 = call ptr @fn_expr()
  store ptr %t12, ptr %t11
  %t13 = load ptr, ptr %t3
  store ptr %t13, ptr %retval
  br label %ret
ret:
  %t14 = load ptr, ptr %retval
  ret ptr %t14
}

define ptr @fn_parse_fn() {
entry:
  %retval = alloca ptr
  %t3 = alloca ptr
  %t12 = alloca ptr
  %t0 = load i32, ptr @g_pi
  %t1 = add i32 %t0, 1
  store i32 %t1, ptr @g_pi
  %t2 = call ptr @fn_node(i32 4)
  store ptr %t2, ptr %t3
  %t4 = load ptr, ptr %t3
  %t5 = getelementptr inbounds %Str_Node, ptr %t4, i32 0, i32 1
  %t6 = call ptr @fn_eat_id()
  store ptr %t6, ptr %t5
  call void @fn_eat_op(ptr @.str97)
  br label %wcond0
wcond0:
  %t7 = call i32 @fn_is_op(ptr @.str98)
  %t8 = icmp eq i32 %t7, 0
  %t9 = zext i1 %t8 to i32
  %t10 = icmp ne i32 %t9, 0
  br i1 %t10, label %wbody1, label %wend2
wbody1:
  %t11 = call ptr @fn_node(i32 5)
  store ptr %t11, ptr %t12
  %t13 = load ptr, ptr %t12
  %t14 = getelementptr inbounds %Str_Node, ptr %t13, i32 0, i32 1
  %t15 = call ptr @fn_eat_id()
  store ptr %t15, ptr %t14
  call void @fn_eat_op(ptr @.str99)
  %t16 = load ptr, ptr %t12
  %t17 = getelementptr inbounds %Str_Node, ptr %t16, i32 0, i32 3
  %t18 = call ptr @fn_ptype()
  store ptr %t18, ptr %t17
  %t19 = load ptr, ptr %t3
  %t20 = getelementptr inbounds %Str_Node, ptr %t19, i32 0, i32 7
  %t21 = load ptr, ptr %t20
  %t22 = getelementptr inbounds %LSlice, ptr %t21, i32 0, i32 1
  %t23 = getelementptr inbounds %LSlice, ptr %t21, i32 0, i32 2
  %t24 = getelementptr inbounds %LSlice, ptr %t21, i32 0, i32 0
  %t25 = load i32, ptr %t22
  %t26 = load i32, ptr %t23
  %t27 = icmp sge i32 %t25, %t26
  br i1 %t27, label %grow3, label %put4
grow3:
  %t28 = mul i32 %t26, 2
  %t29 = icmp eq i32 %t26, 0
  %t30 = select i1 %t29, i32 8, i32 %t28
  %t31 = getelementptr ptr, ptr null, i32 1
  %t32 = ptrtoint ptr %t31 to i64
  %t33 = zext i32 %t30 to i64
  %t34 = mul i64 %t33, %t32
  %t35 = load ptr, ptr %t24
  %t36 = call ptr @realloc(ptr %t35, i64 %t34)
  store ptr %t36, ptr %t24
  store i32 %t30, ptr %t23
  br label %put4
put4:
  %t37 = load ptr, ptr %t12
  %t38 = load ptr, ptr %t24
  %t39 = getelementptr inbounds ptr, ptr %t38, i32 %t25
  store ptr %t37, ptr %t39
  %t40 = add i32 %t25, 1
  store i32 %t40, ptr %t22
  %t41 = call i32 @fn_is_op(ptr @.str100)
  %t42 = icmp ne i32 %t41, 0
  br i1 %t42, label %then5, label %ifend7
then5:
  %t43 = load i32, ptr @g_pi
  %t44 = add i32 %t43, 1
  store i32 %t44, ptr @g_pi
  br label %ifend7
ifend7:
  br label %wcond0
wend2:
  call void @fn_eat_op(ptr @.str101)
  %t45 = load ptr, ptr %t3
  %t46 = getelementptr inbounds %Str_Node, ptr %t45, i32 0, i32 3
  store ptr @.str102, ptr %t46
  %t47 = call i32 @fn_is_op(ptr @.str103)
  %t48 = icmp ne i32 %t47, 0
  br i1 %t48, label %then8, label %ifend10
then8:
  %t49 = load i32, ptr @g_pi
  %t50 = add i32 %t49, 1
  store i32 %t50, ptr @g_pi
  %t51 = load ptr, ptr %t3
  %t52 = getelementptr inbounds %Str_Node, ptr %t51, i32 0, i32 3
  %t53 = call ptr @fn_ptype()
  store ptr %t53, ptr %t52
  br label %ifend10
ifend10:
  %t54 = load ptr, ptr %t3
  %t55 = getelementptr inbounds %Str_Node, ptr %t54, i32 0, i32 4
  %t56 = call ptr @fn_block()
  store ptr %t56, ptr %t55
  %t57 = load ptr, ptr %t3
  store ptr %t57, ptr %retval
  br label %ret
ret:
  %t58 = load ptr, ptr %retval
  ret ptr %t58
}

define ptr @fn_parse_main() {
entry:
  %retval = alloca ptr
  %t3 = alloca ptr
  %t0 = load i32, ptr @g_pi
  %t1 = add i32 %t0, 1
  store i32 %t1, ptr @g_pi
  %t2 = call ptr @fn_node(i32 6)
  store ptr %t2, ptr %t3
  %t4 = load ptr, ptr %t3
  %t5 = getelementptr inbounds %Str_Node, ptr %t4, i32 0, i32 4
  %t6 = call ptr @fn_block()
  store ptr %t6, ptr %t5
  %t7 = load ptr, ptr %t3
  store ptr %t7, ptr %retval
  br label %ret
ret:
  %t8 = load ptr, ptr %retval
  ret ptr %t8
}

define ptr @fn_dir_of(ptr %arg_path) {
entry:
  %retval = alloca ptr
  %t0 = alloca ptr
  %t2 = alloca i32
  %t3 = alloca i32
  store ptr %arg_path, ptr %t0
  %t1 = sub i32 0, 1
  store i32 %t1, ptr %t2
  store i32 0, ptr %t3
  br label %wcond0
wcond0:
  %t4 = load ptr, ptr %t0
  %t5 = load i32, ptr %t3
  %t6 = getelementptr inbounds i8, ptr %t4, i32 %t5
  %t7 = load i8, ptr %t6
  %t8 = zext i8 %t7 to i32
  %t9 = icmp ne i32 %t8, 0
  %t10 = zext i1 %t9 to i32
  %t11 = icmp ne i32 %t10, 0
  br i1 %t11, label %wbody1, label %wend2
wbody1:
  %t12 = load ptr, ptr %t0
  %t13 = load i32, ptr %t3
  %t14 = getelementptr inbounds i8, ptr %t12, i32 %t13
  %t15 = load i8, ptr %t14
  %t16 = zext i8 %t15 to i32
  %t17 = icmp eq i32 %t16, 47
  %t18 = zext i1 %t17 to i32
  %t19 = icmp ne i32 %t18, 0
  br i1 %t19, label %then3, label %ifend5
then3:
  %t20 = load i32, ptr %t3
  store i32 %t20, ptr %t2
  br label %ifend5
ifend5:
  %t21 = load i32, ptr %t3
  %t22 = add i32 %t21, 1
  store i32 %t22, ptr %t3
  br label %wcond0
wend2:
  %t23 = load i32, ptr %t2
  %t24 = icmp slt i32 %t23, 0
  %t25 = zext i1 %t24 to i32
  %t26 = icmp ne i32 %t25, 0
  br i1 %t26, label %then6, label %ifend8
then6:
  store ptr @.str104, ptr %retval
  br label %ret
ifend8:
  %t27 = load ptr, ptr %t0
  %t28 = load i32, ptr %t2
  %t29 = add i32 %t28, 1
  %t30 = call ptr @fn_substr(ptr %t27, i32 0, i32 %t29)
  store ptr %t30, ptr %retval
  br label %ret
ret:
  %t31 = load ptr, ptr %retval
  ret ptr %t31
}

define ptr @fn_path_join(ptr %arg_dir, ptr %arg_rel) {
entry:
  %retval = alloca ptr
  %t0 = alloca ptr
  %t1 = alloca ptr
  store ptr %arg_dir, ptr %t0
  store ptr %arg_rel, ptr %t1
  %t2 = load ptr, ptr %t1
  %t3 = getelementptr inbounds i8, ptr %t2, i32 0
  %t4 = load i8, ptr %t3
  %t5 = zext i8 %t4 to i32
  %t6 = icmp eq i32 %t5, 47
  %t7 = zext i1 %t6 to i32
  %t8 = icmp ne i32 %t7, 0
  br i1 %t8, label %then0, label %ifend2
then0:
  %t9 = load ptr, ptr %t1
  store ptr %t9, ptr %retval
  br label %ret
ifend2:
  %t10 = load ptr, ptr %t0
  %t11 = load ptr, ptr %t1
  %t12 = call ptr @fn_sconcat(ptr %t10, ptr %t11)
  store ptr %t12, ptr %retval
  br label %ret
ret:
  %t13 = load ptr, ptr %retval
  ret ptr %t13
}

define i32 @fn_already_loaded(ptr %arg_full) {
entry:
  %retval = alloca i32
  %t0 = alloca ptr
  %t1 = alloca i32
  store ptr %arg_full, ptr %t0
  store i32 0, ptr %t1
  br label %wcond0
wcond0:
  %t2 = load i32, ptr %t1
  %t3 = load ptr, ptr @g_loaded_paths
  %t4 = getelementptr inbounds %LSlice, ptr %t3, i32 0, i32 1
  %t5 = load i32, ptr %t4
  %t6 = icmp slt i32 %t2, %t5
  %t7 = zext i1 %t6 to i32
  %t8 = icmp ne i32 %t7, 0
  br i1 %t8, label %wbody1, label %wend2
wbody1:
  %t9 = load ptr, ptr @g_loaded_paths
  %t10 = getelementptr inbounds %LSlice, ptr %t9, i32 0, i32 0
  %t11 = load ptr, ptr %t10
  %t12 = load i32, ptr %t1
  %t13 = getelementptr inbounds ptr, ptr %t11, i32 %t12
  %t14 = load ptr, ptr %t13
  %t15 = load ptr, ptr %t0
  %t16 = call i32 @fn_streq(ptr %t14, ptr %t15)
  %t17 = icmp ne i32 %t16, 0
  br i1 %t17, label %then3, label %ifend5
then3:
  store i32 1, ptr %retval
  br label %ret
ifend5:
  %t18 = load i32, ptr %t1
  %t19 = add i32 %t18, 1
  store i32 %t19, ptr %t1
  br label %wcond0
wend2:
  store i32 0, ptr %retval
  br label %ret
ret:
  %t20 = load i32, ptr %retval
  ret i32 %t20
}

define void @fn_parse_one_decl() {
entry:
  %t0 = alloca i32
  %t6 = alloca ptr
  %t12 = alloca i32
  %t38 = alloca ptr
  %t48 = alloca ptr
  %t231 = alloca ptr
  store i32 0, ptr %t0
  br label %wcond0
wcond0:
  %t1 = call i32 @fn_is_op(ptr @.str105)
  %t2 = icmp ne i32 %t1, 0
  br i1 %t2, label %wbody1, label %wend2
wbody1:
  %t3 = load i32, ptr @g_pi
  %t4 = add i32 %t3, 1
  store i32 %t4, ptr @g_pi
  %t5 = call ptr @fn_eat_id()
  store ptr %t5, ptr %t6
  %t7 = load ptr, ptr %t6
  %t8 = call i32 @fn_streq(ptr %t7, ptr @.str106)
  %t9 = icmp ne i32 %t8, 0
  br i1 %t9, label %then3, label %ifend5
then3:
  store i32 1, ptr %t0
  br label %ifend5
ifend5:
  %t10 = call i32 @fn_is_op(ptr @.str107)
  %t11 = icmp ne i32 %t10, 0
  br i1 %t11, label %then6, label %ifend8
then6:
  store i32 0, ptr %t12
  br label %wcond9
wcond9:
  %t13 = icmp ne i32 1, 0
  br i1 %t13, label %wbody10, label %wend11
wbody10:
  %t14 = call i32 @fn_is_op(ptr @.str108)
  %t15 = icmp ne i32 %t14, 0
  br i1 %t15, label %then12, label %ifend14
then12:
  %t16 = load i32, ptr %t12
  %t17 = add i32 %t16, 1
  store i32 %t17, ptr %t12
  br label %ifend14
ifend14:
  %t18 = call i32 @fn_is_op(ptr @.str109)
  %t19 = icmp ne i32 %t18, 0
  br i1 %t19, label %then15, label %ifend17
then15:
  %t20 = load i32, ptr %t12
  %t21 = sub i32 %t20, 1
  store i32 %t21, ptr %t12
  br label %ifend17
ifend17:
  %t22 = load i32, ptr @g_pi
  %t23 = add i32 %t22, 1
  store i32 %t23, ptr @g_pi
  %t24 = load i32, ptr %t12
  %t25 = icmp eq i32 %t24, 0
  %t26 = zext i1 %t25 to i32
  %t27 = icmp ne i32 %t26, 0
  br i1 %t27, label %then18, label %ifend20
then18:
  br label %wend11
ifend20:
  br label %wcond9
wend11:
  br label %ifend8
ifend8:
  call void @fn_skipnl()
  br label %wcond0
wend2:
  %t28 = call i32 @fn_is_id(ptr @.str110)
  %t29 = icmp ne i32 %t28, 0
  br i1 %t29, label %then21, label %ifend23
then21:
  %t30 = load i32, ptr @g_pi
  %t31 = add i32 %t30, 1
  store i32 %t31, ptr @g_pi
  %t32 = load ptr, ptr @g_toks
  %t33 = getelementptr inbounds %LSlice, ptr %t32, i32 0, i32 0
  %t34 = load ptr, ptr %t33
  %t35 = load i32, ptr @g_pi
  %t36 = getelementptr inbounds ptr, ptr %t34, i32 %t35
  %t37 = load ptr, ptr %t36
  store ptr %t37, ptr %t38
  %t39 = load ptr, ptr %t38
  %t40 = getelementptr inbounds %Str_Tok, ptr %t39, i32 0, i32 0
  %t41 = load i32, ptr %t40
  %t42 = icmp ne i32 %t41, 2
  %t43 = zext i1 %t42 to i32
  %t44 = icmp ne i32 %t43, 0
  br i1 %t44, label %then24, label %ifend26
then24:
  call void @fn_perr(ptr @.str111)
  br label %ifend26
ifend26:
  %t45 = load ptr, ptr %t38
  %t46 = getelementptr inbounds %Str_Tok, ptr %t45, i32 0, i32 1
  %t47 = load ptr, ptr %t46
  store ptr %t47, ptr %t48
  %t49 = load i32, ptr @g_pi
  %t50 = add i32 %t49, 1
  store i32 %t50, ptr @g_pi
  %t51 = load ptr, ptr %t48
  call void @fn_do_import(ptr %t51)
  br label %ret
ifend23:
  %t52 = call i32 @fn_is_id(ptr @.str112)
  %t53 = icmp ne i32 %t52, 0
  br i1 %t53, label %then27, label %ifend29
then27:
  %t54 = load ptr, ptr @g_prog
  %t55 = getelementptr inbounds %LSlice, ptr %t54, i32 0, i32 1
  %t56 = getelementptr inbounds %LSlice, ptr %t54, i32 0, i32 2
  %t57 = getelementptr inbounds %LSlice, ptr %t54, i32 0, i32 0
  %t58 = load i32, ptr %t55
  %t59 = load i32, ptr %t56
  %t60 = icmp sge i32 %t58, %t59
  br i1 %t60, label %grow30, label %put31
grow30:
  %t61 = mul i32 %t59, 2
  %t62 = icmp eq i32 %t59, 0
  %t63 = select i1 %t62, i32 8, i32 %t61
  %t64 = getelementptr ptr, ptr null, i32 1
  %t65 = ptrtoint ptr %t64 to i64
  %t66 = zext i32 %t63 to i64
  %t67 = mul i64 %t66, %t65
  %t68 = load ptr, ptr %t57
  %t69 = call ptr @realloc(ptr %t68, i64 %t67)
  store ptr %t69, ptr %t57
  store i32 %t63, ptr %t56
  br label %put31
put31:
  %t70 = call ptr @fn_parse_struct()
  %t71 = load ptr, ptr %t57
  %t72 = getelementptr inbounds ptr, ptr %t71, i32 %t58
  store ptr %t70, ptr %t72
  %t73 = add i32 %t58, 1
  store i32 %t73, ptr %t55
  br label %ret
ifend29:
  %t74 = call i32 @fn_is_id(ptr @.str113)
  %t75 = icmp ne i32 %t74, 0
  br i1 %t75, label %then32, label %ifend34
then32:
  %t76 = load ptr, ptr @g_prog
  %t77 = getelementptr inbounds %LSlice, ptr %t76, i32 0, i32 1
  %t78 = getelementptr inbounds %LSlice, ptr %t76, i32 0, i32 2
  %t79 = getelementptr inbounds %LSlice, ptr %t76, i32 0, i32 0
  %t80 = load i32, ptr %t77
  %t81 = load i32, ptr %t78
  %t82 = icmp sge i32 %t80, %t81
  br i1 %t82, label %grow35, label %put36
grow35:
  %t83 = mul i32 %t81, 2
  %t84 = icmp eq i32 %t81, 0
  %t85 = select i1 %t84, i32 8, i32 %t83
  %t86 = getelementptr ptr, ptr null, i32 1
  %t87 = ptrtoint ptr %t86 to i64
  %t88 = zext i32 %t85 to i64
  %t89 = mul i64 %t88, %t87
  %t90 = load ptr, ptr %t79
  %t91 = call ptr @realloc(ptr %t90, i64 %t89)
  store ptr %t91, ptr %t79
  store i32 %t85, ptr %t78
  br label %put36
put36:
  %t92 = call ptr @fn_parse_enum()
  %t93 = load ptr, ptr %t79
  %t94 = getelementptr inbounds ptr, ptr %t93, i32 %t80
  store ptr %t92, ptr %t94
  %t95 = add i32 %t80, 1
  store i32 %t95, ptr %t77
  br label %ret
ifend34:
  %t96 = call i32 @fn_is_id(ptr @.str114)
  %t97 = icmp ne i32 %t96, 0
  br i1 %t97, label %then37, label %ifend39
then37:
  %t98 = load ptr, ptr @g_prog
  %t99 = getelementptr inbounds %LSlice, ptr %t98, i32 0, i32 1
  %t100 = getelementptr inbounds %LSlice, ptr %t98, i32 0, i32 2
  %t101 = getelementptr inbounds %LSlice, ptr %t98, i32 0, i32 0
  %t102 = load i32, ptr %t99
  %t103 = load i32, ptr %t100
  %t104 = icmp sge i32 %t102, %t103
  br i1 %t104, label %grow40, label %put41
grow40:
  %t105 = mul i32 %t103, 2
  %t106 = icmp eq i32 %t103, 0
  %t107 = select i1 %t106, i32 8, i32 %t105
  %t108 = getelementptr ptr, ptr null, i32 1
  %t109 = ptrtoint ptr %t108 to i64
  %t110 = zext i32 %t107 to i64
  %t111 = mul i64 %t110, %t109
  %t112 = load ptr, ptr %t101
  %t113 = call ptr @realloc(ptr %t112, i64 %t111)
  store ptr %t113, ptr %t101
  store i32 %t107, ptr %t100
  br label %put41
put41:
  %t114 = call ptr @fn_parse_component()
  %t115 = load ptr, ptr %t101
  %t116 = getelementptr inbounds ptr, ptr %t115, i32 %t102
  store ptr %t114, ptr %t116
  %t117 = add i32 %t102, 1
  store i32 %t117, ptr %t99
  br label %ret
ifend39:
  %t118 = call i32 @fn_is_id(ptr @.str115)
  %t119 = icmp ne i32 %t118, 0
  br i1 %t119, label %then42, label %ifend44
then42:
  %t120 = load ptr, ptr @g_prog
  %t121 = getelementptr inbounds %LSlice, ptr %t120, i32 0, i32 1
  %t122 = getelementptr inbounds %LSlice, ptr %t120, i32 0, i32 2
  %t123 = getelementptr inbounds %LSlice, ptr %t120, i32 0, i32 0
  %t124 = load i32, ptr %t121
  %t125 = load i32, ptr %t122
  %t126 = icmp sge i32 %t124, %t125
  br i1 %t126, label %grow45, label %put46
grow45:
  %t127 = mul i32 %t125, 2
  %t128 = icmp eq i32 %t125, 0
  %t129 = select i1 %t128, i32 8, i32 %t127
  %t130 = getelementptr ptr, ptr null, i32 1
  %t131 = ptrtoint ptr %t130 to i64
  %t132 = zext i32 %t129 to i64
  %t133 = mul i64 %t132, %t131
  %t134 = load ptr, ptr %t123
  %t135 = call ptr @realloc(ptr %t134, i64 %t133)
  store ptr %t135, ptr %t123
  store i32 %t129, ptr %t122
  br label %put46
put46:
  %t136 = call ptr @fn_parse_archetype()
  %t137 = load ptr, ptr %t123
  %t138 = getelementptr inbounds ptr, ptr %t137, i32 %t124
  store ptr %t136, ptr %t138
  %t139 = add i32 %t124, 1
  store i32 %t139, ptr %t121
  br label %ret
ifend44:
  %t140 = call i32 @fn_is_id(ptr @.str116)
  %t141 = icmp ne i32 %t140, 0
  br i1 %t141, label %then47, label %ifend49
then47:
  %t142 = load ptr, ptr @g_prog
  %t143 = getelementptr inbounds %LSlice, ptr %t142, i32 0, i32 1
  %t144 = getelementptr inbounds %LSlice, ptr %t142, i32 0, i32 2
  %t145 = getelementptr inbounds %LSlice, ptr %t142, i32 0, i32 0
  %t146 = load i32, ptr %t143
  %t147 = load i32, ptr %t144
  %t148 = icmp sge i32 %t146, %t147
  br i1 %t148, label %grow50, label %put51
grow50:
  %t149 = mul i32 %t147, 2
  %t150 = icmp eq i32 %t147, 0
  %t151 = select i1 %t150, i32 8, i32 %t149
  %t152 = getelementptr ptr, ptr null, i32 1
  %t153 = ptrtoint ptr %t152 to i64
  %t154 = zext i32 %t151 to i64
  %t155 = mul i64 %t154, %t153
  %t156 = load ptr, ptr %t145
  %t157 = call ptr @realloc(ptr %t156, i64 %t155)
  store ptr %t157, ptr %t145
  store i32 %t151, ptr %t144
  br label %put51
put51:
  %t158 = call ptr @fn_parse_system()
  %t159 = load ptr, ptr %t145
  %t160 = getelementptr inbounds ptr, ptr %t159, i32 %t146
  store ptr %t158, ptr %t160
  %t161 = add i32 %t146, 1
  store i32 %t161, ptr %t143
  br label %ret
ifend49:
  %t162 = call i32 @fn_is_id(ptr @.str117)
  %t163 = icmp ne i32 %t162, 0
  br i1 %t163, label %then52, label %ifend54
then52:
  %t164 = load ptr, ptr @g_prog
  %t165 = getelementptr inbounds %LSlice, ptr %t164, i32 0, i32 1
  %t166 = getelementptr inbounds %LSlice, ptr %t164, i32 0, i32 2
  %t167 = getelementptr inbounds %LSlice, ptr %t164, i32 0, i32 0
  %t168 = load i32, ptr %t165
  %t169 = load i32, ptr %t166
  %t170 = icmp sge i32 %t168, %t169
  br i1 %t170, label %grow55, label %put56
grow55:
  %t171 = mul i32 %t169, 2
  %t172 = icmp eq i32 %t169, 0
  %t173 = select i1 %t172, i32 8, i32 %t171
  %t174 = getelementptr ptr, ptr null, i32 1
  %t175 = ptrtoint ptr %t174 to i64
  %t176 = zext i32 %t173 to i64
  %t177 = mul i64 %t176, %t175
  %t178 = load ptr, ptr %t167
  %t179 = call ptr @realloc(ptr %t178, i64 %t177)
  store ptr %t179, ptr %t167
  store i32 %t173, ptr %t166
  br label %put56
put56:
  %t180 = call ptr @fn_parse_ui()
  %t181 = load ptr, ptr %t167
  %t182 = getelementptr inbounds ptr, ptr %t181, i32 %t168
  store ptr %t180, ptr %t182
  %t183 = add i32 %t168, 1
  store i32 %t183, ptr %t165
  br label %ret
ifend54:
  %t184 = call i32 @fn_is_id(ptr @.str118)
  %t185 = icmp ne i32 %t184, 0
  br i1 %t185, label %then57, label %ifend59
then57:
  %t186 = load ptr, ptr @g_prog
  %t187 = getelementptr inbounds %LSlice, ptr %t186, i32 0, i32 1
  %t188 = getelementptr inbounds %LSlice, ptr %t186, i32 0, i32 2
  %t189 = getelementptr inbounds %LSlice, ptr %t186, i32 0, i32 0
  %t190 = load i32, ptr %t187
  %t191 = load i32, ptr %t188
  %t192 = icmp sge i32 %t190, %t191
  br i1 %t192, label %grow60, label %put61
grow60:
  %t193 = mul i32 %t191, 2
  %t194 = icmp eq i32 %t191, 0
  %t195 = select i1 %t194, i32 8, i32 %t193
  %t196 = getelementptr ptr, ptr null, i32 1
  %t197 = ptrtoint ptr %t196 to i64
  %t198 = zext i32 %t195 to i64
  %t199 = mul i64 %t198, %t197
  %t200 = load ptr, ptr %t189
  %t201 = call ptr @realloc(ptr %t200, i64 %t199)
  store ptr %t201, ptr %t189
  store i32 %t195, ptr %t188
  br label %put61
put61:
  %t202 = call ptr @fn_parse_var()
  %t203 = load ptr, ptr %t189
  %t204 = getelementptr inbounds ptr, ptr %t203, i32 %t190
  store ptr %t202, ptr %t204
  %t205 = add i32 %t190, 1
  store i32 %t205, ptr %t187
  br label %ret
ifend59:
  %t206 = call i32 @fn_is_id(ptr @.str119)
  %t207 = icmp ne i32 %t206, 0
  br i1 %t207, label %then62, label %ifend64
then62:
  %t208 = load ptr, ptr @g_prog
  %t209 = getelementptr inbounds %LSlice, ptr %t208, i32 0, i32 1
  %t210 = getelementptr inbounds %LSlice, ptr %t208, i32 0, i32 2
  %t211 = getelementptr inbounds %LSlice, ptr %t208, i32 0, i32 0
  %t212 = load i32, ptr %t209
  %t213 = load i32, ptr %t210
  %t214 = icmp sge i32 %t212, %t213
  br i1 %t214, label %grow65, label %put66
grow65:
  %t215 = mul i32 %t213, 2
  %t216 = icmp eq i32 %t213, 0
  %t217 = select i1 %t216, i32 8, i32 %t215
  %t218 = getelementptr ptr, ptr null, i32 1
  %t219 = ptrtoint ptr %t218 to i64
  %t220 = zext i32 %t217 to i64
  %t221 = mul i64 %t220, %t219
  %t222 = load ptr, ptr %t211
  %t223 = call ptr @realloc(ptr %t222, i64 %t221)
  store ptr %t223, ptr %t211
  store i32 %t217, ptr %t210
  br label %put66
put66:
  %t224 = call ptr @fn_parse_const()
  %t225 = load ptr, ptr %t211
  %t226 = getelementptr inbounds ptr, ptr %t225, i32 %t212
  store ptr %t224, ptr %t226
  %t227 = add i32 %t212, 1
  store i32 %t227, ptr %t209
  br label %ret
ifend64:
  %t228 = call i32 @fn_is_id(ptr @.str120)
  %t229 = icmp ne i32 %t228, 0
  br i1 %t229, label %then67, label %ifend69
then67:
  %t230 = call ptr @fn_parse_fn()
  store ptr %t230, ptr %t231
  %t232 = load i32, ptr %t0
  %t233 = icmp ne i32 %t232, 0
  br i1 %t233, label %then70, label %ifend72
then70:
  %t234 = load ptr, ptr %t231
  %t235 = getelementptr inbounds %Str_Node, ptr %t234, i32 0, i32 2
  store i32 1, ptr %t235
  br label %ifend72
ifend72:
  %t236 = load ptr, ptr @g_prog
  %t237 = getelementptr inbounds %LSlice, ptr %t236, i32 0, i32 1
  %t238 = getelementptr inbounds %LSlice, ptr %t236, i32 0, i32 2
  %t239 = getelementptr inbounds %LSlice, ptr %t236, i32 0, i32 0
  %t240 = load i32, ptr %t237
  %t241 = load i32, ptr %t238
  %t242 = icmp sge i32 %t240, %t241
  br i1 %t242, label %grow73, label %put74
grow73:
  %t243 = mul i32 %t241, 2
  %t244 = icmp eq i32 %t241, 0
  %t245 = select i1 %t244, i32 8, i32 %t243
  %t246 = getelementptr ptr, ptr null, i32 1
  %t247 = ptrtoint ptr %t246 to i64
  %t248 = zext i32 %t245 to i64
  %t249 = mul i64 %t248, %t247
  %t250 = load ptr, ptr %t239
  %t251 = call ptr @realloc(ptr %t250, i64 %t249)
  store ptr %t251, ptr %t239
  store i32 %t245, ptr %t238
  br label %put74
put74:
  %t252 = load ptr, ptr %t231
  %t253 = load ptr, ptr %t239
  %t254 = getelementptr inbounds ptr, ptr %t253, i32 %t240
  store ptr %t252, ptr %t254
  %t255 = add i32 %t240, 1
  store i32 %t255, ptr %t237
  br label %ret
ifend69:
  %t256 = call i32 @fn_is_id(ptr @.str121)
  %t257 = icmp ne i32 %t256, 0
  br i1 %t257, label %then75, label %ifend77
then75:
  %t258 = load ptr, ptr @g_prog
  %t259 = getelementptr inbounds %LSlice, ptr %t258, i32 0, i32 1
  %t260 = getelementptr inbounds %LSlice, ptr %t258, i32 0, i32 2
  %t261 = getelementptr inbounds %LSlice, ptr %t258, i32 0, i32 0
  %t262 = load i32, ptr %t259
  %t263 = load i32, ptr %t260
  %t264 = icmp sge i32 %t262, %t263
  br i1 %t264, label %grow78, label %put79
grow78:
  %t265 = mul i32 %t263, 2
  %t266 = icmp eq i32 %t263, 0
  %t267 = select i1 %t266, i32 8, i32 %t265
  %t268 = getelementptr ptr, ptr null, i32 1
  %t269 = ptrtoint ptr %t268 to i64
  %t270 = zext i32 %t267 to i64
  %t271 = mul i64 %t270, %t269
  %t272 = load ptr, ptr %t261
  %t273 = call ptr @realloc(ptr %t272, i64 %t271)
  store ptr %t273, ptr %t261
  store i32 %t267, ptr %t260
  br label %put79
put79:
  %t274 = call ptr @fn_parse_extern()
  %t275 = load ptr, ptr %t261
  %t276 = getelementptr inbounds ptr, ptr %t275, i32 %t262
  store ptr %t274, ptr %t276
  %t277 = add i32 %t262, 1
  store i32 %t277, ptr %t259
  br label %ret
ifend77:
  %t278 = call i32 @fn_is_id(ptr @.str122)
  %t279 = icmp ne i32 %t278, 0
  br i1 %t279, label %then80, label %ifend82
then80:
  %t280 = load ptr, ptr @g_prog
  %t281 = getelementptr inbounds %LSlice, ptr %t280, i32 0, i32 1
  %t282 = getelementptr inbounds %LSlice, ptr %t280, i32 0, i32 2
  %t283 = getelementptr inbounds %LSlice, ptr %t280, i32 0, i32 0
  %t284 = load i32, ptr %t281
  %t285 = load i32, ptr %t282
  %t286 = icmp sge i32 %t284, %t285
  br i1 %t286, label %grow83, label %put84
grow83:
  %t287 = mul i32 %t285, 2
  %t288 = icmp eq i32 %t285, 0
  %t289 = select i1 %t288, i32 8, i32 %t287
  %t290 = getelementptr ptr, ptr null, i32 1
  %t291 = ptrtoint ptr %t290 to i64
  %t292 = zext i32 %t289 to i64
  %t293 = mul i64 %t292, %t291
  %t294 = load ptr, ptr %t283
  %t295 = call ptr @realloc(ptr %t294, i64 %t293)
  store ptr %t295, ptr %t283
  store i32 %t289, ptr %t282
  br label %put84
put84:
  %t296 = call ptr @fn_parse_main()
  %t297 = load ptr, ptr %t283
  %t298 = getelementptr inbounds ptr, ptr %t297, i32 %t284
  store ptr %t296, ptr %t298
  %t299 = add i32 %t284, 1
  store i32 %t299, ptr %t281
  br label %ret
ifend82:
  call void @fn_perr(ptr @.str123)
  br label %ret
ret:
  ret void
}

define void @fn_do_import(ptr %arg_rel) {
entry:
  %t0 = alloca ptr
  %t4 = alloca ptr
  %t30 = alloca ptr
  %t38 = alloca ptr
  %t40 = alloca i32
  %t42 = alloca ptr
  store ptr %arg_rel, ptr %t0
  %t1 = load ptr, ptr @g_cur_dir
  %t2 = load ptr, ptr %t0
  %t3 = call ptr @fn_path_join(ptr %t1, ptr %t2)
  store ptr %t3, ptr %t4
  %t5 = load ptr, ptr %t4
  %t6 = call i32 @fn_already_loaded(ptr %t5)
  %t7 = icmp ne i32 %t6, 0
  br i1 %t7, label %then0, label %ifend2
then0:
  br label %ret
ifend2:
  %t8 = load ptr, ptr @g_loaded_paths
  %t9 = getelementptr inbounds %LSlice, ptr %t8, i32 0, i32 1
  %t10 = getelementptr inbounds %LSlice, ptr %t8, i32 0, i32 2
  %t11 = getelementptr inbounds %LSlice, ptr %t8, i32 0, i32 0
  %t12 = load i32, ptr %t9
  %t13 = load i32, ptr %t10
  %t14 = icmp sge i32 %t12, %t13
  br i1 %t14, label %grow3, label %put4
grow3:
  %t15 = mul i32 %t13, 2
  %t16 = icmp eq i32 %t13, 0
  %t17 = select i1 %t16, i32 8, i32 %t15
  %t18 = getelementptr ptr, ptr null, i32 1
  %t19 = ptrtoint ptr %t18 to i64
  %t20 = zext i32 %t17 to i64
  %t21 = mul i64 %t20, %t19
  %t22 = load ptr, ptr %t11
  %t23 = call ptr @realloc(ptr %t22, i64 %t21)
  store ptr %t23, ptr %t11
  store i32 %t17, ptr %t10
  br label %put4
put4:
  %t24 = load ptr, ptr %t4
  %t25 = load ptr, ptr %t11
  %t26 = getelementptr inbounds ptr, ptr %t25, i32 %t12
  store ptr %t24, ptr %t26
  %t27 = add i32 %t12, 1
  store i32 %t27, ptr %t9
  %t28 = load ptr, ptr %t4
  %t29 = call ptr @fn_read_file(ptr %t28)
  store ptr %t29, ptr %t30
  %t31 = load ptr, ptr %t30
  %t32 = icmp eq ptr %t31, null
  %t33 = zext i1 %t32 to i32
  %t34 = icmp ne i32 %t33, 0
  br i1 %t34, label %then5, label %ifend7
then5:
  %t35 = load ptr, ptr %t4
  %t36 = call ptr @fn_sconcat(ptr @.str124, ptr %t35)
  call void @fn_perr(ptr %t36)
  br label %ifend7
ifend7:
  %t37 = load ptr, ptr @g_toks
  store ptr %t37, ptr %t38
  %t39 = load i32, ptr @g_pi
  store i32 %t39, ptr %t40
  %t41 = load ptr, ptr @g_cur_dir
  store ptr %t41, ptr %t42
  %t43 = load ptr, ptr %t4
  %t44 = call ptr @fn_dir_of(ptr %t43)
  store ptr %t44, ptr @g_cur_dir
  %t45 = load ptr, ptr %t30
  call void @fn_lex(ptr %t45)
  store i32 0, ptr @g_pi
  call void @fn_skipnl()
  br label %wcond8
wcond8:
  %t46 = load ptr, ptr @g_toks
  %t47 = getelementptr inbounds %LSlice, ptr %t46, i32 0, i32 0
  %t48 = load ptr, ptr %t47
  %t49 = load i32, ptr @g_pi
  %t50 = getelementptr inbounds ptr, ptr %t48, i32 %t49
  %t51 = load ptr, ptr %t50
  %t52 = getelementptr inbounds %Str_Tok, ptr %t51, i32 0, i32 0
  %t53 = load i32, ptr %t52
  %t54 = icmp ne i32 %t53, 5
  %t55 = zext i1 %t54 to i32
  %t56 = icmp ne i32 %t55, 0
  br i1 %t56, label %wbody9, label %wend10
wbody9:
  call void @fn_parse_one_decl()
  call void @fn_skipnl()
  br label %wcond8
wend10:
  %t57 = load ptr, ptr %t38
  store ptr %t57, ptr @g_toks
  %t58 = load i32, ptr %t40
  store i32 %t58, ptr @g_pi
  %t59 = load ptr, ptr %t42
  store ptr %t59, ptr @g_cur_dir
  br label %ret
ret:
  ret void
}

define void @fn_maybe_splice_runtime() {
entry:
  %t5 = alloca ptr
  %t0 = call i32 @fn_has_ecs()
  %t1 = icmp eq i32 %t0, 0
  %t2 = zext i1 %t1 to i32
  %t3 = icmp ne i32 %t2, 0
  br i1 %t3, label %then0, label %ifend2
then0:
  br label %ret
ifend2:
  %t4 = load ptr, ptr @g_cur_dir
  store ptr %t4, ptr %t5
  store ptr @.str125, ptr @g_cur_dir
  call void @fn_do_import(ptr @.str126)
  %t6 = load ptr, ptr %t5
  store ptr %t6, ptr @g_cur_dir
  br label %ret
ret:
  ret void
}

define void @fn_parse_program() {
entry:
  %t22 = alloca ptr
  %t26 = alloca ptr
  %t0 = getelementptr %LSlice, ptr null, i32 1
  %t1 = ptrtoint ptr %t0 to i64
  %t2 = call ptr @malloc(i64 %t1)
  %t3 = getelementptr inbounds %LSlice, ptr %t2, i32 0, i32 0
  store ptr null, ptr %t3
  %t4 = getelementptr inbounds %LSlice, ptr %t2, i32 0, i32 1
  store i32 0, ptr %t4
  %t5 = getelementptr inbounds %LSlice, ptr %t2, i32 0, i32 2
  store i32 0, ptr %t5
  store ptr %t2, ptr @g_prog
  %t6 = getelementptr %LSlice, ptr null, i32 1
  %t7 = ptrtoint ptr %t6 to i64
  %t8 = call ptr @malloc(i64 %t7)
  %t9 = getelementptr inbounds %LSlice, ptr %t8, i32 0, i32 0
  store ptr null, ptr %t9
  %t10 = getelementptr inbounds %LSlice, ptr %t8, i32 0, i32 1
  store i32 0, ptr %t10
  %t11 = getelementptr inbounds %LSlice, ptr %t8, i32 0, i32 2
  store i32 0, ptr %t11
  store ptr %t8, ptr @g_loaded_paths
  call void @fn_skipnl()
  store ptr @.str127, ptr @g_g_game_name
  br label %wcond0
wcond0:
  %t12 = call i32 @fn_is_id(ptr @.str128)
  %t13 = icmp ne i32 %t12, 0
  br i1 %t13, label %wbody1, label %wend2
wbody1:
  %t14 = load i32, ptr @g_pi
  %t15 = add i32 %t14, 1
  store i32 %t15, ptr @g_pi
  %t16 = load ptr, ptr @g_toks
  %t17 = getelementptr inbounds %LSlice, ptr %t16, i32 0, i32 0
  %t18 = load ptr, ptr %t17
  %t19 = load i32, ptr @g_pi
  %t20 = getelementptr inbounds ptr, ptr %t18, i32 %t19
  %t21 = load ptr, ptr %t20
  store ptr %t21, ptr %t22
  %t23 = load ptr, ptr %t22
  %t24 = getelementptr inbounds %Str_Tok, ptr %t23, i32 0, i32 1
  %t25 = load ptr, ptr %t24
  store ptr %t25, ptr %t26
  %t27 = load i32, ptr @g_pi
  %t28 = add i32 %t27, 1
  store i32 %t28, ptr @g_pi
  %t29 = load ptr, ptr %t26
  call void @fn_do_import(ptr %t29)
  call void @fn_skipnl()
  br label %wcond0
wend2:
  %t30 = call i32 @fn_is_id(ptr @.str129)
  %t31 = icmp ne i32 %t30, 0
  br i1 %t31, label %then3, label %ifend5
then3:
  %t32 = load i32, ptr @g_pi
  %t33 = add i32 %t32, 1
  store i32 %t33, ptr @g_pi
  %t34 = call ptr @fn_eat_id()
  store ptr %t34, ptr @g_g_game_name
  call void @fn_skipnl()
  call void @fn_eat_op(ptr @.str130)
  br label %ifend5
ifend5:
  br label %wcond6
wcond6:
  %t35 = icmp ne i32 1, 0
  br i1 %t35, label %wbody7, label %wend8
wbody7:
  call void @fn_skipnl()
  %t36 = load ptr, ptr @g_toks
  %t37 = getelementptr inbounds %LSlice, ptr %t36, i32 0, i32 0
  %t38 = load ptr, ptr %t37
  %t39 = load i32, ptr @g_pi
  %t40 = getelementptr inbounds ptr, ptr %t38, i32 %t39
  %t41 = load ptr, ptr %t40
  %t42 = getelementptr inbounds %Str_Tok, ptr %t41, i32 0, i32 0
  %t43 = load i32, ptr %t42
  %t44 = icmp eq i32 %t43, 5
  %t45 = zext i1 %t44 to i32
  %t46 = icmp ne i32 %t45, 0
  br i1 %t46, label %then9, label %ifend11
then9:
  br label %wend8
ifend11:
  %t47 = call i32 @fn_is_op(ptr @.str131)
  %t48 = icmp ne i32 %t47, 0
  br i1 %t48, label %then12, label %ifend14
then12:
  br label %wend8
ifend14:
  call void @fn_parse_one_decl()
  br label %wcond6
wend8:
  br label %ret
ret:
  ret void
}

define ptr @fn_parse_component() {
entry:
  %retval = alloca ptr
  %t3 = alloca ptr
  %t11 = alloca ptr
  %t0 = load i32, ptr @g_pi
  %t1 = add i32 %t0, 1
  store i32 %t1, ptr @g_pi
  %t2 = call ptr @fn_node(i32 8)
  store ptr %t2, ptr %t3
  %t4 = load ptr, ptr %t3
  %t5 = getelementptr inbounds %Str_Node, ptr %t4, i32 0, i32 1
  %t6 = call ptr @fn_eat_id()
  store ptr %t6, ptr %t5
  call void @fn_skipnl()
  call void @fn_eat_op(ptr @.str132)
  br label %wcond0
wcond0:
  %t7 = icmp ne i32 1, 0
  br i1 %t7, label %wbody1, label %wend2
wbody1:
  call void @fn_skipnl()
  %t8 = call i32 @fn_is_op(ptr @.str133)
  %t9 = icmp ne i32 %t8, 0
  br i1 %t9, label %then3, label %ifend5
then3:
  br label %wend2
ifend5:
  %t10 = call ptr @fn_node(i32 1)
  store ptr %t10, ptr %t11
  %t12 = load ptr, ptr %t11
  %t13 = getelementptr inbounds %Str_Node, ptr %t12, i32 0, i32 1
  %t14 = call ptr @fn_eat_id()
  store ptr %t14, ptr %t13
  call void @fn_eat_op(ptr @.str134)
  %t15 = load ptr, ptr %t11
  %t16 = getelementptr inbounds %Str_Node, ptr %t15, i32 0, i32 3
  %t17 = call ptr @fn_ptype()
  store ptr %t17, ptr %t16
  %t18 = call i32 @fn_is_op(ptr @.str135)
  %t19 = icmp ne i32 %t18, 0
  br i1 %t19, label %then6, label %ifend8
then6:
  %t20 = load i32, ptr @g_pi
  %t21 = add i32 %t20, 1
  store i32 %t21, ptr @g_pi
  %t22 = load ptr, ptr %t11
  %t23 = getelementptr inbounds %Str_Node, ptr %t22, i32 0, i32 4
  %t24 = call ptr @fn_expr()
  store ptr %t24, ptr %t23
  br label %ifend8
ifend8:
  %t25 = load ptr, ptr %t3
  %t26 = getelementptr inbounds %Str_Node, ptr %t25, i32 0, i32 7
  %t27 = load ptr, ptr %t26
  %t28 = getelementptr inbounds %LSlice, ptr %t27, i32 0, i32 1
  %t29 = getelementptr inbounds %LSlice, ptr %t27, i32 0, i32 2
  %t30 = getelementptr inbounds %LSlice, ptr %t27, i32 0, i32 0
  %t31 = load i32, ptr %t28
  %t32 = load i32, ptr %t29
  %t33 = icmp sge i32 %t31, %t32
  br i1 %t33, label %grow9, label %put10
grow9:
  %t34 = mul i32 %t32, 2
  %t35 = icmp eq i32 %t32, 0
  %t36 = select i1 %t35, i32 8, i32 %t34
  %t37 = getelementptr ptr, ptr null, i32 1
  %t38 = ptrtoint ptr %t37 to i64
  %t39 = zext i32 %t36 to i64
  %t40 = mul i64 %t39, %t38
  %t41 = load ptr, ptr %t30
  %t42 = call ptr @realloc(ptr %t41, i64 %t40)
  store ptr %t42, ptr %t30
  store i32 %t36, ptr %t29
  br label %put10
put10:
  %t43 = load ptr, ptr %t11
  %t44 = load ptr, ptr %t30
  %t45 = getelementptr inbounds ptr, ptr %t44, i32 %t31
  store ptr %t43, ptr %t45
  %t46 = add i32 %t31, 1
  store i32 %t46, ptr %t28
  %t47 = call i32 @fn_is_op(ptr @.str136)
  %t48 = icmp ne i32 %t47, 0
  br i1 %t48, label %then11, label %ifend13
then11:
  %t49 = load i32, ptr @g_pi
  %t50 = add i32 %t49, 1
  store i32 %t50, ptr @g_pi
  br label %ifend13
ifend13:
  br label %wcond0
wend2:
  call void @fn_eat_op(ptr @.str137)
  %t51 = load ptr, ptr %t3
  store ptr %t51, ptr %retval
  br label %ret
ret:
  %t52 = load ptr, ptr %retval
  ret ptr %t52
}

define void @fn_skip_clause() {
entry:
  %t2 = alloca i32
  %t0 = call i32 @fn_is_op(ptr @.str138)
  %t1 = icmp ne i32 %t0, 0
  br i1 %t1, label %then0, label %ifend2
then0:
  store i32 0, ptr %t2
  br label %wcond3
wcond3:
  %t3 = icmp ne i32 1, 0
  br i1 %t3, label %wbody4, label %wend5
wbody4:
  %t4 = call i32 @fn_is_op(ptr @.str139)
  %t5 = icmp ne i32 %t4, 0
  br i1 %t5, label %then6, label %ifend8
then6:
  %t6 = load i32, ptr %t2
  %t7 = add i32 %t6, 1
  store i32 %t7, ptr %t2
  br label %ifend8
ifend8:
  %t8 = call i32 @fn_is_op(ptr @.str140)
  %t9 = icmp ne i32 %t8, 0
  br i1 %t9, label %then9, label %ifend11
then9:
  %t10 = load i32, ptr %t2
  %t11 = sub i32 %t10, 1
  store i32 %t11, ptr %t2
  br label %ifend11
ifend11:
  %t12 = load i32, ptr @g_pi
  %t13 = add i32 %t12, 1
  store i32 %t13, ptr @g_pi
  %t14 = load i32, ptr %t2
  %t15 = icmp eq i32 %t14, 0
  %t16 = zext i1 %t15 to i32
  %t17 = icmp ne i32 %t16, 0
  br i1 %t17, label %then12, label %ifend14
then12:
  br label %wend5
ifend14:
  br label %wcond3
wend5:
  br label %ifend2
ifend2:
  br label %ret
ret:
  ret void
}

define ptr @fn_parse_system() {
entry:
  %retval = alloca ptr
  %t3 = alloca ptr
  %t9 = alloca i32
  %t11 = alloca ptr
  %t18 = alloca ptr
  %t21 = alloca i32
  %t44 = alloca i32
  %t66 = alloca ptr
  %t107 = alloca ptr
  %t114 = alloca ptr
  %t0 = load i32, ptr @g_pi
  %t1 = add i32 %t0, 1
  store i32 %t1, ptr @g_pi
  %t2 = call ptr @fn_node(i32 9)
  store ptr %t2, ptr %t3
  %t4 = load ptr, ptr %t3
  %t5 = getelementptr inbounds %Str_Node, ptr %t4, i32 0, i32 1
  %t6 = call ptr @fn_eat_id()
  store ptr %t6, ptr %t5
  %t7 = load ptr, ptr %t3
  %t8 = getelementptr inbounds %Str_Node, ptr %t7, i32 0, i32 3
  store ptr @.str141, ptr %t8
  store i32 0, ptr %t9
  %t10 = call ptr @fn_node(i32 21)
  store ptr %t10, ptr %t11
  br label %wcond0
wcond0:
  %t12 = icmp ne i32 1, 0
  br i1 %t12, label %wbody1, label %wend2
wbody1:
  call void @fn_skipnl()
  %t13 = call i32 @fn_is_op(ptr @.str142)
  %t14 = icmp ne i32 %t13, 0
  br i1 %t14, label %then3, label %ifend5
then3:
  %t15 = load i32, ptr @g_pi
  %t16 = add i32 %t15, 1
  store i32 %t16, ptr @g_pi
  %t17 = call ptr @fn_eat_id()
  store ptr %t17, ptr %t18
  %t19 = call i32 @fn_is_op(ptr @.str143)
  %t20 = icmp ne i32 %t19, 0
  br i1 %t20, label %then6, label %ifend8
then6:
  store i32 0, ptr %t21
  br label %wcond9
wcond9:
  %t22 = icmp ne i32 1, 0
  br i1 %t22, label %wbody10, label %wend11
wbody10:
  %t23 = call i32 @fn_is_op(ptr @.str144)
  %t24 = icmp ne i32 %t23, 0
  br i1 %t24, label %then12, label %ifend14
then12:
  %t25 = load i32, ptr %t21
  %t26 = add i32 %t25, 1
  store i32 %t26, ptr %t21
  br label %ifend14
ifend14:
  %t27 = call i32 @fn_is_op(ptr @.str145)
  %t28 = icmp ne i32 %t27, 0
  br i1 %t28, label %then15, label %ifend17
then15:
  %t29 = load i32, ptr %t21
  %t30 = sub i32 %t29, 1
  store i32 %t30, ptr %t21
  br label %ifend17
ifend17:
  %t31 = load i32, ptr @g_pi
  %t32 = add i32 %t31, 1
  store i32 %t32, ptr @g_pi
  %t33 = load i32, ptr %t21
  %t34 = icmp eq i32 %t33, 0
  %t35 = zext i1 %t34 to i32
  %t36 = icmp ne i32 %t35, 0
  br i1 %t36, label %then18, label %ifend20
then18:
  br label %wend11
ifend20:
  br label %wcond9
wend11:
  br label %ifend8
ifend8:
  br label %wcond0
ifend5:
  %t37 = call i32 @fn_is_id(ptr @.str146)
  %t38 = icmp ne i32 %t37, 0
  br i1 %t38, label %then21, label %ifend23
then21:
  %t39 = load i32, ptr @g_pi
  %t40 = add i32 %t39, 1
  store i32 %t40, ptr @g_pi
  %t41 = load ptr, ptr %t3
  %t42 = getelementptr inbounds %Str_Node, ptr %t41, i32 0, i32 3
  %t43 = call ptr @fn_eat_id()
  store ptr %t43, ptr %t42
  br label %wcond0
ifend23:
  %t45 = call i32 @fn_is_id(ptr @.str147)
  %t46 = icmp ne i32 %t45, 0
  %t47 = zext i1 %t46 to i32
  store i32 %t47, ptr %t44
  br i1 %t46, label %scend25, label %sc24
sc24:
  %t48 = call i32 @fn_is_id(ptr @.str148)
  %t49 = icmp ne i32 %t48, 0
  %t50 = zext i1 %t49 to i32
  store i32 %t50, ptr %t44
  br label %scend25
scend25:
  %t51 = load i32, ptr %t44
  %t52 = icmp ne i32 %t51, 0
  br i1 %t52, label %then26, label %ifend28
then26:
  %t53 = load i32, ptr @g_pi
  %t54 = add i32 %t53, 1
  store i32 %t54, ptr @g_pi
  call void @fn_skip_clause()
  br label %wcond0
ifend28:
  %t55 = call i32 @fn_is_id(ptr @.str149)
  %t56 = icmp ne i32 %t55, 0
  br i1 %t56, label %then29, label %ifend31
then29:
  %t57 = load i32, ptr @g_pi
  %t58 = add i32 %t57, 1
  store i32 %t58, ptr @g_pi
  store i32 1, ptr %t9
  %t59 = call i32 @fn_is_op(ptr @.str150)
  %t60 = icmp ne i32 %t59, 0
  br i1 %t60, label %then32, label %ifend34
then32:
  call void @fn_eat_op(ptr @.str151)
  br label %wcond35
wcond35:
  %t61 = call i32 @fn_is_op(ptr @.str152)
  %t62 = icmp eq i32 %t61, 0
  %t63 = zext i1 %t62 to i32
  %t64 = icmp ne i32 %t63, 0
  br i1 %t64, label %wbody36, label %wend37
wbody36:
  %t65 = call ptr @fn_node(i32 33)
  store ptr %t65, ptr %t66
  %t67 = load ptr, ptr %t66
  %t68 = getelementptr inbounds %Str_Node, ptr %t67, i32 0, i32 1
  %t69 = call ptr @fn_eat_id()
  store ptr %t69, ptr %t68
  %t70 = load ptr, ptr %t11
  %t71 = getelementptr inbounds %Str_Node, ptr %t70, i32 0, i32 7
  %t72 = load ptr, ptr %t71
  %t73 = getelementptr inbounds %LSlice, ptr %t72, i32 0, i32 1
  %t74 = getelementptr inbounds %LSlice, ptr %t72, i32 0, i32 2
  %t75 = getelementptr inbounds %LSlice, ptr %t72, i32 0, i32 0
  %t76 = load i32, ptr %t73
  %t77 = load i32, ptr %t74
  %t78 = icmp sge i32 %t76, %t77
  br i1 %t78, label %grow38, label %put39
grow38:
  %t79 = mul i32 %t77, 2
  %t80 = icmp eq i32 %t77, 0
  %t81 = select i1 %t80, i32 8, i32 %t79
  %t82 = getelementptr ptr, ptr null, i32 1
  %t83 = ptrtoint ptr %t82 to i64
  %t84 = zext i32 %t81 to i64
  %t85 = mul i64 %t84, %t83
  %t86 = load ptr, ptr %t75
  %t87 = call ptr @realloc(ptr %t86, i64 %t85)
  store ptr %t87, ptr %t75
  store i32 %t81, ptr %t74
  br label %put39
put39:
  %t88 = load ptr, ptr %t66
  %t89 = load ptr, ptr %t75
  %t90 = getelementptr inbounds ptr, ptr %t89, i32 %t76
  store ptr %t88, ptr %t90
  %t91 = add i32 %t76, 1
  store i32 %t91, ptr %t73
  %t92 = call i32 @fn_is_op(ptr @.str153)
  %t93 = icmp ne i32 %t92, 0
  br i1 %t93, label %then40, label %ifend42
then40:
  %t94 = load i32, ptr @g_pi
  %t95 = add i32 %t94, 1
  store i32 %t95, ptr @g_pi
  br label %ifend42
ifend42:
  br label %wcond35
wend37:
  call void @fn_eat_op(ptr @.str154)
  br label %ifend34
ifend34:
  %t96 = load ptr, ptr %t11
  %t97 = getelementptr inbounds %Str_Node, ptr %t96, i32 0, i32 6
  %t98 = call ptr @fn_parse_query_tail()
  store ptr %t98, ptr %t97
  %t99 = load ptr, ptr %t11
  %t100 = getelementptr inbounds %Str_Node, ptr %t99, i32 0, i32 5
  %t101 = load ptr, ptr %t11
  %t102 = getelementptr inbounds %Str_Node, ptr %t101, i32 0, i32 6
  %t103 = load ptr, ptr %t102
  %t104 = getelementptr inbounds %Str_Node, ptr %t103, i32 0, i32 4
  %t105 = load ptr, ptr %t104
  store ptr %t105, ptr %t100
  br label %wcond0
ifend31:
  br label %wend2
wend2:
  call void @fn_skipnl()
  %t106 = call ptr @fn_block()
  store ptr %t106, ptr %t107
  %t108 = load i32, ptr %t9
  %t109 = icmp ne i32 %t108, 0
  br i1 %t109, label %then43, label %else44
then43:
  %t110 = load ptr, ptr %t11
  %t111 = getelementptr inbounds %Str_Node, ptr %t110, i32 0, i32 4
  %t112 = load ptr, ptr %t107
  store ptr %t112, ptr %t111
  %t113 = call ptr @fn_node(i32 7)
  store ptr %t113, ptr %t114
  %t115 = load ptr, ptr %t114
  %t116 = getelementptr inbounds %Str_Node, ptr %t115, i32 0, i32 7
  %t117 = load ptr, ptr %t116
  %t118 = getelementptr inbounds %LSlice, ptr %t117, i32 0, i32 1
  %t119 = getelementptr inbounds %LSlice, ptr %t117, i32 0, i32 2
  %t120 = getelementptr inbounds %LSlice, ptr %t117, i32 0, i32 0
  %t121 = load i32, ptr %t118
  %t122 = load i32, ptr %t119
  %t123 = icmp sge i32 %t121, %t122
  br i1 %t123, label %grow46, label %put47
grow46:
  %t124 = mul i32 %t122, 2
  %t125 = icmp eq i32 %t122, 0
  %t126 = select i1 %t125, i32 8, i32 %t124
  %t127 = getelementptr ptr, ptr null, i32 1
  %t128 = ptrtoint ptr %t127 to i64
  %t129 = zext i32 %t126 to i64
  %t130 = mul i64 %t129, %t128
  %t131 = load ptr, ptr %t120
  %t132 = call ptr @realloc(ptr %t131, i64 %t130)
  store ptr %t132, ptr %t120
  store i32 %t126, ptr %t119
  br label %put47
put47:
  %t133 = load ptr, ptr %t11
  %t134 = load ptr, ptr %t120
  %t135 = getelementptr inbounds ptr, ptr %t134, i32 %t121
  store ptr %t133, ptr %t135
  %t136 = add i32 %t121, 1
  store i32 %t136, ptr %t118
  %t137 = load ptr, ptr %t3
  %t138 = getelementptr inbounds %Str_Node, ptr %t137, i32 0, i32 4
  %t139 = load ptr, ptr %t114
  store ptr %t139, ptr %t138
  br label %ifend45
else44:
  %t140 = load ptr, ptr %t3
  %t141 = getelementptr inbounds %Str_Node, ptr %t140, i32 0, i32 4
  %t142 = load ptr, ptr %t107
  store ptr %t142, ptr %t141
  br label %ifend45
ifend45:
  %t143 = load ptr, ptr %t3
  store ptr %t143, ptr %retval
  br label %ret
ret:
  %t144 = load ptr, ptr %retval
  ret ptr %t144
}

define ptr @fn_parse_query_tail() {
entry:
  %retval = alloca ptr
  %t1 = alloca ptr
  %t11 = alloca ptr
  %t40 = alloca ptr
  call void @fn_eat_op(ptr @.str155)
  %t0 = call ptr @fn_node(i32 7)
  store ptr %t0, ptr %t1
  br label %wcond0
wcond0:
  %t2 = call i32 @fn_is_op(ptr @.str156)
  %t3 = icmp eq i32 %t2, 0
  %t4 = zext i1 %t3 to i32
  %t5 = icmp ne i32 %t4, 0
  br i1 %t5, label %wbody1, label %wend2
wbody1:
  %t6 = call i32 @fn_is_op(ptr @.str157)
  %t7 = icmp ne i32 %t6, 0
  br i1 %t7, label %then3, label %else4
then3:
  %t8 = load i32, ptr @g_pi
  %t9 = add i32 %t8, 1
  store i32 %t9, ptr @g_pi
  %t10 = call ptr @fn_node(i32 33)
  store ptr %t10, ptr %t11
  %t12 = load ptr, ptr %t11
  %t13 = getelementptr inbounds %Str_Node, ptr %t12, i32 0, i32 1
  %t14 = call ptr @fn_eat_id()
  store ptr %t14, ptr %t13
  %t15 = load ptr, ptr %t11
  %t16 = getelementptr inbounds %Str_Node, ptr %t15, i32 0, i32 2
  store i32 1, ptr %t16
  %t17 = load ptr, ptr %t1
  %t18 = getelementptr inbounds %Str_Node, ptr %t17, i32 0, i32 7
  %t19 = load ptr, ptr %t18
  %t20 = getelementptr inbounds %LSlice, ptr %t19, i32 0, i32 1
  %t21 = getelementptr inbounds %LSlice, ptr %t19, i32 0, i32 2
  %t22 = getelementptr inbounds %LSlice, ptr %t19, i32 0, i32 0
  %t23 = load i32, ptr %t20
  %t24 = load i32, ptr %t21
  %t25 = icmp sge i32 %t23, %t24
  br i1 %t25, label %grow6, label %put7
grow6:
  %t26 = mul i32 %t24, 2
  %t27 = icmp eq i32 %t24, 0
  %t28 = select i1 %t27, i32 8, i32 %t26
  %t29 = getelementptr ptr, ptr null, i32 1
  %t30 = ptrtoint ptr %t29 to i64
  %t31 = zext i32 %t28 to i64
  %t32 = mul i64 %t31, %t30
  %t33 = load ptr, ptr %t22
  %t34 = call ptr @realloc(ptr %t33, i64 %t32)
  store ptr %t34, ptr %t22
  store i32 %t28, ptr %t21
  br label %put7
put7:
  %t35 = load ptr, ptr %t11
  %t36 = load ptr, ptr %t22
  %t37 = getelementptr inbounds ptr, ptr %t36, i32 %t23
  store ptr %t35, ptr %t37
  %t38 = add i32 %t23, 1
  store i32 %t38, ptr %t20
  call void @fn_eat_op(ptr @.str158)
  br label %ifend5
else4:
  %t39 = call ptr @fn_node(i32 33)
  store ptr %t39, ptr %t40
  %t41 = load ptr, ptr %t40
  %t42 = getelementptr inbounds %Str_Node, ptr %t41, i32 0, i32 1
  %t43 = call ptr @fn_eat_id()
  store ptr %t43, ptr %t42
  %t44 = load ptr, ptr %t40
  %t45 = getelementptr inbounds %Str_Node, ptr %t44, i32 0, i32 2
  store i32 0, ptr %t45
  %t46 = load ptr, ptr %t1
  %t47 = getelementptr inbounds %Str_Node, ptr %t46, i32 0, i32 7
  %t48 = load ptr, ptr %t47
  %t49 = getelementptr inbounds %LSlice, ptr %t48, i32 0, i32 1
  %t50 = getelementptr inbounds %LSlice, ptr %t48, i32 0, i32 2
  %t51 = getelementptr inbounds %LSlice, ptr %t48, i32 0, i32 0
  %t52 = load i32, ptr %t49
  %t53 = load i32, ptr %t50
  %t54 = icmp sge i32 %t52, %t53
  br i1 %t54, label %grow8, label %put9
grow8:
  %t55 = mul i32 %t53, 2
  %t56 = icmp eq i32 %t53, 0
  %t57 = select i1 %t56, i32 8, i32 %t55
  %t58 = getelementptr ptr, ptr null, i32 1
  %t59 = ptrtoint ptr %t58 to i64
  %t60 = zext i32 %t57 to i64
  %t61 = mul i64 %t60, %t59
  %t62 = load ptr, ptr %t51
  %t63 = call ptr @realloc(ptr %t62, i64 %t61)
  store ptr %t63, ptr %t51
  store i32 %t57, ptr %t50
  br label %put9
put9:
  %t64 = load ptr, ptr %t40
  %t65 = load ptr, ptr %t51
  %t66 = getelementptr inbounds ptr, ptr %t65, i32 %t52
  store ptr %t64, ptr %t66
  %t67 = add i32 %t52, 1
  store i32 %t67, ptr %t49
  br label %ifend5
ifend5:
  %t68 = call i32 @fn_is_op(ptr @.str159)
  %t69 = icmp ne i32 %t68, 0
  br i1 %t69, label %then10, label %ifend12
then10:
  %t70 = load i32, ptr @g_pi
  %t71 = add i32 %t70, 1
  store i32 %t71, ptr @g_pi
  br label %ifend12
ifend12:
  br label %wcond0
wend2:
  call void @fn_eat_op(ptr @.str160)
  %t72 = call i32 @fn_is_id(ptr @.str161)
  %t73 = icmp ne i32 %t72, 0
  br i1 %t73, label %then13, label %ifend15
then13:
  %t74 = load i32, ptr @g_pi
  %t75 = add i32 %t74, 1
  store i32 %t75, ptr @g_pi
  %t76 = load ptr, ptr %t1
  %t77 = getelementptr inbounds %Str_Node, ptr %t76, i32 0, i32 4
  %t78 = call ptr @fn_expr()
  store ptr %t78, ptr %t77
  br label %ifend15
ifend15:
  %t79 = load ptr, ptr %t1
  store ptr %t79, ptr %retval
  br label %ret
ret:
  %t80 = load ptr, ptr %retval
  ret ptr %t80
}

define ptr @fn_parse_query_for() {
entry:
  %retval = alloca ptr
  %t1 = alloca ptr
  %t7 = alloca ptr
  %t38 = alloca ptr
  %t40 = alloca ptr
  %t0 = call ptr @fn_node(i32 21)
  store ptr %t0, ptr %t1
  call void @fn_eat_op(ptr @.str162)
  br label %wcond0
wcond0:
  %t2 = call i32 @fn_is_op(ptr @.str163)
  %t3 = icmp eq i32 %t2, 0
  %t4 = zext i1 %t3 to i32
  %t5 = icmp ne i32 %t4, 0
  br i1 %t5, label %wbody1, label %wend2
wbody1:
  %t6 = call ptr @fn_node(i32 33)
  store ptr %t6, ptr %t7
  %t8 = load ptr, ptr %t7
  %t9 = getelementptr inbounds %Str_Node, ptr %t8, i32 0, i32 1
  %t10 = call ptr @fn_eat_id()
  store ptr %t10, ptr %t9
  %t11 = load ptr, ptr %t1
  %t12 = getelementptr inbounds %Str_Node, ptr %t11, i32 0, i32 7
  %t13 = load ptr, ptr %t12
  %t14 = getelementptr inbounds %LSlice, ptr %t13, i32 0, i32 1
  %t15 = getelementptr inbounds %LSlice, ptr %t13, i32 0, i32 2
  %t16 = getelementptr inbounds %LSlice, ptr %t13, i32 0, i32 0
  %t17 = load i32, ptr %t14
  %t18 = load i32, ptr %t15
  %t19 = icmp sge i32 %t17, %t18
  br i1 %t19, label %grow3, label %put4
grow3:
  %t20 = mul i32 %t18, 2
  %t21 = icmp eq i32 %t18, 0
  %t22 = select i1 %t21, i32 8, i32 %t20
  %t23 = getelementptr ptr, ptr null, i32 1
  %t24 = ptrtoint ptr %t23 to i64
  %t25 = zext i32 %t22 to i64
  %t26 = mul i64 %t25, %t24
  %t27 = load ptr, ptr %t16
  %t28 = call ptr @realloc(ptr %t27, i64 %t26)
  store ptr %t28, ptr %t16
  store i32 %t22, ptr %t15
  br label %put4
put4:
  %t29 = load ptr, ptr %t7
  %t30 = load ptr, ptr %t16
  %t31 = getelementptr inbounds ptr, ptr %t30, i32 %t17
  store ptr %t29, ptr %t31
  %t32 = add i32 %t17, 1
  store i32 %t32, ptr %t14
  %t33 = call i32 @fn_is_op(ptr @.str164)
  %t34 = icmp ne i32 %t33, 0
  br i1 %t34, label %then5, label %ifend7
then5:
  %t35 = load i32, ptr @g_pi
  %t36 = add i32 %t35, 1
  store i32 %t36, ptr @g_pi
  br label %ifend7
ifend7:
  br label %wcond0
wend2:
  call void @fn_eat_op(ptr @.str165)
  %t37 = call ptr @fn_eat_id()
  store ptr %t37, ptr %t38
  %t39 = call ptr @fn_eat_id()
  store ptr %t39, ptr %t40
  %t41 = load ptr, ptr %t1
  %t42 = getelementptr inbounds %Str_Node, ptr %t41, i32 0, i32 6
  %t43 = call ptr @fn_parse_query_tail()
  store ptr %t43, ptr %t42
  %t44 = load ptr, ptr %t1
  %t45 = getelementptr inbounds %Str_Node, ptr %t44, i32 0, i32 5
  %t46 = load ptr, ptr %t1
  %t47 = getelementptr inbounds %Str_Node, ptr %t46, i32 0, i32 6
  %t48 = load ptr, ptr %t47
  %t49 = getelementptr inbounds %Str_Node, ptr %t48, i32 0, i32 4
  %t50 = load ptr, ptr %t49
  store ptr %t50, ptr %t45
  %t51 = load ptr, ptr %t1
  %t52 = getelementptr inbounds %Str_Node, ptr %t51, i32 0, i32 4
  %t53 = call ptr @fn_block()
  store ptr %t53, ptr %t52
  %t54 = load ptr, ptr %t1
  store ptr %t54, ptr %retval
  br label %ret
ret:
  %t55 = load ptr, ptr %retval
  ret ptr %t55
}

define ptr @fn_parse_spawn() {
entry:
  %retval = alloca ptr
  %t3 = alloca ptr
  %t11 = alloca ptr
  %t0 = load i32, ptr @g_pi
  %t1 = add i32 %t0, 1
  store i32 %t1, ptr @g_pi
  %t2 = call ptr @fn_node(i32 22)
  store ptr %t2, ptr %t3
  %t4 = load ptr, ptr %t3
  %t5 = getelementptr inbounds %Str_Node, ptr %t4, i32 0, i32 1
  %t6 = call ptr @fn_eat_id()
  store ptr %t6, ptr %t5
  call void @fn_skipnl()
  call void @fn_eat_op(ptr @.str166)
  br label %wcond0
wcond0:
  %t7 = icmp ne i32 1, 0
  br i1 %t7, label %wbody1, label %wend2
wbody1:
  call void @fn_skipnl()
  %t8 = call i32 @fn_is_op(ptr @.str167)
  %t9 = icmp ne i32 %t8, 0
  br i1 %t9, label %then3, label %ifend5
then3:
  br label %wend2
ifend5:
  %t10 = call ptr @fn_node(i32 42)
  store ptr %t10, ptr %t11
  %t12 = load ptr, ptr %t11
  %t13 = getelementptr inbounds %Str_Node, ptr %t12, i32 0, i32 1
  %t14 = call ptr @fn_eat_id()
  store ptr %t14, ptr %t13
  %t15 = load ptr, ptr %t11
  %t16 = getelementptr inbounds %Str_Node, ptr %t15, i32 0, i32 4
  %t17 = call ptr @fn_record()
  store ptr %t17, ptr %t16
  %t18 = load ptr, ptr %t3
  %t19 = getelementptr inbounds %Str_Node, ptr %t18, i32 0, i32 7
  %t20 = load ptr, ptr %t19
  %t21 = getelementptr inbounds %LSlice, ptr %t20, i32 0, i32 1
  %t22 = getelementptr inbounds %LSlice, ptr %t20, i32 0, i32 2
  %t23 = getelementptr inbounds %LSlice, ptr %t20, i32 0, i32 0
  %t24 = load i32, ptr %t21
  %t25 = load i32, ptr %t22
  %t26 = icmp sge i32 %t24, %t25
  br i1 %t26, label %grow6, label %put7
grow6:
  %t27 = mul i32 %t25, 2
  %t28 = icmp eq i32 %t25, 0
  %t29 = select i1 %t28, i32 8, i32 %t27
  %t30 = getelementptr ptr, ptr null, i32 1
  %t31 = ptrtoint ptr %t30 to i64
  %t32 = zext i32 %t29 to i64
  %t33 = mul i64 %t32, %t31
  %t34 = load ptr, ptr %t23
  %t35 = call ptr @realloc(ptr %t34, i64 %t33)
  store ptr %t35, ptr %t23
  store i32 %t29, ptr %t22
  br label %put7
put7:
  %t36 = load ptr, ptr %t11
  %t37 = load ptr, ptr %t23
  %t38 = getelementptr inbounds ptr, ptr %t37, i32 %t24
  store ptr %t36, ptr %t38
  %t39 = add i32 %t24, 1
  store i32 %t39, ptr %t21
  %t40 = call i32 @fn_is_op(ptr @.str168)
  %t41 = icmp ne i32 %t40, 0
  br i1 %t41, label %then8, label %ifend10
then8:
  %t42 = load i32, ptr @g_pi
  %t43 = add i32 %t42, 1
  store i32 %t43, ptr @g_pi
  br label %ifend10
ifend10:
  br label %wcond0
wend2:
  call void @fn_eat_op(ptr @.str169)
  %t44 = load ptr, ptr %t3
  store ptr %t44, ptr %retval
  br label %ret
ret:
  %t45 = load ptr, ptr %retval
  ret ptr %t45
}

define ptr @fn_parse_enum() {
entry:
  %retval = alloca ptr
  %t3 = alloca ptr
  %t11 = alloca ptr
  %t0 = load i32, ptr @g_pi
  %t1 = add i32 %t0, 1
  store i32 %t1, ptr @g_pi
  %t2 = call ptr @fn_node(i32 27)
  store ptr %t2, ptr %t3
  %t4 = load ptr, ptr %t3
  %t5 = getelementptr inbounds %Str_Node, ptr %t4, i32 0, i32 1
  %t6 = call ptr @fn_eat_id()
  store ptr %t6, ptr %t5
  call void @fn_skipnl()
  call void @fn_eat_op(ptr @.str170)
  br label %wcond0
wcond0:
  %t7 = icmp ne i32 1, 0
  br i1 %t7, label %wbody1, label %wend2
wbody1:
  call void @fn_skipnl()
  %t8 = call i32 @fn_is_op(ptr @.str171)
  %t9 = icmp ne i32 %t8, 0
  br i1 %t9, label %then3, label %ifend5
then3:
  br label %wend2
ifend5:
  %t10 = call ptr @fn_node(i32 33)
  store ptr %t10, ptr %t11
  %t12 = load ptr, ptr %t11
  %t13 = getelementptr inbounds %Str_Node, ptr %t12, i32 0, i32 1
  %t14 = call ptr @fn_eat_id()
  store ptr %t14, ptr %t13
  %t15 = load ptr, ptr %t3
  %t16 = getelementptr inbounds %Str_Node, ptr %t15, i32 0, i32 7
  %t17 = load ptr, ptr %t16
  %t18 = getelementptr inbounds %LSlice, ptr %t17, i32 0, i32 1
  %t19 = getelementptr inbounds %LSlice, ptr %t17, i32 0, i32 2
  %t20 = getelementptr inbounds %LSlice, ptr %t17, i32 0, i32 0
  %t21 = load i32, ptr %t18
  %t22 = load i32, ptr %t19
  %t23 = icmp sge i32 %t21, %t22
  br i1 %t23, label %grow6, label %put7
grow6:
  %t24 = mul i32 %t22, 2
  %t25 = icmp eq i32 %t22, 0
  %t26 = select i1 %t25, i32 8, i32 %t24
  %t27 = getelementptr ptr, ptr null, i32 1
  %t28 = ptrtoint ptr %t27 to i64
  %t29 = zext i32 %t26 to i64
  %t30 = mul i64 %t29, %t28
  %t31 = load ptr, ptr %t20
  %t32 = call ptr @realloc(ptr %t31, i64 %t30)
  store ptr %t32, ptr %t20
  store i32 %t26, ptr %t19
  br label %put7
put7:
  %t33 = load ptr, ptr %t11
  %t34 = load ptr, ptr %t20
  %t35 = getelementptr inbounds ptr, ptr %t34, i32 %t21
  store ptr %t33, ptr %t35
  %t36 = add i32 %t21, 1
  store i32 %t36, ptr %t18
  %t37 = call i32 @fn_is_op(ptr @.str172)
  %t38 = icmp ne i32 %t37, 0
  br i1 %t38, label %then8, label %ifend10
then8:
  %t39 = load i32, ptr @g_pi
  %t40 = add i32 %t39, 1
  store i32 %t40, ptr @g_pi
  br label %ifend10
ifend10:
  call void @fn_skipnl()
  br label %wcond0
wend2:
  call void @fn_eat_op(ptr @.str173)
  %t41 = load ptr, ptr %t3
  store ptr %t41, ptr %retval
  br label %ret
ret:
  %t42 = load ptr, ptr %retval
  ret ptr %t42
}

define ptr @fn_parse_archetype() {
entry:
  %retval = alloca ptr
  %t3 = alloca ptr
  %t11 = alloca ptr
  %t0 = load i32, ptr @g_pi
  %t1 = add i32 %t0, 1
  store i32 %t1, ptr @g_pi
  %t2 = call ptr @fn_node(i32 10)
  store ptr %t2, ptr %t3
  %t4 = load ptr, ptr %t3
  %t5 = getelementptr inbounds %Str_Node, ptr %t4, i32 0, i32 1
  %t6 = call ptr @fn_eat_id()
  store ptr %t6, ptr %t5
  call void @fn_skipnl()
  call void @fn_eat_op(ptr @.str174)
  br label %wcond0
wcond0:
  %t7 = icmp ne i32 1, 0
  br i1 %t7, label %wbody1, label %wend2
wbody1:
  call void @fn_skipnl()
  %t8 = call i32 @fn_is_op(ptr @.str175)
  %t9 = icmp ne i32 %t8, 0
  br i1 %t9, label %then3, label %ifend5
then3:
  br label %wend2
ifend5:
  %t10 = call ptr @fn_node(i32 33)
  store ptr %t10, ptr %t11
  %t12 = load ptr, ptr %t11
  %t13 = getelementptr inbounds %Str_Node, ptr %t12, i32 0, i32 1
  %t14 = call ptr @fn_eat_id()
  store ptr %t14, ptr %t13
  %t15 = load ptr, ptr %t3
  %t16 = getelementptr inbounds %Str_Node, ptr %t15, i32 0, i32 7
  %t17 = load ptr, ptr %t16
  %t18 = getelementptr inbounds %LSlice, ptr %t17, i32 0, i32 1
  %t19 = getelementptr inbounds %LSlice, ptr %t17, i32 0, i32 2
  %t20 = getelementptr inbounds %LSlice, ptr %t17, i32 0, i32 0
  %t21 = load i32, ptr %t18
  %t22 = load i32, ptr %t19
  %t23 = icmp sge i32 %t21, %t22
  br i1 %t23, label %grow6, label %put7
grow6:
  %t24 = mul i32 %t22, 2
  %t25 = icmp eq i32 %t22, 0
  %t26 = select i1 %t25, i32 8, i32 %t24
  %t27 = getelementptr ptr, ptr null, i32 1
  %t28 = ptrtoint ptr %t27 to i64
  %t29 = zext i32 %t26 to i64
  %t30 = mul i64 %t29, %t28
  %t31 = load ptr, ptr %t20
  %t32 = call ptr @realloc(ptr %t31, i64 %t30)
  store ptr %t32, ptr %t20
  store i32 %t26, ptr %t19
  br label %put7
put7:
  %t33 = load ptr, ptr %t11
  %t34 = load ptr, ptr %t20
  %t35 = getelementptr inbounds ptr, ptr %t34, i32 %t21
  store ptr %t33, ptr %t35
  %t36 = add i32 %t21, 1
  store i32 %t36, ptr %t18
  %t37 = call i32 @fn_is_op(ptr @.str176)
  %t38 = icmp ne i32 %t37, 0
  br i1 %t38, label %then8, label %ifend10
then8:
  %t39 = load i32, ptr @g_pi
  %t40 = add i32 %t39, 1
  store i32 %t40, ptr @g_pi
  br label %ifend10
ifend10:
  call void @fn_skipnl()
  br label %wcond0
wend2:
  call void @fn_eat_op(ptr @.str177)
  %t41 = load ptr, ptr %t3
  store ptr %t41, ptr %retval
  br label %ret
ret:
  %t42 = load ptr, ptr %retval
  ret ptr %t42
}

define ptr @fn_parse_extern() {
entry:
  %retval = alloca ptr
  %t3 = alloca ptr
  %t5 = alloca ptr
  %t14 = alloca ptr
  %t62 = alloca ptr
  %t0 = load i32, ptr @g_pi
  %t1 = add i32 %t0, 1
  store i32 %t1, ptr @g_pi
  %t2 = call ptr @fn_eat_id()
  store ptr %t2, ptr %t3
  %t4 = call ptr @fn_node(i32 11)
  store ptr %t4, ptr %t5
  %t6 = load ptr, ptr %t5
  %t7 = getelementptr inbounds %Str_Node, ptr %t6, i32 0, i32 1
  %t8 = call ptr @fn_eat_id()
  store ptr %t8, ptr %t7
  call void @fn_eat_op(ptr @.str178)
  br label %wcond0
wcond0:
  %t9 = call i32 @fn_is_op(ptr @.str179)
  %t10 = icmp eq i32 %t9, 0
  %t11 = zext i1 %t10 to i32
  %t12 = icmp ne i32 %t11, 0
  br i1 %t12, label %wbody1, label %wend2
wbody1:
  %t13 = call ptr @fn_node(i32 5)
  store ptr %t13, ptr %t14
  %t15 = load ptr, ptr %t14
  %t16 = getelementptr inbounds %Str_Node, ptr %t15, i32 0, i32 1
  %t17 = call ptr @fn_eat_id()
  store ptr %t17, ptr %t16
  call void @fn_eat_op(ptr @.str180)
  %t18 = load ptr, ptr %t14
  %t19 = getelementptr inbounds %Str_Node, ptr %t18, i32 0, i32 3
  %t20 = call ptr @fn_ptype()
  store ptr %t20, ptr %t19
  %t21 = load ptr, ptr %t5
  %t22 = getelementptr inbounds %Str_Node, ptr %t21, i32 0, i32 7
  %t23 = load ptr, ptr %t22
  %t24 = getelementptr inbounds %LSlice, ptr %t23, i32 0, i32 1
  %t25 = getelementptr inbounds %LSlice, ptr %t23, i32 0, i32 2
  %t26 = getelementptr inbounds %LSlice, ptr %t23, i32 0, i32 0
  %t27 = load i32, ptr %t24
  %t28 = load i32, ptr %t25
  %t29 = icmp sge i32 %t27, %t28
  br i1 %t29, label %grow3, label %put4
grow3:
  %t30 = mul i32 %t28, 2
  %t31 = icmp eq i32 %t28, 0
  %t32 = select i1 %t31, i32 8, i32 %t30
  %t33 = getelementptr ptr, ptr null, i32 1
  %t34 = ptrtoint ptr %t33 to i64
  %t35 = zext i32 %t32 to i64
  %t36 = mul i64 %t35, %t34
  %t37 = load ptr, ptr %t26
  %t38 = call ptr @realloc(ptr %t37, i64 %t36)
  store ptr %t38, ptr %t26
  store i32 %t32, ptr %t25
  br label %put4
put4:
  %t39 = load ptr, ptr %t14
  %t40 = load ptr, ptr %t26
  %t41 = getelementptr inbounds ptr, ptr %t40, i32 %t27
  store ptr %t39, ptr %t41
  %t42 = add i32 %t27, 1
  store i32 %t42, ptr %t24
  %t43 = call i32 @fn_is_op(ptr @.str181)
  %t44 = icmp ne i32 %t43, 0
  br i1 %t44, label %then5, label %ifend7
then5:
  %t45 = load i32, ptr @g_pi
  %t46 = add i32 %t45, 1
  store i32 %t46, ptr @g_pi
  br label %ifend7
ifend7:
  br label %wcond0
wend2:
  call void @fn_eat_op(ptr @.str182)
  %t47 = load ptr, ptr %t5
  %t48 = getelementptr inbounds %Str_Node, ptr %t47, i32 0, i32 3
  store ptr @.str183, ptr %t48
  %t49 = call i32 @fn_is_op(ptr @.str184)
  %t50 = icmp ne i32 %t49, 0
  br i1 %t50, label %then8, label %ifend10
then8:
  %t51 = load i32, ptr @g_pi
  %t52 = add i32 %t51, 1
  store i32 %t52, ptr @g_pi
  %t53 = load ptr, ptr %t5
  %t54 = getelementptr inbounds %Str_Node, ptr %t53, i32 0, i32 3
  %t55 = call ptr @fn_ptype()
  store ptr %t55, ptr %t54
  br label %ifend10
ifend10:
  call void @fn_eat_op(ptr @.str185)
  %t56 = load ptr, ptr @g_toks
  %t57 = getelementptr inbounds %LSlice, ptr %t56, i32 0, i32 0
  %t58 = load ptr, ptr %t57
  %t59 = load i32, ptr @g_pi
  %t60 = getelementptr inbounds ptr, ptr %t58, i32 %t59
  %t61 = load ptr, ptr %t60
  store ptr %t61, ptr %t62
  %t63 = load ptr, ptr %t5
  %t64 = getelementptr inbounds %Str_Node, ptr %t63, i32 0, i32 4
  %t65 = call ptr @fn_node(i32 31)
  store ptr %t65, ptr %t64
  %t66 = load ptr, ptr %t5
  %t67 = getelementptr inbounds %Str_Node, ptr %t66, i32 0, i32 4
  %t68 = load ptr, ptr %t67
  %t69 = getelementptr inbounds %Str_Node, ptr %t68, i32 0, i32 1
  %t70 = load ptr, ptr %t62
  %t71 = getelementptr inbounds %Str_Tok, ptr %t70, i32 0, i32 1
  %t72 = load ptr, ptr %t71
  store ptr %t72, ptr %t69
  %t73 = load i32, ptr @g_pi
  %t74 = add i32 %t73, 1
  store i32 %t74, ptr @g_pi
  %t75 = load ptr, ptr %t5
  store ptr %t75, ptr %retval
  br label %ret
ret:
  %t76 = load ptr, ptr %retval
  ret ptr %t76
}

define ptr @fn_parse_widget() {
entry:
  %retval = alloca ptr
  %t1 = alloca ptr
  %t8 = alloca i32
  %t9 = alloca i32
  %t53 = alloca ptr
  %t0 = call ptr @fn_node(i32 12)
  store ptr %t0, ptr %t1
  %t2 = load ptr, ptr %t1
  %t3 = getelementptr inbounds %Str_Node, ptr %t2, i32 0, i32 1
  %t4 = call ptr @fn_eat_id()
  store ptr %t4, ptr %t3
  %t5 = load ptr, ptr %t1
  %t6 = getelementptr inbounds %Str_Node, ptr %t5, i32 0, i32 5
  %t7 = call ptr @fn_node(i32 7)
  store ptr %t7, ptr %t6
  br label %wcond0
wcond0:
  %t10 = load ptr, ptr @g_toks
  %t11 = getelementptr inbounds %LSlice, ptr %t10, i32 0, i32 0
  %t12 = load ptr, ptr %t11
  %t13 = load i32, ptr @g_pi
  %t14 = getelementptr inbounds ptr, ptr %t12, i32 %t13
  %t15 = load ptr, ptr %t14
  %t16 = getelementptr inbounds %Str_Tok, ptr %t15, i32 0, i32 0
  %t17 = load i32, ptr %t16
  %t18 = icmp eq i32 %t17, 0
  %t19 = zext i1 %t18 to i32
  %t20 = icmp ne i32 %t19, 0
  %t21 = zext i1 %t20 to i32
  store i32 %t21, ptr %t9
  br i1 %t20, label %sc3, label %scend4
sc3:
  %t22 = load ptr, ptr @g_toks
  %t23 = getelementptr inbounds %LSlice, ptr %t22, i32 0, i32 0
  %t24 = load ptr, ptr %t23
  %t25 = load i32, ptr @g_pi
  %t26 = add i32 %t25, 1
  %t27 = getelementptr inbounds ptr, ptr %t24, i32 %t26
  %t28 = load ptr, ptr %t27
  %t29 = getelementptr inbounds %Str_Tok, ptr %t28, i32 0, i32 0
  %t30 = load i32, ptr %t29
  %t31 = icmp eq i32 %t30, 3
  %t32 = zext i1 %t31 to i32
  %t33 = icmp ne i32 %t32, 0
  %t34 = zext i1 %t33 to i32
  store i32 %t34, ptr %t9
  br label %scend4
scend4:
  %t35 = load i32, ptr %t9
  %t36 = icmp ne i32 %t35, 0
  %t37 = zext i1 %t36 to i32
  store i32 %t37, ptr %t8
  br i1 %t36, label %sc5, label %scend6
sc5:
  %t38 = load ptr, ptr @g_toks
  %t39 = getelementptr inbounds %LSlice, ptr %t38, i32 0, i32 0
  %t40 = load ptr, ptr %t39
  %t41 = load i32, ptr @g_pi
  %t42 = add i32 %t41, 1
  %t43 = getelementptr inbounds ptr, ptr %t40, i32 %t42
  %t44 = load ptr, ptr %t43
  %t45 = getelementptr inbounds %Str_Tok, ptr %t44, i32 0, i32 1
  %t46 = load ptr, ptr %t45
  %t47 = call i32 @fn_streq(ptr %t46, ptr @.str186)
  %t48 = icmp ne i32 %t47, 0
  %t49 = zext i1 %t48 to i32
  store i32 %t49, ptr %t8
  br label %scend6
scend6:
  %t50 = load i32, ptr %t8
  %t51 = icmp ne i32 %t50, 0
  br i1 %t51, label %wbody1, label %wend2
wbody1:
  %t52 = call ptr @fn_node(i32 42)
  store ptr %t52, ptr %t53
  %t54 = load ptr, ptr %t53
  %t55 = getelementptr inbounds %Str_Node, ptr %t54, i32 0, i32 1
  %t56 = call ptr @fn_eat_id()
  store ptr %t56, ptr %t55
  call void @fn_eat_op(ptr @.str187)
  %t57 = load ptr, ptr %t53
  %t58 = getelementptr inbounds %Str_Node, ptr %t57, i32 0, i32 4
  %t59 = call ptr @fn_expr()
  store ptr %t59, ptr %t58
  %t60 = load ptr, ptr %t1
  %t61 = getelementptr inbounds %Str_Node, ptr %t60, i32 0, i32 5
  %t62 = load ptr, ptr %t61
  %t63 = getelementptr inbounds %Str_Node, ptr %t62, i32 0, i32 7
  %t64 = load ptr, ptr %t63
  %t65 = getelementptr inbounds %LSlice, ptr %t64, i32 0, i32 1
  %t66 = getelementptr inbounds %LSlice, ptr %t64, i32 0, i32 2
  %t67 = getelementptr inbounds %LSlice, ptr %t64, i32 0, i32 0
  %t68 = load i32, ptr %t65
  %t69 = load i32, ptr %t66
  %t70 = icmp sge i32 %t68, %t69
  br i1 %t70, label %grow7, label %put8
grow7:
  %t71 = mul i32 %t69, 2
  %t72 = icmp eq i32 %t69, 0
  %t73 = select i1 %t72, i32 8, i32 %t71
  %t74 = getelementptr ptr, ptr null, i32 1
  %t75 = ptrtoint ptr %t74 to i64
  %t76 = zext i32 %t73 to i64
  %t77 = mul i64 %t76, %t75
  %t78 = load ptr, ptr %t67
  %t79 = call ptr @realloc(ptr %t78, i64 %t77)
  store ptr %t79, ptr %t67
  store i32 %t73, ptr %t66
  br label %put8
put8:
  %t80 = load ptr, ptr %t53
  %t81 = load ptr, ptr %t67
  %t82 = getelementptr inbounds ptr, ptr %t81, i32 %t68
  store ptr %t80, ptr %t82
  %t83 = add i32 %t68, 1
  store i32 %t83, ptr %t65
  br label %wcond0
wend2:
  call void @fn_skipnl()
  %t84 = call i32 @fn_is_op(ptr @.str188)
  %t85 = icmp ne i32 %t84, 0
  br i1 %t85, label %then9, label %ifend11
then9:
  %t86 = load i32, ptr @g_pi
  %t87 = add i32 %t86, 1
  store i32 %t87, ptr @g_pi
  br label %wcond12
wcond12:
  %t88 = icmp ne i32 1, 0
  br i1 %t88, label %wbody13, label %wend14
wbody13:
  call void @fn_skipnl()
  %t89 = call i32 @fn_is_op(ptr @.str189)
  %t90 = icmp ne i32 %t89, 0
  br i1 %t90, label %then15, label %ifend17
then15:
  br label %wend14
ifend17:
  %t91 = load ptr, ptr %t1
  %t92 = getelementptr inbounds %Str_Node, ptr %t91, i32 0, i32 7
  %t93 = load ptr, ptr %t92
  %t94 = getelementptr inbounds %LSlice, ptr %t93, i32 0, i32 1
  %t95 = getelementptr inbounds %LSlice, ptr %t93, i32 0, i32 2
  %t96 = getelementptr inbounds %LSlice, ptr %t93, i32 0, i32 0
  %t97 = load i32, ptr %t94
  %t98 = load i32, ptr %t95
  %t99 = icmp sge i32 %t97, %t98
  br i1 %t99, label %grow18, label %put19
grow18:
  %t100 = mul i32 %t98, 2
  %t101 = icmp eq i32 %t98, 0
  %t102 = select i1 %t101, i32 8, i32 %t100
  %t103 = getelementptr ptr, ptr null, i32 1
  %t104 = ptrtoint ptr %t103 to i64
  %t105 = zext i32 %t102 to i64
  %t106 = mul i64 %t105, %t104
  %t107 = load ptr, ptr %t96
  %t108 = call ptr @realloc(ptr %t107, i64 %t106)
  store ptr %t108, ptr %t96
  store i32 %t102, ptr %t95
  br label %put19
put19:
  %t109 = call ptr @fn_parse_widget()
  %t110 = load ptr, ptr %t96
  %t111 = getelementptr inbounds ptr, ptr %t110, i32 %t97
  store ptr %t109, ptr %t111
  %t112 = add i32 %t97, 1
  store i32 %t112, ptr %t94
  br label %wcond12
wend14:
  call void @fn_eat_op(ptr @.str190)
  br label %ifend11
ifend11:
  %t113 = load ptr, ptr %t1
  store ptr %t113, ptr %retval
  br label %ret
ret:
  %t114 = load ptr, ptr %retval
  ret ptr %t114
}

define ptr @fn_parse_ui() {
entry:
  %retval = alloca ptr
  %t3 = alloca ptr
  %t0 = load i32, ptr @g_pi
  %t1 = add i32 %t0, 1
  store i32 %t1, ptr @g_pi
  %t2 = call ptr @fn_node(i32 12)
  store ptr %t2, ptr %t3
  %t4 = load ptr, ptr %t3
  %t5 = getelementptr inbounds %Str_Node, ptr %t4, i32 0, i32 1
  %t6 = call ptr @fn_eat_id()
  store ptr %t6, ptr %t5
  %t7 = load ptr, ptr %t3
  %t8 = getelementptr inbounds %Str_Node, ptr %t7, i32 0, i32 2
  store i32 1, ptr %t8
  call void @fn_skipnl()
  call void @fn_eat_op(ptr @.str191)
  call void @fn_skipnl()
  %t9 = load ptr, ptr %t3
  %t10 = getelementptr inbounds %Str_Node, ptr %t9, i32 0, i32 4
  %t11 = call ptr @fn_parse_widget()
  store ptr %t11, ptr %t10
  call void @fn_skipnl()
  call void @fn_eat_op(ptr @.str192)
  %t12 = load ptr, ptr %t3
  store ptr %t12, ptr %retval
  br label %ret
ret:
  %t13 = load ptr, ptr %retval
  ret ptr %t13
}

define ptr @fn_val(ptr %arg_code, ptr %arg_ty) {
entry:
  %retval = alloca ptr
  %t0 = alloca ptr
  %t1 = alloca ptr
  %t7 = alloca ptr
  store ptr %arg_code, ptr %t0
  store ptr %arg_ty, ptr %t1
  %t2 = getelementptr %Str_Val, ptr null, i32 1
  %t3 = ptrtoint ptr %t2 to i64
  %t4 = call ptr @malloc(i64 %t3)
  %t5 = getelementptr inbounds %Str_Val, ptr %t4, i32 0, i32 0
  store ptr null, ptr %t5
  %t6 = getelementptr inbounds %Str_Val, ptr %t4, i32 0, i32 1
  store ptr null, ptr %t6
  store ptr %t4, ptr %t7
  %t8 = load ptr, ptr %t7
  %t9 = getelementptr inbounds %Str_Val, ptr %t8, i32 0, i32 0
  %t10 = load ptr, ptr %t0
  store ptr %t10, ptr %t9
  %t11 = load ptr, ptr %t7
  %t12 = getelementptr inbounds %Str_Val, ptr %t11, i32 0, i32 1
  %t13 = load ptr, ptr %t1
  store ptr %t13, ptr %t12
  %t14 = load ptr, ptr %t7
  store ptr %t14, ptr %retval
  br label %ret
ret:
  %t15 = load ptr, ptr %retval
  ret ptr %t15
}

define void @fn_emit(ptr %arg_s) {
entry:
  %t0 = alloca ptr
  store ptr %arg_s, ptr %t0
  %t1 = load ptr, ptr @g_code
  %t2 = load ptr, ptr %t0
  call void @fn_buf_puts(ptr %t1, ptr %t2)
  br label %ret
ret:
  ret void
}

define void @fn_emith(ptr %arg_s) {
entry:
  %t0 = alloca ptr
  store ptr %arg_s, ptr %t0
  %t1 = load ptr, ptr @g_head
  %t2 = load ptr, ptr %t0
  call void @fn_buf_puts(ptr %t1, ptr %t2)
  br label %ret
ret:
  ret void
}

define ptr @fn_emit_alloca(ptr %arg_llt) {
entry:
  %retval = alloca ptr
  %t0 = alloca ptr
  %t4 = alloca ptr
  store ptr %arg_llt, ptr %t0
  %t1 = load i32, ptr @g_ll_t
  %t2 = call ptr @fn_itoa(i32 %t1)
  %t3 = call ptr @fn_sconcat(ptr @.str193, ptr %t2)
  store ptr %t3, ptr %t4
  %t5 = load i32, ptr @g_ll_t
  %t6 = add i32 %t5, 1
  store i32 %t6, ptr @g_ll_t
  %t7 = load ptr, ptr @g_falloc
  call void @fn_buf_puts(ptr %t7, ptr @.str194)
  %t8 = load ptr, ptr @g_falloc
  %t9 = load ptr, ptr %t4
  call void @fn_buf_puts(ptr %t8, ptr %t9)
  %t10 = load ptr, ptr @g_falloc
  call void @fn_buf_puts(ptr %t10, ptr @.str195)
  %t11 = load ptr, ptr @g_falloc
  %t12 = load ptr, ptr %t0
  call void @fn_buf_puts(ptr %t11, ptr %t12)
  %t13 = load ptr, ptr @g_falloc
  call void @fn_buf_puts(ptr %t13, ptr @.str196)
  %t14 = load ptr, ptr %t4
  store ptr %t14, ptr %retval
  br label %ret
ret:
  %t15 = load ptr, ptr %retval
  ret ptr %t15
}

define ptr @fn_sconcat(ptr %arg_a, ptr %arg_b) {
entry:
  %retval = alloca ptr
  %t0 = alloca ptr
  %t1 = alloca ptr
  %t4 = alloca i32
  %t7 = alloca i32
  %t14 = alloca ptr
  %t15 = alloca i32
  %t32 = alloca i32
  store ptr %arg_a, ptr %t0
  store ptr %arg_b, ptr %t1
  %t2 = load ptr, ptr %t0
  %t3 = call i32 @fn_slen(ptr %t2)
  store i32 %t3, ptr %t4
  %t5 = load ptr, ptr %t1
  %t6 = call i32 @fn_slen(ptr %t5)
  store i32 %t6, ptr %t7
  %t8 = load i32, ptr %t4
  %t9 = load i32, ptr %t7
  %t10 = add i32 %t8, %t9
  %t11 = add i32 %t10, 1
  %t12 = zext i32 %t11 to i64
  %t13 = call ptr @malloc(i64 %t12)
  store ptr %t13, ptr %t14
  store i32 0, ptr %t15
  br label %wcond0
wcond0:
  %t16 = load i32, ptr %t15
  %t17 = load i32, ptr %t4
  %t18 = icmp slt i32 %t16, %t17
  %t19 = zext i1 %t18 to i32
  %t20 = icmp ne i32 %t19, 0
  br i1 %t20, label %wbody1, label %wend2
wbody1:
  %t21 = load ptr, ptr %t14
  %t22 = load i32, ptr %t15
  %t23 = load ptr, ptr %t0
  %t24 = load i32, ptr %t15
  %t25 = getelementptr inbounds i8, ptr %t23, i32 %t24
  %t26 = load i8, ptr %t25
  %t27 = zext i8 %t26 to i32
  %t28 = getelementptr inbounds i8, ptr %t21, i32 %t22
  %t29 = trunc i32 %t27 to i8
  store i8 %t29, ptr %t28
  %t30 = load i32, ptr %t15
  %t31 = add i32 %t30, 1
  store i32 %t31, ptr %t15
  br label %wcond0
wend2:
  store i32 0, ptr %t32
  br label %wcond3
wcond3:
  %t33 = load i32, ptr %t32
  %t34 = load i32, ptr %t7
  %t35 = icmp slt i32 %t33, %t34
  %t36 = zext i1 %t35 to i32
  %t37 = icmp ne i32 %t36, 0
  br i1 %t37, label %wbody4, label %wend5
wbody4:
  %t38 = load ptr, ptr %t14
  %t39 = load i32, ptr %t4
  %t40 = load i32, ptr %t32
  %t41 = add i32 %t39, %t40
  %t42 = load ptr, ptr %t1
  %t43 = load i32, ptr %t32
  %t44 = getelementptr inbounds i8, ptr %t42, i32 %t43
  %t45 = load i8, ptr %t44
  %t46 = zext i8 %t45 to i32
  %t47 = getelementptr inbounds i8, ptr %t38, i32 %t41
  %t48 = trunc i32 %t46 to i8
  store i8 %t48, ptr %t47
  %t49 = load i32, ptr %t32
  %t50 = add i32 %t49, 1
  store i32 %t50, ptr %t32
  br label %wcond3
wend5:
  %t51 = load ptr, ptr %t14
  %t52 = load i32, ptr %t4
  %t53 = load i32, ptr %t7
  %t54 = add i32 %t52, %t53
  %t55 = getelementptr inbounds i8, ptr %t51, i32 %t54
  %t56 = trunc i32 0 to i8
  store i8 %t56, ptr %t55
  %t57 = load ptr, ptr %t14
  store ptr %t57, ptr %retval
  br label %ret
ret:
  %t58 = load ptr, ptr %retval
  ret ptr %t58
}

define ptr @fn_nreg() {
entry:
  %retval = alloca ptr
  %t3 = alloca ptr
  %t0 = load i32, ptr @g_ll_t
  %t1 = call ptr @fn_itoa(i32 %t0)
  %t2 = call ptr @fn_sconcat(ptr @.str197, ptr %t1)
  store ptr %t2, ptr %t3
  %t4 = load i32, ptr @g_ll_t
  %t5 = add i32 %t4, 1
  store i32 %t5, ptr @g_ll_t
  %t6 = load ptr, ptr %t3
  store ptr %t6, ptr %retval
  br label %ret
ret:
  %t7 = load ptr, ptr %retval
  ret ptr %t7
}

define ptr @fn_lbl(ptr %arg_pfx) {
entry:
  %retval = alloca ptr
  %t0 = alloca ptr
  %t5 = alloca ptr
  store ptr %arg_pfx, ptr %t0
  %t1 = load ptr, ptr %t0
  %t2 = load i32, ptr @g_ll_lbl
  %t3 = call ptr @fn_itoa(i32 %t2)
  %t4 = call ptr @fn_sconcat(ptr %t1, ptr %t3)
  store ptr %t4, ptr %t5
  %t6 = load i32, ptr @g_ll_lbl
  %t7 = add i32 %t6, 1
  store i32 %t7, ptr @g_ll_lbl
  %t8 = load ptr, ptr %t5
  store ptr %t8, ptr %retval
  br label %ret
ret:
  %t9 = load ptr, ptr %retval
  ret ptr %t9
}

define ptr @fn_llty(ptr %arg_t) {
entry:
  %retval = alloca ptr
  %t0 = alloca ptr
  %t1 = alloca i32
  %t2 = alloca i32
  store ptr %arg_t, ptr %t0
  %t3 = load ptr, ptr %t0
  %t4 = call i32 @fn_streq(ptr %t3, ptr @.str198)
  %t5 = icmp ne i32 %t4, 0
  %t6 = zext i1 %t5 to i32
  store i32 %t6, ptr %t2
  br i1 %t5, label %scend1, label %sc0
sc0:
  %t7 = load ptr, ptr %t0
  %t8 = call i32 @fn_streq(ptr %t7, ptr @.str199)
  %t9 = icmp ne i32 %t8, 0
  %t10 = zext i1 %t9 to i32
  store i32 %t10, ptr %t2
  br label %scend1
scend1:
  %t11 = load i32, ptr %t2
  %t12 = icmp ne i32 %t11, 0
  %t13 = zext i1 %t12 to i32
  store i32 %t13, ptr %t1
  br i1 %t12, label %scend3, label %sc2
sc2:
  %t14 = load ptr, ptr %t0
  %t15 = call i32 @fn_streq(ptr %t14, ptr @.str200)
  %t16 = icmp ne i32 %t15, 0
  %t17 = zext i1 %t16 to i32
  store i32 %t17, ptr %t1
  br label %scend3
scend3:
  %t18 = load i32, ptr %t1
  %t19 = icmp ne i32 %t18, 0
  br i1 %t19, label %then4, label %ifend6
then4:
  store ptr @.str201, ptr %retval
  br label %ret
ifend6:
  %t20 = load ptr, ptr %t0
  %t21 = call i32 @fn_streq(ptr %t20, ptr @.str202)
  %t22 = icmp ne i32 %t21, 0
  br i1 %t22, label %then7, label %ifend9
then7:
  store ptr @.str203, ptr %retval
  br label %ret
ifend9:
  store ptr @.str204, ptr %retval
  br label %ret
ret:
  %t23 = load ptr, ptr %retval
  ret ptr %t23
}

define i32 @fn_is_slice_ty(ptr %arg_t) {
entry:
  %retval = alloca i32
  %t0 = alloca ptr
  %t1 = alloca i32
  store ptr %arg_t, ptr %t0
  %t2 = load ptr, ptr %t0
  %t3 = getelementptr inbounds i8, ptr %t2, i32 0
  %t4 = load i8, ptr %t3
  %t5 = zext i8 %t4 to i32
  %t6 = icmp eq i32 %t5, 91
  %t7 = zext i1 %t6 to i32
  %t8 = icmp ne i32 %t7, 0
  %t9 = zext i1 %t8 to i32
  store i32 %t9, ptr %t1
  br i1 %t8, label %sc0, label %scend1
sc0:
  %t10 = load ptr, ptr %t0
  %t11 = getelementptr inbounds i8, ptr %t10, i32 1
  %t12 = load i8, ptr %t11
  %t13 = zext i8 %t12 to i32
  %t14 = icmp eq i32 %t13, 93
  %t15 = zext i1 %t14 to i32
  %t16 = icmp ne i32 %t15, 0
  %t17 = zext i1 %t16 to i32
  store i32 %t17, ptr %t1
  br label %scend1
scend1:
  %t18 = load i32, ptr %t1
  store i32 %t18, ptr %retval
  br label %ret
ret:
  %t19 = load i32, ptr %retval
  ret i32 %t19
}

define ptr @fn_slice_elem(ptr %arg_t) {
entry:
  %retval = alloca ptr
  %t0 = alloca ptr
  store ptr %arg_t, ptr %t0
  %t1 = load ptr, ptr %t0
  %t2 = load ptr, ptr %t0
  %t3 = call i32 @fn_slen(ptr %t2)
  %t4 = sub i32 %t3, 2
  %t5 = call ptr @fn_substr(ptr %t1, i32 2, i32 %t4)
  store ptr %t5, ptr %retval
  br label %ret
ret:
  %t6 = load ptr, ptr %retval
  ret ptr %t6
}

define ptr @fn_find_struct(ptr %arg_name) {
entry:
  %retval = alloca ptr
  %t0 = alloca ptr
  %t1 = alloca i32
  %t15 = alloca ptr
  %t16 = alloca i32
  store ptr %arg_name, ptr %t0
  store i32 0, ptr %t1
  br label %wcond0
wcond0:
  %t2 = load i32, ptr %t1
  %t3 = load ptr, ptr @g_prog
  %t4 = getelementptr inbounds %LSlice, ptr %t3, i32 0, i32 1
  %t5 = load i32, ptr %t4
  %t6 = icmp slt i32 %t2, %t5
  %t7 = zext i1 %t6 to i32
  %t8 = icmp ne i32 %t7, 0
  br i1 %t8, label %wbody1, label %wend2
wbody1:
  %t9 = load ptr, ptr @g_prog
  %t10 = getelementptr inbounds %LSlice, ptr %t9, i32 0, i32 0
  %t11 = load ptr, ptr %t10
  %t12 = load i32, ptr %t1
  %t13 = getelementptr inbounds ptr, ptr %t11, i32 %t12
  %t14 = load ptr, ptr %t13
  store ptr %t14, ptr %t15
  %t17 = load ptr, ptr %t15
  %t18 = getelementptr inbounds %Str_Node, ptr %t17, i32 0, i32 0
  %t19 = load i32, ptr %t18
  %t20 = icmp eq i32 %t19, 0
  %t21 = zext i1 %t20 to i32
  %t22 = icmp ne i32 %t21, 0
  %t23 = zext i1 %t22 to i32
  store i32 %t23, ptr %t16
  br i1 %t22, label %sc3, label %scend4
sc3:
  %t24 = load ptr, ptr %t15
  %t25 = getelementptr inbounds %Str_Node, ptr %t24, i32 0, i32 1
  %t26 = load ptr, ptr %t25
  %t27 = load ptr, ptr %t0
  %t28 = call i32 @fn_streq(ptr %t26, ptr %t27)
  %t29 = icmp ne i32 %t28, 0
  %t30 = zext i1 %t29 to i32
  store i32 %t30, ptr %t16
  br label %scend4
scend4:
  %t31 = load i32, ptr %t16
  %t32 = icmp ne i32 %t31, 0
  br i1 %t32, label %then5, label %ifend7
then5:
  %t33 = load ptr, ptr %t15
  store ptr %t33, ptr %retval
  br label %ret
ifend7:
  %t34 = load i32, ptr %t1
  %t35 = add i32 %t34, 1
  store i32 %t35, ptr %t1
  br label %wcond0
wend2:
  store ptr null, ptr %retval
  br label %ret
ret:
  %t36 = load ptr, ptr %retval
  ret ptr %t36
}

define i32 @fn_is_struct_ty(ptr %arg_t) {
entry:
  %retval = alloca i32
  %t0 = alloca ptr
  store ptr %arg_t, ptr %t0
  %t1 = load ptr, ptr %t0
  %t2 = call ptr @fn_find_struct(ptr %t1)
  %t3 = icmp eq ptr %t2, null
  %t4 = zext i1 %t3 to i32
  %t5 = icmp eq i32 %t4, 0
  %t6 = zext i1 %t5 to i32
  store i32 %t6, ptr %retval
  br label %ret
ret:
  %t7 = load i32, ptr %retval
  ret i32 %t7
}

define ptr @fn_find_arch(ptr %arg_name) {
entry:
  %retval = alloca ptr
  %t0 = alloca ptr
  %t1 = alloca i32
  %t15 = alloca ptr
  %t16 = alloca i32
  store ptr %arg_name, ptr %t0
  store i32 0, ptr %t1
  br label %wcond0
wcond0:
  %t2 = load i32, ptr %t1
  %t3 = load ptr, ptr @g_prog
  %t4 = getelementptr inbounds %LSlice, ptr %t3, i32 0, i32 1
  %t5 = load i32, ptr %t4
  %t6 = icmp slt i32 %t2, %t5
  %t7 = zext i1 %t6 to i32
  %t8 = icmp ne i32 %t7, 0
  br i1 %t8, label %wbody1, label %wend2
wbody1:
  %t9 = load ptr, ptr @g_prog
  %t10 = getelementptr inbounds %LSlice, ptr %t9, i32 0, i32 0
  %t11 = load ptr, ptr %t10
  %t12 = load i32, ptr %t1
  %t13 = getelementptr inbounds ptr, ptr %t11, i32 %t12
  %t14 = load ptr, ptr %t13
  store ptr %t14, ptr %t15
  %t17 = load ptr, ptr %t15
  %t18 = getelementptr inbounds %Str_Node, ptr %t17, i32 0, i32 0
  %t19 = load i32, ptr %t18
  %t20 = icmp eq i32 %t19, 10
  %t21 = zext i1 %t20 to i32
  %t22 = icmp ne i32 %t21, 0
  %t23 = zext i1 %t22 to i32
  store i32 %t23, ptr %t16
  br i1 %t22, label %sc3, label %scend4
sc3:
  %t24 = load ptr, ptr %t15
  %t25 = getelementptr inbounds %Str_Node, ptr %t24, i32 0, i32 1
  %t26 = load ptr, ptr %t25
  %t27 = load ptr, ptr %t0
  %t28 = call i32 @fn_streq(ptr %t26, ptr %t27)
  %t29 = icmp ne i32 %t28, 0
  %t30 = zext i1 %t29 to i32
  store i32 %t30, ptr %t16
  br label %scend4
scend4:
  %t31 = load i32, ptr %t16
  %t32 = icmp ne i32 %t31, 0
  br i1 %t32, label %then5, label %ifend7
then5:
  %t33 = load ptr, ptr %t15
  store ptr %t33, ptr %retval
  br label %ret
ifend7:
  %t34 = load i32, ptr %t1
  %t35 = add i32 %t34, 1
  store i32 %t35, ptr %t1
  br label %wcond0
wend2:
  store ptr null, ptr %retval
  br label %ret
ret:
  %t36 = load ptr, ptr %retval
  ret ptr %t36
}

define ptr @fn_find_comp(ptr %arg_name) {
entry:
  %retval = alloca ptr
  %t0 = alloca ptr
  %t1 = alloca i32
  %t15 = alloca ptr
  %t16 = alloca i32
  store ptr %arg_name, ptr %t0
  store i32 0, ptr %t1
  br label %wcond0
wcond0:
  %t2 = load i32, ptr %t1
  %t3 = load ptr, ptr @g_prog
  %t4 = getelementptr inbounds %LSlice, ptr %t3, i32 0, i32 1
  %t5 = load i32, ptr %t4
  %t6 = icmp slt i32 %t2, %t5
  %t7 = zext i1 %t6 to i32
  %t8 = icmp ne i32 %t7, 0
  br i1 %t8, label %wbody1, label %wend2
wbody1:
  %t9 = load ptr, ptr @g_prog
  %t10 = getelementptr inbounds %LSlice, ptr %t9, i32 0, i32 0
  %t11 = load ptr, ptr %t10
  %t12 = load i32, ptr %t1
  %t13 = getelementptr inbounds ptr, ptr %t11, i32 %t12
  %t14 = load ptr, ptr %t13
  store ptr %t14, ptr %t15
  %t17 = load ptr, ptr %t15
  %t18 = getelementptr inbounds %Str_Node, ptr %t17, i32 0, i32 0
  %t19 = load i32, ptr %t18
  %t20 = icmp eq i32 %t19, 8
  %t21 = zext i1 %t20 to i32
  %t22 = icmp ne i32 %t21, 0
  %t23 = zext i1 %t22 to i32
  store i32 %t23, ptr %t16
  br i1 %t22, label %sc3, label %scend4
sc3:
  %t24 = load ptr, ptr %t15
  %t25 = getelementptr inbounds %Str_Node, ptr %t24, i32 0, i32 1
  %t26 = load ptr, ptr %t25
  %t27 = load ptr, ptr %t0
  %t28 = call i32 @fn_streq(ptr %t26, ptr %t27)
  %t29 = icmp ne i32 %t28, 0
  %t30 = zext i1 %t29 to i32
  store i32 %t30, ptr %t16
  br label %scend4
scend4:
  %t31 = load i32, ptr %t16
  %t32 = icmp ne i32 %t31, 0
  br i1 %t32, label %then5, label %ifend7
then5:
  %t33 = load ptr, ptr %t15
  store ptr %t33, ptr %retval
  br label %ret
ifend7:
  %t34 = load i32, ptr %t1
  %t35 = add i32 %t34, 1
  store i32 %t35, ptr %t1
  br label %wcond0
wend2:
  store ptr null, ptr %retval
  br label %ret
ret:
  %t36 = load ptr, ptr %retval
  ret ptr %t36
}

define ptr @fn_layout_node(ptr %arg_name) {
entry:
  %retval = alloca ptr
  %t0 = alloca ptr
  %t3 = alloca ptr
  store ptr %arg_name, ptr %t0
  %t1 = load ptr, ptr %t0
  %t2 = call ptr @fn_find_struct(ptr %t1)
  store ptr %t2, ptr %t3
  %t4 = load ptr, ptr %t3
  %t5 = icmp eq ptr %t4, null
  %t6 = zext i1 %t5 to i32
  %t7 = icmp eq i32 %t6, 0
  %t8 = zext i1 %t7 to i32
  %t9 = icmp ne i32 %t8, 0
  br i1 %t9, label %then0, label %ifend2
then0:
  %t10 = load ptr, ptr %t3
  store ptr %t10, ptr %retval
  br label %ret
ifend2:
  %t11 = load ptr, ptr %t0
  %t12 = call ptr @fn_find_comp(ptr %t11)
  store ptr %t12, ptr %retval
  br label %ret
ret:
  %t13 = load ptr, ptr %retval
  ret ptr %t13
}

define ptr @fn_layout_ty(ptr %arg_name) {
entry:
  %retval = alloca ptr
  %t0 = alloca ptr
  store ptr %arg_name, ptr %t0
  %t1 = load ptr, ptr %t0
  %t2 = call ptr @fn_find_struct(ptr %t1)
  %t3 = icmp eq ptr %t2, null
  %t4 = zext i1 %t3 to i32
  %t5 = icmp eq i32 %t4, 0
  %t6 = zext i1 %t5 to i32
  %t7 = icmp ne i32 %t6, 0
  br i1 %t7, label %then0, label %ifend2
then0:
  %t8 = load ptr, ptr %t0
  %t9 = call ptr @fn_sconcat(ptr @.str205, ptr %t8)
  store ptr %t9, ptr %retval
  br label %ret
ifend2:
  %t10 = load ptr, ptr %t0
  %t11 = call ptr @fn_sconcat(ptr @.str206, ptr %t10)
  store ptr %t11, ptr %retval
  br label %ret
ret:
  %t12 = load ptr, ptr %retval
  ret ptr %t12
}

define i32 @fn_field_index(ptr %arg_s, ptr %arg_fname) {
entry:
  %retval = alloca i32
  %t0 = alloca ptr
  %t1 = alloca ptr
  %t2 = alloca i32
  store ptr %arg_s, ptr %t0
  store ptr %arg_fname, ptr %t1
  store i32 0, ptr %t2
  br label %wcond0
wcond0:
  %t3 = load i32, ptr %t2
  %t4 = load ptr, ptr %t0
  %t5 = getelementptr inbounds %Str_Node, ptr %t4, i32 0, i32 7
  %t6 = load ptr, ptr %t5
  %t7 = getelementptr inbounds %LSlice, ptr %t6, i32 0, i32 1
  %t8 = load i32, ptr %t7
  %t9 = icmp slt i32 %t3, %t8
  %t10 = zext i1 %t9 to i32
  %t11 = icmp ne i32 %t10, 0
  br i1 %t11, label %wbody1, label %wend2
wbody1:
  %t12 = load ptr, ptr %t0
  %t13 = getelementptr inbounds %Str_Node, ptr %t12, i32 0, i32 7
  %t14 = load ptr, ptr %t13
  %t15 = getelementptr inbounds %LSlice, ptr %t14, i32 0, i32 0
  %t16 = load ptr, ptr %t15
  %t17 = load i32, ptr %t2
  %t18 = getelementptr inbounds ptr, ptr %t16, i32 %t17
  %t19 = load ptr, ptr %t18
  %t20 = getelementptr inbounds %Str_Node, ptr %t19, i32 0, i32 1
  %t21 = load ptr, ptr %t20
  %t22 = load ptr, ptr %t1
  %t23 = call i32 @fn_streq(ptr %t21, ptr %t22)
  %t24 = icmp ne i32 %t23, 0
  br i1 %t24, label %then3, label %ifend5
then3:
  %t25 = load i32, ptr %t2
  store i32 %t25, ptr %retval
  br label %ret
ifend5:
  %t26 = load i32, ptr %t2
  %t27 = add i32 %t26, 1
  store i32 %t27, ptr %t2
  br label %wcond0
wend2:
  %t28 = sub i32 0, 1
  store i32 %t28, ptr %retval
  br label %ret
ret:
  %t29 = load i32, ptr %retval
  ret i32 %t29
}

define ptr @fn_field_type(ptr %arg_s, ptr %arg_fname) {
entry:
  %retval = alloca ptr
  %t0 = alloca ptr
  %t1 = alloca ptr
  %t2 = alloca i32
  store ptr %arg_s, ptr %t0
  store ptr %arg_fname, ptr %t1
  store i32 0, ptr %t2
  br label %wcond0
wcond0:
  %t3 = load i32, ptr %t2
  %t4 = load ptr, ptr %t0
  %t5 = getelementptr inbounds %Str_Node, ptr %t4, i32 0, i32 7
  %t6 = load ptr, ptr %t5
  %t7 = getelementptr inbounds %LSlice, ptr %t6, i32 0, i32 1
  %t8 = load i32, ptr %t7
  %t9 = icmp slt i32 %t3, %t8
  %t10 = zext i1 %t9 to i32
  %t11 = icmp ne i32 %t10, 0
  br i1 %t11, label %wbody1, label %wend2
wbody1:
  %t12 = load ptr, ptr %t0
  %t13 = getelementptr inbounds %Str_Node, ptr %t12, i32 0, i32 7
  %t14 = load ptr, ptr %t13
  %t15 = getelementptr inbounds %LSlice, ptr %t14, i32 0, i32 0
  %t16 = load ptr, ptr %t15
  %t17 = load i32, ptr %t2
  %t18 = getelementptr inbounds ptr, ptr %t16, i32 %t17
  %t19 = load ptr, ptr %t18
  %t20 = getelementptr inbounds %Str_Node, ptr %t19, i32 0, i32 1
  %t21 = load ptr, ptr %t20
  %t22 = load ptr, ptr %t1
  %t23 = call i32 @fn_streq(ptr %t21, ptr %t22)
  %t24 = icmp ne i32 %t23, 0
  br i1 %t24, label %then3, label %ifend5
then3:
  %t25 = load ptr, ptr %t0
  %t26 = getelementptr inbounds %Str_Node, ptr %t25, i32 0, i32 7
  %t27 = load ptr, ptr %t26
  %t28 = getelementptr inbounds %LSlice, ptr %t27, i32 0, i32 0
  %t29 = load ptr, ptr %t28
  %t30 = load i32, ptr %t2
  %t31 = getelementptr inbounds ptr, ptr %t29, i32 %t30
  %t32 = load ptr, ptr %t31
  %t33 = getelementptr inbounds %Str_Node, ptr %t32, i32 0, i32 3
  %t34 = load ptr, ptr %t33
  store ptr %t34, ptr %retval
  br label %ret
ifend5:
  %t35 = load i32, ptr %t2
  %t36 = add i32 %t35, 1
  store i32 %t36, ptr %t2
  br label %wcond0
wend2:
  store ptr @.str207, ptr %retval
  br label %ret
ret:
  %t37 = load ptr, ptr %retval
  ret ptr %t37
}

define ptr @fn_find_global(ptr %arg_name) {
entry:
  %retval = alloca ptr
  %t0 = alloca ptr
  %t1 = alloca i32
  %t15 = alloca ptr
  %t16 = alloca i32
  %t34 = alloca i32
  store ptr %arg_name, ptr %t0
  store i32 0, ptr %t1
  br label %wcond0
wcond0:
  %t2 = load i32, ptr %t1
  %t3 = load ptr, ptr @g_prog
  %t4 = getelementptr inbounds %LSlice, ptr %t3, i32 0, i32 1
  %t5 = load i32, ptr %t4
  %t6 = icmp slt i32 %t2, %t5
  %t7 = zext i1 %t6 to i32
  %t8 = icmp ne i32 %t7, 0
  br i1 %t8, label %wbody1, label %wend2
wbody1:
  %t9 = load ptr, ptr @g_prog
  %t10 = getelementptr inbounds %LSlice, ptr %t9, i32 0, i32 0
  %t11 = load ptr, ptr %t10
  %t12 = load i32, ptr %t1
  %t13 = getelementptr inbounds ptr, ptr %t11, i32 %t12
  %t14 = load ptr, ptr %t13
  store ptr %t14, ptr %t15
  %t17 = load ptr, ptr %t15
  %t18 = getelementptr inbounds %Str_Node, ptr %t17, i32 0, i32 0
  %t19 = load i32, ptr %t18
  %t20 = icmp eq i32 %t19, 2
  %t21 = zext i1 %t20 to i32
  %t22 = icmp ne i32 %t21, 0
  %t23 = zext i1 %t22 to i32
  store i32 %t23, ptr %t16
  br i1 %t22, label %sc3, label %scend4
sc3:
  %t24 = load ptr, ptr %t15
  %t25 = getelementptr inbounds %Str_Node, ptr %t24, i32 0, i32 1
  %t26 = load ptr, ptr %t25
  %t27 = load ptr, ptr %t0
  %t28 = call i32 @fn_streq(ptr %t26, ptr %t27)
  %t29 = icmp ne i32 %t28, 0
  %t30 = zext i1 %t29 to i32
  store i32 %t30, ptr %t16
  br label %scend4
scend4:
  %t31 = load i32, ptr %t16
  %t32 = icmp ne i32 %t31, 0
  br i1 %t32, label %then5, label %ifend7
then5:
  %t33 = load ptr, ptr %t15
  store ptr %t33, ptr %retval
  br label %ret
ifend7:
  %t35 = load ptr, ptr %t15
  %t36 = getelementptr inbounds %Str_Node, ptr %t35, i32 0, i32 0
  %t37 = load i32, ptr %t36
  %t38 = icmp eq i32 %t37, 3
  %t39 = zext i1 %t38 to i32
  %t40 = icmp ne i32 %t39, 0
  %t41 = zext i1 %t40 to i32
  store i32 %t41, ptr %t34
  br i1 %t40, label %sc8, label %scend9
sc8:
  %t42 = load ptr, ptr %t15
  %t43 = getelementptr inbounds %Str_Node, ptr %t42, i32 0, i32 1
  %t44 = load ptr, ptr %t43
  %t45 = load ptr, ptr %t0
  %t46 = call i32 @fn_streq(ptr %t44, ptr %t45)
  %t47 = icmp ne i32 %t46, 0
  %t48 = zext i1 %t47 to i32
  store i32 %t48, ptr %t34
  br label %scend9
scend9:
  %t49 = load i32, ptr %t34
  %t50 = icmp ne i32 %t49, 0
  br i1 %t50, label %then10, label %ifend12
then10:
  %t51 = load ptr, ptr %t15
  store ptr %t51, ptr %retval
  br label %ret
ifend12:
  %t52 = load i32, ptr %t1
  %t53 = add i32 %t52, 1
  store i32 %t53, ptr %t1
  br label %wcond0
wend2:
  store ptr null, ptr %retval
  br label %ret
ret:
  %t54 = load ptr, ptr %retval
  ret ptr %t54
}

define i32 @fn_enum_ordinal(ptr %arg_ename, ptr %arg_vname) {
entry:
  %retval = alloca i32
  %t0 = alloca ptr
  %t1 = alloca ptr
  %t2 = alloca i32
  %t16 = alloca ptr
  %t17 = alloca i32
  %t34 = alloca i32
  store ptr %arg_ename, ptr %t0
  store ptr %arg_vname, ptr %t1
  store i32 0, ptr %t2
  br label %wcond0
wcond0:
  %t3 = load i32, ptr %t2
  %t4 = load ptr, ptr @g_prog
  %t5 = getelementptr inbounds %LSlice, ptr %t4, i32 0, i32 1
  %t6 = load i32, ptr %t5
  %t7 = icmp slt i32 %t3, %t6
  %t8 = zext i1 %t7 to i32
  %t9 = icmp ne i32 %t8, 0
  br i1 %t9, label %wbody1, label %wend2
wbody1:
  %t10 = load ptr, ptr @g_prog
  %t11 = getelementptr inbounds %LSlice, ptr %t10, i32 0, i32 0
  %t12 = load ptr, ptr %t11
  %t13 = load i32, ptr %t2
  %t14 = getelementptr inbounds ptr, ptr %t12, i32 %t13
  %t15 = load ptr, ptr %t14
  store ptr %t15, ptr %t16
  %t18 = load ptr, ptr %t16
  %t19 = getelementptr inbounds %Str_Node, ptr %t18, i32 0, i32 0
  %t20 = load i32, ptr %t19
  %t21 = icmp eq i32 %t20, 27
  %t22 = zext i1 %t21 to i32
  %t23 = icmp ne i32 %t22, 0
  %t24 = zext i1 %t23 to i32
  store i32 %t24, ptr %t17
  br i1 %t23, label %sc3, label %scend4
sc3:
  %t25 = load ptr, ptr %t16
  %t26 = getelementptr inbounds %Str_Node, ptr %t25, i32 0, i32 1
  %t27 = load ptr, ptr %t26
  %t28 = load ptr, ptr %t0
  %t29 = call i32 @fn_streq(ptr %t27, ptr %t28)
  %t30 = icmp ne i32 %t29, 0
  %t31 = zext i1 %t30 to i32
  store i32 %t31, ptr %t17
  br label %scend4
scend4:
  %t32 = load i32, ptr %t17
  %t33 = icmp ne i32 %t32, 0
  br i1 %t33, label %then5, label %ifend7
then5:
  store i32 0, ptr %t34
  br label %wcond8
wcond8:
  %t35 = load i32, ptr %t34
  %t36 = load ptr, ptr %t16
  %t37 = getelementptr inbounds %Str_Node, ptr %t36, i32 0, i32 7
  %t38 = load ptr, ptr %t37
  %t39 = getelementptr inbounds %LSlice, ptr %t38, i32 0, i32 1
  %t40 = load i32, ptr %t39
  %t41 = icmp slt i32 %t35, %t40
  %t42 = zext i1 %t41 to i32
  %t43 = icmp ne i32 %t42, 0
  br i1 %t43, label %wbody9, label %wend10
wbody9:
  %t44 = load ptr, ptr %t16
  %t45 = getelementptr inbounds %Str_Node, ptr %t44, i32 0, i32 7
  %t46 = load ptr, ptr %t45
  %t47 = getelementptr inbounds %LSlice, ptr %t46, i32 0, i32 0
  %t48 = load ptr, ptr %t47
  %t49 = load i32, ptr %t34
  %t50 = getelementptr inbounds ptr, ptr %t48, i32 %t49
  %t51 = load ptr, ptr %t50
  %t52 = getelementptr inbounds %Str_Node, ptr %t51, i32 0, i32 1
  %t53 = load ptr, ptr %t52
  %t54 = load ptr, ptr %t1
  %t55 = call i32 @fn_streq(ptr %t53, ptr %t54)
  %t56 = icmp ne i32 %t55, 0
  br i1 %t56, label %then11, label %ifend13
then11:
  %t57 = load i32, ptr %t34
  store i32 %t57, ptr %retval
  br label %ret
ifend13:
  %t58 = load i32, ptr %t34
  %t59 = add i32 %t58, 1
  store i32 %t59, ptr %t34
  br label %wcond8
wend10:
  br label %ifend7
ifend7:
  %t60 = load i32, ptr %t2
  %t61 = add i32 %t60, 1
  store i32 %t61, ptr %t2
  br label %wcond0
wend2:
  %t62 = sub i32 0, 1
  store i32 %t62, ptr %retval
  br label %ret
ret:
  %t63 = load i32, ptr %retval
  ret i32 %t63
}

define ptr @fn_find_fn(ptr %arg_name) {
entry:
  %retval = alloca ptr
  %t0 = alloca ptr
  %t1 = alloca i32
  %t15 = alloca ptr
  %t16 = alloca i32
  store ptr %arg_name, ptr %t0
  store i32 0, ptr %t1
  br label %wcond0
wcond0:
  %t2 = load i32, ptr %t1
  %t3 = load ptr, ptr @g_prog
  %t4 = getelementptr inbounds %LSlice, ptr %t3, i32 0, i32 1
  %t5 = load i32, ptr %t4
  %t6 = icmp slt i32 %t2, %t5
  %t7 = zext i1 %t6 to i32
  %t8 = icmp ne i32 %t7, 0
  br i1 %t8, label %wbody1, label %wend2
wbody1:
  %t9 = load ptr, ptr @g_prog
  %t10 = getelementptr inbounds %LSlice, ptr %t9, i32 0, i32 0
  %t11 = load ptr, ptr %t10
  %t12 = load i32, ptr %t1
  %t13 = getelementptr inbounds ptr, ptr %t11, i32 %t12
  %t14 = load ptr, ptr %t13
  store ptr %t14, ptr %t15
  %t17 = load ptr, ptr %t15
  %t18 = getelementptr inbounds %Str_Node, ptr %t17, i32 0, i32 0
  %t19 = load i32, ptr %t18
  %t20 = icmp eq i32 %t19, 4
  %t21 = zext i1 %t20 to i32
  %t22 = icmp ne i32 %t21, 0
  %t23 = zext i1 %t22 to i32
  store i32 %t23, ptr %t16
  br i1 %t22, label %sc3, label %scend4
sc3:
  %t24 = load ptr, ptr %t15
  %t25 = getelementptr inbounds %Str_Node, ptr %t24, i32 0, i32 1
  %t26 = load ptr, ptr %t25
  %t27 = load ptr, ptr %t0
  %t28 = call i32 @fn_streq(ptr %t26, ptr %t27)
  %t29 = icmp ne i32 %t28, 0
  %t30 = zext i1 %t29 to i32
  store i32 %t30, ptr %t16
  br label %scend4
scend4:
  %t31 = load i32, ptr %t16
  %t32 = icmp ne i32 %t31, 0
  br i1 %t32, label %then5, label %ifend7
then5:
  %t33 = load ptr, ptr %t15
  store ptr %t33, ptr %retval
  br label %ret
ifend7:
  %t34 = load i32, ptr %t1
  %t35 = add i32 %t34, 1
  store i32 %t35, ptr %t1
  br label %wcond0
wend2:
  store ptr null, ptr %retval
  br label %ret
ret:
  %t36 = load ptr, ptr %retval
  ret ptr %t36
}

define void @fn_loc_reset() {
entry:
  store i32 0, ptr @g_nloc
  br label %ret
ret:
  ret void
}

define void @fn_loc_push(ptr %arg_name, ptr %arg_r, ptr %arg_ty) {
entry:
  %t0 = alloca ptr
  %t1 = alloca ptr
  %t2 = alloca ptr
  store ptr %arg_name, ptr %t0
  store ptr %arg_r, ptr %t1
  store ptr %arg_ty, ptr %t2
  %t3 = load i32, ptr @g_nloc
  %t4 = load ptr, ptr @g_loc_name
  %t5 = getelementptr inbounds %LSlice, ptr %t4, i32 0, i32 1
  %t6 = load i32, ptr %t5
  %t7 = icmp slt i32 %t3, %t6
  %t8 = zext i1 %t7 to i32
  %t9 = icmp ne i32 %t8, 0
  br i1 %t9, label %then0, label %else1
then0:
  %t10 = load ptr, ptr @g_loc_name
  %t11 = getelementptr inbounds %LSlice, ptr %t10, i32 0, i32 0
  %t12 = load ptr, ptr %t11
  %t13 = load i32, ptr @g_nloc
  %t14 = getelementptr inbounds ptr, ptr %t12, i32 %t13
  %t15 = load ptr, ptr %t0
  store ptr %t15, ptr %t14
  %t16 = load ptr, ptr @g_loc_reg
  %t17 = getelementptr inbounds %LSlice, ptr %t16, i32 0, i32 0
  %t18 = load ptr, ptr %t17
  %t19 = load i32, ptr @g_nloc
  %t20 = getelementptr inbounds ptr, ptr %t18, i32 %t19
  %t21 = load ptr, ptr %t1
  store ptr %t21, ptr %t20
  %t22 = load ptr, ptr @g_loc_ty
  %t23 = getelementptr inbounds %LSlice, ptr %t22, i32 0, i32 0
  %t24 = load ptr, ptr %t23
  %t25 = load i32, ptr @g_nloc
  %t26 = getelementptr inbounds ptr, ptr %t24, i32 %t25
  %t27 = load ptr, ptr %t2
  store ptr %t27, ptr %t26
  br label %ifend2
else1:
  %t28 = load ptr, ptr @g_loc_name
  %t29 = getelementptr inbounds %LSlice, ptr %t28, i32 0, i32 1
  %t30 = getelementptr inbounds %LSlice, ptr %t28, i32 0, i32 2
  %t31 = getelementptr inbounds %LSlice, ptr %t28, i32 0, i32 0
  %t32 = load i32, ptr %t29
  %t33 = load i32, ptr %t30
  %t34 = icmp sge i32 %t32, %t33
  br i1 %t34, label %grow3, label %put4
grow3:
  %t35 = mul i32 %t33, 2
  %t36 = icmp eq i32 %t33, 0
  %t37 = select i1 %t36, i32 8, i32 %t35
  %t38 = getelementptr ptr, ptr null, i32 1
  %t39 = ptrtoint ptr %t38 to i64
  %t40 = zext i32 %t37 to i64
  %t41 = mul i64 %t40, %t39
  %t42 = load ptr, ptr %t31
  %t43 = call ptr @realloc(ptr %t42, i64 %t41)
  store ptr %t43, ptr %t31
  store i32 %t37, ptr %t30
  br label %put4
put4:
  %t44 = load ptr, ptr %t0
  %t45 = load ptr, ptr %t31
  %t46 = getelementptr inbounds ptr, ptr %t45, i32 %t32
  store ptr %t44, ptr %t46
  %t47 = add i32 %t32, 1
  store i32 %t47, ptr %t29
  %t48 = load ptr, ptr @g_loc_reg
  %t49 = getelementptr inbounds %LSlice, ptr %t48, i32 0, i32 1
  %t50 = getelementptr inbounds %LSlice, ptr %t48, i32 0, i32 2
  %t51 = getelementptr inbounds %LSlice, ptr %t48, i32 0, i32 0
  %t52 = load i32, ptr %t49
  %t53 = load i32, ptr %t50
  %t54 = icmp sge i32 %t52, %t53
  br i1 %t54, label %grow5, label %put6
grow5:
  %t55 = mul i32 %t53, 2
  %t56 = icmp eq i32 %t53, 0
  %t57 = select i1 %t56, i32 8, i32 %t55
  %t58 = getelementptr ptr, ptr null, i32 1
  %t59 = ptrtoint ptr %t58 to i64
  %t60 = zext i32 %t57 to i64
  %t61 = mul i64 %t60, %t59
  %t62 = load ptr, ptr %t51
  %t63 = call ptr @realloc(ptr %t62, i64 %t61)
  store ptr %t63, ptr %t51
  store i32 %t57, ptr %t50
  br label %put6
put6:
  %t64 = load ptr, ptr %t1
  %t65 = load ptr, ptr %t51
  %t66 = getelementptr inbounds ptr, ptr %t65, i32 %t52
  store ptr %t64, ptr %t66
  %t67 = add i32 %t52, 1
  store i32 %t67, ptr %t49
  %t68 = load ptr, ptr @g_loc_ty
  %t69 = getelementptr inbounds %LSlice, ptr %t68, i32 0, i32 1
  %t70 = getelementptr inbounds %LSlice, ptr %t68, i32 0, i32 2
  %t71 = getelementptr inbounds %LSlice, ptr %t68, i32 0, i32 0
  %t72 = load i32, ptr %t69
  %t73 = load i32, ptr %t70
  %t74 = icmp sge i32 %t72, %t73
  br i1 %t74, label %grow7, label %put8
grow7:
  %t75 = mul i32 %t73, 2
  %t76 = icmp eq i32 %t73, 0
  %t77 = select i1 %t76, i32 8, i32 %t75
  %t78 = getelementptr ptr, ptr null, i32 1
  %t79 = ptrtoint ptr %t78 to i64
  %t80 = zext i32 %t77 to i64
  %t81 = mul i64 %t80, %t79
  %t82 = load ptr, ptr %t71
  %t83 = call ptr @realloc(ptr %t82, i64 %t81)
  store ptr %t83, ptr %t71
  store i32 %t77, ptr %t70
  br label %put8
put8:
  %t84 = load ptr, ptr %t2
  %t85 = load ptr, ptr %t71
  %t86 = getelementptr inbounds ptr, ptr %t85, i32 %t72
  store ptr %t84, ptr %t86
  %t87 = add i32 %t72, 1
  store i32 %t87, ptr %t69
  br label %ifend2
ifend2:
  %t88 = load i32, ptr @g_nloc
  %t89 = add i32 %t88, 1
  store i32 %t89, ptr @g_nloc
  br label %ret
ret:
  ret void
}

define i32 @fn_loc_find(ptr %arg_name) {
entry:
  %retval = alloca i32
  %t0 = alloca ptr
  %t3 = alloca i32
  store ptr %arg_name, ptr %t0
  %t1 = load i32, ptr @g_nloc
  %t2 = sub i32 %t1, 1
  store i32 %t2, ptr %t3
  br label %wcond0
wcond0:
  %t4 = load i32, ptr %t3
  %t5 = icmp sge i32 %t4, 0
  %t6 = zext i1 %t5 to i32
  %t7 = icmp ne i32 %t6, 0
  br i1 %t7, label %wbody1, label %wend2
wbody1:
  %t8 = load ptr, ptr @g_loc_name
  %t9 = getelementptr inbounds %LSlice, ptr %t8, i32 0, i32 0
  %t10 = load ptr, ptr %t9
  %t11 = load i32, ptr %t3
  %t12 = getelementptr inbounds ptr, ptr %t10, i32 %t11
  %t13 = load ptr, ptr %t12
  %t14 = load ptr, ptr %t0
  %t15 = call i32 @fn_streq(ptr %t13, ptr %t14)
  %t16 = icmp ne i32 %t15, 0
  br i1 %t16, label %then3, label %ifend5
then3:
  %t17 = load i32, ptr %t3
  store i32 %t17, ptr %retval
  br label %ret
ifend5:
  %t18 = load i32, ptr %t3
  %t19 = sub i32 %t18, 1
  store i32 %t19, ptr %t3
  br label %wcond0
wend2:
  %t20 = sub i32 0, 1
  store i32 %t20, ptr %retval
  br label %ret
ret:
  %t21 = load i32, ptr %retval
  ret i32 %t21
}

define i32 @fn_hexdig(i32 %arg_n) {
entry:
  %retval = alloca i32
  %t0 = alloca i32
  store i32 %arg_n, ptr %t0
  %t1 = load i32, ptr %t0
  %t2 = icmp slt i32 %t1, 10
  %t3 = zext i1 %t2 to i32
  %t4 = icmp ne i32 %t3, 0
  br i1 %t4, label %then0, label %ifend2
then0:
  %t5 = load i32, ptr %t0
  %t6 = add i32 48, %t5
  store i32 %t6, ptr %retval
  br label %ret
ifend2:
  %t7 = load i32, ptr %t0
  %t8 = add i32 55, %t7
  store i32 %t8, ptr %retval
  br label %ret
ret:
  %t9 = load i32, ptr %retval
  ret i32 %t9
}

define ptr @fn_emit_str_const(ptr %arg_s) {
entry:
  %retval = alloca ptr
  %t0 = alloca ptr
  %t4 = alloca ptr
  %t9 = alloca i32
  %t14 = alloca i32
  %t25 = alloca i32
  %t26 = alloca i32
  %t27 = alloca i32
  %t28 = alloca i32
  store ptr %arg_s, ptr %t0
  %t1 = load i32, ptr @g_ll_str
  %t2 = call ptr @fn_itoa(i32 %t1)
  %t3 = call ptr @fn_sconcat(ptr @.str208, ptr %t2)
  store ptr %t3, ptr %t4
  %t5 = load i32, ptr @g_ll_str
  %t6 = add i32 %t5, 1
  store i32 %t6, ptr @g_ll_str
  %t7 = load ptr, ptr %t0
  %t8 = call i32 @fn_slen(ptr %t7)
  store i32 %t8, ptr %t9
  %t10 = load ptr, ptr %t4
  call void @fn_emith(ptr %t10)
  call void @fn_emith(ptr @.str209)
  %t11 = load i32, ptr %t9
  %t12 = add i32 %t11, 1
  %t13 = call ptr @fn_itoa(i32 %t12)
  call void @fn_emith(ptr %t13)
  call void @fn_emith(ptr @.str210)
  store i32 0, ptr %t14
  br label %wcond0
wcond0:
  %t15 = load i32, ptr %t14
  %t16 = load i32, ptr %t9
  %t17 = icmp slt i32 %t15, %t16
  %t18 = zext i1 %t17 to i32
  %t19 = icmp ne i32 %t18, 0
  br i1 %t19, label %wbody1, label %wend2
wbody1:
  %t20 = load ptr, ptr %t0
  %t21 = load i32, ptr %t14
  %t22 = getelementptr inbounds i8, ptr %t20, i32 %t21
  %t23 = load i8, ptr %t22
  %t24 = zext i8 %t23 to i32
  store i32 %t24, ptr %t25
  %t29 = load i32, ptr %t25
  %t30 = icmp eq i32 %t29, 34
  %t31 = zext i1 %t30 to i32
  %t32 = icmp ne i32 %t31, 0
  %t33 = zext i1 %t32 to i32
  store i32 %t33, ptr %t28
  br i1 %t32, label %scend4, label %sc3
sc3:
  %t34 = load i32, ptr %t25
  %t35 = icmp eq i32 %t34, 92
  %t36 = zext i1 %t35 to i32
  %t37 = icmp ne i32 %t36, 0
  %t38 = zext i1 %t37 to i32
  store i32 %t38, ptr %t28
  br label %scend4
scend4:
  %t39 = load i32, ptr %t28
  %t40 = icmp ne i32 %t39, 0
  %t41 = zext i1 %t40 to i32
  store i32 %t41, ptr %t27
  br i1 %t40, label %scend6, label %sc5
sc5:
  %t42 = load i32, ptr %t25
  %t43 = icmp slt i32 %t42, 32
  %t44 = zext i1 %t43 to i32
  %t45 = icmp ne i32 %t44, 0
  %t46 = zext i1 %t45 to i32
  store i32 %t46, ptr %t27
  br label %scend6
scend6:
  %t47 = load i32, ptr %t27
  %t48 = icmp ne i32 %t47, 0
  %t49 = zext i1 %t48 to i32
  store i32 %t49, ptr %t26
  br i1 %t48, label %scend8, label %sc7
sc7:
  %t50 = load i32, ptr %t25
  %t51 = icmp sgt i32 %t50, 126
  %t52 = zext i1 %t51 to i32
  %t53 = icmp ne i32 %t52, 0
  %t54 = zext i1 %t53 to i32
  store i32 %t54, ptr %t26
  br label %scend8
scend8:
  %t55 = load i32, ptr %t26
  %t56 = icmp ne i32 %t55, 0
  br i1 %t56, label %then9, label %else10
then9:
  %t57 = load ptr, ptr @g_head
  call void @fn_buf_putc(ptr %t57, i32 92)
  %t58 = load ptr, ptr @g_head
  %t59 = load i32, ptr %t25
  %t60 = sdiv i32 %t59, 16
  %t61 = call i32 @fn_hexdig(i32 %t60)
  call void @fn_buf_putc(ptr %t58, i32 %t61)
  %t62 = load ptr, ptr @g_head
  %t63 = load i32, ptr %t25
  %t64 = srem i32 %t63, 16
  %t65 = call i32 @fn_hexdig(i32 %t64)
  call void @fn_buf_putc(ptr %t62, i32 %t65)
  br label %ifend11
else10:
  %t66 = load ptr, ptr @g_head
  %t67 = load i32, ptr %t25
  call void @fn_buf_putc(ptr %t66, i32 %t67)
  br label %ifend11
ifend11:
  %t68 = load i32, ptr %t14
  %t69 = add i32 %t68, 1
  store i32 %t69, ptr %t14
  br label %wcond0
wend2:
  call void @fn_emith(ptr @.str211)
  %t70 = load ptr, ptr %t4
  store ptr %t70, ptr %retval
  br label %ret
ret:
  %t71 = load ptr, ptr %retval
  ret ptr %t71
}

define ptr @fn_emit_gep_i8(ptr %arg_base, ptr %arg_idx) {
entry:
  %retval = alloca ptr
  %t0 = alloca ptr
  %t1 = alloca ptr
  %t3 = alloca ptr
  store ptr %arg_base, ptr %t0
  store ptr %arg_idx, ptr %t1
  %t2 = call ptr @fn_nreg()
  store ptr %t2, ptr %t3
  call void @fn_emit(ptr @.str212)
  %t4 = load ptr, ptr %t3
  call void @fn_emit(ptr %t4)
  call void @fn_emit(ptr @.str213)
  %t5 = load ptr, ptr %t0
  call void @fn_emit(ptr %t5)
  call void @fn_emit(ptr @.str214)
  %t6 = load ptr, ptr %t1
  call void @fn_emit(ptr %t6)
  call void @fn_emit(ptr @.str215)
  %t7 = load ptr, ptr %t3
  store ptr %t7, ptr %retval
  br label %ret
ret:
  %t8 = load ptr, ptr %retval
  ret ptr %t8
}

define ptr @fn_global_init(ptr %arg_d) {
entry:
  %retval = alloca ptr
  %t0 = alloca ptr
  %t16 = alloca ptr
  %t17 = alloca i32
  %t18 = alloca i32
  %t49 = alloca i32
  %t50 = alloca i32
  store ptr %arg_d, ptr %t0
  %t1 = load ptr, ptr %t0
  %t2 = getelementptr inbounds %Str_Node, ptr %t1, i32 0, i32 4
  %t3 = load ptr, ptr %t2
  %t4 = icmp eq ptr %t3, null
  %t5 = zext i1 %t4 to i32
  %t6 = icmp ne i32 %t5, 0
  br i1 %t6, label %then0, label %ifend2
then0:
  %t7 = load ptr, ptr %t0
  %t8 = getelementptr inbounds %Str_Node, ptr %t7, i32 0, i32 3
  %t9 = load ptr, ptr %t8
  %t10 = call ptr @fn_llty(ptr %t9)
  %t11 = call i32 @fn_streq(ptr %t10, ptr @.str216)
  %t12 = icmp ne i32 %t11, 0
  br i1 %t12, label %then3, label %ifend5
then3:
  store ptr @.str217, ptr %retval
  br label %ret
ifend5:
  store ptr @.str218, ptr %retval
  br label %ret
ifend2:
  %t13 = load ptr, ptr %t0
  %t14 = getelementptr inbounds %Str_Node, ptr %t13, i32 0, i32 4
  %t15 = load ptr, ptr %t14
  store ptr %t15, ptr %t16
  %t19 = load ptr, ptr %t16
  %t20 = getelementptr inbounds %Str_Node, ptr %t19, i32 0, i32 0
  %t21 = load i32, ptr %t20
  %t22 = icmp eq i32 %t21, 30
  %t23 = zext i1 %t22 to i32
  %t24 = icmp ne i32 %t23, 0
  %t25 = zext i1 %t24 to i32
  store i32 %t25, ptr %t18
  br i1 %t24, label %scend7, label %sc6
sc6:
  %t26 = load ptr, ptr %t16
  %t27 = getelementptr inbounds %Str_Node, ptr %t26, i32 0, i32 0
  %t28 = load i32, ptr %t27
  %t29 = icmp eq i32 %t28, 40
  %t30 = zext i1 %t29 to i32
  %t31 = icmp ne i32 %t30, 0
  %t32 = zext i1 %t31 to i32
  store i32 %t32, ptr %t18
  br label %scend7
scend7:
  %t33 = load i32, ptr %t18
  %t34 = icmp ne i32 %t33, 0
  %t35 = zext i1 %t34 to i32
  store i32 %t35, ptr %t17
  br i1 %t34, label %scend9, label %sc8
sc8:
  %t36 = load ptr, ptr %t16
  %t37 = getelementptr inbounds %Str_Node, ptr %t36, i32 0, i32 0
  %t38 = load i32, ptr %t37
  %t39 = icmp eq i32 %t38, 32
  %t40 = zext i1 %t39 to i32
  %t41 = icmp ne i32 %t40, 0
  %t42 = zext i1 %t41 to i32
  store i32 %t42, ptr %t17
  br label %scend9
scend9:
  %t43 = load i32, ptr %t17
  %t44 = icmp ne i32 %t43, 0
  br i1 %t44, label %then10, label %ifend12
then10:
  %t45 = load ptr, ptr %t16
  %t46 = getelementptr inbounds %Str_Node, ptr %t45, i32 0, i32 2
  %t47 = load i32, ptr %t46
  %t48 = call ptr @fn_itoa(i32 %t47)
  store ptr %t48, ptr %retval
  br label %ret
ifend12:
  %t51 = load ptr, ptr %t16
  %t52 = getelementptr inbounds %Str_Node, ptr %t51, i32 0, i32 0
  %t53 = load i32, ptr %t52
  %t54 = icmp eq i32 %t53, 38
  %t55 = zext i1 %t54 to i32
  %t56 = icmp ne i32 %t55, 0
  %t57 = zext i1 %t56 to i32
  store i32 %t57, ptr %t50
  br i1 %t56, label %sc13, label %scend14
sc13:
  %t58 = load ptr, ptr %t16
  %t59 = getelementptr inbounds %Str_Node, ptr %t58, i32 0, i32 1
  %t60 = load ptr, ptr %t59
  %t61 = call i32 @fn_streq(ptr %t60, ptr @.str219)
  %t62 = icmp ne i32 %t61, 0
  %t63 = zext i1 %t62 to i32
  store i32 %t63, ptr %t50
  br label %scend14
scend14:
  %t64 = load i32, ptr %t50
  %t65 = icmp ne i32 %t64, 0
  %t66 = zext i1 %t65 to i32
  store i32 %t66, ptr %t49
  br i1 %t65, label %sc15, label %scend16
sc15:
  %t67 = load ptr, ptr %t16
  %t68 = getelementptr inbounds %Str_Node, ptr %t67, i32 0, i32 4
  %t69 = load ptr, ptr %t68
  %t70 = getelementptr inbounds %Str_Node, ptr %t69, i32 0, i32 0
  %t71 = load i32, ptr %t70
  %t72 = icmp eq i32 %t71, 30
  %t73 = zext i1 %t72 to i32
  %t74 = icmp ne i32 %t73, 0
  %t75 = zext i1 %t74 to i32
  store i32 %t75, ptr %t49
  br label %scend16
scend16:
  %t76 = load i32, ptr %t49
  %t77 = icmp ne i32 %t76, 0
  br i1 %t77, label %then17, label %ifend19
then17:
  %t78 = load ptr, ptr %t16
  %t79 = getelementptr inbounds %Str_Node, ptr %t78, i32 0, i32 4
  %t80 = load ptr, ptr %t79
  %t81 = getelementptr inbounds %Str_Node, ptr %t80, i32 0, i32 2
  %t82 = load i32, ptr %t81
  %t83 = call ptr @fn_itoa(i32 %t82)
  %t84 = call ptr @fn_sconcat(ptr @.str220, ptr %t83)
  store ptr %t84, ptr %retval
  br label %ret
ifend19:
  %t85 = load ptr, ptr %t0
  %t86 = getelementptr inbounds %Str_Node, ptr %t85, i32 0, i32 3
  %t87 = load ptr, ptr %t86
  %t88 = call ptr @fn_llty(ptr %t87)
  %t89 = call i32 @fn_streq(ptr %t88, ptr @.str221)
  %t90 = icmp ne i32 %t89, 0
  br i1 %t90, label %then20, label %ifend22
then20:
  store ptr @.str222, ptr %retval
  br label %ret
ifend22:
  store ptr @.str223, ptr %retval
  br label %ret
ret:
  %t91 = load ptr, ptr %retval
  ret ptr %t91
}

define void @fn_emit_header() {
entry:
  %t5 = alloca i32
  %t19 = alloca ptr
  %t37 = alloca i32
  %t79 = alloca ptr
  call void @fn_emith(ptr @.str224)
  call void @fn_emith(ptr @.str225)
  call void @fn_emith(ptr @.str226)
  call void @fn_emith(ptr @.str227)
  call void @fn_emith(ptr @.str228)
  call void @fn_emith(ptr @.str229)
  call void @fn_emith(ptr @.str230)
  call void @fn_emith(ptr @.str231)
  call void @fn_emith(ptr @.str232)
  call void @fn_emith(ptr @.str233)
  call void @fn_emith(ptr @.str234)
  call void @fn_emith(ptr @.str235)
  call void @fn_emith(ptr @.str236)
  call void @fn_emith(ptr @.str237)
  call void @fn_emith(ptr @.str238)
  call void @fn_emith(ptr @.str239)
  call void @fn_emith(ptr @.str240)
  call void @fn_emith(ptr @.str241)
  call void @fn_emith(ptr @.str242)
  call void @fn_emith(ptr @.str243)
  call void @fn_emith(ptr @.str244)
  call void @fn_emith(ptr @.str245)
  call void @fn_emith(ptr @.str246)
  call void @fn_emith(ptr @.str247)
  call void @fn_emith(ptr @.str248)
  call void @fn_emith(ptr @.str249)
  call void @fn_emith(ptr @.str250)
  call void @fn_emith(ptr @.str251)
  call void @fn_emith(ptr @.str252)
  call void @fn_emith(ptr @.str253)
  call void @fn_emith(ptr @.str254)
  %t0 = load ptr, ptr @g_g_game_name
  %t1 = call i32 @fn_slen(ptr %t0)
  %t2 = add i32 %t1, 1
  %t3 = call ptr @fn_itoa(i32 %t2)
  call void @fn_emith(ptr %t3)
  call void @fn_emith(ptr @.str255)
  %t4 = load ptr, ptr @g_g_game_name
  call void @fn_emith(ptr %t4)
  call void @fn_emith(ptr @.str256)
  call void @fn_emith(ptr @.str257)
  store i32 0, ptr %t5
  br label %wcond0
wcond0:
  %t6 = load i32, ptr %t5
  %t7 = load ptr, ptr @g_prog
  %t8 = getelementptr inbounds %LSlice, ptr %t7, i32 0, i32 1
  %t9 = load i32, ptr %t8
  %t10 = icmp slt i32 %t6, %t9
  %t11 = zext i1 %t10 to i32
  %t12 = icmp ne i32 %t11, 0
  br i1 %t12, label %wbody1, label %wend2
wbody1:
  %t13 = load ptr, ptr @g_prog
  %t14 = getelementptr inbounds %LSlice, ptr %t13, i32 0, i32 0
  %t15 = load ptr, ptr %t14
  %t16 = load i32, ptr %t5
  %t17 = getelementptr inbounds ptr, ptr %t15, i32 %t16
  %t18 = load ptr, ptr %t17
  store ptr %t18, ptr %t19
  %t20 = load ptr, ptr %t19
  %t21 = getelementptr inbounds %Str_Node, ptr %t20, i32 0, i32 0
  %t22 = load i32, ptr %t21
  %t23 = icmp eq i32 %t22, 0
  %t24 = zext i1 %t23 to i32
  %t25 = icmp ne i32 %t24, 0
  br i1 %t25, label %then3, label %ifend5
then3:
  call void @fn_emith(ptr @.str258)
  %t26 = load ptr, ptr %t19
  %t27 = getelementptr inbounds %Str_Node, ptr %t26, i32 0, i32 1
  %t28 = load ptr, ptr %t27
  call void @fn_emith(ptr %t28)
  call void @fn_emith(ptr @.str259)
  %t29 = load ptr, ptr %t19
  %t30 = getelementptr inbounds %Str_Node, ptr %t29, i32 0, i32 7
  %t31 = load ptr, ptr %t30
  %t32 = getelementptr inbounds %LSlice, ptr %t31, i32 0, i32 1
  %t33 = load i32, ptr %t32
  %t34 = icmp eq i32 %t33, 0
  %t35 = zext i1 %t34 to i32
  %t36 = icmp ne i32 %t35, 0
  br i1 %t36, label %then6, label %ifend8
then6:
  call void @fn_emith(ptr @.str260)
  br label %ifend8
ifend8:
  store i32 0, ptr %t37
  br label %wcond9
wcond9:
  %t38 = load i32, ptr %t37
  %t39 = load ptr, ptr %t19
  %t40 = getelementptr inbounds %Str_Node, ptr %t39, i32 0, i32 7
  %t41 = load ptr, ptr %t40
  %t42 = getelementptr inbounds %LSlice, ptr %t41, i32 0, i32 1
  %t43 = load i32, ptr %t42
  %t44 = icmp slt i32 %t38, %t43
  %t45 = zext i1 %t44 to i32
  %t46 = icmp ne i32 %t45, 0
  br i1 %t46, label %wbody10, label %wend11
wbody10:
  %t47 = load i32, ptr %t37
  %t48 = icmp sgt i32 %t47, 0
  %t49 = zext i1 %t48 to i32
  %t50 = icmp ne i32 %t49, 0
  br i1 %t50, label %then12, label %ifend14
then12:
  call void @fn_emith(ptr @.str261)
  br label %ifend14
ifend14:
  %t51 = load ptr, ptr %t19
  %t52 = getelementptr inbounds %Str_Node, ptr %t51, i32 0, i32 7
  %t53 = load ptr, ptr %t52
  %t54 = getelementptr inbounds %LSlice, ptr %t53, i32 0, i32 0
  %t55 = load ptr, ptr %t54
  %t56 = load i32, ptr %t37
  %t57 = getelementptr inbounds ptr, ptr %t55, i32 %t56
  %t58 = load ptr, ptr %t57
  %t59 = getelementptr inbounds %Str_Node, ptr %t58, i32 0, i32 3
  %t60 = load ptr, ptr %t59
  %t61 = call ptr @fn_llty(ptr %t60)
  call void @fn_emith(ptr %t61)
  %t62 = load i32, ptr %t37
  %t63 = add i32 %t62, 1
  store i32 %t63, ptr %t37
  br label %wcond9
wend11:
  call void @fn_emith(ptr @.str262)
  br label %ifend5
ifend5:
  %t64 = load i32, ptr %t5
  %t65 = add i32 %t64, 1
  store i32 %t65, ptr %t5
  br label %wcond0
wend2:
  store i32 0, ptr %t5
  br label %wcond15
wcond15:
  %t66 = load i32, ptr %t5
  %t67 = load ptr, ptr @g_prog
  %t68 = getelementptr inbounds %LSlice, ptr %t67, i32 0, i32 1
  %t69 = load i32, ptr %t68
  %t70 = icmp slt i32 %t66, %t69
  %t71 = zext i1 %t70 to i32
  %t72 = icmp ne i32 %t71, 0
  br i1 %t72, label %wbody16, label %wend17
wbody16:
  %t73 = load ptr, ptr @g_prog
  %t74 = getelementptr inbounds %LSlice, ptr %t73, i32 0, i32 0
  %t75 = load ptr, ptr %t74
  %t76 = load i32, ptr %t5
  %t77 = getelementptr inbounds ptr, ptr %t75, i32 %t76
  %t78 = load ptr, ptr %t77
  store ptr %t78, ptr %t79
  %t80 = load ptr, ptr %t79
  %t81 = getelementptr inbounds %Str_Node, ptr %t80, i32 0, i32 0
  %t82 = load i32, ptr %t81
  %t83 = icmp eq i32 %t82, 2
  %t84 = zext i1 %t83 to i32
  %t85 = icmp ne i32 %t84, 0
  br i1 %t85, label %then18, label %ifend20
then18:
  call void @fn_emith(ptr @.str263)
  %t86 = load ptr, ptr %t79
  %t87 = getelementptr inbounds %Str_Node, ptr %t86, i32 0, i32 1
  %t88 = load ptr, ptr %t87
  call void @fn_emith(ptr %t88)
  call void @fn_emith(ptr @.str264)
  %t89 = load ptr, ptr %t79
  %t90 = getelementptr inbounds %Str_Node, ptr %t89, i32 0, i32 3
  %t91 = load ptr, ptr %t90
  %t92 = call ptr @fn_llty(ptr %t91)
  call void @fn_emith(ptr %t92)
  call void @fn_emith(ptr @.str265)
  %t93 = load ptr, ptr %t79
  %t94 = call ptr @fn_global_init(ptr %t93)
  call void @fn_emith(ptr %t94)
  call void @fn_emith(ptr @.str266)
  br label %ifend20
ifend20:
  %t95 = load i32, ptr %t5
  %t96 = add i32 %t95, 1
  store i32 %t96, ptr %t5
  br label %wcond15
wend17:
  br label %ret
ret:
  ret void
}

define ptr @fn_emit_member_addr(ptr %arg_e) {
entry:
  %retval = alloca ptr
  %t0 = alloca ptr
  %t5 = alloca ptr
  %t10 = alloca ptr
  %t24 = alloca i32
  %t39 = alloca ptr
  store ptr %arg_e, ptr %t0
  %t1 = load ptr, ptr %t0
  %t2 = getelementptr inbounds %Str_Node, ptr %t1, i32 0, i32 4
  %t3 = load ptr, ptr %t2
  %t4 = call ptr @fn_emit_expr(ptr %t3)
  store ptr %t4, ptr %t5
  %t6 = load ptr, ptr %t5
  %t7 = getelementptr inbounds %Str_Val, ptr %t6, i32 0, i32 1
  %t8 = load ptr, ptr %t7
  %t9 = call ptr @fn_layout_node(ptr %t8)
  store ptr %t9, ptr %t10
  %t11 = load ptr, ptr %t10
  %t12 = icmp eq ptr %t11, null
  %t13 = zext i1 %t12 to i32
  %t14 = icmp ne i32 %t13, 0
  br i1 %t14, label %then0, label %ifend2
then0:
  %t15 = load ptr, ptr %t5
  %t16 = getelementptr inbounds %Str_Val, ptr %t15, i32 0, i32 1
  %t17 = load ptr, ptr %t16
  %t18 = call ptr @fn_sconcat(ptr @.str267, ptr %t17)
  call void @fn_perr(ptr %t18)
  br label %ifend2
ifend2:
  %t19 = load ptr, ptr %t10
  %t20 = load ptr, ptr %t0
  %t21 = getelementptr inbounds %Str_Node, ptr %t20, i32 0, i32 1
  %t22 = load ptr, ptr %t21
  %t23 = call i32 @fn_field_index(ptr %t19, ptr %t22)
  store i32 %t23, ptr %t24
  %t25 = load i32, ptr %t24
  %t26 = icmp slt i32 %t25, 0
  %t27 = zext i1 %t26 to i32
  %t28 = icmp ne i32 %t27, 0
  br i1 %t28, label %then3, label %ifend5
then3:
  %t29 = load ptr, ptr %t0
  %t30 = getelementptr inbounds %Str_Node, ptr %t29, i32 0, i32 1
  %t31 = load ptr, ptr %t30
  %t32 = call ptr @fn_sconcat(ptr @.str268, ptr %t31)
  call void @fn_perr(ptr %t32)
  br label %ifend5
ifend5:
  %t33 = load ptr, ptr %t10
  %t34 = load ptr, ptr %t0
  %t35 = getelementptr inbounds %Str_Node, ptr %t34, i32 0, i32 1
  %t36 = load ptr, ptr %t35
  %t37 = call ptr @fn_field_type(ptr %t33, ptr %t36)
  store ptr %t37, ptr @g_g_addr_ty
  %t38 = call ptr @fn_nreg()
  store ptr %t38, ptr %t39
  call void @fn_emit(ptr @.str269)
  %t40 = load ptr, ptr %t39
  call void @fn_emit(ptr %t40)
  call void @fn_emit(ptr @.str270)
  %t41 = load ptr, ptr %t5
  %t42 = getelementptr inbounds %Str_Val, ptr %t41, i32 0, i32 1
  %t43 = load ptr, ptr %t42
  %t44 = call ptr @fn_layout_ty(ptr %t43)
  call void @fn_emit(ptr %t44)
  call void @fn_emit(ptr @.str271)
  %t45 = load ptr, ptr %t5
  %t46 = getelementptr inbounds %Str_Val, ptr %t45, i32 0, i32 0
  %t47 = load ptr, ptr %t46
  call void @fn_emit(ptr %t47)
  call void @fn_emit(ptr @.str272)
  %t48 = load i32, ptr %t24
  %t49 = call ptr @fn_itoa(i32 %t48)
  call void @fn_emit(ptr %t49)
  call void @fn_emit(ptr @.str273)
  %t50 = load ptr, ptr %t39
  store ptr %t50, ptr %retval
  br label %ret
ret:
  %t51 = load ptr, ptr %retval
  ret ptr %t51
}

define ptr @fn_emit_index_addr(ptr %arg_e) {
entry:
  %retval = alloca ptr
  %t0 = alloca ptr
  %t5 = alloca ptr
  %t17 = alloca ptr
  %t20 = alloca ptr
  %t26 = alloca ptr
  %t33 = alloca ptr
  %t35 = alloca ptr
  store ptr %arg_e, ptr %t0
  %t1 = load ptr, ptr %t0
  %t2 = getelementptr inbounds %Str_Node, ptr %t1, i32 0, i32 4
  %t3 = load ptr, ptr %t2
  %t4 = call ptr @fn_emit_expr(ptr %t3)
  store ptr %t4, ptr %t5
  %t6 = load ptr, ptr %t5
  %t7 = getelementptr inbounds %Str_Val, ptr %t6, i32 0, i32 1
  %t8 = load ptr, ptr %t7
  %t9 = call i32 @fn_is_slice_ty(ptr %t8)
  %t10 = icmp eq i32 %t9, 0
  %t11 = zext i1 %t10 to i32
  %t12 = icmp ne i32 %t11, 0
  br i1 %t12, label %then0, label %ifend2
then0:
  call void @fn_perr(ptr @.str274)
  br label %ifend2
ifend2:
  %t13 = load ptr, ptr %t5
  %t14 = getelementptr inbounds %Str_Val, ptr %t13, i32 0, i32 1
  %t15 = load ptr, ptr %t14
  %t16 = call ptr @fn_slice_elem(ptr %t15)
  store ptr %t16, ptr %t17
  %t18 = load ptr, ptr %t17
  store ptr %t18, ptr @g_g_addr_ty
  %t19 = call ptr @fn_nreg()
  store ptr %t19, ptr %t20
  call void @fn_emit(ptr @.str275)
  %t21 = load ptr, ptr %t20
  call void @fn_emit(ptr %t21)
  call void @fn_emit(ptr @.str276)
  %t22 = load ptr, ptr %t5
  %t23 = getelementptr inbounds %Str_Val, ptr %t22, i32 0, i32 0
  %t24 = load ptr, ptr %t23
  call void @fn_emit(ptr %t24)
  call void @fn_emit(ptr @.str277)
  %t25 = call ptr @fn_nreg()
  store ptr %t25, ptr %t26
  call void @fn_emit(ptr @.str278)
  %t27 = load ptr, ptr %t26
  call void @fn_emit(ptr %t27)
  call void @fn_emit(ptr @.str279)
  %t28 = load ptr, ptr %t20
  call void @fn_emit(ptr %t28)
  call void @fn_emit(ptr @.str280)
  %t29 = load ptr, ptr %t0
  %t30 = getelementptr inbounds %Str_Node, ptr %t29, i32 0, i32 5
  %t31 = load ptr, ptr %t30
  %t32 = call ptr @fn_emit_expr(ptr %t31)
  store ptr %t32, ptr %t33
  %t34 = call ptr @fn_nreg()
  store ptr %t34, ptr %t35
  call void @fn_emit(ptr @.str281)
  %t36 = load ptr, ptr %t35
  call void @fn_emit(ptr %t36)
  call void @fn_emit(ptr @.str282)
  %t37 = load ptr, ptr %t17
  %t38 = call ptr @fn_llty(ptr %t37)
  call void @fn_emit(ptr %t38)
  call void @fn_emit(ptr @.str283)
  %t39 = load ptr, ptr %t26
  call void @fn_emit(ptr %t39)
  call void @fn_emit(ptr @.str284)
  %t40 = load ptr, ptr %t33
  %t41 = getelementptr inbounds %Str_Val, ptr %t40, i32 0, i32 0
  %t42 = load ptr, ptr %t41
  call void @fn_emit(ptr %t42)
  call void @fn_emit(ptr @.str285)
  %t43 = load ptr, ptr %t35
  store ptr %t43, ptr %retval
  br label %ret
ret:
  %t44 = load ptr, ptr %retval
  ret ptr %t44
}

define i32 @fn_is_intrinsic(ptr %arg_name) {
entry:
  %retval = alloca i32
  %t0 = alloca ptr
  %t1 = alloca i32
  %t2 = alloca i32
  %t20 = alloca i32
  %t21 = alloca i32
  %t39 = alloca i32
  %t40 = alloca i32
  %t58 = alloca i32
  %t59 = alloca i32
  %t77 = alloca i32
  %t88 = alloca i32
  %t89 = alloca i32
  %t90 = alloca i32
  %t115 = alloca i32
  %t126 = alloca i32
  %t127 = alloca i32
  %t128 = alloca i32
  %t129 = alloca i32
  %t130 = alloca i32
  %t169 = alloca i32
  store ptr %arg_name, ptr %t0
  %t3 = load ptr, ptr %t0
  %t4 = call i32 @fn_streq(ptr %t3, ptr @.str286)
  %t5 = icmp ne i32 %t4, 0
  %t6 = zext i1 %t5 to i32
  store i32 %t6, ptr %t2
  br i1 %t5, label %scend1, label %sc0
sc0:
  %t7 = load ptr, ptr %t0
  %t8 = call i32 @fn_streq(ptr %t7, ptr @.str287)
  %t9 = icmp ne i32 %t8, 0
  %t10 = zext i1 %t9 to i32
  store i32 %t10, ptr %t2
  br label %scend1
scend1:
  %t11 = load i32, ptr %t2
  %t12 = icmp ne i32 %t11, 0
  %t13 = zext i1 %t12 to i32
  store i32 %t13, ptr %t1
  br i1 %t12, label %scend3, label %sc2
sc2:
  %t14 = load ptr, ptr %t0
  %t15 = call i32 @fn_streq(ptr %t14, ptr @.str288)
  %t16 = icmp ne i32 %t15, 0
  %t17 = zext i1 %t16 to i32
  store i32 %t17, ptr %t1
  br label %scend3
scend3:
  %t18 = load i32, ptr %t1
  %t19 = icmp ne i32 %t18, 0
  br i1 %t19, label %then4, label %ifend6
then4:
  store i32 1, ptr %retval
  br label %ret
ifend6:
  %t22 = load ptr, ptr %t0
  %t23 = call i32 @fn_streq(ptr %t22, ptr @.str289)
  %t24 = icmp ne i32 %t23, 0
  %t25 = zext i1 %t24 to i32
  store i32 %t25, ptr %t21
  br i1 %t24, label %scend8, label %sc7
sc7:
  %t26 = load ptr, ptr %t0
  %t27 = call i32 @fn_streq(ptr %t26, ptr @.str290)
  %t28 = icmp ne i32 %t27, 0
  %t29 = zext i1 %t28 to i32
  store i32 %t29, ptr %t21
  br label %scend8
scend8:
  %t30 = load i32, ptr %t21
  %t31 = icmp ne i32 %t30, 0
  %t32 = zext i1 %t31 to i32
  store i32 %t32, ptr %t20
  br i1 %t31, label %scend10, label %sc9
sc9:
  %t33 = load ptr, ptr %t0
  %t34 = call i32 @fn_streq(ptr %t33, ptr @.str291)
  %t35 = icmp ne i32 %t34, 0
  %t36 = zext i1 %t35 to i32
  store i32 %t36, ptr %t20
  br label %scend10
scend10:
  %t37 = load i32, ptr %t20
  %t38 = icmp ne i32 %t37, 0
  br i1 %t38, label %then11, label %ifend13
then11:
  store i32 1, ptr %retval
  br label %ret
ifend13:
  %t41 = load ptr, ptr %t0
  %t42 = call i32 @fn_streq(ptr %t41, ptr @.str292)
  %t43 = icmp ne i32 %t42, 0
  %t44 = zext i1 %t43 to i32
  store i32 %t44, ptr %t40
  br i1 %t43, label %scend15, label %sc14
sc14:
  %t45 = load ptr, ptr %t0
  %t46 = call i32 @fn_streq(ptr %t45, ptr @.str293)
  %t47 = icmp ne i32 %t46, 0
  %t48 = zext i1 %t47 to i32
  store i32 %t48, ptr %t40
  br label %scend15
scend15:
  %t49 = load i32, ptr %t40
  %t50 = icmp ne i32 %t49, 0
  %t51 = zext i1 %t50 to i32
  store i32 %t51, ptr %t39
  br i1 %t50, label %scend17, label %sc16
sc16:
  %t52 = load ptr, ptr %t0
  %t53 = call i32 @fn_streq(ptr %t52, ptr @.str294)
  %t54 = icmp ne i32 %t53, 0
  %t55 = zext i1 %t54 to i32
  store i32 %t55, ptr %t39
  br label %scend17
scend17:
  %t56 = load i32, ptr %t39
  %t57 = icmp ne i32 %t56, 0
  br i1 %t57, label %then18, label %ifend20
then18:
  store i32 1, ptr %retval
  br label %ret
ifend20:
  %t60 = load ptr, ptr %t0
  %t61 = call i32 @fn_streq(ptr %t60, ptr @.str295)
  %t62 = icmp ne i32 %t61, 0
  %t63 = zext i1 %t62 to i32
  store i32 %t63, ptr %t59
  br i1 %t62, label %scend22, label %sc21
sc21:
  %t64 = load ptr, ptr %t0
  %t65 = call i32 @fn_streq(ptr %t64, ptr @.str296)
  %t66 = icmp ne i32 %t65, 0
  %t67 = zext i1 %t66 to i32
  store i32 %t67, ptr %t59
  br label %scend22
scend22:
  %t68 = load i32, ptr %t59
  %t69 = icmp ne i32 %t68, 0
  %t70 = zext i1 %t69 to i32
  store i32 %t70, ptr %t58
  br i1 %t69, label %scend24, label %sc23
sc23:
  %t71 = load ptr, ptr %t0
  %t72 = call i32 @fn_streq(ptr %t71, ptr @.str297)
  %t73 = icmp ne i32 %t72, 0
  %t74 = zext i1 %t73 to i32
  store i32 %t74, ptr %t58
  br label %scend24
scend24:
  %t75 = load i32, ptr %t58
  %t76 = icmp ne i32 %t75, 0
  br i1 %t76, label %then25, label %ifend27
then25:
  store i32 1, ptr %retval
  br label %ret
ifend27:
  %t78 = load ptr, ptr %t0
  %t79 = call i32 @fn_streq(ptr %t78, ptr @.str298)
  %t80 = icmp ne i32 %t79, 0
  %t81 = zext i1 %t80 to i32
  store i32 %t81, ptr %t77
  br i1 %t80, label %scend29, label %sc28
sc28:
  %t82 = load ptr, ptr %t0
  %t83 = call i32 @fn_streq(ptr %t82, ptr @.str299)
  %t84 = icmp ne i32 %t83, 0
  %t85 = zext i1 %t84 to i32
  store i32 %t85, ptr %t77
  br label %scend29
scend29:
  %t86 = load i32, ptr %t77
  %t87 = icmp ne i32 %t86, 0
  br i1 %t87, label %then30, label %ifend32
then30:
  store i32 1, ptr %retval
  br label %ret
ifend32:
  %t91 = load ptr, ptr %t0
  %t92 = call i32 @fn_streq(ptr %t91, ptr @.str300)
  %t93 = icmp ne i32 %t92, 0
  %t94 = zext i1 %t93 to i32
  store i32 %t94, ptr %t90
  br i1 %t93, label %scend34, label %sc33
sc33:
  %t95 = load ptr, ptr %t0
  %t96 = call i32 @fn_streq(ptr %t95, ptr @.str301)
  %t97 = icmp ne i32 %t96, 0
  %t98 = zext i1 %t97 to i32
  store i32 %t98, ptr %t90
  br label %scend34
scend34:
  %t99 = load i32, ptr %t90
  %t100 = icmp ne i32 %t99, 0
  %t101 = zext i1 %t100 to i32
  store i32 %t101, ptr %t89
  br i1 %t100, label %scend36, label %sc35
sc35:
  %t102 = load ptr, ptr %t0
  %t103 = call i32 @fn_streq(ptr %t102, ptr @.str302)
  %t104 = icmp ne i32 %t103, 0
  %t105 = zext i1 %t104 to i32
  store i32 %t105, ptr %t89
  br label %scend36
scend36:
  %t106 = load i32, ptr %t89
  %t107 = icmp ne i32 %t106, 0
  %t108 = zext i1 %t107 to i32
  store i32 %t108, ptr %t88
  br i1 %t107, label %scend38, label %sc37
sc37:
  %t109 = load ptr, ptr %t0
  %t110 = call i32 @fn_streq(ptr %t109, ptr @.str303)
  %t111 = icmp ne i32 %t110, 0
  %t112 = zext i1 %t111 to i32
  store i32 %t112, ptr %t88
  br label %scend38
scend38:
  %t113 = load i32, ptr %t88
  %t114 = icmp ne i32 %t113, 0
  br i1 %t114, label %then39, label %ifend41
then39:
  store i32 1, ptr %retval
  br label %ret
ifend41:
  %t116 = load ptr, ptr %t0
  %t117 = call i32 @fn_streq(ptr %t116, ptr @.str304)
  %t118 = icmp ne i32 %t117, 0
  %t119 = zext i1 %t118 to i32
  store i32 %t119, ptr %t115
  br i1 %t118, label %scend43, label %sc42
sc42:
  %t120 = load ptr, ptr %t0
  %t121 = call i32 @fn_streq(ptr %t120, ptr @.str305)
  %t122 = icmp ne i32 %t121, 0
  %t123 = zext i1 %t122 to i32
  store i32 %t123, ptr %t115
  br label %scend43
scend43:
  %t124 = load i32, ptr %t115
  %t125 = icmp ne i32 %t124, 0
  br i1 %t125, label %then44, label %ifend46
then44:
  store i32 1, ptr %retval
  br label %ret
ifend46:
  %t131 = load ptr, ptr %t0
  %t132 = call i32 @fn_streq(ptr %t131, ptr @.str306)
  %t133 = icmp ne i32 %t132, 0
  %t134 = zext i1 %t133 to i32
  store i32 %t134, ptr %t130
  br i1 %t133, label %scend48, label %sc47
sc47:
  %t135 = load ptr, ptr %t0
  %t136 = call i32 @fn_streq(ptr %t135, ptr @.str307)
  %t137 = icmp ne i32 %t136, 0
  %t138 = zext i1 %t137 to i32
  store i32 %t138, ptr %t130
  br label %scend48
scend48:
  %t139 = load i32, ptr %t130
  %t140 = icmp ne i32 %t139, 0
  %t141 = zext i1 %t140 to i32
  store i32 %t141, ptr %t129
  br i1 %t140, label %scend50, label %sc49
sc49:
  %t142 = load ptr, ptr %t0
  %t143 = call i32 @fn_streq(ptr %t142, ptr @.str308)
  %t144 = icmp ne i32 %t143, 0
  %t145 = zext i1 %t144 to i32
  store i32 %t145, ptr %t129
  br label %scend50
scend50:
  %t146 = load i32, ptr %t129
  %t147 = icmp ne i32 %t146, 0
  %t148 = zext i1 %t147 to i32
  store i32 %t148, ptr %t128
  br i1 %t147, label %scend52, label %sc51
sc51:
  %t149 = load ptr, ptr %t0
  %t150 = call i32 @fn_streq(ptr %t149, ptr @.str309)
  %t151 = icmp ne i32 %t150, 0
  %t152 = zext i1 %t151 to i32
  store i32 %t152, ptr %t128
  br label %scend52
scend52:
  %t153 = load i32, ptr %t128
  %t154 = icmp ne i32 %t153, 0
  %t155 = zext i1 %t154 to i32
  store i32 %t155, ptr %t127
  br i1 %t154, label %scend54, label %sc53
sc53:
  %t156 = load ptr, ptr %t0
  %t157 = call i32 @fn_streq(ptr %t156, ptr @.str310)
  %t158 = icmp ne i32 %t157, 0
  %t159 = zext i1 %t158 to i32
  store i32 %t159, ptr %t127
  br label %scend54
scend54:
  %t160 = load i32, ptr %t127
  %t161 = icmp ne i32 %t160, 0
  %t162 = zext i1 %t161 to i32
  store i32 %t162, ptr %t126
  br i1 %t161, label %scend56, label %sc55
sc55:
  %t163 = load ptr, ptr %t0
  %t164 = call i32 @fn_streq(ptr %t163, ptr @.str311)
  %t165 = icmp ne i32 %t164, 0
  %t166 = zext i1 %t165 to i32
  store i32 %t166, ptr %t126
  br label %scend56
scend56:
  %t167 = load i32, ptr %t126
  %t168 = icmp ne i32 %t167, 0
  br i1 %t168, label %then57, label %ifend59
then57:
  store i32 1, ptr %retval
  br label %ret
ifend59:
  %t170 = load ptr, ptr %t0
  %t171 = call i32 @fn_streq(ptr %t170, ptr @.str312)
  %t172 = icmp ne i32 %t171, 0
  %t173 = zext i1 %t172 to i32
  store i32 %t173, ptr %t169
  br i1 %t172, label %scend61, label %sc60
sc60:
  %t174 = load ptr, ptr %t0
  %t175 = call i32 @fn_streq(ptr %t174, ptr @.str313)
  %t176 = icmp ne i32 %t175, 0
  %t177 = zext i1 %t176 to i32
  store i32 %t177, ptr %t169
  br label %scend61
scend61:
  %t178 = load i32, ptr %t169
  %t179 = icmp ne i32 %t178, 0
  br i1 %t179, label %then62, label %ifend64
then62:
  store i32 1, ptr %retval
  br label %ret
ifend64:
  store i32 0, ptr %retval
  br label %ret
ret:
  %t180 = load i32, ptr %retval
  ret i32 %t180
}

define ptr @fn_emit_bind(ptr %arg_rest) {
entry:
  %retval = alloca ptr
  %t0 = alloca ptr
  %t2 = alloca ptr
  store ptr %arg_rest, ptr %t0
  %t1 = call ptr @fn_nreg()
  store ptr %t1, ptr %t2
  call void @fn_emit(ptr @.str314)
  %t3 = load ptr, ptr %t2
  call void @fn_emit(ptr %t3)
  call void @fn_emit(ptr @.str315)
  %t4 = load ptr, ptr %t0
  call void @fn_emit(ptr %t4)
  call void @fn_emit(ptr @.str316)
  %t5 = load ptr, ptr %t2
  store ptr %t5, ptr %retval
  br label %ret
ret:
  %t6 = load ptr, ptr %retval
  ret ptr %t6
}

define ptr @fn_arg_code(ptr %arg_e, i32 %arg_i) {
entry:
  %retval = alloca ptr
  %t0 = alloca ptr
  %t1 = alloca i32
  %t11 = alloca ptr
  store ptr %arg_e, ptr %t0
  store i32 %arg_i, ptr %t1
  %t2 = load ptr, ptr %t0
  %t3 = getelementptr inbounds %Str_Node, ptr %t2, i32 0, i32 7
  %t4 = load ptr, ptr %t3
  %t5 = getelementptr inbounds %LSlice, ptr %t4, i32 0, i32 0
  %t6 = load ptr, ptr %t5
  %t7 = load i32, ptr %t1
  %t8 = getelementptr inbounds ptr, ptr %t6, i32 %t7
  %t9 = load ptr, ptr %t8
  %t10 = call ptr @fn_emit_expr(ptr %t9)
  store ptr %t10, ptr %t11
  %t12 = load ptr, ptr %t11
  %t13 = getelementptr inbounds %Str_Val, ptr %t12, i32 0, i32 0
  %t14 = load ptr, ptr %t13
  store ptr %t14, ptr %retval
  br label %ret
ret:
  %t15 = load ptr, ptr %retval
  ret ptr %t15
}

define ptr @fn_emit_intrinsic(ptr %arg_name, ptr %arg_e) {
entry:
  %retval = alloca ptr
  %t0 = alloca ptr
  %t1 = alloca ptr
  %t11 = alloca ptr
  %t16 = alloca ptr
  %t27 = alloca ptr
  %t30 = alloca ptr
  %t35 = alloca ptr
  %t49 = alloca ptr
  %t52 = alloca ptr
  %t56 = alloca ptr
  %t60 = alloca ptr
  %t71 = alloca ptr
  %t74 = alloca ptr
  %t77 = alloca ptr
  %t81 = alloca ptr
  %t86 = alloca ptr
  %t95 = alloca ptr
  %t100 = alloca ptr
  %t111 = alloca ptr
  %t114 = alloca ptr
  %t123 = alloca i32
  %t136 = alloca ptr
  %t139 = alloca ptr
  %t142 = alloca ptr
  %t147 = alloca ptr
  %t148 = alloca ptr
  %t165 = alloca ptr
  %t176 = alloca ptr
  %t179 = alloca ptr
  %t182 = alloca ptr
  %t187 = alloca ptr
  %t204 = alloca ptr
  %t209 = alloca ptr
  %t220 = alloca ptr
  %t228 = alloca ptr
  %t236 = alloca ptr
  %t249 = alloca ptr
  %t251 = alloca ptr
  %t258 = alloca ptr
  %t268 = alloca ptr
  %t281 = alloca ptr
  %t292 = alloca ptr
  %t303 = alloca ptr
  %t309 = alloca i32
  %t310 = alloca i32
  %t311 = alloca i32
  %t312 = alloca i32
  %t346 = alloca ptr
  %t349 = alloca ptr
  %t350 = alloca ptr
  %t377 = alloca ptr
  %t380 = alloca ptr
  %t382 = alloca ptr
  %t395 = alloca ptr
  %t398 = alloca ptr
  %t401 = alloca ptr
  %t403 = alloca ptr
  store ptr %arg_name, ptr %t0
  store ptr %arg_e, ptr %t1
  store i32 1, ptr @g_g_intrin_ok
  %t2 = load ptr, ptr %t0
  %t3 = call i32 @fn_streq(ptr %t2, ptr @.str317)
  %t4 = icmp ne i32 %t3, 0
  br i1 %t4, label %then0, label %ifend2
then0:
  %t5 = call ptr @fn_val(ptr @.str318, ptr @.str319)
  store ptr %t5, ptr %retval
  br label %ret
ifend2:
  %t6 = load ptr, ptr %t0
  %t7 = call i32 @fn_streq(ptr %t6, ptr @.str320)
  %t8 = icmp ne i32 %t7, 0
  br i1 %t8, label %then3, label %ifend5
then3:
  %t9 = load ptr, ptr %t1
  %t10 = call ptr @fn_arg_code(ptr %t9, i32 0)
  store ptr %t10, ptr %t11
  %t12 = load ptr, ptr %t11
  %t13 = call ptr @fn_sconcat(ptr %t12, ptr @.str322)
  %t14 = call ptr @fn_sconcat(ptr @.str321, ptr %t13)
  %t15 = call ptr @fn_emit_bind(ptr %t14)
  store ptr %t15, ptr %t16
  %t17 = load ptr, ptr %t16
  %t18 = call ptr @fn_sconcat(ptr %t17, ptr @.str324)
  %t19 = call ptr @fn_sconcat(ptr @.str323, ptr %t18)
  %t20 = call ptr @fn_emit_bind(ptr %t19)
  %t21 = call ptr @fn_val(ptr %t20, ptr @.str325)
  store ptr %t21, ptr %retval
  br label %ret
ifend5:
  %t22 = load ptr, ptr %t0
  %t23 = call i32 @fn_streq(ptr %t22, ptr @.str326)
  %t24 = icmp ne i32 %t23, 0
  br i1 %t24, label %then6, label %ifend8
then6:
  %t25 = load ptr, ptr %t1
  %t26 = call ptr @fn_arg_code(ptr %t25, i32 0)
  store ptr %t26, ptr %t27
  %t28 = load ptr, ptr %t1
  %t29 = call ptr @fn_arg_code(ptr %t28, i32 1)
  store ptr %t29, ptr %t30
  %t31 = load ptr, ptr %t30
  %t32 = call ptr @fn_sconcat(ptr %t31, ptr @.str328)
  %t33 = call ptr @fn_sconcat(ptr @.str327, ptr %t32)
  %t34 = call ptr @fn_emit_bind(ptr %t33)
  store ptr %t34, ptr %t35
  %t36 = load ptr, ptr %t27
  %t37 = load ptr, ptr %t35
  %t38 = call ptr @fn_sconcat(ptr %t37, ptr @.str331)
  %t39 = call ptr @fn_sconcat(ptr @.str330, ptr %t38)
  %t40 = call ptr @fn_sconcat(ptr %t36, ptr %t39)
  %t41 = call ptr @fn_sconcat(ptr @.str329, ptr %t40)
  %t42 = call ptr @fn_emit_bind(ptr %t41)
  %t43 = call ptr @fn_val(ptr %t42, ptr @.str332)
  store ptr %t43, ptr %retval
  br label %ret
ifend8:
  %t44 = load ptr, ptr %t0
  %t45 = call i32 @fn_streq(ptr %t44, ptr @.str333)
  %t46 = icmp ne i32 %t45, 0
  br i1 %t46, label %then9, label %ifend11
then9:
  %t47 = load ptr, ptr %t1
  %t48 = call ptr @fn_arg_code(ptr %t47, i32 0)
  store ptr %t48, ptr %t49
  %t50 = load ptr, ptr %t1
  %t51 = call ptr @fn_arg_code(ptr %t50, i32 1)
  store ptr %t51, ptr %t52
  %t53 = load ptr, ptr %t49
  %t54 = load ptr, ptr %t52
  %t55 = call ptr @fn_emit_gep_i8(ptr %t53, ptr %t54)
  store ptr %t55, ptr %t56
  %t57 = load ptr, ptr %t56
  %t58 = call ptr @fn_sconcat(ptr @.str334, ptr %t57)
  %t59 = call ptr @fn_emit_bind(ptr %t58)
  store ptr %t59, ptr %t60
  %t61 = load ptr, ptr %t60
  %t62 = call ptr @fn_sconcat(ptr %t61, ptr @.str336)
  %t63 = call ptr @fn_sconcat(ptr @.str335, ptr %t62)
  %t64 = call ptr @fn_emit_bind(ptr %t63)
  %t65 = call ptr @fn_val(ptr %t64, ptr @.str337)
  store ptr %t65, ptr %retval
  br label %ret
ifend11:
  %t66 = load ptr, ptr %t0
  %t67 = call i32 @fn_streq(ptr %t66, ptr @.str338)
  %t68 = icmp ne i32 %t67, 0
  br i1 %t68, label %then12, label %ifend14
then12:
  %t69 = load ptr, ptr %t1
  %t70 = call ptr @fn_arg_code(ptr %t69, i32 0)
  store ptr %t70, ptr %t71
  %t72 = load ptr, ptr %t1
  %t73 = call ptr @fn_arg_code(ptr %t72, i32 1)
  store ptr %t73, ptr %t74
  %t75 = load ptr, ptr %t1
  %t76 = call ptr @fn_arg_code(ptr %t75, i32 2)
  store ptr %t76, ptr %t77
  %t78 = load ptr, ptr %t71
  %t79 = load ptr, ptr %t74
  %t80 = call ptr @fn_emit_gep_i8(ptr %t78, ptr %t79)
  store ptr %t80, ptr %t81
  %t82 = load ptr, ptr %t77
  %t83 = call ptr @fn_sconcat(ptr %t82, ptr @.str340)
  %t84 = call ptr @fn_sconcat(ptr @.str339, ptr %t83)
  %t85 = call ptr @fn_emit_bind(ptr %t84)
  store ptr %t85, ptr %t86
  call void @fn_emit(ptr @.str341)
  %t87 = load ptr, ptr %t86
  call void @fn_emit(ptr %t87)
  call void @fn_emit(ptr @.str342)
  %t88 = load ptr, ptr %t81
  call void @fn_emit(ptr %t88)
  call void @fn_emit(ptr @.str343)
  %t89 = call ptr @fn_val(ptr @.str344, ptr @.str345)
  store ptr %t89, ptr %retval
  br label %ret
ifend14:
  %t90 = load ptr, ptr %t0
  %t91 = call i32 @fn_streq(ptr %t90, ptr @.str346)
  %t92 = icmp ne i32 %t91, 0
  br i1 %t92, label %then15, label %ifend17
then15:
  %t93 = load ptr, ptr %t1
  %t94 = call ptr @fn_arg_code(ptr %t93, i32 0)
  store ptr %t94, ptr %t95
  %t96 = load ptr, ptr %t95
  %t97 = call ptr @fn_sconcat(ptr %t96, ptr @.str348)
  %t98 = call ptr @fn_sconcat(ptr @.str347, ptr %t97)
  %t99 = call ptr @fn_emit_bind(ptr %t98)
  store ptr %t99, ptr %t100
  %t101 = load ptr, ptr %t100
  %t102 = call ptr @fn_sconcat(ptr %t101, ptr @.str350)
  %t103 = call ptr @fn_sconcat(ptr @.str349, ptr %t102)
  %t104 = call ptr @fn_emit_bind(ptr %t103)
  %t105 = call ptr @fn_val(ptr %t104, ptr @.str351)
  store ptr %t105, ptr %retval
  br label %ret
ifend17:
  %t106 = load ptr, ptr %t0
  %t107 = call i32 @fn_streq(ptr %t106, ptr @.str352)
  %t108 = icmp ne i32 %t107, 0
  br i1 %t108, label %then18, label %ifend20
then18:
  %t109 = load ptr, ptr %t1
  %t110 = call ptr @fn_arg_code(ptr %t109, i32 0)
  store ptr %t110, ptr %t111
  %t112 = load ptr, ptr %t1
  %t113 = call ptr @fn_arg_code(ptr %t112, i32 1)
  store ptr %t113, ptr %t114
  %t115 = load ptr, ptr %t111
  %t116 = load ptr, ptr %t114
  %t117 = call ptr @fn_sconcat(ptr %t116, ptr @.str355)
  %t118 = call ptr @fn_sconcat(ptr @.str354, ptr %t117)
  %t119 = call ptr @fn_sconcat(ptr %t115, ptr %t118)
  %t120 = call ptr @fn_sconcat(ptr @.str353, ptr %t119)
  %t121 = call ptr @fn_emit_bind(ptr %t120)
  %t122 = call ptr @fn_val(ptr %t121, ptr @.str356)
  store ptr %t122, ptr %retval
  br label %ret
ifend20:
  %t124 = load ptr, ptr %t0
  %t125 = call i32 @fn_streq(ptr %t124, ptr @.str357)
  %t126 = icmp ne i32 %t125, 0
  %t127 = zext i1 %t126 to i32
  store i32 %t127, ptr %t123
  br i1 %t126, label %scend22, label %sc21
sc21:
  %t128 = load ptr, ptr %t0
  %t129 = call i32 @fn_streq(ptr %t128, ptr @.str358)
  %t130 = icmp ne i32 %t129, 0
  %t131 = zext i1 %t130 to i32
  store i32 %t131, ptr %t123
  br label %scend22
scend22:
  %t132 = load i32, ptr %t123
  %t133 = icmp ne i32 %t132, 0
  br i1 %t133, label %then23, label %ifend25
then23:
  %t134 = load ptr, ptr %t1
  %t135 = call ptr @fn_arg_code(ptr %t134, i32 0)
  store ptr %t135, ptr %t136
  %t137 = load ptr, ptr %t1
  %t138 = call ptr @fn_arg_code(ptr %t137, i32 1)
  store ptr %t138, ptr %t139
  %t140 = load ptr, ptr %t1
  %t141 = call ptr @fn_arg_code(ptr %t140, i32 2)
  store ptr %t141, ptr %t142
  %t143 = load ptr, ptr %t142
  %t144 = call ptr @fn_sconcat(ptr %t143, ptr @.str360)
  %t145 = call ptr @fn_sconcat(ptr @.str359, ptr %t144)
  %t146 = call ptr @fn_emit_bind(ptr %t145)
  store ptr %t146, ptr %t147
  store ptr @.str361, ptr %t148
  %t149 = load ptr, ptr %t0
  %t150 = call i32 @fn_streq(ptr %t149, ptr @.str362)
  %t151 = icmp ne i32 %t150, 0
  br i1 %t151, label %then26, label %ifend28
then26:
  store ptr @.str363, ptr %t148
  br label %ifend28
ifend28:
  %t152 = load ptr, ptr %t148
  %t153 = load ptr, ptr %t139
  %t154 = load ptr, ptr %t147
  %t155 = load ptr, ptr %t136
  %t156 = call ptr @fn_sconcat(ptr %t155, ptr @.str368)
  %t157 = call ptr @fn_sconcat(ptr @.str367, ptr %t156)
  %t158 = call ptr @fn_sconcat(ptr %t154, ptr %t157)
  %t159 = call ptr @fn_sconcat(ptr @.str366, ptr %t158)
  %t160 = call ptr @fn_sconcat(ptr %t153, ptr %t159)
  %t161 = call ptr @fn_sconcat(ptr @.str365, ptr %t160)
  %t162 = call ptr @fn_sconcat(ptr %t152, ptr %t161)
  %t163 = call ptr @fn_sconcat(ptr @.str364, ptr %t162)
  %t164 = call ptr @fn_emit_bind(ptr %t163)
  store ptr %t164, ptr %t165
  %t166 = load ptr, ptr %t165
  %t167 = call ptr @fn_sconcat(ptr %t166, ptr @.str370)
  %t168 = call ptr @fn_sconcat(ptr @.str369, ptr %t167)
  %t169 = call ptr @fn_emit_bind(ptr %t168)
  %t170 = call ptr @fn_val(ptr %t169, ptr @.str371)
  store ptr %t170, ptr %retval
  br label %ret
ifend25:
  %t171 = load ptr, ptr %t0
  %t172 = call i32 @fn_streq(ptr %t171, ptr @.str372)
  %t173 = icmp ne i32 %t172, 0
  br i1 %t173, label %then29, label %ifend31
then29:
  %t174 = load ptr, ptr %t1
  %t175 = call ptr @fn_arg_code(ptr %t174, i32 0)
  store ptr %t175, ptr %t176
  %t177 = load ptr, ptr %t1
  %t178 = call ptr @fn_arg_code(ptr %t177, i32 1)
  store ptr %t178, ptr %t179
  %t180 = load ptr, ptr %t1
  %t181 = call ptr @fn_arg_code(ptr %t180, i32 2)
  store ptr %t181, ptr %t182
  %t183 = load ptr, ptr %t179
  %t184 = call ptr @fn_sconcat(ptr %t183, ptr @.str374)
  %t185 = call ptr @fn_sconcat(ptr @.str373, ptr %t184)
  %t186 = call ptr @fn_emit_bind(ptr %t185)
  store ptr %t186, ptr %t187
  %t188 = load ptr, ptr %t176
  %t189 = load ptr, ptr %t187
  %t190 = load ptr, ptr %t182
  %t191 = call ptr @fn_sconcat(ptr %t190, ptr @.str378)
  %t192 = call ptr @fn_sconcat(ptr @.str377, ptr %t191)
  %t193 = call ptr @fn_sconcat(ptr %t189, ptr %t192)
  %t194 = call ptr @fn_sconcat(ptr @.str376, ptr %t193)
  %t195 = call ptr @fn_sconcat(ptr %t188, ptr %t194)
  %t196 = call ptr @fn_sconcat(ptr @.str375, ptr %t195)
  %t197 = call ptr @fn_emit_bind(ptr %t196)
  %t198 = call ptr @fn_val(ptr %t197, ptr @.str379)
  store ptr %t198, ptr %retval
  br label %ret
ifend31:
  %t199 = load ptr, ptr %t0
  %t200 = call i32 @fn_streq(ptr %t199, ptr @.str380)
  %t201 = icmp ne i32 %t200, 0
  br i1 %t201, label %then32, label %ifend34
then32:
  %t202 = load ptr, ptr %t1
  %t203 = call ptr @fn_arg_code(ptr %t202, i32 0)
  store ptr %t203, ptr %t204
  %t205 = load ptr, ptr %t204
  %t206 = call ptr @fn_sconcat(ptr %t205, ptr @.str382)
  %t207 = call ptr @fn_sconcat(ptr @.str381, ptr %t206)
  %t208 = call ptr @fn_emit_bind(ptr %t207)
  store ptr %t208, ptr %t209
  %t210 = load ptr, ptr %t209
  %t211 = call ptr @fn_sconcat(ptr %t210, ptr @.str384)
  %t212 = call ptr @fn_sconcat(ptr @.str383, ptr %t211)
  %t213 = call ptr @fn_emit_bind(ptr %t212)
  %t214 = call ptr @fn_val(ptr %t213, ptr @.str385)
  store ptr %t214, ptr %retval
  br label %ret
ifend34:
  %t215 = load ptr, ptr %t0
  %t216 = call i32 @fn_streq(ptr %t215, ptr @.str386)
  %t217 = icmp ne i32 %t216, 0
  br i1 %t217, label %then35, label %ifend37
then35:
  %t218 = load ptr, ptr %t1
  %t219 = call ptr @fn_arg_code(ptr %t218, i32 0)
  store ptr %t219, ptr %t220
  call void @fn_emit(ptr @.str387)
  %t221 = load ptr, ptr %t220
  call void @fn_emit(ptr %t221)
  call void @fn_emit(ptr @.str388)
  %t222 = call ptr @fn_val(ptr @.str389, ptr @.str390)
  store ptr %t222, ptr %retval
  br label %ret
ifend37:
  %t223 = load ptr, ptr %t0
  %t224 = call i32 @fn_streq(ptr %t223, ptr @.str391)
  %t225 = icmp ne i32 %t224, 0
  br i1 %t225, label %then38, label %ifend40
then38:
  %t226 = load ptr, ptr %t1
  %t227 = call ptr @fn_arg_code(ptr %t226, i32 0)
  store ptr %t227, ptr %t228
  call void @fn_emit(ptr @.str392)
  %t229 = load ptr, ptr %t228
  call void @fn_emit(ptr %t229)
  call void @fn_emit(ptr @.str393)
  %t230 = call ptr @fn_val(ptr @.str394, ptr @.str395)
  store ptr %t230, ptr %retval
  br label %ret
ifend40:
  %t231 = load ptr, ptr %t0
  %t232 = call i32 @fn_streq(ptr %t231, ptr @.str396)
  %t233 = icmp ne i32 %t232, 0
  br i1 %t233, label %then41, label %ifend43
then41:
  %t234 = load ptr, ptr %t1
  %t235 = call ptr @fn_arg_code(ptr %t234, i32 0)
  store ptr %t235, ptr %t236
  call void @fn_emit(ptr @.str397)
  %t237 = load ptr, ptr %t236
  call void @fn_emit(ptr %t237)
  call void @fn_emit(ptr @.str398)
  %t238 = call ptr @fn_val(ptr @.str399, ptr @.str400)
  store ptr %t238, ptr %retval
  br label %ret
ifend43:
  %t239 = load ptr, ptr %t0
  %t240 = call i32 @fn_streq(ptr %t239, ptr @.str401)
  %t241 = icmp ne i32 %t240, 0
  br i1 %t241, label %then44, label %ifend46
then44:
  %t242 = call ptr @fn_emit_bind(ptr @.str402)
  %t243 = call ptr @fn_val(ptr %t242, ptr @.str403)
  store ptr %t243, ptr %retval
  br label %ret
ifend46:
  %t244 = load ptr, ptr %t0
  %t245 = call i32 @fn_streq(ptr %t244, ptr @.str404)
  %t246 = icmp ne i32 %t245, 0
  br i1 %t246, label %then47, label %ifend49
then47:
  %t247 = load ptr, ptr %t1
  %t248 = call ptr @fn_arg_code(ptr %t247, i32 0)
  store ptr %t248, ptr %t249
  %t250 = call ptr @fn_emit_bind(ptr @.str405)
  store ptr %t250, ptr %t251
  %t252 = load ptr, ptr %t251
  %t253 = load ptr, ptr %t249
  %t254 = call ptr @fn_sconcat(ptr @.str407, ptr %t253)
  %t255 = call ptr @fn_sconcat(ptr %t252, ptr %t254)
  %t256 = call ptr @fn_sconcat(ptr @.str406, ptr %t255)
  %t257 = call ptr @fn_emit_bind(ptr %t256)
  store ptr %t257, ptr %t258
  %t259 = load ptr, ptr %t258
  %t260 = call ptr @fn_sconcat(ptr @.str408, ptr %t259)
  %t261 = call ptr @fn_emit_bind(ptr %t260)
  %t262 = call ptr @fn_val(ptr %t261, ptr @.str409)
  store ptr %t262, ptr %retval
  br label %ret
ifend49:
  %t263 = load ptr, ptr %t0
  %t264 = call i32 @fn_streq(ptr %t263, ptr @.str410)
  %t265 = icmp ne i32 %t264, 0
  br i1 %t265, label %then50, label %ifend52
then50:
  %t266 = load ptr, ptr %t1
  %t267 = call ptr @fn_arg_code(ptr %t266, i32 0)
  store ptr %t267, ptr %t268
  call void @fn_emit(ptr @.str411)
  %t269 = load ptr, ptr %t268
  call void @fn_emit(ptr %t269)
  call void @fn_emit(ptr @.str412)
  call void @fn_emit(ptr @.str413)
  store i32 1, ptr @g_g_term
  %t270 = call ptr @fn_val(ptr @.str414, ptr @.str415)
  store ptr %t270, ptr %retval
  br label %ret
ifend52:
  %t271 = load ptr, ptr %t0
  %t272 = call i32 @fn_streq(ptr %t271, ptr @.str416)
  %t273 = icmp ne i32 %t272, 0
  br i1 %t273, label %then53, label %ifend55
then53:
  %t274 = call ptr @fn_emit_bind(ptr @.str417)
  %t275 = call ptr @fn_val(ptr %t274, ptr @.str418)
  store ptr %t275, ptr %retval
  br label %ret
ifend55:
  %t276 = load ptr, ptr %t0
  %t277 = call i32 @fn_streq(ptr %t276, ptr @.str419)
  %t278 = icmp ne i32 %t277, 0
  br i1 %t278, label %then56, label %ifend58
then56:
  %t279 = load ptr, ptr %t1
  %t280 = call ptr @fn_arg_code(ptr %t279, i32 0)
  store ptr %t280, ptr %t281
  %t282 = load ptr, ptr %t281
  %t283 = call ptr @fn_sconcat(ptr %t282, ptr @.str421)
  %t284 = call ptr @fn_sconcat(ptr @.str420, ptr %t283)
  %t285 = call ptr @fn_emit_bind(ptr %t284)
  %t286 = call ptr @fn_val(ptr %t285, ptr @.str422)
  store ptr %t286, ptr %retval
  br label %ret
ifend58:
  %t287 = load ptr, ptr %t0
  %t288 = call i32 @fn_streq(ptr %t287, ptr @.str423)
  %t289 = icmp ne i32 %t288, 0
  br i1 %t289, label %then59, label %ifend61
then59:
  %t290 = load ptr, ptr %t1
  %t291 = call ptr @fn_arg_code(ptr %t290, i32 0)
  store ptr %t291, ptr %t292
  %t293 = load ptr, ptr %t292
  %t294 = call ptr @fn_sconcat(ptr %t293, ptr @.str425)
  %t295 = call ptr @fn_sconcat(ptr @.str424, ptr %t294)
  %t296 = call ptr @fn_emit_bind(ptr %t295)
  %t297 = call ptr @fn_val(ptr %t296, ptr @.str426)
  store ptr %t297, ptr %retval
  br label %ret
ifend61:
  %t298 = load ptr, ptr %t0
  %t299 = call i32 @fn_streq(ptr %t298, ptr @.str427)
  %t300 = icmp ne i32 %t299, 0
  br i1 %t300, label %then62, label %ifend64
then62:
  %t301 = load ptr, ptr %t1
  %t302 = call ptr @fn_arg_code(ptr %t301, i32 0)
  store ptr %t302, ptr %t303
  %t304 = load ptr, ptr %t303
  %t305 = call ptr @fn_sconcat(ptr %t304, ptr @.str429)
  %t306 = call ptr @fn_sconcat(ptr @.str428, ptr %t305)
  %t307 = call ptr @fn_emit_bind(ptr %t306)
  %t308 = call ptr @fn_val(ptr %t307, ptr @.str430)
  store ptr %t308, ptr %retval
  br label %ret
ifend64:
  %t313 = load ptr, ptr %t0
  %t314 = call i32 @fn_streq(ptr %t313, ptr @.str431)
  %t315 = icmp ne i32 %t314, 0
  %t316 = zext i1 %t315 to i32
  store i32 %t316, ptr %t312
  br i1 %t315, label %scend66, label %sc65
sc65:
  %t317 = load ptr, ptr %t0
  %t318 = call i32 @fn_streq(ptr %t317, ptr @.str432)
  %t319 = icmp ne i32 %t318, 0
  %t320 = zext i1 %t319 to i32
  store i32 %t320, ptr %t312
  br label %scend66
scend66:
  %t321 = load i32, ptr %t312
  %t322 = icmp ne i32 %t321, 0
  %t323 = zext i1 %t322 to i32
  store i32 %t323, ptr %t311
  br i1 %t322, label %scend68, label %sc67
sc67:
  %t324 = load ptr, ptr %t0
  %t325 = call i32 @fn_streq(ptr %t324, ptr @.str433)
  %t326 = icmp ne i32 %t325, 0
  %t327 = zext i1 %t326 to i32
  store i32 %t327, ptr %t311
  br label %scend68
scend68:
  %t328 = load i32, ptr %t311
  %t329 = icmp ne i32 %t328, 0
  %t330 = zext i1 %t329 to i32
  store i32 %t330, ptr %t310
  br i1 %t329, label %scend70, label %sc69
sc69:
  %t331 = load ptr, ptr %t0
  %t332 = call i32 @fn_streq(ptr %t331, ptr @.str434)
  %t333 = icmp ne i32 %t332, 0
  %t334 = zext i1 %t333 to i32
  store i32 %t334, ptr %t310
  br label %scend70
scend70:
  %t335 = load i32, ptr %t310
  %t336 = icmp ne i32 %t335, 0
  %t337 = zext i1 %t336 to i32
  store i32 %t337, ptr %t309
  br i1 %t336, label %scend72, label %sc71
sc71:
  %t338 = load ptr, ptr %t0
  %t339 = call i32 @fn_streq(ptr %t338, ptr @.str435)
  %t340 = icmp ne i32 %t339, 0
  %t341 = zext i1 %t340 to i32
  store i32 %t341, ptr %t309
  br label %scend72
scend72:
  %t342 = load i32, ptr %t309
  %t343 = icmp ne i32 %t342, 0
  br i1 %t343, label %then73, label %ifend75
then73:
  %t344 = load ptr, ptr %t1
  %t345 = call ptr @fn_arg_code(ptr %t344, i32 0)
  store ptr %t345, ptr %t346
  %t347 = load ptr, ptr %t1
  %t348 = call ptr @fn_arg_code(ptr %t347, i32 1)
  store ptr %t348, ptr %t349
  store ptr @.str436, ptr %t350
  %t351 = load ptr, ptr %t0
  %t352 = call i32 @fn_streq(ptr %t351, ptr @.str437)
  %t353 = icmp ne i32 %t352, 0
  br i1 %t353, label %then76, label %ifend78
then76:
  store ptr @.str438, ptr %t350
  br label %ifend78
ifend78:
  %t354 = load ptr, ptr %t0
  %t355 = call i32 @fn_streq(ptr %t354, ptr @.str439)
  %t356 = icmp ne i32 %t355, 0
  br i1 %t356, label %then79, label %ifend81
then79:
  store ptr @.str440, ptr %t350
  br label %ifend81
ifend81:
  %t357 = load ptr, ptr %t0
  %t358 = call i32 @fn_streq(ptr %t357, ptr @.str441)
  %t359 = icmp ne i32 %t358, 0
  br i1 %t359, label %then82, label %ifend84
then82:
  store ptr @.str442, ptr %t350
  br label %ifend84
ifend84:
  %t360 = load ptr, ptr %t0
  %t361 = call i32 @fn_streq(ptr %t360, ptr @.str443)
  %t362 = icmp ne i32 %t361, 0
  br i1 %t362, label %then85, label %ifend87
then85:
  store ptr @.str444, ptr %t350
  br label %ifend87
ifend87:
  %t363 = load ptr, ptr %t350
  %t364 = load ptr, ptr %t346
  %t365 = load ptr, ptr %t349
  %t366 = call ptr @fn_sconcat(ptr @.str446, ptr %t365)
  %t367 = call ptr @fn_sconcat(ptr %t364, ptr %t366)
  %t368 = call ptr @fn_sconcat(ptr @.str445, ptr %t367)
  %t369 = call ptr @fn_sconcat(ptr %t363, ptr %t368)
  %t370 = call ptr @fn_emit_bind(ptr %t369)
  %t371 = call ptr @fn_val(ptr %t370, ptr @.str447)
  store ptr %t371, ptr %retval
  br label %ret
ifend75:
  %t372 = load ptr, ptr %t0
  %t373 = call i32 @fn_streq(ptr %t372, ptr @.str448)
  %t374 = icmp ne i32 %t373, 0
  br i1 %t374, label %then88, label %ifend90
then88:
  %t375 = load ptr, ptr %t1
  %t376 = call ptr @fn_arg_code(ptr %t375, i32 0)
  store ptr %t376, ptr %t377
  %t378 = load ptr, ptr %t1
  %t379 = call ptr @fn_arg_code(ptr %t378, i32 1)
  store ptr %t379, ptr %t380
  %t381 = call ptr @fn_nreg()
  store ptr %t381, ptr %t382
  call void @fn_emit(ptr @.str449)
  %t383 = load ptr, ptr %t382
  call void @fn_emit(ptr %t383)
  call void @fn_emit(ptr @.str450)
  %t384 = load ptr, ptr %t377
  call void @fn_emit(ptr %t384)
  call void @fn_emit(ptr @.str451)
  %t385 = load ptr, ptr %t380
  call void @fn_emit(ptr %t385)
  call void @fn_emit(ptr @.str452)
  %t386 = load ptr, ptr %t382
  %t387 = call ptr @fn_sconcat(ptr @.str453, ptr %t386)
  %t388 = call ptr @fn_emit_bind(ptr %t387)
  %t389 = call ptr @fn_val(ptr %t388, ptr @.str454)
  store ptr %t389, ptr %retval
  br label %ret
ifend90:
  %t390 = load ptr, ptr %t0
  %t391 = call i32 @fn_streq(ptr %t390, ptr @.str455)
  %t392 = icmp ne i32 %t391, 0
  br i1 %t392, label %then91, label %ifend93
then91:
  %t393 = load ptr, ptr %t1
  %t394 = call ptr @fn_arg_code(ptr %t393, i32 0)
  store ptr %t394, ptr %t395
  %t396 = load ptr, ptr %t1
  %t397 = call ptr @fn_arg_code(ptr %t396, i32 1)
  store ptr %t397, ptr %t398
  %t399 = load ptr, ptr %t1
  %t400 = call ptr @fn_arg_code(ptr %t399, i32 2)
  store ptr %t400, ptr %t401
  %t402 = call ptr @fn_nreg()
  store ptr %t402, ptr %t403
  call void @fn_emit(ptr @.str456)
  %t404 = load ptr, ptr %t403
  call void @fn_emit(ptr %t404)
  call void @fn_emit(ptr @.str457)
  %t405 = load ptr, ptr %t395
  call void @fn_emit(ptr %t405)
  call void @fn_emit(ptr @.str458)
  %t406 = load ptr, ptr %t398
  call void @fn_emit(ptr %t406)
  call void @fn_emit(ptr @.str459)
  call void @fn_emit(ptr @.str460)
  %t407 = load ptr, ptr %t401
  call void @fn_emit(ptr %t407)
  call void @fn_emit(ptr @.str461)
  %t408 = load ptr, ptr %t403
  call void @fn_emit(ptr %t408)
  call void @fn_emit(ptr @.str462)
  %t409 = call ptr @fn_val(ptr @.str463, ptr @.str464)
  store ptr %t409, ptr %retval
  br label %ret
ifend93:
  store i32 0, ptr @g_g_intrin_ok
  %t410 = call ptr @fn_val(ptr @.str465, ptr @.str466)
  store ptr %t410, ptr %retval
  br label %ret
ret:
  %t411 = load ptr, ptr %retval
  ret ptr %t411
}

define i32 @fn_is_intrinsic2(ptr %arg_name) {
entry:
  %retval = alloca i32
  %t0 = alloca ptr
  %t1 = alloca i32
  %t2 = alloca i32
  %t20 = alloca i32
  %t21 = alloca i32
  %t39 = alloca i32
  %t50 = alloca i32
  %t51 = alloca i32
  %t52 = alloca i32
  %t77 = alloca i32
  %t88 = alloca i32
  %t99 = alloca i32
  %t100 = alloca i32
  %t118 = alloca i32
  store ptr %arg_name, ptr %t0
  %t3 = load ptr, ptr %t0
  %t4 = call i32 @fn_streq(ptr %t3, ptr @.str467)
  %t5 = icmp ne i32 %t4, 0
  %t6 = zext i1 %t5 to i32
  store i32 %t6, ptr %t2
  br i1 %t5, label %scend1, label %sc0
sc0:
  %t7 = load ptr, ptr %t0
  %t8 = call i32 @fn_streq(ptr %t7, ptr @.str468)
  %t9 = icmp ne i32 %t8, 0
  %t10 = zext i1 %t9 to i32
  store i32 %t10, ptr %t2
  br label %scend1
scend1:
  %t11 = load i32, ptr %t2
  %t12 = icmp ne i32 %t11, 0
  %t13 = zext i1 %t12 to i32
  store i32 %t13, ptr %t1
  br i1 %t12, label %scend3, label %sc2
sc2:
  %t14 = load ptr, ptr %t0
  %t15 = call i32 @fn_streq(ptr %t14, ptr @.str469)
  %t16 = icmp ne i32 %t15, 0
  %t17 = zext i1 %t16 to i32
  store i32 %t17, ptr %t1
  br label %scend3
scend3:
  %t18 = load i32, ptr %t1
  %t19 = icmp ne i32 %t18, 0
  br i1 %t19, label %then4, label %ifend6
then4:
  store i32 1, ptr %retval
  br label %ret
ifend6:
  %t22 = load ptr, ptr %t0
  %t23 = call i32 @fn_streq(ptr %t22, ptr @.str470)
  %t24 = icmp ne i32 %t23, 0
  %t25 = zext i1 %t24 to i32
  store i32 %t25, ptr %t21
  br i1 %t24, label %scend8, label %sc7
sc7:
  %t26 = load ptr, ptr %t0
  %t27 = call i32 @fn_streq(ptr %t26, ptr @.str471)
  %t28 = icmp ne i32 %t27, 0
  %t29 = zext i1 %t28 to i32
  store i32 %t29, ptr %t21
  br label %scend8
scend8:
  %t30 = load i32, ptr %t21
  %t31 = icmp ne i32 %t30, 0
  %t32 = zext i1 %t31 to i32
  store i32 %t32, ptr %t20
  br i1 %t31, label %scend10, label %sc9
sc9:
  %t33 = load ptr, ptr %t0
  %t34 = call i32 @fn_streq(ptr %t33, ptr @.str472)
  %t35 = icmp ne i32 %t34, 0
  %t36 = zext i1 %t35 to i32
  store i32 %t36, ptr %t20
  br label %scend10
scend10:
  %t37 = load i32, ptr %t20
  %t38 = icmp ne i32 %t37, 0
  br i1 %t38, label %then11, label %ifend13
then11:
  store i32 1, ptr %retval
  br label %ret
ifend13:
  %t40 = load ptr, ptr %t0
  %t41 = call i32 @fn_streq(ptr %t40, ptr @.str473)
  %t42 = icmp ne i32 %t41, 0
  %t43 = zext i1 %t42 to i32
  store i32 %t43, ptr %t39
  br i1 %t42, label %scend15, label %sc14
sc14:
  %t44 = load ptr, ptr %t0
  %t45 = call i32 @fn_streq(ptr %t44, ptr @.str474)
  %t46 = icmp ne i32 %t45, 0
  %t47 = zext i1 %t46 to i32
  store i32 %t47, ptr %t39
  br label %scend15
scend15:
  %t48 = load i32, ptr %t39
  %t49 = icmp ne i32 %t48, 0
  br i1 %t49, label %then16, label %ifend18
then16:
  store i32 1, ptr %retval
  br label %ret
ifend18:
  %t53 = load ptr, ptr %t0
  %t54 = call i32 @fn_streq(ptr %t53, ptr @.str475)
  %t55 = icmp ne i32 %t54, 0
  %t56 = zext i1 %t55 to i32
  store i32 %t56, ptr %t52
  br i1 %t55, label %scend20, label %sc19
sc19:
  %t57 = load ptr, ptr %t0
  %t58 = call i32 @fn_streq(ptr %t57, ptr @.str476)
  %t59 = icmp ne i32 %t58, 0
  %t60 = zext i1 %t59 to i32
  store i32 %t60, ptr %t52
  br label %scend20
scend20:
  %t61 = load i32, ptr %t52
  %t62 = icmp ne i32 %t61, 0
  %t63 = zext i1 %t62 to i32
  store i32 %t63, ptr %t51
  br i1 %t62, label %scend22, label %sc21
sc21:
  %t64 = load ptr, ptr %t0
  %t65 = call i32 @fn_streq(ptr %t64, ptr @.str477)
  %t66 = icmp ne i32 %t65, 0
  %t67 = zext i1 %t66 to i32
  store i32 %t67, ptr %t51
  br label %scend22
scend22:
  %t68 = load i32, ptr %t51
  %t69 = icmp ne i32 %t68, 0
  %t70 = zext i1 %t69 to i32
  store i32 %t70, ptr %t50
  br i1 %t69, label %scend24, label %sc23
sc23:
  %t71 = load ptr, ptr %t0
  %t72 = call i32 @fn_streq(ptr %t71, ptr @.str478)
  %t73 = icmp ne i32 %t72, 0
  %t74 = zext i1 %t73 to i32
  store i32 %t74, ptr %t50
  br label %scend24
scend24:
  %t75 = load i32, ptr %t50
  %t76 = icmp ne i32 %t75, 0
  br i1 %t76, label %then25, label %ifend27
then25:
  store i32 1, ptr %retval
  br label %ret
ifend27:
  %t78 = load ptr, ptr %t0
  %t79 = call i32 @fn_streq(ptr %t78, ptr @.str479)
  %t80 = icmp ne i32 %t79, 0
  %t81 = zext i1 %t80 to i32
  store i32 %t81, ptr %t77
  br i1 %t80, label %scend29, label %sc28
sc28:
  %t82 = load ptr, ptr %t0
  %t83 = call i32 @fn_streq(ptr %t82, ptr @.str480)
  %t84 = icmp ne i32 %t83, 0
  %t85 = zext i1 %t84 to i32
  store i32 %t85, ptr %t77
  br label %scend29
scend29:
  %t86 = load i32, ptr %t77
  %t87 = icmp ne i32 %t86, 0
  br i1 %t87, label %then30, label %ifend32
then30:
  store i32 1, ptr %retval
  br label %ret
ifend32:
  %t89 = load ptr, ptr %t0
  %t90 = call i32 @fn_streq(ptr %t89, ptr @.str481)
  %t91 = icmp ne i32 %t90, 0
  %t92 = zext i1 %t91 to i32
  store i32 %t92, ptr %t88
  br i1 %t91, label %scend34, label %sc33
sc33:
  %t93 = load ptr, ptr %t0
  %t94 = call i32 @fn_streq(ptr %t93, ptr @.str482)
  %t95 = icmp ne i32 %t94, 0
  %t96 = zext i1 %t95 to i32
  store i32 %t96, ptr %t88
  br label %scend34
scend34:
  %t97 = load i32, ptr %t88
  %t98 = icmp ne i32 %t97, 0
  br i1 %t98, label %then35, label %ifend37
then35:
  store i32 1, ptr %retval
  br label %ret
ifend37:
  %t101 = load ptr, ptr %t0
  %t102 = call i32 @fn_streq(ptr %t101, ptr @.str483)
  %t103 = icmp ne i32 %t102, 0
  %t104 = zext i1 %t103 to i32
  store i32 %t104, ptr %t100
  br i1 %t103, label %scend39, label %sc38
sc38:
  %t105 = load ptr, ptr %t0
  %t106 = call i32 @fn_streq(ptr %t105, ptr @.str484)
  %t107 = icmp ne i32 %t106, 0
  %t108 = zext i1 %t107 to i32
  store i32 %t108, ptr %t100
  br label %scend39
scend39:
  %t109 = load i32, ptr %t100
  %t110 = icmp ne i32 %t109, 0
  %t111 = zext i1 %t110 to i32
  store i32 %t111, ptr %t99
  br i1 %t110, label %scend41, label %sc40
sc40:
  %t112 = load ptr, ptr %t0
  %t113 = call i32 @fn_streq(ptr %t112, ptr @.str485)
  %t114 = icmp ne i32 %t113, 0
  %t115 = zext i1 %t114 to i32
  store i32 %t115, ptr %t99
  br label %scend41
scend41:
  %t116 = load i32, ptr %t99
  %t117 = icmp ne i32 %t116, 0
  br i1 %t117, label %then42, label %ifend44
then42:
  store i32 1, ptr %retval
  br label %ret
ifend44:
  %t119 = load ptr, ptr %t0
  %t120 = call i32 @fn_streq(ptr %t119, ptr @.str486)
  %t121 = icmp ne i32 %t120, 0
  %t122 = zext i1 %t121 to i32
  store i32 %t122, ptr %t118
  br i1 %t121, label %scend46, label %sc45
sc45:
  %t123 = load ptr, ptr %t0
  %t124 = call i32 @fn_streq(ptr %t123, ptr @.str487)
  %t125 = icmp ne i32 %t124, 0
  %t126 = zext i1 %t125 to i32
  store i32 %t126, ptr %t118
  br label %scend46
scend46:
  %t127 = load i32, ptr %t118
  %t128 = icmp ne i32 %t127, 0
  br i1 %t128, label %then47, label %ifend49
then47:
  store i32 1, ptr %retval
  br label %ret
ifend49:
  store i32 0, ptr %retval
  br label %ret
ret:
  %t129 = load i32, ptr %retval
  ret i32 %t129
}

define ptr @fn_emit_intrinsic2(ptr %arg_name, ptr %arg_e) {
entry:
  %retval = alloca ptr
  %t0 = alloca ptr
  %t1 = alloca ptr
  %t7 = alloca ptr
  %t15 = alloca ptr
  %t18 = alloca ptr
  %t21 = alloca ptr
  %t26 = alloca ptr
  %t36 = alloca ptr
  %t39 = alloca ptr
  %t42 = alloca ptr
  %t47 = alloca ptr
  %t57 = alloca ptr
  %t60 = alloca ptr
  %t62 = alloca ptr
  %t78 = alloca ptr
  %t86 = alloca ptr
  %t91 = alloca ptr
  %t101 = alloca ptr
  %t112 = alloca ptr
  %t115 = alloca ptr
  %t117 = alloca ptr
  %t130 = alloca ptr
  %t133 = alloca ptr
  %t136 = alloca ptr
  %t138 = alloca ptr
  %t150 = alloca ptr
  %t153 = alloca ptr
  %t155 = alloca ptr
  %t168 = alloca ptr
  %t171 = alloca ptr
  %t174 = alloca ptr
  %t176 = alloca ptr
  %t194 = alloca ptr
  %t210 = alloca ptr
  %t241 = alloca ptr
  %t244 = alloca ptr
  %t247 = alloca ptr
  %t250 = alloca ptr
  %t261 = alloca ptr
  %t264 = alloca ptr
  %t267 = alloca ptr
  store ptr %arg_name, ptr %t0
  store ptr %arg_e, ptr %t1
  %t2 = load ptr, ptr %t0
  %t3 = call i32 @fn_streq(ptr %t2, ptr @.str488)
  %t4 = icmp ne i32 %t3, 0
  br i1 %t4, label %then0, label %ifend2
then0:
  %t5 = load ptr, ptr %t1
  %t6 = call ptr @fn_arg_code(ptr %t5, i32 0)
  store ptr %t6, ptr %t7
  call void @fn_emit(ptr @.str489)
  %t8 = load ptr, ptr %t7
  call void @fn_emit(ptr %t8)
  call void @fn_emit(ptr @.str490)
  %t9 = call ptr @fn_val(ptr @.str491, ptr @.str492)
  store ptr %t9, ptr %retval
  br label %ret
ifend2:
  %t10 = load ptr, ptr %t0
  %t11 = call i32 @fn_streq(ptr %t10, ptr @.str493)
  %t12 = icmp ne i32 %t11, 0
  br i1 %t12, label %then3, label %ifend5
then3:
  %t13 = load ptr, ptr %t1
  %t14 = call ptr @fn_arg_code(ptr %t13, i32 0)
  store ptr %t14, ptr %t15
  %t16 = load ptr, ptr %t1
  %t17 = call ptr @fn_arg_code(ptr %t16, i32 1)
  store ptr %t17, ptr %t18
  %t19 = load ptr, ptr %t1
  %t20 = call ptr @fn_arg_code(ptr %t19, i32 2)
  store ptr %t20, ptr %t21
  %t22 = load ptr, ptr %t21
  %t23 = call ptr @fn_sconcat(ptr %t22, ptr @.str495)
  %t24 = call ptr @fn_sconcat(ptr @.str494, ptr %t23)
  %t25 = call ptr @fn_emit_bind(ptr %t24)
  store ptr %t25, ptr %t26
  call void @fn_emit(ptr @.str496)
  %t27 = load ptr, ptr %t15
  call void @fn_emit(ptr %t27)
  call void @fn_emit(ptr @.str497)
  %t28 = load ptr, ptr %t18
  call void @fn_emit(ptr %t28)
  call void @fn_emit(ptr @.str498)
  %t29 = load ptr, ptr %t26
  call void @fn_emit(ptr %t29)
  call void @fn_emit(ptr @.str499)
  %t30 = call ptr @fn_val(ptr @.str500, ptr @.str501)
  store ptr %t30, ptr %retval
  br label %ret
ifend5:
  %t31 = load ptr, ptr %t0
  %t32 = call i32 @fn_streq(ptr %t31, ptr @.str502)
  %t33 = icmp ne i32 %t32, 0
  br i1 %t33, label %then6, label %ifend8
then6:
  %t34 = load ptr, ptr %t1
  %t35 = call ptr @fn_arg_code(ptr %t34, i32 0)
  store ptr %t35, ptr %t36
  %t37 = load ptr, ptr %t1
  %t38 = call ptr @fn_arg_code(ptr %t37, i32 1)
  store ptr %t38, ptr %t39
  %t40 = load ptr, ptr %t1
  %t41 = call ptr @fn_arg_code(ptr %t40, i32 2)
  store ptr %t41, ptr %t42
  %t43 = load ptr, ptr %t42
  %t44 = call ptr @fn_sconcat(ptr %t43, ptr @.str504)
  %t45 = call ptr @fn_sconcat(ptr @.str503, ptr %t44)
  %t46 = call ptr @fn_emit_bind(ptr %t45)
  store ptr %t46, ptr %t47
  call void @fn_emit(ptr @.str505)
  %t48 = load ptr, ptr %t36
  call void @fn_emit(ptr %t48)
  call void @fn_emit(ptr @.str506)
  %t49 = load ptr, ptr %t39
  call void @fn_emit(ptr %t49)
  call void @fn_emit(ptr @.str507)
  %t50 = load ptr, ptr %t47
  call void @fn_emit(ptr %t50)
  call void @fn_emit(ptr @.str508)
  %t51 = call ptr @fn_val(ptr @.str509, ptr @.str510)
  store ptr %t51, ptr %retval
  br label %ret
ifend8:
  %t52 = load ptr, ptr %t0
  %t53 = call i32 @fn_streq(ptr %t52, ptr @.str511)
  %t54 = icmp ne i32 %t53, 0
  br i1 %t54, label %then9, label %ifend11
then9:
  %t55 = load ptr, ptr %t1
  %t56 = call ptr @fn_arg_code(ptr %t55, i32 0)
  store ptr %t56, ptr %t57
  %t58 = load ptr, ptr %t1
  %t59 = call ptr @fn_arg_code(ptr %t58, i32 1)
  store ptr %t59, ptr %t60
  %t61 = call ptr @fn_nreg()
  store ptr %t61, ptr %t62
  call void @fn_emit(ptr @.str512)
  %t63 = load ptr, ptr %t62
  call void @fn_emit(ptr %t63)
  call void @fn_emit(ptr @.str513)
  %t64 = load ptr, ptr %t57
  call void @fn_emit(ptr %t64)
  call void @fn_emit(ptr @.str514)
  %t65 = load ptr, ptr %t60
  call void @fn_emit(ptr %t65)
  call void @fn_emit(ptr @.str515)
  %t66 = load ptr, ptr %t62
  %t67 = call ptr @fn_val(ptr %t66, ptr @.str516)
  store ptr %t67, ptr %retval
  br label %ret
ifend11:
  %t68 = load ptr, ptr %t0
  %t69 = call i32 @fn_streq(ptr %t68, ptr @.str517)
  %t70 = icmp ne i32 %t69, 0
  br i1 %t70, label %then12, label %ifend14
then12:
  %t71 = call ptr @fn_emit_bind(ptr @.str518)
  %t72 = call ptr @fn_val(ptr %t71, ptr @.str519)
  store ptr %t72, ptr %retval
  br label %ret
ifend14:
  %t73 = load ptr, ptr %t0
  %t74 = call i32 @fn_streq(ptr %t73, ptr @.str520)
  %t75 = icmp ne i32 %t74, 0
  br i1 %t75, label %then15, label %ifend17
then15:
  %t76 = load ptr, ptr %t1
  %t77 = call ptr @fn_arg_code(ptr %t76, i32 0)
  store ptr %t77, ptr %t78
  call void @fn_emit(ptr @.str521)
  %t79 = load ptr, ptr %t78
  call void @fn_emit(ptr %t79)
  call void @fn_emit(ptr @.str522)
  %t80 = call ptr @fn_val(ptr @.str523, ptr @.str524)
  store ptr %t80, ptr %retval
  br label %ret
ifend17:
  %t81 = load ptr, ptr %t0
  %t82 = call i32 @fn_streq(ptr %t81, ptr @.str525)
  %t83 = icmp ne i32 %t82, 0
  br i1 %t83, label %then18, label %ifend20
then18:
  %t84 = load ptr, ptr %t1
  %t85 = call ptr @fn_arg_code(ptr %t84, i32 0)
  store ptr %t85, ptr %t86
  %t87 = load ptr, ptr %t86
  %t88 = call ptr @fn_sconcat(ptr %t87, ptr @.str527)
  %t89 = call ptr @fn_sconcat(ptr @.str526, ptr %t88)
  %t90 = call ptr @fn_emit_bind(ptr %t89)
  store ptr %t90, ptr %t91
  %t92 = load ptr, ptr %t91
  %t93 = call ptr @fn_sconcat(ptr %t92, ptr @.str529)
  %t94 = call ptr @fn_sconcat(ptr @.str528, ptr %t93)
  %t95 = call ptr @fn_emit_bind(ptr %t94)
  %t96 = call ptr @fn_val(ptr %t95, ptr @.str530)
  store ptr %t96, ptr %retval
  br label %ret
ifend20:
  %t97 = load ptr, ptr %t0
  %t98 = call i32 @fn_streq(ptr %t97, ptr @.str531)
  %t99 = icmp ne i32 %t98, 0
  br i1 %t99, label %then21, label %ifend23
then21:
  %t100 = call ptr @fn_emit_bind(ptr @.str532)
  store ptr %t100, ptr %t101
  %t102 = load ptr, ptr %t101
  %t103 = call ptr @fn_sconcat(ptr %t102, ptr @.str534)
  %t104 = call ptr @fn_sconcat(ptr @.str533, ptr %t103)
  %t105 = call ptr @fn_emit_bind(ptr %t104)
  %t106 = call ptr @fn_val(ptr %t105, ptr @.str535)
  store ptr %t106, ptr %retval
  br label %ret
ifend23:
  %t107 = load ptr, ptr %t0
  %t108 = call i32 @fn_streq(ptr %t107, ptr @.str536)
  %t109 = icmp ne i32 %t108, 0
  br i1 %t109, label %then24, label %ifend26
then24:
  %t110 = load ptr, ptr %t1
  %t111 = call ptr @fn_arg_code(ptr %t110, i32 0)
  store ptr %t111, ptr %t112
  %t113 = load ptr, ptr %t1
  %t114 = call ptr @fn_arg_code(ptr %t113, i32 1)
  store ptr %t114, ptr %t115
  %t116 = call ptr @fn_nreg()
  store ptr %t116, ptr %t117
  call void @fn_emit(ptr @.str537)
  %t118 = load ptr, ptr %t117
  call void @fn_emit(ptr %t118)
  call void @fn_emit(ptr @.str538)
  %t119 = load ptr, ptr %t112
  call void @fn_emit(ptr %t119)
  call void @fn_emit(ptr @.str539)
  %t120 = load ptr, ptr %t115
  call void @fn_emit(ptr %t120)
  call void @fn_emit(ptr @.str540)
  %t121 = load ptr, ptr %t117
  %t122 = call ptr @fn_sconcat(ptr @.str541, ptr %t121)
  %t123 = call ptr @fn_emit_bind(ptr %t122)
  %t124 = call ptr @fn_val(ptr %t123, ptr @.str542)
  store ptr %t124, ptr %retval
  br label %ret
ifend26:
  %t125 = load ptr, ptr %t0
  %t126 = call i32 @fn_streq(ptr %t125, ptr @.str543)
  %t127 = icmp ne i32 %t126, 0
  br i1 %t127, label %then27, label %ifend29
then27:
  %t128 = load ptr, ptr %t1
  %t129 = call ptr @fn_arg_code(ptr %t128, i32 0)
  store ptr %t129, ptr %t130
  %t131 = load ptr, ptr %t1
  %t132 = call ptr @fn_arg_code(ptr %t131, i32 1)
  store ptr %t132, ptr %t133
  %t134 = load ptr, ptr %t1
  %t135 = call ptr @fn_arg_code(ptr %t134, i32 2)
  store ptr %t135, ptr %t136
  %t137 = call ptr @fn_nreg()
  store ptr %t137, ptr %t138
  call void @fn_emit(ptr @.str544)
  %t139 = load ptr, ptr %t138
  call void @fn_emit(ptr %t139)
  call void @fn_emit(ptr @.str545)
  %t140 = load ptr, ptr %t130
  call void @fn_emit(ptr %t140)
  call void @fn_emit(ptr @.str546)
  %t141 = load ptr, ptr %t133
  call void @fn_emit(ptr %t141)
  call void @fn_emit(ptr @.str547)
  call void @fn_emit(ptr @.str548)
  %t142 = load ptr, ptr %t136
  call void @fn_emit(ptr %t142)
  call void @fn_emit(ptr @.str549)
  %t143 = load ptr, ptr %t138
  call void @fn_emit(ptr %t143)
  call void @fn_emit(ptr @.str550)
  %t144 = call ptr @fn_val(ptr @.str551, ptr @.str552)
  store ptr %t144, ptr %retval
  br label %ret
ifend29:
  %t145 = load ptr, ptr %t0
  %t146 = call i32 @fn_streq(ptr %t145, ptr @.str553)
  %t147 = icmp ne i32 %t146, 0
  br i1 %t147, label %then30, label %ifend32
then30:
  %t148 = load ptr, ptr %t1
  %t149 = call ptr @fn_arg_code(ptr %t148, i32 0)
  store ptr %t149, ptr %t150
  %t151 = load ptr, ptr %t1
  %t152 = call ptr @fn_arg_code(ptr %t151, i32 1)
  store ptr %t152, ptr %t153
  %t154 = call ptr @fn_nreg()
  store ptr %t154, ptr %t155
  call void @fn_emit(ptr @.str554)
  %t156 = load ptr, ptr %t155
  call void @fn_emit(ptr %t156)
  call void @fn_emit(ptr @.str555)
  %t157 = load ptr, ptr %t150
  call void @fn_emit(ptr %t157)
  call void @fn_emit(ptr @.str556)
  %t158 = load ptr, ptr %t153
  call void @fn_emit(ptr %t158)
  call void @fn_emit(ptr @.str557)
  %t159 = load ptr, ptr %t155
  %t160 = call ptr @fn_sconcat(ptr @.str558, ptr %t159)
  %t161 = call ptr @fn_emit_bind(ptr %t160)
  %t162 = call ptr @fn_val(ptr %t161, ptr @.str559)
  store ptr %t162, ptr %retval
  br label %ret
ifend32:
  %t163 = load ptr, ptr %t0
  %t164 = call i32 @fn_streq(ptr %t163, ptr @.str560)
  %t165 = icmp ne i32 %t164, 0
  br i1 %t165, label %then33, label %ifend35
then33:
  %t166 = load ptr, ptr %t1
  %t167 = call ptr @fn_arg_code(ptr %t166, i32 0)
  store ptr %t167, ptr %t168
  %t169 = load ptr, ptr %t1
  %t170 = call ptr @fn_arg_code(ptr %t169, i32 1)
  store ptr %t170, ptr %t171
  %t172 = load ptr, ptr %t1
  %t173 = call ptr @fn_arg_code(ptr %t172, i32 2)
  store ptr %t173, ptr %t174
  %t175 = call ptr @fn_nreg()
  store ptr %t175, ptr %t176
  call void @fn_emit(ptr @.str561)
  %t177 = load ptr, ptr %t176
  call void @fn_emit(ptr %t177)
  call void @fn_emit(ptr @.str562)
  %t178 = load ptr, ptr %t168
  call void @fn_emit(ptr %t178)
  call void @fn_emit(ptr @.str563)
  %t179 = load ptr, ptr %t171
  call void @fn_emit(ptr %t179)
  call void @fn_emit(ptr @.str564)
  call void @fn_emit(ptr @.str565)
  %t180 = load ptr, ptr %t174
  call void @fn_emit(ptr %t180)
  call void @fn_emit(ptr @.str566)
  %t181 = load ptr, ptr %t176
  call void @fn_emit(ptr %t181)
  call void @fn_emit(ptr @.str567)
  %t182 = call ptr @fn_val(ptr @.str568, ptr @.str569)
  store ptr %t182, ptr %retval
  br label %ret
ifend35:
  %t183 = load ptr, ptr %t0
  %t184 = call i32 @fn_streq(ptr %t183, ptr @.str570)
  %t185 = icmp ne i32 %t184, 0
  br i1 %t185, label %then36, label %ifend38
then36:
  %t186 = load ptr, ptr %t1
  %t187 = getelementptr inbounds %Str_Node, ptr %t186, i32 0, i32 7
  %t188 = load ptr, ptr %t187
  %t189 = getelementptr inbounds %LSlice, ptr %t188, i32 0, i32 0
  %t190 = load ptr, ptr %t189
  %t191 = getelementptr inbounds ptr, ptr %t190, i32 0
  %t192 = load ptr, ptr %t191
  %t193 = call ptr @fn_emit_expr(ptr %t192)
  store ptr %t193, ptr %t194
  %t195 = load ptr, ptr %t194
  %t196 = getelementptr inbounds %Str_Val, ptr %t195, i32 0, i32 0
  %t197 = load ptr, ptr %t196
  %t198 = call ptr @fn_val(ptr %t197, ptr @.str571)
  store ptr %t198, ptr %retval
  br label %ret
ifend38:
  %t199 = load ptr, ptr %t0
  %t200 = call i32 @fn_streq(ptr %t199, ptr @.str572)
  %t201 = icmp ne i32 %t200, 0
  br i1 %t201, label %then39, label %ifend41
then39:
  %t202 = load ptr, ptr %t1
  %t203 = getelementptr inbounds %Str_Node, ptr %t202, i32 0, i32 7
  %t204 = load ptr, ptr %t203
  %t205 = getelementptr inbounds %LSlice, ptr %t204, i32 0, i32 0
  %t206 = load ptr, ptr %t205
  %t207 = getelementptr inbounds ptr, ptr %t206, i32 0
  %t208 = load ptr, ptr %t207
  %t209 = call ptr @fn_emit_expr(ptr %t208)
  store ptr %t209, ptr %t210
  %t211 = load ptr, ptr %t210
  %t212 = getelementptr inbounds %Str_Val, ptr %t211, i32 0, i32 0
  %t213 = load ptr, ptr %t212
  %t214 = call ptr @fn_val(ptr %t213, ptr @.str573)
  store ptr %t214, ptr %retval
  br label %ret
ifend41:
  %t215 = load ptr, ptr %t0
  %t216 = call i32 @fn_streq(ptr %t215, ptr @.str574)
  %t217 = icmp ne i32 %t216, 0
  br i1 %t217, label %then42, label %ifend44
then42:
  %t218 = load i32, ptr @g_g_windowed
  %t219 = icmp ne i32 %t218, 0
  br i1 %t219, label %then45, label %ifend47
then45:
  %t220 = call ptr @fn_val(ptr @.str575, ptr @.str576)
  store ptr %t220, ptr %retval
  br label %ret
ifend47:
  %t221 = call ptr @fn_val(ptr @.str577, ptr @.str578)
  store ptr %t221, ptr %retval
  br label %ret
ifend44:
  %t222 = load ptr, ptr %t0
  %t223 = call i32 @fn_streq(ptr %t222, ptr @.str579)
  %t224 = icmp ne i32 %t223, 0
  br i1 %t224, label %then48, label %ifend50
then48:
  %t225 = call ptr @fn_val(ptr @.str580, ptr @.str581)
  store ptr %t225, ptr %retval
  br label %ret
ifend50:
  %t226 = load ptr, ptr %t0
  %t227 = call i32 @fn_streq(ptr %t226, ptr @.str582)
  %t228 = icmp ne i32 %t227, 0
  br i1 %t228, label %then51, label %ifend53
then51:
  %t229 = call ptr @fn_emit_bind(ptr @.str583)
  %t230 = call ptr @fn_val(ptr %t229, ptr @.str584)
  store ptr %t230, ptr %retval
  br label %ret
ifend53:
  %t231 = load ptr, ptr %t0
  %t232 = call i32 @fn_streq(ptr %t231, ptr @.str585)
  %t233 = icmp ne i32 %t232, 0
  br i1 %t233, label %then54, label %ifend56
then54:
  %t234 = call ptr @fn_emit_bind(ptr @.str586)
  %t235 = call ptr @fn_val(ptr %t234, ptr @.str587)
  store ptr %t235, ptr %retval
  br label %ret
ifend56:
  %t236 = load ptr, ptr %t0
  %t237 = call i32 @fn_streq(ptr %t236, ptr @.str588)
  %t238 = icmp ne i32 %t237, 0
  br i1 %t238, label %then57, label %ifend59
then57:
  %t239 = load ptr, ptr %t1
  %t240 = call ptr @fn_arg_code(ptr %t239, i32 0)
  store ptr %t240, ptr %t241
  %t242 = load ptr, ptr %t1
  %t243 = call ptr @fn_arg_code(ptr %t242, i32 1)
  store ptr %t243, ptr %t244
  %t245 = load ptr, ptr %t1
  %t246 = call ptr @fn_arg_code(ptr %t245, i32 2)
  store ptr %t246, ptr %t247
  %t248 = load ptr, ptr %t1
  %t249 = call ptr @fn_arg_code(ptr %t248, i32 3)
  store ptr %t249, ptr %t250
  call void @fn_emit(ptr @.str589)
  %t251 = load ptr, ptr %t241
  call void @fn_emit(ptr %t251)
  call void @fn_emit(ptr @.str590)
  %t252 = load ptr, ptr %t244
  call void @fn_emit(ptr %t252)
  call void @fn_emit(ptr @.str591)
  %t253 = load ptr, ptr %t247
  call void @fn_emit(ptr %t253)
  call void @fn_emit(ptr @.str592)
  %t254 = load ptr, ptr %t250
  call void @fn_emit(ptr %t254)
  call void @fn_emit(ptr @.str593)
  %t255 = call ptr @fn_val(ptr @.str594, ptr @.str595)
  store ptr %t255, ptr %retval
  br label %ret
ifend59:
  %t256 = load ptr, ptr %t0
  %t257 = call i32 @fn_streq(ptr %t256, ptr @.str596)
  %t258 = icmp ne i32 %t257, 0
  br i1 %t258, label %then60, label %ifend62
then60:
  %t259 = load ptr, ptr %t1
  %t260 = call ptr @fn_arg_code(ptr %t259, i32 0)
  store ptr %t260, ptr %t261
  %t262 = load ptr, ptr %t1
  %t263 = call ptr @fn_arg_code(ptr %t262, i32 1)
  store ptr %t263, ptr %t264
  %t265 = load ptr, ptr %t1
  %t266 = call ptr @fn_arg_code(ptr %t265, i32 2)
  store ptr %t266, ptr %t267
  call void @fn_emit(ptr @.str597)
  %t268 = load ptr, ptr %t261
  call void @fn_emit(ptr %t268)
  call void @fn_emit(ptr @.str598)
  %t269 = load ptr, ptr %t264
  call void @fn_emit(ptr %t269)
  call void @fn_emit(ptr @.str599)
  %t270 = load ptr, ptr %t267
  call void @fn_emit(ptr %t270)
  call void @fn_emit(ptr @.str600)
  %t271 = call ptr @fn_val(ptr @.str601, ptr @.str602)
  store ptr %t271, ptr %retval
  br label %ret
ifend62:
  %t272 = load ptr, ptr %t0
  %t273 = call i32 @fn_streq(ptr %t272, ptr @.str603)
  %t274 = icmp ne i32 %t273, 0
  br i1 %t274, label %then63, label %ifend65
then63:
  call void @fn_emit(ptr @.str604)
  %t275 = call ptr @fn_val(ptr @.str605, ptr @.str606)
  store ptr %t275, ptr %retval
  br label %ret
ifend65:
  %t276 = call ptr @fn_val(ptr @.str607, ptr @.str608)
  store ptr %t276, ptr %retval
  br label %ret
ret:
  %t277 = load ptr, ptr %retval
  ret ptr %t277
}

define i32 @fn_is_math_builtin(ptr %arg_name) {
entry:
  %retval = alloca i32
  %t0 = alloca ptr
  %t1 = alloca i32
  %t2 = alloca i32
  %t3 = alloca i32
  store ptr %arg_name, ptr %t0
  %t4 = load ptr, ptr %t0
  %t5 = call i32 @fn_streq(ptr %t4, ptr @.str609)
  %t6 = icmp ne i32 %t5, 0
  %t7 = zext i1 %t6 to i32
  store i32 %t7, ptr %t3
  br i1 %t6, label %scend1, label %sc0
sc0:
  %t8 = load ptr, ptr %t0
  %t9 = call i32 @fn_streq(ptr %t8, ptr @.str610)
  %t10 = icmp ne i32 %t9, 0
  %t11 = zext i1 %t10 to i32
  store i32 %t11, ptr %t3
  br label %scend1
scend1:
  %t12 = load i32, ptr %t3
  %t13 = icmp ne i32 %t12, 0
  %t14 = zext i1 %t13 to i32
  store i32 %t14, ptr %t2
  br i1 %t13, label %scend3, label %sc2
sc2:
  %t15 = load ptr, ptr %t0
  %t16 = call i32 @fn_streq(ptr %t15, ptr @.str611)
  %t17 = icmp ne i32 %t16, 0
  %t18 = zext i1 %t17 to i32
  store i32 %t18, ptr %t2
  br label %scend3
scend3:
  %t19 = load i32, ptr %t2
  %t20 = icmp ne i32 %t19, 0
  %t21 = zext i1 %t20 to i32
  store i32 %t21, ptr %t1
  br i1 %t20, label %scend5, label %sc4
sc4:
  %t22 = load ptr, ptr %t0
  %t23 = call i32 @fn_streq(ptr %t22, ptr @.str612)
  %t24 = icmp ne i32 %t23, 0
  %t25 = zext i1 %t24 to i32
  store i32 %t25, ptr %t1
  br label %scend5
scend5:
  %t26 = load i32, ptr %t1
  store i32 %t26, ptr %retval
  br label %ret
ret:
  %t27 = load i32, ptr %retval
  ret i32 %t27
}

define ptr @fn_emit_math_builtin(ptr %arg_name, ptr %arg_e) {
entry:
  %retval = alloca ptr
  %t0 = alloca ptr
  %t1 = alloca ptr
  %t13 = alloca ptr
  %t20 = alloca ptr
  %t26 = alloca ptr
  %t39 = alloca i32
  %t58 = alloca ptr
  %t67 = alloca ptr
  %t68 = alloca ptr
  %t85 = alloca ptr
  %t108 = alloca ptr
  %t117 = alloca ptr
  %t126 = alloca ptr
  %t137 = alloca ptr
  %t151 = alloca ptr
  %t160 = alloca ptr
  store ptr %arg_name, ptr %t0
  store ptr %arg_e, ptr %t1
  %t2 = load ptr, ptr %t0
  %t3 = call i32 @fn_streq(ptr %t2, ptr @.str613)
  %t4 = icmp ne i32 %t3, 0
  br i1 %t4, label %then0, label %ifend2
then0:
  %t5 = load ptr, ptr %t1
  %t6 = getelementptr inbounds %Str_Node, ptr %t5, i32 0, i32 7
  %t7 = load ptr, ptr %t6
  %t8 = getelementptr inbounds %LSlice, ptr %t7, i32 0, i32 0
  %t9 = load ptr, ptr %t8
  %t10 = getelementptr inbounds ptr, ptr %t9, i32 0
  %t11 = load ptr, ptr %t10
  %t12 = call ptr @fn_emit_expr(ptr %t11)
  store ptr %t12, ptr %t13
  %t14 = load ptr, ptr %t13
  %t15 = getelementptr inbounds %Str_Val, ptr %t14, i32 0, i32 0
  %t16 = load ptr, ptr %t15
  %t17 = call ptr @fn_sconcat(ptr %t16, ptr @.str615)
  %t18 = call ptr @fn_sconcat(ptr @.str614, ptr %t17)
  %t19 = call ptr @fn_emit_bind(ptr %t18)
  store ptr %t19, ptr %t20
  %t21 = load ptr, ptr %t13
  %t22 = getelementptr inbounds %Str_Val, ptr %t21, i32 0, i32 0
  %t23 = load ptr, ptr %t22
  %t24 = call ptr @fn_sconcat(ptr @.str616, ptr %t23)
  %t25 = call ptr @fn_emit_bind(ptr %t24)
  store ptr %t25, ptr %t26
  %t27 = load ptr, ptr %t20
  %t28 = load ptr, ptr %t26
  %t29 = load ptr, ptr %t13
  %t30 = getelementptr inbounds %Str_Val, ptr %t29, i32 0, i32 0
  %t31 = load ptr, ptr %t30
  %t32 = call ptr @fn_sconcat(ptr @.str619, ptr %t31)
  %t33 = call ptr @fn_sconcat(ptr %t28, ptr %t32)
  %t34 = call ptr @fn_sconcat(ptr @.str618, ptr %t33)
  %t35 = call ptr @fn_sconcat(ptr %t27, ptr %t34)
  %t36 = call ptr @fn_sconcat(ptr @.str617, ptr %t35)
  %t37 = call ptr @fn_emit_bind(ptr %t36)
  %t38 = call ptr @fn_val(ptr %t37, ptr @.str620)
  store ptr %t38, ptr %retval
  br label %ret
ifend2:
  %t40 = load ptr, ptr %t0
  %t41 = call i32 @fn_streq(ptr %t40, ptr @.str621)
  %t42 = icmp ne i32 %t41, 0
  %t43 = zext i1 %t42 to i32
  store i32 %t43, ptr %t39
  br i1 %t42, label %scend4, label %sc3
sc3:
  %t44 = load ptr, ptr %t0
  %t45 = call i32 @fn_streq(ptr %t44, ptr @.str622)
  %t46 = icmp ne i32 %t45, 0
  %t47 = zext i1 %t46 to i32
  store i32 %t47, ptr %t39
  br label %scend4
scend4:
  %t48 = load i32, ptr %t39
  %t49 = icmp ne i32 %t48, 0
  br i1 %t49, label %then5, label %ifend7
then5:
  %t50 = load ptr, ptr %t1
  %t51 = getelementptr inbounds %Str_Node, ptr %t50, i32 0, i32 7
  %t52 = load ptr, ptr %t51
  %t53 = getelementptr inbounds %LSlice, ptr %t52, i32 0, i32 0
  %t54 = load ptr, ptr %t53
  %t55 = getelementptr inbounds ptr, ptr %t54, i32 0
  %t56 = load ptr, ptr %t55
  %t57 = call ptr @fn_emit_expr(ptr %t56)
  store ptr %t57, ptr %t58
  %t59 = load ptr, ptr %t1
  %t60 = getelementptr inbounds %Str_Node, ptr %t59, i32 0, i32 7
  %t61 = load ptr, ptr %t60
  %t62 = getelementptr inbounds %LSlice, ptr %t61, i32 0, i32 0
  %t63 = load ptr, ptr %t62
  %t64 = getelementptr inbounds ptr, ptr %t63, i32 1
  %t65 = load ptr, ptr %t64
  %t66 = call ptr @fn_emit_expr(ptr %t65)
  store ptr %t66, ptr %t67
  store ptr @.str623, ptr %t68
  %t69 = load ptr, ptr %t0
  %t70 = call i32 @fn_streq(ptr %t69, ptr @.str624)
  %t71 = icmp ne i32 %t70, 0
  br i1 %t71, label %then8, label %ifend10
then8:
  store ptr @.str625, ptr %t68
  br label %ifend10
ifend10:
  %t72 = load ptr, ptr %t68
  %t73 = load ptr, ptr %t58
  %t74 = getelementptr inbounds %Str_Val, ptr %t73, i32 0, i32 0
  %t75 = load ptr, ptr %t74
  %t76 = load ptr, ptr %t67
  %t77 = getelementptr inbounds %Str_Val, ptr %t76, i32 0, i32 0
  %t78 = load ptr, ptr %t77
  %t79 = call ptr @fn_sconcat(ptr @.str628, ptr %t78)
  %t80 = call ptr @fn_sconcat(ptr %t75, ptr %t79)
  %t81 = call ptr @fn_sconcat(ptr @.str627, ptr %t80)
  %t82 = call ptr @fn_sconcat(ptr %t72, ptr %t81)
  %t83 = call ptr @fn_sconcat(ptr @.str626, ptr %t82)
  %t84 = call ptr @fn_emit_bind(ptr %t83)
  store ptr %t84, ptr %t85
  %t86 = load ptr, ptr %t85
  %t87 = load ptr, ptr %t58
  %t88 = getelementptr inbounds %Str_Val, ptr %t87, i32 0, i32 0
  %t89 = load ptr, ptr %t88
  %t90 = load ptr, ptr %t67
  %t91 = getelementptr inbounds %Str_Val, ptr %t90, i32 0, i32 0
  %t92 = load ptr, ptr %t91
  %t93 = call ptr @fn_sconcat(ptr @.str631, ptr %t92)
  %t94 = call ptr @fn_sconcat(ptr %t89, ptr %t93)
  %t95 = call ptr @fn_sconcat(ptr @.str630, ptr %t94)
  %t96 = call ptr @fn_sconcat(ptr %t86, ptr %t95)
  %t97 = call ptr @fn_sconcat(ptr @.str629, ptr %t96)
  %t98 = call ptr @fn_emit_bind(ptr %t97)
  %t99 = call ptr @fn_val(ptr %t98, ptr @.str632)
  store ptr %t99, ptr %retval
  br label %ret
ifend7:
  %t100 = load ptr, ptr %t1
  %t101 = getelementptr inbounds %Str_Node, ptr %t100, i32 0, i32 7
  %t102 = load ptr, ptr %t101
  %t103 = getelementptr inbounds %LSlice, ptr %t102, i32 0, i32 0
  %t104 = load ptr, ptr %t103
  %t105 = getelementptr inbounds ptr, ptr %t104, i32 0
  %t106 = load ptr, ptr %t105
  %t107 = call ptr @fn_emit_expr(ptr %t106)
  store ptr %t107, ptr %t108
  %t109 = load ptr, ptr %t1
  %t110 = getelementptr inbounds %Str_Node, ptr %t109, i32 0, i32 7
  %t111 = load ptr, ptr %t110
  %t112 = getelementptr inbounds %LSlice, ptr %t111, i32 0, i32 0
  %t113 = load ptr, ptr %t112
  %t114 = getelementptr inbounds ptr, ptr %t113, i32 1
  %t115 = load ptr, ptr %t114
  %t116 = call ptr @fn_emit_expr(ptr %t115)
  store ptr %t116, ptr %t117
  %t118 = load ptr, ptr %t1
  %t119 = getelementptr inbounds %Str_Node, ptr %t118, i32 0, i32 7
  %t120 = load ptr, ptr %t119
  %t121 = getelementptr inbounds %LSlice, ptr %t120, i32 0, i32 0
  %t122 = load ptr, ptr %t121
  %t123 = getelementptr inbounds ptr, ptr %t122, i32 2
  %t124 = load ptr, ptr %t123
  %t125 = call ptr @fn_emit_expr(ptr %t124)
  store ptr %t125, ptr %t126
  %t127 = load ptr, ptr %t108
  %t128 = getelementptr inbounds %Str_Val, ptr %t127, i32 0, i32 0
  %t129 = load ptr, ptr %t128
  %t130 = load ptr, ptr %t126
  %t131 = getelementptr inbounds %Str_Val, ptr %t130, i32 0, i32 0
  %t132 = load ptr, ptr %t131
  %t133 = call ptr @fn_sconcat(ptr @.str634, ptr %t132)
  %t134 = call ptr @fn_sconcat(ptr %t129, ptr %t133)
  %t135 = call ptr @fn_sconcat(ptr @.str633, ptr %t134)
  %t136 = call ptr @fn_emit_bind(ptr %t135)
  store ptr %t136, ptr %t137
  %t138 = load ptr, ptr %t137
  %t139 = load ptr, ptr %t108
  %t140 = getelementptr inbounds %Str_Val, ptr %t139, i32 0, i32 0
  %t141 = load ptr, ptr %t140
  %t142 = load ptr, ptr %t126
  %t143 = getelementptr inbounds %Str_Val, ptr %t142, i32 0, i32 0
  %t144 = load ptr, ptr %t143
  %t145 = call ptr @fn_sconcat(ptr @.str637, ptr %t144)
  %t146 = call ptr @fn_sconcat(ptr %t141, ptr %t145)
  %t147 = call ptr @fn_sconcat(ptr @.str636, ptr %t146)
  %t148 = call ptr @fn_sconcat(ptr %t138, ptr %t147)
  %t149 = call ptr @fn_sconcat(ptr @.str635, ptr %t148)
  %t150 = call ptr @fn_emit_bind(ptr %t149)
  store ptr %t150, ptr %t151
  %t152 = load ptr, ptr %t117
  %t153 = getelementptr inbounds %Str_Val, ptr %t152, i32 0, i32 0
  %t154 = load ptr, ptr %t153
  %t155 = load ptr, ptr %t151
  %t156 = call ptr @fn_sconcat(ptr @.str639, ptr %t155)
  %t157 = call ptr @fn_sconcat(ptr %t154, ptr %t156)
  %t158 = call ptr @fn_sconcat(ptr @.str638, ptr %t157)
  %t159 = call ptr @fn_emit_bind(ptr %t158)
  store ptr %t159, ptr %t160
  %t161 = load ptr, ptr %t160
  %t162 = load ptr, ptr %t117
  %t163 = getelementptr inbounds %Str_Val, ptr %t162, i32 0, i32 0
  %t164 = load ptr, ptr %t163
  %t165 = load ptr, ptr %t151
  %t166 = call ptr @fn_sconcat(ptr @.str642, ptr %t165)
  %t167 = call ptr @fn_sconcat(ptr %t164, ptr %t166)
  %t168 = call ptr @fn_sconcat(ptr @.str641, ptr %t167)
  %t169 = call ptr @fn_sconcat(ptr %t161, ptr %t168)
  %t170 = call ptr @fn_sconcat(ptr @.str640, ptr %t169)
  %t171 = call ptr @fn_emit_bind(ptr %t170)
  %t172 = call ptr @fn_val(ptr %t171, ptr @.str643)
  store ptr %t172, ptr %retval
  br label %ret
ret:
  %t173 = load ptr, ptr %retval
  ret ptr %t173
}

define ptr @fn_emit_sizeof(ptr %arg_llt) {
entry:
  %retval = alloca ptr
  %t0 = alloca ptr
  %t5 = alloca ptr
  store ptr %arg_llt, ptr %t0
  %t1 = load ptr, ptr %t0
  %t2 = call ptr @fn_sconcat(ptr %t1, ptr @.str645)
  %t3 = call ptr @fn_sconcat(ptr @.str644, ptr %t2)
  %t4 = call ptr @fn_emit_bind(ptr %t3)
  store ptr %t4, ptr %t5
  %t6 = load ptr, ptr %t5
  %t7 = call ptr @fn_sconcat(ptr %t6, ptr @.str647)
  %t8 = call ptr @fn_sconcat(ptr @.str646, ptr %t7)
  %t9 = call ptr @fn_emit_bind(ptr %t8)
  store ptr %t9, ptr %retval
  br label %ret
ret:
  %t10 = load ptr, ptr %retval
  ret ptr %t10
}

define ptr @fn_emit_new_struct(ptr %arg_name) {
entry:
  %retval = alloca ptr
  %t0 = alloca ptr
  %t3 = alloca ptr
  %t11 = alloca ptr
  %t16 = alloca ptr
  %t17 = alloca i32
  %t35 = alloca ptr
  %t37 = alloca ptr
  %t47 = alloca ptr
  %t48 = alloca ptr
  %t64 = alloca ptr
  store ptr %arg_name, ptr %t0
  %t1 = load ptr, ptr %t0
  %t2 = call ptr @fn_find_struct(ptr %t1)
  store ptr %t2, ptr %t3
  %t4 = load ptr, ptr %t3
  %t5 = icmp eq ptr %t4, null
  %t6 = zext i1 %t5 to i32
  %t7 = icmp ne i32 %t6, 0
  br i1 %t7, label %then0, label %ifend2
then0:
  call void @fn_perr(ptr @.str648)
  br label %ifend2
ifend2:
  %t8 = load ptr, ptr %t0
  %t9 = call ptr @fn_sconcat(ptr @.str649, ptr %t8)
  %t10 = call ptr @fn_emit_sizeof(ptr %t9)
  store ptr %t10, ptr %t11
  %t12 = load ptr, ptr %t11
  %t13 = call ptr @fn_sconcat(ptr %t12, ptr @.str651)
  %t14 = call ptr @fn_sconcat(ptr @.str650, ptr %t13)
  %t15 = call ptr @fn_emit_bind(ptr %t14)
  store ptr %t15, ptr %t16
  store i32 0, ptr %t17
  br label %wcond3
wcond3:
  %t18 = load i32, ptr %t17
  %t19 = load ptr, ptr %t3
  %t20 = getelementptr inbounds %Str_Node, ptr %t19, i32 0, i32 7
  %t21 = load ptr, ptr %t20
  %t22 = getelementptr inbounds %LSlice, ptr %t21, i32 0, i32 1
  %t23 = load i32, ptr %t22
  %t24 = icmp slt i32 %t18, %t23
  %t25 = zext i1 %t24 to i32
  %t26 = icmp ne i32 %t25, 0
  br i1 %t26, label %wbody4, label %wend5
wbody4:
  %t27 = load ptr, ptr %t3
  %t28 = getelementptr inbounds %Str_Node, ptr %t27, i32 0, i32 7
  %t29 = load ptr, ptr %t28
  %t30 = getelementptr inbounds %LSlice, ptr %t29, i32 0, i32 0
  %t31 = load ptr, ptr %t30
  %t32 = load i32, ptr %t17
  %t33 = getelementptr inbounds ptr, ptr %t31, i32 %t32
  %t34 = load ptr, ptr %t33
  store ptr %t34, ptr %t35
  %t36 = call ptr @fn_nreg()
  store ptr %t36, ptr %t37
  call void @fn_emit(ptr @.str652)
  %t38 = load ptr, ptr %t37
  call void @fn_emit(ptr %t38)
  call void @fn_emit(ptr @.str653)
  %t39 = load ptr, ptr %t0
  call void @fn_emit(ptr %t39)
  call void @fn_emit(ptr @.str654)
  %t40 = load ptr, ptr %t16
  call void @fn_emit(ptr %t40)
  call void @fn_emit(ptr @.str655)
  %t41 = load i32, ptr %t17
  %t42 = call ptr @fn_itoa(i32 %t41)
  call void @fn_emit(ptr %t42)
  call void @fn_emit(ptr @.str656)
  %t43 = load ptr, ptr %t35
  %t44 = getelementptr inbounds %Str_Node, ptr %t43, i32 0, i32 3
  %t45 = load ptr, ptr %t44
  %t46 = call ptr @fn_llty(ptr %t45)
  store ptr %t46, ptr %t47
  store ptr @.str657, ptr %t48
  %t49 = load ptr, ptr %t47
  %t50 = call i32 @fn_streq(ptr %t49, ptr @.str658)
  %t51 = icmp ne i32 %t50, 0
  br i1 %t51, label %then6, label %ifend8
then6:
  store ptr @.str659, ptr %t48
  br label %ifend8
ifend8:
  %t52 = load ptr, ptr %t35
  %t53 = getelementptr inbounds %Str_Node, ptr %t52, i32 0, i32 4
  %t54 = load ptr, ptr %t53
  %t55 = icmp eq ptr %t54, null
  %t56 = zext i1 %t55 to i32
  %t57 = icmp eq i32 %t56, 0
  %t58 = zext i1 %t57 to i32
  %t59 = icmp ne i32 %t58, 0
  br i1 %t59, label %then9, label %ifend11
then9:
  %t60 = load ptr, ptr %t35
  %t61 = getelementptr inbounds %Str_Node, ptr %t60, i32 0, i32 4
  %t62 = load ptr, ptr %t61
  %t63 = call ptr @fn_emit_expr(ptr %t62)
  store ptr %t63, ptr %t64
  %t65 = load ptr, ptr %t64
  %t66 = getelementptr inbounds %Str_Val, ptr %t65, i32 0, i32 0
  %t67 = load ptr, ptr %t66
  store ptr %t67, ptr %t48
  br label %ifend11
ifend11:
  call void @fn_emit(ptr @.str660)
  %t68 = load ptr, ptr %t47
  call void @fn_emit(ptr %t68)
  call void @fn_emit(ptr @.str661)
  %t69 = load ptr, ptr %t48
  call void @fn_emit(ptr %t69)
  call void @fn_emit(ptr @.str662)
  %t70 = load ptr, ptr %t37
  call void @fn_emit(ptr %t70)
  call void @fn_emit(ptr @.str663)
  %t71 = load i32, ptr %t17
  %t72 = add i32 %t71, 1
  store i32 %t72, ptr %t17
  br label %wcond3
wend5:
  %t73 = load ptr, ptr %t16
  %t74 = load ptr, ptr %t0
  %t75 = call ptr @fn_val(ptr %t73, ptr %t74)
  store ptr %t75, ptr %retval
  br label %ret
ret:
  %t76 = load ptr, ptr %retval
  ret ptr %t76
}

define ptr @fn_emit_new_slice(ptr %arg_ty) {
entry:
  %retval = alloca ptr
  %t0 = alloca ptr
  %t2 = alloca ptr
  %t7 = alloca ptr
  %t9 = alloca ptr
  %t14 = alloca ptr
  %t19 = alloca ptr
  store ptr %arg_ty, ptr %t0
  %t1 = call ptr @fn_emit_sizeof(ptr @.str664)
  store ptr %t1, ptr %t2
  %t3 = load ptr, ptr %t2
  %t4 = call ptr @fn_sconcat(ptr %t3, ptr @.str666)
  %t5 = call ptr @fn_sconcat(ptr @.str665, ptr %t4)
  %t6 = call ptr @fn_emit_bind(ptr %t5)
  store ptr %t6, ptr %t7
  %t8 = call ptr @fn_nreg()
  store ptr %t8, ptr %t9
  call void @fn_emit(ptr @.str667)
  %t10 = load ptr, ptr %t9
  call void @fn_emit(ptr %t10)
  call void @fn_emit(ptr @.str668)
  %t11 = load ptr, ptr %t7
  call void @fn_emit(ptr %t11)
  call void @fn_emit(ptr @.str669)
  call void @fn_emit(ptr @.str670)
  %t12 = load ptr, ptr %t9
  call void @fn_emit(ptr %t12)
  call void @fn_emit(ptr @.str671)
  %t13 = call ptr @fn_nreg()
  store ptr %t13, ptr %t14
  call void @fn_emit(ptr @.str672)
  %t15 = load ptr, ptr %t14
  call void @fn_emit(ptr %t15)
  call void @fn_emit(ptr @.str673)
  %t16 = load ptr, ptr %t7
  call void @fn_emit(ptr %t16)
  call void @fn_emit(ptr @.str674)
  call void @fn_emit(ptr @.str675)
  %t17 = load ptr, ptr %t14
  call void @fn_emit(ptr %t17)
  call void @fn_emit(ptr @.str676)
  %t18 = call ptr @fn_nreg()
  store ptr %t18, ptr %t19
  call void @fn_emit(ptr @.str677)
  %t20 = load ptr, ptr %t19
  call void @fn_emit(ptr %t20)
  call void @fn_emit(ptr @.str678)
  %t21 = load ptr, ptr %t7
  call void @fn_emit(ptr %t21)
  call void @fn_emit(ptr @.str679)
  call void @fn_emit(ptr @.str680)
  %t22 = load ptr, ptr %t19
  call void @fn_emit(ptr %t22)
  call void @fn_emit(ptr @.str681)
  %t23 = load ptr, ptr %t7
  %t24 = load ptr, ptr %t0
  %t25 = call ptr @fn_val(ptr %t23, ptr %t24)
  store ptr %t25, ptr %retval
  br label %ret
ret:
  %t26 = load ptr, ptr %retval
  ret ptr %t26
}

define ptr @fn_slice_field(ptr %arg_h, i32 %arg_i) {
entry:
  %retval = alloca ptr
  %t0 = alloca ptr
  %t1 = alloca i32
  %t3 = alloca ptr
  store ptr %arg_h, ptr %t0
  store i32 %arg_i, ptr %t1
  %t2 = call ptr @fn_nreg()
  store ptr %t2, ptr %t3
  call void @fn_emit(ptr @.str682)
  %t4 = load ptr, ptr %t3
  call void @fn_emit(ptr %t4)
  call void @fn_emit(ptr @.str683)
  %t5 = load ptr, ptr %t0
  call void @fn_emit(ptr %t5)
  call void @fn_emit(ptr @.str684)
  %t6 = load i32, ptr %t1
  %t7 = call ptr @fn_itoa(i32 %t6)
  call void @fn_emit(ptr %t7)
  call void @fn_emit(ptr @.str685)
  %t8 = load ptr, ptr %t3
  store ptr %t8, ptr %retval
  br label %ret
ret:
  %t9 = load ptr, ptr %retval
  ret ptr %t9
}

define ptr @fn_emit_len(ptr %arg_e) {
entry:
  %retval = alloca ptr
  %t0 = alloca ptr
  %t9 = alloca ptr
  %t14 = alloca ptr
  store ptr %arg_e, ptr %t0
  %t1 = load ptr, ptr %t0
  %t2 = getelementptr inbounds %Str_Node, ptr %t1, i32 0, i32 7
  %t3 = load ptr, ptr %t2
  %t4 = getelementptr inbounds %LSlice, ptr %t3, i32 0, i32 0
  %t5 = load ptr, ptr %t4
  %t6 = getelementptr inbounds ptr, ptr %t5, i32 0
  %t7 = load ptr, ptr %t6
  %t8 = call ptr @fn_emit_expr(ptr %t7)
  store ptr %t8, ptr %t9
  %t10 = load ptr, ptr %t9
  %t11 = getelementptr inbounds %Str_Val, ptr %t10, i32 0, i32 0
  %t12 = load ptr, ptr %t11
  %t13 = call ptr @fn_slice_field(ptr %t12, i32 1)
  store ptr %t13, ptr %t14
  %t15 = load ptr, ptr %t14
  %t16 = call ptr @fn_sconcat(ptr @.str686, ptr %t15)
  %t17 = call ptr @fn_emit_bind(ptr %t16)
  %t18 = call ptr @fn_val(ptr %t17, ptr @.str687)
  store ptr %t18, ptr %retval
  br label %ret
ret:
  %t19 = load ptr, ptr %retval
  ret ptr %t19
}

define ptr @fn_emit_push(ptr %arg_e) {
entry:
  %retval = alloca ptr
  %t0 = alloca ptr
  %t9 = alloca ptr
  %t14 = alloca ptr
  %t17 = alloca ptr
  %t21 = alloca ptr
  %t24 = alloca ptr
  %t27 = alloca ptr
  %t30 = alloca ptr
  %t34 = alloca ptr
  %t38 = alloca ptr
  %t45 = alloca ptr
  %t47 = alloca ptr
  %t49 = alloca ptr
  %t58 = alloca ptr
  %t63 = alloca ptr
  %t70 = alloca ptr
  %t73 = alloca ptr
  %t78 = alloca ptr
  %t85 = alloca ptr
  %t89 = alloca ptr
  %t97 = alloca ptr
  %t112 = alloca ptr
  %t116 = alloca ptr
  %t118 = alloca ptr
  %t132 = alloca ptr
  store ptr %arg_e, ptr %t0
  %t1 = load ptr, ptr %t0
  %t2 = getelementptr inbounds %Str_Node, ptr %t1, i32 0, i32 7
  %t3 = load ptr, ptr %t2
  %t4 = getelementptr inbounds %LSlice, ptr %t3, i32 0, i32 0
  %t5 = load ptr, ptr %t4
  %t6 = getelementptr inbounds ptr, ptr %t5, i32 0
  %t7 = load ptr, ptr %t6
  %t8 = call ptr @fn_emit_expr(ptr %t7)
  store ptr %t8, ptr %t9
  %t10 = load ptr, ptr %t9
  %t11 = getelementptr inbounds %Str_Val, ptr %t10, i32 0, i32 1
  %t12 = load ptr, ptr %t11
  %t13 = call ptr @fn_slice_elem(ptr %t12)
  store ptr %t13, ptr %t14
  %t15 = load ptr, ptr %t14
  %t16 = call ptr @fn_llty(ptr %t15)
  store ptr %t16, ptr %t17
  %t18 = load ptr, ptr %t9
  %t19 = getelementptr inbounds %Str_Val, ptr %t18, i32 0, i32 0
  %t20 = load ptr, ptr %t19
  store ptr %t20, ptr %t21
  %t22 = load ptr, ptr %t21
  %t23 = call ptr @fn_slice_field(ptr %t22, i32 1)
  store ptr %t23, ptr %t24
  %t25 = load ptr, ptr %t21
  %t26 = call ptr @fn_slice_field(ptr %t25, i32 2)
  store ptr %t26, ptr %t27
  %t28 = load ptr, ptr %t21
  %t29 = call ptr @fn_slice_field(ptr %t28, i32 0)
  store ptr %t29, ptr %t30
  %t31 = load ptr, ptr %t24
  %t32 = call ptr @fn_sconcat(ptr @.str688, ptr %t31)
  %t33 = call ptr @fn_emit_bind(ptr %t32)
  store ptr %t33, ptr %t34
  %t35 = load ptr, ptr %t27
  %t36 = call ptr @fn_sconcat(ptr @.str689, ptr %t35)
  %t37 = call ptr @fn_emit_bind(ptr %t36)
  store ptr %t37, ptr %t38
  %t39 = load ptr, ptr %t34
  %t40 = load ptr, ptr %t38
  %t41 = call ptr @fn_sconcat(ptr @.str691, ptr %t40)
  %t42 = call ptr @fn_sconcat(ptr %t39, ptr %t41)
  %t43 = call ptr @fn_sconcat(ptr @.str690, ptr %t42)
  %t44 = call ptr @fn_emit_bind(ptr %t43)
  store ptr %t44, ptr %t45
  %t46 = call ptr @fn_lbl(ptr @.str692)
  store ptr %t46, ptr %t47
  %t48 = call ptr @fn_lbl(ptr @.str693)
  store ptr %t48, ptr %t49
  call void @fn_emit(ptr @.str694)
  %t50 = load ptr, ptr %t45
  call void @fn_emit(ptr %t50)
  call void @fn_emit(ptr @.str695)
  %t51 = load ptr, ptr %t47
  call void @fn_emit(ptr %t51)
  call void @fn_emit(ptr @.str696)
  %t52 = load ptr, ptr %t49
  call void @fn_emit(ptr %t52)
  call void @fn_emit(ptr @.str697)
  %t53 = load ptr, ptr %t47
  call void @fn_emit(ptr %t53)
  call void @fn_emit(ptr @.str698)
  %t54 = load ptr, ptr %t38
  %t55 = call ptr @fn_sconcat(ptr %t54, ptr @.str700)
  %t56 = call ptr @fn_sconcat(ptr @.str699, ptr %t55)
  %t57 = call ptr @fn_emit_bind(ptr %t56)
  store ptr %t57, ptr %t58
  %t59 = load ptr, ptr %t38
  %t60 = call ptr @fn_sconcat(ptr %t59, ptr @.str702)
  %t61 = call ptr @fn_sconcat(ptr @.str701, ptr %t60)
  %t62 = call ptr @fn_emit_bind(ptr %t61)
  store ptr %t62, ptr %t63
  %t64 = load ptr, ptr %t63
  %t65 = load ptr, ptr %t58
  %t66 = call ptr @fn_sconcat(ptr @.str704, ptr %t65)
  %t67 = call ptr @fn_sconcat(ptr %t64, ptr %t66)
  %t68 = call ptr @fn_sconcat(ptr @.str703, ptr %t67)
  %t69 = call ptr @fn_emit_bind(ptr %t68)
  store ptr %t69, ptr %t70
  %t71 = load ptr, ptr %t17
  %t72 = call ptr @fn_emit_sizeof(ptr %t71)
  store ptr %t72, ptr %t73
  %t74 = load ptr, ptr %t70
  %t75 = call ptr @fn_sconcat(ptr %t74, ptr @.str706)
  %t76 = call ptr @fn_sconcat(ptr @.str705, ptr %t75)
  %t77 = call ptr @fn_emit_bind(ptr %t76)
  store ptr %t77, ptr %t78
  %t79 = load ptr, ptr %t78
  %t80 = load ptr, ptr %t73
  %t81 = call ptr @fn_sconcat(ptr @.str708, ptr %t80)
  %t82 = call ptr @fn_sconcat(ptr %t79, ptr %t81)
  %t83 = call ptr @fn_sconcat(ptr @.str707, ptr %t82)
  %t84 = call ptr @fn_emit_bind(ptr %t83)
  store ptr %t84, ptr %t85
  %t86 = load ptr, ptr %t30
  %t87 = call ptr @fn_sconcat(ptr @.str709, ptr %t86)
  %t88 = call ptr @fn_emit_bind(ptr %t87)
  store ptr %t88, ptr %t89
  %t90 = load ptr, ptr %t89
  %t91 = load ptr, ptr %t85
  %t92 = call ptr @fn_sconcat(ptr %t91, ptr @.str712)
  %t93 = call ptr @fn_sconcat(ptr @.str711, ptr %t92)
  %t94 = call ptr @fn_sconcat(ptr %t90, ptr %t93)
  %t95 = call ptr @fn_sconcat(ptr @.str710, ptr %t94)
  %t96 = call ptr @fn_emit_bind(ptr %t95)
  store ptr %t96, ptr %t97
  call void @fn_emit(ptr @.str713)
  %t98 = load ptr, ptr %t97
  call void @fn_emit(ptr %t98)
  call void @fn_emit(ptr @.str714)
  %t99 = load ptr, ptr %t30
  call void @fn_emit(ptr %t99)
  call void @fn_emit(ptr @.str715)
  call void @fn_emit(ptr @.str716)
  %t100 = load ptr, ptr %t70
  call void @fn_emit(ptr %t100)
  call void @fn_emit(ptr @.str717)
  %t101 = load ptr, ptr %t27
  call void @fn_emit(ptr %t101)
  call void @fn_emit(ptr @.str718)
  call void @fn_emit(ptr @.str719)
  %t102 = load ptr, ptr %t49
  call void @fn_emit(ptr %t102)
  call void @fn_emit(ptr @.str720)
  %t103 = load ptr, ptr %t49
  call void @fn_emit(ptr %t103)
  call void @fn_emit(ptr @.str721)
  %t104 = load ptr, ptr %t0
  %t105 = getelementptr inbounds %Str_Node, ptr %t104, i32 0, i32 7
  %t106 = load ptr, ptr %t105
  %t107 = getelementptr inbounds %LSlice, ptr %t106, i32 0, i32 0
  %t108 = load ptr, ptr %t107
  %t109 = getelementptr inbounds ptr, ptr %t108, i32 1
  %t110 = load ptr, ptr %t109
  %t111 = call ptr @fn_emit_expr(ptr %t110)
  store ptr %t111, ptr %t112
  %t113 = load ptr, ptr %t30
  %t114 = call ptr @fn_sconcat(ptr @.str722, ptr %t113)
  %t115 = call ptr @fn_emit_bind(ptr %t114)
  store ptr %t115, ptr %t116
  %t117 = call ptr @fn_nreg()
  store ptr %t117, ptr %t118
  call void @fn_emit(ptr @.str723)
  %t119 = load ptr, ptr %t118
  call void @fn_emit(ptr %t119)
  call void @fn_emit(ptr @.str724)
  %t120 = load ptr, ptr %t17
  call void @fn_emit(ptr %t120)
  call void @fn_emit(ptr @.str725)
  %t121 = load ptr, ptr %t116
  call void @fn_emit(ptr %t121)
  call void @fn_emit(ptr @.str726)
  %t122 = load ptr, ptr %t34
  call void @fn_emit(ptr %t122)
  call void @fn_emit(ptr @.str727)
  call void @fn_emit(ptr @.str728)
  %t123 = load ptr, ptr %t17
  call void @fn_emit(ptr %t123)
  call void @fn_emit(ptr @.str729)
  %t124 = load ptr, ptr %t112
  %t125 = getelementptr inbounds %Str_Val, ptr %t124, i32 0, i32 0
  %t126 = load ptr, ptr %t125
  call void @fn_emit(ptr %t126)
  call void @fn_emit(ptr @.str730)
  %t127 = load ptr, ptr %t118
  call void @fn_emit(ptr %t127)
  call void @fn_emit(ptr @.str731)
  %t128 = load ptr, ptr %t34
  %t129 = call ptr @fn_sconcat(ptr %t128, ptr @.str733)
  %t130 = call ptr @fn_sconcat(ptr @.str732, ptr %t129)
  %t131 = call ptr @fn_emit_bind(ptr %t130)
  store ptr %t131, ptr %t132
  call void @fn_emit(ptr @.str734)
  %t133 = load ptr, ptr %t132
  call void @fn_emit(ptr %t133)
  call void @fn_emit(ptr @.str735)
  %t134 = load ptr, ptr %t24
  call void @fn_emit(ptr %t134)
  call void @fn_emit(ptr @.str736)
  %t135 = call ptr @fn_val(ptr @.str737, ptr @.str738)
  store ptr %t135, ptr %retval
  br label %ret
ret:
  %t136 = load ptr, ptr %retval
  ret ptr %t136
}

define ptr @fn_emit_load_at(ptr %arg_addr, ptr %arg_ty) {
entry:
  %retval = alloca ptr
  %t0 = alloca ptr
  %t1 = alloca ptr
  %t9 = alloca ptr
  store ptr %arg_addr, ptr %t0
  store ptr %arg_ty, ptr %t1
  %t2 = load ptr, ptr %t1
  %t3 = call ptr @fn_llty(ptr %t2)
  %t4 = load ptr, ptr %t0
  %t5 = call ptr @fn_sconcat(ptr @.str740, ptr %t4)
  %t6 = call ptr @fn_sconcat(ptr %t3, ptr %t5)
  %t7 = call ptr @fn_sconcat(ptr @.str739, ptr %t6)
  %t8 = call ptr @fn_emit_bind(ptr %t7)
  store ptr %t8, ptr %t9
  %t10 = load ptr, ptr %t9
  %t11 = load ptr, ptr %t1
  %t12 = call ptr @fn_val(ptr %t10, ptr %t11)
  store ptr %t12, ptr %retval
  br label %ret
ret:
  %t13 = load ptr, ptr %retval
  ret ptr %t13
}

define ptr @fn_emit_logic(ptr %arg_e) {
entry:
  %retval = alloca ptr
  %t0 = alloca ptr
  %t2 = alloca ptr
  %t7 = alloca ptr
  %t14 = alloca ptr
  %t19 = alloca ptr
  %t23 = alloca ptr
  %t25 = alloca ptr
  %t42 = alloca ptr
  %t49 = alloca ptr
  %t54 = alloca ptr
  store ptr %arg_e, ptr %t0
  %t1 = call ptr @fn_emit_alloca(ptr @.str741)
  store ptr %t1, ptr %t2
  %t3 = load ptr, ptr %t0
  %t4 = getelementptr inbounds %Str_Node, ptr %t3, i32 0, i32 4
  %t5 = load ptr, ptr %t4
  %t6 = call ptr @fn_emit_expr(ptr %t5)
  store ptr %t6, ptr %t7
  %t8 = load ptr, ptr %t7
  %t9 = getelementptr inbounds %Str_Val, ptr %t8, i32 0, i32 0
  %t10 = load ptr, ptr %t9
  %t11 = call ptr @fn_sconcat(ptr %t10, ptr @.str743)
  %t12 = call ptr @fn_sconcat(ptr @.str742, ptr %t11)
  %t13 = call ptr @fn_emit_bind(ptr %t12)
  store ptr %t13, ptr %t14
  %t15 = load ptr, ptr %t14
  %t16 = call ptr @fn_sconcat(ptr %t15, ptr @.str745)
  %t17 = call ptr @fn_sconcat(ptr @.str744, ptr %t16)
  %t18 = call ptr @fn_emit_bind(ptr %t17)
  store ptr %t18, ptr %t19
  call void @fn_emit(ptr @.str746)
  %t20 = load ptr, ptr %t19
  call void @fn_emit(ptr %t20)
  call void @fn_emit(ptr @.str747)
  %t21 = load ptr, ptr %t2
  call void @fn_emit(ptr %t21)
  call void @fn_emit(ptr @.str748)
  %t22 = call ptr @fn_lbl(ptr @.str749)
  store ptr %t22, ptr %t23
  %t24 = call ptr @fn_lbl(ptr @.str750)
  store ptr %t24, ptr %t25
  %t26 = load ptr, ptr %t0
  %t27 = getelementptr inbounds %Str_Node, ptr %t26, i32 0, i32 1
  %t28 = load ptr, ptr %t27
  %t29 = call i32 @fn_streq(ptr %t28, ptr @.str751)
  %t30 = icmp ne i32 %t29, 0
  br i1 %t30, label %then0, label %else1
then0:
  call void @fn_emit(ptr @.str752)
  %t31 = load ptr, ptr %t14
  call void @fn_emit(ptr %t31)
  call void @fn_emit(ptr @.str753)
  %t32 = load ptr, ptr %t23
  call void @fn_emit(ptr %t32)
  call void @fn_emit(ptr @.str754)
  %t33 = load ptr, ptr %t25
  call void @fn_emit(ptr %t33)
  call void @fn_emit(ptr @.str755)
  br label %ifend2
else1:
  call void @fn_emit(ptr @.str756)
  %t34 = load ptr, ptr %t14
  call void @fn_emit(ptr %t34)
  call void @fn_emit(ptr @.str757)
  %t35 = load ptr, ptr %t25
  call void @fn_emit(ptr %t35)
  call void @fn_emit(ptr @.str758)
  %t36 = load ptr, ptr %t23
  call void @fn_emit(ptr %t36)
  call void @fn_emit(ptr @.str759)
  br label %ifend2
ifend2:
  %t37 = load ptr, ptr %t23
  call void @fn_emit(ptr %t37)
  call void @fn_emit(ptr @.str760)
  %t38 = load ptr, ptr %t0
  %t39 = getelementptr inbounds %Str_Node, ptr %t38, i32 0, i32 5
  %t40 = load ptr, ptr %t39
  %t41 = call ptr @fn_emit_expr(ptr %t40)
  store ptr %t41, ptr %t42
  %t43 = load ptr, ptr %t42
  %t44 = getelementptr inbounds %Str_Val, ptr %t43, i32 0, i32 0
  %t45 = load ptr, ptr %t44
  %t46 = call ptr @fn_sconcat(ptr %t45, ptr @.str762)
  %t47 = call ptr @fn_sconcat(ptr @.str761, ptr %t46)
  %t48 = call ptr @fn_emit_bind(ptr %t47)
  store ptr %t48, ptr %t49
  %t50 = load ptr, ptr %t49
  %t51 = call ptr @fn_sconcat(ptr %t50, ptr @.str764)
  %t52 = call ptr @fn_sconcat(ptr @.str763, ptr %t51)
  %t53 = call ptr @fn_emit_bind(ptr %t52)
  store ptr %t53, ptr %t54
  call void @fn_emit(ptr @.str765)
  %t55 = load ptr, ptr %t54
  call void @fn_emit(ptr %t55)
  call void @fn_emit(ptr @.str766)
  %t56 = load ptr, ptr %t2
  call void @fn_emit(ptr %t56)
  call void @fn_emit(ptr @.str767)
  call void @fn_emit(ptr @.str768)
  %t57 = load ptr, ptr %t25
  call void @fn_emit(ptr %t57)
  call void @fn_emit(ptr @.str769)
  %t58 = load ptr, ptr %t25
  call void @fn_emit(ptr %t58)
  call void @fn_emit(ptr @.str770)
  %t59 = load ptr, ptr %t2
  %t60 = call ptr @fn_sconcat(ptr @.str771, ptr %t59)
  %t61 = call ptr @fn_emit_bind(ptr %t60)
  %t62 = call ptr @fn_val(ptr %t61, ptr @.str772)
  store ptr %t62, ptr %retval
  br label %ret
ret:
  %t63 = load ptr, ptr %retval
  ret ptr %t63
}

define ptr @fn_cmp_code(ptr %arg_op) {
entry:
  %retval = alloca ptr
  %t0 = alloca ptr
  store ptr %arg_op, ptr %t0
  %t1 = load ptr, ptr %t0
  %t2 = call i32 @fn_streq(ptr %t1, ptr @.str773)
  %t3 = icmp ne i32 %t2, 0
  br i1 %t3, label %then0, label %ifend2
then0:
  store ptr @.str774, ptr %retval
  br label %ret
ifend2:
  %t4 = load ptr, ptr %t0
  %t5 = call i32 @fn_streq(ptr %t4, ptr @.str775)
  %t6 = icmp ne i32 %t5, 0
  br i1 %t6, label %then3, label %ifend5
then3:
  store ptr @.str776, ptr %retval
  br label %ret
ifend5:
  %t7 = load ptr, ptr %t0
  %t8 = call i32 @fn_streq(ptr %t7, ptr @.str777)
  %t9 = icmp ne i32 %t8, 0
  br i1 %t9, label %then6, label %ifend8
then6:
  store ptr @.str778, ptr %retval
  br label %ret
ifend8:
  %t10 = load ptr, ptr %t0
  %t11 = call i32 @fn_streq(ptr %t10, ptr @.str779)
  %t12 = icmp ne i32 %t11, 0
  br i1 %t12, label %then9, label %ifend11
then9:
  store ptr @.str780, ptr %retval
  br label %ret
ifend11:
  %t13 = load ptr, ptr %t0
  %t14 = call i32 @fn_streq(ptr %t13, ptr @.str781)
  %t15 = icmp ne i32 %t14, 0
  br i1 %t15, label %then12, label %ifend14
then12:
  store ptr @.str782, ptr %retval
  br label %ret
ifend14:
  store ptr @.str783, ptr %retval
  br label %ret
ret:
  %t16 = load ptr, ptr %retval
  ret ptr %t16
}

define i32 @fn_is_cmp(ptr %arg_op) {
entry:
  %retval = alloca i32
  %t0 = alloca ptr
  %t1 = alloca i32
  %t2 = alloca i32
  %t3 = alloca i32
  %t4 = alloca i32
  %t5 = alloca i32
  store ptr %arg_op, ptr %t0
  %t6 = load ptr, ptr %t0
  %t7 = call i32 @fn_streq(ptr %t6, ptr @.str784)
  %t8 = icmp ne i32 %t7, 0
  %t9 = zext i1 %t8 to i32
  store i32 %t9, ptr %t5
  br i1 %t8, label %scend1, label %sc0
sc0:
  %t10 = load ptr, ptr %t0
  %t11 = call i32 @fn_streq(ptr %t10, ptr @.str785)
  %t12 = icmp ne i32 %t11, 0
  %t13 = zext i1 %t12 to i32
  store i32 %t13, ptr %t5
  br label %scend1
scend1:
  %t14 = load i32, ptr %t5
  %t15 = icmp ne i32 %t14, 0
  %t16 = zext i1 %t15 to i32
  store i32 %t16, ptr %t4
  br i1 %t15, label %scend3, label %sc2
sc2:
  %t17 = load ptr, ptr %t0
  %t18 = call i32 @fn_streq(ptr %t17, ptr @.str786)
  %t19 = icmp ne i32 %t18, 0
  %t20 = zext i1 %t19 to i32
  store i32 %t20, ptr %t4
  br label %scend3
scend3:
  %t21 = load i32, ptr %t4
  %t22 = icmp ne i32 %t21, 0
  %t23 = zext i1 %t22 to i32
  store i32 %t23, ptr %t3
  br i1 %t22, label %scend5, label %sc4
sc4:
  %t24 = load ptr, ptr %t0
  %t25 = call i32 @fn_streq(ptr %t24, ptr @.str787)
  %t26 = icmp ne i32 %t25, 0
  %t27 = zext i1 %t26 to i32
  store i32 %t27, ptr %t3
  br label %scend5
scend5:
  %t28 = load i32, ptr %t3
  %t29 = icmp ne i32 %t28, 0
  %t30 = zext i1 %t29 to i32
  store i32 %t30, ptr %t2
  br i1 %t29, label %scend7, label %sc6
sc6:
  %t31 = load ptr, ptr %t0
  %t32 = call i32 @fn_streq(ptr %t31, ptr @.str788)
  %t33 = icmp ne i32 %t32, 0
  %t34 = zext i1 %t33 to i32
  store i32 %t34, ptr %t2
  br label %scend7
scend7:
  %t35 = load i32, ptr %t2
  %t36 = icmp ne i32 %t35, 0
  %t37 = zext i1 %t36 to i32
  store i32 %t37, ptr %t1
  br i1 %t36, label %scend9, label %sc8
sc8:
  %t38 = load ptr, ptr %t0
  %t39 = call i32 @fn_streq(ptr %t38, ptr @.str789)
  %t40 = icmp ne i32 %t39, 0
  %t41 = zext i1 %t40 to i32
  store i32 %t41, ptr %t1
  br label %scend9
scend9:
  %t42 = load i32, ptr %t1
  store i32 %t42, ptr %retval
  br label %ret
ret:
  %t43 = load i32, ptr %retval
  ret i32 %t43
}

define ptr @fn_arith_code(ptr %arg_op) {
entry:
  %retval = alloca ptr
  %t0 = alloca ptr
  store ptr %arg_op, ptr %t0
  %t1 = load ptr, ptr %t0
  %t2 = call i32 @fn_streq(ptr %t1, ptr @.str790)
  %t3 = icmp ne i32 %t2, 0
  br i1 %t3, label %then0, label %ifend2
then0:
  store ptr @.str791, ptr %retval
  br label %ret
ifend2:
  %t4 = load ptr, ptr %t0
  %t5 = call i32 @fn_streq(ptr %t4, ptr @.str792)
  %t6 = icmp ne i32 %t5, 0
  br i1 %t6, label %then3, label %ifend5
then3:
  store ptr @.str793, ptr %retval
  br label %ret
ifend5:
  %t7 = load ptr, ptr %t0
  %t8 = call i32 @fn_streq(ptr %t7, ptr @.str794)
  %t9 = icmp ne i32 %t8, 0
  br i1 %t9, label %then6, label %ifend8
then6:
  store ptr @.str795, ptr %retval
  br label %ret
ifend8:
  %t10 = load ptr, ptr %t0
  %t11 = call i32 @fn_streq(ptr %t10, ptr @.str796)
  %t12 = icmp ne i32 %t11, 0
  br i1 %t12, label %then9, label %ifend11
then9:
  store ptr @.str797, ptr %retval
  br label %ret
ifend11:
  store ptr @.str798, ptr %retval
  br label %ret
ret:
  %t13 = load ptr, ptr %retval
  ret ptr %t13
}

define ptr @fn_to_fixed(ptr %arg_v) {
entry:
  %retval = alloca ptr
  %t0 = alloca ptr
  store ptr %arg_v, ptr %t0
  %t1 = load ptr, ptr %t0
  %t2 = getelementptr inbounds %Str_Val, ptr %t1, i32 0, i32 1
  %t3 = load ptr, ptr %t2
  %t4 = call i32 @fn_streq(ptr %t3, ptr @.str799)
  %t5 = icmp ne i32 %t4, 0
  br i1 %t5, label %then0, label %ifend2
then0:
  %t6 = load ptr, ptr %t0
  %t7 = getelementptr inbounds %Str_Val, ptr %t6, i32 0, i32 0
  %t8 = load ptr, ptr %t7
  store ptr %t8, ptr %retval
  br label %ret
ifend2:
  %t9 = load ptr, ptr %t0
  %t10 = getelementptr inbounds %Str_Val, ptr %t9, i32 0, i32 0
  %t11 = load ptr, ptr %t10
  %t12 = call ptr @fn_sconcat(ptr %t11, ptr @.str801)
  %t13 = call ptr @fn_sconcat(ptr @.str800, ptr %t12)
  %t14 = call ptr @fn_emit_bind(ptr %t13)
  store ptr %t14, ptr %retval
  br label %ret
ret:
  %t15 = load ptr, ptr %retval
  ret ptr %t15
}

define ptr @fn_emit_bin(ptr %arg_e) {
entry:
  %retval = alloca ptr
  %t0 = alloca ptr
  %t1 = alloca i32
  %t22 = alloca ptr
  %t27 = alloca ptr
  %t28 = alloca i32
  %t42 = alloca i32
  %t51 = alloca ptr
  %t55 = alloca ptr
  %t74 = alloca ptr
  %t84 = alloca ptr
  %t87 = alloca ptr
  %t97 = alloca ptr
  %t102 = alloca ptr
  %t109 = alloca ptr
  %t114 = alloca ptr
  %t129 = alloca ptr
  %t134 = alloca ptr
  %t139 = alloca ptr
  %t146 = alloca ptr
  %t163 = alloca ptr
  %t181 = alloca ptr
  store ptr %arg_e, ptr %t0
  %t2 = load ptr, ptr %t0
  %t3 = getelementptr inbounds %Str_Node, ptr %t2, i32 0, i32 1
  %t4 = load ptr, ptr %t3
  %t5 = call i32 @fn_streq(ptr %t4, ptr @.str802)
  %t6 = icmp ne i32 %t5, 0
  %t7 = zext i1 %t6 to i32
  store i32 %t7, ptr %t1
  br i1 %t6, label %scend1, label %sc0
sc0:
  %t8 = load ptr, ptr %t0
  %t9 = getelementptr inbounds %Str_Node, ptr %t8, i32 0, i32 1
  %t10 = load ptr, ptr %t9
  %t11 = call i32 @fn_streq(ptr %t10, ptr @.str803)
  %t12 = icmp ne i32 %t11, 0
  %t13 = zext i1 %t12 to i32
  store i32 %t13, ptr %t1
  br label %scend1
scend1:
  %t14 = load i32, ptr %t1
  %t15 = icmp ne i32 %t14, 0
  br i1 %t15, label %then2, label %ifend4
then2:
  %t16 = load ptr, ptr %t0
  %t17 = call ptr @fn_emit_logic(ptr %t16)
  store ptr %t17, ptr %retval
  br label %ret
ifend4:
  %t18 = load ptr, ptr %t0
  %t19 = getelementptr inbounds %Str_Node, ptr %t18, i32 0, i32 4
  %t20 = load ptr, ptr %t19
  %t21 = call ptr @fn_emit_expr(ptr %t20)
  store ptr %t21, ptr %t22
  %t23 = load ptr, ptr %t0
  %t24 = getelementptr inbounds %Str_Node, ptr %t23, i32 0, i32 5
  %t25 = load ptr, ptr %t24
  %t26 = call ptr @fn_emit_expr(ptr %t25)
  store ptr %t26, ptr %t27
  %t29 = load ptr, ptr %t22
  %t30 = getelementptr inbounds %Str_Val, ptr %t29, i32 0, i32 1
  %t31 = load ptr, ptr %t30
  %t32 = call i32 @fn_streq(ptr %t31, ptr @.str804)
  %t33 = icmp ne i32 %t32, 0
  %t34 = zext i1 %t33 to i32
  store i32 %t34, ptr %t28
  br i1 %t33, label %scend6, label %sc5
sc5:
  %t35 = load ptr, ptr %t27
  %t36 = getelementptr inbounds %Str_Val, ptr %t35, i32 0, i32 1
  %t37 = load ptr, ptr %t36
  %t38 = call i32 @fn_streq(ptr %t37, ptr @.str805)
  %t39 = icmp ne i32 %t38, 0
  %t40 = zext i1 %t39 to i32
  store i32 %t40, ptr %t28
  br label %scend6
scend6:
  %t41 = load i32, ptr %t28
  store i32 %t41, ptr %t42
  %t43 = load ptr, ptr %t0
  %t44 = getelementptr inbounds %Str_Node, ptr %t43, i32 0, i32 1
  %t45 = load ptr, ptr %t44
  %t46 = call i32 @fn_is_cmp(ptr %t45)
  %t47 = icmp ne i32 %t46, 0
  br i1 %t47, label %then7, label %ifend9
then7:
  %t48 = load ptr, ptr %t22
  %t49 = getelementptr inbounds %Str_Val, ptr %t48, i32 0, i32 0
  %t50 = load ptr, ptr %t49
  store ptr %t50, ptr %t51
  %t52 = load ptr, ptr %t27
  %t53 = getelementptr inbounds %Str_Val, ptr %t52, i32 0, i32 0
  %t54 = load ptr, ptr %t53
  store ptr %t54, ptr %t55
  %t56 = load i32, ptr %t42
  %t57 = icmp ne i32 %t56, 0
  br i1 %t57, label %then10, label %ifend12
then10:
  %t58 = load ptr, ptr %t22
  %t59 = call ptr @fn_to_fixed(ptr %t58)
  store ptr %t59, ptr %t51
  %t60 = load ptr, ptr %t27
  %t61 = call ptr @fn_to_fixed(ptr %t60)
  store ptr %t61, ptr %t55
  br label %ifend12
ifend12:
  %t62 = load ptr, ptr %t0
  %t63 = getelementptr inbounds %Str_Node, ptr %t62, i32 0, i32 1
  %t64 = load ptr, ptr %t63
  %t65 = call ptr @fn_cmp_code(ptr %t64)
  %t66 = load ptr, ptr %t51
  %t67 = load ptr, ptr %t55
  %t68 = call ptr @fn_sconcat(ptr @.str808, ptr %t67)
  %t69 = call ptr @fn_sconcat(ptr %t66, ptr %t68)
  %t70 = call ptr @fn_sconcat(ptr @.str807, ptr %t69)
  %t71 = call ptr @fn_sconcat(ptr %t65, ptr %t70)
  %t72 = call ptr @fn_sconcat(ptr @.str806, ptr %t71)
  %t73 = call ptr @fn_emit_bind(ptr %t72)
  store ptr %t73, ptr %t74
  %t75 = load ptr, ptr %t74
  %t76 = call ptr @fn_sconcat(ptr %t75, ptr @.str810)
  %t77 = call ptr @fn_sconcat(ptr @.str809, ptr %t76)
  %t78 = call ptr @fn_emit_bind(ptr %t77)
  %t79 = call ptr @fn_val(ptr %t78, ptr @.str811)
  store ptr %t79, ptr %retval
  br label %ret
ifend9:
  %t80 = load i32, ptr %t42
  %t81 = icmp ne i32 %t80, 0
  br i1 %t81, label %then13, label %ifend15
then13:
  %t82 = load ptr, ptr %t22
  %t83 = call ptr @fn_to_fixed(ptr %t82)
  store ptr %t83, ptr %t84
  %t85 = load ptr, ptr %t27
  %t86 = call ptr @fn_to_fixed(ptr %t85)
  store ptr %t86, ptr %t87
  %t88 = load ptr, ptr %t0
  %t89 = getelementptr inbounds %Str_Node, ptr %t88, i32 0, i32 1
  %t90 = load ptr, ptr %t89
  %t91 = call i32 @fn_streq(ptr %t90, ptr @.str812)
  %t92 = icmp ne i32 %t91, 0
  br i1 %t92, label %then16, label %ifend18
then16:
  %t93 = load ptr, ptr %t84
  %t94 = call ptr @fn_sconcat(ptr %t93, ptr @.str814)
  %t95 = call ptr @fn_sconcat(ptr @.str813, ptr %t94)
  %t96 = call ptr @fn_emit_bind(ptr %t95)
  store ptr %t96, ptr %t97
  %t98 = load ptr, ptr %t87
  %t99 = call ptr @fn_sconcat(ptr %t98, ptr @.str816)
  %t100 = call ptr @fn_sconcat(ptr @.str815, ptr %t99)
  %t101 = call ptr @fn_emit_bind(ptr %t100)
  store ptr %t101, ptr %t102
  %t103 = load ptr, ptr %t97
  %t104 = load ptr, ptr %t102
  %t105 = call ptr @fn_sconcat(ptr @.str818, ptr %t104)
  %t106 = call ptr @fn_sconcat(ptr %t103, ptr %t105)
  %t107 = call ptr @fn_sconcat(ptr @.str817, ptr %t106)
  %t108 = call ptr @fn_emit_bind(ptr %t107)
  store ptr %t108, ptr %t109
  %t110 = load ptr, ptr %t109
  %t111 = call ptr @fn_sconcat(ptr %t110, ptr @.str820)
  %t112 = call ptr @fn_sconcat(ptr @.str819, ptr %t111)
  %t113 = call ptr @fn_emit_bind(ptr %t112)
  store ptr %t113, ptr %t114
  %t115 = load ptr, ptr %t114
  %t116 = call ptr @fn_sconcat(ptr %t115, ptr @.str822)
  %t117 = call ptr @fn_sconcat(ptr @.str821, ptr %t116)
  %t118 = call ptr @fn_emit_bind(ptr %t117)
  %t119 = call ptr @fn_val(ptr %t118, ptr @.str823)
  store ptr %t119, ptr %retval
  br label %ret
ifend18:
  %t120 = load ptr, ptr %t0
  %t121 = getelementptr inbounds %Str_Node, ptr %t120, i32 0, i32 1
  %t122 = load ptr, ptr %t121
  %t123 = call i32 @fn_streq(ptr %t122, ptr @.str824)
  %t124 = icmp ne i32 %t123, 0
  br i1 %t124, label %then19, label %ifend21
then19:
  %t125 = load ptr, ptr %t84
  %t126 = call ptr @fn_sconcat(ptr %t125, ptr @.str826)
  %t127 = call ptr @fn_sconcat(ptr @.str825, ptr %t126)
  %t128 = call ptr @fn_emit_bind(ptr %t127)
  store ptr %t128, ptr %t129
  %t130 = load ptr, ptr %t129
  %t131 = call ptr @fn_sconcat(ptr %t130, ptr @.str828)
  %t132 = call ptr @fn_sconcat(ptr @.str827, ptr %t131)
  %t133 = call ptr @fn_emit_bind(ptr %t132)
  store ptr %t133, ptr %t134
  %t135 = load ptr, ptr %t87
  %t136 = call ptr @fn_sconcat(ptr %t135, ptr @.str830)
  %t137 = call ptr @fn_sconcat(ptr @.str829, ptr %t136)
  %t138 = call ptr @fn_emit_bind(ptr %t137)
  store ptr %t138, ptr %t139
  %t140 = load ptr, ptr %t134
  %t141 = load ptr, ptr %t139
  %t142 = call ptr @fn_sconcat(ptr @.str832, ptr %t141)
  %t143 = call ptr @fn_sconcat(ptr %t140, ptr %t142)
  %t144 = call ptr @fn_sconcat(ptr @.str831, ptr %t143)
  %t145 = call ptr @fn_emit_bind(ptr %t144)
  store ptr %t145, ptr %t146
  %t147 = load ptr, ptr %t146
  %t148 = call ptr @fn_sconcat(ptr %t147, ptr @.str834)
  %t149 = call ptr @fn_sconcat(ptr @.str833, ptr %t148)
  %t150 = call ptr @fn_emit_bind(ptr %t149)
  %t151 = call ptr @fn_val(ptr %t150, ptr @.str835)
  store ptr %t151, ptr %retval
  br label %ret
ifend21:
  %t152 = load ptr, ptr %t0
  %t153 = getelementptr inbounds %Str_Node, ptr %t152, i32 0, i32 1
  %t154 = load ptr, ptr %t153
  %t155 = call ptr @fn_arith_code(ptr %t154)
  %t156 = load ptr, ptr %t84
  %t157 = load ptr, ptr %t87
  %t158 = call ptr @fn_sconcat(ptr @.str837, ptr %t157)
  %t159 = call ptr @fn_sconcat(ptr %t156, ptr %t158)
  %t160 = call ptr @fn_sconcat(ptr @.str836, ptr %t159)
  %t161 = call ptr @fn_sconcat(ptr %t155, ptr %t160)
  %t162 = call ptr @fn_emit_bind(ptr %t161)
  store ptr %t162, ptr %t163
  %t164 = load ptr, ptr %t163
  %t165 = call ptr @fn_val(ptr %t164, ptr @.str838)
  store ptr %t165, ptr %retval
  br label %ret
ifend15:
  %t166 = load ptr, ptr %t0
  %t167 = getelementptr inbounds %Str_Node, ptr %t166, i32 0, i32 1
  %t168 = load ptr, ptr %t167
  %t169 = call ptr @fn_arith_code(ptr %t168)
  %t170 = load ptr, ptr %t22
  %t171 = getelementptr inbounds %Str_Val, ptr %t170, i32 0, i32 0
  %t172 = load ptr, ptr %t171
  %t173 = load ptr, ptr %t27
  %t174 = getelementptr inbounds %Str_Val, ptr %t173, i32 0, i32 0
  %t175 = load ptr, ptr %t174
  %t176 = call ptr @fn_sconcat(ptr @.str840, ptr %t175)
  %t177 = call ptr @fn_sconcat(ptr %t172, ptr %t176)
  %t178 = call ptr @fn_sconcat(ptr @.str839, ptr %t177)
  %t179 = call ptr @fn_sconcat(ptr %t169, ptr %t178)
  %t180 = call ptr @fn_emit_bind(ptr %t179)
  store ptr %t180, ptr %t181
  %t182 = load ptr, ptr %t181
  %t183 = call ptr @fn_val(ptr %t182, ptr @.str841)
  store ptr %t183, ptr %retval
  br label %ret
ret:
  %t184 = load ptr, ptr %retval
  ret ptr %t184
}

define ptr @fn_emit_call(ptr %arg_e) {
entry:
  %retval = alloca ptr
  %t0 = alloca ptr
  %t6 = alloca ptr
  %t68 = alloca ptr
  %t87 = alloca ptr
  %t115 = alloca ptr
  %t117 = alloca ptr
  %t124 = alloca ptr
  %t140 = alloca ptr
  %t147 = alloca ptr
  %t148 = alloca i32
  %t167 = alloca ptr
  %t218 = alloca ptr
  %t219 = alloca ptr
  store ptr %arg_e, ptr %t0
  %t1 = load ptr, ptr %t0
  %t2 = getelementptr inbounds %Str_Node, ptr %t1, i32 0, i32 4
  %t3 = load ptr, ptr %t2
  %t4 = getelementptr inbounds %Str_Node, ptr %t3, i32 0, i32 1
  %t5 = load ptr, ptr %t4
  store ptr %t5, ptr %t6
  %t7 = load ptr, ptr %t6
  %t8 = call i32 @fn_streq(ptr %t7, ptr @.str842)
  %t9 = icmp ne i32 %t8, 0
  br i1 %t9, label %then0, label %ifend2
then0:
  %t10 = load i32, ptr @g_nself
  %t11 = icmp eq i32 %t10, 0
  %t12 = zext i1 %t11 to i32
  %t13 = icmp ne i32 %t12, 0
  br i1 %t13, label %then3, label %ifend5
then3:
  %t14 = call ptr @fn_val(ptr @.str843, ptr @.str844)
  store ptr %t14, ptr %retval
  br label %ret
ifend5:
  %t15 = load ptr, ptr @g_self_stk
  %t16 = getelementptr inbounds %LSlice, ptr %t15, i32 0, i32 0
  %t17 = load ptr, ptr %t16
  %t18 = load i32, ptr @g_nself
  %t19 = sub i32 %t18, 1
  %t20 = getelementptr inbounds ptr, ptr %t17, i32 %t19
  %t21 = load ptr, ptr %t20
  %t22 = call ptr @fn_sconcat(ptr @.str845, ptr %t21)
  %t23 = call ptr @fn_emit_bind(ptr %t22)
  %t24 = call ptr @fn_val(ptr %t23, ptr @.str846)
  store ptr %t24, ptr %retval
  br label %ret
ifend2:
  %t25 = load ptr, ptr %t6
  %t26 = call i32 @fn_streq(ptr %t25, ptr @.str847)
  %t27 = icmp ne i32 %t26, 0
  br i1 %t27, label %then6, label %ifend8
then6:
  %t28 = call ptr @fn_emit_bind(ptr @.str848)
  %t29 = call ptr @fn_val(ptr %t28, ptr @.str849)
  store ptr %t29, ptr %retval
  br label %ret
ifend8:
  %t30 = load ptr, ptr %t6
  %t31 = call i32 @fn_streq(ptr %t30, ptr @.str850)
  %t32 = icmp ne i32 %t31, 0
  br i1 %t32, label %then9, label %ifend11
then9:
  call void @fn_emit(ptr @.str851)
  %t33 = call ptr @fn_val(ptr @.str852, ptr @.str853)
  store ptr %t33, ptr %retval
  br label %ret
ifend11:
  %t34 = load ptr, ptr %t6
  %t35 = call i32 @fn_streq(ptr %t34, ptr @.str854)
  %t36 = icmp ne i32 %t35, 0
  br i1 %t36, label %then12, label %ifend14
then12:
  call void @fn_emit(ptr @.str855)
  %t37 = call ptr @fn_val(ptr @.str856, ptr @.str857)
  store ptr %t37, ptr %retval
  br label %ret
ifend14:
  %t38 = load ptr, ptr %t6
  %t39 = call i32 @fn_streq(ptr %t38, ptr @.str858)
  %t40 = icmp ne i32 %t39, 0
  br i1 %t40, label %then15, label %ifend17
then15:
  %t41 = call ptr @fn_emit_bind(ptr @.str859)
  %t42 = call ptr @fn_val(ptr %t41, ptr @.str860)
  store ptr %t42, ptr %retval
  br label %ret
ifend17:
  %t43 = load ptr, ptr %t6
  %t44 = call i32 @fn_streq(ptr %t43, ptr @.str861)
  %t45 = icmp ne i32 %t44, 0
  br i1 %t45, label %then18, label %ifend20
then18:
  call void @fn_emit(ptr @.str862)
  %t46 = call ptr @fn_val(ptr @.str863, ptr @.str864)
  store ptr %t46, ptr %retval
  br label %ret
ifend20:
  %t47 = load ptr, ptr %t6
  %t48 = call i32 @fn_streq(ptr %t47, ptr @.str865)
  %t49 = icmp ne i32 %t48, 0
  br i1 %t49, label %then21, label %ifend23
then21:
  %t50 = load ptr, ptr %t0
  %t51 = call ptr @fn_emit_len(ptr %t50)
  store ptr %t51, ptr %retval
  br label %ret
ifend23:
  %t52 = load ptr, ptr %t6
  %t53 = call i32 @fn_streq(ptr %t52, ptr @.str866)
  %t54 = icmp ne i32 %t53, 0
  br i1 %t54, label %then24, label %ifend26
then24:
  %t55 = load ptr, ptr %t0
  %t56 = call ptr @fn_emit_push(ptr %t55)
  store ptr %t56, ptr %retval
  br label %ret
ifend26:
  %t57 = load ptr, ptr %t6
  %t58 = call i32 @fn_streq(ptr %t57, ptr @.str867)
  %t59 = icmp ne i32 %t58, 0
  br i1 %t59, label %then27, label %ifend29
then27:
  %t60 = load ptr, ptr %t0
  %t61 = getelementptr inbounds %Str_Node, ptr %t60, i32 0, i32 7
  %t62 = load ptr, ptr %t61
  %t63 = getelementptr inbounds %LSlice, ptr %t62, i32 0, i32 0
  %t64 = load ptr, ptr %t63
  %t65 = getelementptr inbounds ptr, ptr %t64, i32 0
  %t66 = load ptr, ptr %t65
  %t67 = call ptr @fn_emit_expr(ptr %t66)
  store ptr %t67, ptr %t68
  %t69 = load ptr, ptr %t68
  %t70 = getelementptr inbounds %Str_Val, ptr %t69, i32 0, i32 0
  %t71 = load ptr, ptr %t70
  %t72 = call ptr @fn_sconcat(ptr %t71, ptr @.str869)
  %t73 = call ptr @fn_sconcat(ptr @.str868, ptr %t72)
  %t74 = call ptr @fn_emit_bind(ptr %t73)
  %t75 = call ptr @fn_val(ptr %t74, ptr @.str870)
  store ptr %t75, ptr %retval
  br label %ret
ifend29:
  %t76 = load ptr, ptr %t6
  %t77 = call i32 @fn_streq(ptr %t76, ptr @.str871)
  %t78 = icmp ne i32 %t77, 0
  br i1 %t78, label %then30, label %ifend32
then30:
  %t79 = load ptr, ptr %t0
  %t80 = getelementptr inbounds %Str_Node, ptr %t79, i32 0, i32 7
  %t81 = load ptr, ptr %t80
  %t82 = getelementptr inbounds %LSlice, ptr %t81, i32 0, i32 0
  %t83 = load ptr, ptr %t82
  %t84 = getelementptr inbounds ptr, ptr %t83, i32 0
  %t85 = load ptr, ptr %t84
  %t86 = call ptr @fn_emit_expr(ptr %t85)
  store ptr %t86, ptr %t87
  %t88 = load ptr, ptr %t87
  %t89 = getelementptr inbounds %Str_Val, ptr %t88, i32 0, i32 0
  %t90 = load ptr, ptr %t89
  %t91 = call ptr @fn_sconcat(ptr %t90, ptr @.str873)
  %t92 = call ptr @fn_sconcat(ptr @.str872, ptr %t91)
  %t93 = call ptr @fn_emit_bind(ptr %t92)
  %t94 = call ptr @fn_val(ptr %t93, ptr @.str874)
  store ptr %t94, ptr %retval
  br label %ret
ifend32:
  %t95 = load ptr, ptr %t6
  %t96 = call i32 @fn_is_intrinsic(ptr %t95)
  %t97 = icmp ne i32 %t96, 0
  br i1 %t97, label %then33, label %ifend35
then33:
  %t98 = load ptr, ptr %t6
  %t99 = load ptr, ptr %t0
  %t100 = call ptr @fn_emit_intrinsic(ptr %t98, ptr %t99)
  store ptr %t100, ptr %retval
  br label %ret
ifend35:
  %t101 = load ptr, ptr %t6
  %t102 = call i32 @fn_is_intrinsic2(ptr %t101)
  %t103 = icmp ne i32 %t102, 0
  br i1 %t103, label %then36, label %ifend38
then36:
  %t104 = load ptr, ptr %t6
  %t105 = load ptr, ptr %t0
  %t106 = call ptr @fn_emit_intrinsic2(ptr %t104, ptr %t105)
  store ptr %t106, ptr %retval
  br label %ret
ifend38:
  %t107 = load ptr, ptr %t6
  %t108 = call i32 @fn_is_math_builtin(ptr %t107)
  %t109 = icmp ne i32 %t108, 0
  br i1 %t109, label %then39, label %ifend41
then39:
  %t110 = load ptr, ptr %t6
  %t111 = load ptr, ptr %t0
  %t112 = call ptr @fn_emit_math_builtin(ptr %t110, ptr %t111)
  store ptr %t112, ptr %retval
  br label %ret
ifend41:
  %t113 = load ptr, ptr %t6
  %t114 = call ptr @fn_find_fn(ptr %t113)
  store ptr %t114, ptr %t115
  %t116 = load ptr, ptr %t6
  store ptr %t116, ptr %t117
  %t118 = load ptr, ptr %t115
  %t119 = icmp eq ptr %t118, null
  %t120 = zext i1 %t119 to i32
  %t121 = icmp ne i32 %t120, 0
  br i1 %t121, label %then42, label %ifend44
then42:
  %t122 = load ptr, ptr %t6
  %t123 = call ptr @fn_sconcat(ptr @.str875, ptr %t122)
  store ptr %t123, ptr %t124
  %t125 = load ptr, ptr %t124
  %t126 = call ptr @fn_find_fn(ptr %t125)
  store ptr %t126, ptr %t115
  %t127 = load ptr, ptr %t115
  %t128 = icmp eq ptr %t127, null
  %t129 = zext i1 %t128 to i32
  %t130 = icmp ne i32 %t129, 0
  br i1 %t130, label %then45, label %ifend47
then45:
  %t131 = load ptr, ptr %t6
  %t132 = call ptr @fn_sconcat(ptr @.str876, ptr %t131)
  call void @fn_perr(ptr %t132)
  br label %ifend47
ifend47:
  %t133 = load ptr, ptr %t124
  store ptr %t133, ptr %t117
  br label %ifend44
ifend44:
  %t134 = getelementptr %LSlice, ptr null, i32 1
  %t135 = ptrtoint ptr %t134 to i64
  %t136 = call ptr @malloc(i64 %t135)
  %t137 = getelementptr inbounds %LSlice, ptr %t136, i32 0, i32 0
  store ptr null, ptr %t137
  %t138 = getelementptr inbounds %LSlice, ptr %t136, i32 0, i32 1
  store i32 0, ptr %t138
  %t139 = getelementptr inbounds %LSlice, ptr %t136, i32 0, i32 2
  store i32 0, ptr %t139
  store ptr %t136, ptr %t140
  %t141 = getelementptr %LSlice, ptr null, i32 1
  %t142 = ptrtoint ptr %t141 to i64
  %t143 = call ptr @malloc(i64 %t142)
  %t144 = getelementptr inbounds %LSlice, ptr %t143, i32 0, i32 0
  store ptr null, ptr %t144
  %t145 = getelementptr inbounds %LSlice, ptr %t143, i32 0, i32 1
  store i32 0, ptr %t145
  %t146 = getelementptr inbounds %LSlice, ptr %t143, i32 0, i32 2
  store i32 0, ptr %t146
  store ptr %t143, ptr %t147
  store i32 0, ptr %t148
  br label %wcond48
wcond48:
  %t149 = load i32, ptr %t148
  %t150 = load ptr, ptr %t0
  %t151 = getelementptr inbounds %Str_Node, ptr %t150, i32 0, i32 7
  %t152 = load ptr, ptr %t151
  %t153 = getelementptr inbounds %LSlice, ptr %t152, i32 0, i32 1
  %t154 = load i32, ptr %t153
  %t155 = icmp slt i32 %t149, %t154
  %t156 = zext i1 %t155 to i32
  %t157 = icmp ne i32 %t156, 0
  br i1 %t157, label %wbody49, label %wend50
wbody49:
  %t158 = load ptr, ptr %t0
  %t159 = getelementptr inbounds %Str_Node, ptr %t158, i32 0, i32 7
  %t160 = load ptr, ptr %t159
  %t161 = getelementptr inbounds %LSlice, ptr %t160, i32 0, i32 0
  %t162 = load ptr, ptr %t161
  %t163 = load i32, ptr %t148
  %t164 = getelementptr inbounds ptr, ptr %t162, i32 %t163
  %t165 = load ptr, ptr %t164
  %t166 = call ptr @fn_emit_expr(ptr %t165)
  store ptr %t166, ptr %t167
  %t168 = load ptr, ptr %t140
  %t169 = getelementptr inbounds %LSlice, ptr %t168, i32 0, i32 1
  %t170 = getelementptr inbounds %LSlice, ptr %t168, i32 0, i32 2
  %t171 = getelementptr inbounds %LSlice, ptr %t168, i32 0, i32 0
  %t172 = load i32, ptr %t169
  %t173 = load i32, ptr %t170
  %t174 = icmp sge i32 %t172, %t173
  br i1 %t174, label %grow51, label %put52
grow51:
  %t175 = mul i32 %t173, 2
  %t176 = icmp eq i32 %t173, 0
  %t177 = select i1 %t176, i32 8, i32 %t175
  %t178 = getelementptr ptr, ptr null, i32 1
  %t179 = ptrtoint ptr %t178 to i64
  %t180 = zext i32 %t177 to i64
  %t181 = mul i64 %t180, %t179
  %t182 = load ptr, ptr %t171
  %t183 = call ptr @realloc(ptr %t182, i64 %t181)
  store ptr %t183, ptr %t171
  store i32 %t177, ptr %t170
  br label %put52
put52:
  %t184 = load ptr, ptr %t167
  %t185 = getelementptr inbounds %Str_Val, ptr %t184, i32 0, i32 0
  %t186 = load ptr, ptr %t185
  %t187 = load ptr, ptr %t171
  %t188 = getelementptr inbounds ptr, ptr %t187, i32 %t172
  store ptr %t186, ptr %t188
  %t189 = add i32 %t172, 1
  store i32 %t189, ptr %t169
  %t190 = load ptr, ptr %t147
  %t191 = getelementptr inbounds %LSlice, ptr %t190, i32 0, i32 1
  %t192 = getelementptr inbounds %LSlice, ptr %t190, i32 0, i32 2
  %t193 = getelementptr inbounds %LSlice, ptr %t190, i32 0, i32 0
  %t194 = load i32, ptr %t191
  %t195 = load i32, ptr %t192
  %t196 = icmp sge i32 %t194, %t195
  br i1 %t196, label %grow53, label %put54
grow53:
  %t197 = mul i32 %t195, 2
  %t198 = icmp eq i32 %t195, 0
  %t199 = select i1 %t198, i32 8, i32 %t197
  %t200 = getelementptr ptr, ptr null, i32 1
  %t201 = ptrtoint ptr %t200 to i64
  %t202 = zext i32 %t199 to i64
  %t203 = mul i64 %t202, %t201
  %t204 = load ptr, ptr %t193
  %t205 = call ptr @realloc(ptr %t204, i64 %t203)
  store ptr %t205, ptr %t193
  store i32 %t199, ptr %t192
  br label %put54
put54:
  %t206 = load ptr, ptr %t167
  %t207 = getelementptr inbounds %Str_Val, ptr %t206, i32 0, i32 1
  %t208 = load ptr, ptr %t207
  %t209 = load ptr, ptr %t193
  %t210 = getelementptr inbounds ptr, ptr %t209, i32 %t194
  store ptr %t208, ptr %t210
  %t211 = add i32 %t194, 1
  store i32 %t211, ptr %t191
  %t212 = load i32, ptr %t148
  %t213 = add i32 %t212, 1
  store i32 %t213, ptr %t148
  br label %wcond48
wend50:
  %t214 = load ptr, ptr %t115
  %t215 = getelementptr inbounds %Str_Node, ptr %t214, i32 0, i32 3
  %t216 = load ptr, ptr %t215
  %t217 = call ptr @fn_llty(ptr %t216)
  store ptr %t217, ptr %t218
  call void @fn_emit(ptr @.str877)
  store ptr @.str878, ptr %t219
  %t220 = load ptr, ptr %t218
  %t221 = call i32 @fn_streq(ptr %t220, ptr @.str879)
  %t222 = icmp eq i32 %t221, 0
  %t223 = zext i1 %t222 to i32
  %t224 = icmp ne i32 %t223, 0
  br i1 %t224, label %then55, label %ifend57
then55:
  %t225 = call ptr @fn_nreg()
  store ptr %t225, ptr %t219
  %t226 = load ptr, ptr %t219
  call void @fn_emit(ptr %t226)
  call void @fn_emit(ptr @.str880)
  br label %ifend57
ifend57:
  call void @fn_emit(ptr @.str881)
  %t227 = load ptr, ptr %t218
  call void @fn_emit(ptr %t227)
  call void @fn_emit(ptr @.str882)
  %t228 = load ptr, ptr %t117
  call void @fn_emit(ptr %t228)
  call void @fn_emit(ptr @.str883)
  store i32 0, ptr %t148
  br label %wcond58
wcond58:
  %t229 = load i32, ptr %t148
  %t230 = load ptr, ptr %t140
  %t231 = getelementptr inbounds %LSlice, ptr %t230, i32 0, i32 1
  %t232 = load i32, ptr %t231
  %t233 = icmp slt i32 %t229, %t232
  %t234 = zext i1 %t233 to i32
  %t235 = icmp ne i32 %t234, 0
  br i1 %t235, label %wbody59, label %wend60
wbody59:
  %t236 = load i32, ptr %t148
  %t237 = icmp sgt i32 %t236, 0
  %t238 = zext i1 %t237 to i32
  %t239 = icmp ne i32 %t238, 0
  br i1 %t239, label %then61, label %ifend63
then61:
  call void @fn_emit(ptr @.str884)
  br label %ifend63
ifend63:
  %t240 = load ptr, ptr %t147
  %t241 = getelementptr inbounds %LSlice, ptr %t240, i32 0, i32 0
  %t242 = load ptr, ptr %t241
  %t243 = load i32, ptr %t148
  %t244 = getelementptr inbounds ptr, ptr %t242, i32 %t243
  %t245 = load ptr, ptr %t244
  %t246 = call ptr @fn_llty(ptr %t245)
  call void @fn_emit(ptr %t246)
  call void @fn_emit(ptr @.str885)
  %t247 = load ptr, ptr %t140
  %t248 = getelementptr inbounds %LSlice, ptr %t247, i32 0, i32 0
  %t249 = load ptr, ptr %t248
  %t250 = load i32, ptr %t148
  %t251 = getelementptr inbounds ptr, ptr %t249, i32 %t250
  %t252 = load ptr, ptr %t251
  call void @fn_emit(ptr %t252)
  %t253 = load i32, ptr %t148
  %t254 = add i32 %t253, 1
  store i32 %t254, ptr %t148
  br label %wcond58
wend60:
  call void @fn_emit(ptr @.str886)
  %t255 = load ptr, ptr %t219
  %t256 = load ptr, ptr %t115
  %t257 = getelementptr inbounds %Str_Node, ptr %t256, i32 0, i32 3
  %t258 = load ptr, ptr %t257
  %t259 = call ptr @fn_val(ptr %t255, ptr %t258)
  store ptr %t259, ptr %retval
  br label %ret
ret:
  %t260 = load ptr, ptr %retval
  ret ptr %t260
}

define ptr @fn_emit_expr(ptr %arg_e) {
entry:
  %retval = alloca ptr
  %t0 = alloca ptr
  %t79 = alloca i32
  %t101 = alloca ptr
  %t132 = alloca ptr
  %t176 = alloca i32
  %t186 = alloca ptr
  %t198 = alloca ptr
  %t228 = alloca ptr
  %t246 = alloca ptr
  store ptr %arg_e, ptr %t0
  %t1 = load ptr, ptr %t0
  %t2 = icmp eq ptr %t1, null
  %t3 = zext i1 %t2 to i32
  %t4 = icmp ne i32 %t3, 0
  br i1 %t4, label %then0, label %ifend2
then0:
  %t5 = call ptr @fn_val(ptr @.str887, ptr @.str888)
  store ptr %t5, ptr %retval
  br label %ret
ifend2:
  %t6 = load ptr, ptr %t0
  %t7 = getelementptr inbounds %Str_Node, ptr %t6, i32 0, i32 0
  %t8 = load i32, ptr %t7
  %t9 = icmp eq i32 %t8, 30
  %t10 = zext i1 %t9 to i32
  %t11 = icmp ne i32 %t10, 0
  br i1 %t11, label %then3, label %ifend5
then3:
  %t12 = load ptr, ptr %t0
  %t13 = getelementptr inbounds %Str_Node, ptr %t12, i32 0, i32 2
  %t14 = load i32, ptr %t13
  %t15 = call ptr @fn_itoa(i32 %t14)
  %t16 = call ptr @fn_val(ptr %t15, ptr @.str889)
  store ptr %t16, ptr %retval
  br label %ret
ifend5:
  %t17 = load ptr, ptr %t0
  %t18 = getelementptr inbounds %Str_Node, ptr %t17, i32 0, i32 0
  %t19 = load i32, ptr %t18
  %t20 = icmp eq i32 %t19, 40
  %t21 = zext i1 %t20 to i32
  %t22 = icmp ne i32 %t21, 0
  br i1 %t22, label %then6, label %ifend8
then6:
  %t23 = load ptr, ptr %t0
  %t24 = getelementptr inbounds %Str_Node, ptr %t23, i32 0, i32 2
  %t25 = load i32, ptr %t24
  %t26 = call ptr @fn_itoa(i32 %t25)
  %t27 = call ptr @fn_val(ptr %t26, ptr @.str890)
  store ptr %t27, ptr %retval
  br label %ret
ifend8:
  %t28 = load ptr, ptr %t0
  %t29 = getelementptr inbounds %Str_Node, ptr %t28, i32 0, i32 0
  %t30 = load i32, ptr %t29
  %t31 = icmp eq i32 %t30, 32
  %t32 = zext i1 %t31 to i32
  %t33 = icmp ne i32 %t32, 0
  br i1 %t33, label %then9, label %ifend11
then9:
  %t34 = load ptr, ptr %t0
  %t35 = getelementptr inbounds %Str_Node, ptr %t34, i32 0, i32 2
  %t36 = load i32, ptr %t35
  %t37 = call ptr @fn_itoa(i32 %t36)
  %t38 = call ptr @fn_val(ptr %t37, ptr @.str891)
  store ptr %t38, ptr %retval
  br label %ret
ifend11:
  %t39 = load ptr, ptr %t0
  %t40 = getelementptr inbounds %Str_Node, ptr %t39, i32 0, i32 0
  %t41 = load i32, ptr %t40
  %t42 = icmp eq i32 %t41, 31
  %t43 = zext i1 %t42 to i32
  %t44 = icmp ne i32 %t43, 0
  br i1 %t44, label %then12, label %ifend14
then12:
  %t45 = load ptr, ptr %t0
  %t46 = getelementptr inbounds %Str_Node, ptr %t45, i32 0, i32 1
  %t47 = load ptr, ptr %t46
  %t48 = call ptr @fn_emit_str_const(ptr %t47)
  %t49 = call ptr @fn_val(ptr %t48, ptr @.str892)
  store ptr %t49, ptr %retval
  br label %ret
ifend14:
  %t50 = load ptr, ptr %t0
  %t51 = getelementptr inbounds %Str_Node, ptr %t50, i32 0, i32 0
  %t52 = load i32, ptr %t51
  %t53 = icmp eq i32 %t52, 39
  %t54 = zext i1 %t53 to i32
  %t55 = icmp ne i32 %t54, 0
  br i1 %t55, label %then15, label %ifend17
then15:
  %t56 = load ptr, ptr %t0
  %t57 = getelementptr inbounds %Str_Node, ptr %t56, i32 0, i32 1
  %t58 = load ptr, ptr %t57
  %t59 = call i32 @fn_is_slice_ty(ptr %t58)
  %t60 = icmp ne i32 %t59, 0
  br i1 %t60, label %then18, label %ifend20
then18:
  %t61 = load ptr, ptr %t0
  %t62 = getelementptr inbounds %Str_Node, ptr %t61, i32 0, i32 1
  %t63 = load ptr, ptr %t62
  %t64 = call ptr @fn_emit_new_slice(ptr %t63)
  store ptr %t64, ptr %retval
  br label %ret
ifend20:
  %t65 = load ptr, ptr %t0
  %t66 = getelementptr inbounds %Str_Node, ptr %t65, i32 0, i32 1
  %t67 = load ptr, ptr %t66
  %t68 = call ptr @fn_emit_new_struct(ptr %t67)
  store ptr %t68, ptr %retval
  br label %ret
ifend17:
  %t69 = load ptr, ptr %t0
  %t70 = getelementptr inbounds %Str_Node, ptr %t69, i32 0, i32 0
  %t71 = load i32, ptr %t70
  %t72 = icmp eq i32 %t71, 33
  %t73 = zext i1 %t72 to i32
  %t74 = icmp ne i32 %t73, 0
  br i1 %t74, label %then21, label %ifend23
then21:
  %t75 = load ptr, ptr %t0
  %t76 = getelementptr inbounds %Str_Node, ptr %t75, i32 0, i32 1
  %t77 = load ptr, ptr %t76
  %t78 = call i32 @fn_loc_find(ptr %t77)
  store i32 %t78, ptr %t79
  %t80 = load i32, ptr %t79
  %t81 = icmp sge i32 %t80, 0
  %t82 = zext i1 %t81 to i32
  %t83 = icmp ne i32 %t82, 0
  br i1 %t83, label %then24, label %ifend26
then24:
  %t84 = load ptr, ptr @g_loc_reg
  %t85 = getelementptr inbounds %LSlice, ptr %t84, i32 0, i32 0
  %t86 = load ptr, ptr %t85
  %t87 = load i32, ptr %t79
  %t88 = getelementptr inbounds ptr, ptr %t86, i32 %t87
  %t89 = load ptr, ptr %t88
  %t90 = load ptr, ptr @g_loc_ty
  %t91 = getelementptr inbounds %LSlice, ptr %t90, i32 0, i32 0
  %t92 = load ptr, ptr %t91
  %t93 = load i32, ptr %t79
  %t94 = getelementptr inbounds ptr, ptr %t92, i32 %t93
  %t95 = load ptr, ptr %t94
  %t96 = call ptr @fn_emit_load_at(ptr %t89, ptr %t95)
  store ptr %t96, ptr %retval
  br label %ret
ifend26:
  %t97 = load ptr, ptr %t0
  %t98 = getelementptr inbounds %Str_Node, ptr %t97, i32 0, i32 1
  %t99 = load ptr, ptr %t98
  %t100 = call ptr @fn_find_global(ptr %t99)
  store ptr %t100, ptr %t101
  %t102 = load ptr, ptr %t101
  %t103 = icmp eq ptr %t102, null
  %t104 = zext i1 %t103 to i32
  %t105 = icmp eq i32 %t104, 0
  %t106 = zext i1 %t105 to i32
  %t107 = icmp ne i32 %t106, 0
  br i1 %t107, label %then27, label %ifend29
then27:
  %t108 = load ptr, ptr %t101
  %t109 = getelementptr inbounds %Str_Node, ptr %t108, i32 0, i32 0
  %t110 = load i32, ptr %t109
  %t111 = icmp eq i32 %t110, 3
  %t112 = zext i1 %t111 to i32
  %t113 = icmp ne i32 %t112, 0
  br i1 %t113, label %then30, label %ifend32
then30:
  %t114 = load ptr, ptr %t101
  %t115 = getelementptr inbounds %Str_Node, ptr %t114, i32 0, i32 4
  %t116 = load ptr, ptr %t115
  %t117 = getelementptr inbounds %Str_Node, ptr %t116, i32 0, i32 2
  %t118 = load i32, ptr %t117
  %t119 = call ptr @fn_itoa(i32 %t118)
  %t120 = call ptr @fn_val(ptr %t119, ptr @.str893)
  store ptr %t120, ptr %retval
  br label %ret
ifend32:
  %t121 = load ptr, ptr %t101
  %t122 = getelementptr inbounds %Str_Node, ptr %t121, i32 0, i32 3
  %t123 = load ptr, ptr %t122
  %t124 = call ptr @fn_llty(ptr %t123)
  %t125 = load ptr, ptr %t0
  %t126 = getelementptr inbounds %Str_Node, ptr %t125, i32 0, i32 1
  %t127 = load ptr, ptr %t126
  %t128 = call ptr @fn_sconcat(ptr @.str895, ptr %t127)
  %t129 = call ptr @fn_sconcat(ptr %t124, ptr %t128)
  %t130 = call ptr @fn_sconcat(ptr @.str894, ptr %t129)
  %t131 = call ptr @fn_emit_bind(ptr %t130)
  store ptr %t131, ptr %t132
  %t133 = load ptr, ptr %t132
  %t134 = load ptr, ptr %t101
  %t135 = getelementptr inbounds %Str_Node, ptr %t134, i32 0, i32 3
  %t136 = load ptr, ptr %t135
  %t137 = call ptr @fn_val(ptr %t133, ptr %t136)
  store ptr %t137, ptr %retval
  br label %ret
ifend29:
  %t138 = load ptr, ptr %t0
  %t139 = getelementptr inbounds %Str_Node, ptr %t138, i32 0, i32 1
  %t140 = load ptr, ptr %t139
  %t141 = call i32 @fn_is_ui_ident(ptr %t140)
  %t142 = icmp ne i32 %t141, 0
  br i1 %t142, label %then33, label %ifend35
then33:
  %t143 = load ptr, ptr %t0
  %t144 = getelementptr inbounds %Str_Node, ptr %t143, i32 0, i32 1
  %t145 = load ptr, ptr %t144
  %t146 = call i32 @fn_ui_index_of(ptr %t145)
  %t147 = call ptr @fn_itoa(i32 %t146)
  %t148 = call ptr @fn_val(ptr %t147, ptr @.str896)
  store ptr %t148, ptr %retval
  br label %ret
ifend35:
  %t149 = load ptr, ptr %t0
  %t150 = getelementptr inbounds %Str_Node, ptr %t149, i32 0, i32 1
  %t151 = load ptr, ptr %t150
  %t152 = call ptr @fn_sconcat(ptr @.str897, ptr %t151)
  call void @fn_perr(ptr %t152)
  br label %ifend23
ifend23:
  %t153 = load ptr, ptr %t0
  %t154 = getelementptr inbounds %Str_Node, ptr %t153, i32 0, i32 0
  %t155 = load i32, ptr %t154
  %t156 = icmp eq i32 %t155, 35
  %t157 = zext i1 %t156 to i32
  %t158 = icmp ne i32 %t157, 0
  br i1 %t158, label %then36, label %ifend38
then36:
  %t159 = load ptr, ptr %t0
  %t160 = getelementptr inbounds %Str_Node, ptr %t159, i32 0, i32 4
  %t161 = load ptr, ptr %t160
  %t162 = getelementptr inbounds %Str_Node, ptr %t161, i32 0, i32 0
  %t163 = load i32, ptr %t162
  %t164 = icmp eq i32 %t163, 33
  %t165 = zext i1 %t164 to i32
  %t166 = icmp ne i32 %t165, 0
  br i1 %t166, label %then39, label %ifend41
then39:
  %t167 = load ptr, ptr %t0
  %t168 = getelementptr inbounds %Str_Node, ptr %t167, i32 0, i32 4
  %t169 = load ptr, ptr %t168
  %t170 = getelementptr inbounds %Str_Node, ptr %t169, i32 0, i32 1
  %t171 = load ptr, ptr %t170
  %t172 = load ptr, ptr %t0
  %t173 = getelementptr inbounds %Str_Node, ptr %t172, i32 0, i32 1
  %t174 = load ptr, ptr %t173
  %t175 = call i32 @fn_enum_ordinal(ptr %t171, ptr %t174)
  store i32 %t175, ptr %t176
  %t177 = load i32, ptr %t176
  %t178 = icmp sge i32 %t177, 0
  %t179 = zext i1 %t178 to i32
  %t180 = icmp ne i32 %t179, 0
  br i1 %t180, label %then42, label %ifend44
then42:
  %t181 = load i32, ptr %t176
  %t182 = call ptr @fn_itoa(i32 %t181)
  %t183 = call ptr @fn_val(ptr %t182, ptr @.str898)
  store ptr %t183, ptr %retval
  br label %ret
ifend44:
  br label %ifend41
ifend41:
  %t184 = load ptr, ptr %t0
  %t185 = call ptr @fn_emit_member_addr(ptr %t184)
  store ptr %t185, ptr %t186
  %t187 = load ptr, ptr %t186
  %t188 = load ptr, ptr @g_g_addr_ty
  %t189 = call ptr @fn_emit_load_at(ptr %t187, ptr %t188)
  store ptr %t189, ptr %retval
  br label %ret
ifend38:
  %t190 = load ptr, ptr %t0
  %t191 = getelementptr inbounds %Str_Node, ptr %t190, i32 0, i32 0
  %t192 = load i32, ptr %t191
  %t193 = icmp eq i32 %t192, 36
  %t194 = zext i1 %t193 to i32
  %t195 = icmp ne i32 %t194, 0
  br i1 %t195, label %then45, label %ifend47
then45:
  %t196 = load ptr, ptr %t0
  %t197 = call ptr @fn_emit_index_addr(ptr %t196)
  store ptr %t197, ptr %t198
  %t199 = load ptr, ptr %t198
  %t200 = load ptr, ptr @g_g_addr_ty
  %t201 = call ptr @fn_emit_load_at(ptr %t199, ptr %t200)
  store ptr %t201, ptr %retval
  br label %ret
ifend47:
  %t202 = load ptr, ptr %t0
  %t203 = getelementptr inbounds %Str_Node, ptr %t202, i32 0, i32 0
  %t204 = load i32, ptr %t203
  %t205 = icmp eq i32 %t204, 34
  %t206 = zext i1 %t205 to i32
  %t207 = icmp ne i32 %t206, 0
  br i1 %t207, label %then48, label %ifend50
then48:
  %t208 = load ptr, ptr %t0
  %t209 = call ptr @fn_emit_call(ptr %t208)
  store ptr %t209, ptr %retval
  br label %ret
ifend50:
  %t210 = load ptr, ptr %t0
  %t211 = getelementptr inbounds %Str_Node, ptr %t210, i32 0, i32 0
  %t212 = load i32, ptr %t211
  %t213 = icmp eq i32 %t212, 37
  %t214 = zext i1 %t213 to i32
  %t215 = icmp ne i32 %t214, 0
  br i1 %t215, label %then51, label %ifend53
then51:
  %t216 = load ptr, ptr %t0
  %t217 = call ptr @fn_emit_bin(ptr %t216)
  store ptr %t217, ptr %retval
  br label %ret
ifend53:
  %t218 = load ptr, ptr %t0
  %t219 = getelementptr inbounds %Str_Node, ptr %t218, i32 0, i32 0
  %t220 = load i32, ptr %t219
  %t221 = icmp eq i32 %t220, 38
  %t222 = zext i1 %t221 to i32
  %t223 = icmp ne i32 %t222, 0
  br i1 %t223, label %then54, label %ifend56
then54:
  %t224 = load ptr, ptr %t0
  %t225 = getelementptr inbounds %Str_Node, ptr %t224, i32 0, i32 4
  %t226 = load ptr, ptr %t225
  %t227 = call ptr @fn_emit_expr(ptr %t226)
  store ptr %t227, ptr %t228
  %t229 = load ptr, ptr %t0
  %t230 = getelementptr inbounds %Str_Node, ptr %t229, i32 0, i32 1
  %t231 = load ptr, ptr %t230
  %t232 = call i32 @fn_streq(ptr %t231, ptr @.str899)
  %t233 = icmp ne i32 %t232, 0
  br i1 %t233, label %then57, label %ifend59
then57:
  %t234 = load ptr, ptr %t228
  %t235 = getelementptr inbounds %Str_Val, ptr %t234, i32 0, i32 0
  %t236 = load ptr, ptr %t235
  %t237 = call ptr @fn_sconcat(ptr @.str900, ptr %t236)
  %t238 = call ptr @fn_emit_bind(ptr %t237)
  %t239 = call ptr @fn_val(ptr %t238, ptr @.str901)
  store ptr %t239, ptr %retval
  br label %ret
ifend59:
  %t240 = load ptr, ptr %t228
  %t241 = getelementptr inbounds %Str_Val, ptr %t240, i32 0, i32 0
  %t242 = load ptr, ptr %t241
  %t243 = call ptr @fn_sconcat(ptr %t242, ptr @.str903)
  %t244 = call ptr @fn_sconcat(ptr @.str902, ptr %t243)
  %t245 = call ptr @fn_emit_bind(ptr %t244)
  store ptr %t245, ptr %t246
  %t247 = load ptr, ptr %t246
  %t248 = call ptr @fn_sconcat(ptr %t247, ptr @.str905)
  %t249 = call ptr @fn_sconcat(ptr @.str904, ptr %t248)
  %t250 = call ptr @fn_emit_bind(ptr %t249)
  %t251 = call ptr @fn_val(ptr %t250, ptr @.str906)
  store ptr %t251, ptr %retval
  br label %ret
ifend56:
  call void @fn_perr(ptr @.str907)
  %t252 = call ptr @fn_val(ptr @.str908, ptr @.str909)
  store ptr %t252, ptr %retval
  br label %ret
ret:
  %t253 = load ptr, ptr %retval
  ret ptr %t253
}

define void @fn_emit_block(ptr %arg_b) {
entry:
  %t0 = alloca ptr
  %t1 = alloca i32
  store ptr %arg_b, ptr %t0
  store i32 0, ptr %t1
  br label %wcond0
wcond0:
  %t2 = load i32, ptr %t1
  %t3 = load ptr, ptr %t0
  %t4 = getelementptr inbounds %Str_Node, ptr %t3, i32 0, i32 7
  %t5 = load ptr, ptr %t4
  %t6 = getelementptr inbounds %LSlice, ptr %t5, i32 0, i32 1
  %t7 = load i32, ptr %t6
  %t8 = icmp slt i32 %t2, %t7
  %t9 = zext i1 %t8 to i32
  %t10 = icmp ne i32 %t9, 0
  br i1 %t10, label %wbody1, label %wend2
wbody1:
  %t11 = load i32, ptr @g_g_term
  %t12 = icmp ne i32 %t11, 0
  br i1 %t12, label %then3, label %ifend5
then3:
  br label %ret
ifend5:
  %t13 = load ptr, ptr %t0
  %t14 = getelementptr inbounds %Str_Node, ptr %t13, i32 0, i32 7
  %t15 = load ptr, ptr %t14
  %t16 = getelementptr inbounds %LSlice, ptr %t15, i32 0, i32 0
  %t17 = load ptr, ptr %t16
  %t18 = load i32, ptr %t1
  %t19 = getelementptr inbounds ptr, ptr %t17, i32 %t18
  %t20 = load ptr, ptr %t19
  call void @fn_emit_stmt(ptr %t20)
  %t21 = load i32, ptr %t1
  %t22 = add i32 %t21, 1
  store i32 %t22, ptr %t1
  br label %wcond0
wend2:
  br label %ret
ret:
  ret void
}

define void @fn_store_at(ptr %arg_lt, ptr %arg_v, ptr %arg_addr) {
entry:
  %t0 = alloca ptr
  %t1 = alloca ptr
  %t2 = alloca ptr
  store ptr %arg_lt, ptr %t0
  store ptr %arg_v, ptr %t1
  store ptr %arg_addr, ptr %t2
  call void @fn_emit(ptr @.str910)
  %t3 = load ptr, ptr %t0
  call void @fn_emit(ptr %t3)
  call void @fn_emit(ptr @.str911)
  %t4 = load ptr, ptr %t1
  call void @fn_emit(ptr %t4)
  call void @fn_emit(ptr @.str912)
  %t5 = load ptr, ptr %t2
  call void @fn_emit(ptr %t5)
  call void @fn_emit(ptr @.str913)
  br label %ret
ret:
  ret void
}

define void @fn_emit_assign(ptr %arg_st) {
entry:
  %t0 = alloca ptr
  %t4 = alloca ptr
  %t5 = alloca ptr
  %t6 = alloca ptr
  %t17 = alloca i32
  %t38 = alloca ptr
  %t74 = alloca ptr
  %t79 = alloca ptr
  %t83 = alloca ptr
  %t97 = alloca ptr
  %t98 = alloca ptr
  store ptr %arg_st, ptr %t0
  %t1 = load ptr, ptr %t0
  %t2 = getelementptr inbounds %Str_Node, ptr %t1, i32 0, i32 4
  %t3 = load ptr, ptr %t2
  store ptr %t3, ptr %t4
  store ptr @.str914, ptr %t5
  store ptr @.str915, ptr %t6
  %t7 = load ptr, ptr %t4
  %t8 = getelementptr inbounds %Str_Node, ptr %t7, i32 0, i32 0
  %t9 = load i32, ptr %t8
  %t10 = icmp eq i32 %t9, 33
  %t11 = zext i1 %t10 to i32
  %t12 = icmp ne i32 %t11, 0
  br i1 %t12, label %then0, label %else1
then0:
  %t13 = load ptr, ptr %t4
  %t14 = getelementptr inbounds %Str_Node, ptr %t13, i32 0, i32 1
  %t15 = load ptr, ptr %t14
  %t16 = call i32 @fn_loc_find(ptr %t15)
  store i32 %t16, ptr %t17
  %t18 = load i32, ptr %t17
  %t19 = icmp sge i32 %t18, 0
  %t20 = zext i1 %t19 to i32
  %t21 = icmp ne i32 %t20, 0
  br i1 %t21, label %then3, label %else4
then3:
  %t22 = load ptr, ptr @g_loc_reg
  %t23 = getelementptr inbounds %LSlice, ptr %t22, i32 0, i32 0
  %t24 = load ptr, ptr %t23
  %t25 = load i32, ptr %t17
  %t26 = getelementptr inbounds ptr, ptr %t24, i32 %t25
  %t27 = load ptr, ptr %t26
  store ptr %t27, ptr %t5
  %t28 = load ptr, ptr @g_loc_ty
  %t29 = getelementptr inbounds %LSlice, ptr %t28, i32 0, i32 0
  %t30 = load ptr, ptr %t29
  %t31 = load i32, ptr %t17
  %t32 = getelementptr inbounds ptr, ptr %t30, i32 %t31
  %t33 = load ptr, ptr %t32
  store ptr %t33, ptr %t6
  br label %ifend5
else4:
  %t34 = load ptr, ptr %t4
  %t35 = getelementptr inbounds %Str_Node, ptr %t34, i32 0, i32 1
  %t36 = load ptr, ptr %t35
  %t37 = call ptr @fn_find_global(ptr %t36)
  store ptr %t37, ptr %t38
  %t39 = load ptr, ptr %t38
  %t40 = icmp eq ptr %t39, null
  %t41 = zext i1 %t40 to i32
  %t42 = icmp ne i32 %t41, 0
  br i1 %t42, label %then6, label %ifend8
then6:
  %t43 = load ptr, ptr %t4
  %t44 = getelementptr inbounds %Str_Node, ptr %t43, i32 0, i32 1
  %t45 = load ptr, ptr %t44
  %t46 = call ptr @fn_sconcat(ptr @.str916, ptr %t45)
  call void @fn_perr(ptr %t46)
  br label %ifend8
ifend8:
  %t47 = load ptr, ptr %t4
  %t48 = getelementptr inbounds %Str_Node, ptr %t47, i32 0, i32 1
  %t49 = load ptr, ptr %t48
  %t50 = call ptr @fn_sconcat(ptr @.str917, ptr %t49)
  store ptr %t50, ptr %t5
  %t51 = load ptr, ptr %t38
  %t52 = getelementptr inbounds %Str_Node, ptr %t51, i32 0, i32 3
  %t53 = load ptr, ptr %t52
  store ptr %t53, ptr %t6
  br label %ifend5
ifend5:
  br label %ifend2
else1:
  %t54 = load ptr, ptr %t4
  %t55 = getelementptr inbounds %Str_Node, ptr %t54, i32 0, i32 0
  %t56 = load i32, ptr %t55
  %t57 = icmp eq i32 %t56, 35
  %t58 = zext i1 %t57 to i32
  %t59 = icmp ne i32 %t58, 0
  br i1 %t59, label %then9, label %else10
then9:
  %t60 = load ptr, ptr %t4
  %t61 = call ptr @fn_emit_member_addr(ptr %t60)
  store ptr %t61, ptr %t5
  %t62 = load ptr, ptr @g_g_addr_ty
  store ptr %t62, ptr %t6
  br label %ifend11
else10:
  %t63 = load ptr, ptr %t4
  %t64 = getelementptr inbounds %Str_Node, ptr %t63, i32 0, i32 0
  %t65 = load i32, ptr %t64
  %t66 = icmp eq i32 %t65, 36
  %t67 = zext i1 %t66 to i32
  %t68 = icmp ne i32 %t67, 0
  br i1 %t68, label %then12, label %else13
then12:
  %t69 = load ptr, ptr %t4
  %t70 = call ptr @fn_emit_index_addr(ptr %t69)
  store ptr %t70, ptr %t5
  %t71 = load ptr, ptr @g_g_addr_ty
  store ptr %t71, ptr %t6
  br label %ifend14
else13:
  call void @fn_perr(ptr @.str918)
  br label %ifend14
ifend14:
  br label %ifend11
ifend11:
  br label %ifend2
ifend2:
  %t72 = load ptr, ptr %t6
  %t73 = call ptr @fn_llty(ptr %t72)
  store ptr %t73, ptr %t74
  %t75 = load ptr, ptr %t0
  %t76 = getelementptr inbounds %Str_Node, ptr %t75, i32 0, i32 5
  %t77 = load ptr, ptr %t76
  %t78 = call ptr @fn_emit_expr(ptr %t77)
  store ptr %t78, ptr %t79
  %t80 = load ptr, ptr %t79
  %t81 = getelementptr inbounds %Str_Val, ptr %t80, i32 0, i32 0
  %t82 = load ptr, ptr %t81
  store ptr %t82, ptr %t83
  %t84 = load ptr, ptr %t0
  %t85 = getelementptr inbounds %Str_Node, ptr %t84, i32 0, i32 1
  %t86 = load ptr, ptr %t85
  %t87 = call i32 @fn_streq(ptr %t86, ptr @.str919)
  %t88 = icmp eq i32 %t87, 0
  %t89 = zext i1 %t88 to i32
  %t90 = icmp ne i32 %t89, 0
  br i1 %t90, label %then15, label %ifend17
then15:
  %t91 = load ptr, ptr %t74
  %t92 = load ptr, ptr %t5
  %t93 = call ptr @fn_sconcat(ptr @.str921, ptr %t92)
  %t94 = call ptr @fn_sconcat(ptr %t91, ptr %t93)
  %t95 = call ptr @fn_sconcat(ptr @.str920, ptr %t94)
  %t96 = call ptr @fn_emit_bind(ptr %t95)
  store ptr %t96, ptr %t97
  store ptr @.str922, ptr %t98
  %t99 = load ptr, ptr %t0
  %t100 = getelementptr inbounds %Str_Node, ptr %t99, i32 0, i32 1
  %t101 = load ptr, ptr %t100
  %t102 = call i32 @fn_streq(ptr %t101, ptr @.str923)
  %t103 = icmp ne i32 %t102, 0
  br i1 %t103, label %then18, label %ifend20
then18:
  store ptr @.str924, ptr %t98
  br label %ifend20
ifend20:
  %t104 = load ptr, ptr %t0
  %t105 = getelementptr inbounds %Str_Node, ptr %t104, i32 0, i32 1
  %t106 = load ptr, ptr %t105
  %t107 = call i32 @fn_streq(ptr %t106, ptr @.str925)
  %t108 = icmp ne i32 %t107, 0
  br i1 %t108, label %then21, label %ifend23
then21:
  store ptr @.str926, ptr %t98
  br label %ifend23
ifend23:
  %t109 = load ptr, ptr %t0
  %t110 = getelementptr inbounds %Str_Node, ptr %t109, i32 0, i32 1
  %t111 = load ptr, ptr %t110
  %t112 = call i32 @fn_streq(ptr %t111, ptr @.str927)
  %t113 = icmp ne i32 %t112, 0
  br i1 %t113, label %then24, label %ifend26
then24:
  store ptr @.str928, ptr %t98
  br label %ifend26
ifend26:
  %t114 = load ptr, ptr %t98
  %t115 = load ptr, ptr %t97
  %t116 = load ptr, ptr %t83
  %t117 = call ptr @fn_sconcat(ptr @.str930, ptr %t116)
  %t118 = call ptr @fn_sconcat(ptr %t115, ptr %t117)
  %t119 = call ptr @fn_sconcat(ptr @.str929, ptr %t118)
  %t120 = call ptr @fn_sconcat(ptr %t114, ptr %t119)
  %t121 = call ptr @fn_emit_bind(ptr %t120)
  store ptr %t121, ptr %t83
  br label %ifend17
ifend17:
  %t122 = load ptr, ptr %t74
  %t123 = load ptr, ptr %t83
  %t124 = load ptr, ptr %t5
  call void @fn_store_at(ptr %t122, ptr %t123, ptr %t124)
  br label %ret
ret:
  ret void
}

define void @fn_emit_if(ptr %arg_st) {
entry:
  %t0 = alloca ptr
  %t5 = alloca ptr
  %t12 = alloca ptr
  %t20 = alloca i32
  %t22 = alloca ptr
  %t24 = alloca ptr
  %t26 = alloca ptr
  store ptr %arg_st, ptr %t0
  %t1 = load ptr, ptr %t0
  %t2 = getelementptr inbounds %Str_Node, ptr %t1, i32 0, i32 4
  %t3 = load ptr, ptr %t2
  %t4 = call ptr @fn_emit_expr(ptr %t3)
  store ptr %t4, ptr %t5
  %t6 = load ptr, ptr %t5
  %t7 = getelementptr inbounds %Str_Val, ptr %t6, i32 0, i32 0
  %t8 = load ptr, ptr %t7
  %t9 = call ptr @fn_sconcat(ptr %t8, ptr @.str932)
  %t10 = call ptr @fn_sconcat(ptr @.str931, ptr %t9)
  %t11 = call ptr @fn_emit_bind(ptr %t10)
  store ptr %t11, ptr %t12
  %t13 = load ptr, ptr %t0
  %t14 = getelementptr inbounds %Str_Node, ptr %t13, i32 0, i32 6
  %t15 = load ptr, ptr %t14
  %t16 = icmp eq ptr %t15, null
  %t17 = zext i1 %t16 to i32
  %t18 = icmp eq i32 %t17, 0
  %t19 = zext i1 %t18 to i32
  store i32 %t19, ptr %t20
  %t21 = call ptr @fn_lbl(ptr @.str933)
  store ptr %t21, ptr %t22
  %t23 = call ptr @fn_lbl(ptr @.str934)
  store ptr %t23, ptr %t24
  %t25 = call ptr @fn_lbl(ptr @.str935)
  store ptr %t25, ptr %t26
  %t27 = load i32, ptr %t20
  %t28 = icmp ne i32 %t27, 0
  br i1 %t28, label %then0, label %else1
then0:
  call void @fn_emit(ptr @.str936)
  %t29 = load ptr, ptr %t12
  call void @fn_emit(ptr %t29)
  call void @fn_emit(ptr @.str937)
  %t30 = load ptr, ptr %t22
  call void @fn_emit(ptr %t30)
  call void @fn_emit(ptr @.str938)
  %t31 = load ptr, ptr %t24
  call void @fn_emit(ptr %t31)
  call void @fn_emit(ptr @.str939)
  br label %ifend2
else1:
  call void @fn_emit(ptr @.str940)
  %t32 = load ptr, ptr %t12
  call void @fn_emit(ptr %t32)
  call void @fn_emit(ptr @.str941)
  %t33 = load ptr, ptr %t22
  call void @fn_emit(ptr %t33)
  call void @fn_emit(ptr @.str942)
  %t34 = load ptr, ptr %t26
  call void @fn_emit(ptr %t34)
  call void @fn_emit(ptr @.str943)
  br label %ifend2
ifend2:
  %t35 = load ptr, ptr %t22
  call void @fn_emit(ptr %t35)
  call void @fn_emit(ptr @.str944)
  store i32 0, ptr @g_g_term
  %t36 = load ptr, ptr %t0
  %t37 = getelementptr inbounds %Str_Node, ptr %t36, i32 0, i32 5
  %t38 = load ptr, ptr %t37
  call void @fn_emit_block(ptr %t38)
  %t39 = load i32, ptr @g_g_term
  %t40 = icmp eq i32 %t39, 0
  %t41 = zext i1 %t40 to i32
  %t42 = icmp ne i32 %t41, 0
  br i1 %t42, label %then3, label %ifend5
then3:
  call void @fn_emit(ptr @.str945)
  %t43 = load ptr, ptr %t26
  call void @fn_emit(ptr %t43)
  call void @fn_emit(ptr @.str946)
  br label %ifend5
ifend5:
  %t44 = load i32, ptr %t20
  %t45 = icmp ne i32 %t44, 0
  br i1 %t45, label %then6, label %ifend8
then6:
  %t46 = load ptr, ptr %t24
  call void @fn_emit(ptr %t46)
  call void @fn_emit(ptr @.str947)
  store i32 0, ptr @g_g_term
  %t47 = load ptr, ptr %t0
  %t48 = getelementptr inbounds %Str_Node, ptr %t47, i32 0, i32 6
  %t49 = load ptr, ptr %t48
  %t50 = getelementptr inbounds %Str_Node, ptr %t49, i32 0, i32 0
  %t51 = load i32, ptr %t50
  %t52 = icmp eq i32 %t51, 12
  %t53 = zext i1 %t52 to i32
  %t54 = icmp ne i32 %t53, 0
  br i1 %t54, label %then9, label %else10
then9:
  %t55 = load ptr, ptr %t0
  %t56 = getelementptr inbounds %Str_Node, ptr %t55, i32 0, i32 6
  %t57 = load ptr, ptr %t56
  call void @fn_emit_stmt(ptr %t57)
  br label %ifend11
else10:
  %t58 = load ptr, ptr %t0
  %t59 = getelementptr inbounds %Str_Node, ptr %t58, i32 0, i32 6
  %t60 = load ptr, ptr %t59
  call void @fn_emit_block(ptr %t60)
  br label %ifend11
ifend11:
  %t61 = load i32, ptr @g_g_term
  %t62 = icmp eq i32 %t61, 0
  %t63 = zext i1 %t62 to i32
  %t64 = icmp ne i32 %t63, 0
  br i1 %t64, label %then12, label %ifend14
then12:
  call void @fn_emit(ptr @.str948)
  %t65 = load ptr, ptr %t26
  call void @fn_emit(ptr %t65)
  call void @fn_emit(ptr @.str949)
  br label %ifend14
ifend14:
  br label %ifend8
ifend8:
  %t66 = load ptr, ptr %t26
  call void @fn_emit(ptr %t66)
  call void @fn_emit(ptr @.str950)
  store i32 0, ptr @g_g_term
  br label %ret
ret:
  ret void
}

define void @fn_emit_while(ptr %arg_st) {
entry:
  %t0 = alloca ptr
  %t2 = alloca ptr
  %t4 = alloca ptr
  %t6 = alloca ptr
  %t13 = alloca ptr
  %t20 = alloca ptr
  store ptr %arg_st, ptr %t0
  %t1 = call ptr @fn_lbl(ptr @.str951)
  store ptr %t1, ptr %t2
  %t3 = call ptr @fn_lbl(ptr @.str952)
  store ptr %t3, ptr %t4
  %t5 = call ptr @fn_lbl(ptr @.str953)
  store ptr %t5, ptr %t6
  call void @fn_emit(ptr @.str954)
  %t7 = load ptr, ptr %t2
  call void @fn_emit(ptr %t7)
  call void @fn_emit(ptr @.str955)
  %t8 = load ptr, ptr %t2
  call void @fn_emit(ptr %t8)
  call void @fn_emit(ptr @.str956)
  %t9 = load ptr, ptr %t0
  %t10 = getelementptr inbounds %Str_Node, ptr %t9, i32 0, i32 4
  %t11 = load ptr, ptr %t10
  %t12 = call ptr @fn_emit_expr(ptr %t11)
  store ptr %t12, ptr %t13
  %t14 = load ptr, ptr %t13
  %t15 = getelementptr inbounds %Str_Val, ptr %t14, i32 0, i32 0
  %t16 = load ptr, ptr %t15
  %t17 = call ptr @fn_sconcat(ptr %t16, ptr @.str958)
  %t18 = call ptr @fn_sconcat(ptr @.str957, ptr %t17)
  %t19 = call ptr @fn_emit_bind(ptr %t18)
  store ptr %t19, ptr %t20
  call void @fn_emit(ptr @.str959)
  %t21 = load ptr, ptr %t20
  call void @fn_emit(ptr %t21)
  call void @fn_emit(ptr @.str960)
  %t22 = load ptr, ptr %t4
  call void @fn_emit(ptr %t22)
  call void @fn_emit(ptr @.str961)
  %t23 = load ptr, ptr %t6
  call void @fn_emit(ptr %t23)
  call void @fn_emit(ptr @.str962)
  %t24 = load ptr, ptr %t4
  call void @fn_emit(ptr %t24)
  call void @fn_emit(ptr @.str963)
  store i32 0, ptr @g_g_term
  %t25 = load ptr, ptr %t2
  %t26 = load ptr, ptr %t6
  call void @fn_loop_push(ptr %t25, ptr %t26)
  %t27 = load ptr, ptr %t0
  %t28 = getelementptr inbounds %Str_Node, ptr %t27, i32 0, i32 5
  %t29 = load ptr, ptr %t28
  call void @fn_emit_block(ptr %t29)
  call void @fn_loop_pop()
  %t30 = load i32, ptr @g_g_term
  %t31 = icmp eq i32 %t30, 0
  %t32 = zext i1 %t31 to i32
  %t33 = icmp ne i32 %t32, 0
  br i1 %t33, label %then0, label %ifend2
then0:
  call void @fn_emit(ptr @.str964)
  %t34 = load ptr, ptr %t2
  call void @fn_emit(ptr %t34)
  call void @fn_emit(ptr @.str965)
  br label %ifend2
ifend2:
  %t35 = load ptr, ptr %t6
  call void @fn_emit(ptr %t35)
  call void @fn_emit(ptr @.str966)
  store i32 0, ptr @g_g_term
  br label %ret
ret:
  ret void
}

define void @fn_emit_for(ptr %arg_st) {
entry:
  %t0 = alloca ptr
  %t2 = alloca ptr
  %t7 = alloca ptr
  %t17 = alloca ptr
  %t19 = alloca ptr
  %t21 = alloca ptr
  %t23 = alloca ptr
  %t29 = alloca ptr
  %t34 = alloca ptr
  %t43 = alloca ptr
  %t62 = alloca ptr
  %t67 = alloca ptr
  store ptr %arg_st, ptr %t0
  %t1 = call ptr @fn_emit_alloca(ptr @.str967)
  store ptr %t1, ptr %t2
  %t3 = load ptr, ptr %t0
  %t4 = getelementptr inbounds %Str_Node, ptr %t3, i32 0, i32 4
  %t5 = load ptr, ptr %t4
  %t6 = call ptr @fn_emit_expr(ptr %t5)
  store ptr %t6, ptr %t7
  %t8 = load ptr, ptr %t7
  %t9 = getelementptr inbounds %Str_Val, ptr %t8, i32 0, i32 0
  %t10 = load ptr, ptr %t9
  %t11 = load ptr, ptr %t2
  call void @fn_store_at(ptr @.str968, ptr %t10, ptr %t11)
  %t12 = load ptr, ptr %t0
  %t13 = getelementptr inbounds %Str_Node, ptr %t12, i32 0, i32 1
  %t14 = load ptr, ptr %t13
  %t15 = load ptr, ptr %t2
  call void @fn_loc_push(ptr %t14, ptr %t15, ptr @.str969)
  %t16 = call ptr @fn_lbl(ptr @.str970)
  store ptr %t16, ptr %t17
  %t18 = call ptr @fn_lbl(ptr @.str971)
  store ptr %t18, ptr %t19
  %t20 = call ptr @fn_lbl(ptr @.str972)
  store ptr %t20, ptr %t21
  %t22 = call ptr @fn_lbl(ptr @.str973)
  store ptr %t22, ptr %t23
  call void @fn_emit(ptr @.str974)
  %t24 = load ptr, ptr %t17
  call void @fn_emit(ptr %t24)
  call void @fn_emit(ptr @.str975)
  %t25 = load ptr, ptr %t17
  call void @fn_emit(ptr %t25)
  call void @fn_emit(ptr @.str976)
  %t26 = load ptr, ptr %t2
  %t27 = call ptr @fn_sconcat(ptr @.str977, ptr %t26)
  %t28 = call ptr @fn_emit_bind(ptr %t27)
  store ptr %t28, ptr %t29
  %t30 = load ptr, ptr %t0
  %t31 = getelementptr inbounds %Str_Node, ptr %t30, i32 0, i32 5
  %t32 = load ptr, ptr %t31
  %t33 = call ptr @fn_emit_expr(ptr %t32)
  store ptr %t33, ptr %t34
  %t35 = load ptr, ptr %t29
  %t36 = load ptr, ptr %t34
  %t37 = getelementptr inbounds %Str_Val, ptr %t36, i32 0, i32 0
  %t38 = load ptr, ptr %t37
  %t39 = call ptr @fn_sconcat(ptr @.str979, ptr %t38)
  %t40 = call ptr @fn_sconcat(ptr %t35, ptr %t39)
  %t41 = call ptr @fn_sconcat(ptr @.str978, ptr %t40)
  %t42 = call ptr @fn_emit_bind(ptr %t41)
  store ptr %t42, ptr %t43
  call void @fn_emit(ptr @.str980)
  %t44 = load ptr, ptr %t43
  call void @fn_emit(ptr %t44)
  call void @fn_emit(ptr @.str981)
  %t45 = load ptr, ptr %t19
  call void @fn_emit(ptr %t45)
  call void @fn_emit(ptr @.str982)
  %t46 = load ptr, ptr %t23
  call void @fn_emit(ptr %t46)
  call void @fn_emit(ptr @.str983)
  %t47 = load ptr, ptr %t19
  call void @fn_emit(ptr %t47)
  call void @fn_emit(ptr @.str984)
  store i32 0, ptr @g_g_term
  %t48 = load ptr, ptr %t21
  %t49 = load ptr, ptr %t23
  call void @fn_loop_push(ptr %t48, ptr %t49)
  %t50 = load ptr, ptr %t0
  %t51 = getelementptr inbounds %Str_Node, ptr %t50, i32 0, i32 6
  %t52 = load ptr, ptr %t51
  call void @fn_emit_block(ptr %t52)
  call void @fn_loop_pop()
  %t53 = load i32, ptr @g_g_term
  %t54 = icmp eq i32 %t53, 0
  %t55 = zext i1 %t54 to i32
  %t56 = icmp ne i32 %t55, 0
  br i1 %t56, label %then0, label %ifend2
then0:
  call void @fn_emit(ptr @.str985)
  %t57 = load ptr, ptr %t21
  call void @fn_emit(ptr %t57)
  call void @fn_emit(ptr @.str986)
  br label %ifend2
ifend2:
  %t58 = load ptr, ptr %t21
  call void @fn_emit(ptr %t58)
  call void @fn_emit(ptr @.str987)
  %t59 = load ptr, ptr %t2
  %t60 = call ptr @fn_sconcat(ptr @.str988, ptr %t59)
  %t61 = call ptr @fn_emit_bind(ptr %t60)
  store ptr %t61, ptr %t62
  %t63 = load ptr, ptr %t62
  %t64 = call ptr @fn_sconcat(ptr %t63, ptr @.str990)
  %t65 = call ptr @fn_sconcat(ptr @.str989, ptr %t64)
  %t66 = call ptr @fn_emit_bind(ptr %t65)
  store ptr %t66, ptr %t67
  %t68 = load ptr, ptr %t67
  %t69 = load ptr, ptr %t2
  call void @fn_store_at(ptr @.str991, ptr %t68, ptr %t69)
  call void @fn_emit(ptr @.str992)
  %t70 = load ptr, ptr %t17
  call void @fn_emit(ptr %t70)
  call void @fn_emit(ptr @.str993)
  %t71 = load ptr, ptr %t23
  call void @fn_emit(ptr %t71)
  call void @fn_emit(ptr @.str994)
  store i32 0, ptr @g_g_term
  br label %ret
ret:
  ret void
}

define void @fn_emit_return(ptr %arg_st) {
entry:
  %t0 = alloca ptr
  %t13 = alloca ptr
  store ptr %arg_st, ptr %t0
  %t1 = load ptr, ptr %t0
  %t2 = getelementptr inbounds %Str_Node, ptr %t1, i32 0, i32 4
  %t3 = load ptr, ptr %t2
  %t4 = icmp eq ptr %t3, null
  %t5 = zext i1 %t4 to i32
  %t6 = icmp eq i32 %t5, 0
  %t7 = zext i1 %t6 to i32
  %t8 = icmp ne i32 %t7, 0
  br i1 %t8, label %then0, label %ifend2
then0:
  %t9 = load ptr, ptr %t0
  %t10 = getelementptr inbounds %Str_Node, ptr %t9, i32 0, i32 4
  %t11 = load ptr, ptr %t10
  %t12 = call ptr @fn_emit_expr(ptr %t11)
  store ptr %t12, ptr %t13
  %t14 = load ptr, ptr @g_ret_ty
  %t15 = call ptr @fn_llty(ptr %t14)
  %t16 = load ptr, ptr %t13
  %t17 = getelementptr inbounds %Str_Val, ptr %t16, i32 0, i32 0
  %t18 = load ptr, ptr %t17
  call void @fn_store_at(ptr %t15, ptr %t18, ptr @.str995)
  br label %ifend2
ifend2:
  call void @fn_emit(ptr @.str996)
  store i32 1, ptr @g_g_term
  br label %ret
ret:
  ret void
}

define i32 @fn_arm_is_default(ptr %arg_arm) {
entry:
  %retval = alloca i32
  %t0 = alloca ptr
  %t1 = alloca i32
  %t11 = alloca i32
  store ptr %arg_arm, ptr %t0
  store i32 0, ptr %t1
  br label %wcond0
wcond0:
  %t2 = load i32, ptr %t1
  %t3 = load ptr, ptr %t0
  %t4 = getelementptr inbounds %Str_Node, ptr %t3, i32 0, i32 7
  %t5 = load ptr, ptr %t4
  %t6 = getelementptr inbounds %LSlice, ptr %t5, i32 0, i32 1
  %t7 = load i32, ptr %t6
  %t8 = icmp slt i32 %t2, %t7
  %t9 = zext i1 %t8 to i32
  %t10 = icmp ne i32 %t9, 0
  br i1 %t10, label %wbody1, label %wend2
wbody1:
  %t12 = load ptr, ptr %t0
  %t13 = getelementptr inbounds %Str_Node, ptr %t12, i32 0, i32 7
  %t14 = load ptr, ptr %t13
  %t15 = getelementptr inbounds %LSlice, ptr %t14, i32 0, i32 0
  %t16 = load ptr, ptr %t15
  %t17 = load i32, ptr %t1
  %t18 = getelementptr inbounds ptr, ptr %t16, i32 %t17
  %t19 = load ptr, ptr %t18
  %t20 = getelementptr inbounds %Str_Node, ptr %t19, i32 0, i32 0
  %t21 = load i32, ptr %t20
  %t22 = icmp eq i32 %t21, 33
  %t23 = zext i1 %t22 to i32
  %t24 = icmp ne i32 %t23, 0
  %t25 = zext i1 %t24 to i32
  store i32 %t25, ptr %t11
  br i1 %t24, label %sc3, label %scend4
sc3:
  %t26 = load ptr, ptr %t0
  %t27 = getelementptr inbounds %Str_Node, ptr %t26, i32 0, i32 7
  %t28 = load ptr, ptr %t27
  %t29 = getelementptr inbounds %LSlice, ptr %t28, i32 0, i32 0
  %t30 = load ptr, ptr %t29
  %t31 = load i32, ptr %t1
  %t32 = getelementptr inbounds ptr, ptr %t30, i32 %t31
  %t33 = load ptr, ptr %t32
  %t34 = getelementptr inbounds %Str_Node, ptr %t33, i32 0, i32 1
  %t35 = load ptr, ptr %t34
  %t36 = call i32 @fn_streq(ptr %t35, ptr @.str997)
  %t37 = icmp ne i32 %t36, 0
  %t38 = zext i1 %t37 to i32
  store i32 %t38, ptr %t11
  br label %scend4
scend4:
  %t39 = load i32, ptr %t11
  %t40 = icmp ne i32 %t39, 0
  br i1 %t40, label %then5, label %ifend7
then5:
  store i32 1, ptr %retval
  br label %ret
ifend7:
  %t41 = load i32, ptr %t1
  %t42 = add i32 %t41, 1
  store i32 %t42, ptr %t1
  br label %wcond0
wend2:
  store i32 0, ptr %retval
  br label %ret
ret:
  %t43 = load i32, ptr %retval
  ret i32 %t43
}

define void @fn_emit_match(ptr %arg_st) {
entry:
  %t0 = alloca ptr
  %t5 = alloca ptr
  %t7 = alloca ptr
  %t8 = alloca ptr
  %t9 = alloca i32
  %t27 = alloca ptr
  %t32 = alloca ptr
  %t33 = alloca i32
  %t34 = alloca i32
  %t53 = alloca ptr
  %t64 = alloca ptr
  %t77 = alloca ptr
  %t79 = alloca ptr
  store ptr %arg_st, ptr %t0
  %t1 = load ptr, ptr %t0
  %t2 = getelementptr inbounds %Str_Node, ptr %t1, i32 0, i32 4
  %t3 = load ptr, ptr %t2
  %t4 = call ptr @fn_emit_expr(ptr %t3)
  store ptr %t4, ptr %t5
  %t6 = call ptr @fn_lbl(ptr @.str998)
  store ptr %t6, ptr %t7
  store ptr null, ptr %t8
  store i32 0, ptr %t9
  br label %wcond0
wcond0:
  %t10 = load i32, ptr %t9
  %t11 = load ptr, ptr %t0
  %t12 = getelementptr inbounds %Str_Node, ptr %t11, i32 0, i32 7
  %t13 = load ptr, ptr %t12
  %t14 = getelementptr inbounds %LSlice, ptr %t13, i32 0, i32 1
  %t15 = load i32, ptr %t14
  %t16 = icmp slt i32 %t10, %t15
  %t17 = zext i1 %t16 to i32
  %t18 = icmp ne i32 %t17, 0
  br i1 %t18, label %wbody1, label %wend2
wbody1:
  %t19 = load ptr, ptr %t0
  %t20 = getelementptr inbounds %Str_Node, ptr %t19, i32 0, i32 7
  %t21 = load ptr, ptr %t20
  %t22 = getelementptr inbounds %LSlice, ptr %t21, i32 0, i32 0
  %t23 = load ptr, ptr %t22
  %t24 = load i32, ptr %t9
  %t25 = getelementptr inbounds ptr, ptr %t23, i32 %t24
  %t26 = load ptr, ptr %t25
  store ptr %t26, ptr %t27
  %t28 = load ptr, ptr %t27
  %t29 = call i32 @fn_arm_is_default(ptr %t28)
  %t30 = icmp ne i32 %t29, 0
  br i1 %t30, label %then3, label %else4
then3:
  %t31 = load ptr, ptr %t27
  store ptr %t31, ptr %t8
  br label %ifend5
else4:
  store ptr @.str999, ptr %t32
  store i32 1, ptr %t33
  store i32 0, ptr %t34
  br label %wcond6
wcond6:
  %t35 = load i32, ptr %t34
  %t36 = load ptr, ptr %t27
  %t37 = getelementptr inbounds %Str_Node, ptr %t36, i32 0, i32 7
  %t38 = load ptr, ptr %t37
  %t39 = getelementptr inbounds %LSlice, ptr %t38, i32 0, i32 1
  %t40 = load i32, ptr %t39
  %t41 = icmp slt i32 %t35, %t40
  %t42 = zext i1 %t41 to i32
  %t43 = icmp ne i32 %t42, 0
  br i1 %t43, label %wbody7, label %wend8
wbody7:
  %t44 = load ptr, ptr %t27
  %t45 = getelementptr inbounds %Str_Node, ptr %t44, i32 0, i32 7
  %t46 = load ptr, ptr %t45
  %t47 = getelementptr inbounds %LSlice, ptr %t46, i32 0, i32 0
  %t48 = load ptr, ptr %t47
  %t49 = load i32, ptr %t34
  %t50 = getelementptr inbounds ptr, ptr %t48, i32 %t49
  %t51 = load ptr, ptr %t50
  %t52 = call ptr @fn_emit_expr(ptr %t51)
  store ptr %t52, ptr %t53
  %t54 = load ptr, ptr %t5
  %t55 = getelementptr inbounds %Str_Val, ptr %t54, i32 0, i32 0
  %t56 = load ptr, ptr %t55
  %t57 = load ptr, ptr %t53
  %t58 = getelementptr inbounds %Str_Val, ptr %t57, i32 0, i32 0
  %t59 = load ptr, ptr %t58
  %t60 = call ptr @fn_sconcat(ptr @.str1001, ptr %t59)
  %t61 = call ptr @fn_sconcat(ptr %t56, ptr %t60)
  %t62 = call ptr @fn_sconcat(ptr @.str1000, ptr %t61)
  %t63 = call ptr @fn_emit_bind(ptr %t62)
  store ptr %t63, ptr %t64
  %t65 = load i32, ptr %t33
  %t66 = icmp ne i32 %t65, 0
  br i1 %t66, label %then9, label %else10
then9:
  %t67 = load ptr, ptr %t64
  store ptr %t67, ptr %t32
  store i32 0, ptr %t33
  br label %ifend11
else10:
  %t68 = load ptr, ptr %t32
  %t69 = load ptr, ptr %t64
  %t70 = call ptr @fn_sconcat(ptr @.str1003, ptr %t69)
  %t71 = call ptr @fn_sconcat(ptr %t68, ptr %t70)
  %t72 = call ptr @fn_sconcat(ptr @.str1002, ptr %t71)
  %t73 = call ptr @fn_emit_bind(ptr %t72)
  store ptr %t73, ptr %t32
  br label %ifend11
ifend11:
  %t74 = load i32, ptr %t34
  %t75 = add i32 %t74, 1
  store i32 %t75, ptr %t34
  br label %wcond6
wend8:
  %t76 = call ptr @fn_lbl(ptr @.str1004)
  store ptr %t76, ptr %t77
  %t78 = call ptr @fn_lbl(ptr @.str1005)
  store ptr %t78, ptr %t79
  call void @fn_emit(ptr @.str1006)
  %t80 = load ptr, ptr %t32
  call void @fn_emit(ptr %t80)
  call void @fn_emit(ptr @.str1007)
  %t81 = load ptr, ptr %t77
  call void @fn_emit(ptr %t81)
  call void @fn_emit(ptr @.str1008)
  %t82 = load ptr, ptr %t79
  call void @fn_emit(ptr %t82)
  call void @fn_emit(ptr @.str1009)
  %t83 = load ptr, ptr %t77
  call void @fn_emit(ptr %t83)
  call void @fn_emit(ptr @.str1010)
  store i32 0, ptr @g_g_term
  %t84 = load ptr, ptr %t27
  %t85 = getelementptr inbounds %Str_Node, ptr %t84, i32 0, i32 4
  %t86 = load ptr, ptr %t85
  call void @fn_emit_block(ptr %t86)
  %t87 = load i32, ptr @g_g_term
  %t88 = icmp eq i32 %t87, 0
  %t89 = zext i1 %t88 to i32
  %t90 = icmp ne i32 %t89, 0
  br i1 %t90, label %then12, label %ifend14
then12:
  call void @fn_emit(ptr @.str1011)
  %t91 = load ptr, ptr %t7
  call void @fn_emit(ptr %t91)
  call void @fn_emit(ptr @.str1012)
  br label %ifend14
ifend14:
  %t92 = load ptr, ptr %t79
  call void @fn_emit(ptr %t92)
  call void @fn_emit(ptr @.str1013)
  store i32 0, ptr @g_g_term
  br label %ifend5
ifend5:
  %t93 = load i32, ptr %t9
  %t94 = add i32 %t93, 1
  store i32 %t94, ptr %t9
  br label %wcond0
wend2:
  %t95 = load ptr, ptr %t8
  %t96 = icmp eq ptr %t95, null
  %t97 = zext i1 %t96 to i32
  %t98 = icmp eq i32 %t97, 0
  %t99 = zext i1 %t98 to i32
  %t100 = icmp ne i32 %t99, 0
  br i1 %t100, label %then15, label %ifend17
then15:
  %t101 = load ptr, ptr %t8
  %t102 = getelementptr inbounds %Str_Node, ptr %t101, i32 0, i32 4
  %t103 = load ptr, ptr %t102
  call void @fn_emit_block(ptr %t103)
  br label %ifend17
ifend17:
  %t104 = load i32, ptr @g_g_term
  %t105 = icmp eq i32 %t104, 0
  %t106 = zext i1 %t105 to i32
  %t107 = icmp ne i32 %t106, 0
  br i1 %t107, label %then18, label %ifend20
then18:
  call void @fn_emit(ptr @.str1014)
  %t108 = load ptr, ptr %t7
  call void @fn_emit(ptr %t108)
  call void @fn_emit(ptr @.str1015)
  br label %ifend20
ifend20:
  %t109 = load ptr, ptr %t7
  call void @fn_emit(ptr %t109)
  call void @fn_emit(ptr @.str1016)
  store i32 0, ptr @g_g_term
  br label %ret
ret:
  ret void
}

define void @fn_emit_stmt(ptr %arg_st) {
entry:
  %t0 = alloca ptr
  %t10 = alloca ptr
  %t19 = alloca ptr
  %t26 = alloca ptr
  %t41 = alloca ptr
  %t48 = alloca ptr
  %t61 = alloca ptr
  %t186 = alloca ptr
  store ptr %arg_st, ptr %t0
  %t1 = load ptr, ptr %t0
  %t2 = getelementptr inbounds %Str_Node, ptr %t1, i32 0, i32 0
  %t3 = load i32, ptr %t2
  %t4 = icmp eq i32 %t3, 10
  %t5 = zext i1 %t4 to i32
  %t6 = icmp ne i32 %t5, 0
  br i1 %t6, label %then0, label %ifend2
then0:
  %t7 = load ptr, ptr %t0
  %t8 = getelementptr inbounds %Str_Node, ptr %t7, i32 0, i32 3
  %t9 = load ptr, ptr %t8
  store ptr %t9, ptr %t10
  %t11 = load ptr, ptr %t10
  %t12 = icmp eq ptr %t11, null
  %t13 = zext i1 %t12 to i32
  %t14 = icmp ne i32 %t13, 0
  br i1 %t14, label %then3, label %ifend5
then3:
  %t15 = load ptr, ptr %t0
  %t16 = getelementptr inbounds %Str_Node, ptr %t15, i32 0, i32 4
  %t17 = load ptr, ptr %t16
  %t18 = call ptr @fn_emit_expr(ptr %t17)
  store ptr %t18, ptr %t19
  %t20 = load ptr, ptr %t19
  %t21 = getelementptr inbounds %Str_Val, ptr %t20, i32 0, i32 1
  %t22 = load ptr, ptr %t21
  store ptr %t22, ptr %t10
  %t23 = load ptr, ptr %t10
  %t24 = call ptr @fn_llty(ptr %t23)
  %t25 = call ptr @fn_emit_alloca(ptr %t24)
  store ptr %t25, ptr %t26
  %t27 = load ptr, ptr %t10
  %t28 = call ptr @fn_llty(ptr %t27)
  %t29 = load ptr, ptr %t19
  %t30 = getelementptr inbounds %Str_Val, ptr %t29, i32 0, i32 0
  %t31 = load ptr, ptr %t30
  %t32 = load ptr, ptr %t26
  call void @fn_store_at(ptr %t28, ptr %t31, ptr %t32)
  %t33 = load ptr, ptr %t0
  %t34 = getelementptr inbounds %Str_Node, ptr %t33, i32 0, i32 1
  %t35 = load ptr, ptr %t34
  %t36 = load ptr, ptr %t26
  %t37 = load ptr, ptr %t10
  call void @fn_loc_push(ptr %t35, ptr %t36, ptr %t37)
  br label %ret
ifend5:
  %t38 = load ptr, ptr %t10
  %t39 = call ptr @fn_llty(ptr %t38)
  %t40 = call ptr @fn_emit_alloca(ptr %t39)
  store ptr %t40, ptr %t41
  %t42 = load ptr, ptr %t0
  %t43 = getelementptr inbounds %Str_Node, ptr %t42, i32 0, i32 4
  %t44 = load ptr, ptr %t43
  %t45 = icmp eq ptr %t44, null
  %t46 = zext i1 %t45 to i32
  %t47 = icmp ne i32 %t46, 0
  br i1 %t47, label %then6, label %else7
then6:
  store ptr @.str1017, ptr %t48
  %t49 = load ptr, ptr %t10
  %t50 = call ptr @fn_llty(ptr %t49)
  %t51 = call i32 @fn_streq(ptr %t50, ptr @.str1018)
  %t52 = icmp ne i32 %t51, 0
  br i1 %t52, label %then9, label %ifend11
then9:
  store ptr @.str1019, ptr %t48
  br label %ifend11
ifend11:
  %t53 = load ptr, ptr %t10
  %t54 = call ptr @fn_llty(ptr %t53)
  %t55 = load ptr, ptr %t48
  %t56 = load ptr, ptr %t41
  call void @fn_store_at(ptr %t54, ptr %t55, ptr %t56)
  br label %ifend8
else7:
  %t57 = load ptr, ptr %t0
  %t58 = getelementptr inbounds %Str_Node, ptr %t57, i32 0, i32 4
  %t59 = load ptr, ptr %t58
  %t60 = call ptr @fn_emit_expr(ptr %t59)
  store ptr %t60, ptr %t61
  %t62 = load ptr, ptr %t10
  %t63 = call ptr @fn_llty(ptr %t62)
  %t64 = load ptr, ptr %t61
  %t65 = getelementptr inbounds %Str_Val, ptr %t64, i32 0, i32 0
  %t66 = load ptr, ptr %t65
  %t67 = load ptr, ptr %t41
  call void @fn_store_at(ptr %t63, ptr %t66, ptr %t67)
  br label %ifend8
ifend8:
  %t68 = load ptr, ptr %t0
  %t69 = getelementptr inbounds %Str_Node, ptr %t68, i32 0, i32 1
  %t70 = load ptr, ptr %t69
  %t71 = load ptr, ptr %t41
  %t72 = load ptr, ptr %t10
  call void @fn_loc_push(ptr %t70, ptr %t71, ptr %t72)
  br label %ret
ifend2:
  %t73 = load ptr, ptr %t0
  %t74 = getelementptr inbounds %Str_Node, ptr %t73, i32 0, i32 0
  %t75 = load i32, ptr %t74
  %t76 = icmp eq i32 %t75, 11
  %t77 = zext i1 %t76 to i32
  %t78 = icmp ne i32 %t77, 0
  br i1 %t78, label %then12, label %ifend14
then12:
  %t79 = load ptr, ptr %t0
  call void @fn_emit_assign(ptr %t79)
  br label %ret
ifend14:
  %t80 = load ptr, ptr %t0
  %t81 = getelementptr inbounds %Str_Node, ptr %t80, i32 0, i32 0
  %t82 = load i32, ptr %t81
  %t83 = icmp eq i32 %t82, 12
  %t84 = zext i1 %t83 to i32
  %t85 = icmp ne i32 %t84, 0
  br i1 %t85, label %then15, label %ifend17
then15:
  %t86 = load ptr, ptr %t0
  call void @fn_emit_if(ptr %t86)
  br label %ret
ifend17:
  %t87 = load ptr, ptr %t0
  %t88 = getelementptr inbounds %Str_Node, ptr %t87, i32 0, i32 0
  %t89 = load i32, ptr %t88
  %t90 = icmp eq i32 %t89, 13
  %t91 = zext i1 %t90 to i32
  %t92 = icmp ne i32 %t91, 0
  br i1 %t92, label %then18, label %ifend20
then18:
  %t93 = load ptr, ptr %t0
  call void @fn_emit_while(ptr %t93)
  br label %ret
ifend20:
  %t94 = load ptr, ptr %t0
  %t95 = getelementptr inbounds %Str_Node, ptr %t94, i32 0, i32 0
  %t96 = load i32, ptr %t95
  %t97 = icmp eq i32 %t96, 14
  %t98 = zext i1 %t97 to i32
  %t99 = icmp ne i32 %t98, 0
  br i1 %t99, label %then21, label %ifend23
then21:
  %t100 = load ptr, ptr %t0
  call void @fn_emit_for(ptr %t100)
  br label %ret
ifend23:
  %t101 = load ptr, ptr %t0
  %t102 = getelementptr inbounds %Str_Node, ptr %t101, i32 0, i32 0
  %t103 = load i32, ptr %t102
  %t104 = icmp eq i32 %t103, 15
  %t105 = zext i1 %t104 to i32
  %t106 = icmp ne i32 %t105, 0
  br i1 %t106, label %then24, label %ifend26
then24:
  %t107 = load ptr, ptr %t0
  call void @fn_emit_return(ptr %t107)
  br label %ret
ifend26:
  %t108 = load ptr, ptr %t0
  %t109 = getelementptr inbounds %Str_Node, ptr %t108, i32 0, i32 0
  %t110 = load i32, ptr %t109
  %t111 = icmp eq i32 %t110, 17
  %t112 = zext i1 %t111 to i32
  %t113 = icmp ne i32 %t112, 0
  br i1 %t113, label %then27, label %ifend29
then27:
  call void @fn_emit(ptr @.str1020)
  %t114 = load ptr, ptr @g_brk_lbl
  %t115 = getelementptr inbounds %LSlice, ptr %t114, i32 0, i32 0
  %t116 = load ptr, ptr %t115
  %t117 = load i32, ptr @g_nloop
  %t118 = sub i32 %t117, 1
  %t119 = getelementptr inbounds ptr, ptr %t116, i32 %t118
  %t120 = load ptr, ptr %t119
  call void @fn_emit(ptr %t120)
  call void @fn_emit(ptr @.str1021)
  store i32 1, ptr @g_g_term
  br label %ret
ifend29:
  %t121 = load ptr, ptr %t0
  %t122 = getelementptr inbounds %Str_Node, ptr %t121, i32 0, i32 0
  %t123 = load i32, ptr %t122
  %t124 = icmp eq i32 %t123, 18
  %t125 = zext i1 %t124 to i32
  %t126 = icmp ne i32 %t125, 0
  br i1 %t126, label %then30, label %ifend32
then30:
  call void @fn_emit(ptr @.str1022)
  %t127 = load ptr, ptr @g_cnt_lbl
  %t128 = getelementptr inbounds %LSlice, ptr %t127, i32 0, i32 0
  %t129 = load ptr, ptr %t128
  %t130 = load i32, ptr @g_nloop
  %t131 = sub i32 %t130, 1
  %t132 = getelementptr inbounds ptr, ptr %t129, i32 %t131
  %t133 = load ptr, ptr %t132
  call void @fn_emit(ptr %t133)
  call void @fn_emit(ptr @.str1023)
  store i32 1, ptr @g_g_term
  br label %ret
ifend32:
  %t134 = load ptr, ptr %t0
  %t135 = getelementptr inbounds %Str_Node, ptr %t134, i32 0, i32 0
  %t136 = load i32, ptr %t135
  %t137 = icmp eq i32 %t136, 19
  %t138 = zext i1 %t137 to i32
  %t139 = icmp ne i32 %t138, 0
  br i1 %t139, label %then33, label %ifend35
then33:
  %t140 = load ptr, ptr %t0
  call void @fn_emit_match(ptr %t140)
  br label %ret
ifend35:
  %t141 = load ptr, ptr %t0
  %t142 = getelementptr inbounds %Str_Node, ptr %t141, i32 0, i32 0
  %t143 = load i32, ptr %t142
  %t144 = icmp eq i32 %t143, 21
  %t145 = zext i1 %t144 to i32
  %t146 = icmp ne i32 %t145, 0
  br i1 %t146, label %then36, label %ifend38
then36:
  %t147 = load ptr, ptr %t0
  call void @fn_emit_query(ptr %t147)
  br label %ret
ifend38:
  %t148 = load ptr, ptr %t0
  %t149 = getelementptr inbounds %Str_Node, ptr %t148, i32 0, i32 0
  %t150 = load i32, ptr %t149
  %t151 = icmp eq i32 %t150, 22
  %t152 = zext i1 %t151 to i32
  %t153 = icmp ne i32 %t152, 0
  br i1 %t153, label %then39, label %ifend41
then39:
  %t154 = load ptr, ptr %t0
  call void @fn_emit_spawn(ptr %t154)
  br label %ret
ifend41:
  %t155 = load ptr, ptr %t0
  %t156 = getelementptr inbounds %Str_Node, ptr %t155, i32 0, i32 0
  %t157 = load i32, ptr %t156
  %t158 = icmp eq i32 %t157, 23
  %t159 = zext i1 %t158 to i32
  %t160 = icmp ne i32 %t159, 0
  br i1 %t160, label %then42, label %ifend44
then42:
  %t161 = load ptr, ptr %t0
  call void @fn_emit_despawn(ptr %t161)
  br label %ret
ifend44:
  %t162 = load ptr, ptr %t0
  %t163 = getelementptr inbounds %Str_Node, ptr %t162, i32 0, i32 0
  %t164 = load i32, ptr %t163
  %t165 = icmp eq i32 %t164, 24
  %t166 = zext i1 %t165 to i32
  %t167 = icmp ne i32 %t166, 0
  br i1 %t167, label %then45, label %ifend47
then45:
  %t168 = load ptr, ptr %t0
  call void @fn_emit_machine(ptr %t168)
  br label %ret
ifend47:
  %t169 = load ptr, ptr %t0
  %t170 = getelementptr inbounds %Str_Node, ptr %t169, i32 0, i32 0
  %t171 = load i32, ptr %t170
  %t172 = icmp eq i32 %t171, 26
  %t173 = zext i1 %t172 to i32
  %t174 = icmp ne i32 %t173, 0
  br i1 %t174, label %then48, label %ifend50
then48:
  %t175 = load ptr, ptr %t0
  call void @fn_emit_become(ptr %t175)
  br label %ret
ifend50:
  %t176 = load ptr, ptr %t0
  %t177 = getelementptr inbounds %Str_Node, ptr %t176, i32 0, i32 0
  %t178 = load i32, ptr %t177
  %t179 = icmp eq i32 %t178, 16
  %t180 = zext i1 %t179 to i32
  %t181 = icmp ne i32 %t180, 0
  br i1 %t181, label %then51, label %ifend53
then51:
  %t182 = load ptr, ptr %t0
  %t183 = getelementptr inbounds %Str_Node, ptr %t182, i32 0, i32 4
  %t184 = load ptr, ptr %t183
  %t185 = call ptr @fn_emit_expr(ptr %t184)
  store ptr %t185, ptr %t186
  br label %ret
ifend53:
  call void @fn_perr(ptr @.str1024)
  br label %ret
ret:
  ret void
}

define void @fn_loop_push(ptr %arg_cont, ptr %arg_brk) {
entry:
  %t0 = alloca ptr
  %t1 = alloca ptr
  store ptr %arg_cont, ptr %t0
  store ptr %arg_brk, ptr %t1
  %t2 = load i32, ptr @g_nloop
  %t3 = load ptr, ptr @g_cnt_lbl
  %t4 = getelementptr inbounds %LSlice, ptr %t3, i32 0, i32 1
  %t5 = load i32, ptr %t4
  %t6 = icmp slt i32 %t2, %t5
  %t7 = zext i1 %t6 to i32
  %t8 = icmp ne i32 %t7, 0
  br i1 %t8, label %then0, label %else1
then0:
  %t9 = load ptr, ptr @g_cnt_lbl
  %t10 = getelementptr inbounds %LSlice, ptr %t9, i32 0, i32 0
  %t11 = load ptr, ptr %t10
  %t12 = load i32, ptr @g_nloop
  %t13 = getelementptr inbounds ptr, ptr %t11, i32 %t12
  %t14 = load ptr, ptr %t0
  store ptr %t14, ptr %t13
  %t15 = load ptr, ptr @g_brk_lbl
  %t16 = getelementptr inbounds %LSlice, ptr %t15, i32 0, i32 0
  %t17 = load ptr, ptr %t16
  %t18 = load i32, ptr @g_nloop
  %t19 = getelementptr inbounds ptr, ptr %t17, i32 %t18
  %t20 = load ptr, ptr %t1
  store ptr %t20, ptr %t19
  br label %ifend2
else1:
  %t21 = load ptr, ptr @g_cnt_lbl
  %t22 = getelementptr inbounds %LSlice, ptr %t21, i32 0, i32 1
  %t23 = getelementptr inbounds %LSlice, ptr %t21, i32 0, i32 2
  %t24 = getelementptr inbounds %LSlice, ptr %t21, i32 0, i32 0
  %t25 = load i32, ptr %t22
  %t26 = load i32, ptr %t23
  %t27 = icmp sge i32 %t25, %t26
  br i1 %t27, label %grow3, label %put4
grow3:
  %t28 = mul i32 %t26, 2
  %t29 = icmp eq i32 %t26, 0
  %t30 = select i1 %t29, i32 8, i32 %t28
  %t31 = getelementptr ptr, ptr null, i32 1
  %t32 = ptrtoint ptr %t31 to i64
  %t33 = zext i32 %t30 to i64
  %t34 = mul i64 %t33, %t32
  %t35 = load ptr, ptr %t24
  %t36 = call ptr @realloc(ptr %t35, i64 %t34)
  store ptr %t36, ptr %t24
  store i32 %t30, ptr %t23
  br label %put4
put4:
  %t37 = load ptr, ptr %t0
  %t38 = load ptr, ptr %t24
  %t39 = getelementptr inbounds ptr, ptr %t38, i32 %t25
  store ptr %t37, ptr %t39
  %t40 = add i32 %t25, 1
  store i32 %t40, ptr %t22
  %t41 = load ptr, ptr @g_brk_lbl
  %t42 = getelementptr inbounds %LSlice, ptr %t41, i32 0, i32 1
  %t43 = getelementptr inbounds %LSlice, ptr %t41, i32 0, i32 2
  %t44 = getelementptr inbounds %LSlice, ptr %t41, i32 0, i32 0
  %t45 = load i32, ptr %t42
  %t46 = load i32, ptr %t43
  %t47 = icmp sge i32 %t45, %t46
  br i1 %t47, label %grow5, label %put6
grow5:
  %t48 = mul i32 %t46, 2
  %t49 = icmp eq i32 %t46, 0
  %t50 = select i1 %t49, i32 8, i32 %t48
  %t51 = getelementptr ptr, ptr null, i32 1
  %t52 = ptrtoint ptr %t51 to i64
  %t53 = zext i32 %t50 to i64
  %t54 = mul i64 %t53, %t52
  %t55 = load ptr, ptr %t44
  %t56 = call ptr @realloc(ptr %t55, i64 %t54)
  store ptr %t56, ptr %t44
  store i32 %t50, ptr %t43
  br label %put6
put6:
  %t57 = load ptr, ptr %t1
  %t58 = load ptr, ptr %t44
  %t59 = getelementptr inbounds ptr, ptr %t58, i32 %t45
  store ptr %t57, ptr %t59
  %t60 = add i32 %t45, 1
  store i32 %t60, ptr %t42
  br label %ifend2
ifend2:
  %t61 = load i32, ptr @g_nloop
  %t62 = add i32 %t61, 1
  store i32 %t62, ptr @g_nloop
  br label %ret
ret:
  ret void
}

define void @fn_loop_pop() {
entry:
  %t0 = load i32, ptr @g_nloop
  %t1 = sub i32 %t0, 1
  store i32 %t1, ptr @g_nloop
  br label %ret
ret:
  ret void
}

define i32 @fn_has_ecs() {
entry:
  %retval = alloca i32
  %t0 = alloca i32
  %t16 = alloca i32
  %t17 = alloca i32
  store i32 0, ptr %t0
  br label %wcond0
wcond0:
  %t1 = load i32, ptr %t0
  %t2 = load ptr, ptr @g_prog
  %t3 = getelementptr inbounds %LSlice, ptr %t2, i32 0, i32 1
  %t4 = load i32, ptr %t3
  %t5 = icmp slt i32 %t1, %t4
  %t6 = zext i1 %t5 to i32
  %t7 = icmp ne i32 %t6, 0
  br i1 %t7, label %wbody1, label %wend2
wbody1:
  %t8 = load ptr, ptr @g_prog
  %t9 = getelementptr inbounds %LSlice, ptr %t8, i32 0, i32 0
  %t10 = load ptr, ptr %t9
  %t11 = load i32, ptr %t0
  %t12 = getelementptr inbounds ptr, ptr %t10, i32 %t11
  %t13 = load ptr, ptr %t12
  %t14 = getelementptr inbounds %Str_Node, ptr %t13, i32 0, i32 0
  %t15 = load i32, ptr %t14
  store i32 %t15, ptr %t16
  %t18 = load i32, ptr %t16
  %t19 = icmp eq i32 %t18, 8
  %t20 = zext i1 %t19 to i32
  %t21 = icmp ne i32 %t20, 0
  %t22 = zext i1 %t21 to i32
  store i32 %t22, ptr %t17
  br i1 %t21, label %scend4, label %sc3
sc3:
  %t23 = load i32, ptr %t16
  %t24 = icmp eq i32 %t23, 9
  %t25 = zext i1 %t24 to i32
  %t26 = icmp ne i32 %t25, 0
  %t27 = zext i1 %t26 to i32
  store i32 %t27, ptr %t17
  br label %scend4
scend4:
  %t28 = load i32, ptr %t17
  %t29 = icmp ne i32 %t28, 0
  br i1 %t29, label %then5, label %ifend7
then5:
  store i32 1, ptr %retval
  br label %ret
ifend7:
  %t30 = load i32, ptr %t0
  %t31 = add i32 %t30, 1
  store i32 %t31, ptr %t0
  br label %wcond0
wend2:
  store i32 0, ptr %retval
  br label %ret
ret:
  %t32 = load i32, ptr %retval
  ret i32 %t32
}

define i32 @fn_has_systems() {
entry:
  %retval = alloca i32
  %t0 = alloca i32
  store i32 0, ptr %t0
  br label %wcond0
wcond0:
  %t1 = load i32, ptr %t0
  %t2 = load ptr, ptr @g_prog
  %t3 = getelementptr inbounds %LSlice, ptr %t2, i32 0, i32 1
  %t4 = load i32, ptr %t3
  %t5 = icmp slt i32 %t1, %t4
  %t6 = zext i1 %t5 to i32
  %t7 = icmp ne i32 %t6, 0
  br i1 %t7, label %wbody1, label %wend2
wbody1:
  %t8 = load ptr, ptr @g_prog
  %t9 = getelementptr inbounds %LSlice, ptr %t8, i32 0, i32 0
  %t10 = load ptr, ptr %t9
  %t11 = load i32, ptr %t0
  %t12 = getelementptr inbounds ptr, ptr %t10, i32 %t11
  %t13 = load ptr, ptr %t12
  %t14 = getelementptr inbounds %Str_Node, ptr %t13, i32 0, i32 0
  %t15 = load i32, ptr %t14
  %t16 = icmp eq i32 %t15, 9
  %t17 = zext i1 %t16 to i32
  %t18 = icmp ne i32 %t17, 0
  br i1 %t18, label %then3, label %ifend5
then3:
  store i32 1, ptr %retval
  br label %ret
ifend5:
  %t19 = load i32, ptr %t0
  %t20 = add i32 %t19, 1
  store i32 %t20, ptr %t0
  br label %wcond0
wend2:
  store i32 0, ptr %retval
  br label %ret
ret:
  %t21 = load i32, ptr %retval
  ret i32 %t21
}

define void @fn_emit_ecs_storage() {
entry:
  %t1 = alloca ptr
  %t11 = alloca i32
  %t25 = alloca ptr
  %t45 = alloca i32
  call void @fn_emith(ptr @.str1025)
  call void @fn_emith(ptr @.str1026)
  call void @fn_emith(ptr @.str1027)
  %t0 = call ptr @fn_itoa(i32 1024)
  store ptr %t0, ptr %t1
  %t2 = load ptr, ptr %t1
  %t3 = call ptr @fn_sconcat(ptr %t2, ptr @.str1029)
  %t4 = call ptr @fn_sconcat(ptr @.str1028, ptr %t3)
  call void @fn_emith(ptr %t4)
  %t5 = load ptr, ptr %t1
  %t6 = call ptr @fn_sconcat(ptr %t5, ptr @.str1031)
  %t7 = call ptr @fn_sconcat(ptr @.str1030, ptr %t6)
  call void @fn_emith(ptr %t7)
  %t8 = load ptr, ptr %t1
  %t9 = call ptr @fn_sconcat(ptr %t8, ptr @.str1033)
  %t10 = call ptr @fn_sconcat(ptr @.str1032, ptr %t9)
  call void @fn_emith(ptr %t10)
  call void @fn_emith(ptr @.str1034)
  store i32 0, ptr %t11
  br label %wcond0
wcond0:
  %t12 = load i32, ptr %t11
  %t13 = load ptr, ptr @g_prog
  %t14 = getelementptr inbounds %LSlice, ptr %t13, i32 0, i32 1
  %t15 = load i32, ptr %t14
  %t16 = icmp slt i32 %t12, %t15
  %t17 = zext i1 %t16 to i32
  %t18 = icmp ne i32 %t17, 0
  br i1 %t18, label %wbody1, label %wend2
wbody1:
  %t19 = load ptr, ptr @g_prog
  %t20 = getelementptr inbounds %LSlice, ptr %t19, i32 0, i32 0
  %t21 = load ptr, ptr %t20
  %t22 = load i32, ptr %t11
  %t23 = getelementptr inbounds ptr, ptr %t21, i32 %t22
  %t24 = load ptr, ptr %t23
  store ptr %t24, ptr %t25
  %t26 = load ptr, ptr %t25
  %t27 = getelementptr inbounds %Str_Node, ptr %t26, i32 0, i32 0
  %t28 = load i32, ptr %t27
  %t29 = icmp eq i32 %t28, 8
  %t30 = zext i1 %t29 to i32
  %t31 = icmp ne i32 %t30, 0
  br i1 %t31, label %then3, label %ifend5
then3:
  %t32 = load ptr, ptr %t25
  %t33 = getelementptr inbounds %Str_Node, ptr %t32, i32 0, i32 1
  %t34 = load ptr, ptr %t33
  %t35 = call ptr @fn_sconcat(ptr %t34, ptr @.str1036)
  %t36 = call ptr @fn_sconcat(ptr @.str1035, ptr %t35)
  call void @fn_emith(ptr %t36)
  %t37 = load ptr, ptr %t25
  %t38 = getelementptr inbounds %Str_Node, ptr %t37, i32 0, i32 7
  %t39 = load ptr, ptr %t38
  %t40 = getelementptr inbounds %LSlice, ptr %t39, i32 0, i32 1
  %t41 = load i32, ptr %t40
  %t42 = icmp eq i32 %t41, 0
  %t43 = zext i1 %t42 to i32
  %t44 = icmp ne i32 %t43, 0
  br i1 %t44, label %then6, label %ifend8
then6:
  call void @fn_emith(ptr @.str1037)
  br label %ifend8
ifend8:
  store i32 0, ptr %t45
  br label %wcond9
wcond9:
  %t46 = load i32, ptr %t45
  %t47 = load ptr, ptr %t25
  %t48 = getelementptr inbounds %Str_Node, ptr %t47, i32 0, i32 7
  %t49 = load ptr, ptr %t48
  %t50 = getelementptr inbounds %LSlice, ptr %t49, i32 0, i32 1
  %t51 = load i32, ptr %t50
  %t52 = icmp slt i32 %t46, %t51
  %t53 = zext i1 %t52 to i32
  %t54 = icmp ne i32 %t53, 0
  br i1 %t54, label %wbody10, label %wend11
wbody10:
  %t55 = load i32, ptr %t45
  %t56 = icmp sgt i32 %t55, 0
  %t57 = zext i1 %t56 to i32
  %t58 = icmp ne i32 %t57, 0
  br i1 %t58, label %then12, label %ifend14
then12:
  call void @fn_emith(ptr @.str1038)
  br label %ifend14
ifend14:
  %t59 = load ptr, ptr %t25
  %t60 = getelementptr inbounds %Str_Node, ptr %t59, i32 0, i32 7
  %t61 = load ptr, ptr %t60
  %t62 = getelementptr inbounds %LSlice, ptr %t61, i32 0, i32 0
  %t63 = load ptr, ptr %t62
  %t64 = load i32, ptr %t45
  %t65 = getelementptr inbounds ptr, ptr %t63, i32 %t64
  %t66 = load ptr, ptr %t65
  %t67 = getelementptr inbounds %Str_Node, ptr %t66, i32 0, i32 3
  %t68 = load ptr, ptr %t67
  %t69 = call ptr @fn_llty(ptr %t68)
  call void @fn_emith(ptr %t69)
  %t70 = load i32, ptr %t45
  %t71 = add i32 %t70, 1
  store i32 %t71, ptr %t45
  br label %wcond9
wend11:
  call void @fn_emith(ptr @.str1039)
  %t72 = load ptr, ptr %t25
  %t73 = getelementptr inbounds %Str_Node, ptr %t72, i32 0, i32 1
  %t74 = load ptr, ptr %t73
  %t75 = load ptr, ptr %t1
  %t76 = load ptr, ptr %t25
  %t77 = getelementptr inbounds %Str_Node, ptr %t76, i32 0, i32 1
  %t78 = load ptr, ptr %t77
  %t79 = call ptr @fn_sconcat(ptr %t78, ptr @.str1043)
  %t80 = call ptr @fn_sconcat(ptr @.str1042, ptr %t79)
  %t81 = call ptr @fn_sconcat(ptr %t75, ptr %t80)
  %t82 = call ptr @fn_sconcat(ptr @.str1041, ptr %t81)
  %t83 = call ptr @fn_sconcat(ptr %t74, ptr %t82)
  %t84 = call ptr @fn_sconcat(ptr @.str1040, ptr %t83)
  call void @fn_emith(ptr %t84)
  %t85 = load ptr, ptr %t25
  %t86 = getelementptr inbounds %Str_Node, ptr %t85, i32 0, i32 1
  %t87 = load ptr, ptr %t86
  %t88 = load ptr, ptr %t1
  %t89 = call ptr @fn_sconcat(ptr %t88, ptr @.str1046)
  %t90 = call ptr @fn_sconcat(ptr @.str1045, ptr %t89)
  %t91 = call ptr @fn_sconcat(ptr %t87, ptr %t90)
  %t92 = call ptr @fn_sconcat(ptr @.str1044, ptr %t91)
  call void @fn_emith(ptr %t92)
  br label %ifend5
ifend5:
  %t93 = load i32, ptr %t11
  %t94 = add i32 %t93, 1
  store i32 %t94, ptr %t11
  br label %wcond0
wend2:
  br label %ret
ret:
  ret void
}

define void @fn_emit_ecs_allocator() {
entry:
  %t1 = alloca ptr
  %t2 = alloca i32
  %t24 = alloca ptr
  %t0 = call ptr @fn_itoa(i32 1024)
  store ptr %t0, ptr %t1
  call void @fn_emit(ptr @.str1047)
  store i32 0, ptr %t2
  br label %wcond0
wcond0:
  %t3 = load i32, ptr %t2
  %t4 = load ptr, ptr @g_prog
  %t5 = getelementptr inbounds %LSlice, ptr %t4, i32 0, i32 1
  %t6 = load i32, ptr %t5
  %t7 = icmp slt i32 %t3, %t6
  %t8 = zext i1 %t7 to i32
  %t9 = icmp ne i32 %t8, 0
  br i1 %t9, label %wbody1, label %wend2
wbody1:
  %t10 = load ptr, ptr @g_prog
  %t11 = getelementptr inbounds %LSlice, ptr %t10, i32 0, i32 0
  %t12 = load ptr, ptr %t11
  %t13 = load i32, ptr %t2
  %t14 = getelementptr inbounds ptr, ptr %t12, i32 %t13
  %t15 = load ptr, ptr %t14
  %t16 = getelementptr inbounds %Str_Node, ptr %t15, i32 0, i32 0
  %t17 = load i32, ptr %t16
  %t18 = icmp eq i32 %t17, 8
  %t19 = zext i1 %t18 to i32
  %t20 = icmp ne i32 %t19, 0
  br i1 %t20, label %then3, label %ifend5
then3:
  %t21 = load i32, ptr %t2
  %t22 = call ptr @fn_itoa(i32 %t21)
  %t23 = call ptr @fn_sconcat(ptr @.str1048, ptr %t22)
  store ptr %t23, ptr %t24
  call void @fn_emit(ptr @.str1049)
  %t25 = load ptr, ptr %t24
  call void @fn_emit(ptr %t25)
  call void @fn_emit(ptr @.str1050)
  %t26 = load ptr, ptr %t1
  call void @fn_emit(ptr %t26)
  call void @fn_emit(ptr @.str1051)
  %t27 = load ptr, ptr @g_prog
  %t28 = getelementptr inbounds %LSlice, ptr %t27, i32 0, i32 0
  %t29 = load ptr, ptr %t28
  %t30 = load i32, ptr %t2
  %t31 = getelementptr inbounds ptr, ptr %t29, i32 %t30
  %t32 = load ptr, ptr %t31
  %t33 = getelementptr inbounds %Str_Node, ptr %t32, i32 0, i32 1
  %t34 = load ptr, ptr %t33
  call void @fn_emit(ptr %t34)
  call void @fn_emit(ptr @.str1052)
  call void @fn_emit(ptr @.str1053)
  %t35 = load ptr, ptr %t24
  call void @fn_emit(ptr %t35)
  call void @fn_emit(ptr @.str1054)
  br label %ifend5
ifend5:
  %t36 = load i32, ptr %t2
  %t37 = add i32 %t36, 1
  store i32 %t37, ptr %t2
  br label %wcond0
wend2:
  call void @fn_emit(ptr @.str1055)
  %t38 = load ptr, ptr %t1
  call void @fn_emit(ptr %t38)
  call void @fn_emit(ptr @.str1056)
  call void @fn_emit(ptr @.str1057)
  call void @fn_emit(ptr @.str1058)
  call void @fn_emit(ptr @.str1059)
  call void @fn_emit(ptr @.str1060)
  call void @fn_emit(ptr @.str1061)
  call void @fn_emit(ptr @.str1062)
  call void @fn_emit(ptr @.str1063)
  call void @fn_emit(ptr @.str1064)
  call void @fn_emit(ptr @.str1065)
  %t39 = load ptr, ptr %t1
  call void @fn_emit(ptr %t39)
  call void @fn_emit(ptr @.str1066)
  call void @fn_emit(ptr @.str1067)
  call void @fn_emit(ptr @.str1068)
  call void @fn_emit(ptr @.str1069)
  call void @fn_emit(ptr @.str1070)
  call void @fn_emit(ptr @.str1071)
  call void @fn_emit(ptr @.str1072)
  call void @fn_emit(ptr @.str1073)
  call void @fn_emit(ptr @.str1074)
  call void @fn_emit(ptr @.str1075)
  call void @fn_emit(ptr @.str1076)
  call void @fn_emit(ptr @.str1077)
  %t40 = load ptr, ptr %t1
  call void @fn_emit(ptr %t40)
  call void @fn_emit(ptr @.str1078)
  call void @fn_emit(ptr @.str1079)
  call void @fn_emit(ptr @.str1080)
  call void @fn_emit(ptr @.str1081)
  call void @fn_emit(ptr @.str1082)
  %t41 = load ptr, ptr %t1
  call void @fn_emit(ptr %t41)
  call void @fn_emit(ptr @.str1083)
  call void @fn_emit(ptr @.str1084)
  call void @fn_emit(ptr @.str1085)
  call void @fn_emit(ptr @.str1086)
  call void @fn_emit(ptr @.str1087)
  %t42 = load ptr, ptr %t1
  call void @fn_emit(ptr %t42)
  call void @fn_emit(ptr @.str1088)
  call void @fn_emit(ptr @.str1089)
  call void @fn_emit(ptr @.str1090)
  call void @fn_emit(ptr @.str1091)
  call void @fn_emit(ptr @.str1092)
  br label %ret
ret:
  ret void
}

define i32 @fn_find_arch_id(ptr %arg_name) {
entry:
  %retval = alloca i32
  %t0 = alloca ptr
  %t1 = alloca i32
  %t2 = alloca i32
  store ptr %arg_name, ptr %t0
  store i32 0, ptr %t1
  store i32 1, ptr %t2
  br label %wcond0
wcond0:
  %t3 = load i32, ptr %t1
  %t4 = load ptr, ptr @g_prog
  %t5 = getelementptr inbounds %LSlice, ptr %t4, i32 0, i32 1
  %t6 = load i32, ptr %t5
  %t7 = icmp slt i32 %t3, %t6
  %t8 = zext i1 %t7 to i32
  %t9 = icmp ne i32 %t8, 0
  br i1 %t9, label %wbody1, label %wend2
wbody1:
  %t10 = load ptr, ptr @g_prog
  %t11 = getelementptr inbounds %LSlice, ptr %t10, i32 0, i32 0
  %t12 = load ptr, ptr %t11
  %t13 = load i32, ptr %t1
  %t14 = getelementptr inbounds ptr, ptr %t12, i32 %t13
  %t15 = load ptr, ptr %t14
  %t16 = getelementptr inbounds %Str_Node, ptr %t15, i32 0, i32 0
  %t17 = load i32, ptr %t16
  %t18 = icmp eq i32 %t17, 10
  %t19 = zext i1 %t18 to i32
  %t20 = icmp ne i32 %t19, 0
  br i1 %t20, label %then3, label %ifend5
then3:
  %t21 = load ptr, ptr @g_prog
  %t22 = getelementptr inbounds %LSlice, ptr %t21, i32 0, i32 0
  %t23 = load ptr, ptr %t22
  %t24 = load i32, ptr %t1
  %t25 = getelementptr inbounds ptr, ptr %t23, i32 %t24
  %t26 = load ptr, ptr %t25
  %t27 = getelementptr inbounds %Str_Node, ptr %t26, i32 0, i32 1
  %t28 = load ptr, ptr %t27
  %t29 = load ptr, ptr %t0
  %t30 = call i32 @fn_streq(ptr %t28, ptr %t29)
  %t31 = icmp ne i32 %t30, 0
  br i1 %t31, label %then6, label %ifend8
then6:
  %t32 = load i32, ptr %t2
  store i32 %t32, ptr %retval
  br label %ret
ifend8:
  %t33 = load i32, ptr %t2
  %t34 = add i32 %t33, 1
  store i32 %t34, ptr %t2
  br label %ifend5
ifend5:
  %t35 = load i32, ptr %t1
  %t36 = add i32 %t35, 1
  store i32 %t36, ptr %t1
  br label %wcond0
wend2:
  store i32 0, ptr %retval
  br label %ret
ret:
  %t37 = load i32, ptr %retval
  ret i32 %t37
}

define void @fn_emit_query(ptr %arg_st) {
entry:
  %t0 = alloca ptr
  %t2 = alloca ptr
  %t4 = alloca ptr
  %t42 = alloca ptr
  %t44 = alloca ptr
  %t46 = alloca ptr
  %t48 = alloca ptr
  %t54 = alloca ptr
  %t56 = alloca ptr
  %t63 = alloca ptr
  %t71 = alloca ptr
  %t73 = alloca ptr
  %t80 = alloca ptr
  %t85 = alloca ptr
  %t87 = alloca ptr
  %t95 = alloca ptr
  %t96 = alloca i32
  %t114 = alloca ptr
  %t119 = alloca i32
  %t120 = alloca ptr
  %t126 = alloca ptr
  %t133 = alloca ptr
  %t142 = alloca ptr
  %t152 = alloca ptr
  %t158 = alloca ptr
  %t166 = alloca i32
  %t167 = alloca i32
  %t185 = alloca ptr
  %t186 = alloca i32
  %t214 = alloca ptr
  %t225 = alloca ptr
  %t258 = alloca ptr
  %t265 = alloca ptr
  %t267 = alloca ptr
  %t287 = alloca ptr
  %t292 = alloca ptr
  store ptr %arg_st, ptr %t0
  %t1 = call ptr @fn_itoa(i32 1024)
  store ptr %t1, ptr %t2
  %t3 = call ptr @fn_emit_alloca(ptr @.str1093)
  store ptr %t3, ptr %t4
  %t5 = load ptr, ptr %t4
  call void @fn_store_at(ptr @.str1094, ptr @.str1095, ptr %t5)
  %t6 = load i32, ptr @g_nself
  %t7 = load ptr, ptr @g_self_stk
  %t8 = getelementptr inbounds %LSlice, ptr %t7, i32 0, i32 1
  %t9 = load i32, ptr %t8
  %t10 = icmp slt i32 %t6, %t9
  %t11 = zext i1 %t10 to i32
  %t12 = icmp ne i32 %t11, 0
  br i1 %t12, label %then0, label %else1
then0:
  %t13 = load ptr, ptr @g_self_stk
  %t14 = getelementptr inbounds %LSlice, ptr %t13, i32 0, i32 0
  %t15 = load ptr, ptr %t14
  %t16 = load i32, ptr @g_nself
  %t17 = getelementptr inbounds ptr, ptr %t15, i32 %t16
  %t18 = load ptr, ptr %t4
  store ptr %t18, ptr %t17
  br label %ifend2
else1:
  %t19 = load ptr, ptr @g_self_stk
  %t20 = getelementptr inbounds %LSlice, ptr %t19, i32 0, i32 1
  %t21 = getelementptr inbounds %LSlice, ptr %t19, i32 0, i32 2
  %t22 = getelementptr inbounds %LSlice, ptr %t19, i32 0, i32 0
  %t23 = load i32, ptr %t20
  %t24 = load i32, ptr %t21
  %t25 = icmp sge i32 %t23, %t24
  br i1 %t25, label %grow3, label %put4
grow3:
  %t26 = mul i32 %t24, 2
  %t27 = icmp eq i32 %t24, 0
  %t28 = select i1 %t27, i32 8, i32 %t26
  %t29 = getelementptr ptr, ptr null, i32 1
  %t30 = ptrtoint ptr %t29 to i64
  %t31 = zext i32 %t28 to i64
  %t32 = mul i64 %t31, %t30
  %t33 = load ptr, ptr %t22
  %t34 = call ptr @realloc(ptr %t33, i64 %t32)
  store ptr %t34, ptr %t22
  store i32 %t28, ptr %t21
  br label %put4
put4:
  %t35 = load ptr, ptr %t4
  %t36 = load ptr, ptr %t22
  %t37 = getelementptr inbounds ptr, ptr %t36, i32 %t23
  store ptr %t35, ptr %t37
  %t38 = add i32 %t23, 1
  store i32 %t38, ptr %t20
  br label %ifend2
ifend2:
  %t39 = load i32, ptr @g_nself
  %t40 = add i32 %t39, 1
  store i32 %t40, ptr @g_nself
  %t41 = call ptr @fn_lbl(ptr @.str1096)
  store ptr %t41, ptr %t42
  %t43 = call ptr @fn_lbl(ptr @.str1097)
  store ptr %t43, ptr %t44
  %t45 = call ptr @fn_lbl(ptr @.str1098)
  store ptr %t45, ptr %t46
  %t47 = call ptr @fn_lbl(ptr @.str1099)
  store ptr %t47, ptr %t48
  call void @fn_emit(ptr @.str1100)
  %t49 = load ptr, ptr %t42
  call void @fn_emit(ptr %t49)
  call void @fn_emit(ptr @.str1101)
  %t50 = load ptr, ptr %t42
  call void @fn_emit(ptr %t50)
  call void @fn_emit(ptr @.str1102)
  %t51 = load ptr, ptr %t4
  %t52 = call ptr @fn_sconcat(ptr @.str1103, ptr %t51)
  %t53 = call ptr @fn_emit_bind(ptr %t52)
  store ptr %t53, ptr %t54
  %t55 = call ptr @fn_emit_bind(ptr @.str1104)
  store ptr %t55, ptr %t56
  %t57 = load ptr, ptr %t54
  %t58 = load ptr, ptr %t56
  %t59 = call ptr @fn_sconcat(ptr @.str1106, ptr %t58)
  %t60 = call ptr @fn_sconcat(ptr %t57, ptr %t59)
  %t61 = call ptr @fn_sconcat(ptr @.str1105, ptr %t60)
  %t62 = call ptr @fn_emit_bind(ptr %t61)
  store ptr %t62, ptr %t63
  call void @fn_emit(ptr @.str1107)
  %t64 = load ptr, ptr %t63
  call void @fn_emit(ptr %t64)
  call void @fn_emit(ptr @.str1108)
  %t65 = load ptr, ptr %t44
  call void @fn_emit(ptr %t65)
  call void @fn_emit(ptr @.str1109)
  %t66 = load ptr, ptr %t48
  call void @fn_emit(ptr %t66)
  call void @fn_emit(ptr @.str1110)
  %t67 = load ptr, ptr %t44
  call void @fn_emit(ptr %t67)
  call void @fn_emit(ptr @.str1111)
  store i32 0, ptr @g_g_term
  %t68 = load ptr, ptr %t4
  %t69 = call ptr @fn_sconcat(ptr @.str1112, ptr %t68)
  %t70 = call ptr @fn_emit_bind(ptr %t69)
  store ptr %t70, ptr %t71
  %t72 = call ptr @fn_nreg()
  store ptr %t72, ptr %t73
  call void @fn_emit(ptr @.str1113)
  %t74 = load ptr, ptr %t73
  call void @fn_emit(ptr %t74)
  call void @fn_emit(ptr @.str1114)
  %t75 = load ptr, ptr %t2
  call void @fn_emit(ptr %t75)
  call void @fn_emit(ptr @.str1115)
  %t76 = load ptr, ptr %t71
  call void @fn_emit(ptr %t76)
  call void @fn_emit(ptr @.str1116)
  %t77 = load ptr, ptr %t73
  %t78 = call ptr @fn_sconcat(ptr @.str1117, ptr %t77)
  %t79 = call ptr @fn_emit_bind(ptr %t78)
  store ptr %t79, ptr %t80
  %t81 = load ptr, ptr %t80
  %t82 = call ptr @fn_sconcat(ptr %t81, ptr @.str1119)
  %t83 = call ptr @fn_sconcat(ptr @.str1118, ptr %t82)
  %t84 = call ptr @fn_emit_bind(ptr %t83)
  store ptr %t84, ptr %t85
  %t86 = call ptr @fn_lbl(ptr @.str1120)
  store ptr %t86, ptr %t87
  call void @fn_emit(ptr @.str1121)
  %t88 = load ptr, ptr %t85
  call void @fn_emit(ptr %t88)
  call void @fn_emit(ptr @.str1122)
  %t89 = load ptr, ptr %t87
  call void @fn_emit(ptr %t89)
  call void @fn_emit(ptr @.str1123)
  %t90 = load ptr, ptr %t46
  call void @fn_emit(ptr %t90)
  call void @fn_emit(ptr @.str1124)
  %t91 = load ptr, ptr %t87
  call void @fn_emit(ptr %t91)
  call void @fn_emit(ptr @.str1125)
  %t92 = load ptr, ptr %t0
  %t93 = getelementptr inbounds %Str_Node, ptr %t92, i32 0, i32 6
  %t94 = load ptr, ptr %t93
  store ptr %t94, ptr %t95
  store i32 0, ptr %t96
  br label %wcond5
wcond5:
  %t97 = load i32, ptr %t96
  %t98 = load ptr, ptr %t95
  %t99 = getelementptr inbounds %Str_Node, ptr %t98, i32 0, i32 7
  %t100 = load ptr, ptr %t99
  %t101 = getelementptr inbounds %LSlice, ptr %t100, i32 0, i32 1
  %t102 = load i32, ptr %t101
  %t103 = icmp slt i32 %t97, %t102
  %t104 = zext i1 %t103 to i32
  %t105 = icmp ne i32 %t104, 0
  br i1 %t105, label %wbody6, label %wend7
wbody6:
  %t106 = load ptr, ptr %t95
  %t107 = getelementptr inbounds %Str_Node, ptr %t106, i32 0, i32 7
  %t108 = load ptr, ptr %t107
  %t109 = getelementptr inbounds %LSlice, ptr %t108, i32 0, i32 0
  %t110 = load ptr, ptr %t109
  %t111 = load i32, ptr %t96
  %t112 = getelementptr inbounds ptr, ptr %t110, i32 %t111
  %t113 = load ptr, ptr %t112
  store ptr %t113, ptr %t114
  %t115 = load ptr, ptr %t114
  %t116 = getelementptr inbounds %Str_Node, ptr %t115, i32 0, i32 1
  %t117 = load ptr, ptr %t116
  %t118 = call i32 @fn_find_arch_id(ptr %t117)
  store i32 %t118, ptr %t119
  store ptr @.str1126, ptr %t120
  %t121 = load i32, ptr %t119
  %t122 = icmp sgt i32 %t121, 0
  %t123 = zext i1 %t122 to i32
  %t124 = icmp ne i32 %t123, 0
  br i1 %t124, label %then8, label %else9
then8:
  %t125 = call ptr @fn_nreg()
  store ptr %t125, ptr %t126
  call void @fn_emit(ptr @.str1127)
  %t127 = load ptr, ptr %t126
  call void @fn_emit(ptr %t127)
  call void @fn_emit(ptr @.str1128)
  %t128 = load ptr, ptr %t2
  call void @fn_emit(ptr %t128)
  call void @fn_emit(ptr @.str1129)
  %t129 = load ptr, ptr %t71
  call void @fn_emit(ptr %t129)
  call void @fn_emit(ptr @.str1130)
  %t130 = load ptr, ptr %t126
  %t131 = call ptr @fn_sconcat(ptr @.str1131, ptr %t130)
  %t132 = call ptr @fn_emit_bind(ptr %t131)
  store ptr %t132, ptr %t133
  %t134 = load ptr, ptr %t133
  %t135 = load i32, ptr %t119
  %t136 = call ptr @fn_itoa(i32 %t135)
  %t137 = call ptr @fn_sconcat(ptr @.str1133, ptr %t136)
  %t138 = call ptr @fn_sconcat(ptr %t134, ptr %t137)
  %t139 = call ptr @fn_sconcat(ptr @.str1132, ptr %t138)
  %t140 = call ptr @fn_emit_bind(ptr %t139)
  store ptr %t140, ptr %t120
  br label %ifend10
else9:
  %t141 = call ptr @fn_nreg()
  store ptr %t141, ptr %t142
  call void @fn_emit(ptr @.str1134)
  %t143 = load ptr, ptr %t142
  call void @fn_emit(ptr %t143)
  call void @fn_emit(ptr @.str1135)
  %t144 = load ptr, ptr %t2
  call void @fn_emit(ptr %t144)
  call void @fn_emit(ptr @.str1136)
  %t145 = load ptr, ptr %t114
  %t146 = getelementptr inbounds %Str_Node, ptr %t145, i32 0, i32 1
  %t147 = load ptr, ptr %t146
  call void @fn_emit(ptr %t147)
  call void @fn_emit(ptr @.str1137)
  %t148 = load ptr, ptr %t71
  call void @fn_emit(ptr %t148)
  call void @fn_emit(ptr @.str1138)
  %t149 = load ptr, ptr %t142
  %t150 = call ptr @fn_sconcat(ptr @.str1139, ptr %t149)
  %t151 = call ptr @fn_emit_bind(ptr %t150)
  store ptr %t151, ptr %t152
  %t153 = load ptr, ptr %t152
  %t154 = call ptr @fn_sconcat(ptr %t153, ptr @.str1141)
  %t155 = call ptr @fn_sconcat(ptr @.str1140, ptr %t154)
  %t156 = call ptr @fn_emit_bind(ptr %t155)
  store ptr %t156, ptr %t120
  br label %ifend10
ifend10:
  %t157 = call ptr @fn_lbl(ptr @.str1142)
  store ptr %t157, ptr %t158
  call void @fn_emit(ptr @.str1143)
  %t159 = load ptr, ptr %t120
  call void @fn_emit(ptr %t159)
  call void @fn_emit(ptr @.str1144)
  %t160 = load ptr, ptr %t158
  call void @fn_emit(ptr %t160)
  call void @fn_emit(ptr @.str1145)
  %t161 = load ptr, ptr %t46
  call void @fn_emit(ptr %t161)
  call void @fn_emit(ptr @.str1146)
  %t162 = load ptr, ptr %t158
  call void @fn_emit(ptr %t162)
  call void @fn_emit(ptr @.str1147)
  %t163 = load i32, ptr %t96
  %t164 = add i32 %t163, 1
  store i32 %t164, ptr %t96
  br label %wcond5
wend7:
  %t165 = load i32, ptr @g_nloc
  store i32 %t165, ptr %t166
  store i32 0, ptr %t167
  store i32 0, ptr %t96
  br label %wcond11
wcond11:
  %t168 = load i32, ptr %t96
  %t169 = load ptr, ptr %t95
  %t170 = getelementptr inbounds %Str_Node, ptr %t169, i32 0, i32 7
  %t171 = load ptr, ptr %t170
  %t172 = getelementptr inbounds %LSlice, ptr %t171, i32 0, i32 1
  %t173 = load i32, ptr %t172
  %t174 = icmp slt i32 %t168, %t173
  %t175 = zext i1 %t174 to i32
  %t176 = icmp ne i32 %t175, 0
  br i1 %t176, label %wbody12, label %wend13
wbody12:
  %t177 = load ptr, ptr %t95
  %t178 = getelementptr inbounds %Str_Node, ptr %t177, i32 0, i32 7
  %t179 = load ptr, ptr %t178
  %t180 = getelementptr inbounds %LSlice, ptr %t179, i32 0, i32 0
  %t181 = load ptr, ptr %t180
  %t182 = load i32, ptr %t96
  %t183 = getelementptr inbounds ptr, ptr %t181, i32 %t182
  %t184 = load ptr, ptr %t183
  store ptr %t184, ptr %t185
  %t187 = load ptr, ptr %t185
  %t188 = getelementptr inbounds %Str_Node, ptr %t187, i32 0, i32 2
  %t189 = load i32, ptr %t188
  %t190 = icmp eq i32 %t189, 0
  %t191 = zext i1 %t190 to i32
  %t192 = icmp ne i32 %t191, 0
  %t193 = zext i1 %t192 to i32
  store i32 %t193, ptr %t186
  br i1 %t192, label %sc14, label %scend15
sc14:
  %t194 = load ptr, ptr %t185
  %t195 = getelementptr inbounds %Str_Node, ptr %t194, i32 0, i32 1
  %t196 = load ptr, ptr %t195
  %t197 = call i32 @fn_find_arch_id(ptr %t196)
  %t198 = icmp eq i32 %t197, 0
  %t199 = zext i1 %t198 to i32
  %t200 = icmp ne i32 %t199, 0
  %t201 = zext i1 %t200 to i32
  store i32 %t201, ptr %t186
  br label %scend15
scend15:
  %t202 = load i32, ptr %t186
  %t203 = icmp ne i32 %t202, 0
  br i1 %t203, label %then16, label %ifend18
then16:
  %t204 = load i32, ptr %t167
  %t205 = load ptr, ptr %t0
  %t206 = getelementptr inbounds %Str_Node, ptr %t205, i32 0, i32 7
  %t207 = load ptr, ptr %t206
  %t208 = getelementptr inbounds %LSlice, ptr %t207, i32 0, i32 1
  %t209 = load i32, ptr %t208
  %t210 = icmp slt i32 %t204, %t209
  %t211 = zext i1 %t210 to i32
  %t212 = icmp ne i32 %t211, 0
  br i1 %t212, label %then19, label %ifend21
then19:
  %t213 = call ptr @fn_nreg()
  store ptr %t213, ptr %t214
  call void @fn_emit(ptr @.str1148)
  %t215 = load ptr, ptr %t214
  call void @fn_emit(ptr %t215)
  call void @fn_emit(ptr @.str1149)
  %t216 = load ptr, ptr %t2
  call void @fn_emit(ptr %t216)
  call void @fn_emit(ptr @.str1150)
  %t217 = load ptr, ptr %t185
  %t218 = getelementptr inbounds %Str_Node, ptr %t217, i32 0, i32 1
  %t219 = load ptr, ptr %t218
  call void @fn_emit(ptr %t219)
  call void @fn_emit(ptr @.str1151)
  %t220 = load ptr, ptr %t185
  %t221 = getelementptr inbounds %Str_Node, ptr %t220, i32 0, i32 1
  %t222 = load ptr, ptr %t221
  call void @fn_emit(ptr %t222)
  call void @fn_emit(ptr @.str1152)
  %t223 = load ptr, ptr %t71
  call void @fn_emit(ptr %t223)
  call void @fn_emit(ptr @.str1153)
  %t224 = call ptr @fn_emit_alloca(ptr @.str1154)
  store ptr %t224, ptr %t225
  call void @fn_emit(ptr @.str1155)
  %t226 = load ptr, ptr %t214
  call void @fn_emit(ptr %t226)
  call void @fn_emit(ptr @.str1156)
  %t227 = load ptr, ptr %t225
  call void @fn_emit(ptr %t227)
  call void @fn_emit(ptr @.str1157)
  %t228 = load ptr, ptr %t0
  %t229 = getelementptr inbounds %Str_Node, ptr %t228, i32 0, i32 7
  %t230 = load ptr, ptr %t229
  %t231 = getelementptr inbounds %LSlice, ptr %t230, i32 0, i32 0
  %t232 = load ptr, ptr %t231
  %t233 = load i32, ptr %t167
  %t234 = getelementptr inbounds ptr, ptr %t232, i32 %t233
  %t235 = load ptr, ptr %t234
  %t236 = getelementptr inbounds %Str_Node, ptr %t235, i32 0, i32 1
  %t237 = load ptr, ptr %t236
  %t238 = load ptr, ptr %t225
  %t239 = load ptr, ptr %t185
  %t240 = getelementptr inbounds %Str_Node, ptr %t239, i32 0, i32 1
  %t241 = load ptr, ptr %t240
  call void @fn_loc_push(ptr %t237, ptr %t238, ptr %t241)
  %t242 = load i32, ptr %t167
  %t243 = add i32 %t242, 1
  store i32 %t243, ptr %t167
  br label %ifend21
ifend21:
  br label %ifend18
ifend18:
  %t244 = load i32, ptr %t96
  %t245 = add i32 %t244, 1
  store i32 %t245, ptr %t96
  br label %wcond11
wend13:
  %t246 = load ptr, ptr %t0
  %t247 = getelementptr inbounds %Str_Node, ptr %t246, i32 0, i32 5
  %t248 = load ptr, ptr %t247
  %t249 = icmp eq ptr %t248, null
  %t250 = zext i1 %t249 to i32
  %t251 = icmp eq i32 %t250, 0
  %t252 = zext i1 %t251 to i32
  %t253 = icmp ne i32 %t252, 0
  br i1 %t253, label %then22, label %ifend24
then22:
  %t254 = load ptr, ptr %t0
  %t255 = getelementptr inbounds %Str_Node, ptr %t254, i32 0, i32 5
  %t256 = load ptr, ptr %t255
  %t257 = call ptr @fn_emit_expr(ptr %t256)
  store ptr %t257, ptr %t258
  %t259 = load ptr, ptr %t258
  %t260 = getelementptr inbounds %Str_Val, ptr %t259, i32 0, i32 0
  %t261 = load ptr, ptr %t260
  %t262 = call ptr @fn_sconcat(ptr %t261, ptr @.str1159)
  %t263 = call ptr @fn_sconcat(ptr @.str1158, ptr %t262)
  %t264 = call ptr @fn_emit_bind(ptr %t263)
  store ptr %t264, ptr %t265
  %t266 = call ptr @fn_lbl(ptr @.str1160)
  store ptr %t266, ptr %t267
  call void @fn_emit(ptr @.str1161)
  %t268 = load ptr, ptr %t265
  call void @fn_emit(ptr %t268)
  call void @fn_emit(ptr @.str1162)
  %t269 = load ptr, ptr %t267
  call void @fn_emit(ptr %t269)
  call void @fn_emit(ptr @.str1163)
  %t270 = load ptr, ptr %t46
  call void @fn_emit(ptr %t270)
  call void @fn_emit(ptr @.str1164)
  %t271 = load ptr, ptr %t267
  call void @fn_emit(ptr %t271)
  call void @fn_emit(ptr @.str1165)
  br label %ifend24
ifend24:
  %t272 = load ptr, ptr %t46
  %t273 = load ptr, ptr %t48
  call void @fn_loop_push(ptr %t272, ptr %t273)
  %t274 = load ptr, ptr %t0
  %t275 = getelementptr inbounds %Str_Node, ptr %t274, i32 0, i32 4
  %t276 = load ptr, ptr %t275
  call void @fn_emit_block(ptr %t276)
  call void @fn_loop_pop()
  %t277 = load i32, ptr %t166
  store i32 %t277, ptr @g_nloc
  %t278 = load i32, ptr @g_g_term
  %t279 = icmp eq i32 %t278, 0
  %t280 = zext i1 %t279 to i32
  %t281 = icmp ne i32 %t280, 0
  br i1 %t281, label %then25, label %ifend27
then25:
  call void @fn_emit(ptr @.str1166)
  %t282 = load ptr, ptr %t46
  call void @fn_emit(ptr %t282)
  call void @fn_emit(ptr @.str1167)
  br label %ifend27
ifend27:
  %t283 = load ptr, ptr %t46
  call void @fn_emit(ptr %t283)
  call void @fn_emit(ptr @.str1168)
  %t284 = load ptr, ptr %t4
  %t285 = call ptr @fn_sconcat(ptr @.str1169, ptr %t284)
  %t286 = call ptr @fn_emit_bind(ptr %t285)
  store ptr %t286, ptr %t287
  %t288 = load ptr, ptr %t287
  %t289 = call ptr @fn_sconcat(ptr %t288, ptr @.str1171)
  %t290 = call ptr @fn_sconcat(ptr @.str1170, ptr %t289)
  %t291 = call ptr @fn_emit_bind(ptr %t290)
  store ptr %t291, ptr %t292
  %t293 = load ptr, ptr %t292
  %t294 = load ptr, ptr %t4
  call void @fn_store_at(ptr @.str1172, ptr %t293, ptr %t294)
  call void @fn_emit(ptr @.str1173)
  %t295 = load ptr, ptr %t42
  call void @fn_emit(ptr %t295)
  call void @fn_emit(ptr @.str1174)
  %t296 = load ptr, ptr %t48
  call void @fn_emit(ptr %t296)
  call void @fn_emit(ptr @.str1175)
  store i32 0, ptr @g_g_term
  %t297 = load i32, ptr @g_nself
  %t298 = sub i32 %t297, 1
  store i32 %t298, ptr @g_nself
  br label %ret
ret:
  ret void
}

define void @fn_emit_init_component(ptr %arg_e, ptr %arg_comp, ptr %arg_rec) {
entry:
  %t0 = alloca ptr
  %t1 = alloca ptr
  %t2 = alloca ptr
  %t4 = alloca ptr
  %t7 = alloca ptr
  %t15 = alloca ptr
  %t22 = alloca ptr
  %t28 = alloca i32
  %t46 = alloca ptr
  %t48 = alloca ptr
  %t58 = alloca ptr
  %t59 = alloca ptr
  %t75 = alloca ptr
  %t90 = alloca i32
  %t108 = alloca ptr
  %t114 = alloca i32
  %t120 = alloca ptr
  %t130 = alloca ptr
  store ptr %arg_e, ptr %t0
  store ptr %arg_comp, ptr %t1
  store ptr %arg_rec, ptr %t2
  %t3 = call ptr @fn_itoa(i32 1024)
  store ptr %t3, ptr %t4
  %t5 = load ptr, ptr %t1
  %t6 = call ptr @fn_find_comp(ptr %t5)
  store ptr %t6, ptr %t7
  %t8 = load ptr, ptr %t7
  %t9 = icmp eq ptr %t8, null
  %t10 = zext i1 %t9 to i32
  %t11 = icmp ne i32 %t10, 0
  br i1 %t11, label %then0, label %ifend2
then0:
  %t12 = load ptr, ptr %t1
  %t13 = call ptr @fn_sconcat(ptr @.str1176, ptr %t12)
  call void @fn_perr(ptr %t13)
  br label %ifend2
ifend2:
  %t14 = call ptr @fn_nreg()
  store ptr %t14, ptr %t15
  call void @fn_emit(ptr @.str1177)
  %t16 = load ptr, ptr %t15
  call void @fn_emit(ptr %t16)
  call void @fn_emit(ptr @.str1178)
  %t17 = load ptr, ptr %t4
  call void @fn_emit(ptr %t17)
  call void @fn_emit(ptr @.str1179)
  %t18 = load ptr, ptr %t1
  call void @fn_emit(ptr %t18)
  call void @fn_emit(ptr @.str1180)
  %t19 = load ptr, ptr %t0
  call void @fn_emit(ptr %t19)
  call void @fn_emit(ptr @.str1181)
  call void @fn_emit(ptr @.str1182)
  %t20 = load ptr, ptr %t15
  call void @fn_emit(ptr %t20)
  call void @fn_emit(ptr @.str1183)
  %t21 = call ptr @fn_nreg()
  store ptr %t21, ptr %t22
  call void @fn_emit(ptr @.str1184)
  %t23 = load ptr, ptr %t22
  call void @fn_emit(ptr %t23)
  call void @fn_emit(ptr @.str1185)
  %t24 = load ptr, ptr %t4
  call void @fn_emit(ptr %t24)
  call void @fn_emit(ptr @.str1186)
  %t25 = load ptr, ptr %t1
  call void @fn_emit(ptr %t25)
  call void @fn_emit(ptr @.str1187)
  %t26 = load ptr, ptr %t1
  call void @fn_emit(ptr %t26)
  call void @fn_emit(ptr @.str1188)
  %t27 = load ptr, ptr %t0
  call void @fn_emit(ptr %t27)
  call void @fn_emit(ptr @.str1189)
  store i32 0, ptr %t28
  br label %wcond3
wcond3:
  %t29 = load i32, ptr %t28
  %t30 = load ptr, ptr %t7
  %t31 = getelementptr inbounds %Str_Node, ptr %t30, i32 0, i32 7
  %t32 = load ptr, ptr %t31
  %t33 = getelementptr inbounds %LSlice, ptr %t32, i32 0, i32 1
  %t34 = load i32, ptr %t33
  %t35 = icmp slt i32 %t29, %t34
  %t36 = zext i1 %t35 to i32
  %t37 = icmp ne i32 %t36, 0
  br i1 %t37, label %wbody4, label %wend5
wbody4:
  %t38 = load ptr, ptr %t7
  %t39 = getelementptr inbounds %Str_Node, ptr %t38, i32 0, i32 7
  %t40 = load ptr, ptr %t39
  %t41 = getelementptr inbounds %LSlice, ptr %t40, i32 0, i32 0
  %t42 = load ptr, ptr %t41
  %t43 = load i32, ptr %t28
  %t44 = getelementptr inbounds ptr, ptr %t42, i32 %t43
  %t45 = load ptr, ptr %t44
  store ptr %t45, ptr %t46
  %t47 = call ptr @fn_nreg()
  store ptr %t47, ptr %t48
  call void @fn_emit(ptr @.str1190)
  %t49 = load ptr, ptr %t48
  call void @fn_emit(ptr %t49)
  call void @fn_emit(ptr @.str1191)
  %t50 = load ptr, ptr %t1
  call void @fn_emit(ptr %t50)
  call void @fn_emit(ptr @.str1192)
  %t51 = load ptr, ptr %t22
  call void @fn_emit(ptr %t51)
  call void @fn_emit(ptr @.str1193)
  %t52 = load i32, ptr %t28
  %t53 = call ptr @fn_itoa(i32 %t52)
  call void @fn_emit(ptr %t53)
  call void @fn_emit(ptr @.str1194)
  %t54 = load ptr, ptr %t46
  %t55 = getelementptr inbounds %Str_Node, ptr %t54, i32 0, i32 3
  %t56 = load ptr, ptr %t55
  %t57 = call ptr @fn_llty(ptr %t56)
  store ptr %t57, ptr %t58
  store ptr @.str1195, ptr %t59
  %t60 = load ptr, ptr %t58
  %t61 = call i32 @fn_streq(ptr %t60, ptr @.str1196)
  %t62 = icmp ne i32 %t61, 0
  br i1 %t62, label %then6, label %ifend8
then6:
  store ptr @.str1197, ptr %t59
  br label %ifend8
ifend8:
  %t63 = load ptr, ptr %t46
  %t64 = getelementptr inbounds %Str_Node, ptr %t63, i32 0, i32 4
  %t65 = load ptr, ptr %t64
  %t66 = icmp eq ptr %t65, null
  %t67 = zext i1 %t66 to i32
  %t68 = icmp eq i32 %t67, 0
  %t69 = zext i1 %t68 to i32
  %t70 = icmp ne i32 %t69, 0
  br i1 %t70, label %then9, label %ifend11
then9:
  %t71 = load ptr, ptr %t46
  %t72 = getelementptr inbounds %Str_Node, ptr %t71, i32 0, i32 4
  %t73 = load ptr, ptr %t72
  %t74 = call ptr @fn_emit_expr(ptr %t73)
  store ptr %t74, ptr %t75
  %t76 = load ptr, ptr %t75
  %t77 = getelementptr inbounds %Str_Val, ptr %t76, i32 0, i32 0
  %t78 = load ptr, ptr %t77
  store ptr %t78, ptr %t59
  br label %ifend11
ifend11:
  call void @fn_emit(ptr @.str1198)
  %t79 = load ptr, ptr %t58
  call void @fn_emit(ptr %t79)
  call void @fn_emit(ptr @.str1199)
  %t80 = load ptr, ptr %t59
  call void @fn_emit(ptr %t80)
  call void @fn_emit(ptr @.str1200)
  %t81 = load ptr, ptr %t48
  call void @fn_emit(ptr %t81)
  call void @fn_emit(ptr @.str1201)
  %t82 = load i32, ptr %t28
  %t83 = add i32 %t82, 1
  store i32 %t83, ptr %t28
  br label %wcond3
wend5:
  %t84 = load ptr, ptr %t2
  %t85 = icmp eq ptr %t84, null
  %t86 = zext i1 %t85 to i32
  %t87 = icmp eq i32 %t86, 0
  %t88 = zext i1 %t87 to i32
  %t89 = icmp ne i32 %t88, 0
  br i1 %t89, label %then12, label %ifend14
then12:
  store i32 0, ptr %t90
  br label %wcond15
wcond15:
  %t91 = load i32, ptr %t90
  %t92 = load ptr, ptr %t2
  %t93 = getelementptr inbounds %Str_Node, ptr %t92, i32 0, i32 7
  %t94 = load ptr, ptr %t93
  %t95 = getelementptr inbounds %LSlice, ptr %t94, i32 0, i32 1
  %t96 = load i32, ptr %t95
  %t97 = icmp slt i32 %t91, %t96
  %t98 = zext i1 %t97 to i32
  %t99 = icmp ne i32 %t98, 0
  br i1 %t99, label %wbody16, label %wend17
wbody16:
  %t100 = load ptr, ptr %t2
  %t101 = getelementptr inbounds %Str_Node, ptr %t100, i32 0, i32 7
  %t102 = load ptr, ptr %t101
  %t103 = getelementptr inbounds %LSlice, ptr %t102, i32 0, i32 0
  %t104 = load ptr, ptr %t103
  %t105 = load i32, ptr %t90
  %t106 = getelementptr inbounds ptr, ptr %t104, i32 %t105
  %t107 = load ptr, ptr %t106
  store ptr %t107, ptr %t108
  %t109 = load ptr, ptr %t7
  %t110 = load ptr, ptr %t108
  %t111 = getelementptr inbounds %Str_Node, ptr %t110, i32 0, i32 1
  %t112 = load ptr, ptr %t111
  %t113 = call i32 @fn_field_index(ptr %t109, ptr %t112)
  store i32 %t113, ptr %t114
  %t115 = load i32, ptr %t114
  %t116 = icmp sge i32 %t115, 0
  %t117 = zext i1 %t116 to i32
  %t118 = icmp ne i32 %t117, 0
  br i1 %t118, label %then18, label %ifend20
then18:
  %t119 = call ptr @fn_nreg()
  store ptr %t119, ptr %t120
  call void @fn_emit(ptr @.str1202)
  %t121 = load ptr, ptr %t120
  call void @fn_emit(ptr %t121)
  call void @fn_emit(ptr @.str1203)
  %t122 = load ptr, ptr %t1
  call void @fn_emit(ptr %t122)
  call void @fn_emit(ptr @.str1204)
  %t123 = load ptr, ptr %t22
  call void @fn_emit(ptr %t123)
  call void @fn_emit(ptr @.str1205)
  %t124 = load i32, ptr %t114
  %t125 = call ptr @fn_itoa(i32 %t124)
  call void @fn_emit(ptr %t125)
  call void @fn_emit(ptr @.str1206)
  %t126 = load ptr, ptr %t108
  %t127 = getelementptr inbounds %Str_Node, ptr %t126, i32 0, i32 4
  %t128 = load ptr, ptr %t127
  %t129 = call ptr @fn_emit_expr(ptr %t128)
  store ptr %t129, ptr %t130
  call void @fn_emit(ptr @.str1207)
  %t131 = load ptr, ptr %t7
  %t132 = load ptr, ptr %t108
  %t133 = getelementptr inbounds %Str_Node, ptr %t132, i32 0, i32 1
  %t134 = load ptr, ptr %t133
  %t135 = call ptr @fn_field_type(ptr %t131, ptr %t134)
  %t136 = call ptr @fn_llty(ptr %t135)
  call void @fn_emit(ptr %t136)
  call void @fn_emit(ptr @.str1208)
  %t137 = load ptr, ptr %t130
  %t138 = getelementptr inbounds %Str_Val, ptr %t137, i32 0, i32 0
  %t139 = load ptr, ptr %t138
  call void @fn_emit(ptr %t139)
  call void @fn_emit(ptr @.str1209)
  %t140 = load ptr, ptr %t120
  call void @fn_emit(ptr %t140)
  call void @fn_emit(ptr @.str1210)
  br label %ifend20
ifend20:
  %t141 = load i32, ptr %t90
  %t142 = add i32 %t141, 1
  store i32 %t142, ptr %t90
  br label %wcond15
wend17:
  br label %ifend14
ifend14:
  br label %ret
ret:
  ret void
}

define void @fn_emit_spawn(ptr %arg_st) {
entry:
  %t0 = alloca ptr
  %t2 = alloca ptr
  %t7 = alloca i32
  %t13 = alloca ptr
  %t15 = alloca ptr
  %t26 = alloca ptr
  %t27 = alloca i32
  %t47 = alloca ptr
  %t48 = alloca ptr
  %t49 = alloca i32
  %t89 = alloca i32
  store ptr %arg_st, ptr %t0
  %t1 = call ptr @fn_emit_bind(ptr @.str1211)
  store ptr %t1, ptr %t2
  %t3 = load ptr, ptr %t0
  %t4 = getelementptr inbounds %Str_Node, ptr %t3, i32 0, i32 1
  %t5 = load ptr, ptr %t4
  %t6 = call i32 @fn_find_arch_id(ptr %t5)
  store i32 %t6, ptr %t7
  %t8 = load i32, ptr %t7
  %t9 = icmp sgt i32 %t8, 0
  %t10 = zext i1 %t9 to i32
  %t11 = icmp ne i32 %t10, 0
  br i1 %t11, label %then0, label %else1
then0:
  %t12 = call ptr @fn_itoa(i32 1024)
  store ptr %t12, ptr %t13
  %t14 = call ptr @fn_nreg()
  store ptr %t14, ptr %t15
  call void @fn_emit(ptr @.str1212)
  %t16 = load ptr, ptr %t15
  call void @fn_emit(ptr %t16)
  call void @fn_emit(ptr @.str1213)
  %t17 = load ptr, ptr %t13
  call void @fn_emit(ptr %t17)
  call void @fn_emit(ptr @.str1214)
  %t18 = load ptr, ptr %t2
  call void @fn_emit(ptr %t18)
  call void @fn_emit(ptr @.str1215)
  call void @fn_emit(ptr @.str1216)
  %t19 = load i32, ptr %t7
  %t20 = call ptr @fn_itoa(i32 %t19)
  call void @fn_emit(ptr %t20)
  call void @fn_emit(ptr @.str1217)
  %t21 = load ptr, ptr %t15
  call void @fn_emit(ptr %t21)
  call void @fn_emit(ptr @.str1218)
  %t22 = load ptr, ptr %t0
  %t23 = getelementptr inbounds %Str_Node, ptr %t22, i32 0, i32 1
  %t24 = load ptr, ptr %t23
  %t25 = call ptr @fn_find_arch(ptr %t24)
  store ptr %t25, ptr %t26
  store i32 0, ptr %t27
  br label %wcond3
wcond3:
  %t28 = load i32, ptr %t27
  %t29 = load ptr, ptr %t26
  %t30 = getelementptr inbounds %Str_Node, ptr %t29, i32 0, i32 7
  %t31 = load ptr, ptr %t30
  %t32 = getelementptr inbounds %LSlice, ptr %t31, i32 0, i32 1
  %t33 = load i32, ptr %t32
  %t34 = icmp slt i32 %t28, %t33
  %t35 = zext i1 %t34 to i32
  %t36 = icmp ne i32 %t35, 0
  br i1 %t36, label %wbody4, label %wend5
wbody4:
  %t37 = load ptr, ptr %t26
  %t38 = getelementptr inbounds %Str_Node, ptr %t37, i32 0, i32 7
  %t39 = load ptr, ptr %t38
  %t40 = getelementptr inbounds %LSlice, ptr %t39, i32 0, i32 0
  %t41 = load ptr, ptr %t40
  %t42 = load i32, ptr %t27
  %t43 = getelementptr inbounds ptr, ptr %t41, i32 %t42
  %t44 = load ptr, ptr %t43
  %t45 = getelementptr inbounds %Str_Node, ptr %t44, i32 0, i32 1
  %t46 = load ptr, ptr %t45
  store ptr %t46, ptr %t47
  store ptr null, ptr %t48
  store i32 0, ptr %t49
  br label %wcond6
wcond6:
  %t50 = load i32, ptr %t49
  %t51 = load ptr, ptr %t0
  %t52 = getelementptr inbounds %Str_Node, ptr %t51, i32 0, i32 7
  %t53 = load ptr, ptr %t52
  %t54 = getelementptr inbounds %LSlice, ptr %t53, i32 0, i32 1
  %t55 = load i32, ptr %t54
  %t56 = icmp slt i32 %t50, %t55
  %t57 = zext i1 %t56 to i32
  %t58 = icmp ne i32 %t57, 0
  br i1 %t58, label %wbody7, label %wend8
wbody7:
  %t59 = load ptr, ptr %t0
  %t60 = getelementptr inbounds %Str_Node, ptr %t59, i32 0, i32 7
  %t61 = load ptr, ptr %t60
  %t62 = getelementptr inbounds %LSlice, ptr %t61, i32 0, i32 0
  %t63 = load ptr, ptr %t62
  %t64 = load i32, ptr %t49
  %t65 = getelementptr inbounds ptr, ptr %t63, i32 %t64
  %t66 = load ptr, ptr %t65
  %t67 = getelementptr inbounds %Str_Node, ptr %t66, i32 0, i32 1
  %t68 = load ptr, ptr %t67
  %t69 = load ptr, ptr %t47
  %t70 = call i32 @fn_streq(ptr %t68, ptr %t69)
  %t71 = icmp ne i32 %t70, 0
  br i1 %t71, label %then9, label %ifend11
then9:
  %t72 = load ptr, ptr %t0
  %t73 = getelementptr inbounds %Str_Node, ptr %t72, i32 0, i32 7
  %t74 = load ptr, ptr %t73
  %t75 = getelementptr inbounds %LSlice, ptr %t74, i32 0, i32 0
  %t76 = load ptr, ptr %t75
  %t77 = load i32, ptr %t49
  %t78 = getelementptr inbounds ptr, ptr %t76, i32 %t77
  %t79 = load ptr, ptr %t78
  %t80 = getelementptr inbounds %Str_Node, ptr %t79, i32 0, i32 4
  %t81 = load ptr, ptr %t80
  store ptr %t81, ptr %t48
  br label %ifend11
ifend11:
  %t82 = load i32, ptr %t49
  %t83 = add i32 %t82, 1
  store i32 %t83, ptr %t49
  br label %wcond6
wend8:
  %t84 = load ptr, ptr %t2
  %t85 = load ptr, ptr %t47
  %t86 = load ptr, ptr %t48
  call void @fn_emit_init_component(ptr %t84, ptr %t85, ptr %t86)
  %t87 = load i32, ptr %t27
  %t88 = add i32 %t87, 1
  store i32 %t88, ptr %t27
  br label %wcond3
wend5:
  br label %ifend2
else1:
  store i32 0, ptr %t89
  br label %wcond12
wcond12:
  %t90 = load i32, ptr %t89
  %t91 = load ptr, ptr %t0
  %t92 = getelementptr inbounds %Str_Node, ptr %t91, i32 0, i32 7
  %t93 = load ptr, ptr %t92
  %t94 = getelementptr inbounds %LSlice, ptr %t93, i32 0, i32 1
  %t95 = load i32, ptr %t94
  %t96 = icmp slt i32 %t90, %t95
  %t97 = zext i1 %t96 to i32
  %t98 = icmp ne i32 %t97, 0
  br i1 %t98, label %wbody13, label %wend14
wbody13:
  %t99 = load ptr, ptr %t2
  %t100 = load ptr, ptr %t0
  %t101 = getelementptr inbounds %Str_Node, ptr %t100, i32 0, i32 7
  %t102 = load ptr, ptr %t101
  %t103 = getelementptr inbounds %LSlice, ptr %t102, i32 0, i32 0
  %t104 = load ptr, ptr %t103
  %t105 = load i32, ptr %t89
  %t106 = getelementptr inbounds ptr, ptr %t104, i32 %t105
  %t107 = load ptr, ptr %t106
  %t108 = getelementptr inbounds %Str_Node, ptr %t107, i32 0, i32 1
  %t109 = load ptr, ptr %t108
  %t110 = load ptr, ptr %t0
  %t111 = getelementptr inbounds %Str_Node, ptr %t110, i32 0, i32 7
  %t112 = load ptr, ptr %t111
  %t113 = getelementptr inbounds %LSlice, ptr %t112, i32 0, i32 0
  %t114 = load ptr, ptr %t113
  %t115 = load i32, ptr %t89
  %t116 = getelementptr inbounds ptr, ptr %t114, i32 %t115
  %t117 = load ptr, ptr %t116
  %t118 = getelementptr inbounds %Str_Node, ptr %t117, i32 0, i32 4
  %t119 = load ptr, ptr %t118
  call void @fn_emit_init_component(ptr %t99, ptr %t109, ptr %t119)
  %t120 = load i32, ptr %t89
  %t121 = add i32 %t120, 1
  store i32 %t121, ptr %t89
  br label %wcond12
wend14:
  br label %ifend2
ifend2:
  br label %ret
ret:
  ret void
}

define void @fn_emit_despawn(ptr %arg_st) {
entry:
  %t0 = alloca ptr
  %t5 = alloca ptr
  store ptr %arg_st, ptr %t0
  %t1 = load ptr, ptr %t0
  %t2 = getelementptr inbounds %Str_Node, ptr %t1, i32 0, i32 4
  %t3 = load ptr, ptr %t2
  %t4 = call ptr @fn_emit_expr(ptr %t3)
  store ptr %t4, ptr %t5
  call void @fn_emit(ptr @.str1219)
  %t6 = load ptr, ptr %t5
  %t7 = getelementptr inbounds %Str_Val, ptr %t6, i32 0, i32 0
  %t8 = load ptr, ptr %t7
  call void @fn_emit(ptr %t8)
  call void @fn_emit(ptr @.str1220)
  br label %ret
ret:
  ret void
}

define void @fn_emit_system_fn(ptr %arg_sys) {
entry:
  %t0 = alloca ptr
  %t2 = alloca ptr
  %t5 = alloca ptr
  store ptr %arg_sys, ptr %t0
  store i32 0, ptr @g_ll_t
  store i32 0, ptr @g_ll_lbl
  store i32 0, ptr @g_g_term
  call void @fn_loc_reset()
  store i32 0, ptr @g_nloop
  store i32 0, ptr @g_nself
  store ptr @.str1221, ptr @g_ret_ty
  %t1 = call ptr @fn_buf_new()
  store ptr %t1, ptr %t2
  %t3 = call ptr @fn_buf_new()
  store ptr %t3, ptr @g_falloc
  %t4 = load ptr, ptr @g_code
  store ptr %t4, ptr %t5
  %t6 = load ptr, ptr %t2
  store ptr %t6, ptr @g_code
  %t7 = load ptr, ptr %t0
  %t8 = getelementptr inbounds %Str_Node, ptr %t7, i32 0, i32 4
  %t9 = load ptr, ptr %t8
  call void @fn_emit_block(ptr %t9)
  %t10 = load i32, ptr @g_g_term
  %t11 = icmp eq i32 %t10, 0
  %t12 = zext i1 %t11 to i32
  %t13 = icmp ne i32 %t12, 0
  br i1 %t13, label %then0, label %ifend2
then0:
  call void @fn_emit(ptr @.str1222)
  br label %ifend2
ifend2:
  call void @fn_emit(ptr @.str1223)
  %t14 = load ptr, ptr %t5
  store ptr %t14, ptr @g_code
  call void @fn_emit(ptr @.str1224)
  %t15 = load ptr, ptr %t0
  %t16 = getelementptr inbounds %Str_Node, ptr %t15, i32 0, i32 1
  %t17 = load ptr, ptr %t16
  call void @fn_emit(ptr %t17)
  call void @fn_emit(ptr @.str1225)
  %t18 = load ptr, ptr @g_falloc
  %t19 = call ptr @fn_buf_str(ptr %t18)
  call void @fn_emit(ptr %t19)
  %t20 = load ptr, ptr %t2
  %t21 = call ptr @fn_buf_str(ptr %t20)
  call void @fn_emit(ptr %t21)
  call void @fn_emit(ptr @.str1226)
  br label %ret
ret:
  ret void
}

define void @fn_emit_calls_for_phase(ptr %arg_phase) {
entry:
  %t0 = alloca ptr
  %t1 = alloca i32
  %t15 = alloca ptr
  %t16 = alloca i32
  store ptr %arg_phase, ptr %t0
  store i32 0, ptr %t1
  br label %wcond0
wcond0:
  %t2 = load i32, ptr %t1
  %t3 = load ptr, ptr @g_prog
  %t4 = getelementptr inbounds %LSlice, ptr %t3, i32 0, i32 1
  %t5 = load i32, ptr %t4
  %t6 = icmp slt i32 %t2, %t5
  %t7 = zext i1 %t6 to i32
  %t8 = icmp ne i32 %t7, 0
  br i1 %t8, label %wbody1, label %wend2
wbody1:
  %t9 = load ptr, ptr @g_prog
  %t10 = getelementptr inbounds %LSlice, ptr %t9, i32 0, i32 0
  %t11 = load ptr, ptr %t10
  %t12 = load i32, ptr %t1
  %t13 = getelementptr inbounds ptr, ptr %t11, i32 %t12
  %t14 = load ptr, ptr %t13
  store ptr %t14, ptr %t15
  %t17 = load ptr, ptr %t15
  %t18 = getelementptr inbounds %Str_Node, ptr %t17, i32 0, i32 0
  %t19 = load i32, ptr %t18
  %t20 = icmp eq i32 %t19, 9
  %t21 = zext i1 %t20 to i32
  %t22 = icmp ne i32 %t21, 0
  %t23 = zext i1 %t22 to i32
  store i32 %t23, ptr %t16
  br i1 %t22, label %sc3, label %scend4
sc3:
  %t24 = load ptr, ptr %t15
  %t25 = getelementptr inbounds %Str_Node, ptr %t24, i32 0, i32 3
  %t26 = load ptr, ptr %t25
  %t27 = load ptr, ptr %t0
  %t28 = call i32 @fn_streq(ptr %t26, ptr %t27)
  %t29 = icmp ne i32 %t28, 0
  %t30 = zext i1 %t29 to i32
  store i32 %t30, ptr %t16
  br label %scend4
scend4:
  %t31 = load i32, ptr %t16
  %t32 = icmp ne i32 %t31, 0
  br i1 %t32, label %then5, label %ifend7
then5:
  call void @fn_emit(ptr @.str1227)
  %t33 = load ptr, ptr %t15
  %t34 = getelementptr inbounds %Str_Node, ptr %t33, i32 0, i32 1
  %t35 = load ptr, ptr %t34
  call void @fn_emit(ptr %t35)
  call void @fn_emit(ptr @.str1228)
  br label %ifend7
ifend7:
  %t36 = load i32, ptr %t1
  %t37 = add i32 %t36, 1
  store i32 %t37, ptr %t1
  br label %wcond0
wend2:
  br label %ret
ret:
  ret void
}

define void @fn_emit_game_main() {
entry:
  %t0 = alloca i32
  %t34 = alloca ptr
  %t39 = alloca ptr
  %t47 = alloca ptr
  %t52 = alloca ptr
  %t59 = alloca ptr
  %t69 = alloca ptr
  store i32 0, ptr %t0
  br label %wcond0
wcond0:
  %t1 = load i32, ptr %t0
  %t2 = load ptr, ptr @g_prog
  %t3 = getelementptr inbounds %LSlice, ptr %t2, i32 0, i32 1
  %t4 = load i32, ptr %t3
  %t5 = icmp slt i32 %t1, %t4
  %t6 = zext i1 %t5 to i32
  %t7 = icmp ne i32 %t6, 0
  br i1 %t7, label %wbody1, label %wend2
wbody1:
  %t8 = load ptr, ptr @g_prog
  %t9 = getelementptr inbounds %LSlice, ptr %t8, i32 0, i32 0
  %t10 = load ptr, ptr %t9
  %t11 = load i32, ptr %t0
  %t12 = getelementptr inbounds ptr, ptr %t10, i32 %t11
  %t13 = load ptr, ptr %t12
  %t14 = getelementptr inbounds %Str_Node, ptr %t13, i32 0, i32 0
  %t15 = load i32, ptr %t14
  %t16 = icmp eq i32 %t15, 9
  %t17 = zext i1 %t16 to i32
  %t18 = icmp ne i32 %t17, 0
  br i1 %t18, label %then3, label %ifend5
then3:
  %t19 = load ptr, ptr @g_prog
  %t20 = getelementptr inbounds %LSlice, ptr %t19, i32 0, i32 0
  %t21 = load ptr, ptr %t20
  %t22 = load i32, ptr %t0
  %t23 = getelementptr inbounds ptr, ptr %t21, i32 %t22
  %t24 = load ptr, ptr %t23
  call void @fn_emit_system_fn(ptr %t24)
  br label %ifend5
ifend5:
  %t25 = load i32, ptr %t0
  %t26 = add i32 %t25, 1
  store i32 %t26, ptr %t0
  br label %wcond0
wend2:
  call void @fn_emit(ptr @.str1229)
  call void @fn_emit(ptr @.str1230)
  call void @fn_emit(ptr @.str1231)
  %t27 = call ptr @fn_find_fn(ptr @.str1232)
  %t28 = icmp eq ptr %t27, null
  %t29 = zext i1 %t28 to i32
  %t30 = icmp eq i32 %t29, 0
  %t31 = zext i1 %t30 to i32
  %t32 = icmp ne i32 %t31, 0
  br i1 %t32, label %then6, label %ifend8
then6:
  call void @fn_emit(ptr @.str1233)
  br label %ifend8
ifend8:
  call void @fn_emit_calls_for_phase(ptr @.str1234)
  call void @fn_emit(ptr @.str1235)
  call void @fn_emit(ptr @.str1236)
  %t33 = call ptr @fn_emit_bind(ptr @.str1237)
  store ptr %t33, ptr %t34
  %t35 = load ptr, ptr %t34
  %t36 = call ptr @fn_sconcat(ptr %t35, ptr @.str1239)
  %t37 = call ptr @fn_sconcat(ptr @.str1238, ptr %t36)
  %t38 = call ptr @fn_emit_bind(ptr %t37)
  store ptr %t38, ptr %t39
  %t40 = call ptr @fn_find_fn(ptr @.str1240)
  %t41 = icmp eq ptr %t40, null
  %t42 = zext i1 %t41 to i32
  %t43 = icmp eq i32 %t42, 0
  %t44 = zext i1 %t43 to i32
  %t45 = icmp ne i32 %t44, 0
  br i1 %t45, label %then9, label %else10
then9:
  %t46 = call ptr @fn_emit_bind(ptr @.str1241)
  store ptr %t46, ptr %t47
  %t48 = load ptr, ptr %t47
  %t49 = call ptr @fn_sconcat(ptr %t48, ptr @.str1243)
  %t50 = call ptr @fn_sconcat(ptr @.str1242, ptr %t49)
  %t51 = call ptr @fn_emit_bind(ptr %t50)
  store ptr %t51, ptr %t52
  %t53 = load ptr, ptr %t39
  %t54 = load ptr, ptr %t52
  %t55 = call ptr @fn_sconcat(ptr @.str1245, ptr %t54)
  %t56 = call ptr @fn_sconcat(ptr %t53, ptr %t55)
  %t57 = call ptr @fn_sconcat(ptr @.str1244, ptr %t56)
  %t58 = call ptr @fn_emit_bind(ptr %t57)
  store ptr %t58, ptr %t59
  call void @fn_emit(ptr @.str1246)
  %t60 = load ptr, ptr %t59
  call void @fn_emit(ptr %t60)
  call void @fn_emit(ptr @.str1247)
  br label %ifend11
else10:
  call void @fn_emit(ptr @.str1248)
  %t61 = load ptr, ptr %t39
  call void @fn_emit(ptr %t61)
  call void @fn_emit(ptr @.str1249)
  br label %ifend11
ifend11:
  call void @fn_emit(ptr @.str1250)
  %t62 = call ptr @fn_find_fn(ptr @.str1251)
  %t63 = icmp eq ptr %t62, null
  %t64 = zext i1 %t63 to i32
  %t65 = icmp eq i32 %t64, 0
  %t66 = zext i1 %t65 to i32
  %t67 = icmp ne i32 %t66, 0
  br i1 %t67, label %then12, label %ifend14
then12:
  %t68 = call ptr @fn_emit_bind(ptr @.str1252)
  store ptr %t68, ptr %t69
  call void @fn_emit(ptr @.str1253)
  %t70 = load ptr, ptr %t69
  call void @fn_emit(ptr %t70)
  call void @fn_emit(ptr @.str1254)
  br label %ifend14
ifend14:
  call void @fn_emit_calls_for_phase(ptr @.str1255)
  call void @fn_emit_calls_for_phase(ptr @.str1256)
  call void @fn_emit_calls_for_phase(ptr @.str1257)
  call void @fn_emit_calls_for_phase(ptr @.str1258)
  call void @fn_emit_calls_for_phase(ptr @.str1259)
  call void @fn_emit(ptr @.str1260)
  call void @fn_emit(ptr @.str1261)
  %t71 = call ptr @fn_find_fn(ptr @.str1262)
  %t72 = icmp eq ptr %t71, null
  %t73 = zext i1 %t72 to i32
  %t74 = icmp eq i32 %t73, 0
  %t75 = zext i1 %t74 to i32
  %t76 = icmp ne i32 %t75, 0
  br i1 %t76, label %then15, label %ifend17
then15:
  call void @fn_emit(ptr @.str1263)
  br label %ifend17
ifend17:
  call void @fn_emit(ptr @.str1264)
  br label %ret
ret:
  ret void
}

define void @fn_emit_machine(ptr %arg_st) {
entry:
  %t0 = alloca ptr
  %t5 = alloca ptr
  %t12 = alloca ptr
  %t49 = alloca ptr
  %t50 = alloca i32
  %t68 = alloca ptr
  %t73 = alloca ptr
  %t82 = alloca ptr
  %t84 = alloca ptr
  %t86 = alloca ptr
  store ptr %arg_st, ptr %t0
  %t1 = load ptr, ptr %t0
  %t2 = getelementptr inbounds %Str_Node, ptr %t1, i32 0, i32 4
  %t3 = load ptr, ptr %t2
  %t4 = call ptr @fn_emit_expr(ptr %t3)
  store ptr %t4, ptr %t5
  %t6 = load ptr, ptr %t5
  %t7 = getelementptr inbounds %Str_Val, ptr %t6, i32 0, i32 0
  %t8 = load ptr, ptr %t7
  %t9 = call ptr @fn_sconcat(ptr %t8, ptr @.str1266)
  %t10 = call ptr @fn_sconcat(ptr @.str1265, ptr %t9)
  %t11 = call ptr @fn_emit_bind(ptr %t10)
  store ptr %t11, ptr %t12
  %t13 = load i32, ptr @g_nmach
  %t14 = load ptr, ptr @g_mach_stk
  %t15 = getelementptr inbounds %LSlice, ptr %t14, i32 0, i32 1
  %t16 = load i32, ptr %t15
  %t17 = icmp slt i32 %t13, %t16
  %t18 = zext i1 %t17 to i32
  %t19 = icmp ne i32 %t18, 0
  br i1 %t19, label %then0, label %else1
then0:
  %t20 = load ptr, ptr @g_mach_stk
  %t21 = getelementptr inbounds %LSlice, ptr %t20, i32 0, i32 0
  %t22 = load ptr, ptr %t21
  %t23 = load i32, ptr @g_nmach
  %t24 = getelementptr inbounds ptr, ptr %t22, i32 %t23
  %t25 = load ptr, ptr %t0
  store ptr %t25, ptr %t24
  br label %ifend2
else1:
  %t26 = load ptr, ptr @g_mach_stk
  %t27 = getelementptr inbounds %LSlice, ptr %t26, i32 0, i32 1
  %t28 = getelementptr inbounds %LSlice, ptr %t26, i32 0, i32 2
  %t29 = getelementptr inbounds %LSlice, ptr %t26, i32 0, i32 0
  %t30 = load i32, ptr %t27
  %t31 = load i32, ptr %t28
  %t32 = icmp sge i32 %t30, %t31
  br i1 %t32, label %grow3, label %put4
grow3:
  %t33 = mul i32 %t31, 2
  %t34 = icmp eq i32 %t31, 0
  %t35 = select i1 %t34, i32 8, i32 %t33
  %t36 = getelementptr ptr, ptr null, i32 1
  %t37 = ptrtoint ptr %t36 to i64
  %t38 = zext i32 %t35 to i64
  %t39 = mul i64 %t38, %t37
  %t40 = load ptr, ptr %t29
  %t41 = call ptr @realloc(ptr %t40, i64 %t39)
  store ptr %t41, ptr %t29
  store i32 %t35, ptr %t28
  br label %put4
put4:
  %t42 = load ptr, ptr %t0
  %t43 = load ptr, ptr %t29
  %t44 = getelementptr inbounds ptr, ptr %t43, i32 %t30
  store ptr %t42, ptr %t44
  %t45 = add i32 %t30, 1
  store i32 %t45, ptr %t27
  br label %ifend2
ifend2:
  %t46 = load i32, ptr @g_nmach
  %t47 = add i32 %t46, 1
  store i32 %t47, ptr @g_nmach
  %t48 = call ptr @fn_lbl(ptr @.str1267)
  store ptr %t48, ptr %t49
  store i32 0, ptr %t50
  br label %wcond5
wcond5:
  %t51 = load i32, ptr %t50
  %t52 = load ptr, ptr %t0
  %t53 = getelementptr inbounds %Str_Node, ptr %t52, i32 0, i32 7
  %t54 = load ptr, ptr %t53
  %t55 = getelementptr inbounds %LSlice, ptr %t54, i32 0, i32 1
  %t56 = load i32, ptr %t55
  %t57 = icmp slt i32 %t51, %t56
  %t58 = zext i1 %t57 to i32
  %t59 = icmp ne i32 %t58, 0
  br i1 %t59, label %wbody6, label %wend7
wbody6:
  %t60 = load ptr, ptr %t0
  %t61 = getelementptr inbounds %Str_Node, ptr %t60, i32 0, i32 7
  %t62 = load ptr, ptr %t61
  %t63 = getelementptr inbounds %LSlice, ptr %t62, i32 0, i32 0
  %t64 = load ptr, ptr %t63
  %t65 = load i32, ptr %t50
  %t66 = getelementptr inbounds ptr, ptr %t64, i32 %t65
  %t67 = load ptr, ptr %t66
  store ptr %t67, ptr %t68
  %t69 = load ptr, ptr %t68
  %t70 = getelementptr inbounds %Str_Node, ptr %t69, i32 0, i32 5
  %t71 = load ptr, ptr %t70
  %t72 = call ptr @fn_emit_expr(ptr %t71)
  store ptr %t72, ptr %t73
  %t74 = load ptr, ptr %t12
  %t75 = load ptr, ptr %t73
  %t76 = getelementptr inbounds %Str_Val, ptr %t75, i32 0, i32 0
  %t77 = load ptr, ptr %t76
  %t78 = call ptr @fn_sconcat(ptr @.str1269, ptr %t77)
  %t79 = call ptr @fn_sconcat(ptr %t74, ptr %t78)
  %t80 = call ptr @fn_sconcat(ptr @.str1268, ptr %t79)
  %t81 = call ptr @fn_emit_bind(ptr %t80)
  store ptr %t81, ptr %t82
  %t83 = call ptr @fn_lbl(ptr @.str1270)
  store ptr %t83, ptr %t84
  %t85 = call ptr @fn_lbl(ptr @.str1271)
  store ptr %t85, ptr %t86
  call void @fn_emit(ptr @.str1272)
  %t87 = load ptr, ptr %t82
  call void @fn_emit(ptr %t87)
  call void @fn_emit(ptr @.str1273)
  %t88 = load ptr, ptr %t84
  call void @fn_emit(ptr %t88)
  call void @fn_emit(ptr @.str1274)
  %t89 = load ptr, ptr %t86
  call void @fn_emit(ptr %t89)
  call void @fn_emit(ptr @.str1275)
  %t90 = load ptr, ptr %t84
  call void @fn_emit(ptr %t90)
  call void @fn_emit(ptr @.str1276)
  store i32 0, ptr @g_g_term
  %t91 = load ptr, ptr %t68
  %t92 = getelementptr inbounds %Str_Node, ptr %t91, i32 0, i32 4
  %t93 = load ptr, ptr %t92
  call void @fn_emit_block(ptr %t93)
  %t94 = load i32, ptr @g_g_term
  %t95 = icmp eq i32 %t94, 0
  %t96 = zext i1 %t95 to i32
  %t97 = icmp ne i32 %t96, 0
  br i1 %t97, label %then8, label %ifend10
then8:
  call void @fn_emit(ptr @.str1277)
  %t98 = load ptr, ptr %t49
  call void @fn_emit(ptr %t98)
  call void @fn_emit(ptr @.str1278)
  br label %ifend10
ifend10:
  %t99 = load ptr, ptr %t86
  call void @fn_emit(ptr %t99)
  call void @fn_emit(ptr @.str1279)
  store i32 0, ptr @g_g_term
  %t100 = load i32, ptr %t50
  %t101 = add i32 %t100, 1
  store i32 %t101, ptr %t50
  br label %wcond5
wend7:
  %t102 = load i32, ptr @g_g_term
  %t103 = icmp eq i32 %t102, 0
  %t104 = zext i1 %t103 to i32
  %t105 = icmp ne i32 %t104, 0
  br i1 %t105, label %then11, label %ifend13
then11:
  call void @fn_emit(ptr @.str1280)
  %t106 = load ptr, ptr %t49
  call void @fn_emit(ptr %t106)
  call void @fn_emit(ptr @.str1281)
  br label %ifend13
ifend13:
  %t107 = load ptr, ptr %t49
  call void @fn_emit(ptr %t107)
  call void @fn_emit(ptr @.str1282)
  store i32 0, ptr @g_g_term
  %t108 = load i32, ptr @g_nmach
  %t109 = sub i32 %t108, 1
  store i32 %t109, ptr @g_nmach
  br label %ret
ret:
  ret void
}

define void @fn_emit_become(ptr %arg_st) {
entry:
  %t0 = alloca ptr
  %t12 = alloca ptr
  %t13 = alloca ptr
  %t14 = alloca i32
  %t61 = alloca ptr
  %t66 = alloca ptr
  store ptr %arg_st, ptr %t0
  %t1 = load i32, ptr @g_nmach
  %t2 = icmp eq i32 %t1, 0
  %t3 = zext i1 %t2 to i32
  %t4 = icmp ne i32 %t3, 0
  br i1 %t4, label %then0, label %ifend2
then0:
  call void @fn_perr(ptr @.str1283)
  br label %ifend2
ifend2:
  %t5 = load ptr, ptr @g_mach_stk
  %t6 = getelementptr inbounds %LSlice, ptr %t5, i32 0, i32 0
  %t7 = load ptr, ptr %t6
  %t8 = load i32, ptr @g_nmach
  %t9 = sub i32 %t8, 1
  %t10 = getelementptr inbounds ptr, ptr %t7, i32 %t9
  %t11 = load ptr, ptr %t10
  store ptr %t11, ptr %t12
  store ptr null, ptr %t13
  store i32 0, ptr %t14
  br label %wcond3
wcond3:
  %t15 = load i32, ptr %t14
  %t16 = load ptr, ptr %t12
  %t17 = getelementptr inbounds %Str_Node, ptr %t16, i32 0, i32 7
  %t18 = load ptr, ptr %t17
  %t19 = getelementptr inbounds %LSlice, ptr %t18, i32 0, i32 1
  %t20 = load i32, ptr %t19
  %t21 = icmp slt i32 %t15, %t20
  %t22 = zext i1 %t21 to i32
  %t23 = icmp ne i32 %t22, 0
  br i1 %t23, label %wbody4, label %wend5
wbody4:
  %t24 = load ptr, ptr %t12
  %t25 = getelementptr inbounds %Str_Node, ptr %t24, i32 0, i32 7
  %t26 = load ptr, ptr %t25
  %t27 = getelementptr inbounds %LSlice, ptr %t26, i32 0, i32 0
  %t28 = load ptr, ptr %t27
  %t29 = load i32, ptr %t14
  %t30 = getelementptr inbounds ptr, ptr %t28, i32 %t29
  %t31 = load ptr, ptr %t30
  %t32 = getelementptr inbounds %Str_Node, ptr %t31, i32 0, i32 1
  %t33 = load ptr, ptr %t32
  %t34 = load ptr, ptr %t0
  %t35 = getelementptr inbounds %Str_Node, ptr %t34, i32 0, i32 1
  %t36 = load ptr, ptr %t35
  %t37 = call i32 @fn_streq(ptr %t33, ptr %t36)
  %t38 = icmp ne i32 %t37, 0
  br i1 %t38, label %then6, label %ifend8
then6:
  %t39 = load ptr, ptr %t12
  %t40 = getelementptr inbounds %Str_Node, ptr %t39, i32 0, i32 7
  %t41 = load ptr, ptr %t40
  %t42 = getelementptr inbounds %LSlice, ptr %t41, i32 0, i32 0
  %t43 = load ptr, ptr %t42
  %t44 = load i32, ptr %t14
  %t45 = getelementptr inbounds ptr, ptr %t43, i32 %t44
  %t46 = load ptr, ptr %t45
  store ptr %t46, ptr %t13
  br label %ifend8
ifend8:
  %t47 = load i32, ptr %t14
  %t48 = add i32 %t47, 1
  store i32 %t48, ptr %t14
  br label %wcond3
wend5:
  %t49 = load ptr, ptr %t13
  %t50 = icmp eq ptr %t49, null
  %t51 = zext i1 %t50 to i32
  %t52 = icmp ne i32 %t51, 0
  br i1 %t52, label %then9, label %ifend11
then9:
  %t53 = load ptr, ptr %t0
  %t54 = getelementptr inbounds %Str_Node, ptr %t53, i32 0, i32 1
  %t55 = load ptr, ptr %t54
  %t56 = call ptr @fn_sconcat(ptr @.str1284, ptr %t55)
  call void @fn_perr(ptr %t56)
  br label %ifend11
ifend11:
  %t57 = load ptr, ptr %t12
  %t58 = getelementptr inbounds %Str_Node, ptr %t57, i32 0, i32 4
  %t59 = load ptr, ptr %t58
  %t60 = call ptr @fn_emit_expr(ptr %t59)
  store ptr %t60, ptr %t61
  %t62 = load ptr, ptr %t13
  %t63 = getelementptr inbounds %Str_Node, ptr %t62, i32 0, i32 5
  %t64 = load ptr, ptr %t63
  %t65 = call ptr @fn_emit_expr(ptr %t64)
  store ptr %t65, ptr %t66
  call void @fn_emit(ptr @.str1285)
  %t67 = load ptr, ptr %t61
  %t68 = getelementptr inbounds %Str_Val, ptr %t67, i32 0, i32 0
  %t69 = load ptr, ptr %t68
  call void @fn_emit(ptr %t69)
  call void @fn_emit(ptr @.str1286)
  %t70 = load ptr, ptr %t66
  %t71 = getelementptr inbounds %Str_Val, ptr %t70, i32 0, i32 0
  %t72 = load ptr, ptr %t71
  call void @fn_emit(ptr %t72)
  call void @fn_emit(ptr @.str1287)
  br label %ret
ret:
  ret void
}

define void @fn_emit_io(ptr %arg_fn2, ptr %arg_p, ptr %arg_bytes) {
entry:
  %t0 = alloca ptr
  %t1 = alloca ptr
  %t2 = alloca ptr
  %t6 = alloca ptr
  store ptr %arg_fn2, ptr %t0
  store ptr %arg_p, ptr %t1
  store ptr %arg_bytes, ptr %t2
  %t3 = load i32, ptr @g_g_iok
  %t4 = call ptr @fn_itoa(i32 %t3)
  %t5 = call ptr @fn_sconcat(ptr @.str1288, ptr %t4)
  store ptr %t5, ptr %t6
  %t7 = load i32, ptr @g_g_iok
  %t8 = add i32 %t7, 1
  store i32 %t8, ptr @g_g_iok
  call void @fn_emit(ptr @.str1289)
  %t9 = load ptr, ptr %t6
  call void @fn_emit(ptr %t9)
  call void @fn_emit(ptr @.str1290)
  %t10 = load ptr, ptr %t0
  call void @fn_emit(ptr %t10)
  call void @fn_emit(ptr @.str1291)
  %t11 = load ptr, ptr %t1
  call void @fn_emit(ptr %t11)
  call void @fn_emit(ptr @.str1292)
  %t12 = load ptr, ptr %t2
  call void @fn_emit(ptr %t12)
  call void @fn_emit(ptr @.str1293)
  br label %ret
ret:
  ret void
}

define void @fn_emit_snapshot_blocks(ptr %arg_fn2) {
entry:
  %t0 = alloca ptr
  %t2 = alloca ptr
  %t9 = alloca i32
  %t40 = alloca i32
  %t67 = alloca ptr
  %t71 = alloca ptr
  store ptr %arg_fn2, ptr %t0
  store i32 0, ptr @g_g_iok
  %t1 = call ptr @fn_itoa(i32 1024)
  store ptr %t1, ptr %t2
  %t3 = load ptr, ptr %t0
  call void @fn_emit_io(ptr %t3, ptr @.str1294, ptr @.str1295)
  %t4 = load ptr, ptr %t0
  call void @fn_emit_io(ptr %t4, ptr @.str1296, ptr @.str1297)
  call void @fn_emit(ptr @.str1298)
  %t5 = load ptr, ptr %t2
  call void @fn_emit(ptr %t5)
  call void @fn_emit(ptr @.str1299)
  %t6 = load ptr, ptr %t0
  call void @fn_emit_io(ptr %t6, ptr @.str1300, ptr @.str1301)
  %t7 = load ptr, ptr %t0
  call void @fn_emit_io(ptr %t7, ptr @.str1302, ptr @.str1303)
  %t8 = load ptr, ptr %t0
  call void @fn_emit_io(ptr %t8, ptr @.str1304, ptr @.str1305)
  store i32 0, ptr %t9
  br label %wcond0
wcond0:
  %t10 = load i32, ptr %t9
  %t11 = load ptr, ptr @g_prog
  %t12 = getelementptr inbounds %LSlice, ptr %t11, i32 0, i32 1
  %t13 = load i32, ptr %t12
  %t14 = icmp slt i32 %t10, %t13
  %t15 = zext i1 %t14 to i32
  %t16 = icmp ne i32 %t15, 0
  br i1 %t16, label %wbody1, label %wend2
wbody1:
  %t17 = load ptr, ptr @g_prog
  %t18 = getelementptr inbounds %LSlice, ptr %t17, i32 0, i32 0
  %t19 = load ptr, ptr %t18
  %t20 = load i32, ptr %t9
  %t21 = getelementptr inbounds ptr, ptr %t19, i32 %t20
  %t22 = load ptr, ptr %t21
  %t23 = getelementptr inbounds %Str_Node, ptr %t22, i32 0, i32 0
  %t24 = load i32, ptr %t23
  %t25 = icmp eq i32 %t24, 2
  %t26 = zext i1 %t25 to i32
  %t27 = icmp ne i32 %t26, 0
  br i1 %t27, label %then3, label %ifend5
then3:
  %t28 = load ptr, ptr %t0
  %t29 = load ptr, ptr @g_prog
  %t30 = getelementptr inbounds %LSlice, ptr %t29, i32 0, i32 0
  %t31 = load ptr, ptr %t30
  %t32 = load i32, ptr %t9
  %t33 = getelementptr inbounds ptr, ptr %t31, i32 %t32
  %t34 = load ptr, ptr %t33
  %t35 = getelementptr inbounds %Str_Node, ptr %t34, i32 0, i32 1
  %t36 = load ptr, ptr %t35
  %t37 = call ptr @fn_sconcat(ptr @.str1306, ptr %t36)
  call void @fn_emit_io(ptr %t28, ptr %t37, ptr @.str1307)
  br label %ifend5
ifend5:
  %t38 = load i32, ptr %t9
  %t39 = add i32 %t38, 1
  store i32 %t39, ptr %t9
  br label %wcond0
wend2:
  store i32 0, ptr %t40
  store i32 0, ptr %t9
  br label %wcond6
wcond6:
  %t41 = load i32, ptr %t9
  %t42 = load ptr, ptr @g_prog
  %t43 = getelementptr inbounds %LSlice, ptr %t42, i32 0, i32 1
  %t44 = load i32, ptr %t43
  %t45 = icmp slt i32 %t41, %t44
  %t46 = zext i1 %t45 to i32
  %t47 = icmp ne i32 %t46, 0
  br i1 %t47, label %wbody7, label %wend8
wbody7:
  %t48 = load ptr, ptr @g_prog
  %t49 = getelementptr inbounds %LSlice, ptr %t48, i32 0, i32 0
  %t50 = load ptr, ptr %t49
  %t51 = load i32, ptr %t9
  %t52 = getelementptr inbounds ptr, ptr %t50, i32 %t51
  %t53 = load ptr, ptr %t52
  %t54 = getelementptr inbounds %Str_Node, ptr %t53, i32 0, i32 0
  %t55 = load i32, ptr %t54
  %t56 = icmp eq i32 %t55, 8
  %t57 = zext i1 %t56 to i32
  %t58 = icmp ne i32 %t57, 0
  br i1 %t58, label %then9, label %ifend11
then9:
  %t59 = load ptr, ptr @g_prog
  %t60 = getelementptr inbounds %LSlice, ptr %t59, i32 0, i32 0
  %t61 = load ptr, ptr %t60
  %t62 = load i32, ptr %t9
  %t63 = getelementptr inbounds ptr, ptr %t61, i32 %t62
  %t64 = load ptr, ptr %t63
  %t65 = getelementptr inbounds %Str_Node, ptr %t64, i32 0, i32 1
  %t66 = load ptr, ptr %t65
  store ptr %t66, ptr %t67
  %t68 = load i32, ptr %t40
  %t69 = call ptr @fn_itoa(i32 %t68)
  %t70 = call ptr @fn_sconcat(ptr @.str1308, ptr %t69)
  store ptr %t70, ptr %t71
  call void @fn_emit(ptr @.str1309)
  %t72 = load ptr, ptr %t71
  call void @fn_emit(ptr %t72)
  call void @fn_emit(ptr @.str1310)
  %t73 = load ptr, ptr %t67
  call void @fn_emit(ptr %t73)
  call void @fn_emit(ptr @.str1311)
  %t74 = load ptr, ptr %t2
  call void @fn_emit(ptr %t74)
  call void @fn_emit(ptr @.str1312)
  %t75 = load ptr, ptr %t0
  %t76 = load ptr, ptr %t67
  %t77 = call ptr @fn_sconcat(ptr @.str1313, ptr %t76)
  %t78 = load ptr, ptr %t71
  call void @fn_emit_io(ptr %t75, ptr %t77, ptr %t78)
  %t79 = load ptr, ptr %t0
  %t80 = load ptr, ptr %t67
  %t81 = call ptr @fn_sconcat(ptr @.str1314, ptr %t80)
  %t82 = load ptr, ptr %t2
  call void @fn_emit_io(ptr %t79, ptr %t81, ptr %t82)
  %t83 = load i32, ptr %t40
  %t84 = add i32 %t83, 1
  store i32 %t84, ptr %t40
  br label %ifend11
ifend11:
  %t85 = load i32, ptr %t9
  %t86 = add i32 %t85, 1
  store i32 %t86, ptr %t9
  br label %wcond6
wend8:
  br label %ret
ret:
  ret void
}

define void @fn_emit_snapshot() {
entry:
  %t5 = alloca i32
  %t11 = alloca i32
  call void @fn_emith(ptr @.str1315)
  call void @fn_emith(ptr @.str1316)
  call void @fn_emith(ptr @.str1317)
  %t0 = call ptr @fn_find_fn(ptr @.str1318)
  %t1 = icmp eq ptr %t0, null
  %t2 = zext i1 %t1 to i32
  %t3 = icmp eq i32 %t2, 0
  %t4 = zext i1 %t3 to i32
  store i32 %t4, ptr %t5
  %t6 = call ptr @fn_find_fn(ptr @.str1319)
  %t7 = icmp eq ptr %t6, null
  %t8 = zext i1 %t7 to i32
  %t9 = icmp eq i32 %t8, 0
  %t10 = zext i1 %t9 to i32
  store i32 %t10, ptr %t11
  call void @fn_emit(ptr @.str1320)
  call void @fn_emit(ptr @.str1321)
  call void @fn_emit(ptr @.str1322)
  call void @fn_emit(ptr @.str1323)
  call void @fn_emit_snapshot_blocks(ptr @.str1324)
  %t12 = load i32, ptr %t5
  %t13 = icmp ne i32 %t12, 0
  br i1 %t13, label %then0, label %ifend2
then0:
  call void @fn_emit(ptr @.str1325)
  br label %ifend2
ifend2:
  call void @fn_emit(ptr @.str1326)
  call void @fn_emit(ptr @.str1327)
  call void @fn_emit(ptr @.str1328)
  call void @fn_emit(ptr @.str1329)
  call void @fn_emit(ptr @.str1330)
  call void @fn_emit_snapshot_blocks(ptr @.str1331)
  %t14 = load i32, ptr %t11
  %t15 = icmp ne i32 %t14, 0
  br i1 %t15, label %then3, label %ifend5
then3:
  call void @fn_emit(ptr @.str1332)
  br label %ifend5
ifend5:
  call void @fn_emit(ptr @.str1333)
  br label %ret
ret:
  ret void
}

define i32 @fn_ui_wtype(ptr %arg_w) {
entry:
  %retval = alloca i32
  %t0 = alloca ptr
  %t4 = alloca ptr
  store ptr %arg_w, ptr %t0
  %t1 = load ptr, ptr %t0
  %t2 = getelementptr inbounds %Str_Node, ptr %t1, i32 0, i32 1
  %t3 = load ptr, ptr %t2
  store ptr %t3, ptr %t4
  %t5 = load ptr, ptr %t4
  %t6 = call i32 @fn_streq(ptr %t5, ptr @.str1334)
  %t7 = icmp ne i32 %t6, 0
  br i1 %t7, label %then0, label %ifend2
then0:
  store i32 0, ptr %retval
  br label %ret
ifend2:
  %t8 = load ptr, ptr %t4
  %t9 = call i32 @fn_streq(ptr %t8, ptr @.str1335)
  %t10 = icmp ne i32 %t9, 0
  br i1 %t10, label %then3, label %ifend5
then3:
  store i32 1, ptr %retval
  br label %ret
ifend5:
  %t11 = load ptr, ptr %t4
  %t12 = call i32 @fn_streq(ptr %t11, ptr @.str1336)
  %t13 = icmp ne i32 %t12, 0
  br i1 %t13, label %then6, label %ifend8
then6:
  store i32 2, ptr %retval
  br label %ret
ifend8:
  %t14 = load ptr, ptr %t4
  %t15 = call i32 @fn_streq(ptr %t14, ptr @.str1337)
  %t16 = icmp ne i32 %t15, 0
  br i1 %t16, label %then9, label %ifend11
then9:
  store i32 3, ptr %retval
  br label %ret
ifend11:
  %t17 = load ptr, ptr %t4
  %t18 = call i32 @fn_streq(ptr %t17, ptr @.str1338)
  %t19 = icmp ne i32 %t18, 0
  br i1 %t19, label %then12, label %ifend14
then12:
  store i32 4, ptr %retval
  br label %ret
ifend14:
  %t20 = load ptr, ptr %t4
  %t21 = call i32 @fn_streq(ptr %t20, ptr @.str1339)
  %t22 = icmp ne i32 %t21, 0
  br i1 %t22, label %then15, label %ifend17
then15:
  store i32 5, ptr %retval
  br label %ret
ifend17:
  %t23 = load ptr, ptr %t4
  %t24 = call i32 @fn_streq(ptr %t23, ptr @.str1340)
  %t25 = icmp ne i32 %t24, 0
  br i1 %t25, label %then18, label %ifend20
then18:
  store i32 6, ptr %retval
  br label %ret
ifend20:
  store i32 0, ptr %retval
  br label %ret
ret:
  %t26 = load i32, ptr %retval
  ret i32 %t26
}

define ptr @fn_ui_prop(ptr %arg_w, ptr %arg_key) {
entry:
  %retval = alloca ptr
  %t0 = alloca ptr
  %t1 = alloca ptr
  %t2 = alloca i32
  store ptr %arg_w, ptr %t0
  store ptr %arg_key, ptr %t1
  store i32 0, ptr %t2
  br label %wcond0
wcond0:
  %t3 = load i32, ptr %t2
  %t4 = load ptr, ptr %t0
  %t5 = getelementptr inbounds %Str_Node, ptr %t4, i32 0, i32 5
  %t6 = load ptr, ptr %t5
  %t7 = getelementptr inbounds %Str_Node, ptr %t6, i32 0, i32 7
  %t8 = load ptr, ptr %t7
  %t9 = getelementptr inbounds %LSlice, ptr %t8, i32 0, i32 1
  %t10 = load i32, ptr %t9
  %t11 = icmp slt i32 %t3, %t10
  %t12 = zext i1 %t11 to i32
  %t13 = icmp ne i32 %t12, 0
  br i1 %t13, label %wbody1, label %wend2
wbody1:
  %t14 = load ptr, ptr %t0
  %t15 = getelementptr inbounds %Str_Node, ptr %t14, i32 0, i32 5
  %t16 = load ptr, ptr %t15
  %t17 = getelementptr inbounds %Str_Node, ptr %t16, i32 0, i32 7
  %t18 = load ptr, ptr %t17
  %t19 = getelementptr inbounds %LSlice, ptr %t18, i32 0, i32 0
  %t20 = load ptr, ptr %t19
  %t21 = load i32, ptr %t2
  %t22 = getelementptr inbounds ptr, ptr %t20, i32 %t21
  %t23 = load ptr, ptr %t22
  %t24 = getelementptr inbounds %Str_Node, ptr %t23, i32 0, i32 1
  %t25 = load ptr, ptr %t24
  %t26 = load ptr, ptr %t1
  %t27 = call i32 @fn_streq(ptr %t25, ptr %t26)
  %t28 = icmp ne i32 %t27, 0
  br i1 %t28, label %then3, label %ifend5
then3:
  %t29 = load ptr, ptr %t0
  %t30 = getelementptr inbounds %Str_Node, ptr %t29, i32 0, i32 5
  %t31 = load ptr, ptr %t30
  %t32 = getelementptr inbounds %Str_Node, ptr %t31, i32 0, i32 7
  %t33 = load ptr, ptr %t32
  %t34 = getelementptr inbounds %LSlice, ptr %t33, i32 0, i32 0
  %t35 = load ptr, ptr %t34
  %t36 = load i32, ptr %t2
  %t37 = getelementptr inbounds ptr, ptr %t35, i32 %t36
  %t38 = load ptr, ptr %t37
  %t39 = getelementptr inbounds %Str_Node, ptr %t38, i32 0, i32 4
  %t40 = load ptr, ptr %t39
  store ptr %t40, ptr %retval
  br label %ret
ifend5:
  %t41 = load i32, ptr %t2
  %t42 = add i32 %t41, 1
  store i32 %t42, ptr %t2
  br label %wcond0
wend2:
  store ptr null, ptr %retval
  br label %ret
ret:
  %t43 = load ptr, ptr %retval
  ret ptr %t43
}

define void @fn_ui_flatten(ptr %arg_w, i32 %arg_parent) {
entry:
  %t0 = alloca ptr
  %t1 = alloca i32
  %t5 = alloca i32
  %t46 = alloca i32
  store ptr %arg_w, ptr %t0
  store i32 %arg_parent, ptr %t1
  %t2 = load ptr, ptr @g_uiw
  %t3 = getelementptr inbounds %LSlice, ptr %t2, i32 0, i32 1
  %t4 = load i32, ptr %t3
  store i32 %t4, ptr %t5
  %t6 = load ptr, ptr @g_uiw
  %t7 = getelementptr inbounds %LSlice, ptr %t6, i32 0, i32 1
  %t8 = getelementptr inbounds %LSlice, ptr %t6, i32 0, i32 2
  %t9 = getelementptr inbounds %LSlice, ptr %t6, i32 0, i32 0
  %t10 = load i32, ptr %t7
  %t11 = load i32, ptr %t8
  %t12 = icmp sge i32 %t10, %t11
  br i1 %t12, label %grow0, label %put1
grow0:
  %t13 = mul i32 %t11, 2
  %t14 = icmp eq i32 %t11, 0
  %t15 = select i1 %t14, i32 8, i32 %t13
  %t16 = getelementptr ptr, ptr null, i32 1
  %t17 = ptrtoint ptr %t16 to i64
  %t18 = zext i32 %t15 to i64
  %t19 = mul i64 %t18, %t17
  %t20 = load ptr, ptr %t9
  %t21 = call ptr @realloc(ptr %t20, i64 %t19)
  store ptr %t21, ptr %t9
  store i32 %t15, ptr %t8
  br label %put1
put1:
  %t22 = load ptr, ptr %t0
  %t23 = load ptr, ptr %t9
  %t24 = getelementptr inbounds ptr, ptr %t23, i32 %t10
  store ptr %t22, ptr %t24
  %t25 = add i32 %t10, 1
  store i32 %t25, ptr %t7
  %t26 = load ptr, ptr @g_uiw_parent
  %t27 = getelementptr inbounds %LSlice, ptr %t26, i32 0, i32 1
  %t28 = getelementptr inbounds %LSlice, ptr %t26, i32 0, i32 2
  %t29 = getelementptr inbounds %LSlice, ptr %t26, i32 0, i32 0
  %t30 = load i32, ptr %t27
  %t31 = load i32, ptr %t28
  %t32 = icmp sge i32 %t30, %t31
  br i1 %t32, label %grow2, label %put3
grow2:
  %t33 = mul i32 %t31, 2
  %t34 = icmp eq i32 %t31, 0
  %t35 = select i1 %t34, i32 8, i32 %t33
  %t36 = getelementptr i32, ptr null, i32 1
  %t37 = ptrtoint ptr %t36 to i64
  %t38 = zext i32 %t35 to i64
  %t39 = mul i64 %t38, %t37
  %t40 = load ptr, ptr %t29
  %t41 = call ptr @realloc(ptr %t40, i64 %t39)
  store ptr %t41, ptr %t29
  store i32 %t35, ptr %t28
  br label %put3
put3:
  %t42 = load i32, ptr %t1
  %t43 = load ptr, ptr %t29
  %t44 = getelementptr inbounds i32, ptr %t43, i32 %t30
  store i32 %t42, ptr %t44
  %t45 = add i32 %t30, 1
  store i32 %t45, ptr %t27
  store i32 0, ptr %t46
  br label %wcond4
wcond4:
  %t47 = load i32, ptr %t46
  %t48 = load ptr, ptr %t0
  %t49 = getelementptr inbounds %Str_Node, ptr %t48, i32 0, i32 7
  %t50 = load ptr, ptr %t49
  %t51 = getelementptr inbounds %LSlice, ptr %t50, i32 0, i32 1
  %t52 = load i32, ptr %t51
  %t53 = icmp slt i32 %t47, %t52
  %t54 = zext i1 %t53 to i32
  %t55 = icmp ne i32 %t54, 0
  br i1 %t55, label %wbody5, label %wend6
wbody5:
  %t56 = load ptr, ptr %t0
  %t57 = getelementptr inbounds %Str_Node, ptr %t56, i32 0, i32 7
  %t58 = load ptr, ptr %t57
  %t59 = getelementptr inbounds %LSlice, ptr %t58, i32 0, i32 0
  %t60 = load ptr, ptr %t59
  %t61 = load i32, ptr %t46
  %t62 = getelementptr inbounds ptr, ptr %t60, i32 %t61
  %t63 = load ptr, ptr %t62
  %t64 = load i32, ptr %t5
  call void @fn_ui_flatten(ptr %t63, i32 %t64)
  %t65 = load i32, ptr %t46
  %t66 = add i32 %t65, 1
  store i32 %t66, ptr %t46
  br label %wcond4
wend6:
  br label %ret
ret:
  ret void
}

define void @fn_ui_flatten_all() {
entry:
  %t18 = alloca i32
  %t26 = alloca i32
  %t0 = getelementptr %LSlice, ptr null, i32 1
  %t1 = ptrtoint ptr %t0 to i64
  %t2 = call ptr @malloc(i64 %t1)
  %t3 = getelementptr inbounds %LSlice, ptr %t2, i32 0, i32 0
  store ptr null, ptr %t3
  %t4 = getelementptr inbounds %LSlice, ptr %t2, i32 0, i32 1
  store i32 0, ptr %t4
  %t5 = getelementptr inbounds %LSlice, ptr %t2, i32 0, i32 2
  store i32 0, ptr %t5
  store ptr %t2, ptr @g_uiw
  %t6 = getelementptr %LSlice, ptr null, i32 1
  %t7 = ptrtoint ptr %t6 to i64
  %t8 = call ptr @malloc(i64 %t7)
  %t9 = getelementptr inbounds %LSlice, ptr %t8, i32 0, i32 0
  store ptr null, ptr %t9
  %t10 = getelementptr inbounds %LSlice, ptr %t8, i32 0, i32 1
  store i32 0, ptr %t10
  %t11 = getelementptr inbounds %LSlice, ptr %t8, i32 0, i32 2
  store i32 0, ptr %t11
  store ptr %t8, ptr @g_uiw_parent
  %t12 = getelementptr %LSlice, ptr null, i32 1
  %t13 = ptrtoint ptr %t12 to i64
  %t14 = call ptr @malloc(i64 %t13)
  %t15 = getelementptr inbounds %LSlice, ptr %t14, i32 0, i32 0
  store ptr null, ptr %t15
  %t16 = getelementptr inbounds %LSlice, ptr %t14, i32 0, i32 1
  store i32 0, ptr %t16
  %t17 = getelementptr inbounds %LSlice, ptr %t14, i32 0, i32 2
  store i32 0, ptr %t17
  store ptr %t14, ptr @g_ui_roots
  store i32 0, ptr %t18
  br label %wcond0
wcond0:
  %t19 = load i32, ptr %t18
  %t20 = load ptr, ptr @g_prog
  %t21 = getelementptr inbounds %LSlice, ptr %t20, i32 0, i32 1
  %t22 = load i32, ptr %t21
  %t23 = icmp slt i32 %t19, %t22
  %t24 = zext i1 %t23 to i32
  %t25 = icmp ne i32 %t24, 0
  br i1 %t25, label %wbody1, label %wend2
wbody1:
  %t27 = load ptr, ptr @g_prog
  %t28 = getelementptr inbounds %LSlice, ptr %t27, i32 0, i32 0
  %t29 = load ptr, ptr %t28
  %t30 = load i32, ptr %t18
  %t31 = getelementptr inbounds ptr, ptr %t29, i32 %t30
  %t32 = load ptr, ptr %t31
  %t33 = getelementptr inbounds %Str_Node, ptr %t32, i32 0, i32 0
  %t34 = load i32, ptr %t33
  %t35 = icmp eq i32 %t34, 12
  %t36 = zext i1 %t35 to i32
  %t37 = icmp ne i32 %t36, 0
  %t38 = zext i1 %t37 to i32
  store i32 %t38, ptr %t26
  br i1 %t37, label %sc3, label %scend4
sc3:
  %t39 = load ptr, ptr @g_prog
  %t40 = getelementptr inbounds %LSlice, ptr %t39, i32 0, i32 0
  %t41 = load ptr, ptr %t40
  %t42 = load i32, ptr %t18
  %t43 = getelementptr inbounds ptr, ptr %t41, i32 %t42
  %t44 = load ptr, ptr %t43
  %t45 = getelementptr inbounds %Str_Node, ptr %t44, i32 0, i32 2
  %t46 = load i32, ptr %t45
  %t47 = icmp eq i32 %t46, 1
  %t48 = zext i1 %t47 to i32
  %t49 = icmp ne i32 %t48, 0
  %t50 = zext i1 %t49 to i32
  store i32 %t50, ptr %t26
  br label %scend4
scend4:
  %t51 = load i32, ptr %t26
  %t52 = icmp ne i32 %t51, 0
  br i1 %t52, label %then5, label %ifend7
then5:
  %t53 = load ptr, ptr @g_ui_roots
  %t54 = getelementptr inbounds %LSlice, ptr %t53, i32 0, i32 1
  %t55 = getelementptr inbounds %LSlice, ptr %t53, i32 0, i32 2
  %t56 = getelementptr inbounds %LSlice, ptr %t53, i32 0, i32 0
  %t57 = load i32, ptr %t54
  %t58 = load i32, ptr %t55
  %t59 = icmp sge i32 %t57, %t58
  br i1 %t59, label %grow8, label %put9
grow8:
  %t60 = mul i32 %t58, 2
  %t61 = icmp eq i32 %t58, 0
  %t62 = select i1 %t61, i32 8, i32 %t60
  %t63 = getelementptr i32, ptr null, i32 1
  %t64 = ptrtoint ptr %t63 to i64
  %t65 = zext i32 %t62 to i64
  %t66 = mul i64 %t65, %t64
  %t67 = load ptr, ptr %t56
  %t68 = call ptr @realloc(ptr %t67, i64 %t66)
  store ptr %t68, ptr %t56
  store i32 %t62, ptr %t55
  br label %put9
put9:
  %t69 = load ptr, ptr @g_uiw
  %t70 = getelementptr inbounds %LSlice, ptr %t69, i32 0, i32 1
  %t71 = load i32, ptr %t70
  %t72 = load ptr, ptr %t56
  %t73 = getelementptr inbounds i32, ptr %t72, i32 %t57
  store i32 %t71, ptr %t73
  %t74 = add i32 %t57, 1
  store i32 %t74, ptr %t54
  %t75 = load ptr, ptr @g_prog
  %t76 = getelementptr inbounds %LSlice, ptr %t75, i32 0, i32 0
  %t77 = load ptr, ptr %t76
  %t78 = load i32, ptr %t18
  %t79 = getelementptr inbounds ptr, ptr %t77, i32 %t78
  %t80 = load ptr, ptr %t79
  %t81 = getelementptr inbounds %Str_Node, ptr %t80, i32 0, i32 4
  %t82 = load ptr, ptr %t81
  %t83 = sub i32 0, 1
  call void @fn_ui_flatten(ptr %t82, i32 %t83)
  br label %ifend7
ifend7:
  %t84 = load i32, ptr %t18
  %t85 = add i32 %t84, 1
  store i32 %t85, ptr %t18
  br label %wcond0
wend2:
  br label %ret
ret:
  ret void
}

define i32 @fn_has_ui() {
entry:
  %retval = alloca i32
  %t0 = alloca i32
  %t8 = alloca i32
  store i32 0, ptr %t0
  br label %wcond0
wcond0:
  %t1 = load i32, ptr %t0
  %t2 = load ptr, ptr @g_prog
  %t3 = getelementptr inbounds %LSlice, ptr %t2, i32 0, i32 1
  %t4 = load i32, ptr %t3
  %t5 = icmp slt i32 %t1, %t4
  %t6 = zext i1 %t5 to i32
  %t7 = icmp ne i32 %t6, 0
  br i1 %t7, label %wbody1, label %wend2
wbody1:
  %t9 = load ptr, ptr @g_prog
  %t10 = getelementptr inbounds %LSlice, ptr %t9, i32 0, i32 0
  %t11 = load ptr, ptr %t10
  %t12 = load i32, ptr %t0
  %t13 = getelementptr inbounds ptr, ptr %t11, i32 %t12
  %t14 = load ptr, ptr %t13
  %t15 = getelementptr inbounds %Str_Node, ptr %t14, i32 0, i32 0
  %t16 = load i32, ptr %t15
  %t17 = icmp eq i32 %t16, 12
  %t18 = zext i1 %t17 to i32
  %t19 = icmp ne i32 %t18, 0
  %t20 = zext i1 %t19 to i32
  store i32 %t20, ptr %t8
  br i1 %t19, label %sc3, label %scend4
sc3:
  %t21 = load ptr, ptr @g_prog
  %t22 = getelementptr inbounds %LSlice, ptr %t21, i32 0, i32 0
  %t23 = load ptr, ptr %t22
  %t24 = load i32, ptr %t0
  %t25 = getelementptr inbounds ptr, ptr %t23, i32 %t24
  %t26 = load ptr, ptr %t25
  %t27 = getelementptr inbounds %Str_Node, ptr %t26, i32 0, i32 2
  %t28 = load i32, ptr %t27
  %t29 = icmp eq i32 %t28, 1
  %t30 = zext i1 %t29 to i32
  %t31 = icmp ne i32 %t30, 0
  %t32 = zext i1 %t31 to i32
  store i32 %t32, ptr %t8
  br label %scend4
scend4:
  %t33 = load i32, ptr %t8
  %t34 = icmp ne i32 %t33, 0
  br i1 %t34, label %then5, label %ifend7
then5:
  store i32 1, ptr %retval
  br label %ret
ifend7:
  %t35 = load i32, ptr %t0
  %t36 = add i32 %t35, 1
  store i32 %t36, ptr %t0
  br label %wcond0
wend2:
  store i32 0, ptr %retval
  br label %ret
ret:
  %t37 = load i32, ptr %retval
  ret i32 %t37
}

define i32 @fn_ui_index_of(ptr %arg_nm) {
entry:
  %retval = alloca i32
  %t0 = alloca ptr
  %t6 = alloca ptr
  %t7 = alloca i32
  %t8 = alloca i32
  %t9 = alloca i32
  %t17 = alloca i32
  %t79 = alloca ptr
  %t86 = alloca i32
  store ptr %arg_nm, ptr %t0
  %t1 = load ptr, ptr %t0
  %t2 = load ptr, ptr %t0
  %t3 = call i32 @fn_slen(ptr %t2)
  %t4 = sub i32 %t3, 3
  %t5 = call ptr @fn_substr(ptr %t1, i32 3, i32 %t4)
  store ptr %t5, ptr %t6
  store i32 0, ptr %t7
  store i32 0, ptr %t8
  store i32 0, ptr %t9
  br label %wcond0
wcond0:
  %t10 = load i32, ptr %t9
  %t11 = load ptr, ptr @g_prog
  %t12 = getelementptr inbounds %LSlice, ptr %t11, i32 0, i32 1
  %t13 = load i32, ptr %t12
  %t14 = icmp slt i32 %t10, %t13
  %t15 = zext i1 %t14 to i32
  %t16 = icmp ne i32 %t15, 0
  br i1 %t16, label %wbody1, label %wend2
wbody1:
  %t18 = load ptr, ptr @g_prog
  %t19 = getelementptr inbounds %LSlice, ptr %t18, i32 0, i32 0
  %t20 = load ptr, ptr %t19
  %t21 = load i32, ptr %t9
  %t22 = getelementptr inbounds ptr, ptr %t20, i32 %t21
  %t23 = load ptr, ptr %t22
  %t24 = getelementptr inbounds %Str_Node, ptr %t23, i32 0, i32 0
  %t25 = load i32, ptr %t24
  %t26 = icmp eq i32 %t25, 12
  %t27 = zext i1 %t26 to i32
  %t28 = icmp ne i32 %t27, 0
  %t29 = zext i1 %t28 to i32
  store i32 %t29, ptr %t17
  br i1 %t28, label %sc3, label %scend4
sc3:
  %t30 = load ptr, ptr @g_prog
  %t31 = getelementptr inbounds %LSlice, ptr %t30, i32 0, i32 0
  %t32 = load ptr, ptr %t31
  %t33 = load i32, ptr %t9
  %t34 = getelementptr inbounds ptr, ptr %t32, i32 %t33
  %t35 = load ptr, ptr %t34
  %t36 = getelementptr inbounds %Str_Node, ptr %t35, i32 0, i32 2
  %t37 = load i32, ptr %t36
  %t38 = icmp eq i32 %t37, 1
  %t39 = zext i1 %t38 to i32
  %t40 = icmp ne i32 %t39, 0
  %t41 = zext i1 %t40 to i32
  store i32 %t41, ptr %t17
  br label %scend4
scend4:
  %t42 = load i32, ptr %t17
  %t43 = icmp ne i32 %t42, 0
  br i1 %t43, label %then5, label %ifend7
then5:
  %t44 = load ptr, ptr @g_prog
  %t45 = getelementptr inbounds %LSlice, ptr %t44, i32 0, i32 0
  %t46 = load ptr, ptr %t45
  %t47 = load i32, ptr %t9
  %t48 = getelementptr inbounds ptr, ptr %t46, i32 %t47
  %t49 = load ptr, ptr %t48
  %t50 = getelementptr inbounds %Str_Node, ptr %t49, i32 0, i32 1
  %t51 = load ptr, ptr %t50
  %t52 = load ptr, ptr %t6
  %t53 = call i32 @fn_streq(ptr %t51, ptr %t52)
  %t54 = icmp ne i32 %t53, 0
  br i1 %t54, label %then8, label %ifend10
then8:
  %t55 = load ptr, ptr @g_ui_roots
  %t56 = getelementptr inbounds %LSlice, ptr %t55, i32 0, i32 0
  %t57 = load ptr, ptr %t56
  %t58 = load i32, ptr %t8
  %t59 = getelementptr inbounds i32, ptr %t57, i32 %t58
  %t60 = load i32, ptr %t59
  store i32 %t60, ptr %retval
  br label %ret
ifend10:
  %t61 = load i32, ptr %t8
  %t62 = add i32 %t61, 1
  store i32 %t62, ptr %t8
  br label %ifend7
ifend7:
  %t63 = load i32, ptr %t9
  %t64 = add i32 %t63, 1
  store i32 %t64, ptr %t9
  br label %wcond0
wend2:
  store i32 0, ptr %t9
  br label %wcond11
wcond11:
  %t65 = load i32, ptr %t9
  %t66 = load ptr, ptr @g_uiw
  %t67 = getelementptr inbounds %LSlice, ptr %t66, i32 0, i32 1
  %t68 = load i32, ptr %t67
  %t69 = icmp slt i32 %t65, %t68
  %t70 = zext i1 %t69 to i32
  %t71 = icmp ne i32 %t70, 0
  br i1 %t71, label %wbody12, label %wend13
wbody12:
  %t72 = load ptr, ptr @g_uiw
  %t73 = getelementptr inbounds %LSlice, ptr %t72, i32 0, i32 0
  %t74 = load ptr, ptr %t73
  %t75 = load i32, ptr %t9
  %t76 = getelementptr inbounds ptr, ptr %t74, i32 %t75
  %t77 = load ptr, ptr %t76
  %t78 = call ptr @fn_ui_prop(ptr %t77, ptr @.str1341)
  store ptr %t78, ptr %t79
  %t80 = load ptr, ptr %t79
  %t81 = icmp eq ptr %t80, null
  %t82 = zext i1 %t81 to i32
  %t83 = icmp eq i32 %t82, 0
  %t84 = zext i1 %t83 to i32
  %t85 = icmp ne i32 %t84, 0
  br i1 %t85, label %then14, label %ifend16
then14:
  %t87 = load ptr, ptr %t79
  %t88 = getelementptr inbounds %Str_Node, ptr %t87, i32 0, i32 0
  %t89 = load i32, ptr %t88
  %t90 = icmp eq i32 %t89, 33
  %t91 = zext i1 %t90 to i32
  %t92 = icmp ne i32 %t91, 0
  %t93 = zext i1 %t92 to i32
  store i32 %t93, ptr %t86
  br i1 %t92, label %sc17, label %scend18
sc17:
  %t94 = load ptr, ptr %t79
  %t95 = getelementptr inbounds %Str_Node, ptr %t94, i32 0, i32 1
  %t96 = load ptr, ptr %t95
  %t97 = load ptr, ptr %t6
  %t98 = call i32 @fn_streq(ptr %t96, ptr %t97)
  %t99 = icmp ne i32 %t98, 0
  %t100 = zext i1 %t99 to i32
  store i32 %t100, ptr %t86
  br label %scend18
scend18:
  %t101 = load i32, ptr %t86
  %t102 = icmp ne i32 %t101, 0
  br i1 %t102, label %then19, label %ifend21
then19:
  %t103 = load i32, ptr %t9
  store i32 %t103, ptr %retval
  br label %ret
ifend21:
  br label %ifend16
ifend16:
  %t104 = load i32, ptr %t9
  %t105 = add i32 %t104, 1
  store i32 %t105, ptr %t9
  br label %wcond11
wend13:
  store i32 0, ptr %retval
  br label %ret
ret:
  %t106 = load i32, ptr %retval
  ret i32 %t106
}

define i32 @fn_is_ui_ident(ptr %arg_nm) {
entry:
  %retval = alloca i32
  %t0 = alloca ptr
  %t1 = alloca i32
  %t2 = alloca i32
  %t3 = alloca i32
  store ptr %arg_nm, ptr %t0
  %t4 = load ptr, ptr %t0
  %t5 = call i32 @fn_slen(ptr %t4)
  %t6 = icmp sgt i32 %t5, 3
  %t7 = zext i1 %t6 to i32
  %t8 = icmp ne i32 %t7, 0
  %t9 = zext i1 %t8 to i32
  store i32 %t9, ptr %t3
  br i1 %t8, label %sc0, label %scend1
sc0:
  %t10 = load ptr, ptr %t0
  %t11 = getelementptr inbounds i8, ptr %t10, i32 0
  %t12 = load i8, ptr %t11
  %t13 = zext i8 %t12 to i32
  %t14 = icmp eq i32 %t13, 85
  %t15 = zext i1 %t14 to i32
  %t16 = icmp ne i32 %t15, 0
  %t17 = zext i1 %t16 to i32
  store i32 %t17, ptr %t3
  br label %scend1
scend1:
  %t18 = load i32, ptr %t3
  %t19 = icmp ne i32 %t18, 0
  %t20 = zext i1 %t19 to i32
  store i32 %t20, ptr %t2
  br i1 %t19, label %sc2, label %scend3
sc2:
  %t21 = load ptr, ptr %t0
  %t22 = getelementptr inbounds i8, ptr %t21, i32 1
  %t23 = load i8, ptr %t22
  %t24 = zext i8 %t23 to i32
  %t25 = icmp eq i32 %t24, 73
  %t26 = zext i1 %t25 to i32
  %t27 = icmp ne i32 %t26, 0
  %t28 = zext i1 %t27 to i32
  store i32 %t28, ptr %t2
  br label %scend3
scend3:
  %t29 = load i32, ptr %t2
  %t30 = icmp ne i32 %t29, 0
  %t31 = zext i1 %t30 to i32
  store i32 %t31, ptr %t1
  br i1 %t30, label %sc4, label %scend5
sc4:
  %t32 = load ptr, ptr %t0
  %t33 = getelementptr inbounds i8, ptr %t32, i32 2
  %t34 = load i8, ptr %t33
  %t35 = zext i8 %t34 to i32
  %t36 = icmp eq i32 %t35, 95
  %t37 = zext i1 %t36 to i32
  %t38 = icmp ne i32 %t37, 0
  %t39 = zext i1 %t38 to i32
  store i32 %t39, ptr %t1
  br label %scend5
scend5:
  %t40 = load i32, ptr %t1
  store i32 %t40, ptr %retval
  br label %ret
ret:
  %t41 = load i32, ptr %retval
  ret i32 %t41
}

define void @fn_ll_ui_set(i32 %arg_idx, i32 %arg_key, ptr %arg_val) {
entry:
  %t0 = alloca i32
  %t1 = alloca i32
  %t2 = alloca ptr
  store i32 %arg_idx, ptr %t0
  store i32 %arg_key, ptr %t1
  store ptr %arg_val, ptr %t2
  call void @fn_emit(ptr @.str1342)
  %t3 = load i32, ptr %t0
  %t4 = call ptr @fn_itoa(i32 %t3)
  call void @fn_emit(ptr %t4)
  call void @fn_emit(ptr @.str1343)
  %t5 = load i32, ptr %t1
  %t6 = call ptr @fn_itoa(i32 %t5)
  call void @fn_emit(ptr %t6)
  call void @fn_emit(ptr @.str1344)
  %t7 = load ptr, ptr %t2
  call void @fn_emit(ptr %t7)
  call void @fn_emit(ptr @.str1345)
  br label %ret
ret:
  ret void
}

define i32 @fn_ui_prop_key(ptr %arg_k) {
entry:
  %retval = alloca i32
  %t0 = alloca ptr
  store ptr %arg_k, ptr %t0
  %t1 = load ptr, ptr %t0
  %t2 = call i32 @fn_streq(ptr %t1, ptr @.str1346)
  %t3 = icmp ne i32 %t2, 0
  br i1 %t3, label %then0, label %ifend2
then0:
  store i32 2, ptr %retval
  br label %ret
ifend2:
  %t4 = load ptr, ptr %t0
  %t5 = call i32 @fn_streq(ptr %t4, ptr @.str1347)
  %t6 = icmp ne i32 %t5, 0
  br i1 %t6, label %then3, label %ifend5
then3:
  store i32 3, ptr %retval
  br label %ret
ifend5:
  %t7 = load ptr, ptr %t0
  %t8 = call i32 @fn_streq(ptr %t7, ptr @.str1348)
  %t9 = icmp ne i32 %t8, 0
  br i1 %t9, label %then6, label %ifend8
then6:
  store i32 4, ptr %retval
  br label %ret
ifend8:
  %t10 = load ptr, ptr %t0
  %t11 = call i32 @fn_streq(ptr %t10, ptr @.str1349)
  %t12 = icmp ne i32 %t11, 0
  br i1 %t12, label %then9, label %ifend11
then9:
  store i32 5, ptr %retval
  br label %ret
ifend11:
  %t13 = load ptr, ptr %t0
  %t14 = call i32 @fn_streq(ptr %t13, ptr @.str1350)
  %t15 = icmp ne i32 %t14, 0
  br i1 %t15, label %then12, label %ifend14
then12:
  store i32 7, ptr %retval
  br label %ret
ifend14:
  %t16 = load ptr, ptr %t0
  %t17 = call i32 @fn_streq(ptr %t16, ptr @.str1351)
  %t18 = icmp ne i32 %t17, 0
  br i1 %t18, label %then15, label %ifend17
then15:
  store i32 8, ptr %retval
  br label %ret
ifend17:
  %t19 = load ptr, ptr %t0
  %t20 = call i32 @fn_streq(ptr %t19, ptr @.str1352)
  %t21 = icmp ne i32 %t20, 0
  br i1 %t21, label %then18, label %ifend20
then18:
  store i32 9, ptr %retval
  br label %ret
ifend20:
  %t22 = load ptr, ptr %t0
  %t23 = call i32 @fn_streq(ptr %t22, ptr @.str1353)
  %t24 = icmp ne i32 %t23, 0
  br i1 %t24, label %then21, label %ifend23
then21:
  store i32 10, ptr %retval
  br label %ret
ifend23:
  %t25 = load ptr, ptr %t0
  %t26 = call i32 @fn_streq(ptr %t25, ptr @.str1354)
  %t27 = icmp ne i32 %t26, 0
  br i1 %t27, label %then24, label %ifend26
then24:
  store i32 11, ptr %retval
  br label %ret
ifend26:
  %t28 = load ptr, ptr %t0
  %t29 = call i32 @fn_streq(ptr %t28, ptr @.str1355)
  %t30 = icmp ne i32 %t29, 0
  br i1 %t30, label %then27, label %ifend29
then27:
  store i32 13, ptr %retval
  br label %ret
ifend29:
  %t31 = load ptr, ptr %t0
  %t32 = call i32 @fn_streq(ptr %t31, ptr @.str1356)
  %t33 = icmp ne i32 %t32, 0
  br i1 %t33, label %then30, label %ifend32
then30:
  store i32 14, ptr %retval
  br label %ret
ifend32:
  %t34 = load ptr, ptr %t0
  %t35 = call i32 @fn_streq(ptr %t34, ptr @.str1357)
  %t36 = icmp ne i32 %t35, 0
  br i1 %t36, label %then33, label %ifend35
then33:
  store i32 15, ptr %retval
  br label %ret
ifend35:
  %t37 = load ptr, ptr %t0
  %t38 = call i32 @fn_streq(ptr %t37, ptr @.str1358)
  %t39 = icmp ne i32 %t38, 0
  br i1 %t39, label %then36, label %ifend38
then36:
  store i32 16, ptr %retval
  br label %ret
ifend38:
  %t40 = load ptr, ptr %t0
  %t41 = call i32 @fn_streq(ptr %t40, ptr @.str1359)
  %t42 = icmp ne i32 %t41, 0
  br i1 %t42, label %then39, label %ifend41
then39:
  store i32 17, ptr %retval
  br label %ret
ifend41:
  %t43 = sub i32 0, 1
  store i32 %t43, ptr %retval
  br label %ret
ret:
  %t44 = load i32, ptr %retval
  ret i32 %t44
}

define void @fn_emit_ui_build() {
entry:
  %t1 = alloca ptr
  %t4 = alloca ptr
  %t10 = alloca i32
  %t24 = alloca ptr
  %t27 = alloca i32
  %t44 = alloca i32
  %t66 = alloca ptr
  %t70 = alloca ptr
  %t74 = alloca ptr
  %t85 = alloca ptr
  %t91 = alloca i32
  %t104 = alloca ptr
  %t111 = alloca ptr
  %t128 = alloca i32
  %t144 = alloca ptr
  %t151 = alloca i32
  %t158 = alloca ptr
  %t164 = alloca i32
  call void @fn_ui_flatten_all()
  store i32 0, ptr @g_ll_t
  store i32 0, ptr @g_ll_lbl
  store i32 0, ptr @g_g_term
  call void @fn_loc_reset()
  store i32 0, ptr @g_nloop
  %t0 = call ptr @fn_buf_new()
  store ptr %t0, ptr %t1
  %t2 = call ptr @fn_buf_new()
  store ptr %t2, ptr @g_falloc
  %t3 = load ptr, ptr @g_code
  store ptr %t3, ptr %t4
  %t5 = load ptr, ptr %t1
  store ptr %t5, ptr @g_code
  call void @fn_emit(ptr @.str1360)
  %t6 = load ptr, ptr @g_uiw
  %t7 = getelementptr inbounds %LSlice, ptr %t6, i32 0, i32 1
  %t8 = load i32, ptr %t7
  %t9 = call ptr @fn_itoa(i32 %t8)
  call void @fn_emit(ptr %t9)
  call void @fn_emit(ptr @.str1361)
  store i32 0, ptr %t10
  br label %wcond0
wcond0:
  %t11 = load i32, ptr %t10
  %t12 = load ptr, ptr @g_uiw
  %t13 = getelementptr inbounds %LSlice, ptr %t12, i32 0, i32 1
  %t14 = load i32, ptr %t13
  %t15 = icmp slt i32 %t11, %t14
  %t16 = zext i1 %t15 to i32
  %t17 = icmp ne i32 %t16, 0
  br i1 %t17, label %wbody1, label %wend2
wbody1:
  %t18 = load ptr, ptr @g_uiw
  %t19 = getelementptr inbounds %LSlice, ptr %t18, i32 0, i32 0
  %t20 = load ptr, ptr %t19
  %t21 = load i32, ptr %t10
  %t22 = getelementptr inbounds ptr, ptr %t20, i32 %t21
  %t23 = load ptr, ptr %t22
  store ptr %t23, ptr %t24
  %t25 = load ptr, ptr %t24
  %t26 = call i32 @fn_ui_wtype(ptr %t25)
  store i32 %t26, ptr %t27
  %t28 = load i32, ptr %t10
  %t29 = load i32, ptr %t27
  %t30 = call ptr @fn_itoa(i32 %t29)
  call void @fn_ll_ui_set(i32 %t28, i32 0, ptr %t30)
  %t31 = load i32, ptr %t10
  %t32 = load ptr, ptr @g_uiw_parent
  %t33 = getelementptr inbounds %LSlice, ptr %t32, i32 0, i32 0
  %t34 = load ptr, ptr %t33
  %t35 = load i32, ptr %t10
  %t36 = getelementptr inbounds i32, ptr %t34, i32 %t35
  %t37 = load i32, ptr %t36
  %t38 = call ptr @fn_itoa(i32 %t37)
  call void @fn_ll_ui_set(i32 %t31, i32 1, ptr %t38)
  %t39 = load i32, ptr %t27
  %t40 = icmp eq i32 %t39, 4
  %t41 = zext i1 %t40 to i32
  %t42 = icmp ne i32 %t41, 0
  br i1 %t42, label %then3, label %ifend5
then3:
  %t43 = load i32, ptr %t10
  call void @fn_ll_ui_set(i32 %t43, i32 17, ptr @.str1362)
  br label %ifend5
ifend5:
  store i32 0, ptr %t44
  br label %wcond6
wcond6:
  %t45 = load i32, ptr %t44
  %t46 = load ptr, ptr %t24
  %t47 = getelementptr inbounds %Str_Node, ptr %t46, i32 0, i32 5
  %t48 = load ptr, ptr %t47
  %t49 = getelementptr inbounds %Str_Node, ptr %t48, i32 0, i32 7
  %t50 = load ptr, ptr %t49
  %t51 = getelementptr inbounds %LSlice, ptr %t50, i32 0, i32 1
  %t52 = load i32, ptr %t51
  %t53 = icmp slt i32 %t45, %t52
  %t54 = zext i1 %t53 to i32
  %t55 = icmp ne i32 %t54, 0
  br i1 %t55, label %wbody7, label %wend8
wbody7:
  %t56 = load ptr, ptr %t24
  %t57 = getelementptr inbounds %Str_Node, ptr %t56, i32 0, i32 5
  %t58 = load ptr, ptr %t57
  %t59 = getelementptr inbounds %Str_Node, ptr %t58, i32 0, i32 7
  %t60 = load ptr, ptr %t59
  %t61 = getelementptr inbounds %LSlice, ptr %t60, i32 0, i32 0
  %t62 = load ptr, ptr %t61
  %t63 = load i32, ptr %t44
  %t64 = getelementptr inbounds ptr, ptr %t62, i32 %t63
  %t65 = load ptr, ptr %t64
  store ptr %t65, ptr %t66
  %t67 = load ptr, ptr %t66
  %t68 = getelementptr inbounds %Str_Node, ptr %t67, i32 0, i32 1
  %t69 = load ptr, ptr %t68
  store ptr %t69, ptr %t70
  %t71 = load ptr, ptr %t66
  %t72 = getelementptr inbounds %Str_Node, ptr %t71, i32 0, i32 4
  %t73 = load ptr, ptr %t72
  store ptr %t73, ptr %t74
  %t75 = load ptr, ptr %t70
  %t76 = call i32 @fn_streq(ptr %t75, ptr @.str1363)
  %t77 = icmp ne i32 %t76, 0
  br i1 %t77, label %then9, label %ifend11
then9:
  %t78 = load i32, ptr %t44
  %t79 = add i32 %t78, 1
  store i32 %t79, ptr %t44
  br label %wcond6
ifend11:
  %t80 = load ptr, ptr %t70
  %t81 = call i32 @fn_streq(ptr %t80, ptr @.str1364)
  %t82 = icmp ne i32 %t81, 0
  br i1 %t82, label %then12, label %else13
then12:
  %t83 = load ptr, ptr %t74
  %t84 = call ptr @fn_emit_expr(ptr %t83)
  store ptr %t84, ptr %t85
  call void @fn_emit(ptr @.str1365)
  %t86 = load i32, ptr %t10
  %t87 = call ptr @fn_itoa(i32 %t86)
  call void @fn_emit(ptr %t87)
  call void @fn_emit(ptr @.str1366)
  %t88 = load ptr, ptr %t85
  %t89 = getelementptr inbounds %Str_Val, ptr %t88, i32 0, i32 0
  %t90 = load ptr, ptr %t89
  call void @fn_emit(ptr %t90)
  call void @fn_emit(ptr @.str1367)
  br label %ifend14
else13:
  %t92 = load ptr, ptr %t70
  %t93 = call i32 @fn_streq(ptr %t92, ptr @.str1368)
  %t94 = icmp ne i32 %t93, 0
  %t95 = zext i1 %t94 to i32
  store i32 %t95, ptr %t91
  br i1 %t94, label %scend16, label %sc15
sc15:
  %t96 = load ptr, ptr %t70
  %t97 = call i32 @fn_streq(ptr %t96, ptr @.str1369)
  %t98 = icmp ne i32 %t97, 0
  %t99 = zext i1 %t98 to i32
  store i32 %t99, ptr %t91
  br label %scend16
scend16:
  %t100 = load i32, ptr %t91
  %t101 = icmp ne i32 %t100, 0
  br i1 %t101, label %then17, label %else18
then17:
  %t102 = load ptr, ptr %t74
  %t103 = call ptr @fn_emit_expr(ptr %t102)
  store ptr %t103, ptr %t104
  %t105 = load ptr, ptr %t104
  %t106 = getelementptr inbounds %Str_Val, ptr %t105, i32 0, i32 0
  %t107 = load ptr, ptr %t106
  %t108 = call ptr @fn_sconcat(ptr %t107, ptr @.str1371)
  %t109 = call ptr @fn_sconcat(ptr @.str1370, ptr %t108)
  %t110 = call ptr @fn_emit_bind(ptr %t109)
  store ptr %t110, ptr %t111
  %t112 = load ptr, ptr %t70
  %t113 = call i32 @fn_streq(ptr %t112, ptr @.str1372)
  %t114 = icmp ne i32 %t113, 0
  br i1 %t114, label %then20, label %else21
then20:
  %t115 = load i32, ptr %t10
  %t116 = load ptr, ptr %t111
  call void @fn_ll_ui_set(i32 %t115, i32 20, ptr %t116)
  br label %ifend22
else21:
  %t117 = load i32, ptr %t10
  %t118 = load ptr, ptr %t111
  call void @fn_ll_ui_set(i32 %t117, i32 19, ptr %t118)
  br label %ifend22
ifend22:
  br label %ifend19
else18:
  %t119 = load ptr, ptr %t70
  %t120 = call i32 @fn_streq(ptr %t119, ptr @.str1373)
  %t121 = icmp ne i32 %t120, 0
  br i1 %t121, label %then23, label %else24
then23:
  %t122 = load ptr, ptr %t74
  %t123 = getelementptr inbounds %Str_Node, ptr %t122, i32 0, i32 0
  %t124 = load i32, ptr %t123
  %t125 = icmp eq i32 %t124, 33
  %t126 = zext i1 %t125 to i32
  %t127 = icmp ne i32 %t126, 0
  br i1 %t127, label %then26, label %else27
then26:
  store i32 0, ptr %t128
  %t129 = load ptr, ptr %t74
  %t130 = getelementptr inbounds %Str_Node, ptr %t129, i32 0, i32 1
  %t131 = load ptr, ptr %t130
  %t132 = call i32 @fn_streq(ptr %t131, ptr @.str1374)
  %t133 = icmp ne i32 %t132, 0
  br i1 %t133, label %then29, label %ifend31
then29:
  store i32 1, ptr %t128
  br label %ifend31
ifend31:
  %t134 = load ptr, ptr %t74
  %t135 = getelementptr inbounds %Str_Node, ptr %t134, i32 0, i32 1
  %t136 = load ptr, ptr %t135
  %t137 = call i32 @fn_streq(ptr %t136, ptr @.str1375)
  %t138 = icmp ne i32 %t137, 0
  br i1 %t138, label %then32, label %ifend34
then32:
  store i32 2, ptr %t128
  br label %ifend34
ifend34:
  %t139 = load i32, ptr %t10
  %t140 = load i32, ptr %t128
  %t141 = call ptr @fn_itoa(i32 %t140)
  call void @fn_ll_ui_set(i32 %t139, i32 12, ptr %t141)
  br label %ifend28
else27:
  %t142 = load ptr, ptr %t74
  %t143 = call ptr @fn_emit_expr(ptr %t142)
  store ptr %t143, ptr %t144
  %t145 = load i32, ptr %t10
  %t146 = load ptr, ptr %t144
  %t147 = getelementptr inbounds %Str_Val, ptr %t146, i32 0, i32 0
  %t148 = load ptr, ptr %t147
  call void @fn_ll_ui_set(i32 %t145, i32 12, ptr %t148)
  br label %ifend28
ifend28:
  br label %ifend25
else24:
  %t149 = load ptr, ptr %t70
  %t150 = call i32 @fn_ui_prop_key(ptr %t149)
  store i32 %t150, ptr %t151
  %t152 = load i32, ptr %t151
  %t153 = icmp sge i32 %t152, 0
  %t154 = zext i1 %t153 to i32
  %t155 = icmp ne i32 %t154, 0
  br i1 %t155, label %then35, label %ifend37
then35:
  %t156 = load ptr, ptr %t74
  %t157 = call ptr @fn_emit_expr(ptr %t156)
  store ptr %t157, ptr %t158
  %t159 = load i32, ptr %t10
  %t160 = load i32, ptr %t151
  %t161 = load ptr, ptr %t158
  %t162 = getelementptr inbounds %Str_Val, ptr %t161, i32 0, i32 0
  %t163 = load ptr, ptr %t162
  call void @fn_ll_ui_set(i32 %t159, i32 %t160, ptr %t163)
  %t165 = load i32, ptr %t151
  %t166 = icmp eq i32 %t165, 4
  %t167 = zext i1 %t166 to i32
  %t168 = icmp ne i32 %t167, 0
  %t169 = zext i1 %t168 to i32
  store i32 %t169, ptr %t164
  br i1 %t168, label %scend39, label %sc38
sc38:
  %t170 = load i32, ptr %t151
  %t171 = icmp eq i32 %t170, 5
  %t172 = zext i1 %t171 to i32
  %t173 = icmp ne i32 %t172, 0
  %t174 = zext i1 %t173 to i32
  store i32 %t174, ptr %t164
  br label %scend39
scend39:
  %t175 = load i32, ptr %t164
  %t176 = icmp ne i32 %t175, 0
  br i1 %t176, label %then40, label %ifend42
then40:
  %t177 = load i32, ptr %t10
  call void @fn_ll_ui_set(i32 %t177, i32 6, ptr @.str1376)
  br label %ifend42
ifend42:
  br label %ifend37
ifend37:
  br label %ifend25
ifend25:
  br label %ifend19
ifend19:
  br label %ifend14
ifend14:
  %t178 = load i32, ptr %t44
  %t179 = add i32 %t178, 1
  store i32 %t179, ptr %t44
  br label %wcond6
wend8:
  %t180 = load i32, ptr %t10
  %t181 = add i32 %t180, 1
  store i32 %t181, ptr %t10
  br label %wcond0
wend2:
  %t182 = load ptr, ptr %t4
  store ptr %t182, ptr @g_code
  call void @fn_emit(ptr @.str1377)
  %t183 = load ptr, ptr @g_falloc
  %t184 = call ptr @fn_buf_str(ptr %t183)
  call void @fn_emit(ptr %t184)
  %t185 = load ptr, ptr %t1
  %t186 = call ptr @fn_buf_str(ptr %t185)
  call void @fn_emit(ptr %t186)
  call void @fn_emit(ptr @.str1378)
  br label %ret
ret:
  ret void
}

define void @fn_emit_params_sig(ptr %arg_d) {
entry:
  %t0 = alloca ptr
  %t1 = alloca i32
  store ptr %arg_d, ptr %t0
  store i32 0, ptr %t1
  br label %wcond0
wcond0:
  %t2 = load i32, ptr %t1
  %t3 = load ptr, ptr %t0
  %t4 = getelementptr inbounds %Str_Node, ptr %t3, i32 0, i32 7
  %t5 = load ptr, ptr %t4
  %t6 = getelementptr inbounds %LSlice, ptr %t5, i32 0, i32 1
  %t7 = load i32, ptr %t6
  %t8 = icmp slt i32 %t2, %t7
  %t9 = zext i1 %t8 to i32
  %t10 = icmp ne i32 %t9, 0
  br i1 %t10, label %wbody1, label %wend2
wbody1:
  %t11 = load i32, ptr %t1
  %t12 = icmp sgt i32 %t11, 0
  %t13 = zext i1 %t12 to i32
  %t14 = icmp ne i32 %t13, 0
  br i1 %t14, label %then3, label %ifend5
then3:
  call void @fn_emit(ptr @.str1379)
  br label %ifend5
ifend5:
  %t15 = load ptr, ptr %t0
  %t16 = getelementptr inbounds %Str_Node, ptr %t15, i32 0, i32 7
  %t17 = load ptr, ptr %t16
  %t18 = getelementptr inbounds %LSlice, ptr %t17, i32 0, i32 0
  %t19 = load ptr, ptr %t18
  %t20 = load i32, ptr %t1
  %t21 = getelementptr inbounds ptr, ptr %t19, i32 %t20
  %t22 = load ptr, ptr %t21
  %t23 = getelementptr inbounds %Str_Node, ptr %t22, i32 0, i32 3
  %t24 = load ptr, ptr %t23
  %t25 = call ptr @fn_llty(ptr %t24)
  call void @fn_emit(ptr %t25)
  call void @fn_emit(ptr @.str1380)
  %t26 = load ptr, ptr %t0
  %t27 = getelementptr inbounds %Str_Node, ptr %t26, i32 0, i32 7
  %t28 = load ptr, ptr %t27
  %t29 = getelementptr inbounds %LSlice, ptr %t28, i32 0, i32 0
  %t30 = load ptr, ptr %t29
  %t31 = load i32, ptr %t1
  %t32 = getelementptr inbounds ptr, ptr %t30, i32 %t31
  %t33 = load ptr, ptr %t32
  %t34 = getelementptr inbounds %Str_Node, ptr %t33, i32 0, i32 1
  %t35 = load ptr, ptr %t34
  call void @fn_emit(ptr %t35)
  %t36 = load i32, ptr %t1
  %t37 = add i32 %t36, 1
  store i32 %t37, ptr %t1
  br label %wcond0
wend2:
  br label %ret
ret:
  ret void
}

define void @fn_emit_fn(ptr %arg_d) {
entry:
  %t0 = alloca ptr
  %t5 = alloca ptr
  %t8 = alloca ptr
  %t12 = alloca ptr
  %t22 = alloca i32
  %t40 = alloca ptr
  %t46 = alloca ptr
  %t78 = alloca ptr
  store ptr %arg_d, ptr %t0
  store i32 0, ptr @g_ll_t
  store i32 0, ptr @g_ll_lbl
  store i32 0, ptr @g_g_term
  call void @fn_loc_reset()
  store i32 0, ptr @g_nloop
  %t1 = load ptr, ptr %t0
  %t2 = getelementptr inbounds %Str_Node, ptr %t1, i32 0, i32 3
  %t3 = load ptr, ptr %t2
  store ptr %t3, ptr @g_ret_ty
  %t4 = call ptr @fn_buf_new()
  store ptr %t4, ptr %t5
  %t6 = call ptr @fn_buf_new()
  store ptr %t6, ptr @g_falloc
  %t7 = load ptr, ptr @g_code
  store ptr %t7, ptr %t8
  %t9 = load ptr, ptr %t5
  store ptr %t9, ptr @g_code
  %t10 = load ptr, ptr @g_ret_ty
  %t11 = call ptr @fn_llty(ptr %t10)
  store ptr %t11, ptr %t12
  %t13 = load ptr, ptr %t12
  %t14 = call i32 @fn_streq(ptr %t13, ptr @.str1381)
  %t15 = icmp eq i32 %t14, 0
  %t16 = zext i1 %t15 to i32
  %t17 = icmp ne i32 %t16, 0
  br i1 %t17, label %then0, label %ifend2
then0:
  %t18 = load ptr, ptr @g_falloc
  call void @fn_buf_puts(ptr %t18, ptr @.str1382)
  %t19 = load ptr, ptr @g_falloc
  %t20 = load ptr, ptr %t12
  call void @fn_buf_puts(ptr %t19, ptr %t20)
  %t21 = load ptr, ptr @g_falloc
  call void @fn_buf_puts(ptr %t21, ptr @.str1383)
  br label %ifend2
ifend2:
  store i32 0, ptr %t22
  br label %wcond3
wcond3:
  %t23 = load i32, ptr %t22
  %t24 = load ptr, ptr %t0
  %t25 = getelementptr inbounds %Str_Node, ptr %t24, i32 0, i32 7
  %t26 = load ptr, ptr %t25
  %t27 = getelementptr inbounds %LSlice, ptr %t26, i32 0, i32 1
  %t28 = load i32, ptr %t27
  %t29 = icmp slt i32 %t23, %t28
  %t30 = zext i1 %t29 to i32
  %t31 = icmp ne i32 %t30, 0
  br i1 %t31, label %wbody4, label %wend5
wbody4:
  %t32 = load ptr, ptr %t0
  %t33 = getelementptr inbounds %Str_Node, ptr %t32, i32 0, i32 7
  %t34 = load ptr, ptr %t33
  %t35 = getelementptr inbounds %LSlice, ptr %t34, i32 0, i32 0
  %t36 = load ptr, ptr %t35
  %t37 = load i32, ptr %t22
  %t38 = getelementptr inbounds ptr, ptr %t36, i32 %t37
  %t39 = load ptr, ptr %t38
  store ptr %t39, ptr %t40
  %t41 = load ptr, ptr %t40
  %t42 = getelementptr inbounds %Str_Node, ptr %t41, i32 0, i32 3
  %t43 = load ptr, ptr %t42
  %t44 = call ptr @fn_llty(ptr %t43)
  %t45 = call ptr @fn_emit_alloca(ptr %t44)
  store ptr %t45, ptr %t46
  call void @fn_emit(ptr @.str1384)
  %t47 = load ptr, ptr %t40
  %t48 = getelementptr inbounds %Str_Node, ptr %t47, i32 0, i32 3
  %t49 = load ptr, ptr %t48
  %t50 = call ptr @fn_llty(ptr %t49)
  call void @fn_emit(ptr %t50)
  call void @fn_emit(ptr @.str1385)
  %t51 = load ptr, ptr %t40
  %t52 = getelementptr inbounds %Str_Node, ptr %t51, i32 0, i32 1
  %t53 = load ptr, ptr %t52
  call void @fn_emit(ptr %t53)
  call void @fn_emit(ptr @.str1386)
  %t54 = load ptr, ptr %t46
  call void @fn_emit(ptr %t54)
  call void @fn_emit(ptr @.str1387)
  %t55 = load ptr, ptr %t40
  %t56 = getelementptr inbounds %Str_Node, ptr %t55, i32 0, i32 1
  %t57 = load ptr, ptr %t56
  %t58 = load ptr, ptr %t46
  %t59 = load ptr, ptr %t40
  %t60 = getelementptr inbounds %Str_Node, ptr %t59, i32 0, i32 3
  %t61 = load ptr, ptr %t60
  call void @fn_loc_push(ptr %t57, ptr %t58, ptr %t61)
  %t62 = load i32, ptr %t22
  %t63 = add i32 %t62, 1
  store i32 %t63, ptr %t22
  br label %wcond3
wend5:
  %t64 = load ptr, ptr %t0
  %t65 = getelementptr inbounds %Str_Node, ptr %t64, i32 0, i32 4
  %t66 = load ptr, ptr %t65
  call void @fn_emit_block(ptr %t66)
  %t67 = load i32, ptr @g_g_term
  %t68 = icmp eq i32 %t67, 0
  %t69 = zext i1 %t68 to i32
  %t70 = icmp ne i32 %t69, 0
  br i1 %t70, label %then6, label %ifend8
then6:
  call void @fn_emit(ptr @.str1388)
  br label %ifend8
ifend8:
  call void @fn_emit(ptr @.str1389)
  %t71 = load ptr, ptr %t12
  %t72 = call i32 @fn_streq(ptr %t71, ptr @.str1390)
  %t73 = icmp ne i32 %t72, 0
  br i1 %t73, label %then9, label %else10
then9:
  call void @fn_emit(ptr @.str1391)
  br label %ifend11
else10:
  %t74 = load ptr, ptr %t12
  %t75 = call ptr @fn_sconcat(ptr %t74, ptr @.str1393)
  %t76 = call ptr @fn_sconcat(ptr @.str1392, ptr %t75)
  %t77 = call ptr @fn_emit_bind(ptr %t76)
  store ptr %t77, ptr %t78
  call void @fn_emit(ptr @.str1394)
  %t79 = load ptr, ptr %t12
  call void @fn_emit(ptr %t79)
  call void @fn_emit(ptr @.str1395)
  %t80 = load ptr, ptr %t78
  call void @fn_emit(ptr %t80)
  call void @fn_emit(ptr @.str1396)
  br label %ifend11
ifend11:
  %t81 = load ptr, ptr %t8
  store ptr %t81, ptr @g_code
  call void @fn_emit(ptr @.str1397)
  %t82 = load ptr, ptr %t12
  call void @fn_emit(ptr %t82)
  call void @fn_emit(ptr @.str1398)
  %t83 = load ptr, ptr %t0
  %t84 = getelementptr inbounds %Str_Node, ptr %t83, i32 0, i32 1
  %t85 = load ptr, ptr %t84
  call void @fn_emit(ptr %t85)
  call void @fn_emit(ptr @.str1399)
  %t86 = load ptr, ptr %t0
  call void @fn_emit_params_sig(ptr %t86)
  call void @fn_emit(ptr @.str1400)
  %t87 = load ptr, ptr @g_falloc
  %t88 = call ptr @fn_buf_str(ptr %t87)
  call void @fn_emit(ptr %t88)
  %t89 = load ptr, ptr %t5
  %t90 = call ptr @fn_buf_str(ptr %t89)
  call void @fn_emit(ptr %t90)
  call void @fn_emit(ptr @.str1401)
  br label %ret
ret:
  ret void
}

define void @fn_emit_main(ptr %arg_d) {
entry:
  %t0 = alloca ptr
  %t2 = alloca ptr
  %t5 = alloca ptr
  %t16 = alloca ptr
  store ptr %arg_d, ptr %t0
  store i32 0, ptr @g_ll_t
  store i32 0, ptr @g_ll_lbl
  store i32 0, ptr @g_g_term
  call void @fn_loc_reset()
  store i32 0, ptr @g_nloop
  store ptr @.str1402, ptr @g_ret_ty
  %t1 = call ptr @fn_buf_new()
  store ptr %t1, ptr %t2
  %t3 = call ptr @fn_buf_new()
  store ptr %t3, ptr @g_falloc
  %t4 = load ptr, ptr @g_code
  store ptr %t4, ptr %t5
  %t6 = load ptr, ptr %t2
  store ptr %t6, ptr @g_code
  %t7 = load ptr, ptr @g_falloc
  call void @fn_buf_puts(ptr %t7, ptr @.str1403)
  call void @fn_emit(ptr @.str1404)
  call void @fn_emit(ptr @.str1405)
  call void @fn_emit(ptr @.str1406)
  %t8 = load ptr, ptr %t0
  %t9 = getelementptr inbounds %Str_Node, ptr %t8, i32 0, i32 4
  %t10 = load ptr, ptr %t9
  call void @fn_emit_block(ptr %t10)
  %t11 = load i32, ptr @g_g_term
  %t12 = icmp eq i32 %t11, 0
  %t13 = zext i1 %t12 to i32
  %t14 = icmp ne i32 %t13, 0
  br i1 %t14, label %then0, label %ifend2
then0:
  call void @fn_emit(ptr @.str1407)
  br label %ifend2
ifend2:
  call void @fn_emit(ptr @.str1408)
  %t15 = call ptr @fn_emit_bind(ptr @.str1409)
  store ptr %t15, ptr %t16
  call void @fn_emit(ptr @.str1410)
  %t17 = load ptr, ptr %t16
  call void @fn_emit(ptr %t17)
  call void @fn_emit(ptr @.str1411)
  %t18 = load ptr, ptr %t5
  store ptr %t18, ptr @g_code
  call void @fn_emit(ptr @.str1412)
  %t19 = load ptr, ptr @g_falloc
  %t20 = call ptr @fn_buf_str(ptr %t19)
  call void @fn_emit(ptr %t20)
  %t21 = load ptr, ptr %t2
  %t22 = call ptr @fn_buf_str(ptr %t21)
  call void @fn_emit(ptr %t22)
  call void @fn_emit(ptr @.str1413)
  br label %ret
ret:
  ret void
}

define void @fn_emit_program() {
entry:
  %t46 = alloca i32
  %t0 = call ptr @fn_buf_new()
  store ptr %t0, ptr @g_head
  %t1 = call ptr @fn_buf_new()
  store ptr %t1, ptr @g_code
  %t2 = getelementptr %LSlice, ptr null, i32 1
  %t3 = ptrtoint ptr %t2 to i64
  %t4 = call ptr @malloc(i64 %t3)
  %t5 = getelementptr inbounds %LSlice, ptr %t4, i32 0, i32 0
  store ptr null, ptr %t5
  %t6 = getelementptr inbounds %LSlice, ptr %t4, i32 0, i32 1
  store i32 0, ptr %t6
  %t7 = getelementptr inbounds %LSlice, ptr %t4, i32 0, i32 2
  store i32 0, ptr %t7
  store ptr %t4, ptr @g_loc_name
  %t8 = getelementptr %LSlice, ptr null, i32 1
  %t9 = ptrtoint ptr %t8 to i64
  %t10 = call ptr @malloc(i64 %t9)
  %t11 = getelementptr inbounds %LSlice, ptr %t10, i32 0, i32 0
  store ptr null, ptr %t11
  %t12 = getelementptr inbounds %LSlice, ptr %t10, i32 0, i32 1
  store i32 0, ptr %t12
  %t13 = getelementptr inbounds %LSlice, ptr %t10, i32 0, i32 2
  store i32 0, ptr %t13
  store ptr %t10, ptr @g_loc_reg
  %t14 = getelementptr %LSlice, ptr null, i32 1
  %t15 = ptrtoint ptr %t14 to i64
  %t16 = call ptr @malloc(i64 %t15)
  %t17 = getelementptr inbounds %LSlice, ptr %t16, i32 0, i32 0
  store ptr null, ptr %t17
  %t18 = getelementptr inbounds %LSlice, ptr %t16, i32 0, i32 1
  store i32 0, ptr %t18
  %t19 = getelementptr inbounds %LSlice, ptr %t16, i32 0, i32 2
  store i32 0, ptr %t19
  store ptr %t16, ptr @g_loc_ty
  %t20 = getelementptr %LSlice, ptr null, i32 1
  %t21 = ptrtoint ptr %t20 to i64
  %t22 = call ptr @malloc(i64 %t21)
  %t23 = getelementptr inbounds %LSlice, ptr %t22, i32 0, i32 0
  store ptr null, ptr %t23
  %t24 = getelementptr inbounds %LSlice, ptr %t22, i32 0, i32 1
  store i32 0, ptr %t24
  %t25 = getelementptr inbounds %LSlice, ptr %t22, i32 0, i32 2
  store i32 0, ptr %t25
  store ptr %t22, ptr @g_brk_lbl
  %t26 = getelementptr %LSlice, ptr null, i32 1
  %t27 = ptrtoint ptr %t26 to i64
  %t28 = call ptr @malloc(i64 %t27)
  %t29 = getelementptr inbounds %LSlice, ptr %t28, i32 0, i32 0
  store ptr null, ptr %t29
  %t30 = getelementptr inbounds %LSlice, ptr %t28, i32 0, i32 1
  store i32 0, ptr %t30
  %t31 = getelementptr inbounds %LSlice, ptr %t28, i32 0, i32 2
  store i32 0, ptr %t31
  store ptr %t28, ptr @g_cnt_lbl
  %t32 = getelementptr %LSlice, ptr null, i32 1
  %t33 = ptrtoint ptr %t32 to i64
  %t34 = call ptr @malloc(i64 %t33)
  %t35 = getelementptr inbounds %LSlice, ptr %t34, i32 0, i32 0
  store ptr null, ptr %t35
  %t36 = getelementptr inbounds %LSlice, ptr %t34, i32 0, i32 1
  store i32 0, ptr %t36
  %t37 = getelementptr inbounds %LSlice, ptr %t34, i32 0, i32 2
  store i32 0, ptr %t37
  store ptr %t34, ptr @g_self_stk
  %t38 = getelementptr %LSlice, ptr null, i32 1
  %t39 = ptrtoint ptr %t38 to i64
  %t40 = call ptr @malloc(i64 %t39)
  %t41 = getelementptr inbounds %LSlice, ptr %t40, i32 0, i32 0
  store ptr null, ptr %t41
  %t42 = getelementptr inbounds %LSlice, ptr %t40, i32 0, i32 1
  store i32 0, ptr %t42
  %t43 = getelementptr inbounds %LSlice, ptr %t40, i32 0, i32 2
  store i32 0, ptr %t43
  store ptr %t40, ptr @g_mach_stk
  call void @fn_emit_header()
  %t44 = call i32 @fn_has_ecs()
  %t45 = icmp ne i32 %t44, 0
  br i1 %t45, label %then0, label %ifend2
then0:
  call void @fn_emit_ecs_storage()
  br label %ifend2
ifend2:
  store i32 0, ptr %t46
  br label %wcond3
wcond3:
  %t47 = load i32, ptr %t46
  %t48 = load ptr, ptr @g_prog
  %t49 = getelementptr inbounds %LSlice, ptr %t48, i32 0, i32 1
  %t50 = load i32, ptr %t49
  %t51 = icmp slt i32 %t47, %t50
  %t52 = zext i1 %t51 to i32
  %t53 = icmp ne i32 %t52, 0
  br i1 %t53, label %wbody4, label %wend5
wbody4:
  %t54 = load ptr, ptr @g_prog
  %t55 = getelementptr inbounds %LSlice, ptr %t54, i32 0, i32 0
  %t56 = load ptr, ptr %t55
  %t57 = load i32, ptr %t46
  %t58 = getelementptr inbounds ptr, ptr %t56, i32 %t57
  %t59 = load ptr, ptr %t58
  %t60 = getelementptr inbounds %Str_Node, ptr %t59, i32 0, i32 0
  %t61 = load i32, ptr %t60
  %t62 = icmp eq i32 %t61, 4
  %t63 = zext i1 %t62 to i32
  %t64 = icmp ne i32 %t63, 0
  br i1 %t64, label %then6, label %ifend8
then6:
  %t65 = load ptr, ptr @g_prog
  %t66 = getelementptr inbounds %LSlice, ptr %t65, i32 0, i32 0
  %t67 = load ptr, ptr %t66
  %t68 = load i32, ptr %t46
  %t69 = getelementptr inbounds ptr, ptr %t67, i32 %t68
  %t70 = load ptr, ptr %t69
  call void @fn_emit_fn(ptr %t70)
  br label %ifend8
ifend8:
  %t71 = load i32, ptr %t46
  %t72 = add i32 %t71, 1
  store i32 %t72, ptr %t46
  br label %wcond3
wend5:
  %t73 = call i32 @fn_has_ecs()
  %t74 = icmp ne i32 %t73, 0
  br i1 %t74, label %then9, label %ifend11
then9:
  call void @fn_emit_ecs_allocator()
  call void @fn_emit_snapshot()
  br label %ifend11
ifend11:
  %t75 = call i32 @fn_has_ui()
  %t76 = icmp ne i32 %t75, 0
  br i1 %t76, label %then12, label %ifend14
then12:
  call void @fn_emit_ui_build()
  br label %ifend14
ifend14:
  %t77 = call i32 @fn_has_systems()
  %t78 = icmp ne i32 %t77, 0
  br i1 %t78, label %then15, label %else16
then15:
  call void @fn_emit_game_main()
  br label %ifend17
else16:
  store i32 0, ptr %t46
  br label %wcond18
wcond18:
  %t79 = load i32, ptr %t46
  %t80 = load ptr, ptr @g_prog
  %t81 = getelementptr inbounds %LSlice, ptr %t80, i32 0, i32 1
  %t82 = load i32, ptr %t81
  %t83 = icmp slt i32 %t79, %t82
  %t84 = zext i1 %t83 to i32
  %t85 = icmp ne i32 %t84, 0
  br i1 %t85, label %wbody19, label %wend20
wbody19:
  %t86 = load ptr, ptr @g_prog
  %t87 = getelementptr inbounds %LSlice, ptr %t86, i32 0, i32 0
  %t88 = load ptr, ptr %t87
  %t89 = load i32, ptr %t46
  %t90 = getelementptr inbounds ptr, ptr %t88, i32 %t89
  %t91 = load ptr, ptr %t90
  %t92 = getelementptr inbounds %Str_Node, ptr %t91, i32 0, i32 0
  %t93 = load i32, ptr %t92
  %t94 = icmp eq i32 %t93, 6
  %t95 = zext i1 %t94 to i32
  %t96 = icmp ne i32 %t95, 0
  br i1 %t96, label %then21, label %ifend23
then21:
  %t97 = load ptr, ptr @g_prog
  %t98 = getelementptr inbounds %LSlice, ptr %t97, i32 0, i32 0
  %t99 = load ptr, ptr %t98
  %t100 = load i32, ptr %t46
  %t101 = getelementptr inbounds ptr, ptr %t99, i32 %t100
  %t102 = load ptr, ptr %t101
  call void @fn_emit_main(ptr %t102)
  br label %ifend23
ifend23:
  %t103 = load i32, ptr %t46
  %t104 = add i32 %t103, 1
  store i32 %t104, ptr %t46
  br label %wcond18
wend20:
  br label %ifend17
ifend17:
  br label %ret
ret:
  ret void
}

define i32 @fn_ir_flush(ptr %arg_path) {
entry:
  %retval = alloca i32
  %t0 = alloca ptr
  %t3 = alloca ptr
  %t6 = alloca ptr
  %t15 = alloca ptr
  store ptr %arg_path, ptr %t0
  %t1 = load ptr, ptr @g_head
  %t2 = call ptr @fn_buf_str(ptr %t1)
  store ptr %t2, ptr %t3
  %t4 = load ptr, ptr @g_code
  %t5 = call ptr @fn_buf_str(ptr %t4)
  store ptr %t5, ptr %t6
  %t7 = load ptr, ptr %t0
  %t8 = icmp eq ptr %t7, null
  %t9 = zext i1 %t8 to i32
  %t10 = icmp ne i32 %t9, 0
  br i1 %t10, label %then0, label %ifend2
then0:
  %t11 = load ptr, ptr %t3
  call i32 (ptr, ...) @printf(ptr @.fmt_str, ptr %t11)
  %t12 = load ptr, ptr %t6
  call i32 (ptr, ...) @printf(ptr @.fmt_str, ptr %t12)
  store i32 1, ptr %retval
  br label %ret
ifend2:
  %t13 = load ptr, ptr %t0
  %t14 = call ptr @fopen(ptr %t13, ptr @.str1414)
  store ptr %t14, ptr %t15
  %t16 = load ptr, ptr %t15
  %t17 = icmp eq ptr %t16, null
  %t18 = zext i1 %t17 to i32
  %t19 = icmp ne i32 %t18, 0
  br i1 %t19, label %then3, label %ifend5
then3:
  store i32 0, ptr %retval
  br label %ret
ifend5:
  %t20 = load ptr, ptr %t15
  %t21 = load ptr, ptr %t3
  %t22 = load ptr, ptr %t3
  %t23 = call i32 @fn_slen(ptr %t22)
  %t24 = zext i32 %t23 to i64
  %t25 = call i64 @fwrite(ptr %t21, i64 1, i64 %t24, ptr %t20)
  %t26 = trunc i64 %t25 to i32
  %t27 = load ptr, ptr %t15
  %t28 = load ptr, ptr %t6
  %t29 = load ptr, ptr %t6
  %t30 = call i32 @fn_slen(ptr %t29)
  %t31 = zext i32 %t30 to i64
  %t32 = call i64 @fwrite(ptr %t28, i64 1, i64 %t31, ptr %t27)
  %t33 = trunc i64 %t32 to i32
  %t34 = load ptr, ptr %t15
  call i32 @fclose(ptr %t34)
  store i32 1, ptr %retval
  br label %ret
ret:
  %t35 = load i32, ptr %retval
  ret i32 %t35
}

define ptr @fn_base_name(ptr %arg_path) {
entry:
  %retval = alloca ptr
  %t0 = alloca ptr
  %t2 = alloca i32
  %t3 = alloca i32
  store ptr %arg_path, ptr %t0
  %t1 = sub i32 0, 1
  store i32 %t1, ptr %t2
  store i32 0, ptr %t3
  br label %wcond0
wcond0:
  %t4 = load ptr, ptr %t0
  %t5 = load i32, ptr %t3
  %t6 = getelementptr inbounds i8, ptr %t4, i32 %t5
  %t7 = load i8, ptr %t6
  %t8 = zext i8 %t7 to i32
  %t9 = icmp ne i32 %t8, 0
  %t10 = zext i1 %t9 to i32
  %t11 = icmp ne i32 %t10, 0
  br i1 %t11, label %wbody1, label %wend2
wbody1:
  %t12 = load ptr, ptr %t0
  %t13 = load i32, ptr %t3
  %t14 = getelementptr inbounds i8, ptr %t12, i32 %t13
  %t15 = load i8, ptr %t14
  %t16 = zext i8 %t15 to i32
  %t17 = icmp eq i32 %t16, 47
  %t18 = zext i1 %t17 to i32
  %t19 = icmp ne i32 %t18, 0
  br i1 %t19, label %then3, label %ifend5
then3:
  %t20 = load i32, ptr %t3
  store i32 %t20, ptr %t2
  br label %ifend5
ifend5:
  %t21 = load i32, ptr %t3
  %t22 = add i32 %t21, 1
  store i32 %t22, ptr %t3
  br label %wcond0
wend2:
  %t23 = load ptr, ptr %t0
  %t24 = load i32, ptr %t2
  %t25 = add i32 %t24, 1
  %t26 = load i32, ptr %t3
  %t27 = load i32, ptr %t2
  %t28 = add i32 %t27, 1
  %t29 = sub i32 %t26, %t28
  %t30 = call ptr @fn_substr(ptr %t23, i32 %t25, i32 %t29)
  store ptr %t30, ptr %retval
  br label %ret
ret:
  %t31 = load ptr, ptr %retval
  ret ptr %t31
}

define ptr @fn_strip_ludic(ptr %arg_name) {
entry:
  %retval = alloca ptr
  %t0 = alloca ptr
  %t3 = alloca i32
  store ptr %arg_name, ptr %t0
  %t1 = load ptr, ptr %t0
  %t2 = call i32 @fn_slen(ptr %t1)
  store i32 %t2, ptr %t3
  %t4 = load i32, ptr %t3
  %t5 = icmp sgt i32 %t4, 6
  %t6 = zext i1 %t5 to i32
  %t7 = icmp ne i32 %t6, 0
  br i1 %t7, label %then0, label %ifend2
then0:
  %t8 = load ptr, ptr %t0
  %t9 = load i32, ptr %t3
  %t10 = sub i32 %t9, 6
  %t11 = call ptr @fn_substr(ptr %t8, i32 %t10, i32 6)
  %t12 = call i32 @fn_streq(ptr %t11, ptr @.str1415)
  %t13 = icmp ne i32 %t12, 0
  br i1 %t13, label %then3, label %ifend5
then3:
  %t14 = load ptr, ptr %t0
  %t15 = load i32, ptr %t3
  %t16 = sub i32 %t15, 6
  %t17 = call ptr @fn_substr(ptr %t14, i32 0, i32 %t16)
  store ptr %t17, ptr %retval
  br label %ret
ifend5:
  br label %ifend2
ifend2:
  %t18 = load ptr, ptr %t0
  store ptr %t18, ptr %retval
  br label %ret
ret:
  %t19 = load ptr, ptr %retval
  ret ptr %t19
}

define ptr @fn_getenv_or(ptr %arg_name, ptr %arg_dflt) {
entry:
  %retval = alloca ptr
  %t0 = alloca ptr
  %t1 = alloca ptr
  %t4 = alloca ptr
  store ptr %arg_name, ptr %t0
  store ptr %arg_dflt, ptr %t1
  %t2 = load ptr, ptr %t0
  %t3 = call ptr @getenv(ptr %t2)
  store ptr %t3, ptr %t4
  %t5 = load ptr, ptr %t4
  %t6 = icmp eq ptr %t5, null
  %t7 = zext i1 %t6 to i32
  %t8 = icmp ne i32 %t7, 0
  br i1 %t8, label %then0, label %ifend2
then0:
  %t9 = load ptr, ptr %t1
  store ptr %t9, ptr %retval
  br label %ret
ifend2:
  %t10 = load ptr, ptr %t4
  store ptr %t10, ptr %retval
  br label %ret
ret:
  %t11 = load ptr, ptr %retval
  ret ptr %t11
}

define ptr @fn_ensure_slash(ptr %arg_d) {
entry:
  %retval = alloca ptr
  %t0 = alloca ptr
  %t3 = alloca i32
  store ptr %arg_d, ptr %t0
  %t1 = load ptr, ptr %t0
  %t2 = call i32 @fn_slen(ptr %t1)
  store i32 %t2, ptr %t3
  %t4 = load i32, ptr %t3
  %t5 = icmp eq i32 %t4, 0
  %t6 = zext i1 %t5 to i32
  %t7 = icmp ne i32 %t6, 0
  br i1 %t7, label %then0, label %ifend2
then0:
  %t8 = load ptr, ptr %t0
  store ptr %t8, ptr %retval
  br label %ret
ifend2:
  %t9 = load ptr, ptr %t0
  %t10 = load i32, ptr %t3
  %t11 = sub i32 %t10, 1
  %t12 = getelementptr inbounds i8, ptr %t9, i32 %t11
  %t13 = load i8, ptr %t12
  %t14 = zext i8 %t13 to i32
  %t15 = icmp eq i32 %t14, 47
  %t16 = zext i1 %t15 to i32
  %t17 = icmp ne i32 %t16, 0
  br i1 %t17, label %then3, label %ifend5
then3:
  %t18 = load ptr, ptr %t0
  store ptr %t18, ptr %retval
  br label %ret
ifend5:
  %t19 = load ptr, ptr %t0
  %t20 = call ptr @fn_sconcat(ptr %t19, ptr @.str1416)
  store ptr %t20, ptr %retval
  br label %ret
ret:
  %t21 = load ptr, ptr %retval
  ret ptr %t21
}

define void @fn_die(ptr %arg_msg) {
entry:
  %t0 = alloca ptr
  store ptr %arg_msg, ptr %t0
  %t1 = load ptr, ptr @__stderrp
  %t2 = load ptr, ptr %t0
  %t3 = load ptr, ptr %t0
  %t4 = call i32 @fn_slen(ptr %t3)
  %t5 = zext i32 %t4 to i64
  %t6 = call i64 @fwrite(ptr %t2, i64 1, i64 %t5, ptr %t1)
  %t7 = trunc i64 %t6 to i32
  call void @exit(i32 1)
  unreachable
ret:
  ret void
}

define i32 @main(i32 %argc, ptr %argv) {
entry:
  %retval = alloca i32
  %t0 = alloca ptr
  %t1 = alloca ptr
  %t2 = alloca i32
  %t3 = alloca i32
  %t4 = alloca i32
  %t5 = alloca i32
  %t6 = alloca i32
  %t13 = alloca i32
  %t23 = alloca ptr
  %t66 = alloca ptr
  %t83 = alloca ptr
  %t93 = alloca i32
  %t105 = alloca i32
  %t114 = alloca i32
  %t131 = alloca i32
  %t148 = alloca ptr
  %t159 = alloca ptr
  %t166 = alloca ptr
  %t173 = alloca ptr
  %t178 = alloca ptr
  %t183 = alloca ptr
  %t195 = alloca i32
  %t211 = alloca i32
  store i32 %argc, ptr @L_argc
  store ptr %argv, ptr @L_argv
  store i32 0, ptr %retval
  store ptr null, ptr %t0
  store ptr null, ptr %t1
  store i32 0, ptr %t2
  store i32 0, ptr %t3
  store i32 0, ptr %t4
  store i32 0, ptr %t5
  store i32 0, ptr %t6
  %t7 = load ptr, ptr @L_argv
  %t8 = getelementptr ptr, ptr %t7, i32 0
  %t9 = load ptr, ptr %t8
  %t10 = call ptr @fn_base_name(ptr %t9)
  %t11 = call i32 @fn_streq(ptr %t10, ptr @.str1417)
  %t12 = icmp ne i32 %t11, 0
  br i1 %t12, label %then0, label %ifend2
then0:
  store i32 1, ptr %t6
  br label %ifend2
ifend2:
  store i32 1, ptr %t13
  br label %wcond3
wcond3:
  %t14 = load i32, ptr %t13
  %t15 = load i32, ptr @L_argc
  %t16 = icmp slt i32 %t14, %t15
  %t17 = zext i1 %t16 to i32
  %t18 = icmp ne i32 %t17, 0
  br i1 %t18, label %wbody4, label %wend5
wbody4:
  %t19 = load i32, ptr %t13
  %t20 = load ptr, ptr @L_argv
  %t21 = getelementptr ptr, ptr %t20, i32 %t19
  %t22 = load ptr, ptr %t21
  store ptr %t22, ptr %t23
  %t24 = load ptr, ptr %t23
  %t25 = call i32 @fn_streq(ptr %t24, ptr @.str1418)
  %t26 = icmp ne i32 %t25, 0
  br i1 %t26, label %then6, label %else7
then6:
  store i32 1, ptr %t2
  br label %ifend8
else7:
  %t27 = load ptr, ptr %t23
  %t28 = call i32 @fn_streq(ptr %t27, ptr @.str1419)
  %t29 = icmp ne i32 %t28, 0
  br i1 %t29, label %then9, label %else10
then9:
  store i32 2, ptr %t2
  br label %ifend11
else10:
  %t30 = load ptr, ptr %t23
  %t31 = call i32 @fn_streq(ptr %t30, ptr @.str1420)
  %t32 = icmp ne i32 %t31, 0
  br i1 %t32, label %then12, label %else13
then12:
  store i32 1, ptr %t3
  br label %ifend14
else13:
  %t33 = load ptr, ptr %t23
  %t34 = call i32 @fn_streq(ptr %t33, ptr @.str1421)
  %t35 = icmp ne i32 %t34, 0
  br i1 %t35, label %then15, label %else16
then15:
  store i32 1, ptr %t4
  br label %ifend17
else16:
  %t36 = load ptr, ptr %t23
  %t37 = call i32 @fn_streq(ptr %t36, ptr @.str1422)
  %t38 = icmp ne i32 %t37, 0
  br i1 %t38, label %then18, label %else19
then18:
  store i32 1, ptr %t5
  br label %ifend20
else19:
  %t39 = load ptr, ptr %t23
  %t40 = call i32 @fn_streq(ptr %t39, ptr @.str1423)
  %t41 = icmp ne i32 %t40, 0
  br i1 %t41, label %then21, label %else22
then21:
  store i32 1, ptr %t6
  br label %ifend23
else22:
  %t42 = load ptr, ptr %t23
  %t43 = call i32 @fn_streq(ptr %t42, ptr @.str1424)
  %t44 = icmp ne i32 %t43, 0
  br i1 %t44, label %then24, label %else25
then24:
  %t45 = load i32, ptr %t13
  %t46 = add i32 %t45, 1
  store i32 %t46, ptr %t13
  %t47 = load i32, ptr %t13
  %t48 = load i32, ptr @L_argc
  %t49 = icmp slt i32 %t47, %t48
  %t50 = zext i1 %t49 to i32
  %t51 = icmp ne i32 %t50, 0
  br i1 %t51, label %then27, label %ifend29
then27:
  %t52 = load i32, ptr %t13
  %t53 = load ptr, ptr @L_argv
  %t54 = getelementptr ptr, ptr %t53, i32 %t52
  %t55 = load ptr, ptr %t54
  store ptr %t55, ptr %t1
  br label %ifend29
ifend29:
  br label %ifend26
else25:
  %t56 = load ptr, ptr %t23
  %t57 = getelementptr inbounds i8, ptr %t56, i32 0
  %t58 = load i8, ptr %t57
  %t59 = zext i8 %t58 to i32
  %t60 = icmp eq i32 %t59, 45
  %t61 = zext i1 %t60 to i32
  %t62 = icmp ne i32 %t61, 0
  br i1 %t62, label %then30, label %else31
then30:
  %t63 = load ptr, ptr %t23
  %t64 = call ptr @fn_sconcat(ptr %t63, ptr @.str1426)
  %t65 = call ptr @fn_sconcat(ptr @.str1425, ptr %t64)
  store ptr %t65, ptr %t66
  %t67 = load ptr, ptr @__stderrp
  %t68 = load ptr, ptr %t66
  %t69 = load ptr, ptr %t66
  %t70 = call i32 @fn_slen(ptr %t69)
  %t71 = zext i32 %t70 to i64
  %t72 = call i64 @fwrite(ptr %t68, i64 1, i64 %t71, ptr %t67)
  %t73 = trunc i64 %t72 to i32
  br label %ifend32
else31:
  %t74 = load ptr, ptr %t23
  store ptr %t74, ptr %t0
  br label %ifend32
ifend32:
  br label %ifend26
ifend26:
  br label %ifend23
ifend23:
  br label %ifend20
ifend20:
  br label %ifend17
ifend17:
  br label %ifend14
ifend14:
  br label %ifend11
ifend11:
  br label %ifend8
ifend8:
  %t75 = load i32, ptr %t13
  %t76 = add i32 %t75, 1
  store i32 %t76, ptr %t13
  br label %wcond3
wend5:
  %t77 = load ptr, ptr %t0
  %t78 = icmp eq ptr %t77, null
  %t79 = zext i1 %t78 to i32
  %t80 = icmp ne i32 %t79, 0
  br i1 %t80, label %then33, label %ifend35
then33:
  call void @fn_die(ptr @.str1427)
  br label %ifend35
ifend35:
  %t81 = load ptr, ptr %t0
  %t82 = call ptr @fn_read_file(ptr %t81)
  store ptr %t82, ptr %t83
  %t84 = load ptr, ptr %t83
  %t85 = icmp eq ptr %t84, null
  %t86 = zext i1 %t85 to i32
  %t87 = icmp ne i32 %t86, 0
  br i1 %t87, label %then36, label %ifend38
then36:
  call void @fn_die(ptr @.str1428)
  br label %ifend38
ifend38:
  %t88 = load ptr, ptr %t0
  %t89 = call ptr @fn_dir_of(ptr %t88)
  store ptr %t89, ptr @g_cur_dir
  %t90 = load ptr, ptr %t83
  call void @fn_lex(ptr %t90)
  call void @fn_parse_program()
  %t91 = load i32, ptr %t4
  %t92 = icmp ne i32 %t91, 0
  br i1 %t92, label %then39, label %ifend41
then39:
  call void @exit(i32 0)
  unreachable
ifend41:
  call void @fn_maybe_splice_runtime()
  %t94 = load i32, ptr %t6
  %t95 = icmp ne i32 %t94, 0
  %t96 = zext i1 %t95 to i32
  store i32 %t96, ptr %t93
  br i1 %t95, label %scend43, label %sc42
sc42:
  %t97 = load ptr, ptr %t1
  %t98 = icmp eq ptr %t97, null
  %t99 = zext i1 %t98 to i32
  %t100 = icmp eq i32 %t99, 0
  %t101 = zext i1 %t100 to i32
  %t102 = icmp ne i32 %t101, 0
  %t103 = zext i1 %t102 to i32
  store i32 %t103, ptr %t93
  br label %scend43
scend43:
  %t104 = load i32, ptr %t93
  store i32 %t104, ptr %t105
  %t106 = load i32, ptr %t2
  %t107 = icmp eq i32 %t106, 1
  %t108 = zext i1 %t107 to i32
  %t109 = icmp ne i32 %t108, 0
  br i1 %t109, label %then44, label %else45
then44:
  store i32 1, ptr @g_g_windowed
  br label %ifend46
else45:
  %t110 = load i32, ptr %t2
  %t111 = icmp eq i32 %t110, 2
  %t112 = zext i1 %t111 to i32
  %t113 = icmp ne i32 %t112, 0
  br i1 %t113, label %then47, label %else48
then47:
  store i32 0, ptr @g_g_windowed
  br label %ifend49
else48:
  %t115 = load i32, ptr %t105
  %t116 = icmp ne i32 %t115, 0
  %t117 = zext i1 %t116 to i32
  store i32 %t117, ptr %t114
  br i1 %t116, label %sc50, label %scend51
sc50:
  %t118 = call i32 @fn_has_systems()
  %t119 = icmp ne i32 %t118, 0
  %t120 = zext i1 %t119 to i32
  store i32 %t120, ptr %t114
  br label %scend51
scend51:
  %t121 = load i32, ptr %t114
  store i32 %t121, ptr @g_g_windowed
  br label %ifend49
ifend49:
  br label %ifend46
ifend46:
  call void @fn_emit_program()
  %t122 = load i32, ptr %t3
  %t123 = icmp ne i32 %t122, 0
  br i1 %t123, label %then52, label %ifend54
then52:
  %t124 = load ptr, ptr %t1
  %t125 = call i32 @fn_ir_flush(ptr %t124)
  br label %ret
ifend54:
  %t126 = load i32, ptr %t105
  %t127 = icmp eq i32 %t126, 0
  %t128 = zext i1 %t127 to i32
  %t129 = icmp ne i32 %t128, 0
  br i1 %t129, label %then55, label %ifend57
then55:
  %t130 = call i32 @fn_ir_flush(ptr null)
  br label %ret
ifend57:
  %t132 = load i32, ptr %t6
  %t133 = icmp ne i32 %t132, 0
  %t134 = zext i1 %t133 to i32
  store i32 %t134, ptr %t131
  br i1 %t133, label %sc58, label %scend59
sc58:
  %t135 = load ptr, ptr %t1
  %t136 = icmp eq ptr %t135, null
  %t137 = zext i1 %t136 to i32
  %t138 = icmp ne i32 %t137, 0
  %t139 = zext i1 %t138 to i32
  store i32 %t139, ptr %t131
  br label %scend59
scend59:
  %t140 = load i32, ptr %t131
  %t141 = icmp ne i32 %t140, 0
  br i1 %t141, label %then60, label %ifend62
then60:
  %t142 = load ptr, ptr %t0
  %t143 = call ptr @fn_base_name(ptr %t142)
  %t144 = call ptr @fn_strip_ludic(ptr %t143)
  %t145 = call ptr @fn_sconcat(ptr @.str1429, ptr %t144)
  store ptr %t145, ptr %t1
  br label %ifend62
ifend62:
  %t146 = load ptr, ptr %t1
  %t147 = call ptr @fn_dir_of(ptr %t146)
  store ptr %t147, ptr %t148
  %t149 = load ptr, ptr %t148
  %t150 = call i32 @fn_slen(ptr %t149)
  %t151 = icmp sgt i32 %t150, 0
  %t152 = zext i1 %t151 to i32
  %t153 = icmp ne i32 %t152, 0
  br i1 %t153, label %then63, label %ifend65
then63:
  %t154 = load ptr, ptr %t148
  %t155 = call ptr @fn_sconcat(ptr @.str1430, ptr %t154)
  %t156 = call i32 @system(ptr %t155)
  br label %ifend65
ifend65:
  %t157 = load ptr, ptr %t1
  %t158 = call ptr @fn_sconcat(ptr %t157, ptr @.str1431)
  store ptr %t158, ptr %t159
  %t160 = load ptr, ptr %t159
  %t161 = call i32 @fn_ir_flush(ptr %t160)
  %t162 = icmp eq i32 %t161, 0
  %t163 = zext i1 %t162 to i32
  %t164 = icmp ne i32 %t163, 0
  br i1 %t164, label %then66, label %ifend68
then66:
  call void @fn_die(ptr @.str1432)
  br label %ifend68
ifend68:
  %t165 = call ptr @fn_getenv_or(ptr @.str1433, ptr @.str1434)
  store ptr %t165, ptr %t166
  %t167 = load ptr, ptr @L_argv
  %t168 = getelementptr ptr, ptr %t167, i32 0
  %t169 = load ptr, ptr %t168
  %t170 = call ptr @fn_dir_of(ptr %t169)
  %t171 = call ptr @fn_getenv_or(ptr @.str1435, ptr %t170)
  %t172 = call ptr @fn_ensure_slash(ptr %t171)
  store ptr %t172, ptr %t173
  %t174 = load ptr, ptr %t166
  %t175 = load ptr, ptr %t159
  %t176 = call ptr @fn_sconcat(ptr @.str1436, ptr %t175)
  %t177 = call ptr @fn_sconcat(ptr %t174, ptr %t176)
  store ptr %t177, ptr %t178
  %t179 = load i32, ptr @g_g_windowed
  %t180 = icmp ne i32 %t179, 0
  br i1 %t180, label %then69, label %ifend71
then69:
  %t181 = load ptr, ptr %t173
  %t182 = call ptr @fn_path_join(ptr %t181, ptr @.str1437)
  store ptr %t182, ptr %t183
  %t184 = load ptr, ptr %t178
  %t185 = load ptr, ptr %t183
  %t186 = call ptr @fn_sconcat(ptr %t185, ptr @.str1439)
  %t187 = call ptr @fn_sconcat(ptr @.str1438, ptr %t186)
  %t188 = call ptr @fn_sconcat(ptr %t184, ptr %t187)
  store ptr %t188, ptr %t178
  br label %ifend71
ifend71:
  %t189 = load ptr, ptr %t178
  %t190 = load ptr, ptr %t1
  %t191 = call ptr @fn_sconcat(ptr @.str1440, ptr %t190)
  %t192 = call ptr @fn_sconcat(ptr %t189, ptr %t191)
  store ptr %t192, ptr %t178
  %t193 = load ptr, ptr %t178
  %t194 = call i32 @system(ptr %t193)
  store i32 %t194, ptr %t195
  %t196 = load i32, ptr %t5
  %t197 = icmp eq i32 %t196, 0
  %t198 = zext i1 %t197 to i32
  %t199 = icmp ne i32 %t198, 0
  br i1 %t199, label %then72, label %ifend74
then72:
  %t200 = load ptr, ptr %t159
  %t201 = call ptr @fn_sconcat(ptr @.str1441, ptr %t200)
  %t202 = call i32 @system(ptr %t201)
  br label %ifend74
ifend74:
  %t203 = load i32, ptr %t195
  %t204 = icmp ne i32 %t203, 0
  %t205 = zext i1 %t204 to i32
  %t206 = icmp ne i32 %t205, 0
  br i1 %t206, label %then75, label %ifend77
then75:
  call void @fn_die(ptr @.str1442)
  br label %ifend77
ifend77:
  %t207 = load i32, ptr %t6
  %t208 = icmp ne i32 %t207, 0
  br i1 %t208, label %then78, label %ifend80
then78:
  %t209 = load ptr, ptr %t1
  %t210 = call i32 @system(ptr %t209)
  store i32 %t210, ptr %t211
  %t212 = load i32, ptr %t211
  %t213 = lshr i32 %t212, 8
  %t214 = and i32 %t213, 255
  call void @exit(i32 %t214)
  unreachable
ifend80:
  br label %ret
ret:
  %t215 = load i32, ptr %retval
  ret i32 %t215
}
