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
%Cmp_Buf = type { ptr, i32, i32 }
%Cmp_Node = type { i32, ptr, i32, ptr, ptr, ptr, ptr, ptr, i32 }
%Cmp_Tok = type { i32, ptr, i32, i32 }
%Cmp_Val = type { ptr, ptr }
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
@g_loc_mut = internal global ptr null
@g_nloc = internal global i32 0
@g_g_uses_str = internal global i32 0
@g_brk_lbl = internal global ptr null
@g_cnt_lbl = internal global ptr null
@g_nloop = internal global i32 0
@g_ret_ty = internal global ptr null
@g_g_term = internal global i32 0
@g_self_stk = internal global ptr null
@g_nself = internal global i32 0
@g_mach_stk = internal global ptr null
@g_nmach = internal global i32 0
@g_g_computed = internal global ptr null
@g_g_onspawn = internal global ptr null
@g_g_ondespawn = internal global ptr null
@g_g_onattach = internal global ptr null
@g_g_onenable = internal global ptr null
@g_g_ondisable = internal global ptr null
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
@.str12 = private unnamed_addr constant [5 x i8] c"null\00"
@.str13 = private unnamed_addr constant [4 x i8] c"new\00"
@.str14 = private unnamed_addr constant [2 x i8] c"(\00"
@.str15 = private unnamed_addr constant [2 x i8] c")\00"
@.str16 = private unnamed_addr constant [20 x i8] c"expected expression\00"
@.str17 = private unnamed_addr constant [2 x i8] c".\00"
@.str18 = private unnamed_addr constant [2 x i8] c"[\00"
@.str19 = private unnamed_addr constant [2 x i8] c"]\00"
@.str20 = private unnamed_addr constant [2 x i8] c"(\00"
@.str21 = private unnamed_addr constant [2 x i8] c"-\00"
@.str22 = private unnamed_addr constant [2 x i8] c"-\00"
@.str23 = private unnamed_addr constant [2 x i8] c"~\00"
@.str24 = private unnamed_addr constant [2 x i8] c"~\00"
@.str25 = private unnamed_addr constant [4 x i8] c"not\00"
@.str26 = private unnamed_addr constant [4 x i8] c"not\00"
@.str27 = private unnamed_addr constant [2 x i8] c"*\00"
@.str28 = private unnamed_addr constant [2 x i8] c"/\00"
@.str29 = private unnamed_addr constant [2 x i8] c"%\00"
@.str30 = private unnamed_addr constant [3 x i8] c"<<\00"
@.str31 = private unnamed_addr constant [3 x i8] c">>\00"
@.str32 = private unnamed_addr constant [2 x i8] c"&\00"
@.str33 = private unnamed_addr constant [2 x i8] c"+\00"
@.str34 = private unnamed_addr constant [2 x i8] c"-\00"
@.str35 = private unnamed_addr constant [2 x i8] c"|\00"
@.str36 = private unnamed_addr constant [2 x i8] c"^\00"
@.str37 = private unnamed_addr constant [2 x i8] c"<\00"
@.str38 = private unnamed_addr constant [3 x i8] c"<=\00"
@.str39 = private unnamed_addr constant [2 x i8] c">\00"
@.str40 = private unnamed_addr constant [3 x i8] c">=\00"
@.str41 = private unnamed_addr constant [3 x i8] c"==\00"
@.str42 = private unnamed_addr constant [3 x i8] c"!=\00"
@.str43 = private unnamed_addr constant [4 x i8] c"and\00"
@.str44 = private unnamed_addr constant [4 x i8] c"and\00"
@.str45 = private unnamed_addr constant [3 x i8] c"or\00"
@.str46 = private unnamed_addr constant [3 x i8] c"or\00"
@.str47 = private unnamed_addr constant [2 x i8] c"{\00"
@.str48 = private unnamed_addr constant [2 x i8] c"}\00"
@.str49 = private unnamed_addr constant [2 x i8] c":\00"
@.str50 = private unnamed_addr constant [2 x i8] c",\00"
@.str51 = private unnamed_addr constant [2 x i8] c"}\00"
@.str52 = private unnamed_addr constant [2 x i8] c"{\00"
@.str53 = private unnamed_addr constant [2 x i8] c"}\00"
@.str54 = private unnamed_addr constant [2 x i8] c"}\00"
@.str55 = private unnamed_addr constant [43 x i8] c"expected newline or ';' between statements\00"
@.str56 = private unnamed_addr constant [2 x i8] c"}\00"
@.str57 = private unnamed_addr constant [4 x i8] c"let\00"
@.str58 = private unnamed_addr constant [4 x i8] c"var\00"
@.str59 = private unnamed_addr constant [4 x i8] c"var\00"
@.str60 = private unnamed_addr constant [2 x i8] c":\00"
@.str61 = private unnamed_addr constant [2 x i8] c"=\00"
@.str62 = private unnamed_addr constant [7 x i8] c"return\00"
@.str63 = private unnamed_addr constant [2 x i8] c"}\00"
@.str64 = private unnamed_addr constant [3 x i8] c"if\00"
@.str65 = private unnamed_addr constant [5 x i8] c"else\00"
@.str66 = private unnamed_addr constant [3 x i8] c"if\00"
@.str67 = private unnamed_addr constant [6 x i8] c"while\00"
@.str68 = private unnamed_addr constant [4 x i8] c"for\00"
@.str69 = private unnamed_addr constant [2 x i8] c"(\00"
@.str70 = private unnamed_addr constant [3 x i8] c"..\00"
@.str71 = private unnamed_addr constant [6 x i8] c"spawn\00"
@.str72 = private unnamed_addr constant [8 x i8] c"machine\00"
@.str73 = private unnamed_addr constant [2 x i8] c"{\00"
@.str74 = private unnamed_addr constant [2 x i8] c"}\00"
@.str75 = private unnamed_addr constant [2 x i8] c"=\00"
@.str76 = private unnamed_addr constant [2 x i8] c"}\00"
@.str77 = private unnamed_addr constant [7 x i8] c"become\00"
@.str78 = private unnamed_addr constant [8 x i8] c"despawn\00"
@.str79 = private unnamed_addr constant [7 x i8] c"enable\00"
@.str80 = private unnamed_addr constant [8 x i8] c"disable\00"
@.str81 = private unnamed_addr constant [7 x i8] c"enable\00"
@.str82 = private unnamed_addr constant [3 x i8] c"on\00"
@.str83 = private unnamed_addr constant [6 x i8] c"break\00"
@.str84 = private unnamed_addr constant [9 x i8] c"continue\00"
@.str85 = private unnamed_addr constant [6 x i8] c"match\00"
@.str86 = private unnamed_addr constant [2 x i8] c"{\00"
@.str87 = private unnamed_addr constant [2 x i8] c"}\00"
@.str88 = private unnamed_addr constant [2 x i8] c",\00"
@.str89 = private unnamed_addr constant [3 x i8] c"=>\00"
@.str90 = private unnamed_addr constant [2 x i8] c"{\00"
@.str91 = private unnamed_addr constant [2 x i8] c"}\00"
@.str92 = private unnamed_addr constant [2 x i8] c"=\00"
@.str93 = private unnamed_addr constant [3 x i8] c"+=\00"
@.str94 = private unnamed_addr constant [3 x i8] c"-=\00"
@.str95 = private unnamed_addr constant [3 x i8] c"*=\00"
@.str96 = private unnamed_addr constant [3 x i8] c"/=\00"
@.str97 = private unnamed_addr constant [2 x i8] c":\00"
@.str98 = private unnamed_addr constant [2 x i8] c"=\00"
@.str99 = private unnamed_addr constant [2 x i8] c":\00"
@.str100 = private unnamed_addr constant [2 x i8] c"=\00"
@.str101 = private unnamed_addr constant [2 x i8] c"(\00"
@.str102 = private unnamed_addr constant [2 x i8] c")\00"
@.str103 = private unnamed_addr constant [2 x i8] c":\00"
@.str104 = private unnamed_addr constant [2 x i8] c",\00"
@.str105 = private unnamed_addr constant [2 x i8] c")\00"
@.str106 = private unnamed_addr constant [5 x i8] c"void\00"
@.str107 = private unnamed_addr constant [3 x i8] c"->\00"
@.str108 = private unnamed_addr constant [1 x i8] c"\00"
@.str109 = private unnamed_addr constant [2 x i8] c"@\00"
@.str110 = private unnamed_addr constant [7 x i8] c"export\00"
@.str111 = private unnamed_addr constant [8 x i8] c"Queries\00"
@.str112 = private unnamed_addr constant [8 x i8] c"OnSpawn\00"
@.str113 = private unnamed_addr constant [2 x i8] c"(\00"
@.str114 = private unnamed_addr constant [2 x i8] c")\00"
@.str115 = private unnamed_addr constant [10 x i8] c"OnDespawn\00"
@.str116 = private unnamed_addr constant [2 x i8] c"(\00"
@.str117 = private unnamed_addr constant [2 x i8] c")\00"
@.str118 = private unnamed_addr constant [9 x i8] c"OnAttach\00"
@.str119 = private unnamed_addr constant [2 x i8] c"(\00"
@.str120 = private unnamed_addr constant [2 x i8] c")\00"
@.str121 = private unnamed_addr constant [9 x i8] c"OnEnable\00"
@.str122 = private unnamed_addr constant [2 x i8] c"(\00"
@.str123 = private unnamed_addr constant [2 x i8] c")\00"
@.str124 = private unnamed_addr constant [10 x i8] c"OnDisable\00"
@.str125 = private unnamed_addr constant [2 x i8] c"(\00"
@.str126 = private unnamed_addr constant [2 x i8] c")\00"
@.str127 = private unnamed_addr constant [8 x i8] c"OnStart\00"
@.str128 = private unnamed_addr constant [6 x i8] c"Start\00"
@.str129 = private unnamed_addr constant [7 x i8] c"OnQuit\00"
@.str130 = private unnamed_addr constant [7 x i8] c"OnQuit\00"
@.str131 = private unnamed_addr constant [2 x i8] c"(\00"
@.str132 = private unnamed_addr constant [2 x i8] c"(\00"
@.str133 = private unnamed_addr constant [2 x i8] c")\00"
@.str134 = private unnamed_addr constant [7 x i8] c"import\00"
@.str135 = private unnamed_addr constant [29 x i8] c"expected \22path\22 after import\00"
@.str136 = private unnamed_addr constant [5 x i8] c"enum\00"
@.str137 = private unnamed_addr constant [9 x i8] c"property\00"
@.str138 = private unnamed_addr constant [6 x i8] c"model\00"
@.str139 = private unnamed_addr constant [8 x i8] c"handler\00"
@.str140 = private unnamed_addr constant [3 x i8] c"ui\00"
@.str141 = private unnamed_addr constant [4 x i8] c"var\00"
@.str142 = private unnamed_addr constant [6 x i8] c"const\00"
@.str143 = private unnamed_addr constant [3 x i8] c"fn\00"
@.str144 = private unnamed_addr constant [7 x i8] c"extern\00"
@.str145 = private unnamed_addr constant [6 x i8] c"entry\00"
@.str146 = private unnamed_addr constant [21 x i8] c"expected declaration\00"
@.str147 = private unnamed_addr constant [20 x i8] c"cannot open import \00"
@.str148 = private unnamed_addr constant [1 x i8] c"\00"
@.str149 = private unnamed_addr constant [26 x i8] c"runtime/native/core.ludic\00"
@.str150 = private unnamed_addr constant [6 x i8] c"Ludic\00"
@.str151 = private unnamed_addr constant [7 x i8] c"import\00"
@.str152 = private unnamed_addr constant [2 x i8] c"@\00"
@.str153 = private unnamed_addr constant [2 x i8] c"(\00"
@.str154 = private unnamed_addr constant [2 x i8] c"(\00"
@.str155 = private unnamed_addr constant [2 x i8] c")\00"
@.str156 = private unnamed_addr constant [8 x i8] c"program\00"
@.str157 = private unnamed_addr constant [2 x i8] c"{\00"
@.str158 = private unnamed_addr constant [2 x i8] c"}\00"
@.str159 = private unnamed_addr constant [2 x i8] c"{\00"
@.str160 = private unnamed_addr constant [2 x i8] c"}\00"
@.str161 = private unnamed_addr constant [2 x i8] c"@\00"
@.str162 = private unnamed_addr constant [9 x i8] c"Computed\00"
@.str163 = private unnamed_addr constant [2 x i8] c":\00"
@.str164 = private unnamed_addr constant [2 x i8] c"=\00"
@.str165 = private unnamed_addr constant [2 x i8] c",\00"
@.str166 = private unnamed_addr constant [2 x i8] c"}\00"
@.str167 = private unnamed_addr constant [7 x i8] c"Update\00"
@.str168 = private unnamed_addr constant [2 x i8] c"@\00"
@.str169 = private unnamed_addr constant [2 x i8] c"(\00"
@.str170 = private unnamed_addr constant [2 x i8] c"(\00"
@.str171 = private unnamed_addr constant [2 x i8] c")\00"
@.str172 = private unnamed_addr constant [6 x i8] c"phase\00"
@.str173 = private unnamed_addr constant [2 x i8] c"[\00"
@.str174 = private unnamed_addr constant [2 x i8] c"]\00"
@.str175 = private unnamed_addr constant [2 x i8] c"{\00"
@.str176 = private unnamed_addr constant [2 x i8] c"}\00"
@.str177 = private unnamed_addr constant [2 x i8] c",\00"
@.str178 = private unnamed_addr constant [2 x i8] c"]\00"
@.str179 = private unnamed_addr constant [6 x i8] c"where\00"
@.str180 = private unnamed_addr constant [2 x i8] c"(\00"
@.str181 = private unnamed_addr constant [2 x i8] c")\00"
@.str182 = private unnamed_addr constant [2 x i8] c",\00"
@.str183 = private unnamed_addr constant [2 x i8] c")\00"
@.str184 = private unnamed_addr constant [6 x i8] c"query\00"
@.str185 = private unnamed_addr constant [29 x i8] c"expected 'query' in for-loop\00"
@.str186 = private unnamed_addr constant [4 x i8] c"and\00"
@.str187 = private unnamed_addr constant [2 x i8] c"(\00"
@.str188 = private unnamed_addr constant [2 x i8] c")\00"
@.str189 = private unnamed_addr constant [2 x i8] c")\00"
@.str190 = private unnamed_addr constant [2 x i8] c":\00"
@.str191 = private unnamed_addr constant [6 x i8] c"these\00"
@.str192 = private unnamed_addr constant [2 x i8] c"[\00"
@.str193 = private unnamed_addr constant [2 x i8] c"]\00"
@.str194 = private unnamed_addr constant [2 x i8] c"{\00"
@.str195 = private unnamed_addr constant [2 x i8] c"}\00"
@.str196 = private unnamed_addr constant [2 x i8] c",\00"
@.str197 = private unnamed_addr constant [2 x i8] c"]\00"
@.str198 = private unnamed_addr constant [3 x i8] c"on\00"
@.str199 = private unnamed_addr constant [2 x i8] c",\00"
@.str200 = private unnamed_addr constant [2 x i8] c")\00"
@.str201 = private unnamed_addr constant [2 x i8] c"{\00"
@.str202 = private unnamed_addr constant [2 x i8] c"}\00"
@.str203 = private unnamed_addr constant [2 x i8] c",\00"
@.str204 = private unnamed_addr constant [2 x i8] c"}\00"
@.str205 = private unnamed_addr constant [2 x i8] c"{\00"
@.str206 = private unnamed_addr constant [2 x i8] c"}\00"
@.str207 = private unnamed_addr constant [2 x i8] c",\00"
@.str208 = private unnamed_addr constant [2 x i8] c"}\00"
@.str209 = private unnamed_addr constant [2 x i8] c"{\00"
@.str210 = private unnamed_addr constant [2 x i8] c"}\00"
@.str211 = private unnamed_addr constant [2 x i8] c",\00"
@.str212 = private unnamed_addr constant [2 x i8] c"}\00"
@.str213 = private unnamed_addr constant [2 x i8] c"(\00"
@.str214 = private unnamed_addr constant [2 x i8] c")\00"
@.str215 = private unnamed_addr constant [2 x i8] c":\00"
@.str216 = private unnamed_addr constant [2 x i8] c",\00"
@.str217 = private unnamed_addr constant [2 x i8] c")\00"
@.str218 = private unnamed_addr constant [5 x i8] c"void\00"
@.str219 = private unnamed_addr constant [3 x i8] c"->\00"
@.str220 = private unnamed_addr constant [2 x i8] c"=\00"
@.str221 = private unnamed_addr constant [2 x i8] c":\00"
@.str222 = private unnamed_addr constant [2 x i8] c":\00"
@.str223 = private unnamed_addr constant [2 x i8] c"{\00"
@.str224 = private unnamed_addr constant [2 x i8] c"}\00"
@.str225 = private unnamed_addr constant [2 x i8] c"}\00"
@.str226 = private unnamed_addr constant [2 x i8] c"{\00"
@.str227 = private unnamed_addr constant [2 x i8] c"}\00"
@.str228 = private unnamed_addr constant [3 x i8] c"%t\00"
@.str229 = private unnamed_addr constant [3 x i8] c"  \00"
@.str230 = private unnamed_addr constant [11 x i8] c" = alloca \00"
@.str231 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str232 = private unnamed_addr constant [3 x i8] c"%t\00"
@.str233 = private unnamed_addr constant [4 x i8] c"int\00"
@.str234 = private unnamed_addr constant [5 x i8] c"bool\00"
@.str235 = private unnamed_addr constant [6 x i8] c"fixed\00"
@.str236 = private unnamed_addr constant [4 x i8] c"i32\00"
@.str237 = private unnamed_addr constant [5 x i8] c"void\00"
@.str238 = private unnamed_addr constant [5 x i8] c"void\00"
@.str239 = private unnamed_addr constant [4 x i8] c"ptr\00"
@.str240 = private unnamed_addr constant [6 x i8] c"%Cmp_\00"
@.str241 = private unnamed_addr constant [4 x i8] c"int\00"
@.str242 = private unnamed_addr constant [2 x i8] c".\00"
@.str243 = private unnamed_addr constant [2 x i8] c".\00"
@.str244 = private unnamed_addr constant [6 x i8] c"@.str\00"
@.str245 = private unnamed_addr constant [35 x i8] c" = private unnamed_addr constant [\00"
@.str246 = private unnamed_addr constant [10 x i8] c" x i8] c\22\00"
@.str247 = private unnamed_addr constant [6 x i8] c"\5C00\22\0A\00"
@.str248 = private unnamed_addr constant [3 x i8] c"  \00"
@.str249 = private unnamed_addr constant [35 x i8] c" = getelementptr inbounds i8, ptr \00"
@.str250 = private unnamed_addr constant [7 x i8] c", i32 \00"
@.str251 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str252 = private unnamed_addr constant [4 x i8] c"ptr\00"
@.str253 = private unnamed_addr constant [5 x i8] c"null\00"
@.str254 = private unnamed_addr constant [2 x i8] c"0\00"
@.str255 = private unnamed_addr constant [2 x i8] c"-\00"
@.str256 = private unnamed_addr constant [2 x i8] c"-\00"
@.str257 = private unnamed_addr constant [4 x i8] c"ptr\00"
@.str258 = private unnamed_addr constant [5 x i8] c"null\00"
@.str259 = private unnamed_addr constant [2 x i8] c"0\00"
@.str260 = private unnamed_addr constant [34 x i8] c"; Ludic (self-hosted) -> LLVM IR\0A\00"
@.str261 = private unnamed_addr constant [31 x i8] c"declare i32 @printf(ptr, ...)\0A\00"
@.str262 = private unnamed_addr constant [26 x i8] c"declare ptr @malloc(i64)\0A\00"
@.str263 = private unnamed_addr constant [32 x i8] c"declare ptr @realloc(ptr, i64)\0A\00"
@.str264 = private unnamed_addr constant [25 x i8] c"declare void @free(ptr)\0A\00"
@.str265 = private unnamed_addr constant [30 x i8] c"declare ptr @fopen(ptr, ptr)\0A\00"
@.str266 = private unnamed_addr constant [40 x i8] c"declare i64 @fread(ptr, i64, i64, ptr)\0A\00"
@.str267 = private unnamed_addr constant [41 x i8] c"declare i64 @fwrite(ptr, i64, i64, ptr)\0A\00"
@.str268 = private unnamed_addr constant [35 x i8] c"declare i32 @fseek(ptr, i64, i32)\0A\00"
@.str269 = private unnamed_addr constant [25 x i8] c"declare i64 @ftell(ptr)\0A\00"
@.str270 = private unnamed_addr constant [26 x i8] c"declare i32 @fclose(ptr)\0A\00"
@.str271 = private unnamed_addr constant [25 x i8] c"declare void @exit(i32)\0A\00"
@.str272 = private unnamed_addr constant [26 x i8] c"declare i32 @system(ptr)\0A\00"
@.str273 = private unnamed_addr constant [26 x i8] c"declare ptr @getenv(ptr)\0A\00"
@.str274 = private unnamed_addr constant [36 x i8] c"declare ptr @memcpy(ptr, ptr, i64)\0A\00"
@.str275 = private unnamed_addr constant [36 x i8] c"declare ptr @memset(ptr, i32, i64)\0A\00"
@.str276 = private unnamed_addr constant [26 x i8] c"declare i64 @strlen(ptr)\0A\00"
@.str277 = private unnamed_addr constant [24 x i8] c"declare i32 @getchar()\0A\00"
@.str278 = private unnamed_addr constant [27 x i8] c"declare i32 @putchar(i32)\0A\00"
@.str279 = private unnamed_addr constant [24 x i8] c"declare i64 @time(ptr)\0A\00"
@.str280 = private unnamed_addr constant [44 x i8] c"declare void @win_open(i32, i32, i32, ptr)\0A\00"
@.str281 = private unnamed_addr constant [25 x i8] c"declare i32 @win_poll()\0A\00"
@.str282 = private unnamed_addr constant [42 x i8] c"declare void @win_present(ptr, i32, i32)\0A\00"
@.str283 = private unnamed_addr constant [28 x i8] c"declare i32 @win_running()\0A\00"
@.str284 = private unnamed_addr constant [27 x i8] c"declare void @win_close()\0A\00"
@.str285 = private unnamed_addr constant [34 x i8] c"@__stderrp = external global ptr\0A\00"
@.str286 = private unnamed_addr constant [61 x i8] c"@.fmt_str = private unnamed_addr constant [3 x i8] c\22%s\5C00\22\0A\00"
@.str287 = private unnamed_addr constant [64 x i8] c"@.fmt_int = private unnamed_addr constant [4 x i8] c\22%d\5C0A\5C00\22\0A\00"
@.str288 = private unnamed_addr constant [33 x i8] c"@L_argc = internal global i32 0\0A\00"
@.str289 = private unnamed_addr constant [36 x i8] c"@L_argv = internal global ptr null\0A\00"
@.str290 = private unnamed_addr constant [46 x i8] c"@.gametitle = private unnamed_addr constant [\00"
@.str291 = private unnamed_addr constant [10 x i8] c" x i8] c\22\00"
@.str292 = private unnamed_addr constant [6 x i8] c"\5C00\22\0A\00"
@.str293 = private unnamed_addr constant [34 x i8] c"%LSlice = type { ptr, i32, i32 }\0A\00"
@.str294 = private unnamed_addr constant [11 x i8] c" = type { \00"
@.str295 = private unnamed_addr constant [4 x i8] c"i32\00"
@.str296 = private unnamed_addr constant [3 x i8] c", \00"
@.str297 = private unnamed_addr constant [4 x i8] c" }\0A\00"
@.str298 = private unnamed_addr constant [4 x i8] c"@g_\00"
@.str299 = private unnamed_addr constant [20 x i8] c" = internal global \00"
@.str300 = private unnamed_addr constant [2 x i8] c" \00"
@.str301 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str302 = private unnamed_addr constant [41 x i8] c"define i32 @fn_str_eq(ptr %a, ptr %b) {\0A\00"
@.str303 = private unnamed_addr constant [25 x i8] c"entry:\0A  br label %loop\0A\00"
@.str304 = private unnamed_addr constant [52 x i8] c"loop:\0A  %i = phi i32 [ 0, %entry ], [ %i1, %cont ]\0A\00"
@.str305 = private unnamed_addr constant [51 x i8] c"  %pa = getelementptr inbounds i8, ptr %a, i32 %i\0A\00"
@.str306 = private unnamed_addr constant [51 x i8] c"  %pb = getelementptr inbounds i8, ptr %b, i32 %i\0A\00"
@.str307 = private unnamed_addr constant [51 x i8] c"  %ca = load i8, ptr %pa\0A  %cb = load i8, ptr %pb\0A\00"
@.str308 = private unnamed_addr constant [66 x i8] c"  %df = icmp ne i8 %ca, %cb\0A  br i1 %df, label %ret0, label %chk\0A\00"
@.str309 = private unnamed_addr constant [70 x i8] c"chk:\0A  %zt = icmp eq i8 %ca, 0\0A  br i1 %zt, label %ret1, label %cont\0A\00"
@.str310 = private unnamed_addr constant [46 x i8] c"cont:\0A  %i1 = add i32 %i, 1\0A  br label %loop\0A\00"
@.str311 = private unnamed_addr constant [39 x i8] c"ret1:\0A  ret i32 1\0Aret0:\0A  ret i32 0\0A}\0A\00"
@.str312 = private unnamed_addr constant [45 x i8] c"define ptr @fn_str_concat(ptr %a, ptr %b) {\0A\00"
@.str313 = private unnamed_addr constant [23 x i8] c"entry:\0A  br label %al\0A\00"
@.str314 = private unnamed_addr constant [51 x i8] c"al:\0A  %ia = phi i32 [ 0, %entry ], [ %ia1, %alb ]\0A\00"
@.str315 = private unnamed_addr constant [78 x i8] c"  %pa = getelementptr inbounds i8, ptr %a, i32 %ia\0A  %cca = load i8, ptr %pa\0A\00"
@.str316 = private unnamed_addr constant [64 x i8] c"  %za = icmp eq i8 %cca, 0\0A  br i1 %za, label %bl0, label %alb\0A\00"
@.str317 = private unnamed_addr constant [45 x i8] c"alb:\0A  %ia1 = add i32 %ia, 1\0A  br label %al\0A\00"
@.str318 = private unnamed_addr constant [21 x i8] c"bl0:\0A  br label %bl\0A\00"
@.str319 = private unnamed_addr constant [49 x i8] c"bl:\0A  %ib = phi i32 [ 0, %bl0 ], [ %ib1, %blb ]\0A\00"
@.str320 = private unnamed_addr constant [78 x i8] c"  %pb = getelementptr inbounds i8, ptr %b, i32 %ib\0A  %ccb = load i8, ptr %pb\0A\00"
@.str321 = private unnamed_addr constant [66 x i8] c"  %zb = icmp eq i8 %ccb, 0\0A  br i1 %zb, label %alloc, label %blb\0A\00"
@.str322 = private unnamed_addr constant [45 x i8] c"blb:\0A  %ib1 = add i32 %ib, 1\0A  br label %bl\0A\00"
@.str323 = private unnamed_addr constant [58 x i8] c"alloc:\0A  %sum = add i32 %ia, %ib\0A  %sz = add i32 %sum, 1\0A\00"
@.str324 = private unnamed_addr constant [83 x i8] c"  %sz64 = sext i32 %sz to i64\0A  %out = call ptr @malloc(i64 %sz64)\0A  br label %c1\0A\00"
@.str325 = private unnamed_addr constant [49 x i8] c"c1:\0A  %i = phi i32 [ 0, %alloc ], [ %i1, %c1b ]\0A\00"
@.str326 = private unnamed_addr constant [66 x i8] c"  %d1 = icmp slt i32 %i, %ia\0A  br i1 %d1, label %c1b, label %c2i\0A\00"
@.str327 = private unnamed_addr constant [81 x i8] c"c1b:\0A  %s1 = getelementptr inbounds i8, ptr %a, i32 %i\0A  %v1 = load i8, ptr %s1\0A\00"
@.str328 = private unnamed_addr constant [77 x i8] c"  %o1 = getelementptr inbounds i8, ptr %out, i32 %i\0A  store i8 %v1, ptr %o1\0A\00"
@.str329 = private unnamed_addr constant [38 x i8] c"  %i1 = add i32 %i, 1\0A  br label %c1\0A\00"
@.str330 = private unnamed_addr constant [21 x i8] c"c2i:\0A  br label %c2\0A\00"
@.str331 = private unnamed_addr constant [47 x i8] c"c2:\0A  %j = phi i32 [ 0, %c2i ], [ %j1, %c2b ]\0A\00"
@.str332 = private unnamed_addr constant [66 x i8] c"  %d2 = icmp slt i32 %j, %ib\0A  br i1 %d2, label %c2b, label %fin\0A\00"
@.str333 = private unnamed_addr constant [81 x i8] c"c2b:\0A  %s2 = getelementptr inbounds i8, ptr %b, i32 %j\0A  %v2 = load i8, ptr %s2\0A\00"
@.str334 = private unnamed_addr constant [102 x i8] c"  %oj = add i32 %ia, %j\0A  %o2 = getelementptr inbounds i8, ptr %out, i32 %oj\0A  store i8 %v2, ptr %o2\0A\00"
@.str335 = private unnamed_addr constant [38 x i8] c"  %j1 = add i32 %j, 1\0A  br label %c2\0A\00"
@.str336 = private unnamed_addr constant [99 x i8] c"fin:\0A  %pe = getelementptr inbounds i8, ptr %out, i32 %sum\0A  store i8 0, ptr %pe\0A  ret ptr %out\0A}\0A\00"
@.str337 = private unnamed_addr constant [32 x i8] c"member access on non-aggregate \00"
@.str338 = private unnamed_addr constant [15 x i8] c"no such field \00"
@.str339 = private unnamed_addr constant [3 x i8] c"  \00"
@.str340 = private unnamed_addr constant [27 x i8] c" = getelementptr inbounds \00"
@.str341 = private unnamed_addr constant [7 x i8] c", ptr \00"
@.str342 = private unnamed_addr constant [14 x i8] c", i32 0, i32 \00"
@.str343 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str344 = private unnamed_addr constant [21 x i8] c"indexing a non-slice\00"
@.str345 = private unnamed_addr constant [3 x i8] c"  \00"
@.str346 = private unnamed_addr constant [40 x i8] c" = getelementptr inbounds %LSlice, ptr \00"
@.str347 = private unnamed_addr constant [16 x i8] c", i32 0, i32 0\0A\00"
@.str348 = private unnamed_addr constant [3 x i8] c"  \00"
@.str349 = private unnamed_addr constant [18 x i8] c" = load ptr, ptr \00"
@.str350 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str351 = private unnamed_addr constant [3 x i8] c"  \00"
@.str352 = private unnamed_addr constant [27 x i8] c" = getelementptr inbounds \00"
@.str353 = private unnamed_addr constant [7 x i8] c", ptr \00"
@.str354 = private unnamed_addr constant [7 x i8] c", i32 \00"
@.str355 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str356 = private unnamed_addr constant [10 x i8] c"mem_alloc\00"
@.str357 = private unnamed_addr constant [12 x i8] c"mem_realloc\00"
@.str358 = private unnamed_addr constant [6 x i8] c"peek8\00"
@.str359 = private unnamed_addr constant [6 x i8] c"poke8\00"
@.str360 = private unnamed_addr constant [10 x i8] c"file_open\00"
@.str361 = private unnamed_addr constant [10 x i8] c"file_read\00"
@.str362 = private unnamed_addr constant [11 x i8] c"file_write\00"
@.str363 = private unnamed_addr constant [10 x i8] c"file_seek\00"
@.str364 = private unnamed_addr constant [10 x i8] c"file_tell\00"
@.str365 = private unnamed_addr constant [11 x i8] c"file_close\00"
@.str366 = private unnamed_addr constant [10 x i8] c"print_str\00"
@.str367 = private unnamed_addr constant [10 x i8] c"print_int\00"
@.str368 = private unnamed_addr constant [8 x i8] c"os_argc\00"
@.str369 = private unnamed_addr constant [7 x i8] c"os_arg\00"
@.str370 = private unnamed_addr constant [8 x i8] c"os_exit\00"
@.str371 = private unnamed_addr constant [12 x i8] c"file_stderr\00"
@.str372 = private unnamed_addr constant [10 x i8] c"os_system\00"
@.str373 = private unnamed_addr constant [10 x i8] c"os_getenv\00"
@.str374 = private unnamed_addr constant [7 x i8] c"peek32\00"
@.str375 = private unnamed_addr constant [7 x i8] c"poke32\00"
@.str376 = private unnamed_addr constant [3 x i8] c"  \00"
@.str377 = private unnamed_addr constant [4 x i8] c" = \00"
@.str378 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str379 = private unnamed_addr constant [10 x i8] c"mem_alloc\00"
@.str380 = private unnamed_addr constant [10 x i8] c"zext i32 \00"
@.str381 = private unnamed_addr constant [8 x i8] c" to i64\00"
@.str382 = private unnamed_addr constant [22 x i8] c"call ptr @malloc(i64 \00"
@.str383 = private unnamed_addr constant [2 x i8] c")\00"
@.str384 = private unnamed_addr constant [4 x i8] c"ptr\00"
@.str385 = private unnamed_addr constant [12 x i8] c"mem_realloc\00"
@.str386 = private unnamed_addr constant [10 x i8] c"zext i32 \00"
@.str387 = private unnamed_addr constant [8 x i8] c" to i64\00"
@.str388 = private unnamed_addr constant [23 x i8] c"call ptr @realloc(ptr \00"
@.str389 = private unnamed_addr constant [7 x i8] c", i64 \00"
@.str390 = private unnamed_addr constant [2 x i8] c")\00"
@.str391 = private unnamed_addr constant [4 x i8] c"ptr\00"
@.str392 = private unnamed_addr constant [6 x i8] c"peek8\00"
@.str393 = private unnamed_addr constant [14 x i8] c"load i8, ptr \00"
@.str394 = private unnamed_addr constant [9 x i8] c"zext i8 \00"
@.str395 = private unnamed_addr constant [8 x i8] c" to i32\00"
@.str396 = private unnamed_addr constant [4 x i8] c"int\00"
@.str397 = private unnamed_addr constant [6 x i8] c"poke8\00"
@.str398 = private unnamed_addr constant [11 x i8] c"trunc i32 \00"
@.str399 = private unnamed_addr constant [7 x i8] c" to i8\00"
@.str400 = private unnamed_addr constant [12 x i8] c"  store i8 \00"
@.str401 = private unnamed_addr constant [7 x i8] c", ptr \00"
@.str402 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str403 = private unnamed_addr constant [2 x i8] c"0\00"
@.str404 = private unnamed_addr constant [5 x i8] c"void\00"
@.str405 = private unnamed_addr constant [10 x i8] c"file_open\00"
@.str406 = private unnamed_addr constant [21 x i8] c"call ptr @fopen(ptr \00"
@.str407 = private unnamed_addr constant [7 x i8] c", ptr \00"
@.str408 = private unnamed_addr constant [2 x i8] c")\00"
@.str409 = private unnamed_addr constant [4 x i8] c"ptr\00"
@.str410 = private unnamed_addr constant [10 x i8] c"file_read\00"
@.str411 = private unnamed_addr constant [11 x i8] c"file_write\00"
@.str412 = private unnamed_addr constant [10 x i8] c"zext i32 \00"
@.str413 = private unnamed_addr constant [8 x i8] c" to i64\00"
@.str414 = private unnamed_addr constant [7 x i8] c"@fread\00"
@.str415 = private unnamed_addr constant [11 x i8] c"file_write\00"
@.str416 = private unnamed_addr constant [8 x i8] c"@fwrite\00"
@.str417 = private unnamed_addr constant [10 x i8] c"call i64 \00"
@.str418 = private unnamed_addr constant [6 x i8] c"(ptr \00"
@.str419 = private unnamed_addr constant [14 x i8] c", i64 1, i64 \00"
@.str420 = private unnamed_addr constant [7 x i8] c", ptr \00"
@.str421 = private unnamed_addr constant [2 x i8] c")\00"
@.str422 = private unnamed_addr constant [11 x i8] c"trunc i64 \00"
@.str423 = private unnamed_addr constant [8 x i8] c" to i32\00"
@.str424 = private unnamed_addr constant [4 x i8] c"int\00"
@.str425 = private unnamed_addr constant [10 x i8] c"file_seek\00"
@.str426 = private unnamed_addr constant [10 x i8] c"sext i32 \00"
@.str427 = private unnamed_addr constant [8 x i8] c" to i64\00"
@.str428 = private unnamed_addr constant [21 x i8] c"call i32 @fseek(ptr \00"
@.str429 = private unnamed_addr constant [7 x i8] c", i64 \00"
@.str430 = private unnamed_addr constant [7 x i8] c", i32 \00"
@.str431 = private unnamed_addr constant [2 x i8] c")\00"
@.str432 = private unnamed_addr constant [4 x i8] c"int\00"
@.str433 = private unnamed_addr constant [10 x i8] c"file_tell\00"
@.str434 = private unnamed_addr constant [21 x i8] c"call i64 @ftell(ptr \00"
@.str435 = private unnamed_addr constant [2 x i8] c")\00"
@.str436 = private unnamed_addr constant [11 x i8] c"trunc i64 \00"
@.str437 = private unnamed_addr constant [8 x i8] c" to i32\00"
@.str438 = private unnamed_addr constant [4 x i8] c"int\00"
@.str439 = private unnamed_addr constant [11 x i8] c"file_close\00"
@.str440 = private unnamed_addr constant [24 x i8] c"  call i32 @fclose(ptr \00"
@.str441 = private unnamed_addr constant [3 x i8] c")\0A\00"
@.str442 = private unnamed_addr constant [2 x i8] c"0\00"
@.str443 = private unnamed_addr constant [5 x i8] c"void\00"
@.str444 = private unnamed_addr constant [10 x i8] c"print_str\00"
@.str445 = private unnamed_addr constant [50 x i8] c"  call i32 (ptr, ...) @printf(ptr @.fmt_str, ptr \00"
@.str446 = private unnamed_addr constant [3 x i8] c")\0A\00"
@.str447 = private unnamed_addr constant [2 x i8] c"0\00"
@.str448 = private unnamed_addr constant [5 x i8] c"void\00"
@.str449 = private unnamed_addr constant [10 x i8] c"print_int\00"
@.str450 = private unnamed_addr constant [50 x i8] c"  call i32 (ptr, ...) @printf(ptr @.fmt_int, i32 \00"
@.str451 = private unnamed_addr constant [3 x i8] c")\0A\00"
@.str452 = private unnamed_addr constant [2 x i8] c"0\00"
@.str453 = private unnamed_addr constant [5 x i8] c"void\00"
@.str454 = private unnamed_addr constant [8 x i8] c"os_argc\00"
@.str455 = private unnamed_addr constant [22 x i8] c"load i32, ptr @L_argc\00"
@.str456 = private unnamed_addr constant [4 x i8] c"int\00"
@.str457 = private unnamed_addr constant [7 x i8] c"os_arg\00"
@.str458 = private unnamed_addr constant [22 x i8] c"load ptr, ptr @L_argv\00"
@.str459 = private unnamed_addr constant [24 x i8] c"getelementptr ptr, ptr \00"
@.str460 = private unnamed_addr constant [7 x i8] c", i32 \00"
@.str461 = private unnamed_addr constant [15 x i8] c"load ptr, ptr \00"
@.str462 = private unnamed_addr constant [4 x i8] c"str\00"
@.str463 = private unnamed_addr constant [8 x i8] c"os_exit\00"
@.str464 = private unnamed_addr constant [23 x i8] c"  call void @exit(i32 \00"
@.str465 = private unnamed_addr constant [3 x i8] c")\0A\00"
@.str466 = private unnamed_addr constant [15 x i8] c"  unreachable\0A\00"
@.str467 = private unnamed_addr constant [2 x i8] c"0\00"
@.str468 = private unnamed_addr constant [5 x i8] c"void\00"
@.str469 = private unnamed_addr constant [12 x i8] c"file_stderr\00"
@.str470 = private unnamed_addr constant [25 x i8] c"load ptr, ptr @__stderrp\00"
@.str471 = private unnamed_addr constant [4 x i8] c"ptr\00"
@.str472 = private unnamed_addr constant [10 x i8] c"os_system\00"
@.str473 = private unnamed_addr constant [22 x i8] c"call i32 @system(ptr \00"
@.str474 = private unnamed_addr constant [2 x i8] c")\00"
@.str475 = private unnamed_addr constant [4 x i8] c"int\00"
@.str476 = private unnamed_addr constant [10 x i8] c"os_getenv\00"
@.str477 = private unnamed_addr constant [22 x i8] c"call ptr @getenv(ptr \00"
@.str478 = private unnamed_addr constant [2 x i8] c")\00"
@.str479 = private unnamed_addr constant [4 x i8] c"str\00"
@.str480 = private unnamed_addr constant [7 x i8] c"peek32\00"
@.str481 = private unnamed_addr constant [3 x i8] c"  \00"
@.str482 = private unnamed_addr constant [36 x i8] c" = getelementptr inbounds i32, ptr \00"
@.str483 = private unnamed_addr constant [7 x i8] c", i32 \00"
@.str484 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str485 = private unnamed_addr constant [15 x i8] c"load i32, ptr \00"
@.str486 = private unnamed_addr constant [4 x i8] c"int\00"
@.str487 = private unnamed_addr constant [7 x i8] c"poke32\00"
@.str488 = private unnamed_addr constant [3 x i8] c"  \00"
@.str489 = private unnamed_addr constant [36 x i8] c" = getelementptr inbounds i32, ptr \00"
@.str490 = private unnamed_addr constant [7 x i8] c", i32 \00"
@.str491 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str492 = private unnamed_addr constant [13 x i8] c"  store i32 \00"
@.str493 = private unnamed_addr constant [7 x i8] c", ptr \00"
@.str494 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str495 = private unnamed_addr constant [2 x i8] c"0\00"
@.str496 = private unnamed_addr constant [5 x i8] c"void\00"
@.str497 = private unnamed_addr constant [2 x i8] c"0\00"
@.str498 = private unnamed_addr constant [5 x i8] c"void\00"
@.str499 = private unnamed_addr constant [9 x i8] c"mem_free\00"
@.str500 = private unnamed_addr constant [9 x i8] c"mem_copy\00"
@.str501 = private unnamed_addr constant [8 x i8] c"mem_set\00"
@.str502 = private unnamed_addr constant [8 x i8] c"ptr_add\00"
@.str503 = private unnamed_addr constant [10 x i8] c"read_byte\00"
@.str504 = private unnamed_addr constant [11 x i8] c"write_byte\00"
@.str505 = private unnamed_addr constant [8 x i8] c"str_len\00"
@.str506 = private unnamed_addr constant [8 x i8] c"os_time\00"
@.str507 = private unnamed_addr constant [6 x i8] c"peekf\00"
@.str508 = private unnamed_addr constant [6 x i8] c"pokef\00"
@.str509 = private unnamed_addr constant [9 x i8] c"as_fixed\00"
@.str510 = private unnamed_addr constant [7 x i8] c"as_int\00"
@.str511 = private unnamed_addr constant [6 x i8] c"peekp\00"
@.str512 = private unnamed_addr constant [6 x i8] c"pokep\00"
@.str513 = private unnamed_addr constant [12 x i8] c"is_windowed\00"
@.str514 = private unnamed_addr constant [11 x i8] c"game_title\00"
@.str515 = private unnamed_addr constant [9 x i8] c"win_open\00"
@.str516 = private unnamed_addr constant [9 x i8] c"win_poll\00"
@.str517 = private unnamed_addr constant [12 x i8] c"win_present\00"
@.str518 = private unnamed_addr constant [12 x i8] c"win_running\00"
@.str519 = private unnamed_addr constant [10 x i8] c"win_close\00"
@.str520 = private unnamed_addr constant [9 x i8] c"mem_free\00"
@.str521 = private unnamed_addr constant [23 x i8] c"  call void @free(ptr \00"
@.str522 = private unnamed_addr constant [3 x i8] c")\0A\00"
@.str523 = private unnamed_addr constant [2 x i8] c"0\00"
@.str524 = private unnamed_addr constant [5 x i8] c"void\00"
@.str525 = private unnamed_addr constant [9 x i8] c"mem_copy\00"
@.str526 = private unnamed_addr constant [10 x i8] c"zext i32 \00"
@.str527 = private unnamed_addr constant [8 x i8] c" to i64\00"
@.str528 = private unnamed_addr constant [24 x i8] c"  call ptr @memcpy(ptr \00"
@.str529 = private unnamed_addr constant [7 x i8] c", ptr \00"
@.str530 = private unnamed_addr constant [7 x i8] c", i64 \00"
@.str531 = private unnamed_addr constant [3 x i8] c")\0A\00"
@.str532 = private unnamed_addr constant [2 x i8] c"0\00"
@.str533 = private unnamed_addr constant [5 x i8] c"void\00"
@.str534 = private unnamed_addr constant [8 x i8] c"mem_set\00"
@.str535 = private unnamed_addr constant [10 x i8] c"zext i32 \00"
@.str536 = private unnamed_addr constant [8 x i8] c" to i64\00"
@.str537 = private unnamed_addr constant [24 x i8] c"  call ptr @memset(ptr \00"
@.str538 = private unnamed_addr constant [7 x i8] c", i32 \00"
@.str539 = private unnamed_addr constant [7 x i8] c", i64 \00"
@.str540 = private unnamed_addr constant [3 x i8] c")\0A\00"
@.str541 = private unnamed_addr constant [2 x i8] c"0\00"
@.str542 = private unnamed_addr constant [5 x i8] c"void\00"
@.str543 = private unnamed_addr constant [8 x i8] c"ptr_add\00"
@.str544 = private unnamed_addr constant [3 x i8] c"  \00"
@.str545 = private unnamed_addr constant [35 x i8] c" = getelementptr inbounds i8, ptr \00"
@.str546 = private unnamed_addr constant [7 x i8] c", i32 \00"
@.str547 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str548 = private unnamed_addr constant [4 x i8] c"ptr\00"
@.str549 = private unnamed_addr constant [10 x i8] c"read_byte\00"
@.str550 = private unnamed_addr constant [20 x i8] c"call i32 @getchar()\00"
@.str551 = private unnamed_addr constant [4 x i8] c"int\00"
@.str552 = private unnamed_addr constant [11 x i8] c"write_byte\00"
@.str553 = private unnamed_addr constant [25 x i8] c"  call i32 @putchar(i32 \00"
@.str554 = private unnamed_addr constant [3 x i8] c")\0A\00"
@.str555 = private unnamed_addr constant [2 x i8] c"0\00"
@.str556 = private unnamed_addr constant [5 x i8] c"void\00"
@.str557 = private unnamed_addr constant [8 x i8] c"str_len\00"
@.str558 = private unnamed_addr constant [22 x i8] c"call i64 @strlen(ptr \00"
@.str559 = private unnamed_addr constant [2 x i8] c")\00"
@.str560 = private unnamed_addr constant [11 x i8] c"trunc i64 \00"
@.str561 = private unnamed_addr constant [8 x i8] c" to i32\00"
@.str562 = private unnamed_addr constant [4 x i8] c"int\00"
@.str563 = private unnamed_addr constant [8 x i8] c"os_time\00"
@.str564 = private unnamed_addr constant [25 x i8] c"call i64 @time(ptr null)\00"
@.str565 = private unnamed_addr constant [11 x i8] c"trunc i64 \00"
@.str566 = private unnamed_addr constant [8 x i8] c" to i32\00"
@.str567 = private unnamed_addr constant [4 x i8] c"int\00"
@.str568 = private unnamed_addr constant [6 x i8] c"peekf\00"
@.str569 = private unnamed_addr constant [3 x i8] c"  \00"
@.str570 = private unnamed_addr constant [36 x i8] c" = getelementptr inbounds i32, ptr \00"
@.str571 = private unnamed_addr constant [7 x i8] c", i32 \00"
@.str572 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str573 = private unnamed_addr constant [15 x i8] c"load i32, ptr \00"
@.str574 = private unnamed_addr constant [6 x i8] c"fixed\00"
@.str575 = private unnamed_addr constant [6 x i8] c"pokef\00"
@.str576 = private unnamed_addr constant [3 x i8] c"  \00"
@.str577 = private unnamed_addr constant [36 x i8] c" = getelementptr inbounds i32, ptr \00"
@.str578 = private unnamed_addr constant [7 x i8] c", i32 \00"
@.str579 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str580 = private unnamed_addr constant [13 x i8] c"  store i32 \00"
@.str581 = private unnamed_addr constant [7 x i8] c", ptr \00"
@.str582 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str583 = private unnamed_addr constant [2 x i8] c"0\00"
@.str584 = private unnamed_addr constant [5 x i8] c"void\00"
@.str585 = private unnamed_addr constant [6 x i8] c"peekp\00"
@.str586 = private unnamed_addr constant [3 x i8] c"  \00"
@.str587 = private unnamed_addr constant [36 x i8] c" = getelementptr inbounds ptr, ptr \00"
@.str588 = private unnamed_addr constant [7 x i8] c", i32 \00"
@.str589 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str590 = private unnamed_addr constant [15 x i8] c"load ptr, ptr \00"
@.str591 = private unnamed_addr constant [4 x i8] c"ptr\00"
@.str592 = private unnamed_addr constant [6 x i8] c"pokep\00"
@.str593 = private unnamed_addr constant [3 x i8] c"  \00"
@.str594 = private unnamed_addr constant [36 x i8] c" = getelementptr inbounds ptr, ptr \00"
@.str595 = private unnamed_addr constant [7 x i8] c", i32 \00"
@.str596 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str597 = private unnamed_addr constant [13 x i8] c"  store ptr \00"
@.str598 = private unnamed_addr constant [7 x i8] c", ptr \00"
@.str599 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str600 = private unnamed_addr constant [2 x i8] c"0\00"
@.str601 = private unnamed_addr constant [5 x i8] c"void\00"
@.str602 = private unnamed_addr constant [9 x i8] c"as_fixed\00"
@.str603 = private unnamed_addr constant [6 x i8] c"fixed\00"
@.str604 = private unnamed_addr constant [7 x i8] c"as_int\00"
@.str605 = private unnamed_addr constant [4 x i8] c"int\00"
@.str606 = private unnamed_addr constant [12 x i8] c"is_windowed\00"
@.str607 = private unnamed_addr constant [2 x i8] c"1\00"
@.str608 = private unnamed_addr constant [5 x i8] c"bool\00"
@.str609 = private unnamed_addr constant [2 x i8] c"0\00"
@.str610 = private unnamed_addr constant [5 x i8] c"bool\00"
@.str611 = private unnamed_addr constant [11 x i8] c"game_title\00"
@.str612 = private unnamed_addr constant [12 x i8] c"@.gametitle\00"
@.str613 = private unnamed_addr constant [4 x i8] c"str\00"
@.str614 = private unnamed_addr constant [9 x i8] c"win_poll\00"
@.str615 = private unnamed_addr constant [21 x i8] c"call i32 @win_poll()\00"
@.str616 = private unnamed_addr constant [4 x i8] c"int\00"
@.str617 = private unnamed_addr constant [12 x i8] c"win_running\00"
@.str618 = private unnamed_addr constant [24 x i8] c"call i32 @win_running()\00"
@.str619 = private unnamed_addr constant [5 x i8] c"bool\00"
@.str620 = private unnamed_addr constant [9 x i8] c"win_open\00"
@.str621 = private unnamed_addr constant [27 x i8] c"  call void @win_open(i32 \00"
@.str622 = private unnamed_addr constant [7 x i8] c", i32 \00"
@.str623 = private unnamed_addr constant [7 x i8] c", i32 \00"
@.str624 = private unnamed_addr constant [7 x i8] c", ptr \00"
@.str625 = private unnamed_addr constant [3 x i8] c")\0A\00"
@.str626 = private unnamed_addr constant [2 x i8] c"0\00"
@.str627 = private unnamed_addr constant [5 x i8] c"void\00"
@.str628 = private unnamed_addr constant [12 x i8] c"win_present\00"
@.str629 = private unnamed_addr constant [30 x i8] c"  call void @win_present(ptr \00"
@.str630 = private unnamed_addr constant [7 x i8] c", i32 \00"
@.str631 = private unnamed_addr constant [7 x i8] c", i32 \00"
@.str632 = private unnamed_addr constant [3 x i8] c")\0A\00"
@.str633 = private unnamed_addr constant [2 x i8] c"0\00"
@.str634 = private unnamed_addr constant [5 x i8] c"void\00"
@.str635 = private unnamed_addr constant [10 x i8] c"win_close\00"
@.str636 = private unnamed_addr constant [26 x i8] c"  call void @win_close()\0A\00"
@.str637 = private unnamed_addr constant [2 x i8] c"0\00"
@.str638 = private unnamed_addr constant [5 x i8] c"void\00"
@.str639 = private unnamed_addr constant [2 x i8] c"0\00"
@.str640 = private unnamed_addr constant [5 x i8] c"void\00"
@.str641 = private unnamed_addr constant [4 x i8] c"min\00"
@.str642 = private unnamed_addr constant [4 x i8] c"max\00"
@.str643 = private unnamed_addr constant [4 x i8] c"abs\00"
@.str644 = private unnamed_addr constant [6 x i8] c"clamp\00"
@.str645 = private unnamed_addr constant [4 x i8] c"abs\00"
@.str646 = private unnamed_addr constant [14 x i8] c"icmp slt i32 \00"
@.str647 = private unnamed_addr constant [4 x i8] c", 0\00"
@.str648 = private unnamed_addr constant [12 x i8] c"sub i32 0, \00"
@.str649 = private unnamed_addr constant [11 x i8] c"select i1 \00"
@.str650 = private unnamed_addr constant [7 x i8] c", i32 \00"
@.str651 = private unnamed_addr constant [7 x i8] c", i32 \00"
@.str652 = private unnamed_addr constant [4 x i8] c"int\00"
@.str653 = private unnamed_addr constant [4 x i8] c"min\00"
@.str654 = private unnamed_addr constant [4 x i8] c"max\00"
@.str655 = private unnamed_addr constant [4 x i8] c"slt\00"
@.str656 = private unnamed_addr constant [4 x i8] c"max\00"
@.str657 = private unnamed_addr constant [4 x i8] c"sgt\00"
@.str658 = private unnamed_addr constant [6 x i8] c"icmp \00"
@.str659 = private unnamed_addr constant [6 x i8] c" i32 \00"
@.str660 = private unnamed_addr constant [3 x i8] c", \00"
@.str661 = private unnamed_addr constant [11 x i8] c"select i1 \00"
@.str662 = private unnamed_addr constant [7 x i8] c", i32 \00"
@.str663 = private unnamed_addr constant [7 x i8] c", i32 \00"
@.str664 = private unnamed_addr constant [4 x i8] c"int\00"
@.str665 = private unnamed_addr constant [14 x i8] c"icmp slt i32 \00"
@.str666 = private unnamed_addr constant [3 x i8] c", \00"
@.str667 = private unnamed_addr constant [11 x i8] c"select i1 \00"
@.str668 = private unnamed_addr constant [7 x i8] c", i32 \00"
@.str669 = private unnamed_addr constant [7 x i8] c", i32 \00"
@.str670 = private unnamed_addr constant [14 x i8] c"icmp sgt i32 \00"
@.str671 = private unnamed_addr constant [3 x i8] c", \00"
@.str672 = private unnamed_addr constant [11 x i8] c"select i1 \00"
@.str673 = private unnamed_addr constant [7 x i8] c", i32 \00"
@.str674 = private unnamed_addr constant [7 x i8] c", i32 \00"
@.str675 = private unnamed_addr constant [4 x i8] c"int\00"
@.str676 = private unnamed_addr constant [15 x i8] c"getelementptr \00"
@.str677 = private unnamed_addr constant [18 x i8] c", ptr null, i32 1\00"
@.str678 = private unnamed_addr constant [14 x i8] c"ptrtoint ptr \00"
@.str679 = private unnamed_addr constant [8 x i8] c" to i64\00"
@.str680 = private unnamed_addr constant [27 x i8] c"unknown record type in new\00"
@.str681 = private unnamed_addr constant [22 x i8] c"call ptr @malloc(i64 \00"
@.str682 = private unnamed_addr constant [2 x i8] c")\00"
@.str683 = private unnamed_addr constant [3 x i8] c"  \00"
@.str684 = private unnamed_addr constant [27 x i8] c" = getelementptr inbounds \00"
@.str685 = private unnamed_addr constant [7 x i8] c", ptr \00"
@.str686 = private unnamed_addr constant [14 x i8] c", i32 0, i32 \00"
@.str687 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str688 = private unnamed_addr constant [2 x i8] c"0\00"
@.str689 = private unnamed_addr constant [4 x i8] c"ptr\00"
@.str690 = private unnamed_addr constant [5 x i8] c"null\00"
@.str691 = private unnamed_addr constant [9 x i8] c"  store \00"
@.str692 = private unnamed_addr constant [2 x i8] c" \00"
@.str693 = private unnamed_addr constant [7 x i8] c", ptr \00"
@.str694 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str695 = private unnamed_addr constant [8 x i8] c"%LSlice\00"
@.str696 = private unnamed_addr constant [22 x i8] c"call ptr @malloc(i64 \00"
@.str697 = private unnamed_addr constant [2 x i8] c")\00"
@.str698 = private unnamed_addr constant [3 x i8] c"  \00"
@.str699 = private unnamed_addr constant [40 x i8] c" = getelementptr inbounds %LSlice, ptr \00"
@.str700 = private unnamed_addr constant [16 x i8] c", i32 0, i32 0\0A\00"
@.str701 = private unnamed_addr constant [23 x i8] c"  store ptr null, ptr \00"
@.str702 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str703 = private unnamed_addr constant [3 x i8] c"  \00"
@.str704 = private unnamed_addr constant [40 x i8] c" = getelementptr inbounds %LSlice, ptr \00"
@.str705 = private unnamed_addr constant [16 x i8] c", i32 0, i32 1\0A\00"
@.str706 = private unnamed_addr constant [20 x i8] c"  store i32 0, ptr \00"
@.str707 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str708 = private unnamed_addr constant [3 x i8] c"  \00"
@.str709 = private unnamed_addr constant [40 x i8] c" = getelementptr inbounds %LSlice, ptr \00"
@.str710 = private unnamed_addr constant [16 x i8] c", i32 0, i32 2\0A\00"
@.str711 = private unnamed_addr constant [20 x i8] c"  store i32 0, ptr \00"
@.str712 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str713 = private unnamed_addr constant [3 x i8] c"  \00"
@.str714 = private unnamed_addr constant [40 x i8] c" = getelementptr inbounds %LSlice, ptr \00"
@.str715 = private unnamed_addr constant [14 x i8] c", i32 0, i32 \00"
@.str716 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str717 = private unnamed_addr constant [15 x i8] c"load i32, ptr \00"
@.str718 = private unnamed_addr constant [4 x i8] c"int\00"
@.str719 = private unnamed_addr constant [15 x i8] c"load i32, ptr \00"
@.str720 = private unnamed_addr constant [15 x i8] c"load i32, ptr \00"
@.str721 = private unnamed_addr constant [14 x i8] c"icmp sge i32 \00"
@.str722 = private unnamed_addr constant [3 x i8] c", \00"
@.str723 = private unnamed_addr constant [5 x i8] c"grow\00"
@.str724 = private unnamed_addr constant [4 x i8] c"put\00"
@.str725 = private unnamed_addr constant [9 x i8] c"  br i1 \00"
@.str726 = private unnamed_addr constant [10 x i8] c", label %\00"
@.str727 = private unnamed_addr constant [10 x i8] c", label %\00"
@.str728 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str729 = private unnamed_addr constant [3 x i8] c":\0A\00"
@.str730 = private unnamed_addr constant [9 x i8] c"mul i32 \00"
@.str731 = private unnamed_addr constant [4 x i8] c", 2\00"
@.str732 = private unnamed_addr constant [13 x i8] c"icmp eq i32 \00"
@.str733 = private unnamed_addr constant [4 x i8] c", 0\00"
@.str734 = private unnamed_addr constant [11 x i8] c"select i1 \00"
@.str735 = private unnamed_addr constant [14 x i8] c", i32 8, i32 \00"
@.str736 = private unnamed_addr constant [10 x i8] c"zext i32 \00"
@.str737 = private unnamed_addr constant [8 x i8] c" to i64\00"
@.str738 = private unnamed_addr constant [9 x i8] c"mul i64 \00"
@.str739 = private unnamed_addr constant [3 x i8] c", \00"
@.str740 = private unnamed_addr constant [15 x i8] c"load ptr, ptr \00"
@.str741 = private unnamed_addr constant [23 x i8] c"call ptr @realloc(ptr \00"
@.str742 = private unnamed_addr constant [7 x i8] c", i64 \00"
@.str743 = private unnamed_addr constant [2 x i8] c")\00"
@.str744 = private unnamed_addr constant [13 x i8] c"  store ptr \00"
@.str745 = private unnamed_addr constant [7 x i8] c", ptr \00"
@.str746 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str747 = private unnamed_addr constant [13 x i8] c"  store i32 \00"
@.str748 = private unnamed_addr constant [7 x i8] c", ptr \00"
@.str749 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str750 = private unnamed_addr constant [13 x i8] c"  br label %\00"
@.str751 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str752 = private unnamed_addr constant [3 x i8] c":\0A\00"
@.str753 = private unnamed_addr constant [15 x i8] c"load ptr, ptr \00"
@.str754 = private unnamed_addr constant [3 x i8] c"  \00"
@.str755 = private unnamed_addr constant [27 x i8] c" = getelementptr inbounds \00"
@.str756 = private unnamed_addr constant [7 x i8] c", ptr \00"
@.str757 = private unnamed_addr constant [7 x i8] c", i32 \00"
@.str758 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str759 = private unnamed_addr constant [9 x i8] c"  store \00"
@.str760 = private unnamed_addr constant [2 x i8] c" \00"
@.str761 = private unnamed_addr constant [7 x i8] c", ptr \00"
@.str762 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str763 = private unnamed_addr constant [9 x i8] c"add i32 \00"
@.str764 = private unnamed_addr constant [4 x i8] c", 1\00"
@.str765 = private unnamed_addr constant [13 x i8] c"  store i32 \00"
@.str766 = private unnamed_addr constant [7 x i8] c", ptr \00"
@.str767 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str768 = private unnamed_addr constant [2 x i8] c"0\00"
@.str769 = private unnamed_addr constant [5 x i8] c"void\00"
@.str770 = private unnamed_addr constant [6 x i8] c"load \00"
@.str771 = private unnamed_addr constant [7 x i8] c", ptr \00"
@.str772 = private unnamed_addr constant [4 x i8] c"i32\00"
@.str773 = private unnamed_addr constant [13 x i8] c"icmp ne i32 \00"
@.str774 = private unnamed_addr constant [4 x i8] c", 0\00"
@.str775 = private unnamed_addr constant [9 x i8] c"zext i1 \00"
@.str776 = private unnamed_addr constant [8 x i8] c" to i32\00"
@.str777 = private unnamed_addr constant [13 x i8] c"  store i32 \00"
@.str778 = private unnamed_addr constant [7 x i8] c", ptr \00"
@.str779 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str780 = private unnamed_addr constant [3 x i8] c"sc\00"
@.str781 = private unnamed_addr constant [6 x i8] c"scend\00"
@.str782 = private unnamed_addr constant [4 x i8] c"and\00"
@.str783 = private unnamed_addr constant [9 x i8] c"  br i1 \00"
@.str784 = private unnamed_addr constant [10 x i8] c", label %\00"
@.str785 = private unnamed_addr constant [10 x i8] c", label %\00"
@.str786 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str787 = private unnamed_addr constant [9 x i8] c"  br i1 \00"
@.str788 = private unnamed_addr constant [10 x i8] c", label %\00"
@.str789 = private unnamed_addr constant [10 x i8] c", label %\00"
@.str790 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str791 = private unnamed_addr constant [3 x i8] c":\0A\00"
@.str792 = private unnamed_addr constant [13 x i8] c"icmp ne i32 \00"
@.str793 = private unnamed_addr constant [4 x i8] c", 0\00"
@.str794 = private unnamed_addr constant [9 x i8] c"zext i1 \00"
@.str795 = private unnamed_addr constant [8 x i8] c" to i32\00"
@.str796 = private unnamed_addr constant [13 x i8] c"  store i32 \00"
@.str797 = private unnamed_addr constant [7 x i8] c", ptr \00"
@.str798 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str799 = private unnamed_addr constant [13 x i8] c"  br label %\00"
@.str800 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str801 = private unnamed_addr constant [3 x i8] c":\0A\00"
@.str802 = private unnamed_addr constant [15 x i8] c"load i32, ptr \00"
@.str803 = private unnamed_addr constant [5 x i8] c"bool\00"
@.str804 = private unnamed_addr constant [2 x i8] c"<\00"
@.str805 = private unnamed_addr constant [4 x i8] c"slt\00"
@.str806 = private unnamed_addr constant [3 x i8] c"<=\00"
@.str807 = private unnamed_addr constant [4 x i8] c"sle\00"
@.str808 = private unnamed_addr constant [2 x i8] c">\00"
@.str809 = private unnamed_addr constant [4 x i8] c"sgt\00"
@.str810 = private unnamed_addr constant [3 x i8] c">=\00"
@.str811 = private unnamed_addr constant [4 x i8] c"sge\00"
@.str812 = private unnamed_addr constant [3 x i8] c"==\00"
@.str813 = private unnamed_addr constant [3 x i8] c"eq\00"
@.str814 = private unnamed_addr constant [3 x i8] c"ne\00"
@.str815 = private unnamed_addr constant [2 x i8] c"<\00"
@.str816 = private unnamed_addr constant [3 x i8] c"<=\00"
@.str817 = private unnamed_addr constant [2 x i8] c">\00"
@.str818 = private unnamed_addr constant [3 x i8] c">=\00"
@.str819 = private unnamed_addr constant [3 x i8] c"==\00"
@.str820 = private unnamed_addr constant [3 x i8] c"!=\00"
@.str821 = private unnamed_addr constant [2 x i8] c"+\00"
@.str822 = private unnamed_addr constant [4 x i8] c"add\00"
@.str823 = private unnamed_addr constant [2 x i8] c"-\00"
@.str824 = private unnamed_addr constant [4 x i8] c"sub\00"
@.str825 = private unnamed_addr constant [2 x i8] c"*\00"
@.str826 = private unnamed_addr constant [4 x i8] c"mul\00"
@.str827 = private unnamed_addr constant [2 x i8] c"/\00"
@.str828 = private unnamed_addr constant [5 x i8] c"sdiv\00"
@.str829 = private unnamed_addr constant [2 x i8] c"&\00"
@.str830 = private unnamed_addr constant [4 x i8] c"and\00"
@.str831 = private unnamed_addr constant [2 x i8] c"|\00"
@.str832 = private unnamed_addr constant [3 x i8] c"or\00"
@.str833 = private unnamed_addr constant [2 x i8] c"^\00"
@.str834 = private unnamed_addr constant [4 x i8] c"xor\00"
@.str835 = private unnamed_addr constant [3 x i8] c"<<\00"
@.str836 = private unnamed_addr constant [4 x i8] c"shl\00"
@.str837 = private unnamed_addr constant [3 x i8] c">>\00"
@.str838 = private unnamed_addr constant [5 x i8] c"lshr\00"
@.str839 = private unnamed_addr constant [5 x i8] c"srem\00"
@.str840 = private unnamed_addr constant [6 x i8] c"fixed\00"
@.str841 = private unnamed_addr constant [9 x i8] c"shl i32 \00"
@.str842 = private unnamed_addr constant [5 x i8] c", 16\00"
@.str843 = private unnamed_addr constant [2 x i8] c"+\00"
@.str844 = private unnamed_addr constant [29 x i8] c"call ptr @fn_str_concat(ptr \00"
@.str845 = private unnamed_addr constant [7 x i8] c", ptr \00"
@.str846 = private unnamed_addr constant [2 x i8] c")\00"
@.str847 = private unnamed_addr constant [4 x i8] c"str\00"
@.str848 = private unnamed_addr constant [25 x i8] c"call i32 @fn_str_eq(ptr \00"
@.str849 = private unnamed_addr constant [7 x i8] c", ptr \00"
@.str850 = private unnamed_addr constant [2 x i8] c")\00"
@.str851 = private unnamed_addr constant [3 x i8] c"!=\00"
@.str852 = private unnamed_addr constant [13 x i8] c"icmp eq i32 \00"
@.str853 = private unnamed_addr constant [4 x i8] c", 0\00"
@.str854 = private unnamed_addr constant [9 x i8] c"zext i1 \00"
@.str855 = private unnamed_addr constant [8 x i8] c" to i32\00"
@.str856 = private unnamed_addr constant [5 x i8] c"bool\00"
@.str857 = private unnamed_addr constant [5 x i8] c"bool\00"
@.str858 = private unnamed_addr constant [4 x i8] c"and\00"
@.str859 = private unnamed_addr constant [3 x i8] c"or\00"
@.str860 = private unnamed_addr constant [4 x i8] c"ptr\00"
@.str861 = private unnamed_addr constant [4 x i8] c"ptr\00"
@.str862 = private unnamed_addr constant [2 x i8] c"+\00"
@.str863 = private unnamed_addr constant [2 x i8] c"+\00"
@.str864 = private unnamed_addr constant [3 x i8] c"==\00"
@.str865 = private unnamed_addr constant [3 x i8] c"!=\00"
@.str866 = private unnamed_addr constant [6 x i8] c"fixed\00"
@.str867 = private unnamed_addr constant [6 x i8] c"fixed\00"
@.str868 = private unnamed_addr constant [4 x i8] c"i32\00"
@.str869 = private unnamed_addr constant [4 x i8] c"ptr\00"
@.str870 = private unnamed_addr constant [4 x i8] c"ptr\00"
@.str871 = private unnamed_addr constant [4 x i8] c"ptr\00"
@.str872 = private unnamed_addr constant [6 x i8] c"icmp \00"
@.str873 = private unnamed_addr constant [2 x i8] c" \00"
@.str874 = private unnamed_addr constant [2 x i8] c" \00"
@.str875 = private unnamed_addr constant [3 x i8] c", \00"
@.str876 = private unnamed_addr constant [9 x i8] c"zext i1 \00"
@.str877 = private unnamed_addr constant [8 x i8] c" to i32\00"
@.str878 = private unnamed_addr constant [5 x i8] c"bool\00"
@.str879 = private unnamed_addr constant [2 x i8] c"*\00"
@.str880 = private unnamed_addr constant [10 x i8] c"sext i32 \00"
@.str881 = private unnamed_addr constant [8 x i8] c" to i64\00"
@.str882 = private unnamed_addr constant [10 x i8] c"sext i32 \00"
@.str883 = private unnamed_addr constant [8 x i8] c" to i64\00"
@.str884 = private unnamed_addr constant [9 x i8] c"mul i64 \00"
@.str885 = private unnamed_addr constant [3 x i8] c", \00"
@.str886 = private unnamed_addr constant [10 x i8] c"ashr i64 \00"
@.str887 = private unnamed_addr constant [5 x i8] c", 16\00"
@.str888 = private unnamed_addr constant [11 x i8] c"trunc i64 \00"
@.str889 = private unnamed_addr constant [8 x i8] c" to i32\00"
@.str890 = private unnamed_addr constant [6 x i8] c"fixed\00"
@.str891 = private unnamed_addr constant [2 x i8] c"/\00"
@.str892 = private unnamed_addr constant [10 x i8] c"sext i32 \00"
@.str893 = private unnamed_addr constant [8 x i8] c" to i64\00"
@.str894 = private unnamed_addr constant [9 x i8] c"shl i64 \00"
@.str895 = private unnamed_addr constant [5 x i8] c", 16\00"
@.str896 = private unnamed_addr constant [10 x i8] c"sext i32 \00"
@.str897 = private unnamed_addr constant [8 x i8] c" to i64\00"
@.str898 = private unnamed_addr constant [10 x i8] c"sdiv i64 \00"
@.str899 = private unnamed_addr constant [3 x i8] c", \00"
@.str900 = private unnamed_addr constant [11 x i8] c"trunc i64 \00"
@.str901 = private unnamed_addr constant [8 x i8] c" to i32\00"
@.str902 = private unnamed_addr constant [6 x i8] c"fixed\00"
@.str903 = private unnamed_addr constant [6 x i8] c" i32 \00"
@.str904 = private unnamed_addr constant [3 x i8] c", \00"
@.str905 = private unnamed_addr constant [6 x i8] c"fixed\00"
@.str906 = private unnamed_addr constant [6 x i8] c" i32 \00"
@.str907 = private unnamed_addr constant [3 x i8] c", \00"
@.str908 = private unnamed_addr constant [4 x i8] c"int\00"
@.str909 = private unnamed_addr constant [5 x i8] c"self\00"
@.str910 = private unnamed_addr constant [2 x i8] c"0\00"
@.str911 = private unnamed_addr constant [7 x i8] c"entity\00"
@.str912 = private unnamed_addr constant [15 x i8] c"load i32, ptr \00"
@.str913 = private unnamed_addr constant [7 x i8] c"entity\00"
@.str914 = private unnamed_addr constant [4 x i8] c"key\00"
@.str915 = private unnamed_addr constant [21 x i8] c"load i32, ptr @L_key\00"
@.str916 = private unnamed_addr constant [4 x i8] c"int\00"
@.str917 = private unnamed_addr constant [5 x i8] c"save\00"
@.str918 = private unnamed_addr constant [23 x i8] c"  call void @L_save()\0A\00"
@.str919 = private unnamed_addr constant [2 x i8] c"0\00"
@.str920 = private unnamed_addr constant [5 x i8] c"void\00"
@.str921 = private unnamed_addr constant [9 x i8] c"ui_build\00"
@.str922 = private unnamed_addr constant [25 x i8] c"  call void @ui_build()\0A\00"
@.str923 = private unnamed_addr constant [2 x i8] c"0\00"
@.str924 = private unnamed_addr constant [5 x i8] c"void\00"
@.str925 = private unnamed_addr constant [5 x i8] c"load\00"
@.str926 = private unnamed_addr constant [19 x i8] c"call i32 @L_load()\00"
@.str927 = private unnamed_addr constant [5 x i8] c"bool\00"
@.str928 = private unnamed_addr constant [5 x i8] c"quit\00"
@.str929 = private unnamed_addr constant [31 x i8] c"  store i32 0, ptr @L_running\0A\00"
@.str930 = private unnamed_addr constant [2 x i8] c"0\00"
@.str931 = private unnamed_addr constant [5 x i8] c"void\00"
@.str932 = private unnamed_addr constant [4 x i8] c"len\00"
@.str933 = private unnamed_addr constant [5 x i8] c"push\00"
@.str934 = private unnamed_addr constant [3 x i8] c"fx\00"
@.str935 = private unnamed_addr constant [9 x i8] c"shl i32 \00"
@.str936 = private unnamed_addr constant [5 x i8] c", 16\00"
@.str937 = private unnamed_addr constant [6 x i8] c"fixed\00"
@.str938 = private unnamed_addr constant [4 x i8] c"flr\00"
@.str939 = private unnamed_addr constant [10 x i8] c"ashr i32 \00"
@.str940 = private unnamed_addr constant [5 x i8] c", 16\00"
@.str941 = private unnamed_addr constant [4 x i8] c"int\00"
@.str942 = private unnamed_addr constant [4 x i8] c"rt_\00"
@.str943 = private unnamed_addr constant [18 x i8] c"unknown function \00"
@.str944 = private unnamed_addr constant [3 x i8] c"  \00"
@.str945 = private unnamed_addr constant [2 x i8] c"0\00"
@.str946 = private unnamed_addr constant [5 x i8] c"void\00"
@.str947 = private unnamed_addr constant [4 x i8] c" = \00"
@.str948 = private unnamed_addr constant [6 x i8] c"call \00"
@.str949 = private unnamed_addr constant [6 x i8] c" @fn_\00"
@.str950 = private unnamed_addr constant [2 x i8] c"(\00"
@.str951 = private unnamed_addr constant [3 x i8] c", \00"
@.str952 = private unnamed_addr constant [2 x i8] c" \00"
@.str953 = private unnamed_addr constant [3 x i8] c")\0A\00"
@.str954 = private unnamed_addr constant [2 x i8] c"0\00"
@.str955 = private unnamed_addr constant [4 x i8] c"int\00"
@.str956 = private unnamed_addr constant [4 x i8] c"int\00"
@.str957 = private unnamed_addr constant [6 x i8] c"fixed\00"
@.str958 = private unnamed_addr constant [5 x i8] c"bool\00"
@.str959 = private unnamed_addr constant [5 x i8] c"null\00"
@.str960 = private unnamed_addr constant [4 x i8] c"ptr\00"
@.str961 = private unnamed_addr constant [4 x i8] c"str\00"
@.str962 = private unnamed_addr constant [4 x i8] c"int\00"
@.str963 = private unnamed_addr constant [6 x i8] c"load \00"
@.str964 = private unnamed_addr constant [10 x i8] c", ptr @g_\00"
@.str965 = private unnamed_addr constant [4 x i8] c"int\00"
@.str966 = private unnamed_addr constant [20 x i8] c"unknown identifier \00"
@.str967 = private unnamed_addr constant [4 x i8] c"int\00"
@.str968 = private unnamed_addr constant [2 x i8] c"-\00"
@.str969 = private unnamed_addr constant [12 x i8] c"sub i32 0, \00"
@.str970 = private unnamed_addr constant [4 x i8] c"int\00"
@.str971 = private unnamed_addr constant [2 x i8] c"~\00"
@.str972 = private unnamed_addr constant [9 x i8] c"xor i32 \00"
@.str973 = private unnamed_addr constant [5 x i8] c", -1\00"
@.str974 = private unnamed_addr constant [4 x i8] c"int\00"
@.str975 = private unnamed_addr constant [13 x i8] c"icmp eq i32 \00"
@.str976 = private unnamed_addr constant [4 x i8] c", 0\00"
@.str977 = private unnamed_addr constant [9 x i8] c"zext i1 \00"
@.str978 = private unnamed_addr constant [8 x i8] c" to i32\00"
@.str979 = private unnamed_addr constant [5 x i8] c"bool\00"
@.str980 = private unnamed_addr constant [23 x i8] c"cannot emit expression\00"
@.str981 = private unnamed_addr constant [2 x i8] c"0\00"
@.str982 = private unnamed_addr constant [4 x i8] c"int\00"
@.str983 = private unnamed_addr constant [9 x i8] c"  store \00"
@.str984 = private unnamed_addr constant [2 x i8] c" \00"
@.str985 = private unnamed_addr constant [7 x i8] c", ptr \00"
@.str986 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str987 = private unnamed_addr constant [2 x i8] c"0\00"
@.str988 = private unnamed_addr constant [4 x i8] c"int\00"
@.str989 = private unnamed_addr constant [29 x i8] c"cannot assign to immutable '\00"
@.str990 = private unnamed_addr constant [41 x i8] c"' (declared with let; use var) \E2\80\94 line \00"
@.str991 = private unnamed_addr constant [19 x i8] c"assign to unknown \00"
@.str992 = private unnamed_addr constant [4 x i8] c"@g_\00"
@.str993 = private unnamed_addr constant [22 x i8] c"bad assignment target\00"
@.str994 = private unnamed_addr constant [2 x i8] c"=\00"
@.str995 = private unnamed_addr constant [6 x i8] c"load \00"
@.str996 = private unnamed_addr constant [7 x i8] c", ptr \00"
@.str997 = private unnamed_addr constant [4 x i8] c"add\00"
@.str998 = private unnamed_addr constant [3 x i8] c"-=\00"
@.str999 = private unnamed_addr constant [4 x i8] c"sub\00"
@.str1000 = private unnamed_addr constant [3 x i8] c"*=\00"
@.str1001 = private unnamed_addr constant [4 x i8] c"mul\00"
@.str1002 = private unnamed_addr constant [3 x i8] c"/=\00"
@.str1003 = private unnamed_addr constant [5 x i8] c"sdiv\00"
@.str1004 = private unnamed_addr constant [6 x i8] c" i32 \00"
@.str1005 = private unnamed_addr constant [3 x i8] c", \00"
@.str1006 = private unnamed_addr constant [13 x i8] c"icmp ne i32 \00"
@.str1007 = private unnamed_addr constant [4 x i8] c", 0\00"
@.str1008 = private unnamed_addr constant [5 x i8] c"then\00"
@.str1009 = private unnamed_addr constant [5 x i8] c"else\00"
@.str1010 = private unnamed_addr constant [6 x i8] c"ifend\00"
@.str1011 = private unnamed_addr constant [9 x i8] c"  br i1 \00"
@.str1012 = private unnamed_addr constant [10 x i8] c", label %\00"
@.str1013 = private unnamed_addr constant [10 x i8] c", label %\00"
@.str1014 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str1015 = private unnamed_addr constant [9 x i8] c"  br i1 \00"
@.str1016 = private unnamed_addr constant [10 x i8] c", label %\00"
@.str1017 = private unnamed_addr constant [10 x i8] c", label %\00"
@.str1018 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str1019 = private unnamed_addr constant [3 x i8] c":\0A\00"
@.str1020 = private unnamed_addr constant [13 x i8] c"  br label %\00"
@.str1021 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str1022 = private unnamed_addr constant [3 x i8] c":\0A\00"
@.str1023 = private unnamed_addr constant [13 x i8] c"  br label %\00"
@.str1024 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str1025 = private unnamed_addr constant [3 x i8] c":\0A\00"
@.str1026 = private unnamed_addr constant [6 x i8] c"wcond\00"
@.str1027 = private unnamed_addr constant [6 x i8] c"wbody\00"
@.str1028 = private unnamed_addr constant [5 x i8] c"wend\00"
@.str1029 = private unnamed_addr constant [13 x i8] c"  br label %\00"
@.str1030 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str1031 = private unnamed_addr constant [3 x i8] c":\0A\00"
@.str1032 = private unnamed_addr constant [13 x i8] c"icmp ne i32 \00"
@.str1033 = private unnamed_addr constant [4 x i8] c", 0\00"
@.str1034 = private unnamed_addr constant [9 x i8] c"  br i1 \00"
@.str1035 = private unnamed_addr constant [10 x i8] c", label %\00"
@.str1036 = private unnamed_addr constant [10 x i8] c", label %\00"
@.str1037 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str1038 = private unnamed_addr constant [3 x i8] c":\0A\00"
@.str1039 = private unnamed_addr constant [13 x i8] c"  br label %\00"
@.str1040 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str1041 = private unnamed_addr constant [3 x i8] c":\0A\00"
@.str1042 = private unnamed_addr constant [4 x i8] c"i32\00"
@.str1043 = private unnamed_addr constant [4 x i8] c"i32\00"
@.str1044 = private unnamed_addr constant [4 x i8] c"int\00"
@.str1045 = private unnamed_addr constant [6 x i8] c"fcond\00"
@.str1046 = private unnamed_addr constant [6 x i8] c"fbody\00"
@.str1047 = private unnamed_addr constant [6 x i8] c"fcont\00"
@.str1048 = private unnamed_addr constant [5 x i8] c"fend\00"
@.str1049 = private unnamed_addr constant [13 x i8] c"  br label %\00"
@.str1050 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str1051 = private unnamed_addr constant [3 x i8] c":\0A\00"
@.str1052 = private unnamed_addr constant [15 x i8] c"load i32, ptr \00"
@.str1053 = private unnamed_addr constant [14 x i8] c"icmp slt i32 \00"
@.str1054 = private unnamed_addr constant [3 x i8] c", \00"
@.str1055 = private unnamed_addr constant [9 x i8] c"  br i1 \00"
@.str1056 = private unnamed_addr constant [10 x i8] c", label %\00"
@.str1057 = private unnamed_addr constant [10 x i8] c", label %\00"
@.str1058 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str1059 = private unnamed_addr constant [3 x i8] c":\0A\00"
@.str1060 = private unnamed_addr constant [13 x i8] c"  br label %\00"
@.str1061 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str1062 = private unnamed_addr constant [3 x i8] c":\0A\00"
@.str1063 = private unnamed_addr constant [15 x i8] c"load i32, ptr \00"
@.str1064 = private unnamed_addr constant [9 x i8] c"add i32 \00"
@.str1065 = private unnamed_addr constant [4 x i8] c", 1\00"
@.str1066 = private unnamed_addr constant [4 x i8] c"i32\00"
@.str1067 = private unnamed_addr constant [13 x i8] c"  br label %\00"
@.str1068 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str1069 = private unnamed_addr constant [3 x i8] c":\0A\00"
@.str1070 = private unnamed_addr constant [8 x i8] c"%retval\00"
@.str1071 = private unnamed_addr constant [17 x i8] c"  br label %ret\0A\00"
@.str1072 = private unnamed_addr constant [2 x i8] c"_\00"
@.str1073 = private unnamed_addr constant [5 x i8] c"mend\00"
@.str1074 = private unnamed_addr constant [2 x i8] c"0\00"
@.str1075 = private unnamed_addr constant [13 x i8] c"icmp eq i32 \00"
@.str1076 = private unnamed_addr constant [3 x i8] c", \00"
@.str1077 = private unnamed_addr constant [7 x i8] c"or i1 \00"
@.str1078 = private unnamed_addr constant [3 x i8] c", \00"
@.str1079 = private unnamed_addr constant [6 x i8] c"mbody\00"
@.str1080 = private unnamed_addr constant [5 x i8] c"marm\00"
@.str1081 = private unnamed_addr constant [9 x i8] c"  br i1 \00"
@.str1082 = private unnamed_addr constant [10 x i8] c", label %\00"
@.str1083 = private unnamed_addr constant [10 x i8] c", label %\00"
@.str1084 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str1085 = private unnamed_addr constant [3 x i8] c":\0A\00"
@.str1086 = private unnamed_addr constant [13 x i8] c"  br label %\00"
@.str1087 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str1088 = private unnamed_addr constant [3 x i8] c":\0A\00"
@.str1089 = private unnamed_addr constant [13 x i8] c"  br label %\00"
@.str1090 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str1091 = private unnamed_addr constant [3 x i8] c":\0A\00"
@.str1092 = private unnamed_addr constant [2 x i8] c"0\00"
@.str1093 = private unnamed_addr constant [4 x i8] c"ptr\00"
@.str1094 = private unnamed_addr constant [5 x i8] c"null\00"
@.str1095 = private unnamed_addr constant [13 x i8] c"  br label %\00"
@.str1096 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str1097 = private unnamed_addr constant [13 x i8] c"  br label %\00"
@.str1098 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str1099 = private unnamed_addr constant [22 x i8] c"cannot emit statement\00"
@.str1100 = private unnamed_addr constant [36 x i8] c"@L_running = internal global i32 1\0A\00"
@.str1101 = private unnamed_addr constant [32 x i8] c"@L_key = internal global i32 0\0A\00"
@.str1102 = private unnamed_addr constant [33 x i8] c"@L_entc = internal global i32 0\0A\00"
@.str1103 = private unnamed_addr constant [29 x i8] c"@L_alive = internal global [\00"
@.str1104 = private unnamed_addr constant [25 x i8] c" x i32] zeroinitializer\0A\00"
@.str1105 = private unnamed_addr constant [28 x i8] c"@L_kind = internal global [\00"
@.str1106 = private unnamed_addr constant [25 x i8] c" x i32] zeroinitializer\0A\00"
@.str1107 = private unnamed_addr constant [32 x i8] c"@L_freelist = internal global [\00"
@.str1108 = private unnamed_addr constant [25 x i8] c" x i32] zeroinitializer\0A\00"
@.str1109 = private unnamed_addr constant [34 x i8] c"@L_freen = internal global i32 0\0A\00"
@.str1110 = private unnamed_addr constant [4 x i8] c"@S_\00"
@.str1111 = private unnamed_addr constant [21 x i8] c" = internal global [\00"
@.str1112 = private unnamed_addr constant [9 x i8] c" x %Cmp_\00"
@.str1113 = private unnamed_addr constant [19 x i8] c"] zeroinitializer\0A\00"
@.str1114 = private unnamed_addr constant [4 x i8] c"@H_\00"
@.str1115 = private unnamed_addr constant [21 x i8] c" = internal global [\00"
@.str1116 = private unnamed_addr constant [24 x i8] c" x i8] zeroinitializer\0A\00"
@.str1117 = private unnamed_addr constant [5 x i8] c"@ME_\00"
@.str1118 = private unnamed_addr constant [26 x i8] c" = internal global i32 1\0A\00"
@.str1119 = private unnamed_addr constant [5 x i8] c"@HE_\00"
@.str1120 = private unnamed_addr constant [26 x i8] c" = internal global i32 1\0A\00"
@.str1121 = private unnamed_addr constant [39 x i8] c"define void @L_reset(i32 %e) {\0Aentry:\0A\00"
@.str1122 = private unnamed_addr constant [3 x i8] c"%h\00"
@.str1123 = private unnamed_addr constant [3 x i8] c"  \00"
@.str1124 = private unnamed_addr constant [28 x i8] c" = getelementptr inbounds [\00"
@.str1125 = private unnamed_addr constant [16 x i8] c" x i8], ptr @H_\00"
@.str1126 = private unnamed_addr constant [17 x i8] c", i32 0, i32 %e\0A\00"
@.str1127 = private unnamed_addr constant [19 x i8] c"  store i8 0, ptr \00"
@.str1128 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str1129 = private unnamed_addr constant [32 x i8] c"  %k = getelementptr inbounds [\00"
@.str1130 = private unnamed_addr constant [37 x i8] c" x i32], ptr @L_kind, i32 0, i32 %e\0A\00"
@.str1131 = private unnamed_addr constant [37 x i8] c"  store i32 0, ptr %k\0A  ret void\0A}\0A\0A\00"
@.str1132 = private unnamed_addr constant [32 x i8] c"define i32 @L_alloc() {\0Aentry:\0A\00"
@.str1133 = private unnamed_addr constant [32 x i8] c"  %fn = load i32, ptr @L_freen\0A\00"
@.str1134 = private unnamed_addr constant [30 x i8] c"  %has = icmp sgt i32 %fn, 0\0A\00"
@.str1135 = private unnamed_addr constant [42 x i8] c"  br i1 %has, label %reuse, label %fresh\0A\00"
@.str1136 = private unnamed_addr constant [8 x i8] c"reuse:\0A\00"
@.str1137 = private unnamed_addr constant [25 x i8] c"  %fn1 = sub i32 %fn, 1\0A\00"
@.str1138 = private unnamed_addr constant [32 x i8] c"  store i32 %fn1, ptr @L_freen\0A\00"
@.str1139 = private unnamed_addr constant [33 x i8] c"  %fp = getelementptr inbounds [\00"
@.str1140 = private unnamed_addr constant [43 x i8] c" x i32], ptr @L_freelist, i32 0, i32 %fn1\0A\00"
@.str1141 = private unnamed_addr constant [27 x i8] c"  %re = load i32, ptr %fp\0A\00"
@.str1142 = private unnamed_addr constant [18 x i8] c"  br label %done\0A\00"
@.str1143 = private unnamed_addr constant [8 x i8] c"fresh:\0A\00"
@.str1144 = private unnamed_addr constant [31 x i8] c"  %ec = load i32, ptr @L_entc\0A\00"
@.str1145 = private unnamed_addr constant [25 x i8] c"  %ec1 = add i32 %ec, 1\0A\00"
@.str1146 = private unnamed_addr constant [31 x i8] c"  store i32 %ec1, ptr @L_entc\0A\00"
@.str1147 = private unnamed_addr constant [18 x i8] c"  br label %done\0A\00"
@.str1148 = private unnamed_addr constant [7 x i8] c"done:\0A\00"
@.str1149 = private unnamed_addr constant [49 x i8] c"  %e = phi i32 [ %re, %reuse ], [ %ec, %fresh ]\0A\00"
@.str1150 = private unnamed_addr constant [30 x i8] c"  call void @L_reset(i32 %e)\0A\00"
@.str1151 = private unnamed_addr constant [33 x i8] c"  %ap = getelementptr inbounds [\00"
@.str1152 = private unnamed_addr constant [38 x i8] c" x i32], ptr @L_alive, i32 0, i32 %e\0A\00"
@.str1153 = private unnamed_addr constant [24 x i8] c"  store i32 1, ptr %ap\0A\00"
@.str1154 = private unnamed_addr constant [17 x i8] c"  ret i32 %e\0A}\0A\0A\00"
@.str1155 = private unnamed_addr constant [45 x i8] c"define void @L_free_entity(i32 %e) {\0Aentry:\0A\00"
@.str1156 = private unnamed_addr constant [33 x i8] c"  %ap = getelementptr inbounds [\00"
@.str1157 = private unnamed_addr constant [38 x i8] c" x i32], ptr @L_alive, i32 0, i32 %e\0A\00"
@.str1158 = private unnamed_addr constant [24 x i8] c"  store i32 0, ptr %ap\0A\00"
@.str1159 = private unnamed_addr constant [30 x i8] c"  call void @L_reset(i32 %e)\0A\00"
@.str1160 = private unnamed_addr constant [32 x i8] c"  %fn = load i32, ptr @L_freen\0A\00"
@.str1161 = private unnamed_addr constant [33 x i8] c"  %fp = getelementptr inbounds [\00"
@.str1162 = private unnamed_addr constant [42 x i8] c" x i32], ptr @L_freelist, i32 0, i32 %fn\0A\00"
@.str1163 = private unnamed_addr constant [25 x i8] c"  store i32 %e, ptr %fp\0A\00"
@.str1164 = private unnamed_addr constant [25 x i8] c"  %fn1 = add i32 %fn, 1\0A\00"
@.str1165 = private unnamed_addr constant [32 x i8] c"  store i32 %fn1, ptr @L_freen\0A\00"
@.str1166 = private unnamed_addr constant [15 x i8] c"  ret void\0A}\0A\0A\00"
@.str1167 = private unnamed_addr constant [4 x i8] c"i32\00"
@.str1168 = private unnamed_addr constant [4 x i8] c"i32\00"
@.str1169 = private unnamed_addr constant [2 x i8] c"0\00"
@.str1170 = private unnamed_addr constant [6 x i8] c"qcond\00"
@.str1171 = private unnamed_addr constant [6 x i8] c"qbody\00"
@.str1172 = private unnamed_addr constant [6 x i8] c"qnext\00"
@.str1173 = private unnamed_addr constant [5 x i8] c"qend\00"
@.str1174 = private unnamed_addr constant [13 x i8] c"  br label %\00"
@.str1175 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str1176 = private unnamed_addr constant [3 x i8] c":\0A\00"
@.str1177 = private unnamed_addr constant [15 x i8] c"load i32, ptr \00"
@.str1178 = private unnamed_addr constant [22 x i8] c"load i32, ptr @L_entc\00"
@.str1179 = private unnamed_addr constant [14 x i8] c"icmp slt i32 \00"
@.str1180 = private unnamed_addr constant [3 x i8] c", \00"
@.str1181 = private unnamed_addr constant [9 x i8] c"  br i1 \00"
@.str1182 = private unnamed_addr constant [10 x i8] c", label %\00"
@.str1183 = private unnamed_addr constant [10 x i8] c", label %\00"
@.str1184 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str1185 = private unnamed_addr constant [3 x i8] c":\0A\00"
@.str1186 = private unnamed_addr constant [15 x i8] c"load i32, ptr \00"
@.str1187 = private unnamed_addr constant [3 x i8] c"  \00"
@.str1188 = private unnamed_addr constant [28 x i8] c" = getelementptr inbounds [\00"
@.str1189 = private unnamed_addr constant [35 x i8] c" x i32], ptr @L_alive, i32 0, i32 \00"
@.str1190 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str1191 = private unnamed_addr constant [15 x i8] c"load i32, ptr \00"
@.str1192 = private unnamed_addr constant [13 x i8] c"icmp ne i32 \00"
@.str1193 = private unnamed_addr constant [4 x i8] c", 0\00"
@.str1194 = private unnamed_addr constant [3 x i8] c"qa\00"
@.str1195 = private unnamed_addr constant [9 x i8] c"  br i1 \00"
@.str1196 = private unnamed_addr constant [10 x i8] c", label %\00"
@.str1197 = private unnamed_addr constant [10 x i8] c", label %\00"
@.str1198 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str1199 = private unnamed_addr constant [3 x i8] c":\0A\00"
@.str1200 = private unnamed_addr constant [2 x i8] c"0\00"
@.str1201 = private unnamed_addr constant [3 x i8] c"  \00"
@.str1202 = private unnamed_addr constant [28 x i8] c" = getelementptr inbounds [\00"
@.str1203 = private unnamed_addr constant [34 x i8] c" x i32], ptr @L_kind, i32 0, i32 \00"
@.str1204 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str1205 = private unnamed_addr constant [15 x i8] c"load i32, ptr \00"
@.str1206 = private unnamed_addr constant [13 x i8] c"icmp eq i32 \00"
@.str1207 = private unnamed_addr constant [3 x i8] c", \00"
@.str1208 = private unnamed_addr constant [19 x i8] c"load i32, ptr @ME_\00"
@.str1209 = private unnamed_addr constant [13 x i8] c"icmp ne i32 \00"
@.str1210 = private unnamed_addr constant [4 x i8] c", 0\00"
@.str1211 = private unnamed_addr constant [8 x i8] c"and i1 \00"
@.str1212 = private unnamed_addr constant [3 x i8] c", \00"
@.str1213 = private unnamed_addr constant [3 x i8] c"  \00"
@.str1214 = private unnamed_addr constant [28 x i8] c" = getelementptr inbounds [\00"
@.str1215 = private unnamed_addr constant [16 x i8] c" x i8], ptr @H_\00"
@.str1216 = private unnamed_addr constant [14 x i8] c", i32 0, i32 \00"
@.str1217 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str1218 = private unnamed_addr constant [14 x i8] c"load i8, ptr \00"
@.str1219 = private unnamed_addr constant [12 x i8] c"icmp ne i8 \00"
@.str1220 = private unnamed_addr constant [4 x i8] c", 0\00"
@.str1221 = private unnamed_addr constant [3 x i8] c"qt\00"
@.str1222 = private unnamed_addr constant [9 x i8] c"  br i1 \00"
@.str1223 = private unnamed_addr constant [10 x i8] c", label %\00"
@.str1224 = private unnamed_addr constant [10 x i8] c", label %\00"
@.str1225 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str1226 = private unnamed_addr constant [3 x i8] c":\0A\00"
@.str1227 = private unnamed_addr constant [3 x i8] c"  \00"
@.str1228 = private unnamed_addr constant [28 x i8] c" = getelementptr inbounds [\00"
@.str1229 = private unnamed_addr constant [9 x i8] c" x %Cmp_\00"
@.str1230 = private unnamed_addr constant [11 x i8] c"], ptr @S_\00"
@.str1231 = private unnamed_addr constant [14 x i8] c", i32 0, i32 \00"
@.str1232 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str1233 = private unnamed_addr constant [4 x i8] c"ptr\00"
@.str1234 = private unnamed_addr constant [13 x i8] c"  store ptr \00"
@.str1235 = private unnamed_addr constant [7 x i8] c", ptr \00"
@.str1236 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str1237 = private unnamed_addr constant [13 x i8] c"icmp ne i32 \00"
@.str1238 = private unnamed_addr constant [4 x i8] c", 0\00"
@.str1239 = private unnamed_addr constant [3 x i8] c"qw\00"
@.str1240 = private unnamed_addr constant [9 x i8] c"  br i1 \00"
@.str1241 = private unnamed_addr constant [10 x i8] c", label %\00"
@.str1242 = private unnamed_addr constant [10 x i8] c", label %\00"
@.str1243 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str1244 = private unnamed_addr constant [3 x i8] c":\0A\00"
@.str1245 = private unnamed_addr constant [13 x i8] c"  br label %\00"
@.str1246 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str1247 = private unnamed_addr constant [3 x i8] c":\0A\00"
@.str1248 = private unnamed_addr constant [15 x i8] c"load i32, ptr \00"
@.str1249 = private unnamed_addr constant [9 x i8] c"add i32 \00"
@.str1250 = private unnamed_addr constant [4 x i8] c", 1\00"
@.str1251 = private unnamed_addr constant [4 x i8] c"i32\00"
@.str1252 = private unnamed_addr constant [13 x i8] c"  br label %\00"
@.str1253 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str1254 = private unnamed_addr constant [3 x i8] c":\0A\00"
@.str1255 = private unnamed_addr constant [25 x i8] c"spawn: unknown property \00"
@.str1256 = private unnamed_addr constant [3 x i8] c"  \00"
@.str1257 = private unnamed_addr constant [28 x i8] c" = getelementptr inbounds [\00"
@.str1258 = private unnamed_addr constant [16 x i8] c" x i8], ptr @H_\00"
@.str1259 = private unnamed_addr constant [14 x i8] c", i32 0, i32 \00"
@.str1260 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str1261 = private unnamed_addr constant [19 x i8] c"  store i8 1, ptr \00"
@.str1262 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str1263 = private unnamed_addr constant [3 x i8] c"  \00"
@.str1264 = private unnamed_addr constant [28 x i8] c" = getelementptr inbounds [\00"
@.str1265 = private unnamed_addr constant [9 x i8] c" x %Cmp_\00"
@.str1266 = private unnamed_addr constant [11 x i8] c"], ptr @S_\00"
@.str1267 = private unnamed_addr constant [14 x i8] c", i32 0, i32 \00"
@.str1268 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str1269 = private unnamed_addr constant [3 x i8] c"  \00"
@.str1270 = private unnamed_addr constant [32 x i8] c" = getelementptr inbounds %Cmp_\00"
@.str1271 = private unnamed_addr constant [7 x i8] c", ptr \00"
@.str1272 = private unnamed_addr constant [14 x i8] c", i32 0, i32 \00"
@.str1273 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str1274 = private unnamed_addr constant [2 x i8] c"0\00"
@.str1275 = private unnamed_addr constant [4 x i8] c"ptr\00"
@.str1276 = private unnamed_addr constant [5 x i8] c"null\00"
@.str1277 = private unnamed_addr constant [9 x i8] c"  store \00"
@.str1278 = private unnamed_addr constant [2 x i8] c" \00"
@.str1279 = private unnamed_addr constant [7 x i8] c", ptr \00"
@.str1280 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str1281 = private unnamed_addr constant [3 x i8] c"  \00"
@.str1282 = private unnamed_addr constant [32 x i8] c" = getelementptr inbounds %Cmp_\00"
@.str1283 = private unnamed_addr constant [7 x i8] c", ptr \00"
@.str1284 = private unnamed_addr constant [14 x i8] c", i32 0, i32 \00"
@.str1285 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str1286 = private unnamed_addr constant [9 x i8] c"  store \00"
@.str1287 = private unnamed_addr constant [2 x i8] c" \00"
@.str1288 = private unnamed_addr constant [7 x i8] c", ptr \00"
@.str1289 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str1290 = private unnamed_addr constant [4 x i8] c"ptr\00"
@.str1291 = private unnamed_addr constant [13 x i8] c"  store ptr \00"
@.str1292 = private unnamed_addr constant [7 x i8] c", ptr \00"
@.str1293 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str1294 = private unnamed_addr constant [3 x i8] c"  \00"
@.str1295 = private unnamed_addr constant [28 x i8] c" = getelementptr inbounds [\00"
@.str1296 = private unnamed_addr constant [9 x i8] c" x %Cmp_\00"
@.str1297 = private unnamed_addr constant [11 x i8] c"], ptr @S_\00"
@.str1298 = private unnamed_addr constant [14 x i8] c", i32 0, i32 \00"
@.str1299 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str1300 = private unnamed_addr constant [4 x i8] c"ptr\00"
@.str1301 = private unnamed_addr constant [13 x i8] c"  store ptr \00"
@.str1302 = private unnamed_addr constant [7 x i8] c", ptr \00"
@.str1303 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str1304 = private unnamed_addr constant [20 x i8] c"call i32 @L_alloc()\00"
@.str1305 = private unnamed_addr constant [3 x i8] c"  \00"
@.str1306 = private unnamed_addr constant [28 x i8] c" = getelementptr inbounds [\00"
@.str1307 = private unnamed_addr constant [34 x i8] c" x i32], ptr @L_kind, i32 0, i32 \00"
@.str1308 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str1309 = private unnamed_addr constant [13 x i8] c"  store i32 \00"
@.str1310 = private unnamed_addr constant [7 x i8] c", ptr \00"
@.str1311 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str1312 = private unnamed_addr constant [3 x i8] c"  \00"
@.str1313 = private unnamed_addr constant [28 x i8] c" = getelementptr inbounds [\00"
@.str1314 = private unnamed_addr constant [34 x i8] c" x i32], ptr @L_kind, i32 0, i32 \00"
@.str1315 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str1316 = private unnamed_addr constant [15 x i8] c"load i32, ptr \00"
@.str1317 = private unnamed_addr constant [13 x i8] c"icmp eq i32 \00"
@.str1318 = private unnamed_addr constant [3 x i8] c", \00"
@.str1319 = private unnamed_addr constant [3 x i8] c"dh\00"
@.str1320 = private unnamed_addr constant [4 x i8] c"dhn\00"
@.str1321 = private unnamed_addr constant [9 x i8] c"  br i1 \00"
@.str1322 = private unnamed_addr constant [10 x i8] c", label %\00"
@.str1323 = private unnamed_addr constant [10 x i8] c", label %\00"
@.str1324 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str1325 = private unnamed_addr constant [27 x i8] c":\0A  call void @on_despawn_\00"
@.str1326 = private unnamed_addr constant [6 x i8] c"(i32 \00"
@.str1327 = private unnamed_addr constant [3 x i8] c")\0A\00"
@.str1328 = private unnamed_addr constant [13 x i8] c"  br label %\00"
@.str1329 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str1330 = private unnamed_addr constant [3 x i8] c":\0A\00"
@.str1331 = private unnamed_addr constant [32 x i8] c"  call void @L_free_entity(i32 \00"
@.str1332 = private unnamed_addr constant [3 x i8] c")\0A\00"
@.str1333 = private unnamed_addr constant [2 x i8] c"0\00"
@.str1334 = private unnamed_addr constant [2 x i8] c"1\00"
@.str1335 = private unnamed_addr constant [3 x i8] c"  \00"
@.str1336 = private unnamed_addr constant [28 x i8] c" = getelementptr inbounds [\00"
@.str1337 = private unnamed_addr constant [16 x i8] c" x i8], ptr @H_\00"
@.str1338 = private unnamed_addr constant [14 x i8] c", i32 0, i32 \00"
@.str1339 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str1340 = private unnamed_addr constant [12 x i8] c"  store i8 \00"
@.str1341 = private unnamed_addr constant [7 x i8] c", ptr \00"
@.str1342 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str1343 = private unnamed_addr constant [3 x i8] c"  \00"
@.str1344 = private unnamed_addr constant [28 x i8] c" = getelementptr inbounds [\00"
@.str1345 = private unnamed_addr constant [9 x i8] c" x %Cmp_\00"
@.str1346 = private unnamed_addr constant [11 x i8] c"], ptr @S_\00"
@.str1347 = private unnamed_addr constant [14 x i8] c", i32 0, i32 \00"
@.str1348 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str1349 = private unnamed_addr constant [4 x i8] c"ptr\00"
@.str1350 = private unnamed_addr constant [13 x i8] c"  store ptr \00"
@.str1351 = private unnamed_addr constant [7 x i8] c", ptr \00"
@.str1352 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str1353 = private unnamed_addr constant [5 x i8] c"@HE_\00"
@.str1354 = private unnamed_addr constant [5 x i8] c"@ME_\00"
@.str1355 = private unnamed_addr constant [13 x i8] c"  store i32 \00"
@.str1356 = private unnamed_addr constant [7 x i8] c", ptr \00"
@.str1357 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str1358 = private unnamed_addr constant [5 x i8] c"void\00"
@.str1359 = private unnamed_addr constant [17 x i8] c"  br label %ret\0A\00"
@.str1360 = private unnamed_addr constant [17 x i8] c"ret:\0A  ret void\0A\00"
@.str1361 = private unnamed_addr constant [18 x i8] c"define void @sys_\00"
@.str1362 = private unnamed_addr constant [13 x i8] c"() {\0Aentry:\0A\00"
@.str1363 = private unnamed_addr constant [4 x i8] c"}\0A\0A\00"
@.str1364 = private unnamed_addr constant [19 x i8] c"load i32, ptr @HE_\00"
@.str1365 = private unnamed_addr constant [13 x i8] c"icmp ne i32 \00"
@.str1366 = private unnamed_addr constant [4 x i8] c", 0\00"
@.str1367 = private unnamed_addr constant [5 x i8] c"hrun\00"
@.str1368 = private unnamed_addr constant [6 x i8] c"hskip\00"
@.str1369 = private unnamed_addr constant [9 x i8] c"  br i1 \00"
@.str1370 = private unnamed_addr constant [10 x i8] c", label %\00"
@.str1371 = private unnamed_addr constant [10 x i8] c", label %\00"
@.str1372 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str1373 = private unnamed_addr constant [20 x i8] c":\0A  call void @sys_\00"
@.str1374 = private unnamed_addr constant [4 x i8] c"()\0A\00"
@.str1375 = private unnamed_addr constant [13 x i8] c"  br label %\00"
@.str1376 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str1377 = private unnamed_addr constant [3 x i8] c":\0A\00"
@.str1378 = private unnamed_addr constant [5 x i8] c"void\00"
@.str1379 = private unnamed_addr constant [3 x i8] c"%e\00"
@.str1380 = private unnamed_addr constant [17 x i8] c"  br label %ret\0A\00"
@.str1381 = private unnamed_addr constant [17 x i8] c"ret:\0A  ret void\0A\00"
@.str1382 = private unnamed_addr constant [25 x i8] c"define void @on_despawn_\00"
@.str1383 = private unnamed_addr constant [19 x i8] c"(i32 %e) {\0Aentry:\0A\00"
@.str1384 = private unnamed_addr constant [4 x i8] c"}\0A\0A\00"
@.str1385 = private unnamed_addr constant [49 x i8] c"define i32 @main(i32 %argc, ptr %argv) {\0Aentry:\0A\00"
@.str1386 = private unnamed_addr constant [32 x i8] c"  store i32 %argc, ptr @L_argc\0A\00"
@.str1387 = private unnamed_addr constant [32 x i8] c"  store ptr %argv, ptr @L_argv\0A\00"
@.str1388 = private unnamed_addr constant [8 x i8] c"rt_init\00"
@.str1389 = private unnamed_addr constant [27 x i8] c"  call void @fn_rt_init()\0A\00"
@.str1390 = private unnamed_addr constant [6 x i8] c"Start\00"
@.str1391 = private unnamed_addr constant [18 x i8] c"  br label %loop\0A\00"
@.str1392 = private unnamed_addr constant [7 x i8] c"loop:\0A\00"
@.str1393 = private unnamed_addr constant [25 x i8] c"load i32, ptr @L_running\00"
@.str1394 = private unnamed_addr constant [13 x i8] c"icmp ne i32 \00"
@.str1395 = private unnamed_addr constant [4 x i8] c", 0\00"
@.str1396 = private unnamed_addr constant [11 x i8] c"rt_running\00"
@.str1397 = private unnamed_addr constant [26 x i8] c"call i32 @fn_rt_running()\00"
@.str1398 = private unnamed_addr constant [13 x i8] c"icmp ne i32 \00"
@.str1399 = private unnamed_addr constant [4 x i8] c", 0\00"
@.str1400 = private unnamed_addr constant [8 x i8] c"and i1 \00"
@.str1401 = private unnamed_addr constant [3 x i8] c", \00"
@.str1402 = private unnamed_addr constant [9 x i8] c"  br i1 \00"
@.str1403 = private unnamed_addr constant [28 x i8] c", label %body, label %done\0A\00"
@.str1404 = private unnamed_addr constant [9 x i8] c"  br i1 \00"
@.str1405 = private unnamed_addr constant [28 x i8] c", label %body, label %done\0A\00"
@.str1406 = private unnamed_addr constant [7 x i8] c"body:\0A\00"
@.str1407 = private unnamed_addr constant [8 x i8] c"rt_poll\00"
@.str1408 = private unnamed_addr constant [23 x i8] c"call i32 @fn_rt_poll()\00"
@.str1409 = private unnamed_addr constant [13 x i8] c"  store i32 \00"
@.str1410 = private unnamed_addr constant [14 x i8] c", ptr @L_key\0A\00"
@.str1411 = private unnamed_addr constant [6 x i8] c"Input\00"
@.str1412 = private unnamed_addr constant [12 x i8] c"FixedUpdate\00"
@.str1413 = private unnamed_addr constant [7 x i8] c"Update\00"
@.str1414 = private unnamed_addr constant [11 x i8] c"LateUpdate\00"
@.str1415 = private unnamed_addr constant [7 x i8] c"Render\00"
@.str1416 = private unnamed_addr constant [18 x i8] c"  br label %loop\0A\00"
@.str1417 = private unnamed_addr constant [7 x i8] c"done:\0A\00"
@.str1418 = private unnamed_addr constant [7 x i8] c"OnQuit\00"
@.str1419 = private unnamed_addr constant [12 x i8] c"rt_shutdown\00"
@.str1420 = private unnamed_addr constant [31 x i8] c"  call void @fn_rt_shutdown()\0A\00"
@.str1421 = private unnamed_addr constant [15 x i8] c"  ret i32 0\0A}\0A\00"
@.str1422 = private unnamed_addr constant [25 x i8] c"call i32 @fn_rt_reg(i32 \00"
@.str1423 = private unnamed_addr constant [2 x i8] c")\00"
@.str1424 = private unnamed_addr constant [6 x i8] c"smend\00"
@.str1425 = private unnamed_addr constant [13 x i8] c"icmp eq i32 \00"
@.str1426 = private unnamed_addr constant [3 x i8] c", \00"
@.str1427 = private unnamed_addr constant [6 x i8] c"sbody\00"
@.str1428 = private unnamed_addr constant [5 x i8] c"sarm\00"
@.str1429 = private unnamed_addr constant [9 x i8] c"  br i1 \00"
@.str1430 = private unnamed_addr constant [10 x i8] c", label %\00"
@.str1431 = private unnamed_addr constant [10 x i8] c", label %\00"
@.str1432 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str1433 = private unnamed_addr constant [3 x i8] c":\0A\00"
@.str1434 = private unnamed_addr constant [13 x i8] c"  br label %\00"
@.str1435 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str1436 = private unnamed_addr constant [3 x i8] c":\0A\00"
@.str1437 = private unnamed_addr constant [13 x i8] c"  br label %\00"
@.str1438 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str1439 = private unnamed_addr constant [3 x i8] c":\0A\00"
@.str1440 = private unnamed_addr constant [27 x i8] c"'become' outside a machine\00"
@.str1441 = private unnamed_addr constant [18 x i8] c"become: no state \00"
@.str1442 = private unnamed_addr constant [32 x i8] c"  call void @fn_rt_set_reg(i32 \00"
@.str1443 = private unnamed_addr constant [7 x i8] c", i32 \00"
@.str1444 = private unnamed_addr constant [3 x i8] c")\0A\00"
@.str1445 = private unnamed_addr constant [4 x i8] c"%io\00"
@.str1446 = private unnamed_addr constant [3 x i8] c"  \00"
@.str1447 = private unnamed_addr constant [14 x i8] c" = call i64 @\00"
@.str1448 = private unnamed_addr constant [6 x i8] c"(ptr \00"
@.str1449 = private unnamed_addr constant [14 x i8] c", i64 1, i64 \00"
@.str1450 = private unnamed_addr constant [11 x i8] c", ptr %f)\0A\00"
@.str1451 = private unnamed_addr constant [8 x i8] c"@L_entc\00"
@.str1452 = private unnamed_addr constant [2 x i8] c"4\00"
@.str1453 = private unnamed_addr constant [9 x i8] c"@L_freen\00"
@.str1454 = private unnamed_addr constant [2 x i8] c"4\00"
@.str1455 = private unnamed_addr constant [21 x i8] c"  %nalive = mul i64 \00"
@.str1456 = private unnamed_addr constant [5 x i8] c", 4\0A\00"
@.str1457 = private unnamed_addr constant [9 x i8] c"@L_alive\00"
@.str1458 = private unnamed_addr constant [8 x i8] c"%nalive\00"
@.str1459 = private unnamed_addr constant [12 x i8] c"@L_freelist\00"
@.str1460 = private unnamed_addr constant [8 x i8] c"%nalive\00"
@.str1461 = private unnamed_addr constant [8 x i8] c"@L_kind\00"
@.str1462 = private unnamed_addr constant [8 x i8] c"%nalive\00"
@.str1463 = private unnamed_addr constant [4 x i8] c"@g_\00"
@.str1464 = private unnamed_addr constant [2 x i8] c"4\00"
@.str1465 = private unnamed_addr constant [5 x i8] c"%csz\00"
@.str1466 = private unnamed_addr constant [3 x i8] c"  \00"
@.str1467 = private unnamed_addr constant [37 x i8] c" = ptrtoint ptr getelementptr (%Cmp_\00"
@.str1468 = private unnamed_addr constant [17 x i8] c", ptr null, i32 \00"
@.str1469 = private unnamed_addr constant [10 x i8] c") to i64\0A\00"
@.str1470 = private unnamed_addr constant [4 x i8] c"@S_\00"
@.str1471 = private unnamed_addr constant [4 x i8] c"@H_\00"
@.str1472 = private unnamed_addr constant [70 x i8] c"@.sav_path = private unnamed_addr constant [10 x i8] c\22ludic.sav\5C00\22\0A\00"
@.str1473 = private unnamed_addr constant [60 x i8] c"@.sav_wb = private unnamed_addr constant [3 x i8] c\22wb\5C00\22\0A\00"
@.str1474 = private unnamed_addr constant [60 x i8] c"@.sav_rb = private unnamed_addr constant [3 x i8] c\22rb\5C00\22\0A\00"
@.str1475 = private unnamed_addr constant [14 x i8] c"rt_save_state\00"
@.str1476 = private unnamed_addr constant [14 x i8] c"rt_load_state\00"
@.str1477 = private unnamed_addr constant [32 x i8] c"define void @L_save() {\0Aentry:\0A\00"
@.str1478 = private unnamed_addr constant [54 x i8] c"  %f = call ptr @fopen(ptr @.sav_path, ptr @.sav_wb)\0A\00"
@.str1479 = private unnamed_addr constant [31 x i8] c"  %bad = icmp eq ptr %f, null\0A\00"
@.str1480 = private unnamed_addr constant [41 x i8] c"  br i1 %bad, label %out, label %go\0Ago:\0A\00"
@.str1481 = private unnamed_addr constant [7 x i8] c"fwrite\00"
@.str1482 = private unnamed_addr constant [39 x i8] c"  call void @fn_rt_save_state(ptr %f)\0A\00"
@.str1483 = private unnamed_addr constant [68 x i8] c"  %c = call i32 @fclose(ptr %f)\0A  br label %out\0Aout:\0A  ret void\0A}\0A\0A\00"
@.str1484 = private unnamed_addr constant [31 x i8] c"define i32 @L_load() {\0Aentry:\0A\00"
@.str1485 = private unnamed_addr constant [54 x i8] c"  %f = call ptr @fopen(ptr @.sav_path, ptr @.sav_rb)\0A\00"
@.str1486 = private unnamed_addr constant [31 x i8] c"  %bad = icmp eq ptr %f, null\0A\00"
@.str1487 = private unnamed_addr constant [60 x i8] c"  br i1 %bad, label %miss, label %go\0Amiss:\0A  ret i32 0\0Ago:\0A\00"
@.str1488 = private unnamed_addr constant [6 x i8] c"fread\00"
@.str1489 = private unnamed_addr constant [39 x i8] c"  call void @fn_rt_load_state(ptr %f)\0A\00"
@.str1490 = private unnamed_addr constant [48 x i8] c"  %c = call i32 @fclose(ptr %f)\0A  ret i32 1\0A}\0A\0A\00"
@.str1491 = private unnamed_addr constant [6 x i8] c"panel\00"
@.str1492 = private unnamed_addr constant [4 x i8] c"col\00"
@.str1493 = private unnamed_addr constant [4 x i8] c"row\00"
@.str1494 = private unnamed_addr constant [6 x i8] c"label\00"
@.str1495 = private unnamed_addr constant [7 x i8] c"button\00"
@.str1496 = private unnamed_addr constant [6 x i8] c"image\00"
@.str1497 = private unnamed_addr constant [7 x i8] c"spacer\00"
@.str1498 = private unnamed_addr constant [3 x i8] c"id\00"
@.str1499 = private unnamed_addr constant [31 x i8] c"  call void @fn_rt_ui_set(i32 \00"
@.str1500 = private unnamed_addr constant [7 x i8] c", i32 \00"
@.str1501 = private unnamed_addr constant [7 x i8] c", i32 \00"
@.str1502 = private unnamed_addr constant [3 x i8] c")\0A\00"
@.str1503 = private unnamed_addr constant [2 x i8] c"w\00"
@.str1504 = private unnamed_addr constant [2 x i8] c"h\00"
@.str1505 = private unnamed_addr constant [2 x i8] c"x\00"
@.str1506 = private unnamed_addr constant [2 x i8] c"y\00"
@.str1507 = private unnamed_addr constant [4 x i8] c"pad\00"
@.str1508 = private unnamed_addr constant [4 x i8] c"gap\00"
@.str1509 = private unnamed_addr constant [3 x i8] c"bg\00"
@.str1510 = private unnamed_addr constant [3 x i8] c"fg\00"
@.str1511 = private unnamed_addr constant [7 x i8] c"border\00"
@.str1512 = private unnamed_addr constant [5 x i8] c"grow\00"
@.str1513 = private unnamed_addr constant [5 x i8] c"font\00"
@.str1514 = private unnamed_addr constant [5 x i8] c"size\00"
@.str1515 = private unnamed_addr constant [6 x i8] c"inset\00"
@.str1516 = private unnamed_addr constant [6 x i8] c"focus\00"
@.str1517 = private unnamed_addr constant [33 x i8] c"  call void @fn_rt_ui_reset(i32 \00"
@.str1518 = private unnamed_addr constant [3 x i8] c")\0A\00"
@.str1519 = private unnamed_addr constant [2 x i8] c"1\00"
@.str1520 = private unnamed_addr constant [3 x i8] c"id\00"
@.str1521 = private unnamed_addr constant [5 x i8] c"text\00"
@.str1522 = private unnamed_addr constant [39 x i8] c"  call void @fn_rt_ui_static_text(i32 \00"
@.str1523 = private unnamed_addr constant [7 x i8] c", ptr \00"
@.str1524 = private unnamed_addr constant [3 x i8] c")\0A\00"
@.str1525 = private unnamed_addr constant [5 x i8] c"skin\00"
@.str1526 = private unnamed_addr constant [6 x i8] c"image\00"
@.str1527 = private unnamed_addr constant [32 x i8] c"call i32 @fn_rt_image_load(ptr \00"
@.str1528 = private unnamed_addr constant [2 x i8] c")\00"
@.str1529 = private unnamed_addr constant [5 x i8] c"skin\00"
@.str1530 = private unnamed_addr constant [6 x i8] c"align\00"
@.str1531 = private unnamed_addr constant [7 x i8] c"center\00"
@.str1532 = private unnamed_addr constant [4 x i8] c"end\00"
@.str1533 = private unnamed_addr constant [2 x i8] c"1\00"
@.str1534 = private unnamed_addr constant [34 x i8] c"define void @ui_build() {\0Aentry:\0A\00"
@.str1535 = private unnamed_addr constant [15 x i8] c"  ret void\0A}\0A\0A\00"
@.str1536 = private unnamed_addr constant [3 x i8] c", \00"
@.str1537 = private unnamed_addr constant [7 x i8] c" %arg_\00"
@.str1538 = private unnamed_addr constant [5 x i8] c"void\00"
@.str1539 = private unnamed_addr constant [20 x i8] c"  %retval = alloca \00"
@.str1540 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str1541 = private unnamed_addr constant [9 x i8] c"  store \00"
@.str1542 = private unnamed_addr constant [7 x i8] c" %arg_\00"
@.str1543 = private unnamed_addr constant [7 x i8] c", ptr \00"
@.str1544 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str1545 = private unnamed_addr constant [17 x i8] c"  br label %ret\0A\00"
@.str1546 = private unnamed_addr constant [6 x i8] c"ret:\0A\00"
@.str1547 = private unnamed_addr constant [5 x i8] c"void\00"
@.str1548 = private unnamed_addr constant [12 x i8] c"  ret void\0A\00"
@.str1549 = private unnamed_addr constant [6 x i8] c"load \00"
@.str1550 = private unnamed_addr constant [14 x i8] c", ptr %retval\00"
@.str1551 = private unnamed_addr constant [7 x i8] c"  ret \00"
@.str1552 = private unnamed_addr constant [2 x i8] c" \00"
@.str1553 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str1554 = private unnamed_addr constant [8 x i8] c"define \00"
@.str1555 = private unnamed_addr constant [6 x i8] c" @fn_\00"
@.str1556 = private unnamed_addr constant [2 x i8] c"(\00"
@.str1557 = private unnamed_addr constant [12 x i8] c") {\0Aentry:\0A\00"
@.str1558 = private unnamed_addr constant [4 x i8] c"}\0A\0A\00"
@.str1559 = private unnamed_addr constant [4 x i8] c"int\00"
@.str1560 = private unnamed_addr constant [24 x i8] c"  %retval = alloca i32\0A\00"
@.str1561 = private unnamed_addr constant [32 x i8] c"  store i32 %argc, ptr @L_argc\0A\00"
@.str1562 = private unnamed_addr constant [32 x i8] c"  store ptr %argv, ptr @L_argv\0A\00"
@.str1563 = private unnamed_addr constant [28 x i8] c"  store i32 0, ptr %retval\0A\00"
@.str1564 = private unnamed_addr constant [17 x i8] c"  br label %ret\0A\00"
@.str1565 = private unnamed_addr constant [6 x i8] c"ret:\0A\00"
@.str1566 = private unnamed_addr constant [22 x i8] c"load i32, ptr %retval\00"
@.str1567 = private unnamed_addr constant [11 x i8] c"  ret i32 \00"
@.str1568 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str1569 = private unnamed_addr constant [49 x i8] c"define i32 @main(i32 %argc, ptr %argv) {\0Aentry:\0A\00"
@.str1570 = private unnamed_addr constant [3 x i8] c"}\0A\00"
@.str1571 = private unnamed_addr constant [3 x i8] c"wb\00"
@.str1572 = private unnamed_addr constant [7 x i8] c".ludic\00"
@.str1573 = private unnamed_addr constant [2 x i8] c"/\00"
@.str1574 = private unnamed_addr constant [6 x i8] c"ludic\00"
@.str1575 = private unnamed_addr constant [11 x i8] c"--windowed\00"
@.str1576 = private unnamed_addr constant [11 x i8] c"--headless\00"
@.str1577 = private unnamed_addr constant [12 x i8] c"--emit-llvm\00"
@.str1578 = private unnamed_addr constant [6 x i8] c"--fmt\00"
@.str1579 = private unnamed_addr constant [13 x i8] c"--save-temps\00"
@.str1580 = private unnamed_addr constant [6 x i8] c"--run\00"
@.str1581 = private unnamed_addr constant [3 x i8] c"-o\00"
@.str1582 = private unnamed_addr constant [31 x i8] c"ludicc: ignoring unknown flag \00"
@.str1583 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str1584 = private unnamed_addr constant [90 x i8] c"usage: ludicc <file.ludic> [-o out] [--windowed|--headless] [--emit-llvm] [--save-temps]\0A\00"
@.str1585 = private unnamed_addr constant [27 x i8] c"ludicc: cannot open input\0A\00"
@.str1586 = private unnamed_addr constant [16 x i8] c"/tmp/ludic-run-\00"
@.str1587 = private unnamed_addr constant [10 x i8] c"mkdir -p \00"
@.str1588 = private unnamed_addr constant [4 x i8] c".ll\00"
@.str1589 = private unnamed_addr constant [25 x i8] c"ludicc: cannot write IR\0A\00"
@.str1590 = private unnamed_addr constant [9 x i8] c"LUDIC_CC\00"
@.str1591 = private unnamed_addr constant [6 x i8] c"clang\00"
@.str1592 = private unnamed_addr constant [11 x i8] c"LUDIC_HOME\00"
@.str1593 = private unnamed_addr constant [27 x i8] c" -O2 -Wno-override-module \00"
@.str1594 = private unnamed_addr constant [24 x i8] c"runtime/native/cocoa.ll\00"
@.str1595 = private unnamed_addr constant [2 x i8] c" \00"
@.str1596 = private unnamed_addr constant [42 x i8] c" -framework Cocoa -Wl,-rpath,@loader_path\00"
@.str1597 = private unnamed_addr constant [5 x i8] c" -o \00"
@.str1598 = private unnamed_addr constant [7 x i8] c"rm -f \00"
@.str1599 = private unnamed_addr constant [21 x i8] c"ludicc: link failed\0A\00"
define i32 @fn_str_eq(ptr %a, ptr %b) {
entry:
  br label %loop
loop:
  %i = phi i32 [ 0, %entry ], [ %i1, %cont ]
  %pa = getelementptr inbounds i8, ptr %a, i32 %i
  %pb = getelementptr inbounds i8, ptr %b, i32 %i
  %ca = load i8, ptr %pa
  %cb = load i8, ptr %pb
  %df = icmp ne i8 %ca, %cb
  br i1 %df, label %ret0, label %chk
chk:
  %zt = icmp eq i8 %ca, 0
  br i1 %zt, label %ret1, label %cont
cont:
  %i1 = add i32 %i, 1
  br label %loop
ret1:
  ret i32 1
ret0:
  ret i32 0
}
define ptr @fn_str_concat(ptr %a, ptr %b) {
entry:
  br label %al
al:
  %ia = phi i32 [ 0, %entry ], [ %ia1, %alb ]
  %pa = getelementptr inbounds i8, ptr %a, i32 %ia
  %cca = load i8, ptr %pa
  %za = icmp eq i8 %cca, 0
  br i1 %za, label %bl0, label %alb
alb:
  %ia1 = add i32 %ia, 1
  br label %al
bl0:
  br label %bl
bl:
  %ib = phi i32 [ 0, %bl0 ], [ %ib1, %blb ]
  %pb = getelementptr inbounds i8, ptr %b, i32 %ib
  %ccb = load i8, ptr %pb
  %zb = icmp eq i8 %ccb, 0
  br i1 %zb, label %alloc, label %blb
blb:
  %ib1 = add i32 %ib, 1
  br label %bl
alloc:
  %sum = add i32 %ia, %ib
  %sz = add i32 %sum, 1
  %sz64 = sext i32 %sz to i64
  %out = call ptr @malloc(i64 %sz64)
  br label %c1
c1:
  %i = phi i32 [ 0, %alloc ], [ %i1, %c1b ]
  %d1 = icmp slt i32 %i, %ia
  br i1 %d1, label %c1b, label %c2i
c1b:
  %s1 = getelementptr inbounds i8, ptr %a, i32 %i
  %v1 = load i8, ptr %s1
  %o1 = getelementptr inbounds i8, ptr %out, i32 %i
  store i8 %v1, ptr %o1
  %i1 = add i32 %i, 1
  br label %c1
c2i:
  br label %c2
c2:
  %j = phi i32 [ 0, %c2i ], [ %j1, %c2b ]
  %d2 = icmp slt i32 %j, %ib
  br i1 %d2, label %c2b, label %fin
c2b:
  %s2 = getelementptr inbounds i8, ptr %b, i32 %j
  %v2 = load i8, ptr %s2
  %oj = add i32 %ia, %j
  %o2 = getelementptr inbounds i8, ptr %out, i32 %oj
  store i8 %v2, ptr %o2
  %j1 = add i32 %j, 1
  br label %c2
fin:
  %pe = getelementptr inbounds i8, ptr %out, i32 %sum
  store i8 0, ptr %pe
  ret ptr %out
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
  %t0 = getelementptr %Cmp_Buf, ptr null, i32 1
  %t1 = ptrtoint ptr %t0 to i64
  %t2 = call ptr @malloc(i64 %t1)
  %t3 = getelementptr inbounds %Cmp_Buf, ptr %t2, i32 0, i32 0
  store ptr null, ptr %t3
  %t4 = getelementptr inbounds %Cmp_Buf, ptr %t2, i32 0, i32 1
  store i32 0, ptr %t4
  %t5 = getelementptr inbounds %Cmp_Buf, ptr %t2, i32 0, i32 2
  store i32 0, ptr %t5
  store ptr %t2, ptr %t6
  %t7 = load ptr, ptr %t6
  %t8 = getelementptr inbounds %Cmp_Buf, ptr %t7, i32 0, i32 2
  store i32 256, ptr %t8
  %t9 = load ptr, ptr %t6
  %t10 = getelementptr inbounds %Cmp_Buf, ptr %t9, i32 0, i32 0
  %t11 = load ptr, ptr %t6
  %t12 = getelementptr inbounds %Cmp_Buf, ptr %t11, i32 0, i32 2
  %t13 = load i32, ptr %t12
  %t14 = zext i32 %t13 to i64
  %t15 = call ptr @malloc(i64 %t14)
  store ptr %t15, ptr %t10
  %t16 = load ptr, ptr %t6
  %t17 = getelementptr inbounds %Cmp_Buf, ptr %t16, i32 0, i32 1
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
  %t3 = getelementptr inbounds %Cmp_Buf, ptr %t2, i32 0, i32 1
  %t4 = load i32, ptr %t3
  %t5 = load i32, ptr %t1
  %t6 = add i32 %t4, %t5
  %t7 = add i32 %t6, 1
  %t8 = load ptr, ptr %t0
  %t9 = getelementptr inbounds %Cmp_Buf, ptr %t8, i32 0, i32 2
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
  %t15 = getelementptr inbounds %Cmp_Buf, ptr %t14, i32 0, i32 1
  %t16 = load i32, ptr %t15
  %t17 = load i32, ptr %t1
  %t18 = add i32 %t16, %t17
  %t19 = add i32 %t18, 1
  %t20 = load ptr, ptr %t0
  %t21 = getelementptr inbounds %Cmp_Buf, ptr %t20, i32 0, i32 2
  %t22 = load i32, ptr %t21
  %t23 = icmp sgt i32 %t19, %t22
  %t24 = zext i1 %t23 to i32
  %t25 = icmp ne i32 %t24, 0
  br i1 %t25, label %wbody4, label %wend5
wbody4:
  %t26 = load ptr, ptr %t0
  %t27 = getelementptr inbounds %Cmp_Buf, ptr %t26, i32 0, i32 2
  %t28 = load ptr, ptr %t0
  %t29 = getelementptr inbounds %Cmp_Buf, ptr %t28, i32 0, i32 2
  %t30 = load i32, ptr %t29
  %t31 = mul i32 %t30, 2
  store i32 %t31, ptr %t27
  br label %wcond3
wend5:
  %t32 = load ptr, ptr %t0
  %t33 = getelementptr inbounds %Cmp_Buf, ptr %t32, i32 0, i32 0
  %t34 = load ptr, ptr %t0
  %t35 = getelementptr inbounds %Cmp_Buf, ptr %t34, i32 0, i32 0
  %t36 = load ptr, ptr %t35
  %t37 = load ptr, ptr %t0
  %t38 = getelementptr inbounds %Cmp_Buf, ptr %t37, i32 0, i32 2
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
  %t4 = getelementptr inbounds %Cmp_Buf, ptr %t3, i32 0, i32 0
  %t5 = load ptr, ptr %t4
  %t6 = load ptr, ptr %t0
  %t7 = getelementptr inbounds %Cmp_Buf, ptr %t6, i32 0, i32 1
  %t8 = load i32, ptr %t7
  %t9 = load i32, ptr %t1
  %t10 = getelementptr inbounds i8, ptr %t5, i32 %t8
  %t11 = trunc i32 %t9 to i8
  store i8 %t11, ptr %t10
  %t12 = load ptr, ptr %t0
  %t13 = getelementptr inbounds %Cmp_Buf, ptr %t12, i32 0, i32 1
  %t14 = load ptr, ptr %t0
  %t15 = getelementptr inbounds %Cmp_Buf, ptr %t14, i32 0, i32 1
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
  %t2 = getelementptr inbounds %Cmp_Buf, ptr %t1, i32 0, i32 0
  %t3 = load ptr, ptr %t2
  %t4 = load ptr, ptr %t0
  %t5 = getelementptr inbounds %Cmp_Buf, ptr %t4, i32 0, i32 1
  %t6 = load i32, ptr %t5
  %t7 = getelementptr inbounds i8, ptr %t3, i32 %t6
  %t8 = trunc i32 0 to i8
  store i8 %t8, ptr %t7
  %t9 = load ptr, ptr %t0
  %t10 = getelementptr inbounds %Cmp_Buf, ptr %t9, i32 0, i32 0
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
  %t1 = getelementptr %Cmp_Node, ptr null, i32 1
  %t2 = ptrtoint ptr %t1 to i64
  %t3 = call ptr @malloc(i64 %t2)
  %t4 = getelementptr inbounds %Cmp_Node, ptr %t3, i32 0, i32 0
  store i32 0, ptr %t4
  %t5 = getelementptr inbounds %Cmp_Node, ptr %t3, i32 0, i32 1
  store ptr null, ptr %t5
  %t6 = getelementptr inbounds %Cmp_Node, ptr %t3, i32 0, i32 2
  store i32 0, ptr %t6
  %t7 = getelementptr inbounds %Cmp_Node, ptr %t3, i32 0, i32 3
  store ptr null, ptr %t7
  %t8 = getelementptr inbounds %Cmp_Node, ptr %t3, i32 0, i32 4
  store ptr null, ptr %t8
  %t9 = getelementptr inbounds %Cmp_Node, ptr %t3, i32 0, i32 5
  store ptr null, ptr %t9
  %t10 = getelementptr inbounds %Cmp_Node, ptr %t3, i32 0, i32 6
  store ptr null, ptr %t10
  %t11 = getelementptr inbounds %Cmp_Node, ptr %t3, i32 0, i32 7
  store ptr null, ptr %t11
  %t12 = getelementptr inbounds %Cmp_Node, ptr %t3, i32 0, i32 8
  store i32 0, ptr %t12
  store ptr %t3, ptr %t13
  %t14 = load ptr, ptr %t13
  %t15 = getelementptr inbounds %Cmp_Node, ptr %t14, i32 0, i32 0
  %t16 = load i32, ptr %t0
  store i32 %t16, ptr %t15
  %t17 = load ptr, ptr %t13
  %t18 = getelementptr inbounds %Cmp_Node, ptr %t17, i32 0, i32 7
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
  %t4 = getelementptr %Cmp_Tok, ptr null, i32 1
  %t5 = ptrtoint ptr %t4 to i64
  %t6 = call ptr @malloc(i64 %t5)
  %t7 = getelementptr inbounds %Cmp_Tok, ptr %t6, i32 0, i32 0
  store i32 0, ptr %t7
  %t8 = getelementptr inbounds %Cmp_Tok, ptr %t6, i32 0, i32 1
  store ptr null, ptr %t8
  %t9 = getelementptr inbounds %Cmp_Tok, ptr %t6, i32 0, i32 2
  store i32 0, ptr %t9
  %t10 = getelementptr inbounds %Cmp_Tok, ptr %t6, i32 0, i32 3
  store i32 0, ptr %t10
  store ptr %t6, ptr %t11
  %t12 = load ptr, ptr %t11
  %t13 = getelementptr inbounds %Cmp_Tok, ptr %t12, i32 0, i32 0
  %t14 = load i32, ptr %t0
  store i32 %t14, ptr %t13
  %t15 = load ptr, ptr %t11
  %t16 = getelementptr inbounds %Cmp_Tok, ptr %t15, i32 0, i32 1
  %t17 = load ptr, ptr %t1
  store ptr %t17, ptr %t16
  %t18 = load ptr, ptr %t11
  %t19 = getelementptr inbounds %Cmp_Tok, ptr %t18, i32 0, i32 2
  %t20 = load i32, ptr %t2
  store i32 %t20, ptr %t19
  %t21 = load ptr, ptr %t11
  %t22 = getelementptr inbounds %Cmp_Tok, ptr %t21, i32 0, i32 3
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
  %t147 = alloca i32
  %t148 = alloca i32
  %t149 = alloca i32
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
  %t150 = load i32, ptr %t0
  %t151 = icmp eq i32 %t150, 38
  %t152 = zext i1 %t151 to i32
  %t153 = icmp ne i32 %t152, 0
  %t154 = zext i1 %t153 to i32
  store i32 %t154, ptr %t149
  br i1 %t153, label %scend44, label %sc43
sc43:
  %t155 = load i32, ptr %t0
  %t156 = icmp eq i32 %t155, 124
  %t157 = zext i1 %t156 to i32
  %t158 = icmp ne i32 %t157, 0
  %t159 = zext i1 %t158 to i32
  store i32 %t159, ptr %t149
  br label %scend44
scend44:
  %t160 = load i32, ptr %t149
  %t161 = icmp ne i32 %t160, 0
  %t162 = zext i1 %t161 to i32
  store i32 %t162, ptr %t148
  br i1 %t161, label %scend46, label %sc45
sc45:
  %t163 = load i32, ptr %t0
  %t164 = icmp eq i32 %t163, 94
  %t165 = zext i1 %t164 to i32
  %t166 = icmp ne i32 %t165, 0
  %t167 = zext i1 %t166 to i32
  store i32 %t167, ptr %t148
  br label %scend46
scend46:
  %t168 = load i32, ptr %t148
  %t169 = icmp ne i32 %t168, 0
  %t170 = zext i1 %t169 to i32
  store i32 %t170, ptr %t147
  br i1 %t169, label %scend48, label %sc47
sc47:
  %t171 = load i32, ptr %t0
  %t172 = icmp eq i32 %t171, 126
  %t173 = zext i1 %t172 to i32
  %t174 = icmp ne i32 %t173, 0
  %t175 = zext i1 %t174 to i32
  store i32 %t175, ptr %t147
  br label %scend48
scend48:
  %t176 = load i32, ptr %t147
  %t177 = icmp ne i32 %t176, 0
  br i1 %t177, label %then49, label %ifend51
then49:
  store i32 1, ptr %retval
  br label %ret
ifend51:
  store i32 0, ptr %retval
  br label %ret
ret:
  %t178 = load i32, ptr %retval
  ret i32 %t178
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
  %t558 = load ptr, ptr %t0
  %t559 = load i32, ptr %t7
  %t560 = call i32 @fn_two_at(ptr %t558, i32 %t559, i32 60, i32 60)
  %t561 = icmp ne i32 %t560, 0
  br i1 %t561, label %then144, label %ifend146
then144:
  %t562 = load ptr, ptr %t0
  %t563 = load i32, ptr %t7
  %t564 = call ptr @fn_substr(ptr %t562, i32 %t563, i32 2)
  %t565 = load i32, ptr %t8
  call void @fn_tok_push(i32 3, ptr %t564, i32 0, i32 %t565)
  %t566 = load i32, ptr %t7
  %t567 = add i32 %t566, 2
  store i32 %t567, ptr %t7
  br label %wcond0
ifend146:
  %t568 = load ptr, ptr %t0
  %t569 = load i32, ptr %t7
  %t570 = call i32 @fn_two_at(ptr %t568, i32 %t569, i32 62, i32 62)
  %t571 = icmp ne i32 %t570, 0
  br i1 %t571, label %then147, label %ifend149
then147:
  %t572 = load ptr, ptr %t0
  %t573 = load i32, ptr %t7
  %t574 = call ptr @fn_substr(ptr %t572, i32 %t573, i32 2)
  %t575 = load i32, ptr %t8
  call void @fn_tok_push(i32 3, ptr %t574, i32 0, i32 %t575)
  %t576 = load i32, ptr %t7
  %t577 = add i32 %t576, 2
  store i32 %t577, ptr %t7
  br label %wcond0
ifend149:
  %t578 = load i32, ptr %t22
  %t579 = call i32 @fn_is_op1(i32 %t578)
  %t580 = icmp ne i32 %t579, 0
  br i1 %t580, label %then150, label %ifend152
then150:
  %t581 = load ptr, ptr %t0
  %t582 = load i32, ptr %t7
  %t583 = call ptr @fn_substr(ptr %t581, i32 %t582, i32 1)
  %t584 = load i32, ptr %t8
  call void @fn_tok_push(i32 3, ptr %t583, i32 0, i32 %t584)
  %t585 = load i32, ptr %t7
  %t586 = add i32 %t585, 1
  store i32 %t586, ptr %t7
  br label %wcond0
ifend152:
  %t587 = load i32, ptr %t7
  %t588 = add i32 %t587, 1
  store i32 %t588, ptr %t7
  br label %wcond0
wend2:
  %t589 = load i32, ptr %t8
  call void @fn_tok_push(i32 5, ptr null, i32 0, i32 %t589)
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
  %t10 = getelementptr inbounds %Cmp_Tok, ptr %t9, i32 0, i32 0
  %t11 = load i32, ptr %t10
  %t12 = icmp eq i32 %t11, 3
  %t13 = zext i1 %t12 to i32
  %t14 = icmp ne i32 %t13, 0
  %t15 = zext i1 %t14 to i32
  store i32 %t15, ptr %t8
  br i1 %t14, label %sc0, label %scend1
sc0:
  %t16 = load ptr, ptr %t7
  %t17 = getelementptr inbounds %Cmp_Tok, ptr %t16, i32 0, i32 1
  %t18 = load ptr, ptr %t17
  %t19 = load ptr, ptr %t0
  %t20 = call i32 @fn_str_eq(ptr %t18, ptr %t19)
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
  %t10 = getelementptr inbounds %Cmp_Tok, ptr %t9, i32 0, i32 0
  %t11 = load i32, ptr %t10
  %t12 = icmp eq i32 %t11, 0
  %t13 = zext i1 %t12 to i32
  %t14 = icmp ne i32 %t13, 0
  %t15 = zext i1 %t14 to i32
  store i32 %t15, ptr %t8
  br i1 %t14, label %sc0, label %scend1
sc0:
  %t16 = load ptr, ptr %t7
  %t17 = getelementptr inbounds %Cmp_Tok, ptr %t16, i32 0, i32 1
  %t18 = load ptr, ptr %t17
  %t19 = load ptr, ptr %t0
  %t20 = call i32 @fn_str_eq(ptr %t18, ptr %t19)
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
  %t8 = getelementptr inbounds %Cmp_Tok, ptr %t7, i32 0, i32 0
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
  %t16 = getelementptr inbounds %Cmp_Tok, ptr %t15, i32 0, i32 1
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
  %t6 = getelementptr inbounds %Cmp_Tok, ptr %t5, i32 0, i32 0
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
  %t6 = getelementptr inbounds %Cmp_Node, ptr %t5, i32 0, i32 7
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
  %t101 = alloca ptr
  %t107 = alloca ptr
  %t121 = alloca ptr
  %t0 = load ptr, ptr @g_toks
  %t1 = getelementptr inbounds %LSlice, ptr %t0, i32 0, i32 0
  %t2 = load ptr, ptr %t1
  %t3 = load i32, ptr @g_pi
  %t4 = getelementptr inbounds ptr, ptr %t2, i32 %t3
  %t5 = load ptr, ptr %t4
  store ptr %t5, ptr %t6
  %t7 = load ptr, ptr %t6
  %t8 = getelementptr inbounds %Cmp_Tok, ptr %t7, i32 0, i32 0
  %t9 = load i32, ptr %t8
  %t10 = icmp eq i32 %t9, 1
  %t11 = zext i1 %t10 to i32
  %t12 = icmp ne i32 %t11, 0
  br i1 %t12, label %then0, label %ifend2
then0:
  %t13 = call ptr @fn_node(i32 30)
  store ptr %t13, ptr %t14
  %t15 = load ptr, ptr %t14
  %t16 = getelementptr inbounds %Cmp_Node, ptr %t15, i32 0, i32 2
  %t17 = load ptr, ptr %t6
  %t18 = getelementptr inbounds %Cmp_Tok, ptr %t17, i32 0, i32 2
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
  %t24 = getelementptr inbounds %Cmp_Tok, ptr %t23, i32 0, i32 0
  %t25 = load i32, ptr %t24
  %t26 = icmp eq i32 %t25, 6
  %t27 = zext i1 %t26 to i32
  %t28 = icmp ne i32 %t27, 0
  br i1 %t28, label %then3, label %ifend5
then3:
  %t29 = call ptr @fn_node(i32 40)
  store ptr %t29, ptr %t30
  %t31 = load ptr, ptr %t30
  %t32 = getelementptr inbounds %Cmp_Node, ptr %t31, i32 0, i32 2
  %t33 = load ptr, ptr %t6
  %t34 = getelementptr inbounds %Cmp_Tok, ptr %t33, i32 0, i32 2
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
  %t40 = getelementptr inbounds %Cmp_Tok, ptr %t39, i32 0, i32 0
  %t41 = load i32, ptr %t40
  %t42 = icmp eq i32 %t41, 2
  %t43 = zext i1 %t42 to i32
  %t44 = icmp ne i32 %t43, 0
  br i1 %t44, label %then6, label %ifend8
then6:
  %t45 = call ptr @fn_node(i32 31)
  store ptr %t45, ptr %t46
  %t47 = load ptr, ptr %t46
  %t48 = getelementptr inbounds %Cmp_Node, ptr %t47, i32 0, i32 1
  %t49 = load ptr, ptr %t6
  %t50 = getelementptr inbounds %Cmp_Tok, ptr %t49, i32 0, i32 1
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
  %t56 = getelementptr inbounds %Cmp_Tok, ptr %t55, i32 0, i32 0
  %t57 = load i32, ptr %t56
  %t58 = icmp eq i32 %t57, 0
  %t59 = zext i1 %t58 to i32
  %t60 = icmp ne i32 %t59, 0
  br i1 %t60, label %then9, label %ifend11
then9:
  %t61 = load ptr, ptr %t6
  %t62 = getelementptr inbounds %Cmp_Tok, ptr %t61, i32 0, i32 1
  %t63 = load ptr, ptr %t62
  %t64 = call i32 @fn_str_eq(ptr %t63, ptr @.str10)
  %t65 = icmp ne i32 %t64, 0
  br i1 %t65, label %then12, label %ifend14
then12:
  %t66 = call ptr @fn_node(i32 32)
  store ptr %t66, ptr %t67
  %t68 = load ptr, ptr %t67
  %t69 = getelementptr inbounds %Cmp_Node, ptr %t68, i32 0, i32 2
  store i32 1, ptr %t69
  %t70 = load i32, ptr @g_pi
  %t71 = add i32 %t70, 1
  store i32 %t71, ptr @g_pi
  %t72 = load ptr, ptr %t67
  store ptr %t72, ptr %retval
  br label %ret
ifend14:
  %t73 = load ptr, ptr %t6
  %t74 = getelementptr inbounds %Cmp_Tok, ptr %t73, i32 0, i32 1
  %t75 = load ptr, ptr %t74
  %t76 = call i32 @fn_str_eq(ptr %t75, ptr @.str11)
  %t77 = icmp ne i32 %t76, 0
  br i1 %t77, label %then15, label %ifend17
then15:
  %t78 = call ptr @fn_node(i32 32)
  store ptr %t78, ptr %t79
  %t80 = load ptr, ptr %t79
  %t81 = getelementptr inbounds %Cmp_Node, ptr %t80, i32 0, i32 2
  store i32 0, ptr %t81
  %t82 = load i32, ptr @g_pi
  %t83 = add i32 %t82, 1
  store i32 %t83, ptr @g_pi
  %t84 = load ptr, ptr %t79
  store ptr %t84, ptr %retval
  br label %ret
ifend17:
  %t85 = load ptr, ptr %t6
  %t86 = getelementptr inbounds %Cmp_Tok, ptr %t85, i32 0, i32 1
  %t87 = load ptr, ptr %t86
  %t88 = call i32 @fn_str_eq(ptr %t87, ptr @.str12)
  %t89 = icmp ne i32 %t88, 0
  br i1 %t89, label %then18, label %ifend20
then18:
  %t90 = load i32, ptr @g_pi
  %t91 = add i32 %t90, 1
  store i32 %t91, ptr @g_pi
  %t92 = call ptr @fn_node(i32 43)
  store ptr %t92, ptr %retval
  br label %ret
ifend20:
  %t93 = load ptr, ptr %t6
  %t94 = getelementptr inbounds %Cmp_Tok, ptr %t93, i32 0, i32 1
  %t95 = load ptr, ptr %t94
  %t96 = call i32 @fn_str_eq(ptr %t95, ptr @.str13)
  %t97 = icmp ne i32 %t96, 0
  br i1 %t97, label %then21, label %ifend23
then21:
  %t98 = load i32, ptr @g_pi
  %t99 = add i32 %t98, 1
  store i32 %t99, ptr @g_pi
  %t100 = call ptr @fn_node(i32 39)
  store ptr %t100, ptr %t101
  %t102 = load ptr, ptr %t101
  %t103 = getelementptr inbounds %Cmp_Node, ptr %t102, i32 0, i32 1
  %t104 = call ptr @fn_ptype()
  store ptr %t104, ptr %t103
  %t105 = load ptr, ptr %t101
  store ptr %t105, ptr %retval
  br label %ret
ifend23:
  %t106 = call ptr @fn_node(i32 33)
  store ptr %t106, ptr %t107
  %t108 = load ptr, ptr %t107
  %t109 = getelementptr inbounds %Cmp_Node, ptr %t108, i32 0, i32 1
  %t110 = load ptr, ptr %t6
  %t111 = getelementptr inbounds %Cmp_Tok, ptr %t110, i32 0, i32 1
  %t112 = load ptr, ptr %t111
  store ptr %t112, ptr %t109
  %t113 = load i32, ptr @g_pi
  %t114 = add i32 %t113, 1
  store i32 %t114, ptr @g_pi
  %t115 = load ptr, ptr %t107
  store ptr %t115, ptr %retval
  br label %ret
ifend11:
  %t116 = call i32 @fn_is_op(ptr @.str14)
  %t117 = icmp ne i32 %t116, 0
  br i1 %t117, label %then24, label %ifend26
then24:
  %t118 = load i32, ptr @g_pi
  %t119 = add i32 %t118, 1
  store i32 %t119, ptr @g_pi
  call void @fn_skipnl()
  %t120 = call ptr @fn_expr()
  store ptr %t120, ptr %t121
  call void @fn_skipnl()
  call void @fn_eat_op(ptr @.str15)
  %t122 = load ptr, ptr %t121
  store ptr %t122, ptr %retval
  br label %ret
ifend26:
  call void @fn_perr(ptr @.str16)
  %t123 = call ptr @fn_node(i32 30)
  store ptr %t123, ptr %retval
  br label %ret
ret:
  %t124 = load ptr, ptr %retval
  ret ptr %t124
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
  %t3 = call i32 @fn_is_op(ptr @.str17)
  %t4 = icmp ne i32 %t3, 0
  br i1 %t4, label %then3, label %else4
then3:
  %t5 = load i32, ptr @g_pi
  %t6 = add i32 %t5, 1
  store i32 %t6, ptr @g_pi
  %t7 = call ptr @fn_node(i32 35)
  store ptr %t7, ptr %t8
  %t9 = load ptr, ptr %t8
  %t10 = getelementptr inbounds %Cmp_Node, ptr %t9, i32 0, i32 4
  %t11 = load ptr, ptr %t1
  store ptr %t11, ptr %t10
  %t12 = load ptr, ptr %t8
  %t13 = getelementptr inbounds %Cmp_Node, ptr %t12, i32 0, i32 1
  %t14 = call ptr @fn_eat_id()
  store ptr %t14, ptr %t13
  %t15 = load ptr, ptr %t8
  store ptr %t15, ptr %t1
  br label %ifend5
else4:
  %t16 = call i32 @fn_is_op(ptr @.str18)
  %t17 = icmp ne i32 %t16, 0
  br i1 %t17, label %then6, label %else7
then6:
  %t18 = load i32, ptr @g_pi
  %t19 = add i32 %t18, 1
  store i32 %t19, ptr @g_pi
  %t20 = call ptr @fn_node(i32 36)
  store ptr %t20, ptr %t21
  %t22 = load ptr, ptr %t21
  %t23 = getelementptr inbounds %Cmp_Node, ptr %t22, i32 0, i32 4
  %t24 = load ptr, ptr %t1
  store ptr %t24, ptr %t23
  %t25 = load ptr, ptr %t21
  %t26 = getelementptr inbounds %Cmp_Node, ptr %t25, i32 0, i32 5
  %t27 = call ptr @fn_expr()
  store ptr %t27, ptr %t26
  call void @fn_eat_op(ptr @.str19)
  %t28 = load ptr, ptr %t21
  store ptr %t28, ptr %t1
  br label %ifend8
else7:
  %t29 = call i32 @fn_is_op(ptr @.str20)
  %t30 = icmp ne i32 %t29, 0
  br i1 %t30, label %then9, label %else10
then9:
  %t31 = call ptr @fn_node(i32 34)
  store ptr %t31, ptr %t32
  %t33 = load ptr, ptr %t32
  %t34 = getelementptr inbounds %Cmp_Node, ptr %t33, i32 0, i32 4
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
  %t29 = alloca ptr
  %t0 = call i32 @fn_is_op(ptr @.str21)
  %t1 = icmp ne i32 %t0, 0
  br i1 %t1, label %then0, label %ifend2
then0:
  %t2 = load i32, ptr @g_pi
  %t3 = add i32 %t2, 1
  store i32 %t3, ptr @g_pi
  %t4 = call ptr @fn_node(i32 38)
  store ptr %t4, ptr %t5
  %t6 = load ptr, ptr %t5
  %t7 = getelementptr inbounds %Cmp_Node, ptr %t6, i32 0, i32 1
  store ptr @.str22, ptr %t7
  %t8 = load ptr, ptr %t5
  %t9 = getelementptr inbounds %Cmp_Node, ptr %t8, i32 0, i32 4
  %t10 = call ptr @fn_p_unary()
  store ptr %t10, ptr %t9
  %t11 = load ptr, ptr %t5
  store ptr %t11, ptr %retval
  br label %ret
ifend2:
  %t12 = call i32 @fn_is_op(ptr @.str23)
  %t13 = icmp ne i32 %t12, 0
  br i1 %t13, label %then3, label %ifend5
then3:
  %t14 = load i32, ptr @g_pi
  %t15 = add i32 %t14, 1
  store i32 %t15, ptr @g_pi
  %t16 = call ptr @fn_node(i32 38)
  store ptr %t16, ptr %t17
  %t18 = load ptr, ptr %t17
  %t19 = getelementptr inbounds %Cmp_Node, ptr %t18, i32 0, i32 1
  store ptr @.str24, ptr %t19
  %t20 = load ptr, ptr %t17
  %t21 = getelementptr inbounds %Cmp_Node, ptr %t20, i32 0, i32 4
  %t22 = call ptr @fn_p_unary()
  store ptr %t22, ptr %t21
  %t23 = load ptr, ptr %t17
  store ptr %t23, ptr %retval
  br label %ret
ifend5:
  %t24 = call i32 @fn_is_id(ptr @.str25)
  %t25 = icmp ne i32 %t24, 0
  br i1 %t25, label %then6, label %ifend8
then6:
  %t26 = load i32, ptr @g_pi
  %t27 = add i32 %t26, 1
  store i32 %t27, ptr @g_pi
  %t28 = call ptr @fn_node(i32 38)
  store ptr %t28, ptr %t29
  %t30 = load ptr, ptr %t29
  %t31 = getelementptr inbounds %Cmp_Node, ptr %t30, i32 0, i32 1
  store ptr @.str26, ptr %t31
  %t32 = load ptr, ptr %t29
  %t33 = getelementptr inbounds %Cmp_Node, ptr %t32, i32 0, i32 4
  %t34 = call ptr @fn_p_unary()
  store ptr %t34, ptr %t33
  %t35 = load ptr, ptr %t29
  store ptr %t35, ptr %retval
  br label %ret
ifend8:
  %t36 = call ptr @fn_p_postfix()
  store ptr %t36, ptr %retval
  br label %ret
ret:
  %t37 = load ptr, ptr %retval
  ret ptr %t37
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
  %t6 = getelementptr inbounds %Cmp_Node, ptr %t5, i32 0, i32 1
  %t7 = load ptr, ptr %t0
  store ptr %t7, ptr %t6
  %t8 = load ptr, ptr %t4
  %t9 = getelementptr inbounds %Cmp_Node, ptr %t8, i32 0, i32 4
  %t10 = load ptr, ptr %t1
  store ptr %t10, ptr %t9
  %t11 = load ptr, ptr %t4
  %t12 = getelementptr inbounds %Cmp_Node, ptr %t11, i32 0, i32 5
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
  %t4 = alloca i32
  %t5 = alloca i32
  %t6 = alloca i32
  %t47 = alloca ptr
  %t0 = call ptr @fn_p_unary()
  store ptr %t0, ptr %t1
  br label %wcond0
wcond0:
  %t7 = call i32 @fn_is_op(ptr @.str27)
  %t8 = icmp ne i32 %t7, 0
  %t9 = zext i1 %t8 to i32
  store i32 %t9, ptr %t6
  br i1 %t8, label %scend4, label %sc3
sc3:
  %t10 = call i32 @fn_is_op(ptr @.str28)
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
  %t16 = call i32 @fn_is_op(ptr @.str29)
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
  %t22 = call i32 @fn_is_op(ptr @.str30)
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
  %t28 = call i32 @fn_is_op(ptr @.str31)
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
  %t34 = call i32 @fn_is_op(ptr @.str32)
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
  %t45 = getelementptr inbounds %Cmp_Tok, ptr %t44, i32 0, i32 1
  %t46 = load ptr, ptr %t45
  store ptr %t46, ptr %t47
  %t48 = load i32, ptr @g_pi
  %t49 = add i32 %t48, 1
  store i32 %t49, ptr @g_pi
  %t50 = load ptr, ptr %t47
  %t51 = load ptr, ptr %t1
  %t52 = call ptr @fn_p_unary()
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

define ptr @fn_p_add() {
entry:
  %retval = alloca ptr
  %t1 = alloca ptr
  %t2 = alloca i32
  %t3 = alloca i32
  %t4 = alloca i32
  %t33 = alloca ptr
  %t0 = call ptr @fn_p_mul()
  store ptr %t0, ptr %t1
  br label %wcond0
wcond0:
  %t5 = call i32 @fn_is_op(ptr @.str33)
  %t6 = icmp ne i32 %t5, 0
  %t7 = zext i1 %t6 to i32
  store i32 %t7, ptr %t4
  br i1 %t6, label %scend4, label %sc3
sc3:
  %t8 = call i32 @fn_is_op(ptr @.str34)
  %t9 = icmp ne i32 %t8, 0
  %t10 = zext i1 %t9 to i32
  store i32 %t10, ptr %t4
  br label %scend4
scend4:
  %t11 = load i32, ptr %t4
  %t12 = icmp ne i32 %t11, 0
  %t13 = zext i1 %t12 to i32
  store i32 %t13, ptr %t3
  br i1 %t12, label %scend6, label %sc5
sc5:
  %t14 = call i32 @fn_is_op(ptr @.str35)
  %t15 = icmp ne i32 %t14, 0
  %t16 = zext i1 %t15 to i32
  store i32 %t16, ptr %t3
  br label %scend6
scend6:
  %t17 = load i32, ptr %t3
  %t18 = icmp ne i32 %t17, 0
  %t19 = zext i1 %t18 to i32
  store i32 %t19, ptr %t2
  br i1 %t18, label %scend8, label %sc7
sc7:
  %t20 = call i32 @fn_is_op(ptr @.str36)
  %t21 = icmp ne i32 %t20, 0
  %t22 = zext i1 %t21 to i32
  store i32 %t22, ptr %t2
  br label %scend8
scend8:
  %t23 = load i32, ptr %t2
  %t24 = icmp ne i32 %t23, 0
  br i1 %t24, label %wbody1, label %wend2
wbody1:
  %t25 = load ptr, ptr @g_toks
  %t26 = getelementptr inbounds %LSlice, ptr %t25, i32 0, i32 0
  %t27 = load ptr, ptr %t26
  %t28 = load i32, ptr @g_pi
  %t29 = getelementptr inbounds ptr, ptr %t27, i32 %t28
  %t30 = load ptr, ptr %t29
  %t31 = getelementptr inbounds %Cmp_Tok, ptr %t30, i32 0, i32 1
  %t32 = load ptr, ptr %t31
  store ptr %t32, ptr %t33
  %t34 = load i32, ptr @g_pi
  %t35 = add i32 %t34, 1
  store i32 %t35, ptr @g_pi
  %t36 = load ptr, ptr %t33
  %t37 = load ptr, ptr %t1
  %t38 = call ptr @fn_p_mul()
  %t39 = call ptr @fn_mkbin(ptr %t36, ptr %t37, ptr %t38)
  store ptr %t39, ptr %t1
  br label %wcond0
wend2:
  %t40 = load ptr, ptr %t1
  store ptr %t40, ptr %retval
  br label %ret
ret:
  %t41 = load ptr, ptr %retval
  ret ptr %t41
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
  %t7 = call i32 @fn_is_op(ptr @.str37)
  %t8 = icmp ne i32 %t7, 0
  %t9 = zext i1 %t8 to i32
  store i32 %t9, ptr %t6
  br i1 %t8, label %scend4, label %sc3
sc3:
  %t10 = call i32 @fn_is_op(ptr @.str38)
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
  %t16 = call i32 @fn_is_op(ptr @.str39)
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
  %t22 = call i32 @fn_is_op(ptr @.str40)
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
  %t28 = call i32 @fn_is_op(ptr @.str41)
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
  %t34 = call i32 @fn_is_op(ptr @.str42)
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
  %t45 = getelementptr inbounds %Cmp_Tok, ptr %t44, i32 0, i32 1
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
  %t2 = call i32 @fn_is_id(ptr @.str43)
  %t3 = icmp ne i32 %t2, 0
  br i1 %t3, label %wbody1, label %wend2
wbody1:
  %t4 = load i32, ptr @g_pi
  %t5 = add i32 %t4, 1
  store i32 %t5, ptr @g_pi
  %t6 = load ptr, ptr %t1
  %t7 = call ptr @fn_p_cmp()
  %t8 = call ptr @fn_mkbin(ptr @.str44, ptr %t6, ptr %t7)
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
  %t2 = call i32 @fn_is_id(ptr @.str45)
  %t3 = icmp ne i32 %t2, 0
  br i1 %t3, label %wbody1, label %wend2
wbody1:
  %t4 = load i32, ptr @g_pi
  %t5 = add i32 %t4, 1
  store i32 %t5, ptr @g_pi
  %t6 = load ptr, ptr %t1
  %t7 = call ptr @fn_p_and()
  %t8 = call ptr @fn_mkbin(ptr @.str46, ptr %t6, ptr %t7)
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
  call void @fn_eat_op(ptr @.str47)
  %t0 = call ptr @fn_node(i32 41)
  store ptr %t0, ptr %t1
  br label %wcond0
wcond0:
  %t2 = icmp ne i32 1, 0
  br i1 %t2, label %wbody1, label %wend2
wbody1:
  call void @fn_skipnl()
  %t3 = call i32 @fn_is_op(ptr @.str48)
  %t4 = icmp ne i32 %t3, 0
  br i1 %t4, label %then3, label %ifend5
then3:
  br label %wend2
ifend5:
  %t5 = call ptr @fn_node(i32 42)
  store ptr %t5, ptr %t6
  %t7 = load ptr, ptr %t6
  %t8 = getelementptr inbounds %Cmp_Node, ptr %t7, i32 0, i32 1
  %t9 = call ptr @fn_eat_id()
  store ptr %t9, ptr %t8
  call void @fn_eat_op(ptr @.str49)
  %t10 = load ptr, ptr %t6
  %t11 = getelementptr inbounds %Cmp_Node, ptr %t10, i32 0, i32 4
  %t12 = call ptr @fn_expr()
  store ptr %t12, ptr %t11
  %t13 = load ptr, ptr %t1
  %t14 = getelementptr inbounds %Cmp_Node, ptr %t13, i32 0, i32 7
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
  %t35 = call i32 @fn_is_op(ptr @.str50)
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
  call void @fn_eat_op(ptr @.str51)
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
  call void @fn_skipnl()
  call void @fn_eat_op(ptr @.str52)
  %t0 = call ptr @fn_node(i32 7)
  store ptr %t0, ptr %t1
  br label %wcond0
wcond0:
  %t2 = icmp ne i32 1, 0
  br i1 %t2, label %wbody1, label %wend2
wbody1:
  call void @fn_skipnl()
  %t3 = call i32 @fn_is_op(ptr @.str53)
  %t4 = icmp ne i32 %t3, 0
  br i1 %t4, label %then3, label %ifend5
then3:
  br label %wend2
ifend5:
  %t5 = load ptr, ptr %t1
  %t6 = getelementptr inbounds %Cmp_Node, ptr %t5, i32 0, i32 7
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
  %t33 = getelementptr inbounds %Cmp_Tok, ptr %t32, i32 0, i32 0
  %t34 = load i32, ptr %t33
  %t35 = icmp eq i32 %t34, 4
  %t36 = zext i1 %t35 to i32
  store i32 %t36, ptr %t37
  %t38 = call i32 @fn_is_op(ptr @.str54)
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
  call void @fn_perr(ptr @.str55)
  br label %ifend13
ifend13:
  br label %wcond0
wend2:
  call void @fn_eat_op(ptr @.str56)
  %t44 = load ptr, ptr %t1
  store ptr %t44, ptr %retval
  br label %ret
ret:
  %t45 = load ptr, ptr %retval
  ret ptr %t45
}

define ptr @fn_stmt() {
entry:
  %retval = alloca ptr
  %t6 = alloca ptr
  %t13 = alloca i32
  %t28 = alloca i32
  %t37 = alloca ptr
  %t77 = alloca ptr
  %t78 = alloca i32
  %t110 = alloca ptr
  %t118 = alloca i32
  %t141 = alloca ptr
  %t160 = alloca ptr
  %t165 = alloca ptr
  %t190 = alloca ptr
  %t194 = alloca i32
  %t199 = alloca ptr
  %t201 = alloca ptr
  %t213 = alloca ptr
  %t256 = alloca ptr
  %t269 = alloca ptr
  %t274 = alloca i32
  %t289 = alloca i32
  %t298 = alloca ptr
  %t337 = alloca ptr
  %t345 = alloca ptr
  %t379 = alloca ptr
  %t429 = alloca ptr
  %t430 = alloca i32
  %t431 = alloca i32
  %t432 = alloca i32
  %t433 = alloca i32
  %t461 = alloca ptr
  %t492 = alloca ptr
  %t0 = load ptr, ptr @g_toks
  %t1 = getelementptr inbounds %LSlice, ptr %t0, i32 0, i32 0
  %t2 = load ptr, ptr %t1
  %t3 = load i32, ptr @g_pi
  %t4 = getelementptr inbounds ptr, ptr %t2, i32 %t3
  %t5 = load ptr, ptr %t4
  store ptr %t5, ptr %t6
  %t7 = load ptr, ptr %t6
  %t8 = getelementptr inbounds %Cmp_Tok, ptr %t7, i32 0, i32 0
  %t9 = load i32, ptr %t8
  %t10 = icmp eq i32 %t9, 0
  %t11 = zext i1 %t10 to i32
  %t12 = icmp ne i32 %t11, 0
  br i1 %t12, label %then0, label %ifend2
then0:
  %t14 = load ptr, ptr %t6
  %t15 = getelementptr inbounds %Cmp_Tok, ptr %t14, i32 0, i32 1
  %t16 = load ptr, ptr %t15
  %t17 = call i32 @fn_str_eq(ptr %t16, ptr @.str57)
  %t18 = icmp ne i32 %t17, 0
  %t19 = zext i1 %t18 to i32
  store i32 %t19, ptr %t13
  br i1 %t18, label %scend4, label %sc3
sc3:
  %t20 = load ptr, ptr %t6
  %t21 = getelementptr inbounds %Cmp_Tok, ptr %t20, i32 0, i32 1
  %t22 = load ptr, ptr %t21
  %t23 = call i32 @fn_str_eq(ptr %t22, ptr @.str58)
  %t24 = icmp ne i32 %t23, 0
  %t25 = zext i1 %t24 to i32
  store i32 %t25, ptr %t13
  br label %scend4
scend4:
  %t26 = load i32, ptr %t13
  %t27 = icmp ne i32 %t26, 0
  br i1 %t27, label %then5, label %ifend7
then5:
  store i32 0, ptr %t28
  %t29 = load ptr, ptr %t6
  %t30 = getelementptr inbounds %Cmp_Tok, ptr %t29, i32 0, i32 1
  %t31 = load ptr, ptr %t30
  %t32 = call i32 @fn_str_eq(ptr %t31, ptr @.str59)
  %t33 = icmp ne i32 %t32, 0
  br i1 %t33, label %then8, label %ifend10
then8:
  store i32 1, ptr %t28
  br label %ifend10
ifend10:
  %t34 = load i32, ptr @g_pi
  %t35 = add i32 %t34, 1
  store i32 %t35, ptr @g_pi
  %t36 = call ptr @fn_node(i32 10)
  store ptr %t36, ptr %t37
  %t38 = load ptr, ptr %t37
  %t39 = getelementptr inbounds %Cmp_Node, ptr %t38, i32 0, i32 2
  %t40 = load i32, ptr %t28
  store i32 %t40, ptr %t39
  %t41 = load ptr, ptr %t37
  %t42 = getelementptr inbounds %Cmp_Node, ptr %t41, i32 0, i32 8
  %t43 = load ptr, ptr @g_toks
  %t44 = getelementptr inbounds %LSlice, ptr %t43, i32 0, i32 0
  %t45 = load ptr, ptr %t44
  %t46 = load i32, ptr @g_pi
  %t47 = getelementptr inbounds ptr, ptr %t45, i32 %t46
  %t48 = load ptr, ptr %t47
  %t49 = getelementptr inbounds %Cmp_Tok, ptr %t48, i32 0, i32 3
  %t50 = load i32, ptr %t49
  store i32 %t50, ptr %t42
  %t51 = load ptr, ptr %t37
  %t52 = getelementptr inbounds %Cmp_Node, ptr %t51, i32 0, i32 1
  %t53 = call ptr @fn_eat_id()
  store ptr %t53, ptr %t52
  %t54 = call i32 @fn_is_op(ptr @.str60)
  %t55 = icmp ne i32 %t54, 0
  br i1 %t55, label %then11, label %ifend13
then11:
  %t56 = load i32, ptr @g_pi
  %t57 = add i32 %t56, 1
  store i32 %t57, ptr @g_pi
  %t58 = load ptr, ptr %t37
  %t59 = getelementptr inbounds %Cmp_Node, ptr %t58, i32 0, i32 3
  %t60 = call ptr @fn_ptype()
  store ptr %t60, ptr %t59
  br label %ifend13
ifend13:
  %t61 = call i32 @fn_is_op(ptr @.str61)
  %t62 = icmp ne i32 %t61, 0
  br i1 %t62, label %then14, label %ifend16
then14:
  %t63 = load i32, ptr @g_pi
  %t64 = add i32 %t63, 1
  store i32 %t64, ptr @g_pi
  %t65 = load ptr, ptr %t37
  %t66 = getelementptr inbounds %Cmp_Node, ptr %t65, i32 0, i32 4
  %t67 = call ptr @fn_expr()
  store ptr %t67, ptr %t66
  br label %ifend16
ifend16:
  %t68 = load ptr, ptr %t37
  store ptr %t68, ptr %retval
  br label %ret
ifend7:
  %t69 = load ptr, ptr %t6
  %t70 = getelementptr inbounds %Cmp_Tok, ptr %t69, i32 0, i32 1
  %t71 = load ptr, ptr %t70
  %t72 = call i32 @fn_str_eq(ptr %t71, ptr @.str62)
  %t73 = icmp ne i32 %t72, 0
  br i1 %t73, label %then17, label %ifend19
then17:
  %t74 = load i32, ptr @g_pi
  %t75 = add i32 %t74, 1
  store i32 %t75, ptr @g_pi
  %t76 = call ptr @fn_node(i32 15)
  store ptr %t76, ptr %t77
  %t79 = load ptr, ptr @g_toks
  %t80 = getelementptr inbounds %LSlice, ptr %t79, i32 0, i32 0
  %t81 = load ptr, ptr %t80
  %t82 = load i32, ptr @g_pi
  %t83 = getelementptr inbounds ptr, ptr %t81, i32 %t82
  %t84 = load ptr, ptr %t83
  %t85 = getelementptr inbounds %Cmp_Tok, ptr %t84, i32 0, i32 0
  %t86 = load i32, ptr %t85
  %t87 = icmp ne i32 %t86, 4
  %t88 = zext i1 %t87 to i32
  %t89 = icmp ne i32 %t88, 0
  %t90 = zext i1 %t89 to i32
  store i32 %t90, ptr %t78
  br i1 %t89, label %sc20, label %scend21
sc20:
  %t91 = call i32 @fn_is_op(ptr @.str63)
  %t92 = icmp eq i32 %t91, 0
  %t93 = zext i1 %t92 to i32
  %t94 = icmp ne i32 %t93, 0
  %t95 = zext i1 %t94 to i32
  store i32 %t95, ptr %t78
  br label %scend21
scend21:
  %t96 = load i32, ptr %t78
  %t97 = icmp ne i32 %t96, 0
  br i1 %t97, label %then22, label %ifend24
then22:
  %t98 = load ptr, ptr %t77
  %t99 = getelementptr inbounds %Cmp_Node, ptr %t98, i32 0, i32 4
  %t100 = call ptr @fn_expr()
  store ptr %t100, ptr %t99
  br label %ifend24
ifend24:
  %t101 = load ptr, ptr %t77
  store ptr %t101, ptr %retval
  br label %ret
ifend19:
  %t102 = load ptr, ptr %t6
  %t103 = getelementptr inbounds %Cmp_Tok, ptr %t102, i32 0, i32 1
  %t104 = load ptr, ptr %t103
  %t105 = call i32 @fn_str_eq(ptr %t104, ptr @.str64)
  %t106 = icmp ne i32 %t105, 0
  br i1 %t106, label %then25, label %ifend27
then25:
  %t107 = load i32, ptr @g_pi
  %t108 = add i32 %t107, 1
  store i32 %t108, ptr @g_pi
  %t109 = call ptr @fn_node(i32 12)
  store ptr %t109, ptr %t110
  %t111 = load ptr, ptr %t110
  %t112 = getelementptr inbounds %Cmp_Node, ptr %t111, i32 0, i32 4
  %t113 = call ptr @fn_expr()
  store ptr %t113, ptr %t112
  %t114 = load ptr, ptr %t110
  %t115 = getelementptr inbounds %Cmp_Node, ptr %t114, i32 0, i32 5
  %t116 = call ptr @fn_block()
  store ptr %t116, ptr %t115
  %t117 = load i32, ptr @g_pi
  store i32 %t117, ptr %t118
  call void @fn_skipnl()
  %t119 = call i32 @fn_is_id(ptr @.str65)
  %t120 = icmp ne i32 %t119, 0
  br i1 %t120, label %then28, label %else29
then28:
  %t121 = load i32, ptr @g_pi
  %t122 = add i32 %t121, 1
  store i32 %t122, ptr @g_pi
  call void @fn_skipnl()
  %t123 = call i32 @fn_is_id(ptr @.str66)
  %t124 = icmp ne i32 %t123, 0
  br i1 %t124, label %then31, label %else32
then31:
  %t125 = load ptr, ptr %t110
  %t126 = getelementptr inbounds %Cmp_Node, ptr %t125, i32 0, i32 6
  %t127 = call ptr @fn_stmt()
  store ptr %t127, ptr %t126
  br label %ifend33
else32:
  %t128 = load ptr, ptr %t110
  %t129 = getelementptr inbounds %Cmp_Node, ptr %t128, i32 0, i32 6
  %t130 = call ptr @fn_block()
  store ptr %t130, ptr %t129
  br label %ifend33
ifend33:
  br label %ifend30
else29:
  %t131 = load i32, ptr %t118
  store i32 %t131, ptr @g_pi
  br label %ifend30
ifend30:
  %t132 = load ptr, ptr %t110
  store ptr %t132, ptr %retval
  br label %ret
ifend27:
  %t133 = load ptr, ptr %t6
  %t134 = getelementptr inbounds %Cmp_Tok, ptr %t133, i32 0, i32 1
  %t135 = load ptr, ptr %t134
  %t136 = call i32 @fn_str_eq(ptr %t135, ptr @.str67)
  %t137 = icmp ne i32 %t136, 0
  br i1 %t137, label %then34, label %ifend36
then34:
  %t138 = load i32, ptr @g_pi
  %t139 = add i32 %t138, 1
  store i32 %t139, ptr @g_pi
  %t140 = call ptr @fn_node(i32 13)
  store ptr %t140, ptr %t141
  %t142 = load ptr, ptr %t141
  %t143 = getelementptr inbounds %Cmp_Node, ptr %t142, i32 0, i32 4
  %t144 = call ptr @fn_expr()
  store ptr %t144, ptr %t143
  %t145 = load ptr, ptr %t141
  %t146 = getelementptr inbounds %Cmp_Node, ptr %t145, i32 0, i32 5
  %t147 = call ptr @fn_block()
  store ptr %t147, ptr %t146
  %t148 = load ptr, ptr %t141
  store ptr %t148, ptr %retval
  br label %ret
ifend36:
  %t149 = load ptr, ptr %t6
  %t150 = getelementptr inbounds %Cmp_Tok, ptr %t149, i32 0, i32 1
  %t151 = load ptr, ptr %t150
  %t152 = call i32 @fn_str_eq(ptr %t151, ptr @.str68)
  %t153 = icmp ne i32 %t152, 0
  br i1 %t153, label %then37, label %ifend39
then37:
  %t154 = load i32, ptr @g_pi
  %t155 = add i32 %t154, 1
  store i32 %t155, ptr @g_pi
  %t156 = call i32 @fn_is_op(ptr @.str69)
  %t157 = icmp ne i32 %t156, 0
  br i1 %t157, label %then40, label %ifend42
then40:
  %t158 = call ptr @fn_parse_query_for()
  store ptr %t158, ptr %retval
  br label %ret
ifend42:
  %t159 = call ptr @fn_node(i32 14)
  store ptr %t159, ptr %t160
  %t161 = load ptr, ptr %t160
  %t162 = getelementptr inbounds %Cmp_Node, ptr %t161, i32 0, i32 1
  %t163 = call ptr @fn_eat_id()
  store ptr %t163, ptr %t162
  %t164 = call ptr @fn_eat_id()
  store ptr %t164, ptr %t165
  %t166 = load ptr, ptr %t160
  %t167 = getelementptr inbounds %Cmp_Node, ptr %t166, i32 0, i32 4
  %t168 = call ptr @fn_expr()
  store ptr %t168, ptr %t167
  call void @fn_eat_op(ptr @.str70)
  %t169 = load ptr, ptr %t160
  %t170 = getelementptr inbounds %Cmp_Node, ptr %t169, i32 0, i32 5
  %t171 = call ptr @fn_expr()
  store ptr %t171, ptr %t170
  %t172 = load ptr, ptr %t160
  %t173 = getelementptr inbounds %Cmp_Node, ptr %t172, i32 0, i32 6
  %t174 = call ptr @fn_block()
  store ptr %t174, ptr %t173
  %t175 = load ptr, ptr %t160
  store ptr %t175, ptr %retval
  br label %ret
ifend39:
  %t176 = load ptr, ptr %t6
  %t177 = getelementptr inbounds %Cmp_Tok, ptr %t176, i32 0, i32 1
  %t178 = load ptr, ptr %t177
  %t179 = call i32 @fn_str_eq(ptr %t178, ptr @.str71)
  %t180 = icmp ne i32 %t179, 0
  br i1 %t180, label %then43, label %ifend45
then43:
  %t181 = call ptr @fn_parse_spawn()
  store ptr %t181, ptr %retval
  br label %ret
ifend45:
  %t182 = load ptr, ptr %t6
  %t183 = getelementptr inbounds %Cmp_Tok, ptr %t182, i32 0, i32 1
  %t184 = load ptr, ptr %t183
  %t185 = call i32 @fn_str_eq(ptr %t184, ptr @.str72)
  %t186 = icmp ne i32 %t185, 0
  br i1 %t186, label %then46, label %ifend48
then46:
  %t187 = load i32, ptr @g_pi
  %t188 = add i32 %t187, 1
  store i32 %t188, ptr @g_pi
  %t189 = call ptr @fn_node(i32 24)
  store ptr %t189, ptr %t190
  %t191 = load ptr, ptr %t190
  %t192 = getelementptr inbounds %Cmp_Node, ptr %t191, i32 0, i32 4
  %t193 = call ptr @fn_expr()
  store ptr %t193, ptr %t192
  call void @fn_skipnl()
  call void @fn_eat_op(ptr @.str73)
  store i32 0, ptr %t194
  br label %wcond49
wcond49:
  %t195 = icmp ne i32 1, 0
  br i1 %t195, label %wbody50, label %wend51
wbody50:
  call void @fn_skipnl()
  %t196 = call i32 @fn_is_op(ptr @.str74)
  %t197 = icmp ne i32 %t196, 0
  br i1 %t197, label %then52, label %ifend54
then52:
  br label %wend51
ifend54:
  %t198 = call ptr @fn_eat_id()
  store ptr %t198, ptr %t199
  %t200 = call ptr @fn_node(i32 25)
  store ptr %t200, ptr %t201
  %t202 = load ptr, ptr %t201
  %t203 = getelementptr inbounds %Cmp_Node, ptr %t202, i32 0, i32 1
  %t204 = call ptr @fn_eat_id()
  store ptr %t204, ptr %t203
  %t205 = call i32 @fn_is_op(ptr @.str75)
  %t206 = icmp ne i32 %t205, 0
  br i1 %t206, label %then55, label %else56
then55:
  %t207 = load i32, ptr @g_pi
  %t208 = add i32 %t207, 1
  store i32 %t208, ptr @g_pi
  %t209 = load ptr, ptr %t201
  %t210 = getelementptr inbounds %Cmp_Node, ptr %t209, i32 0, i32 5
  %t211 = call ptr @fn_expr()
  store ptr %t211, ptr %t210
  br label %ifend57
else56:
  %t212 = call ptr @fn_node(i32 30)
  store ptr %t212, ptr %t213
  %t214 = load ptr, ptr %t213
  %t215 = getelementptr inbounds %Cmp_Node, ptr %t214, i32 0, i32 2
  %t216 = load i32, ptr %t194
  store i32 %t216, ptr %t215
  %t217 = load ptr, ptr %t201
  %t218 = getelementptr inbounds %Cmp_Node, ptr %t217, i32 0, i32 5
  %t219 = load ptr, ptr %t213
  store ptr %t219, ptr %t218
  br label %ifend57
ifend57:
  call void @fn_skipnl()
  %t220 = load ptr, ptr %t201
  %t221 = getelementptr inbounds %Cmp_Node, ptr %t220, i32 0, i32 4
  %t222 = call ptr @fn_block()
  store ptr %t222, ptr %t221
  %t223 = load ptr, ptr %t190
  %t224 = getelementptr inbounds %Cmp_Node, ptr %t223, i32 0, i32 7
  %t225 = load ptr, ptr %t224
  %t226 = getelementptr inbounds %LSlice, ptr %t225, i32 0, i32 1
  %t227 = getelementptr inbounds %LSlice, ptr %t225, i32 0, i32 2
  %t228 = getelementptr inbounds %LSlice, ptr %t225, i32 0, i32 0
  %t229 = load i32, ptr %t226
  %t230 = load i32, ptr %t227
  %t231 = icmp sge i32 %t229, %t230
  br i1 %t231, label %grow58, label %put59
grow58:
  %t232 = mul i32 %t230, 2
  %t233 = icmp eq i32 %t230, 0
  %t234 = select i1 %t233, i32 8, i32 %t232
  %t235 = getelementptr ptr, ptr null, i32 1
  %t236 = ptrtoint ptr %t235 to i64
  %t237 = zext i32 %t234 to i64
  %t238 = mul i64 %t237, %t236
  %t239 = load ptr, ptr %t228
  %t240 = call ptr @realloc(ptr %t239, i64 %t238)
  store ptr %t240, ptr %t228
  store i32 %t234, ptr %t227
  br label %put59
put59:
  %t241 = load ptr, ptr %t201
  %t242 = load ptr, ptr %t228
  %t243 = getelementptr inbounds ptr, ptr %t242, i32 %t229
  store ptr %t241, ptr %t243
  %t244 = add i32 %t229, 1
  store i32 %t244, ptr %t226
  %t245 = load i32, ptr %t194
  %t246 = add i32 %t245, 1
  store i32 %t246, ptr %t194
  br label %wcond49
wend51:
  call void @fn_eat_op(ptr @.str76)
  %t247 = load ptr, ptr %t190
  store ptr %t247, ptr %retval
  br label %ret
ifend48:
  %t248 = load ptr, ptr %t6
  %t249 = getelementptr inbounds %Cmp_Tok, ptr %t248, i32 0, i32 1
  %t250 = load ptr, ptr %t249
  %t251 = call i32 @fn_str_eq(ptr %t250, ptr @.str77)
  %t252 = icmp ne i32 %t251, 0
  br i1 %t252, label %then60, label %ifend62
then60:
  %t253 = load i32, ptr @g_pi
  %t254 = add i32 %t253, 1
  store i32 %t254, ptr @g_pi
  %t255 = call ptr @fn_node(i32 26)
  store ptr %t255, ptr %t256
  %t257 = load ptr, ptr %t256
  %t258 = getelementptr inbounds %Cmp_Node, ptr %t257, i32 0, i32 1
  %t259 = call ptr @fn_eat_id()
  store ptr %t259, ptr %t258
  %t260 = load ptr, ptr %t256
  store ptr %t260, ptr %retval
  br label %ret
ifend62:
  %t261 = load ptr, ptr %t6
  %t262 = getelementptr inbounds %Cmp_Tok, ptr %t261, i32 0, i32 1
  %t263 = load ptr, ptr %t262
  %t264 = call i32 @fn_str_eq(ptr %t263, ptr @.str78)
  %t265 = icmp ne i32 %t264, 0
  br i1 %t265, label %then63, label %ifend65
then63:
  %t266 = load i32, ptr @g_pi
  %t267 = add i32 %t266, 1
  store i32 %t267, ptr @g_pi
  %t268 = call ptr @fn_node(i32 23)
  store ptr %t268, ptr %t269
  %t270 = load ptr, ptr %t269
  %t271 = getelementptr inbounds %Cmp_Node, ptr %t270, i32 0, i32 4
  %t272 = call ptr @fn_expr()
  store ptr %t272, ptr %t271
  %t273 = load ptr, ptr %t269
  store ptr %t273, ptr %retval
  br label %ret
ifend65:
  %t275 = load ptr, ptr %t6
  %t276 = getelementptr inbounds %Cmp_Tok, ptr %t275, i32 0, i32 1
  %t277 = load ptr, ptr %t276
  %t278 = call i32 @fn_str_eq(ptr %t277, ptr @.str79)
  %t279 = icmp ne i32 %t278, 0
  %t280 = zext i1 %t279 to i32
  store i32 %t280, ptr %t274
  br i1 %t279, label %scend67, label %sc66
sc66:
  %t281 = load ptr, ptr %t6
  %t282 = getelementptr inbounds %Cmp_Tok, ptr %t281, i32 0, i32 1
  %t283 = load ptr, ptr %t282
  %t284 = call i32 @fn_str_eq(ptr %t283, ptr @.str80)
  %t285 = icmp ne i32 %t284, 0
  %t286 = zext i1 %t285 to i32
  store i32 %t286, ptr %t274
  br label %scend67
scend67:
  %t287 = load i32, ptr %t274
  %t288 = icmp ne i32 %t287, 0
  br i1 %t288, label %then68, label %ifend70
then68:
  store i32 0, ptr %t289
  %t290 = load ptr, ptr %t6
  %t291 = getelementptr inbounds %Cmp_Tok, ptr %t290, i32 0, i32 1
  %t292 = load ptr, ptr %t291
  %t293 = call i32 @fn_str_eq(ptr %t292, ptr @.str81)
  %t294 = icmp ne i32 %t293, 0
  br i1 %t294, label %then71, label %ifend73
then71:
  store i32 1, ptr %t289
  br label %ifend73
ifend73:
  %t295 = load i32, ptr @g_pi
  %t296 = add i32 %t295, 1
  store i32 %t296, ptr @g_pi
  %t297 = call ptr @fn_node(i32 28)
  store ptr %t297, ptr %t298
  %t299 = load ptr, ptr %t298
  %t300 = getelementptr inbounds %Cmp_Node, ptr %t299, i32 0, i32 2
  %t301 = load i32, ptr %t289
  store i32 %t301, ptr %t300
  %t302 = load ptr, ptr %t298
  %t303 = getelementptr inbounds %Cmp_Node, ptr %t302, i32 0, i32 1
  %t304 = call ptr @fn_eat_id()
  store ptr %t304, ptr %t303
  %t305 = call i32 @fn_is_id(ptr @.str82)
  %t306 = icmp ne i32 %t305, 0
  br i1 %t306, label %then74, label %ifend76
then74:
  %t307 = load i32, ptr @g_pi
  %t308 = add i32 %t307, 1
  store i32 %t308, ptr @g_pi
  %t309 = load ptr, ptr %t298
  %t310 = getelementptr inbounds %Cmp_Node, ptr %t309, i32 0, i32 4
  %t311 = call ptr @fn_expr()
  store ptr %t311, ptr %t310
  br label %ifend76
ifend76:
  %t312 = load ptr, ptr %t298
  store ptr %t312, ptr %retval
  br label %ret
ifend70:
  %t313 = load ptr, ptr %t6
  %t314 = getelementptr inbounds %Cmp_Tok, ptr %t313, i32 0, i32 1
  %t315 = load ptr, ptr %t314
  %t316 = call i32 @fn_str_eq(ptr %t315, ptr @.str83)
  %t317 = icmp ne i32 %t316, 0
  br i1 %t317, label %then77, label %ifend79
then77:
  %t318 = load i32, ptr @g_pi
  %t319 = add i32 %t318, 1
  store i32 %t319, ptr @g_pi
  %t320 = call ptr @fn_node(i32 17)
  store ptr %t320, ptr %retval
  br label %ret
ifend79:
  %t321 = load ptr, ptr %t6
  %t322 = getelementptr inbounds %Cmp_Tok, ptr %t321, i32 0, i32 1
  %t323 = load ptr, ptr %t322
  %t324 = call i32 @fn_str_eq(ptr %t323, ptr @.str84)
  %t325 = icmp ne i32 %t324, 0
  br i1 %t325, label %then80, label %ifend82
then80:
  %t326 = load i32, ptr @g_pi
  %t327 = add i32 %t326, 1
  store i32 %t327, ptr @g_pi
  %t328 = call ptr @fn_node(i32 18)
  store ptr %t328, ptr %retval
  br label %ret
ifend82:
  %t329 = load ptr, ptr %t6
  %t330 = getelementptr inbounds %Cmp_Tok, ptr %t329, i32 0, i32 1
  %t331 = load ptr, ptr %t330
  %t332 = call i32 @fn_str_eq(ptr %t331, ptr @.str85)
  %t333 = icmp ne i32 %t332, 0
  br i1 %t333, label %then83, label %ifend85
then83:
  %t334 = load i32, ptr @g_pi
  %t335 = add i32 %t334, 1
  store i32 %t335, ptr @g_pi
  %t336 = call ptr @fn_node(i32 19)
  store ptr %t336, ptr %t337
  %t338 = load ptr, ptr %t337
  %t339 = getelementptr inbounds %Cmp_Node, ptr %t338, i32 0, i32 4
  %t340 = call ptr @fn_expr()
  store ptr %t340, ptr %t339
  call void @fn_skipnl()
  call void @fn_eat_op(ptr @.str86)
  br label %wcond86
wcond86:
  %t341 = icmp ne i32 1, 0
  br i1 %t341, label %wbody87, label %wend88
wbody87:
  call void @fn_skipnl()
  %t342 = call i32 @fn_is_op(ptr @.str87)
  %t343 = icmp ne i32 %t342, 0
  br i1 %t343, label %then89, label %ifend91
then89:
  br label %wend88
ifend91:
  %t344 = call ptr @fn_node(i32 20)
  store ptr %t344, ptr %t345
  br label %wcond92
wcond92:
  %t346 = icmp ne i32 1, 0
  br i1 %t346, label %wbody93, label %wend94
wbody93:
  %t347 = load ptr, ptr %t345
  %t348 = getelementptr inbounds %Cmp_Node, ptr %t347, i32 0, i32 7
  %t349 = load ptr, ptr %t348
  %t350 = getelementptr inbounds %LSlice, ptr %t349, i32 0, i32 1
  %t351 = getelementptr inbounds %LSlice, ptr %t349, i32 0, i32 2
  %t352 = getelementptr inbounds %LSlice, ptr %t349, i32 0, i32 0
  %t353 = load i32, ptr %t350
  %t354 = load i32, ptr %t351
  %t355 = icmp sge i32 %t353, %t354
  br i1 %t355, label %grow95, label %put96
grow95:
  %t356 = mul i32 %t354, 2
  %t357 = icmp eq i32 %t354, 0
  %t358 = select i1 %t357, i32 8, i32 %t356
  %t359 = getelementptr ptr, ptr null, i32 1
  %t360 = ptrtoint ptr %t359 to i64
  %t361 = zext i32 %t358 to i64
  %t362 = mul i64 %t361, %t360
  %t363 = load ptr, ptr %t352
  %t364 = call ptr @realloc(ptr %t363, i64 %t362)
  store ptr %t364, ptr %t352
  store i32 %t358, ptr %t351
  br label %put96
put96:
  %t365 = call ptr @fn_expr()
  %t366 = load ptr, ptr %t352
  %t367 = getelementptr inbounds ptr, ptr %t366, i32 %t353
  store ptr %t365, ptr %t367
  %t368 = add i32 %t353, 1
  store i32 %t368, ptr %t350
  %t369 = call i32 @fn_is_op(ptr @.str88)
  %t370 = icmp ne i32 %t369, 0
  br i1 %t370, label %then97, label %ifend99
then97:
  %t371 = load i32, ptr @g_pi
  %t372 = add i32 %t371, 1
  store i32 %t372, ptr @g_pi
  call void @fn_skipnl()
  br label %wcond92
ifend99:
  br label %wend94
wend94:
  call void @fn_eat_op(ptr @.str89)
  call void @fn_skipnl()
  %t373 = call i32 @fn_is_op(ptr @.str90)
  %t374 = icmp ne i32 %t373, 0
  br i1 %t374, label %then100, label %else101
then100:
  %t375 = load ptr, ptr %t345
  %t376 = getelementptr inbounds %Cmp_Node, ptr %t375, i32 0, i32 4
  %t377 = call ptr @fn_block()
  store ptr %t377, ptr %t376
  br label %ifend102
else101:
  %t378 = call ptr @fn_node(i32 7)
  store ptr %t378, ptr %t379
  %t380 = load ptr, ptr %t379
  %t381 = getelementptr inbounds %Cmp_Node, ptr %t380, i32 0, i32 7
  %t382 = load ptr, ptr %t381
  %t383 = getelementptr inbounds %LSlice, ptr %t382, i32 0, i32 1
  %t384 = getelementptr inbounds %LSlice, ptr %t382, i32 0, i32 2
  %t385 = getelementptr inbounds %LSlice, ptr %t382, i32 0, i32 0
  %t386 = load i32, ptr %t383
  %t387 = load i32, ptr %t384
  %t388 = icmp sge i32 %t386, %t387
  br i1 %t388, label %grow103, label %put104
grow103:
  %t389 = mul i32 %t387, 2
  %t390 = icmp eq i32 %t387, 0
  %t391 = select i1 %t390, i32 8, i32 %t389
  %t392 = getelementptr ptr, ptr null, i32 1
  %t393 = ptrtoint ptr %t392 to i64
  %t394 = zext i32 %t391 to i64
  %t395 = mul i64 %t394, %t393
  %t396 = load ptr, ptr %t385
  %t397 = call ptr @realloc(ptr %t396, i64 %t395)
  store ptr %t397, ptr %t385
  store i32 %t391, ptr %t384
  br label %put104
put104:
  %t398 = call ptr @fn_stmt()
  %t399 = load ptr, ptr %t385
  %t400 = getelementptr inbounds ptr, ptr %t399, i32 %t386
  store ptr %t398, ptr %t400
  %t401 = add i32 %t386, 1
  store i32 %t401, ptr %t383
  %t402 = load ptr, ptr %t345
  %t403 = getelementptr inbounds %Cmp_Node, ptr %t402, i32 0, i32 4
  %t404 = load ptr, ptr %t379
  store ptr %t404, ptr %t403
  br label %ifend102
ifend102:
  %t405 = load ptr, ptr %t337
  %t406 = getelementptr inbounds %Cmp_Node, ptr %t405, i32 0, i32 7
  %t407 = load ptr, ptr %t406
  %t408 = getelementptr inbounds %LSlice, ptr %t407, i32 0, i32 1
  %t409 = getelementptr inbounds %LSlice, ptr %t407, i32 0, i32 2
  %t410 = getelementptr inbounds %LSlice, ptr %t407, i32 0, i32 0
  %t411 = load i32, ptr %t408
  %t412 = load i32, ptr %t409
  %t413 = icmp sge i32 %t411, %t412
  br i1 %t413, label %grow105, label %put106
grow105:
  %t414 = mul i32 %t412, 2
  %t415 = icmp eq i32 %t412, 0
  %t416 = select i1 %t415, i32 8, i32 %t414
  %t417 = getelementptr ptr, ptr null, i32 1
  %t418 = ptrtoint ptr %t417 to i64
  %t419 = zext i32 %t416 to i64
  %t420 = mul i64 %t419, %t418
  %t421 = load ptr, ptr %t410
  %t422 = call ptr @realloc(ptr %t421, i64 %t420)
  store ptr %t422, ptr %t410
  store i32 %t416, ptr %t409
  br label %put106
put106:
  %t423 = load ptr, ptr %t345
  %t424 = load ptr, ptr %t410
  %t425 = getelementptr inbounds ptr, ptr %t424, i32 %t411
  store ptr %t423, ptr %t425
  %t426 = add i32 %t411, 1
  store i32 %t426, ptr %t408
  br label %wcond86
wend88:
  call void @fn_eat_op(ptr @.str91)
  %t427 = load ptr, ptr %t337
  store ptr %t427, ptr %retval
  br label %ret
ifend85:
  br label %ifend2
ifend2:
  %t428 = call ptr @fn_expr()
  store ptr %t428, ptr %t429
  %t434 = call i32 @fn_is_op(ptr @.str92)
  %t435 = icmp ne i32 %t434, 0
  %t436 = zext i1 %t435 to i32
  store i32 %t436, ptr %t433
  br i1 %t435, label %scend108, label %sc107
sc107:
  %t437 = call i32 @fn_is_op(ptr @.str93)
  %t438 = icmp ne i32 %t437, 0
  %t439 = zext i1 %t438 to i32
  store i32 %t439, ptr %t433
  br label %scend108
scend108:
  %t440 = load i32, ptr %t433
  %t441 = icmp ne i32 %t440, 0
  %t442 = zext i1 %t441 to i32
  store i32 %t442, ptr %t432
  br i1 %t441, label %scend110, label %sc109
sc109:
  %t443 = call i32 @fn_is_op(ptr @.str94)
  %t444 = icmp ne i32 %t443, 0
  %t445 = zext i1 %t444 to i32
  store i32 %t445, ptr %t432
  br label %scend110
scend110:
  %t446 = load i32, ptr %t432
  %t447 = icmp ne i32 %t446, 0
  %t448 = zext i1 %t447 to i32
  store i32 %t448, ptr %t431
  br i1 %t447, label %scend112, label %sc111
sc111:
  %t449 = call i32 @fn_is_op(ptr @.str95)
  %t450 = icmp ne i32 %t449, 0
  %t451 = zext i1 %t450 to i32
  store i32 %t451, ptr %t431
  br label %scend112
scend112:
  %t452 = load i32, ptr %t431
  %t453 = icmp ne i32 %t452, 0
  %t454 = zext i1 %t453 to i32
  store i32 %t454, ptr %t430
  br i1 %t453, label %scend114, label %sc113
sc113:
  %t455 = call i32 @fn_is_op(ptr @.str96)
  %t456 = icmp ne i32 %t455, 0
  %t457 = zext i1 %t456 to i32
  store i32 %t457, ptr %t430
  br label %scend114
scend114:
  %t458 = load i32, ptr %t430
  %t459 = icmp ne i32 %t458, 0
  br i1 %t459, label %then115, label %ifend117
then115:
  %t460 = call ptr @fn_node(i32 11)
  store ptr %t460, ptr %t461
  %t462 = load ptr, ptr %t461
  %t463 = getelementptr inbounds %Cmp_Node, ptr %t462, i32 0, i32 8
  %t464 = load ptr, ptr @g_toks
  %t465 = getelementptr inbounds %LSlice, ptr %t464, i32 0, i32 0
  %t466 = load ptr, ptr %t465
  %t467 = load i32, ptr @g_pi
  %t468 = getelementptr inbounds ptr, ptr %t466, i32 %t467
  %t469 = load ptr, ptr %t468
  %t470 = getelementptr inbounds %Cmp_Tok, ptr %t469, i32 0, i32 3
  %t471 = load i32, ptr %t470
  store i32 %t471, ptr %t463
  %t472 = load ptr, ptr %t461
  %t473 = getelementptr inbounds %Cmp_Node, ptr %t472, i32 0, i32 1
  %t474 = load ptr, ptr @g_toks
  %t475 = getelementptr inbounds %LSlice, ptr %t474, i32 0, i32 0
  %t476 = load ptr, ptr %t475
  %t477 = load i32, ptr @g_pi
  %t478 = getelementptr inbounds ptr, ptr %t476, i32 %t477
  %t479 = load ptr, ptr %t478
  %t480 = getelementptr inbounds %Cmp_Tok, ptr %t479, i32 0, i32 1
  %t481 = load ptr, ptr %t480
  store ptr %t481, ptr %t473
  %t482 = load i32, ptr @g_pi
  %t483 = add i32 %t482, 1
  store i32 %t483, ptr @g_pi
  %t484 = load ptr, ptr %t461
  %t485 = getelementptr inbounds %Cmp_Node, ptr %t484, i32 0, i32 4
  %t486 = load ptr, ptr %t429
  store ptr %t486, ptr %t485
  %t487 = load ptr, ptr %t461
  %t488 = getelementptr inbounds %Cmp_Node, ptr %t487, i32 0, i32 5
  %t489 = call ptr @fn_expr()
  store ptr %t489, ptr %t488
  %t490 = load ptr, ptr %t461
  store ptr %t490, ptr %retval
  br label %ret
ifend117:
  %t491 = call ptr @fn_node(i32 16)
  store ptr %t491, ptr %t492
  %t493 = load ptr, ptr %t492
  %t494 = getelementptr inbounds %Cmp_Node, ptr %t493, i32 0, i32 4
  %t495 = load ptr, ptr %t429
  store ptr %t495, ptr %t494
  %t496 = load ptr, ptr %t492
  store ptr %t496, ptr %retval
  br label %ret
ret:
  %t497 = load ptr, ptr %retval
  ret ptr %t497
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
  %t5 = getelementptr inbounds %Cmp_Node, ptr %t4, i32 0, i32 1
  %t6 = call ptr @fn_eat_id()
  store ptr %t6, ptr %t5
  call void @fn_eat_op(ptr @.str97)
  %t7 = load ptr, ptr %t3
  %t8 = getelementptr inbounds %Cmp_Node, ptr %t7, i32 0, i32 3
  %t9 = call ptr @fn_ptype()
  store ptr %t9, ptr %t8
  %t10 = call i32 @fn_is_op(ptr @.str98)
  %t11 = icmp ne i32 %t10, 0
  br i1 %t11, label %then0, label %ifend2
then0:
  %t12 = load i32, ptr @g_pi
  %t13 = add i32 %t12, 1
  store i32 %t13, ptr @g_pi
  %t14 = load ptr, ptr %t3
  %t15 = getelementptr inbounds %Cmp_Node, ptr %t14, i32 0, i32 4
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
  %t5 = getelementptr inbounds %Cmp_Node, ptr %t4, i32 0, i32 1
  %t6 = call ptr @fn_eat_id()
  store ptr %t6, ptr %t5
  call void @fn_eat_op(ptr @.str99)
  %t7 = load ptr, ptr %t3
  %t8 = getelementptr inbounds %Cmp_Node, ptr %t7, i32 0, i32 3
  %t9 = call ptr @fn_ptype()
  store ptr %t9, ptr %t8
  call void @fn_eat_op(ptr @.str100)
  %t10 = load ptr, ptr %t3
  %t11 = getelementptr inbounds %Cmp_Node, ptr %t10, i32 0, i32 4
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
  %t5 = getelementptr inbounds %Cmp_Node, ptr %t4, i32 0, i32 1
  %t6 = call ptr @fn_eat_id()
  store ptr %t6, ptr %t5
  call void @fn_eat_op(ptr @.str101)
  br label %wcond0
wcond0:
  %t7 = call i32 @fn_is_op(ptr @.str102)
  %t8 = icmp eq i32 %t7, 0
  %t9 = zext i1 %t8 to i32
  %t10 = icmp ne i32 %t9, 0
  br i1 %t10, label %wbody1, label %wend2
wbody1:
  %t11 = call ptr @fn_node(i32 5)
  store ptr %t11, ptr %t12
  %t13 = load ptr, ptr %t12
  %t14 = getelementptr inbounds %Cmp_Node, ptr %t13, i32 0, i32 1
  %t15 = call ptr @fn_eat_id()
  store ptr %t15, ptr %t14
  call void @fn_eat_op(ptr @.str103)
  %t16 = load ptr, ptr %t12
  %t17 = getelementptr inbounds %Cmp_Node, ptr %t16, i32 0, i32 3
  %t18 = call ptr @fn_ptype()
  store ptr %t18, ptr %t17
  %t19 = load ptr, ptr %t3
  %t20 = getelementptr inbounds %Cmp_Node, ptr %t19, i32 0, i32 7
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
  %t41 = call i32 @fn_is_op(ptr @.str104)
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
  call void @fn_eat_op(ptr @.str105)
  %t45 = load ptr, ptr %t3
  %t46 = getelementptr inbounds %Cmp_Node, ptr %t45, i32 0, i32 3
  store ptr @.str106, ptr %t46
  %t47 = call i32 @fn_is_op(ptr @.str107)
  %t48 = icmp ne i32 %t47, 0
  br i1 %t48, label %then8, label %ifend10
then8:
  %t49 = load i32, ptr @g_pi
  %t50 = add i32 %t49, 1
  store i32 %t50, ptr @g_pi
  %t51 = load ptr, ptr %t3
  %t52 = getelementptr inbounds %Cmp_Node, ptr %t51, i32 0, i32 3
  %t53 = call ptr @fn_ptype()
  store ptr %t53, ptr %t52
  br label %ifend10
ifend10:
  %t54 = load ptr, ptr %t3
  %t55 = getelementptr inbounds %Cmp_Node, ptr %t54, i32 0, i32 4
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
  %t5 = getelementptr inbounds %Cmp_Node, ptr %t4, i32 0, i32 4
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
  store ptr @.str108, ptr %retval
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
  %t12 = call ptr @fn_str_concat(ptr %t10, ptr %t11)
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
  %t16 = call i32 @fn_str_eq(ptr %t14, ptr %t15)
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
  %t1 = alloca ptr
  %t2 = alloca ptr
  %t3 = alloca ptr
  %t4 = alloca ptr
  %t5 = alloca ptr
  %t6 = alloca ptr
  %t7 = alloca ptr
  %t13 = alloca ptr
  %t49 = alloca i32
  %t75 = alloca ptr
  %t85 = alloca ptr
  %t158 = alloca ptr
  %t216 = alloca ptr
  %t331 = alloca ptr
  store i32 0, ptr %t0
  store ptr null, ptr %t1
  store ptr null, ptr %t2
  store ptr null, ptr %t3
  store ptr null, ptr %t4
  store ptr null, ptr %t5
  store ptr null, ptr %t6
  store ptr null, ptr %t7
  br label %wcond0
wcond0:
  %t8 = call i32 @fn_is_op(ptr @.str109)
  %t9 = icmp ne i32 %t8, 0
  br i1 %t9, label %wbody1, label %wend2
wbody1:
  %t10 = load i32, ptr @g_pi
  %t11 = add i32 %t10, 1
  store i32 %t11, ptr @g_pi
  %t12 = call ptr @fn_eat_id()
  store ptr %t12, ptr %t13
  %t14 = load ptr, ptr %t13
  %t15 = call i32 @fn_str_eq(ptr %t14, ptr @.str110)
  %t16 = icmp ne i32 %t15, 0
  br i1 %t16, label %then3, label %else4
then3:
  store i32 1, ptr %t0
  br label %ifend5
else4:
  %t17 = load ptr, ptr %t13
  %t18 = call i32 @fn_str_eq(ptr %t17, ptr @.str111)
  %t19 = icmp ne i32 %t18, 0
  br i1 %t19, label %then6, label %else7
then6:
  %t20 = call ptr @fn_parse_queries_anno()
  store ptr %t20, ptr %t1
  br label %ifend8
else7:
  %t21 = load ptr, ptr %t13
  %t22 = call i32 @fn_str_eq(ptr %t21, ptr @.str112)
  %t23 = icmp ne i32 %t22, 0
  br i1 %t23, label %then9, label %else10
then9:
  call void @fn_eat_op(ptr @.str113)
  %t24 = call ptr @fn_eat_id()
  store ptr %t24, ptr %t2
  call void @fn_eat_op(ptr @.str114)
  br label %ifend11
else10:
  %t25 = load ptr, ptr %t13
  %t26 = call i32 @fn_str_eq(ptr %t25, ptr @.str115)
  %t27 = icmp ne i32 %t26, 0
  br i1 %t27, label %then12, label %else13
then12:
  call void @fn_eat_op(ptr @.str116)
  %t28 = call ptr @fn_eat_id()
  store ptr %t28, ptr %t3
  call void @fn_eat_op(ptr @.str117)
  br label %ifend14
else13:
  %t29 = load ptr, ptr %t13
  %t30 = call i32 @fn_str_eq(ptr %t29, ptr @.str118)
  %t31 = icmp ne i32 %t30, 0
  br i1 %t31, label %then15, label %else16
then15:
  call void @fn_eat_op(ptr @.str119)
  %t32 = call ptr @fn_eat_id()
  store ptr %t32, ptr %t4
  call void @fn_eat_op(ptr @.str120)
  br label %ifend17
else16:
  %t33 = load ptr, ptr %t13
  %t34 = call i32 @fn_str_eq(ptr %t33, ptr @.str121)
  %t35 = icmp ne i32 %t34, 0
  br i1 %t35, label %then18, label %else19
then18:
  call void @fn_eat_op(ptr @.str122)
  %t36 = call ptr @fn_eat_id()
  store ptr %t36, ptr %t5
  call void @fn_eat_op(ptr @.str123)
  br label %ifend20
else19:
  %t37 = load ptr, ptr %t13
  %t38 = call i32 @fn_str_eq(ptr %t37, ptr @.str124)
  %t39 = icmp ne i32 %t38, 0
  br i1 %t39, label %then21, label %else22
then21:
  call void @fn_eat_op(ptr @.str125)
  %t40 = call ptr @fn_eat_id()
  store ptr %t40, ptr %t6
  call void @fn_eat_op(ptr @.str126)
  br label %ifend23
else22:
  %t41 = load ptr, ptr %t13
  %t42 = call i32 @fn_str_eq(ptr %t41, ptr @.str127)
  %t43 = icmp ne i32 %t42, 0
  br i1 %t43, label %then24, label %else25
then24:
  store ptr @.str128, ptr %t7
  br label %ifend26
else25:
  %t44 = load ptr, ptr %t13
  %t45 = call i32 @fn_str_eq(ptr %t44, ptr @.str129)
  %t46 = icmp ne i32 %t45, 0
  br i1 %t46, label %then27, label %else28
then27:
  store ptr @.str130, ptr %t7
  br label %ifend29
else28:
  %t47 = call i32 @fn_is_op(ptr @.str131)
  %t48 = icmp ne i32 %t47, 0
  br i1 %t48, label %then30, label %ifend32
then30:
  store i32 0, ptr %t49
  br label %wcond33
wcond33:
  %t50 = icmp ne i32 1, 0
  br i1 %t50, label %wbody34, label %wend35
wbody34:
  %t51 = call i32 @fn_is_op(ptr @.str132)
  %t52 = icmp ne i32 %t51, 0
  br i1 %t52, label %then36, label %ifend38
then36:
  %t53 = load i32, ptr %t49
  %t54 = add i32 %t53, 1
  store i32 %t54, ptr %t49
  br label %ifend38
ifend38:
  %t55 = call i32 @fn_is_op(ptr @.str133)
  %t56 = icmp ne i32 %t55, 0
  br i1 %t56, label %then39, label %ifend41
then39:
  %t57 = load i32, ptr %t49
  %t58 = sub i32 %t57, 1
  store i32 %t58, ptr %t49
  br label %ifend41
ifend41:
  %t59 = load i32, ptr @g_pi
  %t60 = add i32 %t59, 1
  store i32 %t60, ptr @g_pi
  %t61 = load i32, ptr %t49
  %t62 = icmp eq i32 %t61, 0
  %t63 = zext i1 %t62 to i32
  %t64 = icmp ne i32 %t63, 0
  br i1 %t64, label %then42, label %ifend44
then42:
  br label %wend35
ifend44:
  br label %wcond33
wend35:
  br label %ifend32
ifend32:
  br label %ifend29
ifend29:
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
  br label %ifend5
ifend5:
  call void @fn_skipnl()
  br label %wcond0
wend2:
  %t65 = call i32 @fn_is_id(ptr @.str134)
  %t66 = icmp ne i32 %t65, 0
  br i1 %t66, label %then45, label %ifend47
then45:
  %t67 = load i32, ptr @g_pi
  %t68 = add i32 %t67, 1
  store i32 %t68, ptr @g_pi
  %t69 = load ptr, ptr @g_toks
  %t70 = getelementptr inbounds %LSlice, ptr %t69, i32 0, i32 0
  %t71 = load ptr, ptr %t70
  %t72 = load i32, ptr @g_pi
  %t73 = getelementptr inbounds ptr, ptr %t71, i32 %t72
  %t74 = load ptr, ptr %t73
  store ptr %t74, ptr %t75
  %t76 = load ptr, ptr %t75
  %t77 = getelementptr inbounds %Cmp_Tok, ptr %t76, i32 0, i32 0
  %t78 = load i32, ptr %t77
  %t79 = icmp ne i32 %t78, 2
  %t80 = zext i1 %t79 to i32
  %t81 = icmp ne i32 %t80, 0
  br i1 %t81, label %then48, label %ifend50
then48:
  call void @fn_perr(ptr @.str135)
  br label %ifend50
ifend50:
  %t82 = load ptr, ptr %t75
  %t83 = getelementptr inbounds %Cmp_Tok, ptr %t82, i32 0, i32 1
  %t84 = load ptr, ptr %t83
  store ptr %t84, ptr %t85
  %t86 = load i32, ptr @g_pi
  %t87 = add i32 %t86, 1
  store i32 %t87, ptr @g_pi
  %t88 = load ptr, ptr %t85
  call void @fn_do_import(ptr %t88)
  br label %ret
ifend47:
  %t89 = call i32 @fn_is_id(ptr @.str136)
  %t90 = icmp ne i32 %t89, 0
  br i1 %t90, label %then51, label %ifend53
then51:
  %t91 = load ptr, ptr @g_prog
  %t92 = getelementptr inbounds %LSlice, ptr %t91, i32 0, i32 1
  %t93 = getelementptr inbounds %LSlice, ptr %t91, i32 0, i32 2
  %t94 = getelementptr inbounds %LSlice, ptr %t91, i32 0, i32 0
  %t95 = load i32, ptr %t92
  %t96 = load i32, ptr %t93
  %t97 = icmp sge i32 %t95, %t96
  br i1 %t97, label %grow54, label %put55
grow54:
  %t98 = mul i32 %t96, 2
  %t99 = icmp eq i32 %t96, 0
  %t100 = select i1 %t99, i32 8, i32 %t98
  %t101 = getelementptr ptr, ptr null, i32 1
  %t102 = ptrtoint ptr %t101 to i64
  %t103 = zext i32 %t100 to i64
  %t104 = mul i64 %t103, %t102
  %t105 = load ptr, ptr %t94
  %t106 = call ptr @realloc(ptr %t105, i64 %t104)
  store ptr %t106, ptr %t94
  store i32 %t100, ptr %t93
  br label %put55
put55:
  %t107 = call ptr @fn_parse_enum()
  %t108 = load ptr, ptr %t94
  %t109 = getelementptr inbounds ptr, ptr %t108, i32 %t95
  store ptr %t107, ptr %t109
  %t110 = add i32 %t95, 1
  store i32 %t110, ptr %t92
  br label %ret
ifend53:
  %t111 = call i32 @fn_is_id(ptr @.str137)
  %t112 = icmp ne i32 %t111, 0
  br i1 %t112, label %then56, label %ifend58
then56:
  %t113 = load ptr, ptr @g_prog
  %t114 = getelementptr inbounds %LSlice, ptr %t113, i32 0, i32 1
  %t115 = getelementptr inbounds %LSlice, ptr %t113, i32 0, i32 2
  %t116 = getelementptr inbounds %LSlice, ptr %t113, i32 0, i32 0
  %t117 = load i32, ptr %t114
  %t118 = load i32, ptr %t115
  %t119 = icmp sge i32 %t117, %t118
  br i1 %t119, label %grow59, label %put60
grow59:
  %t120 = mul i32 %t118, 2
  %t121 = icmp eq i32 %t118, 0
  %t122 = select i1 %t121, i32 8, i32 %t120
  %t123 = getelementptr ptr, ptr null, i32 1
  %t124 = ptrtoint ptr %t123 to i64
  %t125 = zext i32 %t122 to i64
  %t126 = mul i64 %t125, %t124
  %t127 = load ptr, ptr %t116
  %t128 = call ptr @realloc(ptr %t127, i64 %t126)
  store ptr %t128, ptr %t116
  store i32 %t122, ptr %t115
  br label %put60
put60:
  %t129 = call ptr @fn_parse_component()
  %t130 = load ptr, ptr %t116
  %t131 = getelementptr inbounds ptr, ptr %t130, i32 %t117
  store ptr %t129, ptr %t131
  %t132 = add i32 %t117, 1
  store i32 %t132, ptr %t114
  br label %ret
ifend58:
  %t133 = call i32 @fn_is_id(ptr @.str138)
  %t134 = icmp ne i32 %t133, 0
  br i1 %t134, label %then61, label %ifend63
then61:
  %t135 = load ptr, ptr @g_prog
  %t136 = getelementptr inbounds %LSlice, ptr %t135, i32 0, i32 1
  %t137 = getelementptr inbounds %LSlice, ptr %t135, i32 0, i32 2
  %t138 = getelementptr inbounds %LSlice, ptr %t135, i32 0, i32 0
  %t139 = load i32, ptr %t136
  %t140 = load i32, ptr %t137
  %t141 = icmp sge i32 %t139, %t140
  br i1 %t141, label %grow64, label %put65
grow64:
  %t142 = mul i32 %t140, 2
  %t143 = icmp eq i32 %t140, 0
  %t144 = select i1 %t143, i32 8, i32 %t142
  %t145 = getelementptr ptr, ptr null, i32 1
  %t146 = ptrtoint ptr %t145 to i64
  %t147 = zext i32 %t144 to i64
  %t148 = mul i64 %t147, %t146
  %t149 = load ptr, ptr %t138
  %t150 = call ptr @realloc(ptr %t149, i64 %t148)
  store ptr %t150, ptr %t138
  store i32 %t144, ptr %t137
  br label %put65
put65:
  %t151 = call ptr @fn_parse_archetype()
  %t152 = load ptr, ptr %t138
  %t153 = getelementptr inbounds ptr, ptr %t152, i32 %t139
  store ptr %t151, ptr %t153
  %t154 = add i32 %t139, 1
  store i32 %t154, ptr %t136
  br label %ret
ifend63:
  %t155 = call i32 @fn_is_id(ptr @.str139)
  %t156 = icmp ne i32 %t155, 0
  br i1 %t156, label %then66, label %ifend68
then66:
  %t157 = call ptr @fn_parse_system()
  store ptr %t157, ptr %t158
  %t159 = load ptr, ptr %t2
  %t160 = icmp ne ptr %t159, null
  %t161 = zext i1 %t160 to i32
  %t162 = icmp ne i32 %t161, 0
  br i1 %t162, label %then69, label %ifend71
then69:
  %t163 = load ptr, ptr %t2
  %t164 = load ptr, ptr %t158
  %t165 = getelementptr inbounds %Cmp_Node, ptr %t164, i32 0, i32 4
  %t166 = load ptr, ptr %t165
  call void @fn_register_onspawn(ptr %t163, ptr %t166)
  br label %ret
ifend71:
  %t167 = load ptr, ptr %t3
  %t168 = icmp ne ptr %t167, null
  %t169 = zext i1 %t168 to i32
  %t170 = icmp ne i32 %t169, 0
  br i1 %t170, label %then72, label %ifend74
then72:
  %t171 = load ptr, ptr %t3
  %t172 = load ptr, ptr %t158
  %t173 = getelementptr inbounds %Cmp_Node, ptr %t172, i32 0, i32 4
  %t174 = load ptr, ptr %t173
  call void @fn_register_ondespawn(ptr %t171, ptr %t174)
  br label %ret
ifend74:
  %t175 = load ptr, ptr %t4
  %t176 = icmp ne ptr %t175, null
  %t177 = zext i1 %t176 to i32
  %t178 = icmp ne i32 %t177, 0
  br i1 %t178, label %then75, label %ifend77
then75:
  %t179 = load ptr, ptr %t4
  %t180 = load ptr, ptr %t158
  %t181 = getelementptr inbounds %Cmp_Node, ptr %t180, i32 0, i32 4
  %t182 = load ptr, ptr %t181
  call void @fn_register_onattach(ptr %t179, ptr %t182)
  br label %ret
ifend77:
  %t183 = load ptr, ptr %t5
  %t184 = icmp ne ptr %t183, null
  %t185 = zext i1 %t184 to i32
  %t186 = icmp ne i32 %t185, 0
  br i1 %t186, label %then78, label %ifend80
then78:
  %t187 = load ptr, ptr %t5
  %t188 = load ptr, ptr %t158
  %t189 = getelementptr inbounds %Cmp_Node, ptr %t188, i32 0, i32 4
  %t190 = load ptr, ptr %t189
  call void @fn_register_onenable(ptr %t187, ptr %t190)
  br label %ret
ifend80:
  %t191 = load ptr, ptr %t6
  %t192 = icmp ne ptr %t191, null
  %t193 = zext i1 %t192 to i32
  %t194 = icmp ne i32 %t193, 0
  br i1 %t194, label %then81, label %ifend83
then81:
  %t195 = load ptr, ptr %t6
  %t196 = load ptr, ptr %t158
  %t197 = getelementptr inbounds %Cmp_Node, ptr %t196, i32 0, i32 4
  %t198 = load ptr, ptr %t197
  call void @fn_register_ondisable(ptr %t195, ptr %t198)
  br label %ret
ifend83:
  %t199 = load ptr, ptr %t7
  %t200 = icmp ne ptr %t199, null
  %t201 = zext i1 %t200 to i32
  %t202 = icmp ne i32 %t201, 0
  br i1 %t202, label %then84, label %ifend86
then84:
  %t203 = load ptr, ptr %t158
  %t204 = getelementptr inbounds %Cmp_Node, ptr %t203, i32 0, i32 3
  %t205 = load ptr, ptr %t7
  store ptr %t205, ptr %t204
  br label %ifend86
ifend86:
  %t206 = load ptr, ptr %t1
  %t207 = icmp ne ptr %t206, null
  %t208 = zext i1 %t207 to i32
  %t209 = icmp ne i32 %t208, 0
  br i1 %t209, label %then87, label %ifend89
then87:
  %t210 = load ptr, ptr %t1
  %t211 = getelementptr inbounds %Cmp_Node, ptr %t210, i32 0, i32 4
  %t212 = load ptr, ptr %t158
  %t213 = getelementptr inbounds %Cmp_Node, ptr %t212, i32 0, i32 4
  %t214 = load ptr, ptr %t213
  store ptr %t214, ptr %t211
  %t215 = call ptr @fn_node(i32 7)
  store ptr %t215, ptr %t216
  %t217 = load ptr, ptr %t216
  %t218 = getelementptr inbounds %Cmp_Node, ptr %t217, i32 0, i32 7
  %t219 = load ptr, ptr %t218
  %t220 = getelementptr inbounds %LSlice, ptr %t219, i32 0, i32 1
  %t221 = getelementptr inbounds %LSlice, ptr %t219, i32 0, i32 2
  %t222 = getelementptr inbounds %LSlice, ptr %t219, i32 0, i32 0
  %t223 = load i32, ptr %t220
  %t224 = load i32, ptr %t221
  %t225 = icmp sge i32 %t223, %t224
  br i1 %t225, label %grow90, label %put91
grow90:
  %t226 = mul i32 %t224, 2
  %t227 = icmp eq i32 %t224, 0
  %t228 = select i1 %t227, i32 8, i32 %t226
  %t229 = getelementptr ptr, ptr null, i32 1
  %t230 = ptrtoint ptr %t229 to i64
  %t231 = zext i32 %t228 to i64
  %t232 = mul i64 %t231, %t230
  %t233 = load ptr, ptr %t222
  %t234 = call ptr @realloc(ptr %t233, i64 %t232)
  store ptr %t234, ptr %t222
  store i32 %t228, ptr %t221
  br label %put91
put91:
  %t235 = load ptr, ptr %t1
  %t236 = load ptr, ptr %t222
  %t237 = getelementptr inbounds ptr, ptr %t236, i32 %t223
  store ptr %t235, ptr %t237
  %t238 = add i32 %t223, 1
  store i32 %t238, ptr %t220
  %t239 = load ptr, ptr %t158
  %t240 = getelementptr inbounds %Cmp_Node, ptr %t239, i32 0, i32 4
  %t241 = load ptr, ptr %t216
  store ptr %t241, ptr %t240
  br label %ifend89
ifend89:
  %t242 = load ptr, ptr @g_prog
  %t243 = getelementptr inbounds %LSlice, ptr %t242, i32 0, i32 1
  %t244 = getelementptr inbounds %LSlice, ptr %t242, i32 0, i32 2
  %t245 = getelementptr inbounds %LSlice, ptr %t242, i32 0, i32 0
  %t246 = load i32, ptr %t243
  %t247 = load i32, ptr %t244
  %t248 = icmp sge i32 %t246, %t247
  br i1 %t248, label %grow92, label %put93
grow92:
  %t249 = mul i32 %t247, 2
  %t250 = icmp eq i32 %t247, 0
  %t251 = select i1 %t250, i32 8, i32 %t249
  %t252 = getelementptr ptr, ptr null, i32 1
  %t253 = ptrtoint ptr %t252 to i64
  %t254 = zext i32 %t251 to i64
  %t255 = mul i64 %t254, %t253
  %t256 = load ptr, ptr %t245
  %t257 = call ptr @realloc(ptr %t256, i64 %t255)
  store ptr %t257, ptr %t245
  store i32 %t251, ptr %t244
  br label %put93
put93:
  %t258 = load ptr, ptr %t158
  %t259 = load ptr, ptr %t245
  %t260 = getelementptr inbounds ptr, ptr %t259, i32 %t246
  store ptr %t258, ptr %t260
  %t261 = add i32 %t246, 1
  store i32 %t261, ptr %t243
  br label %ret
ifend68:
  %t262 = call i32 @fn_is_id(ptr @.str140)
  %t263 = icmp ne i32 %t262, 0
  br i1 %t263, label %then94, label %ifend96
then94:
  %t264 = load ptr, ptr @g_prog
  %t265 = getelementptr inbounds %LSlice, ptr %t264, i32 0, i32 1
  %t266 = getelementptr inbounds %LSlice, ptr %t264, i32 0, i32 2
  %t267 = getelementptr inbounds %LSlice, ptr %t264, i32 0, i32 0
  %t268 = load i32, ptr %t265
  %t269 = load i32, ptr %t266
  %t270 = icmp sge i32 %t268, %t269
  br i1 %t270, label %grow97, label %put98
grow97:
  %t271 = mul i32 %t269, 2
  %t272 = icmp eq i32 %t269, 0
  %t273 = select i1 %t272, i32 8, i32 %t271
  %t274 = getelementptr ptr, ptr null, i32 1
  %t275 = ptrtoint ptr %t274 to i64
  %t276 = zext i32 %t273 to i64
  %t277 = mul i64 %t276, %t275
  %t278 = load ptr, ptr %t267
  %t279 = call ptr @realloc(ptr %t278, i64 %t277)
  store ptr %t279, ptr %t267
  store i32 %t273, ptr %t266
  br label %put98
put98:
  %t280 = call ptr @fn_parse_ui()
  %t281 = load ptr, ptr %t267
  %t282 = getelementptr inbounds ptr, ptr %t281, i32 %t268
  store ptr %t280, ptr %t282
  %t283 = add i32 %t268, 1
  store i32 %t283, ptr %t265
  br label %ret
ifend96:
  %t284 = call i32 @fn_is_id(ptr @.str141)
  %t285 = icmp ne i32 %t284, 0
  br i1 %t285, label %then99, label %ifend101
then99:
  %t286 = load ptr, ptr @g_prog
  %t287 = getelementptr inbounds %LSlice, ptr %t286, i32 0, i32 1
  %t288 = getelementptr inbounds %LSlice, ptr %t286, i32 0, i32 2
  %t289 = getelementptr inbounds %LSlice, ptr %t286, i32 0, i32 0
  %t290 = load i32, ptr %t287
  %t291 = load i32, ptr %t288
  %t292 = icmp sge i32 %t290, %t291
  br i1 %t292, label %grow102, label %put103
grow102:
  %t293 = mul i32 %t291, 2
  %t294 = icmp eq i32 %t291, 0
  %t295 = select i1 %t294, i32 8, i32 %t293
  %t296 = getelementptr ptr, ptr null, i32 1
  %t297 = ptrtoint ptr %t296 to i64
  %t298 = zext i32 %t295 to i64
  %t299 = mul i64 %t298, %t297
  %t300 = load ptr, ptr %t289
  %t301 = call ptr @realloc(ptr %t300, i64 %t299)
  store ptr %t301, ptr %t289
  store i32 %t295, ptr %t288
  br label %put103
put103:
  %t302 = call ptr @fn_parse_var()
  %t303 = load ptr, ptr %t289
  %t304 = getelementptr inbounds ptr, ptr %t303, i32 %t290
  store ptr %t302, ptr %t304
  %t305 = add i32 %t290, 1
  store i32 %t305, ptr %t287
  br label %ret
ifend101:
  %t306 = call i32 @fn_is_id(ptr @.str142)
  %t307 = icmp ne i32 %t306, 0
  br i1 %t307, label %then104, label %ifend106
then104:
  %t308 = load ptr, ptr @g_prog
  %t309 = getelementptr inbounds %LSlice, ptr %t308, i32 0, i32 1
  %t310 = getelementptr inbounds %LSlice, ptr %t308, i32 0, i32 2
  %t311 = getelementptr inbounds %LSlice, ptr %t308, i32 0, i32 0
  %t312 = load i32, ptr %t309
  %t313 = load i32, ptr %t310
  %t314 = icmp sge i32 %t312, %t313
  br i1 %t314, label %grow107, label %put108
grow107:
  %t315 = mul i32 %t313, 2
  %t316 = icmp eq i32 %t313, 0
  %t317 = select i1 %t316, i32 8, i32 %t315
  %t318 = getelementptr ptr, ptr null, i32 1
  %t319 = ptrtoint ptr %t318 to i64
  %t320 = zext i32 %t317 to i64
  %t321 = mul i64 %t320, %t319
  %t322 = load ptr, ptr %t311
  %t323 = call ptr @realloc(ptr %t322, i64 %t321)
  store ptr %t323, ptr %t311
  store i32 %t317, ptr %t310
  br label %put108
put108:
  %t324 = call ptr @fn_parse_const()
  %t325 = load ptr, ptr %t311
  %t326 = getelementptr inbounds ptr, ptr %t325, i32 %t312
  store ptr %t324, ptr %t326
  %t327 = add i32 %t312, 1
  store i32 %t327, ptr %t309
  br label %ret
ifend106:
  %t328 = call i32 @fn_is_id(ptr @.str143)
  %t329 = icmp ne i32 %t328, 0
  br i1 %t329, label %then109, label %ifend111
then109:
  %t330 = call ptr @fn_parse_fn()
  store ptr %t330, ptr %t331
  %t332 = load i32, ptr %t0
  %t333 = icmp ne i32 %t332, 0
  br i1 %t333, label %then112, label %ifend114
then112:
  %t334 = load ptr, ptr %t331
  %t335 = getelementptr inbounds %Cmp_Node, ptr %t334, i32 0, i32 2
  store i32 1, ptr %t335
  br label %ifend114
ifend114:
  %t336 = load ptr, ptr @g_prog
  %t337 = getelementptr inbounds %LSlice, ptr %t336, i32 0, i32 1
  %t338 = getelementptr inbounds %LSlice, ptr %t336, i32 0, i32 2
  %t339 = getelementptr inbounds %LSlice, ptr %t336, i32 0, i32 0
  %t340 = load i32, ptr %t337
  %t341 = load i32, ptr %t338
  %t342 = icmp sge i32 %t340, %t341
  br i1 %t342, label %grow115, label %put116
grow115:
  %t343 = mul i32 %t341, 2
  %t344 = icmp eq i32 %t341, 0
  %t345 = select i1 %t344, i32 8, i32 %t343
  %t346 = getelementptr ptr, ptr null, i32 1
  %t347 = ptrtoint ptr %t346 to i64
  %t348 = zext i32 %t345 to i64
  %t349 = mul i64 %t348, %t347
  %t350 = load ptr, ptr %t339
  %t351 = call ptr @realloc(ptr %t350, i64 %t349)
  store ptr %t351, ptr %t339
  store i32 %t345, ptr %t338
  br label %put116
put116:
  %t352 = load ptr, ptr %t331
  %t353 = load ptr, ptr %t339
  %t354 = getelementptr inbounds ptr, ptr %t353, i32 %t340
  store ptr %t352, ptr %t354
  %t355 = add i32 %t340, 1
  store i32 %t355, ptr %t337
  br label %ret
ifend111:
  %t356 = call i32 @fn_is_id(ptr @.str144)
  %t357 = icmp ne i32 %t356, 0
  br i1 %t357, label %then117, label %ifend119
then117:
  %t358 = load ptr, ptr @g_prog
  %t359 = getelementptr inbounds %LSlice, ptr %t358, i32 0, i32 1
  %t360 = getelementptr inbounds %LSlice, ptr %t358, i32 0, i32 2
  %t361 = getelementptr inbounds %LSlice, ptr %t358, i32 0, i32 0
  %t362 = load i32, ptr %t359
  %t363 = load i32, ptr %t360
  %t364 = icmp sge i32 %t362, %t363
  br i1 %t364, label %grow120, label %put121
grow120:
  %t365 = mul i32 %t363, 2
  %t366 = icmp eq i32 %t363, 0
  %t367 = select i1 %t366, i32 8, i32 %t365
  %t368 = getelementptr ptr, ptr null, i32 1
  %t369 = ptrtoint ptr %t368 to i64
  %t370 = zext i32 %t367 to i64
  %t371 = mul i64 %t370, %t369
  %t372 = load ptr, ptr %t361
  %t373 = call ptr @realloc(ptr %t372, i64 %t371)
  store ptr %t373, ptr %t361
  store i32 %t367, ptr %t360
  br label %put121
put121:
  %t374 = call ptr @fn_parse_extern()
  %t375 = load ptr, ptr %t361
  %t376 = getelementptr inbounds ptr, ptr %t375, i32 %t362
  store ptr %t374, ptr %t376
  %t377 = add i32 %t362, 1
  store i32 %t377, ptr %t359
  br label %ret
ifend119:
  %t378 = call i32 @fn_is_id(ptr @.str145)
  %t379 = icmp ne i32 %t378, 0
  br i1 %t379, label %then122, label %ifend124
then122:
  %t380 = load ptr, ptr @g_prog
  %t381 = getelementptr inbounds %LSlice, ptr %t380, i32 0, i32 1
  %t382 = getelementptr inbounds %LSlice, ptr %t380, i32 0, i32 2
  %t383 = getelementptr inbounds %LSlice, ptr %t380, i32 0, i32 0
  %t384 = load i32, ptr %t381
  %t385 = load i32, ptr %t382
  %t386 = icmp sge i32 %t384, %t385
  br i1 %t386, label %grow125, label %put126
grow125:
  %t387 = mul i32 %t385, 2
  %t388 = icmp eq i32 %t385, 0
  %t389 = select i1 %t388, i32 8, i32 %t387
  %t390 = getelementptr ptr, ptr null, i32 1
  %t391 = ptrtoint ptr %t390 to i64
  %t392 = zext i32 %t389 to i64
  %t393 = mul i64 %t392, %t391
  %t394 = load ptr, ptr %t383
  %t395 = call ptr @realloc(ptr %t394, i64 %t393)
  store ptr %t395, ptr %t383
  store i32 %t389, ptr %t382
  br label %put126
put126:
  %t396 = call ptr @fn_parse_main()
  %t397 = load ptr, ptr %t383
  %t398 = getelementptr inbounds ptr, ptr %t397, i32 %t384
  store ptr %t396, ptr %t398
  %t399 = add i32 %t384, 1
  store i32 %t399, ptr %t381
  br label %ret
ifend124:
  call void @fn_perr(ptr @.str146)
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
  %t36 = call ptr @fn_str_concat(ptr @.str147, ptr %t35)
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
  %t52 = getelementptr inbounds %Cmp_Tok, ptr %t51, i32 0, i32 0
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
  store ptr @.str148, ptr @g_cur_dir
  call void @fn_do_import(ptr @.str149)
  %t6 = load ptr, ptr %t5
  store ptr %t6, ptr @g_cur_dir
  br label %ret
ret:
  ret void
}

define void @fn_parse_program() {
entry:
  %t58 = alloca ptr
  %t62 = alloca ptr
  %t71 = alloca ptr
  %t74 = alloca i32
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
  store ptr %t8, ptr @g_g_computed
  %t12 = getelementptr %LSlice, ptr null, i32 1
  %t13 = ptrtoint ptr %t12 to i64
  %t14 = call ptr @malloc(i64 %t13)
  %t15 = getelementptr inbounds %LSlice, ptr %t14, i32 0, i32 0
  store ptr null, ptr %t15
  %t16 = getelementptr inbounds %LSlice, ptr %t14, i32 0, i32 1
  store i32 0, ptr %t16
  %t17 = getelementptr inbounds %LSlice, ptr %t14, i32 0, i32 2
  store i32 0, ptr %t17
  store ptr %t14, ptr @g_g_onspawn
  %t18 = getelementptr %LSlice, ptr null, i32 1
  %t19 = ptrtoint ptr %t18 to i64
  %t20 = call ptr @malloc(i64 %t19)
  %t21 = getelementptr inbounds %LSlice, ptr %t20, i32 0, i32 0
  store ptr null, ptr %t21
  %t22 = getelementptr inbounds %LSlice, ptr %t20, i32 0, i32 1
  store i32 0, ptr %t22
  %t23 = getelementptr inbounds %LSlice, ptr %t20, i32 0, i32 2
  store i32 0, ptr %t23
  store ptr %t20, ptr @g_g_ondespawn
  %t24 = getelementptr %LSlice, ptr null, i32 1
  %t25 = ptrtoint ptr %t24 to i64
  %t26 = call ptr @malloc(i64 %t25)
  %t27 = getelementptr inbounds %LSlice, ptr %t26, i32 0, i32 0
  store ptr null, ptr %t27
  %t28 = getelementptr inbounds %LSlice, ptr %t26, i32 0, i32 1
  store i32 0, ptr %t28
  %t29 = getelementptr inbounds %LSlice, ptr %t26, i32 0, i32 2
  store i32 0, ptr %t29
  store ptr %t26, ptr @g_g_onattach
  %t30 = getelementptr %LSlice, ptr null, i32 1
  %t31 = ptrtoint ptr %t30 to i64
  %t32 = call ptr @malloc(i64 %t31)
  %t33 = getelementptr inbounds %LSlice, ptr %t32, i32 0, i32 0
  store ptr null, ptr %t33
  %t34 = getelementptr inbounds %LSlice, ptr %t32, i32 0, i32 1
  store i32 0, ptr %t34
  %t35 = getelementptr inbounds %LSlice, ptr %t32, i32 0, i32 2
  store i32 0, ptr %t35
  store ptr %t32, ptr @g_g_onenable
  %t36 = getelementptr %LSlice, ptr null, i32 1
  %t37 = ptrtoint ptr %t36 to i64
  %t38 = call ptr @malloc(i64 %t37)
  %t39 = getelementptr inbounds %LSlice, ptr %t38, i32 0, i32 0
  store ptr null, ptr %t39
  %t40 = getelementptr inbounds %LSlice, ptr %t38, i32 0, i32 1
  store i32 0, ptr %t40
  %t41 = getelementptr inbounds %LSlice, ptr %t38, i32 0, i32 2
  store i32 0, ptr %t41
  store ptr %t38, ptr @g_g_ondisable
  %t42 = getelementptr %LSlice, ptr null, i32 1
  %t43 = ptrtoint ptr %t42 to i64
  %t44 = call ptr @malloc(i64 %t43)
  %t45 = getelementptr inbounds %LSlice, ptr %t44, i32 0, i32 0
  store ptr null, ptr %t45
  %t46 = getelementptr inbounds %LSlice, ptr %t44, i32 0, i32 1
  store i32 0, ptr %t46
  %t47 = getelementptr inbounds %LSlice, ptr %t44, i32 0, i32 2
  store i32 0, ptr %t47
  store ptr %t44, ptr @g_loaded_paths
  call void @fn_skipnl()
  store ptr @.str150, ptr @g_g_game_name
  br label %wcond0
wcond0:
  %t48 = call i32 @fn_is_id(ptr @.str151)
  %t49 = icmp ne i32 %t48, 0
  br i1 %t49, label %wbody1, label %wend2
wbody1:
  %t50 = load i32, ptr @g_pi
  %t51 = add i32 %t50, 1
  store i32 %t51, ptr @g_pi
  %t52 = load ptr, ptr @g_toks
  %t53 = getelementptr inbounds %LSlice, ptr %t52, i32 0, i32 0
  %t54 = load ptr, ptr %t53
  %t55 = load i32, ptr @g_pi
  %t56 = getelementptr inbounds ptr, ptr %t54, i32 %t55
  %t57 = load ptr, ptr %t56
  store ptr %t57, ptr %t58
  %t59 = load ptr, ptr %t58
  %t60 = getelementptr inbounds %Cmp_Tok, ptr %t59, i32 0, i32 1
  %t61 = load ptr, ptr %t60
  store ptr %t61, ptr %t62
  %t63 = load i32, ptr @g_pi
  %t64 = add i32 %t63, 1
  store i32 %t64, ptr @g_pi
  %t65 = load ptr, ptr %t62
  call void @fn_do_import(ptr %t65)
  call void @fn_skipnl()
  br label %wcond0
wend2:
  br label %wcond3
wcond3:
  %t66 = call i32 @fn_is_op(ptr @.str152)
  %t67 = icmp ne i32 %t66, 0
  br i1 %t67, label %wbody4, label %wend5
wbody4:
  %t68 = load i32, ptr @g_pi
  %t69 = add i32 %t68, 1
  store i32 %t69, ptr @g_pi
  %t70 = call ptr @fn_eat_id()
  store ptr %t70, ptr %t71
  %t72 = call i32 @fn_is_op(ptr @.str153)
  %t73 = icmp ne i32 %t72, 0
  br i1 %t73, label %then6, label %ifend8
then6:
  store i32 0, ptr %t74
  br label %wcond9
wcond9:
  %t75 = icmp ne i32 1, 0
  br i1 %t75, label %wbody10, label %wend11
wbody10:
  %t76 = call i32 @fn_is_op(ptr @.str154)
  %t77 = icmp ne i32 %t76, 0
  br i1 %t77, label %then12, label %ifend14
then12:
  %t78 = load i32, ptr %t74
  %t79 = add i32 %t78, 1
  store i32 %t79, ptr %t74
  br label %ifend14
ifend14:
  %t80 = call i32 @fn_is_op(ptr @.str155)
  %t81 = icmp ne i32 %t80, 0
  br i1 %t81, label %then15, label %ifend17
then15:
  %t82 = load i32, ptr %t74
  %t83 = sub i32 %t82, 1
  store i32 %t83, ptr %t74
  br label %ifend17
ifend17:
  %t84 = load i32, ptr @g_pi
  %t85 = add i32 %t84, 1
  store i32 %t85, ptr @g_pi
  %t86 = load i32, ptr %t74
  %t87 = icmp eq i32 %t86, 0
  %t88 = zext i1 %t87 to i32
  %t89 = icmp ne i32 %t88, 0
  br i1 %t89, label %then18, label %ifend20
then18:
  br label %wend11
ifend20:
  br label %wcond9
wend11:
  br label %ifend8
ifend8:
  call void @fn_skipnl()
  br label %wcond3
wend5:
  %t90 = call i32 @fn_is_id(ptr @.str156)
  %t91 = icmp ne i32 %t90, 0
  br i1 %t91, label %then21, label %ifend23
then21:
  %t92 = load i32, ptr @g_pi
  %t93 = add i32 %t92, 1
  store i32 %t93, ptr @g_pi
  %t94 = call ptr @fn_eat_id()
  store ptr %t94, ptr @g_g_game_name
  call void @fn_skipnl()
  call void @fn_eat_op(ptr @.str157)
  br label %ifend23
ifend23:
  br label %wcond24
wcond24:
  %t95 = icmp ne i32 1, 0
  br i1 %t95, label %wbody25, label %wend26
wbody25:
  call void @fn_skipnl()
  %t96 = load ptr, ptr @g_toks
  %t97 = getelementptr inbounds %LSlice, ptr %t96, i32 0, i32 0
  %t98 = load ptr, ptr %t97
  %t99 = load i32, ptr @g_pi
  %t100 = getelementptr inbounds ptr, ptr %t98, i32 %t99
  %t101 = load ptr, ptr %t100
  %t102 = getelementptr inbounds %Cmp_Tok, ptr %t101, i32 0, i32 0
  %t103 = load i32, ptr %t102
  %t104 = icmp eq i32 %t103, 5
  %t105 = zext i1 %t104 to i32
  %t106 = icmp ne i32 %t105, 0
  br i1 %t106, label %then27, label %ifend29
then27:
  br label %wend26
ifend29:
  %t107 = call i32 @fn_is_op(ptr @.str158)
  %t108 = icmp ne i32 %t107, 0
  br i1 %t108, label %then30, label %ifend32
then30:
  br label %wend26
ifend32:
  call void @fn_parse_one_decl()
  br label %wcond24
wend26:
  br label %ret
ret:
  ret void
}

define ptr @fn_parse_component() {
entry:
  %retval = alloca ptr
  %t3 = alloca ptr
  %t10 = alloca i32
  %t16 = alloca ptr
  %t21 = alloca ptr
  %t0 = load i32, ptr @g_pi
  %t1 = add i32 %t0, 1
  store i32 %t1, ptr @g_pi
  %t2 = call ptr @fn_node(i32 8)
  store ptr %t2, ptr %t3
  %t4 = load ptr, ptr %t3
  %t5 = getelementptr inbounds %Cmp_Node, ptr %t4, i32 0, i32 1
  %t6 = call ptr @fn_eat_id()
  store ptr %t6, ptr %t5
  call void @fn_skipnl()
  call void @fn_eat_op(ptr @.str159)
  br label %wcond0
wcond0:
  %t7 = icmp ne i32 1, 0
  br i1 %t7, label %wbody1, label %wend2
wbody1:
  call void @fn_skipnl()
  %t8 = call i32 @fn_is_op(ptr @.str160)
  %t9 = icmp ne i32 %t8, 0
  br i1 %t9, label %then3, label %ifend5
then3:
  br label %wend2
ifend5:
  store i32 0, ptr %t10
  %t11 = call i32 @fn_is_op(ptr @.str161)
  %t12 = icmp ne i32 %t11, 0
  br i1 %t12, label %then6, label %ifend8
then6:
  %t13 = load i32, ptr @g_pi
  %t14 = add i32 %t13, 1
  store i32 %t14, ptr @g_pi
  %t15 = call ptr @fn_eat_id()
  store ptr %t15, ptr %t16
  %t17 = load ptr, ptr %t16
  %t18 = call i32 @fn_str_eq(ptr %t17, ptr @.str162)
  %t19 = icmp ne i32 %t18, 0
  br i1 %t19, label %then9, label %ifend11
then9:
  store i32 1, ptr %t10
  br label %ifend11
ifend11:
  call void @fn_skipnl()
  br label %ifend8
ifend8:
  %t20 = call ptr @fn_node(i32 1)
  store ptr %t20, ptr %t21
  %t22 = load ptr, ptr %t21
  %t23 = getelementptr inbounds %Cmp_Node, ptr %t22, i32 0, i32 1
  %t24 = call ptr @fn_eat_id()
  store ptr %t24, ptr %t23
  call void @fn_eat_op(ptr @.str163)
  %t25 = load ptr, ptr %t21
  %t26 = getelementptr inbounds %Cmp_Node, ptr %t25, i32 0, i32 3
  %t27 = call ptr @fn_ptype()
  store ptr %t27, ptr %t26
  %t28 = call i32 @fn_is_op(ptr @.str164)
  %t29 = icmp ne i32 %t28, 0
  br i1 %t29, label %then12, label %ifend14
then12:
  %t30 = load i32, ptr @g_pi
  %t31 = add i32 %t30, 1
  store i32 %t31, ptr @g_pi
  %t32 = load ptr, ptr %t21
  %t33 = getelementptr inbounds %Cmp_Node, ptr %t32, i32 0, i32 4
  %t34 = call ptr @fn_expr()
  store ptr %t34, ptr %t33
  br label %ifend14
ifend14:
  %t35 = load i32, ptr %t10
  %t36 = icmp ne i32 %t35, 0
  br i1 %t36, label %then15, label %else16
then15:
  %t37 = load ptr, ptr %t3
  %t38 = getelementptr inbounds %Cmp_Node, ptr %t37, i32 0, i32 1
  %t39 = load ptr, ptr %t38
  %t40 = load ptr, ptr %t21
  %t41 = getelementptr inbounds %Cmp_Node, ptr %t40, i32 0, i32 1
  %t42 = load ptr, ptr %t41
  %t43 = load ptr, ptr %t21
  %t44 = getelementptr inbounds %Cmp_Node, ptr %t43, i32 0, i32 3
  %t45 = load ptr, ptr %t44
  %t46 = load ptr, ptr %t21
  %t47 = getelementptr inbounds %Cmp_Node, ptr %t46, i32 0, i32 4
  %t48 = load ptr, ptr %t47
  call void @fn_register_computed(ptr %t39, ptr %t42, ptr %t45, ptr %t48)
  br label %ifend17
else16:
  %t49 = load ptr, ptr %t3
  %t50 = getelementptr inbounds %Cmp_Node, ptr %t49, i32 0, i32 7
  %t51 = load ptr, ptr %t50
  %t52 = getelementptr inbounds %LSlice, ptr %t51, i32 0, i32 1
  %t53 = getelementptr inbounds %LSlice, ptr %t51, i32 0, i32 2
  %t54 = getelementptr inbounds %LSlice, ptr %t51, i32 0, i32 0
  %t55 = load i32, ptr %t52
  %t56 = load i32, ptr %t53
  %t57 = icmp sge i32 %t55, %t56
  br i1 %t57, label %grow18, label %put19
grow18:
  %t58 = mul i32 %t56, 2
  %t59 = icmp eq i32 %t56, 0
  %t60 = select i1 %t59, i32 8, i32 %t58
  %t61 = getelementptr ptr, ptr null, i32 1
  %t62 = ptrtoint ptr %t61 to i64
  %t63 = zext i32 %t60 to i64
  %t64 = mul i64 %t63, %t62
  %t65 = load ptr, ptr %t54
  %t66 = call ptr @realloc(ptr %t65, i64 %t64)
  store ptr %t66, ptr %t54
  store i32 %t60, ptr %t53
  br label %put19
put19:
  %t67 = load ptr, ptr %t21
  %t68 = load ptr, ptr %t54
  %t69 = getelementptr inbounds ptr, ptr %t68, i32 %t55
  store ptr %t67, ptr %t69
  %t70 = add i32 %t55, 1
  store i32 %t70, ptr %t52
  br label %ifend17
ifend17:
  %t71 = call i32 @fn_is_op(ptr @.str165)
  %t72 = icmp ne i32 %t71, 0
  br i1 %t72, label %then20, label %ifend22
then20:
  %t73 = load i32, ptr @g_pi
  %t74 = add i32 %t73, 1
  store i32 %t74, ptr @g_pi
  br label %ifend22
ifend22:
  br label %wcond0
wend2:
  call void @fn_eat_op(ptr @.str166)
  %t75 = load ptr, ptr %t3
  store ptr %t75, ptr %retval
  br label %ret
ret:
  %t76 = load ptr, ptr %retval
  ret ptr %t76
}

define ptr @fn_parse_system() {
entry:
  %retval = alloca ptr
  %t3 = alloca ptr
  %t15 = alloca ptr
  %t18 = alloca i32
  %t0 = load i32, ptr @g_pi
  %t1 = add i32 %t0, 1
  store i32 %t1, ptr @g_pi
  %t2 = call ptr @fn_node(i32 9)
  store ptr %t2, ptr %t3
  %t4 = load ptr, ptr %t3
  %t5 = getelementptr inbounds %Cmp_Node, ptr %t4, i32 0, i32 1
  %t6 = call ptr @fn_eat_id()
  store ptr %t6, ptr %t5
  %t7 = load ptr, ptr %t3
  %t8 = getelementptr inbounds %Cmp_Node, ptr %t7, i32 0, i32 3
  store ptr @.str167, ptr %t8
  br label %wcond0
wcond0:
  %t9 = icmp ne i32 1, 0
  br i1 %t9, label %wbody1, label %wend2
wbody1:
  call void @fn_skipnl()
  %t10 = call i32 @fn_is_op(ptr @.str168)
  %t11 = icmp ne i32 %t10, 0
  br i1 %t11, label %then3, label %ifend5
then3:
  %t12 = load i32, ptr @g_pi
  %t13 = add i32 %t12, 1
  store i32 %t13, ptr @g_pi
  %t14 = call ptr @fn_eat_id()
  store ptr %t14, ptr %t15
  %t16 = call i32 @fn_is_op(ptr @.str169)
  %t17 = icmp ne i32 %t16, 0
  br i1 %t17, label %then6, label %ifend8
then6:
  store i32 0, ptr %t18
  br label %wcond9
wcond9:
  %t19 = icmp ne i32 1, 0
  br i1 %t19, label %wbody10, label %wend11
wbody10:
  %t20 = call i32 @fn_is_op(ptr @.str170)
  %t21 = icmp ne i32 %t20, 0
  br i1 %t21, label %then12, label %ifend14
then12:
  %t22 = load i32, ptr %t18
  %t23 = add i32 %t22, 1
  store i32 %t23, ptr %t18
  br label %ifend14
ifend14:
  %t24 = call i32 @fn_is_op(ptr @.str171)
  %t25 = icmp ne i32 %t24, 0
  br i1 %t25, label %then15, label %ifend17
then15:
  %t26 = load i32, ptr %t18
  %t27 = sub i32 %t26, 1
  store i32 %t27, ptr %t18
  br label %ifend17
ifend17:
  %t28 = load i32, ptr @g_pi
  %t29 = add i32 %t28, 1
  store i32 %t29, ptr @g_pi
  %t30 = load i32, ptr %t18
  %t31 = icmp eq i32 %t30, 0
  %t32 = zext i1 %t31 to i32
  %t33 = icmp ne i32 %t32, 0
  br i1 %t33, label %then18, label %ifend20
then18:
  br label %wend11
ifend20:
  br label %wcond9
wend11:
  br label %ifend8
ifend8:
  br label %wcond0
ifend5:
  %t34 = call i32 @fn_is_id(ptr @.str172)
  %t35 = icmp ne i32 %t34, 0
  br i1 %t35, label %then21, label %ifend23
then21:
  %t36 = load i32, ptr @g_pi
  %t37 = add i32 %t36, 1
  store i32 %t37, ptr @g_pi
  %t38 = load ptr, ptr %t3
  %t39 = getelementptr inbounds %Cmp_Node, ptr %t38, i32 0, i32 3
  %t40 = call ptr @fn_eat_id()
  store ptr %t40, ptr %t39
  br label %wcond0
ifend23:
  br label %wend2
wend2:
  call void @fn_skipnl()
  %t41 = load ptr, ptr %t3
  %t42 = getelementptr inbounds %Cmp_Node, ptr %t41, i32 0, i32 4
  %t43 = call ptr @fn_block()
  store ptr %t43, ptr %t42
  %t44 = load ptr, ptr %t3
  store ptr %t44, ptr %retval
  br label %ret
ret:
  %t45 = load ptr, ptr %retval
  ret ptr %t45
}

define ptr @fn_parse_query_tail() {
entry:
  %retval = alloca ptr
  %t1 = alloca ptr
  %t11 = alloca ptr
  %t40 = alloca ptr
  call void @fn_eat_op(ptr @.str173)
  %t0 = call ptr @fn_node(i32 7)
  store ptr %t0, ptr %t1
  br label %wcond0
wcond0:
  %t2 = call i32 @fn_is_op(ptr @.str174)
  %t3 = icmp eq i32 %t2, 0
  %t4 = zext i1 %t3 to i32
  %t5 = icmp ne i32 %t4, 0
  br i1 %t5, label %wbody1, label %wend2
wbody1:
  %t6 = call i32 @fn_is_op(ptr @.str175)
  %t7 = icmp ne i32 %t6, 0
  br i1 %t7, label %then3, label %else4
then3:
  %t8 = load i32, ptr @g_pi
  %t9 = add i32 %t8, 1
  store i32 %t9, ptr @g_pi
  %t10 = call ptr @fn_node(i32 33)
  store ptr %t10, ptr %t11
  %t12 = load ptr, ptr %t11
  %t13 = getelementptr inbounds %Cmp_Node, ptr %t12, i32 0, i32 1
  %t14 = call ptr @fn_eat_id()
  store ptr %t14, ptr %t13
  %t15 = load ptr, ptr %t11
  %t16 = getelementptr inbounds %Cmp_Node, ptr %t15, i32 0, i32 2
  store i32 1, ptr %t16
  %t17 = load ptr, ptr %t1
  %t18 = getelementptr inbounds %Cmp_Node, ptr %t17, i32 0, i32 7
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
  call void @fn_eat_op(ptr @.str176)
  br label %ifend5
else4:
  %t39 = call ptr @fn_node(i32 33)
  store ptr %t39, ptr %t40
  %t41 = load ptr, ptr %t40
  %t42 = getelementptr inbounds %Cmp_Node, ptr %t41, i32 0, i32 1
  %t43 = call ptr @fn_eat_id()
  store ptr %t43, ptr %t42
  %t44 = load ptr, ptr %t40
  %t45 = getelementptr inbounds %Cmp_Node, ptr %t44, i32 0, i32 2
  store i32 0, ptr %t45
  %t46 = load ptr, ptr %t1
  %t47 = getelementptr inbounds %Cmp_Node, ptr %t46, i32 0, i32 7
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
  %t68 = call i32 @fn_is_op(ptr @.str177)
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
  call void @fn_eat_op(ptr @.str178)
  %t72 = call i32 @fn_is_id(ptr @.str179)
  %t73 = icmp ne i32 %t72, 0
  br i1 %t73, label %then13, label %ifend15
then13:
  %t74 = load i32, ptr @g_pi
  %t75 = add i32 %t74, 1
  store i32 %t75, ptr @g_pi
  %t76 = load ptr, ptr %t1
  %t77 = getelementptr inbounds %Cmp_Node, ptr %t76, i32 0, i32 4
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
  %t0 = call ptr @fn_node(i32 21)
  store ptr %t0, ptr %t1
  call void @fn_eat_op(ptr @.str180)
  br label %wcond0
wcond0:
  %t2 = call i32 @fn_is_op(ptr @.str181)
  %t3 = icmp eq i32 %t2, 0
  %t4 = zext i1 %t3 to i32
  %t5 = icmp ne i32 %t4, 0
  br i1 %t5, label %wbody1, label %wend2
wbody1:
  %t6 = call ptr @fn_node(i32 33)
  store ptr %t6, ptr %t7
  %t8 = load ptr, ptr %t7
  %t9 = getelementptr inbounds %Cmp_Node, ptr %t8, i32 0, i32 1
  %t10 = call ptr @fn_eat_id()
  store ptr %t10, ptr %t9
  %t11 = load ptr, ptr %t1
  %t12 = getelementptr inbounds %Cmp_Node, ptr %t11, i32 0, i32 7
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
  %t33 = call i32 @fn_is_op(ptr @.str182)
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
  call void @fn_eat_op(ptr @.str183)
  %t37 = call ptr @fn_eat_id()
  store ptr %t37, ptr %t38
  %t39 = call i32 @fn_is_id(ptr @.str184)
  %t40 = icmp eq i32 %t39, 0
  %t41 = zext i1 %t40 to i32
  %t42 = icmp ne i32 %t41, 0
  br i1 %t42, label %then8, label %ifend10
then8:
  call void @fn_perr(ptr @.str185)
  br label %ifend10
ifend10:
  %t43 = load i32, ptr @g_pi
  %t44 = add i32 %t43, 1
  store i32 %t44, ptr @g_pi
  %t45 = load ptr, ptr %t1
  %t46 = getelementptr inbounds %Cmp_Node, ptr %t45, i32 0, i32 6
  %t47 = call ptr @fn_parse_query_tail()
  store ptr %t47, ptr %t46
  %t48 = load ptr, ptr %t1
  %t49 = getelementptr inbounds %Cmp_Node, ptr %t48, i32 0, i32 5
  %t50 = load ptr, ptr %t1
  %t51 = getelementptr inbounds %Cmp_Node, ptr %t50, i32 0, i32 6
  %t52 = load ptr, ptr %t51
  %t53 = getelementptr inbounds %Cmp_Node, ptr %t52, i32 0, i32 4
  %t54 = load ptr, ptr %t53
  store ptr %t54, ptr %t49
  %t55 = load ptr, ptr %t1
  %t56 = getelementptr inbounds %Cmp_Node, ptr %t55, i32 0, i32 4
  %t57 = call ptr @fn_block()
  store ptr %t57, ptr %t56
  %t58 = load ptr, ptr %t1
  store ptr %t58, ptr %retval
  br label %ret
ret:
  %t59 = load ptr, ptr %retval
  ret ptr %t59
}

define ptr @fn_mk_and(ptr %arg_a, ptr %arg_b) {
entry:
  %retval = alloca ptr
  %t0 = alloca ptr
  %t1 = alloca ptr
  %t8 = alloca ptr
  store ptr %arg_a, ptr %t0
  store ptr %arg_b, ptr %t1
  %t2 = load ptr, ptr %t0
  %t3 = icmp eq ptr %t2, null
  %t4 = zext i1 %t3 to i32
  %t5 = icmp ne i32 %t4, 0
  br i1 %t5, label %then0, label %ifend2
then0:
  %t6 = load ptr, ptr %t1
  store ptr %t6, ptr %retval
  br label %ret
ifend2:
  %t7 = call ptr @fn_node(i32 37)
  store ptr %t7, ptr %t8
  %t9 = load ptr, ptr %t8
  %t10 = getelementptr inbounds %Cmp_Node, ptr %t9, i32 0, i32 1
  store ptr @.str186, ptr %t10
  %t11 = load ptr, ptr %t8
  %t12 = getelementptr inbounds %Cmp_Node, ptr %t11, i32 0, i32 4
  %t13 = load ptr, ptr %t0
  store ptr %t13, ptr %t12
  %t14 = load ptr, ptr %t8
  %t15 = getelementptr inbounds %Cmp_Node, ptr %t14, i32 0, i32 5
  %t16 = load ptr, ptr %t1
  store ptr %t16, ptr %t15
  %t17 = load ptr, ptr %t8
  store ptr %t17, ptr %retval
  br label %ret
ret:
  %t18 = load ptr, ptr %retval
  ret ptr %t18
}

define ptr @fn_qualify_fields(ptr %arg_e, ptr %arg_base) {
entry:
  %retval = alloca ptr
  %t0 = alloca ptr
  %t1 = alloca ptr
  %t14 = alloca ptr
  %t31 = alloca ptr
  %t59 = alloca ptr
  store ptr %arg_e, ptr %t0
  store ptr %arg_base, ptr %t1
  %t2 = load ptr, ptr %t0
  %t3 = icmp eq ptr %t2, null
  %t4 = zext i1 %t3 to i32
  %t5 = icmp ne i32 %t4, 0
  br i1 %t5, label %then0, label %ifend2
then0:
  %t6 = load ptr, ptr %t0
  store ptr %t6, ptr %retval
  br label %ret
ifend2:
  %t7 = load ptr, ptr %t0
  %t8 = getelementptr inbounds %Cmp_Node, ptr %t7, i32 0, i32 0
  %t9 = load i32, ptr %t8
  %t10 = icmp eq i32 %t9, 33
  %t11 = zext i1 %t10 to i32
  %t12 = icmp ne i32 %t11, 0
  br i1 %t12, label %then3, label %ifend5
then3:
  %t13 = call ptr @fn_node(i32 35)
  store ptr %t13, ptr %t14
  %t15 = load ptr, ptr %t14
  %t16 = getelementptr inbounds %Cmp_Node, ptr %t15, i32 0, i32 4
  %t17 = load ptr, ptr %t1
  store ptr %t17, ptr %t16
  %t18 = load ptr, ptr %t14
  %t19 = getelementptr inbounds %Cmp_Node, ptr %t18, i32 0, i32 1
  %t20 = load ptr, ptr %t0
  %t21 = getelementptr inbounds %Cmp_Node, ptr %t20, i32 0, i32 1
  %t22 = load ptr, ptr %t21
  store ptr %t22, ptr %t19
  %t23 = load ptr, ptr %t14
  store ptr %t23, ptr %retval
  br label %ret
ifend5:
  %t24 = load ptr, ptr %t0
  %t25 = getelementptr inbounds %Cmp_Node, ptr %t24, i32 0, i32 0
  %t26 = load i32, ptr %t25
  %t27 = icmp eq i32 %t26, 37
  %t28 = zext i1 %t27 to i32
  %t29 = icmp ne i32 %t28, 0
  br i1 %t29, label %then6, label %ifend8
then6:
  %t30 = call ptr @fn_node(i32 37)
  store ptr %t30, ptr %t31
  %t32 = load ptr, ptr %t31
  %t33 = getelementptr inbounds %Cmp_Node, ptr %t32, i32 0, i32 1
  %t34 = load ptr, ptr %t0
  %t35 = getelementptr inbounds %Cmp_Node, ptr %t34, i32 0, i32 1
  %t36 = load ptr, ptr %t35
  store ptr %t36, ptr %t33
  %t37 = load ptr, ptr %t31
  %t38 = getelementptr inbounds %Cmp_Node, ptr %t37, i32 0, i32 4
  %t39 = load ptr, ptr %t0
  %t40 = getelementptr inbounds %Cmp_Node, ptr %t39, i32 0, i32 4
  %t41 = load ptr, ptr %t40
  %t42 = load ptr, ptr %t1
  %t43 = call ptr @fn_qualify_fields(ptr %t41, ptr %t42)
  store ptr %t43, ptr %t38
  %t44 = load ptr, ptr %t31
  %t45 = getelementptr inbounds %Cmp_Node, ptr %t44, i32 0, i32 5
  %t46 = load ptr, ptr %t0
  %t47 = getelementptr inbounds %Cmp_Node, ptr %t46, i32 0, i32 5
  %t48 = load ptr, ptr %t47
  %t49 = load ptr, ptr %t1
  %t50 = call ptr @fn_qualify_fields(ptr %t48, ptr %t49)
  store ptr %t50, ptr %t45
  %t51 = load ptr, ptr %t31
  store ptr %t51, ptr %retval
  br label %ret
ifend8:
  %t52 = load ptr, ptr %t0
  %t53 = getelementptr inbounds %Cmp_Node, ptr %t52, i32 0, i32 0
  %t54 = load i32, ptr %t53
  %t55 = icmp eq i32 %t54, 38
  %t56 = zext i1 %t55 to i32
  %t57 = icmp ne i32 %t56, 0
  br i1 %t57, label %then9, label %ifend11
then9:
  %t58 = call ptr @fn_node(i32 38)
  store ptr %t58, ptr %t59
  %t60 = load ptr, ptr %t59
  %t61 = getelementptr inbounds %Cmp_Node, ptr %t60, i32 0, i32 1
  %t62 = load ptr, ptr %t0
  %t63 = getelementptr inbounds %Cmp_Node, ptr %t62, i32 0, i32 1
  %t64 = load ptr, ptr %t63
  store ptr %t64, ptr %t61
  %t65 = load ptr, ptr %t59
  %t66 = getelementptr inbounds %Cmp_Node, ptr %t65, i32 0, i32 4
  %t67 = load ptr, ptr %t0
  %t68 = getelementptr inbounds %Cmp_Node, ptr %t67, i32 0, i32 4
  %t69 = load ptr, ptr %t68
  %t70 = load ptr, ptr %t1
  %t71 = call ptr @fn_qualify_fields(ptr %t69, ptr %t70)
  store ptr %t71, ptr %t66
  %t72 = load ptr, ptr %t59
  store ptr %t72, ptr %retval
  br label %ret
ifend11:
  %t73 = load ptr, ptr %t0
  store ptr %t73, ptr %retval
  br label %ret
ret:
  %t74 = load ptr, ptr %retval
  ret ptr %t74
}

define ptr @fn_parse_queries_anno() {
entry:
  %retval = alloca ptr
  %t1 = alloca ptr
  %t3 = alloca ptr
  %t4 = alloca ptr
  %t12 = alloca ptr
  %t21 = alloca ptr
  %t23 = alloca ptr
  %t50 = alloca ptr
  %t83 = alloca ptr
  %t85 = alloca ptr
  %t102 = alloca ptr
  %t104 = alloca ptr
  call void @fn_eat_op(ptr @.str187)
  %t0 = call ptr @fn_node(i32 21)
  store ptr %t0, ptr %t1
  %t2 = call ptr @fn_node(i32 7)
  store ptr %t2, ptr %t3
  store ptr null, ptr %t4
  br label %wcond0
wcond0:
  %t5 = call i32 @fn_is_op(ptr @.str188)
  %t6 = icmp eq i32 %t5, 0
  %t7 = zext i1 %t6 to i32
  %t8 = icmp ne i32 %t7, 0
  br i1 %t8, label %wbody1, label %wend2
wbody1:
  call void @fn_skipnl()
  %t9 = call i32 @fn_is_op(ptr @.str189)
  %t10 = icmp ne i32 %t9, 0
  br i1 %t10, label %then3, label %ifend5
then3:
  br label %wend2
ifend5:
  %t11 = call ptr @fn_eat_id()
  store ptr %t11, ptr %t12
  call void @fn_eat_op(ptr @.str190)
  %t13 = load ptr, ptr %t12
  %t14 = call i32 @fn_str_eq(ptr %t13, ptr @.str191)
  %t15 = icmp ne i32 %t14, 0
  br i1 %t15, label %then6, label %else7
then6:
  call void @fn_eat_op(ptr @.str192)
  call void @fn_skipnl()
  br label %wcond9
wcond9:
  %t16 = call i32 @fn_is_op(ptr @.str193)
  %t17 = icmp eq i32 %t16, 0
  %t18 = zext i1 %t17 to i32
  %t19 = icmp ne i32 %t18, 0
  br i1 %t19, label %wbody10, label %wend11
wbody10:
  %t20 = call ptr @fn_eat_id()
  store ptr %t20, ptr %t21
  %t22 = call ptr @fn_node(i32 33)
  store ptr %t22, ptr %t23
  %t24 = load ptr, ptr %t23
  %t25 = getelementptr inbounds %Cmp_Node, ptr %t24, i32 0, i32 1
  %t26 = load ptr, ptr %t21
  store ptr %t26, ptr %t25
  %t27 = load ptr, ptr %t1
  %t28 = getelementptr inbounds %Cmp_Node, ptr %t27, i32 0, i32 7
  %t29 = load ptr, ptr %t28
  %t30 = getelementptr inbounds %LSlice, ptr %t29, i32 0, i32 1
  %t31 = getelementptr inbounds %LSlice, ptr %t29, i32 0, i32 2
  %t32 = getelementptr inbounds %LSlice, ptr %t29, i32 0, i32 0
  %t33 = load i32, ptr %t30
  %t34 = load i32, ptr %t31
  %t35 = icmp sge i32 %t33, %t34
  br i1 %t35, label %grow12, label %put13
grow12:
  %t36 = mul i32 %t34, 2
  %t37 = icmp eq i32 %t34, 0
  %t38 = select i1 %t37, i32 8, i32 %t36
  %t39 = getelementptr ptr, ptr null, i32 1
  %t40 = ptrtoint ptr %t39 to i64
  %t41 = zext i32 %t38 to i64
  %t42 = mul i64 %t41, %t40
  %t43 = load ptr, ptr %t32
  %t44 = call ptr @realloc(ptr %t43, i64 %t42)
  store ptr %t44, ptr %t32
  store i32 %t38, ptr %t31
  br label %put13
put13:
  %t45 = load ptr, ptr %t23
  %t46 = load ptr, ptr %t32
  %t47 = getelementptr inbounds ptr, ptr %t46, i32 %t33
  store ptr %t45, ptr %t47
  %t48 = add i32 %t33, 1
  store i32 %t48, ptr %t30
  %t49 = call ptr @fn_node(i32 33)
  store ptr %t49, ptr %t50
  %t51 = load ptr, ptr %t50
  %t52 = getelementptr inbounds %Cmp_Node, ptr %t51, i32 0, i32 1
  %t53 = load ptr, ptr %t21
  store ptr %t53, ptr %t52
  %t54 = load ptr, ptr %t50
  %t55 = getelementptr inbounds %Cmp_Node, ptr %t54, i32 0, i32 2
  store i32 0, ptr %t55
  %t56 = load ptr, ptr %t3
  %t57 = getelementptr inbounds %Cmp_Node, ptr %t56, i32 0, i32 7
  %t58 = load ptr, ptr %t57
  %t59 = getelementptr inbounds %LSlice, ptr %t58, i32 0, i32 1
  %t60 = getelementptr inbounds %LSlice, ptr %t58, i32 0, i32 2
  %t61 = getelementptr inbounds %LSlice, ptr %t58, i32 0, i32 0
  %t62 = load i32, ptr %t59
  %t63 = load i32, ptr %t60
  %t64 = icmp sge i32 %t62, %t63
  br i1 %t64, label %grow14, label %put15
grow14:
  %t65 = mul i32 %t63, 2
  %t66 = icmp eq i32 %t63, 0
  %t67 = select i1 %t66, i32 8, i32 %t65
  %t68 = getelementptr ptr, ptr null, i32 1
  %t69 = ptrtoint ptr %t68 to i64
  %t70 = zext i32 %t67 to i64
  %t71 = mul i64 %t70, %t69
  %t72 = load ptr, ptr %t61
  %t73 = call ptr @realloc(ptr %t72, i64 %t71)
  store ptr %t73, ptr %t61
  store i32 %t67, ptr %t60
  br label %put15
put15:
  %t74 = load ptr, ptr %t50
  %t75 = load ptr, ptr %t61
  %t76 = getelementptr inbounds ptr, ptr %t75, i32 %t62
  store ptr %t74, ptr %t76
  %t77 = add i32 %t62, 1
  store i32 %t77, ptr %t59
  %t78 = call i32 @fn_is_op(ptr @.str194)
  %t79 = icmp ne i32 %t78, 0
  br i1 %t79, label %then16, label %ifend18
then16:
  %t80 = load i32, ptr @g_pi
  %t81 = add i32 %t80, 1
  store i32 %t81, ptr @g_pi
  %t82 = call ptr @fn_expr()
  store ptr %t82, ptr %t83
  call void @fn_eat_op(ptr @.str195)
  %t84 = call ptr @fn_node(i32 33)
  store ptr %t84, ptr %t85
  %t86 = load ptr, ptr %t85
  %t87 = getelementptr inbounds %Cmp_Node, ptr %t86, i32 0, i32 1
  %t88 = load ptr, ptr %t21
  store ptr %t88, ptr %t87
  %t89 = load ptr, ptr %t4
  %t90 = load ptr, ptr %t83
  %t91 = load ptr, ptr %t85
  %t92 = call ptr @fn_qualify_fields(ptr %t90, ptr %t91)
  %t93 = call ptr @fn_mk_and(ptr %t89, ptr %t92)
  store ptr %t93, ptr %t4
  br label %ifend18
ifend18:
  %t94 = call i32 @fn_is_op(ptr @.str196)
  %t95 = icmp ne i32 %t94, 0
  br i1 %t95, label %then19, label %ifend21
then19:
  %t96 = load i32, ptr @g_pi
  %t97 = add i32 %t96, 1
  store i32 %t97, ptr @g_pi
  br label %ifend21
ifend21:
  call void @fn_skipnl()
  br label %wcond9
wend11:
  call void @fn_eat_op(ptr @.str197)
  br label %ifend8
else7:
  %t98 = load ptr, ptr %t12
  %t99 = call i32 @fn_str_eq(ptr %t98, ptr @.str198)
  %t100 = icmp ne i32 %t99, 0
  br i1 %t100, label %then22, label %else23
then22:
  %t101 = call ptr @fn_eat_id()
  store ptr %t101, ptr %t102
  %t103 = call ptr @fn_node(i32 33)
  store ptr %t103, ptr %t104
  %t105 = load ptr, ptr %t104
  %t106 = getelementptr inbounds %Cmp_Node, ptr %t105, i32 0, i32 1
  %t107 = load ptr, ptr %t102
  store ptr %t107, ptr %t106
  %t108 = load ptr, ptr %t104
  %t109 = getelementptr inbounds %Cmp_Node, ptr %t108, i32 0, i32 2
  store i32 1, ptr %t109
  %t110 = load ptr, ptr %t3
  %t111 = getelementptr inbounds %Cmp_Node, ptr %t110, i32 0, i32 7
  %t112 = load ptr, ptr %t111
  %t113 = getelementptr inbounds %LSlice, ptr %t112, i32 0, i32 1
  %t114 = getelementptr inbounds %LSlice, ptr %t112, i32 0, i32 2
  %t115 = getelementptr inbounds %LSlice, ptr %t112, i32 0, i32 0
  %t116 = load i32, ptr %t113
  %t117 = load i32, ptr %t114
  %t118 = icmp sge i32 %t116, %t117
  br i1 %t118, label %grow25, label %put26
grow25:
  %t119 = mul i32 %t117, 2
  %t120 = icmp eq i32 %t117, 0
  %t121 = select i1 %t120, i32 8, i32 %t119
  %t122 = getelementptr ptr, ptr null, i32 1
  %t123 = ptrtoint ptr %t122 to i64
  %t124 = zext i32 %t121 to i64
  %t125 = mul i64 %t124, %t123
  %t126 = load ptr, ptr %t115
  %t127 = call ptr @realloc(ptr %t126, i64 %t125)
  store ptr %t127, ptr %t115
  store i32 %t121, ptr %t114
  br label %put26
put26:
  %t128 = load ptr, ptr %t104
  %t129 = load ptr, ptr %t115
  %t130 = getelementptr inbounds ptr, ptr %t129, i32 %t116
  store ptr %t128, ptr %t130
  %t131 = add i32 %t116, 1
  store i32 %t131, ptr %t113
  br label %ifend24
else23:
  %t132 = call ptr @fn_expr()
  br label %ifend24
ifend24:
  br label %ifend8
ifend8:
  %t133 = call i32 @fn_is_op(ptr @.str199)
  %t134 = icmp ne i32 %t133, 0
  br i1 %t134, label %then27, label %ifend29
then27:
  %t135 = load i32, ptr @g_pi
  %t136 = add i32 %t135, 1
  store i32 %t136, ptr @g_pi
  br label %ifend29
ifend29:
  call void @fn_skipnl()
  br label %wcond0
wend2:
  call void @fn_eat_op(ptr @.str200)
  %t137 = load ptr, ptr %t1
  %t138 = getelementptr inbounds %Cmp_Node, ptr %t137, i32 0, i32 6
  %t139 = load ptr, ptr %t3
  store ptr %t139, ptr %t138
  %t140 = load ptr, ptr %t1
  %t141 = getelementptr inbounds %Cmp_Node, ptr %t140, i32 0, i32 5
  %t142 = load ptr, ptr %t4
  store ptr %t142, ptr %t141
  %t143 = load ptr, ptr %t1
  store ptr %t143, ptr %retval
  br label %ret
ret:
  %t144 = load ptr, ptr %retval
  ret ptr %t144
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
  %t5 = getelementptr inbounds %Cmp_Node, ptr %t4, i32 0, i32 1
  %t6 = call ptr @fn_eat_id()
  store ptr %t6, ptr %t5
  call void @fn_skipnl()
  call void @fn_eat_op(ptr @.str201)
  br label %wcond0
wcond0:
  %t7 = icmp ne i32 1, 0
  br i1 %t7, label %wbody1, label %wend2
wbody1:
  call void @fn_skipnl()
  %t8 = call i32 @fn_is_op(ptr @.str202)
  %t9 = icmp ne i32 %t8, 0
  br i1 %t9, label %then3, label %ifend5
then3:
  br label %wend2
ifend5:
  %t10 = call ptr @fn_node(i32 42)
  store ptr %t10, ptr %t11
  %t12 = load ptr, ptr %t11
  %t13 = getelementptr inbounds %Cmp_Node, ptr %t12, i32 0, i32 1
  %t14 = call ptr @fn_eat_id()
  store ptr %t14, ptr %t13
  %t15 = load ptr, ptr %t11
  %t16 = getelementptr inbounds %Cmp_Node, ptr %t15, i32 0, i32 4
  %t17 = call ptr @fn_record()
  store ptr %t17, ptr %t16
  %t18 = load ptr, ptr %t3
  %t19 = getelementptr inbounds %Cmp_Node, ptr %t18, i32 0, i32 7
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
  %t40 = call i32 @fn_is_op(ptr @.str203)
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
  call void @fn_eat_op(ptr @.str204)
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
  %t5 = getelementptr inbounds %Cmp_Node, ptr %t4, i32 0, i32 1
  %t6 = call ptr @fn_eat_id()
  store ptr %t6, ptr %t5
  call void @fn_skipnl()
  call void @fn_eat_op(ptr @.str205)
  br label %wcond0
wcond0:
  %t7 = icmp ne i32 1, 0
  br i1 %t7, label %wbody1, label %wend2
wbody1:
  call void @fn_skipnl()
  %t8 = call i32 @fn_is_op(ptr @.str206)
  %t9 = icmp ne i32 %t8, 0
  br i1 %t9, label %then3, label %ifend5
then3:
  br label %wend2
ifend5:
  %t10 = call ptr @fn_node(i32 33)
  store ptr %t10, ptr %t11
  %t12 = load ptr, ptr %t11
  %t13 = getelementptr inbounds %Cmp_Node, ptr %t12, i32 0, i32 1
  %t14 = call ptr @fn_eat_id()
  store ptr %t14, ptr %t13
  %t15 = load ptr, ptr %t3
  %t16 = getelementptr inbounds %Cmp_Node, ptr %t15, i32 0, i32 7
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
  %t37 = call i32 @fn_is_op(ptr @.str207)
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
  call void @fn_eat_op(ptr @.str208)
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
  %t5 = getelementptr inbounds %Cmp_Node, ptr %t4, i32 0, i32 1
  %t6 = call ptr @fn_eat_id()
  store ptr %t6, ptr %t5
  call void @fn_skipnl()
  call void @fn_eat_op(ptr @.str209)
  br label %wcond0
wcond0:
  %t7 = icmp ne i32 1, 0
  br i1 %t7, label %wbody1, label %wend2
wbody1:
  call void @fn_skipnl()
  %t8 = call i32 @fn_is_op(ptr @.str210)
  %t9 = icmp ne i32 %t8, 0
  br i1 %t9, label %then3, label %ifend5
then3:
  br label %wend2
ifend5:
  %t10 = call ptr @fn_node(i32 33)
  store ptr %t10, ptr %t11
  %t12 = load ptr, ptr %t11
  %t13 = getelementptr inbounds %Cmp_Node, ptr %t12, i32 0, i32 1
  %t14 = call ptr @fn_eat_id()
  store ptr %t14, ptr %t13
  %t15 = load ptr, ptr %t3
  %t16 = getelementptr inbounds %Cmp_Node, ptr %t15, i32 0, i32 7
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
  %t37 = call i32 @fn_is_op(ptr @.str211)
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
  call void @fn_eat_op(ptr @.str212)
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
  %t7 = getelementptr inbounds %Cmp_Node, ptr %t6, i32 0, i32 1
  %t8 = call ptr @fn_eat_id()
  store ptr %t8, ptr %t7
  call void @fn_eat_op(ptr @.str213)
  br label %wcond0
wcond0:
  %t9 = call i32 @fn_is_op(ptr @.str214)
  %t10 = icmp eq i32 %t9, 0
  %t11 = zext i1 %t10 to i32
  %t12 = icmp ne i32 %t11, 0
  br i1 %t12, label %wbody1, label %wend2
wbody1:
  %t13 = call ptr @fn_node(i32 5)
  store ptr %t13, ptr %t14
  %t15 = load ptr, ptr %t14
  %t16 = getelementptr inbounds %Cmp_Node, ptr %t15, i32 0, i32 1
  %t17 = call ptr @fn_eat_id()
  store ptr %t17, ptr %t16
  call void @fn_eat_op(ptr @.str215)
  %t18 = load ptr, ptr %t14
  %t19 = getelementptr inbounds %Cmp_Node, ptr %t18, i32 0, i32 3
  %t20 = call ptr @fn_ptype()
  store ptr %t20, ptr %t19
  %t21 = load ptr, ptr %t5
  %t22 = getelementptr inbounds %Cmp_Node, ptr %t21, i32 0, i32 7
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
  %t43 = call i32 @fn_is_op(ptr @.str216)
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
  call void @fn_eat_op(ptr @.str217)
  %t47 = load ptr, ptr %t5
  %t48 = getelementptr inbounds %Cmp_Node, ptr %t47, i32 0, i32 3
  store ptr @.str218, ptr %t48
  %t49 = call i32 @fn_is_op(ptr @.str219)
  %t50 = icmp ne i32 %t49, 0
  br i1 %t50, label %then8, label %ifend10
then8:
  %t51 = load i32, ptr @g_pi
  %t52 = add i32 %t51, 1
  store i32 %t52, ptr @g_pi
  %t53 = load ptr, ptr %t5
  %t54 = getelementptr inbounds %Cmp_Node, ptr %t53, i32 0, i32 3
  %t55 = call ptr @fn_ptype()
  store ptr %t55, ptr %t54
  br label %ifend10
ifend10:
  call void @fn_eat_op(ptr @.str220)
  %t56 = load ptr, ptr @g_toks
  %t57 = getelementptr inbounds %LSlice, ptr %t56, i32 0, i32 0
  %t58 = load ptr, ptr %t57
  %t59 = load i32, ptr @g_pi
  %t60 = getelementptr inbounds ptr, ptr %t58, i32 %t59
  %t61 = load ptr, ptr %t60
  store ptr %t61, ptr %t62
  %t63 = load ptr, ptr %t5
  %t64 = getelementptr inbounds %Cmp_Node, ptr %t63, i32 0, i32 4
  %t65 = call ptr @fn_node(i32 31)
  store ptr %t65, ptr %t64
  %t66 = load ptr, ptr %t5
  %t67 = getelementptr inbounds %Cmp_Node, ptr %t66, i32 0, i32 4
  %t68 = load ptr, ptr %t67
  %t69 = getelementptr inbounds %Cmp_Node, ptr %t68, i32 0, i32 1
  %t70 = load ptr, ptr %t62
  %t71 = getelementptr inbounds %Cmp_Tok, ptr %t70, i32 0, i32 1
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
  %t3 = getelementptr inbounds %Cmp_Node, ptr %t2, i32 0, i32 1
  %t4 = call ptr @fn_eat_id()
  store ptr %t4, ptr %t3
  %t5 = load ptr, ptr %t1
  %t6 = getelementptr inbounds %Cmp_Node, ptr %t5, i32 0, i32 5
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
  %t16 = getelementptr inbounds %Cmp_Tok, ptr %t15, i32 0, i32 0
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
  %t29 = getelementptr inbounds %Cmp_Tok, ptr %t28, i32 0, i32 0
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
  %t45 = getelementptr inbounds %Cmp_Tok, ptr %t44, i32 0, i32 1
  %t46 = load ptr, ptr %t45
  %t47 = call i32 @fn_str_eq(ptr %t46, ptr @.str221)
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
  %t55 = getelementptr inbounds %Cmp_Node, ptr %t54, i32 0, i32 1
  %t56 = call ptr @fn_eat_id()
  store ptr %t56, ptr %t55
  call void @fn_eat_op(ptr @.str222)
  %t57 = load ptr, ptr %t53
  %t58 = getelementptr inbounds %Cmp_Node, ptr %t57, i32 0, i32 4
  %t59 = call ptr @fn_expr()
  store ptr %t59, ptr %t58
  %t60 = load ptr, ptr %t1
  %t61 = getelementptr inbounds %Cmp_Node, ptr %t60, i32 0, i32 5
  %t62 = load ptr, ptr %t61
  %t63 = getelementptr inbounds %Cmp_Node, ptr %t62, i32 0, i32 7
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
  %t84 = call i32 @fn_is_op(ptr @.str223)
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
  %t89 = call i32 @fn_is_op(ptr @.str224)
  %t90 = icmp ne i32 %t89, 0
  br i1 %t90, label %then15, label %ifend17
then15:
  br label %wend14
ifend17:
  %t91 = load ptr, ptr %t1
  %t92 = getelementptr inbounds %Cmp_Node, ptr %t91, i32 0, i32 7
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
  call void @fn_eat_op(ptr @.str225)
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
  %t5 = getelementptr inbounds %Cmp_Node, ptr %t4, i32 0, i32 1
  %t6 = call ptr @fn_eat_id()
  store ptr %t6, ptr %t5
  %t7 = load ptr, ptr %t3
  %t8 = getelementptr inbounds %Cmp_Node, ptr %t7, i32 0, i32 2
  store i32 1, ptr %t8
  call void @fn_skipnl()
  call void @fn_eat_op(ptr @.str226)
  call void @fn_skipnl()
  %t9 = load ptr, ptr %t3
  %t10 = getelementptr inbounds %Cmp_Node, ptr %t9, i32 0, i32 4
  %t11 = call ptr @fn_parse_widget()
  store ptr %t11, ptr %t10
  call void @fn_skipnl()
  call void @fn_eat_op(ptr @.str227)
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
  %t2 = getelementptr %Cmp_Val, ptr null, i32 1
  %t3 = ptrtoint ptr %t2 to i64
  %t4 = call ptr @malloc(i64 %t3)
  %t5 = getelementptr inbounds %Cmp_Val, ptr %t4, i32 0, i32 0
  store ptr null, ptr %t5
  %t6 = getelementptr inbounds %Cmp_Val, ptr %t4, i32 0, i32 1
  store ptr null, ptr %t6
  store ptr %t4, ptr %t7
  %t8 = load ptr, ptr %t7
  %t9 = getelementptr inbounds %Cmp_Val, ptr %t8, i32 0, i32 0
  %t10 = load ptr, ptr %t0
  store ptr %t10, ptr %t9
  %t11 = load ptr, ptr %t7
  %t12 = getelementptr inbounds %Cmp_Val, ptr %t11, i32 0, i32 1
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
  %t3 = call ptr @fn_str_concat(ptr @.str228, ptr %t2)
  store ptr %t3, ptr %t4
  %t5 = load i32, ptr @g_ll_t
  %t6 = add i32 %t5, 1
  store i32 %t6, ptr @g_ll_t
  %t7 = load ptr, ptr @g_falloc
  call void @fn_buf_puts(ptr %t7, ptr @.str229)
  %t8 = load ptr, ptr @g_falloc
  %t9 = load ptr, ptr %t4
  call void @fn_buf_puts(ptr %t8, ptr %t9)
  %t10 = load ptr, ptr @g_falloc
  call void @fn_buf_puts(ptr %t10, ptr @.str230)
  %t11 = load ptr, ptr @g_falloc
  %t12 = load ptr, ptr %t0
  call void @fn_buf_puts(ptr %t11, ptr %t12)
  %t13 = load ptr, ptr @g_falloc
  call void @fn_buf_puts(ptr %t13, ptr @.str231)
  %t14 = load ptr, ptr %t4
  store ptr %t14, ptr %retval
  br label %ret
ret:
  %t15 = load ptr, ptr %retval
  ret ptr %t15
}

define ptr @fn_nreg() {
entry:
  %retval = alloca ptr
  %t3 = alloca ptr
  %t0 = load i32, ptr @g_ll_t
  %t1 = call ptr @fn_itoa(i32 %t0)
  %t2 = call ptr @fn_str_concat(ptr @.str232, ptr %t1)
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
  %t4 = call ptr @fn_str_concat(ptr %t1, ptr %t3)
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
  %t4 = call i32 @fn_str_eq(ptr %t3, ptr @.str233)
  %t5 = icmp ne i32 %t4, 0
  %t6 = zext i1 %t5 to i32
  store i32 %t6, ptr %t2
  br i1 %t5, label %scend1, label %sc0
sc0:
  %t7 = load ptr, ptr %t0
  %t8 = call i32 @fn_str_eq(ptr %t7, ptr @.str234)
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
  %t15 = call i32 @fn_str_eq(ptr %t14, ptr @.str235)
  %t16 = icmp ne i32 %t15, 0
  %t17 = zext i1 %t16 to i32
  store i32 %t17, ptr %t1
  br label %scend3
scend3:
  %t18 = load i32, ptr %t1
  %t19 = icmp ne i32 %t18, 0
  br i1 %t19, label %then4, label %ifend6
then4:
  store ptr @.str236, ptr %retval
  br label %ret
ifend6:
  %t20 = load ptr, ptr %t0
  %t21 = call i32 @fn_str_eq(ptr %t20, ptr @.str237)
  %t22 = icmp ne i32 %t21, 0
  br i1 %t22, label %then7, label %ifend9
then7:
  store ptr @.str238, ptr %retval
  br label %ret
ifend9:
  store ptr @.str239, ptr %retval
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
  %t18 = getelementptr inbounds %Cmp_Node, ptr %t17, i32 0, i32 0
  %t19 = load i32, ptr %t18
  %t20 = icmp eq i32 %t19, 10
  %t21 = zext i1 %t20 to i32
  %t22 = icmp ne i32 %t21, 0
  %t23 = zext i1 %t22 to i32
  store i32 %t23, ptr %t16
  br i1 %t22, label %sc3, label %scend4
sc3:
  %t24 = load ptr, ptr %t15
  %t25 = getelementptr inbounds %Cmp_Node, ptr %t24, i32 0, i32 1
  %t26 = load ptr, ptr %t25
  %t27 = load ptr, ptr %t0
  %t28 = call i32 @fn_str_eq(ptr %t26, ptr %t27)
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
  %t18 = getelementptr inbounds %Cmp_Node, ptr %t17, i32 0, i32 0
  %t19 = load i32, ptr %t18
  %t20 = icmp eq i32 %t19, 8
  %t21 = zext i1 %t20 to i32
  %t22 = icmp ne i32 %t21, 0
  %t23 = zext i1 %t22 to i32
  store i32 %t23, ptr %t16
  br i1 %t22, label %sc3, label %scend4
sc3:
  %t24 = load ptr, ptr %t15
  %t25 = getelementptr inbounds %Cmp_Node, ptr %t24, i32 0, i32 1
  %t26 = load ptr, ptr %t25
  %t27 = load ptr, ptr %t0
  %t28 = call i32 @fn_str_eq(ptr %t26, ptr %t27)
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
  store ptr %arg_name, ptr %t0
  %t1 = load ptr, ptr %t0
  %t2 = call ptr @fn_find_comp(ptr %t1)
  store ptr %t2, ptr %retval
  br label %ret
ret:
  %t3 = load ptr, ptr %retval
  ret ptr %t3
}

define ptr @fn_layout_ty(ptr %arg_name) {
entry:
  %retval = alloca ptr
  %t0 = alloca ptr
  store ptr %arg_name, ptr %t0
  %t1 = load ptr, ptr %t0
  %t2 = call ptr @fn_str_concat(ptr @.str240, ptr %t1)
  store ptr %t2, ptr %retval
  br label %ret
ret:
  %t3 = load ptr, ptr %retval
  ret ptr %t3
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
  %t5 = getelementptr inbounds %Cmp_Node, ptr %t4, i32 0, i32 7
  %t6 = load ptr, ptr %t5
  %t7 = getelementptr inbounds %LSlice, ptr %t6, i32 0, i32 1
  %t8 = load i32, ptr %t7
  %t9 = icmp slt i32 %t3, %t8
  %t10 = zext i1 %t9 to i32
  %t11 = icmp ne i32 %t10, 0
  br i1 %t11, label %wbody1, label %wend2
wbody1:
  %t12 = load ptr, ptr %t0
  %t13 = getelementptr inbounds %Cmp_Node, ptr %t12, i32 0, i32 7
  %t14 = load ptr, ptr %t13
  %t15 = getelementptr inbounds %LSlice, ptr %t14, i32 0, i32 0
  %t16 = load ptr, ptr %t15
  %t17 = load i32, ptr %t2
  %t18 = getelementptr inbounds ptr, ptr %t16, i32 %t17
  %t19 = load ptr, ptr %t18
  %t20 = getelementptr inbounds %Cmp_Node, ptr %t19, i32 0, i32 1
  %t21 = load ptr, ptr %t20
  %t22 = load ptr, ptr %t1
  %t23 = call i32 @fn_str_eq(ptr %t21, ptr %t22)
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
  %t5 = getelementptr inbounds %Cmp_Node, ptr %t4, i32 0, i32 7
  %t6 = load ptr, ptr %t5
  %t7 = getelementptr inbounds %LSlice, ptr %t6, i32 0, i32 1
  %t8 = load i32, ptr %t7
  %t9 = icmp slt i32 %t3, %t8
  %t10 = zext i1 %t9 to i32
  %t11 = icmp ne i32 %t10, 0
  br i1 %t11, label %wbody1, label %wend2
wbody1:
  %t12 = load ptr, ptr %t0
  %t13 = getelementptr inbounds %Cmp_Node, ptr %t12, i32 0, i32 7
  %t14 = load ptr, ptr %t13
  %t15 = getelementptr inbounds %LSlice, ptr %t14, i32 0, i32 0
  %t16 = load ptr, ptr %t15
  %t17 = load i32, ptr %t2
  %t18 = getelementptr inbounds ptr, ptr %t16, i32 %t17
  %t19 = load ptr, ptr %t18
  %t20 = getelementptr inbounds %Cmp_Node, ptr %t19, i32 0, i32 1
  %t21 = load ptr, ptr %t20
  %t22 = load ptr, ptr %t1
  %t23 = call i32 @fn_str_eq(ptr %t21, ptr %t22)
  %t24 = icmp ne i32 %t23, 0
  br i1 %t24, label %then3, label %ifend5
then3:
  %t25 = load ptr, ptr %t0
  %t26 = getelementptr inbounds %Cmp_Node, ptr %t25, i32 0, i32 7
  %t27 = load ptr, ptr %t26
  %t28 = getelementptr inbounds %LSlice, ptr %t27, i32 0, i32 0
  %t29 = load ptr, ptr %t28
  %t30 = load i32, ptr %t2
  %t31 = getelementptr inbounds ptr, ptr %t29, i32 %t30
  %t32 = load ptr, ptr %t31
  %t33 = getelementptr inbounds %Cmp_Node, ptr %t32, i32 0, i32 3
  %t34 = load ptr, ptr %t33
  store ptr %t34, ptr %retval
  br label %ret
ifend5:
  %t35 = load i32, ptr %t2
  %t36 = add i32 %t35, 1
  store i32 %t36, ptr %t2
  br label %wcond0
wend2:
  store ptr @.str241, ptr %retval
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
  %t18 = getelementptr inbounds %Cmp_Node, ptr %t17, i32 0, i32 0
  %t19 = load i32, ptr %t18
  %t20 = icmp eq i32 %t19, 2
  %t21 = zext i1 %t20 to i32
  %t22 = icmp ne i32 %t21, 0
  %t23 = zext i1 %t22 to i32
  store i32 %t23, ptr %t16
  br i1 %t22, label %sc3, label %scend4
sc3:
  %t24 = load ptr, ptr %t15
  %t25 = getelementptr inbounds %Cmp_Node, ptr %t24, i32 0, i32 1
  %t26 = load ptr, ptr %t25
  %t27 = load ptr, ptr %t0
  %t28 = call i32 @fn_str_eq(ptr %t26, ptr %t27)
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
  %t36 = getelementptr inbounds %Cmp_Node, ptr %t35, i32 0, i32 0
  %t37 = load i32, ptr %t36
  %t38 = icmp eq i32 %t37, 3
  %t39 = zext i1 %t38 to i32
  %t40 = icmp ne i32 %t39, 0
  %t41 = zext i1 %t40 to i32
  store i32 %t41, ptr %t34
  br i1 %t40, label %sc8, label %scend9
sc8:
  %t42 = load ptr, ptr %t15
  %t43 = getelementptr inbounds %Cmp_Node, ptr %t42, i32 0, i32 1
  %t44 = load ptr, ptr %t43
  %t45 = load ptr, ptr %t0
  %t46 = call i32 @fn_str_eq(ptr %t44, ptr %t45)
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
  %t19 = getelementptr inbounds %Cmp_Node, ptr %t18, i32 0, i32 0
  %t20 = load i32, ptr %t19
  %t21 = icmp eq i32 %t20, 27
  %t22 = zext i1 %t21 to i32
  %t23 = icmp ne i32 %t22, 0
  %t24 = zext i1 %t23 to i32
  store i32 %t24, ptr %t17
  br i1 %t23, label %sc3, label %scend4
sc3:
  %t25 = load ptr, ptr %t16
  %t26 = getelementptr inbounds %Cmp_Node, ptr %t25, i32 0, i32 1
  %t27 = load ptr, ptr %t26
  %t28 = load ptr, ptr %t0
  %t29 = call i32 @fn_str_eq(ptr %t27, ptr %t28)
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
  %t37 = getelementptr inbounds %Cmp_Node, ptr %t36, i32 0, i32 7
  %t38 = load ptr, ptr %t37
  %t39 = getelementptr inbounds %LSlice, ptr %t38, i32 0, i32 1
  %t40 = load i32, ptr %t39
  %t41 = icmp slt i32 %t35, %t40
  %t42 = zext i1 %t41 to i32
  %t43 = icmp ne i32 %t42, 0
  br i1 %t43, label %wbody9, label %wend10
wbody9:
  %t44 = load ptr, ptr %t16
  %t45 = getelementptr inbounds %Cmp_Node, ptr %t44, i32 0, i32 7
  %t46 = load ptr, ptr %t45
  %t47 = getelementptr inbounds %LSlice, ptr %t46, i32 0, i32 0
  %t48 = load ptr, ptr %t47
  %t49 = load i32, ptr %t34
  %t50 = getelementptr inbounds ptr, ptr %t48, i32 %t49
  %t51 = load ptr, ptr %t50
  %t52 = getelementptr inbounds %Cmp_Node, ptr %t51, i32 0, i32 1
  %t53 = load ptr, ptr %t52
  %t54 = load ptr, ptr %t1
  %t55 = call i32 @fn_str_eq(ptr %t53, ptr %t54)
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
  %t18 = getelementptr inbounds %Cmp_Node, ptr %t17, i32 0, i32 0
  %t19 = load i32, ptr %t18
  %t20 = icmp eq i32 %t19, 4
  %t21 = zext i1 %t20 to i32
  %t22 = icmp ne i32 %t21, 0
  %t23 = zext i1 %t22 to i32
  store i32 %t23, ptr %t16
  br i1 %t22, label %sc3, label %scend4
sc3:
  %t24 = load ptr, ptr %t15
  %t25 = getelementptr inbounds %Cmp_Node, ptr %t24, i32 0, i32 1
  %t26 = load ptr, ptr %t25
  %t27 = load ptr, ptr %t0
  %t28 = call i32 @fn_str_eq(ptr %t26, ptr %t27)
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

define void @fn_register_computed(ptr %arg_prop, ptr %arg_field, ptr %arg_ty, ptr %arg_e) {
entry:
  %t0 = alloca ptr
  %t1 = alloca ptr
  %t2 = alloca ptr
  %t3 = alloca ptr
  %t5 = alloca ptr
  store ptr %arg_prop, ptr %t0
  store ptr %arg_field, ptr %t1
  store ptr %arg_ty, ptr %t2
  store ptr %arg_e, ptr %t3
  %t4 = call ptr @fn_node(i32 1)
  store ptr %t4, ptr %t5
  %t6 = load ptr, ptr %t5
  %t7 = getelementptr inbounds %Cmp_Node, ptr %t6, i32 0, i32 1
  %t8 = load ptr, ptr %t0
  %t9 = load ptr, ptr %t1
  %t10 = call ptr @fn_str_concat(ptr @.str242, ptr %t9)
  %t11 = call ptr @fn_str_concat(ptr %t8, ptr %t10)
  store ptr %t11, ptr %t7
  %t12 = load ptr, ptr %t5
  %t13 = getelementptr inbounds %Cmp_Node, ptr %t12, i32 0, i32 3
  %t14 = load ptr, ptr %t2
  store ptr %t14, ptr %t13
  %t15 = load ptr, ptr %t5
  %t16 = getelementptr inbounds %Cmp_Node, ptr %t15, i32 0, i32 4
  %t17 = load ptr, ptr %t3
  store ptr %t17, ptr %t16
  %t18 = load ptr, ptr @g_g_computed
  %t19 = getelementptr inbounds %LSlice, ptr %t18, i32 0, i32 1
  %t20 = getelementptr inbounds %LSlice, ptr %t18, i32 0, i32 2
  %t21 = getelementptr inbounds %LSlice, ptr %t18, i32 0, i32 0
  %t22 = load i32, ptr %t19
  %t23 = load i32, ptr %t20
  %t24 = icmp sge i32 %t22, %t23
  br i1 %t24, label %grow0, label %put1
grow0:
  %t25 = mul i32 %t23, 2
  %t26 = icmp eq i32 %t23, 0
  %t27 = select i1 %t26, i32 8, i32 %t25
  %t28 = getelementptr ptr, ptr null, i32 1
  %t29 = ptrtoint ptr %t28 to i64
  %t30 = zext i32 %t27 to i64
  %t31 = mul i64 %t30, %t29
  %t32 = load ptr, ptr %t21
  %t33 = call ptr @realloc(ptr %t32, i64 %t31)
  store ptr %t33, ptr %t21
  store i32 %t27, ptr %t20
  br label %put1
put1:
  %t34 = load ptr, ptr %t5
  %t35 = load ptr, ptr %t21
  %t36 = getelementptr inbounds ptr, ptr %t35, i32 %t22
  store ptr %t34, ptr %t36
  %t37 = add i32 %t22, 1
  store i32 %t37, ptr %t19
  br label %ret
ret:
  ret void
}

define ptr @fn_computed_expr(ptr %arg_prop, ptr %arg_field) {
entry:
  %retval = alloca ptr
  %t0 = alloca ptr
  %t1 = alloca ptr
  %t10 = alloca ptr
  %t11 = alloca i32
  store ptr %arg_prop, ptr %t0
  store ptr %arg_field, ptr %t1
  %t2 = load ptr, ptr %t0
  %t3 = icmp eq ptr %t2, null
  %t4 = zext i1 %t3 to i32
  %t5 = icmp ne i32 %t4, 0
  br i1 %t5, label %then0, label %ifend2
then0:
  store ptr null, ptr %retval
  br label %ret
ifend2:
  %t6 = load ptr, ptr %t0
  %t7 = load ptr, ptr %t1
  %t8 = call ptr @fn_str_concat(ptr @.str243, ptr %t7)
  %t9 = call ptr @fn_str_concat(ptr %t6, ptr %t8)
  store ptr %t9, ptr %t10
  store i32 0, ptr %t11
  br label %wcond3
wcond3:
  %t12 = load i32, ptr %t11
  %t13 = load ptr, ptr @g_g_computed
  %t14 = getelementptr inbounds %LSlice, ptr %t13, i32 0, i32 1
  %t15 = load i32, ptr %t14
  %t16 = icmp slt i32 %t12, %t15
  %t17 = zext i1 %t16 to i32
  %t18 = icmp ne i32 %t17, 0
  br i1 %t18, label %wbody4, label %wend5
wbody4:
  %t19 = load ptr, ptr @g_g_computed
  %t20 = getelementptr inbounds %LSlice, ptr %t19, i32 0, i32 0
  %t21 = load ptr, ptr %t20
  %t22 = load i32, ptr %t11
  %t23 = getelementptr inbounds ptr, ptr %t21, i32 %t22
  %t24 = load ptr, ptr %t23
  %t25 = getelementptr inbounds %Cmp_Node, ptr %t24, i32 0, i32 1
  %t26 = load ptr, ptr %t25
  %t27 = load ptr, ptr %t10
  %t28 = call i32 @fn_str_eq(ptr %t26, ptr %t27)
  %t29 = icmp ne i32 %t28, 0
  br i1 %t29, label %then6, label %ifend8
then6:
  %t30 = load ptr, ptr @g_g_computed
  %t31 = getelementptr inbounds %LSlice, ptr %t30, i32 0, i32 0
  %t32 = load ptr, ptr %t31
  %t33 = load i32, ptr %t11
  %t34 = getelementptr inbounds ptr, ptr %t32, i32 %t33
  %t35 = load ptr, ptr %t34
  %t36 = getelementptr inbounds %Cmp_Node, ptr %t35, i32 0, i32 4
  %t37 = load ptr, ptr %t36
  store ptr %t37, ptr %retval
  br label %ret
ifend8:
  %t38 = load i32, ptr %t11
  %t39 = add i32 %t38, 1
  store i32 %t39, ptr %t11
  br label %wcond3
wend5:
  store ptr null, ptr %retval
  br label %ret
ret:
  %t40 = load ptr, ptr %retval
  ret ptr %t40
}

define ptr @fn_static_type(ptr %arg_e) {
entry:
  %retval = alloca ptr
  %t0 = alloca ptr
  %t11 = alloca i32
  store ptr %arg_e, ptr %t0
  %t1 = load ptr, ptr %t0
  %t2 = getelementptr inbounds %Cmp_Node, ptr %t1, i32 0, i32 0
  %t3 = load i32, ptr %t2
  %t4 = icmp eq i32 %t3, 33
  %t5 = zext i1 %t4 to i32
  %t6 = icmp ne i32 %t5, 0
  br i1 %t6, label %then0, label %ifend2
then0:
  %t7 = load ptr, ptr %t0
  %t8 = getelementptr inbounds %Cmp_Node, ptr %t7, i32 0, i32 1
  %t9 = load ptr, ptr %t8
  %t10 = call i32 @fn_loc_find(ptr %t9)
  store i32 %t10, ptr %t11
  %t12 = load i32, ptr %t11
  %t13 = icmp sge i32 %t12, 0
  %t14 = zext i1 %t13 to i32
  %t15 = icmp ne i32 %t14, 0
  br i1 %t15, label %then3, label %ifend5
then3:
  %t16 = load ptr, ptr @g_loc_ty
  %t17 = getelementptr inbounds %LSlice, ptr %t16, i32 0, i32 0
  %t18 = load ptr, ptr %t17
  %t19 = load i32, ptr %t11
  %t20 = getelementptr inbounds ptr, ptr %t18, i32 %t19
  %t21 = load ptr, ptr %t20
  store ptr %t21, ptr %retval
  br label %ret
ifend5:
  br label %ifend2
ifend2:
  store ptr null, ptr %retval
  br label %ret
ret:
  %t22 = load ptr, ptr %retval
  ret ptr %t22
}

define void @fn_register_onspawn(ptr %arg_model, ptr %arg_body) {
entry:
  %t0 = alloca ptr
  %t1 = alloca ptr
  %t3 = alloca ptr
  store ptr %arg_model, ptr %t0
  store ptr %arg_body, ptr %t1
  %t2 = call ptr @fn_node(i32 7)
  store ptr %t2, ptr %t3
  %t4 = load ptr, ptr %t3
  %t5 = getelementptr inbounds %Cmp_Node, ptr %t4, i32 0, i32 1
  %t6 = load ptr, ptr %t0
  store ptr %t6, ptr %t5
  %t7 = load ptr, ptr %t3
  %t8 = getelementptr inbounds %Cmp_Node, ptr %t7, i32 0, i32 4
  %t9 = load ptr, ptr %t1
  store ptr %t9, ptr %t8
  %t10 = load ptr, ptr @g_g_onspawn
  %t11 = getelementptr inbounds %LSlice, ptr %t10, i32 0, i32 1
  %t12 = getelementptr inbounds %LSlice, ptr %t10, i32 0, i32 2
  %t13 = getelementptr inbounds %LSlice, ptr %t10, i32 0, i32 0
  %t14 = load i32, ptr %t11
  %t15 = load i32, ptr %t12
  %t16 = icmp sge i32 %t14, %t15
  br i1 %t16, label %grow0, label %put1
grow0:
  %t17 = mul i32 %t15, 2
  %t18 = icmp eq i32 %t15, 0
  %t19 = select i1 %t18, i32 8, i32 %t17
  %t20 = getelementptr ptr, ptr null, i32 1
  %t21 = ptrtoint ptr %t20 to i64
  %t22 = zext i32 %t19 to i64
  %t23 = mul i64 %t22, %t21
  %t24 = load ptr, ptr %t13
  %t25 = call ptr @realloc(ptr %t24, i64 %t23)
  store ptr %t25, ptr %t13
  store i32 %t19, ptr %t12
  br label %put1
put1:
  %t26 = load ptr, ptr %t3
  %t27 = load ptr, ptr %t13
  %t28 = getelementptr inbounds ptr, ptr %t27, i32 %t14
  store ptr %t26, ptr %t28
  %t29 = add i32 %t14, 1
  store i32 %t29, ptr %t11
  br label %ret
ret:
  ret void
}

define ptr @fn_onspawn_body(ptr %arg_model) {
entry:
  %retval = alloca ptr
  %t0 = alloca ptr
  %t1 = alloca i32
  store ptr %arg_model, ptr %t0
  store i32 0, ptr %t1
  br label %wcond0
wcond0:
  %t2 = load i32, ptr %t1
  %t3 = load ptr, ptr @g_g_onspawn
  %t4 = getelementptr inbounds %LSlice, ptr %t3, i32 0, i32 1
  %t5 = load i32, ptr %t4
  %t6 = icmp slt i32 %t2, %t5
  %t7 = zext i1 %t6 to i32
  %t8 = icmp ne i32 %t7, 0
  br i1 %t8, label %wbody1, label %wend2
wbody1:
  %t9 = load ptr, ptr @g_g_onspawn
  %t10 = getelementptr inbounds %LSlice, ptr %t9, i32 0, i32 0
  %t11 = load ptr, ptr %t10
  %t12 = load i32, ptr %t1
  %t13 = getelementptr inbounds ptr, ptr %t11, i32 %t12
  %t14 = load ptr, ptr %t13
  %t15 = getelementptr inbounds %Cmp_Node, ptr %t14, i32 0, i32 1
  %t16 = load ptr, ptr %t15
  %t17 = load ptr, ptr %t0
  %t18 = call i32 @fn_str_eq(ptr %t16, ptr %t17)
  %t19 = icmp ne i32 %t18, 0
  br i1 %t19, label %then3, label %ifend5
then3:
  %t20 = load ptr, ptr @g_g_onspawn
  %t21 = getelementptr inbounds %LSlice, ptr %t20, i32 0, i32 0
  %t22 = load ptr, ptr %t21
  %t23 = load i32, ptr %t1
  %t24 = getelementptr inbounds ptr, ptr %t22, i32 %t23
  %t25 = load ptr, ptr %t24
  %t26 = getelementptr inbounds %Cmp_Node, ptr %t25, i32 0, i32 4
  %t27 = load ptr, ptr %t26
  store ptr %t27, ptr %retval
  br label %ret
ifend5:
  %t28 = load i32, ptr %t1
  %t29 = add i32 %t28, 1
  store i32 %t29, ptr %t1
  br label %wcond0
wend2:
  store ptr null, ptr %retval
  br label %ret
ret:
  %t30 = load ptr, ptr %retval
  ret ptr %t30
}

define void @fn_register_ondespawn(ptr %arg_model, ptr %arg_body) {
entry:
  %t0 = alloca ptr
  %t1 = alloca ptr
  %t3 = alloca ptr
  store ptr %arg_model, ptr %t0
  store ptr %arg_body, ptr %t1
  %t2 = call ptr @fn_node(i32 7)
  store ptr %t2, ptr %t3
  %t4 = load ptr, ptr %t3
  %t5 = getelementptr inbounds %Cmp_Node, ptr %t4, i32 0, i32 1
  %t6 = load ptr, ptr %t0
  store ptr %t6, ptr %t5
  %t7 = load ptr, ptr %t3
  %t8 = getelementptr inbounds %Cmp_Node, ptr %t7, i32 0, i32 4
  %t9 = load ptr, ptr %t1
  store ptr %t9, ptr %t8
  %t10 = load ptr, ptr @g_g_ondespawn
  %t11 = getelementptr inbounds %LSlice, ptr %t10, i32 0, i32 1
  %t12 = getelementptr inbounds %LSlice, ptr %t10, i32 0, i32 2
  %t13 = getelementptr inbounds %LSlice, ptr %t10, i32 0, i32 0
  %t14 = load i32, ptr %t11
  %t15 = load i32, ptr %t12
  %t16 = icmp sge i32 %t14, %t15
  br i1 %t16, label %grow0, label %put1
grow0:
  %t17 = mul i32 %t15, 2
  %t18 = icmp eq i32 %t15, 0
  %t19 = select i1 %t18, i32 8, i32 %t17
  %t20 = getelementptr ptr, ptr null, i32 1
  %t21 = ptrtoint ptr %t20 to i64
  %t22 = zext i32 %t19 to i64
  %t23 = mul i64 %t22, %t21
  %t24 = load ptr, ptr %t13
  %t25 = call ptr @realloc(ptr %t24, i64 %t23)
  store ptr %t25, ptr %t13
  store i32 %t19, ptr %t12
  br label %put1
put1:
  %t26 = load ptr, ptr %t3
  %t27 = load ptr, ptr %t13
  %t28 = getelementptr inbounds ptr, ptr %t27, i32 %t14
  store ptr %t26, ptr %t28
  %t29 = add i32 %t14, 1
  store i32 %t29, ptr %t11
  br label %ret
ret:
  ret void
}

define ptr @fn_ondespawn_body(ptr %arg_model) {
entry:
  %retval = alloca ptr
  %t0 = alloca ptr
  %t1 = alloca i32
  store ptr %arg_model, ptr %t0
  store i32 0, ptr %t1
  br label %wcond0
wcond0:
  %t2 = load i32, ptr %t1
  %t3 = load ptr, ptr @g_g_ondespawn
  %t4 = getelementptr inbounds %LSlice, ptr %t3, i32 0, i32 1
  %t5 = load i32, ptr %t4
  %t6 = icmp slt i32 %t2, %t5
  %t7 = zext i1 %t6 to i32
  %t8 = icmp ne i32 %t7, 0
  br i1 %t8, label %wbody1, label %wend2
wbody1:
  %t9 = load ptr, ptr @g_g_ondespawn
  %t10 = getelementptr inbounds %LSlice, ptr %t9, i32 0, i32 0
  %t11 = load ptr, ptr %t10
  %t12 = load i32, ptr %t1
  %t13 = getelementptr inbounds ptr, ptr %t11, i32 %t12
  %t14 = load ptr, ptr %t13
  %t15 = getelementptr inbounds %Cmp_Node, ptr %t14, i32 0, i32 1
  %t16 = load ptr, ptr %t15
  %t17 = load ptr, ptr %t0
  %t18 = call i32 @fn_str_eq(ptr %t16, ptr %t17)
  %t19 = icmp ne i32 %t18, 0
  br i1 %t19, label %then3, label %ifend5
then3:
  %t20 = load ptr, ptr @g_g_ondespawn
  %t21 = getelementptr inbounds %LSlice, ptr %t20, i32 0, i32 0
  %t22 = load ptr, ptr %t21
  %t23 = load i32, ptr %t1
  %t24 = getelementptr inbounds ptr, ptr %t22, i32 %t23
  %t25 = load ptr, ptr %t24
  %t26 = getelementptr inbounds %Cmp_Node, ptr %t25, i32 0, i32 4
  %t27 = load ptr, ptr %t26
  store ptr %t27, ptr %retval
  br label %ret
ifend5:
  %t28 = load i32, ptr %t1
  %t29 = add i32 %t28, 1
  store i32 %t29, ptr %t1
  br label %wcond0
wend2:
  store ptr null, ptr %retval
  br label %ret
ret:
  %t30 = load ptr, ptr %retval
  ret ptr %t30
}

define void @fn_register_onattach(ptr %arg_prop, ptr %arg_body) {
entry:
  %t0 = alloca ptr
  %t1 = alloca ptr
  %t3 = alloca ptr
  store ptr %arg_prop, ptr %t0
  store ptr %arg_body, ptr %t1
  %t2 = call ptr @fn_node(i32 7)
  store ptr %t2, ptr %t3
  %t4 = load ptr, ptr %t3
  %t5 = getelementptr inbounds %Cmp_Node, ptr %t4, i32 0, i32 1
  %t6 = load ptr, ptr %t0
  store ptr %t6, ptr %t5
  %t7 = load ptr, ptr %t3
  %t8 = getelementptr inbounds %Cmp_Node, ptr %t7, i32 0, i32 4
  %t9 = load ptr, ptr %t1
  store ptr %t9, ptr %t8
  %t10 = load ptr, ptr @g_g_onattach
  %t11 = getelementptr inbounds %LSlice, ptr %t10, i32 0, i32 1
  %t12 = getelementptr inbounds %LSlice, ptr %t10, i32 0, i32 2
  %t13 = getelementptr inbounds %LSlice, ptr %t10, i32 0, i32 0
  %t14 = load i32, ptr %t11
  %t15 = load i32, ptr %t12
  %t16 = icmp sge i32 %t14, %t15
  br i1 %t16, label %grow0, label %put1
grow0:
  %t17 = mul i32 %t15, 2
  %t18 = icmp eq i32 %t15, 0
  %t19 = select i1 %t18, i32 8, i32 %t17
  %t20 = getelementptr ptr, ptr null, i32 1
  %t21 = ptrtoint ptr %t20 to i64
  %t22 = zext i32 %t19 to i64
  %t23 = mul i64 %t22, %t21
  %t24 = load ptr, ptr %t13
  %t25 = call ptr @realloc(ptr %t24, i64 %t23)
  store ptr %t25, ptr %t13
  store i32 %t19, ptr %t12
  br label %put1
put1:
  %t26 = load ptr, ptr %t3
  %t27 = load ptr, ptr %t13
  %t28 = getelementptr inbounds ptr, ptr %t27, i32 %t14
  store ptr %t26, ptr %t28
  %t29 = add i32 %t14, 1
  store i32 %t29, ptr %t11
  br label %ret
ret:
  ret void
}

define ptr @fn_onattach_body(ptr %arg_prop) {
entry:
  %retval = alloca ptr
  %t0 = alloca ptr
  %t1 = alloca i32
  store ptr %arg_prop, ptr %t0
  store i32 0, ptr %t1
  br label %wcond0
wcond0:
  %t2 = load i32, ptr %t1
  %t3 = load ptr, ptr @g_g_onattach
  %t4 = getelementptr inbounds %LSlice, ptr %t3, i32 0, i32 1
  %t5 = load i32, ptr %t4
  %t6 = icmp slt i32 %t2, %t5
  %t7 = zext i1 %t6 to i32
  %t8 = icmp ne i32 %t7, 0
  br i1 %t8, label %wbody1, label %wend2
wbody1:
  %t9 = load ptr, ptr @g_g_onattach
  %t10 = getelementptr inbounds %LSlice, ptr %t9, i32 0, i32 0
  %t11 = load ptr, ptr %t10
  %t12 = load i32, ptr %t1
  %t13 = getelementptr inbounds ptr, ptr %t11, i32 %t12
  %t14 = load ptr, ptr %t13
  %t15 = getelementptr inbounds %Cmp_Node, ptr %t14, i32 0, i32 1
  %t16 = load ptr, ptr %t15
  %t17 = load ptr, ptr %t0
  %t18 = call i32 @fn_str_eq(ptr %t16, ptr %t17)
  %t19 = icmp ne i32 %t18, 0
  br i1 %t19, label %then3, label %ifend5
then3:
  %t20 = load ptr, ptr @g_g_onattach
  %t21 = getelementptr inbounds %LSlice, ptr %t20, i32 0, i32 0
  %t22 = load ptr, ptr %t21
  %t23 = load i32, ptr %t1
  %t24 = getelementptr inbounds ptr, ptr %t22, i32 %t23
  %t25 = load ptr, ptr %t24
  %t26 = getelementptr inbounds %Cmp_Node, ptr %t25, i32 0, i32 4
  %t27 = load ptr, ptr %t26
  store ptr %t27, ptr %retval
  br label %ret
ifend5:
  %t28 = load i32, ptr %t1
  %t29 = add i32 %t28, 1
  store i32 %t29, ptr %t1
  br label %wcond0
wend2:
  store ptr null, ptr %retval
  br label %ret
ret:
  %t30 = load ptr, ptr %retval
  ret ptr %t30
}

define void @fn_register_onenable(ptr %arg_prop, ptr %arg_body) {
entry:
  %t0 = alloca ptr
  %t1 = alloca ptr
  %t3 = alloca ptr
  store ptr %arg_prop, ptr %t0
  store ptr %arg_body, ptr %t1
  %t2 = call ptr @fn_node(i32 7)
  store ptr %t2, ptr %t3
  %t4 = load ptr, ptr %t3
  %t5 = getelementptr inbounds %Cmp_Node, ptr %t4, i32 0, i32 1
  %t6 = load ptr, ptr %t0
  store ptr %t6, ptr %t5
  %t7 = load ptr, ptr %t3
  %t8 = getelementptr inbounds %Cmp_Node, ptr %t7, i32 0, i32 4
  %t9 = load ptr, ptr %t1
  store ptr %t9, ptr %t8
  %t10 = load ptr, ptr @g_g_onenable
  %t11 = getelementptr inbounds %LSlice, ptr %t10, i32 0, i32 1
  %t12 = getelementptr inbounds %LSlice, ptr %t10, i32 0, i32 2
  %t13 = getelementptr inbounds %LSlice, ptr %t10, i32 0, i32 0
  %t14 = load i32, ptr %t11
  %t15 = load i32, ptr %t12
  %t16 = icmp sge i32 %t14, %t15
  br i1 %t16, label %grow0, label %put1
grow0:
  %t17 = mul i32 %t15, 2
  %t18 = icmp eq i32 %t15, 0
  %t19 = select i1 %t18, i32 8, i32 %t17
  %t20 = getelementptr ptr, ptr null, i32 1
  %t21 = ptrtoint ptr %t20 to i64
  %t22 = zext i32 %t19 to i64
  %t23 = mul i64 %t22, %t21
  %t24 = load ptr, ptr %t13
  %t25 = call ptr @realloc(ptr %t24, i64 %t23)
  store ptr %t25, ptr %t13
  store i32 %t19, ptr %t12
  br label %put1
put1:
  %t26 = load ptr, ptr %t3
  %t27 = load ptr, ptr %t13
  %t28 = getelementptr inbounds ptr, ptr %t27, i32 %t14
  store ptr %t26, ptr %t28
  %t29 = add i32 %t14, 1
  store i32 %t29, ptr %t11
  br label %ret
ret:
  ret void
}

define void @fn_register_ondisable(ptr %arg_prop, ptr %arg_body) {
entry:
  %t0 = alloca ptr
  %t1 = alloca ptr
  %t3 = alloca ptr
  store ptr %arg_prop, ptr %t0
  store ptr %arg_body, ptr %t1
  %t2 = call ptr @fn_node(i32 7)
  store ptr %t2, ptr %t3
  %t4 = load ptr, ptr %t3
  %t5 = getelementptr inbounds %Cmp_Node, ptr %t4, i32 0, i32 1
  %t6 = load ptr, ptr %t0
  store ptr %t6, ptr %t5
  %t7 = load ptr, ptr %t3
  %t8 = getelementptr inbounds %Cmp_Node, ptr %t7, i32 0, i32 4
  %t9 = load ptr, ptr %t1
  store ptr %t9, ptr %t8
  %t10 = load ptr, ptr @g_g_ondisable
  %t11 = getelementptr inbounds %LSlice, ptr %t10, i32 0, i32 1
  %t12 = getelementptr inbounds %LSlice, ptr %t10, i32 0, i32 2
  %t13 = getelementptr inbounds %LSlice, ptr %t10, i32 0, i32 0
  %t14 = load i32, ptr %t11
  %t15 = load i32, ptr %t12
  %t16 = icmp sge i32 %t14, %t15
  br i1 %t16, label %grow0, label %put1
grow0:
  %t17 = mul i32 %t15, 2
  %t18 = icmp eq i32 %t15, 0
  %t19 = select i1 %t18, i32 8, i32 %t17
  %t20 = getelementptr ptr, ptr null, i32 1
  %t21 = ptrtoint ptr %t20 to i64
  %t22 = zext i32 %t19 to i64
  %t23 = mul i64 %t22, %t21
  %t24 = load ptr, ptr %t13
  %t25 = call ptr @realloc(ptr %t24, i64 %t23)
  store ptr %t25, ptr %t13
  store i32 %t19, ptr %t12
  br label %put1
put1:
  %t26 = load ptr, ptr %t3
  %t27 = load ptr, ptr %t13
  %t28 = getelementptr inbounds ptr, ptr %t27, i32 %t14
  store ptr %t26, ptr %t28
  %t29 = add i32 %t14, 1
  store i32 %t29, ptr %t11
  br label %ret
ret:
  ret void
}

define ptr @fn_onenable_body(ptr %arg_prop) {
entry:
  %retval = alloca ptr
  %t0 = alloca ptr
  %t1 = alloca i32
  store ptr %arg_prop, ptr %t0
  store i32 0, ptr %t1
  br label %wcond0
wcond0:
  %t2 = load i32, ptr %t1
  %t3 = load ptr, ptr @g_g_onenable
  %t4 = getelementptr inbounds %LSlice, ptr %t3, i32 0, i32 1
  %t5 = load i32, ptr %t4
  %t6 = icmp slt i32 %t2, %t5
  %t7 = zext i1 %t6 to i32
  %t8 = icmp ne i32 %t7, 0
  br i1 %t8, label %wbody1, label %wend2
wbody1:
  %t9 = load ptr, ptr @g_g_onenable
  %t10 = getelementptr inbounds %LSlice, ptr %t9, i32 0, i32 0
  %t11 = load ptr, ptr %t10
  %t12 = load i32, ptr %t1
  %t13 = getelementptr inbounds ptr, ptr %t11, i32 %t12
  %t14 = load ptr, ptr %t13
  %t15 = getelementptr inbounds %Cmp_Node, ptr %t14, i32 0, i32 1
  %t16 = load ptr, ptr %t15
  %t17 = load ptr, ptr %t0
  %t18 = call i32 @fn_str_eq(ptr %t16, ptr %t17)
  %t19 = icmp ne i32 %t18, 0
  br i1 %t19, label %then3, label %ifend5
then3:
  %t20 = load ptr, ptr @g_g_onenable
  %t21 = getelementptr inbounds %LSlice, ptr %t20, i32 0, i32 0
  %t22 = load ptr, ptr %t21
  %t23 = load i32, ptr %t1
  %t24 = getelementptr inbounds ptr, ptr %t22, i32 %t23
  %t25 = load ptr, ptr %t24
  %t26 = getelementptr inbounds %Cmp_Node, ptr %t25, i32 0, i32 4
  %t27 = load ptr, ptr %t26
  store ptr %t27, ptr %retval
  br label %ret
ifend5:
  %t28 = load i32, ptr %t1
  %t29 = add i32 %t28, 1
  store i32 %t29, ptr %t1
  br label %wcond0
wend2:
  store ptr null, ptr %retval
  br label %ret
ret:
  %t30 = load ptr, ptr %retval
  ret ptr %t30
}

define ptr @fn_ondisable_body(ptr %arg_prop) {
entry:
  %retval = alloca ptr
  %t0 = alloca ptr
  %t1 = alloca i32
  store ptr %arg_prop, ptr %t0
  store i32 0, ptr %t1
  br label %wcond0
wcond0:
  %t2 = load i32, ptr %t1
  %t3 = load ptr, ptr @g_g_ondisable
  %t4 = getelementptr inbounds %LSlice, ptr %t3, i32 0, i32 1
  %t5 = load i32, ptr %t4
  %t6 = icmp slt i32 %t2, %t5
  %t7 = zext i1 %t6 to i32
  %t8 = icmp ne i32 %t7, 0
  br i1 %t8, label %wbody1, label %wend2
wbody1:
  %t9 = load ptr, ptr @g_g_ondisable
  %t10 = getelementptr inbounds %LSlice, ptr %t9, i32 0, i32 0
  %t11 = load ptr, ptr %t10
  %t12 = load i32, ptr %t1
  %t13 = getelementptr inbounds ptr, ptr %t11, i32 %t12
  %t14 = load ptr, ptr %t13
  %t15 = getelementptr inbounds %Cmp_Node, ptr %t14, i32 0, i32 1
  %t16 = load ptr, ptr %t15
  %t17 = load ptr, ptr %t0
  %t18 = call i32 @fn_str_eq(ptr %t16, ptr %t17)
  %t19 = icmp ne i32 %t18, 0
  br i1 %t19, label %then3, label %ifend5
then3:
  %t20 = load ptr, ptr @g_g_ondisable
  %t21 = getelementptr inbounds %LSlice, ptr %t20, i32 0, i32 0
  %t22 = load ptr, ptr %t21
  %t23 = load i32, ptr %t1
  %t24 = getelementptr inbounds ptr, ptr %t22, i32 %t23
  %t25 = load ptr, ptr %t24
  %t26 = getelementptr inbounds %Cmp_Node, ptr %t25, i32 0, i32 4
  %t27 = load ptr, ptr %t26
  store ptr %t27, ptr %retval
  br label %ret
ifend5:
  %t28 = load i32, ptr %t1
  %t29 = add i32 %t28, 1
  store i32 %t29, ptr %t1
  br label %wcond0
wend2:
  store ptr null, ptr %retval
  br label %ret
ret:
  %t30 = load ptr, ptr %retval
  ret ptr %t30
}

define i32 @fn_is_model(ptr %arg_name) {
entry:
  %retval = alloca i32
  %t0 = alloca ptr
  store ptr %arg_name, ptr %t0
  %t1 = load ptr, ptr %t0
  %t2 = call i32 @fn_find_arch_id(ptr %t1)
  %t3 = icmp sgt i32 %t2, 0
  %t4 = zext i1 %t3 to i32
  store i32 %t4, ptr %retval
  br label %ret
ret:
  %t5 = load i32, ptr %retval
  ret i32 %t5
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
  %t28 = load ptr, ptr @g_loc_mut
  %t29 = getelementptr inbounds %LSlice, ptr %t28, i32 0, i32 0
  %t30 = load ptr, ptr %t29
  %t31 = load i32, ptr @g_nloc
  %t32 = getelementptr inbounds i32, ptr %t30, i32 %t31
  store i32 1, ptr %t32
  br label %ifend2
else1:
  %t33 = load ptr, ptr @g_loc_name
  %t34 = getelementptr inbounds %LSlice, ptr %t33, i32 0, i32 1
  %t35 = getelementptr inbounds %LSlice, ptr %t33, i32 0, i32 2
  %t36 = getelementptr inbounds %LSlice, ptr %t33, i32 0, i32 0
  %t37 = load i32, ptr %t34
  %t38 = load i32, ptr %t35
  %t39 = icmp sge i32 %t37, %t38
  br i1 %t39, label %grow3, label %put4
grow3:
  %t40 = mul i32 %t38, 2
  %t41 = icmp eq i32 %t38, 0
  %t42 = select i1 %t41, i32 8, i32 %t40
  %t43 = getelementptr ptr, ptr null, i32 1
  %t44 = ptrtoint ptr %t43 to i64
  %t45 = zext i32 %t42 to i64
  %t46 = mul i64 %t45, %t44
  %t47 = load ptr, ptr %t36
  %t48 = call ptr @realloc(ptr %t47, i64 %t46)
  store ptr %t48, ptr %t36
  store i32 %t42, ptr %t35
  br label %put4
put4:
  %t49 = load ptr, ptr %t0
  %t50 = load ptr, ptr %t36
  %t51 = getelementptr inbounds ptr, ptr %t50, i32 %t37
  store ptr %t49, ptr %t51
  %t52 = add i32 %t37, 1
  store i32 %t52, ptr %t34
  %t53 = load ptr, ptr @g_loc_reg
  %t54 = getelementptr inbounds %LSlice, ptr %t53, i32 0, i32 1
  %t55 = getelementptr inbounds %LSlice, ptr %t53, i32 0, i32 2
  %t56 = getelementptr inbounds %LSlice, ptr %t53, i32 0, i32 0
  %t57 = load i32, ptr %t54
  %t58 = load i32, ptr %t55
  %t59 = icmp sge i32 %t57, %t58
  br i1 %t59, label %grow5, label %put6
grow5:
  %t60 = mul i32 %t58, 2
  %t61 = icmp eq i32 %t58, 0
  %t62 = select i1 %t61, i32 8, i32 %t60
  %t63 = getelementptr ptr, ptr null, i32 1
  %t64 = ptrtoint ptr %t63 to i64
  %t65 = zext i32 %t62 to i64
  %t66 = mul i64 %t65, %t64
  %t67 = load ptr, ptr %t56
  %t68 = call ptr @realloc(ptr %t67, i64 %t66)
  store ptr %t68, ptr %t56
  store i32 %t62, ptr %t55
  br label %put6
put6:
  %t69 = load ptr, ptr %t1
  %t70 = load ptr, ptr %t56
  %t71 = getelementptr inbounds ptr, ptr %t70, i32 %t57
  store ptr %t69, ptr %t71
  %t72 = add i32 %t57, 1
  store i32 %t72, ptr %t54
  %t73 = load ptr, ptr @g_loc_ty
  %t74 = getelementptr inbounds %LSlice, ptr %t73, i32 0, i32 1
  %t75 = getelementptr inbounds %LSlice, ptr %t73, i32 0, i32 2
  %t76 = getelementptr inbounds %LSlice, ptr %t73, i32 0, i32 0
  %t77 = load i32, ptr %t74
  %t78 = load i32, ptr %t75
  %t79 = icmp sge i32 %t77, %t78
  br i1 %t79, label %grow7, label %put8
grow7:
  %t80 = mul i32 %t78, 2
  %t81 = icmp eq i32 %t78, 0
  %t82 = select i1 %t81, i32 8, i32 %t80
  %t83 = getelementptr ptr, ptr null, i32 1
  %t84 = ptrtoint ptr %t83 to i64
  %t85 = zext i32 %t82 to i64
  %t86 = mul i64 %t85, %t84
  %t87 = load ptr, ptr %t76
  %t88 = call ptr @realloc(ptr %t87, i64 %t86)
  store ptr %t88, ptr %t76
  store i32 %t82, ptr %t75
  br label %put8
put8:
  %t89 = load ptr, ptr %t2
  %t90 = load ptr, ptr %t76
  %t91 = getelementptr inbounds ptr, ptr %t90, i32 %t77
  store ptr %t89, ptr %t91
  %t92 = add i32 %t77, 1
  store i32 %t92, ptr %t74
  %t93 = load ptr, ptr @g_loc_mut
  %t94 = getelementptr inbounds %LSlice, ptr %t93, i32 0, i32 1
  %t95 = getelementptr inbounds %LSlice, ptr %t93, i32 0, i32 2
  %t96 = getelementptr inbounds %LSlice, ptr %t93, i32 0, i32 0
  %t97 = load i32, ptr %t94
  %t98 = load i32, ptr %t95
  %t99 = icmp sge i32 %t97, %t98
  br i1 %t99, label %grow9, label %put10
grow9:
  %t100 = mul i32 %t98, 2
  %t101 = icmp eq i32 %t98, 0
  %t102 = select i1 %t101, i32 8, i32 %t100
  %t103 = getelementptr i32, ptr null, i32 1
  %t104 = ptrtoint ptr %t103 to i64
  %t105 = zext i32 %t102 to i64
  %t106 = mul i64 %t105, %t104
  %t107 = load ptr, ptr %t96
  %t108 = call ptr @realloc(ptr %t107, i64 %t106)
  store ptr %t108, ptr %t96
  store i32 %t102, ptr %t95
  br label %put10
put10:
  %t109 = load ptr, ptr %t96
  %t110 = getelementptr inbounds i32, ptr %t109, i32 %t97
  store i32 1, ptr %t110
  %t111 = add i32 %t97, 1
  store i32 %t111, ptr %t94
  br label %ifend2
ifend2:
  %t112 = load i32, ptr @g_nloc
  %t113 = add i32 %t112, 1
  store i32 %t113, ptr @g_nloc
  br label %ret
ret:
  ret void
}

define void @fn_loc_set_mut(i32 %arg_m) {
entry:
  %t0 = alloca i32
  store i32 %arg_m, ptr %t0
  %t1 = load i32, ptr @g_nloc
  %t2 = icmp sgt i32 %t1, 0
  %t3 = zext i1 %t2 to i32
  %t4 = icmp ne i32 %t3, 0
  br i1 %t4, label %then0, label %ifend2
then0:
  %t5 = load ptr, ptr @g_loc_mut
  %t6 = getelementptr inbounds %LSlice, ptr %t5, i32 0, i32 0
  %t7 = load ptr, ptr %t6
  %t8 = load i32, ptr @g_nloc
  %t9 = sub i32 %t8, 1
  %t10 = getelementptr inbounds i32, ptr %t7, i32 %t9
  %t11 = load i32, ptr %t0
  store i32 %t11, ptr %t10
  br label %ifend2
ifend2:
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
  %t15 = call i32 @fn_str_eq(ptr %t13, ptr %t14)
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
  %t3 = call ptr @fn_str_concat(ptr @.str244, ptr %t2)
  store ptr %t3, ptr %t4
  %t5 = load i32, ptr @g_ll_str
  %t6 = add i32 %t5, 1
  store i32 %t6, ptr @g_ll_str
  %t7 = load ptr, ptr %t0
  %t8 = call i32 @fn_slen(ptr %t7)
  store i32 %t8, ptr %t9
  %t10 = load ptr, ptr %t4
  call void @fn_emith(ptr %t10)
  call void @fn_emith(ptr @.str245)
  %t11 = load i32, ptr %t9
  %t12 = add i32 %t11, 1
  %t13 = call ptr @fn_itoa(i32 %t12)
  call void @fn_emith(ptr %t13)
  call void @fn_emith(ptr @.str246)
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
  call void @fn_emith(ptr @.str247)
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
  call void @fn_emit(ptr @.str248)
  %t4 = load ptr, ptr %t3
  call void @fn_emit(ptr %t4)
  call void @fn_emit(ptr @.str249)
  %t5 = load ptr, ptr %t0
  call void @fn_emit(ptr %t5)
  call void @fn_emit(ptr @.str250)
  %t6 = load ptr, ptr %t1
  call void @fn_emit(ptr %t6)
  call void @fn_emit(ptr @.str251)
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
  %t2 = getelementptr inbounds %Cmp_Node, ptr %t1, i32 0, i32 4
  %t3 = load ptr, ptr %t2
  %t4 = icmp eq ptr %t3, null
  %t5 = zext i1 %t4 to i32
  %t6 = icmp ne i32 %t5, 0
  br i1 %t6, label %then0, label %ifend2
then0:
  %t7 = load ptr, ptr %t0
  %t8 = getelementptr inbounds %Cmp_Node, ptr %t7, i32 0, i32 3
  %t9 = load ptr, ptr %t8
  %t10 = call ptr @fn_llty(ptr %t9)
  %t11 = call i32 @fn_str_eq(ptr %t10, ptr @.str252)
  %t12 = icmp ne i32 %t11, 0
  br i1 %t12, label %then3, label %ifend5
then3:
  store ptr @.str253, ptr %retval
  br label %ret
ifend5:
  store ptr @.str254, ptr %retval
  br label %ret
ifend2:
  %t13 = load ptr, ptr %t0
  %t14 = getelementptr inbounds %Cmp_Node, ptr %t13, i32 0, i32 4
  %t15 = load ptr, ptr %t14
  store ptr %t15, ptr %t16
  %t19 = load ptr, ptr %t16
  %t20 = getelementptr inbounds %Cmp_Node, ptr %t19, i32 0, i32 0
  %t21 = load i32, ptr %t20
  %t22 = icmp eq i32 %t21, 30
  %t23 = zext i1 %t22 to i32
  %t24 = icmp ne i32 %t23, 0
  %t25 = zext i1 %t24 to i32
  store i32 %t25, ptr %t18
  br i1 %t24, label %scend7, label %sc6
sc6:
  %t26 = load ptr, ptr %t16
  %t27 = getelementptr inbounds %Cmp_Node, ptr %t26, i32 0, i32 0
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
  %t37 = getelementptr inbounds %Cmp_Node, ptr %t36, i32 0, i32 0
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
  %t46 = getelementptr inbounds %Cmp_Node, ptr %t45, i32 0, i32 2
  %t47 = load i32, ptr %t46
  %t48 = call ptr @fn_itoa(i32 %t47)
  store ptr %t48, ptr %retval
  br label %ret
ifend12:
  %t51 = load ptr, ptr %t16
  %t52 = getelementptr inbounds %Cmp_Node, ptr %t51, i32 0, i32 0
  %t53 = load i32, ptr %t52
  %t54 = icmp eq i32 %t53, 38
  %t55 = zext i1 %t54 to i32
  %t56 = icmp ne i32 %t55, 0
  %t57 = zext i1 %t56 to i32
  store i32 %t57, ptr %t50
  br i1 %t56, label %sc13, label %scend14
sc13:
  %t58 = load ptr, ptr %t16
  %t59 = getelementptr inbounds %Cmp_Node, ptr %t58, i32 0, i32 1
  %t60 = load ptr, ptr %t59
  %t61 = call i32 @fn_str_eq(ptr %t60, ptr @.str255)
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
  %t68 = getelementptr inbounds %Cmp_Node, ptr %t67, i32 0, i32 4
  %t69 = load ptr, ptr %t68
  %t70 = getelementptr inbounds %Cmp_Node, ptr %t69, i32 0, i32 0
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
  %t79 = getelementptr inbounds %Cmp_Node, ptr %t78, i32 0, i32 4
  %t80 = load ptr, ptr %t79
  %t81 = getelementptr inbounds %Cmp_Node, ptr %t80, i32 0, i32 2
  %t82 = load i32, ptr %t81
  %t83 = call ptr @fn_itoa(i32 %t82)
  %t84 = call ptr @fn_str_concat(ptr @.str256, ptr %t83)
  store ptr %t84, ptr %retval
  br label %ret
ifend19:
  %t85 = load ptr, ptr %t0
  %t86 = getelementptr inbounds %Cmp_Node, ptr %t85, i32 0, i32 3
  %t87 = load ptr, ptr %t86
  %t88 = call ptr @fn_llty(ptr %t87)
  %t89 = call i32 @fn_str_eq(ptr %t88, ptr @.str257)
  %t90 = icmp ne i32 %t89, 0
  br i1 %t90, label %then20, label %ifend22
then20:
  store ptr @.str258, ptr %retval
  br label %ret
ifend22:
  store ptr @.str259, ptr %retval
  br label %ret
ret:
  %t91 = load ptr, ptr %retval
  ret ptr %t91
}

define void @fn_emit_header() {
entry:
  %t5 = alloca i32
  %t19 = alloca ptr
  %t38 = alloca i32
  %t80 = alloca ptr
  call void @fn_emith(ptr @.str260)
  call void @fn_emith(ptr @.str261)
  call void @fn_emith(ptr @.str262)
  call void @fn_emith(ptr @.str263)
  call void @fn_emith(ptr @.str264)
  call void @fn_emith(ptr @.str265)
  call void @fn_emith(ptr @.str266)
  call void @fn_emith(ptr @.str267)
  call void @fn_emith(ptr @.str268)
  call void @fn_emith(ptr @.str269)
  call void @fn_emith(ptr @.str270)
  call void @fn_emith(ptr @.str271)
  call void @fn_emith(ptr @.str272)
  call void @fn_emith(ptr @.str273)
  call void @fn_emith(ptr @.str274)
  call void @fn_emith(ptr @.str275)
  call void @fn_emith(ptr @.str276)
  call void @fn_emith(ptr @.str277)
  call void @fn_emith(ptr @.str278)
  call void @fn_emith(ptr @.str279)
  call void @fn_emith(ptr @.str280)
  call void @fn_emith(ptr @.str281)
  call void @fn_emith(ptr @.str282)
  call void @fn_emith(ptr @.str283)
  call void @fn_emith(ptr @.str284)
  call void @fn_emith(ptr @.str285)
  call void @fn_emith(ptr @.str286)
  call void @fn_emith(ptr @.str287)
  call void @fn_emith(ptr @.str288)
  call void @fn_emith(ptr @.str289)
  call void @fn_emith(ptr @.str290)
  %t0 = load ptr, ptr @g_g_game_name
  %t1 = call i32 @fn_slen(ptr %t0)
  %t2 = add i32 %t1, 1
  %t3 = call ptr @fn_itoa(i32 %t2)
  call void @fn_emith(ptr %t3)
  call void @fn_emith(ptr @.str291)
  %t4 = load ptr, ptr @g_g_game_name
  call void @fn_emith(ptr %t4)
  call void @fn_emith(ptr @.str292)
  call void @fn_emith(ptr @.str293)
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
  %t21 = getelementptr inbounds %Cmp_Node, ptr %t20, i32 0, i32 0
  %t22 = load i32, ptr %t21
  %t23 = icmp eq i32 %t22, 8
  %t24 = zext i1 %t23 to i32
  %t25 = icmp ne i32 %t24, 0
  br i1 %t25, label %then3, label %ifend5
then3:
  %t26 = load ptr, ptr %t19
  %t27 = getelementptr inbounds %Cmp_Node, ptr %t26, i32 0, i32 1
  %t28 = load ptr, ptr %t27
  %t29 = call ptr @fn_layout_ty(ptr %t28)
  call void @fn_emith(ptr %t29)
  call void @fn_emith(ptr @.str294)
  %t30 = load ptr, ptr %t19
  %t31 = getelementptr inbounds %Cmp_Node, ptr %t30, i32 0, i32 7
  %t32 = load ptr, ptr %t31
  %t33 = getelementptr inbounds %LSlice, ptr %t32, i32 0, i32 1
  %t34 = load i32, ptr %t33
  %t35 = icmp eq i32 %t34, 0
  %t36 = zext i1 %t35 to i32
  %t37 = icmp ne i32 %t36, 0
  br i1 %t37, label %then6, label %ifend8
then6:
  call void @fn_emith(ptr @.str295)
  br label %ifend8
ifend8:
  store i32 0, ptr %t38
  br label %wcond9
wcond9:
  %t39 = load i32, ptr %t38
  %t40 = load ptr, ptr %t19
  %t41 = getelementptr inbounds %Cmp_Node, ptr %t40, i32 0, i32 7
  %t42 = load ptr, ptr %t41
  %t43 = getelementptr inbounds %LSlice, ptr %t42, i32 0, i32 1
  %t44 = load i32, ptr %t43
  %t45 = icmp slt i32 %t39, %t44
  %t46 = zext i1 %t45 to i32
  %t47 = icmp ne i32 %t46, 0
  br i1 %t47, label %wbody10, label %wend11
wbody10:
  %t48 = load i32, ptr %t38
  %t49 = icmp sgt i32 %t48, 0
  %t50 = zext i1 %t49 to i32
  %t51 = icmp ne i32 %t50, 0
  br i1 %t51, label %then12, label %ifend14
then12:
  call void @fn_emith(ptr @.str296)
  br label %ifend14
ifend14:
  %t52 = load ptr, ptr %t19
  %t53 = getelementptr inbounds %Cmp_Node, ptr %t52, i32 0, i32 7
  %t54 = load ptr, ptr %t53
  %t55 = getelementptr inbounds %LSlice, ptr %t54, i32 0, i32 0
  %t56 = load ptr, ptr %t55
  %t57 = load i32, ptr %t38
  %t58 = getelementptr inbounds ptr, ptr %t56, i32 %t57
  %t59 = load ptr, ptr %t58
  %t60 = getelementptr inbounds %Cmp_Node, ptr %t59, i32 0, i32 3
  %t61 = load ptr, ptr %t60
  %t62 = call ptr @fn_llty(ptr %t61)
  call void @fn_emith(ptr %t62)
  %t63 = load i32, ptr %t38
  %t64 = add i32 %t63, 1
  store i32 %t64, ptr %t38
  br label %wcond9
wend11:
  call void @fn_emith(ptr @.str297)
  br label %ifend5
ifend5:
  %t65 = load i32, ptr %t5
  %t66 = add i32 %t65, 1
  store i32 %t66, ptr %t5
  br label %wcond0
wend2:
  store i32 0, ptr %t5
  br label %wcond15
wcond15:
  %t67 = load i32, ptr %t5
  %t68 = load ptr, ptr @g_prog
  %t69 = getelementptr inbounds %LSlice, ptr %t68, i32 0, i32 1
  %t70 = load i32, ptr %t69
  %t71 = icmp slt i32 %t67, %t70
  %t72 = zext i1 %t71 to i32
  %t73 = icmp ne i32 %t72, 0
  br i1 %t73, label %wbody16, label %wend17
wbody16:
  %t74 = load ptr, ptr @g_prog
  %t75 = getelementptr inbounds %LSlice, ptr %t74, i32 0, i32 0
  %t76 = load ptr, ptr %t75
  %t77 = load i32, ptr %t5
  %t78 = getelementptr inbounds ptr, ptr %t76, i32 %t77
  %t79 = load ptr, ptr %t78
  store ptr %t79, ptr %t80
  %t81 = load ptr, ptr %t80
  %t82 = getelementptr inbounds %Cmp_Node, ptr %t81, i32 0, i32 0
  %t83 = load i32, ptr %t82
  %t84 = icmp eq i32 %t83, 2
  %t85 = zext i1 %t84 to i32
  %t86 = icmp ne i32 %t85, 0
  br i1 %t86, label %then18, label %ifend20
then18:
  call void @fn_emith(ptr @.str298)
  %t87 = load ptr, ptr %t80
  %t88 = getelementptr inbounds %Cmp_Node, ptr %t87, i32 0, i32 1
  %t89 = load ptr, ptr %t88
  call void @fn_emith(ptr %t89)
  call void @fn_emith(ptr @.str299)
  %t90 = load ptr, ptr %t80
  %t91 = getelementptr inbounds %Cmp_Node, ptr %t90, i32 0, i32 3
  %t92 = load ptr, ptr %t91
  %t93 = call ptr @fn_llty(ptr %t92)
  call void @fn_emith(ptr %t93)
  call void @fn_emith(ptr @.str300)
  %t94 = load ptr, ptr %t80
  %t95 = call ptr @fn_global_init(ptr %t94)
  call void @fn_emith(ptr %t95)
  call void @fn_emith(ptr @.str301)
  br label %ifend20
ifend20:
  %t96 = load i32, ptr %t5
  %t97 = add i32 %t96, 1
  store i32 %t97, ptr %t5
  br label %wcond15
wend17:
  br label %ret
ret:
  ret void
}

define void @fn_emit_str_prelude() {
entry:
  call void @fn_emith(ptr @.str302)
  call void @fn_emith(ptr @.str303)
  call void @fn_emith(ptr @.str304)
  call void @fn_emith(ptr @.str305)
  call void @fn_emith(ptr @.str306)
  call void @fn_emith(ptr @.str307)
  call void @fn_emith(ptr @.str308)
  call void @fn_emith(ptr @.str309)
  call void @fn_emith(ptr @.str310)
  call void @fn_emith(ptr @.str311)
  call void @fn_emith(ptr @.str312)
  call void @fn_emith(ptr @.str313)
  call void @fn_emith(ptr @.str314)
  call void @fn_emith(ptr @.str315)
  call void @fn_emith(ptr @.str316)
  call void @fn_emith(ptr @.str317)
  call void @fn_emith(ptr @.str318)
  call void @fn_emith(ptr @.str319)
  call void @fn_emith(ptr @.str320)
  call void @fn_emith(ptr @.str321)
  call void @fn_emith(ptr @.str322)
  call void @fn_emith(ptr @.str323)
  call void @fn_emith(ptr @.str324)
  call void @fn_emith(ptr @.str325)
  call void @fn_emith(ptr @.str326)
  call void @fn_emith(ptr @.str327)
  call void @fn_emith(ptr @.str328)
  call void @fn_emith(ptr @.str329)
  call void @fn_emith(ptr @.str330)
  call void @fn_emith(ptr @.str331)
  call void @fn_emith(ptr @.str332)
  call void @fn_emith(ptr @.str333)
  call void @fn_emith(ptr @.str334)
  call void @fn_emith(ptr @.str335)
  call void @fn_emith(ptr @.str336)
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
  %t2 = getelementptr inbounds %Cmp_Node, ptr %t1, i32 0, i32 4
  %t3 = load ptr, ptr %t2
  %t4 = call ptr @fn_emit_expr(ptr %t3)
  store ptr %t4, ptr %t5
  %t6 = load ptr, ptr %t5
  %t7 = getelementptr inbounds %Cmp_Val, ptr %t6, i32 0, i32 1
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
  %t16 = getelementptr inbounds %Cmp_Val, ptr %t15, i32 0, i32 1
  %t17 = load ptr, ptr %t16
  %t18 = call ptr @fn_str_concat(ptr @.str337, ptr %t17)
  call void @fn_perr(ptr %t18)
  br label %ifend2
ifend2:
  %t19 = load ptr, ptr %t10
  %t20 = load ptr, ptr %t0
  %t21 = getelementptr inbounds %Cmp_Node, ptr %t20, i32 0, i32 1
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
  %t30 = getelementptr inbounds %Cmp_Node, ptr %t29, i32 0, i32 1
  %t31 = load ptr, ptr %t30
  %t32 = call ptr @fn_str_concat(ptr @.str338, ptr %t31)
  call void @fn_perr(ptr %t32)
  br label %ifend5
ifend5:
  %t33 = load ptr, ptr %t10
  %t34 = load ptr, ptr %t0
  %t35 = getelementptr inbounds %Cmp_Node, ptr %t34, i32 0, i32 1
  %t36 = load ptr, ptr %t35
  %t37 = call ptr @fn_field_type(ptr %t33, ptr %t36)
  store ptr %t37, ptr @g_g_addr_ty
  %t38 = call ptr @fn_nreg()
  store ptr %t38, ptr %t39
  call void @fn_emit(ptr @.str339)
  %t40 = load ptr, ptr %t39
  call void @fn_emit(ptr %t40)
  call void @fn_emit(ptr @.str340)
  %t41 = load ptr, ptr %t5
  %t42 = getelementptr inbounds %Cmp_Val, ptr %t41, i32 0, i32 1
  %t43 = load ptr, ptr %t42
  %t44 = call ptr @fn_layout_ty(ptr %t43)
  call void @fn_emit(ptr %t44)
  call void @fn_emit(ptr @.str341)
  %t45 = load ptr, ptr %t5
  %t46 = getelementptr inbounds %Cmp_Val, ptr %t45, i32 0, i32 0
  %t47 = load ptr, ptr %t46
  call void @fn_emit(ptr %t47)
  call void @fn_emit(ptr @.str342)
  %t48 = load i32, ptr %t24
  %t49 = call ptr @fn_itoa(i32 %t48)
  call void @fn_emit(ptr %t49)
  call void @fn_emit(ptr @.str343)
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
  %t2 = getelementptr inbounds %Cmp_Node, ptr %t1, i32 0, i32 4
  %t3 = load ptr, ptr %t2
  %t4 = call ptr @fn_emit_expr(ptr %t3)
  store ptr %t4, ptr %t5
  %t6 = load ptr, ptr %t5
  %t7 = getelementptr inbounds %Cmp_Val, ptr %t6, i32 0, i32 1
  %t8 = load ptr, ptr %t7
  %t9 = call i32 @fn_is_slice_ty(ptr %t8)
  %t10 = icmp eq i32 %t9, 0
  %t11 = zext i1 %t10 to i32
  %t12 = icmp ne i32 %t11, 0
  br i1 %t12, label %then0, label %ifend2
then0:
  call void @fn_perr(ptr @.str344)
  br label %ifend2
ifend2:
  %t13 = load ptr, ptr %t5
  %t14 = getelementptr inbounds %Cmp_Val, ptr %t13, i32 0, i32 1
  %t15 = load ptr, ptr %t14
  %t16 = call ptr @fn_slice_elem(ptr %t15)
  store ptr %t16, ptr %t17
  %t18 = load ptr, ptr %t17
  store ptr %t18, ptr @g_g_addr_ty
  %t19 = call ptr @fn_nreg()
  store ptr %t19, ptr %t20
  call void @fn_emit(ptr @.str345)
  %t21 = load ptr, ptr %t20
  call void @fn_emit(ptr %t21)
  call void @fn_emit(ptr @.str346)
  %t22 = load ptr, ptr %t5
  %t23 = getelementptr inbounds %Cmp_Val, ptr %t22, i32 0, i32 0
  %t24 = load ptr, ptr %t23
  call void @fn_emit(ptr %t24)
  call void @fn_emit(ptr @.str347)
  %t25 = call ptr @fn_nreg()
  store ptr %t25, ptr %t26
  call void @fn_emit(ptr @.str348)
  %t27 = load ptr, ptr %t26
  call void @fn_emit(ptr %t27)
  call void @fn_emit(ptr @.str349)
  %t28 = load ptr, ptr %t20
  call void @fn_emit(ptr %t28)
  call void @fn_emit(ptr @.str350)
  %t29 = load ptr, ptr %t0
  %t30 = getelementptr inbounds %Cmp_Node, ptr %t29, i32 0, i32 5
  %t31 = load ptr, ptr %t30
  %t32 = call ptr @fn_emit_expr(ptr %t31)
  store ptr %t32, ptr %t33
  %t34 = call ptr @fn_nreg()
  store ptr %t34, ptr %t35
  call void @fn_emit(ptr @.str351)
  %t36 = load ptr, ptr %t35
  call void @fn_emit(ptr %t36)
  call void @fn_emit(ptr @.str352)
  %t37 = load ptr, ptr %t17
  %t38 = call ptr @fn_llty(ptr %t37)
  call void @fn_emit(ptr %t38)
  call void @fn_emit(ptr @.str353)
  %t39 = load ptr, ptr %t26
  call void @fn_emit(ptr %t39)
  call void @fn_emit(ptr @.str354)
  %t40 = load ptr, ptr %t33
  %t41 = getelementptr inbounds %Cmp_Val, ptr %t40, i32 0, i32 0
  %t42 = load ptr, ptr %t41
  call void @fn_emit(ptr %t42)
  call void @fn_emit(ptr @.str355)
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
  %t12 = alloca i32
  %t23 = alloca i32
  %t24 = alloca i32
  %t42 = alloca i32
  %t43 = alloca i32
  %t61 = alloca i32
  %t72 = alloca i32
  %t73 = alloca i32
  %t74 = alloca i32
  %t99 = alloca i32
  %t110 = alloca i32
  store ptr %arg_name, ptr %t0
  %t2 = load ptr, ptr %t0
  %t3 = call i32 @fn_str_eq(ptr %t2, ptr @.str356)
  %t4 = icmp ne i32 %t3, 0
  %t5 = zext i1 %t4 to i32
  store i32 %t5, ptr %t1
  br i1 %t4, label %scend1, label %sc0
sc0:
  %t6 = load ptr, ptr %t0
  %t7 = call i32 @fn_str_eq(ptr %t6, ptr @.str357)
  %t8 = icmp ne i32 %t7, 0
  %t9 = zext i1 %t8 to i32
  store i32 %t9, ptr %t1
  br label %scend1
scend1:
  %t10 = load i32, ptr %t1
  %t11 = icmp ne i32 %t10, 0
  br i1 %t11, label %then2, label %ifend4
then2:
  store i32 1, ptr %retval
  br label %ret
ifend4:
  %t13 = load ptr, ptr %t0
  %t14 = call i32 @fn_str_eq(ptr %t13, ptr @.str358)
  %t15 = icmp ne i32 %t14, 0
  %t16 = zext i1 %t15 to i32
  store i32 %t16, ptr %t12
  br i1 %t15, label %scend6, label %sc5
sc5:
  %t17 = load ptr, ptr %t0
  %t18 = call i32 @fn_str_eq(ptr %t17, ptr @.str359)
  %t19 = icmp ne i32 %t18, 0
  %t20 = zext i1 %t19 to i32
  store i32 %t20, ptr %t12
  br label %scend6
scend6:
  %t21 = load i32, ptr %t12
  %t22 = icmp ne i32 %t21, 0
  br i1 %t22, label %then7, label %ifend9
then7:
  store i32 1, ptr %retval
  br label %ret
ifend9:
  %t25 = load ptr, ptr %t0
  %t26 = call i32 @fn_str_eq(ptr %t25, ptr @.str360)
  %t27 = icmp ne i32 %t26, 0
  %t28 = zext i1 %t27 to i32
  store i32 %t28, ptr %t24
  br i1 %t27, label %scend11, label %sc10
sc10:
  %t29 = load ptr, ptr %t0
  %t30 = call i32 @fn_str_eq(ptr %t29, ptr @.str361)
  %t31 = icmp ne i32 %t30, 0
  %t32 = zext i1 %t31 to i32
  store i32 %t32, ptr %t24
  br label %scend11
scend11:
  %t33 = load i32, ptr %t24
  %t34 = icmp ne i32 %t33, 0
  %t35 = zext i1 %t34 to i32
  store i32 %t35, ptr %t23
  br i1 %t34, label %scend13, label %sc12
sc12:
  %t36 = load ptr, ptr %t0
  %t37 = call i32 @fn_str_eq(ptr %t36, ptr @.str362)
  %t38 = icmp ne i32 %t37, 0
  %t39 = zext i1 %t38 to i32
  store i32 %t39, ptr %t23
  br label %scend13
scend13:
  %t40 = load i32, ptr %t23
  %t41 = icmp ne i32 %t40, 0
  br i1 %t41, label %then14, label %ifend16
then14:
  store i32 1, ptr %retval
  br label %ret
ifend16:
  %t44 = load ptr, ptr %t0
  %t45 = call i32 @fn_str_eq(ptr %t44, ptr @.str363)
  %t46 = icmp ne i32 %t45, 0
  %t47 = zext i1 %t46 to i32
  store i32 %t47, ptr %t43
  br i1 %t46, label %scend18, label %sc17
sc17:
  %t48 = load ptr, ptr %t0
  %t49 = call i32 @fn_str_eq(ptr %t48, ptr @.str364)
  %t50 = icmp ne i32 %t49, 0
  %t51 = zext i1 %t50 to i32
  store i32 %t51, ptr %t43
  br label %scend18
scend18:
  %t52 = load i32, ptr %t43
  %t53 = icmp ne i32 %t52, 0
  %t54 = zext i1 %t53 to i32
  store i32 %t54, ptr %t42
  br i1 %t53, label %scend20, label %sc19
sc19:
  %t55 = load ptr, ptr %t0
  %t56 = call i32 @fn_str_eq(ptr %t55, ptr @.str365)
  %t57 = icmp ne i32 %t56, 0
  %t58 = zext i1 %t57 to i32
  store i32 %t58, ptr %t42
  br label %scend20
scend20:
  %t59 = load i32, ptr %t42
  %t60 = icmp ne i32 %t59, 0
  br i1 %t60, label %then21, label %ifend23
then21:
  store i32 1, ptr %retval
  br label %ret
ifend23:
  %t62 = load ptr, ptr %t0
  %t63 = call i32 @fn_str_eq(ptr %t62, ptr @.str366)
  %t64 = icmp ne i32 %t63, 0
  %t65 = zext i1 %t64 to i32
  store i32 %t65, ptr %t61
  br i1 %t64, label %scend25, label %sc24
sc24:
  %t66 = load ptr, ptr %t0
  %t67 = call i32 @fn_str_eq(ptr %t66, ptr @.str367)
  %t68 = icmp ne i32 %t67, 0
  %t69 = zext i1 %t68 to i32
  store i32 %t69, ptr %t61
  br label %scend25
scend25:
  %t70 = load i32, ptr %t61
  %t71 = icmp ne i32 %t70, 0
  br i1 %t71, label %then26, label %ifend28
then26:
  store i32 1, ptr %retval
  br label %ret
ifend28:
  %t75 = load ptr, ptr %t0
  %t76 = call i32 @fn_str_eq(ptr %t75, ptr @.str368)
  %t77 = icmp ne i32 %t76, 0
  %t78 = zext i1 %t77 to i32
  store i32 %t78, ptr %t74
  br i1 %t77, label %scend30, label %sc29
sc29:
  %t79 = load ptr, ptr %t0
  %t80 = call i32 @fn_str_eq(ptr %t79, ptr @.str369)
  %t81 = icmp ne i32 %t80, 0
  %t82 = zext i1 %t81 to i32
  store i32 %t82, ptr %t74
  br label %scend30
scend30:
  %t83 = load i32, ptr %t74
  %t84 = icmp ne i32 %t83, 0
  %t85 = zext i1 %t84 to i32
  store i32 %t85, ptr %t73
  br i1 %t84, label %scend32, label %sc31
sc31:
  %t86 = load ptr, ptr %t0
  %t87 = call i32 @fn_str_eq(ptr %t86, ptr @.str370)
  %t88 = icmp ne i32 %t87, 0
  %t89 = zext i1 %t88 to i32
  store i32 %t89, ptr %t73
  br label %scend32
scend32:
  %t90 = load i32, ptr %t73
  %t91 = icmp ne i32 %t90, 0
  %t92 = zext i1 %t91 to i32
  store i32 %t92, ptr %t72
  br i1 %t91, label %scend34, label %sc33
sc33:
  %t93 = load ptr, ptr %t0
  %t94 = call i32 @fn_str_eq(ptr %t93, ptr @.str371)
  %t95 = icmp ne i32 %t94, 0
  %t96 = zext i1 %t95 to i32
  store i32 %t96, ptr %t72
  br label %scend34
scend34:
  %t97 = load i32, ptr %t72
  %t98 = icmp ne i32 %t97, 0
  br i1 %t98, label %then35, label %ifend37
then35:
  store i32 1, ptr %retval
  br label %ret
ifend37:
  %t100 = load ptr, ptr %t0
  %t101 = call i32 @fn_str_eq(ptr %t100, ptr @.str372)
  %t102 = icmp ne i32 %t101, 0
  %t103 = zext i1 %t102 to i32
  store i32 %t103, ptr %t99
  br i1 %t102, label %scend39, label %sc38
sc38:
  %t104 = load ptr, ptr %t0
  %t105 = call i32 @fn_str_eq(ptr %t104, ptr @.str373)
  %t106 = icmp ne i32 %t105, 0
  %t107 = zext i1 %t106 to i32
  store i32 %t107, ptr %t99
  br label %scend39
scend39:
  %t108 = load i32, ptr %t99
  %t109 = icmp ne i32 %t108, 0
  br i1 %t109, label %then40, label %ifend42
then40:
  store i32 1, ptr %retval
  br label %ret
ifend42:
  %t111 = load ptr, ptr %t0
  %t112 = call i32 @fn_str_eq(ptr %t111, ptr @.str374)
  %t113 = icmp ne i32 %t112, 0
  %t114 = zext i1 %t113 to i32
  store i32 %t114, ptr %t110
  br i1 %t113, label %scend44, label %sc43
sc43:
  %t115 = load ptr, ptr %t0
  %t116 = call i32 @fn_str_eq(ptr %t115, ptr @.str375)
  %t117 = icmp ne i32 %t116, 0
  %t118 = zext i1 %t117 to i32
  store i32 %t118, ptr %t110
  br label %scend44
scend44:
  %t119 = load i32, ptr %t110
  %t120 = icmp ne i32 %t119, 0
  br i1 %t120, label %then45, label %ifend47
then45:
  store i32 1, ptr %retval
  br label %ret
ifend47:
  store i32 0, ptr %retval
  br label %ret
ret:
  %t121 = load i32, ptr %retval
  ret i32 %t121
}

define ptr @fn_emit_bind(ptr %arg_rest) {
entry:
  %retval = alloca ptr
  %t0 = alloca ptr
  %t2 = alloca ptr
  store ptr %arg_rest, ptr %t0
  %t1 = call ptr @fn_nreg()
  store ptr %t1, ptr %t2
  call void @fn_emit(ptr @.str376)
  %t3 = load ptr, ptr %t2
  call void @fn_emit(ptr %t3)
  call void @fn_emit(ptr @.str377)
  %t4 = load ptr, ptr %t0
  call void @fn_emit(ptr %t4)
  call void @fn_emit(ptr @.str378)
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
  %t3 = getelementptr inbounds %Cmp_Node, ptr %t2, i32 0, i32 7
  %t4 = load ptr, ptr %t3
  %t5 = getelementptr inbounds %LSlice, ptr %t4, i32 0, i32 0
  %t6 = load ptr, ptr %t5
  %t7 = load i32, ptr %t1
  %t8 = getelementptr inbounds ptr, ptr %t6, i32 %t7
  %t9 = load ptr, ptr %t8
  %t10 = call ptr @fn_emit_expr(ptr %t9)
  store ptr %t10, ptr %t11
  %t12 = load ptr, ptr %t11
  %t13 = getelementptr inbounds %Cmp_Val, ptr %t12, i32 0, i32 0
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
  %t7 = alloca ptr
  %t12 = alloca ptr
  %t23 = alloca ptr
  %t26 = alloca ptr
  %t31 = alloca ptr
  %t45 = alloca ptr
  %t48 = alloca ptr
  %t52 = alloca ptr
  %t56 = alloca ptr
  %t67 = alloca ptr
  %t70 = alloca ptr
  %t73 = alloca ptr
  %t77 = alloca ptr
  %t82 = alloca ptr
  %t91 = alloca ptr
  %t94 = alloca ptr
  %t103 = alloca i32
  %t116 = alloca ptr
  %t119 = alloca ptr
  %t122 = alloca ptr
  %t127 = alloca ptr
  %t128 = alloca ptr
  %t145 = alloca ptr
  %t156 = alloca ptr
  %t159 = alloca ptr
  %t162 = alloca ptr
  %t167 = alloca ptr
  %t184 = alloca ptr
  %t189 = alloca ptr
  %t200 = alloca ptr
  %t208 = alloca ptr
  %t216 = alloca ptr
  %t229 = alloca ptr
  %t231 = alloca ptr
  %t238 = alloca ptr
  %t248 = alloca ptr
  %t261 = alloca ptr
  %t272 = alloca ptr
  %t283 = alloca ptr
  %t286 = alloca ptr
  %t288 = alloca ptr
  %t301 = alloca ptr
  %t304 = alloca ptr
  %t307 = alloca ptr
  %t309 = alloca ptr
  store ptr %arg_name, ptr %t0
  store ptr %arg_e, ptr %t1
  store i32 1, ptr @g_g_intrin_ok
  %t2 = load ptr, ptr %t0
  %t3 = call i32 @fn_str_eq(ptr %t2, ptr @.str379)
  %t4 = icmp ne i32 %t3, 0
  br i1 %t4, label %then0, label %ifend2
then0:
  %t5 = load ptr, ptr %t1
  %t6 = call ptr @fn_arg_code(ptr %t5, i32 0)
  store ptr %t6, ptr %t7
  %t8 = load ptr, ptr %t7
  %t9 = call ptr @fn_str_concat(ptr %t8, ptr @.str381)
  %t10 = call ptr @fn_str_concat(ptr @.str380, ptr %t9)
  %t11 = call ptr @fn_emit_bind(ptr %t10)
  store ptr %t11, ptr %t12
  %t13 = load ptr, ptr %t12
  %t14 = call ptr @fn_str_concat(ptr %t13, ptr @.str383)
  %t15 = call ptr @fn_str_concat(ptr @.str382, ptr %t14)
  %t16 = call ptr @fn_emit_bind(ptr %t15)
  %t17 = call ptr @fn_val(ptr %t16, ptr @.str384)
  store ptr %t17, ptr %retval
  br label %ret
ifend2:
  %t18 = load ptr, ptr %t0
  %t19 = call i32 @fn_str_eq(ptr %t18, ptr @.str385)
  %t20 = icmp ne i32 %t19, 0
  br i1 %t20, label %then3, label %ifend5
then3:
  %t21 = load ptr, ptr %t1
  %t22 = call ptr @fn_arg_code(ptr %t21, i32 0)
  store ptr %t22, ptr %t23
  %t24 = load ptr, ptr %t1
  %t25 = call ptr @fn_arg_code(ptr %t24, i32 1)
  store ptr %t25, ptr %t26
  %t27 = load ptr, ptr %t26
  %t28 = call ptr @fn_str_concat(ptr %t27, ptr @.str387)
  %t29 = call ptr @fn_str_concat(ptr @.str386, ptr %t28)
  %t30 = call ptr @fn_emit_bind(ptr %t29)
  store ptr %t30, ptr %t31
  %t32 = load ptr, ptr %t23
  %t33 = load ptr, ptr %t31
  %t34 = call ptr @fn_str_concat(ptr %t33, ptr @.str390)
  %t35 = call ptr @fn_str_concat(ptr @.str389, ptr %t34)
  %t36 = call ptr @fn_str_concat(ptr %t32, ptr %t35)
  %t37 = call ptr @fn_str_concat(ptr @.str388, ptr %t36)
  %t38 = call ptr @fn_emit_bind(ptr %t37)
  %t39 = call ptr @fn_val(ptr %t38, ptr @.str391)
  store ptr %t39, ptr %retval
  br label %ret
ifend5:
  %t40 = load ptr, ptr %t0
  %t41 = call i32 @fn_str_eq(ptr %t40, ptr @.str392)
  %t42 = icmp ne i32 %t41, 0
  br i1 %t42, label %then6, label %ifend8
then6:
  %t43 = load ptr, ptr %t1
  %t44 = call ptr @fn_arg_code(ptr %t43, i32 0)
  store ptr %t44, ptr %t45
  %t46 = load ptr, ptr %t1
  %t47 = call ptr @fn_arg_code(ptr %t46, i32 1)
  store ptr %t47, ptr %t48
  %t49 = load ptr, ptr %t45
  %t50 = load ptr, ptr %t48
  %t51 = call ptr @fn_emit_gep_i8(ptr %t49, ptr %t50)
  store ptr %t51, ptr %t52
  %t53 = load ptr, ptr %t52
  %t54 = call ptr @fn_str_concat(ptr @.str393, ptr %t53)
  %t55 = call ptr @fn_emit_bind(ptr %t54)
  store ptr %t55, ptr %t56
  %t57 = load ptr, ptr %t56
  %t58 = call ptr @fn_str_concat(ptr %t57, ptr @.str395)
  %t59 = call ptr @fn_str_concat(ptr @.str394, ptr %t58)
  %t60 = call ptr @fn_emit_bind(ptr %t59)
  %t61 = call ptr @fn_val(ptr %t60, ptr @.str396)
  store ptr %t61, ptr %retval
  br label %ret
ifend8:
  %t62 = load ptr, ptr %t0
  %t63 = call i32 @fn_str_eq(ptr %t62, ptr @.str397)
  %t64 = icmp ne i32 %t63, 0
  br i1 %t64, label %then9, label %ifend11
then9:
  %t65 = load ptr, ptr %t1
  %t66 = call ptr @fn_arg_code(ptr %t65, i32 0)
  store ptr %t66, ptr %t67
  %t68 = load ptr, ptr %t1
  %t69 = call ptr @fn_arg_code(ptr %t68, i32 1)
  store ptr %t69, ptr %t70
  %t71 = load ptr, ptr %t1
  %t72 = call ptr @fn_arg_code(ptr %t71, i32 2)
  store ptr %t72, ptr %t73
  %t74 = load ptr, ptr %t67
  %t75 = load ptr, ptr %t70
  %t76 = call ptr @fn_emit_gep_i8(ptr %t74, ptr %t75)
  store ptr %t76, ptr %t77
  %t78 = load ptr, ptr %t73
  %t79 = call ptr @fn_str_concat(ptr %t78, ptr @.str399)
  %t80 = call ptr @fn_str_concat(ptr @.str398, ptr %t79)
  %t81 = call ptr @fn_emit_bind(ptr %t80)
  store ptr %t81, ptr %t82
  call void @fn_emit(ptr @.str400)
  %t83 = load ptr, ptr %t82
  call void @fn_emit(ptr %t83)
  call void @fn_emit(ptr @.str401)
  %t84 = load ptr, ptr %t77
  call void @fn_emit(ptr %t84)
  call void @fn_emit(ptr @.str402)
  %t85 = call ptr @fn_val(ptr @.str403, ptr @.str404)
  store ptr %t85, ptr %retval
  br label %ret
ifend11:
  %t86 = load ptr, ptr %t0
  %t87 = call i32 @fn_str_eq(ptr %t86, ptr @.str405)
  %t88 = icmp ne i32 %t87, 0
  br i1 %t88, label %then12, label %ifend14
then12:
  %t89 = load ptr, ptr %t1
  %t90 = call ptr @fn_arg_code(ptr %t89, i32 0)
  store ptr %t90, ptr %t91
  %t92 = load ptr, ptr %t1
  %t93 = call ptr @fn_arg_code(ptr %t92, i32 1)
  store ptr %t93, ptr %t94
  %t95 = load ptr, ptr %t91
  %t96 = load ptr, ptr %t94
  %t97 = call ptr @fn_str_concat(ptr %t96, ptr @.str408)
  %t98 = call ptr @fn_str_concat(ptr @.str407, ptr %t97)
  %t99 = call ptr @fn_str_concat(ptr %t95, ptr %t98)
  %t100 = call ptr @fn_str_concat(ptr @.str406, ptr %t99)
  %t101 = call ptr @fn_emit_bind(ptr %t100)
  %t102 = call ptr @fn_val(ptr %t101, ptr @.str409)
  store ptr %t102, ptr %retval
  br label %ret
ifend14:
  %t104 = load ptr, ptr %t0
  %t105 = call i32 @fn_str_eq(ptr %t104, ptr @.str410)
  %t106 = icmp ne i32 %t105, 0
  %t107 = zext i1 %t106 to i32
  store i32 %t107, ptr %t103
  br i1 %t106, label %scend16, label %sc15
sc15:
  %t108 = load ptr, ptr %t0
  %t109 = call i32 @fn_str_eq(ptr %t108, ptr @.str411)
  %t110 = icmp ne i32 %t109, 0
  %t111 = zext i1 %t110 to i32
  store i32 %t111, ptr %t103
  br label %scend16
scend16:
  %t112 = load i32, ptr %t103
  %t113 = icmp ne i32 %t112, 0
  br i1 %t113, label %then17, label %ifend19
then17:
  %t114 = load ptr, ptr %t1
  %t115 = call ptr @fn_arg_code(ptr %t114, i32 0)
  store ptr %t115, ptr %t116
  %t117 = load ptr, ptr %t1
  %t118 = call ptr @fn_arg_code(ptr %t117, i32 1)
  store ptr %t118, ptr %t119
  %t120 = load ptr, ptr %t1
  %t121 = call ptr @fn_arg_code(ptr %t120, i32 2)
  store ptr %t121, ptr %t122
  %t123 = load ptr, ptr %t122
  %t124 = call ptr @fn_str_concat(ptr %t123, ptr @.str413)
  %t125 = call ptr @fn_str_concat(ptr @.str412, ptr %t124)
  %t126 = call ptr @fn_emit_bind(ptr %t125)
  store ptr %t126, ptr %t127
  store ptr @.str414, ptr %t128
  %t129 = load ptr, ptr %t0
  %t130 = call i32 @fn_str_eq(ptr %t129, ptr @.str415)
  %t131 = icmp ne i32 %t130, 0
  br i1 %t131, label %then20, label %ifend22
then20:
  store ptr @.str416, ptr %t128
  br label %ifend22
ifend22:
  %t132 = load ptr, ptr %t128
  %t133 = load ptr, ptr %t119
  %t134 = load ptr, ptr %t127
  %t135 = load ptr, ptr %t116
  %t136 = call ptr @fn_str_concat(ptr %t135, ptr @.str421)
  %t137 = call ptr @fn_str_concat(ptr @.str420, ptr %t136)
  %t138 = call ptr @fn_str_concat(ptr %t134, ptr %t137)
  %t139 = call ptr @fn_str_concat(ptr @.str419, ptr %t138)
  %t140 = call ptr @fn_str_concat(ptr %t133, ptr %t139)
  %t141 = call ptr @fn_str_concat(ptr @.str418, ptr %t140)
  %t142 = call ptr @fn_str_concat(ptr %t132, ptr %t141)
  %t143 = call ptr @fn_str_concat(ptr @.str417, ptr %t142)
  %t144 = call ptr @fn_emit_bind(ptr %t143)
  store ptr %t144, ptr %t145
  %t146 = load ptr, ptr %t145
  %t147 = call ptr @fn_str_concat(ptr %t146, ptr @.str423)
  %t148 = call ptr @fn_str_concat(ptr @.str422, ptr %t147)
  %t149 = call ptr @fn_emit_bind(ptr %t148)
  %t150 = call ptr @fn_val(ptr %t149, ptr @.str424)
  store ptr %t150, ptr %retval
  br label %ret
ifend19:
  %t151 = load ptr, ptr %t0
  %t152 = call i32 @fn_str_eq(ptr %t151, ptr @.str425)
  %t153 = icmp ne i32 %t152, 0
  br i1 %t153, label %then23, label %ifend25
then23:
  %t154 = load ptr, ptr %t1
  %t155 = call ptr @fn_arg_code(ptr %t154, i32 0)
  store ptr %t155, ptr %t156
  %t157 = load ptr, ptr %t1
  %t158 = call ptr @fn_arg_code(ptr %t157, i32 1)
  store ptr %t158, ptr %t159
  %t160 = load ptr, ptr %t1
  %t161 = call ptr @fn_arg_code(ptr %t160, i32 2)
  store ptr %t161, ptr %t162
  %t163 = load ptr, ptr %t159
  %t164 = call ptr @fn_str_concat(ptr %t163, ptr @.str427)
  %t165 = call ptr @fn_str_concat(ptr @.str426, ptr %t164)
  %t166 = call ptr @fn_emit_bind(ptr %t165)
  store ptr %t166, ptr %t167
  %t168 = load ptr, ptr %t156
  %t169 = load ptr, ptr %t167
  %t170 = load ptr, ptr %t162
  %t171 = call ptr @fn_str_concat(ptr %t170, ptr @.str431)
  %t172 = call ptr @fn_str_concat(ptr @.str430, ptr %t171)
  %t173 = call ptr @fn_str_concat(ptr %t169, ptr %t172)
  %t174 = call ptr @fn_str_concat(ptr @.str429, ptr %t173)
  %t175 = call ptr @fn_str_concat(ptr %t168, ptr %t174)
  %t176 = call ptr @fn_str_concat(ptr @.str428, ptr %t175)
  %t177 = call ptr @fn_emit_bind(ptr %t176)
  %t178 = call ptr @fn_val(ptr %t177, ptr @.str432)
  store ptr %t178, ptr %retval
  br label %ret
ifend25:
  %t179 = load ptr, ptr %t0
  %t180 = call i32 @fn_str_eq(ptr %t179, ptr @.str433)
  %t181 = icmp ne i32 %t180, 0
  br i1 %t181, label %then26, label %ifend28
then26:
  %t182 = load ptr, ptr %t1
  %t183 = call ptr @fn_arg_code(ptr %t182, i32 0)
  store ptr %t183, ptr %t184
  %t185 = load ptr, ptr %t184
  %t186 = call ptr @fn_str_concat(ptr %t185, ptr @.str435)
  %t187 = call ptr @fn_str_concat(ptr @.str434, ptr %t186)
  %t188 = call ptr @fn_emit_bind(ptr %t187)
  store ptr %t188, ptr %t189
  %t190 = load ptr, ptr %t189
  %t191 = call ptr @fn_str_concat(ptr %t190, ptr @.str437)
  %t192 = call ptr @fn_str_concat(ptr @.str436, ptr %t191)
  %t193 = call ptr @fn_emit_bind(ptr %t192)
  %t194 = call ptr @fn_val(ptr %t193, ptr @.str438)
  store ptr %t194, ptr %retval
  br label %ret
ifend28:
  %t195 = load ptr, ptr %t0
  %t196 = call i32 @fn_str_eq(ptr %t195, ptr @.str439)
  %t197 = icmp ne i32 %t196, 0
  br i1 %t197, label %then29, label %ifend31
then29:
  %t198 = load ptr, ptr %t1
  %t199 = call ptr @fn_arg_code(ptr %t198, i32 0)
  store ptr %t199, ptr %t200
  call void @fn_emit(ptr @.str440)
  %t201 = load ptr, ptr %t200
  call void @fn_emit(ptr %t201)
  call void @fn_emit(ptr @.str441)
  %t202 = call ptr @fn_val(ptr @.str442, ptr @.str443)
  store ptr %t202, ptr %retval
  br label %ret
ifend31:
  %t203 = load ptr, ptr %t0
  %t204 = call i32 @fn_str_eq(ptr %t203, ptr @.str444)
  %t205 = icmp ne i32 %t204, 0
  br i1 %t205, label %then32, label %ifend34
then32:
  %t206 = load ptr, ptr %t1
  %t207 = call ptr @fn_arg_code(ptr %t206, i32 0)
  store ptr %t207, ptr %t208
  call void @fn_emit(ptr @.str445)
  %t209 = load ptr, ptr %t208
  call void @fn_emit(ptr %t209)
  call void @fn_emit(ptr @.str446)
  %t210 = call ptr @fn_val(ptr @.str447, ptr @.str448)
  store ptr %t210, ptr %retval
  br label %ret
ifend34:
  %t211 = load ptr, ptr %t0
  %t212 = call i32 @fn_str_eq(ptr %t211, ptr @.str449)
  %t213 = icmp ne i32 %t212, 0
  br i1 %t213, label %then35, label %ifend37
then35:
  %t214 = load ptr, ptr %t1
  %t215 = call ptr @fn_arg_code(ptr %t214, i32 0)
  store ptr %t215, ptr %t216
  call void @fn_emit(ptr @.str450)
  %t217 = load ptr, ptr %t216
  call void @fn_emit(ptr %t217)
  call void @fn_emit(ptr @.str451)
  %t218 = call ptr @fn_val(ptr @.str452, ptr @.str453)
  store ptr %t218, ptr %retval
  br label %ret
ifend37:
  %t219 = load ptr, ptr %t0
  %t220 = call i32 @fn_str_eq(ptr %t219, ptr @.str454)
  %t221 = icmp ne i32 %t220, 0
  br i1 %t221, label %then38, label %ifend40
then38:
  %t222 = call ptr @fn_emit_bind(ptr @.str455)
  %t223 = call ptr @fn_val(ptr %t222, ptr @.str456)
  store ptr %t223, ptr %retval
  br label %ret
ifend40:
  %t224 = load ptr, ptr %t0
  %t225 = call i32 @fn_str_eq(ptr %t224, ptr @.str457)
  %t226 = icmp ne i32 %t225, 0
  br i1 %t226, label %then41, label %ifend43
then41:
  %t227 = load ptr, ptr %t1
  %t228 = call ptr @fn_arg_code(ptr %t227, i32 0)
  store ptr %t228, ptr %t229
  %t230 = call ptr @fn_emit_bind(ptr @.str458)
  store ptr %t230, ptr %t231
  %t232 = load ptr, ptr %t231
  %t233 = load ptr, ptr %t229
  %t234 = call ptr @fn_str_concat(ptr @.str460, ptr %t233)
  %t235 = call ptr @fn_str_concat(ptr %t232, ptr %t234)
  %t236 = call ptr @fn_str_concat(ptr @.str459, ptr %t235)
  %t237 = call ptr @fn_emit_bind(ptr %t236)
  store ptr %t237, ptr %t238
  %t239 = load ptr, ptr %t238
  %t240 = call ptr @fn_str_concat(ptr @.str461, ptr %t239)
  %t241 = call ptr @fn_emit_bind(ptr %t240)
  %t242 = call ptr @fn_val(ptr %t241, ptr @.str462)
  store ptr %t242, ptr %retval
  br label %ret
ifend43:
  %t243 = load ptr, ptr %t0
  %t244 = call i32 @fn_str_eq(ptr %t243, ptr @.str463)
  %t245 = icmp ne i32 %t244, 0
  br i1 %t245, label %then44, label %ifend46
then44:
  %t246 = load ptr, ptr %t1
  %t247 = call ptr @fn_arg_code(ptr %t246, i32 0)
  store ptr %t247, ptr %t248
  call void @fn_emit(ptr @.str464)
  %t249 = load ptr, ptr %t248
  call void @fn_emit(ptr %t249)
  call void @fn_emit(ptr @.str465)
  call void @fn_emit(ptr @.str466)
  store i32 1, ptr @g_g_term
  %t250 = call ptr @fn_val(ptr @.str467, ptr @.str468)
  store ptr %t250, ptr %retval
  br label %ret
ifend46:
  %t251 = load ptr, ptr %t0
  %t252 = call i32 @fn_str_eq(ptr %t251, ptr @.str469)
  %t253 = icmp ne i32 %t252, 0
  br i1 %t253, label %then47, label %ifend49
then47:
  %t254 = call ptr @fn_emit_bind(ptr @.str470)
  %t255 = call ptr @fn_val(ptr %t254, ptr @.str471)
  store ptr %t255, ptr %retval
  br label %ret
ifend49:
  %t256 = load ptr, ptr %t0
  %t257 = call i32 @fn_str_eq(ptr %t256, ptr @.str472)
  %t258 = icmp ne i32 %t257, 0
  br i1 %t258, label %then50, label %ifend52
then50:
  %t259 = load ptr, ptr %t1
  %t260 = call ptr @fn_arg_code(ptr %t259, i32 0)
  store ptr %t260, ptr %t261
  %t262 = load ptr, ptr %t261
  %t263 = call ptr @fn_str_concat(ptr %t262, ptr @.str474)
  %t264 = call ptr @fn_str_concat(ptr @.str473, ptr %t263)
  %t265 = call ptr @fn_emit_bind(ptr %t264)
  %t266 = call ptr @fn_val(ptr %t265, ptr @.str475)
  store ptr %t266, ptr %retval
  br label %ret
ifend52:
  %t267 = load ptr, ptr %t0
  %t268 = call i32 @fn_str_eq(ptr %t267, ptr @.str476)
  %t269 = icmp ne i32 %t268, 0
  br i1 %t269, label %then53, label %ifend55
then53:
  %t270 = load ptr, ptr %t1
  %t271 = call ptr @fn_arg_code(ptr %t270, i32 0)
  store ptr %t271, ptr %t272
  %t273 = load ptr, ptr %t272
  %t274 = call ptr @fn_str_concat(ptr %t273, ptr @.str478)
  %t275 = call ptr @fn_str_concat(ptr @.str477, ptr %t274)
  %t276 = call ptr @fn_emit_bind(ptr %t275)
  %t277 = call ptr @fn_val(ptr %t276, ptr @.str479)
  store ptr %t277, ptr %retval
  br label %ret
ifend55:
  %t278 = load ptr, ptr %t0
  %t279 = call i32 @fn_str_eq(ptr %t278, ptr @.str480)
  %t280 = icmp ne i32 %t279, 0
  br i1 %t280, label %then56, label %ifend58
then56:
  %t281 = load ptr, ptr %t1
  %t282 = call ptr @fn_arg_code(ptr %t281, i32 0)
  store ptr %t282, ptr %t283
  %t284 = load ptr, ptr %t1
  %t285 = call ptr @fn_arg_code(ptr %t284, i32 1)
  store ptr %t285, ptr %t286
  %t287 = call ptr @fn_nreg()
  store ptr %t287, ptr %t288
  call void @fn_emit(ptr @.str481)
  %t289 = load ptr, ptr %t288
  call void @fn_emit(ptr %t289)
  call void @fn_emit(ptr @.str482)
  %t290 = load ptr, ptr %t283
  call void @fn_emit(ptr %t290)
  call void @fn_emit(ptr @.str483)
  %t291 = load ptr, ptr %t286
  call void @fn_emit(ptr %t291)
  call void @fn_emit(ptr @.str484)
  %t292 = load ptr, ptr %t288
  %t293 = call ptr @fn_str_concat(ptr @.str485, ptr %t292)
  %t294 = call ptr @fn_emit_bind(ptr %t293)
  %t295 = call ptr @fn_val(ptr %t294, ptr @.str486)
  store ptr %t295, ptr %retval
  br label %ret
ifend58:
  %t296 = load ptr, ptr %t0
  %t297 = call i32 @fn_str_eq(ptr %t296, ptr @.str487)
  %t298 = icmp ne i32 %t297, 0
  br i1 %t298, label %then59, label %ifend61
then59:
  %t299 = load ptr, ptr %t1
  %t300 = call ptr @fn_arg_code(ptr %t299, i32 0)
  store ptr %t300, ptr %t301
  %t302 = load ptr, ptr %t1
  %t303 = call ptr @fn_arg_code(ptr %t302, i32 1)
  store ptr %t303, ptr %t304
  %t305 = load ptr, ptr %t1
  %t306 = call ptr @fn_arg_code(ptr %t305, i32 2)
  store ptr %t306, ptr %t307
  %t308 = call ptr @fn_nreg()
  store ptr %t308, ptr %t309
  call void @fn_emit(ptr @.str488)
  %t310 = load ptr, ptr %t309
  call void @fn_emit(ptr %t310)
  call void @fn_emit(ptr @.str489)
  %t311 = load ptr, ptr %t301
  call void @fn_emit(ptr %t311)
  call void @fn_emit(ptr @.str490)
  %t312 = load ptr, ptr %t304
  call void @fn_emit(ptr %t312)
  call void @fn_emit(ptr @.str491)
  call void @fn_emit(ptr @.str492)
  %t313 = load ptr, ptr %t307
  call void @fn_emit(ptr %t313)
  call void @fn_emit(ptr @.str493)
  %t314 = load ptr, ptr %t309
  call void @fn_emit(ptr %t314)
  call void @fn_emit(ptr @.str494)
  %t315 = call ptr @fn_val(ptr @.str495, ptr @.str496)
  store ptr %t315, ptr %retval
  br label %ret
ifend61:
  store i32 0, ptr @g_g_intrin_ok
  %t316 = call ptr @fn_val(ptr @.str497, ptr @.str498)
  store ptr %t316, ptr %retval
  br label %ret
ret:
  %t317 = load ptr, ptr %retval
  ret ptr %t317
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
  %t4 = call i32 @fn_str_eq(ptr %t3, ptr @.str499)
  %t5 = icmp ne i32 %t4, 0
  %t6 = zext i1 %t5 to i32
  store i32 %t6, ptr %t2
  br i1 %t5, label %scend1, label %sc0
sc0:
  %t7 = load ptr, ptr %t0
  %t8 = call i32 @fn_str_eq(ptr %t7, ptr @.str500)
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
  %t15 = call i32 @fn_str_eq(ptr %t14, ptr @.str501)
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
  %t23 = call i32 @fn_str_eq(ptr %t22, ptr @.str502)
  %t24 = icmp ne i32 %t23, 0
  %t25 = zext i1 %t24 to i32
  store i32 %t25, ptr %t21
  br i1 %t24, label %scend8, label %sc7
sc7:
  %t26 = load ptr, ptr %t0
  %t27 = call i32 @fn_str_eq(ptr %t26, ptr @.str503)
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
  %t34 = call i32 @fn_str_eq(ptr %t33, ptr @.str504)
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
  %t41 = call i32 @fn_str_eq(ptr %t40, ptr @.str505)
  %t42 = icmp ne i32 %t41, 0
  %t43 = zext i1 %t42 to i32
  store i32 %t43, ptr %t39
  br i1 %t42, label %scend15, label %sc14
sc14:
  %t44 = load ptr, ptr %t0
  %t45 = call i32 @fn_str_eq(ptr %t44, ptr @.str506)
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
  %t54 = call i32 @fn_str_eq(ptr %t53, ptr @.str507)
  %t55 = icmp ne i32 %t54, 0
  %t56 = zext i1 %t55 to i32
  store i32 %t56, ptr %t52
  br i1 %t55, label %scend20, label %sc19
sc19:
  %t57 = load ptr, ptr %t0
  %t58 = call i32 @fn_str_eq(ptr %t57, ptr @.str508)
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
  %t65 = call i32 @fn_str_eq(ptr %t64, ptr @.str509)
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
  %t72 = call i32 @fn_str_eq(ptr %t71, ptr @.str510)
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
  %t79 = call i32 @fn_str_eq(ptr %t78, ptr @.str511)
  %t80 = icmp ne i32 %t79, 0
  %t81 = zext i1 %t80 to i32
  store i32 %t81, ptr %t77
  br i1 %t80, label %scend29, label %sc28
sc28:
  %t82 = load ptr, ptr %t0
  %t83 = call i32 @fn_str_eq(ptr %t82, ptr @.str512)
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
  %t90 = call i32 @fn_str_eq(ptr %t89, ptr @.str513)
  %t91 = icmp ne i32 %t90, 0
  %t92 = zext i1 %t91 to i32
  store i32 %t92, ptr %t88
  br i1 %t91, label %scend34, label %sc33
sc33:
  %t93 = load ptr, ptr %t0
  %t94 = call i32 @fn_str_eq(ptr %t93, ptr @.str514)
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
  %t102 = call i32 @fn_str_eq(ptr %t101, ptr @.str515)
  %t103 = icmp ne i32 %t102, 0
  %t104 = zext i1 %t103 to i32
  store i32 %t104, ptr %t100
  br i1 %t103, label %scend39, label %sc38
sc38:
  %t105 = load ptr, ptr %t0
  %t106 = call i32 @fn_str_eq(ptr %t105, ptr @.str516)
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
  %t113 = call i32 @fn_str_eq(ptr %t112, ptr @.str517)
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
  %t120 = call i32 @fn_str_eq(ptr %t119, ptr @.str518)
  %t121 = icmp ne i32 %t120, 0
  %t122 = zext i1 %t121 to i32
  store i32 %t122, ptr %t118
  br i1 %t121, label %scend46, label %sc45
sc45:
  %t123 = load ptr, ptr %t0
  %t124 = call i32 @fn_str_eq(ptr %t123, ptr @.str519)
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
  %t3 = call i32 @fn_str_eq(ptr %t2, ptr @.str520)
  %t4 = icmp ne i32 %t3, 0
  br i1 %t4, label %then0, label %ifend2
then0:
  %t5 = load ptr, ptr %t1
  %t6 = call ptr @fn_arg_code(ptr %t5, i32 0)
  store ptr %t6, ptr %t7
  call void @fn_emit(ptr @.str521)
  %t8 = load ptr, ptr %t7
  call void @fn_emit(ptr %t8)
  call void @fn_emit(ptr @.str522)
  %t9 = call ptr @fn_val(ptr @.str523, ptr @.str524)
  store ptr %t9, ptr %retval
  br label %ret
ifend2:
  %t10 = load ptr, ptr %t0
  %t11 = call i32 @fn_str_eq(ptr %t10, ptr @.str525)
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
  %t23 = call ptr @fn_str_concat(ptr %t22, ptr @.str527)
  %t24 = call ptr @fn_str_concat(ptr @.str526, ptr %t23)
  %t25 = call ptr @fn_emit_bind(ptr %t24)
  store ptr %t25, ptr %t26
  call void @fn_emit(ptr @.str528)
  %t27 = load ptr, ptr %t15
  call void @fn_emit(ptr %t27)
  call void @fn_emit(ptr @.str529)
  %t28 = load ptr, ptr %t18
  call void @fn_emit(ptr %t28)
  call void @fn_emit(ptr @.str530)
  %t29 = load ptr, ptr %t26
  call void @fn_emit(ptr %t29)
  call void @fn_emit(ptr @.str531)
  %t30 = call ptr @fn_val(ptr @.str532, ptr @.str533)
  store ptr %t30, ptr %retval
  br label %ret
ifend5:
  %t31 = load ptr, ptr %t0
  %t32 = call i32 @fn_str_eq(ptr %t31, ptr @.str534)
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
  %t44 = call ptr @fn_str_concat(ptr %t43, ptr @.str536)
  %t45 = call ptr @fn_str_concat(ptr @.str535, ptr %t44)
  %t46 = call ptr @fn_emit_bind(ptr %t45)
  store ptr %t46, ptr %t47
  call void @fn_emit(ptr @.str537)
  %t48 = load ptr, ptr %t36
  call void @fn_emit(ptr %t48)
  call void @fn_emit(ptr @.str538)
  %t49 = load ptr, ptr %t39
  call void @fn_emit(ptr %t49)
  call void @fn_emit(ptr @.str539)
  %t50 = load ptr, ptr %t47
  call void @fn_emit(ptr %t50)
  call void @fn_emit(ptr @.str540)
  %t51 = call ptr @fn_val(ptr @.str541, ptr @.str542)
  store ptr %t51, ptr %retval
  br label %ret
ifend8:
  %t52 = load ptr, ptr %t0
  %t53 = call i32 @fn_str_eq(ptr %t52, ptr @.str543)
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
  call void @fn_emit(ptr @.str544)
  %t63 = load ptr, ptr %t62
  call void @fn_emit(ptr %t63)
  call void @fn_emit(ptr @.str545)
  %t64 = load ptr, ptr %t57
  call void @fn_emit(ptr %t64)
  call void @fn_emit(ptr @.str546)
  %t65 = load ptr, ptr %t60
  call void @fn_emit(ptr %t65)
  call void @fn_emit(ptr @.str547)
  %t66 = load ptr, ptr %t62
  %t67 = call ptr @fn_val(ptr %t66, ptr @.str548)
  store ptr %t67, ptr %retval
  br label %ret
ifend11:
  %t68 = load ptr, ptr %t0
  %t69 = call i32 @fn_str_eq(ptr %t68, ptr @.str549)
  %t70 = icmp ne i32 %t69, 0
  br i1 %t70, label %then12, label %ifend14
then12:
  %t71 = call ptr @fn_emit_bind(ptr @.str550)
  %t72 = call ptr @fn_val(ptr %t71, ptr @.str551)
  store ptr %t72, ptr %retval
  br label %ret
ifend14:
  %t73 = load ptr, ptr %t0
  %t74 = call i32 @fn_str_eq(ptr %t73, ptr @.str552)
  %t75 = icmp ne i32 %t74, 0
  br i1 %t75, label %then15, label %ifend17
then15:
  %t76 = load ptr, ptr %t1
  %t77 = call ptr @fn_arg_code(ptr %t76, i32 0)
  store ptr %t77, ptr %t78
  call void @fn_emit(ptr @.str553)
  %t79 = load ptr, ptr %t78
  call void @fn_emit(ptr %t79)
  call void @fn_emit(ptr @.str554)
  %t80 = call ptr @fn_val(ptr @.str555, ptr @.str556)
  store ptr %t80, ptr %retval
  br label %ret
ifend17:
  %t81 = load ptr, ptr %t0
  %t82 = call i32 @fn_str_eq(ptr %t81, ptr @.str557)
  %t83 = icmp ne i32 %t82, 0
  br i1 %t83, label %then18, label %ifend20
then18:
  %t84 = load ptr, ptr %t1
  %t85 = call ptr @fn_arg_code(ptr %t84, i32 0)
  store ptr %t85, ptr %t86
  %t87 = load ptr, ptr %t86
  %t88 = call ptr @fn_str_concat(ptr %t87, ptr @.str559)
  %t89 = call ptr @fn_str_concat(ptr @.str558, ptr %t88)
  %t90 = call ptr @fn_emit_bind(ptr %t89)
  store ptr %t90, ptr %t91
  %t92 = load ptr, ptr %t91
  %t93 = call ptr @fn_str_concat(ptr %t92, ptr @.str561)
  %t94 = call ptr @fn_str_concat(ptr @.str560, ptr %t93)
  %t95 = call ptr @fn_emit_bind(ptr %t94)
  %t96 = call ptr @fn_val(ptr %t95, ptr @.str562)
  store ptr %t96, ptr %retval
  br label %ret
ifend20:
  %t97 = load ptr, ptr %t0
  %t98 = call i32 @fn_str_eq(ptr %t97, ptr @.str563)
  %t99 = icmp ne i32 %t98, 0
  br i1 %t99, label %then21, label %ifend23
then21:
  %t100 = call ptr @fn_emit_bind(ptr @.str564)
  store ptr %t100, ptr %t101
  %t102 = load ptr, ptr %t101
  %t103 = call ptr @fn_str_concat(ptr %t102, ptr @.str566)
  %t104 = call ptr @fn_str_concat(ptr @.str565, ptr %t103)
  %t105 = call ptr @fn_emit_bind(ptr %t104)
  %t106 = call ptr @fn_val(ptr %t105, ptr @.str567)
  store ptr %t106, ptr %retval
  br label %ret
ifend23:
  %t107 = load ptr, ptr %t0
  %t108 = call i32 @fn_str_eq(ptr %t107, ptr @.str568)
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
  call void @fn_emit(ptr @.str569)
  %t118 = load ptr, ptr %t117
  call void @fn_emit(ptr %t118)
  call void @fn_emit(ptr @.str570)
  %t119 = load ptr, ptr %t112
  call void @fn_emit(ptr %t119)
  call void @fn_emit(ptr @.str571)
  %t120 = load ptr, ptr %t115
  call void @fn_emit(ptr %t120)
  call void @fn_emit(ptr @.str572)
  %t121 = load ptr, ptr %t117
  %t122 = call ptr @fn_str_concat(ptr @.str573, ptr %t121)
  %t123 = call ptr @fn_emit_bind(ptr %t122)
  %t124 = call ptr @fn_val(ptr %t123, ptr @.str574)
  store ptr %t124, ptr %retval
  br label %ret
ifend26:
  %t125 = load ptr, ptr %t0
  %t126 = call i32 @fn_str_eq(ptr %t125, ptr @.str575)
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
  call void @fn_emit(ptr @.str576)
  %t139 = load ptr, ptr %t138
  call void @fn_emit(ptr %t139)
  call void @fn_emit(ptr @.str577)
  %t140 = load ptr, ptr %t130
  call void @fn_emit(ptr %t140)
  call void @fn_emit(ptr @.str578)
  %t141 = load ptr, ptr %t133
  call void @fn_emit(ptr %t141)
  call void @fn_emit(ptr @.str579)
  call void @fn_emit(ptr @.str580)
  %t142 = load ptr, ptr %t136
  call void @fn_emit(ptr %t142)
  call void @fn_emit(ptr @.str581)
  %t143 = load ptr, ptr %t138
  call void @fn_emit(ptr %t143)
  call void @fn_emit(ptr @.str582)
  %t144 = call ptr @fn_val(ptr @.str583, ptr @.str584)
  store ptr %t144, ptr %retval
  br label %ret
ifend29:
  %t145 = load ptr, ptr %t0
  %t146 = call i32 @fn_str_eq(ptr %t145, ptr @.str585)
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
  call void @fn_emit(ptr @.str586)
  %t156 = load ptr, ptr %t155
  call void @fn_emit(ptr %t156)
  call void @fn_emit(ptr @.str587)
  %t157 = load ptr, ptr %t150
  call void @fn_emit(ptr %t157)
  call void @fn_emit(ptr @.str588)
  %t158 = load ptr, ptr %t153
  call void @fn_emit(ptr %t158)
  call void @fn_emit(ptr @.str589)
  %t159 = load ptr, ptr %t155
  %t160 = call ptr @fn_str_concat(ptr @.str590, ptr %t159)
  %t161 = call ptr @fn_emit_bind(ptr %t160)
  %t162 = call ptr @fn_val(ptr %t161, ptr @.str591)
  store ptr %t162, ptr %retval
  br label %ret
ifend32:
  %t163 = load ptr, ptr %t0
  %t164 = call i32 @fn_str_eq(ptr %t163, ptr @.str592)
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
  call void @fn_emit(ptr @.str593)
  %t177 = load ptr, ptr %t176
  call void @fn_emit(ptr %t177)
  call void @fn_emit(ptr @.str594)
  %t178 = load ptr, ptr %t168
  call void @fn_emit(ptr %t178)
  call void @fn_emit(ptr @.str595)
  %t179 = load ptr, ptr %t171
  call void @fn_emit(ptr %t179)
  call void @fn_emit(ptr @.str596)
  call void @fn_emit(ptr @.str597)
  %t180 = load ptr, ptr %t174
  call void @fn_emit(ptr %t180)
  call void @fn_emit(ptr @.str598)
  %t181 = load ptr, ptr %t176
  call void @fn_emit(ptr %t181)
  call void @fn_emit(ptr @.str599)
  %t182 = call ptr @fn_val(ptr @.str600, ptr @.str601)
  store ptr %t182, ptr %retval
  br label %ret
ifend35:
  %t183 = load ptr, ptr %t0
  %t184 = call i32 @fn_str_eq(ptr %t183, ptr @.str602)
  %t185 = icmp ne i32 %t184, 0
  br i1 %t185, label %then36, label %ifend38
then36:
  %t186 = load ptr, ptr %t1
  %t187 = getelementptr inbounds %Cmp_Node, ptr %t186, i32 0, i32 7
  %t188 = load ptr, ptr %t187
  %t189 = getelementptr inbounds %LSlice, ptr %t188, i32 0, i32 0
  %t190 = load ptr, ptr %t189
  %t191 = getelementptr inbounds ptr, ptr %t190, i32 0
  %t192 = load ptr, ptr %t191
  %t193 = call ptr @fn_emit_expr(ptr %t192)
  store ptr %t193, ptr %t194
  %t195 = load ptr, ptr %t194
  %t196 = getelementptr inbounds %Cmp_Val, ptr %t195, i32 0, i32 0
  %t197 = load ptr, ptr %t196
  %t198 = call ptr @fn_val(ptr %t197, ptr @.str603)
  store ptr %t198, ptr %retval
  br label %ret
ifend38:
  %t199 = load ptr, ptr %t0
  %t200 = call i32 @fn_str_eq(ptr %t199, ptr @.str604)
  %t201 = icmp ne i32 %t200, 0
  br i1 %t201, label %then39, label %ifend41
then39:
  %t202 = load ptr, ptr %t1
  %t203 = getelementptr inbounds %Cmp_Node, ptr %t202, i32 0, i32 7
  %t204 = load ptr, ptr %t203
  %t205 = getelementptr inbounds %LSlice, ptr %t204, i32 0, i32 0
  %t206 = load ptr, ptr %t205
  %t207 = getelementptr inbounds ptr, ptr %t206, i32 0
  %t208 = load ptr, ptr %t207
  %t209 = call ptr @fn_emit_expr(ptr %t208)
  store ptr %t209, ptr %t210
  %t211 = load ptr, ptr %t210
  %t212 = getelementptr inbounds %Cmp_Val, ptr %t211, i32 0, i32 0
  %t213 = load ptr, ptr %t212
  %t214 = call ptr @fn_val(ptr %t213, ptr @.str605)
  store ptr %t214, ptr %retval
  br label %ret
ifend41:
  %t215 = load ptr, ptr %t0
  %t216 = call i32 @fn_str_eq(ptr %t215, ptr @.str606)
  %t217 = icmp ne i32 %t216, 0
  br i1 %t217, label %then42, label %ifend44
then42:
  %t218 = load i32, ptr @g_g_windowed
  %t219 = icmp ne i32 %t218, 0
  br i1 %t219, label %then45, label %ifend47
then45:
  %t220 = call ptr @fn_val(ptr @.str607, ptr @.str608)
  store ptr %t220, ptr %retval
  br label %ret
ifend47:
  %t221 = call ptr @fn_val(ptr @.str609, ptr @.str610)
  store ptr %t221, ptr %retval
  br label %ret
ifend44:
  %t222 = load ptr, ptr %t0
  %t223 = call i32 @fn_str_eq(ptr %t222, ptr @.str611)
  %t224 = icmp ne i32 %t223, 0
  br i1 %t224, label %then48, label %ifend50
then48:
  %t225 = call ptr @fn_val(ptr @.str612, ptr @.str613)
  store ptr %t225, ptr %retval
  br label %ret
ifend50:
  %t226 = load ptr, ptr %t0
  %t227 = call i32 @fn_str_eq(ptr %t226, ptr @.str614)
  %t228 = icmp ne i32 %t227, 0
  br i1 %t228, label %then51, label %ifend53
then51:
  %t229 = call ptr @fn_emit_bind(ptr @.str615)
  %t230 = call ptr @fn_val(ptr %t229, ptr @.str616)
  store ptr %t230, ptr %retval
  br label %ret
ifend53:
  %t231 = load ptr, ptr %t0
  %t232 = call i32 @fn_str_eq(ptr %t231, ptr @.str617)
  %t233 = icmp ne i32 %t232, 0
  br i1 %t233, label %then54, label %ifend56
then54:
  %t234 = call ptr @fn_emit_bind(ptr @.str618)
  %t235 = call ptr @fn_val(ptr %t234, ptr @.str619)
  store ptr %t235, ptr %retval
  br label %ret
ifend56:
  %t236 = load ptr, ptr %t0
  %t237 = call i32 @fn_str_eq(ptr %t236, ptr @.str620)
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
  call void @fn_emit(ptr @.str621)
  %t251 = load ptr, ptr %t241
  call void @fn_emit(ptr %t251)
  call void @fn_emit(ptr @.str622)
  %t252 = load ptr, ptr %t244
  call void @fn_emit(ptr %t252)
  call void @fn_emit(ptr @.str623)
  %t253 = load ptr, ptr %t247
  call void @fn_emit(ptr %t253)
  call void @fn_emit(ptr @.str624)
  %t254 = load ptr, ptr %t250
  call void @fn_emit(ptr %t254)
  call void @fn_emit(ptr @.str625)
  %t255 = call ptr @fn_val(ptr @.str626, ptr @.str627)
  store ptr %t255, ptr %retval
  br label %ret
ifend59:
  %t256 = load ptr, ptr %t0
  %t257 = call i32 @fn_str_eq(ptr %t256, ptr @.str628)
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
  call void @fn_emit(ptr @.str629)
  %t268 = load ptr, ptr %t261
  call void @fn_emit(ptr %t268)
  call void @fn_emit(ptr @.str630)
  %t269 = load ptr, ptr %t264
  call void @fn_emit(ptr %t269)
  call void @fn_emit(ptr @.str631)
  %t270 = load ptr, ptr %t267
  call void @fn_emit(ptr %t270)
  call void @fn_emit(ptr @.str632)
  %t271 = call ptr @fn_val(ptr @.str633, ptr @.str634)
  store ptr %t271, ptr %retval
  br label %ret
ifend62:
  %t272 = load ptr, ptr %t0
  %t273 = call i32 @fn_str_eq(ptr %t272, ptr @.str635)
  %t274 = icmp ne i32 %t273, 0
  br i1 %t274, label %then63, label %ifend65
then63:
  call void @fn_emit(ptr @.str636)
  %t275 = call ptr @fn_val(ptr @.str637, ptr @.str638)
  store ptr %t275, ptr %retval
  br label %ret
ifend65:
  %t276 = call ptr @fn_val(ptr @.str639, ptr @.str640)
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
  %t5 = call i32 @fn_str_eq(ptr %t4, ptr @.str641)
  %t6 = icmp ne i32 %t5, 0
  %t7 = zext i1 %t6 to i32
  store i32 %t7, ptr %t3
  br i1 %t6, label %scend1, label %sc0
sc0:
  %t8 = load ptr, ptr %t0
  %t9 = call i32 @fn_str_eq(ptr %t8, ptr @.str642)
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
  %t16 = call i32 @fn_str_eq(ptr %t15, ptr @.str643)
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
  %t23 = call i32 @fn_str_eq(ptr %t22, ptr @.str644)
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
  %t3 = call i32 @fn_str_eq(ptr %t2, ptr @.str645)
  %t4 = icmp ne i32 %t3, 0
  br i1 %t4, label %then0, label %ifend2
then0:
  %t5 = load ptr, ptr %t1
  %t6 = getelementptr inbounds %Cmp_Node, ptr %t5, i32 0, i32 7
  %t7 = load ptr, ptr %t6
  %t8 = getelementptr inbounds %LSlice, ptr %t7, i32 0, i32 0
  %t9 = load ptr, ptr %t8
  %t10 = getelementptr inbounds ptr, ptr %t9, i32 0
  %t11 = load ptr, ptr %t10
  %t12 = call ptr @fn_emit_expr(ptr %t11)
  store ptr %t12, ptr %t13
  %t14 = load ptr, ptr %t13
  %t15 = getelementptr inbounds %Cmp_Val, ptr %t14, i32 0, i32 0
  %t16 = load ptr, ptr %t15
  %t17 = call ptr @fn_str_concat(ptr %t16, ptr @.str647)
  %t18 = call ptr @fn_str_concat(ptr @.str646, ptr %t17)
  %t19 = call ptr @fn_emit_bind(ptr %t18)
  store ptr %t19, ptr %t20
  %t21 = load ptr, ptr %t13
  %t22 = getelementptr inbounds %Cmp_Val, ptr %t21, i32 0, i32 0
  %t23 = load ptr, ptr %t22
  %t24 = call ptr @fn_str_concat(ptr @.str648, ptr %t23)
  %t25 = call ptr @fn_emit_bind(ptr %t24)
  store ptr %t25, ptr %t26
  %t27 = load ptr, ptr %t20
  %t28 = load ptr, ptr %t26
  %t29 = load ptr, ptr %t13
  %t30 = getelementptr inbounds %Cmp_Val, ptr %t29, i32 0, i32 0
  %t31 = load ptr, ptr %t30
  %t32 = call ptr @fn_str_concat(ptr @.str651, ptr %t31)
  %t33 = call ptr @fn_str_concat(ptr %t28, ptr %t32)
  %t34 = call ptr @fn_str_concat(ptr @.str650, ptr %t33)
  %t35 = call ptr @fn_str_concat(ptr %t27, ptr %t34)
  %t36 = call ptr @fn_str_concat(ptr @.str649, ptr %t35)
  %t37 = call ptr @fn_emit_bind(ptr %t36)
  %t38 = call ptr @fn_val(ptr %t37, ptr @.str652)
  store ptr %t38, ptr %retval
  br label %ret
ifend2:
  %t40 = load ptr, ptr %t0
  %t41 = call i32 @fn_str_eq(ptr %t40, ptr @.str653)
  %t42 = icmp ne i32 %t41, 0
  %t43 = zext i1 %t42 to i32
  store i32 %t43, ptr %t39
  br i1 %t42, label %scend4, label %sc3
sc3:
  %t44 = load ptr, ptr %t0
  %t45 = call i32 @fn_str_eq(ptr %t44, ptr @.str654)
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
  %t51 = getelementptr inbounds %Cmp_Node, ptr %t50, i32 0, i32 7
  %t52 = load ptr, ptr %t51
  %t53 = getelementptr inbounds %LSlice, ptr %t52, i32 0, i32 0
  %t54 = load ptr, ptr %t53
  %t55 = getelementptr inbounds ptr, ptr %t54, i32 0
  %t56 = load ptr, ptr %t55
  %t57 = call ptr @fn_emit_expr(ptr %t56)
  store ptr %t57, ptr %t58
  %t59 = load ptr, ptr %t1
  %t60 = getelementptr inbounds %Cmp_Node, ptr %t59, i32 0, i32 7
  %t61 = load ptr, ptr %t60
  %t62 = getelementptr inbounds %LSlice, ptr %t61, i32 0, i32 0
  %t63 = load ptr, ptr %t62
  %t64 = getelementptr inbounds ptr, ptr %t63, i32 1
  %t65 = load ptr, ptr %t64
  %t66 = call ptr @fn_emit_expr(ptr %t65)
  store ptr %t66, ptr %t67
  store ptr @.str655, ptr %t68
  %t69 = load ptr, ptr %t0
  %t70 = call i32 @fn_str_eq(ptr %t69, ptr @.str656)
  %t71 = icmp ne i32 %t70, 0
  br i1 %t71, label %then8, label %ifend10
then8:
  store ptr @.str657, ptr %t68
  br label %ifend10
ifend10:
  %t72 = load ptr, ptr %t68
  %t73 = load ptr, ptr %t58
  %t74 = getelementptr inbounds %Cmp_Val, ptr %t73, i32 0, i32 0
  %t75 = load ptr, ptr %t74
  %t76 = load ptr, ptr %t67
  %t77 = getelementptr inbounds %Cmp_Val, ptr %t76, i32 0, i32 0
  %t78 = load ptr, ptr %t77
  %t79 = call ptr @fn_str_concat(ptr @.str660, ptr %t78)
  %t80 = call ptr @fn_str_concat(ptr %t75, ptr %t79)
  %t81 = call ptr @fn_str_concat(ptr @.str659, ptr %t80)
  %t82 = call ptr @fn_str_concat(ptr %t72, ptr %t81)
  %t83 = call ptr @fn_str_concat(ptr @.str658, ptr %t82)
  %t84 = call ptr @fn_emit_bind(ptr %t83)
  store ptr %t84, ptr %t85
  %t86 = load ptr, ptr %t85
  %t87 = load ptr, ptr %t58
  %t88 = getelementptr inbounds %Cmp_Val, ptr %t87, i32 0, i32 0
  %t89 = load ptr, ptr %t88
  %t90 = load ptr, ptr %t67
  %t91 = getelementptr inbounds %Cmp_Val, ptr %t90, i32 0, i32 0
  %t92 = load ptr, ptr %t91
  %t93 = call ptr @fn_str_concat(ptr @.str663, ptr %t92)
  %t94 = call ptr @fn_str_concat(ptr %t89, ptr %t93)
  %t95 = call ptr @fn_str_concat(ptr @.str662, ptr %t94)
  %t96 = call ptr @fn_str_concat(ptr %t86, ptr %t95)
  %t97 = call ptr @fn_str_concat(ptr @.str661, ptr %t96)
  %t98 = call ptr @fn_emit_bind(ptr %t97)
  %t99 = call ptr @fn_val(ptr %t98, ptr @.str664)
  store ptr %t99, ptr %retval
  br label %ret
ifend7:
  %t100 = load ptr, ptr %t1
  %t101 = getelementptr inbounds %Cmp_Node, ptr %t100, i32 0, i32 7
  %t102 = load ptr, ptr %t101
  %t103 = getelementptr inbounds %LSlice, ptr %t102, i32 0, i32 0
  %t104 = load ptr, ptr %t103
  %t105 = getelementptr inbounds ptr, ptr %t104, i32 0
  %t106 = load ptr, ptr %t105
  %t107 = call ptr @fn_emit_expr(ptr %t106)
  store ptr %t107, ptr %t108
  %t109 = load ptr, ptr %t1
  %t110 = getelementptr inbounds %Cmp_Node, ptr %t109, i32 0, i32 7
  %t111 = load ptr, ptr %t110
  %t112 = getelementptr inbounds %LSlice, ptr %t111, i32 0, i32 0
  %t113 = load ptr, ptr %t112
  %t114 = getelementptr inbounds ptr, ptr %t113, i32 1
  %t115 = load ptr, ptr %t114
  %t116 = call ptr @fn_emit_expr(ptr %t115)
  store ptr %t116, ptr %t117
  %t118 = load ptr, ptr %t1
  %t119 = getelementptr inbounds %Cmp_Node, ptr %t118, i32 0, i32 7
  %t120 = load ptr, ptr %t119
  %t121 = getelementptr inbounds %LSlice, ptr %t120, i32 0, i32 0
  %t122 = load ptr, ptr %t121
  %t123 = getelementptr inbounds ptr, ptr %t122, i32 2
  %t124 = load ptr, ptr %t123
  %t125 = call ptr @fn_emit_expr(ptr %t124)
  store ptr %t125, ptr %t126
  %t127 = load ptr, ptr %t108
  %t128 = getelementptr inbounds %Cmp_Val, ptr %t127, i32 0, i32 0
  %t129 = load ptr, ptr %t128
  %t130 = load ptr, ptr %t126
  %t131 = getelementptr inbounds %Cmp_Val, ptr %t130, i32 0, i32 0
  %t132 = load ptr, ptr %t131
  %t133 = call ptr @fn_str_concat(ptr @.str666, ptr %t132)
  %t134 = call ptr @fn_str_concat(ptr %t129, ptr %t133)
  %t135 = call ptr @fn_str_concat(ptr @.str665, ptr %t134)
  %t136 = call ptr @fn_emit_bind(ptr %t135)
  store ptr %t136, ptr %t137
  %t138 = load ptr, ptr %t137
  %t139 = load ptr, ptr %t108
  %t140 = getelementptr inbounds %Cmp_Val, ptr %t139, i32 0, i32 0
  %t141 = load ptr, ptr %t140
  %t142 = load ptr, ptr %t126
  %t143 = getelementptr inbounds %Cmp_Val, ptr %t142, i32 0, i32 0
  %t144 = load ptr, ptr %t143
  %t145 = call ptr @fn_str_concat(ptr @.str669, ptr %t144)
  %t146 = call ptr @fn_str_concat(ptr %t141, ptr %t145)
  %t147 = call ptr @fn_str_concat(ptr @.str668, ptr %t146)
  %t148 = call ptr @fn_str_concat(ptr %t138, ptr %t147)
  %t149 = call ptr @fn_str_concat(ptr @.str667, ptr %t148)
  %t150 = call ptr @fn_emit_bind(ptr %t149)
  store ptr %t150, ptr %t151
  %t152 = load ptr, ptr %t117
  %t153 = getelementptr inbounds %Cmp_Val, ptr %t152, i32 0, i32 0
  %t154 = load ptr, ptr %t153
  %t155 = load ptr, ptr %t151
  %t156 = call ptr @fn_str_concat(ptr @.str671, ptr %t155)
  %t157 = call ptr @fn_str_concat(ptr %t154, ptr %t156)
  %t158 = call ptr @fn_str_concat(ptr @.str670, ptr %t157)
  %t159 = call ptr @fn_emit_bind(ptr %t158)
  store ptr %t159, ptr %t160
  %t161 = load ptr, ptr %t160
  %t162 = load ptr, ptr %t117
  %t163 = getelementptr inbounds %Cmp_Val, ptr %t162, i32 0, i32 0
  %t164 = load ptr, ptr %t163
  %t165 = load ptr, ptr %t151
  %t166 = call ptr @fn_str_concat(ptr @.str674, ptr %t165)
  %t167 = call ptr @fn_str_concat(ptr %t164, ptr %t166)
  %t168 = call ptr @fn_str_concat(ptr @.str673, ptr %t167)
  %t169 = call ptr @fn_str_concat(ptr %t161, ptr %t168)
  %t170 = call ptr @fn_str_concat(ptr @.str672, ptr %t169)
  %t171 = call ptr @fn_emit_bind(ptr %t170)
  %t172 = call ptr @fn_val(ptr %t171, ptr @.str675)
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
  %t2 = call ptr @fn_str_concat(ptr %t1, ptr @.str677)
  %t3 = call ptr @fn_str_concat(ptr @.str676, ptr %t2)
  %t4 = call ptr @fn_emit_bind(ptr %t3)
  store ptr %t4, ptr %t5
  %t6 = load ptr, ptr %t5
  %t7 = call ptr @fn_str_concat(ptr %t6, ptr @.str679)
  %t8 = call ptr @fn_str_concat(ptr @.str678, ptr %t7)
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
  %t10 = alloca ptr
  %t13 = alloca ptr
  %t18 = alloca ptr
  %t19 = alloca i32
  %t37 = alloca ptr
  %t39 = alloca ptr
  %t49 = alloca ptr
  %t50 = alloca ptr
  %t64 = alloca ptr
  store ptr %arg_name, ptr %t0
  %t1 = load ptr, ptr %t0
  %t2 = call ptr @fn_layout_node(ptr %t1)
  store ptr %t2, ptr %t3
  %t4 = load ptr, ptr %t3
  %t5 = icmp eq ptr %t4, null
  %t6 = zext i1 %t5 to i32
  %t7 = icmp ne i32 %t6, 0
  br i1 %t7, label %then0, label %ifend2
then0:
  call void @fn_perr(ptr @.str680)
  br label %ifend2
ifend2:
  %t8 = load ptr, ptr %t0
  %t9 = call ptr @fn_layout_ty(ptr %t8)
  store ptr %t9, ptr %t10
  %t11 = load ptr, ptr %t10
  %t12 = call ptr @fn_emit_sizeof(ptr %t11)
  store ptr %t12, ptr %t13
  %t14 = load ptr, ptr %t13
  %t15 = call ptr @fn_str_concat(ptr %t14, ptr @.str682)
  %t16 = call ptr @fn_str_concat(ptr @.str681, ptr %t15)
  %t17 = call ptr @fn_emit_bind(ptr %t16)
  store ptr %t17, ptr %t18
  store i32 0, ptr %t19
  br label %wcond3
wcond3:
  %t20 = load i32, ptr %t19
  %t21 = load ptr, ptr %t3
  %t22 = getelementptr inbounds %Cmp_Node, ptr %t21, i32 0, i32 7
  %t23 = load ptr, ptr %t22
  %t24 = getelementptr inbounds %LSlice, ptr %t23, i32 0, i32 1
  %t25 = load i32, ptr %t24
  %t26 = icmp slt i32 %t20, %t25
  %t27 = zext i1 %t26 to i32
  %t28 = icmp ne i32 %t27, 0
  br i1 %t28, label %wbody4, label %wend5
wbody4:
  %t29 = load ptr, ptr %t3
  %t30 = getelementptr inbounds %Cmp_Node, ptr %t29, i32 0, i32 7
  %t31 = load ptr, ptr %t30
  %t32 = getelementptr inbounds %LSlice, ptr %t31, i32 0, i32 0
  %t33 = load ptr, ptr %t32
  %t34 = load i32, ptr %t19
  %t35 = getelementptr inbounds ptr, ptr %t33, i32 %t34
  %t36 = load ptr, ptr %t35
  store ptr %t36, ptr %t37
  %t38 = call ptr @fn_nreg()
  store ptr %t38, ptr %t39
  call void @fn_emit(ptr @.str683)
  %t40 = load ptr, ptr %t39
  call void @fn_emit(ptr %t40)
  call void @fn_emit(ptr @.str684)
  %t41 = load ptr, ptr %t10
  call void @fn_emit(ptr %t41)
  call void @fn_emit(ptr @.str685)
  %t42 = load ptr, ptr %t18
  call void @fn_emit(ptr %t42)
  call void @fn_emit(ptr @.str686)
  %t43 = load i32, ptr %t19
  %t44 = call ptr @fn_itoa(i32 %t43)
  call void @fn_emit(ptr %t44)
  call void @fn_emit(ptr @.str687)
  %t45 = load ptr, ptr %t37
  %t46 = getelementptr inbounds %Cmp_Node, ptr %t45, i32 0, i32 3
  %t47 = load ptr, ptr %t46
  %t48 = call ptr @fn_llty(ptr %t47)
  store ptr %t48, ptr %t49
  store ptr @.str688, ptr %t50
  %t51 = load ptr, ptr %t49
  %t52 = call i32 @fn_str_eq(ptr %t51, ptr @.str689)
  %t53 = icmp ne i32 %t52, 0
  br i1 %t53, label %then6, label %ifend8
then6:
  store ptr @.str690, ptr %t50
  br label %ifend8
ifend8:
  %t54 = load ptr, ptr %t37
  %t55 = getelementptr inbounds %Cmp_Node, ptr %t54, i32 0, i32 4
  %t56 = load ptr, ptr %t55
  %t57 = icmp ne ptr %t56, null
  %t58 = zext i1 %t57 to i32
  %t59 = icmp ne i32 %t58, 0
  br i1 %t59, label %then9, label %ifend11
then9:
  %t60 = load ptr, ptr %t37
  %t61 = getelementptr inbounds %Cmp_Node, ptr %t60, i32 0, i32 4
  %t62 = load ptr, ptr %t61
  %t63 = call ptr @fn_emit_expr(ptr %t62)
  store ptr %t63, ptr %t64
  %t65 = load ptr, ptr %t64
  %t66 = getelementptr inbounds %Cmp_Val, ptr %t65, i32 0, i32 0
  %t67 = load ptr, ptr %t66
  store ptr %t67, ptr %t50
  br label %ifend11
ifend11:
  call void @fn_emit(ptr @.str691)
  %t68 = load ptr, ptr %t49
  call void @fn_emit(ptr %t68)
  call void @fn_emit(ptr @.str692)
  %t69 = load ptr, ptr %t50
  call void @fn_emit(ptr %t69)
  call void @fn_emit(ptr @.str693)
  %t70 = load ptr, ptr %t39
  call void @fn_emit(ptr %t70)
  call void @fn_emit(ptr @.str694)
  %t71 = load i32, ptr %t19
  %t72 = add i32 %t71, 1
  store i32 %t72, ptr %t19
  br label %wcond3
wend5:
  %t73 = load ptr, ptr %t18
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
  %t1 = call ptr @fn_emit_sizeof(ptr @.str695)
  store ptr %t1, ptr %t2
  %t3 = load ptr, ptr %t2
  %t4 = call ptr @fn_str_concat(ptr %t3, ptr @.str697)
  %t5 = call ptr @fn_str_concat(ptr @.str696, ptr %t4)
  %t6 = call ptr @fn_emit_bind(ptr %t5)
  store ptr %t6, ptr %t7
  %t8 = call ptr @fn_nreg()
  store ptr %t8, ptr %t9
  call void @fn_emit(ptr @.str698)
  %t10 = load ptr, ptr %t9
  call void @fn_emit(ptr %t10)
  call void @fn_emit(ptr @.str699)
  %t11 = load ptr, ptr %t7
  call void @fn_emit(ptr %t11)
  call void @fn_emit(ptr @.str700)
  call void @fn_emit(ptr @.str701)
  %t12 = load ptr, ptr %t9
  call void @fn_emit(ptr %t12)
  call void @fn_emit(ptr @.str702)
  %t13 = call ptr @fn_nreg()
  store ptr %t13, ptr %t14
  call void @fn_emit(ptr @.str703)
  %t15 = load ptr, ptr %t14
  call void @fn_emit(ptr %t15)
  call void @fn_emit(ptr @.str704)
  %t16 = load ptr, ptr %t7
  call void @fn_emit(ptr %t16)
  call void @fn_emit(ptr @.str705)
  call void @fn_emit(ptr @.str706)
  %t17 = load ptr, ptr %t14
  call void @fn_emit(ptr %t17)
  call void @fn_emit(ptr @.str707)
  %t18 = call ptr @fn_nreg()
  store ptr %t18, ptr %t19
  call void @fn_emit(ptr @.str708)
  %t20 = load ptr, ptr %t19
  call void @fn_emit(ptr %t20)
  call void @fn_emit(ptr @.str709)
  %t21 = load ptr, ptr %t7
  call void @fn_emit(ptr %t21)
  call void @fn_emit(ptr @.str710)
  call void @fn_emit(ptr @.str711)
  %t22 = load ptr, ptr %t19
  call void @fn_emit(ptr %t22)
  call void @fn_emit(ptr @.str712)
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
  call void @fn_emit(ptr @.str713)
  %t4 = load ptr, ptr %t3
  call void @fn_emit(ptr %t4)
  call void @fn_emit(ptr @.str714)
  %t5 = load ptr, ptr %t0
  call void @fn_emit(ptr %t5)
  call void @fn_emit(ptr @.str715)
  %t6 = load i32, ptr %t1
  %t7 = call ptr @fn_itoa(i32 %t6)
  call void @fn_emit(ptr %t7)
  call void @fn_emit(ptr @.str716)
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
  %t2 = getelementptr inbounds %Cmp_Node, ptr %t1, i32 0, i32 7
  %t3 = load ptr, ptr %t2
  %t4 = getelementptr inbounds %LSlice, ptr %t3, i32 0, i32 0
  %t5 = load ptr, ptr %t4
  %t6 = getelementptr inbounds ptr, ptr %t5, i32 0
  %t7 = load ptr, ptr %t6
  %t8 = call ptr @fn_emit_expr(ptr %t7)
  store ptr %t8, ptr %t9
  %t10 = load ptr, ptr %t9
  %t11 = getelementptr inbounds %Cmp_Val, ptr %t10, i32 0, i32 0
  %t12 = load ptr, ptr %t11
  %t13 = call ptr @fn_slice_field(ptr %t12, i32 1)
  store ptr %t13, ptr %t14
  %t15 = load ptr, ptr %t14
  %t16 = call ptr @fn_str_concat(ptr @.str717, ptr %t15)
  %t17 = call ptr @fn_emit_bind(ptr %t16)
  %t18 = call ptr @fn_val(ptr %t17, ptr @.str718)
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
  %t2 = getelementptr inbounds %Cmp_Node, ptr %t1, i32 0, i32 7
  %t3 = load ptr, ptr %t2
  %t4 = getelementptr inbounds %LSlice, ptr %t3, i32 0, i32 0
  %t5 = load ptr, ptr %t4
  %t6 = getelementptr inbounds ptr, ptr %t5, i32 0
  %t7 = load ptr, ptr %t6
  %t8 = call ptr @fn_emit_expr(ptr %t7)
  store ptr %t8, ptr %t9
  %t10 = load ptr, ptr %t9
  %t11 = getelementptr inbounds %Cmp_Val, ptr %t10, i32 0, i32 1
  %t12 = load ptr, ptr %t11
  %t13 = call ptr @fn_slice_elem(ptr %t12)
  store ptr %t13, ptr %t14
  %t15 = load ptr, ptr %t14
  %t16 = call ptr @fn_llty(ptr %t15)
  store ptr %t16, ptr %t17
  %t18 = load ptr, ptr %t9
  %t19 = getelementptr inbounds %Cmp_Val, ptr %t18, i32 0, i32 0
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
  %t32 = call ptr @fn_str_concat(ptr @.str719, ptr %t31)
  %t33 = call ptr @fn_emit_bind(ptr %t32)
  store ptr %t33, ptr %t34
  %t35 = load ptr, ptr %t27
  %t36 = call ptr @fn_str_concat(ptr @.str720, ptr %t35)
  %t37 = call ptr @fn_emit_bind(ptr %t36)
  store ptr %t37, ptr %t38
  %t39 = load ptr, ptr %t34
  %t40 = load ptr, ptr %t38
  %t41 = call ptr @fn_str_concat(ptr @.str722, ptr %t40)
  %t42 = call ptr @fn_str_concat(ptr %t39, ptr %t41)
  %t43 = call ptr @fn_str_concat(ptr @.str721, ptr %t42)
  %t44 = call ptr @fn_emit_bind(ptr %t43)
  store ptr %t44, ptr %t45
  %t46 = call ptr @fn_lbl(ptr @.str723)
  store ptr %t46, ptr %t47
  %t48 = call ptr @fn_lbl(ptr @.str724)
  store ptr %t48, ptr %t49
  call void @fn_emit(ptr @.str725)
  %t50 = load ptr, ptr %t45
  call void @fn_emit(ptr %t50)
  call void @fn_emit(ptr @.str726)
  %t51 = load ptr, ptr %t47
  call void @fn_emit(ptr %t51)
  call void @fn_emit(ptr @.str727)
  %t52 = load ptr, ptr %t49
  call void @fn_emit(ptr %t52)
  call void @fn_emit(ptr @.str728)
  %t53 = load ptr, ptr %t47
  call void @fn_emit(ptr %t53)
  call void @fn_emit(ptr @.str729)
  %t54 = load ptr, ptr %t38
  %t55 = call ptr @fn_str_concat(ptr %t54, ptr @.str731)
  %t56 = call ptr @fn_str_concat(ptr @.str730, ptr %t55)
  %t57 = call ptr @fn_emit_bind(ptr %t56)
  store ptr %t57, ptr %t58
  %t59 = load ptr, ptr %t38
  %t60 = call ptr @fn_str_concat(ptr %t59, ptr @.str733)
  %t61 = call ptr @fn_str_concat(ptr @.str732, ptr %t60)
  %t62 = call ptr @fn_emit_bind(ptr %t61)
  store ptr %t62, ptr %t63
  %t64 = load ptr, ptr %t63
  %t65 = load ptr, ptr %t58
  %t66 = call ptr @fn_str_concat(ptr @.str735, ptr %t65)
  %t67 = call ptr @fn_str_concat(ptr %t64, ptr %t66)
  %t68 = call ptr @fn_str_concat(ptr @.str734, ptr %t67)
  %t69 = call ptr @fn_emit_bind(ptr %t68)
  store ptr %t69, ptr %t70
  %t71 = load ptr, ptr %t17
  %t72 = call ptr @fn_emit_sizeof(ptr %t71)
  store ptr %t72, ptr %t73
  %t74 = load ptr, ptr %t70
  %t75 = call ptr @fn_str_concat(ptr %t74, ptr @.str737)
  %t76 = call ptr @fn_str_concat(ptr @.str736, ptr %t75)
  %t77 = call ptr @fn_emit_bind(ptr %t76)
  store ptr %t77, ptr %t78
  %t79 = load ptr, ptr %t78
  %t80 = load ptr, ptr %t73
  %t81 = call ptr @fn_str_concat(ptr @.str739, ptr %t80)
  %t82 = call ptr @fn_str_concat(ptr %t79, ptr %t81)
  %t83 = call ptr @fn_str_concat(ptr @.str738, ptr %t82)
  %t84 = call ptr @fn_emit_bind(ptr %t83)
  store ptr %t84, ptr %t85
  %t86 = load ptr, ptr %t30
  %t87 = call ptr @fn_str_concat(ptr @.str740, ptr %t86)
  %t88 = call ptr @fn_emit_bind(ptr %t87)
  store ptr %t88, ptr %t89
  %t90 = load ptr, ptr %t89
  %t91 = load ptr, ptr %t85
  %t92 = call ptr @fn_str_concat(ptr %t91, ptr @.str743)
  %t93 = call ptr @fn_str_concat(ptr @.str742, ptr %t92)
  %t94 = call ptr @fn_str_concat(ptr %t90, ptr %t93)
  %t95 = call ptr @fn_str_concat(ptr @.str741, ptr %t94)
  %t96 = call ptr @fn_emit_bind(ptr %t95)
  store ptr %t96, ptr %t97
  call void @fn_emit(ptr @.str744)
  %t98 = load ptr, ptr %t97
  call void @fn_emit(ptr %t98)
  call void @fn_emit(ptr @.str745)
  %t99 = load ptr, ptr %t30
  call void @fn_emit(ptr %t99)
  call void @fn_emit(ptr @.str746)
  call void @fn_emit(ptr @.str747)
  %t100 = load ptr, ptr %t70
  call void @fn_emit(ptr %t100)
  call void @fn_emit(ptr @.str748)
  %t101 = load ptr, ptr %t27
  call void @fn_emit(ptr %t101)
  call void @fn_emit(ptr @.str749)
  call void @fn_emit(ptr @.str750)
  %t102 = load ptr, ptr %t49
  call void @fn_emit(ptr %t102)
  call void @fn_emit(ptr @.str751)
  %t103 = load ptr, ptr %t49
  call void @fn_emit(ptr %t103)
  call void @fn_emit(ptr @.str752)
  %t104 = load ptr, ptr %t0
  %t105 = getelementptr inbounds %Cmp_Node, ptr %t104, i32 0, i32 7
  %t106 = load ptr, ptr %t105
  %t107 = getelementptr inbounds %LSlice, ptr %t106, i32 0, i32 0
  %t108 = load ptr, ptr %t107
  %t109 = getelementptr inbounds ptr, ptr %t108, i32 1
  %t110 = load ptr, ptr %t109
  %t111 = call ptr @fn_emit_expr(ptr %t110)
  store ptr %t111, ptr %t112
  %t113 = load ptr, ptr %t30
  %t114 = call ptr @fn_str_concat(ptr @.str753, ptr %t113)
  %t115 = call ptr @fn_emit_bind(ptr %t114)
  store ptr %t115, ptr %t116
  %t117 = call ptr @fn_nreg()
  store ptr %t117, ptr %t118
  call void @fn_emit(ptr @.str754)
  %t119 = load ptr, ptr %t118
  call void @fn_emit(ptr %t119)
  call void @fn_emit(ptr @.str755)
  %t120 = load ptr, ptr %t17
  call void @fn_emit(ptr %t120)
  call void @fn_emit(ptr @.str756)
  %t121 = load ptr, ptr %t116
  call void @fn_emit(ptr %t121)
  call void @fn_emit(ptr @.str757)
  %t122 = load ptr, ptr %t34
  call void @fn_emit(ptr %t122)
  call void @fn_emit(ptr @.str758)
  call void @fn_emit(ptr @.str759)
  %t123 = load ptr, ptr %t17
  call void @fn_emit(ptr %t123)
  call void @fn_emit(ptr @.str760)
  %t124 = load ptr, ptr %t112
  %t125 = getelementptr inbounds %Cmp_Val, ptr %t124, i32 0, i32 0
  %t126 = load ptr, ptr %t125
  call void @fn_emit(ptr %t126)
  call void @fn_emit(ptr @.str761)
  %t127 = load ptr, ptr %t118
  call void @fn_emit(ptr %t127)
  call void @fn_emit(ptr @.str762)
  %t128 = load ptr, ptr %t34
  %t129 = call ptr @fn_str_concat(ptr %t128, ptr @.str764)
  %t130 = call ptr @fn_str_concat(ptr @.str763, ptr %t129)
  %t131 = call ptr @fn_emit_bind(ptr %t130)
  store ptr %t131, ptr %t132
  call void @fn_emit(ptr @.str765)
  %t133 = load ptr, ptr %t132
  call void @fn_emit(ptr %t133)
  call void @fn_emit(ptr @.str766)
  %t134 = load ptr, ptr %t24
  call void @fn_emit(ptr %t134)
  call void @fn_emit(ptr @.str767)
  %t135 = call ptr @fn_val(ptr @.str768, ptr @.str769)
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
  %t5 = call ptr @fn_str_concat(ptr @.str771, ptr %t4)
  %t6 = call ptr @fn_str_concat(ptr %t3, ptr %t5)
  %t7 = call ptr @fn_str_concat(ptr @.str770, ptr %t6)
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
  %t1 = call ptr @fn_emit_alloca(ptr @.str772)
  store ptr %t1, ptr %t2
  %t3 = load ptr, ptr %t0
  %t4 = getelementptr inbounds %Cmp_Node, ptr %t3, i32 0, i32 4
  %t5 = load ptr, ptr %t4
  %t6 = call ptr @fn_emit_expr(ptr %t5)
  store ptr %t6, ptr %t7
  %t8 = load ptr, ptr %t7
  %t9 = getelementptr inbounds %Cmp_Val, ptr %t8, i32 0, i32 0
  %t10 = load ptr, ptr %t9
  %t11 = call ptr @fn_str_concat(ptr %t10, ptr @.str774)
  %t12 = call ptr @fn_str_concat(ptr @.str773, ptr %t11)
  %t13 = call ptr @fn_emit_bind(ptr %t12)
  store ptr %t13, ptr %t14
  %t15 = load ptr, ptr %t14
  %t16 = call ptr @fn_str_concat(ptr %t15, ptr @.str776)
  %t17 = call ptr @fn_str_concat(ptr @.str775, ptr %t16)
  %t18 = call ptr @fn_emit_bind(ptr %t17)
  store ptr %t18, ptr %t19
  call void @fn_emit(ptr @.str777)
  %t20 = load ptr, ptr %t19
  call void @fn_emit(ptr %t20)
  call void @fn_emit(ptr @.str778)
  %t21 = load ptr, ptr %t2
  call void @fn_emit(ptr %t21)
  call void @fn_emit(ptr @.str779)
  %t22 = call ptr @fn_lbl(ptr @.str780)
  store ptr %t22, ptr %t23
  %t24 = call ptr @fn_lbl(ptr @.str781)
  store ptr %t24, ptr %t25
  %t26 = load ptr, ptr %t0
  %t27 = getelementptr inbounds %Cmp_Node, ptr %t26, i32 0, i32 1
  %t28 = load ptr, ptr %t27
  %t29 = call i32 @fn_str_eq(ptr %t28, ptr @.str782)
  %t30 = icmp ne i32 %t29, 0
  br i1 %t30, label %then0, label %else1
then0:
  call void @fn_emit(ptr @.str783)
  %t31 = load ptr, ptr %t14
  call void @fn_emit(ptr %t31)
  call void @fn_emit(ptr @.str784)
  %t32 = load ptr, ptr %t23
  call void @fn_emit(ptr %t32)
  call void @fn_emit(ptr @.str785)
  %t33 = load ptr, ptr %t25
  call void @fn_emit(ptr %t33)
  call void @fn_emit(ptr @.str786)
  br label %ifend2
else1:
  call void @fn_emit(ptr @.str787)
  %t34 = load ptr, ptr %t14
  call void @fn_emit(ptr %t34)
  call void @fn_emit(ptr @.str788)
  %t35 = load ptr, ptr %t25
  call void @fn_emit(ptr %t35)
  call void @fn_emit(ptr @.str789)
  %t36 = load ptr, ptr %t23
  call void @fn_emit(ptr %t36)
  call void @fn_emit(ptr @.str790)
  br label %ifend2
ifend2:
  %t37 = load ptr, ptr %t23
  call void @fn_emit(ptr %t37)
  call void @fn_emit(ptr @.str791)
  %t38 = load ptr, ptr %t0
  %t39 = getelementptr inbounds %Cmp_Node, ptr %t38, i32 0, i32 5
  %t40 = load ptr, ptr %t39
  %t41 = call ptr @fn_emit_expr(ptr %t40)
  store ptr %t41, ptr %t42
  %t43 = load ptr, ptr %t42
  %t44 = getelementptr inbounds %Cmp_Val, ptr %t43, i32 0, i32 0
  %t45 = load ptr, ptr %t44
  %t46 = call ptr @fn_str_concat(ptr %t45, ptr @.str793)
  %t47 = call ptr @fn_str_concat(ptr @.str792, ptr %t46)
  %t48 = call ptr @fn_emit_bind(ptr %t47)
  store ptr %t48, ptr %t49
  %t50 = load ptr, ptr %t49
  %t51 = call ptr @fn_str_concat(ptr %t50, ptr @.str795)
  %t52 = call ptr @fn_str_concat(ptr @.str794, ptr %t51)
  %t53 = call ptr @fn_emit_bind(ptr %t52)
  store ptr %t53, ptr %t54
  call void @fn_emit(ptr @.str796)
  %t55 = load ptr, ptr %t54
  call void @fn_emit(ptr %t55)
  call void @fn_emit(ptr @.str797)
  %t56 = load ptr, ptr %t2
  call void @fn_emit(ptr %t56)
  call void @fn_emit(ptr @.str798)
  call void @fn_emit(ptr @.str799)
  %t57 = load ptr, ptr %t25
  call void @fn_emit(ptr %t57)
  call void @fn_emit(ptr @.str800)
  %t58 = load ptr, ptr %t25
  call void @fn_emit(ptr %t58)
  call void @fn_emit(ptr @.str801)
  %t59 = load ptr, ptr %t2
  %t60 = call ptr @fn_str_concat(ptr @.str802, ptr %t59)
  %t61 = call ptr @fn_emit_bind(ptr %t60)
  %t62 = call ptr @fn_val(ptr %t61, ptr @.str803)
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
  %t2 = call i32 @fn_str_eq(ptr %t1, ptr @.str804)
  %t3 = icmp ne i32 %t2, 0
  br i1 %t3, label %then0, label %ifend2
then0:
  store ptr @.str805, ptr %retval
  br label %ret
ifend2:
  %t4 = load ptr, ptr %t0
  %t5 = call i32 @fn_str_eq(ptr %t4, ptr @.str806)
  %t6 = icmp ne i32 %t5, 0
  br i1 %t6, label %then3, label %ifend5
then3:
  store ptr @.str807, ptr %retval
  br label %ret
ifend5:
  %t7 = load ptr, ptr %t0
  %t8 = call i32 @fn_str_eq(ptr %t7, ptr @.str808)
  %t9 = icmp ne i32 %t8, 0
  br i1 %t9, label %then6, label %ifend8
then6:
  store ptr @.str809, ptr %retval
  br label %ret
ifend8:
  %t10 = load ptr, ptr %t0
  %t11 = call i32 @fn_str_eq(ptr %t10, ptr @.str810)
  %t12 = icmp ne i32 %t11, 0
  br i1 %t12, label %then9, label %ifend11
then9:
  store ptr @.str811, ptr %retval
  br label %ret
ifend11:
  %t13 = load ptr, ptr %t0
  %t14 = call i32 @fn_str_eq(ptr %t13, ptr @.str812)
  %t15 = icmp ne i32 %t14, 0
  br i1 %t15, label %then12, label %ifend14
then12:
  store ptr @.str813, ptr %retval
  br label %ret
ifend14:
  store ptr @.str814, ptr %retval
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
  %t7 = call i32 @fn_str_eq(ptr %t6, ptr @.str815)
  %t8 = icmp ne i32 %t7, 0
  %t9 = zext i1 %t8 to i32
  store i32 %t9, ptr %t5
  br i1 %t8, label %scend1, label %sc0
sc0:
  %t10 = load ptr, ptr %t0
  %t11 = call i32 @fn_str_eq(ptr %t10, ptr @.str816)
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
  %t18 = call i32 @fn_str_eq(ptr %t17, ptr @.str817)
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
  %t25 = call i32 @fn_str_eq(ptr %t24, ptr @.str818)
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
  %t32 = call i32 @fn_str_eq(ptr %t31, ptr @.str819)
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
  %t39 = call i32 @fn_str_eq(ptr %t38, ptr @.str820)
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
  %t2 = call i32 @fn_str_eq(ptr %t1, ptr @.str821)
  %t3 = icmp ne i32 %t2, 0
  br i1 %t3, label %then0, label %ifend2
then0:
  store ptr @.str822, ptr %retval
  br label %ret
ifend2:
  %t4 = load ptr, ptr %t0
  %t5 = call i32 @fn_str_eq(ptr %t4, ptr @.str823)
  %t6 = icmp ne i32 %t5, 0
  br i1 %t6, label %then3, label %ifend5
then3:
  store ptr @.str824, ptr %retval
  br label %ret
ifend5:
  %t7 = load ptr, ptr %t0
  %t8 = call i32 @fn_str_eq(ptr %t7, ptr @.str825)
  %t9 = icmp ne i32 %t8, 0
  br i1 %t9, label %then6, label %ifend8
then6:
  store ptr @.str826, ptr %retval
  br label %ret
ifend8:
  %t10 = load ptr, ptr %t0
  %t11 = call i32 @fn_str_eq(ptr %t10, ptr @.str827)
  %t12 = icmp ne i32 %t11, 0
  br i1 %t12, label %then9, label %ifend11
then9:
  store ptr @.str828, ptr %retval
  br label %ret
ifend11:
  %t13 = load ptr, ptr %t0
  %t14 = call i32 @fn_str_eq(ptr %t13, ptr @.str829)
  %t15 = icmp ne i32 %t14, 0
  br i1 %t15, label %then12, label %ifend14
then12:
  store ptr @.str830, ptr %retval
  br label %ret
ifend14:
  %t16 = load ptr, ptr %t0
  %t17 = call i32 @fn_str_eq(ptr %t16, ptr @.str831)
  %t18 = icmp ne i32 %t17, 0
  br i1 %t18, label %then15, label %ifend17
then15:
  store ptr @.str832, ptr %retval
  br label %ret
ifend17:
  %t19 = load ptr, ptr %t0
  %t20 = call i32 @fn_str_eq(ptr %t19, ptr @.str833)
  %t21 = icmp ne i32 %t20, 0
  br i1 %t21, label %then18, label %ifend20
then18:
  store ptr @.str834, ptr %retval
  br label %ret
ifend20:
  %t22 = load ptr, ptr %t0
  %t23 = call i32 @fn_str_eq(ptr %t22, ptr @.str835)
  %t24 = icmp ne i32 %t23, 0
  br i1 %t24, label %then21, label %ifend23
then21:
  store ptr @.str836, ptr %retval
  br label %ret
ifend23:
  %t25 = load ptr, ptr %t0
  %t26 = call i32 @fn_str_eq(ptr %t25, ptr @.str837)
  %t27 = icmp ne i32 %t26, 0
  br i1 %t27, label %then24, label %ifend26
then24:
  store ptr @.str838, ptr %retval
  br label %ret
ifend26:
  store ptr @.str839, ptr %retval
  br label %ret
ret:
  %t28 = load ptr, ptr %retval
  ret ptr %t28
}

define ptr @fn_to_fixed(ptr %arg_v) {
entry:
  %retval = alloca ptr
  %t0 = alloca ptr
  store ptr %arg_v, ptr %t0
  %t1 = load ptr, ptr %t0
  %t2 = getelementptr inbounds %Cmp_Val, ptr %t1, i32 0, i32 1
  %t3 = load ptr, ptr %t2
  %t4 = call i32 @fn_str_eq(ptr %t3, ptr @.str840)
  %t5 = icmp ne i32 %t4, 0
  br i1 %t5, label %then0, label %ifend2
then0:
  %t6 = load ptr, ptr %t0
  %t7 = getelementptr inbounds %Cmp_Val, ptr %t6, i32 0, i32 0
  %t8 = load ptr, ptr %t7
  store ptr %t8, ptr %retval
  br label %ret
ifend2:
  %t9 = load ptr, ptr %t0
  %t10 = getelementptr inbounds %Cmp_Val, ptr %t9, i32 0, i32 0
  %t11 = load ptr, ptr %t10
  %t12 = call ptr @fn_str_concat(ptr %t11, ptr @.str842)
  %t13 = call ptr @fn_str_concat(ptr @.str841, ptr %t12)
  %t14 = call ptr @fn_emit_bind(ptr %t13)
  store ptr %t14, ptr %retval
  br label %ret
ret:
  %t15 = load ptr, ptr %retval
  ret ptr %t15
}

define ptr @fn_emit_str_op(ptr %arg_op, ptr %arg_a, ptr %arg_b) {
entry:
  %retval = alloca ptr
  %t0 = alloca ptr
  %t1 = alloca ptr
  %t2 = alloca ptr
  %t29 = alloca ptr
  %t37 = alloca ptr
  store ptr %arg_op, ptr %t0
  store ptr %arg_a, ptr %t1
  store ptr %arg_b, ptr %t2
  store i32 1, ptr @g_g_uses_str
  %t3 = load ptr, ptr %t0
  %t4 = call i32 @fn_str_eq(ptr %t3, ptr @.str843)
  %t5 = icmp ne i32 %t4, 0
  br i1 %t5, label %then0, label %ifend2
then0:
  %t6 = load ptr, ptr %t1
  %t7 = getelementptr inbounds %Cmp_Val, ptr %t6, i32 0, i32 0
  %t8 = load ptr, ptr %t7
  %t9 = load ptr, ptr %t2
  %t10 = getelementptr inbounds %Cmp_Val, ptr %t9, i32 0, i32 0
  %t11 = load ptr, ptr %t10
  %t12 = call ptr @fn_str_concat(ptr %t11, ptr @.str846)
  %t13 = call ptr @fn_str_concat(ptr @.str845, ptr %t12)
  %t14 = call ptr @fn_str_concat(ptr %t8, ptr %t13)
  %t15 = call ptr @fn_str_concat(ptr @.str844, ptr %t14)
  %t16 = call ptr @fn_emit_bind(ptr %t15)
  %t17 = call ptr @fn_val(ptr %t16, ptr @.str847)
  store ptr %t17, ptr %retval
  br label %ret
ifend2:
  %t18 = load ptr, ptr %t1
  %t19 = getelementptr inbounds %Cmp_Val, ptr %t18, i32 0, i32 0
  %t20 = load ptr, ptr %t19
  %t21 = load ptr, ptr %t2
  %t22 = getelementptr inbounds %Cmp_Val, ptr %t21, i32 0, i32 0
  %t23 = load ptr, ptr %t22
  %t24 = call ptr @fn_str_concat(ptr %t23, ptr @.str850)
  %t25 = call ptr @fn_str_concat(ptr @.str849, ptr %t24)
  %t26 = call ptr @fn_str_concat(ptr %t20, ptr %t25)
  %t27 = call ptr @fn_str_concat(ptr @.str848, ptr %t26)
  %t28 = call ptr @fn_emit_bind(ptr %t27)
  store ptr %t28, ptr %t29
  %t30 = load ptr, ptr %t0
  %t31 = call i32 @fn_str_eq(ptr %t30, ptr @.str851)
  %t32 = icmp ne i32 %t31, 0
  br i1 %t32, label %then3, label %ifend5
then3:
  %t33 = load ptr, ptr %t29
  %t34 = call ptr @fn_str_concat(ptr %t33, ptr @.str853)
  %t35 = call ptr @fn_str_concat(ptr @.str852, ptr %t34)
  %t36 = call ptr @fn_emit_bind(ptr %t35)
  store ptr %t36, ptr %t37
  %t38 = load ptr, ptr %t37
  %t39 = call ptr @fn_str_concat(ptr %t38, ptr @.str855)
  %t40 = call ptr @fn_str_concat(ptr @.str854, ptr %t39)
  %t41 = call ptr @fn_emit_bind(ptr %t40)
  %t42 = call ptr @fn_val(ptr %t41, ptr @.str856)
  store ptr %t42, ptr %retval
  br label %ret
ifend5:
  %t43 = load ptr, ptr %t29
  %t44 = call ptr @fn_val(ptr %t43, ptr @.str857)
  store ptr %t44, ptr %retval
  br label %ret
ret:
  %t45 = load ptr, ptr %retval
  ret ptr %t45
}

define ptr @fn_emit_bin(ptr %arg_e) {
entry:
  %retval = alloca ptr
  %t0 = alloca ptr
  %t1 = alloca i32
  %t22 = alloca ptr
  %t27 = alloca ptr
  %t28 = alloca i32
  %t44 = alloca i32
  %t45 = alloca i32
  %t65 = alloca i32
  %t76 = alloca i32
  %t77 = alloca i32
  %t106 = alloca i32
  %t120 = alloca i32
  %t129 = alloca ptr
  %t133 = alloca ptr
  %t134 = alloca ptr
  %t141 = alloca i32
  %t173 = alloca ptr
  %t183 = alloca ptr
  %t186 = alloca ptr
  %t196 = alloca ptr
  %t201 = alloca ptr
  %t208 = alloca ptr
  %t213 = alloca ptr
  %t228 = alloca ptr
  %t233 = alloca ptr
  %t238 = alloca ptr
  %t245 = alloca ptr
  %t262 = alloca ptr
  %t280 = alloca ptr
  store ptr %arg_e, ptr %t0
  %t2 = load ptr, ptr %t0
  %t3 = getelementptr inbounds %Cmp_Node, ptr %t2, i32 0, i32 1
  %t4 = load ptr, ptr %t3
  %t5 = call i32 @fn_str_eq(ptr %t4, ptr @.str858)
  %t6 = icmp ne i32 %t5, 0
  %t7 = zext i1 %t6 to i32
  store i32 %t7, ptr %t1
  br i1 %t6, label %scend1, label %sc0
sc0:
  %t8 = load ptr, ptr %t0
  %t9 = getelementptr inbounds %Cmp_Node, ptr %t8, i32 0, i32 1
  %t10 = load ptr, ptr %t9
  %t11 = call i32 @fn_str_eq(ptr %t10, ptr @.str859)
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
  %t19 = getelementptr inbounds %Cmp_Node, ptr %t18, i32 0, i32 4
  %t20 = load ptr, ptr %t19
  %t21 = call ptr @fn_emit_expr(ptr %t20)
  store ptr %t21, ptr %t22
  %t23 = load ptr, ptr %t0
  %t24 = getelementptr inbounds %Cmp_Node, ptr %t23, i32 0, i32 5
  %t25 = load ptr, ptr %t24
  %t26 = call ptr @fn_emit_expr(ptr %t25)
  store ptr %t26, ptr %t27
  %t29 = load ptr, ptr %t22
  %t30 = getelementptr inbounds %Cmp_Val, ptr %t29, i32 0, i32 1
  %t31 = load ptr, ptr %t30
  %t32 = call ptr @fn_llty(ptr %t31)
  %t33 = call i32 @fn_str_eq(ptr %t32, ptr @.str860)
  %t34 = icmp ne i32 %t33, 0
  %t35 = zext i1 %t34 to i32
  store i32 %t35, ptr %t28
  br i1 %t34, label %scend6, label %sc5
sc5:
  %t36 = load ptr, ptr %t27
  %t37 = getelementptr inbounds %Cmp_Val, ptr %t36, i32 0, i32 1
  %t38 = load ptr, ptr %t37
  %t39 = call ptr @fn_llty(ptr %t38)
  %t40 = call i32 @fn_str_eq(ptr %t39, ptr @.str861)
  %t41 = icmp ne i32 %t40, 0
  %t42 = zext i1 %t41 to i32
  store i32 %t42, ptr %t28
  br label %scend6
scend6:
  %t43 = load i32, ptr %t28
  store i32 %t43, ptr %t44
  %t46 = load ptr, ptr %t0
  %t47 = getelementptr inbounds %Cmp_Node, ptr %t46, i32 0, i32 4
  %t48 = load ptr, ptr %t47
  %t49 = getelementptr inbounds %Cmp_Node, ptr %t48, i32 0, i32 0
  %t50 = load i32, ptr %t49
  %t51 = icmp eq i32 %t50, 43
  %t52 = zext i1 %t51 to i32
  %t53 = icmp ne i32 %t52, 0
  %t54 = zext i1 %t53 to i32
  store i32 %t54, ptr %t45
  br i1 %t53, label %scend8, label %sc7
sc7:
  %t55 = load ptr, ptr %t0
  %t56 = getelementptr inbounds %Cmp_Node, ptr %t55, i32 0, i32 5
  %t57 = load ptr, ptr %t56
  %t58 = getelementptr inbounds %Cmp_Node, ptr %t57, i32 0, i32 0
  %t59 = load i32, ptr %t58
  %t60 = icmp eq i32 %t59, 43
  %t61 = zext i1 %t60 to i32
  %t62 = icmp ne i32 %t61, 0
  %t63 = zext i1 %t62 to i32
  store i32 %t63, ptr %t45
  br label %scend8
scend8:
  %t64 = load i32, ptr %t45
  store i32 %t64, ptr %t65
  %t66 = load i32, ptr %t44
  %t67 = icmp ne i32 %t66, 0
  br i1 %t67, label %then9, label %ifend11
then9:
  %t68 = load ptr, ptr %t0
  %t69 = getelementptr inbounds %Cmp_Node, ptr %t68, i32 0, i32 1
  %t70 = load ptr, ptr %t69
  %t71 = call i32 @fn_str_eq(ptr %t70, ptr @.str862)
  %t72 = icmp ne i32 %t71, 0
  br i1 %t72, label %then12, label %ifend14
then12:
  %t73 = load ptr, ptr %t22
  %t74 = load ptr, ptr %t27
  %t75 = call ptr @fn_emit_str_op(ptr @.str863, ptr %t73, ptr %t74)
  store ptr %t75, ptr %retval
  br label %ret
ifend14:
  %t78 = load ptr, ptr %t0
  %t79 = getelementptr inbounds %Cmp_Node, ptr %t78, i32 0, i32 1
  %t80 = load ptr, ptr %t79
  %t81 = call i32 @fn_str_eq(ptr %t80, ptr @.str864)
  %t82 = icmp ne i32 %t81, 0
  %t83 = zext i1 %t82 to i32
  store i32 %t83, ptr %t77
  br i1 %t82, label %scend16, label %sc15
sc15:
  %t84 = load ptr, ptr %t0
  %t85 = getelementptr inbounds %Cmp_Node, ptr %t84, i32 0, i32 1
  %t86 = load ptr, ptr %t85
  %t87 = call i32 @fn_str_eq(ptr %t86, ptr @.str865)
  %t88 = icmp ne i32 %t87, 0
  %t89 = zext i1 %t88 to i32
  store i32 %t89, ptr %t77
  br label %scend16
scend16:
  %t90 = load i32, ptr %t77
  %t91 = icmp ne i32 %t90, 0
  %t92 = zext i1 %t91 to i32
  store i32 %t92, ptr %t76
  br i1 %t91, label %sc17, label %scend18
sc17:
  %t93 = load i32, ptr %t65
  %t94 = icmp eq i32 %t93, 0
  %t95 = zext i1 %t94 to i32
  %t96 = icmp ne i32 %t95, 0
  %t97 = zext i1 %t96 to i32
  store i32 %t97, ptr %t76
  br label %scend18
scend18:
  %t98 = load i32, ptr %t76
  %t99 = icmp ne i32 %t98, 0
  br i1 %t99, label %then19, label %ifend21
then19:
  %t100 = load ptr, ptr %t0
  %t101 = getelementptr inbounds %Cmp_Node, ptr %t100, i32 0, i32 1
  %t102 = load ptr, ptr %t101
  %t103 = load ptr, ptr %t22
  %t104 = load ptr, ptr %t27
  %t105 = call ptr @fn_emit_str_op(ptr %t102, ptr %t103, ptr %t104)
  store ptr %t105, ptr %retval
  br label %ret
ifend21:
  br label %ifend11
ifend11:
  %t107 = load ptr, ptr %t22
  %t108 = getelementptr inbounds %Cmp_Val, ptr %t107, i32 0, i32 1
  %t109 = load ptr, ptr %t108
  %t110 = call i32 @fn_str_eq(ptr %t109, ptr @.str866)
  %t111 = icmp ne i32 %t110, 0
  %t112 = zext i1 %t111 to i32
  store i32 %t112, ptr %t106
  br i1 %t111, label %scend23, label %sc22
sc22:
  %t113 = load ptr, ptr %t27
  %t114 = getelementptr inbounds %Cmp_Val, ptr %t113, i32 0, i32 1
  %t115 = load ptr, ptr %t114
  %t116 = call i32 @fn_str_eq(ptr %t115, ptr @.str867)
  %t117 = icmp ne i32 %t116, 0
  %t118 = zext i1 %t117 to i32
  store i32 %t118, ptr %t106
  br label %scend23
scend23:
  %t119 = load i32, ptr %t106
  store i32 %t119, ptr %t120
  %t121 = load ptr, ptr %t0
  %t122 = getelementptr inbounds %Cmp_Node, ptr %t121, i32 0, i32 1
  %t123 = load ptr, ptr %t122
  %t124 = call i32 @fn_is_cmp(ptr %t123)
  %t125 = icmp ne i32 %t124, 0
  br i1 %t125, label %then24, label %ifend26
then24:
  %t126 = load ptr, ptr %t22
  %t127 = getelementptr inbounds %Cmp_Val, ptr %t126, i32 0, i32 0
  %t128 = load ptr, ptr %t127
  store ptr %t128, ptr %t129
  %t130 = load ptr, ptr %t27
  %t131 = getelementptr inbounds %Cmp_Val, ptr %t130, i32 0, i32 0
  %t132 = load ptr, ptr %t131
  store ptr %t132, ptr %t133
  store ptr @.str868, ptr %t134
  %t135 = load i32, ptr %t120
  %t136 = icmp ne i32 %t135, 0
  br i1 %t136, label %then27, label %else28
then27:
  %t137 = load ptr, ptr %t22
  %t138 = call ptr @fn_to_fixed(ptr %t137)
  store ptr %t138, ptr %t129
  %t139 = load ptr, ptr %t27
  %t140 = call ptr @fn_to_fixed(ptr %t139)
  store ptr %t140, ptr %t133
  br label %ifend29
else28:
  %t142 = load ptr, ptr %t22
  %t143 = getelementptr inbounds %Cmp_Val, ptr %t142, i32 0, i32 1
  %t144 = load ptr, ptr %t143
  %t145 = call ptr @fn_llty(ptr %t144)
  %t146 = call i32 @fn_str_eq(ptr %t145, ptr @.str869)
  %t147 = icmp ne i32 %t146, 0
  %t148 = zext i1 %t147 to i32
  store i32 %t148, ptr %t141
  br i1 %t147, label %scend31, label %sc30
sc30:
  %t149 = load ptr, ptr %t27
  %t150 = getelementptr inbounds %Cmp_Val, ptr %t149, i32 0, i32 1
  %t151 = load ptr, ptr %t150
  %t152 = call ptr @fn_llty(ptr %t151)
  %t153 = call i32 @fn_str_eq(ptr %t152, ptr @.str870)
  %t154 = icmp ne i32 %t153, 0
  %t155 = zext i1 %t154 to i32
  store i32 %t155, ptr %t141
  br label %scend31
scend31:
  %t156 = load i32, ptr %t141
  %t157 = icmp ne i32 %t156, 0
  br i1 %t157, label %then32, label %ifend34
then32:
  store ptr @.str871, ptr %t134
  br label %ifend34
ifend34:
  br label %ifend29
ifend29:
  %t158 = load ptr, ptr %t0
  %t159 = getelementptr inbounds %Cmp_Node, ptr %t158, i32 0, i32 1
  %t160 = load ptr, ptr %t159
  %t161 = call ptr @fn_cmp_code(ptr %t160)
  %t162 = load ptr, ptr %t134
  %t163 = call ptr @fn_str_concat(ptr %t162, ptr @.str874)
  %t164 = call ptr @fn_str_concat(ptr @.str873, ptr %t163)
  %t165 = load ptr, ptr %t129
  %t166 = load ptr, ptr %t133
  %t167 = call ptr @fn_str_concat(ptr @.str875, ptr %t166)
  %t168 = call ptr @fn_str_concat(ptr %t165, ptr %t167)
  %t169 = call ptr @fn_str_concat(ptr %t164, ptr %t168)
  %t170 = call ptr @fn_str_concat(ptr %t161, ptr %t169)
  %t171 = call ptr @fn_str_concat(ptr @.str872, ptr %t170)
  %t172 = call ptr @fn_emit_bind(ptr %t171)
  store ptr %t172, ptr %t173
  %t174 = load ptr, ptr %t173
  %t175 = call ptr @fn_str_concat(ptr %t174, ptr @.str877)
  %t176 = call ptr @fn_str_concat(ptr @.str876, ptr %t175)
  %t177 = call ptr @fn_emit_bind(ptr %t176)
  %t178 = call ptr @fn_val(ptr %t177, ptr @.str878)
  store ptr %t178, ptr %retval
  br label %ret
ifend26:
  %t179 = load i32, ptr %t120
  %t180 = icmp ne i32 %t179, 0
  br i1 %t180, label %then35, label %ifend37
then35:
  %t181 = load ptr, ptr %t22
  %t182 = call ptr @fn_to_fixed(ptr %t181)
  store ptr %t182, ptr %t183
  %t184 = load ptr, ptr %t27
  %t185 = call ptr @fn_to_fixed(ptr %t184)
  store ptr %t185, ptr %t186
  %t187 = load ptr, ptr %t0
  %t188 = getelementptr inbounds %Cmp_Node, ptr %t187, i32 0, i32 1
  %t189 = load ptr, ptr %t188
  %t190 = call i32 @fn_str_eq(ptr %t189, ptr @.str879)
  %t191 = icmp ne i32 %t190, 0
  br i1 %t191, label %then38, label %ifend40
then38:
  %t192 = load ptr, ptr %t183
  %t193 = call ptr @fn_str_concat(ptr %t192, ptr @.str881)
  %t194 = call ptr @fn_str_concat(ptr @.str880, ptr %t193)
  %t195 = call ptr @fn_emit_bind(ptr %t194)
  store ptr %t195, ptr %t196
  %t197 = load ptr, ptr %t186
  %t198 = call ptr @fn_str_concat(ptr %t197, ptr @.str883)
  %t199 = call ptr @fn_str_concat(ptr @.str882, ptr %t198)
  %t200 = call ptr @fn_emit_bind(ptr %t199)
  store ptr %t200, ptr %t201
  %t202 = load ptr, ptr %t196
  %t203 = load ptr, ptr %t201
  %t204 = call ptr @fn_str_concat(ptr @.str885, ptr %t203)
  %t205 = call ptr @fn_str_concat(ptr %t202, ptr %t204)
  %t206 = call ptr @fn_str_concat(ptr @.str884, ptr %t205)
  %t207 = call ptr @fn_emit_bind(ptr %t206)
  store ptr %t207, ptr %t208
  %t209 = load ptr, ptr %t208
  %t210 = call ptr @fn_str_concat(ptr %t209, ptr @.str887)
  %t211 = call ptr @fn_str_concat(ptr @.str886, ptr %t210)
  %t212 = call ptr @fn_emit_bind(ptr %t211)
  store ptr %t212, ptr %t213
  %t214 = load ptr, ptr %t213
  %t215 = call ptr @fn_str_concat(ptr %t214, ptr @.str889)
  %t216 = call ptr @fn_str_concat(ptr @.str888, ptr %t215)
  %t217 = call ptr @fn_emit_bind(ptr %t216)
  %t218 = call ptr @fn_val(ptr %t217, ptr @.str890)
  store ptr %t218, ptr %retval
  br label %ret
ifend40:
  %t219 = load ptr, ptr %t0
  %t220 = getelementptr inbounds %Cmp_Node, ptr %t219, i32 0, i32 1
  %t221 = load ptr, ptr %t220
  %t222 = call i32 @fn_str_eq(ptr %t221, ptr @.str891)
  %t223 = icmp ne i32 %t222, 0
  br i1 %t223, label %then41, label %ifend43
then41:
  %t224 = load ptr, ptr %t183
  %t225 = call ptr @fn_str_concat(ptr %t224, ptr @.str893)
  %t226 = call ptr @fn_str_concat(ptr @.str892, ptr %t225)
  %t227 = call ptr @fn_emit_bind(ptr %t226)
  store ptr %t227, ptr %t228
  %t229 = load ptr, ptr %t228
  %t230 = call ptr @fn_str_concat(ptr %t229, ptr @.str895)
  %t231 = call ptr @fn_str_concat(ptr @.str894, ptr %t230)
  %t232 = call ptr @fn_emit_bind(ptr %t231)
  store ptr %t232, ptr %t233
  %t234 = load ptr, ptr %t186
  %t235 = call ptr @fn_str_concat(ptr %t234, ptr @.str897)
  %t236 = call ptr @fn_str_concat(ptr @.str896, ptr %t235)
  %t237 = call ptr @fn_emit_bind(ptr %t236)
  store ptr %t237, ptr %t238
  %t239 = load ptr, ptr %t233
  %t240 = load ptr, ptr %t238
  %t241 = call ptr @fn_str_concat(ptr @.str899, ptr %t240)
  %t242 = call ptr @fn_str_concat(ptr %t239, ptr %t241)
  %t243 = call ptr @fn_str_concat(ptr @.str898, ptr %t242)
  %t244 = call ptr @fn_emit_bind(ptr %t243)
  store ptr %t244, ptr %t245
  %t246 = load ptr, ptr %t245
  %t247 = call ptr @fn_str_concat(ptr %t246, ptr @.str901)
  %t248 = call ptr @fn_str_concat(ptr @.str900, ptr %t247)
  %t249 = call ptr @fn_emit_bind(ptr %t248)
  %t250 = call ptr @fn_val(ptr %t249, ptr @.str902)
  store ptr %t250, ptr %retval
  br label %ret
ifend43:
  %t251 = load ptr, ptr %t0
  %t252 = getelementptr inbounds %Cmp_Node, ptr %t251, i32 0, i32 1
  %t253 = load ptr, ptr %t252
  %t254 = call ptr @fn_arith_code(ptr %t253)
  %t255 = load ptr, ptr %t183
  %t256 = load ptr, ptr %t186
  %t257 = call ptr @fn_str_concat(ptr @.str904, ptr %t256)
  %t258 = call ptr @fn_str_concat(ptr %t255, ptr %t257)
  %t259 = call ptr @fn_str_concat(ptr @.str903, ptr %t258)
  %t260 = call ptr @fn_str_concat(ptr %t254, ptr %t259)
  %t261 = call ptr @fn_emit_bind(ptr %t260)
  store ptr %t261, ptr %t262
  %t263 = load ptr, ptr %t262
  %t264 = call ptr @fn_val(ptr %t263, ptr @.str905)
  store ptr %t264, ptr %retval
  br label %ret
ifend37:
  %t265 = load ptr, ptr %t0
  %t266 = getelementptr inbounds %Cmp_Node, ptr %t265, i32 0, i32 1
  %t267 = load ptr, ptr %t266
  %t268 = call ptr @fn_arith_code(ptr %t267)
  %t269 = load ptr, ptr %t22
  %t270 = getelementptr inbounds %Cmp_Val, ptr %t269, i32 0, i32 0
  %t271 = load ptr, ptr %t270
  %t272 = load ptr, ptr %t27
  %t273 = getelementptr inbounds %Cmp_Val, ptr %t272, i32 0, i32 0
  %t274 = load ptr, ptr %t273
  %t275 = call ptr @fn_str_concat(ptr @.str907, ptr %t274)
  %t276 = call ptr @fn_str_concat(ptr %t271, ptr %t275)
  %t277 = call ptr @fn_str_concat(ptr @.str906, ptr %t276)
  %t278 = call ptr @fn_str_concat(ptr %t268, ptr %t277)
  %t279 = call ptr @fn_emit_bind(ptr %t278)
  store ptr %t279, ptr %t280
  %t281 = load ptr, ptr %t280
  %t282 = call ptr @fn_val(ptr %t281, ptr @.str908)
  store ptr %t282, ptr %retval
  br label %ret
ret:
  %t283 = load ptr, ptr %retval
  ret ptr %t283
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
  %t2 = getelementptr inbounds %Cmp_Node, ptr %t1, i32 0, i32 4
  %t3 = load ptr, ptr %t2
  %t4 = getelementptr inbounds %Cmp_Node, ptr %t3, i32 0, i32 1
  %t5 = load ptr, ptr %t4
  store ptr %t5, ptr %t6
  %t7 = load ptr, ptr %t6
  %t8 = call i32 @fn_str_eq(ptr %t7, ptr @.str909)
  %t9 = icmp ne i32 %t8, 0
  br i1 %t9, label %then0, label %ifend2
then0:
  %t10 = load i32, ptr @g_nself
  %t11 = icmp eq i32 %t10, 0
  %t12 = zext i1 %t11 to i32
  %t13 = icmp ne i32 %t12, 0
  br i1 %t13, label %then3, label %ifend5
then3:
  %t14 = call ptr @fn_val(ptr @.str910, ptr @.str911)
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
  %t22 = call ptr @fn_str_concat(ptr @.str912, ptr %t21)
  %t23 = call ptr @fn_emit_bind(ptr %t22)
  %t24 = call ptr @fn_val(ptr %t23, ptr @.str913)
  store ptr %t24, ptr %retval
  br label %ret
ifend2:
  %t25 = load ptr, ptr %t6
  %t26 = call i32 @fn_str_eq(ptr %t25, ptr @.str914)
  %t27 = icmp ne i32 %t26, 0
  br i1 %t27, label %then6, label %ifend8
then6:
  %t28 = call ptr @fn_emit_bind(ptr @.str915)
  %t29 = call ptr @fn_val(ptr %t28, ptr @.str916)
  store ptr %t29, ptr %retval
  br label %ret
ifend8:
  %t30 = load ptr, ptr %t6
  %t31 = call i32 @fn_str_eq(ptr %t30, ptr @.str917)
  %t32 = icmp ne i32 %t31, 0
  br i1 %t32, label %then9, label %ifend11
then9:
  call void @fn_emit(ptr @.str918)
  %t33 = call ptr @fn_val(ptr @.str919, ptr @.str920)
  store ptr %t33, ptr %retval
  br label %ret
ifend11:
  %t34 = load ptr, ptr %t6
  %t35 = call i32 @fn_str_eq(ptr %t34, ptr @.str921)
  %t36 = icmp ne i32 %t35, 0
  br i1 %t36, label %then12, label %ifend14
then12:
  call void @fn_emit(ptr @.str922)
  %t37 = call ptr @fn_val(ptr @.str923, ptr @.str924)
  store ptr %t37, ptr %retval
  br label %ret
ifend14:
  %t38 = load ptr, ptr %t6
  %t39 = call i32 @fn_str_eq(ptr %t38, ptr @.str925)
  %t40 = icmp ne i32 %t39, 0
  br i1 %t40, label %then15, label %ifend17
then15:
  %t41 = call ptr @fn_emit_bind(ptr @.str926)
  %t42 = call ptr @fn_val(ptr %t41, ptr @.str927)
  store ptr %t42, ptr %retval
  br label %ret
ifend17:
  %t43 = load ptr, ptr %t6
  %t44 = call i32 @fn_str_eq(ptr %t43, ptr @.str928)
  %t45 = icmp ne i32 %t44, 0
  br i1 %t45, label %then18, label %ifend20
then18:
  call void @fn_emit(ptr @.str929)
  %t46 = call ptr @fn_val(ptr @.str930, ptr @.str931)
  store ptr %t46, ptr %retval
  br label %ret
ifend20:
  %t47 = load ptr, ptr %t6
  %t48 = call i32 @fn_str_eq(ptr %t47, ptr @.str932)
  %t49 = icmp ne i32 %t48, 0
  br i1 %t49, label %then21, label %ifend23
then21:
  %t50 = load ptr, ptr %t0
  %t51 = call ptr @fn_emit_len(ptr %t50)
  store ptr %t51, ptr %retval
  br label %ret
ifend23:
  %t52 = load ptr, ptr %t6
  %t53 = call i32 @fn_str_eq(ptr %t52, ptr @.str933)
  %t54 = icmp ne i32 %t53, 0
  br i1 %t54, label %then24, label %ifend26
then24:
  %t55 = load ptr, ptr %t0
  %t56 = call ptr @fn_emit_push(ptr %t55)
  store ptr %t56, ptr %retval
  br label %ret
ifend26:
  %t57 = load ptr, ptr %t6
  %t58 = call i32 @fn_str_eq(ptr %t57, ptr @.str934)
  %t59 = icmp ne i32 %t58, 0
  br i1 %t59, label %then27, label %ifend29
then27:
  %t60 = load ptr, ptr %t0
  %t61 = getelementptr inbounds %Cmp_Node, ptr %t60, i32 0, i32 7
  %t62 = load ptr, ptr %t61
  %t63 = getelementptr inbounds %LSlice, ptr %t62, i32 0, i32 0
  %t64 = load ptr, ptr %t63
  %t65 = getelementptr inbounds ptr, ptr %t64, i32 0
  %t66 = load ptr, ptr %t65
  %t67 = call ptr @fn_emit_expr(ptr %t66)
  store ptr %t67, ptr %t68
  %t69 = load ptr, ptr %t68
  %t70 = getelementptr inbounds %Cmp_Val, ptr %t69, i32 0, i32 0
  %t71 = load ptr, ptr %t70
  %t72 = call ptr @fn_str_concat(ptr %t71, ptr @.str936)
  %t73 = call ptr @fn_str_concat(ptr @.str935, ptr %t72)
  %t74 = call ptr @fn_emit_bind(ptr %t73)
  %t75 = call ptr @fn_val(ptr %t74, ptr @.str937)
  store ptr %t75, ptr %retval
  br label %ret
ifend29:
  %t76 = load ptr, ptr %t6
  %t77 = call i32 @fn_str_eq(ptr %t76, ptr @.str938)
  %t78 = icmp ne i32 %t77, 0
  br i1 %t78, label %then30, label %ifend32
then30:
  %t79 = load ptr, ptr %t0
  %t80 = getelementptr inbounds %Cmp_Node, ptr %t79, i32 0, i32 7
  %t81 = load ptr, ptr %t80
  %t82 = getelementptr inbounds %LSlice, ptr %t81, i32 0, i32 0
  %t83 = load ptr, ptr %t82
  %t84 = getelementptr inbounds ptr, ptr %t83, i32 0
  %t85 = load ptr, ptr %t84
  %t86 = call ptr @fn_emit_expr(ptr %t85)
  store ptr %t86, ptr %t87
  %t88 = load ptr, ptr %t87
  %t89 = getelementptr inbounds %Cmp_Val, ptr %t88, i32 0, i32 0
  %t90 = load ptr, ptr %t89
  %t91 = call ptr @fn_str_concat(ptr %t90, ptr @.str940)
  %t92 = call ptr @fn_str_concat(ptr @.str939, ptr %t91)
  %t93 = call ptr @fn_emit_bind(ptr %t92)
  %t94 = call ptr @fn_val(ptr %t93, ptr @.str941)
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
  %t123 = call ptr @fn_str_concat(ptr @.str942, ptr %t122)
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
  %t132 = call ptr @fn_str_concat(ptr @.str943, ptr %t131)
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
  %t151 = getelementptr inbounds %Cmp_Node, ptr %t150, i32 0, i32 7
  %t152 = load ptr, ptr %t151
  %t153 = getelementptr inbounds %LSlice, ptr %t152, i32 0, i32 1
  %t154 = load i32, ptr %t153
  %t155 = icmp slt i32 %t149, %t154
  %t156 = zext i1 %t155 to i32
  %t157 = icmp ne i32 %t156, 0
  br i1 %t157, label %wbody49, label %wend50
wbody49:
  %t158 = load ptr, ptr %t0
  %t159 = getelementptr inbounds %Cmp_Node, ptr %t158, i32 0, i32 7
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
  %t185 = getelementptr inbounds %Cmp_Val, ptr %t184, i32 0, i32 0
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
  %t207 = getelementptr inbounds %Cmp_Val, ptr %t206, i32 0, i32 1
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
  %t215 = getelementptr inbounds %Cmp_Node, ptr %t214, i32 0, i32 3
  %t216 = load ptr, ptr %t215
  %t217 = call ptr @fn_llty(ptr %t216)
  store ptr %t217, ptr %t218
  call void @fn_emit(ptr @.str944)
  store ptr @.str945, ptr %t219
  %t220 = load ptr, ptr %t218
  %t221 = call i32 @fn_str_eq(ptr %t220, ptr @.str946)
  %t222 = icmp eq i32 %t221, 0
  %t223 = zext i1 %t222 to i32
  %t224 = icmp ne i32 %t223, 0
  br i1 %t224, label %then55, label %ifend57
then55:
  %t225 = call ptr @fn_nreg()
  store ptr %t225, ptr %t219
  %t226 = load ptr, ptr %t219
  call void @fn_emit(ptr %t226)
  call void @fn_emit(ptr @.str947)
  br label %ifend57
ifend57:
  call void @fn_emit(ptr @.str948)
  %t227 = load ptr, ptr %t218
  call void @fn_emit(ptr %t227)
  call void @fn_emit(ptr @.str949)
  %t228 = load ptr, ptr %t117
  call void @fn_emit(ptr %t228)
  call void @fn_emit(ptr @.str950)
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
  call void @fn_emit(ptr @.str951)
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
  call void @fn_emit(ptr @.str952)
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
  call void @fn_emit(ptr @.str953)
  %t255 = load ptr, ptr %t219
  %t256 = load ptr, ptr %t115
  %t257 = getelementptr inbounds %Cmp_Node, ptr %t256, i32 0, i32 3
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
  %t86 = alloca i32
  %t108 = alloca ptr
  %t137 = alloca ptr
  %t181 = alloca i32
  %t193 = alloca ptr
  %t203 = alloca ptr
  %t216 = alloca ptr
  %t228 = alloca ptr
  %t258 = alloca ptr
  %t288 = alloca ptr
  store ptr %arg_e, ptr %t0
  %t1 = load ptr, ptr %t0
  %t2 = icmp eq ptr %t1, null
  %t3 = zext i1 %t2 to i32
  %t4 = icmp ne i32 %t3, 0
  br i1 %t4, label %then0, label %ifend2
then0:
  %t5 = call ptr @fn_val(ptr @.str954, ptr @.str955)
  store ptr %t5, ptr %retval
  br label %ret
ifend2:
  %t6 = load ptr, ptr %t0
  %t7 = getelementptr inbounds %Cmp_Node, ptr %t6, i32 0, i32 0
  %t8 = load i32, ptr %t7
  %t9 = icmp eq i32 %t8, 30
  %t10 = zext i1 %t9 to i32
  %t11 = icmp ne i32 %t10, 0
  br i1 %t11, label %then3, label %ifend5
then3:
  %t12 = load ptr, ptr %t0
  %t13 = getelementptr inbounds %Cmp_Node, ptr %t12, i32 0, i32 2
  %t14 = load i32, ptr %t13
  %t15 = call ptr @fn_itoa(i32 %t14)
  %t16 = call ptr @fn_val(ptr %t15, ptr @.str956)
  store ptr %t16, ptr %retval
  br label %ret
ifend5:
  %t17 = load ptr, ptr %t0
  %t18 = getelementptr inbounds %Cmp_Node, ptr %t17, i32 0, i32 0
  %t19 = load i32, ptr %t18
  %t20 = icmp eq i32 %t19, 40
  %t21 = zext i1 %t20 to i32
  %t22 = icmp ne i32 %t21, 0
  br i1 %t22, label %then6, label %ifend8
then6:
  %t23 = load ptr, ptr %t0
  %t24 = getelementptr inbounds %Cmp_Node, ptr %t23, i32 0, i32 2
  %t25 = load i32, ptr %t24
  %t26 = call ptr @fn_itoa(i32 %t25)
  %t27 = call ptr @fn_val(ptr %t26, ptr @.str957)
  store ptr %t27, ptr %retval
  br label %ret
ifend8:
  %t28 = load ptr, ptr %t0
  %t29 = getelementptr inbounds %Cmp_Node, ptr %t28, i32 0, i32 0
  %t30 = load i32, ptr %t29
  %t31 = icmp eq i32 %t30, 32
  %t32 = zext i1 %t31 to i32
  %t33 = icmp ne i32 %t32, 0
  br i1 %t33, label %then9, label %ifend11
then9:
  %t34 = load ptr, ptr %t0
  %t35 = getelementptr inbounds %Cmp_Node, ptr %t34, i32 0, i32 2
  %t36 = load i32, ptr %t35
  %t37 = call ptr @fn_itoa(i32 %t36)
  %t38 = call ptr @fn_val(ptr %t37, ptr @.str958)
  store ptr %t38, ptr %retval
  br label %ret
ifend11:
  %t39 = load ptr, ptr %t0
  %t40 = getelementptr inbounds %Cmp_Node, ptr %t39, i32 0, i32 0
  %t41 = load i32, ptr %t40
  %t42 = icmp eq i32 %t41, 43
  %t43 = zext i1 %t42 to i32
  %t44 = icmp ne i32 %t43, 0
  br i1 %t44, label %then12, label %ifend14
then12:
  %t45 = call ptr @fn_val(ptr @.str959, ptr @.str960)
  store ptr %t45, ptr %retval
  br label %ret
ifend14:
  %t46 = load ptr, ptr %t0
  %t47 = getelementptr inbounds %Cmp_Node, ptr %t46, i32 0, i32 0
  %t48 = load i32, ptr %t47
  %t49 = icmp eq i32 %t48, 31
  %t50 = zext i1 %t49 to i32
  %t51 = icmp ne i32 %t50, 0
  br i1 %t51, label %then15, label %ifend17
then15:
  %t52 = load ptr, ptr %t0
  %t53 = getelementptr inbounds %Cmp_Node, ptr %t52, i32 0, i32 1
  %t54 = load ptr, ptr %t53
  %t55 = call ptr @fn_emit_str_const(ptr %t54)
  %t56 = call ptr @fn_val(ptr %t55, ptr @.str961)
  store ptr %t56, ptr %retval
  br label %ret
ifend17:
  %t57 = load ptr, ptr %t0
  %t58 = getelementptr inbounds %Cmp_Node, ptr %t57, i32 0, i32 0
  %t59 = load i32, ptr %t58
  %t60 = icmp eq i32 %t59, 39
  %t61 = zext i1 %t60 to i32
  %t62 = icmp ne i32 %t61, 0
  br i1 %t62, label %then18, label %ifend20
then18:
  %t63 = load ptr, ptr %t0
  %t64 = getelementptr inbounds %Cmp_Node, ptr %t63, i32 0, i32 1
  %t65 = load ptr, ptr %t64
  %t66 = call i32 @fn_is_slice_ty(ptr %t65)
  %t67 = icmp ne i32 %t66, 0
  br i1 %t67, label %then21, label %ifend23
then21:
  %t68 = load ptr, ptr %t0
  %t69 = getelementptr inbounds %Cmp_Node, ptr %t68, i32 0, i32 1
  %t70 = load ptr, ptr %t69
  %t71 = call ptr @fn_emit_new_slice(ptr %t70)
  store ptr %t71, ptr %retval
  br label %ret
ifend23:
  %t72 = load ptr, ptr %t0
  %t73 = getelementptr inbounds %Cmp_Node, ptr %t72, i32 0, i32 1
  %t74 = load ptr, ptr %t73
  %t75 = call ptr @fn_emit_new_struct(ptr %t74)
  store ptr %t75, ptr %retval
  br label %ret
ifend20:
  %t76 = load ptr, ptr %t0
  %t77 = getelementptr inbounds %Cmp_Node, ptr %t76, i32 0, i32 0
  %t78 = load i32, ptr %t77
  %t79 = icmp eq i32 %t78, 33
  %t80 = zext i1 %t79 to i32
  %t81 = icmp ne i32 %t80, 0
  br i1 %t81, label %then24, label %ifend26
then24:
  %t82 = load ptr, ptr %t0
  %t83 = getelementptr inbounds %Cmp_Node, ptr %t82, i32 0, i32 1
  %t84 = load ptr, ptr %t83
  %t85 = call i32 @fn_loc_find(ptr %t84)
  store i32 %t85, ptr %t86
  %t87 = load i32, ptr %t86
  %t88 = icmp sge i32 %t87, 0
  %t89 = zext i1 %t88 to i32
  %t90 = icmp ne i32 %t89, 0
  br i1 %t90, label %then27, label %ifend29
then27:
  %t91 = load ptr, ptr @g_loc_reg
  %t92 = getelementptr inbounds %LSlice, ptr %t91, i32 0, i32 0
  %t93 = load ptr, ptr %t92
  %t94 = load i32, ptr %t86
  %t95 = getelementptr inbounds ptr, ptr %t93, i32 %t94
  %t96 = load ptr, ptr %t95
  %t97 = load ptr, ptr @g_loc_ty
  %t98 = getelementptr inbounds %LSlice, ptr %t97, i32 0, i32 0
  %t99 = load ptr, ptr %t98
  %t100 = load i32, ptr %t86
  %t101 = getelementptr inbounds ptr, ptr %t99, i32 %t100
  %t102 = load ptr, ptr %t101
  %t103 = call ptr @fn_emit_load_at(ptr %t96, ptr %t102)
  store ptr %t103, ptr %retval
  br label %ret
ifend29:
  %t104 = load ptr, ptr %t0
  %t105 = getelementptr inbounds %Cmp_Node, ptr %t104, i32 0, i32 1
  %t106 = load ptr, ptr %t105
  %t107 = call ptr @fn_find_global(ptr %t106)
  store ptr %t107, ptr %t108
  %t109 = load ptr, ptr %t108
  %t110 = icmp ne ptr %t109, null
  %t111 = zext i1 %t110 to i32
  %t112 = icmp ne i32 %t111, 0
  br i1 %t112, label %then30, label %ifend32
then30:
  %t113 = load ptr, ptr %t108
  %t114 = getelementptr inbounds %Cmp_Node, ptr %t113, i32 0, i32 0
  %t115 = load i32, ptr %t114
  %t116 = icmp eq i32 %t115, 3
  %t117 = zext i1 %t116 to i32
  %t118 = icmp ne i32 %t117, 0
  br i1 %t118, label %then33, label %ifend35
then33:
  %t119 = load ptr, ptr %t108
  %t120 = getelementptr inbounds %Cmp_Node, ptr %t119, i32 0, i32 4
  %t121 = load ptr, ptr %t120
  %t122 = getelementptr inbounds %Cmp_Node, ptr %t121, i32 0, i32 2
  %t123 = load i32, ptr %t122
  %t124 = call ptr @fn_itoa(i32 %t123)
  %t125 = call ptr @fn_val(ptr %t124, ptr @.str962)
  store ptr %t125, ptr %retval
  br label %ret
ifend35:
  %t126 = load ptr, ptr %t108
  %t127 = getelementptr inbounds %Cmp_Node, ptr %t126, i32 0, i32 3
  %t128 = load ptr, ptr %t127
  %t129 = call ptr @fn_llty(ptr %t128)
  %t130 = load ptr, ptr %t0
  %t131 = getelementptr inbounds %Cmp_Node, ptr %t130, i32 0, i32 1
  %t132 = load ptr, ptr %t131
  %t133 = call ptr @fn_str_concat(ptr @.str964, ptr %t132)
  %t134 = call ptr @fn_str_concat(ptr %t129, ptr %t133)
  %t135 = call ptr @fn_str_concat(ptr @.str963, ptr %t134)
  %t136 = call ptr @fn_emit_bind(ptr %t135)
  store ptr %t136, ptr %t137
  %t138 = load ptr, ptr %t137
  %t139 = load ptr, ptr %t108
  %t140 = getelementptr inbounds %Cmp_Node, ptr %t139, i32 0, i32 3
  %t141 = load ptr, ptr %t140
  %t142 = call ptr @fn_val(ptr %t138, ptr %t141)
  store ptr %t142, ptr %retval
  br label %ret
ifend32:
  %t143 = load ptr, ptr %t0
  %t144 = getelementptr inbounds %Cmp_Node, ptr %t143, i32 0, i32 1
  %t145 = load ptr, ptr %t144
  %t146 = call i32 @fn_is_ui_ident(ptr %t145)
  %t147 = icmp ne i32 %t146, 0
  br i1 %t147, label %then36, label %ifend38
then36:
  %t148 = load ptr, ptr %t0
  %t149 = getelementptr inbounds %Cmp_Node, ptr %t148, i32 0, i32 1
  %t150 = load ptr, ptr %t149
  %t151 = call i32 @fn_ui_index_of(ptr %t150)
  %t152 = call ptr @fn_itoa(i32 %t151)
  %t153 = call ptr @fn_val(ptr %t152, ptr @.str965)
  store ptr %t153, ptr %retval
  br label %ret
ifend38:
  %t154 = load ptr, ptr %t0
  %t155 = getelementptr inbounds %Cmp_Node, ptr %t154, i32 0, i32 1
  %t156 = load ptr, ptr %t155
  %t157 = call ptr @fn_str_concat(ptr @.str966, ptr %t156)
  call void @fn_perr(ptr %t157)
  br label %ifend26
ifend26:
  %t158 = load ptr, ptr %t0
  %t159 = getelementptr inbounds %Cmp_Node, ptr %t158, i32 0, i32 0
  %t160 = load i32, ptr %t159
  %t161 = icmp eq i32 %t160, 35
  %t162 = zext i1 %t161 to i32
  %t163 = icmp ne i32 %t162, 0
  br i1 %t163, label %then39, label %ifend41
then39:
  %t164 = load ptr, ptr %t0
  %t165 = getelementptr inbounds %Cmp_Node, ptr %t164, i32 0, i32 4
  %t166 = load ptr, ptr %t165
  %t167 = getelementptr inbounds %Cmp_Node, ptr %t166, i32 0, i32 0
  %t168 = load i32, ptr %t167
  %t169 = icmp eq i32 %t168, 33
  %t170 = zext i1 %t169 to i32
  %t171 = icmp ne i32 %t170, 0
  br i1 %t171, label %then42, label %ifend44
then42:
  %t172 = load ptr, ptr %t0
  %t173 = getelementptr inbounds %Cmp_Node, ptr %t172, i32 0, i32 4
  %t174 = load ptr, ptr %t173
  %t175 = getelementptr inbounds %Cmp_Node, ptr %t174, i32 0, i32 1
  %t176 = load ptr, ptr %t175
  %t177 = load ptr, ptr %t0
  %t178 = getelementptr inbounds %Cmp_Node, ptr %t177, i32 0, i32 1
  %t179 = load ptr, ptr %t178
  %t180 = call i32 @fn_enum_ordinal(ptr %t176, ptr %t179)
  store i32 %t180, ptr %t181
  %t182 = load i32, ptr %t181
  %t183 = icmp sge i32 %t182, 0
  %t184 = zext i1 %t183 to i32
  %t185 = icmp ne i32 %t184, 0
  br i1 %t185, label %then45, label %ifend47
then45:
  %t186 = load i32, ptr %t181
  %t187 = call ptr @fn_itoa(i32 %t186)
  %t188 = call ptr @fn_val(ptr %t187, ptr @.str967)
  store ptr %t188, ptr %retval
  br label %ret
ifend47:
  br label %ifend44
ifend44:
  %t189 = load ptr, ptr %t0
  %t190 = getelementptr inbounds %Cmp_Node, ptr %t189, i32 0, i32 4
  %t191 = load ptr, ptr %t190
  %t192 = call ptr @fn_static_type(ptr %t191)
  store ptr %t192, ptr %t193
  %t194 = load ptr, ptr %t193
  %t195 = icmp ne ptr %t194, null
  %t196 = zext i1 %t195 to i32
  %t197 = icmp ne i32 %t196, 0
  br i1 %t197, label %then48, label %ifend50
then48:
  %t198 = load ptr, ptr %t193
  %t199 = load ptr, ptr %t0
  %t200 = getelementptr inbounds %Cmp_Node, ptr %t199, i32 0, i32 1
  %t201 = load ptr, ptr %t200
  %t202 = call ptr @fn_computed_expr(ptr %t198, ptr %t201)
  store ptr %t202, ptr %t203
  %t204 = load ptr, ptr %t203
  %t205 = icmp ne ptr %t204, null
  %t206 = zext i1 %t205 to i32
  %t207 = icmp ne i32 %t206, 0
  br i1 %t207, label %then51, label %ifend53
then51:
  %t208 = load ptr, ptr %t203
  %t209 = load ptr, ptr %t0
  %t210 = getelementptr inbounds %Cmp_Node, ptr %t209, i32 0, i32 4
  %t211 = load ptr, ptr %t210
  %t212 = call ptr @fn_qualify_fields(ptr %t208, ptr %t211)
  %t213 = call ptr @fn_emit_expr(ptr %t212)
  store ptr %t213, ptr %retval
  br label %ret
ifend53:
  br label %ifend50
ifend50:
  %t214 = load ptr, ptr %t0
  %t215 = call ptr @fn_emit_member_addr(ptr %t214)
  store ptr %t215, ptr %t216
  %t217 = load ptr, ptr %t216
  %t218 = load ptr, ptr @g_g_addr_ty
  %t219 = call ptr @fn_emit_load_at(ptr %t217, ptr %t218)
  store ptr %t219, ptr %retval
  br label %ret
ifend41:
  %t220 = load ptr, ptr %t0
  %t221 = getelementptr inbounds %Cmp_Node, ptr %t220, i32 0, i32 0
  %t222 = load i32, ptr %t221
  %t223 = icmp eq i32 %t222, 36
  %t224 = zext i1 %t223 to i32
  %t225 = icmp ne i32 %t224, 0
  br i1 %t225, label %then54, label %ifend56
then54:
  %t226 = load ptr, ptr %t0
  %t227 = call ptr @fn_emit_index_addr(ptr %t226)
  store ptr %t227, ptr %t228
  %t229 = load ptr, ptr %t228
  %t230 = load ptr, ptr @g_g_addr_ty
  %t231 = call ptr @fn_emit_load_at(ptr %t229, ptr %t230)
  store ptr %t231, ptr %retval
  br label %ret
ifend56:
  %t232 = load ptr, ptr %t0
  %t233 = getelementptr inbounds %Cmp_Node, ptr %t232, i32 0, i32 0
  %t234 = load i32, ptr %t233
  %t235 = icmp eq i32 %t234, 34
  %t236 = zext i1 %t235 to i32
  %t237 = icmp ne i32 %t236, 0
  br i1 %t237, label %then57, label %ifend59
then57:
  %t238 = load ptr, ptr %t0
  %t239 = call ptr @fn_emit_call(ptr %t238)
  store ptr %t239, ptr %retval
  br label %ret
ifend59:
  %t240 = load ptr, ptr %t0
  %t241 = getelementptr inbounds %Cmp_Node, ptr %t240, i32 0, i32 0
  %t242 = load i32, ptr %t241
  %t243 = icmp eq i32 %t242, 37
  %t244 = zext i1 %t243 to i32
  %t245 = icmp ne i32 %t244, 0
  br i1 %t245, label %then60, label %ifend62
then60:
  %t246 = load ptr, ptr %t0
  %t247 = call ptr @fn_emit_bin(ptr %t246)
  store ptr %t247, ptr %retval
  br label %ret
ifend62:
  %t248 = load ptr, ptr %t0
  %t249 = getelementptr inbounds %Cmp_Node, ptr %t248, i32 0, i32 0
  %t250 = load i32, ptr %t249
  %t251 = icmp eq i32 %t250, 38
  %t252 = zext i1 %t251 to i32
  %t253 = icmp ne i32 %t252, 0
  br i1 %t253, label %then63, label %ifend65
then63:
  %t254 = load ptr, ptr %t0
  %t255 = getelementptr inbounds %Cmp_Node, ptr %t254, i32 0, i32 4
  %t256 = load ptr, ptr %t255
  %t257 = call ptr @fn_emit_expr(ptr %t256)
  store ptr %t257, ptr %t258
  %t259 = load ptr, ptr %t0
  %t260 = getelementptr inbounds %Cmp_Node, ptr %t259, i32 0, i32 1
  %t261 = load ptr, ptr %t260
  %t262 = call i32 @fn_str_eq(ptr %t261, ptr @.str968)
  %t263 = icmp ne i32 %t262, 0
  br i1 %t263, label %then66, label %ifend68
then66:
  %t264 = load ptr, ptr %t258
  %t265 = getelementptr inbounds %Cmp_Val, ptr %t264, i32 0, i32 0
  %t266 = load ptr, ptr %t265
  %t267 = call ptr @fn_str_concat(ptr @.str969, ptr %t266)
  %t268 = call ptr @fn_emit_bind(ptr %t267)
  %t269 = call ptr @fn_val(ptr %t268, ptr @.str970)
  store ptr %t269, ptr %retval
  br label %ret
ifend68:
  %t270 = load ptr, ptr %t0
  %t271 = getelementptr inbounds %Cmp_Node, ptr %t270, i32 0, i32 1
  %t272 = load ptr, ptr %t271
  %t273 = call i32 @fn_str_eq(ptr %t272, ptr @.str971)
  %t274 = icmp ne i32 %t273, 0
  br i1 %t274, label %then69, label %ifend71
then69:
  %t275 = load ptr, ptr %t258
  %t276 = getelementptr inbounds %Cmp_Val, ptr %t275, i32 0, i32 0
  %t277 = load ptr, ptr %t276
  %t278 = call ptr @fn_str_concat(ptr %t277, ptr @.str973)
  %t279 = call ptr @fn_str_concat(ptr @.str972, ptr %t278)
  %t280 = call ptr @fn_emit_bind(ptr %t279)
  %t281 = call ptr @fn_val(ptr %t280, ptr @.str974)
  store ptr %t281, ptr %retval
  br label %ret
ifend71:
  %t282 = load ptr, ptr %t258
  %t283 = getelementptr inbounds %Cmp_Val, ptr %t282, i32 0, i32 0
  %t284 = load ptr, ptr %t283
  %t285 = call ptr @fn_str_concat(ptr %t284, ptr @.str976)
  %t286 = call ptr @fn_str_concat(ptr @.str975, ptr %t285)
  %t287 = call ptr @fn_emit_bind(ptr %t286)
  store ptr %t287, ptr %t288
  %t289 = load ptr, ptr %t288
  %t290 = call ptr @fn_str_concat(ptr %t289, ptr @.str978)
  %t291 = call ptr @fn_str_concat(ptr @.str977, ptr %t290)
  %t292 = call ptr @fn_emit_bind(ptr %t291)
  %t293 = call ptr @fn_val(ptr %t292, ptr @.str979)
  store ptr %t293, ptr %retval
  br label %ret
ifend65:
  call void @fn_perr(ptr @.str980)
  %t294 = call ptr @fn_val(ptr @.str981, ptr @.str982)
  store ptr %t294, ptr %retval
  br label %ret
ret:
  %t295 = load ptr, ptr %retval
  ret ptr %t295
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
  %t4 = getelementptr inbounds %Cmp_Node, ptr %t3, i32 0, i32 7
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
  %t14 = getelementptr inbounds %Cmp_Node, ptr %t13, i32 0, i32 7
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
  call void @fn_emit(ptr @.str983)
  %t3 = load ptr, ptr %t0
  call void @fn_emit(ptr %t3)
  call void @fn_emit(ptr @.str984)
  %t4 = load ptr, ptr %t1
  call void @fn_emit(ptr %t4)
  call void @fn_emit(ptr @.str985)
  %t5 = load ptr, ptr %t2
  call void @fn_emit(ptr %t5)
  call void @fn_emit(ptr @.str986)
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
  %t57 = alloca ptr
  %t93 = alloca ptr
  %t98 = alloca ptr
  %t102 = alloca ptr
  %t116 = alloca ptr
  %t117 = alloca ptr
  store ptr %arg_st, ptr %t0
  %t1 = load ptr, ptr %t0
  %t2 = getelementptr inbounds %Cmp_Node, ptr %t1, i32 0, i32 4
  %t3 = load ptr, ptr %t2
  store ptr %t3, ptr %t4
  store ptr @.str987, ptr %t5
  store ptr @.str988, ptr %t6
  %t7 = load ptr, ptr %t4
  %t8 = getelementptr inbounds %Cmp_Node, ptr %t7, i32 0, i32 0
  %t9 = load i32, ptr %t8
  %t10 = icmp eq i32 %t9, 33
  %t11 = zext i1 %t10 to i32
  %t12 = icmp ne i32 %t11, 0
  br i1 %t12, label %then0, label %else1
then0:
  %t13 = load ptr, ptr %t4
  %t14 = getelementptr inbounds %Cmp_Node, ptr %t13, i32 0, i32 1
  %t15 = load ptr, ptr %t14
  %t16 = call i32 @fn_loc_find(ptr %t15)
  store i32 %t16, ptr %t17
  %t18 = load i32, ptr %t17
  %t19 = icmp sge i32 %t18, 0
  %t20 = zext i1 %t19 to i32
  %t21 = icmp ne i32 %t20, 0
  br i1 %t21, label %then3, label %else4
then3:
  %t22 = load ptr, ptr @g_loc_mut
  %t23 = getelementptr inbounds %LSlice, ptr %t22, i32 0, i32 0
  %t24 = load ptr, ptr %t23
  %t25 = load i32, ptr %t17
  %t26 = getelementptr inbounds i32, ptr %t24, i32 %t25
  %t27 = load i32, ptr %t26
  %t28 = icmp eq i32 %t27, 0
  %t29 = zext i1 %t28 to i32
  %t30 = icmp ne i32 %t29, 0
  br i1 %t30, label %then6, label %ifend8
then6:
  %t31 = load ptr, ptr %t4
  %t32 = getelementptr inbounds %Cmp_Node, ptr %t31, i32 0, i32 1
  %t33 = load ptr, ptr %t32
  %t34 = load ptr, ptr %t0
  %t35 = getelementptr inbounds %Cmp_Node, ptr %t34, i32 0, i32 8
  %t36 = load i32, ptr %t35
  %t37 = call ptr @fn_itoa(i32 %t36)
  %t38 = call ptr @fn_str_concat(ptr @.str990, ptr %t37)
  %t39 = call ptr @fn_str_concat(ptr %t33, ptr %t38)
  %t40 = call ptr @fn_str_concat(ptr @.str989, ptr %t39)
  call void @fn_perr(ptr %t40)
  br label %ifend8
ifend8:
  %t41 = load ptr, ptr @g_loc_reg
  %t42 = getelementptr inbounds %LSlice, ptr %t41, i32 0, i32 0
  %t43 = load ptr, ptr %t42
  %t44 = load i32, ptr %t17
  %t45 = getelementptr inbounds ptr, ptr %t43, i32 %t44
  %t46 = load ptr, ptr %t45
  store ptr %t46, ptr %t5
  %t47 = load ptr, ptr @g_loc_ty
  %t48 = getelementptr inbounds %LSlice, ptr %t47, i32 0, i32 0
  %t49 = load ptr, ptr %t48
  %t50 = load i32, ptr %t17
  %t51 = getelementptr inbounds ptr, ptr %t49, i32 %t50
  %t52 = load ptr, ptr %t51
  store ptr %t52, ptr %t6
  br label %ifend5
else4:
  %t53 = load ptr, ptr %t4
  %t54 = getelementptr inbounds %Cmp_Node, ptr %t53, i32 0, i32 1
  %t55 = load ptr, ptr %t54
  %t56 = call ptr @fn_find_global(ptr %t55)
  store ptr %t56, ptr %t57
  %t58 = load ptr, ptr %t57
  %t59 = icmp eq ptr %t58, null
  %t60 = zext i1 %t59 to i32
  %t61 = icmp ne i32 %t60, 0
  br i1 %t61, label %then9, label %ifend11
then9:
  %t62 = load ptr, ptr %t4
  %t63 = getelementptr inbounds %Cmp_Node, ptr %t62, i32 0, i32 1
  %t64 = load ptr, ptr %t63
  %t65 = call ptr @fn_str_concat(ptr @.str991, ptr %t64)
  call void @fn_perr(ptr %t65)
  br label %ifend11
ifend11:
  %t66 = load ptr, ptr %t4
  %t67 = getelementptr inbounds %Cmp_Node, ptr %t66, i32 0, i32 1
  %t68 = load ptr, ptr %t67
  %t69 = call ptr @fn_str_concat(ptr @.str992, ptr %t68)
  store ptr %t69, ptr %t5
  %t70 = load ptr, ptr %t57
  %t71 = getelementptr inbounds %Cmp_Node, ptr %t70, i32 0, i32 3
  %t72 = load ptr, ptr %t71
  store ptr %t72, ptr %t6
  br label %ifend5
ifend5:
  br label %ifend2
else1:
  %t73 = load ptr, ptr %t4
  %t74 = getelementptr inbounds %Cmp_Node, ptr %t73, i32 0, i32 0
  %t75 = load i32, ptr %t74
  %t76 = icmp eq i32 %t75, 35
  %t77 = zext i1 %t76 to i32
  %t78 = icmp ne i32 %t77, 0
  br i1 %t78, label %then12, label %else13
then12:
  %t79 = load ptr, ptr %t4
  %t80 = call ptr @fn_emit_member_addr(ptr %t79)
  store ptr %t80, ptr %t5
  %t81 = load ptr, ptr @g_g_addr_ty
  store ptr %t81, ptr %t6
  br label %ifend14
else13:
  %t82 = load ptr, ptr %t4
  %t83 = getelementptr inbounds %Cmp_Node, ptr %t82, i32 0, i32 0
  %t84 = load i32, ptr %t83
  %t85 = icmp eq i32 %t84, 36
  %t86 = zext i1 %t85 to i32
  %t87 = icmp ne i32 %t86, 0
  br i1 %t87, label %then15, label %else16
then15:
  %t88 = load ptr, ptr %t4
  %t89 = call ptr @fn_emit_index_addr(ptr %t88)
  store ptr %t89, ptr %t5
  %t90 = load ptr, ptr @g_g_addr_ty
  store ptr %t90, ptr %t6
  br label %ifend17
else16:
  call void @fn_perr(ptr @.str993)
  br label %ifend17
ifend17:
  br label %ifend14
ifend14:
  br label %ifend2
ifend2:
  %t91 = load ptr, ptr %t6
  %t92 = call ptr @fn_llty(ptr %t91)
  store ptr %t92, ptr %t93
  %t94 = load ptr, ptr %t0
  %t95 = getelementptr inbounds %Cmp_Node, ptr %t94, i32 0, i32 5
  %t96 = load ptr, ptr %t95
  %t97 = call ptr @fn_emit_expr(ptr %t96)
  store ptr %t97, ptr %t98
  %t99 = load ptr, ptr %t98
  %t100 = getelementptr inbounds %Cmp_Val, ptr %t99, i32 0, i32 0
  %t101 = load ptr, ptr %t100
  store ptr %t101, ptr %t102
  %t103 = load ptr, ptr %t0
  %t104 = getelementptr inbounds %Cmp_Node, ptr %t103, i32 0, i32 1
  %t105 = load ptr, ptr %t104
  %t106 = call i32 @fn_str_eq(ptr %t105, ptr @.str994)
  %t107 = icmp eq i32 %t106, 0
  %t108 = zext i1 %t107 to i32
  %t109 = icmp ne i32 %t108, 0
  br i1 %t109, label %then18, label %ifend20
then18:
  %t110 = load ptr, ptr %t93
  %t111 = load ptr, ptr %t5
  %t112 = call ptr @fn_str_concat(ptr @.str996, ptr %t111)
  %t113 = call ptr @fn_str_concat(ptr %t110, ptr %t112)
  %t114 = call ptr @fn_str_concat(ptr @.str995, ptr %t113)
  %t115 = call ptr @fn_emit_bind(ptr %t114)
  store ptr %t115, ptr %t116
  store ptr @.str997, ptr %t117
  %t118 = load ptr, ptr %t0
  %t119 = getelementptr inbounds %Cmp_Node, ptr %t118, i32 0, i32 1
  %t120 = load ptr, ptr %t119
  %t121 = call i32 @fn_str_eq(ptr %t120, ptr @.str998)
  %t122 = icmp ne i32 %t121, 0
  br i1 %t122, label %then21, label %ifend23
then21:
  store ptr @.str999, ptr %t117
  br label %ifend23
ifend23:
  %t123 = load ptr, ptr %t0
  %t124 = getelementptr inbounds %Cmp_Node, ptr %t123, i32 0, i32 1
  %t125 = load ptr, ptr %t124
  %t126 = call i32 @fn_str_eq(ptr %t125, ptr @.str1000)
  %t127 = icmp ne i32 %t126, 0
  br i1 %t127, label %then24, label %ifend26
then24:
  store ptr @.str1001, ptr %t117
  br label %ifend26
ifend26:
  %t128 = load ptr, ptr %t0
  %t129 = getelementptr inbounds %Cmp_Node, ptr %t128, i32 0, i32 1
  %t130 = load ptr, ptr %t129
  %t131 = call i32 @fn_str_eq(ptr %t130, ptr @.str1002)
  %t132 = icmp ne i32 %t131, 0
  br i1 %t132, label %then27, label %ifend29
then27:
  store ptr @.str1003, ptr %t117
  br label %ifend29
ifend29:
  %t133 = load ptr, ptr %t117
  %t134 = load ptr, ptr %t116
  %t135 = load ptr, ptr %t102
  %t136 = call ptr @fn_str_concat(ptr @.str1005, ptr %t135)
  %t137 = call ptr @fn_str_concat(ptr %t134, ptr %t136)
  %t138 = call ptr @fn_str_concat(ptr @.str1004, ptr %t137)
  %t139 = call ptr @fn_str_concat(ptr %t133, ptr %t138)
  %t140 = call ptr @fn_emit_bind(ptr %t139)
  store ptr %t140, ptr %t102
  br label %ifend20
ifend20:
  %t141 = load ptr, ptr %t93
  %t142 = load ptr, ptr %t102
  %t143 = load ptr, ptr %t5
  call void @fn_store_at(ptr %t141, ptr %t142, ptr %t143)
  br label %ret
ret:
  ret void
}

define void @fn_emit_if(ptr %arg_st) {
entry:
  %t0 = alloca ptr
  %t5 = alloca ptr
  %t12 = alloca ptr
  %t18 = alloca i32
  %t20 = alloca ptr
  %t22 = alloca ptr
  %t24 = alloca ptr
  store ptr %arg_st, ptr %t0
  %t1 = load ptr, ptr %t0
  %t2 = getelementptr inbounds %Cmp_Node, ptr %t1, i32 0, i32 4
  %t3 = load ptr, ptr %t2
  %t4 = call ptr @fn_emit_expr(ptr %t3)
  store ptr %t4, ptr %t5
  %t6 = load ptr, ptr %t5
  %t7 = getelementptr inbounds %Cmp_Val, ptr %t6, i32 0, i32 0
  %t8 = load ptr, ptr %t7
  %t9 = call ptr @fn_str_concat(ptr %t8, ptr @.str1007)
  %t10 = call ptr @fn_str_concat(ptr @.str1006, ptr %t9)
  %t11 = call ptr @fn_emit_bind(ptr %t10)
  store ptr %t11, ptr %t12
  %t13 = load ptr, ptr %t0
  %t14 = getelementptr inbounds %Cmp_Node, ptr %t13, i32 0, i32 6
  %t15 = load ptr, ptr %t14
  %t16 = icmp ne ptr %t15, null
  %t17 = zext i1 %t16 to i32
  store i32 %t17, ptr %t18
  %t19 = call ptr @fn_lbl(ptr @.str1008)
  store ptr %t19, ptr %t20
  %t21 = call ptr @fn_lbl(ptr @.str1009)
  store ptr %t21, ptr %t22
  %t23 = call ptr @fn_lbl(ptr @.str1010)
  store ptr %t23, ptr %t24
  %t25 = load i32, ptr %t18
  %t26 = icmp ne i32 %t25, 0
  br i1 %t26, label %then0, label %else1
then0:
  call void @fn_emit(ptr @.str1011)
  %t27 = load ptr, ptr %t12
  call void @fn_emit(ptr %t27)
  call void @fn_emit(ptr @.str1012)
  %t28 = load ptr, ptr %t20
  call void @fn_emit(ptr %t28)
  call void @fn_emit(ptr @.str1013)
  %t29 = load ptr, ptr %t22
  call void @fn_emit(ptr %t29)
  call void @fn_emit(ptr @.str1014)
  br label %ifend2
else1:
  call void @fn_emit(ptr @.str1015)
  %t30 = load ptr, ptr %t12
  call void @fn_emit(ptr %t30)
  call void @fn_emit(ptr @.str1016)
  %t31 = load ptr, ptr %t20
  call void @fn_emit(ptr %t31)
  call void @fn_emit(ptr @.str1017)
  %t32 = load ptr, ptr %t24
  call void @fn_emit(ptr %t32)
  call void @fn_emit(ptr @.str1018)
  br label %ifend2
ifend2:
  %t33 = load ptr, ptr %t20
  call void @fn_emit(ptr %t33)
  call void @fn_emit(ptr @.str1019)
  store i32 0, ptr @g_g_term
  %t34 = load ptr, ptr %t0
  %t35 = getelementptr inbounds %Cmp_Node, ptr %t34, i32 0, i32 5
  %t36 = load ptr, ptr %t35
  call void @fn_emit_block(ptr %t36)
  %t37 = load i32, ptr @g_g_term
  %t38 = icmp eq i32 %t37, 0
  %t39 = zext i1 %t38 to i32
  %t40 = icmp ne i32 %t39, 0
  br i1 %t40, label %then3, label %ifend5
then3:
  call void @fn_emit(ptr @.str1020)
  %t41 = load ptr, ptr %t24
  call void @fn_emit(ptr %t41)
  call void @fn_emit(ptr @.str1021)
  br label %ifend5
ifend5:
  %t42 = load i32, ptr %t18
  %t43 = icmp ne i32 %t42, 0
  br i1 %t43, label %then6, label %ifend8
then6:
  %t44 = load ptr, ptr %t22
  call void @fn_emit(ptr %t44)
  call void @fn_emit(ptr @.str1022)
  store i32 0, ptr @g_g_term
  %t45 = load ptr, ptr %t0
  %t46 = getelementptr inbounds %Cmp_Node, ptr %t45, i32 0, i32 6
  %t47 = load ptr, ptr %t46
  %t48 = getelementptr inbounds %Cmp_Node, ptr %t47, i32 0, i32 0
  %t49 = load i32, ptr %t48
  %t50 = icmp eq i32 %t49, 12
  %t51 = zext i1 %t50 to i32
  %t52 = icmp ne i32 %t51, 0
  br i1 %t52, label %then9, label %else10
then9:
  %t53 = load ptr, ptr %t0
  %t54 = getelementptr inbounds %Cmp_Node, ptr %t53, i32 0, i32 6
  %t55 = load ptr, ptr %t54
  call void @fn_emit_stmt(ptr %t55)
  br label %ifend11
else10:
  %t56 = load ptr, ptr %t0
  %t57 = getelementptr inbounds %Cmp_Node, ptr %t56, i32 0, i32 6
  %t58 = load ptr, ptr %t57
  call void @fn_emit_block(ptr %t58)
  br label %ifend11
ifend11:
  %t59 = load i32, ptr @g_g_term
  %t60 = icmp eq i32 %t59, 0
  %t61 = zext i1 %t60 to i32
  %t62 = icmp ne i32 %t61, 0
  br i1 %t62, label %then12, label %ifend14
then12:
  call void @fn_emit(ptr @.str1023)
  %t63 = load ptr, ptr %t24
  call void @fn_emit(ptr %t63)
  call void @fn_emit(ptr @.str1024)
  br label %ifend14
ifend14:
  br label %ifend8
ifend8:
  %t64 = load ptr, ptr %t24
  call void @fn_emit(ptr %t64)
  call void @fn_emit(ptr @.str1025)
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
  %t1 = call ptr @fn_lbl(ptr @.str1026)
  store ptr %t1, ptr %t2
  %t3 = call ptr @fn_lbl(ptr @.str1027)
  store ptr %t3, ptr %t4
  %t5 = call ptr @fn_lbl(ptr @.str1028)
  store ptr %t5, ptr %t6
  call void @fn_emit(ptr @.str1029)
  %t7 = load ptr, ptr %t2
  call void @fn_emit(ptr %t7)
  call void @fn_emit(ptr @.str1030)
  %t8 = load ptr, ptr %t2
  call void @fn_emit(ptr %t8)
  call void @fn_emit(ptr @.str1031)
  %t9 = load ptr, ptr %t0
  %t10 = getelementptr inbounds %Cmp_Node, ptr %t9, i32 0, i32 4
  %t11 = load ptr, ptr %t10
  %t12 = call ptr @fn_emit_expr(ptr %t11)
  store ptr %t12, ptr %t13
  %t14 = load ptr, ptr %t13
  %t15 = getelementptr inbounds %Cmp_Val, ptr %t14, i32 0, i32 0
  %t16 = load ptr, ptr %t15
  %t17 = call ptr @fn_str_concat(ptr %t16, ptr @.str1033)
  %t18 = call ptr @fn_str_concat(ptr @.str1032, ptr %t17)
  %t19 = call ptr @fn_emit_bind(ptr %t18)
  store ptr %t19, ptr %t20
  call void @fn_emit(ptr @.str1034)
  %t21 = load ptr, ptr %t20
  call void @fn_emit(ptr %t21)
  call void @fn_emit(ptr @.str1035)
  %t22 = load ptr, ptr %t4
  call void @fn_emit(ptr %t22)
  call void @fn_emit(ptr @.str1036)
  %t23 = load ptr, ptr %t6
  call void @fn_emit(ptr %t23)
  call void @fn_emit(ptr @.str1037)
  %t24 = load ptr, ptr %t4
  call void @fn_emit(ptr %t24)
  call void @fn_emit(ptr @.str1038)
  store i32 0, ptr @g_g_term
  %t25 = load ptr, ptr %t2
  %t26 = load ptr, ptr %t6
  call void @fn_loop_push(ptr %t25, ptr %t26)
  %t27 = load ptr, ptr %t0
  %t28 = getelementptr inbounds %Cmp_Node, ptr %t27, i32 0, i32 5
  %t29 = load ptr, ptr %t28
  call void @fn_emit_block(ptr %t29)
  call void @fn_loop_pop()
  %t30 = load i32, ptr @g_g_term
  %t31 = icmp eq i32 %t30, 0
  %t32 = zext i1 %t31 to i32
  %t33 = icmp ne i32 %t32, 0
  br i1 %t33, label %then0, label %ifend2
then0:
  call void @fn_emit(ptr @.str1039)
  %t34 = load ptr, ptr %t2
  call void @fn_emit(ptr %t34)
  call void @fn_emit(ptr @.str1040)
  br label %ifend2
ifend2:
  %t35 = load ptr, ptr %t6
  call void @fn_emit(ptr %t35)
  call void @fn_emit(ptr @.str1041)
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
  %t1 = call ptr @fn_emit_alloca(ptr @.str1042)
  store ptr %t1, ptr %t2
  %t3 = load ptr, ptr %t0
  %t4 = getelementptr inbounds %Cmp_Node, ptr %t3, i32 0, i32 4
  %t5 = load ptr, ptr %t4
  %t6 = call ptr @fn_emit_expr(ptr %t5)
  store ptr %t6, ptr %t7
  %t8 = load ptr, ptr %t7
  %t9 = getelementptr inbounds %Cmp_Val, ptr %t8, i32 0, i32 0
  %t10 = load ptr, ptr %t9
  %t11 = load ptr, ptr %t2
  call void @fn_store_at(ptr @.str1043, ptr %t10, ptr %t11)
  %t12 = load ptr, ptr %t0
  %t13 = getelementptr inbounds %Cmp_Node, ptr %t12, i32 0, i32 1
  %t14 = load ptr, ptr %t13
  %t15 = load ptr, ptr %t2
  call void @fn_loc_push(ptr %t14, ptr %t15, ptr @.str1044)
  %t16 = call ptr @fn_lbl(ptr @.str1045)
  store ptr %t16, ptr %t17
  %t18 = call ptr @fn_lbl(ptr @.str1046)
  store ptr %t18, ptr %t19
  %t20 = call ptr @fn_lbl(ptr @.str1047)
  store ptr %t20, ptr %t21
  %t22 = call ptr @fn_lbl(ptr @.str1048)
  store ptr %t22, ptr %t23
  call void @fn_emit(ptr @.str1049)
  %t24 = load ptr, ptr %t17
  call void @fn_emit(ptr %t24)
  call void @fn_emit(ptr @.str1050)
  %t25 = load ptr, ptr %t17
  call void @fn_emit(ptr %t25)
  call void @fn_emit(ptr @.str1051)
  %t26 = load ptr, ptr %t2
  %t27 = call ptr @fn_str_concat(ptr @.str1052, ptr %t26)
  %t28 = call ptr @fn_emit_bind(ptr %t27)
  store ptr %t28, ptr %t29
  %t30 = load ptr, ptr %t0
  %t31 = getelementptr inbounds %Cmp_Node, ptr %t30, i32 0, i32 5
  %t32 = load ptr, ptr %t31
  %t33 = call ptr @fn_emit_expr(ptr %t32)
  store ptr %t33, ptr %t34
  %t35 = load ptr, ptr %t29
  %t36 = load ptr, ptr %t34
  %t37 = getelementptr inbounds %Cmp_Val, ptr %t36, i32 0, i32 0
  %t38 = load ptr, ptr %t37
  %t39 = call ptr @fn_str_concat(ptr @.str1054, ptr %t38)
  %t40 = call ptr @fn_str_concat(ptr %t35, ptr %t39)
  %t41 = call ptr @fn_str_concat(ptr @.str1053, ptr %t40)
  %t42 = call ptr @fn_emit_bind(ptr %t41)
  store ptr %t42, ptr %t43
  call void @fn_emit(ptr @.str1055)
  %t44 = load ptr, ptr %t43
  call void @fn_emit(ptr %t44)
  call void @fn_emit(ptr @.str1056)
  %t45 = load ptr, ptr %t19
  call void @fn_emit(ptr %t45)
  call void @fn_emit(ptr @.str1057)
  %t46 = load ptr, ptr %t23
  call void @fn_emit(ptr %t46)
  call void @fn_emit(ptr @.str1058)
  %t47 = load ptr, ptr %t19
  call void @fn_emit(ptr %t47)
  call void @fn_emit(ptr @.str1059)
  store i32 0, ptr @g_g_term
  %t48 = load ptr, ptr %t21
  %t49 = load ptr, ptr %t23
  call void @fn_loop_push(ptr %t48, ptr %t49)
  %t50 = load ptr, ptr %t0
  %t51 = getelementptr inbounds %Cmp_Node, ptr %t50, i32 0, i32 6
  %t52 = load ptr, ptr %t51
  call void @fn_emit_block(ptr %t52)
  call void @fn_loop_pop()
  %t53 = load i32, ptr @g_g_term
  %t54 = icmp eq i32 %t53, 0
  %t55 = zext i1 %t54 to i32
  %t56 = icmp ne i32 %t55, 0
  br i1 %t56, label %then0, label %ifend2
then0:
  call void @fn_emit(ptr @.str1060)
  %t57 = load ptr, ptr %t21
  call void @fn_emit(ptr %t57)
  call void @fn_emit(ptr @.str1061)
  br label %ifend2
ifend2:
  %t58 = load ptr, ptr %t21
  call void @fn_emit(ptr %t58)
  call void @fn_emit(ptr @.str1062)
  %t59 = load ptr, ptr %t2
  %t60 = call ptr @fn_str_concat(ptr @.str1063, ptr %t59)
  %t61 = call ptr @fn_emit_bind(ptr %t60)
  store ptr %t61, ptr %t62
  %t63 = load ptr, ptr %t62
  %t64 = call ptr @fn_str_concat(ptr %t63, ptr @.str1065)
  %t65 = call ptr @fn_str_concat(ptr @.str1064, ptr %t64)
  %t66 = call ptr @fn_emit_bind(ptr %t65)
  store ptr %t66, ptr %t67
  %t68 = load ptr, ptr %t67
  %t69 = load ptr, ptr %t2
  call void @fn_store_at(ptr @.str1066, ptr %t68, ptr %t69)
  call void @fn_emit(ptr @.str1067)
  %t70 = load ptr, ptr %t17
  call void @fn_emit(ptr %t70)
  call void @fn_emit(ptr @.str1068)
  %t71 = load ptr, ptr %t23
  call void @fn_emit(ptr %t71)
  call void @fn_emit(ptr @.str1069)
  store i32 0, ptr @g_g_term
  br label %ret
ret:
  ret void
}

define void @fn_emit_return(ptr %arg_st) {
entry:
  %t0 = alloca ptr
  %t11 = alloca ptr
  store ptr %arg_st, ptr %t0
  %t1 = load ptr, ptr %t0
  %t2 = getelementptr inbounds %Cmp_Node, ptr %t1, i32 0, i32 4
  %t3 = load ptr, ptr %t2
  %t4 = icmp ne ptr %t3, null
  %t5 = zext i1 %t4 to i32
  %t6 = icmp ne i32 %t5, 0
  br i1 %t6, label %then0, label %ifend2
then0:
  %t7 = load ptr, ptr %t0
  %t8 = getelementptr inbounds %Cmp_Node, ptr %t7, i32 0, i32 4
  %t9 = load ptr, ptr %t8
  %t10 = call ptr @fn_emit_expr(ptr %t9)
  store ptr %t10, ptr %t11
  %t12 = load ptr, ptr @g_ret_ty
  %t13 = call ptr @fn_llty(ptr %t12)
  %t14 = load ptr, ptr %t11
  %t15 = getelementptr inbounds %Cmp_Val, ptr %t14, i32 0, i32 0
  %t16 = load ptr, ptr %t15
  call void @fn_store_at(ptr %t13, ptr %t16, ptr @.str1070)
  br label %ifend2
ifend2:
  call void @fn_emit(ptr @.str1071)
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
  %t4 = getelementptr inbounds %Cmp_Node, ptr %t3, i32 0, i32 7
  %t5 = load ptr, ptr %t4
  %t6 = getelementptr inbounds %LSlice, ptr %t5, i32 0, i32 1
  %t7 = load i32, ptr %t6
  %t8 = icmp slt i32 %t2, %t7
  %t9 = zext i1 %t8 to i32
  %t10 = icmp ne i32 %t9, 0
  br i1 %t10, label %wbody1, label %wend2
wbody1:
  %t12 = load ptr, ptr %t0
  %t13 = getelementptr inbounds %Cmp_Node, ptr %t12, i32 0, i32 7
  %t14 = load ptr, ptr %t13
  %t15 = getelementptr inbounds %LSlice, ptr %t14, i32 0, i32 0
  %t16 = load ptr, ptr %t15
  %t17 = load i32, ptr %t1
  %t18 = getelementptr inbounds ptr, ptr %t16, i32 %t17
  %t19 = load ptr, ptr %t18
  %t20 = getelementptr inbounds %Cmp_Node, ptr %t19, i32 0, i32 0
  %t21 = load i32, ptr %t20
  %t22 = icmp eq i32 %t21, 33
  %t23 = zext i1 %t22 to i32
  %t24 = icmp ne i32 %t23, 0
  %t25 = zext i1 %t24 to i32
  store i32 %t25, ptr %t11
  br i1 %t24, label %sc3, label %scend4
sc3:
  %t26 = load ptr, ptr %t0
  %t27 = getelementptr inbounds %Cmp_Node, ptr %t26, i32 0, i32 7
  %t28 = load ptr, ptr %t27
  %t29 = getelementptr inbounds %LSlice, ptr %t28, i32 0, i32 0
  %t30 = load ptr, ptr %t29
  %t31 = load i32, ptr %t1
  %t32 = getelementptr inbounds ptr, ptr %t30, i32 %t31
  %t33 = load ptr, ptr %t32
  %t34 = getelementptr inbounds %Cmp_Node, ptr %t33, i32 0, i32 1
  %t35 = load ptr, ptr %t34
  %t36 = call i32 @fn_str_eq(ptr %t35, ptr @.str1072)
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
  %t2 = getelementptr inbounds %Cmp_Node, ptr %t1, i32 0, i32 4
  %t3 = load ptr, ptr %t2
  %t4 = call ptr @fn_emit_expr(ptr %t3)
  store ptr %t4, ptr %t5
  %t6 = call ptr @fn_lbl(ptr @.str1073)
  store ptr %t6, ptr %t7
  store ptr null, ptr %t8
  store i32 0, ptr %t9
  br label %wcond0
wcond0:
  %t10 = load i32, ptr %t9
  %t11 = load ptr, ptr %t0
  %t12 = getelementptr inbounds %Cmp_Node, ptr %t11, i32 0, i32 7
  %t13 = load ptr, ptr %t12
  %t14 = getelementptr inbounds %LSlice, ptr %t13, i32 0, i32 1
  %t15 = load i32, ptr %t14
  %t16 = icmp slt i32 %t10, %t15
  %t17 = zext i1 %t16 to i32
  %t18 = icmp ne i32 %t17, 0
  br i1 %t18, label %wbody1, label %wend2
wbody1:
  %t19 = load ptr, ptr %t0
  %t20 = getelementptr inbounds %Cmp_Node, ptr %t19, i32 0, i32 7
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
  store ptr @.str1074, ptr %t32
  store i32 1, ptr %t33
  store i32 0, ptr %t34
  br label %wcond6
wcond6:
  %t35 = load i32, ptr %t34
  %t36 = load ptr, ptr %t27
  %t37 = getelementptr inbounds %Cmp_Node, ptr %t36, i32 0, i32 7
  %t38 = load ptr, ptr %t37
  %t39 = getelementptr inbounds %LSlice, ptr %t38, i32 0, i32 1
  %t40 = load i32, ptr %t39
  %t41 = icmp slt i32 %t35, %t40
  %t42 = zext i1 %t41 to i32
  %t43 = icmp ne i32 %t42, 0
  br i1 %t43, label %wbody7, label %wend8
wbody7:
  %t44 = load ptr, ptr %t27
  %t45 = getelementptr inbounds %Cmp_Node, ptr %t44, i32 0, i32 7
  %t46 = load ptr, ptr %t45
  %t47 = getelementptr inbounds %LSlice, ptr %t46, i32 0, i32 0
  %t48 = load ptr, ptr %t47
  %t49 = load i32, ptr %t34
  %t50 = getelementptr inbounds ptr, ptr %t48, i32 %t49
  %t51 = load ptr, ptr %t50
  %t52 = call ptr @fn_emit_expr(ptr %t51)
  store ptr %t52, ptr %t53
  %t54 = load ptr, ptr %t5
  %t55 = getelementptr inbounds %Cmp_Val, ptr %t54, i32 0, i32 0
  %t56 = load ptr, ptr %t55
  %t57 = load ptr, ptr %t53
  %t58 = getelementptr inbounds %Cmp_Val, ptr %t57, i32 0, i32 0
  %t59 = load ptr, ptr %t58
  %t60 = call ptr @fn_str_concat(ptr @.str1076, ptr %t59)
  %t61 = call ptr @fn_str_concat(ptr %t56, ptr %t60)
  %t62 = call ptr @fn_str_concat(ptr @.str1075, ptr %t61)
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
  %t70 = call ptr @fn_str_concat(ptr @.str1078, ptr %t69)
  %t71 = call ptr @fn_str_concat(ptr %t68, ptr %t70)
  %t72 = call ptr @fn_str_concat(ptr @.str1077, ptr %t71)
  %t73 = call ptr @fn_emit_bind(ptr %t72)
  store ptr %t73, ptr %t32
  br label %ifend11
ifend11:
  %t74 = load i32, ptr %t34
  %t75 = add i32 %t74, 1
  store i32 %t75, ptr %t34
  br label %wcond6
wend8:
  %t76 = call ptr @fn_lbl(ptr @.str1079)
  store ptr %t76, ptr %t77
  %t78 = call ptr @fn_lbl(ptr @.str1080)
  store ptr %t78, ptr %t79
  call void @fn_emit(ptr @.str1081)
  %t80 = load ptr, ptr %t32
  call void @fn_emit(ptr %t80)
  call void @fn_emit(ptr @.str1082)
  %t81 = load ptr, ptr %t77
  call void @fn_emit(ptr %t81)
  call void @fn_emit(ptr @.str1083)
  %t82 = load ptr, ptr %t79
  call void @fn_emit(ptr %t82)
  call void @fn_emit(ptr @.str1084)
  %t83 = load ptr, ptr %t77
  call void @fn_emit(ptr %t83)
  call void @fn_emit(ptr @.str1085)
  store i32 0, ptr @g_g_term
  %t84 = load ptr, ptr %t27
  %t85 = getelementptr inbounds %Cmp_Node, ptr %t84, i32 0, i32 4
  %t86 = load ptr, ptr %t85
  call void @fn_emit_block(ptr %t86)
  %t87 = load i32, ptr @g_g_term
  %t88 = icmp eq i32 %t87, 0
  %t89 = zext i1 %t88 to i32
  %t90 = icmp ne i32 %t89, 0
  br i1 %t90, label %then12, label %ifend14
then12:
  call void @fn_emit(ptr @.str1086)
  %t91 = load ptr, ptr %t7
  call void @fn_emit(ptr %t91)
  call void @fn_emit(ptr @.str1087)
  br label %ifend14
ifend14:
  %t92 = load ptr, ptr %t79
  call void @fn_emit(ptr %t92)
  call void @fn_emit(ptr @.str1088)
  store i32 0, ptr @g_g_term
  br label %ifend5
ifend5:
  %t93 = load i32, ptr %t9
  %t94 = add i32 %t93, 1
  store i32 %t94, ptr %t9
  br label %wcond0
wend2:
  %t95 = load ptr, ptr %t8
  %t96 = icmp ne ptr %t95, null
  %t97 = zext i1 %t96 to i32
  %t98 = icmp ne i32 %t97, 0
  br i1 %t98, label %then15, label %ifend17
then15:
  %t99 = load ptr, ptr %t8
  %t100 = getelementptr inbounds %Cmp_Node, ptr %t99, i32 0, i32 4
  %t101 = load ptr, ptr %t100
  call void @fn_emit_block(ptr %t101)
  br label %ifend17
ifend17:
  %t102 = load i32, ptr @g_g_term
  %t103 = icmp eq i32 %t102, 0
  %t104 = zext i1 %t103 to i32
  %t105 = icmp ne i32 %t104, 0
  br i1 %t105, label %then18, label %ifend20
then18:
  call void @fn_emit(ptr @.str1089)
  %t106 = load ptr, ptr %t7
  call void @fn_emit(ptr %t106)
  call void @fn_emit(ptr @.str1090)
  br label %ifend20
ifend20:
  %t107 = load ptr, ptr %t7
  call void @fn_emit(ptr %t107)
  call void @fn_emit(ptr @.str1091)
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
  %t44 = alloca ptr
  %t51 = alloca ptr
  %t64 = alloca ptr
  %t199 = alloca ptr
  store ptr %arg_st, ptr %t0
  %t1 = load ptr, ptr %t0
  %t2 = getelementptr inbounds %Cmp_Node, ptr %t1, i32 0, i32 0
  %t3 = load i32, ptr %t2
  %t4 = icmp eq i32 %t3, 10
  %t5 = zext i1 %t4 to i32
  %t6 = icmp ne i32 %t5, 0
  br i1 %t6, label %then0, label %ifend2
then0:
  %t7 = load ptr, ptr %t0
  %t8 = getelementptr inbounds %Cmp_Node, ptr %t7, i32 0, i32 3
  %t9 = load ptr, ptr %t8
  store ptr %t9, ptr %t10
  %t11 = load ptr, ptr %t10
  %t12 = icmp eq ptr %t11, null
  %t13 = zext i1 %t12 to i32
  %t14 = icmp ne i32 %t13, 0
  br i1 %t14, label %then3, label %ifend5
then3:
  %t15 = load ptr, ptr %t0
  %t16 = getelementptr inbounds %Cmp_Node, ptr %t15, i32 0, i32 4
  %t17 = load ptr, ptr %t16
  %t18 = call ptr @fn_emit_expr(ptr %t17)
  store ptr %t18, ptr %t19
  %t20 = load ptr, ptr %t19
  %t21 = getelementptr inbounds %Cmp_Val, ptr %t20, i32 0, i32 1
  %t22 = load ptr, ptr %t21
  store ptr %t22, ptr %t10
  %t23 = load ptr, ptr %t10
  %t24 = call ptr @fn_llty(ptr %t23)
  %t25 = call ptr @fn_emit_alloca(ptr %t24)
  store ptr %t25, ptr %t26
  %t27 = load ptr, ptr %t10
  %t28 = call ptr @fn_llty(ptr %t27)
  %t29 = load ptr, ptr %t19
  %t30 = getelementptr inbounds %Cmp_Val, ptr %t29, i32 0, i32 0
  %t31 = load ptr, ptr %t30
  %t32 = load ptr, ptr %t26
  call void @fn_store_at(ptr %t28, ptr %t31, ptr %t32)
  %t33 = load ptr, ptr %t0
  %t34 = getelementptr inbounds %Cmp_Node, ptr %t33, i32 0, i32 1
  %t35 = load ptr, ptr %t34
  %t36 = load ptr, ptr %t26
  %t37 = load ptr, ptr %t10
  call void @fn_loc_push(ptr %t35, ptr %t36, ptr %t37)
  %t38 = load ptr, ptr %t0
  %t39 = getelementptr inbounds %Cmp_Node, ptr %t38, i32 0, i32 2
  %t40 = load i32, ptr %t39
  call void @fn_loc_set_mut(i32 %t40)
  br label %ret
ifend5:
  %t41 = load ptr, ptr %t10
  %t42 = call ptr @fn_llty(ptr %t41)
  %t43 = call ptr @fn_emit_alloca(ptr %t42)
  store ptr %t43, ptr %t44
  %t45 = load ptr, ptr %t0
  %t46 = getelementptr inbounds %Cmp_Node, ptr %t45, i32 0, i32 4
  %t47 = load ptr, ptr %t46
  %t48 = icmp eq ptr %t47, null
  %t49 = zext i1 %t48 to i32
  %t50 = icmp ne i32 %t49, 0
  br i1 %t50, label %then6, label %else7
then6:
  store ptr @.str1092, ptr %t51
  %t52 = load ptr, ptr %t10
  %t53 = call ptr @fn_llty(ptr %t52)
  %t54 = call i32 @fn_str_eq(ptr %t53, ptr @.str1093)
  %t55 = icmp ne i32 %t54, 0
  br i1 %t55, label %then9, label %ifend11
then9:
  store ptr @.str1094, ptr %t51
  br label %ifend11
ifend11:
  %t56 = load ptr, ptr %t10
  %t57 = call ptr @fn_llty(ptr %t56)
  %t58 = load ptr, ptr %t51
  %t59 = load ptr, ptr %t44
  call void @fn_store_at(ptr %t57, ptr %t58, ptr %t59)
  br label %ifend8
else7:
  %t60 = load ptr, ptr %t0
  %t61 = getelementptr inbounds %Cmp_Node, ptr %t60, i32 0, i32 4
  %t62 = load ptr, ptr %t61
  %t63 = call ptr @fn_emit_expr(ptr %t62)
  store ptr %t63, ptr %t64
  %t65 = load ptr, ptr %t10
  %t66 = call ptr @fn_llty(ptr %t65)
  %t67 = load ptr, ptr %t64
  %t68 = getelementptr inbounds %Cmp_Val, ptr %t67, i32 0, i32 0
  %t69 = load ptr, ptr %t68
  %t70 = load ptr, ptr %t44
  call void @fn_store_at(ptr %t66, ptr %t69, ptr %t70)
  br label %ifend8
ifend8:
  %t71 = load ptr, ptr %t0
  %t72 = getelementptr inbounds %Cmp_Node, ptr %t71, i32 0, i32 1
  %t73 = load ptr, ptr %t72
  %t74 = load ptr, ptr %t44
  %t75 = load ptr, ptr %t10
  call void @fn_loc_push(ptr %t73, ptr %t74, ptr %t75)
  %t76 = load ptr, ptr %t0
  %t77 = getelementptr inbounds %Cmp_Node, ptr %t76, i32 0, i32 2
  %t78 = load i32, ptr %t77
  call void @fn_loc_set_mut(i32 %t78)
  br label %ret
ifend2:
  %t79 = load ptr, ptr %t0
  %t80 = getelementptr inbounds %Cmp_Node, ptr %t79, i32 0, i32 0
  %t81 = load i32, ptr %t80
  %t82 = icmp eq i32 %t81, 11
  %t83 = zext i1 %t82 to i32
  %t84 = icmp ne i32 %t83, 0
  br i1 %t84, label %then12, label %ifend14
then12:
  %t85 = load ptr, ptr %t0
  call void @fn_emit_assign(ptr %t85)
  br label %ret
ifend14:
  %t86 = load ptr, ptr %t0
  %t87 = getelementptr inbounds %Cmp_Node, ptr %t86, i32 0, i32 0
  %t88 = load i32, ptr %t87
  %t89 = icmp eq i32 %t88, 12
  %t90 = zext i1 %t89 to i32
  %t91 = icmp ne i32 %t90, 0
  br i1 %t91, label %then15, label %ifend17
then15:
  %t92 = load ptr, ptr %t0
  call void @fn_emit_if(ptr %t92)
  br label %ret
ifend17:
  %t93 = load ptr, ptr %t0
  %t94 = getelementptr inbounds %Cmp_Node, ptr %t93, i32 0, i32 0
  %t95 = load i32, ptr %t94
  %t96 = icmp eq i32 %t95, 13
  %t97 = zext i1 %t96 to i32
  %t98 = icmp ne i32 %t97, 0
  br i1 %t98, label %then18, label %ifend20
then18:
  %t99 = load ptr, ptr %t0
  call void @fn_emit_while(ptr %t99)
  br label %ret
ifend20:
  %t100 = load ptr, ptr %t0
  %t101 = getelementptr inbounds %Cmp_Node, ptr %t100, i32 0, i32 0
  %t102 = load i32, ptr %t101
  %t103 = icmp eq i32 %t102, 14
  %t104 = zext i1 %t103 to i32
  %t105 = icmp ne i32 %t104, 0
  br i1 %t105, label %then21, label %ifend23
then21:
  %t106 = load ptr, ptr %t0
  call void @fn_emit_for(ptr %t106)
  br label %ret
ifend23:
  %t107 = load ptr, ptr %t0
  %t108 = getelementptr inbounds %Cmp_Node, ptr %t107, i32 0, i32 0
  %t109 = load i32, ptr %t108
  %t110 = icmp eq i32 %t109, 15
  %t111 = zext i1 %t110 to i32
  %t112 = icmp ne i32 %t111, 0
  br i1 %t112, label %then24, label %ifend26
then24:
  %t113 = load ptr, ptr %t0
  call void @fn_emit_return(ptr %t113)
  br label %ret
ifend26:
  %t114 = load ptr, ptr %t0
  %t115 = getelementptr inbounds %Cmp_Node, ptr %t114, i32 0, i32 0
  %t116 = load i32, ptr %t115
  %t117 = icmp eq i32 %t116, 17
  %t118 = zext i1 %t117 to i32
  %t119 = icmp ne i32 %t118, 0
  br i1 %t119, label %then27, label %ifend29
then27:
  call void @fn_emit(ptr @.str1095)
  %t120 = load ptr, ptr @g_brk_lbl
  %t121 = getelementptr inbounds %LSlice, ptr %t120, i32 0, i32 0
  %t122 = load ptr, ptr %t121
  %t123 = load i32, ptr @g_nloop
  %t124 = sub i32 %t123, 1
  %t125 = getelementptr inbounds ptr, ptr %t122, i32 %t124
  %t126 = load ptr, ptr %t125
  call void @fn_emit(ptr %t126)
  call void @fn_emit(ptr @.str1096)
  store i32 1, ptr @g_g_term
  br label %ret
ifend29:
  %t127 = load ptr, ptr %t0
  %t128 = getelementptr inbounds %Cmp_Node, ptr %t127, i32 0, i32 0
  %t129 = load i32, ptr %t128
  %t130 = icmp eq i32 %t129, 18
  %t131 = zext i1 %t130 to i32
  %t132 = icmp ne i32 %t131, 0
  br i1 %t132, label %then30, label %ifend32
then30:
  call void @fn_emit(ptr @.str1097)
  %t133 = load ptr, ptr @g_cnt_lbl
  %t134 = getelementptr inbounds %LSlice, ptr %t133, i32 0, i32 0
  %t135 = load ptr, ptr %t134
  %t136 = load i32, ptr @g_nloop
  %t137 = sub i32 %t136, 1
  %t138 = getelementptr inbounds ptr, ptr %t135, i32 %t137
  %t139 = load ptr, ptr %t138
  call void @fn_emit(ptr %t139)
  call void @fn_emit(ptr @.str1098)
  store i32 1, ptr @g_g_term
  br label %ret
ifend32:
  %t140 = load ptr, ptr %t0
  %t141 = getelementptr inbounds %Cmp_Node, ptr %t140, i32 0, i32 0
  %t142 = load i32, ptr %t141
  %t143 = icmp eq i32 %t142, 19
  %t144 = zext i1 %t143 to i32
  %t145 = icmp ne i32 %t144, 0
  br i1 %t145, label %then33, label %ifend35
then33:
  %t146 = load ptr, ptr %t0
  call void @fn_emit_match(ptr %t146)
  br label %ret
ifend35:
  %t147 = load ptr, ptr %t0
  %t148 = getelementptr inbounds %Cmp_Node, ptr %t147, i32 0, i32 0
  %t149 = load i32, ptr %t148
  %t150 = icmp eq i32 %t149, 21
  %t151 = zext i1 %t150 to i32
  %t152 = icmp ne i32 %t151, 0
  br i1 %t152, label %then36, label %ifend38
then36:
  %t153 = load ptr, ptr %t0
  call void @fn_emit_query(ptr %t153)
  br label %ret
ifend38:
  %t154 = load ptr, ptr %t0
  %t155 = getelementptr inbounds %Cmp_Node, ptr %t154, i32 0, i32 0
  %t156 = load i32, ptr %t155
  %t157 = icmp eq i32 %t156, 22
  %t158 = zext i1 %t157 to i32
  %t159 = icmp ne i32 %t158, 0
  br i1 %t159, label %then39, label %ifend41
then39:
  %t160 = load ptr, ptr %t0
  call void @fn_emit_spawn(ptr %t160)
  br label %ret
ifend41:
  %t161 = load ptr, ptr %t0
  %t162 = getelementptr inbounds %Cmp_Node, ptr %t161, i32 0, i32 0
  %t163 = load i32, ptr %t162
  %t164 = icmp eq i32 %t163, 23
  %t165 = zext i1 %t164 to i32
  %t166 = icmp ne i32 %t165, 0
  br i1 %t166, label %then42, label %ifend44
then42:
  %t167 = load ptr, ptr %t0
  call void @fn_emit_despawn(ptr %t167)
  br label %ret
ifend44:
  %t168 = load ptr, ptr %t0
  %t169 = getelementptr inbounds %Cmp_Node, ptr %t168, i32 0, i32 0
  %t170 = load i32, ptr %t169
  %t171 = icmp eq i32 %t170, 28
  %t172 = zext i1 %t171 to i32
  %t173 = icmp ne i32 %t172, 0
  br i1 %t173, label %then45, label %ifend47
then45:
  %t174 = load ptr, ptr %t0
  call void @fn_emit_toggle(ptr %t174)
  br label %ret
ifend47:
  %t175 = load ptr, ptr %t0
  %t176 = getelementptr inbounds %Cmp_Node, ptr %t175, i32 0, i32 0
  %t177 = load i32, ptr %t176
  %t178 = icmp eq i32 %t177, 24
  %t179 = zext i1 %t178 to i32
  %t180 = icmp ne i32 %t179, 0
  br i1 %t180, label %then48, label %ifend50
then48:
  %t181 = load ptr, ptr %t0
  call void @fn_emit_machine(ptr %t181)
  br label %ret
ifend50:
  %t182 = load ptr, ptr %t0
  %t183 = getelementptr inbounds %Cmp_Node, ptr %t182, i32 0, i32 0
  %t184 = load i32, ptr %t183
  %t185 = icmp eq i32 %t184, 26
  %t186 = zext i1 %t185 to i32
  %t187 = icmp ne i32 %t186, 0
  br i1 %t187, label %then51, label %ifend53
then51:
  %t188 = load ptr, ptr %t0
  call void @fn_emit_become(ptr %t188)
  br label %ret
ifend53:
  %t189 = load ptr, ptr %t0
  %t190 = getelementptr inbounds %Cmp_Node, ptr %t189, i32 0, i32 0
  %t191 = load i32, ptr %t190
  %t192 = icmp eq i32 %t191, 16
  %t193 = zext i1 %t192 to i32
  %t194 = icmp ne i32 %t193, 0
  br i1 %t194, label %then54, label %ifend56
then54:
  %t195 = load ptr, ptr %t0
  %t196 = getelementptr inbounds %Cmp_Node, ptr %t195, i32 0, i32 4
  %t197 = load ptr, ptr %t196
  %t198 = call ptr @fn_emit_expr(ptr %t197)
  store ptr %t198, ptr %t199
  br label %ret
ifend56:
  call void @fn_perr(ptr @.str1099)
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
  %t14 = getelementptr inbounds %Cmp_Node, ptr %t13, i32 0, i32 0
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

define i32 @fn_has_models() {
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
  %t14 = getelementptr inbounds %Cmp_Node, ptr %t13, i32 0, i32 0
  %t15 = load i32, ptr %t14
  %t16 = icmp eq i32 %t15, 10
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

define i32 @fn_has_ecs() {
entry:
  %retval = alloca i32
  %t0 = alloca i32
  %t1 = call i32 @fn_has_systems()
  %t2 = icmp ne i32 %t1, 0
  %t3 = zext i1 %t2 to i32
  store i32 %t3, ptr %t0
  br i1 %t2, label %scend1, label %sc0
sc0:
  %t4 = call i32 @fn_has_models()
  %t5 = icmp ne i32 %t4, 0
  %t6 = zext i1 %t5 to i32
  store i32 %t6, ptr %t0
  br label %scend1
scend1:
  %t7 = load i32, ptr %t0
  store i32 %t7, ptr %retval
  br label %ret
ret:
  %t8 = load i32, ptr %retval
  ret i32 %t8
}

define void @fn_emit_ecs_storage() {
entry:
  %t1 = alloca ptr
  %t11 = alloca i32
  %t25 = alloca ptr
  call void @fn_emith(ptr @.str1100)
  call void @fn_emith(ptr @.str1101)
  call void @fn_emith(ptr @.str1102)
  %t0 = call ptr @fn_itoa(i32 1024)
  store ptr %t0, ptr %t1
  %t2 = load ptr, ptr %t1
  %t3 = call ptr @fn_str_concat(ptr %t2, ptr @.str1104)
  %t4 = call ptr @fn_str_concat(ptr @.str1103, ptr %t3)
  call void @fn_emith(ptr %t4)
  %t5 = load ptr, ptr %t1
  %t6 = call ptr @fn_str_concat(ptr %t5, ptr @.str1106)
  %t7 = call ptr @fn_str_concat(ptr @.str1105, ptr %t6)
  call void @fn_emith(ptr %t7)
  %t8 = load ptr, ptr %t1
  %t9 = call ptr @fn_str_concat(ptr %t8, ptr @.str1108)
  %t10 = call ptr @fn_str_concat(ptr @.str1107, ptr %t9)
  call void @fn_emith(ptr %t10)
  call void @fn_emith(ptr @.str1109)
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
  %t27 = getelementptr inbounds %Cmp_Node, ptr %t26, i32 0, i32 0
  %t28 = load i32, ptr %t27
  %t29 = icmp eq i32 %t28, 8
  %t30 = zext i1 %t29 to i32
  %t31 = icmp ne i32 %t30, 0
  br i1 %t31, label %then3, label %ifend5
then3:
  %t32 = load ptr, ptr %t25
  %t33 = getelementptr inbounds %Cmp_Node, ptr %t32, i32 0, i32 1
  %t34 = load ptr, ptr %t33
  %t35 = load ptr, ptr %t1
  %t36 = load ptr, ptr %t25
  %t37 = getelementptr inbounds %Cmp_Node, ptr %t36, i32 0, i32 1
  %t38 = load ptr, ptr %t37
  %t39 = call ptr @fn_str_concat(ptr %t38, ptr @.str1113)
  %t40 = call ptr @fn_str_concat(ptr @.str1112, ptr %t39)
  %t41 = call ptr @fn_str_concat(ptr %t35, ptr %t40)
  %t42 = call ptr @fn_str_concat(ptr @.str1111, ptr %t41)
  %t43 = call ptr @fn_str_concat(ptr %t34, ptr %t42)
  %t44 = call ptr @fn_str_concat(ptr @.str1110, ptr %t43)
  call void @fn_emith(ptr %t44)
  %t45 = load ptr, ptr %t25
  %t46 = getelementptr inbounds %Cmp_Node, ptr %t45, i32 0, i32 1
  %t47 = load ptr, ptr %t46
  %t48 = load ptr, ptr %t1
  %t49 = call ptr @fn_str_concat(ptr %t48, ptr @.str1116)
  %t50 = call ptr @fn_str_concat(ptr @.str1115, ptr %t49)
  %t51 = call ptr @fn_str_concat(ptr %t47, ptr %t50)
  %t52 = call ptr @fn_str_concat(ptr @.str1114, ptr %t51)
  call void @fn_emith(ptr %t52)
  br label %ifend5
ifend5:
  %t53 = load ptr, ptr %t25
  %t54 = getelementptr inbounds %Cmp_Node, ptr %t53, i32 0, i32 0
  %t55 = load i32, ptr %t54
  %t56 = icmp eq i32 %t55, 10
  %t57 = zext i1 %t56 to i32
  %t58 = icmp ne i32 %t57, 0
  br i1 %t58, label %then6, label %ifend8
then6:
  %t59 = load ptr, ptr %t25
  %t60 = getelementptr inbounds %Cmp_Node, ptr %t59, i32 0, i32 1
  %t61 = load ptr, ptr %t60
  %t62 = call ptr @fn_str_concat(ptr %t61, ptr @.str1118)
  %t63 = call ptr @fn_str_concat(ptr @.str1117, ptr %t62)
  call void @fn_emith(ptr %t63)
  br label %ifend8
ifend8:
  %t64 = load ptr, ptr %t25
  %t65 = getelementptr inbounds %Cmp_Node, ptr %t64, i32 0, i32 0
  %t66 = load i32, ptr %t65
  %t67 = icmp eq i32 %t66, 9
  %t68 = zext i1 %t67 to i32
  %t69 = icmp ne i32 %t68, 0
  br i1 %t69, label %then9, label %ifend11
then9:
  %t70 = load ptr, ptr %t25
  %t71 = getelementptr inbounds %Cmp_Node, ptr %t70, i32 0, i32 1
  %t72 = load ptr, ptr %t71
  %t73 = call ptr @fn_str_concat(ptr %t72, ptr @.str1120)
  %t74 = call ptr @fn_str_concat(ptr @.str1119, ptr %t73)
  call void @fn_emith(ptr %t74)
  br label %ifend11
ifend11:
  %t75 = load i32, ptr %t11
  %t76 = add i32 %t75, 1
  store i32 %t76, ptr %t11
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
  call void @fn_emit(ptr @.str1121)
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
  %t16 = getelementptr inbounds %Cmp_Node, ptr %t15, i32 0, i32 0
  %t17 = load i32, ptr %t16
  %t18 = icmp eq i32 %t17, 8
  %t19 = zext i1 %t18 to i32
  %t20 = icmp ne i32 %t19, 0
  br i1 %t20, label %then3, label %ifend5
then3:
  %t21 = load i32, ptr %t2
  %t22 = call ptr @fn_itoa(i32 %t21)
  %t23 = call ptr @fn_str_concat(ptr @.str1122, ptr %t22)
  store ptr %t23, ptr %t24
  call void @fn_emit(ptr @.str1123)
  %t25 = load ptr, ptr %t24
  call void @fn_emit(ptr %t25)
  call void @fn_emit(ptr @.str1124)
  %t26 = load ptr, ptr %t1
  call void @fn_emit(ptr %t26)
  call void @fn_emit(ptr @.str1125)
  %t27 = load ptr, ptr @g_prog
  %t28 = getelementptr inbounds %LSlice, ptr %t27, i32 0, i32 0
  %t29 = load ptr, ptr %t28
  %t30 = load i32, ptr %t2
  %t31 = getelementptr inbounds ptr, ptr %t29, i32 %t30
  %t32 = load ptr, ptr %t31
  %t33 = getelementptr inbounds %Cmp_Node, ptr %t32, i32 0, i32 1
  %t34 = load ptr, ptr %t33
  call void @fn_emit(ptr %t34)
  call void @fn_emit(ptr @.str1126)
  call void @fn_emit(ptr @.str1127)
  %t35 = load ptr, ptr %t24
  call void @fn_emit(ptr %t35)
  call void @fn_emit(ptr @.str1128)
  br label %ifend5
ifend5:
  %t36 = load i32, ptr %t2
  %t37 = add i32 %t36, 1
  store i32 %t37, ptr %t2
  br label %wcond0
wend2:
  call void @fn_emit(ptr @.str1129)
  %t38 = load ptr, ptr %t1
  call void @fn_emit(ptr %t38)
  call void @fn_emit(ptr @.str1130)
  call void @fn_emit(ptr @.str1131)
  call void @fn_emit(ptr @.str1132)
  call void @fn_emit(ptr @.str1133)
  call void @fn_emit(ptr @.str1134)
  call void @fn_emit(ptr @.str1135)
  call void @fn_emit(ptr @.str1136)
  call void @fn_emit(ptr @.str1137)
  call void @fn_emit(ptr @.str1138)
  call void @fn_emit(ptr @.str1139)
  %t39 = load ptr, ptr %t1
  call void @fn_emit(ptr %t39)
  call void @fn_emit(ptr @.str1140)
  call void @fn_emit(ptr @.str1141)
  call void @fn_emit(ptr @.str1142)
  call void @fn_emit(ptr @.str1143)
  call void @fn_emit(ptr @.str1144)
  call void @fn_emit(ptr @.str1145)
  call void @fn_emit(ptr @.str1146)
  call void @fn_emit(ptr @.str1147)
  call void @fn_emit(ptr @.str1148)
  call void @fn_emit(ptr @.str1149)
  call void @fn_emit(ptr @.str1150)
  call void @fn_emit(ptr @.str1151)
  %t40 = load ptr, ptr %t1
  call void @fn_emit(ptr %t40)
  call void @fn_emit(ptr @.str1152)
  call void @fn_emit(ptr @.str1153)
  call void @fn_emit(ptr @.str1154)
  call void @fn_emit(ptr @.str1155)
  call void @fn_emit(ptr @.str1156)
  %t41 = load ptr, ptr %t1
  call void @fn_emit(ptr %t41)
  call void @fn_emit(ptr @.str1157)
  call void @fn_emit(ptr @.str1158)
  call void @fn_emit(ptr @.str1159)
  call void @fn_emit(ptr @.str1160)
  call void @fn_emit(ptr @.str1161)
  %t42 = load ptr, ptr %t1
  call void @fn_emit(ptr %t42)
  call void @fn_emit(ptr @.str1162)
  call void @fn_emit(ptr @.str1163)
  call void @fn_emit(ptr @.str1164)
  call void @fn_emit(ptr @.str1165)
  call void @fn_emit(ptr @.str1166)
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
  %t16 = getelementptr inbounds %Cmp_Node, ptr %t15, i32 0, i32 0
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
  %t27 = getelementptr inbounds %Cmp_Node, ptr %t26, i32 0, i32 1
  %t28 = load ptr, ptr %t27
  %t29 = load ptr, ptr %t0
  %t30 = call i32 @fn_str_eq(ptr %t28, ptr %t29)
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
  %t141 = alloca ptr
  %t147 = alloca ptr
  %t152 = alloca ptr
  %t160 = alloca ptr
  %t170 = alloca ptr
  %t176 = alloca ptr
  %t184 = alloca i32
  %t185 = alloca i32
  %t203 = alloca ptr
  %t204 = alloca i32
  %t232 = alloca ptr
  %t243 = alloca ptr
  %t274 = alloca ptr
  %t281 = alloca ptr
  %t283 = alloca ptr
  %t303 = alloca ptr
  %t308 = alloca ptr
  store ptr %arg_st, ptr %t0
  %t1 = call ptr @fn_itoa(i32 1024)
  store ptr %t1, ptr %t2
  %t3 = call ptr @fn_emit_alloca(ptr @.str1167)
  store ptr %t3, ptr %t4
  %t5 = load ptr, ptr %t4
  call void @fn_store_at(ptr @.str1168, ptr @.str1169, ptr %t5)
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
  %t41 = call ptr @fn_lbl(ptr @.str1170)
  store ptr %t41, ptr %t42
  %t43 = call ptr @fn_lbl(ptr @.str1171)
  store ptr %t43, ptr %t44
  %t45 = call ptr @fn_lbl(ptr @.str1172)
  store ptr %t45, ptr %t46
  %t47 = call ptr @fn_lbl(ptr @.str1173)
  store ptr %t47, ptr %t48
  call void @fn_emit(ptr @.str1174)
  %t49 = load ptr, ptr %t42
  call void @fn_emit(ptr %t49)
  call void @fn_emit(ptr @.str1175)
  %t50 = load ptr, ptr %t42
  call void @fn_emit(ptr %t50)
  call void @fn_emit(ptr @.str1176)
  %t51 = load ptr, ptr %t4
  %t52 = call ptr @fn_str_concat(ptr @.str1177, ptr %t51)
  %t53 = call ptr @fn_emit_bind(ptr %t52)
  store ptr %t53, ptr %t54
  %t55 = call ptr @fn_emit_bind(ptr @.str1178)
  store ptr %t55, ptr %t56
  %t57 = load ptr, ptr %t54
  %t58 = load ptr, ptr %t56
  %t59 = call ptr @fn_str_concat(ptr @.str1180, ptr %t58)
  %t60 = call ptr @fn_str_concat(ptr %t57, ptr %t59)
  %t61 = call ptr @fn_str_concat(ptr @.str1179, ptr %t60)
  %t62 = call ptr @fn_emit_bind(ptr %t61)
  store ptr %t62, ptr %t63
  call void @fn_emit(ptr @.str1181)
  %t64 = load ptr, ptr %t63
  call void @fn_emit(ptr %t64)
  call void @fn_emit(ptr @.str1182)
  %t65 = load ptr, ptr %t44
  call void @fn_emit(ptr %t65)
  call void @fn_emit(ptr @.str1183)
  %t66 = load ptr, ptr %t48
  call void @fn_emit(ptr %t66)
  call void @fn_emit(ptr @.str1184)
  %t67 = load ptr, ptr %t44
  call void @fn_emit(ptr %t67)
  call void @fn_emit(ptr @.str1185)
  store i32 0, ptr @g_g_term
  %t68 = load ptr, ptr %t4
  %t69 = call ptr @fn_str_concat(ptr @.str1186, ptr %t68)
  %t70 = call ptr @fn_emit_bind(ptr %t69)
  store ptr %t70, ptr %t71
  %t72 = call ptr @fn_nreg()
  store ptr %t72, ptr %t73
  call void @fn_emit(ptr @.str1187)
  %t74 = load ptr, ptr %t73
  call void @fn_emit(ptr %t74)
  call void @fn_emit(ptr @.str1188)
  %t75 = load ptr, ptr %t2
  call void @fn_emit(ptr %t75)
  call void @fn_emit(ptr @.str1189)
  %t76 = load ptr, ptr %t71
  call void @fn_emit(ptr %t76)
  call void @fn_emit(ptr @.str1190)
  %t77 = load ptr, ptr %t73
  %t78 = call ptr @fn_str_concat(ptr @.str1191, ptr %t77)
  %t79 = call ptr @fn_emit_bind(ptr %t78)
  store ptr %t79, ptr %t80
  %t81 = load ptr, ptr %t80
  %t82 = call ptr @fn_str_concat(ptr %t81, ptr @.str1193)
  %t83 = call ptr @fn_str_concat(ptr @.str1192, ptr %t82)
  %t84 = call ptr @fn_emit_bind(ptr %t83)
  store ptr %t84, ptr %t85
  %t86 = call ptr @fn_lbl(ptr @.str1194)
  store ptr %t86, ptr %t87
  call void @fn_emit(ptr @.str1195)
  %t88 = load ptr, ptr %t85
  call void @fn_emit(ptr %t88)
  call void @fn_emit(ptr @.str1196)
  %t89 = load ptr, ptr %t87
  call void @fn_emit(ptr %t89)
  call void @fn_emit(ptr @.str1197)
  %t90 = load ptr, ptr %t46
  call void @fn_emit(ptr %t90)
  call void @fn_emit(ptr @.str1198)
  %t91 = load ptr, ptr %t87
  call void @fn_emit(ptr %t91)
  call void @fn_emit(ptr @.str1199)
  %t92 = load ptr, ptr %t0
  %t93 = getelementptr inbounds %Cmp_Node, ptr %t92, i32 0, i32 6
  %t94 = load ptr, ptr %t93
  store ptr %t94, ptr %t95
  store i32 0, ptr %t96
  br label %wcond5
wcond5:
  %t97 = load i32, ptr %t96
  %t98 = load ptr, ptr %t95
  %t99 = getelementptr inbounds %Cmp_Node, ptr %t98, i32 0, i32 7
  %t100 = load ptr, ptr %t99
  %t101 = getelementptr inbounds %LSlice, ptr %t100, i32 0, i32 1
  %t102 = load i32, ptr %t101
  %t103 = icmp slt i32 %t97, %t102
  %t104 = zext i1 %t103 to i32
  %t105 = icmp ne i32 %t104, 0
  br i1 %t105, label %wbody6, label %wend7
wbody6:
  %t106 = load ptr, ptr %t95
  %t107 = getelementptr inbounds %Cmp_Node, ptr %t106, i32 0, i32 7
  %t108 = load ptr, ptr %t107
  %t109 = getelementptr inbounds %LSlice, ptr %t108, i32 0, i32 0
  %t110 = load ptr, ptr %t109
  %t111 = load i32, ptr %t96
  %t112 = getelementptr inbounds ptr, ptr %t110, i32 %t111
  %t113 = load ptr, ptr %t112
  store ptr %t113, ptr %t114
  %t115 = load ptr, ptr %t114
  %t116 = getelementptr inbounds %Cmp_Node, ptr %t115, i32 0, i32 1
  %t117 = load ptr, ptr %t116
  %t118 = call i32 @fn_find_arch_id(ptr %t117)
  store i32 %t118, ptr %t119
  store ptr @.str1200, ptr %t120
  %t121 = load i32, ptr %t119
  %t122 = icmp sgt i32 %t121, 0
  %t123 = zext i1 %t122 to i32
  %t124 = icmp ne i32 %t123, 0
  br i1 %t124, label %then8, label %else9
then8:
  %t125 = call ptr @fn_nreg()
  store ptr %t125, ptr %t126
  call void @fn_emit(ptr @.str1201)
  %t127 = load ptr, ptr %t126
  call void @fn_emit(ptr %t127)
  call void @fn_emit(ptr @.str1202)
  %t128 = load ptr, ptr %t2
  call void @fn_emit(ptr %t128)
  call void @fn_emit(ptr @.str1203)
  %t129 = load ptr, ptr %t71
  call void @fn_emit(ptr %t129)
  call void @fn_emit(ptr @.str1204)
  %t130 = load ptr, ptr %t126
  %t131 = call ptr @fn_str_concat(ptr @.str1205, ptr %t130)
  %t132 = call ptr @fn_emit_bind(ptr %t131)
  store ptr %t132, ptr %t133
  %t134 = load ptr, ptr %t133
  %t135 = load i32, ptr %t119
  %t136 = call ptr @fn_itoa(i32 %t135)
  %t137 = call ptr @fn_str_concat(ptr @.str1207, ptr %t136)
  %t138 = call ptr @fn_str_concat(ptr %t134, ptr %t137)
  %t139 = call ptr @fn_str_concat(ptr @.str1206, ptr %t138)
  %t140 = call ptr @fn_emit_bind(ptr %t139)
  store ptr %t140, ptr %t141
  %t142 = load ptr, ptr %t114
  %t143 = getelementptr inbounds %Cmp_Node, ptr %t142, i32 0, i32 1
  %t144 = load ptr, ptr %t143
  %t145 = call ptr @fn_str_concat(ptr @.str1208, ptr %t144)
  %t146 = call ptr @fn_emit_bind(ptr %t145)
  store ptr %t146, ptr %t147
  %t148 = load ptr, ptr %t147
  %t149 = call ptr @fn_str_concat(ptr %t148, ptr @.str1210)
  %t150 = call ptr @fn_str_concat(ptr @.str1209, ptr %t149)
  %t151 = call ptr @fn_emit_bind(ptr %t150)
  store ptr %t151, ptr %t152
  %t153 = load ptr, ptr %t141
  %t154 = load ptr, ptr %t152
  %t155 = call ptr @fn_str_concat(ptr @.str1212, ptr %t154)
  %t156 = call ptr @fn_str_concat(ptr %t153, ptr %t155)
  %t157 = call ptr @fn_str_concat(ptr @.str1211, ptr %t156)
  %t158 = call ptr @fn_emit_bind(ptr %t157)
  store ptr %t158, ptr %t120
  br label %ifend10
else9:
  %t159 = call ptr @fn_nreg()
  store ptr %t159, ptr %t160
  call void @fn_emit(ptr @.str1213)
  %t161 = load ptr, ptr %t160
  call void @fn_emit(ptr %t161)
  call void @fn_emit(ptr @.str1214)
  %t162 = load ptr, ptr %t2
  call void @fn_emit(ptr %t162)
  call void @fn_emit(ptr @.str1215)
  %t163 = load ptr, ptr %t114
  %t164 = getelementptr inbounds %Cmp_Node, ptr %t163, i32 0, i32 1
  %t165 = load ptr, ptr %t164
  call void @fn_emit(ptr %t165)
  call void @fn_emit(ptr @.str1216)
  %t166 = load ptr, ptr %t71
  call void @fn_emit(ptr %t166)
  call void @fn_emit(ptr @.str1217)
  %t167 = load ptr, ptr %t160
  %t168 = call ptr @fn_str_concat(ptr @.str1218, ptr %t167)
  %t169 = call ptr @fn_emit_bind(ptr %t168)
  store ptr %t169, ptr %t170
  %t171 = load ptr, ptr %t170
  %t172 = call ptr @fn_str_concat(ptr %t171, ptr @.str1220)
  %t173 = call ptr @fn_str_concat(ptr @.str1219, ptr %t172)
  %t174 = call ptr @fn_emit_bind(ptr %t173)
  store ptr %t174, ptr %t120
  br label %ifend10
ifend10:
  %t175 = call ptr @fn_lbl(ptr @.str1221)
  store ptr %t175, ptr %t176
  call void @fn_emit(ptr @.str1222)
  %t177 = load ptr, ptr %t120
  call void @fn_emit(ptr %t177)
  call void @fn_emit(ptr @.str1223)
  %t178 = load ptr, ptr %t176
  call void @fn_emit(ptr %t178)
  call void @fn_emit(ptr @.str1224)
  %t179 = load ptr, ptr %t46
  call void @fn_emit(ptr %t179)
  call void @fn_emit(ptr @.str1225)
  %t180 = load ptr, ptr %t176
  call void @fn_emit(ptr %t180)
  call void @fn_emit(ptr @.str1226)
  %t181 = load i32, ptr %t96
  %t182 = add i32 %t181, 1
  store i32 %t182, ptr %t96
  br label %wcond5
wend7:
  %t183 = load i32, ptr @g_nloc
  store i32 %t183, ptr %t184
  store i32 0, ptr %t185
  store i32 0, ptr %t96
  br label %wcond11
wcond11:
  %t186 = load i32, ptr %t96
  %t187 = load ptr, ptr %t95
  %t188 = getelementptr inbounds %Cmp_Node, ptr %t187, i32 0, i32 7
  %t189 = load ptr, ptr %t188
  %t190 = getelementptr inbounds %LSlice, ptr %t189, i32 0, i32 1
  %t191 = load i32, ptr %t190
  %t192 = icmp slt i32 %t186, %t191
  %t193 = zext i1 %t192 to i32
  %t194 = icmp ne i32 %t193, 0
  br i1 %t194, label %wbody12, label %wend13
wbody12:
  %t195 = load ptr, ptr %t95
  %t196 = getelementptr inbounds %Cmp_Node, ptr %t195, i32 0, i32 7
  %t197 = load ptr, ptr %t196
  %t198 = getelementptr inbounds %LSlice, ptr %t197, i32 0, i32 0
  %t199 = load ptr, ptr %t198
  %t200 = load i32, ptr %t96
  %t201 = getelementptr inbounds ptr, ptr %t199, i32 %t200
  %t202 = load ptr, ptr %t201
  store ptr %t202, ptr %t203
  %t205 = load ptr, ptr %t203
  %t206 = getelementptr inbounds %Cmp_Node, ptr %t205, i32 0, i32 2
  %t207 = load i32, ptr %t206
  %t208 = icmp eq i32 %t207, 0
  %t209 = zext i1 %t208 to i32
  %t210 = icmp ne i32 %t209, 0
  %t211 = zext i1 %t210 to i32
  store i32 %t211, ptr %t204
  br i1 %t210, label %sc14, label %scend15
sc14:
  %t212 = load ptr, ptr %t203
  %t213 = getelementptr inbounds %Cmp_Node, ptr %t212, i32 0, i32 1
  %t214 = load ptr, ptr %t213
  %t215 = call i32 @fn_find_arch_id(ptr %t214)
  %t216 = icmp eq i32 %t215, 0
  %t217 = zext i1 %t216 to i32
  %t218 = icmp ne i32 %t217, 0
  %t219 = zext i1 %t218 to i32
  store i32 %t219, ptr %t204
  br label %scend15
scend15:
  %t220 = load i32, ptr %t204
  %t221 = icmp ne i32 %t220, 0
  br i1 %t221, label %then16, label %ifend18
then16:
  %t222 = load i32, ptr %t185
  %t223 = load ptr, ptr %t0
  %t224 = getelementptr inbounds %Cmp_Node, ptr %t223, i32 0, i32 7
  %t225 = load ptr, ptr %t224
  %t226 = getelementptr inbounds %LSlice, ptr %t225, i32 0, i32 1
  %t227 = load i32, ptr %t226
  %t228 = icmp slt i32 %t222, %t227
  %t229 = zext i1 %t228 to i32
  %t230 = icmp ne i32 %t229, 0
  br i1 %t230, label %then19, label %ifend21
then19:
  %t231 = call ptr @fn_nreg()
  store ptr %t231, ptr %t232
  call void @fn_emit(ptr @.str1227)
  %t233 = load ptr, ptr %t232
  call void @fn_emit(ptr %t233)
  call void @fn_emit(ptr @.str1228)
  %t234 = load ptr, ptr %t2
  call void @fn_emit(ptr %t234)
  call void @fn_emit(ptr @.str1229)
  %t235 = load ptr, ptr %t203
  %t236 = getelementptr inbounds %Cmp_Node, ptr %t235, i32 0, i32 1
  %t237 = load ptr, ptr %t236
  call void @fn_emit(ptr %t237)
  call void @fn_emit(ptr @.str1230)
  %t238 = load ptr, ptr %t203
  %t239 = getelementptr inbounds %Cmp_Node, ptr %t238, i32 0, i32 1
  %t240 = load ptr, ptr %t239
  call void @fn_emit(ptr %t240)
  call void @fn_emit(ptr @.str1231)
  %t241 = load ptr, ptr %t71
  call void @fn_emit(ptr %t241)
  call void @fn_emit(ptr @.str1232)
  %t242 = call ptr @fn_emit_alloca(ptr @.str1233)
  store ptr %t242, ptr %t243
  call void @fn_emit(ptr @.str1234)
  %t244 = load ptr, ptr %t232
  call void @fn_emit(ptr %t244)
  call void @fn_emit(ptr @.str1235)
  %t245 = load ptr, ptr %t243
  call void @fn_emit(ptr %t245)
  call void @fn_emit(ptr @.str1236)
  %t246 = load ptr, ptr %t0
  %t247 = getelementptr inbounds %Cmp_Node, ptr %t246, i32 0, i32 7
  %t248 = load ptr, ptr %t247
  %t249 = getelementptr inbounds %LSlice, ptr %t248, i32 0, i32 0
  %t250 = load ptr, ptr %t249
  %t251 = load i32, ptr %t185
  %t252 = getelementptr inbounds ptr, ptr %t250, i32 %t251
  %t253 = load ptr, ptr %t252
  %t254 = getelementptr inbounds %Cmp_Node, ptr %t253, i32 0, i32 1
  %t255 = load ptr, ptr %t254
  %t256 = load ptr, ptr %t243
  %t257 = load ptr, ptr %t203
  %t258 = getelementptr inbounds %Cmp_Node, ptr %t257, i32 0, i32 1
  %t259 = load ptr, ptr %t258
  call void @fn_loc_push(ptr %t255, ptr %t256, ptr %t259)
  %t260 = load i32, ptr %t185
  %t261 = add i32 %t260, 1
  store i32 %t261, ptr %t185
  br label %ifend21
ifend21:
  br label %ifend18
ifend18:
  %t262 = load i32, ptr %t96
  %t263 = add i32 %t262, 1
  store i32 %t263, ptr %t96
  br label %wcond11
wend13:
  %t264 = load ptr, ptr %t0
  %t265 = getelementptr inbounds %Cmp_Node, ptr %t264, i32 0, i32 5
  %t266 = load ptr, ptr %t265
  %t267 = icmp ne ptr %t266, null
  %t268 = zext i1 %t267 to i32
  %t269 = icmp ne i32 %t268, 0
  br i1 %t269, label %then22, label %ifend24
then22:
  %t270 = load ptr, ptr %t0
  %t271 = getelementptr inbounds %Cmp_Node, ptr %t270, i32 0, i32 5
  %t272 = load ptr, ptr %t271
  %t273 = call ptr @fn_emit_expr(ptr %t272)
  store ptr %t273, ptr %t274
  %t275 = load ptr, ptr %t274
  %t276 = getelementptr inbounds %Cmp_Val, ptr %t275, i32 0, i32 0
  %t277 = load ptr, ptr %t276
  %t278 = call ptr @fn_str_concat(ptr %t277, ptr @.str1238)
  %t279 = call ptr @fn_str_concat(ptr @.str1237, ptr %t278)
  %t280 = call ptr @fn_emit_bind(ptr %t279)
  store ptr %t280, ptr %t281
  %t282 = call ptr @fn_lbl(ptr @.str1239)
  store ptr %t282, ptr %t283
  call void @fn_emit(ptr @.str1240)
  %t284 = load ptr, ptr %t281
  call void @fn_emit(ptr %t284)
  call void @fn_emit(ptr @.str1241)
  %t285 = load ptr, ptr %t283
  call void @fn_emit(ptr %t285)
  call void @fn_emit(ptr @.str1242)
  %t286 = load ptr, ptr %t46
  call void @fn_emit(ptr %t286)
  call void @fn_emit(ptr @.str1243)
  %t287 = load ptr, ptr %t283
  call void @fn_emit(ptr %t287)
  call void @fn_emit(ptr @.str1244)
  br label %ifend24
ifend24:
  %t288 = load ptr, ptr %t46
  %t289 = load ptr, ptr %t48
  call void @fn_loop_push(ptr %t288, ptr %t289)
  %t290 = load ptr, ptr %t0
  %t291 = getelementptr inbounds %Cmp_Node, ptr %t290, i32 0, i32 4
  %t292 = load ptr, ptr %t291
  call void @fn_emit_block(ptr %t292)
  call void @fn_loop_pop()
  %t293 = load i32, ptr %t184
  store i32 %t293, ptr @g_nloc
  %t294 = load i32, ptr @g_g_term
  %t295 = icmp eq i32 %t294, 0
  %t296 = zext i1 %t295 to i32
  %t297 = icmp ne i32 %t296, 0
  br i1 %t297, label %then25, label %ifend27
then25:
  call void @fn_emit(ptr @.str1245)
  %t298 = load ptr, ptr %t46
  call void @fn_emit(ptr %t298)
  call void @fn_emit(ptr @.str1246)
  br label %ifend27
ifend27:
  %t299 = load ptr, ptr %t46
  call void @fn_emit(ptr %t299)
  call void @fn_emit(ptr @.str1247)
  %t300 = load ptr, ptr %t4
  %t301 = call ptr @fn_str_concat(ptr @.str1248, ptr %t300)
  %t302 = call ptr @fn_emit_bind(ptr %t301)
  store ptr %t302, ptr %t303
  %t304 = load ptr, ptr %t303
  %t305 = call ptr @fn_str_concat(ptr %t304, ptr @.str1250)
  %t306 = call ptr @fn_str_concat(ptr @.str1249, ptr %t305)
  %t307 = call ptr @fn_emit_bind(ptr %t306)
  store ptr %t307, ptr %t308
  %t309 = load ptr, ptr %t308
  %t310 = load ptr, ptr %t4
  call void @fn_store_at(ptr @.str1251, ptr %t309, ptr %t310)
  call void @fn_emit(ptr @.str1252)
  %t311 = load ptr, ptr %t42
  call void @fn_emit(ptr %t311)
  call void @fn_emit(ptr @.str1253)
  %t312 = load ptr, ptr %t48
  call void @fn_emit(ptr %t312)
  call void @fn_emit(ptr @.str1254)
  store i32 0, ptr @g_g_term
  %t313 = load i32, ptr @g_nself
  %t314 = sub i32 %t313, 1
  store i32 %t314, ptr @g_nself
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
  %t73 = alloca ptr
  %t86 = alloca i32
  %t104 = alloca ptr
  %t110 = alloca i32
  %t116 = alloca ptr
  %t126 = alloca ptr
  %t141 = alloca ptr
  %t147 = alloca i32
  %t149 = alloca ptr
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
  %t13 = call ptr @fn_str_concat(ptr @.str1255, ptr %t12)
  call void @fn_perr(ptr %t13)
  br label %ifend2
ifend2:
  %t14 = call ptr @fn_nreg()
  store ptr %t14, ptr %t15
  call void @fn_emit(ptr @.str1256)
  %t16 = load ptr, ptr %t15
  call void @fn_emit(ptr %t16)
  call void @fn_emit(ptr @.str1257)
  %t17 = load ptr, ptr %t4
  call void @fn_emit(ptr %t17)
  call void @fn_emit(ptr @.str1258)
  %t18 = load ptr, ptr %t1
  call void @fn_emit(ptr %t18)
  call void @fn_emit(ptr @.str1259)
  %t19 = load ptr, ptr %t0
  call void @fn_emit(ptr %t19)
  call void @fn_emit(ptr @.str1260)
  call void @fn_emit(ptr @.str1261)
  %t20 = load ptr, ptr %t15
  call void @fn_emit(ptr %t20)
  call void @fn_emit(ptr @.str1262)
  %t21 = call ptr @fn_nreg()
  store ptr %t21, ptr %t22
  call void @fn_emit(ptr @.str1263)
  %t23 = load ptr, ptr %t22
  call void @fn_emit(ptr %t23)
  call void @fn_emit(ptr @.str1264)
  %t24 = load ptr, ptr %t4
  call void @fn_emit(ptr %t24)
  call void @fn_emit(ptr @.str1265)
  %t25 = load ptr, ptr %t1
  call void @fn_emit(ptr %t25)
  call void @fn_emit(ptr @.str1266)
  %t26 = load ptr, ptr %t1
  call void @fn_emit(ptr %t26)
  call void @fn_emit(ptr @.str1267)
  %t27 = load ptr, ptr %t0
  call void @fn_emit(ptr %t27)
  call void @fn_emit(ptr @.str1268)
  store i32 0, ptr %t28
  br label %wcond3
wcond3:
  %t29 = load i32, ptr %t28
  %t30 = load ptr, ptr %t7
  %t31 = getelementptr inbounds %Cmp_Node, ptr %t30, i32 0, i32 7
  %t32 = load ptr, ptr %t31
  %t33 = getelementptr inbounds %LSlice, ptr %t32, i32 0, i32 1
  %t34 = load i32, ptr %t33
  %t35 = icmp slt i32 %t29, %t34
  %t36 = zext i1 %t35 to i32
  %t37 = icmp ne i32 %t36, 0
  br i1 %t37, label %wbody4, label %wend5
wbody4:
  %t38 = load ptr, ptr %t7
  %t39 = getelementptr inbounds %Cmp_Node, ptr %t38, i32 0, i32 7
  %t40 = load ptr, ptr %t39
  %t41 = getelementptr inbounds %LSlice, ptr %t40, i32 0, i32 0
  %t42 = load ptr, ptr %t41
  %t43 = load i32, ptr %t28
  %t44 = getelementptr inbounds ptr, ptr %t42, i32 %t43
  %t45 = load ptr, ptr %t44
  store ptr %t45, ptr %t46
  %t47 = call ptr @fn_nreg()
  store ptr %t47, ptr %t48
  call void @fn_emit(ptr @.str1269)
  %t49 = load ptr, ptr %t48
  call void @fn_emit(ptr %t49)
  call void @fn_emit(ptr @.str1270)
  %t50 = load ptr, ptr %t1
  call void @fn_emit(ptr %t50)
  call void @fn_emit(ptr @.str1271)
  %t51 = load ptr, ptr %t22
  call void @fn_emit(ptr %t51)
  call void @fn_emit(ptr @.str1272)
  %t52 = load i32, ptr %t28
  %t53 = call ptr @fn_itoa(i32 %t52)
  call void @fn_emit(ptr %t53)
  call void @fn_emit(ptr @.str1273)
  %t54 = load ptr, ptr %t46
  %t55 = getelementptr inbounds %Cmp_Node, ptr %t54, i32 0, i32 3
  %t56 = load ptr, ptr %t55
  %t57 = call ptr @fn_llty(ptr %t56)
  store ptr %t57, ptr %t58
  store ptr @.str1274, ptr %t59
  %t60 = load ptr, ptr %t58
  %t61 = call i32 @fn_str_eq(ptr %t60, ptr @.str1275)
  %t62 = icmp ne i32 %t61, 0
  br i1 %t62, label %then6, label %ifend8
then6:
  store ptr @.str1276, ptr %t59
  br label %ifend8
ifend8:
  %t63 = load ptr, ptr %t46
  %t64 = getelementptr inbounds %Cmp_Node, ptr %t63, i32 0, i32 4
  %t65 = load ptr, ptr %t64
  %t66 = icmp ne ptr %t65, null
  %t67 = zext i1 %t66 to i32
  %t68 = icmp ne i32 %t67, 0
  br i1 %t68, label %then9, label %ifend11
then9:
  %t69 = load ptr, ptr %t46
  %t70 = getelementptr inbounds %Cmp_Node, ptr %t69, i32 0, i32 4
  %t71 = load ptr, ptr %t70
  %t72 = call ptr @fn_emit_expr(ptr %t71)
  store ptr %t72, ptr %t73
  %t74 = load ptr, ptr %t73
  %t75 = getelementptr inbounds %Cmp_Val, ptr %t74, i32 0, i32 0
  %t76 = load ptr, ptr %t75
  store ptr %t76, ptr %t59
  br label %ifend11
ifend11:
  call void @fn_emit(ptr @.str1277)
  %t77 = load ptr, ptr %t58
  call void @fn_emit(ptr %t77)
  call void @fn_emit(ptr @.str1278)
  %t78 = load ptr, ptr %t59
  call void @fn_emit(ptr %t78)
  call void @fn_emit(ptr @.str1279)
  %t79 = load ptr, ptr %t48
  call void @fn_emit(ptr %t79)
  call void @fn_emit(ptr @.str1280)
  %t80 = load i32, ptr %t28
  %t81 = add i32 %t80, 1
  store i32 %t81, ptr %t28
  br label %wcond3
wend5:
  %t82 = load ptr, ptr %t2
  %t83 = icmp ne ptr %t82, null
  %t84 = zext i1 %t83 to i32
  %t85 = icmp ne i32 %t84, 0
  br i1 %t85, label %then12, label %ifend14
then12:
  store i32 0, ptr %t86
  br label %wcond15
wcond15:
  %t87 = load i32, ptr %t86
  %t88 = load ptr, ptr %t2
  %t89 = getelementptr inbounds %Cmp_Node, ptr %t88, i32 0, i32 7
  %t90 = load ptr, ptr %t89
  %t91 = getelementptr inbounds %LSlice, ptr %t90, i32 0, i32 1
  %t92 = load i32, ptr %t91
  %t93 = icmp slt i32 %t87, %t92
  %t94 = zext i1 %t93 to i32
  %t95 = icmp ne i32 %t94, 0
  br i1 %t95, label %wbody16, label %wend17
wbody16:
  %t96 = load ptr, ptr %t2
  %t97 = getelementptr inbounds %Cmp_Node, ptr %t96, i32 0, i32 7
  %t98 = load ptr, ptr %t97
  %t99 = getelementptr inbounds %LSlice, ptr %t98, i32 0, i32 0
  %t100 = load ptr, ptr %t99
  %t101 = load i32, ptr %t86
  %t102 = getelementptr inbounds ptr, ptr %t100, i32 %t101
  %t103 = load ptr, ptr %t102
  store ptr %t103, ptr %t104
  %t105 = load ptr, ptr %t7
  %t106 = load ptr, ptr %t104
  %t107 = getelementptr inbounds %Cmp_Node, ptr %t106, i32 0, i32 1
  %t108 = load ptr, ptr %t107
  %t109 = call i32 @fn_field_index(ptr %t105, ptr %t108)
  store i32 %t109, ptr %t110
  %t111 = load i32, ptr %t110
  %t112 = icmp sge i32 %t111, 0
  %t113 = zext i1 %t112 to i32
  %t114 = icmp ne i32 %t113, 0
  br i1 %t114, label %then18, label %ifend20
then18:
  %t115 = call ptr @fn_nreg()
  store ptr %t115, ptr %t116
  call void @fn_emit(ptr @.str1281)
  %t117 = load ptr, ptr %t116
  call void @fn_emit(ptr %t117)
  call void @fn_emit(ptr @.str1282)
  %t118 = load ptr, ptr %t1
  call void @fn_emit(ptr %t118)
  call void @fn_emit(ptr @.str1283)
  %t119 = load ptr, ptr %t22
  call void @fn_emit(ptr %t119)
  call void @fn_emit(ptr @.str1284)
  %t120 = load i32, ptr %t110
  %t121 = call ptr @fn_itoa(i32 %t120)
  call void @fn_emit(ptr %t121)
  call void @fn_emit(ptr @.str1285)
  %t122 = load ptr, ptr %t104
  %t123 = getelementptr inbounds %Cmp_Node, ptr %t122, i32 0, i32 4
  %t124 = load ptr, ptr %t123
  %t125 = call ptr @fn_emit_expr(ptr %t124)
  store ptr %t125, ptr %t126
  call void @fn_emit(ptr @.str1286)
  %t127 = load ptr, ptr %t7
  %t128 = load ptr, ptr %t104
  %t129 = getelementptr inbounds %Cmp_Node, ptr %t128, i32 0, i32 1
  %t130 = load ptr, ptr %t129
  %t131 = call ptr @fn_field_type(ptr %t127, ptr %t130)
  %t132 = call ptr @fn_llty(ptr %t131)
  call void @fn_emit(ptr %t132)
  call void @fn_emit(ptr @.str1287)
  %t133 = load ptr, ptr %t126
  %t134 = getelementptr inbounds %Cmp_Val, ptr %t133, i32 0, i32 0
  %t135 = load ptr, ptr %t134
  call void @fn_emit(ptr %t135)
  call void @fn_emit(ptr @.str1288)
  %t136 = load ptr, ptr %t116
  call void @fn_emit(ptr %t136)
  call void @fn_emit(ptr @.str1289)
  br label %ifend20
ifend20:
  %t137 = load i32, ptr %t86
  %t138 = add i32 %t137, 1
  store i32 %t138, ptr %t86
  br label %wcond15
wend17:
  br label %ifend14
ifend14:
  %t139 = load ptr, ptr %t1
  %t140 = call ptr @fn_onattach_body(ptr %t139)
  store ptr %t140, ptr %t141
  %t142 = load ptr, ptr %t141
  %t143 = icmp ne ptr %t142, null
  %t144 = zext i1 %t143 to i32
  %t145 = icmp ne i32 %t144, 0
  br i1 %t145, label %then21, label %ifend23
then21:
  %t146 = load i32, ptr @g_nloc
  store i32 %t146, ptr %t147
  %t148 = call ptr @fn_emit_alloca(ptr @.str1290)
  store ptr %t148, ptr %t149
  call void @fn_emit(ptr @.str1291)
  %t150 = load ptr, ptr %t22
  call void @fn_emit(ptr %t150)
  call void @fn_emit(ptr @.str1292)
  %t151 = load ptr, ptr %t149
  call void @fn_emit(ptr %t151)
  call void @fn_emit(ptr @.str1293)
  %t152 = load ptr, ptr %t1
  %t153 = load ptr, ptr %t149
  %t154 = load ptr, ptr %t1
  call void @fn_loc_push(ptr %t152, ptr %t153, ptr %t154)
  %t155 = load ptr, ptr %t141
  call void @fn_emit_block(ptr %t155)
  %t156 = load i32, ptr %t147
  store i32 %t156, ptr @g_nloc
  br label %ifend23
ifend23:
  br label %ret
ret:
  ret void
}

define void @fn_emit_bind_props(ptr %arg_model, ptr %arg_e) {
entry:
  %t0 = alloca ptr
  %t1 = alloca ptr
  %t3 = alloca ptr
  %t4 = alloca i32
  %t24 = alloca ptr
  %t26 = alloca ptr
  %t33 = alloca ptr
  store ptr %arg_model, ptr %t0
  store ptr %arg_e, ptr %t1
  %t2 = call ptr @fn_itoa(i32 1024)
  store ptr %t2, ptr %t3
  store i32 0, ptr %t4
  br label %wcond0
wcond0:
  %t5 = load i32, ptr %t4
  %t6 = load ptr, ptr %t0
  %t7 = getelementptr inbounds %Cmp_Node, ptr %t6, i32 0, i32 7
  %t8 = load ptr, ptr %t7
  %t9 = getelementptr inbounds %LSlice, ptr %t8, i32 0, i32 1
  %t10 = load i32, ptr %t9
  %t11 = icmp slt i32 %t5, %t10
  %t12 = zext i1 %t11 to i32
  %t13 = icmp ne i32 %t12, 0
  br i1 %t13, label %wbody1, label %wend2
wbody1:
  %t14 = load ptr, ptr %t0
  %t15 = getelementptr inbounds %Cmp_Node, ptr %t14, i32 0, i32 7
  %t16 = load ptr, ptr %t15
  %t17 = getelementptr inbounds %LSlice, ptr %t16, i32 0, i32 0
  %t18 = load ptr, ptr %t17
  %t19 = load i32, ptr %t4
  %t20 = getelementptr inbounds ptr, ptr %t18, i32 %t19
  %t21 = load ptr, ptr %t20
  %t22 = getelementptr inbounds %Cmp_Node, ptr %t21, i32 0, i32 1
  %t23 = load ptr, ptr %t22
  store ptr %t23, ptr %t24
  %t25 = call ptr @fn_nreg()
  store ptr %t25, ptr %t26
  call void @fn_emit(ptr @.str1294)
  %t27 = load ptr, ptr %t26
  call void @fn_emit(ptr %t27)
  call void @fn_emit(ptr @.str1295)
  %t28 = load ptr, ptr %t3
  call void @fn_emit(ptr %t28)
  call void @fn_emit(ptr @.str1296)
  %t29 = load ptr, ptr %t24
  call void @fn_emit(ptr %t29)
  call void @fn_emit(ptr @.str1297)
  %t30 = load ptr, ptr %t24
  call void @fn_emit(ptr %t30)
  call void @fn_emit(ptr @.str1298)
  %t31 = load ptr, ptr %t1
  call void @fn_emit(ptr %t31)
  call void @fn_emit(ptr @.str1299)
  %t32 = call ptr @fn_emit_alloca(ptr @.str1300)
  store ptr %t32, ptr %t33
  call void @fn_emit(ptr @.str1301)
  %t34 = load ptr, ptr %t26
  call void @fn_emit(ptr %t34)
  call void @fn_emit(ptr @.str1302)
  %t35 = load ptr, ptr %t33
  call void @fn_emit(ptr %t35)
  call void @fn_emit(ptr @.str1303)
  %t36 = load ptr, ptr %t24
  %t37 = load ptr, ptr %t33
  %t38 = load ptr, ptr %t24
  call void @fn_loc_push(ptr %t36, ptr %t37, ptr %t38)
  %t39 = load i32, ptr %t4
  %t40 = add i32 %t39, 1
  store i32 %t40, ptr %t4
  br label %wcond0
wend2:
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
  %t93 = alloca ptr
  %t99 = alloca i32
  %t104 = alloca i32
  store ptr %arg_st, ptr %t0
  %t1 = call ptr @fn_emit_bind(ptr @.str1304)
  store ptr %t1, ptr %t2
  %t3 = load ptr, ptr %t0
  %t4 = getelementptr inbounds %Cmp_Node, ptr %t3, i32 0, i32 1
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
  call void @fn_emit(ptr @.str1305)
  %t16 = load ptr, ptr %t15
  call void @fn_emit(ptr %t16)
  call void @fn_emit(ptr @.str1306)
  %t17 = load ptr, ptr %t13
  call void @fn_emit(ptr %t17)
  call void @fn_emit(ptr @.str1307)
  %t18 = load ptr, ptr %t2
  call void @fn_emit(ptr %t18)
  call void @fn_emit(ptr @.str1308)
  call void @fn_emit(ptr @.str1309)
  %t19 = load i32, ptr %t7
  %t20 = call ptr @fn_itoa(i32 %t19)
  call void @fn_emit(ptr %t20)
  call void @fn_emit(ptr @.str1310)
  %t21 = load ptr, ptr %t15
  call void @fn_emit(ptr %t21)
  call void @fn_emit(ptr @.str1311)
  %t22 = load ptr, ptr %t0
  %t23 = getelementptr inbounds %Cmp_Node, ptr %t22, i32 0, i32 1
  %t24 = load ptr, ptr %t23
  %t25 = call ptr @fn_find_arch(ptr %t24)
  store ptr %t25, ptr %t26
  store i32 0, ptr %t27
  br label %wcond3
wcond3:
  %t28 = load i32, ptr %t27
  %t29 = load ptr, ptr %t26
  %t30 = getelementptr inbounds %Cmp_Node, ptr %t29, i32 0, i32 7
  %t31 = load ptr, ptr %t30
  %t32 = getelementptr inbounds %LSlice, ptr %t31, i32 0, i32 1
  %t33 = load i32, ptr %t32
  %t34 = icmp slt i32 %t28, %t33
  %t35 = zext i1 %t34 to i32
  %t36 = icmp ne i32 %t35, 0
  br i1 %t36, label %wbody4, label %wend5
wbody4:
  %t37 = load ptr, ptr %t26
  %t38 = getelementptr inbounds %Cmp_Node, ptr %t37, i32 0, i32 7
  %t39 = load ptr, ptr %t38
  %t40 = getelementptr inbounds %LSlice, ptr %t39, i32 0, i32 0
  %t41 = load ptr, ptr %t40
  %t42 = load i32, ptr %t27
  %t43 = getelementptr inbounds ptr, ptr %t41, i32 %t42
  %t44 = load ptr, ptr %t43
  %t45 = getelementptr inbounds %Cmp_Node, ptr %t44, i32 0, i32 1
  %t46 = load ptr, ptr %t45
  store ptr %t46, ptr %t47
  store ptr null, ptr %t48
  store i32 0, ptr %t49
  br label %wcond6
wcond6:
  %t50 = load i32, ptr %t49
  %t51 = load ptr, ptr %t0
  %t52 = getelementptr inbounds %Cmp_Node, ptr %t51, i32 0, i32 7
  %t53 = load ptr, ptr %t52
  %t54 = getelementptr inbounds %LSlice, ptr %t53, i32 0, i32 1
  %t55 = load i32, ptr %t54
  %t56 = icmp slt i32 %t50, %t55
  %t57 = zext i1 %t56 to i32
  %t58 = icmp ne i32 %t57, 0
  br i1 %t58, label %wbody7, label %wend8
wbody7:
  %t59 = load ptr, ptr %t0
  %t60 = getelementptr inbounds %Cmp_Node, ptr %t59, i32 0, i32 7
  %t61 = load ptr, ptr %t60
  %t62 = getelementptr inbounds %LSlice, ptr %t61, i32 0, i32 0
  %t63 = load ptr, ptr %t62
  %t64 = load i32, ptr %t49
  %t65 = getelementptr inbounds ptr, ptr %t63, i32 %t64
  %t66 = load ptr, ptr %t65
  %t67 = getelementptr inbounds %Cmp_Node, ptr %t66, i32 0, i32 1
  %t68 = load ptr, ptr %t67
  %t69 = load ptr, ptr %t47
  %t70 = call i32 @fn_str_eq(ptr %t68, ptr %t69)
  %t71 = icmp ne i32 %t70, 0
  br i1 %t71, label %then9, label %ifend11
then9:
  %t72 = load ptr, ptr %t0
  %t73 = getelementptr inbounds %Cmp_Node, ptr %t72, i32 0, i32 7
  %t74 = load ptr, ptr %t73
  %t75 = getelementptr inbounds %LSlice, ptr %t74, i32 0, i32 0
  %t76 = load ptr, ptr %t75
  %t77 = load i32, ptr %t49
  %t78 = getelementptr inbounds ptr, ptr %t76, i32 %t77
  %t79 = load ptr, ptr %t78
  %t80 = getelementptr inbounds %Cmp_Node, ptr %t79, i32 0, i32 4
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
  %t89 = load ptr, ptr %t0
  %t90 = getelementptr inbounds %Cmp_Node, ptr %t89, i32 0, i32 1
  %t91 = load ptr, ptr %t90
  %t92 = call ptr @fn_onspawn_body(ptr %t91)
  store ptr %t92, ptr %t93
  %t94 = load ptr, ptr %t93
  %t95 = icmp ne ptr %t94, null
  %t96 = zext i1 %t95 to i32
  %t97 = icmp ne i32 %t96, 0
  br i1 %t97, label %then12, label %ifend14
then12:
  %t98 = load i32, ptr @g_nloc
  store i32 %t98, ptr %t99
  %t100 = load ptr, ptr %t26
  %t101 = load ptr, ptr %t2
  call void @fn_emit_bind_props(ptr %t100, ptr %t101)
  %t102 = load ptr, ptr %t93
  call void @fn_emit_block(ptr %t102)
  %t103 = load i32, ptr %t99
  store i32 %t103, ptr @g_nloc
  br label %ifend14
ifend14:
  br label %ifend2
else1:
  store i32 0, ptr %t104
  br label %wcond15
wcond15:
  %t105 = load i32, ptr %t104
  %t106 = load ptr, ptr %t0
  %t107 = getelementptr inbounds %Cmp_Node, ptr %t106, i32 0, i32 7
  %t108 = load ptr, ptr %t107
  %t109 = getelementptr inbounds %LSlice, ptr %t108, i32 0, i32 1
  %t110 = load i32, ptr %t109
  %t111 = icmp slt i32 %t105, %t110
  %t112 = zext i1 %t111 to i32
  %t113 = icmp ne i32 %t112, 0
  br i1 %t113, label %wbody16, label %wend17
wbody16:
  %t114 = load ptr, ptr %t2
  %t115 = load ptr, ptr %t0
  %t116 = getelementptr inbounds %Cmp_Node, ptr %t115, i32 0, i32 7
  %t117 = load ptr, ptr %t116
  %t118 = getelementptr inbounds %LSlice, ptr %t117, i32 0, i32 0
  %t119 = load ptr, ptr %t118
  %t120 = load i32, ptr %t104
  %t121 = getelementptr inbounds ptr, ptr %t119, i32 %t120
  %t122 = load ptr, ptr %t121
  %t123 = getelementptr inbounds %Cmp_Node, ptr %t122, i32 0, i32 1
  %t124 = load ptr, ptr %t123
  %t125 = load ptr, ptr %t0
  %t126 = getelementptr inbounds %Cmp_Node, ptr %t125, i32 0, i32 7
  %t127 = load ptr, ptr %t126
  %t128 = getelementptr inbounds %LSlice, ptr %t127, i32 0, i32 0
  %t129 = load ptr, ptr %t128
  %t130 = load i32, ptr %t104
  %t131 = getelementptr inbounds ptr, ptr %t129, i32 %t130
  %t132 = load ptr, ptr %t131
  %t133 = getelementptr inbounds %Cmp_Node, ptr %t132, i32 0, i32 4
  %t134 = load ptr, ptr %t133
  call void @fn_emit_init_component(ptr %t114, ptr %t124, ptr %t134)
  %t135 = load i32, ptr %t104
  %t136 = add i32 %t135, 1
  store i32 %t136, ptr %t104
  br label %wcond15
wend17:
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
  %t13 = alloca ptr
  %t15 = alloca ptr
  %t24 = alloca ptr
  %t25 = alloca i32
  %t41 = alloca ptr
  %t50 = alloca ptr
  %t52 = alloca ptr
  %t54 = alloca ptr
  store ptr %arg_st, ptr %t0
  %t1 = load ptr, ptr %t0
  %t2 = getelementptr inbounds %Cmp_Node, ptr %t1, i32 0, i32 4
  %t3 = load ptr, ptr %t2
  %t4 = call ptr @fn_emit_expr(ptr %t3)
  store ptr %t4, ptr %t5
  %t6 = load ptr, ptr @g_g_ondespawn
  %t7 = getelementptr inbounds %LSlice, ptr %t6, i32 0, i32 1
  %t8 = load i32, ptr %t7
  %t9 = icmp sgt i32 %t8, 0
  %t10 = zext i1 %t9 to i32
  %t11 = icmp ne i32 %t10, 0
  br i1 %t11, label %then0, label %ifend2
then0:
  %t12 = call ptr @fn_itoa(i32 1024)
  store ptr %t12, ptr %t13
  %t14 = call ptr @fn_nreg()
  store ptr %t14, ptr %t15
  call void @fn_emit(ptr @.str1312)
  %t16 = load ptr, ptr %t15
  call void @fn_emit(ptr %t16)
  call void @fn_emit(ptr @.str1313)
  %t17 = load ptr, ptr %t13
  call void @fn_emit(ptr %t17)
  call void @fn_emit(ptr @.str1314)
  %t18 = load ptr, ptr %t5
  %t19 = getelementptr inbounds %Cmp_Val, ptr %t18, i32 0, i32 0
  %t20 = load ptr, ptr %t19
  call void @fn_emit(ptr %t20)
  call void @fn_emit(ptr @.str1315)
  %t21 = load ptr, ptr %t15
  %t22 = call ptr @fn_str_concat(ptr @.str1316, ptr %t21)
  %t23 = call ptr @fn_emit_bind(ptr %t22)
  store ptr %t23, ptr %t24
  store i32 0, ptr %t25
  br label %wcond3
wcond3:
  %t26 = load i32, ptr %t25
  %t27 = load ptr, ptr @g_g_ondespawn
  %t28 = getelementptr inbounds %LSlice, ptr %t27, i32 0, i32 1
  %t29 = load i32, ptr %t28
  %t30 = icmp slt i32 %t26, %t29
  %t31 = zext i1 %t30 to i32
  %t32 = icmp ne i32 %t31, 0
  br i1 %t32, label %wbody4, label %wend5
wbody4:
  %t33 = load ptr, ptr @g_g_ondespawn
  %t34 = getelementptr inbounds %LSlice, ptr %t33, i32 0, i32 0
  %t35 = load ptr, ptr %t34
  %t36 = load i32, ptr %t25
  %t37 = getelementptr inbounds ptr, ptr %t35, i32 %t36
  %t38 = load ptr, ptr %t37
  %t39 = getelementptr inbounds %Cmp_Node, ptr %t38, i32 0, i32 1
  %t40 = load ptr, ptr %t39
  store ptr %t40, ptr %t41
  %t42 = load ptr, ptr %t24
  %t43 = load ptr, ptr %t41
  %t44 = call i32 @fn_find_arch_id(ptr %t43)
  %t45 = call ptr @fn_itoa(i32 %t44)
  %t46 = call ptr @fn_str_concat(ptr @.str1318, ptr %t45)
  %t47 = call ptr @fn_str_concat(ptr %t42, ptr %t46)
  %t48 = call ptr @fn_str_concat(ptr @.str1317, ptr %t47)
  %t49 = call ptr @fn_emit_bind(ptr %t48)
  store ptr %t49, ptr %t50
  %t51 = call ptr @fn_lbl(ptr @.str1319)
  store ptr %t51, ptr %t52
  %t53 = call ptr @fn_lbl(ptr @.str1320)
  store ptr %t53, ptr %t54
  call void @fn_emit(ptr @.str1321)
  %t55 = load ptr, ptr %t50
  call void @fn_emit(ptr %t55)
  call void @fn_emit(ptr @.str1322)
  %t56 = load ptr, ptr %t52
  call void @fn_emit(ptr %t56)
  call void @fn_emit(ptr @.str1323)
  %t57 = load ptr, ptr %t54
  call void @fn_emit(ptr %t57)
  call void @fn_emit(ptr @.str1324)
  %t58 = load ptr, ptr %t52
  call void @fn_emit(ptr %t58)
  call void @fn_emit(ptr @.str1325)
  %t59 = load ptr, ptr %t41
  call void @fn_emit(ptr %t59)
  call void @fn_emit(ptr @.str1326)
  %t60 = load ptr, ptr %t5
  %t61 = getelementptr inbounds %Cmp_Val, ptr %t60, i32 0, i32 0
  %t62 = load ptr, ptr %t61
  call void @fn_emit(ptr %t62)
  call void @fn_emit(ptr @.str1327)
  call void @fn_emit(ptr @.str1328)
  %t63 = load ptr, ptr %t54
  call void @fn_emit(ptr %t63)
  call void @fn_emit(ptr @.str1329)
  %t64 = load ptr, ptr %t54
  call void @fn_emit(ptr %t64)
  call void @fn_emit(ptr @.str1330)
  %t65 = load i32, ptr %t25
  %t66 = add i32 %t65, 1
  store i32 %t66, ptr %t25
  br label %wcond3
wend5:
  br label %ifend2
ifend2:
  call void @fn_emit(ptr @.str1331)
  %t67 = load ptr, ptr %t5
  %t68 = getelementptr inbounds %Cmp_Val, ptr %t67, i32 0, i32 0
  %t69 = load ptr, ptr %t68
  call void @fn_emit(ptr %t69)
  call void @fn_emit(ptr @.str1332)
  br label %ret
ret:
  ret void
}

define void @fn_emit_toggle(ptr %arg_st) {
entry:
  %t0 = alloca ptr
  %t1 = alloca ptr
  %t18 = alloca ptr
  %t20 = alloca ptr
  %t22 = alloca ptr
  %t33 = alloca ptr
  %t53 = alloca i32
  %t55 = alloca ptr
  %t68 = alloca ptr
  %t80 = alloca ptr
  store ptr %arg_st, ptr %t0
  store ptr @.str1333, ptr %t1
  %t2 = load ptr, ptr %t0
  %t3 = getelementptr inbounds %Cmp_Node, ptr %t2, i32 0, i32 2
  %t4 = load i32, ptr %t3
  %t5 = icmp eq i32 %t4, 1
  %t6 = zext i1 %t5 to i32
  %t7 = icmp ne i32 %t6, 0
  br i1 %t7, label %then0, label %ifend2
then0:
  store ptr @.str1334, ptr %t1
  br label %ifend2
ifend2:
  %t8 = load ptr, ptr %t0
  %t9 = getelementptr inbounds %Cmp_Node, ptr %t8, i32 0, i32 4
  %t10 = load ptr, ptr %t9
  %t11 = icmp ne ptr %t10, null
  %t12 = zext i1 %t11 to i32
  %t13 = icmp ne i32 %t12, 0
  br i1 %t13, label %then3, label %else4
then3:
  %t14 = load ptr, ptr %t0
  %t15 = getelementptr inbounds %Cmp_Node, ptr %t14, i32 0, i32 4
  %t16 = load ptr, ptr %t15
  %t17 = call ptr @fn_emit_expr(ptr %t16)
  store ptr %t17, ptr %t18
  %t19 = call ptr @fn_itoa(i32 1024)
  store ptr %t19, ptr %t20
  %t21 = call ptr @fn_nreg()
  store ptr %t21, ptr %t22
  call void @fn_emit(ptr @.str1335)
  %t23 = load ptr, ptr %t22
  call void @fn_emit(ptr %t23)
  call void @fn_emit(ptr @.str1336)
  %t24 = load ptr, ptr %t20
  call void @fn_emit(ptr %t24)
  call void @fn_emit(ptr @.str1337)
  %t25 = load ptr, ptr %t0
  %t26 = getelementptr inbounds %Cmp_Node, ptr %t25, i32 0, i32 1
  %t27 = load ptr, ptr %t26
  call void @fn_emit(ptr %t27)
  call void @fn_emit(ptr @.str1338)
  %t28 = load ptr, ptr %t18
  %t29 = getelementptr inbounds %Cmp_Val, ptr %t28, i32 0, i32 0
  %t30 = load ptr, ptr %t29
  call void @fn_emit(ptr %t30)
  call void @fn_emit(ptr @.str1339)
  call void @fn_emit(ptr @.str1340)
  %t31 = load ptr, ptr %t1
  call void @fn_emit(ptr %t31)
  call void @fn_emit(ptr @.str1341)
  %t32 = load ptr, ptr %t22
  call void @fn_emit(ptr %t32)
  call void @fn_emit(ptr @.str1342)
  store ptr null, ptr %t33
  %t34 = load ptr, ptr %t0
  %t35 = getelementptr inbounds %Cmp_Node, ptr %t34, i32 0, i32 2
  %t36 = load i32, ptr %t35
  %t37 = icmp eq i32 %t36, 1
  %t38 = zext i1 %t37 to i32
  %t39 = icmp ne i32 %t38, 0
  br i1 %t39, label %then6, label %else7
then6:
  %t40 = load ptr, ptr %t0
  %t41 = getelementptr inbounds %Cmp_Node, ptr %t40, i32 0, i32 1
  %t42 = load ptr, ptr %t41
  %t43 = call ptr @fn_onenable_body(ptr %t42)
  store ptr %t43, ptr %t33
  br label %ifend8
else7:
  %t44 = load ptr, ptr %t0
  %t45 = getelementptr inbounds %Cmp_Node, ptr %t44, i32 0, i32 1
  %t46 = load ptr, ptr %t45
  %t47 = call ptr @fn_ondisable_body(ptr %t46)
  store ptr %t47, ptr %t33
  br label %ifend8
ifend8:
  %t48 = load ptr, ptr %t33
  %t49 = icmp ne ptr %t48, null
  %t50 = zext i1 %t49 to i32
  %t51 = icmp ne i32 %t50, 0
  br i1 %t51, label %then9, label %ifend11
then9:
  %t52 = load i32, ptr @g_nloc
  store i32 %t52, ptr %t53
  %t54 = call ptr @fn_nreg()
  store ptr %t54, ptr %t55
  call void @fn_emit(ptr @.str1343)
  %t56 = load ptr, ptr %t55
  call void @fn_emit(ptr %t56)
  call void @fn_emit(ptr @.str1344)
  %t57 = load ptr, ptr %t20
  call void @fn_emit(ptr %t57)
  call void @fn_emit(ptr @.str1345)
  %t58 = load ptr, ptr %t0
  %t59 = getelementptr inbounds %Cmp_Node, ptr %t58, i32 0, i32 1
  %t60 = load ptr, ptr %t59
  call void @fn_emit(ptr %t60)
  call void @fn_emit(ptr @.str1346)
  %t61 = load ptr, ptr %t0
  %t62 = getelementptr inbounds %Cmp_Node, ptr %t61, i32 0, i32 1
  %t63 = load ptr, ptr %t62
  call void @fn_emit(ptr %t63)
  call void @fn_emit(ptr @.str1347)
  %t64 = load ptr, ptr %t18
  %t65 = getelementptr inbounds %Cmp_Val, ptr %t64, i32 0, i32 0
  %t66 = load ptr, ptr %t65
  call void @fn_emit(ptr %t66)
  call void @fn_emit(ptr @.str1348)
  %t67 = call ptr @fn_emit_alloca(ptr @.str1349)
  store ptr %t67, ptr %t68
  call void @fn_emit(ptr @.str1350)
  %t69 = load ptr, ptr %t55
  call void @fn_emit(ptr %t69)
  call void @fn_emit(ptr @.str1351)
  %t70 = load ptr, ptr %t68
  call void @fn_emit(ptr %t70)
  call void @fn_emit(ptr @.str1352)
  %t71 = load ptr, ptr %t0
  %t72 = getelementptr inbounds %Cmp_Node, ptr %t71, i32 0, i32 1
  %t73 = load ptr, ptr %t72
  %t74 = load ptr, ptr %t68
  %t75 = load ptr, ptr %t0
  %t76 = getelementptr inbounds %Cmp_Node, ptr %t75, i32 0, i32 1
  %t77 = load ptr, ptr %t76
  call void @fn_loc_push(ptr %t73, ptr %t74, ptr %t77)
  %t78 = load ptr, ptr %t33
  call void @fn_emit_block(ptr %t78)
  %t79 = load i32, ptr %t53
  store i32 %t79, ptr @g_nloc
  br label %ifend11
ifend11:
  br label %ifend5
else4:
  store ptr @.str1353, ptr %t80
  %t81 = load ptr, ptr %t0
  %t82 = getelementptr inbounds %Cmp_Node, ptr %t81, i32 0, i32 1
  %t83 = load ptr, ptr %t82
  %t84 = call i32 @fn_is_model(ptr %t83)
  %t85 = icmp ne i32 %t84, 0
  br i1 %t85, label %then12, label %ifend14
then12:
  store ptr @.str1354, ptr %t80
  br label %ifend14
ifend14:
  call void @fn_emit(ptr @.str1355)
  %t86 = load ptr, ptr %t1
  call void @fn_emit(ptr %t86)
  call void @fn_emit(ptr @.str1356)
  %t87 = load ptr, ptr %t80
  call void @fn_emit(ptr %t87)
  %t88 = load ptr, ptr %t0
  %t89 = getelementptr inbounds %Cmp_Node, ptr %t88, i32 0, i32 1
  %t90 = load ptr, ptr %t89
  call void @fn_emit(ptr %t90)
  call void @fn_emit(ptr @.str1357)
  br label %ifend5
ifend5:
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
  store ptr @.str1358, ptr @g_ret_ty
  %t1 = call ptr @fn_buf_new()
  store ptr %t1, ptr %t2
  %t3 = call ptr @fn_buf_new()
  store ptr %t3, ptr @g_falloc
  %t4 = load ptr, ptr @g_code
  store ptr %t4, ptr %t5
  %t6 = load ptr, ptr %t2
  store ptr %t6, ptr @g_code
  %t7 = load ptr, ptr %t0
  %t8 = getelementptr inbounds %Cmp_Node, ptr %t7, i32 0, i32 4
  %t9 = load ptr, ptr %t8
  call void @fn_emit_block(ptr %t9)
  %t10 = load i32, ptr @g_g_term
  %t11 = icmp eq i32 %t10, 0
  %t12 = zext i1 %t11 to i32
  %t13 = icmp ne i32 %t12, 0
  br i1 %t13, label %then0, label %ifend2
then0:
  call void @fn_emit(ptr @.str1359)
  br label %ifend2
ifend2:
  call void @fn_emit(ptr @.str1360)
  %t14 = load ptr, ptr %t5
  store ptr %t14, ptr @g_code
  call void @fn_emit(ptr @.str1361)
  %t15 = load ptr, ptr %t0
  %t16 = getelementptr inbounds %Cmp_Node, ptr %t15, i32 0, i32 1
  %t17 = load ptr, ptr %t16
  call void @fn_emit(ptr %t17)
  call void @fn_emit(ptr @.str1362)
  %t18 = load ptr, ptr @g_falloc
  %t19 = call ptr @fn_buf_str(ptr %t18)
  call void @fn_emit(ptr %t19)
  %t20 = load ptr, ptr %t2
  %t21 = call ptr @fn_buf_str(ptr %t20)
  call void @fn_emit(ptr %t21)
  call void @fn_emit(ptr @.str1363)
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
  %t38 = alloca ptr
  %t43 = alloca ptr
  %t45 = alloca ptr
  %t47 = alloca ptr
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
  %t18 = getelementptr inbounds %Cmp_Node, ptr %t17, i32 0, i32 0
  %t19 = load i32, ptr %t18
  %t20 = icmp eq i32 %t19, 9
  %t21 = zext i1 %t20 to i32
  %t22 = icmp ne i32 %t21, 0
  %t23 = zext i1 %t22 to i32
  store i32 %t23, ptr %t16
  br i1 %t22, label %sc3, label %scend4
sc3:
  %t24 = load ptr, ptr %t15
  %t25 = getelementptr inbounds %Cmp_Node, ptr %t24, i32 0, i32 3
  %t26 = load ptr, ptr %t25
  %t27 = load ptr, ptr %t0
  %t28 = call i32 @fn_str_eq(ptr %t26, ptr %t27)
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
  %t34 = getelementptr inbounds %Cmp_Node, ptr %t33, i32 0, i32 1
  %t35 = load ptr, ptr %t34
  %t36 = call ptr @fn_str_concat(ptr @.str1364, ptr %t35)
  %t37 = call ptr @fn_emit_bind(ptr %t36)
  store ptr %t37, ptr %t38
  %t39 = load ptr, ptr %t38
  %t40 = call ptr @fn_str_concat(ptr %t39, ptr @.str1366)
  %t41 = call ptr @fn_str_concat(ptr @.str1365, ptr %t40)
  %t42 = call ptr @fn_emit_bind(ptr %t41)
  store ptr %t42, ptr %t43
  %t44 = call ptr @fn_lbl(ptr @.str1367)
  store ptr %t44, ptr %t45
  %t46 = call ptr @fn_lbl(ptr @.str1368)
  store ptr %t46, ptr %t47
  call void @fn_emit(ptr @.str1369)
  %t48 = load ptr, ptr %t43
  call void @fn_emit(ptr %t48)
  call void @fn_emit(ptr @.str1370)
  %t49 = load ptr, ptr %t45
  call void @fn_emit(ptr %t49)
  call void @fn_emit(ptr @.str1371)
  %t50 = load ptr, ptr %t47
  call void @fn_emit(ptr %t50)
  call void @fn_emit(ptr @.str1372)
  %t51 = load ptr, ptr %t45
  call void @fn_emit(ptr %t51)
  call void @fn_emit(ptr @.str1373)
  %t52 = load ptr, ptr %t15
  %t53 = getelementptr inbounds %Cmp_Node, ptr %t52, i32 0, i32 1
  %t54 = load ptr, ptr %t53
  call void @fn_emit(ptr %t54)
  call void @fn_emit(ptr @.str1374)
  call void @fn_emit(ptr @.str1375)
  %t55 = load ptr, ptr %t47
  call void @fn_emit(ptr %t55)
  call void @fn_emit(ptr @.str1376)
  %t56 = load ptr, ptr %t47
  call void @fn_emit(ptr %t56)
  call void @fn_emit(ptr @.str1377)
  br label %ifend7
ifend7:
  %t57 = load i32, ptr %t1
  %t58 = add i32 %t57, 1
  store i32 %t58, ptr %t1
  br label %wcond0
wend2:
  br label %ret
ret:
  ret void
}

define void @fn_emit_despawn_hooks() {
entry:
  %t0 = alloca i32
  %t14 = alloca ptr
  %t19 = alloca ptr
  %t21 = alloca ptr
  %t24 = alloca ptr
  store i32 0, ptr %t0
  br label %wcond0
wcond0:
  %t1 = load i32, ptr %t0
  %t2 = load ptr, ptr @g_g_ondespawn
  %t3 = getelementptr inbounds %LSlice, ptr %t2, i32 0, i32 1
  %t4 = load i32, ptr %t3
  %t5 = icmp slt i32 %t1, %t4
  %t6 = zext i1 %t5 to i32
  %t7 = icmp ne i32 %t6, 0
  br i1 %t7, label %wbody1, label %wend2
wbody1:
  %t8 = load ptr, ptr @g_g_ondespawn
  %t9 = getelementptr inbounds %LSlice, ptr %t8, i32 0, i32 0
  %t10 = load ptr, ptr %t9
  %t11 = load i32, ptr %t0
  %t12 = getelementptr inbounds ptr, ptr %t10, i32 %t11
  %t13 = load ptr, ptr %t12
  store ptr %t13, ptr %t14
  %t15 = load ptr, ptr %t14
  %t16 = getelementptr inbounds %Cmp_Node, ptr %t15, i32 0, i32 1
  %t17 = load ptr, ptr %t16
  %t18 = call ptr @fn_find_arch(ptr %t17)
  store ptr %t18, ptr %t19
  store i32 0, ptr @g_ll_t
  store i32 0, ptr @g_ll_lbl
  store i32 0, ptr @g_g_term
  call void @fn_loc_reset()
  store i32 0, ptr @g_nloop
  store i32 0, ptr @g_nself
  store ptr @.str1378, ptr @g_ret_ty
  %t20 = call ptr @fn_buf_new()
  store ptr %t20, ptr %t21
  %t22 = call ptr @fn_buf_new()
  store ptr %t22, ptr @g_falloc
  %t23 = load ptr, ptr @g_code
  store ptr %t23, ptr %t24
  %t25 = load ptr, ptr %t21
  store ptr %t25, ptr @g_code
  %t26 = load ptr, ptr %t19
  call void @fn_emit_bind_props(ptr %t26, ptr @.str1379)
  %t27 = load ptr, ptr %t14
  %t28 = getelementptr inbounds %Cmp_Node, ptr %t27, i32 0, i32 4
  %t29 = load ptr, ptr %t28
  call void @fn_emit_block(ptr %t29)
  %t30 = load i32, ptr @g_g_term
  %t31 = icmp eq i32 %t30, 0
  %t32 = zext i1 %t31 to i32
  %t33 = icmp ne i32 %t32, 0
  br i1 %t33, label %then3, label %ifend5
then3:
  call void @fn_emit(ptr @.str1380)
  br label %ifend5
ifend5:
  call void @fn_emit(ptr @.str1381)
  %t34 = load ptr, ptr %t24
  store ptr %t34, ptr @g_code
  call void @fn_emit(ptr @.str1382)
  %t35 = load ptr, ptr %t14
  %t36 = getelementptr inbounds %Cmp_Node, ptr %t35, i32 0, i32 1
  %t37 = load ptr, ptr %t36
  call void @fn_emit(ptr %t37)
  call void @fn_emit(ptr @.str1383)
  %t38 = load ptr, ptr @g_falloc
  %t39 = call ptr @fn_buf_str(ptr %t38)
  call void @fn_emit(ptr %t39)
  %t40 = load ptr, ptr %t21
  %t41 = call ptr @fn_buf_str(ptr %t40)
  call void @fn_emit(ptr %t41)
  call void @fn_emit(ptr @.str1384)
  %t42 = load i32, ptr %t0
  %t43 = add i32 %t42, 1
  store i32 %t43, ptr %t0
  br label %wcond0
wend2:
  br label %ret
ret:
  ret void
}

define void @fn_emit_game_main() {
entry:
  %t0 = alloca i32
  %t32 = alloca ptr
  %t37 = alloca ptr
  %t43 = alloca ptr
  %t48 = alloca ptr
  %t55 = alloca ptr
  %t63 = alloca ptr
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
  %t14 = getelementptr inbounds %Cmp_Node, ptr %t13, i32 0, i32 0
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
  call void @fn_emit_despawn_hooks()
  call void @fn_emit(ptr @.str1385)
  call void @fn_emit(ptr @.str1386)
  call void @fn_emit(ptr @.str1387)
  %t27 = call ptr @fn_find_fn(ptr @.str1388)
  %t28 = icmp ne ptr %t27, null
  %t29 = zext i1 %t28 to i32
  %t30 = icmp ne i32 %t29, 0
  br i1 %t30, label %then6, label %ifend8
then6:
  call void @fn_emit(ptr @.str1389)
  br label %ifend8
ifend8:
  call void @fn_emit_calls_for_phase(ptr @.str1390)
  call void @fn_emit(ptr @.str1391)
  call void @fn_emit(ptr @.str1392)
  %t31 = call ptr @fn_emit_bind(ptr @.str1393)
  store ptr %t31, ptr %t32
  %t33 = load ptr, ptr %t32
  %t34 = call ptr @fn_str_concat(ptr %t33, ptr @.str1395)
  %t35 = call ptr @fn_str_concat(ptr @.str1394, ptr %t34)
  %t36 = call ptr @fn_emit_bind(ptr %t35)
  store ptr %t36, ptr %t37
  %t38 = call ptr @fn_find_fn(ptr @.str1396)
  %t39 = icmp ne ptr %t38, null
  %t40 = zext i1 %t39 to i32
  %t41 = icmp ne i32 %t40, 0
  br i1 %t41, label %then9, label %else10
then9:
  %t42 = call ptr @fn_emit_bind(ptr @.str1397)
  store ptr %t42, ptr %t43
  %t44 = load ptr, ptr %t43
  %t45 = call ptr @fn_str_concat(ptr %t44, ptr @.str1399)
  %t46 = call ptr @fn_str_concat(ptr @.str1398, ptr %t45)
  %t47 = call ptr @fn_emit_bind(ptr %t46)
  store ptr %t47, ptr %t48
  %t49 = load ptr, ptr %t37
  %t50 = load ptr, ptr %t48
  %t51 = call ptr @fn_str_concat(ptr @.str1401, ptr %t50)
  %t52 = call ptr @fn_str_concat(ptr %t49, ptr %t51)
  %t53 = call ptr @fn_str_concat(ptr @.str1400, ptr %t52)
  %t54 = call ptr @fn_emit_bind(ptr %t53)
  store ptr %t54, ptr %t55
  call void @fn_emit(ptr @.str1402)
  %t56 = load ptr, ptr %t55
  call void @fn_emit(ptr %t56)
  call void @fn_emit(ptr @.str1403)
  br label %ifend11
else10:
  call void @fn_emit(ptr @.str1404)
  %t57 = load ptr, ptr %t37
  call void @fn_emit(ptr %t57)
  call void @fn_emit(ptr @.str1405)
  br label %ifend11
ifend11:
  call void @fn_emit(ptr @.str1406)
  %t58 = call ptr @fn_find_fn(ptr @.str1407)
  %t59 = icmp ne ptr %t58, null
  %t60 = zext i1 %t59 to i32
  %t61 = icmp ne i32 %t60, 0
  br i1 %t61, label %then12, label %ifend14
then12:
  %t62 = call ptr @fn_emit_bind(ptr @.str1408)
  store ptr %t62, ptr %t63
  call void @fn_emit(ptr @.str1409)
  %t64 = load ptr, ptr %t63
  call void @fn_emit(ptr %t64)
  call void @fn_emit(ptr @.str1410)
  br label %ifend14
ifend14:
  call void @fn_emit_calls_for_phase(ptr @.str1411)
  call void @fn_emit_calls_for_phase(ptr @.str1412)
  call void @fn_emit_calls_for_phase(ptr @.str1413)
  call void @fn_emit_calls_for_phase(ptr @.str1414)
  call void @fn_emit_calls_for_phase(ptr @.str1415)
  call void @fn_emit(ptr @.str1416)
  call void @fn_emit(ptr @.str1417)
  call void @fn_emit_calls_for_phase(ptr @.str1418)
  %t65 = call ptr @fn_find_fn(ptr @.str1419)
  %t66 = icmp ne ptr %t65, null
  %t67 = zext i1 %t66 to i32
  %t68 = icmp ne i32 %t67, 0
  br i1 %t68, label %then15, label %ifend17
then15:
  call void @fn_emit(ptr @.str1420)
  br label %ifend17
ifend17:
  call void @fn_emit(ptr @.str1421)
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
  %t2 = getelementptr inbounds %Cmp_Node, ptr %t1, i32 0, i32 4
  %t3 = load ptr, ptr %t2
  %t4 = call ptr @fn_emit_expr(ptr %t3)
  store ptr %t4, ptr %t5
  %t6 = load ptr, ptr %t5
  %t7 = getelementptr inbounds %Cmp_Val, ptr %t6, i32 0, i32 0
  %t8 = load ptr, ptr %t7
  %t9 = call ptr @fn_str_concat(ptr %t8, ptr @.str1423)
  %t10 = call ptr @fn_str_concat(ptr @.str1422, ptr %t9)
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
  %t48 = call ptr @fn_lbl(ptr @.str1424)
  store ptr %t48, ptr %t49
  store i32 0, ptr %t50
  br label %wcond5
wcond5:
  %t51 = load i32, ptr %t50
  %t52 = load ptr, ptr %t0
  %t53 = getelementptr inbounds %Cmp_Node, ptr %t52, i32 0, i32 7
  %t54 = load ptr, ptr %t53
  %t55 = getelementptr inbounds %LSlice, ptr %t54, i32 0, i32 1
  %t56 = load i32, ptr %t55
  %t57 = icmp slt i32 %t51, %t56
  %t58 = zext i1 %t57 to i32
  %t59 = icmp ne i32 %t58, 0
  br i1 %t59, label %wbody6, label %wend7
wbody6:
  %t60 = load ptr, ptr %t0
  %t61 = getelementptr inbounds %Cmp_Node, ptr %t60, i32 0, i32 7
  %t62 = load ptr, ptr %t61
  %t63 = getelementptr inbounds %LSlice, ptr %t62, i32 0, i32 0
  %t64 = load ptr, ptr %t63
  %t65 = load i32, ptr %t50
  %t66 = getelementptr inbounds ptr, ptr %t64, i32 %t65
  %t67 = load ptr, ptr %t66
  store ptr %t67, ptr %t68
  %t69 = load ptr, ptr %t68
  %t70 = getelementptr inbounds %Cmp_Node, ptr %t69, i32 0, i32 5
  %t71 = load ptr, ptr %t70
  %t72 = call ptr @fn_emit_expr(ptr %t71)
  store ptr %t72, ptr %t73
  %t74 = load ptr, ptr %t12
  %t75 = load ptr, ptr %t73
  %t76 = getelementptr inbounds %Cmp_Val, ptr %t75, i32 0, i32 0
  %t77 = load ptr, ptr %t76
  %t78 = call ptr @fn_str_concat(ptr @.str1426, ptr %t77)
  %t79 = call ptr @fn_str_concat(ptr %t74, ptr %t78)
  %t80 = call ptr @fn_str_concat(ptr @.str1425, ptr %t79)
  %t81 = call ptr @fn_emit_bind(ptr %t80)
  store ptr %t81, ptr %t82
  %t83 = call ptr @fn_lbl(ptr @.str1427)
  store ptr %t83, ptr %t84
  %t85 = call ptr @fn_lbl(ptr @.str1428)
  store ptr %t85, ptr %t86
  call void @fn_emit(ptr @.str1429)
  %t87 = load ptr, ptr %t82
  call void @fn_emit(ptr %t87)
  call void @fn_emit(ptr @.str1430)
  %t88 = load ptr, ptr %t84
  call void @fn_emit(ptr %t88)
  call void @fn_emit(ptr @.str1431)
  %t89 = load ptr, ptr %t86
  call void @fn_emit(ptr %t89)
  call void @fn_emit(ptr @.str1432)
  %t90 = load ptr, ptr %t84
  call void @fn_emit(ptr %t90)
  call void @fn_emit(ptr @.str1433)
  store i32 0, ptr @g_g_term
  %t91 = load ptr, ptr %t68
  %t92 = getelementptr inbounds %Cmp_Node, ptr %t91, i32 0, i32 4
  %t93 = load ptr, ptr %t92
  call void @fn_emit_block(ptr %t93)
  %t94 = load i32, ptr @g_g_term
  %t95 = icmp eq i32 %t94, 0
  %t96 = zext i1 %t95 to i32
  %t97 = icmp ne i32 %t96, 0
  br i1 %t97, label %then8, label %ifend10
then8:
  call void @fn_emit(ptr @.str1434)
  %t98 = load ptr, ptr %t49
  call void @fn_emit(ptr %t98)
  call void @fn_emit(ptr @.str1435)
  br label %ifend10
ifend10:
  %t99 = load ptr, ptr %t86
  call void @fn_emit(ptr %t99)
  call void @fn_emit(ptr @.str1436)
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
  call void @fn_emit(ptr @.str1437)
  %t106 = load ptr, ptr %t49
  call void @fn_emit(ptr %t106)
  call void @fn_emit(ptr @.str1438)
  br label %ifend13
ifend13:
  %t107 = load ptr, ptr %t49
  call void @fn_emit(ptr %t107)
  call void @fn_emit(ptr @.str1439)
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
  call void @fn_perr(ptr @.str1440)
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
  %t17 = getelementptr inbounds %Cmp_Node, ptr %t16, i32 0, i32 7
  %t18 = load ptr, ptr %t17
  %t19 = getelementptr inbounds %LSlice, ptr %t18, i32 0, i32 1
  %t20 = load i32, ptr %t19
  %t21 = icmp slt i32 %t15, %t20
  %t22 = zext i1 %t21 to i32
  %t23 = icmp ne i32 %t22, 0
  br i1 %t23, label %wbody4, label %wend5
wbody4:
  %t24 = load ptr, ptr %t12
  %t25 = getelementptr inbounds %Cmp_Node, ptr %t24, i32 0, i32 7
  %t26 = load ptr, ptr %t25
  %t27 = getelementptr inbounds %LSlice, ptr %t26, i32 0, i32 0
  %t28 = load ptr, ptr %t27
  %t29 = load i32, ptr %t14
  %t30 = getelementptr inbounds ptr, ptr %t28, i32 %t29
  %t31 = load ptr, ptr %t30
  %t32 = getelementptr inbounds %Cmp_Node, ptr %t31, i32 0, i32 1
  %t33 = load ptr, ptr %t32
  %t34 = load ptr, ptr %t0
  %t35 = getelementptr inbounds %Cmp_Node, ptr %t34, i32 0, i32 1
  %t36 = load ptr, ptr %t35
  %t37 = call i32 @fn_str_eq(ptr %t33, ptr %t36)
  %t38 = icmp ne i32 %t37, 0
  br i1 %t38, label %then6, label %ifend8
then6:
  %t39 = load ptr, ptr %t12
  %t40 = getelementptr inbounds %Cmp_Node, ptr %t39, i32 0, i32 7
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
  %t54 = getelementptr inbounds %Cmp_Node, ptr %t53, i32 0, i32 1
  %t55 = load ptr, ptr %t54
  %t56 = call ptr @fn_str_concat(ptr @.str1441, ptr %t55)
  call void @fn_perr(ptr %t56)
  br label %ifend11
ifend11:
  %t57 = load ptr, ptr %t12
  %t58 = getelementptr inbounds %Cmp_Node, ptr %t57, i32 0, i32 4
  %t59 = load ptr, ptr %t58
  %t60 = call ptr @fn_emit_expr(ptr %t59)
  store ptr %t60, ptr %t61
  %t62 = load ptr, ptr %t13
  %t63 = getelementptr inbounds %Cmp_Node, ptr %t62, i32 0, i32 5
  %t64 = load ptr, ptr %t63
  %t65 = call ptr @fn_emit_expr(ptr %t64)
  store ptr %t65, ptr %t66
  call void @fn_emit(ptr @.str1442)
  %t67 = load ptr, ptr %t61
  %t68 = getelementptr inbounds %Cmp_Val, ptr %t67, i32 0, i32 0
  %t69 = load ptr, ptr %t68
  call void @fn_emit(ptr %t69)
  call void @fn_emit(ptr @.str1443)
  %t70 = load ptr, ptr %t66
  %t71 = getelementptr inbounds %Cmp_Val, ptr %t70, i32 0, i32 0
  %t72 = load ptr, ptr %t71
  call void @fn_emit(ptr %t72)
  call void @fn_emit(ptr @.str1444)
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
  %t5 = call ptr @fn_str_concat(ptr @.str1445, ptr %t4)
  store ptr %t5, ptr %t6
  %t7 = load i32, ptr @g_g_iok
  %t8 = add i32 %t7, 1
  store i32 %t8, ptr @g_g_iok
  call void @fn_emit(ptr @.str1446)
  %t9 = load ptr, ptr %t6
  call void @fn_emit(ptr %t9)
  call void @fn_emit(ptr @.str1447)
  %t10 = load ptr, ptr %t0
  call void @fn_emit(ptr %t10)
  call void @fn_emit(ptr @.str1448)
  %t11 = load ptr, ptr %t1
  call void @fn_emit(ptr %t11)
  call void @fn_emit(ptr @.str1449)
  %t12 = load ptr, ptr %t2
  call void @fn_emit(ptr %t12)
  call void @fn_emit(ptr @.str1450)
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
  call void @fn_emit_io(ptr %t3, ptr @.str1451, ptr @.str1452)
  %t4 = load ptr, ptr %t0
  call void @fn_emit_io(ptr %t4, ptr @.str1453, ptr @.str1454)
  call void @fn_emit(ptr @.str1455)
  %t5 = load ptr, ptr %t2
  call void @fn_emit(ptr %t5)
  call void @fn_emit(ptr @.str1456)
  %t6 = load ptr, ptr %t0
  call void @fn_emit_io(ptr %t6, ptr @.str1457, ptr @.str1458)
  %t7 = load ptr, ptr %t0
  call void @fn_emit_io(ptr %t7, ptr @.str1459, ptr @.str1460)
  %t8 = load ptr, ptr %t0
  call void @fn_emit_io(ptr %t8, ptr @.str1461, ptr @.str1462)
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
  %t23 = getelementptr inbounds %Cmp_Node, ptr %t22, i32 0, i32 0
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
  %t35 = getelementptr inbounds %Cmp_Node, ptr %t34, i32 0, i32 1
  %t36 = load ptr, ptr %t35
  %t37 = call ptr @fn_str_concat(ptr @.str1463, ptr %t36)
  call void @fn_emit_io(ptr %t28, ptr %t37, ptr @.str1464)
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
  %t54 = getelementptr inbounds %Cmp_Node, ptr %t53, i32 0, i32 0
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
  %t65 = getelementptr inbounds %Cmp_Node, ptr %t64, i32 0, i32 1
  %t66 = load ptr, ptr %t65
  store ptr %t66, ptr %t67
  %t68 = load i32, ptr %t40
  %t69 = call ptr @fn_itoa(i32 %t68)
  %t70 = call ptr @fn_str_concat(ptr @.str1465, ptr %t69)
  store ptr %t70, ptr %t71
  call void @fn_emit(ptr @.str1466)
  %t72 = load ptr, ptr %t71
  call void @fn_emit(ptr %t72)
  call void @fn_emit(ptr @.str1467)
  %t73 = load ptr, ptr %t67
  call void @fn_emit(ptr %t73)
  call void @fn_emit(ptr @.str1468)
  %t74 = load ptr, ptr %t2
  call void @fn_emit(ptr %t74)
  call void @fn_emit(ptr @.str1469)
  %t75 = load ptr, ptr %t0
  %t76 = load ptr, ptr %t67
  %t77 = call ptr @fn_str_concat(ptr @.str1470, ptr %t76)
  %t78 = load ptr, ptr %t71
  call void @fn_emit_io(ptr %t75, ptr %t77, ptr %t78)
  %t79 = load ptr, ptr %t0
  %t80 = load ptr, ptr %t67
  %t81 = call ptr @fn_str_concat(ptr @.str1471, ptr %t80)
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
  %t3 = alloca i32
  %t7 = alloca i32
  call void @fn_emith(ptr @.str1472)
  call void @fn_emith(ptr @.str1473)
  call void @fn_emith(ptr @.str1474)
  %t0 = call ptr @fn_find_fn(ptr @.str1475)
  %t1 = icmp ne ptr %t0, null
  %t2 = zext i1 %t1 to i32
  store i32 %t2, ptr %t3
  %t4 = call ptr @fn_find_fn(ptr @.str1476)
  %t5 = icmp ne ptr %t4, null
  %t6 = zext i1 %t5 to i32
  store i32 %t6, ptr %t7
  call void @fn_emit(ptr @.str1477)
  call void @fn_emit(ptr @.str1478)
  call void @fn_emit(ptr @.str1479)
  call void @fn_emit(ptr @.str1480)
  call void @fn_emit_snapshot_blocks(ptr @.str1481)
  %t8 = load i32, ptr %t3
  %t9 = icmp ne i32 %t8, 0
  br i1 %t9, label %then0, label %ifend2
then0:
  call void @fn_emit(ptr @.str1482)
  br label %ifend2
ifend2:
  call void @fn_emit(ptr @.str1483)
  call void @fn_emit(ptr @.str1484)
  call void @fn_emit(ptr @.str1485)
  call void @fn_emit(ptr @.str1486)
  call void @fn_emit(ptr @.str1487)
  call void @fn_emit_snapshot_blocks(ptr @.str1488)
  %t10 = load i32, ptr %t7
  %t11 = icmp ne i32 %t10, 0
  br i1 %t11, label %then3, label %ifend5
then3:
  call void @fn_emit(ptr @.str1489)
  br label %ifend5
ifend5:
  call void @fn_emit(ptr @.str1490)
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
  %t2 = getelementptr inbounds %Cmp_Node, ptr %t1, i32 0, i32 1
  %t3 = load ptr, ptr %t2
  store ptr %t3, ptr %t4
  %t5 = load ptr, ptr %t4
  %t6 = call i32 @fn_str_eq(ptr %t5, ptr @.str1491)
  %t7 = icmp ne i32 %t6, 0
  br i1 %t7, label %then0, label %ifend2
then0:
  store i32 0, ptr %retval
  br label %ret
ifend2:
  %t8 = load ptr, ptr %t4
  %t9 = call i32 @fn_str_eq(ptr %t8, ptr @.str1492)
  %t10 = icmp ne i32 %t9, 0
  br i1 %t10, label %then3, label %ifend5
then3:
  store i32 1, ptr %retval
  br label %ret
ifend5:
  %t11 = load ptr, ptr %t4
  %t12 = call i32 @fn_str_eq(ptr %t11, ptr @.str1493)
  %t13 = icmp ne i32 %t12, 0
  br i1 %t13, label %then6, label %ifend8
then6:
  store i32 2, ptr %retval
  br label %ret
ifend8:
  %t14 = load ptr, ptr %t4
  %t15 = call i32 @fn_str_eq(ptr %t14, ptr @.str1494)
  %t16 = icmp ne i32 %t15, 0
  br i1 %t16, label %then9, label %ifend11
then9:
  store i32 3, ptr %retval
  br label %ret
ifend11:
  %t17 = load ptr, ptr %t4
  %t18 = call i32 @fn_str_eq(ptr %t17, ptr @.str1495)
  %t19 = icmp ne i32 %t18, 0
  br i1 %t19, label %then12, label %ifend14
then12:
  store i32 4, ptr %retval
  br label %ret
ifend14:
  %t20 = load ptr, ptr %t4
  %t21 = call i32 @fn_str_eq(ptr %t20, ptr @.str1496)
  %t22 = icmp ne i32 %t21, 0
  br i1 %t22, label %then15, label %ifend17
then15:
  store i32 5, ptr %retval
  br label %ret
ifend17:
  %t23 = load ptr, ptr %t4
  %t24 = call i32 @fn_str_eq(ptr %t23, ptr @.str1497)
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
  %t5 = getelementptr inbounds %Cmp_Node, ptr %t4, i32 0, i32 5
  %t6 = load ptr, ptr %t5
  %t7 = getelementptr inbounds %Cmp_Node, ptr %t6, i32 0, i32 7
  %t8 = load ptr, ptr %t7
  %t9 = getelementptr inbounds %LSlice, ptr %t8, i32 0, i32 1
  %t10 = load i32, ptr %t9
  %t11 = icmp slt i32 %t3, %t10
  %t12 = zext i1 %t11 to i32
  %t13 = icmp ne i32 %t12, 0
  br i1 %t13, label %wbody1, label %wend2
wbody1:
  %t14 = load ptr, ptr %t0
  %t15 = getelementptr inbounds %Cmp_Node, ptr %t14, i32 0, i32 5
  %t16 = load ptr, ptr %t15
  %t17 = getelementptr inbounds %Cmp_Node, ptr %t16, i32 0, i32 7
  %t18 = load ptr, ptr %t17
  %t19 = getelementptr inbounds %LSlice, ptr %t18, i32 0, i32 0
  %t20 = load ptr, ptr %t19
  %t21 = load i32, ptr %t2
  %t22 = getelementptr inbounds ptr, ptr %t20, i32 %t21
  %t23 = load ptr, ptr %t22
  %t24 = getelementptr inbounds %Cmp_Node, ptr %t23, i32 0, i32 1
  %t25 = load ptr, ptr %t24
  %t26 = load ptr, ptr %t1
  %t27 = call i32 @fn_str_eq(ptr %t25, ptr %t26)
  %t28 = icmp ne i32 %t27, 0
  br i1 %t28, label %then3, label %ifend5
then3:
  %t29 = load ptr, ptr %t0
  %t30 = getelementptr inbounds %Cmp_Node, ptr %t29, i32 0, i32 5
  %t31 = load ptr, ptr %t30
  %t32 = getelementptr inbounds %Cmp_Node, ptr %t31, i32 0, i32 7
  %t33 = load ptr, ptr %t32
  %t34 = getelementptr inbounds %LSlice, ptr %t33, i32 0, i32 0
  %t35 = load ptr, ptr %t34
  %t36 = load i32, ptr %t2
  %t37 = getelementptr inbounds ptr, ptr %t35, i32 %t36
  %t38 = load ptr, ptr %t37
  %t39 = getelementptr inbounds %Cmp_Node, ptr %t38, i32 0, i32 4
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
  %t49 = getelementptr inbounds %Cmp_Node, ptr %t48, i32 0, i32 7
  %t50 = load ptr, ptr %t49
  %t51 = getelementptr inbounds %LSlice, ptr %t50, i32 0, i32 1
  %t52 = load i32, ptr %t51
  %t53 = icmp slt i32 %t47, %t52
  %t54 = zext i1 %t53 to i32
  %t55 = icmp ne i32 %t54, 0
  br i1 %t55, label %wbody5, label %wend6
wbody5:
  %t56 = load ptr, ptr %t0
  %t57 = getelementptr inbounds %Cmp_Node, ptr %t56, i32 0, i32 7
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
  %t33 = getelementptr inbounds %Cmp_Node, ptr %t32, i32 0, i32 0
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
  %t45 = getelementptr inbounds %Cmp_Node, ptr %t44, i32 0, i32 2
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
  %t81 = getelementptr inbounds %Cmp_Node, ptr %t80, i32 0, i32 4
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
  %t15 = getelementptr inbounds %Cmp_Node, ptr %t14, i32 0, i32 0
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
  %t27 = getelementptr inbounds %Cmp_Node, ptr %t26, i32 0, i32 2
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
  %t84 = alloca i32
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
  %t24 = getelementptr inbounds %Cmp_Node, ptr %t23, i32 0, i32 0
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
  %t36 = getelementptr inbounds %Cmp_Node, ptr %t35, i32 0, i32 2
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
  %t50 = getelementptr inbounds %Cmp_Node, ptr %t49, i32 0, i32 1
  %t51 = load ptr, ptr %t50
  %t52 = load ptr, ptr %t6
  %t53 = call i32 @fn_str_eq(ptr %t51, ptr %t52)
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
  %t78 = call ptr @fn_ui_prop(ptr %t77, ptr @.str1498)
  store ptr %t78, ptr %t79
  %t80 = load ptr, ptr %t79
  %t81 = icmp ne ptr %t80, null
  %t82 = zext i1 %t81 to i32
  %t83 = icmp ne i32 %t82, 0
  br i1 %t83, label %then14, label %ifend16
then14:
  %t85 = load ptr, ptr %t79
  %t86 = getelementptr inbounds %Cmp_Node, ptr %t85, i32 0, i32 0
  %t87 = load i32, ptr %t86
  %t88 = icmp eq i32 %t87, 33
  %t89 = zext i1 %t88 to i32
  %t90 = icmp ne i32 %t89, 0
  %t91 = zext i1 %t90 to i32
  store i32 %t91, ptr %t84
  br i1 %t90, label %sc17, label %scend18
sc17:
  %t92 = load ptr, ptr %t79
  %t93 = getelementptr inbounds %Cmp_Node, ptr %t92, i32 0, i32 1
  %t94 = load ptr, ptr %t93
  %t95 = load ptr, ptr %t6
  %t96 = call i32 @fn_str_eq(ptr %t94, ptr %t95)
  %t97 = icmp ne i32 %t96, 0
  %t98 = zext i1 %t97 to i32
  store i32 %t98, ptr %t84
  br label %scend18
scend18:
  %t99 = load i32, ptr %t84
  %t100 = icmp ne i32 %t99, 0
  br i1 %t100, label %then19, label %ifend21
then19:
  %t101 = load i32, ptr %t9
  store i32 %t101, ptr %retval
  br label %ret
ifend21:
  br label %ifend16
ifend16:
  %t102 = load i32, ptr %t9
  %t103 = add i32 %t102, 1
  store i32 %t103, ptr %t9
  br label %wcond11
wend13:
  store i32 0, ptr %retval
  br label %ret
ret:
  %t104 = load i32, ptr %retval
  ret i32 %t104
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
  call void @fn_emit(ptr @.str1499)
  %t3 = load i32, ptr %t0
  %t4 = call ptr @fn_itoa(i32 %t3)
  call void @fn_emit(ptr %t4)
  call void @fn_emit(ptr @.str1500)
  %t5 = load i32, ptr %t1
  %t6 = call ptr @fn_itoa(i32 %t5)
  call void @fn_emit(ptr %t6)
  call void @fn_emit(ptr @.str1501)
  %t7 = load ptr, ptr %t2
  call void @fn_emit(ptr %t7)
  call void @fn_emit(ptr @.str1502)
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
  %t2 = call i32 @fn_str_eq(ptr %t1, ptr @.str1503)
  %t3 = icmp ne i32 %t2, 0
  br i1 %t3, label %then0, label %ifend2
then0:
  store i32 2, ptr %retval
  br label %ret
ifend2:
  %t4 = load ptr, ptr %t0
  %t5 = call i32 @fn_str_eq(ptr %t4, ptr @.str1504)
  %t6 = icmp ne i32 %t5, 0
  br i1 %t6, label %then3, label %ifend5
then3:
  store i32 3, ptr %retval
  br label %ret
ifend5:
  %t7 = load ptr, ptr %t0
  %t8 = call i32 @fn_str_eq(ptr %t7, ptr @.str1505)
  %t9 = icmp ne i32 %t8, 0
  br i1 %t9, label %then6, label %ifend8
then6:
  store i32 4, ptr %retval
  br label %ret
ifend8:
  %t10 = load ptr, ptr %t0
  %t11 = call i32 @fn_str_eq(ptr %t10, ptr @.str1506)
  %t12 = icmp ne i32 %t11, 0
  br i1 %t12, label %then9, label %ifend11
then9:
  store i32 5, ptr %retval
  br label %ret
ifend11:
  %t13 = load ptr, ptr %t0
  %t14 = call i32 @fn_str_eq(ptr %t13, ptr @.str1507)
  %t15 = icmp ne i32 %t14, 0
  br i1 %t15, label %then12, label %ifend14
then12:
  store i32 7, ptr %retval
  br label %ret
ifend14:
  %t16 = load ptr, ptr %t0
  %t17 = call i32 @fn_str_eq(ptr %t16, ptr @.str1508)
  %t18 = icmp ne i32 %t17, 0
  br i1 %t18, label %then15, label %ifend17
then15:
  store i32 8, ptr %retval
  br label %ret
ifend17:
  %t19 = load ptr, ptr %t0
  %t20 = call i32 @fn_str_eq(ptr %t19, ptr @.str1509)
  %t21 = icmp ne i32 %t20, 0
  br i1 %t21, label %then18, label %ifend20
then18:
  store i32 9, ptr %retval
  br label %ret
ifend20:
  %t22 = load ptr, ptr %t0
  %t23 = call i32 @fn_str_eq(ptr %t22, ptr @.str1510)
  %t24 = icmp ne i32 %t23, 0
  br i1 %t24, label %then21, label %ifend23
then21:
  store i32 10, ptr %retval
  br label %ret
ifend23:
  %t25 = load ptr, ptr %t0
  %t26 = call i32 @fn_str_eq(ptr %t25, ptr @.str1511)
  %t27 = icmp ne i32 %t26, 0
  br i1 %t27, label %then24, label %ifend26
then24:
  store i32 11, ptr %retval
  br label %ret
ifend26:
  %t28 = load ptr, ptr %t0
  %t29 = call i32 @fn_str_eq(ptr %t28, ptr @.str1512)
  %t30 = icmp ne i32 %t29, 0
  br i1 %t30, label %then27, label %ifend29
then27:
  store i32 13, ptr %retval
  br label %ret
ifend29:
  %t31 = load ptr, ptr %t0
  %t32 = call i32 @fn_str_eq(ptr %t31, ptr @.str1513)
  %t33 = icmp ne i32 %t32, 0
  br i1 %t33, label %then30, label %ifend32
then30:
  store i32 14, ptr %retval
  br label %ret
ifend32:
  %t34 = load ptr, ptr %t0
  %t35 = call i32 @fn_str_eq(ptr %t34, ptr @.str1514)
  %t36 = icmp ne i32 %t35, 0
  br i1 %t36, label %then33, label %ifend35
then33:
  store i32 15, ptr %retval
  br label %ret
ifend35:
  %t37 = load ptr, ptr %t0
  %t38 = call i32 @fn_str_eq(ptr %t37, ptr @.str1515)
  %t39 = icmp ne i32 %t38, 0
  br i1 %t39, label %then36, label %ifend38
then36:
  store i32 16, ptr %retval
  br label %ret
ifend38:
  %t40 = load ptr, ptr %t0
  %t41 = call i32 @fn_str_eq(ptr %t40, ptr @.str1516)
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
  call void @fn_emit(ptr @.str1517)
  %t6 = load ptr, ptr @g_uiw
  %t7 = getelementptr inbounds %LSlice, ptr %t6, i32 0, i32 1
  %t8 = load i32, ptr %t7
  %t9 = call ptr @fn_itoa(i32 %t8)
  call void @fn_emit(ptr %t9)
  call void @fn_emit(ptr @.str1518)
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
  call void @fn_ll_ui_set(i32 %t43, i32 17, ptr @.str1519)
  br label %ifend5
ifend5:
  store i32 0, ptr %t44
  br label %wcond6
wcond6:
  %t45 = load i32, ptr %t44
  %t46 = load ptr, ptr %t24
  %t47 = getelementptr inbounds %Cmp_Node, ptr %t46, i32 0, i32 5
  %t48 = load ptr, ptr %t47
  %t49 = getelementptr inbounds %Cmp_Node, ptr %t48, i32 0, i32 7
  %t50 = load ptr, ptr %t49
  %t51 = getelementptr inbounds %LSlice, ptr %t50, i32 0, i32 1
  %t52 = load i32, ptr %t51
  %t53 = icmp slt i32 %t45, %t52
  %t54 = zext i1 %t53 to i32
  %t55 = icmp ne i32 %t54, 0
  br i1 %t55, label %wbody7, label %wend8
wbody7:
  %t56 = load ptr, ptr %t24
  %t57 = getelementptr inbounds %Cmp_Node, ptr %t56, i32 0, i32 5
  %t58 = load ptr, ptr %t57
  %t59 = getelementptr inbounds %Cmp_Node, ptr %t58, i32 0, i32 7
  %t60 = load ptr, ptr %t59
  %t61 = getelementptr inbounds %LSlice, ptr %t60, i32 0, i32 0
  %t62 = load ptr, ptr %t61
  %t63 = load i32, ptr %t44
  %t64 = getelementptr inbounds ptr, ptr %t62, i32 %t63
  %t65 = load ptr, ptr %t64
  store ptr %t65, ptr %t66
  %t67 = load ptr, ptr %t66
  %t68 = getelementptr inbounds %Cmp_Node, ptr %t67, i32 0, i32 1
  %t69 = load ptr, ptr %t68
  store ptr %t69, ptr %t70
  %t71 = load ptr, ptr %t66
  %t72 = getelementptr inbounds %Cmp_Node, ptr %t71, i32 0, i32 4
  %t73 = load ptr, ptr %t72
  store ptr %t73, ptr %t74
  %t75 = load ptr, ptr %t70
  %t76 = call i32 @fn_str_eq(ptr %t75, ptr @.str1520)
  %t77 = icmp ne i32 %t76, 0
  br i1 %t77, label %then9, label %ifend11
then9:
  %t78 = load i32, ptr %t44
  %t79 = add i32 %t78, 1
  store i32 %t79, ptr %t44
  br label %wcond6
ifend11:
  %t80 = load ptr, ptr %t70
  %t81 = call i32 @fn_str_eq(ptr %t80, ptr @.str1521)
  %t82 = icmp ne i32 %t81, 0
  br i1 %t82, label %then12, label %else13
then12:
  %t83 = load ptr, ptr %t74
  %t84 = call ptr @fn_emit_expr(ptr %t83)
  store ptr %t84, ptr %t85
  call void @fn_emit(ptr @.str1522)
  %t86 = load i32, ptr %t10
  %t87 = call ptr @fn_itoa(i32 %t86)
  call void @fn_emit(ptr %t87)
  call void @fn_emit(ptr @.str1523)
  %t88 = load ptr, ptr %t85
  %t89 = getelementptr inbounds %Cmp_Val, ptr %t88, i32 0, i32 0
  %t90 = load ptr, ptr %t89
  call void @fn_emit(ptr %t90)
  call void @fn_emit(ptr @.str1524)
  br label %ifend14
else13:
  %t92 = load ptr, ptr %t70
  %t93 = call i32 @fn_str_eq(ptr %t92, ptr @.str1525)
  %t94 = icmp ne i32 %t93, 0
  %t95 = zext i1 %t94 to i32
  store i32 %t95, ptr %t91
  br i1 %t94, label %scend16, label %sc15
sc15:
  %t96 = load ptr, ptr %t70
  %t97 = call i32 @fn_str_eq(ptr %t96, ptr @.str1526)
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
  %t106 = getelementptr inbounds %Cmp_Val, ptr %t105, i32 0, i32 0
  %t107 = load ptr, ptr %t106
  %t108 = call ptr @fn_str_concat(ptr %t107, ptr @.str1528)
  %t109 = call ptr @fn_str_concat(ptr @.str1527, ptr %t108)
  %t110 = call ptr @fn_emit_bind(ptr %t109)
  store ptr %t110, ptr %t111
  %t112 = load ptr, ptr %t70
  %t113 = call i32 @fn_str_eq(ptr %t112, ptr @.str1529)
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
  %t120 = call i32 @fn_str_eq(ptr %t119, ptr @.str1530)
  %t121 = icmp ne i32 %t120, 0
  br i1 %t121, label %then23, label %else24
then23:
  %t122 = load ptr, ptr %t74
  %t123 = getelementptr inbounds %Cmp_Node, ptr %t122, i32 0, i32 0
  %t124 = load i32, ptr %t123
  %t125 = icmp eq i32 %t124, 33
  %t126 = zext i1 %t125 to i32
  %t127 = icmp ne i32 %t126, 0
  br i1 %t127, label %then26, label %else27
then26:
  store i32 0, ptr %t128
  %t129 = load ptr, ptr %t74
  %t130 = getelementptr inbounds %Cmp_Node, ptr %t129, i32 0, i32 1
  %t131 = load ptr, ptr %t130
  %t132 = call i32 @fn_str_eq(ptr %t131, ptr @.str1531)
  %t133 = icmp ne i32 %t132, 0
  br i1 %t133, label %then29, label %ifend31
then29:
  store i32 1, ptr %t128
  br label %ifend31
ifend31:
  %t134 = load ptr, ptr %t74
  %t135 = getelementptr inbounds %Cmp_Node, ptr %t134, i32 0, i32 1
  %t136 = load ptr, ptr %t135
  %t137 = call i32 @fn_str_eq(ptr %t136, ptr @.str1532)
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
  %t147 = getelementptr inbounds %Cmp_Val, ptr %t146, i32 0, i32 0
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
  %t162 = getelementptr inbounds %Cmp_Val, ptr %t161, i32 0, i32 0
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
  call void @fn_ll_ui_set(i32 %t177, i32 6, ptr @.str1533)
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
  call void @fn_emit(ptr @.str1534)
  %t183 = load ptr, ptr @g_falloc
  %t184 = call ptr @fn_buf_str(ptr %t183)
  call void @fn_emit(ptr %t184)
  %t185 = load ptr, ptr %t1
  %t186 = call ptr @fn_buf_str(ptr %t185)
  call void @fn_emit(ptr %t186)
  call void @fn_emit(ptr @.str1535)
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
  %t4 = getelementptr inbounds %Cmp_Node, ptr %t3, i32 0, i32 7
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
  call void @fn_emit(ptr @.str1536)
  br label %ifend5
ifend5:
  %t15 = load ptr, ptr %t0
  %t16 = getelementptr inbounds %Cmp_Node, ptr %t15, i32 0, i32 7
  %t17 = load ptr, ptr %t16
  %t18 = getelementptr inbounds %LSlice, ptr %t17, i32 0, i32 0
  %t19 = load ptr, ptr %t18
  %t20 = load i32, ptr %t1
  %t21 = getelementptr inbounds ptr, ptr %t19, i32 %t20
  %t22 = load ptr, ptr %t21
  %t23 = getelementptr inbounds %Cmp_Node, ptr %t22, i32 0, i32 3
  %t24 = load ptr, ptr %t23
  %t25 = call ptr @fn_llty(ptr %t24)
  call void @fn_emit(ptr %t25)
  call void @fn_emit(ptr @.str1537)
  %t26 = load ptr, ptr %t0
  %t27 = getelementptr inbounds %Cmp_Node, ptr %t26, i32 0, i32 7
  %t28 = load ptr, ptr %t27
  %t29 = getelementptr inbounds %LSlice, ptr %t28, i32 0, i32 0
  %t30 = load ptr, ptr %t29
  %t31 = load i32, ptr %t1
  %t32 = getelementptr inbounds ptr, ptr %t30, i32 %t31
  %t33 = load ptr, ptr %t32
  %t34 = getelementptr inbounds %Cmp_Node, ptr %t33, i32 0, i32 1
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
  %t2 = getelementptr inbounds %Cmp_Node, ptr %t1, i32 0, i32 3
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
  %t14 = call i32 @fn_str_eq(ptr %t13, ptr @.str1538)
  %t15 = icmp eq i32 %t14, 0
  %t16 = zext i1 %t15 to i32
  %t17 = icmp ne i32 %t16, 0
  br i1 %t17, label %then0, label %ifend2
then0:
  %t18 = load ptr, ptr @g_falloc
  call void @fn_buf_puts(ptr %t18, ptr @.str1539)
  %t19 = load ptr, ptr @g_falloc
  %t20 = load ptr, ptr %t12
  call void @fn_buf_puts(ptr %t19, ptr %t20)
  %t21 = load ptr, ptr @g_falloc
  call void @fn_buf_puts(ptr %t21, ptr @.str1540)
  br label %ifend2
ifend2:
  store i32 0, ptr %t22
  br label %wcond3
wcond3:
  %t23 = load i32, ptr %t22
  %t24 = load ptr, ptr %t0
  %t25 = getelementptr inbounds %Cmp_Node, ptr %t24, i32 0, i32 7
  %t26 = load ptr, ptr %t25
  %t27 = getelementptr inbounds %LSlice, ptr %t26, i32 0, i32 1
  %t28 = load i32, ptr %t27
  %t29 = icmp slt i32 %t23, %t28
  %t30 = zext i1 %t29 to i32
  %t31 = icmp ne i32 %t30, 0
  br i1 %t31, label %wbody4, label %wend5
wbody4:
  %t32 = load ptr, ptr %t0
  %t33 = getelementptr inbounds %Cmp_Node, ptr %t32, i32 0, i32 7
  %t34 = load ptr, ptr %t33
  %t35 = getelementptr inbounds %LSlice, ptr %t34, i32 0, i32 0
  %t36 = load ptr, ptr %t35
  %t37 = load i32, ptr %t22
  %t38 = getelementptr inbounds ptr, ptr %t36, i32 %t37
  %t39 = load ptr, ptr %t38
  store ptr %t39, ptr %t40
  %t41 = load ptr, ptr %t40
  %t42 = getelementptr inbounds %Cmp_Node, ptr %t41, i32 0, i32 3
  %t43 = load ptr, ptr %t42
  %t44 = call ptr @fn_llty(ptr %t43)
  %t45 = call ptr @fn_emit_alloca(ptr %t44)
  store ptr %t45, ptr %t46
  call void @fn_emit(ptr @.str1541)
  %t47 = load ptr, ptr %t40
  %t48 = getelementptr inbounds %Cmp_Node, ptr %t47, i32 0, i32 3
  %t49 = load ptr, ptr %t48
  %t50 = call ptr @fn_llty(ptr %t49)
  call void @fn_emit(ptr %t50)
  call void @fn_emit(ptr @.str1542)
  %t51 = load ptr, ptr %t40
  %t52 = getelementptr inbounds %Cmp_Node, ptr %t51, i32 0, i32 1
  %t53 = load ptr, ptr %t52
  call void @fn_emit(ptr %t53)
  call void @fn_emit(ptr @.str1543)
  %t54 = load ptr, ptr %t46
  call void @fn_emit(ptr %t54)
  call void @fn_emit(ptr @.str1544)
  %t55 = load ptr, ptr %t40
  %t56 = getelementptr inbounds %Cmp_Node, ptr %t55, i32 0, i32 1
  %t57 = load ptr, ptr %t56
  %t58 = load ptr, ptr %t46
  %t59 = load ptr, ptr %t40
  %t60 = getelementptr inbounds %Cmp_Node, ptr %t59, i32 0, i32 3
  %t61 = load ptr, ptr %t60
  call void @fn_loc_push(ptr %t57, ptr %t58, ptr %t61)
  %t62 = load i32, ptr %t22
  %t63 = add i32 %t62, 1
  store i32 %t63, ptr %t22
  br label %wcond3
wend5:
  %t64 = load ptr, ptr %t0
  %t65 = getelementptr inbounds %Cmp_Node, ptr %t64, i32 0, i32 4
  %t66 = load ptr, ptr %t65
  call void @fn_emit_block(ptr %t66)
  %t67 = load i32, ptr @g_g_term
  %t68 = icmp eq i32 %t67, 0
  %t69 = zext i1 %t68 to i32
  %t70 = icmp ne i32 %t69, 0
  br i1 %t70, label %then6, label %ifend8
then6:
  call void @fn_emit(ptr @.str1545)
  br label %ifend8
ifend8:
  call void @fn_emit(ptr @.str1546)
  %t71 = load ptr, ptr %t12
  %t72 = call i32 @fn_str_eq(ptr %t71, ptr @.str1547)
  %t73 = icmp ne i32 %t72, 0
  br i1 %t73, label %then9, label %else10
then9:
  call void @fn_emit(ptr @.str1548)
  br label %ifend11
else10:
  %t74 = load ptr, ptr %t12
  %t75 = call ptr @fn_str_concat(ptr %t74, ptr @.str1550)
  %t76 = call ptr @fn_str_concat(ptr @.str1549, ptr %t75)
  %t77 = call ptr @fn_emit_bind(ptr %t76)
  store ptr %t77, ptr %t78
  call void @fn_emit(ptr @.str1551)
  %t79 = load ptr, ptr %t12
  call void @fn_emit(ptr %t79)
  call void @fn_emit(ptr @.str1552)
  %t80 = load ptr, ptr %t78
  call void @fn_emit(ptr %t80)
  call void @fn_emit(ptr @.str1553)
  br label %ifend11
ifend11:
  %t81 = load ptr, ptr %t8
  store ptr %t81, ptr @g_code
  call void @fn_emit(ptr @.str1554)
  %t82 = load ptr, ptr %t12
  call void @fn_emit(ptr %t82)
  call void @fn_emit(ptr @.str1555)
  %t83 = load ptr, ptr %t0
  %t84 = getelementptr inbounds %Cmp_Node, ptr %t83, i32 0, i32 1
  %t85 = load ptr, ptr %t84
  call void @fn_emit(ptr %t85)
  call void @fn_emit(ptr @.str1556)
  %t86 = load ptr, ptr %t0
  call void @fn_emit_params_sig(ptr %t86)
  call void @fn_emit(ptr @.str1557)
  %t87 = load ptr, ptr @g_falloc
  %t88 = call ptr @fn_buf_str(ptr %t87)
  call void @fn_emit(ptr %t88)
  %t89 = load ptr, ptr %t5
  %t90 = call ptr @fn_buf_str(ptr %t89)
  call void @fn_emit(ptr %t90)
  call void @fn_emit(ptr @.str1558)
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
  store ptr @.str1559, ptr @g_ret_ty
  %t1 = call ptr @fn_buf_new()
  store ptr %t1, ptr %t2
  %t3 = call ptr @fn_buf_new()
  store ptr %t3, ptr @g_falloc
  %t4 = load ptr, ptr @g_code
  store ptr %t4, ptr %t5
  %t6 = load ptr, ptr %t2
  store ptr %t6, ptr @g_code
  %t7 = load ptr, ptr @g_falloc
  call void @fn_buf_puts(ptr %t7, ptr @.str1560)
  call void @fn_emit(ptr @.str1561)
  call void @fn_emit(ptr @.str1562)
  call void @fn_emit(ptr @.str1563)
  %t8 = load ptr, ptr %t0
  %t9 = getelementptr inbounds %Cmp_Node, ptr %t8, i32 0, i32 4
  %t10 = load ptr, ptr %t9
  call void @fn_emit_block(ptr %t10)
  %t11 = load i32, ptr @g_g_term
  %t12 = icmp eq i32 %t11, 0
  %t13 = zext i1 %t12 to i32
  %t14 = icmp ne i32 %t13, 0
  br i1 %t14, label %then0, label %ifend2
then0:
  call void @fn_emit(ptr @.str1564)
  br label %ifend2
ifend2:
  call void @fn_emit(ptr @.str1565)
  %t15 = call ptr @fn_emit_bind(ptr @.str1566)
  store ptr %t15, ptr %t16
  call void @fn_emit(ptr @.str1567)
  %t17 = load ptr, ptr %t16
  call void @fn_emit(ptr %t17)
  call void @fn_emit(ptr @.str1568)
  %t18 = load ptr, ptr %t5
  store ptr %t18, ptr @g_code
  call void @fn_emit(ptr @.str1569)
  %t19 = load ptr, ptr @g_falloc
  %t20 = call ptr @fn_buf_str(ptr %t19)
  call void @fn_emit(ptr %t20)
  %t21 = load ptr, ptr %t2
  %t22 = call ptr @fn_buf_str(ptr %t21)
  call void @fn_emit(ptr %t22)
  call void @fn_emit(ptr @.str1570)
  br label %ret
ret:
  ret void
}

define void @fn_emit_program() {
entry:
  %t52 = alloca i32
  %t0 = call ptr @fn_buf_new()
  store ptr %t0, ptr @g_head
  %t1 = call ptr @fn_buf_new()
  store ptr %t1, ptr @g_code
  store i32 0, ptr @g_g_uses_str
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
  store ptr %t22, ptr @g_loc_mut
  %t26 = getelementptr %LSlice, ptr null, i32 1
  %t27 = ptrtoint ptr %t26 to i64
  %t28 = call ptr @malloc(i64 %t27)
  %t29 = getelementptr inbounds %LSlice, ptr %t28, i32 0, i32 0
  store ptr null, ptr %t29
  %t30 = getelementptr inbounds %LSlice, ptr %t28, i32 0, i32 1
  store i32 0, ptr %t30
  %t31 = getelementptr inbounds %LSlice, ptr %t28, i32 0, i32 2
  store i32 0, ptr %t31
  store ptr %t28, ptr @g_brk_lbl
  %t32 = getelementptr %LSlice, ptr null, i32 1
  %t33 = ptrtoint ptr %t32 to i64
  %t34 = call ptr @malloc(i64 %t33)
  %t35 = getelementptr inbounds %LSlice, ptr %t34, i32 0, i32 0
  store ptr null, ptr %t35
  %t36 = getelementptr inbounds %LSlice, ptr %t34, i32 0, i32 1
  store i32 0, ptr %t36
  %t37 = getelementptr inbounds %LSlice, ptr %t34, i32 0, i32 2
  store i32 0, ptr %t37
  store ptr %t34, ptr @g_cnt_lbl
  %t38 = getelementptr %LSlice, ptr null, i32 1
  %t39 = ptrtoint ptr %t38 to i64
  %t40 = call ptr @malloc(i64 %t39)
  %t41 = getelementptr inbounds %LSlice, ptr %t40, i32 0, i32 0
  store ptr null, ptr %t41
  %t42 = getelementptr inbounds %LSlice, ptr %t40, i32 0, i32 1
  store i32 0, ptr %t42
  %t43 = getelementptr inbounds %LSlice, ptr %t40, i32 0, i32 2
  store i32 0, ptr %t43
  store ptr %t40, ptr @g_self_stk
  %t44 = getelementptr %LSlice, ptr null, i32 1
  %t45 = ptrtoint ptr %t44 to i64
  %t46 = call ptr @malloc(i64 %t45)
  %t47 = getelementptr inbounds %LSlice, ptr %t46, i32 0, i32 0
  store ptr null, ptr %t47
  %t48 = getelementptr inbounds %LSlice, ptr %t46, i32 0, i32 1
  store i32 0, ptr %t48
  %t49 = getelementptr inbounds %LSlice, ptr %t46, i32 0, i32 2
  store i32 0, ptr %t49
  store ptr %t46, ptr @g_mach_stk
  call void @fn_emit_header()
  %t50 = call i32 @fn_has_ecs()
  %t51 = icmp ne i32 %t50, 0
  br i1 %t51, label %then0, label %ifend2
then0:
  call void @fn_emit_ecs_storage()
  br label %ifend2
ifend2:
  store i32 0, ptr %t52
  br label %wcond3
wcond3:
  %t53 = load i32, ptr %t52
  %t54 = load ptr, ptr @g_prog
  %t55 = getelementptr inbounds %LSlice, ptr %t54, i32 0, i32 1
  %t56 = load i32, ptr %t55
  %t57 = icmp slt i32 %t53, %t56
  %t58 = zext i1 %t57 to i32
  %t59 = icmp ne i32 %t58, 0
  br i1 %t59, label %wbody4, label %wend5
wbody4:
  %t60 = load ptr, ptr @g_prog
  %t61 = getelementptr inbounds %LSlice, ptr %t60, i32 0, i32 0
  %t62 = load ptr, ptr %t61
  %t63 = load i32, ptr %t52
  %t64 = getelementptr inbounds ptr, ptr %t62, i32 %t63
  %t65 = load ptr, ptr %t64
  %t66 = getelementptr inbounds %Cmp_Node, ptr %t65, i32 0, i32 0
  %t67 = load i32, ptr %t66
  %t68 = icmp eq i32 %t67, 4
  %t69 = zext i1 %t68 to i32
  %t70 = icmp ne i32 %t69, 0
  br i1 %t70, label %then6, label %ifend8
then6:
  %t71 = load ptr, ptr @g_prog
  %t72 = getelementptr inbounds %LSlice, ptr %t71, i32 0, i32 0
  %t73 = load ptr, ptr %t72
  %t74 = load i32, ptr %t52
  %t75 = getelementptr inbounds ptr, ptr %t73, i32 %t74
  %t76 = load ptr, ptr %t75
  call void @fn_emit_fn(ptr %t76)
  br label %ifend8
ifend8:
  %t77 = load i32, ptr %t52
  %t78 = add i32 %t77, 1
  store i32 %t78, ptr %t52
  br label %wcond3
wend5:
  %t79 = call i32 @fn_has_ecs()
  %t80 = icmp ne i32 %t79, 0
  br i1 %t80, label %then9, label %ifend11
then9:
  call void @fn_emit_ecs_allocator()
  call void @fn_emit_snapshot()
  br label %ifend11
ifend11:
  %t81 = call i32 @fn_has_ui()
  %t82 = icmp ne i32 %t81, 0
  br i1 %t82, label %then12, label %ifend14
then12:
  call void @fn_emit_ui_build()
  br label %ifend14
ifend14:
  %t83 = call i32 @fn_has_systems()
  %t84 = icmp ne i32 %t83, 0
  br i1 %t84, label %then15, label %else16
then15:
  call void @fn_emit_game_main()
  br label %ifend17
else16:
  store i32 0, ptr %t52
  br label %wcond18
wcond18:
  %t85 = load i32, ptr %t52
  %t86 = load ptr, ptr @g_prog
  %t87 = getelementptr inbounds %LSlice, ptr %t86, i32 0, i32 1
  %t88 = load i32, ptr %t87
  %t89 = icmp slt i32 %t85, %t88
  %t90 = zext i1 %t89 to i32
  %t91 = icmp ne i32 %t90, 0
  br i1 %t91, label %wbody19, label %wend20
wbody19:
  %t92 = load ptr, ptr @g_prog
  %t93 = getelementptr inbounds %LSlice, ptr %t92, i32 0, i32 0
  %t94 = load ptr, ptr %t93
  %t95 = load i32, ptr %t52
  %t96 = getelementptr inbounds ptr, ptr %t94, i32 %t95
  %t97 = load ptr, ptr %t96
  %t98 = getelementptr inbounds %Cmp_Node, ptr %t97, i32 0, i32 0
  %t99 = load i32, ptr %t98
  %t100 = icmp eq i32 %t99, 6
  %t101 = zext i1 %t100 to i32
  %t102 = icmp ne i32 %t101, 0
  br i1 %t102, label %then21, label %ifend23
then21:
  %t103 = load ptr, ptr @g_prog
  %t104 = getelementptr inbounds %LSlice, ptr %t103, i32 0, i32 0
  %t105 = load ptr, ptr %t104
  %t106 = load i32, ptr %t52
  %t107 = getelementptr inbounds ptr, ptr %t105, i32 %t106
  %t108 = load ptr, ptr %t107
  call void @fn_emit_main(ptr %t108)
  br label %ifend23
ifend23:
  %t109 = load i32, ptr %t52
  %t110 = add i32 %t109, 1
  store i32 %t110, ptr %t52
  br label %wcond18
wend20:
  br label %ifend17
ifend17:
  %t111 = load i32, ptr @g_g_uses_str
  %t112 = icmp ne i32 %t111, 0
  br i1 %t112, label %then24, label %ifend26
then24:
  call void @fn_emit_str_prelude()
  br label %ifend26
ifend26:
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
  %t14 = call ptr @fopen(ptr %t13, ptr @.str1571)
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
  %t12 = call i32 @fn_str_eq(ptr %t11, ptr @.str1572)
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
  %t20 = call ptr @fn_str_concat(ptr %t19, ptr @.str1573)
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
  %t103 = alloca i32
  %t112 = alloca i32
  %t129 = alloca i32
  %t146 = alloca ptr
  %t157 = alloca ptr
  %t164 = alloca ptr
  %t171 = alloca ptr
  %t176 = alloca ptr
  %t181 = alloca ptr
  %t193 = alloca i32
  %t209 = alloca i32
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
  %t11 = call i32 @fn_str_eq(ptr %t10, ptr @.str1574)
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
  %t25 = call i32 @fn_str_eq(ptr %t24, ptr @.str1575)
  %t26 = icmp ne i32 %t25, 0
  br i1 %t26, label %then6, label %else7
then6:
  store i32 1, ptr %t2
  br label %ifend8
else7:
  %t27 = load ptr, ptr %t23
  %t28 = call i32 @fn_str_eq(ptr %t27, ptr @.str1576)
  %t29 = icmp ne i32 %t28, 0
  br i1 %t29, label %then9, label %else10
then9:
  store i32 2, ptr %t2
  br label %ifend11
else10:
  %t30 = load ptr, ptr %t23
  %t31 = call i32 @fn_str_eq(ptr %t30, ptr @.str1577)
  %t32 = icmp ne i32 %t31, 0
  br i1 %t32, label %then12, label %else13
then12:
  store i32 1, ptr %t3
  br label %ifend14
else13:
  %t33 = load ptr, ptr %t23
  %t34 = call i32 @fn_str_eq(ptr %t33, ptr @.str1578)
  %t35 = icmp ne i32 %t34, 0
  br i1 %t35, label %then15, label %else16
then15:
  store i32 1, ptr %t4
  br label %ifend17
else16:
  %t36 = load ptr, ptr %t23
  %t37 = call i32 @fn_str_eq(ptr %t36, ptr @.str1579)
  %t38 = icmp ne i32 %t37, 0
  br i1 %t38, label %then18, label %else19
then18:
  store i32 1, ptr %t5
  br label %ifend20
else19:
  %t39 = load ptr, ptr %t23
  %t40 = call i32 @fn_str_eq(ptr %t39, ptr @.str1580)
  %t41 = icmp ne i32 %t40, 0
  br i1 %t41, label %then21, label %else22
then21:
  store i32 1, ptr %t6
  br label %ifend23
else22:
  %t42 = load ptr, ptr %t23
  %t43 = call i32 @fn_str_eq(ptr %t42, ptr @.str1581)
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
  %t64 = call ptr @fn_str_concat(ptr %t63, ptr @.str1583)
  %t65 = call ptr @fn_str_concat(ptr @.str1582, ptr %t64)
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
  call void @fn_die(ptr @.str1584)
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
  call void @fn_die(ptr @.str1585)
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
  %t98 = icmp ne ptr %t97, null
  %t99 = zext i1 %t98 to i32
  %t100 = icmp ne i32 %t99, 0
  %t101 = zext i1 %t100 to i32
  store i32 %t101, ptr %t93
  br label %scend43
scend43:
  %t102 = load i32, ptr %t93
  store i32 %t102, ptr %t103
  %t104 = load i32, ptr %t2
  %t105 = icmp eq i32 %t104, 1
  %t106 = zext i1 %t105 to i32
  %t107 = icmp ne i32 %t106, 0
  br i1 %t107, label %then44, label %else45
then44:
  store i32 1, ptr @g_g_windowed
  br label %ifend46
else45:
  %t108 = load i32, ptr %t2
  %t109 = icmp eq i32 %t108, 2
  %t110 = zext i1 %t109 to i32
  %t111 = icmp ne i32 %t110, 0
  br i1 %t111, label %then47, label %else48
then47:
  store i32 0, ptr @g_g_windowed
  br label %ifend49
else48:
  %t113 = load i32, ptr %t103
  %t114 = icmp ne i32 %t113, 0
  %t115 = zext i1 %t114 to i32
  store i32 %t115, ptr %t112
  br i1 %t114, label %sc50, label %scend51
sc50:
  %t116 = call i32 @fn_has_systems()
  %t117 = icmp ne i32 %t116, 0
  %t118 = zext i1 %t117 to i32
  store i32 %t118, ptr %t112
  br label %scend51
scend51:
  %t119 = load i32, ptr %t112
  store i32 %t119, ptr @g_g_windowed
  br label %ifend49
ifend49:
  br label %ifend46
ifend46:
  call void @fn_emit_program()
  %t120 = load i32, ptr %t3
  %t121 = icmp ne i32 %t120, 0
  br i1 %t121, label %then52, label %ifend54
then52:
  %t122 = load ptr, ptr %t1
  %t123 = call i32 @fn_ir_flush(ptr %t122)
  br label %ret
ifend54:
  %t124 = load i32, ptr %t103
  %t125 = icmp eq i32 %t124, 0
  %t126 = zext i1 %t125 to i32
  %t127 = icmp ne i32 %t126, 0
  br i1 %t127, label %then55, label %ifend57
then55:
  %t128 = call i32 @fn_ir_flush(ptr null)
  br label %ret
ifend57:
  %t130 = load i32, ptr %t6
  %t131 = icmp ne i32 %t130, 0
  %t132 = zext i1 %t131 to i32
  store i32 %t132, ptr %t129
  br i1 %t131, label %sc58, label %scend59
sc58:
  %t133 = load ptr, ptr %t1
  %t134 = icmp eq ptr %t133, null
  %t135 = zext i1 %t134 to i32
  %t136 = icmp ne i32 %t135, 0
  %t137 = zext i1 %t136 to i32
  store i32 %t137, ptr %t129
  br label %scend59
scend59:
  %t138 = load i32, ptr %t129
  %t139 = icmp ne i32 %t138, 0
  br i1 %t139, label %then60, label %ifend62
then60:
  %t140 = load ptr, ptr %t0
  %t141 = call ptr @fn_base_name(ptr %t140)
  %t142 = call ptr @fn_strip_ludic(ptr %t141)
  %t143 = call ptr @fn_str_concat(ptr @.str1586, ptr %t142)
  store ptr %t143, ptr %t1
  br label %ifend62
ifend62:
  %t144 = load ptr, ptr %t1
  %t145 = call ptr @fn_dir_of(ptr %t144)
  store ptr %t145, ptr %t146
  %t147 = load ptr, ptr %t146
  %t148 = call i32 @fn_slen(ptr %t147)
  %t149 = icmp sgt i32 %t148, 0
  %t150 = zext i1 %t149 to i32
  %t151 = icmp ne i32 %t150, 0
  br i1 %t151, label %then63, label %ifend65
then63:
  %t152 = load ptr, ptr %t146
  %t153 = call ptr @fn_str_concat(ptr @.str1587, ptr %t152)
  %t154 = call i32 @system(ptr %t153)
  br label %ifend65
ifend65:
  %t155 = load ptr, ptr %t1
  %t156 = call ptr @fn_str_concat(ptr %t155, ptr @.str1588)
  store ptr %t156, ptr %t157
  %t158 = load ptr, ptr %t157
  %t159 = call i32 @fn_ir_flush(ptr %t158)
  %t160 = icmp eq i32 %t159, 0
  %t161 = zext i1 %t160 to i32
  %t162 = icmp ne i32 %t161, 0
  br i1 %t162, label %then66, label %ifend68
then66:
  call void @fn_die(ptr @.str1589)
  br label %ifend68
ifend68:
  %t163 = call ptr @fn_getenv_or(ptr @.str1590, ptr @.str1591)
  store ptr %t163, ptr %t164
  %t165 = load ptr, ptr @L_argv
  %t166 = getelementptr ptr, ptr %t165, i32 0
  %t167 = load ptr, ptr %t166
  %t168 = call ptr @fn_dir_of(ptr %t167)
  %t169 = call ptr @fn_getenv_or(ptr @.str1592, ptr %t168)
  %t170 = call ptr @fn_ensure_slash(ptr %t169)
  store ptr %t170, ptr %t171
  %t172 = load ptr, ptr %t164
  %t173 = load ptr, ptr %t157
  %t174 = call ptr @fn_str_concat(ptr @.str1593, ptr %t173)
  %t175 = call ptr @fn_str_concat(ptr %t172, ptr %t174)
  store ptr %t175, ptr %t176
  %t177 = load i32, ptr @g_g_windowed
  %t178 = icmp ne i32 %t177, 0
  br i1 %t178, label %then69, label %ifend71
then69:
  %t179 = load ptr, ptr %t171
  %t180 = call ptr @fn_path_join(ptr %t179, ptr @.str1594)
  store ptr %t180, ptr %t181
  %t182 = load ptr, ptr %t176
  %t183 = load ptr, ptr %t181
  %t184 = call ptr @fn_str_concat(ptr %t183, ptr @.str1596)
  %t185 = call ptr @fn_str_concat(ptr @.str1595, ptr %t184)
  %t186 = call ptr @fn_str_concat(ptr %t182, ptr %t185)
  store ptr %t186, ptr %t176
  br label %ifend71
ifend71:
  %t187 = load ptr, ptr %t176
  %t188 = load ptr, ptr %t1
  %t189 = call ptr @fn_str_concat(ptr @.str1597, ptr %t188)
  %t190 = call ptr @fn_str_concat(ptr %t187, ptr %t189)
  store ptr %t190, ptr %t176
  %t191 = load ptr, ptr %t176
  %t192 = call i32 @system(ptr %t191)
  store i32 %t192, ptr %t193
  %t194 = load i32, ptr %t5
  %t195 = icmp eq i32 %t194, 0
  %t196 = zext i1 %t195 to i32
  %t197 = icmp ne i32 %t196, 0
  br i1 %t197, label %then72, label %ifend74
then72:
  %t198 = load ptr, ptr %t157
  %t199 = call ptr @fn_str_concat(ptr @.str1598, ptr %t198)
  %t200 = call i32 @system(ptr %t199)
  br label %ifend74
ifend74:
  %t201 = load i32, ptr %t193
  %t202 = icmp ne i32 %t201, 0
  %t203 = zext i1 %t202 to i32
  %t204 = icmp ne i32 %t203, 0
  br i1 %t204, label %then75, label %ifend77
then75:
  call void @fn_die(ptr @.str1599)
  br label %ifend77
ifend77:
  %t205 = load i32, ptr %t6
  %t206 = icmp ne i32 %t205, 0
  br i1 %t206, label %then78, label %ifend80
then78:
  %t207 = load ptr, ptr %t1
  %t208 = call i32 @system(ptr %t207)
  store i32 %t208, ptr %t209
  %t210 = load i32, ptr %t209
  %t211 = lshr i32 %t210, 8
  %t212 = and i32 %t211, 255
  call void @exit(i32 %t212)
  unreachable
ifend80:
  br label %ret
ret:
  %t213 = load i32, ptr %retval
  ret i32 %t213
}
