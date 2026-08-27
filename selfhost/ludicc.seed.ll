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
@__stdoutp = external global ptr
@.fmt_int = private unnamed_addr constant [4 x i8] c"%d\0A\00"
@.fmt_line = private unnamed_addr constant [4 x i8] c"%s\0A\00"
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
@g_g_uses_intstr = internal global i32 0
@g_g_uses_strslice = internal global i32 0
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
@.str10 = private unnamed_addr constant [2 x i8] c"+\00"
@.str11 = private unnamed_addr constant [4 x i8] c"str\00"
@.str12 = private unnamed_addr constant [5 x i8] c"true\00"
@.str13 = private unnamed_addr constant [6 x i8] c"false\00"
@.str14 = private unnamed_addr constant [5 x i8] c"null\00"
@.str15 = private unnamed_addr constant [4 x i8] c"new\00"
@.str16 = private unnamed_addr constant [2 x i8] c"(\00"
@.str17 = private unnamed_addr constant [2 x i8] c")\00"
@.str18 = private unnamed_addr constant [20 x i8] c"expected expression\00"
@.str19 = private unnamed_addr constant [2 x i8] c".\00"
@.str20 = private unnamed_addr constant [2 x i8] c"[\00"
@.str21 = private unnamed_addr constant [3 x i8] c"..\00"
@.str22 = private unnamed_addr constant [2 x i8] c"]\00"
@.str23 = private unnamed_addr constant [2 x i8] c"]\00"
@.str24 = private unnamed_addr constant [2 x i8] c"(\00"
@.str25 = private unnamed_addr constant [2 x i8] c"-\00"
@.str26 = private unnamed_addr constant [2 x i8] c"-\00"
@.str27 = private unnamed_addr constant [2 x i8] c"~\00"
@.str28 = private unnamed_addr constant [2 x i8] c"~\00"
@.str29 = private unnamed_addr constant [4 x i8] c"not\00"
@.str30 = private unnamed_addr constant [4 x i8] c"not\00"
@.str31 = private unnamed_addr constant [2 x i8] c"*\00"
@.str32 = private unnamed_addr constant [2 x i8] c"/\00"
@.str33 = private unnamed_addr constant [2 x i8] c"%\00"
@.str34 = private unnamed_addr constant [3 x i8] c"<<\00"
@.str35 = private unnamed_addr constant [3 x i8] c">>\00"
@.str36 = private unnamed_addr constant [2 x i8] c"&\00"
@.str37 = private unnamed_addr constant [2 x i8] c"+\00"
@.str38 = private unnamed_addr constant [2 x i8] c"-\00"
@.str39 = private unnamed_addr constant [2 x i8] c"|\00"
@.str40 = private unnamed_addr constant [2 x i8] c"^\00"
@.str41 = private unnamed_addr constant [2 x i8] c"<\00"
@.str42 = private unnamed_addr constant [3 x i8] c"<=\00"
@.str43 = private unnamed_addr constant [2 x i8] c">\00"
@.str44 = private unnamed_addr constant [3 x i8] c">=\00"
@.str45 = private unnamed_addr constant [3 x i8] c"==\00"
@.str46 = private unnamed_addr constant [3 x i8] c"!=\00"
@.str47 = private unnamed_addr constant [4 x i8] c"and\00"
@.str48 = private unnamed_addr constant [4 x i8] c"and\00"
@.str49 = private unnamed_addr constant [3 x i8] c"or\00"
@.str50 = private unnamed_addr constant [3 x i8] c"or\00"
@.str51 = private unnamed_addr constant [2 x i8] c"{\00"
@.str52 = private unnamed_addr constant [2 x i8] c"}\00"
@.str53 = private unnamed_addr constant [2 x i8] c":\00"
@.str54 = private unnamed_addr constant [2 x i8] c",\00"
@.str55 = private unnamed_addr constant [2 x i8] c"}\00"
@.str56 = private unnamed_addr constant [2 x i8] c"{\00"
@.str57 = private unnamed_addr constant [2 x i8] c"}\00"
@.str58 = private unnamed_addr constant [2 x i8] c"}\00"
@.str59 = private unnamed_addr constant [43 x i8] c"expected newline or ';' between statements\00"
@.str60 = private unnamed_addr constant [2 x i8] c"}\00"
@.str61 = private unnamed_addr constant [4 x i8] c"let\00"
@.str62 = private unnamed_addr constant [4 x i8] c"var\00"
@.str63 = private unnamed_addr constant [4 x i8] c"var\00"
@.str64 = private unnamed_addr constant [2 x i8] c":\00"
@.str65 = private unnamed_addr constant [2 x i8] c"=\00"
@.str66 = private unnamed_addr constant [7 x i8] c"return\00"
@.str67 = private unnamed_addr constant [2 x i8] c"}\00"
@.str68 = private unnamed_addr constant [3 x i8] c"if\00"
@.str69 = private unnamed_addr constant [5 x i8] c"else\00"
@.str70 = private unnamed_addr constant [3 x i8] c"if\00"
@.str71 = private unnamed_addr constant [6 x i8] c"while\00"
@.str72 = private unnamed_addr constant [4 x i8] c"for\00"
@.str73 = private unnamed_addr constant [2 x i8] c"(\00"
@.str74 = private unnamed_addr constant [3 x i8] c"..\00"
@.str75 = private unnamed_addr constant [6 x i8] c"spawn\00"
@.str76 = private unnamed_addr constant [8 x i8] c"machine\00"
@.str77 = private unnamed_addr constant [2 x i8] c"{\00"
@.str78 = private unnamed_addr constant [2 x i8] c"}\00"
@.str79 = private unnamed_addr constant [2 x i8] c"=\00"
@.str80 = private unnamed_addr constant [2 x i8] c"}\00"
@.str81 = private unnamed_addr constant [7 x i8] c"become\00"
@.str82 = private unnamed_addr constant [8 x i8] c"despawn\00"
@.str83 = private unnamed_addr constant [7 x i8] c"enable\00"
@.str84 = private unnamed_addr constant [8 x i8] c"disable\00"
@.str85 = private unnamed_addr constant [7 x i8] c"enable\00"
@.str86 = private unnamed_addr constant [3 x i8] c"on\00"
@.str87 = private unnamed_addr constant [6 x i8] c"break\00"
@.str88 = private unnamed_addr constant [9 x i8] c"continue\00"
@.str89 = private unnamed_addr constant [6 x i8] c"match\00"
@.str90 = private unnamed_addr constant [2 x i8] c"{\00"
@.str91 = private unnamed_addr constant [2 x i8] c"}\00"
@.str92 = private unnamed_addr constant [2 x i8] c",\00"
@.str93 = private unnamed_addr constant [3 x i8] c"=>\00"
@.str94 = private unnamed_addr constant [2 x i8] c"{\00"
@.str95 = private unnamed_addr constant [2 x i8] c"}\00"
@.str96 = private unnamed_addr constant [2 x i8] c"=\00"
@.str97 = private unnamed_addr constant [3 x i8] c"+=\00"
@.str98 = private unnamed_addr constant [3 x i8] c"-=\00"
@.str99 = private unnamed_addr constant [3 x i8] c"*=\00"
@.str100 = private unnamed_addr constant [3 x i8] c"/=\00"
@.str101 = private unnamed_addr constant [2 x i8] c":\00"
@.str102 = private unnamed_addr constant [2 x i8] c"=\00"
@.str103 = private unnamed_addr constant [2 x i8] c":\00"
@.str104 = private unnamed_addr constant [2 x i8] c"=\00"
@.str105 = private unnamed_addr constant [2 x i8] c"(\00"
@.str106 = private unnamed_addr constant [2 x i8] c")\00"
@.str107 = private unnamed_addr constant [2 x i8] c":\00"
@.str108 = private unnamed_addr constant [2 x i8] c",\00"
@.str109 = private unnamed_addr constant [2 x i8] c")\00"
@.str110 = private unnamed_addr constant [5 x i8] c"void\00"
@.str111 = private unnamed_addr constant [3 x i8] c"->\00"
@.str112 = private unnamed_addr constant [1 x i8] c"\00"
@.str113 = private unnamed_addr constant [2 x i8] c"@\00"
@.str114 = private unnamed_addr constant [7 x i8] c"export\00"
@.str115 = private unnamed_addr constant [8 x i8] c"Queries\00"
@.str116 = private unnamed_addr constant [8 x i8] c"OnSpawn\00"
@.str117 = private unnamed_addr constant [2 x i8] c"(\00"
@.str118 = private unnamed_addr constant [2 x i8] c")\00"
@.str119 = private unnamed_addr constant [10 x i8] c"OnDespawn\00"
@.str120 = private unnamed_addr constant [2 x i8] c"(\00"
@.str121 = private unnamed_addr constant [2 x i8] c")\00"
@.str122 = private unnamed_addr constant [9 x i8] c"OnAttach\00"
@.str123 = private unnamed_addr constant [2 x i8] c"(\00"
@.str124 = private unnamed_addr constant [2 x i8] c")\00"
@.str125 = private unnamed_addr constant [9 x i8] c"OnEnable\00"
@.str126 = private unnamed_addr constant [2 x i8] c"(\00"
@.str127 = private unnamed_addr constant [2 x i8] c")\00"
@.str128 = private unnamed_addr constant [10 x i8] c"OnDisable\00"
@.str129 = private unnamed_addr constant [2 x i8] c"(\00"
@.str130 = private unnamed_addr constant [2 x i8] c")\00"
@.str131 = private unnamed_addr constant [8 x i8] c"OnStart\00"
@.str132 = private unnamed_addr constant [6 x i8] c"Start\00"
@.str133 = private unnamed_addr constant [7 x i8] c"OnQuit\00"
@.str134 = private unnamed_addr constant [7 x i8] c"OnQuit\00"
@.str135 = private unnamed_addr constant [2 x i8] c"(\00"
@.str136 = private unnamed_addr constant [2 x i8] c"(\00"
@.str137 = private unnamed_addr constant [2 x i8] c")\00"
@.str138 = private unnamed_addr constant [7 x i8] c"import\00"
@.str139 = private unnamed_addr constant [29 x i8] c"expected \22path\22 after import\00"
@.str140 = private unnamed_addr constant [5 x i8] c"enum\00"
@.str141 = private unnamed_addr constant [9 x i8] c"property\00"
@.str142 = private unnamed_addr constant [6 x i8] c"model\00"
@.str143 = private unnamed_addr constant [8 x i8] c"handler\00"
@.str144 = private unnamed_addr constant [3 x i8] c"ui\00"
@.str145 = private unnamed_addr constant [4 x i8] c"var\00"
@.str146 = private unnamed_addr constant [6 x i8] c"const\00"
@.str147 = private unnamed_addr constant [3 x i8] c"fn\00"
@.str148 = private unnamed_addr constant [7 x i8] c"extern\00"
@.str149 = private unnamed_addr constant [6 x i8] c"entry\00"
@.str150 = private unnamed_addr constant [21 x i8] c"expected declaration\00"
@.str151 = private unnamed_addr constant [20 x i8] c"cannot open import \00"
@.str152 = private unnamed_addr constant [1 x i8] c"\00"
@.str153 = private unnamed_addr constant [26 x i8] c"runtime/native/core.ludic\00"
@.str154 = private unnamed_addr constant [6 x i8] c"Ludic\00"
@.str155 = private unnamed_addr constant [7 x i8] c"import\00"
@.str156 = private unnamed_addr constant [2 x i8] c"@\00"
@.str157 = private unnamed_addr constant [2 x i8] c"(\00"
@.str158 = private unnamed_addr constant [2 x i8] c"(\00"
@.str159 = private unnamed_addr constant [2 x i8] c")\00"
@.str160 = private unnamed_addr constant [8 x i8] c"program\00"
@.str161 = private unnamed_addr constant [2 x i8] c"{\00"
@.str162 = private unnamed_addr constant [2 x i8] c"}\00"
@.str163 = private unnamed_addr constant [2 x i8] c"{\00"
@.str164 = private unnamed_addr constant [2 x i8] c"}\00"
@.str165 = private unnamed_addr constant [2 x i8] c"@\00"
@.str166 = private unnamed_addr constant [9 x i8] c"Computed\00"
@.str167 = private unnamed_addr constant [2 x i8] c":\00"
@.str168 = private unnamed_addr constant [2 x i8] c"=\00"
@.str169 = private unnamed_addr constant [2 x i8] c",\00"
@.str170 = private unnamed_addr constant [2 x i8] c"}\00"
@.str171 = private unnamed_addr constant [7 x i8] c"Update\00"
@.str172 = private unnamed_addr constant [2 x i8] c"@\00"
@.str173 = private unnamed_addr constant [2 x i8] c"(\00"
@.str174 = private unnamed_addr constant [2 x i8] c"(\00"
@.str175 = private unnamed_addr constant [2 x i8] c")\00"
@.str176 = private unnamed_addr constant [6 x i8] c"phase\00"
@.str177 = private unnamed_addr constant [2 x i8] c"[\00"
@.str178 = private unnamed_addr constant [2 x i8] c"]\00"
@.str179 = private unnamed_addr constant [2 x i8] c"{\00"
@.str180 = private unnamed_addr constant [2 x i8] c"}\00"
@.str181 = private unnamed_addr constant [2 x i8] c",\00"
@.str182 = private unnamed_addr constant [2 x i8] c"]\00"
@.str183 = private unnamed_addr constant [6 x i8] c"where\00"
@.str184 = private unnamed_addr constant [2 x i8] c"(\00"
@.str185 = private unnamed_addr constant [2 x i8] c")\00"
@.str186 = private unnamed_addr constant [2 x i8] c",\00"
@.str187 = private unnamed_addr constant [2 x i8] c")\00"
@.str188 = private unnamed_addr constant [6 x i8] c"query\00"
@.str189 = private unnamed_addr constant [29 x i8] c"expected 'query' in for-loop\00"
@.str190 = private unnamed_addr constant [4 x i8] c"and\00"
@.str191 = private unnamed_addr constant [2 x i8] c"(\00"
@.str192 = private unnamed_addr constant [2 x i8] c")\00"
@.str193 = private unnamed_addr constant [2 x i8] c")\00"
@.str194 = private unnamed_addr constant [2 x i8] c":\00"
@.str195 = private unnamed_addr constant [6 x i8] c"these\00"
@.str196 = private unnamed_addr constant [2 x i8] c"[\00"
@.str197 = private unnamed_addr constant [2 x i8] c"]\00"
@.str198 = private unnamed_addr constant [2 x i8] c"{\00"
@.str199 = private unnamed_addr constant [2 x i8] c"}\00"
@.str200 = private unnamed_addr constant [2 x i8] c",\00"
@.str201 = private unnamed_addr constant [2 x i8] c"]\00"
@.str202 = private unnamed_addr constant [3 x i8] c"on\00"
@.str203 = private unnamed_addr constant [2 x i8] c",\00"
@.str204 = private unnamed_addr constant [2 x i8] c")\00"
@.str205 = private unnamed_addr constant [2 x i8] c"{\00"
@.str206 = private unnamed_addr constant [2 x i8] c"}\00"
@.str207 = private unnamed_addr constant [2 x i8] c",\00"
@.str208 = private unnamed_addr constant [2 x i8] c"}\00"
@.str209 = private unnamed_addr constant [2 x i8] c"{\00"
@.str210 = private unnamed_addr constant [2 x i8] c"}\00"
@.str211 = private unnamed_addr constant [2 x i8] c",\00"
@.str212 = private unnamed_addr constant [2 x i8] c"}\00"
@.str213 = private unnamed_addr constant [2 x i8] c"{\00"
@.str214 = private unnamed_addr constant [2 x i8] c"}\00"
@.str215 = private unnamed_addr constant [2 x i8] c",\00"
@.str216 = private unnamed_addr constant [2 x i8] c"}\00"
@.str217 = private unnamed_addr constant [2 x i8] c"(\00"
@.str218 = private unnamed_addr constant [2 x i8] c")\00"
@.str219 = private unnamed_addr constant [2 x i8] c":\00"
@.str220 = private unnamed_addr constant [2 x i8] c",\00"
@.str221 = private unnamed_addr constant [2 x i8] c")\00"
@.str222 = private unnamed_addr constant [5 x i8] c"void\00"
@.str223 = private unnamed_addr constant [3 x i8] c"->\00"
@.str224 = private unnamed_addr constant [2 x i8] c"=\00"
@.str225 = private unnamed_addr constant [2 x i8] c":\00"
@.str226 = private unnamed_addr constant [2 x i8] c":\00"
@.str227 = private unnamed_addr constant [2 x i8] c"{\00"
@.str228 = private unnamed_addr constant [2 x i8] c"}\00"
@.str229 = private unnamed_addr constant [2 x i8] c"}\00"
@.str230 = private unnamed_addr constant [2 x i8] c"{\00"
@.str231 = private unnamed_addr constant [2 x i8] c"}\00"
@.str232 = private unnamed_addr constant [3 x i8] c"%t\00"
@.str233 = private unnamed_addr constant [3 x i8] c"  \00"
@.str234 = private unnamed_addr constant [11 x i8] c" = alloca \00"
@.str235 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str236 = private unnamed_addr constant [3 x i8] c"%t\00"
@.str237 = private unnamed_addr constant [4 x i8] c"int\00"
@.str238 = private unnamed_addr constant [5 x i8] c"bool\00"
@.str239 = private unnamed_addr constant [6 x i8] c"fixed\00"
@.str240 = private unnamed_addr constant [4 x i8] c"i32\00"
@.str241 = private unnamed_addr constant [5 x i8] c"byte\00"
@.str242 = private unnamed_addr constant [3 x i8] c"i8\00"
@.str243 = private unnamed_addr constant [6 x i8] c"words\00"
@.str244 = private unnamed_addr constant [7 x i8] c"fixeds\00"
@.str245 = private unnamed_addr constant [5 x i8] c"ptrs\00"
@.str246 = private unnamed_addr constant [4 x i8] c"ptr\00"
@.str247 = private unnamed_addr constant [5 x i8] c"void\00"
@.str248 = private unnamed_addr constant [5 x i8] c"void\00"
@.str249 = private unnamed_addr constant [4 x i8] c"ptr\00"
@.str250 = private unnamed_addr constant [6 x i8] c"%Cmp_\00"
@.str251 = private unnamed_addr constant [4 x i8] c"int\00"
@.str252 = private unnamed_addr constant [2 x i8] c".\00"
@.str253 = private unnamed_addr constant [2 x i8] c".\00"
@.str254 = private unnamed_addr constant [6 x i8] c"@.str\00"
@.str255 = private unnamed_addr constant [35 x i8] c" = private unnamed_addr constant [\00"
@.str256 = private unnamed_addr constant [10 x i8] c" x i8] c\22\00"
@.str257 = private unnamed_addr constant [6 x i8] c"\5C00\22\0A\00"
@.str258 = private unnamed_addr constant [4 x i8] c"ptr\00"
@.str259 = private unnamed_addr constant [5 x i8] c"null\00"
@.str260 = private unnamed_addr constant [2 x i8] c"0\00"
@.str261 = private unnamed_addr constant [2 x i8] c"-\00"
@.str262 = private unnamed_addr constant [2 x i8] c"-\00"
@.str263 = private unnamed_addr constant [4 x i8] c"ptr\00"
@.str264 = private unnamed_addr constant [5 x i8] c"null\00"
@.str265 = private unnamed_addr constant [2 x i8] c"0\00"
@.str266 = private unnamed_addr constant [34 x i8] c"; Ludic (self-hosted) -> LLVM IR\0A\00"
@.str267 = private unnamed_addr constant [31 x i8] c"declare i32 @printf(ptr, ...)\0A\00"
@.str268 = private unnamed_addr constant [26 x i8] c"declare ptr @malloc(i64)\0A\00"
@.str269 = private unnamed_addr constant [32 x i8] c"declare ptr @realloc(ptr, i64)\0A\00"
@.str270 = private unnamed_addr constant [25 x i8] c"declare void @free(ptr)\0A\00"
@.str271 = private unnamed_addr constant [30 x i8] c"declare ptr @fopen(ptr, ptr)\0A\00"
@.str272 = private unnamed_addr constant [40 x i8] c"declare i64 @fread(ptr, i64, i64, ptr)\0A\00"
@.str273 = private unnamed_addr constant [41 x i8] c"declare i64 @fwrite(ptr, i64, i64, ptr)\0A\00"
@.str274 = private unnamed_addr constant [35 x i8] c"declare i32 @fseek(ptr, i64, i32)\0A\00"
@.str275 = private unnamed_addr constant [25 x i8] c"declare i64 @ftell(ptr)\0A\00"
@.str276 = private unnamed_addr constant [26 x i8] c"declare i32 @fclose(ptr)\0A\00"
@.str277 = private unnamed_addr constant [25 x i8] c"declare void @exit(i32)\0A\00"
@.str278 = private unnamed_addr constant [26 x i8] c"declare i32 @system(ptr)\0A\00"
@.str279 = private unnamed_addr constant [26 x i8] c"declare ptr @getenv(ptr)\0A\00"
@.str280 = private unnamed_addr constant [36 x i8] c"declare ptr @memcpy(ptr, ptr, i64)\0A\00"
@.str281 = private unnamed_addr constant [36 x i8] c"declare ptr @memset(ptr, i32, i64)\0A\00"
@.str282 = private unnamed_addr constant [26 x i8] c"declare i64 @strlen(ptr)\0A\00"
@.str283 = private unnamed_addr constant [24 x i8] c"declare i32 @getchar()\0A\00"
@.str284 = private unnamed_addr constant [27 x i8] c"declare i32 @putchar(i32)\0A\00"
@.str285 = private unnamed_addr constant [24 x i8] c"declare i64 @time(ptr)\0A\00"
@.str286 = private unnamed_addr constant [44 x i8] c"declare void @win_open(i32, i32, i32, ptr)\0A\00"
@.str287 = private unnamed_addr constant [25 x i8] c"declare i32 @win_poll()\0A\00"
@.str288 = private unnamed_addr constant [42 x i8] c"declare void @win_present(ptr, i32, i32)\0A\00"
@.str289 = private unnamed_addr constant [28 x i8] c"declare i32 @win_running()\0A\00"
@.str290 = private unnamed_addr constant [27 x i8] c"declare void @win_close()\0A\00"
@.str291 = private unnamed_addr constant [34 x i8] c"@__stderrp = external global ptr\0A\00"
@.str292 = private unnamed_addr constant [34 x i8] c"@__stdoutp = external global ptr\0A\00"
@.str293 = private unnamed_addr constant [64 x i8] c"@.fmt_int = private unnamed_addr constant [4 x i8] c\22%d\5C0A\5C00\22\0A\00"
@.str294 = private unnamed_addr constant [65 x i8] c"@.fmt_line = private unnamed_addr constant [4 x i8] c\22%s\5C0A\5C00\22\0A\00"
@.str295 = private unnamed_addr constant [33 x i8] c"@L_argc = internal global i32 0\0A\00"
@.str296 = private unnamed_addr constant [36 x i8] c"@L_argv = internal global ptr null\0A\00"
@.str297 = private unnamed_addr constant [46 x i8] c"@.gametitle = private unnamed_addr constant [\00"
@.str298 = private unnamed_addr constant [10 x i8] c" x i8] c\22\00"
@.str299 = private unnamed_addr constant [6 x i8] c"\5C00\22\0A\00"
@.str300 = private unnamed_addr constant [34 x i8] c"%LSlice = type { ptr, i32, i32 }\0A\00"
@.str301 = private unnamed_addr constant [11 x i8] c" = type { \00"
@.str302 = private unnamed_addr constant [4 x i8] c"i32\00"
@.str303 = private unnamed_addr constant [3 x i8] c", \00"
@.str304 = private unnamed_addr constant [4 x i8] c" }\0A\00"
@.str305 = private unnamed_addr constant [4 x i8] c"@g_\00"
@.str306 = private unnamed_addr constant [20 x i8] c" = internal global \00"
@.str307 = private unnamed_addr constant [2 x i8] c" \00"
@.str308 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str309 = private unnamed_addr constant [41 x i8] c"define i32 @fn_str_eq(ptr %a, ptr %b) {\0A\00"
@.str310 = private unnamed_addr constant [25 x i8] c"entry:\0A  br label %loop\0A\00"
@.str311 = private unnamed_addr constant [52 x i8] c"loop:\0A  %i = phi i32 [ 0, %entry ], [ %i1, %cont ]\0A\00"
@.str312 = private unnamed_addr constant [51 x i8] c"  %pa = getelementptr inbounds i8, ptr %a, i32 %i\0A\00"
@.str313 = private unnamed_addr constant [51 x i8] c"  %pb = getelementptr inbounds i8, ptr %b, i32 %i\0A\00"
@.str314 = private unnamed_addr constant [51 x i8] c"  %ca = load i8, ptr %pa\0A  %cb = load i8, ptr %pb\0A\00"
@.str315 = private unnamed_addr constant [66 x i8] c"  %df = icmp ne i8 %ca, %cb\0A  br i1 %df, label %ret0, label %chk\0A\00"
@.str316 = private unnamed_addr constant [70 x i8] c"chk:\0A  %zt = icmp eq i8 %ca, 0\0A  br i1 %zt, label %ret1, label %cont\0A\00"
@.str317 = private unnamed_addr constant [46 x i8] c"cont:\0A  %i1 = add i32 %i, 1\0A  br label %loop\0A\00"
@.str318 = private unnamed_addr constant [39 x i8] c"ret1:\0A  ret i32 1\0Aret0:\0A  ret i32 0\0A}\0A\00"
@.str319 = private unnamed_addr constant [45 x i8] c"define ptr @fn_str_concat(ptr %a, ptr %b) {\0A\00"
@.str320 = private unnamed_addr constant [23 x i8] c"entry:\0A  br label %al\0A\00"
@.str321 = private unnamed_addr constant [51 x i8] c"al:\0A  %ia = phi i32 [ 0, %entry ], [ %ia1, %alb ]\0A\00"
@.str322 = private unnamed_addr constant [78 x i8] c"  %pa = getelementptr inbounds i8, ptr %a, i32 %ia\0A  %cca = load i8, ptr %pa\0A\00"
@.str323 = private unnamed_addr constant [64 x i8] c"  %za = icmp eq i8 %cca, 0\0A  br i1 %za, label %bl0, label %alb\0A\00"
@.str324 = private unnamed_addr constant [45 x i8] c"alb:\0A  %ia1 = add i32 %ia, 1\0A  br label %al\0A\00"
@.str325 = private unnamed_addr constant [21 x i8] c"bl0:\0A  br label %bl\0A\00"
@.str326 = private unnamed_addr constant [49 x i8] c"bl:\0A  %ib = phi i32 [ 0, %bl0 ], [ %ib1, %blb ]\0A\00"
@.str327 = private unnamed_addr constant [78 x i8] c"  %pb = getelementptr inbounds i8, ptr %b, i32 %ib\0A  %ccb = load i8, ptr %pb\0A\00"
@.str328 = private unnamed_addr constant [66 x i8] c"  %zb = icmp eq i8 %ccb, 0\0A  br i1 %zb, label %alloc, label %blb\0A\00"
@.str329 = private unnamed_addr constant [45 x i8] c"blb:\0A  %ib1 = add i32 %ib, 1\0A  br label %bl\0A\00"
@.str330 = private unnamed_addr constant [58 x i8] c"alloc:\0A  %sum = add i32 %ia, %ib\0A  %sz = add i32 %sum, 1\0A\00"
@.str331 = private unnamed_addr constant [83 x i8] c"  %sz64 = sext i32 %sz to i64\0A  %out = call ptr @malloc(i64 %sz64)\0A  br label %c1\0A\00"
@.str332 = private unnamed_addr constant [49 x i8] c"c1:\0A  %i = phi i32 [ 0, %alloc ], [ %i1, %c1b ]\0A\00"
@.str333 = private unnamed_addr constant [66 x i8] c"  %d1 = icmp slt i32 %i, %ia\0A  br i1 %d1, label %c1b, label %c2i\0A\00"
@.str334 = private unnamed_addr constant [81 x i8] c"c1b:\0A  %s1 = getelementptr inbounds i8, ptr %a, i32 %i\0A  %v1 = load i8, ptr %s1\0A\00"
@.str335 = private unnamed_addr constant [77 x i8] c"  %o1 = getelementptr inbounds i8, ptr %out, i32 %i\0A  store i8 %v1, ptr %o1\0A\00"
@.str336 = private unnamed_addr constant [38 x i8] c"  %i1 = add i32 %i, 1\0A  br label %c1\0A\00"
@.str337 = private unnamed_addr constant [21 x i8] c"c2i:\0A  br label %c2\0A\00"
@.str338 = private unnamed_addr constant [47 x i8] c"c2:\0A  %j = phi i32 [ 0, %c2i ], [ %j1, %c2b ]\0A\00"
@.str339 = private unnamed_addr constant [66 x i8] c"  %d2 = icmp slt i32 %j, %ib\0A  br i1 %d2, label %c2b, label %fin\0A\00"
@.str340 = private unnamed_addr constant [81 x i8] c"c2b:\0A  %s2 = getelementptr inbounds i8, ptr %b, i32 %j\0A  %v2 = load i8, ptr %s2\0A\00"
@.str341 = private unnamed_addr constant [102 x i8] c"  %oj = add i32 %ia, %j\0A  %o2 = getelementptr inbounds i8, ptr %out, i32 %oj\0A  store i8 %v2, ptr %o2\0A\00"
@.str342 = private unnamed_addr constant [38 x i8] c"  %j1 = add i32 %j, 1\0A  br label %c2\0A\00"
@.str343 = private unnamed_addr constant [99 x i8] c"fin:\0A  %pe = getelementptr inbounds i8, ptr %out, i32 %sum\0A  store i8 0, ptr %pe\0A  ret ptr %out\0A}\0A\00"
@.str344 = private unnamed_addr constant [35 x i8] c"define ptr @fn_int_str(i32 %n0) {\0A\00"
@.str345 = private unnamed_addr constant [42 x i8] c"entry:\0A  %buf = call ptr @malloc(i64 24)\0A\00"
@.str346 = private unnamed_addr constant [56 x i8] c"  %isneg = icmp slt i32 %n0, 0\0A  %neg = sub i32 0, %n0\0A\00"
@.str347 = private unnamed_addr constant [44 x i8] c"  %n = select i1 %isneg, i32 %neg, i32 %n0\0A\00"
@.str348 = private unnamed_addr constant [79 x i8] c"  %term = getelementptr inbounds i8, ptr %buf, i32 23\0A  store i8 0, ptr %term\0A\00"
@.str349 = private unnamed_addr constant [70 x i8] c"  %iszero = icmp eq i32 %n0, 0\0A  br i1 %iszero, label %zc, label %dl\0A\00"
@.str350 = private unnamed_addr constant [94 x i8] c"zc:\0A  %zp = getelementptr inbounds i8, ptr %buf, i32 22\0A  store i8 48, ptr %zp\0A  ret ptr %zp\0A\00"
@.str351 = private unnamed_addr constant [23 x i8] c"dl:\0A  br label %dloop\0A\00"
@.str352 = private unnamed_addr constant [104 x i8] c"dloop:\0A  %pos = phi i32 [ 22, %dl ], [ %pos2, %dbody ]\0A  %cur = phi i32 [ %n, %dl ], [ %cur2, %dbody ]\0A\00"
@.str353 = private unnamed_addr constant [72 x i8] c"  %done = icmp eq i32 %cur, 0\0A  br i1 %done, label %sign, label %dbody\0A\00"
@.str354 = private unnamed_addr constant [85 x i8] c"dbody:\0A  %d = urem i32 %cur, 10\0A  %ch = add i32 %d, 48\0A  %ch8 = trunc i32 %ch to i8\0A\00"
@.str355 = private unnamed_addr constant [80 x i8] c"  %pp = getelementptr inbounds i8, ptr %buf, i32 %pos\0A  store i8 %ch8, ptr %pp\0A\00"
@.str356 = private unnamed_addr constant [73 x i8] c"  %cur2 = udiv i32 %cur, 10\0A  %pos2 = sub i32 %pos, 1\0A  br label %dloop\0A\00"
@.str357 = private unnamed_addr constant [49 x i8] c"sign:\0A  br i1 %isneg, label %addneg, label %fin\0A\00"
@.str358 = private unnamed_addr constant [128 x i8] c"addneg:\0A  %sp = getelementptr inbounds i8, ptr %buf, i32 %pos\0A  store i8 45, ptr %sp\0A  %posn = sub i32 %pos, 1\0A  br label %fin\0A\00"
@.str359 = private unnamed_addr constant [60 x i8] c"fin:\0A  %fpos = phi i32 [ %pos, %sign ], [ %posn, %addneg ]\0A\00"
@.str360 = private unnamed_addr constant [101 x i8] c"  %rpos = add i32 %fpos, 1\0A  %res = getelementptr inbounds i8, ptr %buf, i32 %rpos\0A  ret ptr %res\0A}\0A\00"
@.str361 = private unnamed_addr constant [58 x i8] c"define ptr @fn_str_slice(ptr %s, i32 %start, i32 %end) {\0A\00"
@.str362 = private unnamed_addr constant [62 x i8] c"entry:\0A  %len = sub i32 %end, %start\0A  %sz = add i32 %len, 1\0A\00"
@.str363 = private unnamed_addr constant [85 x i8] c"  %sz64 = sext i32 %sz to i64\0A  %out = call ptr @malloc(i64 %sz64)\0A  br label %loop\0A\00"
@.str364 = private unnamed_addr constant [52 x i8] c"loop:\0A  %i = phi i32 [ 0, %entry ], [ %i1, %body ]\0A\00"
@.str365 = private unnamed_addr constant [66 x i8] c"  %d = icmp slt i32 %i, %len\0A  br i1 %d, label %body, label %fin\0A\00"
@.str366 = private unnamed_addr constant [109 x i8] c"body:\0A  %si = add i32 %start, %i\0A  %sp = getelementptr inbounds i8, ptr %s, i32 %si\0A  %c = load i8, ptr %sp\0A\00"
@.str367 = private unnamed_addr constant [115 x i8] c"  %op = getelementptr inbounds i8, ptr %out, i32 %i\0A  store i8 %c, ptr %op\0A  %i1 = add i32 %i, 1\0A  br label %loop\0A\00"
@.str368 = private unnamed_addr constant [99 x i8] c"fin:\0A  %tp = getelementptr inbounds i8, ptr %out, i32 %len\0A  store i8 0, ptr %tp\0A  ret ptr %out\0A}\0A\00"
@.str369 = private unnamed_addr constant [32 x i8] c"member access on non-aggregate \00"
@.str370 = private unnamed_addr constant [15 x i8] c"no such field \00"
@.str371 = private unnamed_addr constant [3 x i8] c"  \00"
@.str372 = private unnamed_addr constant [27 x i8] c" = getelementptr inbounds \00"
@.str373 = private unnamed_addr constant [7 x i8] c", ptr \00"
@.str374 = private unnamed_addr constant [14 x i8] c", i32 0, i32 \00"
@.str375 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str376 = private unnamed_addr constant [6 x i8] c"words\00"
@.str377 = private unnamed_addr constant [33 x i8] c"getelementptr inbounds i32, ptr \00"
@.str378 = private unnamed_addr constant [7 x i8] c", i32 \00"
@.str379 = private unnamed_addr constant [4 x i8] c"int\00"
@.str380 = private unnamed_addr constant [7 x i8] c"fixeds\00"
@.str381 = private unnamed_addr constant [33 x i8] c"getelementptr inbounds i32, ptr \00"
@.str382 = private unnamed_addr constant [7 x i8] c", i32 \00"
@.str383 = private unnamed_addr constant [6 x i8] c"fixed\00"
@.str384 = private unnamed_addr constant [5 x i8] c"ptrs\00"
@.str385 = private unnamed_addr constant [33 x i8] c"getelementptr inbounds ptr, ptr \00"
@.str386 = private unnamed_addr constant [7 x i8] c", i32 \00"
@.str387 = private unnamed_addr constant [4 x i8] c"ptr\00"
@.str388 = private unnamed_addr constant [32 x i8] c"getelementptr inbounds i8, ptr \00"
@.str389 = private unnamed_addr constant [7 x i8] c", i32 \00"
@.str390 = private unnamed_addr constant [5 x i8] c"byte\00"
@.str391 = private unnamed_addr constant [3 x i8] c"  \00"
@.str392 = private unnamed_addr constant [40 x i8] c" = getelementptr inbounds %LSlice, ptr \00"
@.str393 = private unnamed_addr constant [16 x i8] c", i32 0, i32 0\0A\00"
@.str394 = private unnamed_addr constant [3 x i8] c"  \00"
@.str395 = private unnamed_addr constant [18 x i8] c" = load ptr, ptr \00"
@.str396 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str397 = private unnamed_addr constant [3 x i8] c"  \00"
@.str398 = private unnamed_addr constant [27 x i8] c" = getelementptr inbounds \00"
@.str399 = private unnamed_addr constant [7 x i8] c", ptr \00"
@.str400 = private unnamed_addr constant [7 x i8] c", i32 \00"
@.str401 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str402 = private unnamed_addr constant [7 x i8] c"resize\00"
@.str403 = private unnamed_addr constant [10 x i8] c"file_open\00"
@.str404 = private unnamed_addr constant [10 x i8] c"file_read\00"
@.str405 = private unnamed_addr constant [11 x i8] c"file_write\00"
@.str406 = private unnamed_addr constant [10 x i8] c"file_seek\00"
@.str407 = private unnamed_addr constant [10 x i8] c"file_tell\00"
@.str408 = private unnamed_addr constant [11 x i8] c"file_close\00"
@.str409 = private unnamed_addr constant [10 x i8] c"arg_count\00"
@.str410 = private unnamed_addr constant [4 x i8] c"arg\00"
@.str411 = private unnamed_addr constant [5 x i8] c"exit\00"
@.str412 = private unnamed_addr constant [12 x i8] c"file_stderr\00"
@.str413 = private unnamed_addr constant [12 x i8] c"file_stdout\00"
@.str414 = private unnamed_addr constant [4 x i8] c"run\00"
@.str415 = private unnamed_addr constant [7 x i8] c"getenv\00"
@.str416 = private unnamed_addr constant [3 x i8] c"  \00"
@.str417 = private unnamed_addr constant [4 x i8] c" = \00"
@.str418 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str419 = private unnamed_addr constant [7 x i8] c"resize\00"
@.str420 = private unnamed_addr constant [10 x i8] c"zext i32 \00"
@.str421 = private unnamed_addr constant [8 x i8] c" to i64\00"
@.str422 = private unnamed_addr constant [23 x i8] c"call ptr @realloc(ptr \00"
@.str423 = private unnamed_addr constant [7 x i8] c", i64 \00"
@.str424 = private unnamed_addr constant [2 x i8] c")\00"
@.str425 = private unnamed_addr constant [4 x i8] c"ptr\00"
@.str426 = private unnamed_addr constant [10 x i8] c"file_open\00"
@.str427 = private unnamed_addr constant [21 x i8] c"call ptr @fopen(ptr \00"
@.str428 = private unnamed_addr constant [7 x i8] c", ptr \00"
@.str429 = private unnamed_addr constant [2 x i8] c")\00"
@.str430 = private unnamed_addr constant [4 x i8] c"ptr\00"
@.str431 = private unnamed_addr constant [10 x i8] c"file_read\00"
@.str432 = private unnamed_addr constant [11 x i8] c"file_write\00"
@.str433 = private unnamed_addr constant [10 x i8] c"zext i32 \00"
@.str434 = private unnamed_addr constant [8 x i8] c" to i64\00"
@.str435 = private unnamed_addr constant [7 x i8] c"@fread\00"
@.str436 = private unnamed_addr constant [11 x i8] c"file_write\00"
@.str437 = private unnamed_addr constant [8 x i8] c"@fwrite\00"
@.str438 = private unnamed_addr constant [10 x i8] c"call i64 \00"
@.str439 = private unnamed_addr constant [6 x i8] c"(ptr \00"
@.str440 = private unnamed_addr constant [14 x i8] c", i64 1, i64 \00"
@.str441 = private unnamed_addr constant [7 x i8] c", ptr \00"
@.str442 = private unnamed_addr constant [2 x i8] c")\00"
@.str443 = private unnamed_addr constant [11 x i8] c"trunc i64 \00"
@.str444 = private unnamed_addr constant [8 x i8] c" to i32\00"
@.str445 = private unnamed_addr constant [4 x i8] c"int\00"
@.str446 = private unnamed_addr constant [10 x i8] c"file_seek\00"
@.str447 = private unnamed_addr constant [10 x i8] c"sext i32 \00"
@.str448 = private unnamed_addr constant [8 x i8] c" to i64\00"
@.str449 = private unnamed_addr constant [21 x i8] c"call i32 @fseek(ptr \00"
@.str450 = private unnamed_addr constant [7 x i8] c", i64 \00"
@.str451 = private unnamed_addr constant [7 x i8] c", i32 \00"
@.str452 = private unnamed_addr constant [2 x i8] c")\00"
@.str453 = private unnamed_addr constant [4 x i8] c"int\00"
@.str454 = private unnamed_addr constant [10 x i8] c"file_tell\00"
@.str455 = private unnamed_addr constant [21 x i8] c"call i64 @ftell(ptr \00"
@.str456 = private unnamed_addr constant [2 x i8] c")\00"
@.str457 = private unnamed_addr constant [11 x i8] c"trunc i64 \00"
@.str458 = private unnamed_addr constant [8 x i8] c" to i32\00"
@.str459 = private unnamed_addr constant [4 x i8] c"int\00"
@.str460 = private unnamed_addr constant [11 x i8] c"file_close\00"
@.str461 = private unnamed_addr constant [24 x i8] c"  call i32 @fclose(ptr \00"
@.str462 = private unnamed_addr constant [3 x i8] c")\0A\00"
@.str463 = private unnamed_addr constant [2 x i8] c"0\00"
@.str464 = private unnamed_addr constant [5 x i8] c"void\00"
@.str465 = private unnamed_addr constant [10 x i8] c"arg_count\00"
@.str466 = private unnamed_addr constant [22 x i8] c"load i32, ptr @L_argc\00"
@.str467 = private unnamed_addr constant [4 x i8] c"int\00"
@.str468 = private unnamed_addr constant [4 x i8] c"arg\00"
@.str469 = private unnamed_addr constant [22 x i8] c"load ptr, ptr @L_argv\00"
@.str470 = private unnamed_addr constant [24 x i8] c"getelementptr ptr, ptr \00"
@.str471 = private unnamed_addr constant [7 x i8] c", i32 \00"
@.str472 = private unnamed_addr constant [15 x i8] c"load ptr, ptr \00"
@.str473 = private unnamed_addr constant [4 x i8] c"str\00"
@.str474 = private unnamed_addr constant [5 x i8] c"exit\00"
@.str475 = private unnamed_addr constant [23 x i8] c"  call void @exit(i32 \00"
@.str476 = private unnamed_addr constant [3 x i8] c")\0A\00"
@.str477 = private unnamed_addr constant [15 x i8] c"  unreachable\0A\00"
@.str478 = private unnamed_addr constant [2 x i8] c"0\00"
@.str479 = private unnamed_addr constant [5 x i8] c"void\00"
@.str480 = private unnamed_addr constant [12 x i8] c"file_stderr\00"
@.str481 = private unnamed_addr constant [25 x i8] c"load ptr, ptr @__stderrp\00"
@.str482 = private unnamed_addr constant [4 x i8] c"ptr\00"
@.str483 = private unnamed_addr constant [12 x i8] c"file_stdout\00"
@.str484 = private unnamed_addr constant [25 x i8] c"load ptr, ptr @__stdoutp\00"
@.str485 = private unnamed_addr constant [4 x i8] c"ptr\00"
@.str486 = private unnamed_addr constant [4 x i8] c"run\00"
@.str487 = private unnamed_addr constant [22 x i8] c"call i32 @system(ptr \00"
@.str488 = private unnamed_addr constant [2 x i8] c")\00"
@.str489 = private unnamed_addr constant [4 x i8] c"int\00"
@.str490 = private unnamed_addr constant [7 x i8] c"getenv\00"
@.str491 = private unnamed_addr constant [22 x i8] c"call ptr @getenv(ptr \00"
@.str492 = private unnamed_addr constant [2 x i8] c")\00"
@.str493 = private unnamed_addr constant [4 x i8] c"str\00"
@.str494 = private unnamed_addr constant [2 x i8] c"0\00"
@.str495 = private unnamed_addr constant [5 x i8] c"void\00"
@.str496 = private unnamed_addr constant [5 x i8] c"free\00"
@.str497 = private unnamed_addr constant [5 x i8] c"fill\00"
@.str498 = private unnamed_addr constant [7 x i8] c"offset\00"
@.str499 = private unnamed_addr constant [10 x i8] c"read_char\00"
@.str500 = private unnamed_addr constant [9 x i8] c"as_fixed\00"
@.str501 = private unnamed_addr constant [7 x i8] c"as_int\00"
@.str502 = private unnamed_addr constant [12 x i8] c"is_windowed\00"
@.str503 = private unnamed_addr constant [11 x i8] c"game_title\00"
@.str504 = private unnamed_addr constant [9 x i8] c"win_open\00"
@.str505 = private unnamed_addr constant [9 x i8] c"win_poll\00"
@.str506 = private unnamed_addr constant [12 x i8] c"win_present\00"
@.str507 = private unnamed_addr constant [12 x i8] c"win_running\00"
@.str508 = private unnamed_addr constant [10 x i8] c"win_close\00"
@.str509 = private unnamed_addr constant [5 x i8] c"free\00"
@.str510 = private unnamed_addr constant [23 x i8] c"  call void @free(ptr \00"
@.str511 = private unnamed_addr constant [3 x i8] c")\0A\00"
@.str512 = private unnamed_addr constant [2 x i8] c"0\00"
@.str513 = private unnamed_addr constant [5 x i8] c"void\00"
@.str514 = private unnamed_addr constant [5 x i8] c"fill\00"
@.str515 = private unnamed_addr constant [10 x i8] c"zext i32 \00"
@.str516 = private unnamed_addr constant [8 x i8] c" to i64\00"
@.str517 = private unnamed_addr constant [24 x i8] c"  call ptr @memset(ptr \00"
@.str518 = private unnamed_addr constant [7 x i8] c", i32 \00"
@.str519 = private unnamed_addr constant [7 x i8] c", i64 \00"
@.str520 = private unnamed_addr constant [3 x i8] c")\0A\00"
@.str521 = private unnamed_addr constant [2 x i8] c"0\00"
@.str522 = private unnamed_addr constant [5 x i8] c"void\00"
@.str523 = private unnamed_addr constant [7 x i8] c"offset\00"
@.str524 = private unnamed_addr constant [3 x i8] c"  \00"
@.str525 = private unnamed_addr constant [35 x i8] c" = getelementptr inbounds i8, ptr \00"
@.str526 = private unnamed_addr constant [7 x i8] c", i32 \00"
@.str527 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str528 = private unnamed_addr constant [4 x i8] c"ptr\00"
@.str529 = private unnamed_addr constant [10 x i8] c"read_char\00"
@.str530 = private unnamed_addr constant [20 x i8] c"call i32 @getchar()\00"
@.str531 = private unnamed_addr constant [4 x i8] c"int\00"
@.str532 = private unnamed_addr constant [9 x i8] c"as_fixed\00"
@.str533 = private unnamed_addr constant [6 x i8] c"fixed\00"
@.str534 = private unnamed_addr constant [7 x i8] c"as_int\00"
@.str535 = private unnamed_addr constant [4 x i8] c"int\00"
@.str536 = private unnamed_addr constant [12 x i8] c"is_windowed\00"
@.str537 = private unnamed_addr constant [2 x i8] c"1\00"
@.str538 = private unnamed_addr constant [5 x i8] c"bool\00"
@.str539 = private unnamed_addr constant [2 x i8] c"0\00"
@.str540 = private unnamed_addr constant [5 x i8] c"bool\00"
@.str541 = private unnamed_addr constant [11 x i8] c"game_title\00"
@.str542 = private unnamed_addr constant [12 x i8] c"@.gametitle\00"
@.str543 = private unnamed_addr constant [4 x i8] c"str\00"
@.str544 = private unnamed_addr constant [9 x i8] c"win_poll\00"
@.str545 = private unnamed_addr constant [21 x i8] c"call i32 @win_poll()\00"
@.str546 = private unnamed_addr constant [4 x i8] c"int\00"
@.str547 = private unnamed_addr constant [12 x i8] c"win_running\00"
@.str548 = private unnamed_addr constant [24 x i8] c"call i32 @win_running()\00"
@.str549 = private unnamed_addr constant [5 x i8] c"bool\00"
@.str550 = private unnamed_addr constant [9 x i8] c"win_open\00"
@.str551 = private unnamed_addr constant [27 x i8] c"  call void @win_open(i32 \00"
@.str552 = private unnamed_addr constant [7 x i8] c", i32 \00"
@.str553 = private unnamed_addr constant [7 x i8] c", i32 \00"
@.str554 = private unnamed_addr constant [7 x i8] c", ptr \00"
@.str555 = private unnamed_addr constant [3 x i8] c")\0A\00"
@.str556 = private unnamed_addr constant [2 x i8] c"0\00"
@.str557 = private unnamed_addr constant [5 x i8] c"void\00"
@.str558 = private unnamed_addr constant [12 x i8] c"win_present\00"
@.str559 = private unnamed_addr constant [30 x i8] c"  call void @win_present(ptr \00"
@.str560 = private unnamed_addr constant [7 x i8] c", i32 \00"
@.str561 = private unnamed_addr constant [7 x i8] c", i32 \00"
@.str562 = private unnamed_addr constant [3 x i8] c")\0A\00"
@.str563 = private unnamed_addr constant [2 x i8] c"0\00"
@.str564 = private unnamed_addr constant [5 x i8] c"void\00"
@.str565 = private unnamed_addr constant [10 x i8] c"win_close\00"
@.str566 = private unnamed_addr constant [26 x i8] c"  call void @win_close()\0A\00"
@.str567 = private unnamed_addr constant [2 x i8] c"0\00"
@.str568 = private unnamed_addr constant [5 x i8] c"void\00"
@.str569 = private unnamed_addr constant [2 x i8] c"0\00"
@.str570 = private unnamed_addr constant [5 x i8] c"void\00"
@.str571 = private unnamed_addr constant [4 x i8] c"min\00"
@.str572 = private unnamed_addr constant [4 x i8] c"max\00"
@.str573 = private unnamed_addr constant [4 x i8] c"abs\00"
@.str574 = private unnamed_addr constant [6 x i8] c"clamp\00"
@.str575 = private unnamed_addr constant [4 x i8] c"abs\00"
@.str576 = private unnamed_addr constant [14 x i8] c"icmp slt i32 \00"
@.str577 = private unnamed_addr constant [4 x i8] c", 0\00"
@.str578 = private unnamed_addr constant [12 x i8] c"sub i32 0, \00"
@.str579 = private unnamed_addr constant [11 x i8] c"select i1 \00"
@.str580 = private unnamed_addr constant [7 x i8] c", i32 \00"
@.str581 = private unnamed_addr constant [7 x i8] c", i32 \00"
@.str582 = private unnamed_addr constant [4 x i8] c"int\00"
@.str583 = private unnamed_addr constant [4 x i8] c"min\00"
@.str584 = private unnamed_addr constant [4 x i8] c"max\00"
@.str585 = private unnamed_addr constant [4 x i8] c"slt\00"
@.str586 = private unnamed_addr constant [4 x i8] c"max\00"
@.str587 = private unnamed_addr constant [4 x i8] c"sgt\00"
@.str588 = private unnamed_addr constant [6 x i8] c"icmp \00"
@.str589 = private unnamed_addr constant [6 x i8] c" i32 \00"
@.str590 = private unnamed_addr constant [3 x i8] c", \00"
@.str591 = private unnamed_addr constant [11 x i8] c"select i1 \00"
@.str592 = private unnamed_addr constant [7 x i8] c", i32 \00"
@.str593 = private unnamed_addr constant [7 x i8] c", i32 \00"
@.str594 = private unnamed_addr constant [4 x i8] c"int\00"
@.str595 = private unnamed_addr constant [14 x i8] c"icmp slt i32 \00"
@.str596 = private unnamed_addr constant [3 x i8] c", \00"
@.str597 = private unnamed_addr constant [11 x i8] c"select i1 \00"
@.str598 = private unnamed_addr constant [7 x i8] c", i32 \00"
@.str599 = private unnamed_addr constant [7 x i8] c", i32 \00"
@.str600 = private unnamed_addr constant [14 x i8] c"icmp sgt i32 \00"
@.str601 = private unnamed_addr constant [3 x i8] c", \00"
@.str602 = private unnamed_addr constant [11 x i8] c"select i1 \00"
@.str603 = private unnamed_addr constant [7 x i8] c", i32 \00"
@.str604 = private unnamed_addr constant [7 x i8] c", i32 \00"
@.str605 = private unnamed_addr constant [4 x i8] c"int\00"
@.str606 = private unnamed_addr constant [15 x i8] c"getelementptr \00"
@.str607 = private unnamed_addr constant [18 x i8] c", ptr null, i32 1\00"
@.str608 = private unnamed_addr constant [14 x i8] c"ptrtoint ptr \00"
@.str609 = private unnamed_addr constant [8 x i8] c" to i64\00"
@.str610 = private unnamed_addr constant [27 x i8] c"unknown record type in new\00"
@.str611 = private unnamed_addr constant [22 x i8] c"call ptr @malloc(i64 \00"
@.str612 = private unnamed_addr constant [2 x i8] c")\00"
@.str613 = private unnamed_addr constant [3 x i8] c"  \00"
@.str614 = private unnamed_addr constant [27 x i8] c" = getelementptr inbounds \00"
@.str615 = private unnamed_addr constant [7 x i8] c", ptr \00"
@.str616 = private unnamed_addr constant [14 x i8] c", i32 0, i32 \00"
@.str617 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str618 = private unnamed_addr constant [2 x i8] c"0\00"
@.str619 = private unnamed_addr constant [4 x i8] c"ptr\00"
@.str620 = private unnamed_addr constant [5 x i8] c"null\00"
@.str621 = private unnamed_addr constant [9 x i8] c"  store \00"
@.str622 = private unnamed_addr constant [2 x i8] c" \00"
@.str623 = private unnamed_addr constant [7 x i8] c", ptr \00"
@.str624 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str625 = private unnamed_addr constant [8 x i8] c"%LSlice\00"
@.str626 = private unnamed_addr constant [22 x i8] c"call ptr @malloc(i64 \00"
@.str627 = private unnamed_addr constant [2 x i8] c")\00"
@.str628 = private unnamed_addr constant [3 x i8] c"  \00"
@.str629 = private unnamed_addr constant [40 x i8] c" = getelementptr inbounds %LSlice, ptr \00"
@.str630 = private unnamed_addr constant [16 x i8] c", i32 0, i32 0\0A\00"
@.str631 = private unnamed_addr constant [23 x i8] c"  store ptr null, ptr \00"
@.str632 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str633 = private unnamed_addr constant [3 x i8] c"  \00"
@.str634 = private unnamed_addr constant [40 x i8] c" = getelementptr inbounds %LSlice, ptr \00"
@.str635 = private unnamed_addr constant [16 x i8] c", i32 0, i32 1\0A\00"
@.str636 = private unnamed_addr constant [20 x i8] c"  store i32 0, ptr \00"
@.str637 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str638 = private unnamed_addr constant [3 x i8] c"  \00"
@.str639 = private unnamed_addr constant [40 x i8] c" = getelementptr inbounds %LSlice, ptr \00"
@.str640 = private unnamed_addr constant [16 x i8] c", i32 0, i32 2\0A\00"
@.str641 = private unnamed_addr constant [20 x i8] c"  store i32 0, ptr \00"
@.str642 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str643 = private unnamed_addr constant [3 x i8] c"  \00"
@.str644 = private unnamed_addr constant [40 x i8] c" = getelementptr inbounds %LSlice, ptr \00"
@.str645 = private unnamed_addr constant [14 x i8] c", i32 0, i32 \00"
@.str646 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str647 = private unnamed_addr constant [15 x i8] c"load i32, ptr \00"
@.str648 = private unnamed_addr constant [4 x i8] c"int\00"
@.str649 = private unnamed_addr constant [22 x i8] c"call i64 @strlen(ptr \00"
@.str650 = private unnamed_addr constant [2 x i8] c")\00"
@.str651 = private unnamed_addr constant [11 x i8] c"trunc i64 \00"
@.str652 = private unnamed_addr constant [8 x i8] c" to i32\00"
@.str653 = private unnamed_addr constant [4 x i8] c"int\00"
@.str654 = private unnamed_addr constant [15 x i8] c"load i32, ptr \00"
@.str655 = private unnamed_addr constant [15 x i8] c"load i32, ptr \00"
@.str656 = private unnamed_addr constant [14 x i8] c"icmp sge i32 \00"
@.str657 = private unnamed_addr constant [3 x i8] c", \00"
@.str658 = private unnamed_addr constant [5 x i8] c"grow\00"
@.str659 = private unnamed_addr constant [4 x i8] c"put\00"
@.str660 = private unnamed_addr constant [9 x i8] c"  br i1 \00"
@.str661 = private unnamed_addr constant [10 x i8] c", label %\00"
@.str662 = private unnamed_addr constant [10 x i8] c", label %\00"
@.str663 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str664 = private unnamed_addr constant [3 x i8] c":\0A\00"
@.str665 = private unnamed_addr constant [9 x i8] c"mul i32 \00"
@.str666 = private unnamed_addr constant [4 x i8] c", 2\00"
@.str667 = private unnamed_addr constant [13 x i8] c"icmp eq i32 \00"
@.str668 = private unnamed_addr constant [4 x i8] c", 0\00"
@.str669 = private unnamed_addr constant [11 x i8] c"select i1 \00"
@.str670 = private unnamed_addr constant [14 x i8] c", i32 8, i32 \00"
@.str671 = private unnamed_addr constant [10 x i8] c"zext i32 \00"
@.str672 = private unnamed_addr constant [8 x i8] c" to i64\00"
@.str673 = private unnamed_addr constant [9 x i8] c"mul i64 \00"
@.str674 = private unnamed_addr constant [3 x i8] c", \00"
@.str675 = private unnamed_addr constant [15 x i8] c"load ptr, ptr \00"
@.str676 = private unnamed_addr constant [23 x i8] c"call ptr @realloc(ptr \00"
@.str677 = private unnamed_addr constant [7 x i8] c", i64 \00"
@.str678 = private unnamed_addr constant [2 x i8] c")\00"
@.str679 = private unnamed_addr constant [13 x i8] c"  store ptr \00"
@.str680 = private unnamed_addr constant [7 x i8] c", ptr \00"
@.str681 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str682 = private unnamed_addr constant [13 x i8] c"  store i32 \00"
@.str683 = private unnamed_addr constant [7 x i8] c", ptr \00"
@.str684 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str685 = private unnamed_addr constant [13 x i8] c"  br label %\00"
@.str686 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str687 = private unnamed_addr constant [3 x i8] c":\0A\00"
@.str688 = private unnamed_addr constant [15 x i8] c"load ptr, ptr \00"
@.str689 = private unnamed_addr constant [3 x i8] c"  \00"
@.str690 = private unnamed_addr constant [27 x i8] c" = getelementptr inbounds \00"
@.str691 = private unnamed_addr constant [7 x i8] c", ptr \00"
@.str692 = private unnamed_addr constant [7 x i8] c", i32 \00"
@.str693 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str694 = private unnamed_addr constant [9 x i8] c"  store \00"
@.str695 = private unnamed_addr constant [2 x i8] c" \00"
@.str696 = private unnamed_addr constant [7 x i8] c", ptr \00"
@.str697 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str698 = private unnamed_addr constant [9 x i8] c"add i32 \00"
@.str699 = private unnamed_addr constant [4 x i8] c", 1\00"
@.str700 = private unnamed_addr constant [13 x i8] c"  store i32 \00"
@.str701 = private unnamed_addr constant [7 x i8] c", ptr \00"
@.str702 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str703 = private unnamed_addr constant [2 x i8] c"0\00"
@.str704 = private unnamed_addr constant [5 x i8] c"void\00"
@.str705 = private unnamed_addr constant [6 x i8] c"load \00"
@.str706 = private unnamed_addr constant [7 x i8] c", ptr \00"
@.str707 = private unnamed_addr constant [4 x i8] c"i32\00"
@.str708 = private unnamed_addr constant [13 x i8] c"icmp ne i32 \00"
@.str709 = private unnamed_addr constant [4 x i8] c", 0\00"
@.str710 = private unnamed_addr constant [9 x i8] c"zext i1 \00"
@.str711 = private unnamed_addr constant [8 x i8] c" to i32\00"
@.str712 = private unnamed_addr constant [13 x i8] c"  store i32 \00"
@.str713 = private unnamed_addr constant [7 x i8] c", ptr \00"
@.str714 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str715 = private unnamed_addr constant [3 x i8] c"sc\00"
@.str716 = private unnamed_addr constant [6 x i8] c"scend\00"
@.str717 = private unnamed_addr constant [4 x i8] c"and\00"
@.str718 = private unnamed_addr constant [9 x i8] c"  br i1 \00"
@.str719 = private unnamed_addr constant [10 x i8] c", label %\00"
@.str720 = private unnamed_addr constant [10 x i8] c", label %\00"
@.str721 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str722 = private unnamed_addr constant [9 x i8] c"  br i1 \00"
@.str723 = private unnamed_addr constant [10 x i8] c", label %\00"
@.str724 = private unnamed_addr constant [10 x i8] c", label %\00"
@.str725 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str726 = private unnamed_addr constant [3 x i8] c":\0A\00"
@.str727 = private unnamed_addr constant [13 x i8] c"icmp ne i32 \00"
@.str728 = private unnamed_addr constant [4 x i8] c", 0\00"
@.str729 = private unnamed_addr constant [9 x i8] c"zext i1 \00"
@.str730 = private unnamed_addr constant [8 x i8] c" to i32\00"
@.str731 = private unnamed_addr constant [13 x i8] c"  store i32 \00"
@.str732 = private unnamed_addr constant [7 x i8] c", ptr \00"
@.str733 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str734 = private unnamed_addr constant [13 x i8] c"  br label %\00"
@.str735 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str736 = private unnamed_addr constant [3 x i8] c":\0A\00"
@.str737 = private unnamed_addr constant [15 x i8] c"load i32, ptr \00"
@.str738 = private unnamed_addr constant [5 x i8] c"bool\00"
@.str739 = private unnamed_addr constant [2 x i8] c"<\00"
@.str740 = private unnamed_addr constant [4 x i8] c"slt\00"
@.str741 = private unnamed_addr constant [3 x i8] c"<=\00"
@.str742 = private unnamed_addr constant [4 x i8] c"sle\00"
@.str743 = private unnamed_addr constant [2 x i8] c">\00"
@.str744 = private unnamed_addr constant [4 x i8] c"sgt\00"
@.str745 = private unnamed_addr constant [3 x i8] c">=\00"
@.str746 = private unnamed_addr constant [4 x i8] c"sge\00"
@.str747 = private unnamed_addr constant [3 x i8] c"==\00"
@.str748 = private unnamed_addr constant [3 x i8] c"eq\00"
@.str749 = private unnamed_addr constant [3 x i8] c"ne\00"
@.str750 = private unnamed_addr constant [2 x i8] c"<\00"
@.str751 = private unnamed_addr constant [3 x i8] c"<=\00"
@.str752 = private unnamed_addr constant [2 x i8] c">\00"
@.str753 = private unnamed_addr constant [3 x i8] c">=\00"
@.str754 = private unnamed_addr constant [3 x i8] c"==\00"
@.str755 = private unnamed_addr constant [3 x i8] c"!=\00"
@.str756 = private unnamed_addr constant [2 x i8] c"+\00"
@.str757 = private unnamed_addr constant [4 x i8] c"add\00"
@.str758 = private unnamed_addr constant [2 x i8] c"-\00"
@.str759 = private unnamed_addr constant [4 x i8] c"sub\00"
@.str760 = private unnamed_addr constant [2 x i8] c"*\00"
@.str761 = private unnamed_addr constant [4 x i8] c"mul\00"
@.str762 = private unnamed_addr constant [2 x i8] c"/\00"
@.str763 = private unnamed_addr constant [5 x i8] c"sdiv\00"
@.str764 = private unnamed_addr constant [2 x i8] c"&\00"
@.str765 = private unnamed_addr constant [4 x i8] c"and\00"
@.str766 = private unnamed_addr constant [2 x i8] c"|\00"
@.str767 = private unnamed_addr constant [3 x i8] c"or\00"
@.str768 = private unnamed_addr constant [2 x i8] c"^\00"
@.str769 = private unnamed_addr constant [4 x i8] c"xor\00"
@.str770 = private unnamed_addr constant [3 x i8] c"<<\00"
@.str771 = private unnamed_addr constant [4 x i8] c"shl\00"
@.str772 = private unnamed_addr constant [3 x i8] c">>\00"
@.str773 = private unnamed_addr constant [5 x i8] c"lshr\00"
@.str774 = private unnamed_addr constant [5 x i8] c"srem\00"
@.str775 = private unnamed_addr constant [6 x i8] c"fixed\00"
@.str776 = private unnamed_addr constant [9 x i8] c"shl i32 \00"
@.str777 = private unnamed_addr constant [5 x i8] c", 16\00"
@.str778 = private unnamed_addr constant [2 x i8] c"+\00"
@.str779 = private unnamed_addr constant [29 x i8] c"call ptr @fn_str_concat(ptr \00"
@.str780 = private unnamed_addr constant [7 x i8] c", ptr \00"
@.str781 = private unnamed_addr constant [2 x i8] c")\00"
@.str782 = private unnamed_addr constant [4 x i8] c"str\00"
@.str783 = private unnamed_addr constant [25 x i8] c"call i32 @fn_str_eq(ptr \00"
@.str784 = private unnamed_addr constant [7 x i8] c", ptr \00"
@.str785 = private unnamed_addr constant [2 x i8] c")\00"
@.str786 = private unnamed_addr constant [3 x i8] c"!=\00"
@.str787 = private unnamed_addr constant [13 x i8] c"icmp eq i32 \00"
@.str788 = private unnamed_addr constant [4 x i8] c", 0\00"
@.str789 = private unnamed_addr constant [9 x i8] c"zext i1 \00"
@.str790 = private unnamed_addr constant [8 x i8] c" to i32\00"
@.str791 = private unnamed_addr constant [5 x i8] c"bool\00"
@.str792 = private unnamed_addr constant [5 x i8] c"bool\00"
@.str793 = private unnamed_addr constant [4 x i8] c"and\00"
@.str794 = private unnamed_addr constant [3 x i8] c"or\00"
@.str795 = private unnamed_addr constant [4 x i8] c"ptr\00"
@.str796 = private unnamed_addr constant [4 x i8] c"ptr\00"
@.str797 = private unnamed_addr constant [2 x i8] c"+\00"
@.str798 = private unnamed_addr constant [2 x i8] c"+\00"
@.str799 = private unnamed_addr constant [3 x i8] c"==\00"
@.str800 = private unnamed_addr constant [3 x i8] c"!=\00"
@.str801 = private unnamed_addr constant [6 x i8] c"fixed\00"
@.str802 = private unnamed_addr constant [6 x i8] c"fixed\00"
@.str803 = private unnamed_addr constant [4 x i8] c"i32\00"
@.str804 = private unnamed_addr constant [4 x i8] c"ptr\00"
@.str805 = private unnamed_addr constant [4 x i8] c"ptr\00"
@.str806 = private unnamed_addr constant [4 x i8] c"ptr\00"
@.str807 = private unnamed_addr constant [6 x i8] c"icmp \00"
@.str808 = private unnamed_addr constant [2 x i8] c" \00"
@.str809 = private unnamed_addr constant [2 x i8] c" \00"
@.str810 = private unnamed_addr constant [3 x i8] c", \00"
@.str811 = private unnamed_addr constant [9 x i8] c"zext i1 \00"
@.str812 = private unnamed_addr constant [8 x i8] c" to i32\00"
@.str813 = private unnamed_addr constant [5 x i8] c"bool\00"
@.str814 = private unnamed_addr constant [2 x i8] c"*\00"
@.str815 = private unnamed_addr constant [10 x i8] c"sext i32 \00"
@.str816 = private unnamed_addr constant [8 x i8] c" to i64\00"
@.str817 = private unnamed_addr constant [10 x i8] c"sext i32 \00"
@.str818 = private unnamed_addr constant [8 x i8] c" to i64\00"
@.str819 = private unnamed_addr constant [9 x i8] c"mul i64 \00"
@.str820 = private unnamed_addr constant [3 x i8] c", \00"
@.str821 = private unnamed_addr constant [10 x i8] c"ashr i64 \00"
@.str822 = private unnamed_addr constant [5 x i8] c", 16\00"
@.str823 = private unnamed_addr constant [11 x i8] c"trunc i64 \00"
@.str824 = private unnamed_addr constant [8 x i8] c" to i32\00"
@.str825 = private unnamed_addr constant [6 x i8] c"fixed\00"
@.str826 = private unnamed_addr constant [2 x i8] c"/\00"
@.str827 = private unnamed_addr constant [10 x i8] c"sext i32 \00"
@.str828 = private unnamed_addr constant [8 x i8] c" to i64\00"
@.str829 = private unnamed_addr constant [9 x i8] c"shl i64 \00"
@.str830 = private unnamed_addr constant [5 x i8] c", 16\00"
@.str831 = private unnamed_addr constant [10 x i8] c"sext i32 \00"
@.str832 = private unnamed_addr constant [8 x i8] c" to i64\00"
@.str833 = private unnamed_addr constant [10 x i8] c"sdiv i64 \00"
@.str834 = private unnamed_addr constant [3 x i8] c", \00"
@.str835 = private unnamed_addr constant [11 x i8] c"trunc i64 \00"
@.str836 = private unnamed_addr constant [8 x i8] c" to i32\00"
@.str837 = private unnamed_addr constant [6 x i8] c"fixed\00"
@.str838 = private unnamed_addr constant [6 x i8] c" i32 \00"
@.str839 = private unnamed_addr constant [3 x i8] c", \00"
@.str840 = private unnamed_addr constant [6 x i8] c"fixed\00"
@.str841 = private unnamed_addr constant [6 x i8] c" i32 \00"
@.str842 = private unnamed_addr constant [3 x i8] c", \00"
@.str843 = private unnamed_addr constant [4 x i8] c"int\00"
@.str844 = private unnamed_addr constant [5 x i8] c"self\00"
@.str845 = private unnamed_addr constant [2 x i8] c"0\00"
@.str846 = private unnamed_addr constant [7 x i8] c"entity\00"
@.str847 = private unnamed_addr constant [15 x i8] c"load i32, ptr \00"
@.str848 = private unnamed_addr constant [7 x i8] c"entity\00"
@.str849 = private unnamed_addr constant [4 x i8] c"key\00"
@.str850 = private unnamed_addr constant [21 x i8] c"load i32, ptr @L_key\00"
@.str851 = private unnamed_addr constant [4 x i8] c"int\00"
@.str852 = private unnamed_addr constant [5 x i8] c"save\00"
@.str853 = private unnamed_addr constant [23 x i8] c"  call void @L_save()\0A\00"
@.str854 = private unnamed_addr constant [2 x i8] c"0\00"
@.str855 = private unnamed_addr constant [5 x i8] c"void\00"
@.str856 = private unnamed_addr constant [9 x i8] c"ui_build\00"
@.str857 = private unnamed_addr constant [25 x i8] c"  call void @ui_build()\0A\00"
@.str858 = private unnamed_addr constant [2 x i8] c"0\00"
@.str859 = private unnamed_addr constant [5 x i8] c"void\00"
@.str860 = private unnamed_addr constant [5 x i8] c"load\00"
@.str861 = private unnamed_addr constant [19 x i8] c"call i32 @L_load()\00"
@.str862 = private unnamed_addr constant [5 x i8] c"bool\00"
@.str863 = private unnamed_addr constant [5 x i8] c"quit\00"
@.str864 = private unnamed_addr constant [31 x i8] c"  store i32 0, ptr @L_running\0A\00"
@.str865 = private unnamed_addr constant [2 x i8] c"0\00"
@.str866 = private unnamed_addr constant [5 x i8] c"void\00"
@.str867 = private unnamed_addr constant [4 x i8] c"len\00"
@.str868 = private unnamed_addr constant [5 x i8] c"push\00"
@.str869 = private unnamed_addr constant [4 x i8] c"str\00"
@.str870 = private unnamed_addr constant [4 x i8] c"ptr\00"
@.str871 = private unnamed_addr constant [26 x i8] c"call ptr @fn_int_str(i32 \00"
@.str872 = private unnamed_addr constant [2 x i8] c")\00"
@.str873 = private unnamed_addr constant [4 x i8] c"str\00"
@.str874 = private unnamed_addr constant [6 x i8] c"print\00"
@.str875 = private unnamed_addr constant [4 x i8] c"ptr\00"
@.str876 = private unnamed_addr constant [51 x i8] c"  call i32 (ptr, ...) @printf(ptr @.fmt_line, ptr \00"
@.str877 = private unnamed_addr constant [3 x i8] c")\0A\00"
@.str878 = private unnamed_addr constant [50 x i8] c"  call i32 (ptr, ...) @printf(ptr @.fmt_int, i32 \00"
@.str879 = private unnamed_addr constant [3 x i8] c")\0A\00"
@.str880 = private unnamed_addr constant [2 x i8] c"0\00"
@.str881 = private unnamed_addr constant [5 x i8] c"void\00"
@.str882 = private unnamed_addr constant [6 x i8] c"bytes\00"
@.str883 = private unnamed_addr constant [10 x i8] c"zext i32 \00"
@.str884 = private unnamed_addr constant [8 x i8] c" to i64\00"
@.str885 = private unnamed_addr constant [22 x i8] c"call ptr @malloc(i64 \00"
@.str886 = private unnamed_addr constant [2 x i8] c")\00"
@.str887 = private unnamed_addr constant [4 x i8] c"ptr\00"
@.str888 = private unnamed_addr constant [6 x i8] c"words\00"
@.str889 = private unnamed_addr constant [9 x i8] c"mul i32 \00"
@.str890 = private unnamed_addr constant [4 x i8] c", 4\00"
@.str891 = private unnamed_addr constant [10 x i8] c"zext i32 \00"
@.str892 = private unnamed_addr constant [8 x i8] c" to i64\00"
@.str893 = private unnamed_addr constant [22 x i8] c"call ptr @malloc(i64 \00"
@.str894 = private unnamed_addr constant [2 x i8] c")\00"
@.str895 = private unnamed_addr constant [6 x i8] c"words\00"
@.str896 = private unnamed_addr constant [3 x i8] c"fx\00"
@.str897 = private unnamed_addr constant [9 x i8] c"shl i32 \00"
@.str898 = private unnamed_addr constant [5 x i8] c", 16\00"
@.str899 = private unnamed_addr constant [6 x i8] c"fixed\00"
@.str900 = private unnamed_addr constant [4 x i8] c"flr\00"
@.str901 = private unnamed_addr constant [10 x i8] c"ashr i32 \00"
@.str902 = private unnamed_addr constant [5 x i8] c", 16\00"
@.str903 = private unnamed_addr constant [4 x i8] c"int\00"
@.str904 = private unnamed_addr constant [4 x i8] c"rt_\00"
@.str905 = private unnamed_addr constant [18 x i8] c"unknown function \00"
@.str906 = private unnamed_addr constant [3 x i8] c"  \00"
@.str907 = private unnamed_addr constant [2 x i8] c"0\00"
@.str908 = private unnamed_addr constant [5 x i8] c"void\00"
@.str909 = private unnamed_addr constant [4 x i8] c" = \00"
@.str910 = private unnamed_addr constant [6 x i8] c"call \00"
@.str911 = private unnamed_addr constant [6 x i8] c" @fn_\00"
@.str912 = private unnamed_addr constant [2 x i8] c"(\00"
@.str913 = private unnamed_addr constant [3 x i8] c", \00"
@.str914 = private unnamed_addr constant [2 x i8] c" \00"
@.str915 = private unnamed_addr constant [3 x i8] c")\0A\00"
@.str916 = private unnamed_addr constant [2 x i8] c"0\00"
@.str917 = private unnamed_addr constant [4 x i8] c"int\00"
@.str918 = private unnamed_addr constant [4 x i8] c"int\00"
@.str919 = private unnamed_addr constant [6 x i8] c"fixed\00"
@.str920 = private unnamed_addr constant [5 x i8] c"bool\00"
@.str921 = private unnamed_addr constant [5 x i8] c"null\00"
@.str922 = private unnamed_addr constant [4 x i8] c"ptr\00"
@.str923 = private unnamed_addr constant [28 x i8] c"call ptr @fn_str_slice(ptr \00"
@.str924 = private unnamed_addr constant [7 x i8] c", i32 \00"
@.str925 = private unnamed_addr constant [7 x i8] c", i32 \00"
@.str926 = private unnamed_addr constant [2 x i8] c")\00"
@.str927 = private unnamed_addr constant [4 x i8] c"str\00"
@.str928 = private unnamed_addr constant [4 x i8] c"str\00"
@.str929 = private unnamed_addr constant [4 x i8] c"int\00"
@.str930 = private unnamed_addr constant [6 x i8] c"load \00"
@.str931 = private unnamed_addr constant [10 x i8] c", ptr @g_\00"
@.str932 = private unnamed_addr constant [4 x i8] c"int\00"
@.str933 = private unnamed_addr constant [20 x i8] c"unknown identifier \00"
@.str934 = private unnamed_addr constant [4 x i8] c"int\00"
@.str935 = private unnamed_addr constant [5 x i8] c"byte\00"
@.str936 = private unnamed_addr constant [14 x i8] c"load i8, ptr \00"
@.str937 = private unnamed_addr constant [9 x i8] c"zext i8 \00"
@.str938 = private unnamed_addr constant [8 x i8] c" to i32\00"
@.str939 = private unnamed_addr constant [4 x i8] c"int\00"
@.str940 = private unnamed_addr constant [2 x i8] c"-\00"
@.str941 = private unnamed_addr constant [12 x i8] c"sub i32 0, \00"
@.str942 = private unnamed_addr constant [4 x i8] c"int\00"
@.str943 = private unnamed_addr constant [2 x i8] c"~\00"
@.str944 = private unnamed_addr constant [9 x i8] c"xor i32 \00"
@.str945 = private unnamed_addr constant [5 x i8] c", -1\00"
@.str946 = private unnamed_addr constant [4 x i8] c"int\00"
@.str947 = private unnamed_addr constant [13 x i8] c"icmp eq i32 \00"
@.str948 = private unnamed_addr constant [4 x i8] c", 0\00"
@.str949 = private unnamed_addr constant [9 x i8] c"zext i1 \00"
@.str950 = private unnamed_addr constant [8 x i8] c" to i32\00"
@.str951 = private unnamed_addr constant [5 x i8] c"bool\00"
@.str952 = private unnamed_addr constant [23 x i8] c"cannot emit expression\00"
@.str953 = private unnamed_addr constant [2 x i8] c"0\00"
@.str954 = private unnamed_addr constant [4 x i8] c"int\00"
@.str955 = private unnamed_addr constant [9 x i8] c"  store \00"
@.str956 = private unnamed_addr constant [2 x i8] c" \00"
@.str957 = private unnamed_addr constant [7 x i8] c", ptr \00"
@.str958 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str959 = private unnamed_addr constant [2 x i8] c"0\00"
@.str960 = private unnamed_addr constant [4 x i8] c"int\00"
@.str961 = private unnamed_addr constant [29 x i8] c"cannot assign to immutable '\00"
@.str962 = private unnamed_addr constant [41 x i8] c"' (declared with let; use var) \E2\80\94 line \00"
@.str963 = private unnamed_addr constant [19 x i8] c"assign to unknown \00"
@.str964 = private unnamed_addr constant [4 x i8] c"@g_\00"
@.str965 = private unnamed_addr constant [22 x i8] c"bad assignment target\00"
@.str966 = private unnamed_addr constant [2 x i8] c"=\00"
@.str967 = private unnamed_addr constant [6 x i8] c"load \00"
@.str968 = private unnamed_addr constant [7 x i8] c", ptr \00"
@.str969 = private unnamed_addr constant [4 x i8] c"add\00"
@.str970 = private unnamed_addr constant [3 x i8] c"-=\00"
@.str971 = private unnamed_addr constant [4 x i8] c"sub\00"
@.str972 = private unnamed_addr constant [3 x i8] c"*=\00"
@.str973 = private unnamed_addr constant [4 x i8] c"mul\00"
@.str974 = private unnamed_addr constant [3 x i8] c"/=\00"
@.str975 = private unnamed_addr constant [5 x i8] c"sdiv\00"
@.str976 = private unnamed_addr constant [6 x i8] c" i32 \00"
@.str977 = private unnamed_addr constant [3 x i8] c", \00"
@.str978 = private unnamed_addr constant [3 x i8] c"i8\00"
@.str979 = private unnamed_addr constant [11 x i8] c"trunc i32 \00"
@.str980 = private unnamed_addr constant [7 x i8] c" to i8\00"
@.str981 = private unnamed_addr constant [13 x i8] c"icmp ne i32 \00"
@.str982 = private unnamed_addr constant [4 x i8] c", 0\00"
@.str983 = private unnamed_addr constant [5 x i8] c"then\00"
@.str984 = private unnamed_addr constant [5 x i8] c"else\00"
@.str985 = private unnamed_addr constant [6 x i8] c"ifend\00"
@.str986 = private unnamed_addr constant [9 x i8] c"  br i1 \00"
@.str987 = private unnamed_addr constant [10 x i8] c", label %\00"
@.str988 = private unnamed_addr constant [10 x i8] c", label %\00"
@.str989 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str990 = private unnamed_addr constant [9 x i8] c"  br i1 \00"
@.str991 = private unnamed_addr constant [10 x i8] c", label %\00"
@.str992 = private unnamed_addr constant [10 x i8] c", label %\00"
@.str993 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str994 = private unnamed_addr constant [3 x i8] c":\0A\00"
@.str995 = private unnamed_addr constant [13 x i8] c"  br label %\00"
@.str996 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str997 = private unnamed_addr constant [3 x i8] c":\0A\00"
@.str998 = private unnamed_addr constant [13 x i8] c"  br label %\00"
@.str999 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str1000 = private unnamed_addr constant [3 x i8] c":\0A\00"
@.str1001 = private unnamed_addr constant [6 x i8] c"wcond\00"
@.str1002 = private unnamed_addr constant [6 x i8] c"wbody\00"
@.str1003 = private unnamed_addr constant [5 x i8] c"wend\00"
@.str1004 = private unnamed_addr constant [13 x i8] c"  br label %\00"
@.str1005 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str1006 = private unnamed_addr constant [3 x i8] c":\0A\00"
@.str1007 = private unnamed_addr constant [13 x i8] c"icmp ne i32 \00"
@.str1008 = private unnamed_addr constant [4 x i8] c", 0\00"
@.str1009 = private unnamed_addr constant [9 x i8] c"  br i1 \00"
@.str1010 = private unnamed_addr constant [10 x i8] c", label %\00"
@.str1011 = private unnamed_addr constant [10 x i8] c", label %\00"
@.str1012 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str1013 = private unnamed_addr constant [3 x i8] c":\0A\00"
@.str1014 = private unnamed_addr constant [13 x i8] c"  br label %\00"
@.str1015 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str1016 = private unnamed_addr constant [3 x i8] c":\0A\00"
@.str1017 = private unnamed_addr constant [4 x i8] c"i32\00"
@.str1018 = private unnamed_addr constant [4 x i8] c"i32\00"
@.str1019 = private unnamed_addr constant [4 x i8] c"int\00"
@.str1020 = private unnamed_addr constant [6 x i8] c"fcond\00"
@.str1021 = private unnamed_addr constant [6 x i8] c"fbody\00"
@.str1022 = private unnamed_addr constant [6 x i8] c"fcont\00"
@.str1023 = private unnamed_addr constant [5 x i8] c"fend\00"
@.str1024 = private unnamed_addr constant [13 x i8] c"  br label %\00"
@.str1025 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str1026 = private unnamed_addr constant [3 x i8] c":\0A\00"
@.str1027 = private unnamed_addr constant [15 x i8] c"load i32, ptr \00"
@.str1028 = private unnamed_addr constant [14 x i8] c"icmp slt i32 \00"
@.str1029 = private unnamed_addr constant [3 x i8] c", \00"
@.str1030 = private unnamed_addr constant [9 x i8] c"  br i1 \00"
@.str1031 = private unnamed_addr constant [10 x i8] c", label %\00"
@.str1032 = private unnamed_addr constant [10 x i8] c", label %\00"
@.str1033 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str1034 = private unnamed_addr constant [3 x i8] c":\0A\00"
@.str1035 = private unnamed_addr constant [13 x i8] c"  br label %\00"
@.str1036 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str1037 = private unnamed_addr constant [3 x i8] c":\0A\00"
@.str1038 = private unnamed_addr constant [15 x i8] c"load i32, ptr \00"
@.str1039 = private unnamed_addr constant [9 x i8] c"add i32 \00"
@.str1040 = private unnamed_addr constant [4 x i8] c", 1\00"
@.str1041 = private unnamed_addr constant [4 x i8] c"i32\00"
@.str1042 = private unnamed_addr constant [13 x i8] c"  br label %\00"
@.str1043 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str1044 = private unnamed_addr constant [3 x i8] c":\0A\00"
@.str1045 = private unnamed_addr constant [8 x i8] c"%retval\00"
@.str1046 = private unnamed_addr constant [17 x i8] c"  br label %ret\0A\00"
@.str1047 = private unnamed_addr constant [2 x i8] c"_\00"
@.str1048 = private unnamed_addr constant [5 x i8] c"mend\00"
@.str1049 = private unnamed_addr constant [2 x i8] c"0\00"
@.str1050 = private unnamed_addr constant [13 x i8] c"icmp eq i32 \00"
@.str1051 = private unnamed_addr constant [3 x i8] c", \00"
@.str1052 = private unnamed_addr constant [7 x i8] c"or i1 \00"
@.str1053 = private unnamed_addr constant [3 x i8] c", \00"
@.str1054 = private unnamed_addr constant [6 x i8] c"mbody\00"
@.str1055 = private unnamed_addr constant [5 x i8] c"marm\00"
@.str1056 = private unnamed_addr constant [9 x i8] c"  br i1 \00"
@.str1057 = private unnamed_addr constant [10 x i8] c", label %\00"
@.str1058 = private unnamed_addr constant [10 x i8] c", label %\00"
@.str1059 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str1060 = private unnamed_addr constant [3 x i8] c":\0A\00"
@.str1061 = private unnamed_addr constant [13 x i8] c"  br label %\00"
@.str1062 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str1063 = private unnamed_addr constant [3 x i8] c":\0A\00"
@.str1064 = private unnamed_addr constant [13 x i8] c"  br label %\00"
@.str1065 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str1066 = private unnamed_addr constant [3 x i8] c":\0A\00"
@.str1067 = private unnamed_addr constant [2 x i8] c"0\00"
@.str1068 = private unnamed_addr constant [4 x i8] c"ptr\00"
@.str1069 = private unnamed_addr constant [5 x i8] c"null\00"
@.str1070 = private unnamed_addr constant [13 x i8] c"  br label %\00"
@.str1071 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str1072 = private unnamed_addr constant [13 x i8] c"  br label %\00"
@.str1073 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str1074 = private unnamed_addr constant [22 x i8] c"cannot emit statement\00"
@.str1075 = private unnamed_addr constant [36 x i8] c"@L_running = internal global i32 1\0A\00"
@.str1076 = private unnamed_addr constant [32 x i8] c"@L_key = internal global i32 0\0A\00"
@.str1077 = private unnamed_addr constant [33 x i8] c"@L_entc = internal global i32 0\0A\00"
@.str1078 = private unnamed_addr constant [29 x i8] c"@L_alive = internal global [\00"
@.str1079 = private unnamed_addr constant [25 x i8] c" x i32] zeroinitializer\0A\00"
@.str1080 = private unnamed_addr constant [28 x i8] c"@L_kind = internal global [\00"
@.str1081 = private unnamed_addr constant [25 x i8] c" x i32] zeroinitializer\0A\00"
@.str1082 = private unnamed_addr constant [32 x i8] c"@L_freelist = internal global [\00"
@.str1083 = private unnamed_addr constant [25 x i8] c" x i32] zeroinitializer\0A\00"
@.str1084 = private unnamed_addr constant [34 x i8] c"@L_freen = internal global i32 0\0A\00"
@.str1085 = private unnamed_addr constant [4 x i8] c"@S_\00"
@.str1086 = private unnamed_addr constant [21 x i8] c" = internal global [\00"
@.str1087 = private unnamed_addr constant [9 x i8] c" x %Cmp_\00"
@.str1088 = private unnamed_addr constant [19 x i8] c"] zeroinitializer\0A\00"
@.str1089 = private unnamed_addr constant [4 x i8] c"@H_\00"
@.str1090 = private unnamed_addr constant [21 x i8] c" = internal global [\00"
@.str1091 = private unnamed_addr constant [24 x i8] c" x i8] zeroinitializer\0A\00"
@.str1092 = private unnamed_addr constant [5 x i8] c"@ME_\00"
@.str1093 = private unnamed_addr constant [26 x i8] c" = internal global i32 1\0A\00"
@.str1094 = private unnamed_addr constant [5 x i8] c"@HE_\00"
@.str1095 = private unnamed_addr constant [26 x i8] c" = internal global i32 1\0A\00"
@.str1096 = private unnamed_addr constant [39 x i8] c"define void @L_reset(i32 %e) {\0Aentry:\0A\00"
@.str1097 = private unnamed_addr constant [3 x i8] c"%h\00"
@.str1098 = private unnamed_addr constant [3 x i8] c"  \00"
@.str1099 = private unnamed_addr constant [28 x i8] c" = getelementptr inbounds [\00"
@.str1100 = private unnamed_addr constant [16 x i8] c" x i8], ptr @H_\00"
@.str1101 = private unnamed_addr constant [17 x i8] c", i32 0, i32 %e\0A\00"
@.str1102 = private unnamed_addr constant [19 x i8] c"  store i8 0, ptr \00"
@.str1103 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str1104 = private unnamed_addr constant [32 x i8] c"  %k = getelementptr inbounds [\00"
@.str1105 = private unnamed_addr constant [37 x i8] c" x i32], ptr @L_kind, i32 0, i32 %e\0A\00"
@.str1106 = private unnamed_addr constant [37 x i8] c"  store i32 0, ptr %k\0A  ret void\0A}\0A\0A\00"
@.str1107 = private unnamed_addr constant [32 x i8] c"define i32 @L_alloc() {\0Aentry:\0A\00"
@.str1108 = private unnamed_addr constant [32 x i8] c"  %fn = load i32, ptr @L_freen\0A\00"
@.str1109 = private unnamed_addr constant [30 x i8] c"  %has = icmp sgt i32 %fn, 0\0A\00"
@.str1110 = private unnamed_addr constant [42 x i8] c"  br i1 %has, label %reuse, label %fresh\0A\00"
@.str1111 = private unnamed_addr constant [8 x i8] c"reuse:\0A\00"
@.str1112 = private unnamed_addr constant [25 x i8] c"  %fn1 = sub i32 %fn, 1\0A\00"
@.str1113 = private unnamed_addr constant [32 x i8] c"  store i32 %fn1, ptr @L_freen\0A\00"
@.str1114 = private unnamed_addr constant [33 x i8] c"  %fp = getelementptr inbounds [\00"
@.str1115 = private unnamed_addr constant [43 x i8] c" x i32], ptr @L_freelist, i32 0, i32 %fn1\0A\00"
@.str1116 = private unnamed_addr constant [27 x i8] c"  %re = load i32, ptr %fp\0A\00"
@.str1117 = private unnamed_addr constant [18 x i8] c"  br label %done\0A\00"
@.str1118 = private unnamed_addr constant [8 x i8] c"fresh:\0A\00"
@.str1119 = private unnamed_addr constant [31 x i8] c"  %ec = load i32, ptr @L_entc\0A\00"
@.str1120 = private unnamed_addr constant [25 x i8] c"  %ec1 = add i32 %ec, 1\0A\00"
@.str1121 = private unnamed_addr constant [31 x i8] c"  store i32 %ec1, ptr @L_entc\0A\00"
@.str1122 = private unnamed_addr constant [18 x i8] c"  br label %done\0A\00"
@.str1123 = private unnamed_addr constant [7 x i8] c"done:\0A\00"
@.str1124 = private unnamed_addr constant [49 x i8] c"  %e = phi i32 [ %re, %reuse ], [ %ec, %fresh ]\0A\00"
@.str1125 = private unnamed_addr constant [30 x i8] c"  call void @L_reset(i32 %e)\0A\00"
@.str1126 = private unnamed_addr constant [33 x i8] c"  %ap = getelementptr inbounds [\00"
@.str1127 = private unnamed_addr constant [38 x i8] c" x i32], ptr @L_alive, i32 0, i32 %e\0A\00"
@.str1128 = private unnamed_addr constant [24 x i8] c"  store i32 1, ptr %ap\0A\00"
@.str1129 = private unnamed_addr constant [17 x i8] c"  ret i32 %e\0A}\0A\0A\00"
@.str1130 = private unnamed_addr constant [45 x i8] c"define void @L_free_entity(i32 %e) {\0Aentry:\0A\00"
@.str1131 = private unnamed_addr constant [33 x i8] c"  %ap = getelementptr inbounds [\00"
@.str1132 = private unnamed_addr constant [38 x i8] c" x i32], ptr @L_alive, i32 0, i32 %e\0A\00"
@.str1133 = private unnamed_addr constant [24 x i8] c"  store i32 0, ptr %ap\0A\00"
@.str1134 = private unnamed_addr constant [30 x i8] c"  call void @L_reset(i32 %e)\0A\00"
@.str1135 = private unnamed_addr constant [32 x i8] c"  %fn = load i32, ptr @L_freen\0A\00"
@.str1136 = private unnamed_addr constant [33 x i8] c"  %fp = getelementptr inbounds [\00"
@.str1137 = private unnamed_addr constant [42 x i8] c" x i32], ptr @L_freelist, i32 0, i32 %fn\0A\00"
@.str1138 = private unnamed_addr constant [25 x i8] c"  store i32 %e, ptr %fp\0A\00"
@.str1139 = private unnamed_addr constant [25 x i8] c"  %fn1 = add i32 %fn, 1\0A\00"
@.str1140 = private unnamed_addr constant [32 x i8] c"  store i32 %fn1, ptr @L_freen\0A\00"
@.str1141 = private unnamed_addr constant [15 x i8] c"  ret void\0A}\0A\0A\00"
@.str1142 = private unnamed_addr constant [4 x i8] c"i32\00"
@.str1143 = private unnamed_addr constant [4 x i8] c"i32\00"
@.str1144 = private unnamed_addr constant [2 x i8] c"0\00"
@.str1145 = private unnamed_addr constant [6 x i8] c"qcond\00"
@.str1146 = private unnamed_addr constant [6 x i8] c"qbody\00"
@.str1147 = private unnamed_addr constant [6 x i8] c"qnext\00"
@.str1148 = private unnamed_addr constant [5 x i8] c"qend\00"
@.str1149 = private unnamed_addr constant [13 x i8] c"  br label %\00"
@.str1150 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str1151 = private unnamed_addr constant [3 x i8] c":\0A\00"
@.str1152 = private unnamed_addr constant [15 x i8] c"load i32, ptr \00"
@.str1153 = private unnamed_addr constant [22 x i8] c"load i32, ptr @L_entc\00"
@.str1154 = private unnamed_addr constant [14 x i8] c"icmp slt i32 \00"
@.str1155 = private unnamed_addr constant [3 x i8] c", \00"
@.str1156 = private unnamed_addr constant [9 x i8] c"  br i1 \00"
@.str1157 = private unnamed_addr constant [10 x i8] c", label %\00"
@.str1158 = private unnamed_addr constant [10 x i8] c", label %\00"
@.str1159 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str1160 = private unnamed_addr constant [3 x i8] c":\0A\00"
@.str1161 = private unnamed_addr constant [15 x i8] c"load i32, ptr \00"
@.str1162 = private unnamed_addr constant [3 x i8] c"  \00"
@.str1163 = private unnamed_addr constant [28 x i8] c" = getelementptr inbounds [\00"
@.str1164 = private unnamed_addr constant [35 x i8] c" x i32], ptr @L_alive, i32 0, i32 \00"
@.str1165 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str1166 = private unnamed_addr constant [15 x i8] c"load i32, ptr \00"
@.str1167 = private unnamed_addr constant [13 x i8] c"icmp ne i32 \00"
@.str1168 = private unnamed_addr constant [4 x i8] c", 0\00"
@.str1169 = private unnamed_addr constant [3 x i8] c"qa\00"
@.str1170 = private unnamed_addr constant [9 x i8] c"  br i1 \00"
@.str1171 = private unnamed_addr constant [10 x i8] c", label %\00"
@.str1172 = private unnamed_addr constant [10 x i8] c", label %\00"
@.str1173 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str1174 = private unnamed_addr constant [3 x i8] c":\0A\00"
@.str1175 = private unnamed_addr constant [2 x i8] c"0\00"
@.str1176 = private unnamed_addr constant [3 x i8] c"  \00"
@.str1177 = private unnamed_addr constant [28 x i8] c" = getelementptr inbounds [\00"
@.str1178 = private unnamed_addr constant [34 x i8] c" x i32], ptr @L_kind, i32 0, i32 \00"
@.str1179 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str1180 = private unnamed_addr constant [15 x i8] c"load i32, ptr \00"
@.str1181 = private unnamed_addr constant [13 x i8] c"icmp eq i32 \00"
@.str1182 = private unnamed_addr constant [3 x i8] c", \00"
@.str1183 = private unnamed_addr constant [19 x i8] c"load i32, ptr @ME_\00"
@.str1184 = private unnamed_addr constant [13 x i8] c"icmp ne i32 \00"
@.str1185 = private unnamed_addr constant [4 x i8] c", 0\00"
@.str1186 = private unnamed_addr constant [8 x i8] c"and i1 \00"
@.str1187 = private unnamed_addr constant [3 x i8] c", \00"
@.str1188 = private unnamed_addr constant [3 x i8] c"  \00"
@.str1189 = private unnamed_addr constant [28 x i8] c" = getelementptr inbounds [\00"
@.str1190 = private unnamed_addr constant [16 x i8] c" x i8], ptr @H_\00"
@.str1191 = private unnamed_addr constant [14 x i8] c", i32 0, i32 \00"
@.str1192 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str1193 = private unnamed_addr constant [14 x i8] c"load i8, ptr \00"
@.str1194 = private unnamed_addr constant [12 x i8] c"icmp ne i8 \00"
@.str1195 = private unnamed_addr constant [4 x i8] c", 0\00"
@.str1196 = private unnamed_addr constant [3 x i8] c"qt\00"
@.str1197 = private unnamed_addr constant [9 x i8] c"  br i1 \00"
@.str1198 = private unnamed_addr constant [10 x i8] c", label %\00"
@.str1199 = private unnamed_addr constant [10 x i8] c", label %\00"
@.str1200 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str1201 = private unnamed_addr constant [3 x i8] c":\0A\00"
@.str1202 = private unnamed_addr constant [3 x i8] c"  \00"
@.str1203 = private unnamed_addr constant [28 x i8] c" = getelementptr inbounds [\00"
@.str1204 = private unnamed_addr constant [9 x i8] c" x %Cmp_\00"
@.str1205 = private unnamed_addr constant [11 x i8] c"], ptr @S_\00"
@.str1206 = private unnamed_addr constant [14 x i8] c", i32 0, i32 \00"
@.str1207 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str1208 = private unnamed_addr constant [4 x i8] c"ptr\00"
@.str1209 = private unnamed_addr constant [13 x i8] c"  store ptr \00"
@.str1210 = private unnamed_addr constant [7 x i8] c", ptr \00"
@.str1211 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str1212 = private unnamed_addr constant [13 x i8] c"icmp ne i32 \00"
@.str1213 = private unnamed_addr constant [4 x i8] c", 0\00"
@.str1214 = private unnamed_addr constant [3 x i8] c"qw\00"
@.str1215 = private unnamed_addr constant [9 x i8] c"  br i1 \00"
@.str1216 = private unnamed_addr constant [10 x i8] c", label %\00"
@.str1217 = private unnamed_addr constant [10 x i8] c", label %\00"
@.str1218 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str1219 = private unnamed_addr constant [3 x i8] c":\0A\00"
@.str1220 = private unnamed_addr constant [13 x i8] c"  br label %\00"
@.str1221 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str1222 = private unnamed_addr constant [3 x i8] c":\0A\00"
@.str1223 = private unnamed_addr constant [15 x i8] c"load i32, ptr \00"
@.str1224 = private unnamed_addr constant [9 x i8] c"add i32 \00"
@.str1225 = private unnamed_addr constant [4 x i8] c", 1\00"
@.str1226 = private unnamed_addr constant [4 x i8] c"i32\00"
@.str1227 = private unnamed_addr constant [13 x i8] c"  br label %\00"
@.str1228 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str1229 = private unnamed_addr constant [3 x i8] c":\0A\00"
@.str1230 = private unnamed_addr constant [25 x i8] c"spawn: unknown property \00"
@.str1231 = private unnamed_addr constant [3 x i8] c"  \00"
@.str1232 = private unnamed_addr constant [28 x i8] c" = getelementptr inbounds [\00"
@.str1233 = private unnamed_addr constant [16 x i8] c" x i8], ptr @H_\00"
@.str1234 = private unnamed_addr constant [14 x i8] c", i32 0, i32 \00"
@.str1235 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str1236 = private unnamed_addr constant [19 x i8] c"  store i8 1, ptr \00"
@.str1237 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str1238 = private unnamed_addr constant [3 x i8] c"  \00"
@.str1239 = private unnamed_addr constant [28 x i8] c" = getelementptr inbounds [\00"
@.str1240 = private unnamed_addr constant [9 x i8] c" x %Cmp_\00"
@.str1241 = private unnamed_addr constant [11 x i8] c"], ptr @S_\00"
@.str1242 = private unnamed_addr constant [14 x i8] c", i32 0, i32 \00"
@.str1243 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str1244 = private unnamed_addr constant [3 x i8] c"  \00"
@.str1245 = private unnamed_addr constant [32 x i8] c" = getelementptr inbounds %Cmp_\00"
@.str1246 = private unnamed_addr constant [7 x i8] c", ptr \00"
@.str1247 = private unnamed_addr constant [14 x i8] c", i32 0, i32 \00"
@.str1248 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str1249 = private unnamed_addr constant [2 x i8] c"0\00"
@.str1250 = private unnamed_addr constant [4 x i8] c"ptr\00"
@.str1251 = private unnamed_addr constant [5 x i8] c"null\00"
@.str1252 = private unnamed_addr constant [9 x i8] c"  store \00"
@.str1253 = private unnamed_addr constant [2 x i8] c" \00"
@.str1254 = private unnamed_addr constant [7 x i8] c", ptr \00"
@.str1255 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str1256 = private unnamed_addr constant [3 x i8] c"  \00"
@.str1257 = private unnamed_addr constant [32 x i8] c" = getelementptr inbounds %Cmp_\00"
@.str1258 = private unnamed_addr constant [7 x i8] c", ptr \00"
@.str1259 = private unnamed_addr constant [14 x i8] c", i32 0, i32 \00"
@.str1260 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str1261 = private unnamed_addr constant [9 x i8] c"  store \00"
@.str1262 = private unnamed_addr constant [2 x i8] c" \00"
@.str1263 = private unnamed_addr constant [7 x i8] c", ptr \00"
@.str1264 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str1265 = private unnamed_addr constant [4 x i8] c"ptr\00"
@.str1266 = private unnamed_addr constant [13 x i8] c"  store ptr \00"
@.str1267 = private unnamed_addr constant [7 x i8] c", ptr \00"
@.str1268 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str1269 = private unnamed_addr constant [3 x i8] c"  \00"
@.str1270 = private unnamed_addr constant [28 x i8] c" = getelementptr inbounds [\00"
@.str1271 = private unnamed_addr constant [9 x i8] c" x %Cmp_\00"
@.str1272 = private unnamed_addr constant [11 x i8] c"], ptr @S_\00"
@.str1273 = private unnamed_addr constant [14 x i8] c", i32 0, i32 \00"
@.str1274 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str1275 = private unnamed_addr constant [4 x i8] c"ptr\00"
@.str1276 = private unnamed_addr constant [13 x i8] c"  store ptr \00"
@.str1277 = private unnamed_addr constant [7 x i8] c", ptr \00"
@.str1278 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str1279 = private unnamed_addr constant [20 x i8] c"call i32 @L_alloc()\00"
@.str1280 = private unnamed_addr constant [3 x i8] c"  \00"
@.str1281 = private unnamed_addr constant [28 x i8] c" = getelementptr inbounds [\00"
@.str1282 = private unnamed_addr constant [34 x i8] c" x i32], ptr @L_kind, i32 0, i32 \00"
@.str1283 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str1284 = private unnamed_addr constant [13 x i8] c"  store i32 \00"
@.str1285 = private unnamed_addr constant [7 x i8] c", ptr \00"
@.str1286 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str1287 = private unnamed_addr constant [3 x i8] c"  \00"
@.str1288 = private unnamed_addr constant [28 x i8] c" = getelementptr inbounds [\00"
@.str1289 = private unnamed_addr constant [34 x i8] c" x i32], ptr @L_kind, i32 0, i32 \00"
@.str1290 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str1291 = private unnamed_addr constant [15 x i8] c"load i32, ptr \00"
@.str1292 = private unnamed_addr constant [13 x i8] c"icmp eq i32 \00"
@.str1293 = private unnamed_addr constant [3 x i8] c", \00"
@.str1294 = private unnamed_addr constant [3 x i8] c"dh\00"
@.str1295 = private unnamed_addr constant [4 x i8] c"dhn\00"
@.str1296 = private unnamed_addr constant [9 x i8] c"  br i1 \00"
@.str1297 = private unnamed_addr constant [10 x i8] c", label %\00"
@.str1298 = private unnamed_addr constant [10 x i8] c", label %\00"
@.str1299 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str1300 = private unnamed_addr constant [27 x i8] c":\0A  call void @on_despawn_\00"
@.str1301 = private unnamed_addr constant [6 x i8] c"(i32 \00"
@.str1302 = private unnamed_addr constant [3 x i8] c")\0A\00"
@.str1303 = private unnamed_addr constant [13 x i8] c"  br label %\00"
@.str1304 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str1305 = private unnamed_addr constant [3 x i8] c":\0A\00"
@.str1306 = private unnamed_addr constant [32 x i8] c"  call void @L_free_entity(i32 \00"
@.str1307 = private unnamed_addr constant [3 x i8] c")\0A\00"
@.str1308 = private unnamed_addr constant [2 x i8] c"0\00"
@.str1309 = private unnamed_addr constant [2 x i8] c"1\00"
@.str1310 = private unnamed_addr constant [3 x i8] c"  \00"
@.str1311 = private unnamed_addr constant [28 x i8] c" = getelementptr inbounds [\00"
@.str1312 = private unnamed_addr constant [16 x i8] c" x i8], ptr @H_\00"
@.str1313 = private unnamed_addr constant [14 x i8] c", i32 0, i32 \00"
@.str1314 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str1315 = private unnamed_addr constant [12 x i8] c"  store i8 \00"
@.str1316 = private unnamed_addr constant [7 x i8] c", ptr \00"
@.str1317 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str1318 = private unnamed_addr constant [3 x i8] c"  \00"
@.str1319 = private unnamed_addr constant [28 x i8] c" = getelementptr inbounds [\00"
@.str1320 = private unnamed_addr constant [9 x i8] c" x %Cmp_\00"
@.str1321 = private unnamed_addr constant [11 x i8] c"], ptr @S_\00"
@.str1322 = private unnamed_addr constant [14 x i8] c", i32 0, i32 \00"
@.str1323 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str1324 = private unnamed_addr constant [4 x i8] c"ptr\00"
@.str1325 = private unnamed_addr constant [13 x i8] c"  store ptr \00"
@.str1326 = private unnamed_addr constant [7 x i8] c", ptr \00"
@.str1327 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str1328 = private unnamed_addr constant [5 x i8] c"@HE_\00"
@.str1329 = private unnamed_addr constant [5 x i8] c"@ME_\00"
@.str1330 = private unnamed_addr constant [13 x i8] c"  store i32 \00"
@.str1331 = private unnamed_addr constant [7 x i8] c", ptr \00"
@.str1332 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str1333 = private unnamed_addr constant [5 x i8] c"void\00"
@.str1334 = private unnamed_addr constant [17 x i8] c"  br label %ret\0A\00"
@.str1335 = private unnamed_addr constant [17 x i8] c"ret:\0A  ret void\0A\00"
@.str1336 = private unnamed_addr constant [18 x i8] c"define void @sys_\00"
@.str1337 = private unnamed_addr constant [13 x i8] c"() {\0Aentry:\0A\00"
@.str1338 = private unnamed_addr constant [4 x i8] c"}\0A\0A\00"
@.str1339 = private unnamed_addr constant [19 x i8] c"load i32, ptr @HE_\00"
@.str1340 = private unnamed_addr constant [13 x i8] c"icmp ne i32 \00"
@.str1341 = private unnamed_addr constant [4 x i8] c", 0\00"
@.str1342 = private unnamed_addr constant [5 x i8] c"hrun\00"
@.str1343 = private unnamed_addr constant [6 x i8] c"hskip\00"
@.str1344 = private unnamed_addr constant [9 x i8] c"  br i1 \00"
@.str1345 = private unnamed_addr constant [10 x i8] c", label %\00"
@.str1346 = private unnamed_addr constant [10 x i8] c", label %\00"
@.str1347 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str1348 = private unnamed_addr constant [20 x i8] c":\0A  call void @sys_\00"
@.str1349 = private unnamed_addr constant [4 x i8] c"()\0A\00"
@.str1350 = private unnamed_addr constant [13 x i8] c"  br label %\00"
@.str1351 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str1352 = private unnamed_addr constant [3 x i8] c":\0A\00"
@.str1353 = private unnamed_addr constant [5 x i8] c"void\00"
@.str1354 = private unnamed_addr constant [3 x i8] c"%e\00"
@.str1355 = private unnamed_addr constant [17 x i8] c"  br label %ret\0A\00"
@.str1356 = private unnamed_addr constant [17 x i8] c"ret:\0A  ret void\0A\00"
@.str1357 = private unnamed_addr constant [25 x i8] c"define void @on_despawn_\00"
@.str1358 = private unnamed_addr constant [19 x i8] c"(i32 %e) {\0Aentry:\0A\00"
@.str1359 = private unnamed_addr constant [4 x i8] c"}\0A\0A\00"
@.str1360 = private unnamed_addr constant [49 x i8] c"define i32 @main(i32 %argc, ptr %argv) {\0Aentry:\0A\00"
@.str1361 = private unnamed_addr constant [32 x i8] c"  store i32 %argc, ptr @L_argc\0A\00"
@.str1362 = private unnamed_addr constant [32 x i8] c"  store ptr %argv, ptr @L_argv\0A\00"
@.str1363 = private unnamed_addr constant [8 x i8] c"rt_init\00"
@.str1364 = private unnamed_addr constant [27 x i8] c"  call void @fn_rt_init()\0A\00"
@.str1365 = private unnamed_addr constant [6 x i8] c"Start\00"
@.str1366 = private unnamed_addr constant [18 x i8] c"  br label %loop\0A\00"
@.str1367 = private unnamed_addr constant [7 x i8] c"loop:\0A\00"
@.str1368 = private unnamed_addr constant [25 x i8] c"load i32, ptr @L_running\00"
@.str1369 = private unnamed_addr constant [13 x i8] c"icmp ne i32 \00"
@.str1370 = private unnamed_addr constant [4 x i8] c", 0\00"
@.str1371 = private unnamed_addr constant [11 x i8] c"rt_running\00"
@.str1372 = private unnamed_addr constant [26 x i8] c"call i32 @fn_rt_running()\00"
@.str1373 = private unnamed_addr constant [13 x i8] c"icmp ne i32 \00"
@.str1374 = private unnamed_addr constant [4 x i8] c", 0\00"
@.str1375 = private unnamed_addr constant [8 x i8] c"and i1 \00"
@.str1376 = private unnamed_addr constant [3 x i8] c", \00"
@.str1377 = private unnamed_addr constant [9 x i8] c"  br i1 \00"
@.str1378 = private unnamed_addr constant [28 x i8] c", label %body, label %done\0A\00"
@.str1379 = private unnamed_addr constant [9 x i8] c"  br i1 \00"
@.str1380 = private unnamed_addr constant [28 x i8] c", label %body, label %done\0A\00"
@.str1381 = private unnamed_addr constant [7 x i8] c"body:\0A\00"
@.str1382 = private unnamed_addr constant [8 x i8] c"rt_poll\00"
@.str1383 = private unnamed_addr constant [23 x i8] c"call i32 @fn_rt_poll()\00"
@.str1384 = private unnamed_addr constant [13 x i8] c"  store i32 \00"
@.str1385 = private unnamed_addr constant [14 x i8] c", ptr @L_key\0A\00"
@.str1386 = private unnamed_addr constant [6 x i8] c"Input\00"
@.str1387 = private unnamed_addr constant [12 x i8] c"FixedUpdate\00"
@.str1388 = private unnamed_addr constant [7 x i8] c"Update\00"
@.str1389 = private unnamed_addr constant [11 x i8] c"LateUpdate\00"
@.str1390 = private unnamed_addr constant [7 x i8] c"Render\00"
@.str1391 = private unnamed_addr constant [18 x i8] c"  br label %loop\0A\00"
@.str1392 = private unnamed_addr constant [7 x i8] c"done:\0A\00"
@.str1393 = private unnamed_addr constant [7 x i8] c"OnQuit\00"
@.str1394 = private unnamed_addr constant [12 x i8] c"rt_shutdown\00"
@.str1395 = private unnamed_addr constant [31 x i8] c"  call void @fn_rt_shutdown()\0A\00"
@.str1396 = private unnamed_addr constant [15 x i8] c"  ret i32 0\0A}\0A\00"
@.str1397 = private unnamed_addr constant [25 x i8] c"call i32 @fn_rt_reg(i32 \00"
@.str1398 = private unnamed_addr constant [2 x i8] c")\00"
@.str1399 = private unnamed_addr constant [6 x i8] c"smend\00"
@.str1400 = private unnamed_addr constant [13 x i8] c"icmp eq i32 \00"
@.str1401 = private unnamed_addr constant [3 x i8] c", \00"
@.str1402 = private unnamed_addr constant [6 x i8] c"sbody\00"
@.str1403 = private unnamed_addr constant [5 x i8] c"sarm\00"
@.str1404 = private unnamed_addr constant [9 x i8] c"  br i1 \00"
@.str1405 = private unnamed_addr constant [10 x i8] c", label %\00"
@.str1406 = private unnamed_addr constant [10 x i8] c", label %\00"
@.str1407 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str1408 = private unnamed_addr constant [3 x i8] c":\0A\00"
@.str1409 = private unnamed_addr constant [13 x i8] c"  br label %\00"
@.str1410 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str1411 = private unnamed_addr constant [3 x i8] c":\0A\00"
@.str1412 = private unnamed_addr constant [13 x i8] c"  br label %\00"
@.str1413 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str1414 = private unnamed_addr constant [3 x i8] c":\0A\00"
@.str1415 = private unnamed_addr constant [27 x i8] c"'become' outside a machine\00"
@.str1416 = private unnamed_addr constant [18 x i8] c"become: no state \00"
@.str1417 = private unnamed_addr constant [32 x i8] c"  call void @fn_rt_set_reg(i32 \00"
@.str1418 = private unnamed_addr constant [7 x i8] c", i32 \00"
@.str1419 = private unnamed_addr constant [3 x i8] c")\0A\00"
@.str1420 = private unnamed_addr constant [4 x i8] c"%io\00"
@.str1421 = private unnamed_addr constant [3 x i8] c"  \00"
@.str1422 = private unnamed_addr constant [14 x i8] c" = call i64 @\00"
@.str1423 = private unnamed_addr constant [6 x i8] c"(ptr \00"
@.str1424 = private unnamed_addr constant [14 x i8] c", i64 1, i64 \00"
@.str1425 = private unnamed_addr constant [11 x i8] c", ptr %f)\0A\00"
@.str1426 = private unnamed_addr constant [8 x i8] c"@L_entc\00"
@.str1427 = private unnamed_addr constant [2 x i8] c"4\00"
@.str1428 = private unnamed_addr constant [9 x i8] c"@L_freen\00"
@.str1429 = private unnamed_addr constant [2 x i8] c"4\00"
@.str1430 = private unnamed_addr constant [21 x i8] c"  %nalive = mul i64 \00"
@.str1431 = private unnamed_addr constant [5 x i8] c", 4\0A\00"
@.str1432 = private unnamed_addr constant [9 x i8] c"@L_alive\00"
@.str1433 = private unnamed_addr constant [8 x i8] c"%nalive\00"
@.str1434 = private unnamed_addr constant [12 x i8] c"@L_freelist\00"
@.str1435 = private unnamed_addr constant [8 x i8] c"%nalive\00"
@.str1436 = private unnamed_addr constant [8 x i8] c"@L_kind\00"
@.str1437 = private unnamed_addr constant [8 x i8] c"%nalive\00"
@.str1438 = private unnamed_addr constant [4 x i8] c"@g_\00"
@.str1439 = private unnamed_addr constant [2 x i8] c"4\00"
@.str1440 = private unnamed_addr constant [5 x i8] c"%csz\00"
@.str1441 = private unnamed_addr constant [3 x i8] c"  \00"
@.str1442 = private unnamed_addr constant [37 x i8] c" = ptrtoint ptr getelementptr (%Cmp_\00"
@.str1443 = private unnamed_addr constant [17 x i8] c", ptr null, i32 \00"
@.str1444 = private unnamed_addr constant [10 x i8] c") to i64\0A\00"
@.str1445 = private unnamed_addr constant [4 x i8] c"@S_\00"
@.str1446 = private unnamed_addr constant [4 x i8] c"@H_\00"
@.str1447 = private unnamed_addr constant [70 x i8] c"@.sav_path = private unnamed_addr constant [10 x i8] c\22ludic.sav\5C00\22\0A\00"
@.str1448 = private unnamed_addr constant [60 x i8] c"@.sav_wb = private unnamed_addr constant [3 x i8] c\22wb\5C00\22\0A\00"
@.str1449 = private unnamed_addr constant [60 x i8] c"@.sav_rb = private unnamed_addr constant [3 x i8] c\22rb\5C00\22\0A\00"
@.str1450 = private unnamed_addr constant [14 x i8] c"rt_save_state\00"
@.str1451 = private unnamed_addr constant [14 x i8] c"rt_load_state\00"
@.str1452 = private unnamed_addr constant [32 x i8] c"define void @L_save() {\0Aentry:\0A\00"
@.str1453 = private unnamed_addr constant [54 x i8] c"  %f = call ptr @fopen(ptr @.sav_path, ptr @.sav_wb)\0A\00"
@.str1454 = private unnamed_addr constant [31 x i8] c"  %bad = icmp eq ptr %f, null\0A\00"
@.str1455 = private unnamed_addr constant [41 x i8] c"  br i1 %bad, label %out, label %go\0Ago:\0A\00"
@.str1456 = private unnamed_addr constant [7 x i8] c"fwrite\00"
@.str1457 = private unnamed_addr constant [39 x i8] c"  call void @fn_rt_save_state(ptr %f)\0A\00"
@.str1458 = private unnamed_addr constant [68 x i8] c"  %c = call i32 @fclose(ptr %f)\0A  br label %out\0Aout:\0A  ret void\0A}\0A\0A\00"
@.str1459 = private unnamed_addr constant [31 x i8] c"define i32 @L_load() {\0Aentry:\0A\00"
@.str1460 = private unnamed_addr constant [54 x i8] c"  %f = call ptr @fopen(ptr @.sav_path, ptr @.sav_rb)\0A\00"
@.str1461 = private unnamed_addr constant [31 x i8] c"  %bad = icmp eq ptr %f, null\0A\00"
@.str1462 = private unnamed_addr constant [60 x i8] c"  br i1 %bad, label %miss, label %go\0Amiss:\0A  ret i32 0\0Ago:\0A\00"
@.str1463 = private unnamed_addr constant [6 x i8] c"fread\00"
@.str1464 = private unnamed_addr constant [39 x i8] c"  call void @fn_rt_load_state(ptr %f)\0A\00"
@.str1465 = private unnamed_addr constant [48 x i8] c"  %c = call i32 @fclose(ptr %f)\0A  ret i32 1\0A}\0A\0A\00"
@.str1466 = private unnamed_addr constant [6 x i8] c"panel\00"
@.str1467 = private unnamed_addr constant [4 x i8] c"col\00"
@.str1468 = private unnamed_addr constant [4 x i8] c"row\00"
@.str1469 = private unnamed_addr constant [6 x i8] c"label\00"
@.str1470 = private unnamed_addr constant [7 x i8] c"button\00"
@.str1471 = private unnamed_addr constant [6 x i8] c"image\00"
@.str1472 = private unnamed_addr constant [7 x i8] c"spacer\00"
@.str1473 = private unnamed_addr constant [3 x i8] c"id\00"
@.str1474 = private unnamed_addr constant [31 x i8] c"  call void @fn_rt_ui_set(i32 \00"
@.str1475 = private unnamed_addr constant [7 x i8] c", i32 \00"
@.str1476 = private unnamed_addr constant [7 x i8] c", i32 \00"
@.str1477 = private unnamed_addr constant [3 x i8] c")\0A\00"
@.str1478 = private unnamed_addr constant [2 x i8] c"w\00"
@.str1479 = private unnamed_addr constant [2 x i8] c"h\00"
@.str1480 = private unnamed_addr constant [2 x i8] c"x\00"
@.str1481 = private unnamed_addr constant [2 x i8] c"y\00"
@.str1482 = private unnamed_addr constant [4 x i8] c"pad\00"
@.str1483 = private unnamed_addr constant [4 x i8] c"gap\00"
@.str1484 = private unnamed_addr constant [3 x i8] c"bg\00"
@.str1485 = private unnamed_addr constant [3 x i8] c"fg\00"
@.str1486 = private unnamed_addr constant [7 x i8] c"border\00"
@.str1487 = private unnamed_addr constant [5 x i8] c"grow\00"
@.str1488 = private unnamed_addr constant [5 x i8] c"font\00"
@.str1489 = private unnamed_addr constant [5 x i8] c"size\00"
@.str1490 = private unnamed_addr constant [6 x i8] c"inset\00"
@.str1491 = private unnamed_addr constant [6 x i8] c"focus\00"
@.str1492 = private unnamed_addr constant [33 x i8] c"  call void @fn_rt_ui_reset(i32 \00"
@.str1493 = private unnamed_addr constant [3 x i8] c")\0A\00"
@.str1494 = private unnamed_addr constant [2 x i8] c"1\00"
@.str1495 = private unnamed_addr constant [3 x i8] c"id\00"
@.str1496 = private unnamed_addr constant [5 x i8] c"text\00"
@.str1497 = private unnamed_addr constant [39 x i8] c"  call void @fn_rt_ui_static_text(i32 \00"
@.str1498 = private unnamed_addr constant [7 x i8] c", ptr \00"
@.str1499 = private unnamed_addr constant [3 x i8] c")\0A\00"
@.str1500 = private unnamed_addr constant [5 x i8] c"skin\00"
@.str1501 = private unnamed_addr constant [6 x i8] c"image\00"
@.str1502 = private unnamed_addr constant [32 x i8] c"call i32 @fn_rt_image_load(ptr \00"
@.str1503 = private unnamed_addr constant [2 x i8] c")\00"
@.str1504 = private unnamed_addr constant [5 x i8] c"skin\00"
@.str1505 = private unnamed_addr constant [6 x i8] c"align\00"
@.str1506 = private unnamed_addr constant [7 x i8] c"center\00"
@.str1507 = private unnamed_addr constant [4 x i8] c"end\00"
@.str1508 = private unnamed_addr constant [2 x i8] c"1\00"
@.str1509 = private unnamed_addr constant [34 x i8] c"define void @ui_build() {\0Aentry:\0A\00"
@.str1510 = private unnamed_addr constant [15 x i8] c"  ret void\0A}\0A\0A\00"
@.str1511 = private unnamed_addr constant [3 x i8] c", \00"
@.str1512 = private unnamed_addr constant [7 x i8] c" %arg_\00"
@.str1513 = private unnamed_addr constant [5 x i8] c"void\00"
@.str1514 = private unnamed_addr constant [20 x i8] c"  %retval = alloca \00"
@.str1515 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str1516 = private unnamed_addr constant [9 x i8] c"  store \00"
@.str1517 = private unnamed_addr constant [7 x i8] c" %arg_\00"
@.str1518 = private unnamed_addr constant [7 x i8] c", ptr \00"
@.str1519 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str1520 = private unnamed_addr constant [17 x i8] c"  br label %ret\0A\00"
@.str1521 = private unnamed_addr constant [6 x i8] c"ret:\0A\00"
@.str1522 = private unnamed_addr constant [5 x i8] c"void\00"
@.str1523 = private unnamed_addr constant [12 x i8] c"  ret void\0A\00"
@.str1524 = private unnamed_addr constant [6 x i8] c"load \00"
@.str1525 = private unnamed_addr constant [14 x i8] c", ptr %retval\00"
@.str1526 = private unnamed_addr constant [7 x i8] c"  ret \00"
@.str1527 = private unnamed_addr constant [2 x i8] c" \00"
@.str1528 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str1529 = private unnamed_addr constant [8 x i8] c"define \00"
@.str1530 = private unnamed_addr constant [6 x i8] c" @fn_\00"
@.str1531 = private unnamed_addr constant [2 x i8] c"(\00"
@.str1532 = private unnamed_addr constant [12 x i8] c") {\0Aentry:\0A\00"
@.str1533 = private unnamed_addr constant [4 x i8] c"}\0A\0A\00"
@.str1534 = private unnamed_addr constant [4 x i8] c"int\00"
@.str1535 = private unnamed_addr constant [24 x i8] c"  %retval = alloca i32\0A\00"
@.str1536 = private unnamed_addr constant [32 x i8] c"  store i32 %argc, ptr @L_argc\0A\00"
@.str1537 = private unnamed_addr constant [32 x i8] c"  store ptr %argv, ptr @L_argv\0A\00"
@.str1538 = private unnamed_addr constant [28 x i8] c"  store i32 0, ptr %retval\0A\00"
@.str1539 = private unnamed_addr constant [17 x i8] c"  br label %ret\0A\00"
@.str1540 = private unnamed_addr constant [6 x i8] c"ret:\0A\00"
@.str1541 = private unnamed_addr constant [22 x i8] c"load i32, ptr %retval\00"
@.str1542 = private unnamed_addr constant [11 x i8] c"  ret i32 \00"
@.str1543 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str1544 = private unnamed_addr constant [49 x i8] c"define i32 @main(i32 %argc, ptr %argv) {\0Aentry:\0A\00"
@.str1545 = private unnamed_addr constant [3 x i8] c"}\0A\00"
@.str1546 = private unnamed_addr constant [3 x i8] c"wb\00"
@.str1547 = private unnamed_addr constant [7 x i8] c".ludic\00"
@.str1548 = private unnamed_addr constant [2 x i8] c"/\00"
@.str1549 = private unnamed_addr constant [6 x i8] c"ludic\00"
@.str1550 = private unnamed_addr constant [11 x i8] c"--windowed\00"
@.str1551 = private unnamed_addr constant [11 x i8] c"--headless\00"
@.str1552 = private unnamed_addr constant [12 x i8] c"--emit-llvm\00"
@.str1553 = private unnamed_addr constant [6 x i8] c"--fmt\00"
@.str1554 = private unnamed_addr constant [13 x i8] c"--save-temps\00"
@.str1555 = private unnamed_addr constant [6 x i8] c"--run\00"
@.str1556 = private unnamed_addr constant [3 x i8] c"-o\00"
@.str1557 = private unnamed_addr constant [31 x i8] c"ludicc: ignoring unknown flag \00"
@.str1558 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str1559 = private unnamed_addr constant [90 x i8] c"usage: ludicc <file.ludic> [-o out] [--windowed|--headless] [--emit-llvm] [--save-temps]\0A\00"
@.str1560 = private unnamed_addr constant [27 x i8] c"ludicc: cannot open input\0A\00"
@.str1561 = private unnamed_addr constant [16 x i8] c"/tmp/ludic-run-\00"
@.str1562 = private unnamed_addr constant [10 x i8] c"mkdir -p \00"
@.str1563 = private unnamed_addr constant [4 x i8] c".ll\00"
@.str1564 = private unnamed_addr constant [25 x i8] c"ludicc: cannot write IR\0A\00"
@.str1565 = private unnamed_addr constant [9 x i8] c"LUDIC_CC\00"
@.str1566 = private unnamed_addr constant [6 x i8] c"clang\00"
@.str1567 = private unnamed_addr constant [11 x i8] c"LUDIC_HOME\00"
@.str1568 = private unnamed_addr constant [27 x i8] c" -O2 -Wno-override-module \00"
@.str1569 = private unnamed_addr constant [24 x i8] c"runtime/native/cocoa.ll\00"
@.str1570 = private unnamed_addr constant [2 x i8] c" \00"
@.str1571 = private unnamed_addr constant [42 x i8] c" -framework Cocoa -Wl,-rpath,@loader_path\00"
@.str1572 = private unnamed_addr constant [5 x i8] c" -o \00"
@.str1573 = private unnamed_addr constant [7 x i8] c"rm -f \00"
@.str1574 = private unnamed_addr constant [21 x i8] c"ludicc: link failed\0A\00"
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
define ptr @fn_str_slice(ptr %s, i32 %start, i32 %end) {
entry:
  %len = sub i32 %end, %start
  %sz = add i32 %len, 1
  %sz64 = sext i32 %sz to i64
  %out = call ptr @malloc(i64 %sz64)
  br label %loop
loop:
  %i = phi i32 [ 0, %entry ], [ %i1, %body ]
  %d = icmp slt i32 %i, %len
  br i1 %d, label %body, label %fin
body:
  %si = add i32 %start, %i
  %sp = getelementptr inbounds i8, ptr %s, i32 %si
  %c = load i8, ptr %sp
  %op = getelementptr inbounds i8, ptr %out, i32 %i
  store i8 %c, ptr %op
  %i1 = add i32 %i, 1
  br label %loop
fin:
  %tp = getelementptr inbounds i8, ptr %out, i32 %len
  store i8 0, ptr %tp
  ret ptr %out
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
  %t34 = getelementptr inbounds i8, ptr %t32, i32 %t33
  %t35 = load i32, ptr %t17
  %t36 = srem i32 %t35, 10
  %t37 = add i32 48, %t36
  %t38 = trunc i32 %t37 to i8
  store i8 %t38, ptr %t34
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
  %t70 = getelementptr inbounds i8, ptr %t66, i32 %t69
  %t71 = load ptr, ptr %t26
  %t72 = load i32, ptr %t27
  %t73 = sub i32 %t72, 1
  %t74 = load i32, ptr %t60
  %t75 = sub i32 %t73, %t74
  %t76 = getelementptr inbounds i8, ptr %t71, i32 %t75
  %t77 = load i8, ptr %t76
  %t78 = zext i8 %t77 to i32
  %t79 = trunc i32 %t78 to i8
  store i8 %t79, ptr %t70
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
  %t9 = getelementptr inbounds i8, ptr %t5, i32 %t8
  %t10 = load i32, ptr %t1
  %t11 = trunc i32 %t10 to i8
  store i8 %t11, ptr %t9
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
  %t12 = alloca i32
  %t23 = alloca i32
  %t33 = alloca i32
  %t34 = alloca i32
  %t61 = alloca i32
  %t88 = alloca i32
  %t92 = alloca ptr
  %t93 = alloca i32
  %t94 = alloca i32
  %t126 = alloca i32
  %t128 = alloca i32
  %t180 = alloca ptr
  %t181 = alloca i32
  %t182 = alloca i32
  %t227 = alloca i32
  %t242 = alloca i32
  %t279 = alloca i32
  %t297 = alloca i32
  %t310 = alloca i32
  %t311 = alloca i32
  %t317 = alloca i32
  %t332 = alloca i32
  %t355 = alloca i32
  %t356 = alloca i32
  %t384 = alloca i32
  %t385 = alloca i32
  %t417 = alloca i32
  %t418 = alloca i32
  %t419 = alloca i32
  %t456 = alloca i32
  %t465 = alloca i32
  %t466 = alloca i32
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
  %t10 = call i64 @strlen(ptr %t9)
  %t11 = trunc i64 %t10 to i32
  store i32 %t11, ptr %t12
  br label %wcond0
wcond0:
  %t13 = load i32, ptr %t7
  %t14 = load i32, ptr %t12
  %t15 = icmp slt i32 %t13, %t14
  %t16 = zext i1 %t15 to i32
  %t17 = icmp ne i32 %t16, 0
  br i1 %t17, label %wbody1, label %wend2
wbody1:
  %t18 = load ptr, ptr %t0
  %t19 = load i32, ptr %t7
  %t20 = getelementptr inbounds i8, ptr %t18, i32 %t19
  %t21 = load i8, ptr %t20
  %t22 = zext i8 %t21 to i32
  store i32 %t22, ptr %t23
  %t24 = load i32, ptr %t23
  %t25 = icmp eq i32 %t24, 10
  %t26 = zext i1 %t25 to i32
  %t27 = icmp ne i32 %t26, 0
  br i1 %t27, label %then3, label %ifend5
then3:
  %t28 = load i32, ptr %t8
  call void @fn_tok_push(i32 4, ptr null, i32 0, i32 %t28)
  %t29 = load i32, ptr %t8
  %t30 = add i32 %t29, 1
  store i32 %t30, ptr %t8
  %t31 = load i32, ptr %t7
  %t32 = add i32 %t31, 1
  store i32 %t32, ptr %t7
  br label %wcond0
ifend5:
  %t35 = load i32, ptr %t23
  %t36 = icmp eq i32 %t35, 32
  %t37 = zext i1 %t36 to i32
  %t38 = icmp ne i32 %t37, 0
  %t39 = zext i1 %t38 to i32
  store i32 %t39, ptr %t34
  br i1 %t38, label %scend7, label %sc6
sc6:
  %t40 = load i32, ptr %t23
  %t41 = icmp eq i32 %t40, 9
  %t42 = zext i1 %t41 to i32
  %t43 = icmp ne i32 %t42, 0
  %t44 = zext i1 %t43 to i32
  store i32 %t44, ptr %t34
  br label %scend7
scend7:
  %t45 = load i32, ptr %t34
  %t46 = icmp ne i32 %t45, 0
  %t47 = zext i1 %t46 to i32
  store i32 %t47, ptr %t33
  br i1 %t46, label %scend9, label %sc8
sc8:
  %t48 = load i32, ptr %t23
  %t49 = icmp eq i32 %t48, 13
  %t50 = zext i1 %t49 to i32
  %t51 = icmp ne i32 %t50, 0
  %t52 = zext i1 %t51 to i32
  store i32 %t52, ptr %t33
  br label %scend9
scend9:
  %t53 = load i32, ptr %t33
  %t54 = icmp ne i32 %t53, 0
  br i1 %t54, label %then10, label %ifend12
then10:
  %t55 = load i32, ptr %t7
  %t56 = add i32 %t55, 1
  store i32 %t56, ptr %t7
  br label %wcond0
ifend12:
  %t57 = load i32, ptr %t23
  %t58 = icmp eq i32 %t57, 35
  %t59 = zext i1 %t58 to i32
  %t60 = icmp ne i32 %t59, 0
  br i1 %t60, label %then13, label %ifend15
then13:
  br label %wcond16
wcond16:
  %t62 = load i32, ptr %t7
  %t63 = load i32, ptr %t12
  %t64 = icmp slt i32 %t62, %t63
  %t65 = zext i1 %t64 to i32
  %t66 = icmp ne i32 %t65, 0
  %t67 = zext i1 %t66 to i32
  store i32 %t67, ptr %t61
  br i1 %t66, label %sc19, label %scend20
sc19:
  %t68 = load ptr, ptr %t0
  %t69 = load i32, ptr %t7
  %t70 = getelementptr inbounds i8, ptr %t68, i32 %t69
  %t71 = load i8, ptr %t70
  %t72 = zext i8 %t71 to i32
  %t73 = icmp ne i32 %t72, 10
  %t74 = zext i1 %t73 to i32
  %t75 = icmp ne i32 %t74, 0
  %t76 = zext i1 %t75 to i32
  store i32 %t76, ptr %t61
  br label %scend20
scend20:
  %t77 = load i32, ptr %t61
  %t78 = icmp ne i32 %t77, 0
  br i1 %t78, label %wbody17, label %wend18
wbody17:
  %t79 = load i32, ptr %t7
  %t80 = add i32 %t79, 1
  store i32 %t80, ptr %t7
  br label %wcond16
wend18:
  br label %wcond0
ifend15:
  %t81 = load i32, ptr %t23
  %t82 = icmp eq i32 %t81, 34
  %t83 = zext i1 %t82 to i32
  %t84 = icmp ne i32 %t83, 0
  br i1 %t84, label %then21, label %ifend23
then21:
  %t85 = load i32, ptr %t7
  %t86 = add i32 %t85, 1
  store i32 %t86, ptr %t7
  %t87 = load i32, ptr %t7
  store i32 %t87, ptr %t88
  %t89 = load i32, ptr %t12
  %t90 = zext i32 %t89 to i64
  %t91 = call ptr @malloc(i64 %t90)
  store ptr %t91, ptr %t92
  store i32 0, ptr %t93
  br label %wcond24
wcond24:
  %t95 = load i32, ptr %t7
  %t96 = load i32, ptr %t12
  %t97 = icmp slt i32 %t95, %t96
  %t98 = zext i1 %t97 to i32
  %t99 = icmp ne i32 %t98, 0
  %t100 = zext i1 %t99 to i32
  store i32 %t100, ptr %t94
  br i1 %t99, label %sc27, label %scend28
sc27:
  %t101 = load ptr, ptr %t0
  %t102 = load i32, ptr %t7
  %t103 = getelementptr inbounds i8, ptr %t101, i32 %t102
  %t104 = load i8, ptr %t103
  %t105 = zext i8 %t104 to i32
  %t106 = icmp ne i32 %t105, 34
  %t107 = zext i1 %t106 to i32
  %t108 = icmp ne i32 %t107, 0
  %t109 = zext i1 %t108 to i32
  store i32 %t109, ptr %t94
  br label %scend28
scend28:
  %t110 = load i32, ptr %t94
  %t111 = icmp ne i32 %t110, 0
  br i1 %t111, label %wbody25, label %wend26
wbody25:
  %t112 = load ptr, ptr %t0
  %t113 = load i32, ptr %t7
  %t114 = getelementptr inbounds i8, ptr %t112, i32 %t113
  %t115 = load i8, ptr %t114
  %t116 = zext i8 %t115 to i32
  %t117 = icmp eq i32 %t116, 92
  %t118 = zext i1 %t117 to i32
  %t119 = icmp ne i32 %t118, 0
  br i1 %t119, label %then29, label %else30
then29:
  %t120 = load ptr, ptr %t0
  %t121 = load i32, ptr %t7
  %t122 = add i32 %t121, 1
  %t123 = getelementptr inbounds i8, ptr %t120, i32 %t122
  %t124 = load i8, ptr %t123
  %t125 = zext i8 %t124 to i32
  store i32 %t125, ptr %t126
  %t127 = load i32, ptr %t126
  store i32 %t127, ptr %t128
  %t129 = load i32, ptr %t126
  %t130 = icmp eq i32 %t129, 110
  %t131 = zext i1 %t130 to i32
  %t132 = icmp ne i32 %t131, 0
  br i1 %t132, label %then32, label %ifend34
then32:
  store i32 10, ptr %t128
  br label %ifend34
ifend34:
  %t133 = load i32, ptr %t126
  %t134 = icmp eq i32 %t133, 116
  %t135 = zext i1 %t134 to i32
  %t136 = icmp ne i32 %t135, 0
  br i1 %t136, label %then35, label %ifend37
then35:
  store i32 9, ptr %t128
  br label %ifend37
ifend37:
  %t137 = load i32, ptr %t126
  %t138 = icmp eq i32 %t137, 48
  %t139 = zext i1 %t138 to i32
  %t140 = icmp ne i32 %t139, 0
  br i1 %t140, label %then38, label %ifend40
then38:
  store i32 0, ptr %t128
  br label %ifend40
ifend40:
  %t141 = load ptr, ptr %t92
  %t142 = load i32, ptr %t93
  %t143 = getelementptr inbounds i8, ptr %t141, i32 %t142
  %t144 = load i32, ptr %t128
  %t145 = trunc i32 %t144 to i8
  store i8 %t145, ptr %t143
  %t146 = load i32, ptr %t93
  %t147 = add i32 %t146, 1
  store i32 %t147, ptr %t93
  %t148 = load i32, ptr %t7
  %t149 = add i32 %t148, 2
  store i32 %t149, ptr %t7
  br label %ifend31
else30:
  %t150 = load ptr, ptr %t92
  %t151 = load i32, ptr %t93
  %t152 = getelementptr inbounds i8, ptr %t150, i32 %t151
  %t153 = load ptr, ptr %t0
  %t154 = load i32, ptr %t7
  %t155 = getelementptr inbounds i8, ptr %t153, i32 %t154
  %t156 = load i8, ptr %t155
  %t157 = zext i8 %t156 to i32
  %t158 = trunc i32 %t157 to i8
  store i8 %t158, ptr %t152
  %t159 = load i32, ptr %t93
  %t160 = add i32 %t159, 1
  store i32 %t160, ptr %t93
  %t161 = load i32, ptr %t7
  %t162 = add i32 %t161, 1
  store i32 %t162, ptr %t7
  br label %ifend31
ifend31:
  br label %wcond24
wend26:
  %t163 = load i32, ptr %t7
  %t164 = add i32 %t163, 1
  store i32 %t164, ptr %t7
  %t165 = load ptr, ptr %t92
  %t166 = load i32, ptr %t93
  %t167 = getelementptr inbounds i8, ptr %t165, i32 %t166
  %t168 = trunc i32 0 to i8
  store i8 %t168, ptr %t167
  %t169 = load ptr, ptr %t92
  %t170 = load i32, ptr %t8
  call void @fn_tok_push(i32 2, ptr %t169, i32 0, i32 %t170)
  br label %wcond0
ifend23:
  %t171 = load i32, ptr %t23
  %t172 = icmp eq i32 %t171, 96
  %t173 = zext i1 %t172 to i32
  %t174 = icmp ne i32 %t173, 0
  br i1 %t174, label %then41, label %ifend43
then41:
  %t175 = load i32, ptr %t7
  %t176 = add i32 %t175, 1
  store i32 %t176, ptr %t7
  %t177 = load i32, ptr %t12
  %t178 = zext i32 %t177 to i64
  %t179 = call ptr @malloc(i64 %t178)
  store ptr %t179, ptr %t180
  store i32 0, ptr %t181
  br label %wcond44
wcond44:
  %t183 = load i32, ptr %t7
  %t184 = load i32, ptr %t12
  %t185 = icmp slt i32 %t183, %t184
  %t186 = zext i1 %t185 to i32
  %t187 = icmp ne i32 %t186, 0
  %t188 = zext i1 %t187 to i32
  store i32 %t188, ptr %t182
  br i1 %t187, label %sc47, label %scend48
sc47:
  %t189 = load ptr, ptr %t0
  %t190 = load i32, ptr %t7
  %t191 = getelementptr inbounds i8, ptr %t189, i32 %t190
  %t192 = load i8, ptr %t191
  %t193 = zext i8 %t192 to i32
  %t194 = icmp ne i32 %t193, 96
  %t195 = zext i1 %t194 to i32
  %t196 = icmp ne i32 %t195, 0
  %t197 = zext i1 %t196 to i32
  store i32 %t197, ptr %t182
  br label %scend48
scend48:
  %t198 = load i32, ptr %t182
  %t199 = icmp ne i32 %t198, 0
  br i1 %t199, label %wbody45, label %wend46
wbody45:
  %t200 = load ptr, ptr %t180
  %t201 = load i32, ptr %t181
  %t202 = getelementptr inbounds i8, ptr %t200, i32 %t201
  %t203 = load ptr, ptr %t0
  %t204 = load i32, ptr %t7
  %t205 = getelementptr inbounds i8, ptr %t203, i32 %t204
  %t206 = load i8, ptr %t205
  %t207 = zext i8 %t206 to i32
  %t208 = trunc i32 %t207 to i8
  store i8 %t208, ptr %t202
  %t209 = load i32, ptr %t181
  %t210 = add i32 %t209, 1
  store i32 %t210, ptr %t181
  %t211 = load i32, ptr %t7
  %t212 = add i32 %t211, 1
  store i32 %t212, ptr %t7
  br label %wcond44
wend46:
  %t213 = load i32, ptr %t7
  %t214 = add i32 %t213, 1
  store i32 %t214, ptr %t7
  %t215 = load ptr, ptr %t180
  %t216 = load i32, ptr %t181
  %t217 = getelementptr inbounds i8, ptr %t215, i32 %t216
  %t218 = trunc i32 0 to i8
  store i8 %t218, ptr %t217
  %t219 = load ptr, ptr %t180
  %t220 = load i32, ptr %t8
  call void @fn_tok_push(i32 7, ptr %t219, i32 0, i32 %t220)
  br label %wcond0
ifend43:
  %t221 = load i32, ptr %t23
  %t222 = icmp eq i32 %t221, 39
  %t223 = zext i1 %t222 to i32
  %t224 = icmp ne i32 %t223, 0
  br i1 %t224, label %then49, label %ifend51
then49:
  %t225 = load i32, ptr %t7
  %t226 = add i32 %t225, 1
  store i32 %t226, ptr %t7
  store i32 0, ptr %t227
  %t228 = load ptr, ptr %t0
  %t229 = load i32, ptr %t7
  %t230 = getelementptr inbounds i8, ptr %t228, i32 %t229
  %t231 = load i8, ptr %t230
  %t232 = zext i8 %t231 to i32
  %t233 = icmp eq i32 %t232, 92
  %t234 = zext i1 %t233 to i32
  %t235 = icmp ne i32 %t234, 0
  br i1 %t235, label %then52, label %else53
then52:
  %t236 = load ptr, ptr %t0
  %t237 = load i32, ptr %t7
  %t238 = add i32 %t237, 1
  %t239 = getelementptr inbounds i8, ptr %t236, i32 %t238
  %t240 = load i8, ptr %t239
  %t241 = zext i8 %t240 to i32
  store i32 %t241, ptr %t242
  %t243 = load i32, ptr %t242
  %t244 = icmp eq i32 %t243, 110
  %t245 = zext i1 %t244 to i32
  %t246 = icmp ne i32 %t245, 0
  br i1 %t246, label %then55, label %ifend57
then55:
  store i32 10, ptr %t227
  br label %ifend57
ifend57:
  %t247 = load i32, ptr %t242
  %t248 = icmp eq i32 %t247, 116
  %t249 = zext i1 %t248 to i32
  %t250 = icmp ne i32 %t249, 0
  br i1 %t250, label %then58, label %ifend60
then58:
  store i32 9, ptr %t227
  br label %ifend60
ifend60:
  %t251 = load i32, ptr %t242
  %t252 = icmp eq i32 %t251, 48
  %t253 = zext i1 %t252 to i32
  %t254 = icmp ne i32 %t253, 0
  br i1 %t254, label %then61, label %ifend63
then61:
  store i32 0, ptr %t227
  br label %ifend63
ifend63:
  %t255 = load i32, ptr %t7
  %t256 = add i32 %t255, 2
  store i32 %t256, ptr %t7
  br label %ifend54
else53:
  %t257 = load ptr, ptr %t0
  %t258 = load i32, ptr %t7
  %t259 = getelementptr inbounds i8, ptr %t257, i32 %t258
  %t260 = load i8, ptr %t259
  %t261 = zext i8 %t260 to i32
  store i32 %t261, ptr %t227
  %t262 = load i32, ptr %t7
  %t263 = add i32 %t262, 1
  store i32 %t263, ptr %t7
  br label %ifend54
ifend54:
  %t264 = load ptr, ptr %t0
  %t265 = load i32, ptr %t7
  %t266 = getelementptr inbounds i8, ptr %t264, i32 %t265
  %t267 = load i8, ptr %t266
  %t268 = zext i8 %t267 to i32
  %t269 = icmp eq i32 %t268, 39
  %t270 = zext i1 %t269 to i32
  %t271 = icmp ne i32 %t270, 0
  br i1 %t271, label %then64, label %ifend66
then64:
  %t272 = load i32, ptr %t7
  %t273 = add i32 %t272, 1
  store i32 %t273, ptr %t7
  br label %ifend66
ifend66:
  %t274 = load i32, ptr %t227
  %t275 = load i32, ptr %t8
  call void @fn_tok_push(i32 1, ptr null, i32 %t274, i32 %t275)
  br label %wcond0
ifend51:
  %t276 = load i32, ptr %t23
  %t277 = call i32 @fn_char_is_digit(i32 %t276)
  %t278 = icmp ne i32 %t277, 0
  br i1 %t278, label %then67, label %ifend69
then67:
  %t280 = load i32, ptr %t23
  %t281 = icmp eq i32 %t280, 48
  %t282 = zext i1 %t281 to i32
  %t283 = icmp ne i32 %t282, 0
  %t284 = zext i1 %t283 to i32
  store i32 %t284, ptr %t279
  br i1 %t283, label %sc70, label %scend71
sc70:
  %t285 = load ptr, ptr %t0
  %t286 = load i32, ptr %t7
  %t287 = add i32 %t286, 1
  %t288 = getelementptr inbounds i8, ptr %t285, i32 %t287
  %t289 = load i8, ptr %t288
  %t290 = zext i8 %t289 to i32
  %t291 = icmp eq i32 %t290, 120
  %t292 = zext i1 %t291 to i32
  %t293 = icmp ne i32 %t292, 0
  %t294 = zext i1 %t293 to i32
  store i32 %t294, ptr %t279
  br label %scend71
scend71:
  %t295 = load i32, ptr %t279
  %t296 = icmp ne i32 %t295, 0
  br i1 %t296, label %then72, label %ifend74
then72:
  store i32 0, ptr %t297
  %t298 = load i32, ptr %t7
  %t299 = add i32 %t298, 2
  store i32 %t299, ptr %t7
  br label %wcond75
wcond75:
  %t300 = load i32, ptr %t7
  %t301 = load i32, ptr %t12
  %t302 = icmp slt i32 %t300, %t301
  %t303 = zext i1 %t302 to i32
  %t304 = icmp ne i32 %t303, 0
  br i1 %t304, label %wbody76, label %wend77
wbody76:
  %t305 = load ptr, ptr %t0
  %t306 = load i32, ptr %t7
  %t307 = getelementptr inbounds i8, ptr %t305, i32 %t306
  %t308 = load i8, ptr %t307
  %t309 = zext i8 %t308 to i32
  store i32 %t309, ptr %t310
  store i32 0, ptr %t311
  %t312 = load i32, ptr %t310
  %t313 = call i32 @fn_char_is_digit(i32 %t312)
  %t314 = icmp ne i32 %t313, 0
  br i1 %t314, label %then78, label %else79
then78:
  %t315 = load i32, ptr %t310
  %t316 = sub i32 %t315, 48
  store i32 %t316, ptr %t311
  br label %ifend80
else79:
  %t318 = load i32, ptr %t310
  %t319 = icmp sge i32 %t318, 97
  %t320 = zext i1 %t319 to i32
  %t321 = icmp ne i32 %t320, 0
  %t322 = zext i1 %t321 to i32
  store i32 %t322, ptr %t317
  br i1 %t321, label %sc81, label %scend82
sc81:
  %t323 = load i32, ptr %t310
  %t324 = icmp sle i32 %t323, 102
  %t325 = zext i1 %t324 to i32
  %t326 = icmp ne i32 %t325, 0
  %t327 = zext i1 %t326 to i32
  store i32 %t327, ptr %t317
  br label %scend82
scend82:
  %t328 = load i32, ptr %t317
  %t329 = icmp ne i32 %t328, 0
  br i1 %t329, label %then83, label %else84
then83:
  %t330 = load i32, ptr %t310
  %t331 = sub i32 %t330, 87
  store i32 %t331, ptr %t311
  br label %ifend85
else84:
  %t333 = load i32, ptr %t310
  %t334 = icmp sge i32 %t333, 65
  %t335 = zext i1 %t334 to i32
  %t336 = icmp ne i32 %t335, 0
  %t337 = zext i1 %t336 to i32
  store i32 %t337, ptr %t332
  br i1 %t336, label %sc86, label %scend87
sc86:
  %t338 = load i32, ptr %t310
  %t339 = icmp sle i32 %t338, 70
  %t340 = zext i1 %t339 to i32
  %t341 = icmp ne i32 %t340, 0
  %t342 = zext i1 %t341 to i32
  store i32 %t342, ptr %t332
  br label %scend87
scend87:
  %t343 = load i32, ptr %t332
  %t344 = icmp ne i32 %t343, 0
  br i1 %t344, label %then88, label %else89
then88:
  %t345 = load i32, ptr %t310
  %t346 = sub i32 %t345, 55
  store i32 %t346, ptr %t311
  br label %ifend90
else89:
  br label %wend77
ifend90:
  br label %ifend85
ifend85:
  br label %ifend80
ifend80:
  %t347 = load i32, ptr %t297
  %t348 = mul i32 %t347, 16
  %t349 = load i32, ptr %t311
  %t350 = add i32 %t348, %t349
  store i32 %t350, ptr %t297
  %t351 = load i32, ptr %t7
  %t352 = add i32 %t351, 1
  store i32 %t352, ptr %t7
  br label %wcond75
wend77:
  %t353 = load i32, ptr %t297
  %t354 = load i32, ptr %t8
  call void @fn_tok_push(i32 1, ptr null, i32 %t353, i32 %t354)
  br label %wcond0
ifend74:
  store i32 0, ptr %t355
  br label %wcond91
wcond91:
  %t357 = load i32, ptr %t7
  %t358 = load i32, ptr %t12
  %t359 = icmp slt i32 %t357, %t358
  %t360 = zext i1 %t359 to i32
  %t361 = icmp ne i32 %t360, 0
  %t362 = zext i1 %t361 to i32
  store i32 %t362, ptr %t356
  br i1 %t361, label %sc94, label %scend95
sc94:
  %t363 = load ptr, ptr %t0
  %t364 = load i32, ptr %t7
  %t365 = getelementptr inbounds i8, ptr %t363, i32 %t364
  %t366 = load i8, ptr %t365
  %t367 = zext i8 %t366 to i32
  %t368 = call i32 @fn_char_is_digit(i32 %t367)
  %t369 = icmp ne i32 %t368, 0
  %t370 = zext i1 %t369 to i32
  store i32 %t370, ptr %t356
  br label %scend95
scend95:
  %t371 = load i32, ptr %t356
  %t372 = icmp ne i32 %t371, 0
  br i1 %t372, label %wbody92, label %wend93
wbody92:
  %t373 = load i32, ptr %t355
  %t374 = mul i32 %t373, 10
  %t375 = load ptr, ptr %t0
  %t376 = load i32, ptr %t7
  %t377 = getelementptr inbounds i8, ptr %t375, i32 %t376
  %t378 = load i8, ptr %t377
  %t379 = zext i8 %t378 to i32
  %t380 = sub i32 %t379, 48
  %t381 = add i32 %t374, %t380
  store i32 %t381, ptr %t355
  %t382 = load i32, ptr %t7
  %t383 = add i32 %t382, 1
  store i32 %t383, ptr %t7
  br label %wcond91
wend93:
  %t386 = load i32, ptr %t7
  %t387 = load i32, ptr %t12
  %t388 = icmp slt i32 %t386, %t387
  %t389 = zext i1 %t388 to i32
  %t390 = icmp ne i32 %t389, 0
  %t391 = zext i1 %t390 to i32
  store i32 %t391, ptr %t385
  br i1 %t390, label %sc96, label %scend97
sc96:
  %t392 = load ptr, ptr %t0
  %t393 = load i32, ptr %t7
  %t394 = getelementptr inbounds i8, ptr %t392, i32 %t393
  %t395 = load i8, ptr %t394
  %t396 = zext i8 %t395 to i32
  %t397 = icmp eq i32 %t396, 46
  %t398 = zext i1 %t397 to i32
  %t399 = icmp ne i32 %t398, 0
  %t400 = zext i1 %t399 to i32
  store i32 %t400, ptr %t385
  br label %scend97
scend97:
  %t401 = load i32, ptr %t385
  %t402 = icmp ne i32 %t401, 0
  %t403 = zext i1 %t402 to i32
  store i32 %t403, ptr %t384
  br i1 %t402, label %sc98, label %scend99
sc98:
  %t404 = load ptr, ptr %t0
  %t405 = load i32, ptr %t7
  %t406 = add i32 %t405, 1
  %t407 = getelementptr inbounds i8, ptr %t404, i32 %t406
  %t408 = load i8, ptr %t407
  %t409 = zext i8 %t408 to i32
  %t410 = call i32 @fn_char_is_digit(i32 %t409)
  %t411 = icmp ne i32 %t410, 0
  %t412 = zext i1 %t411 to i32
  store i32 %t412, ptr %t384
  br label %scend99
scend99:
  %t413 = load i32, ptr %t384
  %t414 = icmp ne i32 %t413, 0
  br i1 %t414, label %then100, label %ifend102
then100:
  %t415 = load i32, ptr %t7
  %t416 = add i32 %t415, 1
  store i32 %t416, ptr %t7
  store i32 0, ptr %t417
  store i32 1, ptr %t418
  br label %wcond103
wcond103:
  %t420 = load i32, ptr %t7
  %t421 = load i32, ptr %t12
  %t422 = icmp slt i32 %t420, %t421
  %t423 = zext i1 %t422 to i32
  %t424 = icmp ne i32 %t423, 0
  %t425 = zext i1 %t424 to i32
  store i32 %t425, ptr %t419
  br i1 %t424, label %sc106, label %scend107
sc106:
  %t426 = load ptr, ptr %t0
  %t427 = load i32, ptr %t7
  %t428 = getelementptr inbounds i8, ptr %t426, i32 %t427
  %t429 = load i8, ptr %t428
  %t430 = zext i8 %t429 to i32
  %t431 = call i32 @fn_char_is_digit(i32 %t430)
  %t432 = icmp ne i32 %t431, 0
  %t433 = zext i1 %t432 to i32
  store i32 %t433, ptr %t419
  br label %scend107
scend107:
  %t434 = load i32, ptr %t419
  %t435 = icmp ne i32 %t434, 0
  br i1 %t435, label %wbody104, label %wend105
wbody104:
  %t436 = load i32, ptr %t417
  %t437 = mul i32 %t436, 10
  %t438 = load ptr, ptr %t0
  %t439 = load i32, ptr %t7
  %t440 = getelementptr inbounds i8, ptr %t438, i32 %t439
  %t441 = load i8, ptr %t440
  %t442 = zext i8 %t441 to i32
  %t443 = sub i32 %t442, 48
  %t444 = add i32 %t437, %t443
  store i32 %t444, ptr %t417
  %t445 = load i32, ptr %t418
  %t446 = mul i32 %t445, 10
  store i32 %t446, ptr %t418
  %t447 = load i32, ptr %t7
  %t448 = add i32 %t447, 1
  store i32 %t448, ptr %t7
  br label %wcond103
wend105:
  %t449 = load i32, ptr %t355
  %t450 = shl i32 %t449, 16
  %t451 = load i32, ptr %t417
  %t452 = shl i32 %t451, 16
  %t453 = load i32, ptr %t418
  %t454 = sdiv i32 %t452, %t453
  %t455 = add i32 %t450, %t454
  store i32 %t455, ptr %t456
  %t457 = load i32, ptr %t456
  %t458 = load i32, ptr %t8
  call void @fn_tok_push(i32 6, ptr null, i32 %t457, i32 %t458)
  br label %wcond0
ifend102:
  %t459 = load i32, ptr %t355
  %t460 = load i32, ptr %t8
  call void @fn_tok_push(i32 1, ptr null, i32 %t459, i32 %t460)
  br label %wcond0
ifend69:
  %t461 = load i32, ptr %t23
  %t462 = call i32 @fn_char_is_alpha(i32 %t461)
  %t463 = icmp ne i32 %t462, 0
  br i1 %t463, label %then108, label %ifend110
then108:
  %t464 = load i32, ptr %t7
  store i32 %t464, ptr %t465
  br label %wcond111
wcond111:
  %t467 = load i32, ptr %t7
  %t468 = load i32, ptr %t12
  %t469 = icmp slt i32 %t467, %t468
  %t470 = zext i1 %t469 to i32
  %t471 = icmp ne i32 %t470, 0
  %t472 = zext i1 %t471 to i32
  store i32 %t472, ptr %t466
  br i1 %t471, label %sc114, label %scend115
sc114:
  %t473 = load ptr, ptr %t0
  %t474 = load i32, ptr %t7
  %t475 = getelementptr inbounds i8, ptr %t473, i32 %t474
  %t476 = load i8, ptr %t475
  %t477 = zext i8 %t476 to i32
  %t478 = call i32 @fn_char_is_alnum(i32 %t477)
  %t479 = icmp ne i32 %t478, 0
  %t480 = zext i1 %t479 to i32
  store i32 %t480, ptr %t466
  br label %scend115
scend115:
  %t481 = load i32, ptr %t466
  %t482 = icmp ne i32 %t481, 0
  br i1 %t482, label %wbody112, label %wend113
wbody112:
  %t483 = load i32, ptr %t7
  %t484 = add i32 %t483, 1
  store i32 %t484, ptr %t7
  br label %wcond111
wend113:
  %t485 = load ptr, ptr %t0
  %t486 = load i32, ptr %t465
  %t487 = load i32, ptr %t7
  %t488 = call ptr @fn_str_slice(ptr %t485, i32 %t486, i32 %t487)
  %t489 = load i32, ptr %t8
  call void @fn_tok_push(i32 0, ptr %t488, i32 0, i32 %t489)
  br label %wcond0
ifend110:
  %t490 = load i32, ptr %t23
  %t491 = icmp eq i32 %t490, 59
  %t492 = zext i1 %t491 to i32
  %t493 = icmp ne i32 %t492, 0
  br i1 %t493, label %then116, label %ifend118
then116:
  %t494 = load i32, ptr %t8
  call void @fn_tok_push(i32 4, ptr null, i32 0, i32 %t494)
  %t495 = load i32, ptr %t7
  %t496 = add i32 %t495, 1
  store i32 %t496, ptr %t7
  br label %wcond0
ifend118:
  %t497 = load ptr, ptr %t0
  %t498 = load i32, ptr %t7
  %t499 = call i32 @fn_two_at(ptr %t497, i32 %t498, i32 45, i32 62)
  %t500 = icmp ne i32 %t499, 0
  br i1 %t500, label %then119, label %ifend121
then119:
  %t501 = load ptr, ptr %t0
  %t502 = load i32, ptr %t7
  %t503 = load i32, ptr %t7
  %t504 = add i32 %t503, 2
  %t505 = call ptr @fn_str_slice(ptr %t501, i32 %t502, i32 %t504)
  %t506 = load i32, ptr %t8
  call void @fn_tok_push(i32 3, ptr %t505, i32 0, i32 %t506)
  %t507 = load i32, ptr %t7
  %t508 = add i32 %t507, 2
  store i32 %t508, ptr %t7
  br label %wcond0
ifend121:
  %t509 = load ptr, ptr %t0
  %t510 = load i32, ptr %t7
  %t511 = call i32 @fn_two_at(ptr %t509, i32 %t510, i32 61, i32 62)
  %t512 = icmp ne i32 %t511, 0
  br i1 %t512, label %then122, label %ifend124
then122:
  %t513 = load ptr, ptr %t0
  %t514 = load i32, ptr %t7
  %t515 = load i32, ptr %t7
  %t516 = add i32 %t515, 2
  %t517 = call ptr @fn_str_slice(ptr %t513, i32 %t514, i32 %t516)
  %t518 = load i32, ptr %t8
  call void @fn_tok_push(i32 3, ptr %t517, i32 0, i32 %t518)
  %t519 = load i32, ptr %t7
  %t520 = add i32 %t519, 2
  store i32 %t520, ptr %t7
  br label %wcond0
ifend124:
  %t521 = load ptr, ptr %t0
  %t522 = load i32, ptr %t7
  %t523 = call i32 @fn_two_at(ptr %t521, i32 %t522, i32 61, i32 61)
  %t524 = icmp ne i32 %t523, 0
  br i1 %t524, label %then125, label %ifend127
then125:
  %t525 = load ptr, ptr %t0
  %t526 = load i32, ptr %t7
  %t527 = load i32, ptr %t7
  %t528 = add i32 %t527, 2
  %t529 = call ptr @fn_str_slice(ptr %t525, i32 %t526, i32 %t528)
  %t530 = load i32, ptr %t8
  call void @fn_tok_push(i32 3, ptr %t529, i32 0, i32 %t530)
  %t531 = load i32, ptr %t7
  %t532 = add i32 %t531, 2
  store i32 %t532, ptr %t7
  br label %wcond0
ifend127:
  %t533 = load ptr, ptr %t0
  %t534 = load i32, ptr %t7
  %t535 = call i32 @fn_two_at(ptr %t533, i32 %t534, i32 33, i32 61)
  %t536 = icmp ne i32 %t535, 0
  br i1 %t536, label %then128, label %ifend130
then128:
  %t537 = load ptr, ptr %t0
  %t538 = load i32, ptr %t7
  %t539 = load i32, ptr %t7
  %t540 = add i32 %t539, 2
  %t541 = call ptr @fn_str_slice(ptr %t537, i32 %t538, i32 %t540)
  %t542 = load i32, ptr %t8
  call void @fn_tok_push(i32 3, ptr %t541, i32 0, i32 %t542)
  %t543 = load i32, ptr %t7
  %t544 = add i32 %t543, 2
  store i32 %t544, ptr %t7
  br label %wcond0
ifend130:
  %t545 = load ptr, ptr %t0
  %t546 = load i32, ptr %t7
  %t547 = call i32 @fn_two_at(ptr %t545, i32 %t546, i32 60, i32 61)
  %t548 = icmp ne i32 %t547, 0
  br i1 %t548, label %then131, label %ifend133
then131:
  %t549 = load ptr, ptr %t0
  %t550 = load i32, ptr %t7
  %t551 = load i32, ptr %t7
  %t552 = add i32 %t551, 2
  %t553 = call ptr @fn_str_slice(ptr %t549, i32 %t550, i32 %t552)
  %t554 = load i32, ptr %t8
  call void @fn_tok_push(i32 3, ptr %t553, i32 0, i32 %t554)
  %t555 = load i32, ptr %t7
  %t556 = add i32 %t555, 2
  store i32 %t556, ptr %t7
  br label %wcond0
ifend133:
  %t557 = load ptr, ptr %t0
  %t558 = load i32, ptr %t7
  %t559 = call i32 @fn_two_at(ptr %t557, i32 %t558, i32 62, i32 61)
  %t560 = icmp ne i32 %t559, 0
  br i1 %t560, label %then134, label %ifend136
then134:
  %t561 = load ptr, ptr %t0
  %t562 = load i32, ptr %t7
  %t563 = load i32, ptr %t7
  %t564 = add i32 %t563, 2
  %t565 = call ptr @fn_str_slice(ptr %t561, i32 %t562, i32 %t564)
  %t566 = load i32, ptr %t8
  call void @fn_tok_push(i32 3, ptr %t565, i32 0, i32 %t566)
  %t567 = load i32, ptr %t7
  %t568 = add i32 %t567, 2
  store i32 %t568, ptr %t7
  br label %wcond0
ifend136:
  %t569 = load ptr, ptr %t0
  %t570 = load i32, ptr %t7
  %t571 = call i32 @fn_two_at(ptr %t569, i32 %t570, i32 43, i32 61)
  %t572 = icmp ne i32 %t571, 0
  br i1 %t572, label %then137, label %ifend139
then137:
  %t573 = load ptr, ptr %t0
  %t574 = load i32, ptr %t7
  %t575 = load i32, ptr %t7
  %t576 = add i32 %t575, 2
  %t577 = call ptr @fn_str_slice(ptr %t573, i32 %t574, i32 %t576)
  %t578 = load i32, ptr %t8
  call void @fn_tok_push(i32 3, ptr %t577, i32 0, i32 %t578)
  %t579 = load i32, ptr %t7
  %t580 = add i32 %t579, 2
  store i32 %t580, ptr %t7
  br label %wcond0
ifend139:
  %t581 = load ptr, ptr %t0
  %t582 = load i32, ptr %t7
  %t583 = call i32 @fn_two_at(ptr %t581, i32 %t582, i32 45, i32 61)
  %t584 = icmp ne i32 %t583, 0
  br i1 %t584, label %then140, label %ifend142
then140:
  %t585 = load ptr, ptr %t0
  %t586 = load i32, ptr %t7
  %t587 = load i32, ptr %t7
  %t588 = add i32 %t587, 2
  %t589 = call ptr @fn_str_slice(ptr %t585, i32 %t586, i32 %t588)
  %t590 = load i32, ptr %t8
  call void @fn_tok_push(i32 3, ptr %t589, i32 0, i32 %t590)
  %t591 = load i32, ptr %t7
  %t592 = add i32 %t591, 2
  store i32 %t592, ptr %t7
  br label %wcond0
ifend142:
  %t593 = load ptr, ptr %t0
  %t594 = load i32, ptr %t7
  %t595 = call i32 @fn_two_at(ptr %t593, i32 %t594, i32 42, i32 61)
  %t596 = icmp ne i32 %t595, 0
  br i1 %t596, label %then143, label %ifend145
then143:
  %t597 = load ptr, ptr %t0
  %t598 = load i32, ptr %t7
  %t599 = load i32, ptr %t7
  %t600 = add i32 %t599, 2
  %t601 = call ptr @fn_str_slice(ptr %t597, i32 %t598, i32 %t600)
  %t602 = load i32, ptr %t8
  call void @fn_tok_push(i32 3, ptr %t601, i32 0, i32 %t602)
  %t603 = load i32, ptr %t7
  %t604 = add i32 %t603, 2
  store i32 %t604, ptr %t7
  br label %wcond0
ifend145:
  %t605 = load ptr, ptr %t0
  %t606 = load i32, ptr %t7
  %t607 = call i32 @fn_two_at(ptr %t605, i32 %t606, i32 47, i32 61)
  %t608 = icmp ne i32 %t607, 0
  br i1 %t608, label %then146, label %ifend148
then146:
  %t609 = load ptr, ptr %t0
  %t610 = load i32, ptr %t7
  %t611 = load i32, ptr %t7
  %t612 = add i32 %t611, 2
  %t613 = call ptr @fn_str_slice(ptr %t609, i32 %t610, i32 %t612)
  %t614 = load i32, ptr %t8
  call void @fn_tok_push(i32 3, ptr %t613, i32 0, i32 %t614)
  %t615 = load i32, ptr %t7
  %t616 = add i32 %t615, 2
  store i32 %t616, ptr %t7
  br label %wcond0
ifend148:
  %t617 = load ptr, ptr %t0
  %t618 = load i32, ptr %t7
  %t619 = call i32 @fn_two_at(ptr %t617, i32 %t618, i32 46, i32 46)
  %t620 = icmp ne i32 %t619, 0
  br i1 %t620, label %then149, label %ifend151
then149:
  %t621 = load ptr, ptr %t0
  %t622 = load i32, ptr %t7
  %t623 = load i32, ptr %t7
  %t624 = add i32 %t623, 2
  %t625 = call ptr @fn_str_slice(ptr %t621, i32 %t622, i32 %t624)
  %t626 = load i32, ptr %t8
  call void @fn_tok_push(i32 3, ptr %t625, i32 0, i32 %t626)
  %t627 = load i32, ptr %t7
  %t628 = add i32 %t627, 2
  store i32 %t628, ptr %t7
  br label %wcond0
ifend151:
  %t629 = load ptr, ptr %t0
  %t630 = load i32, ptr %t7
  %t631 = call i32 @fn_two_at(ptr %t629, i32 %t630, i32 60, i32 60)
  %t632 = icmp ne i32 %t631, 0
  br i1 %t632, label %then152, label %ifend154
then152:
  %t633 = load ptr, ptr %t0
  %t634 = load i32, ptr %t7
  %t635 = load i32, ptr %t7
  %t636 = add i32 %t635, 2
  %t637 = call ptr @fn_str_slice(ptr %t633, i32 %t634, i32 %t636)
  %t638 = load i32, ptr %t8
  call void @fn_tok_push(i32 3, ptr %t637, i32 0, i32 %t638)
  %t639 = load i32, ptr %t7
  %t640 = add i32 %t639, 2
  store i32 %t640, ptr %t7
  br label %wcond0
ifend154:
  %t641 = load ptr, ptr %t0
  %t642 = load i32, ptr %t7
  %t643 = call i32 @fn_two_at(ptr %t641, i32 %t642, i32 62, i32 62)
  %t644 = icmp ne i32 %t643, 0
  br i1 %t644, label %then155, label %ifend157
then155:
  %t645 = load ptr, ptr %t0
  %t646 = load i32, ptr %t7
  %t647 = load i32, ptr %t7
  %t648 = add i32 %t647, 2
  %t649 = call ptr @fn_str_slice(ptr %t645, i32 %t646, i32 %t648)
  %t650 = load i32, ptr %t8
  call void @fn_tok_push(i32 3, ptr %t649, i32 0, i32 %t650)
  %t651 = load i32, ptr %t7
  %t652 = add i32 %t651, 2
  store i32 %t652, ptr %t7
  br label %wcond0
ifend157:
  %t653 = load i32, ptr %t23
  %t654 = call i32 @fn_is_op1(i32 %t653)
  %t655 = icmp ne i32 %t654, 0
  br i1 %t655, label %then158, label %ifend160
then158:
  %t656 = load ptr, ptr %t0
  %t657 = load i32, ptr %t7
  %t658 = load i32, ptr %t7
  %t659 = add i32 %t658, 1
  %t660 = call ptr @fn_str_slice(ptr %t656, i32 %t657, i32 %t659)
  %t661 = load i32, ptr %t8
  call void @fn_tok_push(i32 3, ptr %t660, i32 0, i32 %t661)
  %t662 = load i32, ptr %t7
  %t663 = add i32 %t662, 1
  store i32 %t663, ptr %t7
  br label %wcond0
ifend160:
  %t664 = load i32, ptr %t7
  %t665 = add i32 %t664, 1
  store i32 %t665, ptr %t7
  br label %wcond0
wend2:
  %t666 = load i32, ptr %t8
  call void @fn_tok_push(i32 5, ptr null, i32 0, i32 %t666)
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
  %t10 = call i64 @strlen(ptr %t9)
  %t11 = trunc i64 %t10 to i32
  %t12 = zext i32 %t11 to i64
  %t13 = call i64 @fwrite(ptr %t8, i64 1, i64 %t12, ptr %t7)
  %t14 = trunc i64 %t13 to i32
  %t15 = load ptr, ptr %t2
  %t16 = zext i32 1 to i64
  %t17 = call i64 @fwrite(ptr @.str2, i64 1, i64 %t16, ptr %t15)
  %t18 = trunc i64 %t17 to i32
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
  %t12 = alloca ptr
  %t19 = alloca i32
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
  %t7 = call i64 @strlen(ptr %t6)
  %t8 = trunc i64 %t7 to i32
  %t9 = add i32 %t8, 3
  %t10 = zext i32 %t9 to i64
  %t11 = call ptr @malloc(i64 %t10)
  store ptr %t11, ptr %t12
  %t13 = load ptr, ptr %t12
  %t14 = getelementptr inbounds i8, ptr %t13, i32 0
  %t15 = trunc i32 91 to i8
  store i8 %t15, ptr %t14
  %t16 = load ptr, ptr %t12
  %t17 = getelementptr inbounds i8, ptr %t16, i32 1
  %t18 = trunc i32 93 to i8
  store i8 %t18, ptr %t17
  store i32 0, ptr %t19
  br label %wcond3
wcond3:
  %t20 = load ptr, ptr %t5
  %t21 = load i32, ptr %t19
  %t22 = getelementptr inbounds i8, ptr %t20, i32 %t21
  %t23 = load i8, ptr %t22
  %t24 = zext i8 %t23 to i32
  %t25 = icmp ne i32 %t24, 0
  %t26 = zext i1 %t25 to i32
  %t27 = icmp ne i32 %t26, 0
  br i1 %t27, label %wbody4, label %wend5
wbody4:
  %t28 = load ptr, ptr %t12
  %t29 = load i32, ptr %t19
  %t30 = add i32 2, %t29
  %t31 = getelementptr inbounds i8, ptr %t28, i32 %t30
  %t32 = load ptr, ptr %t5
  %t33 = load i32, ptr %t19
  %t34 = getelementptr inbounds i8, ptr %t32, i32 %t33
  %t35 = load i8, ptr %t34
  %t36 = zext i8 %t35 to i32
  %t37 = trunc i32 %t36 to i8
  store i8 %t37, ptr %t31
  %t38 = load i32, ptr %t19
  %t39 = add i32 %t38, 1
  store i32 %t39, ptr %t19
  br label %wcond3
wend5:
  %t40 = load ptr, ptr %t12
  %t41 = load i32, ptr %t19
  %t42 = add i32 2, %t41
  %t43 = getelementptr inbounds i8, ptr %t40, i32 %t42
  %t44 = trunc i32 0 to i8
  store i8 %t44, ptr %t43
  %t45 = load ptr, ptr %t12
  store ptr %t45, ptr %retval
  br label %ret
ifend2:
  %t46 = call ptr @fn_eat_id()
  store ptr %t46, ptr %retval
  br label %ret
ret:
  %t47 = load ptr, ptr %retval
  ret ptr %t47
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

define ptr @fn_interp_lit(ptr %arg_buf, i32 %arg_len) {
entry:
  %retval = alloca ptr
  %t0 = alloca ptr
  %t1 = alloca i32
  %t3 = alloca ptr
  store ptr %arg_buf, ptr %t0
  store i32 %arg_len, ptr %t1
  %t2 = call ptr @fn_node(i32 31)
  store ptr %t2, ptr %t3
  %t4 = load ptr, ptr %t3
  %t5 = getelementptr inbounds %Cmp_Node, ptr %t4, i32 0, i32 1
  %t6 = load ptr, ptr %t0
  %t7 = load i32, ptr %t1
  %t8 = add i32 0, %t7
  %t9 = call ptr @fn_str_slice(ptr %t6, i32 0, i32 %t8)
  store ptr %t9, ptr %t5
  %t10 = load ptr, ptr %t3
  store ptr %t10, ptr %retval
  br label %ret
ret:
  %t11 = load ptr, ptr %retval
  ret ptr %t11
}

define ptr @fn_interp_add(ptr %arg_acc, ptr %arg_part) {
entry:
  %retval = alloca ptr
  %t0 = alloca ptr
  %t1 = alloca ptr
  store ptr %arg_acc, ptr %t0
  store ptr %arg_part, ptr %t1
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
  %t7 = load ptr, ptr %t0
  %t8 = load ptr, ptr %t1
  %t9 = call ptr @fn_mkbin(ptr @.str10, ptr %t7, ptr %t8)
  store ptr %t9, ptr %retval
  br label %ret
ret:
  %t10 = load ptr, ptr %retval
  ret ptr %t10
}

define ptr @fn_interp_str(ptr %arg_e) {
entry:
  %retval = alloca ptr
  %t0 = alloca ptr
  %t2 = alloca ptr
  %t4 = alloca ptr
  store ptr %arg_e, ptr %t0
  %t1 = call ptr @fn_node(i32 34)
  store ptr %t1, ptr %t2
  %t3 = call ptr @fn_node(i32 33)
  store ptr %t3, ptr %t4
  %t5 = load ptr, ptr %t4
  %t6 = getelementptr inbounds %Cmp_Node, ptr %t5, i32 0, i32 1
  store ptr @.str11, ptr %t6
  %t7 = load ptr, ptr %t2
  %t8 = getelementptr inbounds %Cmp_Node, ptr %t7, i32 0, i32 4
  %t9 = load ptr, ptr %t4
  store ptr %t9, ptr %t8
  %t10 = load ptr, ptr %t2
  %t11 = getelementptr inbounds %Cmp_Node, ptr %t10, i32 0, i32 7
  %t12 = load ptr, ptr %t11
  %t13 = getelementptr inbounds %LSlice, ptr %t12, i32 0, i32 1
  %t14 = getelementptr inbounds %LSlice, ptr %t12, i32 0, i32 2
  %t15 = getelementptr inbounds %LSlice, ptr %t12, i32 0, i32 0
  %t16 = load i32, ptr %t13
  %t17 = load i32, ptr %t14
  %t18 = icmp sge i32 %t16, %t17
  br i1 %t18, label %grow0, label %put1
grow0:
  %t19 = mul i32 %t17, 2
  %t20 = icmp eq i32 %t17, 0
  %t21 = select i1 %t20, i32 8, i32 %t19
  %t22 = getelementptr ptr, ptr null, i32 1
  %t23 = ptrtoint ptr %t22 to i64
  %t24 = zext i32 %t21 to i64
  %t25 = mul i64 %t24, %t23
  %t26 = load ptr, ptr %t15
  %t27 = call ptr @realloc(ptr %t26, i64 %t25)
  store ptr %t27, ptr %t15
  store i32 %t21, ptr %t14
  br label %put1
put1:
  %t28 = load ptr, ptr %t0
  %t29 = load ptr, ptr %t15
  %t30 = getelementptr inbounds ptr, ptr %t29, i32 %t16
  store ptr %t28, ptr %t30
  %t31 = add i32 %t16, 1
  store i32 %t31, ptr %t13
  %t32 = load ptr, ptr %t2
  store ptr %t32, ptr %retval
  br label %ret
ret:
  %t33 = load ptr, ptr %retval
  ret ptr %t33
}

define ptr @fn_parse_hole(ptr %arg_inner) {
entry:
  %retval = alloca ptr
  %t0 = alloca ptr
  %t2 = alloca ptr
  %t4 = alloca i32
  %t7 = alloca ptr
  store ptr %arg_inner, ptr %t0
  %t1 = load ptr, ptr @g_toks
  store ptr %t1, ptr %t2
  %t3 = load i32, ptr @g_pi
  store i32 %t3, ptr %t4
  %t5 = load ptr, ptr %t0
  call void @fn_lex(ptr %t5)
  store i32 0, ptr @g_pi
  call void @fn_skipnl()
  %t6 = call ptr @fn_expr()
  store ptr %t6, ptr %t7
  %t8 = load ptr, ptr %t2
  store ptr %t8, ptr @g_toks
  %t9 = load i32, ptr %t4
  store i32 %t9, ptr @g_pi
  %t10 = load ptr, ptr %t7
  store ptr %t10, ptr %retval
  br label %ret
ret:
  %t11 = load ptr, ptr %retval
  ret ptr %t11
}

define ptr @fn_parse_interp(ptr %arg_raw) {
entry:
  %retval = alloca ptr
  %t0 = alloca ptr
  %t4 = alloca i32
  %t5 = alloca ptr
  %t10 = alloca ptr
  %t11 = alloca i32
  %t12 = alloca i32
  %t23 = alloca i32
  %t57 = alloca i32
  %t58 = alloca i32
  %t59 = alloca i32
  %t78 = alloca i32
  %t107 = alloca i32
  %t143 = alloca i32
  %t145 = alloca i32
  %t172 = alloca i32
  store ptr %arg_raw, ptr %t0
  %t1 = load ptr, ptr %t0
  %t2 = call i64 @strlen(ptr %t1)
  %t3 = trunc i64 %t2 to i32
  store i32 %t3, ptr %t4
  store ptr null, ptr %t5
  %t6 = load i32, ptr %t4
  %t7 = add i32 %t6, 1
  %t8 = zext i32 %t7 to i64
  %t9 = call ptr @malloc(i64 %t8)
  store ptr %t9, ptr %t10
  store i32 0, ptr %t11
  store i32 0, ptr %t12
  br label %wcond0
wcond0:
  %t13 = load i32, ptr %t12
  %t14 = load i32, ptr %t4
  %t15 = icmp slt i32 %t13, %t14
  %t16 = zext i1 %t15 to i32
  %t17 = icmp ne i32 %t16, 0
  br i1 %t17, label %wbody1, label %wend2
wbody1:
  %t18 = load ptr, ptr %t0
  %t19 = load i32, ptr %t12
  %t20 = getelementptr inbounds i8, ptr %t18, i32 %t19
  %t21 = load i8, ptr %t20
  %t22 = zext i8 %t21 to i32
  store i32 %t22, ptr %t23
  %t24 = load i32, ptr %t23
  %t25 = icmp eq i32 %t24, 123
  %t26 = zext i1 %t25 to i32
  %t27 = icmp ne i32 %t26, 0
  br i1 %t27, label %then3, label %else4
then3:
  %t28 = load ptr, ptr %t0
  %t29 = load i32, ptr %t12
  %t30 = add i32 %t29, 1
  %t31 = getelementptr inbounds i8, ptr %t28, i32 %t30
  %t32 = load i8, ptr %t31
  %t33 = zext i8 %t32 to i32
  %t34 = icmp eq i32 %t33, 123
  %t35 = zext i1 %t34 to i32
  %t36 = icmp ne i32 %t35, 0
  br i1 %t36, label %then6, label %ifend8
then6:
  %t37 = load ptr, ptr %t10
  %t38 = load i32, ptr %t11
  %t39 = getelementptr inbounds i8, ptr %t37, i32 %t38
  %t40 = trunc i32 123 to i8
  store i8 %t40, ptr %t39
  %t41 = load i32, ptr %t11
  %t42 = add i32 %t41, 1
  store i32 %t42, ptr %t11
  %t43 = load i32, ptr %t12
  %t44 = add i32 %t43, 2
  store i32 %t44, ptr %t12
  br label %wcond0
ifend8:
  %t45 = load i32, ptr %t11
  %t46 = icmp sgt i32 %t45, 0
  %t47 = zext i1 %t46 to i32
  %t48 = icmp ne i32 %t47, 0
  br i1 %t48, label %then9, label %ifend11
then9:
  %t49 = load ptr, ptr %t5
  %t50 = load ptr, ptr %t10
  %t51 = load i32, ptr %t11
  %t52 = call ptr @fn_interp_lit(ptr %t50, i32 %t51)
  %t53 = call ptr @fn_interp_add(ptr %t49, ptr %t52)
  store ptr %t53, ptr %t5
  store i32 0, ptr %t11
  br label %ifend11
ifend11:
  %t54 = load i32, ptr %t12
  %t55 = add i32 %t54, 1
  store i32 %t55, ptr %t12
  %t56 = load i32, ptr %t12
  store i32 %t56, ptr %t57
  store i32 1, ptr %t58
  br label %wcond12
wcond12:
  %t60 = load i32, ptr %t12
  %t61 = load i32, ptr %t4
  %t62 = icmp slt i32 %t60, %t61
  %t63 = zext i1 %t62 to i32
  %t64 = icmp ne i32 %t63, 0
  %t65 = zext i1 %t64 to i32
  store i32 %t65, ptr %t59
  br i1 %t64, label %sc15, label %scend16
sc15:
  %t66 = load i32, ptr %t58
  %t67 = icmp sgt i32 %t66, 0
  %t68 = zext i1 %t67 to i32
  %t69 = icmp ne i32 %t68, 0
  %t70 = zext i1 %t69 to i32
  store i32 %t70, ptr %t59
  br label %scend16
scend16:
  %t71 = load i32, ptr %t59
  %t72 = icmp ne i32 %t71, 0
  br i1 %t72, label %wbody13, label %wend14
wbody13:
  %t73 = load ptr, ptr %t0
  %t74 = load i32, ptr %t12
  %t75 = getelementptr inbounds i8, ptr %t73, i32 %t74
  %t76 = load i8, ptr %t75
  %t77 = zext i8 %t76 to i32
  store i32 %t77, ptr %t78
  %t79 = load i32, ptr %t78
  %t80 = icmp eq i32 %t79, 123
  %t81 = zext i1 %t80 to i32
  %t82 = icmp ne i32 %t81, 0
  br i1 %t82, label %then17, label %else18
then17:
  %t83 = load i32, ptr %t58
  %t84 = add i32 %t83, 1
  store i32 %t84, ptr %t58
  br label %ifend19
else18:
  %t85 = load i32, ptr %t78
  %t86 = icmp eq i32 %t85, 125
  %t87 = zext i1 %t86 to i32
  %t88 = icmp ne i32 %t87, 0
  br i1 %t88, label %then20, label %ifend22
then20:
  %t89 = load i32, ptr %t58
  %t90 = sub i32 %t89, 1
  store i32 %t90, ptr %t58
  %t91 = load i32, ptr %t58
  %t92 = icmp eq i32 %t91, 0
  %t93 = zext i1 %t92 to i32
  %t94 = icmp ne i32 %t93, 0
  br i1 %t94, label %then23, label %ifend25
then23:
  br label %wend14
ifend25:
  br label %ifend22
ifend22:
  br label %ifend19
ifend19:
  %t95 = load i32, ptr %t12
  %t96 = add i32 %t95, 1
  store i32 %t96, ptr %t12
  br label %wcond12
wend14:
  %t97 = load ptr, ptr %t5
  %t98 = load ptr, ptr %t0
  %t99 = load i32, ptr %t57
  %t100 = load i32, ptr %t12
  %t101 = call ptr @fn_str_slice(ptr %t98, i32 %t99, i32 %t100)
  %t102 = call ptr @fn_parse_hole(ptr %t101)
  %t103 = call ptr @fn_interp_str(ptr %t102)
  %t104 = call ptr @fn_interp_add(ptr %t97, ptr %t103)
  store ptr %t104, ptr %t5
  %t105 = load i32, ptr %t12
  %t106 = add i32 %t105, 1
  store i32 %t106, ptr %t12
  br label %ifend5
else4:
  %t108 = load i32, ptr %t23
  %t109 = icmp eq i32 %t108, 125
  %t110 = zext i1 %t109 to i32
  %t111 = icmp ne i32 %t110, 0
  %t112 = zext i1 %t111 to i32
  store i32 %t112, ptr %t107
  br i1 %t111, label %sc26, label %scend27
sc26:
  %t113 = load ptr, ptr %t0
  %t114 = load i32, ptr %t12
  %t115 = add i32 %t114, 1
  %t116 = getelementptr inbounds i8, ptr %t113, i32 %t115
  %t117 = load i8, ptr %t116
  %t118 = zext i8 %t117 to i32
  %t119 = icmp eq i32 %t118, 125
  %t120 = zext i1 %t119 to i32
  %t121 = icmp ne i32 %t120, 0
  %t122 = zext i1 %t121 to i32
  store i32 %t122, ptr %t107
  br label %scend27
scend27:
  %t123 = load i32, ptr %t107
  %t124 = icmp ne i32 %t123, 0
  br i1 %t124, label %then28, label %ifend30
then28:
  %t125 = load ptr, ptr %t10
  %t126 = load i32, ptr %t11
  %t127 = getelementptr inbounds i8, ptr %t125, i32 %t126
  %t128 = trunc i32 125 to i8
  store i8 %t128, ptr %t127
  %t129 = load i32, ptr %t11
  %t130 = add i32 %t129, 1
  store i32 %t130, ptr %t11
  %t131 = load i32, ptr %t12
  %t132 = add i32 %t131, 2
  store i32 %t132, ptr %t12
  br label %wcond0
ifend30:
  %t133 = load i32, ptr %t23
  %t134 = icmp eq i32 %t133, 92
  %t135 = zext i1 %t134 to i32
  %t136 = icmp ne i32 %t135, 0
  br i1 %t136, label %then31, label %ifend33
then31:
  %t137 = load ptr, ptr %t0
  %t138 = load i32, ptr %t12
  %t139 = add i32 %t138, 1
  %t140 = getelementptr inbounds i8, ptr %t137, i32 %t139
  %t141 = load i8, ptr %t140
  %t142 = zext i8 %t141 to i32
  store i32 %t142, ptr %t143
  %t144 = load i32, ptr %t143
  store i32 %t144, ptr %t145
  %t146 = load i32, ptr %t143
  %t147 = icmp eq i32 %t146, 110
  %t148 = zext i1 %t147 to i32
  %t149 = icmp ne i32 %t148, 0
  br i1 %t149, label %then34, label %ifend36
then34:
  store i32 10, ptr %t145
  br label %ifend36
ifend36:
  %t150 = load i32, ptr %t143
  %t151 = icmp eq i32 %t150, 116
  %t152 = zext i1 %t151 to i32
  %t153 = icmp ne i32 %t152, 0
  br i1 %t153, label %then37, label %ifend39
then37:
  store i32 9, ptr %t145
  br label %ifend39
ifend39:
  %t154 = load ptr, ptr %t10
  %t155 = load i32, ptr %t11
  %t156 = getelementptr inbounds i8, ptr %t154, i32 %t155
  %t157 = load i32, ptr %t145
  %t158 = trunc i32 %t157 to i8
  store i8 %t158, ptr %t156
  %t159 = load i32, ptr %t11
  %t160 = add i32 %t159, 1
  store i32 %t160, ptr %t11
  %t161 = load i32, ptr %t12
  %t162 = add i32 %t161, 2
  store i32 %t162, ptr %t12
  br label %wcond0
ifend33:
  %t163 = load ptr, ptr %t10
  %t164 = load i32, ptr %t11
  %t165 = getelementptr inbounds i8, ptr %t163, i32 %t164
  %t166 = load i32, ptr %t23
  %t167 = trunc i32 %t166 to i8
  store i8 %t167, ptr %t165
  %t168 = load i32, ptr %t11
  %t169 = add i32 %t168, 1
  store i32 %t169, ptr %t11
  %t170 = load i32, ptr %t12
  %t171 = add i32 %t170, 1
  store i32 %t171, ptr %t12
  br label %ifend5
ifend5:
  br label %wcond0
wend2:
  %t173 = load i32, ptr %t11
  %t174 = icmp sgt i32 %t173, 0
  %t175 = zext i1 %t174 to i32
  %t176 = icmp ne i32 %t175, 0
  %t177 = zext i1 %t176 to i32
  store i32 %t177, ptr %t172
  br i1 %t176, label %scend41, label %sc40
sc40:
  %t178 = load ptr, ptr %t5
  %t179 = icmp eq ptr %t178, null
  %t180 = zext i1 %t179 to i32
  %t181 = icmp ne i32 %t180, 0
  %t182 = zext i1 %t181 to i32
  store i32 %t182, ptr %t172
  br label %scend41
scend41:
  %t183 = load i32, ptr %t172
  %t184 = icmp ne i32 %t183, 0
  br i1 %t184, label %then42, label %ifend44
then42:
  %t185 = load ptr, ptr %t5
  %t186 = load ptr, ptr %t10
  %t187 = load i32, ptr %t11
  %t188 = call ptr @fn_interp_lit(ptr %t186, i32 %t187)
  %t189 = call ptr @fn_interp_add(ptr %t185, ptr %t188)
  store ptr %t189, ptr %t5
  br label %ifend44
ifend44:
  %t190 = load ptr, ptr %t5
  store ptr %t190, ptr %retval
  br label %ret
ret:
  %t191 = load ptr, ptr %retval
  ret ptr %t191
}

define ptr @fn_p_primary() {
entry:
  %retval = alloca ptr
  %t6 = alloca ptr
  %t26 = alloca ptr
  %t42 = alloca ptr
  %t58 = alloca ptr
  %t79 = alloca ptr
  %t91 = alloca ptr
  %t113 = alloca ptr
  %t119 = alloca ptr
  %t133 = alloca ptr
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
  %t10 = icmp eq i32 %t9, 7
  %t11 = zext i1 %t10 to i32
  %t12 = icmp ne i32 %t11, 0
  br i1 %t12, label %then0, label %ifend2
then0:
  %t13 = load i32, ptr @g_pi
  %t14 = add i32 %t13, 1
  store i32 %t14, ptr @g_pi
  %t15 = load ptr, ptr %t6
  %t16 = getelementptr inbounds %Cmp_Tok, ptr %t15, i32 0, i32 1
  %t17 = load ptr, ptr %t16
  %t18 = call ptr @fn_parse_interp(ptr %t17)
  store ptr %t18, ptr %retval
  br label %ret
ifend2:
  %t19 = load ptr, ptr %t6
  %t20 = getelementptr inbounds %Cmp_Tok, ptr %t19, i32 0, i32 0
  %t21 = load i32, ptr %t20
  %t22 = icmp eq i32 %t21, 1
  %t23 = zext i1 %t22 to i32
  %t24 = icmp ne i32 %t23, 0
  br i1 %t24, label %then3, label %ifend5
then3:
  %t25 = call ptr @fn_node(i32 30)
  store ptr %t25, ptr %t26
  %t27 = load ptr, ptr %t26
  %t28 = getelementptr inbounds %Cmp_Node, ptr %t27, i32 0, i32 2
  %t29 = load ptr, ptr %t6
  %t30 = getelementptr inbounds %Cmp_Tok, ptr %t29, i32 0, i32 2
  %t31 = load i32, ptr %t30
  store i32 %t31, ptr %t28
  %t32 = load i32, ptr @g_pi
  %t33 = add i32 %t32, 1
  store i32 %t33, ptr @g_pi
  %t34 = load ptr, ptr %t26
  store ptr %t34, ptr %retval
  br label %ret
ifend5:
  %t35 = load ptr, ptr %t6
  %t36 = getelementptr inbounds %Cmp_Tok, ptr %t35, i32 0, i32 0
  %t37 = load i32, ptr %t36
  %t38 = icmp eq i32 %t37, 6
  %t39 = zext i1 %t38 to i32
  %t40 = icmp ne i32 %t39, 0
  br i1 %t40, label %then6, label %ifend8
then6:
  %t41 = call ptr @fn_node(i32 40)
  store ptr %t41, ptr %t42
  %t43 = load ptr, ptr %t42
  %t44 = getelementptr inbounds %Cmp_Node, ptr %t43, i32 0, i32 2
  %t45 = load ptr, ptr %t6
  %t46 = getelementptr inbounds %Cmp_Tok, ptr %t45, i32 0, i32 2
  %t47 = load i32, ptr %t46
  store i32 %t47, ptr %t44
  %t48 = load i32, ptr @g_pi
  %t49 = add i32 %t48, 1
  store i32 %t49, ptr @g_pi
  %t50 = load ptr, ptr %t42
  store ptr %t50, ptr %retval
  br label %ret
ifend8:
  %t51 = load ptr, ptr %t6
  %t52 = getelementptr inbounds %Cmp_Tok, ptr %t51, i32 0, i32 0
  %t53 = load i32, ptr %t52
  %t54 = icmp eq i32 %t53, 2
  %t55 = zext i1 %t54 to i32
  %t56 = icmp ne i32 %t55, 0
  br i1 %t56, label %then9, label %ifend11
then9:
  %t57 = call ptr @fn_node(i32 31)
  store ptr %t57, ptr %t58
  %t59 = load ptr, ptr %t58
  %t60 = getelementptr inbounds %Cmp_Node, ptr %t59, i32 0, i32 1
  %t61 = load ptr, ptr %t6
  %t62 = getelementptr inbounds %Cmp_Tok, ptr %t61, i32 0, i32 1
  %t63 = load ptr, ptr %t62
  store ptr %t63, ptr %t60
  %t64 = load i32, ptr @g_pi
  %t65 = add i32 %t64, 1
  store i32 %t65, ptr @g_pi
  %t66 = load ptr, ptr %t58
  store ptr %t66, ptr %retval
  br label %ret
ifend11:
  %t67 = load ptr, ptr %t6
  %t68 = getelementptr inbounds %Cmp_Tok, ptr %t67, i32 0, i32 0
  %t69 = load i32, ptr %t68
  %t70 = icmp eq i32 %t69, 0
  %t71 = zext i1 %t70 to i32
  %t72 = icmp ne i32 %t71, 0
  br i1 %t72, label %then12, label %ifend14
then12:
  %t73 = load ptr, ptr %t6
  %t74 = getelementptr inbounds %Cmp_Tok, ptr %t73, i32 0, i32 1
  %t75 = load ptr, ptr %t74
  %t76 = call i32 @fn_str_eq(ptr %t75, ptr @.str12)
  %t77 = icmp ne i32 %t76, 0
  br i1 %t77, label %then15, label %ifend17
then15:
  %t78 = call ptr @fn_node(i32 32)
  store ptr %t78, ptr %t79
  %t80 = load ptr, ptr %t79
  %t81 = getelementptr inbounds %Cmp_Node, ptr %t80, i32 0, i32 2
  store i32 1, ptr %t81
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
  %t88 = call i32 @fn_str_eq(ptr %t87, ptr @.str13)
  %t89 = icmp ne i32 %t88, 0
  br i1 %t89, label %then18, label %ifend20
then18:
  %t90 = call ptr @fn_node(i32 32)
  store ptr %t90, ptr %t91
  %t92 = load ptr, ptr %t91
  %t93 = getelementptr inbounds %Cmp_Node, ptr %t92, i32 0, i32 2
  store i32 0, ptr %t93
  %t94 = load i32, ptr @g_pi
  %t95 = add i32 %t94, 1
  store i32 %t95, ptr @g_pi
  %t96 = load ptr, ptr %t91
  store ptr %t96, ptr %retval
  br label %ret
ifend20:
  %t97 = load ptr, ptr %t6
  %t98 = getelementptr inbounds %Cmp_Tok, ptr %t97, i32 0, i32 1
  %t99 = load ptr, ptr %t98
  %t100 = call i32 @fn_str_eq(ptr %t99, ptr @.str14)
  %t101 = icmp ne i32 %t100, 0
  br i1 %t101, label %then21, label %ifend23
then21:
  %t102 = load i32, ptr @g_pi
  %t103 = add i32 %t102, 1
  store i32 %t103, ptr @g_pi
  %t104 = call ptr @fn_node(i32 43)
  store ptr %t104, ptr %retval
  br label %ret
ifend23:
  %t105 = load ptr, ptr %t6
  %t106 = getelementptr inbounds %Cmp_Tok, ptr %t105, i32 0, i32 1
  %t107 = load ptr, ptr %t106
  %t108 = call i32 @fn_str_eq(ptr %t107, ptr @.str15)
  %t109 = icmp ne i32 %t108, 0
  br i1 %t109, label %then24, label %ifend26
then24:
  %t110 = load i32, ptr @g_pi
  %t111 = add i32 %t110, 1
  store i32 %t111, ptr @g_pi
  %t112 = call ptr @fn_node(i32 39)
  store ptr %t112, ptr %t113
  %t114 = load ptr, ptr %t113
  %t115 = getelementptr inbounds %Cmp_Node, ptr %t114, i32 0, i32 1
  %t116 = call ptr @fn_ptype()
  store ptr %t116, ptr %t115
  %t117 = load ptr, ptr %t113
  store ptr %t117, ptr %retval
  br label %ret
ifend26:
  %t118 = call ptr @fn_node(i32 33)
  store ptr %t118, ptr %t119
  %t120 = load ptr, ptr %t119
  %t121 = getelementptr inbounds %Cmp_Node, ptr %t120, i32 0, i32 1
  %t122 = load ptr, ptr %t6
  %t123 = getelementptr inbounds %Cmp_Tok, ptr %t122, i32 0, i32 1
  %t124 = load ptr, ptr %t123
  store ptr %t124, ptr %t121
  %t125 = load i32, ptr @g_pi
  %t126 = add i32 %t125, 1
  store i32 %t126, ptr @g_pi
  %t127 = load ptr, ptr %t119
  store ptr %t127, ptr %retval
  br label %ret
ifend14:
  %t128 = call i32 @fn_is_op(ptr @.str16)
  %t129 = icmp ne i32 %t128, 0
  br i1 %t129, label %then27, label %ifend29
then27:
  %t130 = load i32, ptr @g_pi
  %t131 = add i32 %t130, 1
  store i32 %t131, ptr @g_pi
  call void @fn_skipnl()
  %t132 = call ptr @fn_expr()
  store ptr %t132, ptr %t133
  call void @fn_skipnl()
  call void @fn_eat_op(ptr @.str17)
  %t134 = load ptr, ptr %t133
  store ptr %t134, ptr %retval
  br label %ret
ifend29:
  call void @fn_perr(ptr @.str18)
  %t135 = call ptr @fn_node(i32 30)
  store ptr %t135, ptr %retval
  br label %ret
ret:
  %t136 = load ptr, ptr %retval
  ret ptr %t136
}

define ptr @fn_p_postfix() {
entry:
  %retval = alloca ptr
  %t1 = alloca ptr
  %t8 = alloca ptr
  %t21 = alloca ptr
  %t27 = alloca ptr
  %t39 = alloca ptr
  %t50 = alloca ptr
  %t0 = call ptr @fn_p_primary()
  store ptr %t0, ptr %t1
  br label %wcond0
wcond0:
  %t2 = icmp ne i32 1, 0
  br i1 %t2, label %wbody1, label %wend2
wbody1:
  %t3 = call i32 @fn_is_op(ptr @.str19)
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
  %t16 = call i32 @fn_is_op(ptr @.str20)
  %t17 = icmp ne i32 %t16, 0
  br i1 %t17, label %then6, label %else7
then6:
  %t18 = load i32, ptr @g_pi
  %t19 = add i32 %t18, 1
  store i32 %t19, ptr @g_pi
  %t20 = call ptr @fn_expr()
  store ptr %t20, ptr %t21
  %t22 = call i32 @fn_is_op(ptr @.str21)
  %t23 = icmp ne i32 %t22, 0
  br i1 %t23, label %then9, label %else10
then9:
  %t24 = load i32, ptr @g_pi
  %t25 = add i32 %t24, 1
  store i32 %t25, ptr @g_pi
  %t26 = call ptr @fn_node(i32 44)
  store ptr %t26, ptr %t27
  %t28 = load ptr, ptr %t27
  %t29 = getelementptr inbounds %Cmp_Node, ptr %t28, i32 0, i32 4
  %t30 = load ptr, ptr %t1
  store ptr %t30, ptr %t29
  %t31 = load ptr, ptr %t27
  %t32 = getelementptr inbounds %Cmp_Node, ptr %t31, i32 0, i32 5
  %t33 = load ptr, ptr %t21
  store ptr %t33, ptr %t32
  %t34 = load ptr, ptr %t27
  %t35 = getelementptr inbounds %Cmp_Node, ptr %t34, i32 0, i32 6
  %t36 = call ptr @fn_expr()
  store ptr %t36, ptr %t35
  call void @fn_eat_op(ptr @.str22)
  %t37 = load ptr, ptr %t27
  store ptr %t37, ptr %t1
  br label %ifend11
else10:
  %t38 = call ptr @fn_node(i32 36)
  store ptr %t38, ptr %t39
  %t40 = load ptr, ptr %t39
  %t41 = getelementptr inbounds %Cmp_Node, ptr %t40, i32 0, i32 4
  %t42 = load ptr, ptr %t1
  store ptr %t42, ptr %t41
  %t43 = load ptr, ptr %t39
  %t44 = getelementptr inbounds %Cmp_Node, ptr %t43, i32 0, i32 5
  %t45 = load ptr, ptr %t21
  store ptr %t45, ptr %t44
  call void @fn_eat_op(ptr @.str23)
  %t46 = load ptr, ptr %t39
  store ptr %t46, ptr %t1
  br label %ifend11
ifend11:
  br label %ifend8
else7:
  %t47 = call i32 @fn_is_op(ptr @.str24)
  %t48 = icmp ne i32 %t47, 0
  br i1 %t48, label %then12, label %else13
then12:
  %t49 = call ptr @fn_node(i32 34)
  store ptr %t49, ptr %t50
  %t51 = load ptr, ptr %t50
  %t52 = getelementptr inbounds %Cmp_Node, ptr %t51, i32 0, i32 4
  %t53 = load ptr, ptr %t1
  store ptr %t53, ptr %t52
  %t54 = load ptr, ptr %t50
  call void @fn_args_call(ptr %t54)
  %t55 = load ptr, ptr %t50
  store ptr %t55, ptr %t1
  br label %ifend14
else13:
  br label %wend2
ifend14:
  br label %ifend8
ifend8:
  br label %ifend5
ifend5:
  br label %wcond0
wend2:
  %t56 = load ptr, ptr %t1
  store ptr %t56, ptr %retval
  br label %ret
ret:
  %t57 = load ptr, ptr %retval
  ret ptr %t57
}

define ptr @fn_p_unary() {
entry:
  %retval = alloca ptr
  %t5 = alloca ptr
  %t17 = alloca ptr
  %t29 = alloca ptr
  %t0 = call i32 @fn_is_op(ptr @.str25)
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
  store ptr @.str26, ptr %t7
  %t8 = load ptr, ptr %t5
  %t9 = getelementptr inbounds %Cmp_Node, ptr %t8, i32 0, i32 4
  %t10 = call ptr @fn_p_unary()
  store ptr %t10, ptr %t9
  %t11 = load ptr, ptr %t5
  store ptr %t11, ptr %retval
  br label %ret
ifend2:
  %t12 = call i32 @fn_is_op(ptr @.str27)
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
  store ptr @.str28, ptr %t19
  %t20 = load ptr, ptr %t17
  %t21 = getelementptr inbounds %Cmp_Node, ptr %t20, i32 0, i32 4
  %t22 = call ptr @fn_p_unary()
  store ptr %t22, ptr %t21
  %t23 = load ptr, ptr %t17
  store ptr %t23, ptr %retval
  br label %ret
ifend5:
  %t24 = call i32 @fn_is_id(ptr @.str29)
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
  store ptr @.str30, ptr %t31
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
  %t7 = call i32 @fn_is_op(ptr @.str31)
  %t8 = icmp ne i32 %t7, 0
  %t9 = zext i1 %t8 to i32
  store i32 %t9, ptr %t6
  br i1 %t8, label %scend4, label %sc3
sc3:
  %t10 = call i32 @fn_is_op(ptr @.str32)
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
  %t16 = call i32 @fn_is_op(ptr @.str33)
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
  %t22 = call i32 @fn_is_op(ptr @.str34)
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
  %t28 = call i32 @fn_is_op(ptr @.str35)
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
  %t34 = call i32 @fn_is_op(ptr @.str36)
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
  %t5 = call i32 @fn_is_op(ptr @.str37)
  %t6 = icmp ne i32 %t5, 0
  %t7 = zext i1 %t6 to i32
  store i32 %t7, ptr %t4
  br i1 %t6, label %scend4, label %sc3
sc3:
  %t8 = call i32 @fn_is_op(ptr @.str38)
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
  %t14 = call i32 @fn_is_op(ptr @.str39)
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
  %t20 = call i32 @fn_is_op(ptr @.str40)
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
  %t7 = call i32 @fn_is_op(ptr @.str41)
  %t8 = icmp ne i32 %t7, 0
  %t9 = zext i1 %t8 to i32
  store i32 %t9, ptr %t6
  br i1 %t8, label %scend4, label %sc3
sc3:
  %t10 = call i32 @fn_is_op(ptr @.str42)
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
  %t16 = call i32 @fn_is_op(ptr @.str43)
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
  %t22 = call i32 @fn_is_op(ptr @.str44)
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
  %t28 = call i32 @fn_is_op(ptr @.str45)
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
  %t34 = call i32 @fn_is_op(ptr @.str46)
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
  %t2 = call i32 @fn_is_id(ptr @.str47)
  %t3 = icmp ne i32 %t2, 0
  br i1 %t3, label %wbody1, label %wend2
wbody1:
  %t4 = load i32, ptr @g_pi
  %t5 = add i32 %t4, 1
  store i32 %t5, ptr @g_pi
  %t6 = load ptr, ptr %t1
  %t7 = call ptr @fn_p_cmp()
  %t8 = call ptr @fn_mkbin(ptr @.str48, ptr %t6, ptr %t7)
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
  %t2 = call i32 @fn_is_id(ptr @.str49)
  %t3 = icmp ne i32 %t2, 0
  br i1 %t3, label %wbody1, label %wend2
wbody1:
  %t4 = load i32, ptr @g_pi
  %t5 = add i32 %t4, 1
  store i32 %t5, ptr @g_pi
  %t6 = load ptr, ptr %t1
  %t7 = call ptr @fn_p_and()
  %t8 = call ptr @fn_mkbin(ptr @.str50, ptr %t6, ptr %t7)
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
  call void @fn_eat_op(ptr @.str51)
  %t0 = call ptr @fn_node(i32 41)
  store ptr %t0, ptr %t1
  br label %wcond0
wcond0:
  %t2 = icmp ne i32 1, 0
  br i1 %t2, label %wbody1, label %wend2
wbody1:
  call void @fn_skipnl()
  %t3 = call i32 @fn_is_op(ptr @.str52)
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
  call void @fn_eat_op(ptr @.str53)
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
  %t35 = call i32 @fn_is_op(ptr @.str54)
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
  call void @fn_eat_op(ptr @.str55)
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
  call void @fn_eat_op(ptr @.str56)
  %t0 = call ptr @fn_node(i32 7)
  store ptr %t0, ptr %t1
  br label %wcond0
wcond0:
  %t2 = icmp ne i32 1, 0
  br i1 %t2, label %wbody1, label %wend2
wbody1:
  call void @fn_skipnl()
  %t3 = call i32 @fn_is_op(ptr @.str57)
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
  %t38 = call i32 @fn_is_op(ptr @.str58)
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
  call void @fn_perr(ptr @.str59)
  br label %ifend13
ifend13:
  br label %wcond0
wend2:
  call void @fn_eat_op(ptr @.str60)
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
  %t17 = call i32 @fn_str_eq(ptr %t16, ptr @.str61)
  %t18 = icmp ne i32 %t17, 0
  %t19 = zext i1 %t18 to i32
  store i32 %t19, ptr %t13
  br i1 %t18, label %scend4, label %sc3
sc3:
  %t20 = load ptr, ptr %t6
  %t21 = getelementptr inbounds %Cmp_Tok, ptr %t20, i32 0, i32 1
  %t22 = load ptr, ptr %t21
  %t23 = call i32 @fn_str_eq(ptr %t22, ptr @.str62)
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
  %t32 = call i32 @fn_str_eq(ptr %t31, ptr @.str63)
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
  %t54 = call i32 @fn_is_op(ptr @.str64)
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
  %t61 = call i32 @fn_is_op(ptr @.str65)
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
  %t72 = call i32 @fn_str_eq(ptr %t71, ptr @.str66)
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
  %t91 = call i32 @fn_is_op(ptr @.str67)
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
  %t105 = call i32 @fn_str_eq(ptr %t104, ptr @.str68)
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
  %t119 = call i32 @fn_is_id(ptr @.str69)
  %t120 = icmp ne i32 %t119, 0
  br i1 %t120, label %then28, label %else29
then28:
  %t121 = load i32, ptr @g_pi
  %t122 = add i32 %t121, 1
  store i32 %t122, ptr @g_pi
  call void @fn_skipnl()
  %t123 = call i32 @fn_is_id(ptr @.str70)
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
  %t136 = call i32 @fn_str_eq(ptr %t135, ptr @.str71)
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
  %t152 = call i32 @fn_str_eq(ptr %t151, ptr @.str72)
  %t153 = icmp ne i32 %t152, 0
  br i1 %t153, label %then37, label %ifend39
then37:
  %t154 = load i32, ptr @g_pi
  %t155 = add i32 %t154, 1
  store i32 %t155, ptr @g_pi
  %t156 = call i32 @fn_is_op(ptr @.str73)
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
  call void @fn_eat_op(ptr @.str74)
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
  %t179 = call i32 @fn_str_eq(ptr %t178, ptr @.str75)
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
  %t185 = call i32 @fn_str_eq(ptr %t184, ptr @.str76)
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
  call void @fn_eat_op(ptr @.str77)
  store i32 0, ptr %t194
  br label %wcond49
wcond49:
  %t195 = icmp ne i32 1, 0
  br i1 %t195, label %wbody50, label %wend51
wbody50:
  call void @fn_skipnl()
  %t196 = call i32 @fn_is_op(ptr @.str78)
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
  %t205 = call i32 @fn_is_op(ptr @.str79)
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
  call void @fn_eat_op(ptr @.str80)
  %t247 = load ptr, ptr %t190
  store ptr %t247, ptr %retval
  br label %ret
ifend48:
  %t248 = load ptr, ptr %t6
  %t249 = getelementptr inbounds %Cmp_Tok, ptr %t248, i32 0, i32 1
  %t250 = load ptr, ptr %t249
  %t251 = call i32 @fn_str_eq(ptr %t250, ptr @.str81)
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
  %t264 = call i32 @fn_str_eq(ptr %t263, ptr @.str82)
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
  %t278 = call i32 @fn_str_eq(ptr %t277, ptr @.str83)
  %t279 = icmp ne i32 %t278, 0
  %t280 = zext i1 %t279 to i32
  store i32 %t280, ptr %t274
  br i1 %t279, label %scend67, label %sc66
sc66:
  %t281 = load ptr, ptr %t6
  %t282 = getelementptr inbounds %Cmp_Tok, ptr %t281, i32 0, i32 1
  %t283 = load ptr, ptr %t282
  %t284 = call i32 @fn_str_eq(ptr %t283, ptr @.str84)
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
  %t293 = call i32 @fn_str_eq(ptr %t292, ptr @.str85)
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
  %t305 = call i32 @fn_is_id(ptr @.str86)
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
  %t316 = call i32 @fn_str_eq(ptr %t315, ptr @.str87)
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
  %t324 = call i32 @fn_str_eq(ptr %t323, ptr @.str88)
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
  %t332 = call i32 @fn_str_eq(ptr %t331, ptr @.str89)
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
  call void @fn_eat_op(ptr @.str90)
  br label %wcond86
wcond86:
  %t341 = icmp ne i32 1, 0
  br i1 %t341, label %wbody87, label %wend88
wbody87:
  call void @fn_skipnl()
  %t342 = call i32 @fn_is_op(ptr @.str91)
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
  %t369 = call i32 @fn_is_op(ptr @.str92)
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
  call void @fn_eat_op(ptr @.str93)
  call void @fn_skipnl()
  %t373 = call i32 @fn_is_op(ptr @.str94)
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
  call void @fn_eat_op(ptr @.str95)
  %t427 = load ptr, ptr %t337
  store ptr %t427, ptr %retval
  br label %ret
ifend85:
  br label %ifend2
ifend2:
  %t428 = call ptr @fn_expr()
  store ptr %t428, ptr %t429
  %t434 = call i32 @fn_is_op(ptr @.str96)
  %t435 = icmp ne i32 %t434, 0
  %t436 = zext i1 %t435 to i32
  store i32 %t436, ptr %t433
  br i1 %t435, label %scend108, label %sc107
sc107:
  %t437 = call i32 @fn_is_op(ptr @.str97)
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
  %t443 = call i32 @fn_is_op(ptr @.str98)
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
  %t449 = call i32 @fn_is_op(ptr @.str99)
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
  %t455 = call i32 @fn_is_op(ptr @.str100)
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
  call void @fn_eat_op(ptr @.str101)
  %t7 = load ptr, ptr %t3
  %t8 = getelementptr inbounds %Cmp_Node, ptr %t7, i32 0, i32 3
  %t9 = call ptr @fn_ptype()
  store ptr %t9, ptr %t8
  %t10 = call i32 @fn_is_op(ptr @.str102)
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
  call void @fn_eat_op(ptr @.str103)
  %t7 = load ptr, ptr %t3
  %t8 = getelementptr inbounds %Cmp_Node, ptr %t7, i32 0, i32 3
  %t9 = call ptr @fn_ptype()
  store ptr %t9, ptr %t8
  call void @fn_eat_op(ptr @.str104)
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
  call void @fn_eat_op(ptr @.str105)
  br label %wcond0
wcond0:
  %t7 = call i32 @fn_is_op(ptr @.str106)
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
  call void @fn_eat_op(ptr @.str107)
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
  %t41 = call i32 @fn_is_op(ptr @.str108)
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
  call void @fn_eat_op(ptr @.str109)
  %t45 = load ptr, ptr %t3
  %t46 = getelementptr inbounds %Cmp_Node, ptr %t45, i32 0, i32 3
  store ptr @.str110, ptr %t46
  %t47 = call i32 @fn_is_op(ptr @.str111)
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
  store ptr @.str112, ptr %retval
  br label %ret
ifend8:
  %t27 = load ptr, ptr %t0
  %t28 = load i32, ptr %t2
  %t29 = add i32 %t28, 1
  %t30 = add i32 0, %t29
  %t31 = call ptr @fn_str_slice(ptr %t27, i32 0, i32 %t30)
  store ptr %t31, ptr %retval
  br label %ret
ret:
  %t32 = load ptr, ptr %retval
  ret ptr %t32
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
  %t8 = call i32 @fn_is_op(ptr @.str113)
  %t9 = icmp ne i32 %t8, 0
  br i1 %t9, label %wbody1, label %wend2
wbody1:
  %t10 = load i32, ptr @g_pi
  %t11 = add i32 %t10, 1
  store i32 %t11, ptr @g_pi
  %t12 = call ptr @fn_eat_id()
  store ptr %t12, ptr %t13
  %t14 = load ptr, ptr %t13
  %t15 = call i32 @fn_str_eq(ptr %t14, ptr @.str114)
  %t16 = icmp ne i32 %t15, 0
  br i1 %t16, label %then3, label %else4
then3:
  store i32 1, ptr %t0
  br label %ifend5
else4:
  %t17 = load ptr, ptr %t13
  %t18 = call i32 @fn_str_eq(ptr %t17, ptr @.str115)
  %t19 = icmp ne i32 %t18, 0
  br i1 %t19, label %then6, label %else7
then6:
  %t20 = call ptr @fn_parse_queries_anno()
  store ptr %t20, ptr %t1
  br label %ifend8
else7:
  %t21 = load ptr, ptr %t13
  %t22 = call i32 @fn_str_eq(ptr %t21, ptr @.str116)
  %t23 = icmp ne i32 %t22, 0
  br i1 %t23, label %then9, label %else10
then9:
  call void @fn_eat_op(ptr @.str117)
  %t24 = call ptr @fn_eat_id()
  store ptr %t24, ptr %t2
  call void @fn_eat_op(ptr @.str118)
  br label %ifend11
else10:
  %t25 = load ptr, ptr %t13
  %t26 = call i32 @fn_str_eq(ptr %t25, ptr @.str119)
  %t27 = icmp ne i32 %t26, 0
  br i1 %t27, label %then12, label %else13
then12:
  call void @fn_eat_op(ptr @.str120)
  %t28 = call ptr @fn_eat_id()
  store ptr %t28, ptr %t3
  call void @fn_eat_op(ptr @.str121)
  br label %ifend14
else13:
  %t29 = load ptr, ptr %t13
  %t30 = call i32 @fn_str_eq(ptr %t29, ptr @.str122)
  %t31 = icmp ne i32 %t30, 0
  br i1 %t31, label %then15, label %else16
then15:
  call void @fn_eat_op(ptr @.str123)
  %t32 = call ptr @fn_eat_id()
  store ptr %t32, ptr %t4
  call void @fn_eat_op(ptr @.str124)
  br label %ifend17
else16:
  %t33 = load ptr, ptr %t13
  %t34 = call i32 @fn_str_eq(ptr %t33, ptr @.str125)
  %t35 = icmp ne i32 %t34, 0
  br i1 %t35, label %then18, label %else19
then18:
  call void @fn_eat_op(ptr @.str126)
  %t36 = call ptr @fn_eat_id()
  store ptr %t36, ptr %t5
  call void @fn_eat_op(ptr @.str127)
  br label %ifend20
else19:
  %t37 = load ptr, ptr %t13
  %t38 = call i32 @fn_str_eq(ptr %t37, ptr @.str128)
  %t39 = icmp ne i32 %t38, 0
  br i1 %t39, label %then21, label %else22
then21:
  call void @fn_eat_op(ptr @.str129)
  %t40 = call ptr @fn_eat_id()
  store ptr %t40, ptr %t6
  call void @fn_eat_op(ptr @.str130)
  br label %ifend23
else22:
  %t41 = load ptr, ptr %t13
  %t42 = call i32 @fn_str_eq(ptr %t41, ptr @.str131)
  %t43 = icmp ne i32 %t42, 0
  br i1 %t43, label %then24, label %else25
then24:
  store ptr @.str132, ptr %t7
  br label %ifend26
else25:
  %t44 = load ptr, ptr %t13
  %t45 = call i32 @fn_str_eq(ptr %t44, ptr @.str133)
  %t46 = icmp ne i32 %t45, 0
  br i1 %t46, label %then27, label %else28
then27:
  store ptr @.str134, ptr %t7
  br label %ifend29
else28:
  %t47 = call i32 @fn_is_op(ptr @.str135)
  %t48 = icmp ne i32 %t47, 0
  br i1 %t48, label %then30, label %ifend32
then30:
  store i32 0, ptr %t49
  br label %wcond33
wcond33:
  %t50 = icmp ne i32 1, 0
  br i1 %t50, label %wbody34, label %wend35
wbody34:
  %t51 = call i32 @fn_is_op(ptr @.str136)
  %t52 = icmp ne i32 %t51, 0
  br i1 %t52, label %then36, label %ifend38
then36:
  %t53 = load i32, ptr %t49
  %t54 = add i32 %t53, 1
  store i32 %t54, ptr %t49
  br label %ifend38
ifend38:
  %t55 = call i32 @fn_is_op(ptr @.str137)
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
  %t65 = call i32 @fn_is_id(ptr @.str138)
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
  call void @fn_perr(ptr @.str139)
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
  %t89 = call i32 @fn_is_id(ptr @.str140)
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
  %t111 = call i32 @fn_is_id(ptr @.str141)
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
  %t133 = call i32 @fn_is_id(ptr @.str142)
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
  %t155 = call i32 @fn_is_id(ptr @.str143)
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
  %t262 = call i32 @fn_is_id(ptr @.str144)
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
  %t284 = call i32 @fn_is_id(ptr @.str145)
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
  %t306 = call i32 @fn_is_id(ptr @.str146)
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
  %t328 = call i32 @fn_is_id(ptr @.str147)
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
  %t356 = call i32 @fn_is_id(ptr @.str148)
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
  %t378 = call i32 @fn_is_id(ptr @.str149)
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
  call void @fn_perr(ptr @.str150)
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
  %t36 = call ptr @fn_str_concat(ptr @.str151, ptr %t35)
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
  store ptr @.str152, ptr @g_cur_dir
  call void @fn_do_import(ptr @.str153)
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
  store ptr @.str154, ptr @g_g_game_name
  br label %wcond0
wcond0:
  %t48 = call i32 @fn_is_id(ptr @.str155)
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
  %t66 = call i32 @fn_is_op(ptr @.str156)
  %t67 = icmp ne i32 %t66, 0
  br i1 %t67, label %wbody4, label %wend5
wbody4:
  %t68 = load i32, ptr @g_pi
  %t69 = add i32 %t68, 1
  store i32 %t69, ptr @g_pi
  %t70 = call ptr @fn_eat_id()
  store ptr %t70, ptr %t71
  %t72 = call i32 @fn_is_op(ptr @.str157)
  %t73 = icmp ne i32 %t72, 0
  br i1 %t73, label %then6, label %ifend8
then6:
  store i32 0, ptr %t74
  br label %wcond9
wcond9:
  %t75 = icmp ne i32 1, 0
  br i1 %t75, label %wbody10, label %wend11
wbody10:
  %t76 = call i32 @fn_is_op(ptr @.str158)
  %t77 = icmp ne i32 %t76, 0
  br i1 %t77, label %then12, label %ifend14
then12:
  %t78 = load i32, ptr %t74
  %t79 = add i32 %t78, 1
  store i32 %t79, ptr %t74
  br label %ifend14
ifend14:
  %t80 = call i32 @fn_is_op(ptr @.str159)
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
  %t90 = call i32 @fn_is_id(ptr @.str160)
  %t91 = icmp ne i32 %t90, 0
  br i1 %t91, label %then21, label %ifend23
then21:
  %t92 = load i32, ptr @g_pi
  %t93 = add i32 %t92, 1
  store i32 %t93, ptr @g_pi
  %t94 = call ptr @fn_eat_id()
  store ptr %t94, ptr @g_g_game_name
  call void @fn_skipnl()
  call void @fn_eat_op(ptr @.str161)
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
  %t107 = call i32 @fn_is_op(ptr @.str162)
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
  call void @fn_eat_op(ptr @.str163)
  br label %wcond0
wcond0:
  %t7 = icmp ne i32 1, 0
  br i1 %t7, label %wbody1, label %wend2
wbody1:
  call void @fn_skipnl()
  %t8 = call i32 @fn_is_op(ptr @.str164)
  %t9 = icmp ne i32 %t8, 0
  br i1 %t9, label %then3, label %ifend5
then3:
  br label %wend2
ifend5:
  store i32 0, ptr %t10
  %t11 = call i32 @fn_is_op(ptr @.str165)
  %t12 = icmp ne i32 %t11, 0
  br i1 %t12, label %then6, label %ifend8
then6:
  %t13 = load i32, ptr @g_pi
  %t14 = add i32 %t13, 1
  store i32 %t14, ptr @g_pi
  %t15 = call ptr @fn_eat_id()
  store ptr %t15, ptr %t16
  %t17 = load ptr, ptr %t16
  %t18 = call i32 @fn_str_eq(ptr %t17, ptr @.str166)
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
  call void @fn_eat_op(ptr @.str167)
  %t25 = load ptr, ptr %t21
  %t26 = getelementptr inbounds %Cmp_Node, ptr %t25, i32 0, i32 3
  %t27 = call ptr @fn_ptype()
  store ptr %t27, ptr %t26
  %t28 = call i32 @fn_is_op(ptr @.str168)
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
  %t71 = call i32 @fn_is_op(ptr @.str169)
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
  call void @fn_eat_op(ptr @.str170)
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
  store ptr @.str171, ptr %t8
  br label %wcond0
wcond0:
  %t9 = icmp ne i32 1, 0
  br i1 %t9, label %wbody1, label %wend2
wbody1:
  call void @fn_skipnl()
  %t10 = call i32 @fn_is_op(ptr @.str172)
  %t11 = icmp ne i32 %t10, 0
  br i1 %t11, label %then3, label %ifend5
then3:
  %t12 = load i32, ptr @g_pi
  %t13 = add i32 %t12, 1
  store i32 %t13, ptr @g_pi
  %t14 = call ptr @fn_eat_id()
  store ptr %t14, ptr %t15
  %t16 = call i32 @fn_is_op(ptr @.str173)
  %t17 = icmp ne i32 %t16, 0
  br i1 %t17, label %then6, label %ifend8
then6:
  store i32 0, ptr %t18
  br label %wcond9
wcond9:
  %t19 = icmp ne i32 1, 0
  br i1 %t19, label %wbody10, label %wend11
wbody10:
  %t20 = call i32 @fn_is_op(ptr @.str174)
  %t21 = icmp ne i32 %t20, 0
  br i1 %t21, label %then12, label %ifend14
then12:
  %t22 = load i32, ptr %t18
  %t23 = add i32 %t22, 1
  store i32 %t23, ptr %t18
  br label %ifend14
ifend14:
  %t24 = call i32 @fn_is_op(ptr @.str175)
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
  %t34 = call i32 @fn_is_id(ptr @.str176)
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
  call void @fn_eat_op(ptr @.str177)
  %t0 = call ptr @fn_node(i32 7)
  store ptr %t0, ptr %t1
  br label %wcond0
wcond0:
  %t2 = call i32 @fn_is_op(ptr @.str178)
  %t3 = icmp eq i32 %t2, 0
  %t4 = zext i1 %t3 to i32
  %t5 = icmp ne i32 %t4, 0
  br i1 %t5, label %wbody1, label %wend2
wbody1:
  %t6 = call i32 @fn_is_op(ptr @.str179)
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
  call void @fn_eat_op(ptr @.str180)
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
  %t68 = call i32 @fn_is_op(ptr @.str181)
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
  call void @fn_eat_op(ptr @.str182)
  %t72 = call i32 @fn_is_id(ptr @.str183)
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
  call void @fn_eat_op(ptr @.str184)
  br label %wcond0
wcond0:
  %t2 = call i32 @fn_is_op(ptr @.str185)
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
  %t33 = call i32 @fn_is_op(ptr @.str186)
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
  call void @fn_eat_op(ptr @.str187)
  %t37 = call ptr @fn_eat_id()
  store ptr %t37, ptr %t38
  %t39 = call i32 @fn_is_id(ptr @.str188)
  %t40 = icmp eq i32 %t39, 0
  %t41 = zext i1 %t40 to i32
  %t42 = icmp ne i32 %t41, 0
  br i1 %t42, label %then8, label %ifend10
then8:
  call void @fn_perr(ptr @.str189)
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
  store ptr @.str190, ptr %t10
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
  call void @fn_eat_op(ptr @.str191)
  %t0 = call ptr @fn_node(i32 21)
  store ptr %t0, ptr %t1
  %t2 = call ptr @fn_node(i32 7)
  store ptr %t2, ptr %t3
  store ptr null, ptr %t4
  br label %wcond0
wcond0:
  %t5 = call i32 @fn_is_op(ptr @.str192)
  %t6 = icmp eq i32 %t5, 0
  %t7 = zext i1 %t6 to i32
  %t8 = icmp ne i32 %t7, 0
  br i1 %t8, label %wbody1, label %wend2
wbody1:
  call void @fn_skipnl()
  %t9 = call i32 @fn_is_op(ptr @.str193)
  %t10 = icmp ne i32 %t9, 0
  br i1 %t10, label %then3, label %ifend5
then3:
  br label %wend2
ifend5:
  %t11 = call ptr @fn_eat_id()
  store ptr %t11, ptr %t12
  call void @fn_eat_op(ptr @.str194)
  %t13 = load ptr, ptr %t12
  %t14 = call i32 @fn_str_eq(ptr %t13, ptr @.str195)
  %t15 = icmp ne i32 %t14, 0
  br i1 %t15, label %then6, label %else7
then6:
  call void @fn_eat_op(ptr @.str196)
  call void @fn_skipnl()
  br label %wcond9
wcond9:
  %t16 = call i32 @fn_is_op(ptr @.str197)
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
  %t78 = call i32 @fn_is_op(ptr @.str198)
  %t79 = icmp ne i32 %t78, 0
  br i1 %t79, label %then16, label %ifend18
then16:
  %t80 = load i32, ptr @g_pi
  %t81 = add i32 %t80, 1
  store i32 %t81, ptr @g_pi
  %t82 = call ptr @fn_expr()
  store ptr %t82, ptr %t83
  call void @fn_eat_op(ptr @.str199)
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
  %t94 = call i32 @fn_is_op(ptr @.str200)
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
  call void @fn_eat_op(ptr @.str201)
  br label %ifend8
else7:
  %t98 = load ptr, ptr %t12
  %t99 = call i32 @fn_str_eq(ptr %t98, ptr @.str202)
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
  %t133 = call i32 @fn_is_op(ptr @.str203)
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
  call void @fn_eat_op(ptr @.str204)
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
  %t40 = call i32 @fn_is_op(ptr @.str207)
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
  call void @fn_eat_op(ptr @.str208)
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
  call void @fn_eat_op(ptr @.str213)
  br label %wcond0
wcond0:
  %t7 = icmp ne i32 1, 0
  br i1 %t7, label %wbody1, label %wend2
wbody1:
  call void @fn_skipnl()
  %t8 = call i32 @fn_is_op(ptr @.str214)
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
  %t37 = call i32 @fn_is_op(ptr @.str215)
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
  call void @fn_eat_op(ptr @.str216)
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
  call void @fn_eat_op(ptr @.str217)
  br label %wcond0
wcond0:
  %t9 = call i32 @fn_is_op(ptr @.str218)
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
  call void @fn_eat_op(ptr @.str219)
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
  %t43 = call i32 @fn_is_op(ptr @.str220)
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
  call void @fn_eat_op(ptr @.str221)
  %t47 = load ptr, ptr %t5
  %t48 = getelementptr inbounds %Cmp_Node, ptr %t47, i32 0, i32 3
  store ptr @.str222, ptr %t48
  %t49 = call i32 @fn_is_op(ptr @.str223)
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
  call void @fn_eat_op(ptr @.str224)
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
  %t47 = call i32 @fn_str_eq(ptr %t46, ptr @.str225)
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
  call void @fn_eat_op(ptr @.str226)
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
  %t84 = call i32 @fn_is_op(ptr @.str227)
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
  %t89 = call i32 @fn_is_op(ptr @.str228)
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
  call void @fn_eat_op(ptr @.str229)
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
  call void @fn_eat_op(ptr @.str230)
  call void @fn_skipnl()
  %t9 = load ptr, ptr %t3
  %t10 = getelementptr inbounds %Cmp_Node, ptr %t9, i32 0, i32 4
  %t11 = call ptr @fn_parse_widget()
  store ptr %t11, ptr %t10
  call void @fn_skipnl()
  call void @fn_eat_op(ptr @.str231)
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
  %t3 = call ptr @fn_str_concat(ptr @.str232, ptr %t2)
  store ptr %t3, ptr %t4
  %t5 = load i32, ptr @g_ll_t
  %t6 = add i32 %t5, 1
  store i32 %t6, ptr @g_ll_t
  %t7 = load ptr, ptr @g_falloc
  call void @fn_buf_puts(ptr %t7, ptr @.str233)
  %t8 = load ptr, ptr @g_falloc
  %t9 = load ptr, ptr %t4
  call void @fn_buf_puts(ptr %t8, ptr %t9)
  %t10 = load ptr, ptr @g_falloc
  call void @fn_buf_puts(ptr %t10, ptr @.str234)
  %t11 = load ptr, ptr @g_falloc
  %t12 = load ptr, ptr %t0
  call void @fn_buf_puts(ptr %t11, ptr %t12)
  %t13 = load ptr, ptr @g_falloc
  call void @fn_buf_puts(ptr %t13, ptr @.str235)
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
  %t2 = call ptr @fn_str_concat(ptr @.str236, ptr %t1)
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
  %t23 = alloca i32
  %t24 = alloca i32
  store ptr %arg_t, ptr %t0
  %t3 = load ptr, ptr %t0
  %t4 = call i32 @fn_str_eq(ptr %t3, ptr @.str237)
  %t5 = icmp ne i32 %t4, 0
  %t6 = zext i1 %t5 to i32
  store i32 %t6, ptr %t2
  br i1 %t5, label %scend1, label %sc0
sc0:
  %t7 = load ptr, ptr %t0
  %t8 = call i32 @fn_str_eq(ptr %t7, ptr @.str238)
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
  %t15 = call i32 @fn_str_eq(ptr %t14, ptr @.str239)
  %t16 = icmp ne i32 %t15, 0
  %t17 = zext i1 %t16 to i32
  store i32 %t17, ptr %t1
  br label %scend3
scend3:
  %t18 = load i32, ptr %t1
  %t19 = icmp ne i32 %t18, 0
  br i1 %t19, label %then4, label %ifend6
then4:
  store ptr @.str240, ptr %retval
  br label %ret
ifend6:
  %t20 = load ptr, ptr %t0
  %t21 = call i32 @fn_str_eq(ptr %t20, ptr @.str241)
  %t22 = icmp ne i32 %t21, 0
  br i1 %t22, label %then7, label %ifend9
then7:
  store ptr @.str242, ptr %retval
  br label %ret
ifend9:
  %t25 = load ptr, ptr %t0
  %t26 = call i32 @fn_str_eq(ptr %t25, ptr @.str243)
  %t27 = icmp ne i32 %t26, 0
  %t28 = zext i1 %t27 to i32
  store i32 %t28, ptr %t24
  br i1 %t27, label %scend11, label %sc10
sc10:
  %t29 = load ptr, ptr %t0
  %t30 = call i32 @fn_str_eq(ptr %t29, ptr @.str244)
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
  %t37 = call i32 @fn_str_eq(ptr %t36, ptr @.str245)
  %t38 = icmp ne i32 %t37, 0
  %t39 = zext i1 %t38 to i32
  store i32 %t39, ptr %t23
  br label %scend13
scend13:
  %t40 = load i32, ptr %t23
  %t41 = icmp ne i32 %t40, 0
  br i1 %t41, label %then14, label %ifend16
then14:
  store ptr @.str246, ptr %retval
  br label %ret
ifend16:
  %t42 = load ptr, ptr %t0
  %t43 = call i32 @fn_str_eq(ptr %t42, ptr @.str247)
  %t44 = icmp ne i32 %t43, 0
  br i1 %t44, label %then17, label %ifend19
then17:
  store ptr @.str248, ptr %retval
  br label %ret
ifend19:
  store ptr @.str249, ptr %retval
  br label %ret
ret:
  %t45 = load ptr, ptr %retval
  ret ptr %t45
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
  %t3 = call i64 @strlen(ptr %t2)
  %t4 = trunc i64 %t3 to i32
  %t5 = call ptr @fn_str_slice(ptr %t1, i32 2, i32 %t4)
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
  %t2 = call ptr @fn_str_concat(ptr @.str250, ptr %t1)
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
  store ptr @.str251, ptr %retval
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
  %t9 = call ptr @fn_str_concat(ptr %t8, ptr @.str252)
  %t10 = load ptr, ptr %t1
  %t11 = call ptr @fn_str_concat(ptr %t9, ptr %t10)
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
  %t7 = call ptr @fn_str_concat(ptr %t6, ptr @.str253)
  %t8 = load ptr, ptr %t1
  %t9 = call ptr @fn_str_concat(ptr %t7, ptr %t8)
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
  %t10 = alloca i32
  %t15 = alloca i32
  %t26 = alloca i32
  %t27 = alloca i32
  %t28 = alloca i32
  %t29 = alloca i32
  store ptr %arg_s, ptr %t0
  %t1 = load i32, ptr @g_ll_str
  %t2 = call ptr @fn_itoa(i32 %t1)
  %t3 = call ptr @fn_str_concat(ptr @.str254, ptr %t2)
  store ptr %t3, ptr %t4
  %t5 = load i32, ptr @g_ll_str
  %t6 = add i32 %t5, 1
  store i32 %t6, ptr @g_ll_str
  %t7 = load ptr, ptr %t0
  %t8 = call i64 @strlen(ptr %t7)
  %t9 = trunc i64 %t8 to i32
  store i32 %t9, ptr %t10
  %t11 = load ptr, ptr %t4
  call void @fn_emith(ptr %t11)
  call void @fn_emith(ptr @.str255)
  %t12 = load i32, ptr %t10
  %t13 = add i32 %t12, 1
  %t14 = call ptr @fn_itoa(i32 %t13)
  call void @fn_emith(ptr %t14)
  call void @fn_emith(ptr @.str256)
  store i32 0, ptr %t15
  br label %wcond0
wcond0:
  %t16 = load i32, ptr %t15
  %t17 = load i32, ptr %t10
  %t18 = icmp slt i32 %t16, %t17
  %t19 = zext i1 %t18 to i32
  %t20 = icmp ne i32 %t19, 0
  br i1 %t20, label %wbody1, label %wend2
wbody1:
  %t21 = load ptr, ptr %t0
  %t22 = load i32, ptr %t15
  %t23 = getelementptr inbounds i8, ptr %t21, i32 %t22
  %t24 = load i8, ptr %t23
  %t25 = zext i8 %t24 to i32
  store i32 %t25, ptr %t26
  %t30 = load i32, ptr %t26
  %t31 = icmp eq i32 %t30, 34
  %t32 = zext i1 %t31 to i32
  %t33 = icmp ne i32 %t32, 0
  %t34 = zext i1 %t33 to i32
  store i32 %t34, ptr %t29
  br i1 %t33, label %scend4, label %sc3
sc3:
  %t35 = load i32, ptr %t26
  %t36 = icmp eq i32 %t35, 92
  %t37 = zext i1 %t36 to i32
  %t38 = icmp ne i32 %t37, 0
  %t39 = zext i1 %t38 to i32
  store i32 %t39, ptr %t29
  br label %scend4
scend4:
  %t40 = load i32, ptr %t29
  %t41 = icmp ne i32 %t40, 0
  %t42 = zext i1 %t41 to i32
  store i32 %t42, ptr %t28
  br i1 %t41, label %scend6, label %sc5
sc5:
  %t43 = load i32, ptr %t26
  %t44 = icmp slt i32 %t43, 32
  %t45 = zext i1 %t44 to i32
  %t46 = icmp ne i32 %t45, 0
  %t47 = zext i1 %t46 to i32
  store i32 %t47, ptr %t28
  br label %scend6
scend6:
  %t48 = load i32, ptr %t28
  %t49 = icmp ne i32 %t48, 0
  %t50 = zext i1 %t49 to i32
  store i32 %t50, ptr %t27
  br i1 %t49, label %scend8, label %sc7
sc7:
  %t51 = load i32, ptr %t26
  %t52 = icmp sgt i32 %t51, 126
  %t53 = zext i1 %t52 to i32
  %t54 = icmp ne i32 %t53, 0
  %t55 = zext i1 %t54 to i32
  store i32 %t55, ptr %t27
  br label %scend8
scend8:
  %t56 = load i32, ptr %t27
  %t57 = icmp ne i32 %t56, 0
  br i1 %t57, label %then9, label %else10
then9:
  %t58 = load ptr, ptr @g_head
  call void @fn_buf_putc(ptr %t58, i32 92)
  %t59 = load ptr, ptr @g_head
  %t60 = load i32, ptr %t26
  %t61 = sdiv i32 %t60, 16
  %t62 = call i32 @fn_hexdig(i32 %t61)
  call void @fn_buf_putc(ptr %t59, i32 %t62)
  %t63 = load ptr, ptr @g_head
  %t64 = load i32, ptr %t26
  %t65 = srem i32 %t64, 16
  %t66 = call i32 @fn_hexdig(i32 %t65)
  call void @fn_buf_putc(ptr %t63, i32 %t66)
  br label %ifend11
else10:
  %t67 = load ptr, ptr @g_head
  %t68 = load i32, ptr %t26
  call void @fn_buf_putc(ptr %t67, i32 %t68)
  br label %ifend11
ifend11:
  %t69 = load i32, ptr %t15
  %t70 = add i32 %t69, 1
  store i32 %t70, ptr %t15
  br label %wcond0
wend2:
  call void @fn_emith(ptr @.str257)
  %t71 = load ptr, ptr %t4
  store ptr %t71, ptr %retval
  br label %ret
ret:
  %t72 = load ptr, ptr %retval
  ret ptr %t72
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
  %t11 = call i32 @fn_str_eq(ptr %t10, ptr @.str258)
  %t12 = icmp ne i32 %t11, 0
  br i1 %t12, label %then3, label %ifend5
then3:
  store ptr @.str259, ptr %retval
  br label %ret
ifend5:
  store ptr @.str260, ptr %retval
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
  %t61 = call i32 @fn_str_eq(ptr %t60, ptr @.str261)
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
  %t84 = call ptr @fn_str_concat(ptr @.str262, ptr %t83)
  store ptr %t84, ptr %retval
  br label %ret
ifend19:
  %t85 = load ptr, ptr %t0
  %t86 = getelementptr inbounds %Cmp_Node, ptr %t85, i32 0, i32 3
  %t87 = load ptr, ptr %t86
  %t88 = call ptr @fn_llty(ptr %t87)
  %t89 = call i32 @fn_str_eq(ptr %t88, ptr @.str263)
  %t90 = icmp ne i32 %t89, 0
  br i1 %t90, label %then20, label %ifend22
then20:
  store ptr @.str264, ptr %retval
  br label %ret
ifend22:
  store ptr @.str265, ptr %retval
  br label %ret
ret:
  %t91 = load ptr, ptr %retval
  ret ptr %t91
}

define void @fn_emit_header() {
entry:
  %t6 = alloca i32
  %t20 = alloca ptr
  %t39 = alloca i32
  %t81 = alloca ptr
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
  call void @fn_emith(ptr @.str291)
  call void @fn_emith(ptr @.str292)
  call void @fn_emith(ptr @.str293)
  call void @fn_emith(ptr @.str294)
  call void @fn_emith(ptr @.str295)
  call void @fn_emith(ptr @.str296)
  call void @fn_emith(ptr @.str297)
  %t0 = load ptr, ptr @g_g_game_name
  %t1 = call i64 @strlen(ptr %t0)
  %t2 = trunc i64 %t1 to i32
  %t3 = add i32 %t2, 1
  %t4 = call ptr @fn_itoa(i32 %t3)
  call void @fn_emith(ptr %t4)
  call void @fn_emith(ptr @.str298)
  %t5 = load ptr, ptr @g_g_game_name
  call void @fn_emith(ptr %t5)
  call void @fn_emith(ptr @.str299)
  call void @fn_emith(ptr @.str300)
  store i32 0, ptr %t6
  br label %wcond0
wcond0:
  %t7 = load i32, ptr %t6
  %t8 = load ptr, ptr @g_prog
  %t9 = getelementptr inbounds %LSlice, ptr %t8, i32 0, i32 1
  %t10 = load i32, ptr %t9
  %t11 = icmp slt i32 %t7, %t10
  %t12 = zext i1 %t11 to i32
  %t13 = icmp ne i32 %t12, 0
  br i1 %t13, label %wbody1, label %wend2
wbody1:
  %t14 = load ptr, ptr @g_prog
  %t15 = getelementptr inbounds %LSlice, ptr %t14, i32 0, i32 0
  %t16 = load ptr, ptr %t15
  %t17 = load i32, ptr %t6
  %t18 = getelementptr inbounds ptr, ptr %t16, i32 %t17
  %t19 = load ptr, ptr %t18
  store ptr %t19, ptr %t20
  %t21 = load ptr, ptr %t20
  %t22 = getelementptr inbounds %Cmp_Node, ptr %t21, i32 0, i32 0
  %t23 = load i32, ptr %t22
  %t24 = icmp eq i32 %t23, 8
  %t25 = zext i1 %t24 to i32
  %t26 = icmp ne i32 %t25, 0
  br i1 %t26, label %then3, label %ifend5
then3:
  %t27 = load ptr, ptr %t20
  %t28 = getelementptr inbounds %Cmp_Node, ptr %t27, i32 0, i32 1
  %t29 = load ptr, ptr %t28
  %t30 = call ptr @fn_layout_ty(ptr %t29)
  call void @fn_emith(ptr %t30)
  call void @fn_emith(ptr @.str301)
  %t31 = load ptr, ptr %t20
  %t32 = getelementptr inbounds %Cmp_Node, ptr %t31, i32 0, i32 7
  %t33 = load ptr, ptr %t32
  %t34 = getelementptr inbounds %LSlice, ptr %t33, i32 0, i32 1
  %t35 = load i32, ptr %t34
  %t36 = icmp eq i32 %t35, 0
  %t37 = zext i1 %t36 to i32
  %t38 = icmp ne i32 %t37, 0
  br i1 %t38, label %then6, label %ifend8
then6:
  call void @fn_emith(ptr @.str302)
  br label %ifend8
ifend8:
  store i32 0, ptr %t39
  br label %wcond9
wcond9:
  %t40 = load i32, ptr %t39
  %t41 = load ptr, ptr %t20
  %t42 = getelementptr inbounds %Cmp_Node, ptr %t41, i32 0, i32 7
  %t43 = load ptr, ptr %t42
  %t44 = getelementptr inbounds %LSlice, ptr %t43, i32 0, i32 1
  %t45 = load i32, ptr %t44
  %t46 = icmp slt i32 %t40, %t45
  %t47 = zext i1 %t46 to i32
  %t48 = icmp ne i32 %t47, 0
  br i1 %t48, label %wbody10, label %wend11
wbody10:
  %t49 = load i32, ptr %t39
  %t50 = icmp sgt i32 %t49, 0
  %t51 = zext i1 %t50 to i32
  %t52 = icmp ne i32 %t51, 0
  br i1 %t52, label %then12, label %ifend14
then12:
  call void @fn_emith(ptr @.str303)
  br label %ifend14
ifend14:
  %t53 = load ptr, ptr %t20
  %t54 = getelementptr inbounds %Cmp_Node, ptr %t53, i32 0, i32 7
  %t55 = load ptr, ptr %t54
  %t56 = getelementptr inbounds %LSlice, ptr %t55, i32 0, i32 0
  %t57 = load ptr, ptr %t56
  %t58 = load i32, ptr %t39
  %t59 = getelementptr inbounds ptr, ptr %t57, i32 %t58
  %t60 = load ptr, ptr %t59
  %t61 = getelementptr inbounds %Cmp_Node, ptr %t60, i32 0, i32 3
  %t62 = load ptr, ptr %t61
  %t63 = call ptr @fn_llty(ptr %t62)
  call void @fn_emith(ptr %t63)
  %t64 = load i32, ptr %t39
  %t65 = add i32 %t64, 1
  store i32 %t65, ptr %t39
  br label %wcond9
wend11:
  call void @fn_emith(ptr @.str304)
  br label %ifend5
ifend5:
  %t66 = load i32, ptr %t6
  %t67 = add i32 %t66, 1
  store i32 %t67, ptr %t6
  br label %wcond0
wend2:
  store i32 0, ptr %t6
  br label %wcond15
wcond15:
  %t68 = load i32, ptr %t6
  %t69 = load ptr, ptr @g_prog
  %t70 = getelementptr inbounds %LSlice, ptr %t69, i32 0, i32 1
  %t71 = load i32, ptr %t70
  %t72 = icmp slt i32 %t68, %t71
  %t73 = zext i1 %t72 to i32
  %t74 = icmp ne i32 %t73, 0
  br i1 %t74, label %wbody16, label %wend17
wbody16:
  %t75 = load ptr, ptr @g_prog
  %t76 = getelementptr inbounds %LSlice, ptr %t75, i32 0, i32 0
  %t77 = load ptr, ptr %t76
  %t78 = load i32, ptr %t6
  %t79 = getelementptr inbounds ptr, ptr %t77, i32 %t78
  %t80 = load ptr, ptr %t79
  store ptr %t80, ptr %t81
  %t82 = load ptr, ptr %t81
  %t83 = getelementptr inbounds %Cmp_Node, ptr %t82, i32 0, i32 0
  %t84 = load i32, ptr %t83
  %t85 = icmp eq i32 %t84, 2
  %t86 = zext i1 %t85 to i32
  %t87 = icmp ne i32 %t86, 0
  br i1 %t87, label %then18, label %ifend20
then18:
  call void @fn_emith(ptr @.str305)
  %t88 = load ptr, ptr %t81
  %t89 = getelementptr inbounds %Cmp_Node, ptr %t88, i32 0, i32 1
  %t90 = load ptr, ptr %t89
  call void @fn_emith(ptr %t90)
  call void @fn_emith(ptr @.str306)
  %t91 = load ptr, ptr %t81
  %t92 = getelementptr inbounds %Cmp_Node, ptr %t91, i32 0, i32 3
  %t93 = load ptr, ptr %t92
  %t94 = call ptr @fn_llty(ptr %t93)
  call void @fn_emith(ptr %t94)
  call void @fn_emith(ptr @.str307)
  %t95 = load ptr, ptr %t81
  %t96 = call ptr @fn_global_init(ptr %t95)
  call void @fn_emith(ptr %t96)
  call void @fn_emith(ptr @.str308)
  br label %ifend20
ifend20:
  %t97 = load i32, ptr %t6
  %t98 = add i32 %t97, 1
  store i32 %t98, ptr %t6
  br label %wcond15
wend17:
  br label %ret
ret:
  ret void
}

define void @fn_emit_str_prelude() {
entry:
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
  call void @fn_emith(ptr @.str337)
  call void @fn_emith(ptr @.str338)
  call void @fn_emith(ptr @.str339)
  call void @fn_emith(ptr @.str340)
  call void @fn_emith(ptr @.str341)
  call void @fn_emith(ptr @.str342)
  call void @fn_emith(ptr @.str343)
  br label %ret
ret:
  ret void
}

define void @fn_emit_int_str() {
entry:
  call void @fn_emith(ptr @.str344)
  call void @fn_emith(ptr @.str345)
  call void @fn_emith(ptr @.str346)
  call void @fn_emith(ptr @.str347)
  call void @fn_emith(ptr @.str348)
  call void @fn_emith(ptr @.str349)
  call void @fn_emith(ptr @.str350)
  call void @fn_emith(ptr @.str351)
  call void @fn_emith(ptr @.str352)
  call void @fn_emith(ptr @.str353)
  call void @fn_emith(ptr @.str354)
  call void @fn_emith(ptr @.str355)
  call void @fn_emith(ptr @.str356)
  call void @fn_emith(ptr @.str357)
  call void @fn_emith(ptr @.str358)
  call void @fn_emith(ptr @.str359)
  call void @fn_emith(ptr @.str360)
  br label %ret
ret:
  ret void
}

define void @fn_emit_str_slice() {
entry:
  call void @fn_emith(ptr @.str361)
  call void @fn_emith(ptr @.str362)
  call void @fn_emith(ptr @.str363)
  call void @fn_emith(ptr @.str364)
  call void @fn_emith(ptr @.str365)
  call void @fn_emith(ptr @.str366)
  call void @fn_emith(ptr @.str367)
  call void @fn_emith(ptr @.str368)
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
  %t18 = call ptr @fn_str_concat(ptr @.str369, ptr %t17)
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
  %t32 = call ptr @fn_str_concat(ptr @.str370, ptr %t31)
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
  call void @fn_emit(ptr @.str371)
  %t40 = load ptr, ptr %t39
  call void @fn_emit(ptr %t40)
  call void @fn_emit(ptr @.str372)
  %t41 = load ptr, ptr %t5
  %t42 = getelementptr inbounds %Cmp_Val, ptr %t41, i32 0, i32 1
  %t43 = load ptr, ptr %t42
  %t44 = call ptr @fn_layout_ty(ptr %t43)
  call void @fn_emit(ptr %t44)
  call void @fn_emit(ptr @.str373)
  %t45 = load ptr, ptr %t5
  %t46 = getelementptr inbounds %Cmp_Val, ptr %t45, i32 0, i32 0
  %t47 = load ptr, ptr %t46
  call void @fn_emit(ptr %t47)
  call void @fn_emit(ptr @.str374)
  %t48 = load i32, ptr %t24
  %t49 = call ptr @fn_itoa(i32 %t48)
  call void @fn_emit(ptr %t49)
  call void @fn_emit(ptr @.str375)
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
  %t33 = alloca ptr
  %t50 = alloca ptr
  %t67 = alloca ptr
  %t79 = alloca ptr
  %t85 = alloca ptr
  %t88 = alloca ptr
  %t94 = alloca ptr
  %t101 = alloca ptr
  %t103 = alloca ptr
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
  %t13 = load ptr, ptr %t0
  %t14 = getelementptr inbounds %Cmp_Node, ptr %t13, i32 0, i32 5
  %t15 = load ptr, ptr %t14
  %t16 = call ptr @fn_emit_expr(ptr %t15)
  store ptr %t16, ptr %t17
  %t18 = load ptr, ptr %t5
  %t19 = getelementptr inbounds %Cmp_Val, ptr %t18, i32 0, i32 1
  %t20 = load ptr, ptr %t19
  %t21 = call i32 @fn_str_eq(ptr %t20, ptr @.str376)
  %t22 = icmp ne i32 %t21, 0
  br i1 %t22, label %then3, label %ifend5
then3:
  %t23 = load ptr, ptr %t5
  %t24 = getelementptr inbounds %Cmp_Val, ptr %t23, i32 0, i32 0
  %t25 = load ptr, ptr %t24
  %t26 = call ptr @fn_str_concat(ptr @.str377, ptr %t25)
  %t27 = call ptr @fn_str_concat(ptr %t26, ptr @.str378)
  %t28 = load ptr, ptr %t17
  %t29 = getelementptr inbounds %Cmp_Val, ptr %t28, i32 0, i32 0
  %t30 = load ptr, ptr %t29
  %t31 = call ptr @fn_str_concat(ptr %t27, ptr %t30)
  %t32 = call ptr @fn_emit_bind(ptr %t31)
  store ptr %t32, ptr %t33
  store ptr @.str379, ptr @g_g_addr_ty
  %t34 = load ptr, ptr %t33
  store ptr %t34, ptr %retval
  br label %ret
ifend5:
  %t35 = load ptr, ptr %t5
  %t36 = getelementptr inbounds %Cmp_Val, ptr %t35, i32 0, i32 1
  %t37 = load ptr, ptr %t36
  %t38 = call i32 @fn_str_eq(ptr %t37, ptr @.str380)
  %t39 = icmp ne i32 %t38, 0
  br i1 %t39, label %then6, label %ifend8
then6:
  %t40 = load ptr, ptr %t5
  %t41 = getelementptr inbounds %Cmp_Val, ptr %t40, i32 0, i32 0
  %t42 = load ptr, ptr %t41
  %t43 = call ptr @fn_str_concat(ptr @.str381, ptr %t42)
  %t44 = call ptr @fn_str_concat(ptr %t43, ptr @.str382)
  %t45 = load ptr, ptr %t17
  %t46 = getelementptr inbounds %Cmp_Val, ptr %t45, i32 0, i32 0
  %t47 = load ptr, ptr %t46
  %t48 = call ptr @fn_str_concat(ptr %t44, ptr %t47)
  %t49 = call ptr @fn_emit_bind(ptr %t48)
  store ptr %t49, ptr %t50
  store ptr @.str383, ptr @g_g_addr_ty
  %t51 = load ptr, ptr %t50
  store ptr %t51, ptr %retval
  br label %ret
ifend8:
  %t52 = load ptr, ptr %t5
  %t53 = getelementptr inbounds %Cmp_Val, ptr %t52, i32 0, i32 1
  %t54 = load ptr, ptr %t53
  %t55 = call i32 @fn_str_eq(ptr %t54, ptr @.str384)
  %t56 = icmp ne i32 %t55, 0
  br i1 %t56, label %then9, label %ifend11
then9:
  %t57 = load ptr, ptr %t5
  %t58 = getelementptr inbounds %Cmp_Val, ptr %t57, i32 0, i32 0
  %t59 = load ptr, ptr %t58
  %t60 = call ptr @fn_str_concat(ptr @.str385, ptr %t59)
  %t61 = call ptr @fn_str_concat(ptr %t60, ptr @.str386)
  %t62 = load ptr, ptr %t17
  %t63 = getelementptr inbounds %Cmp_Val, ptr %t62, i32 0, i32 0
  %t64 = load ptr, ptr %t63
  %t65 = call ptr @fn_str_concat(ptr %t61, ptr %t64)
  %t66 = call ptr @fn_emit_bind(ptr %t65)
  store ptr %t66, ptr %t67
  store ptr @.str387, ptr @g_g_addr_ty
  %t68 = load ptr, ptr %t67
  store ptr %t68, ptr %retval
  br label %ret
ifend11:
  %t69 = load ptr, ptr %t5
  %t70 = getelementptr inbounds %Cmp_Val, ptr %t69, i32 0, i32 0
  %t71 = load ptr, ptr %t70
  %t72 = call ptr @fn_str_concat(ptr @.str388, ptr %t71)
  %t73 = call ptr @fn_str_concat(ptr %t72, ptr @.str389)
  %t74 = load ptr, ptr %t17
  %t75 = getelementptr inbounds %Cmp_Val, ptr %t74, i32 0, i32 0
  %t76 = load ptr, ptr %t75
  %t77 = call ptr @fn_str_concat(ptr %t73, ptr %t76)
  %t78 = call ptr @fn_emit_bind(ptr %t77)
  store ptr %t78, ptr %t79
  store ptr @.str390, ptr @g_g_addr_ty
  %t80 = load ptr, ptr %t79
  store ptr %t80, ptr %retval
  br label %ret
ifend2:
  %t81 = load ptr, ptr %t5
  %t82 = getelementptr inbounds %Cmp_Val, ptr %t81, i32 0, i32 1
  %t83 = load ptr, ptr %t82
  %t84 = call ptr @fn_slice_elem(ptr %t83)
  store ptr %t84, ptr %t85
  %t86 = load ptr, ptr %t85
  store ptr %t86, ptr @g_g_addr_ty
  %t87 = call ptr @fn_nreg()
  store ptr %t87, ptr %t88
  call void @fn_emit(ptr @.str391)
  %t89 = load ptr, ptr %t88
  call void @fn_emit(ptr %t89)
  call void @fn_emit(ptr @.str392)
  %t90 = load ptr, ptr %t5
  %t91 = getelementptr inbounds %Cmp_Val, ptr %t90, i32 0, i32 0
  %t92 = load ptr, ptr %t91
  call void @fn_emit(ptr %t92)
  call void @fn_emit(ptr @.str393)
  %t93 = call ptr @fn_nreg()
  store ptr %t93, ptr %t94
  call void @fn_emit(ptr @.str394)
  %t95 = load ptr, ptr %t94
  call void @fn_emit(ptr %t95)
  call void @fn_emit(ptr @.str395)
  %t96 = load ptr, ptr %t88
  call void @fn_emit(ptr %t96)
  call void @fn_emit(ptr @.str396)
  %t97 = load ptr, ptr %t0
  %t98 = getelementptr inbounds %Cmp_Node, ptr %t97, i32 0, i32 5
  %t99 = load ptr, ptr %t98
  %t100 = call ptr @fn_emit_expr(ptr %t99)
  store ptr %t100, ptr %t101
  %t102 = call ptr @fn_nreg()
  store ptr %t102, ptr %t103
  call void @fn_emit(ptr @.str397)
  %t104 = load ptr, ptr %t103
  call void @fn_emit(ptr %t104)
  call void @fn_emit(ptr @.str398)
  %t105 = load ptr, ptr %t85
  %t106 = call ptr @fn_llty(ptr %t105)
  call void @fn_emit(ptr %t106)
  call void @fn_emit(ptr @.str399)
  %t107 = load ptr, ptr %t94
  call void @fn_emit(ptr %t107)
  call void @fn_emit(ptr @.str400)
  %t108 = load ptr, ptr %t101
  %t109 = getelementptr inbounds %Cmp_Val, ptr %t108, i32 0, i32 0
  %t110 = load ptr, ptr %t109
  call void @fn_emit(ptr %t110)
  call void @fn_emit(ptr @.str401)
  %t111 = load ptr, ptr %t103
  store ptr %t111, ptr %retval
  br label %ret
ret:
  %t112 = load ptr, ptr %retval
  ret ptr %t112
}

define i32 @fn_is_intrinsic(ptr %arg_name) {
entry:
  %retval = alloca i32
  %t0 = alloca ptr
  %t4 = alloca i32
  %t5 = alloca i32
  %t23 = alloca i32
  %t24 = alloca i32
  %t42 = alloca i32
  %t43 = alloca i32
  %t61 = alloca i32
  %t72 = alloca i32
  store ptr %arg_name, ptr %t0
  %t1 = load ptr, ptr %t0
  %t2 = call i32 @fn_str_eq(ptr %t1, ptr @.str402)
  %t3 = icmp ne i32 %t2, 0
  br i1 %t3, label %then0, label %ifend2
then0:
  store i32 1, ptr %retval
  br label %ret
ifend2:
  %t6 = load ptr, ptr %t0
  %t7 = call i32 @fn_str_eq(ptr %t6, ptr @.str403)
  %t8 = icmp ne i32 %t7, 0
  %t9 = zext i1 %t8 to i32
  store i32 %t9, ptr %t5
  br i1 %t8, label %scend4, label %sc3
sc3:
  %t10 = load ptr, ptr %t0
  %t11 = call i32 @fn_str_eq(ptr %t10, ptr @.str404)
  %t12 = icmp ne i32 %t11, 0
  %t13 = zext i1 %t12 to i32
  store i32 %t13, ptr %t5
  br label %scend4
scend4:
  %t14 = load i32, ptr %t5
  %t15 = icmp ne i32 %t14, 0
  %t16 = zext i1 %t15 to i32
  store i32 %t16, ptr %t4
  br i1 %t15, label %scend6, label %sc5
sc5:
  %t17 = load ptr, ptr %t0
  %t18 = call i32 @fn_str_eq(ptr %t17, ptr @.str405)
  %t19 = icmp ne i32 %t18, 0
  %t20 = zext i1 %t19 to i32
  store i32 %t20, ptr %t4
  br label %scend6
scend6:
  %t21 = load i32, ptr %t4
  %t22 = icmp ne i32 %t21, 0
  br i1 %t22, label %then7, label %ifend9
then7:
  store i32 1, ptr %retval
  br label %ret
ifend9:
  %t25 = load ptr, ptr %t0
  %t26 = call i32 @fn_str_eq(ptr %t25, ptr @.str406)
  %t27 = icmp ne i32 %t26, 0
  %t28 = zext i1 %t27 to i32
  store i32 %t28, ptr %t24
  br i1 %t27, label %scend11, label %sc10
sc10:
  %t29 = load ptr, ptr %t0
  %t30 = call i32 @fn_str_eq(ptr %t29, ptr @.str407)
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
  %t37 = call i32 @fn_str_eq(ptr %t36, ptr @.str408)
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
  %t45 = call i32 @fn_str_eq(ptr %t44, ptr @.str409)
  %t46 = icmp ne i32 %t45, 0
  %t47 = zext i1 %t46 to i32
  store i32 %t47, ptr %t43
  br i1 %t46, label %scend18, label %sc17
sc17:
  %t48 = load ptr, ptr %t0
  %t49 = call i32 @fn_str_eq(ptr %t48, ptr @.str410)
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
  %t56 = call i32 @fn_str_eq(ptr %t55, ptr @.str411)
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
  %t63 = call i32 @fn_str_eq(ptr %t62, ptr @.str412)
  %t64 = icmp ne i32 %t63, 0
  %t65 = zext i1 %t64 to i32
  store i32 %t65, ptr %t61
  br i1 %t64, label %scend25, label %sc24
sc24:
  %t66 = load ptr, ptr %t0
  %t67 = call i32 @fn_str_eq(ptr %t66, ptr @.str413)
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
  %t73 = load ptr, ptr %t0
  %t74 = call i32 @fn_str_eq(ptr %t73, ptr @.str414)
  %t75 = icmp ne i32 %t74, 0
  %t76 = zext i1 %t75 to i32
  store i32 %t76, ptr %t72
  br i1 %t75, label %scend30, label %sc29
sc29:
  %t77 = load ptr, ptr %t0
  %t78 = call i32 @fn_str_eq(ptr %t77, ptr @.str415)
  %t79 = icmp ne i32 %t78, 0
  %t80 = zext i1 %t79 to i32
  store i32 %t80, ptr %t72
  br label %scend30
scend30:
  %t81 = load i32, ptr %t72
  %t82 = icmp ne i32 %t81, 0
  br i1 %t82, label %then31, label %ifend33
then31:
  store i32 1, ptr %retval
  br label %ret
ifend33:
  store i32 0, ptr %retval
  br label %ret
ret:
  %t83 = load i32, ptr %retval
  ret i32 %t83
}

define ptr @fn_emit_bind(ptr %arg_rest) {
entry:
  %retval = alloca ptr
  %t0 = alloca ptr
  %t2 = alloca ptr
  store ptr %arg_rest, ptr %t0
  %t1 = call ptr @fn_nreg()
  store ptr %t1, ptr %t2
  call void @fn_emit(ptr @.str416)
  %t3 = load ptr, ptr %t2
  call void @fn_emit(ptr %t3)
  call void @fn_emit(ptr @.str417)
  %t4 = load ptr, ptr %t0
  call void @fn_emit(ptr %t4)
  call void @fn_emit(ptr @.str418)
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
  %t10 = alloca ptr
  %t15 = alloca ptr
  %t29 = alloca ptr
  %t32 = alloca ptr
  %t41 = alloca i32
  %t54 = alloca ptr
  %t57 = alloca ptr
  %t60 = alloca ptr
  %t65 = alloca ptr
  %t66 = alloca ptr
  %t83 = alloca ptr
  %t94 = alloca ptr
  %t97 = alloca ptr
  %t100 = alloca ptr
  %t105 = alloca ptr
  %t122 = alloca ptr
  %t127 = alloca ptr
  %t138 = alloca ptr
  %t151 = alloca ptr
  %t153 = alloca ptr
  %t160 = alloca ptr
  %t170 = alloca ptr
  %t188 = alloca ptr
  %t199 = alloca ptr
  store ptr %arg_name, ptr %t0
  store ptr %arg_e, ptr %t1
  store i32 1, ptr @g_g_intrin_ok
  %t2 = load ptr, ptr %t0
  %t3 = call i32 @fn_str_eq(ptr %t2, ptr @.str419)
  %t4 = icmp ne i32 %t3, 0
  br i1 %t4, label %then0, label %ifend2
then0:
  %t5 = load ptr, ptr %t1
  %t6 = call ptr @fn_arg_code(ptr %t5, i32 0)
  store ptr %t6, ptr %t7
  %t8 = load ptr, ptr %t1
  %t9 = call ptr @fn_arg_code(ptr %t8, i32 1)
  store ptr %t9, ptr %t10
  %t11 = load ptr, ptr %t10
  %t12 = call ptr @fn_str_concat(ptr @.str420, ptr %t11)
  %t13 = call ptr @fn_str_concat(ptr %t12, ptr @.str421)
  %t14 = call ptr @fn_emit_bind(ptr %t13)
  store ptr %t14, ptr %t15
  %t16 = load ptr, ptr %t7
  %t17 = call ptr @fn_str_concat(ptr @.str422, ptr %t16)
  %t18 = call ptr @fn_str_concat(ptr %t17, ptr @.str423)
  %t19 = load ptr, ptr %t15
  %t20 = call ptr @fn_str_concat(ptr %t18, ptr %t19)
  %t21 = call ptr @fn_str_concat(ptr %t20, ptr @.str424)
  %t22 = call ptr @fn_emit_bind(ptr %t21)
  %t23 = call ptr @fn_val(ptr %t22, ptr @.str425)
  store ptr %t23, ptr %retval
  br label %ret
ifend2:
  %t24 = load ptr, ptr %t0
  %t25 = call i32 @fn_str_eq(ptr %t24, ptr @.str426)
  %t26 = icmp ne i32 %t25, 0
  br i1 %t26, label %then3, label %ifend5
then3:
  %t27 = load ptr, ptr %t1
  %t28 = call ptr @fn_arg_code(ptr %t27, i32 0)
  store ptr %t28, ptr %t29
  %t30 = load ptr, ptr %t1
  %t31 = call ptr @fn_arg_code(ptr %t30, i32 1)
  store ptr %t31, ptr %t32
  %t33 = load ptr, ptr %t29
  %t34 = call ptr @fn_str_concat(ptr @.str427, ptr %t33)
  %t35 = call ptr @fn_str_concat(ptr %t34, ptr @.str428)
  %t36 = load ptr, ptr %t32
  %t37 = call ptr @fn_str_concat(ptr %t35, ptr %t36)
  %t38 = call ptr @fn_str_concat(ptr %t37, ptr @.str429)
  %t39 = call ptr @fn_emit_bind(ptr %t38)
  %t40 = call ptr @fn_val(ptr %t39, ptr @.str430)
  store ptr %t40, ptr %retval
  br label %ret
ifend5:
  %t42 = load ptr, ptr %t0
  %t43 = call i32 @fn_str_eq(ptr %t42, ptr @.str431)
  %t44 = icmp ne i32 %t43, 0
  %t45 = zext i1 %t44 to i32
  store i32 %t45, ptr %t41
  br i1 %t44, label %scend7, label %sc6
sc6:
  %t46 = load ptr, ptr %t0
  %t47 = call i32 @fn_str_eq(ptr %t46, ptr @.str432)
  %t48 = icmp ne i32 %t47, 0
  %t49 = zext i1 %t48 to i32
  store i32 %t49, ptr %t41
  br label %scend7
scend7:
  %t50 = load i32, ptr %t41
  %t51 = icmp ne i32 %t50, 0
  br i1 %t51, label %then8, label %ifend10
then8:
  %t52 = load ptr, ptr %t1
  %t53 = call ptr @fn_arg_code(ptr %t52, i32 0)
  store ptr %t53, ptr %t54
  %t55 = load ptr, ptr %t1
  %t56 = call ptr @fn_arg_code(ptr %t55, i32 1)
  store ptr %t56, ptr %t57
  %t58 = load ptr, ptr %t1
  %t59 = call ptr @fn_arg_code(ptr %t58, i32 2)
  store ptr %t59, ptr %t60
  %t61 = load ptr, ptr %t60
  %t62 = call ptr @fn_str_concat(ptr @.str433, ptr %t61)
  %t63 = call ptr @fn_str_concat(ptr %t62, ptr @.str434)
  %t64 = call ptr @fn_emit_bind(ptr %t63)
  store ptr %t64, ptr %t65
  store ptr @.str435, ptr %t66
  %t67 = load ptr, ptr %t0
  %t68 = call i32 @fn_str_eq(ptr %t67, ptr @.str436)
  %t69 = icmp ne i32 %t68, 0
  br i1 %t69, label %then11, label %ifend13
then11:
  store ptr @.str437, ptr %t66
  br label %ifend13
ifend13:
  %t70 = load ptr, ptr %t66
  %t71 = call ptr @fn_str_concat(ptr @.str438, ptr %t70)
  %t72 = call ptr @fn_str_concat(ptr %t71, ptr @.str439)
  %t73 = load ptr, ptr %t57
  %t74 = call ptr @fn_str_concat(ptr %t72, ptr %t73)
  %t75 = call ptr @fn_str_concat(ptr %t74, ptr @.str440)
  %t76 = load ptr, ptr %t65
  %t77 = call ptr @fn_str_concat(ptr %t75, ptr %t76)
  %t78 = call ptr @fn_str_concat(ptr %t77, ptr @.str441)
  %t79 = load ptr, ptr %t54
  %t80 = call ptr @fn_str_concat(ptr %t78, ptr %t79)
  %t81 = call ptr @fn_str_concat(ptr %t80, ptr @.str442)
  %t82 = call ptr @fn_emit_bind(ptr %t81)
  store ptr %t82, ptr %t83
  %t84 = load ptr, ptr %t83
  %t85 = call ptr @fn_str_concat(ptr @.str443, ptr %t84)
  %t86 = call ptr @fn_str_concat(ptr %t85, ptr @.str444)
  %t87 = call ptr @fn_emit_bind(ptr %t86)
  %t88 = call ptr @fn_val(ptr %t87, ptr @.str445)
  store ptr %t88, ptr %retval
  br label %ret
ifend10:
  %t89 = load ptr, ptr %t0
  %t90 = call i32 @fn_str_eq(ptr %t89, ptr @.str446)
  %t91 = icmp ne i32 %t90, 0
  br i1 %t91, label %then14, label %ifend16
then14:
  %t92 = load ptr, ptr %t1
  %t93 = call ptr @fn_arg_code(ptr %t92, i32 0)
  store ptr %t93, ptr %t94
  %t95 = load ptr, ptr %t1
  %t96 = call ptr @fn_arg_code(ptr %t95, i32 1)
  store ptr %t96, ptr %t97
  %t98 = load ptr, ptr %t1
  %t99 = call ptr @fn_arg_code(ptr %t98, i32 2)
  store ptr %t99, ptr %t100
  %t101 = load ptr, ptr %t97
  %t102 = call ptr @fn_str_concat(ptr @.str447, ptr %t101)
  %t103 = call ptr @fn_str_concat(ptr %t102, ptr @.str448)
  %t104 = call ptr @fn_emit_bind(ptr %t103)
  store ptr %t104, ptr %t105
  %t106 = load ptr, ptr %t94
  %t107 = call ptr @fn_str_concat(ptr @.str449, ptr %t106)
  %t108 = call ptr @fn_str_concat(ptr %t107, ptr @.str450)
  %t109 = load ptr, ptr %t105
  %t110 = call ptr @fn_str_concat(ptr %t108, ptr %t109)
  %t111 = call ptr @fn_str_concat(ptr %t110, ptr @.str451)
  %t112 = load ptr, ptr %t100
  %t113 = call ptr @fn_str_concat(ptr %t111, ptr %t112)
  %t114 = call ptr @fn_str_concat(ptr %t113, ptr @.str452)
  %t115 = call ptr @fn_emit_bind(ptr %t114)
  %t116 = call ptr @fn_val(ptr %t115, ptr @.str453)
  store ptr %t116, ptr %retval
  br label %ret
ifend16:
  %t117 = load ptr, ptr %t0
  %t118 = call i32 @fn_str_eq(ptr %t117, ptr @.str454)
  %t119 = icmp ne i32 %t118, 0
  br i1 %t119, label %then17, label %ifend19
then17:
  %t120 = load ptr, ptr %t1
  %t121 = call ptr @fn_arg_code(ptr %t120, i32 0)
  store ptr %t121, ptr %t122
  %t123 = load ptr, ptr %t122
  %t124 = call ptr @fn_str_concat(ptr @.str455, ptr %t123)
  %t125 = call ptr @fn_str_concat(ptr %t124, ptr @.str456)
  %t126 = call ptr @fn_emit_bind(ptr %t125)
  store ptr %t126, ptr %t127
  %t128 = load ptr, ptr %t127
  %t129 = call ptr @fn_str_concat(ptr @.str457, ptr %t128)
  %t130 = call ptr @fn_str_concat(ptr %t129, ptr @.str458)
  %t131 = call ptr @fn_emit_bind(ptr %t130)
  %t132 = call ptr @fn_val(ptr %t131, ptr @.str459)
  store ptr %t132, ptr %retval
  br label %ret
ifend19:
  %t133 = load ptr, ptr %t0
  %t134 = call i32 @fn_str_eq(ptr %t133, ptr @.str460)
  %t135 = icmp ne i32 %t134, 0
  br i1 %t135, label %then20, label %ifend22
then20:
  %t136 = load ptr, ptr %t1
  %t137 = call ptr @fn_arg_code(ptr %t136, i32 0)
  store ptr %t137, ptr %t138
  call void @fn_emit(ptr @.str461)
  %t139 = load ptr, ptr %t138
  call void @fn_emit(ptr %t139)
  call void @fn_emit(ptr @.str462)
  %t140 = call ptr @fn_val(ptr @.str463, ptr @.str464)
  store ptr %t140, ptr %retval
  br label %ret
ifend22:
  %t141 = load ptr, ptr %t0
  %t142 = call i32 @fn_str_eq(ptr %t141, ptr @.str465)
  %t143 = icmp ne i32 %t142, 0
  br i1 %t143, label %then23, label %ifend25
then23:
  %t144 = call ptr @fn_emit_bind(ptr @.str466)
  %t145 = call ptr @fn_val(ptr %t144, ptr @.str467)
  store ptr %t145, ptr %retval
  br label %ret
ifend25:
  %t146 = load ptr, ptr %t0
  %t147 = call i32 @fn_str_eq(ptr %t146, ptr @.str468)
  %t148 = icmp ne i32 %t147, 0
  br i1 %t148, label %then26, label %ifend28
then26:
  %t149 = load ptr, ptr %t1
  %t150 = call ptr @fn_arg_code(ptr %t149, i32 0)
  store ptr %t150, ptr %t151
  %t152 = call ptr @fn_emit_bind(ptr @.str469)
  store ptr %t152, ptr %t153
  %t154 = load ptr, ptr %t153
  %t155 = call ptr @fn_str_concat(ptr @.str470, ptr %t154)
  %t156 = call ptr @fn_str_concat(ptr %t155, ptr @.str471)
  %t157 = load ptr, ptr %t151
  %t158 = call ptr @fn_str_concat(ptr %t156, ptr %t157)
  %t159 = call ptr @fn_emit_bind(ptr %t158)
  store ptr %t159, ptr %t160
  %t161 = load ptr, ptr %t160
  %t162 = call ptr @fn_str_concat(ptr @.str472, ptr %t161)
  %t163 = call ptr @fn_emit_bind(ptr %t162)
  %t164 = call ptr @fn_val(ptr %t163, ptr @.str473)
  store ptr %t164, ptr %retval
  br label %ret
ifend28:
  %t165 = load ptr, ptr %t0
  %t166 = call i32 @fn_str_eq(ptr %t165, ptr @.str474)
  %t167 = icmp ne i32 %t166, 0
  br i1 %t167, label %then29, label %ifend31
then29:
  %t168 = load ptr, ptr %t1
  %t169 = call ptr @fn_arg_code(ptr %t168, i32 0)
  store ptr %t169, ptr %t170
  call void @fn_emit(ptr @.str475)
  %t171 = load ptr, ptr %t170
  call void @fn_emit(ptr %t171)
  call void @fn_emit(ptr @.str476)
  call void @fn_emit(ptr @.str477)
  store i32 1, ptr @g_g_term
  %t172 = call ptr @fn_val(ptr @.str478, ptr @.str479)
  store ptr %t172, ptr %retval
  br label %ret
ifend31:
  %t173 = load ptr, ptr %t0
  %t174 = call i32 @fn_str_eq(ptr %t173, ptr @.str480)
  %t175 = icmp ne i32 %t174, 0
  br i1 %t175, label %then32, label %ifend34
then32:
  %t176 = call ptr @fn_emit_bind(ptr @.str481)
  %t177 = call ptr @fn_val(ptr %t176, ptr @.str482)
  store ptr %t177, ptr %retval
  br label %ret
ifend34:
  %t178 = load ptr, ptr %t0
  %t179 = call i32 @fn_str_eq(ptr %t178, ptr @.str483)
  %t180 = icmp ne i32 %t179, 0
  br i1 %t180, label %then35, label %ifend37
then35:
  %t181 = call ptr @fn_emit_bind(ptr @.str484)
  %t182 = call ptr @fn_val(ptr %t181, ptr @.str485)
  store ptr %t182, ptr %retval
  br label %ret
ifend37:
  %t183 = load ptr, ptr %t0
  %t184 = call i32 @fn_str_eq(ptr %t183, ptr @.str486)
  %t185 = icmp ne i32 %t184, 0
  br i1 %t185, label %then38, label %ifend40
then38:
  %t186 = load ptr, ptr %t1
  %t187 = call ptr @fn_arg_code(ptr %t186, i32 0)
  store ptr %t187, ptr %t188
  %t189 = load ptr, ptr %t188
  %t190 = call ptr @fn_str_concat(ptr @.str487, ptr %t189)
  %t191 = call ptr @fn_str_concat(ptr %t190, ptr @.str488)
  %t192 = call ptr @fn_emit_bind(ptr %t191)
  %t193 = call ptr @fn_val(ptr %t192, ptr @.str489)
  store ptr %t193, ptr %retval
  br label %ret
ifend40:
  %t194 = load ptr, ptr %t0
  %t195 = call i32 @fn_str_eq(ptr %t194, ptr @.str490)
  %t196 = icmp ne i32 %t195, 0
  br i1 %t196, label %then41, label %ifend43
then41:
  %t197 = load ptr, ptr %t1
  %t198 = call ptr @fn_arg_code(ptr %t197, i32 0)
  store ptr %t198, ptr %t199
  %t200 = load ptr, ptr %t199
  %t201 = call ptr @fn_str_concat(ptr @.str491, ptr %t200)
  %t202 = call ptr @fn_str_concat(ptr %t201, ptr @.str492)
  %t203 = call ptr @fn_emit_bind(ptr %t202)
  %t204 = call ptr @fn_val(ptr %t203, ptr @.str493)
  store ptr %t204, ptr %retval
  br label %ret
ifend43:
  store i32 0, ptr @g_g_intrin_ok
  %t205 = call ptr @fn_val(ptr @.str494, ptr @.str495)
  store ptr %t205, ptr %retval
  br label %ret
ret:
  %t206 = load ptr, ptr %retval
  ret ptr %t206
}

define i32 @fn_is_intrinsic2(ptr %arg_name) {
entry:
  %retval = alloca i32
  %t0 = alloca ptr
  %t1 = alloca i32
  %t12 = alloca i32
  %t23 = alloca i32
  %t34 = alloca i32
  %t45 = alloca i32
  %t46 = alloca i32
  %t64 = alloca i32
  store ptr %arg_name, ptr %t0
  %t2 = load ptr, ptr %t0
  %t3 = call i32 @fn_str_eq(ptr %t2, ptr @.str496)
  %t4 = icmp ne i32 %t3, 0
  %t5 = zext i1 %t4 to i32
  store i32 %t5, ptr %t1
  br i1 %t4, label %scend1, label %sc0
sc0:
  %t6 = load ptr, ptr %t0
  %t7 = call i32 @fn_str_eq(ptr %t6, ptr @.str497)
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
  %t14 = call i32 @fn_str_eq(ptr %t13, ptr @.str498)
  %t15 = icmp ne i32 %t14, 0
  %t16 = zext i1 %t15 to i32
  store i32 %t16, ptr %t12
  br i1 %t15, label %scend6, label %sc5
sc5:
  %t17 = load ptr, ptr %t0
  %t18 = call i32 @fn_str_eq(ptr %t17, ptr @.str499)
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
  %t24 = load ptr, ptr %t0
  %t25 = call i32 @fn_str_eq(ptr %t24, ptr @.str500)
  %t26 = icmp ne i32 %t25, 0
  %t27 = zext i1 %t26 to i32
  store i32 %t27, ptr %t23
  br i1 %t26, label %scend11, label %sc10
sc10:
  %t28 = load ptr, ptr %t0
  %t29 = call i32 @fn_str_eq(ptr %t28, ptr @.str501)
  %t30 = icmp ne i32 %t29, 0
  %t31 = zext i1 %t30 to i32
  store i32 %t31, ptr %t23
  br label %scend11
scend11:
  %t32 = load i32, ptr %t23
  %t33 = icmp ne i32 %t32, 0
  br i1 %t33, label %then12, label %ifend14
then12:
  store i32 1, ptr %retval
  br label %ret
ifend14:
  %t35 = load ptr, ptr %t0
  %t36 = call i32 @fn_str_eq(ptr %t35, ptr @.str502)
  %t37 = icmp ne i32 %t36, 0
  %t38 = zext i1 %t37 to i32
  store i32 %t38, ptr %t34
  br i1 %t37, label %scend16, label %sc15
sc15:
  %t39 = load ptr, ptr %t0
  %t40 = call i32 @fn_str_eq(ptr %t39, ptr @.str503)
  %t41 = icmp ne i32 %t40, 0
  %t42 = zext i1 %t41 to i32
  store i32 %t42, ptr %t34
  br label %scend16
scend16:
  %t43 = load i32, ptr %t34
  %t44 = icmp ne i32 %t43, 0
  br i1 %t44, label %then17, label %ifend19
then17:
  store i32 1, ptr %retval
  br label %ret
ifend19:
  %t47 = load ptr, ptr %t0
  %t48 = call i32 @fn_str_eq(ptr %t47, ptr @.str504)
  %t49 = icmp ne i32 %t48, 0
  %t50 = zext i1 %t49 to i32
  store i32 %t50, ptr %t46
  br i1 %t49, label %scend21, label %sc20
sc20:
  %t51 = load ptr, ptr %t0
  %t52 = call i32 @fn_str_eq(ptr %t51, ptr @.str505)
  %t53 = icmp ne i32 %t52, 0
  %t54 = zext i1 %t53 to i32
  store i32 %t54, ptr %t46
  br label %scend21
scend21:
  %t55 = load i32, ptr %t46
  %t56 = icmp ne i32 %t55, 0
  %t57 = zext i1 %t56 to i32
  store i32 %t57, ptr %t45
  br i1 %t56, label %scend23, label %sc22
sc22:
  %t58 = load ptr, ptr %t0
  %t59 = call i32 @fn_str_eq(ptr %t58, ptr @.str506)
  %t60 = icmp ne i32 %t59, 0
  %t61 = zext i1 %t60 to i32
  store i32 %t61, ptr %t45
  br label %scend23
scend23:
  %t62 = load i32, ptr %t45
  %t63 = icmp ne i32 %t62, 0
  br i1 %t63, label %then24, label %ifend26
then24:
  store i32 1, ptr %retval
  br label %ret
ifend26:
  %t65 = load ptr, ptr %t0
  %t66 = call i32 @fn_str_eq(ptr %t65, ptr @.str507)
  %t67 = icmp ne i32 %t66, 0
  %t68 = zext i1 %t67 to i32
  store i32 %t68, ptr %t64
  br i1 %t67, label %scend28, label %sc27
sc27:
  %t69 = load ptr, ptr %t0
  %t70 = call i32 @fn_str_eq(ptr %t69, ptr @.str508)
  %t71 = icmp ne i32 %t70, 0
  %t72 = zext i1 %t71 to i32
  store i32 %t72, ptr %t64
  br label %scend28
scend28:
  %t73 = load i32, ptr %t64
  %t74 = icmp ne i32 %t73, 0
  br i1 %t74, label %then29, label %ifend31
then29:
  store i32 1, ptr %retval
  br label %ret
ifend31:
  store i32 0, ptr %retval
  br label %ret
ret:
  %t75 = load i32, ptr %retval
  ret i32 %t75
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
  %t41 = alloca ptr
  %t63 = alloca ptr
  %t79 = alloca ptr
  %t110 = alloca ptr
  %t113 = alloca ptr
  %t116 = alloca ptr
  %t119 = alloca ptr
  %t130 = alloca ptr
  %t133 = alloca ptr
  %t136 = alloca ptr
  store ptr %arg_name, ptr %t0
  store ptr %arg_e, ptr %t1
  %t2 = load ptr, ptr %t0
  %t3 = call i32 @fn_str_eq(ptr %t2, ptr @.str509)
  %t4 = icmp ne i32 %t3, 0
  br i1 %t4, label %then0, label %ifend2
then0:
  %t5 = load ptr, ptr %t1
  %t6 = call ptr @fn_arg_code(ptr %t5, i32 0)
  store ptr %t6, ptr %t7
  call void @fn_emit(ptr @.str510)
  %t8 = load ptr, ptr %t7
  call void @fn_emit(ptr %t8)
  call void @fn_emit(ptr @.str511)
  %t9 = call ptr @fn_val(ptr @.str512, ptr @.str513)
  store ptr %t9, ptr %retval
  br label %ret
ifend2:
  %t10 = load ptr, ptr %t0
  %t11 = call i32 @fn_str_eq(ptr %t10, ptr @.str514)
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
  %t23 = call ptr @fn_str_concat(ptr @.str515, ptr %t22)
  %t24 = call ptr @fn_str_concat(ptr %t23, ptr @.str516)
  %t25 = call ptr @fn_emit_bind(ptr %t24)
  store ptr %t25, ptr %t26
  call void @fn_emit(ptr @.str517)
  %t27 = load ptr, ptr %t15
  call void @fn_emit(ptr %t27)
  call void @fn_emit(ptr @.str518)
  %t28 = load ptr, ptr %t18
  call void @fn_emit(ptr %t28)
  call void @fn_emit(ptr @.str519)
  %t29 = load ptr, ptr %t26
  call void @fn_emit(ptr %t29)
  call void @fn_emit(ptr @.str520)
  %t30 = call ptr @fn_val(ptr @.str521, ptr @.str522)
  store ptr %t30, ptr %retval
  br label %ret
ifend5:
  %t31 = load ptr, ptr %t0
  %t32 = call i32 @fn_str_eq(ptr %t31, ptr @.str523)
  %t33 = icmp ne i32 %t32, 0
  br i1 %t33, label %then6, label %ifend8
then6:
  %t34 = load ptr, ptr %t1
  %t35 = call ptr @fn_arg_code(ptr %t34, i32 0)
  store ptr %t35, ptr %t36
  %t37 = load ptr, ptr %t1
  %t38 = call ptr @fn_arg_code(ptr %t37, i32 1)
  store ptr %t38, ptr %t39
  %t40 = call ptr @fn_nreg()
  store ptr %t40, ptr %t41
  call void @fn_emit(ptr @.str524)
  %t42 = load ptr, ptr %t41
  call void @fn_emit(ptr %t42)
  call void @fn_emit(ptr @.str525)
  %t43 = load ptr, ptr %t36
  call void @fn_emit(ptr %t43)
  call void @fn_emit(ptr @.str526)
  %t44 = load ptr, ptr %t39
  call void @fn_emit(ptr %t44)
  call void @fn_emit(ptr @.str527)
  %t45 = load ptr, ptr %t41
  %t46 = call ptr @fn_val(ptr %t45, ptr @.str528)
  store ptr %t46, ptr %retval
  br label %ret
ifend8:
  %t47 = load ptr, ptr %t0
  %t48 = call i32 @fn_str_eq(ptr %t47, ptr @.str529)
  %t49 = icmp ne i32 %t48, 0
  br i1 %t49, label %then9, label %ifend11
then9:
  %t50 = call ptr @fn_emit_bind(ptr @.str530)
  %t51 = call ptr @fn_val(ptr %t50, ptr @.str531)
  store ptr %t51, ptr %retval
  br label %ret
ifend11:
  %t52 = load ptr, ptr %t0
  %t53 = call i32 @fn_str_eq(ptr %t52, ptr @.str532)
  %t54 = icmp ne i32 %t53, 0
  br i1 %t54, label %then12, label %ifend14
then12:
  %t55 = load ptr, ptr %t1
  %t56 = getelementptr inbounds %Cmp_Node, ptr %t55, i32 0, i32 7
  %t57 = load ptr, ptr %t56
  %t58 = getelementptr inbounds %LSlice, ptr %t57, i32 0, i32 0
  %t59 = load ptr, ptr %t58
  %t60 = getelementptr inbounds ptr, ptr %t59, i32 0
  %t61 = load ptr, ptr %t60
  %t62 = call ptr @fn_emit_expr(ptr %t61)
  store ptr %t62, ptr %t63
  %t64 = load ptr, ptr %t63
  %t65 = getelementptr inbounds %Cmp_Val, ptr %t64, i32 0, i32 0
  %t66 = load ptr, ptr %t65
  %t67 = call ptr @fn_val(ptr %t66, ptr @.str533)
  store ptr %t67, ptr %retval
  br label %ret
ifend14:
  %t68 = load ptr, ptr %t0
  %t69 = call i32 @fn_str_eq(ptr %t68, ptr @.str534)
  %t70 = icmp ne i32 %t69, 0
  br i1 %t70, label %then15, label %ifend17
then15:
  %t71 = load ptr, ptr %t1
  %t72 = getelementptr inbounds %Cmp_Node, ptr %t71, i32 0, i32 7
  %t73 = load ptr, ptr %t72
  %t74 = getelementptr inbounds %LSlice, ptr %t73, i32 0, i32 0
  %t75 = load ptr, ptr %t74
  %t76 = getelementptr inbounds ptr, ptr %t75, i32 0
  %t77 = load ptr, ptr %t76
  %t78 = call ptr @fn_emit_expr(ptr %t77)
  store ptr %t78, ptr %t79
  %t80 = load ptr, ptr %t79
  %t81 = getelementptr inbounds %Cmp_Val, ptr %t80, i32 0, i32 0
  %t82 = load ptr, ptr %t81
  %t83 = call ptr @fn_val(ptr %t82, ptr @.str535)
  store ptr %t83, ptr %retval
  br label %ret
ifend17:
  %t84 = load ptr, ptr %t0
  %t85 = call i32 @fn_str_eq(ptr %t84, ptr @.str536)
  %t86 = icmp ne i32 %t85, 0
  br i1 %t86, label %then18, label %ifend20
then18:
  %t87 = load i32, ptr @g_g_windowed
  %t88 = icmp ne i32 %t87, 0
  br i1 %t88, label %then21, label %ifend23
then21:
  %t89 = call ptr @fn_val(ptr @.str537, ptr @.str538)
  store ptr %t89, ptr %retval
  br label %ret
ifend23:
  %t90 = call ptr @fn_val(ptr @.str539, ptr @.str540)
  store ptr %t90, ptr %retval
  br label %ret
ifend20:
  %t91 = load ptr, ptr %t0
  %t92 = call i32 @fn_str_eq(ptr %t91, ptr @.str541)
  %t93 = icmp ne i32 %t92, 0
  br i1 %t93, label %then24, label %ifend26
then24:
  %t94 = call ptr @fn_val(ptr @.str542, ptr @.str543)
  store ptr %t94, ptr %retval
  br label %ret
ifend26:
  %t95 = load ptr, ptr %t0
  %t96 = call i32 @fn_str_eq(ptr %t95, ptr @.str544)
  %t97 = icmp ne i32 %t96, 0
  br i1 %t97, label %then27, label %ifend29
then27:
  %t98 = call ptr @fn_emit_bind(ptr @.str545)
  %t99 = call ptr @fn_val(ptr %t98, ptr @.str546)
  store ptr %t99, ptr %retval
  br label %ret
ifend29:
  %t100 = load ptr, ptr %t0
  %t101 = call i32 @fn_str_eq(ptr %t100, ptr @.str547)
  %t102 = icmp ne i32 %t101, 0
  br i1 %t102, label %then30, label %ifend32
then30:
  %t103 = call ptr @fn_emit_bind(ptr @.str548)
  %t104 = call ptr @fn_val(ptr %t103, ptr @.str549)
  store ptr %t104, ptr %retval
  br label %ret
ifend32:
  %t105 = load ptr, ptr %t0
  %t106 = call i32 @fn_str_eq(ptr %t105, ptr @.str550)
  %t107 = icmp ne i32 %t106, 0
  br i1 %t107, label %then33, label %ifend35
then33:
  %t108 = load ptr, ptr %t1
  %t109 = call ptr @fn_arg_code(ptr %t108, i32 0)
  store ptr %t109, ptr %t110
  %t111 = load ptr, ptr %t1
  %t112 = call ptr @fn_arg_code(ptr %t111, i32 1)
  store ptr %t112, ptr %t113
  %t114 = load ptr, ptr %t1
  %t115 = call ptr @fn_arg_code(ptr %t114, i32 2)
  store ptr %t115, ptr %t116
  %t117 = load ptr, ptr %t1
  %t118 = call ptr @fn_arg_code(ptr %t117, i32 3)
  store ptr %t118, ptr %t119
  call void @fn_emit(ptr @.str551)
  %t120 = load ptr, ptr %t110
  call void @fn_emit(ptr %t120)
  call void @fn_emit(ptr @.str552)
  %t121 = load ptr, ptr %t113
  call void @fn_emit(ptr %t121)
  call void @fn_emit(ptr @.str553)
  %t122 = load ptr, ptr %t116
  call void @fn_emit(ptr %t122)
  call void @fn_emit(ptr @.str554)
  %t123 = load ptr, ptr %t119
  call void @fn_emit(ptr %t123)
  call void @fn_emit(ptr @.str555)
  %t124 = call ptr @fn_val(ptr @.str556, ptr @.str557)
  store ptr %t124, ptr %retval
  br label %ret
ifend35:
  %t125 = load ptr, ptr %t0
  %t126 = call i32 @fn_str_eq(ptr %t125, ptr @.str558)
  %t127 = icmp ne i32 %t126, 0
  br i1 %t127, label %then36, label %ifend38
then36:
  %t128 = load ptr, ptr %t1
  %t129 = call ptr @fn_arg_code(ptr %t128, i32 0)
  store ptr %t129, ptr %t130
  %t131 = load ptr, ptr %t1
  %t132 = call ptr @fn_arg_code(ptr %t131, i32 1)
  store ptr %t132, ptr %t133
  %t134 = load ptr, ptr %t1
  %t135 = call ptr @fn_arg_code(ptr %t134, i32 2)
  store ptr %t135, ptr %t136
  call void @fn_emit(ptr @.str559)
  %t137 = load ptr, ptr %t130
  call void @fn_emit(ptr %t137)
  call void @fn_emit(ptr @.str560)
  %t138 = load ptr, ptr %t133
  call void @fn_emit(ptr %t138)
  call void @fn_emit(ptr @.str561)
  %t139 = load ptr, ptr %t136
  call void @fn_emit(ptr %t139)
  call void @fn_emit(ptr @.str562)
  %t140 = call ptr @fn_val(ptr @.str563, ptr @.str564)
  store ptr %t140, ptr %retval
  br label %ret
ifend38:
  %t141 = load ptr, ptr %t0
  %t142 = call i32 @fn_str_eq(ptr %t141, ptr @.str565)
  %t143 = icmp ne i32 %t142, 0
  br i1 %t143, label %then39, label %ifend41
then39:
  call void @fn_emit(ptr @.str566)
  %t144 = call ptr @fn_val(ptr @.str567, ptr @.str568)
  store ptr %t144, ptr %retval
  br label %ret
ifend41:
  %t145 = call ptr @fn_val(ptr @.str569, ptr @.str570)
  store ptr %t145, ptr %retval
  br label %ret
ret:
  %t146 = load ptr, ptr %retval
  ret ptr %t146
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
  %t5 = call i32 @fn_str_eq(ptr %t4, ptr @.str571)
  %t6 = icmp ne i32 %t5, 0
  %t7 = zext i1 %t6 to i32
  store i32 %t7, ptr %t3
  br i1 %t6, label %scend1, label %sc0
sc0:
  %t8 = load ptr, ptr %t0
  %t9 = call i32 @fn_str_eq(ptr %t8, ptr @.str572)
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
  %t16 = call i32 @fn_str_eq(ptr %t15, ptr @.str573)
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
  %t23 = call i32 @fn_str_eq(ptr %t22, ptr @.str574)
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
  %t3 = call i32 @fn_str_eq(ptr %t2, ptr @.str575)
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
  %t17 = call ptr @fn_str_concat(ptr @.str576, ptr %t16)
  %t18 = call ptr @fn_str_concat(ptr %t17, ptr @.str577)
  %t19 = call ptr @fn_emit_bind(ptr %t18)
  store ptr %t19, ptr %t20
  %t21 = load ptr, ptr %t13
  %t22 = getelementptr inbounds %Cmp_Val, ptr %t21, i32 0, i32 0
  %t23 = load ptr, ptr %t22
  %t24 = call ptr @fn_str_concat(ptr @.str578, ptr %t23)
  %t25 = call ptr @fn_emit_bind(ptr %t24)
  store ptr %t25, ptr %t26
  %t27 = load ptr, ptr %t20
  %t28 = call ptr @fn_str_concat(ptr @.str579, ptr %t27)
  %t29 = call ptr @fn_str_concat(ptr %t28, ptr @.str580)
  %t30 = load ptr, ptr %t26
  %t31 = call ptr @fn_str_concat(ptr %t29, ptr %t30)
  %t32 = call ptr @fn_str_concat(ptr %t31, ptr @.str581)
  %t33 = load ptr, ptr %t13
  %t34 = getelementptr inbounds %Cmp_Val, ptr %t33, i32 0, i32 0
  %t35 = load ptr, ptr %t34
  %t36 = call ptr @fn_str_concat(ptr %t32, ptr %t35)
  %t37 = call ptr @fn_emit_bind(ptr %t36)
  %t38 = call ptr @fn_val(ptr %t37, ptr @.str582)
  store ptr %t38, ptr %retval
  br label %ret
ifend2:
  %t40 = load ptr, ptr %t0
  %t41 = call i32 @fn_str_eq(ptr %t40, ptr @.str583)
  %t42 = icmp ne i32 %t41, 0
  %t43 = zext i1 %t42 to i32
  store i32 %t43, ptr %t39
  br i1 %t42, label %scend4, label %sc3
sc3:
  %t44 = load ptr, ptr %t0
  %t45 = call i32 @fn_str_eq(ptr %t44, ptr @.str584)
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
  store ptr @.str585, ptr %t68
  %t69 = load ptr, ptr %t0
  %t70 = call i32 @fn_str_eq(ptr %t69, ptr @.str586)
  %t71 = icmp ne i32 %t70, 0
  br i1 %t71, label %then8, label %ifend10
then8:
  store ptr @.str587, ptr %t68
  br label %ifend10
ifend10:
  %t72 = load ptr, ptr %t68
  %t73 = call ptr @fn_str_concat(ptr @.str588, ptr %t72)
  %t74 = call ptr @fn_str_concat(ptr %t73, ptr @.str589)
  %t75 = load ptr, ptr %t58
  %t76 = getelementptr inbounds %Cmp_Val, ptr %t75, i32 0, i32 0
  %t77 = load ptr, ptr %t76
  %t78 = call ptr @fn_str_concat(ptr %t74, ptr %t77)
  %t79 = call ptr @fn_str_concat(ptr %t78, ptr @.str590)
  %t80 = load ptr, ptr %t67
  %t81 = getelementptr inbounds %Cmp_Val, ptr %t80, i32 0, i32 0
  %t82 = load ptr, ptr %t81
  %t83 = call ptr @fn_str_concat(ptr %t79, ptr %t82)
  %t84 = call ptr @fn_emit_bind(ptr %t83)
  store ptr %t84, ptr %t85
  %t86 = load ptr, ptr %t85
  %t87 = call ptr @fn_str_concat(ptr @.str591, ptr %t86)
  %t88 = call ptr @fn_str_concat(ptr %t87, ptr @.str592)
  %t89 = load ptr, ptr %t58
  %t90 = getelementptr inbounds %Cmp_Val, ptr %t89, i32 0, i32 0
  %t91 = load ptr, ptr %t90
  %t92 = call ptr @fn_str_concat(ptr %t88, ptr %t91)
  %t93 = call ptr @fn_str_concat(ptr %t92, ptr @.str593)
  %t94 = load ptr, ptr %t67
  %t95 = getelementptr inbounds %Cmp_Val, ptr %t94, i32 0, i32 0
  %t96 = load ptr, ptr %t95
  %t97 = call ptr @fn_str_concat(ptr %t93, ptr %t96)
  %t98 = call ptr @fn_emit_bind(ptr %t97)
  %t99 = call ptr @fn_val(ptr %t98, ptr @.str594)
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
  %t130 = call ptr @fn_str_concat(ptr @.str595, ptr %t129)
  %t131 = call ptr @fn_str_concat(ptr %t130, ptr @.str596)
  %t132 = load ptr, ptr %t126
  %t133 = getelementptr inbounds %Cmp_Val, ptr %t132, i32 0, i32 0
  %t134 = load ptr, ptr %t133
  %t135 = call ptr @fn_str_concat(ptr %t131, ptr %t134)
  %t136 = call ptr @fn_emit_bind(ptr %t135)
  store ptr %t136, ptr %t137
  %t138 = load ptr, ptr %t137
  %t139 = call ptr @fn_str_concat(ptr @.str597, ptr %t138)
  %t140 = call ptr @fn_str_concat(ptr %t139, ptr @.str598)
  %t141 = load ptr, ptr %t108
  %t142 = getelementptr inbounds %Cmp_Val, ptr %t141, i32 0, i32 0
  %t143 = load ptr, ptr %t142
  %t144 = call ptr @fn_str_concat(ptr %t140, ptr %t143)
  %t145 = call ptr @fn_str_concat(ptr %t144, ptr @.str599)
  %t146 = load ptr, ptr %t126
  %t147 = getelementptr inbounds %Cmp_Val, ptr %t146, i32 0, i32 0
  %t148 = load ptr, ptr %t147
  %t149 = call ptr @fn_str_concat(ptr %t145, ptr %t148)
  %t150 = call ptr @fn_emit_bind(ptr %t149)
  store ptr %t150, ptr %t151
  %t152 = load ptr, ptr %t117
  %t153 = getelementptr inbounds %Cmp_Val, ptr %t152, i32 0, i32 0
  %t154 = load ptr, ptr %t153
  %t155 = call ptr @fn_str_concat(ptr @.str600, ptr %t154)
  %t156 = call ptr @fn_str_concat(ptr %t155, ptr @.str601)
  %t157 = load ptr, ptr %t151
  %t158 = call ptr @fn_str_concat(ptr %t156, ptr %t157)
  %t159 = call ptr @fn_emit_bind(ptr %t158)
  store ptr %t159, ptr %t160
  %t161 = load ptr, ptr %t160
  %t162 = call ptr @fn_str_concat(ptr @.str602, ptr %t161)
  %t163 = call ptr @fn_str_concat(ptr %t162, ptr @.str603)
  %t164 = load ptr, ptr %t117
  %t165 = getelementptr inbounds %Cmp_Val, ptr %t164, i32 0, i32 0
  %t166 = load ptr, ptr %t165
  %t167 = call ptr @fn_str_concat(ptr %t163, ptr %t166)
  %t168 = call ptr @fn_str_concat(ptr %t167, ptr @.str604)
  %t169 = load ptr, ptr %t151
  %t170 = call ptr @fn_str_concat(ptr %t168, ptr %t169)
  %t171 = call ptr @fn_emit_bind(ptr %t170)
  %t172 = call ptr @fn_val(ptr %t171, ptr @.str605)
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
  %t2 = call ptr @fn_str_concat(ptr @.str606, ptr %t1)
  %t3 = call ptr @fn_str_concat(ptr %t2, ptr @.str607)
  %t4 = call ptr @fn_emit_bind(ptr %t3)
  store ptr %t4, ptr %t5
  %t6 = load ptr, ptr %t5
  %t7 = call ptr @fn_str_concat(ptr @.str608, ptr %t6)
  %t8 = call ptr @fn_str_concat(ptr %t7, ptr @.str609)
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
  call void @fn_perr(ptr @.str610)
  br label %ifend2
ifend2:
  %t8 = load ptr, ptr %t0
  %t9 = call ptr @fn_layout_ty(ptr %t8)
  store ptr %t9, ptr %t10
  %t11 = load ptr, ptr %t10
  %t12 = call ptr @fn_emit_sizeof(ptr %t11)
  store ptr %t12, ptr %t13
  %t14 = load ptr, ptr %t13
  %t15 = call ptr @fn_str_concat(ptr @.str611, ptr %t14)
  %t16 = call ptr @fn_str_concat(ptr %t15, ptr @.str612)
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
  call void @fn_emit(ptr @.str613)
  %t40 = load ptr, ptr %t39
  call void @fn_emit(ptr %t40)
  call void @fn_emit(ptr @.str614)
  %t41 = load ptr, ptr %t10
  call void @fn_emit(ptr %t41)
  call void @fn_emit(ptr @.str615)
  %t42 = load ptr, ptr %t18
  call void @fn_emit(ptr %t42)
  call void @fn_emit(ptr @.str616)
  %t43 = load i32, ptr %t19
  %t44 = call ptr @fn_itoa(i32 %t43)
  call void @fn_emit(ptr %t44)
  call void @fn_emit(ptr @.str617)
  %t45 = load ptr, ptr %t37
  %t46 = getelementptr inbounds %Cmp_Node, ptr %t45, i32 0, i32 3
  %t47 = load ptr, ptr %t46
  %t48 = call ptr @fn_llty(ptr %t47)
  store ptr %t48, ptr %t49
  store ptr @.str618, ptr %t50
  %t51 = load ptr, ptr %t49
  %t52 = call i32 @fn_str_eq(ptr %t51, ptr @.str619)
  %t53 = icmp ne i32 %t52, 0
  br i1 %t53, label %then6, label %ifend8
then6:
  store ptr @.str620, ptr %t50
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
  call void @fn_emit(ptr @.str621)
  %t68 = load ptr, ptr %t49
  call void @fn_emit(ptr %t68)
  call void @fn_emit(ptr @.str622)
  %t69 = load ptr, ptr %t50
  call void @fn_emit(ptr %t69)
  call void @fn_emit(ptr @.str623)
  %t70 = load ptr, ptr %t39
  call void @fn_emit(ptr %t70)
  call void @fn_emit(ptr @.str624)
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
  %t1 = call ptr @fn_emit_sizeof(ptr @.str625)
  store ptr %t1, ptr %t2
  %t3 = load ptr, ptr %t2
  %t4 = call ptr @fn_str_concat(ptr @.str626, ptr %t3)
  %t5 = call ptr @fn_str_concat(ptr %t4, ptr @.str627)
  %t6 = call ptr @fn_emit_bind(ptr %t5)
  store ptr %t6, ptr %t7
  %t8 = call ptr @fn_nreg()
  store ptr %t8, ptr %t9
  call void @fn_emit(ptr @.str628)
  %t10 = load ptr, ptr %t9
  call void @fn_emit(ptr %t10)
  call void @fn_emit(ptr @.str629)
  %t11 = load ptr, ptr %t7
  call void @fn_emit(ptr %t11)
  call void @fn_emit(ptr @.str630)
  call void @fn_emit(ptr @.str631)
  %t12 = load ptr, ptr %t9
  call void @fn_emit(ptr %t12)
  call void @fn_emit(ptr @.str632)
  %t13 = call ptr @fn_nreg()
  store ptr %t13, ptr %t14
  call void @fn_emit(ptr @.str633)
  %t15 = load ptr, ptr %t14
  call void @fn_emit(ptr %t15)
  call void @fn_emit(ptr @.str634)
  %t16 = load ptr, ptr %t7
  call void @fn_emit(ptr %t16)
  call void @fn_emit(ptr @.str635)
  call void @fn_emit(ptr @.str636)
  %t17 = load ptr, ptr %t14
  call void @fn_emit(ptr %t17)
  call void @fn_emit(ptr @.str637)
  %t18 = call ptr @fn_nreg()
  store ptr %t18, ptr %t19
  call void @fn_emit(ptr @.str638)
  %t20 = load ptr, ptr %t19
  call void @fn_emit(ptr %t20)
  call void @fn_emit(ptr @.str639)
  %t21 = load ptr, ptr %t7
  call void @fn_emit(ptr %t21)
  call void @fn_emit(ptr @.str640)
  call void @fn_emit(ptr @.str641)
  %t22 = load ptr, ptr %t19
  call void @fn_emit(ptr %t22)
  call void @fn_emit(ptr @.str642)
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
  call void @fn_emit(ptr @.str643)
  %t4 = load ptr, ptr %t3
  call void @fn_emit(ptr %t4)
  call void @fn_emit(ptr @.str644)
  %t5 = load ptr, ptr %t0
  call void @fn_emit(ptr %t5)
  call void @fn_emit(ptr @.str645)
  %t6 = load i32, ptr %t1
  %t7 = call ptr @fn_itoa(i32 %t6)
  call void @fn_emit(ptr %t7)
  call void @fn_emit(ptr @.str646)
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
  %t19 = alloca ptr
  %t30 = alloca ptr
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
  %t13 = call i32 @fn_is_slice_ty(ptr %t12)
  %t14 = icmp ne i32 %t13, 0
  br i1 %t14, label %then0, label %ifend2
then0:
  %t15 = load ptr, ptr %t9
  %t16 = getelementptr inbounds %Cmp_Val, ptr %t15, i32 0, i32 0
  %t17 = load ptr, ptr %t16
  %t18 = call ptr @fn_slice_field(ptr %t17, i32 1)
  store ptr %t18, ptr %t19
  %t20 = load ptr, ptr %t19
  %t21 = call ptr @fn_str_concat(ptr @.str647, ptr %t20)
  %t22 = call ptr @fn_emit_bind(ptr %t21)
  %t23 = call ptr @fn_val(ptr %t22, ptr @.str648)
  store ptr %t23, ptr %retval
  br label %ret
ifend2:
  %t24 = load ptr, ptr %t9
  %t25 = getelementptr inbounds %Cmp_Val, ptr %t24, i32 0, i32 0
  %t26 = load ptr, ptr %t25
  %t27 = call ptr @fn_str_concat(ptr @.str649, ptr %t26)
  %t28 = call ptr @fn_str_concat(ptr %t27, ptr @.str650)
  %t29 = call ptr @fn_emit_bind(ptr %t28)
  store ptr %t29, ptr %t30
  %t31 = load ptr, ptr %t30
  %t32 = call ptr @fn_str_concat(ptr @.str651, ptr %t31)
  %t33 = call ptr @fn_str_concat(ptr %t32, ptr @.str652)
  %t34 = call ptr @fn_emit_bind(ptr %t33)
  %t35 = call ptr @fn_val(ptr %t34, ptr @.str653)
  store ptr %t35, ptr %retval
  br label %ret
ret:
  %t36 = load ptr, ptr %retval
  ret ptr %t36
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
  %t32 = call ptr @fn_str_concat(ptr @.str654, ptr %t31)
  %t33 = call ptr @fn_emit_bind(ptr %t32)
  store ptr %t33, ptr %t34
  %t35 = load ptr, ptr %t27
  %t36 = call ptr @fn_str_concat(ptr @.str655, ptr %t35)
  %t37 = call ptr @fn_emit_bind(ptr %t36)
  store ptr %t37, ptr %t38
  %t39 = load ptr, ptr %t34
  %t40 = call ptr @fn_str_concat(ptr @.str656, ptr %t39)
  %t41 = call ptr @fn_str_concat(ptr %t40, ptr @.str657)
  %t42 = load ptr, ptr %t38
  %t43 = call ptr @fn_str_concat(ptr %t41, ptr %t42)
  %t44 = call ptr @fn_emit_bind(ptr %t43)
  store ptr %t44, ptr %t45
  %t46 = call ptr @fn_lbl(ptr @.str658)
  store ptr %t46, ptr %t47
  %t48 = call ptr @fn_lbl(ptr @.str659)
  store ptr %t48, ptr %t49
  call void @fn_emit(ptr @.str660)
  %t50 = load ptr, ptr %t45
  call void @fn_emit(ptr %t50)
  call void @fn_emit(ptr @.str661)
  %t51 = load ptr, ptr %t47
  call void @fn_emit(ptr %t51)
  call void @fn_emit(ptr @.str662)
  %t52 = load ptr, ptr %t49
  call void @fn_emit(ptr %t52)
  call void @fn_emit(ptr @.str663)
  %t53 = load ptr, ptr %t47
  call void @fn_emit(ptr %t53)
  call void @fn_emit(ptr @.str664)
  %t54 = load ptr, ptr %t38
  %t55 = call ptr @fn_str_concat(ptr @.str665, ptr %t54)
  %t56 = call ptr @fn_str_concat(ptr %t55, ptr @.str666)
  %t57 = call ptr @fn_emit_bind(ptr %t56)
  store ptr %t57, ptr %t58
  %t59 = load ptr, ptr %t38
  %t60 = call ptr @fn_str_concat(ptr @.str667, ptr %t59)
  %t61 = call ptr @fn_str_concat(ptr %t60, ptr @.str668)
  %t62 = call ptr @fn_emit_bind(ptr %t61)
  store ptr %t62, ptr %t63
  %t64 = load ptr, ptr %t63
  %t65 = call ptr @fn_str_concat(ptr @.str669, ptr %t64)
  %t66 = call ptr @fn_str_concat(ptr %t65, ptr @.str670)
  %t67 = load ptr, ptr %t58
  %t68 = call ptr @fn_str_concat(ptr %t66, ptr %t67)
  %t69 = call ptr @fn_emit_bind(ptr %t68)
  store ptr %t69, ptr %t70
  %t71 = load ptr, ptr %t17
  %t72 = call ptr @fn_emit_sizeof(ptr %t71)
  store ptr %t72, ptr %t73
  %t74 = load ptr, ptr %t70
  %t75 = call ptr @fn_str_concat(ptr @.str671, ptr %t74)
  %t76 = call ptr @fn_str_concat(ptr %t75, ptr @.str672)
  %t77 = call ptr @fn_emit_bind(ptr %t76)
  store ptr %t77, ptr %t78
  %t79 = load ptr, ptr %t78
  %t80 = call ptr @fn_str_concat(ptr @.str673, ptr %t79)
  %t81 = call ptr @fn_str_concat(ptr %t80, ptr @.str674)
  %t82 = load ptr, ptr %t73
  %t83 = call ptr @fn_str_concat(ptr %t81, ptr %t82)
  %t84 = call ptr @fn_emit_bind(ptr %t83)
  store ptr %t84, ptr %t85
  %t86 = load ptr, ptr %t30
  %t87 = call ptr @fn_str_concat(ptr @.str675, ptr %t86)
  %t88 = call ptr @fn_emit_bind(ptr %t87)
  store ptr %t88, ptr %t89
  %t90 = load ptr, ptr %t89
  %t91 = call ptr @fn_str_concat(ptr @.str676, ptr %t90)
  %t92 = call ptr @fn_str_concat(ptr %t91, ptr @.str677)
  %t93 = load ptr, ptr %t85
  %t94 = call ptr @fn_str_concat(ptr %t92, ptr %t93)
  %t95 = call ptr @fn_str_concat(ptr %t94, ptr @.str678)
  %t96 = call ptr @fn_emit_bind(ptr %t95)
  store ptr %t96, ptr %t97
  call void @fn_emit(ptr @.str679)
  %t98 = load ptr, ptr %t97
  call void @fn_emit(ptr %t98)
  call void @fn_emit(ptr @.str680)
  %t99 = load ptr, ptr %t30
  call void @fn_emit(ptr %t99)
  call void @fn_emit(ptr @.str681)
  call void @fn_emit(ptr @.str682)
  %t100 = load ptr, ptr %t70
  call void @fn_emit(ptr %t100)
  call void @fn_emit(ptr @.str683)
  %t101 = load ptr, ptr %t27
  call void @fn_emit(ptr %t101)
  call void @fn_emit(ptr @.str684)
  call void @fn_emit(ptr @.str685)
  %t102 = load ptr, ptr %t49
  call void @fn_emit(ptr %t102)
  call void @fn_emit(ptr @.str686)
  %t103 = load ptr, ptr %t49
  call void @fn_emit(ptr %t103)
  call void @fn_emit(ptr @.str687)
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
  %t114 = call ptr @fn_str_concat(ptr @.str688, ptr %t113)
  %t115 = call ptr @fn_emit_bind(ptr %t114)
  store ptr %t115, ptr %t116
  %t117 = call ptr @fn_nreg()
  store ptr %t117, ptr %t118
  call void @fn_emit(ptr @.str689)
  %t119 = load ptr, ptr %t118
  call void @fn_emit(ptr %t119)
  call void @fn_emit(ptr @.str690)
  %t120 = load ptr, ptr %t17
  call void @fn_emit(ptr %t120)
  call void @fn_emit(ptr @.str691)
  %t121 = load ptr, ptr %t116
  call void @fn_emit(ptr %t121)
  call void @fn_emit(ptr @.str692)
  %t122 = load ptr, ptr %t34
  call void @fn_emit(ptr %t122)
  call void @fn_emit(ptr @.str693)
  call void @fn_emit(ptr @.str694)
  %t123 = load ptr, ptr %t17
  call void @fn_emit(ptr %t123)
  call void @fn_emit(ptr @.str695)
  %t124 = load ptr, ptr %t112
  %t125 = getelementptr inbounds %Cmp_Val, ptr %t124, i32 0, i32 0
  %t126 = load ptr, ptr %t125
  call void @fn_emit(ptr %t126)
  call void @fn_emit(ptr @.str696)
  %t127 = load ptr, ptr %t118
  call void @fn_emit(ptr %t127)
  call void @fn_emit(ptr @.str697)
  %t128 = load ptr, ptr %t34
  %t129 = call ptr @fn_str_concat(ptr @.str698, ptr %t128)
  %t130 = call ptr @fn_str_concat(ptr %t129, ptr @.str699)
  %t131 = call ptr @fn_emit_bind(ptr %t130)
  store ptr %t131, ptr %t132
  call void @fn_emit(ptr @.str700)
  %t133 = load ptr, ptr %t132
  call void @fn_emit(ptr %t133)
  call void @fn_emit(ptr @.str701)
  %t134 = load ptr, ptr %t24
  call void @fn_emit(ptr %t134)
  call void @fn_emit(ptr @.str702)
  %t135 = call ptr @fn_val(ptr @.str703, ptr @.str704)
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
  %t4 = call ptr @fn_str_concat(ptr @.str705, ptr %t3)
  %t5 = call ptr @fn_str_concat(ptr %t4, ptr @.str706)
  %t6 = load ptr, ptr %t0
  %t7 = call ptr @fn_str_concat(ptr %t5, ptr %t6)
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
  %t1 = call ptr @fn_emit_alloca(ptr @.str707)
  store ptr %t1, ptr %t2
  %t3 = load ptr, ptr %t0
  %t4 = getelementptr inbounds %Cmp_Node, ptr %t3, i32 0, i32 4
  %t5 = load ptr, ptr %t4
  %t6 = call ptr @fn_emit_expr(ptr %t5)
  store ptr %t6, ptr %t7
  %t8 = load ptr, ptr %t7
  %t9 = getelementptr inbounds %Cmp_Val, ptr %t8, i32 0, i32 0
  %t10 = load ptr, ptr %t9
  %t11 = call ptr @fn_str_concat(ptr @.str708, ptr %t10)
  %t12 = call ptr @fn_str_concat(ptr %t11, ptr @.str709)
  %t13 = call ptr @fn_emit_bind(ptr %t12)
  store ptr %t13, ptr %t14
  %t15 = load ptr, ptr %t14
  %t16 = call ptr @fn_str_concat(ptr @.str710, ptr %t15)
  %t17 = call ptr @fn_str_concat(ptr %t16, ptr @.str711)
  %t18 = call ptr @fn_emit_bind(ptr %t17)
  store ptr %t18, ptr %t19
  call void @fn_emit(ptr @.str712)
  %t20 = load ptr, ptr %t19
  call void @fn_emit(ptr %t20)
  call void @fn_emit(ptr @.str713)
  %t21 = load ptr, ptr %t2
  call void @fn_emit(ptr %t21)
  call void @fn_emit(ptr @.str714)
  %t22 = call ptr @fn_lbl(ptr @.str715)
  store ptr %t22, ptr %t23
  %t24 = call ptr @fn_lbl(ptr @.str716)
  store ptr %t24, ptr %t25
  %t26 = load ptr, ptr %t0
  %t27 = getelementptr inbounds %Cmp_Node, ptr %t26, i32 0, i32 1
  %t28 = load ptr, ptr %t27
  %t29 = call i32 @fn_str_eq(ptr %t28, ptr @.str717)
  %t30 = icmp ne i32 %t29, 0
  br i1 %t30, label %then0, label %else1
then0:
  call void @fn_emit(ptr @.str718)
  %t31 = load ptr, ptr %t14
  call void @fn_emit(ptr %t31)
  call void @fn_emit(ptr @.str719)
  %t32 = load ptr, ptr %t23
  call void @fn_emit(ptr %t32)
  call void @fn_emit(ptr @.str720)
  %t33 = load ptr, ptr %t25
  call void @fn_emit(ptr %t33)
  call void @fn_emit(ptr @.str721)
  br label %ifend2
else1:
  call void @fn_emit(ptr @.str722)
  %t34 = load ptr, ptr %t14
  call void @fn_emit(ptr %t34)
  call void @fn_emit(ptr @.str723)
  %t35 = load ptr, ptr %t25
  call void @fn_emit(ptr %t35)
  call void @fn_emit(ptr @.str724)
  %t36 = load ptr, ptr %t23
  call void @fn_emit(ptr %t36)
  call void @fn_emit(ptr @.str725)
  br label %ifend2
ifend2:
  %t37 = load ptr, ptr %t23
  call void @fn_emit(ptr %t37)
  call void @fn_emit(ptr @.str726)
  %t38 = load ptr, ptr %t0
  %t39 = getelementptr inbounds %Cmp_Node, ptr %t38, i32 0, i32 5
  %t40 = load ptr, ptr %t39
  %t41 = call ptr @fn_emit_expr(ptr %t40)
  store ptr %t41, ptr %t42
  %t43 = load ptr, ptr %t42
  %t44 = getelementptr inbounds %Cmp_Val, ptr %t43, i32 0, i32 0
  %t45 = load ptr, ptr %t44
  %t46 = call ptr @fn_str_concat(ptr @.str727, ptr %t45)
  %t47 = call ptr @fn_str_concat(ptr %t46, ptr @.str728)
  %t48 = call ptr @fn_emit_bind(ptr %t47)
  store ptr %t48, ptr %t49
  %t50 = load ptr, ptr %t49
  %t51 = call ptr @fn_str_concat(ptr @.str729, ptr %t50)
  %t52 = call ptr @fn_str_concat(ptr %t51, ptr @.str730)
  %t53 = call ptr @fn_emit_bind(ptr %t52)
  store ptr %t53, ptr %t54
  call void @fn_emit(ptr @.str731)
  %t55 = load ptr, ptr %t54
  call void @fn_emit(ptr %t55)
  call void @fn_emit(ptr @.str732)
  %t56 = load ptr, ptr %t2
  call void @fn_emit(ptr %t56)
  call void @fn_emit(ptr @.str733)
  call void @fn_emit(ptr @.str734)
  %t57 = load ptr, ptr %t25
  call void @fn_emit(ptr %t57)
  call void @fn_emit(ptr @.str735)
  %t58 = load ptr, ptr %t25
  call void @fn_emit(ptr %t58)
  call void @fn_emit(ptr @.str736)
  %t59 = load ptr, ptr %t2
  %t60 = call ptr @fn_str_concat(ptr @.str737, ptr %t59)
  %t61 = call ptr @fn_emit_bind(ptr %t60)
  %t62 = call ptr @fn_val(ptr %t61, ptr @.str738)
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
  %t2 = call i32 @fn_str_eq(ptr %t1, ptr @.str739)
  %t3 = icmp ne i32 %t2, 0
  br i1 %t3, label %then0, label %ifend2
then0:
  store ptr @.str740, ptr %retval
  br label %ret
ifend2:
  %t4 = load ptr, ptr %t0
  %t5 = call i32 @fn_str_eq(ptr %t4, ptr @.str741)
  %t6 = icmp ne i32 %t5, 0
  br i1 %t6, label %then3, label %ifend5
then3:
  store ptr @.str742, ptr %retval
  br label %ret
ifend5:
  %t7 = load ptr, ptr %t0
  %t8 = call i32 @fn_str_eq(ptr %t7, ptr @.str743)
  %t9 = icmp ne i32 %t8, 0
  br i1 %t9, label %then6, label %ifend8
then6:
  store ptr @.str744, ptr %retval
  br label %ret
ifend8:
  %t10 = load ptr, ptr %t0
  %t11 = call i32 @fn_str_eq(ptr %t10, ptr @.str745)
  %t12 = icmp ne i32 %t11, 0
  br i1 %t12, label %then9, label %ifend11
then9:
  store ptr @.str746, ptr %retval
  br label %ret
ifend11:
  %t13 = load ptr, ptr %t0
  %t14 = call i32 @fn_str_eq(ptr %t13, ptr @.str747)
  %t15 = icmp ne i32 %t14, 0
  br i1 %t15, label %then12, label %ifend14
then12:
  store ptr @.str748, ptr %retval
  br label %ret
ifend14:
  store ptr @.str749, ptr %retval
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
  %t7 = call i32 @fn_str_eq(ptr %t6, ptr @.str750)
  %t8 = icmp ne i32 %t7, 0
  %t9 = zext i1 %t8 to i32
  store i32 %t9, ptr %t5
  br i1 %t8, label %scend1, label %sc0
sc0:
  %t10 = load ptr, ptr %t0
  %t11 = call i32 @fn_str_eq(ptr %t10, ptr @.str751)
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
  %t18 = call i32 @fn_str_eq(ptr %t17, ptr @.str752)
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
  %t25 = call i32 @fn_str_eq(ptr %t24, ptr @.str753)
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
  %t32 = call i32 @fn_str_eq(ptr %t31, ptr @.str754)
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
  %t39 = call i32 @fn_str_eq(ptr %t38, ptr @.str755)
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
  %t2 = call i32 @fn_str_eq(ptr %t1, ptr @.str756)
  %t3 = icmp ne i32 %t2, 0
  br i1 %t3, label %then0, label %ifend2
then0:
  store ptr @.str757, ptr %retval
  br label %ret
ifend2:
  %t4 = load ptr, ptr %t0
  %t5 = call i32 @fn_str_eq(ptr %t4, ptr @.str758)
  %t6 = icmp ne i32 %t5, 0
  br i1 %t6, label %then3, label %ifend5
then3:
  store ptr @.str759, ptr %retval
  br label %ret
ifend5:
  %t7 = load ptr, ptr %t0
  %t8 = call i32 @fn_str_eq(ptr %t7, ptr @.str760)
  %t9 = icmp ne i32 %t8, 0
  br i1 %t9, label %then6, label %ifend8
then6:
  store ptr @.str761, ptr %retval
  br label %ret
ifend8:
  %t10 = load ptr, ptr %t0
  %t11 = call i32 @fn_str_eq(ptr %t10, ptr @.str762)
  %t12 = icmp ne i32 %t11, 0
  br i1 %t12, label %then9, label %ifend11
then9:
  store ptr @.str763, ptr %retval
  br label %ret
ifend11:
  %t13 = load ptr, ptr %t0
  %t14 = call i32 @fn_str_eq(ptr %t13, ptr @.str764)
  %t15 = icmp ne i32 %t14, 0
  br i1 %t15, label %then12, label %ifend14
then12:
  store ptr @.str765, ptr %retval
  br label %ret
ifend14:
  %t16 = load ptr, ptr %t0
  %t17 = call i32 @fn_str_eq(ptr %t16, ptr @.str766)
  %t18 = icmp ne i32 %t17, 0
  br i1 %t18, label %then15, label %ifend17
then15:
  store ptr @.str767, ptr %retval
  br label %ret
ifend17:
  %t19 = load ptr, ptr %t0
  %t20 = call i32 @fn_str_eq(ptr %t19, ptr @.str768)
  %t21 = icmp ne i32 %t20, 0
  br i1 %t21, label %then18, label %ifend20
then18:
  store ptr @.str769, ptr %retval
  br label %ret
ifend20:
  %t22 = load ptr, ptr %t0
  %t23 = call i32 @fn_str_eq(ptr %t22, ptr @.str770)
  %t24 = icmp ne i32 %t23, 0
  br i1 %t24, label %then21, label %ifend23
then21:
  store ptr @.str771, ptr %retval
  br label %ret
ifend23:
  %t25 = load ptr, ptr %t0
  %t26 = call i32 @fn_str_eq(ptr %t25, ptr @.str772)
  %t27 = icmp ne i32 %t26, 0
  br i1 %t27, label %then24, label %ifend26
then24:
  store ptr @.str773, ptr %retval
  br label %ret
ifend26:
  store ptr @.str774, ptr %retval
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
  %t4 = call i32 @fn_str_eq(ptr %t3, ptr @.str775)
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
  %t12 = call ptr @fn_str_concat(ptr @.str776, ptr %t11)
  %t13 = call ptr @fn_str_concat(ptr %t12, ptr @.str777)
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
  %t4 = call i32 @fn_str_eq(ptr %t3, ptr @.str778)
  %t5 = icmp ne i32 %t4, 0
  br i1 %t5, label %then0, label %ifend2
then0:
  %t6 = load ptr, ptr %t1
  %t7 = getelementptr inbounds %Cmp_Val, ptr %t6, i32 0, i32 0
  %t8 = load ptr, ptr %t7
  %t9 = call ptr @fn_str_concat(ptr @.str779, ptr %t8)
  %t10 = call ptr @fn_str_concat(ptr %t9, ptr @.str780)
  %t11 = load ptr, ptr %t2
  %t12 = getelementptr inbounds %Cmp_Val, ptr %t11, i32 0, i32 0
  %t13 = load ptr, ptr %t12
  %t14 = call ptr @fn_str_concat(ptr %t10, ptr %t13)
  %t15 = call ptr @fn_str_concat(ptr %t14, ptr @.str781)
  %t16 = call ptr @fn_emit_bind(ptr %t15)
  %t17 = call ptr @fn_val(ptr %t16, ptr @.str782)
  store ptr %t17, ptr %retval
  br label %ret
ifend2:
  %t18 = load ptr, ptr %t1
  %t19 = getelementptr inbounds %Cmp_Val, ptr %t18, i32 0, i32 0
  %t20 = load ptr, ptr %t19
  %t21 = call ptr @fn_str_concat(ptr @.str783, ptr %t20)
  %t22 = call ptr @fn_str_concat(ptr %t21, ptr @.str784)
  %t23 = load ptr, ptr %t2
  %t24 = getelementptr inbounds %Cmp_Val, ptr %t23, i32 0, i32 0
  %t25 = load ptr, ptr %t24
  %t26 = call ptr @fn_str_concat(ptr %t22, ptr %t25)
  %t27 = call ptr @fn_str_concat(ptr %t26, ptr @.str785)
  %t28 = call ptr @fn_emit_bind(ptr %t27)
  store ptr %t28, ptr %t29
  %t30 = load ptr, ptr %t0
  %t31 = call i32 @fn_str_eq(ptr %t30, ptr @.str786)
  %t32 = icmp ne i32 %t31, 0
  br i1 %t32, label %then3, label %ifend5
then3:
  %t33 = load ptr, ptr %t29
  %t34 = call ptr @fn_str_concat(ptr @.str787, ptr %t33)
  %t35 = call ptr @fn_str_concat(ptr %t34, ptr @.str788)
  %t36 = call ptr @fn_emit_bind(ptr %t35)
  store ptr %t36, ptr %t37
  %t38 = load ptr, ptr %t37
  %t39 = call ptr @fn_str_concat(ptr @.str789, ptr %t38)
  %t40 = call ptr @fn_str_concat(ptr %t39, ptr @.str790)
  %t41 = call ptr @fn_emit_bind(ptr %t40)
  %t42 = call ptr @fn_val(ptr %t41, ptr @.str791)
  store ptr %t42, ptr %retval
  br label %ret
ifend5:
  %t43 = load ptr, ptr %t29
  %t44 = call ptr @fn_val(ptr %t43, ptr @.str792)
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
  %t5 = call i32 @fn_str_eq(ptr %t4, ptr @.str793)
  %t6 = icmp ne i32 %t5, 0
  %t7 = zext i1 %t6 to i32
  store i32 %t7, ptr %t1
  br i1 %t6, label %scend1, label %sc0
sc0:
  %t8 = load ptr, ptr %t0
  %t9 = getelementptr inbounds %Cmp_Node, ptr %t8, i32 0, i32 1
  %t10 = load ptr, ptr %t9
  %t11 = call i32 @fn_str_eq(ptr %t10, ptr @.str794)
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
  %t33 = call i32 @fn_str_eq(ptr %t32, ptr @.str795)
  %t34 = icmp ne i32 %t33, 0
  %t35 = zext i1 %t34 to i32
  store i32 %t35, ptr %t28
  br i1 %t34, label %scend6, label %sc5
sc5:
  %t36 = load ptr, ptr %t27
  %t37 = getelementptr inbounds %Cmp_Val, ptr %t36, i32 0, i32 1
  %t38 = load ptr, ptr %t37
  %t39 = call ptr @fn_llty(ptr %t38)
  %t40 = call i32 @fn_str_eq(ptr %t39, ptr @.str796)
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
  %t71 = call i32 @fn_str_eq(ptr %t70, ptr @.str797)
  %t72 = icmp ne i32 %t71, 0
  br i1 %t72, label %then12, label %ifend14
then12:
  %t73 = load ptr, ptr %t22
  %t74 = load ptr, ptr %t27
  %t75 = call ptr @fn_emit_str_op(ptr @.str798, ptr %t73, ptr %t74)
  store ptr %t75, ptr %retval
  br label %ret
ifend14:
  %t78 = load ptr, ptr %t0
  %t79 = getelementptr inbounds %Cmp_Node, ptr %t78, i32 0, i32 1
  %t80 = load ptr, ptr %t79
  %t81 = call i32 @fn_str_eq(ptr %t80, ptr @.str799)
  %t82 = icmp ne i32 %t81, 0
  %t83 = zext i1 %t82 to i32
  store i32 %t83, ptr %t77
  br i1 %t82, label %scend16, label %sc15
sc15:
  %t84 = load ptr, ptr %t0
  %t85 = getelementptr inbounds %Cmp_Node, ptr %t84, i32 0, i32 1
  %t86 = load ptr, ptr %t85
  %t87 = call i32 @fn_str_eq(ptr %t86, ptr @.str800)
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
  %t110 = call i32 @fn_str_eq(ptr %t109, ptr @.str801)
  %t111 = icmp ne i32 %t110, 0
  %t112 = zext i1 %t111 to i32
  store i32 %t112, ptr %t106
  br i1 %t111, label %scend23, label %sc22
sc22:
  %t113 = load ptr, ptr %t27
  %t114 = getelementptr inbounds %Cmp_Val, ptr %t113, i32 0, i32 1
  %t115 = load ptr, ptr %t114
  %t116 = call i32 @fn_str_eq(ptr %t115, ptr @.str802)
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
  store ptr @.str803, ptr %t134
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
  %t146 = call i32 @fn_str_eq(ptr %t145, ptr @.str804)
  %t147 = icmp ne i32 %t146, 0
  %t148 = zext i1 %t147 to i32
  store i32 %t148, ptr %t141
  br i1 %t147, label %scend31, label %sc30
sc30:
  %t149 = load ptr, ptr %t27
  %t150 = getelementptr inbounds %Cmp_Val, ptr %t149, i32 0, i32 1
  %t151 = load ptr, ptr %t150
  %t152 = call ptr @fn_llty(ptr %t151)
  %t153 = call i32 @fn_str_eq(ptr %t152, ptr @.str805)
  %t154 = icmp ne i32 %t153, 0
  %t155 = zext i1 %t154 to i32
  store i32 %t155, ptr %t141
  br label %scend31
scend31:
  %t156 = load i32, ptr %t141
  %t157 = icmp ne i32 %t156, 0
  br i1 %t157, label %then32, label %ifend34
then32:
  store ptr @.str806, ptr %t134
  br label %ifend34
ifend34:
  br label %ifend29
ifend29:
  %t158 = load ptr, ptr %t0
  %t159 = getelementptr inbounds %Cmp_Node, ptr %t158, i32 0, i32 1
  %t160 = load ptr, ptr %t159
  %t161 = call ptr @fn_cmp_code(ptr %t160)
  %t162 = call ptr @fn_str_concat(ptr @.str807, ptr %t161)
  %t163 = call ptr @fn_str_concat(ptr %t162, ptr @.str808)
  %t164 = load ptr, ptr %t134
  %t165 = call ptr @fn_str_concat(ptr %t163, ptr %t164)
  %t166 = call ptr @fn_str_concat(ptr %t165, ptr @.str809)
  %t167 = load ptr, ptr %t129
  %t168 = call ptr @fn_str_concat(ptr %t166, ptr %t167)
  %t169 = call ptr @fn_str_concat(ptr %t168, ptr @.str810)
  %t170 = load ptr, ptr %t133
  %t171 = call ptr @fn_str_concat(ptr %t169, ptr %t170)
  %t172 = call ptr @fn_emit_bind(ptr %t171)
  store ptr %t172, ptr %t173
  %t174 = load ptr, ptr %t173
  %t175 = call ptr @fn_str_concat(ptr @.str811, ptr %t174)
  %t176 = call ptr @fn_str_concat(ptr %t175, ptr @.str812)
  %t177 = call ptr @fn_emit_bind(ptr %t176)
  %t178 = call ptr @fn_val(ptr %t177, ptr @.str813)
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
  %t190 = call i32 @fn_str_eq(ptr %t189, ptr @.str814)
  %t191 = icmp ne i32 %t190, 0
  br i1 %t191, label %then38, label %ifend40
then38:
  %t192 = load ptr, ptr %t183
  %t193 = call ptr @fn_str_concat(ptr @.str815, ptr %t192)
  %t194 = call ptr @fn_str_concat(ptr %t193, ptr @.str816)
  %t195 = call ptr @fn_emit_bind(ptr %t194)
  store ptr %t195, ptr %t196
  %t197 = load ptr, ptr %t186
  %t198 = call ptr @fn_str_concat(ptr @.str817, ptr %t197)
  %t199 = call ptr @fn_str_concat(ptr %t198, ptr @.str818)
  %t200 = call ptr @fn_emit_bind(ptr %t199)
  store ptr %t200, ptr %t201
  %t202 = load ptr, ptr %t196
  %t203 = call ptr @fn_str_concat(ptr @.str819, ptr %t202)
  %t204 = call ptr @fn_str_concat(ptr %t203, ptr @.str820)
  %t205 = load ptr, ptr %t201
  %t206 = call ptr @fn_str_concat(ptr %t204, ptr %t205)
  %t207 = call ptr @fn_emit_bind(ptr %t206)
  store ptr %t207, ptr %t208
  %t209 = load ptr, ptr %t208
  %t210 = call ptr @fn_str_concat(ptr @.str821, ptr %t209)
  %t211 = call ptr @fn_str_concat(ptr %t210, ptr @.str822)
  %t212 = call ptr @fn_emit_bind(ptr %t211)
  store ptr %t212, ptr %t213
  %t214 = load ptr, ptr %t213
  %t215 = call ptr @fn_str_concat(ptr @.str823, ptr %t214)
  %t216 = call ptr @fn_str_concat(ptr %t215, ptr @.str824)
  %t217 = call ptr @fn_emit_bind(ptr %t216)
  %t218 = call ptr @fn_val(ptr %t217, ptr @.str825)
  store ptr %t218, ptr %retval
  br label %ret
ifend40:
  %t219 = load ptr, ptr %t0
  %t220 = getelementptr inbounds %Cmp_Node, ptr %t219, i32 0, i32 1
  %t221 = load ptr, ptr %t220
  %t222 = call i32 @fn_str_eq(ptr %t221, ptr @.str826)
  %t223 = icmp ne i32 %t222, 0
  br i1 %t223, label %then41, label %ifend43
then41:
  %t224 = load ptr, ptr %t183
  %t225 = call ptr @fn_str_concat(ptr @.str827, ptr %t224)
  %t226 = call ptr @fn_str_concat(ptr %t225, ptr @.str828)
  %t227 = call ptr @fn_emit_bind(ptr %t226)
  store ptr %t227, ptr %t228
  %t229 = load ptr, ptr %t228
  %t230 = call ptr @fn_str_concat(ptr @.str829, ptr %t229)
  %t231 = call ptr @fn_str_concat(ptr %t230, ptr @.str830)
  %t232 = call ptr @fn_emit_bind(ptr %t231)
  store ptr %t232, ptr %t233
  %t234 = load ptr, ptr %t186
  %t235 = call ptr @fn_str_concat(ptr @.str831, ptr %t234)
  %t236 = call ptr @fn_str_concat(ptr %t235, ptr @.str832)
  %t237 = call ptr @fn_emit_bind(ptr %t236)
  store ptr %t237, ptr %t238
  %t239 = load ptr, ptr %t233
  %t240 = call ptr @fn_str_concat(ptr @.str833, ptr %t239)
  %t241 = call ptr @fn_str_concat(ptr %t240, ptr @.str834)
  %t242 = load ptr, ptr %t238
  %t243 = call ptr @fn_str_concat(ptr %t241, ptr %t242)
  %t244 = call ptr @fn_emit_bind(ptr %t243)
  store ptr %t244, ptr %t245
  %t246 = load ptr, ptr %t245
  %t247 = call ptr @fn_str_concat(ptr @.str835, ptr %t246)
  %t248 = call ptr @fn_str_concat(ptr %t247, ptr @.str836)
  %t249 = call ptr @fn_emit_bind(ptr %t248)
  %t250 = call ptr @fn_val(ptr %t249, ptr @.str837)
  store ptr %t250, ptr %retval
  br label %ret
ifend43:
  %t251 = load ptr, ptr %t0
  %t252 = getelementptr inbounds %Cmp_Node, ptr %t251, i32 0, i32 1
  %t253 = load ptr, ptr %t252
  %t254 = call ptr @fn_arith_code(ptr %t253)
  %t255 = call ptr @fn_str_concat(ptr %t254, ptr @.str838)
  %t256 = load ptr, ptr %t183
  %t257 = call ptr @fn_str_concat(ptr %t255, ptr %t256)
  %t258 = call ptr @fn_str_concat(ptr %t257, ptr @.str839)
  %t259 = load ptr, ptr %t186
  %t260 = call ptr @fn_str_concat(ptr %t258, ptr %t259)
  %t261 = call ptr @fn_emit_bind(ptr %t260)
  store ptr %t261, ptr %t262
  %t263 = load ptr, ptr %t262
  %t264 = call ptr @fn_val(ptr %t263, ptr @.str840)
  store ptr %t264, ptr %retval
  br label %ret
ifend37:
  %t265 = load ptr, ptr %t0
  %t266 = getelementptr inbounds %Cmp_Node, ptr %t265, i32 0, i32 1
  %t267 = load ptr, ptr %t266
  %t268 = call ptr @fn_arith_code(ptr %t267)
  %t269 = call ptr @fn_str_concat(ptr %t268, ptr @.str841)
  %t270 = load ptr, ptr %t22
  %t271 = getelementptr inbounds %Cmp_Val, ptr %t270, i32 0, i32 0
  %t272 = load ptr, ptr %t271
  %t273 = call ptr @fn_str_concat(ptr %t269, ptr %t272)
  %t274 = call ptr @fn_str_concat(ptr %t273, ptr @.str842)
  %t275 = load ptr, ptr %t27
  %t276 = getelementptr inbounds %Cmp_Val, ptr %t275, i32 0, i32 0
  %t277 = load ptr, ptr %t276
  %t278 = call ptr @fn_str_concat(ptr %t274, ptr %t277)
  %t279 = call ptr @fn_emit_bind(ptr %t278)
  store ptr %t279, ptr %t280
  %t281 = load ptr, ptr %t280
  %t282 = call ptr @fn_val(ptr %t281, ptr @.str843)
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
  %t94 = alloca ptr
  %t123 = alloca ptr
  %t130 = alloca ptr
  %t147 = alloca ptr
  %t154 = alloca ptr
  %t159 = alloca ptr
  %t176 = alloca ptr
  %t195 = alloca ptr
  %t223 = alloca ptr
  %t225 = alloca ptr
  %t232 = alloca ptr
  %t248 = alloca ptr
  %t255 = alloca ptr
  %t256 = alloca i32
  %t275 = alloca ptr
  %t326 = alloca ptr
  %t327 = alloca ptr
  store ptr %arg_e, ptr %t0
  %t1 = load ptr, ptr %t0
  %t2 = getelementptr inbounds %Cmp_Node, ptr %t1, i32 0, i32 4
  %t3 = load ptr, ptr %t2
  %t4 = getelementptr inbounds %Cmp_Node, ptr %t3, i32 0, i32 1
  %t5 = load ptr, ptr %t4
  store ptr %t5, ptr %t6
  %t7 = load ptr, ptr %t6
  %t8 = call i32 @fn_str_eq(ptr %t7, ptr @.str844)
  %t9 = icmp ne i32 %t8, 0
  br i1 %t9, label %then0, label %ifend2
then0:
  %t10 = load i32, ptr @g_nself
  %t11 = icmp eq i32 %t10, 0
  %t12 = zext i1 %t11 to i32
  %t13 = icmp ne i32 %t12, 0
  br i1 %t13, label %then3, label %ifend5
then3:
  %t14 = call ptr @fn_val(ptr @.str845, ptr @.str846)
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
  %t22 = call ptr @fn_str_concat(ptr @.str847, ptr %t21)
  %t23 = call ptr @fn_emit_bind(ptr %t22)
  %t24 = call ptr @fn_val(ptr %t23, ptr @.str848)
  store ptr %t24, ptr %retval
  br label %ret
ifend2:
  %t25 = load ptr, ptr %t6
  %t26 = call i32 @fn_str_eq(ptr %t25, ptr @.str849)
  %t27 = icmp ne i32 %t26, 0
  br i1 %t27, label %then6, label %ifend8
then6:
  %t28 = call ptr @fn_emit_bind(ptr @.str850)
  %t29 = call ptr @fn_val(ptr %t28, ptr @.str851)
  store ptr %t29, ptr %retval
  br label %ret
ifend8:
  %t30 = load ptr, ptr %t6
  %t31 = call i32 @fn_str_eq(ptr %t30, ptr @.str852)
  %t32 = icmp ne i32 %t31, 0
  br i1 %t32, label %then9, label %ifend11
then9:
  call void @fn_emit(ptr @.str853)
  %t33 = call ptr @fn_val(ptr @.str854, ptr @.str855)
  store ptr %t33, ptr %retval
  br label %ret
ifend11:
  %t34 = load ptr, ptr %t6
  %t35 = call i32 @fn_str_eq(ptr %t34, ptr @.str856)
  %t36 = icmp ne i32 %t35, 0
  br i1 %t36, label %then12, label %ifend14
then12:
  call void @fn_emit(ptr @.str857)
  %t37 = call ptr @fn_val(ptr @.str858, ptr @.str859)
  store ptr %t37, ptr %retval
  br label %ret
ifend14:
  %t38 = load ptr, ptr %t6
  %t39 = call i32 @fn_str_eq(ptr %t38, ptr @.str860)
  %t40 = icmp ne i32 %t39, 0
  br i1 %t40, label %then15, label %ifend17
then15:
  %t41 = call ptr @fn_emit_bind(ptr @.str861)
  %t42 = call ptr @fn_val(ptr %t41, ptr @.str862)
  store ptr %t42, ptr %retval
  br label %ret
ifend17:
  %t43 = load ptr, ptr %t6
  %t44 = call i32 @fn_str_eq(ptr %t43, ptr @.str863)
  %t45 = icmp ne i32 %t44, 0
  br i1 %t45, label %then18, label %ifend20
then18:
  call void @fn_emit(ptr @.str864)
  %t46 = call ptr @fn_val(ptr @.str865, ptr @.str866)
  store ptr %t46, ptr %retval
  br label %ret
ifend20:
  %t47 = load ptr, ptr %t6
  %t48 = call i32 @fn_str_eq(ptr %t47, ptr @.str867)
  %t49 = icmp ne i32 %t48, 0
  br i1 %t49, label %then21, label %ifend23
then21:
  %t50 = load ptr, ptr %t0
  %t51 = call ptr @fn_emit_len(ptr %t50)
  store ptr %t51, ptr %retval
  br label %ret
ifend23:
  %t52 = load ptr, ptr %t6
  %t53 = call i32 @fn_str_eq(ptr %t52, ptr @.str868)
  %t54 = icmp ne i32 %t53, 0
  br i1 %t54, label %then24, label %ifend26
then24:
  %t55 = load ptr, ptr %t0
  %t56 = call ptr @fn_emit_push(ptr %t55)
  store ptr %t56, ptr %retval
  br label %ret
ifend26:
  %t57 = load ptr, ptr %t6
  %t58 = call i32 @fn_str_eq(ptr %t57, ptr @.str869)
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
  %t70 = getelementptr inbounds %Cmp_Val, ptr %t69, i32 0, i32 1
  %t71 = load ptr, ptr %t70
  %t72 = call ptr @fn_llty(ptr %t71)
  %t73 = call i32 @fn_str_eq(ptr %t72, ptr @.str870)
  %t74 = icmp ne i32 %t73, 0
  br i1 %t74, label %then30, label %ifend32
then30:
  %t75 = load ptr, ptr %t68
  store ptr %t75, ptr %retval
  br label %ret
ifend32:
  store i32 1, ptr @g_g_uses_intstr
  %t76 = load ptr, ptr %t68
  %t77 = getelementptr inbounds %Cmp_Val, ptr %t76, i32 0, i32 0
  %t78 = load ptr, ptr %t77
  %t79 = call ptr @fn_str_concat(ptr @.str871, ptr %t78)
  %t80 = call ptr @fn_str_concat(ptr %t79, ptr @.str872)
  %t81 = call ptr @fn_emit_bind(ptr %t80)
  %t82 = call ptr @fn_val(ptr %t81, ptr @.str873)
  store ptr %t82, ptr %retval
  br label %ret
ifend29:
  %t83 = load ptr, ptr %t6
  %t84 = call i32 @fn_str_eq(ptr %t83, ptr @.str874)
  %t85 = icmp ne i32 %t84, 0
  br i1 %t85, label %then33, label %ifend35
then33:
  %t86 = load ptr, ptr %t0
  %t87 = getelementptr inbounds %Cmp_Node, ptr %t86, i32 0, i32 7
  %t88 = load ptr, ptr %t87
  %t89 = getelementptr inbounds %LSlice, ptr %t88, i32 0, i32 0
  %t90 = load ptr, ptr %t89
  %t91 = getelementptr inbounds ptr, ptr %t90, i32 0
  %t92 = load ptr, ptr %t91
  %t93 = call ptr @fn_emit_expr(ptr %t92)
  store ptr %t93, ptr %t94
  %t95 = load ptr, ptr %t94
  %t96 = getelementptr inbounds %Cmp_Val, ptr %t95, i32 0, i32 1
  %t97 = load ptr, ptr %t96
  %t98 = call ptr @fn_llty(ptr %t97)
  %t99 = call i32 @fn_str_eq(ptr %t98, ptr @.str875)
  %t100 = icmp ne i32 %t99, 0
  br i1 %t100, label %then36, label %else37
then36:
  %t101 = load ptr, ptr %t94
  %t102 = getelementptr inbounds %Cmp_Val, ptr %t101, i32 0, i32 0
  %t103 = load ptr, ptr %t102
  %t104 = call ptr @fn_str_concat(ptr %t103, ptr @.str877)
  %t105 = call ptr @fn_str_concat(ptr @.str876, ptr %t104)
  call void @fn_emit(ptr %t105)
  br label %ifend38
else37:
  %t106 = load ptr, ptr %t94
  %t107 = getelementptr inbounds %Cmp_Val, ptr %t106, i32 0, i32 0
  %t108 = load ptr, ptr %t107
  %t109 = call ptr @fn_str_concat(ptr %t108, ptr @.str879)
  %t110 = call ptr @fn_str_concat(ptr @.str878, ptr %t109)
  call void @fn_emit(ptr %t110)
  br label %ifend38
ifend38:
  %t111 = call ptr @fn_val(ptr @.str880, ptr @.str881)
  store ptr %t111, ptr %retval
  br label %ret
ifend35:
  %t112 = load ptr, ptr %t6
  %t113 = call i32 @fn_str_eq(ptr %t112, ptr @.str882)
  %t114 = icmp ne i32 %t113, 0
  br i1 %t114, label %then39, label %ifend41
then39:
  %t115 = load ptr, ptr %t0
  %t116 = getelementptr inbounds %Cmp_Node, ptr %t115, i32 0, i32 7
  %t117 = load ptr, ptr %t116
  %t118 = getelementptr inbounds %LSlice, ptr %t117, i32 0, i32 0
  %t119 = load ptr, ptr %t118
  %t120 = getelementptr inbounds ptr, ptr %t119, i32 0
  %t121 = load ptr, ptr %t120
  %t122 = call ptr @fn_emit_expr(ptr %t121)
  store ptr %t122, ptr %t123
  %t124 = load ptr, ptr %t123
  %t125 = getelementptr inbounds %Cmp_Val, ptr %t124, i32 0, i32 0
  %t126 = load ptr, ptr %t125
  %t127 = call ptr @fn_str_concat(ptr @.str883, ptr %t126)
  %t128 = call ptr @fn_str_concat(ptr %t127, ptr @.str884)
  %t129 = call ptr @fn_emit_bind(ptr %t128)
  store ptr %t129, ptr %t130
  %t131 = load ptr, ptr %t130
  %t132 = call ptr @fn_str_concat(ptr @.str885, ptr %t131)
  %t133 = call ptr @fn_str_concat(ptr %t132, ptr @.str886)
  %t134 = call ptr @fn_emit_bind(ptr %t133)
  %t135 = call ptr @fn_val(ptr %t134, ptr @.str887)
  store ptr %t135, ptr %retval
  br label %ret
ifend41:
  %t136 = load ptr, ptr %t6
  %t137 = call i32 @fn_str_eq(ptr %t136, ptr @.str888)
  %t138 = icmp ne i32 %t137, 0
  br i1 %t138, label %then42, label %ifend44
then42:
  %t139 = load ptr, ptr %t0
  %t140 = getelementptr inbounds %Cmp_Node, ptr %t139, i32 0, i32 7
  %t141 = load ptr, ptr %t140
  %t142 = getelementptr inbounds %LSlice, ptr %t141, i32 0, i32 0
  %t143 = load ptr, ptr %t142
  %t144 = getelementptr inbounds ptr, ptr %t143, i32 0
  %t145 = load ptr, ptr %t144
  %t146 = call ptr @fn_emit_expr(ptr %t145)
  store ptr %t146, ptr %t147
  %t148 = load ptr, ptr %t147
  %t149 = getelementptr inbounds %Cmp_Val, ptr %t148, i32 0, i32 0
  %t150 = load ptr, ptr %t149
  %t151 = call ptr @fn_str_concat(ptr @.str889, ptr %t150)
  %t152 = call ptr @fn_str_concat(ptr %t151, ptr @.str890)
  %t153 = call ptr @fn_emit_bind(ptr %t152)
  store ptr %t153, ptr %t154
  %t155 = load ptr, ptr %t154
  %t156 = call ptr @fn_str_concat(ptr @.str891, ptr %t155)
  %t157 = call ptr @fn_str_concat(ptr %t156, ptr @.str892)
  %t158 = call ptr @fn_emit_bind(ptr %t157)
  store ptr %t158, ptr %t159
  %t160 = load ptr, ptr %t159
  %t161 = call ptr @fn_str_concat(ptr @.str893, ptr %t160)
  %t162 = call ptr @fn_str_concat(ptr %t161, ptr @.str894)
  %t163 = call ptr @fn_emit_bind(ptr %t162)
  %t164 = call ptr @fn_val(ptr %t163, ptr @.str895)
  store ptr %t164, ptr %retval
  br label %ret
ifend44:
  %t165 = load ptr, ptr %t6
  %t166 = call i32 @fn_str_eq(ptr %t165, ptr @.str896)
  %t167 = icmp ne i32 %t166, 0
  br i1 %t167, label %then45, label %ifend47
then45:
  %t168 = load ptr, ptr %t0
  %t169 = getelementptr inbounds %Cmp_Node, ptr %t168, i32 0, i32 7
  %t170 = load ptr, ptr %t169
  %t171 = getelementptr inbounds %LSlice, ptr %t170, i32 0, i32 0
  %t172 = load ptr, ptr %t171
  %t173 = getelementptr inbounds ptr, ptr %t172, i32 0
  %t174 = load ptr, ptr %t173
  %t175 = call ptr @fn_emit_expr(ptr %t174)
  store ptr %t175, ptr %t176
  %t177 = load ptr, ptr %t176
  %t178 = getelementptr inbounds %Cmp_Val, ptr %t177, i32 0, i32 0
  %t179 = load ptr, ptr %t178
  %t180 = call ptr @fn_str_concat(ptr @.str897, ptr %t179)
  %t181 = call ptr @fn_str_concat(ptr %t180, ptr @.str898)
  %t182 = call ptr @fn_emit_bind(ptr %t181)
  %t183 = call ptr @fn_val(ptr %t182, ptr @.str899)
  store ptr %t183, ptr %retval
  br label %ret
ifend47:
  %t184 = load ptr, ptr %t6
  %t185 = call i32 @fn_str_eq(ptr %t184, ptr @.str900)
  %t186 = icmp ne i32 %t185, 0
  br i1 %t186, label %then48, label %ifend50
then48:
  %t187 = load ptr, ptr %t0
  %t188 = getelementptr inbounds %Cmp_Node, ptr %t187, i32 0, i32 7
  %t189 = load ptr, ptr %t188
  %t190 = getelementptr inbounds %LSlice, ptr %t189, i32 0, i32 0
  %t191 = load ptr, ptr %t190
  %t192 = getelementptr inbounds ptr, ptr %t191, i32 0
  %t193 = load ptr, ptr %t192
  %t194 = call ptr @fn_emit_expr(ptr %t193)
  store ptr %t194, ptr %t195
  %t196 = load ptr, ptr %t195
  %t197 = getelementptr inbounds %Cmp_Val, ptr %t196, i32 0, i32 0
  %t198 = load ptr, ptr %t197
  %t199 = call ptr @fn_str_concat(ptr @.str901, ptr %t198)
  %t200 = call ptr @fn_str_concat(ptr %t199, ptr @.str902)
  %t201 = call ptr @fn_emit_bind(ptr %t200)
  %t202 = call ptr @fn_val(ptr %t201, ptr @.str903)
  store ptr %t202, ptr %retval
  br label %ret
ifend50:
  %t203 = load ptr, ptr %t6
  %t204 = call i32 @fn_is_intrinsic(ptr %t203)
  %t205 = icmp ne i32 %t204, 0
  br i1 %t205, label %then51, label %ifend53
then51:
  %t206 = load ptr, ptr %t6
  %t207 = load ptr, ptr %t0
  %t208 = call ptr @fn_emit_intrinsic(ptr %t206, ptr %t207)
  store ptr %t208, ptr %retval
  br label %ret
ifend53:
  %t209 = load ptr, ptr %t6
  %t210 = call i32 @fn_is_intrinsic2(ptr %t209)
  %t211 = icmp ne i32 %t210, 0
  br i1 %t211, label %then54, label %ifend56
then54:
  %t212 = load ptr, ptr %t6
  %t213 = load ptr, ptr %t0
  %t214 = call ptr @fn_emit_intrinsic2(ptr %t212, ptr %t213)
  store ptr %t214, ptr %retval
  br label %ret
ifend56:
  %t215 = load ptr, ptr %t6
  %t216 = call i32 @fn_is_math_builtin(ptr %t215)
  %t217 = icmp ne i32 %t216, 0
  br i1 %t217, label %then57, label %ifend59
then57:
  %t218 = load ptr, ptr %t6
  %t219 = load ptr, ptr %t0
  %t220 = call ptr @fn_emit_math_builtin(ptr %t218, ptr %t219)
  store ptr %t220, ptr %retval
  br label %ret
ifend59:
  %t221 = load ptr, ptr %t6
  %t222 = call ptr @fn_find_fn(ptr %t221)
  store ptr %t222, ptr %t223
  %t224 = load ptr, ptr %t6
  store ptr %t224, ptr %t225
  %t226 = load ptr, ptr %t223
  %t227 = icmp eq ptr %t226, null
  %t228 = zext i1 %t227 to i32
  %t229 = icmp ne i32 %t228, 0
  br i1 %t229, label %then60, label %ifend62
then60:
  %t230 = load ptr, ptr %t6
  %t231 = call ptr @fn_str_concat(ptr @.str904, ptr %t230)
  store ptr %t231, ptr %t232
  %t233 = load ptr, ptr %t232
  %t234 = call ptr @fn_find_fn(ptr %t233)
  store ptr %t234, ptr %t223
  %t235 = load ptr, ptr %t223
  %t236 = icmp eq ptr %t235, null
  %t237 = zext i1 %t236 to i32
  %t238 = icmp ne i32 %t237, 0
  br i1 %t238, label %then63, label %ifend65
then63:
  %t239 = load ptr, ptr %t6
  %t240 = call ptr @fn_str_concat(ptr @.str905, ptr %t239)
  call void @fn_perr(ptr %t240)
  br label %ifend65
ifend65:
  %t241 = load ptr, ptr %t232
  store ptr %t241, ptr %t225
  br label %ifend62
ifend62:
  %t242 = getelementptr %LSlice, ptr null, i32 1
  %t243 = ptrtoint ptr %t242 to i64
  %t244 = call ptr @malloc(i64 %t243)
  %t245 = getelementptr inbounds %LSlice, ptr %t244, i32 0, i32 0
  store ptr null, ptr %t245
  %t246 = getelementptr inbounds %LSlice, ptr %t244, i32 0, i32 1
  store i32 0, ptr %t246
  %t247 = getelementptr inbounds %LSlice, ptr %t244, i32 0, i32 2
  store i32 0, ptr %t247
  store ptr %t244, ptr %t248
  %t249 = getelementptr %LSlice, ptr null, i32 1
  %t250 = ptrtoint ptr %t249 to i64
  %t251 = call ptr @malloc(i64 %t250)
  %t252 = getelementptr inbounds %LSlice, ptr %t251, i32 0, i32 0
  store ptr null, ptr %t252
  %t253 = getelementptr inbounds %LSlice, ptr %t251, i32 0, i32 1
  store i32 0, ptr %t253
  %t254 = getelementptr inbounds %LSlice, ptr %t251, i32 0, i32 2
  store i32 0, ptr %t254
  store ptr %t251, ptr %t255
  store i32 0, ptr %t256
  br label %wcond66
wcond66:
  %t257 = load i32, ptr %t256
  %t258 = load ptr, ptr %t0
  %t259 = getelementptr inbounds %Cmp_Node, ptr %t258, i32 0, i32 7
  %t260 = load ptr, ptr %t259
  %t261 = getelementptr inbounds %LSlice, ptr %t260, i32 0, i32 1
  %t262 = load i32, ptr %t261
  %t263 = icmp slt i32 %t257, %t262
  %t264 = zext i1 %t263 to i32
  %t265 = icmp ne i32 %t264, 0
  br i1 %t265, label %wbody67, label %wend68
wbody67:
  %t266 = load ptr, ptr %t0
  %t267 = getelementptr inbounds %Cmp_Node, ptr %t266, i32 0, i32 7
  %t268 = load ptr, ptr %t267
  %t269 = getelementptr inbounds %LSlice, ptr %t268, i32 0, i32 0
  %t270 = load ptr, ptr %t269
  %t271 = load i32, ptr %t256
  %t272 = getelementptr inbounds ptr, ptr %t270, i32 %t271
  %t273 = load ptr, ptr %t272
  %t274 = call ptr @fn_emit_expr(ptr %t273)
  store ptr %t274, ptr %t275
  %t276 = load ptr, ptr %t248
  %t277 = getelementptr inbounds %LSlice, ptr %t276, i32 0, i32 1
  %t278 = getelementptr inbounds %LSlice, ptr %t276, i32 0, i32 2
  %t279 = getelementptr inbounds %LSlice, ptr %t276, i32 0, i32 0
  %t280 = load i32, ptr %t277
  %t281 = load i32, ptr %t278
  %t282 = icmp sge i32 %t280, %t281
  br i1 %t282, label %grow69, label %put70
grow69:
  %t283 = mul i32 %t281, 2
  %t284 = icmp eq i32 %t281, 0
  %t285 = select i1 %t284, i32 8, i32 %t283
  %t286 = getelementptr ptr, ptr null, i32 1
  %t287 = ptrtoint ptr %t286 to i64
  %t288 = zext i32 %t285 to i64
  %t289 = mul i64 %t288, %t287
  %t290 = load ptr, ptr %t279
  %t291 = call ptr @realloc(ptr %t290, i64 %t289)
  store ptr %t291, ptr %t279
  store i32 %t285, ptr %t278
  br label %put70
put70:
  %t292 = load ptr, ptr %t275
  %t293 = getelementptr inbounds %Cmp_Val, ptr %t292, i32 0, i32 0
  %t294 = load ptr, ptr %t293
  %t295 = load ptr, ptr %t279
  %t296 = getelementptr inbounds ptr, ptr %t295, i32 %t280
  store ptr %t294, ptr %t296
  %t297 = add i32 %t280, 1
  store i32 %t297, ptr %t277
  %t298 = load ptr, ptr %t255
  %t299 = getelementptr inbounds %LSlice, ptr %t298, i32 0, i32 1
  %t300 = getelementptr inbounds %LSlice, ptr %t298, i32 0, i32 2
  %t301 = getelementptr inbounds %LSlice, ptr %t298, i32 0, i32 0
  %t302 = load i32, ptr %t299
  %t303 = load i32, ptr %t300
  %t304 = icmp sge i32 %t302, %t303
  br i1 %t304, label %grow71, label %put72
grow71:
  %t305 = mul i32 %t303, 2
  %t306 = icmp eq i32 %t303, 0
  %t307 = select i1 %t306, i32 8, i32 %t305
  %t308 = getelementptr ptr, ptr null, i32 1
  %t309 = ptrtoint ptr %t308 to i64
  %t310 = zext i32 %t307 to i64
  %t311 = mul i64 %t310, %t309
  %t312 = load ptr, ptr %t301
  %t313 = call ptr @realloc(ptr %t312, i64 %t311)
  store ptr %t313, ptr %t301
  store i32 %t307, ptr %t300
  br label %put72
put72:
  %t314 = load ptr, ptr %t275
  %t315 = getelementptr inbounds %Cmp_Val, ptr %t314, i32 0, i32 1
  %t316 = load ptr, ptr %t315
  %t317 = load ptr, ptr %t301
  %t318 = getelementptr inbounds ptr, ptr %t317, i32 %t302
  store ptr %t316, ptr %t318
  %t319 = add i32 %t302, 1
  store i32 %t319, ptr %t299
  %t320 = load i32, ptr %t256
  %t321 = add i32 %t320, 1
  store i32 %t321, ptr %t256
  br label %wcond66
wend68:
  %t322 = load ptr, ptr %t223
  %t323 = getelementptr inbounds %Cmp_Node, ptr %t322, i32 0, i32 3
  %t324 = load ptr, ptr %t323
  %t325 = call ptr @fn_llty(ptr %t324)
  store ptr %t325, ptr %t326
  call void @fn_emit(ptr @.str906)
  store ptr @.str907, ptr %t327
  %t328 = load ptr, ptr %t326
  %t329 = call i32 @fn_str_eq(ptr %t328, ptr @.str908)
  %t330 = icmp eq i32 %t329, 0
  %t331 = zext i1 %t330 to i32
  %t332 = icmp ne i32 %t331, 0
  br i1 %t332, label %then73, label %ifend75
then73:
  %t333 = call ptr @fn_nreg()
  store ptr %t333, ptr %t327
  %t334 = load ptr, ptr %t327
  call void @fn_emit(ptr %t334)
  call void @fn_emit(ptr @.str909)
  br label %ifend75
ifend75:
  call void @fn_emit(ptr @.str910)
  %t335 = load ptr, ptr %t326
  call void @fn_emit(ptr %t335)
  call void @fn_emit(ptr @.str911)
  %t336 = load ptr, ptr %t225
  call void @fn_emit(ptr %t336)
  call void @fn_emit(ptr @.str912)
  store i32 0, ptr %t256
  br label %wcond76
wcond76:
  %t337 = load i32, ptr %t256
  %t338 = load ptr, ptr %t248
  %t339 = getelementptr inbounds %LSlice, ptr %t338, i32 0, i32 1
  %t340 = load i32, ptr %t339
  %t341 = icmp slt i32 %t337, %t340
  %t342 = zext i1 %t341 to i32
  %t343 = icmp ne i32 %t342, 0
  br i1 %t343, label %wbody77, label %wend78
wbody77:
  %t344 = load i32, ptr %t256
  %t345 = icmp sgt i32 %t344, 0
  %t346 = zext i1 %t345 to i32
  %t347 = icmp ne i32 %t346, 0
  br i1 %t347, label %then79, label %ifend81
then79:
  call void @fn_emit(ptr @.str913)
  br label %ifend81
ifend81:
  %t348 = load ptr, ptr %t255
  %t349 = getelementptr inbounds %LSlice, ptr %t348, i32 0, i32 0
  %t350 = load ptr, ptr %t349
  %t351 = load i32, ptr %t256
  %t352 = getelementptr inbounds ptr, ptr %t350, i32 %t351
  %t353 = load ptr, ptr %t352
  %t354 = call ptr @fn_llty(ptr %t353)
  call void @fn_emit(ptr %t354)
  call void @fn_emit(ptr @.str914)
  %t355 = load ptr, ptr %t248
  %t356 = getelementptr inbounds %LSlice, ptr %t355, i32 0, i32 0
  %t357 = load ptr, ptr %t356
  %t358 = load i32, ptr %t256
  %t359 = getelementptr inbounds ptr, ptr %t357, i32 %t358
  %t360 = load ptr, ptr %t359
  call void @fn_emit(ptr %t360)
  %t361 = load i32, ptr %t256
  %t362 = add i32 %t361, 1
  store i32 %t362, ptr %t256
  br label %wcond76
wend78:
  call void @fn_emit(ptr @.str915)
  %t363 = load ptr, ptr %t327
  %t364 = load ptr, ptr %t223
  %t365 = getelementptr inbounds %Cmp_Node, ptr %t364, i32 0, i32 3
  %t366 = load ptr, ptr %t365
  %t367 = call ptr @fn_val(ptr %t363, ptr %t366)
  store ptr %t367, ptr %retval
  br label %ret
ret:
  %t368 = load ptr, ptr %retval
  ret ptr %t368
}

define ptr @fn_emit_expr(ptr %arg_e) {
entry:
  %retval = alloca ptr
  %t0 = alloca ptr
  %t56 = alloca ptr
  %t61 = alloca ptr
  %t66 = alloca ptr
  %t124 = alloca i32
  %t146 = alloca ptr
  %t175 = alloca ptr
  %t219 = alloca i32
  %t231 = alloca ptr
  %t241 = alloca ptr
  %t254 = alloca ptr
  %t266 = alloca ptr
  %t273 = alloca ptr
  %t308 = alloca ptr
  %t338 = alloca ptr
  store ptr %arg_e, ptr %t0
  %t1 = load ptr, ptr %t0
  %t2 = icmp eq ptr %t1, null
  %t3 = zext i1 %t2 to i32
  %t4 = icmp ne i32 %t3, 0
  br i1 %t4, label %then0, label %ifend2
then0:
  %t5 = call ptr @fn_val(ptr @.str916, ptr @.str917)
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
  %t16 = call ptr @fn_val(ptr %t15, ptr @.str918)
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
  %t27 = call ptr @fn_val(ptr %t26, ptr @.str919)
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
  %t38 = call ptr @fn_val(ptr %t37, ptr @.str920)
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
  %t45 = call ptr @fn_val(ptr @.str921, ptr @.str922)
  store ptr %t45, ptr %retval
  br label %ret
ifend14:
  %t46 = load ptr, ptr %t0
  %t47 = getelementptr inbounds %Cmp_Node, ptr %t46, i32 0, i32 0
  %t48 = load i32, ptr %t47
  %t49 = icmp eq i32 %t48, 44
  %t50 = zext i1 %t49 to i32
  %t51 = icmp ne i32 %t50, 0
  br i1 %t51, label %then15, label %ifend17
then15:
  %t52 = load ptr, ptr %t0
  %t53 = getelementptr inbounds %Cmp_Node, ptr %t52, i32 0, i32 4
  %t54 = load ptr, ptr %t53
  %t55 = call ptr @fn_emit_expr(ptr %t54)
  store ptr %t55, ptr %t56
  %t57 = load ptr, ptr %t0
  %t58 = getelementptr inbounds %Cmp_Node, ptr %t57, i32 0, i32 5
  %t59 = load ptr, ptr %t58
  %t60 = call ptr @fn_emit_expr(ptr %t59)
  store ptr %t60, ptr %t61
  %t62 = load ptr, ptr %t0
  %t63 = getelementptr inbounds %Cmp_Node, ptr %t62, i32 0, i32 6
  %t64 = load ptr, ptr %t63
  %t65 = call ptr @fn_emit_expr(ptr %t64)
  store ptr %t65, ptr %t66
  store i32 1, ptr @g_g_uses_strslice
  %t67 = load ptr, ptr %t56
  %t68 = getelementptr inbounds %Cmp_Val, ptr %t67, i32 0, i32 0
  %t69 = load ptr, ptr %t68
  %t70 = call ptr @fn_str_concat(ptr @.str923, ptr %t69)
  %t71 = call ptr @fn_str_concat(ptr %t70, ptr @.str924)
  %t72 = load ptr, ptr %t61
  %t73 = getelementptr inbounds %Cmp_Val, ptr %t72, i32 0, i32 0
  %t74 = load ptr, ptr %t73
  %t75 = call ptr @fn_str_concat(ptr %t71, ptr %t74)
  %t76 = call ptr @fn_str_concat(ptr %t75, ptr @.str925)
  %t77 = load ptr, ptr %t66
  %t78 = getelementptr inbounds %Cmp_Val, ptr %t77, i32 0, i32 0
  %t79 = load ptr, ptr %t78
  %t80 = call ptr @fn_str_concat(ptr %t76, ptr %t79)
  %t81 = call ptr @fn_str_concat(ptr %t80, ptr @.str926)
  %t82 = call ptr @fn_emit_bind(ptr %t81)
  %t83 = call ptr @fn_val(ptr %t82, ptr @.str927)
  store ptr %t83, ptr %retval
  br label %ret
ifend17:
  %t84 = load ptr, ptr %t0
  %t85 = getelementptr inbounds %Cmp_Node, ptr %t84, i32 0, i32 0
  %t86 = load i32, ptr %t85
  %t87 = icmp eq i32 %t86, 31
  %t88 = zext i1 %t87 to i32
  %t89 = icmp ne i32 %t88, 0
  br i1 %t89, label %then18, label %ifend20
then18:
  %t90 = load ptr, ptr %t0
  %t91 = getelementptr inbounds %Cmp_Node, ptr %t90, i32 0, i32 1
  %t92 = load ptr, ptr %t91
  %t93 = call ptr @fn_emit_str_const(ptr %t92)
  %t94 = call ptr @fn_val(ptr %t93, ptr @.str928)
  store ptr %t94, ptr %retval
  br label %ret
ifend20:
  %t95 = load ptr, ptr %t0
  %t96 = getelementptr inbounds %Cmp_Node, ptr %t95, i32 0, i32 0
  %t97 = load i32, ptr %t96
  %t98 = icmp eq i32 %t97, 39
  %t99 = zext i1 %t98 to i32
  %t100 = icmp ne i32 %t99, 0
  br i1 %t100, label %then21, label %ifend23
then21:
  %t101 = load ptr, ptr %t0
  %t102 = getelementptr inbounds %Cmp_Node, ptr %t101, i32 0, i32 1
  %t103 = load ptr, ptr %t102
  %t104 = call i32 @fn_is_slice_ty(ptr %t103)
  %t105 = icmp ne i32 %t104, 0
  br i1 %t105, label %then24, label %ifend26
then24:
  %t106 = load ptr, ptr %t0
  %t107 = getelementptr inbounds %Cmp_Node, ptr %t106, i32 0, i32 1
  %t108 = load ptr, ptr %t107
  %t109 = call ptr @fn_emit_new_slice(ptr %t108)
  store ptr %t109, ptr %retval
  br label %ret
ifend26:
  %t110 = load ptr, ptr %t0
  %t111 = getelementptr inbounds %Cmp_Node, ptr %t110, i32 0, i32 1
  %t112 = load ptr, ptr %t111
  %t113 = call ptr @fn_emit_new_struct(ptr %t112)
  store ptr %t113, ptr %retval
  br label %ret
ifend23:
  %t114 = load ptr, ptr %t0
  %t115 = getelementptr inbounds %Cmp_Node, ptr %t114, i32 0, i32 0
  %t116 = load i32, ptr %t115
  %t117 = icmp eq i32 %t116, 33
  %t118 = zext i1 %t117 to i32
  %t119 = icmp ne i32 %t118, 0
  br i1 %t119, label %then27, label %ifend29
then27:
  %t120 = load ptr, ptr %t0
  %t121 = getelementptr inbounds %Cmp_Node, ptr %t120, i32 0, i32 1
  %t122 = load ptr, ptr %t121
  %t123 = call i32 @fn_loc_find(ptr %t122)
  store i32 %t123, ptr %t124
  %t125 = load i32, ptr %t124
  %t126 = icmp sge i32 %t125, 0
  %t127 = zext i1 %t126 to i32
  %t128 = icmp ne i32 %t127, 0
  br i1 %t128, label %then30, label %ifend32
then30:
  %t129 = load ptr, ptr @g_loc_reg
  %t130 = getelementptr inbounds %LSlice, ptr %t129, i32 0, i32 0
  %t131 = load ptr, ptr %t130
  %t132 = load i32, ptr %t124
  %t133 = getelementptr inbounds ptr, ptr %t131, i32 %t132
  %t134 = load ptr, ptr %t133
  %t135 = load ptr, ptr @g_loc_ty
  %t136 = getelementptr inbounds %LSlice, ptr %t135, i32 0, i32 0
  %t137 = load ptr, ptr %t136
  %t138 = load i32, ptr %t124
  %t139 = getelementptr inbounds ptr, ptr %t137, i32 %t138
  %t140 = load ptr, ptr %t139
  %t141 = call ptr @fn_emit_load_at(ptr %t134, ptr %t140)
  store ptr %t141, ptr %retval
  br label %ret
ifend32:
  %t142 = load ptr, ptr %t0
  %t143 = getelementptr inbounds %Cmp_Node, ptr %t142, i32 0, i32 1
  %t144 = load ptr, ptr %t143
  %t145 = call ptr @fn_find_global(ptr %t144)
  store ptr %t145, ptr %t146
  %t147 = load ptr, ptr %t146
  %t148 = icmp ne ptr %t147, null
  %t149 = zext i1 %t148 to i32
  %t150 = icmp ne i32 %t149, 0
  br i1 %t150, label %then33, label %ifend35
then33:
  %t151 = load ptr, ptr %t146
  %t152 = getelementptr inbounds %Cmp_Node, ptr %t151, i32 0, i32 0
  %t153 = load i32, ptr %t152
  %t154 = icmp eq i32 %t153, 3
  %t155 = zext i1 %t154 to i32
  %t156 = icmp ne i32 %t155, 0
  br i1 %t156, label %then36, label %ifend38
then36:
  %t157 = load ptr, ptr %t146
  %t158 = getelementptr inbounds %Cmp_Node, ptr %t157, i32 0, i32 4
  %t159 = load ptr, ptr %t158
  %t160 = getelementptr inbounds %Cmp_Node, ptr %t159, i32 0, i32 2
  %t161 = load i32, ptr %t160
  %t162 = call ptr @fn_itoa(i32 %t161)
  %t163 = call ptr @fn_val(ptr %t162, ptr @.str929)
  store ptr %t163, ptr %retval
  br label %ret
ifend38:
  %t164 = load ptr, ptr %t146
  %t165 = getelementptr inbounds %Cmp_Node, ptr %t164, i32 0, i32 3
  %t166 = load ptr, ptr %t165
  %t167 = call ptr @fn_llty(ptr %t166)
  %t168 = call ptr @fn_str_concat(ptr @.str930, ptr %t167)
  %t169 = call ptr @fn_str_concat(ptr %t168, ptr @.str931)
  %t170 = load ptr, ptr %t0
  %t171 = getelementptr inbounds %Cmp_Node, ptr %t170, i32 0, i32 1
  %t172 = load ptr, ptr %t171
  %t173 = call ptr @fn_str_concat(ptr %t169, ptr %t172)
  %t174 = call ptr @fn_emit_bind(ptr %t173)
  store ptr %t174, ptr %t175
  %t176 = load ptr, ptr %t175
  %t177 = load ptr, ptr %t146
  %t178 = getelementptr inbounds %Cmp_Node, ptr %t177, i32 0, i32 3
  %t179 = load ptr, ptr %t178
  %t180 = call ptr @fn_val(ptr %t176, ptr %t179)
  store ptr %t180, ptr %retval
  br label %ret
ifend35:
  %t181 = load ptr, ptr %t0
  %t182 = getelementptr inbounds %Cmp_Node, ptr %t181, i32 0, i32 1
  %t183 = load ptr, ptr %t182
  %t184 = call i32 @fn_is_ui_ident(ptr %t183)
  %t185 = icmp ne i32 %t184, 0
  br i1 %t185, label %then39, label %ifend41
then39:
  %t186 = load ptr, ptr %t0
  %t187 = getelementptr inbounds %Cmp_Node, ptr %t186, i32 0, i32 1
  %t188 = load ptr, ptr %t187
  %t189 = call i32 @fn_ui_index_of(ptr %t188)
  %t190 = call ptr @fn_itoa(i32 %t189)
  %t191 = call ptr @fn_val(ptr %t190, ptr @.str932)
  store ptr %t191, ptr %retval
  br label %ret
ifend41:
  %t192 = load ptr, ptr %t0
  %t193 = getelementptr inbounds %Cmp_Node, ptr %t192, i32 0, i32 1
  %t194 = load ptr, ptr %t193
  %t195 = call ptr @fn_str_concat(ptr @.str933, ptr %t194)
  call void @fn_perr(ptr %t195)
  br label %ifend29
ifend29:
  %t196 = load ptr, ptr %t0
  %t197 = getelementptr inbounds %Cmp_Node, ptr %t196, i32 0, i32 0
  %t198 = load i32, ptr %t197
  %t199 = icmp eq i32 %t198, 35
  %t200 = zext i1 %t199 to i32
  %t201 = icmp ne i32 %t200, 0
  br i1 %t201, label %then42, label %ifend44
then42:
  %t202 = load ptr, ptr %t0
  %t203 = getelementptr inbounds %Cmp_Node, ptr %t202, i32 0, i32 4
  %t204 = load ptr, ptr %t203
  %t205 = getelementptr inbounds %Cmp_Node, ptr %t204, i32 0, i32 0
  %t206 = load i32, ptr %t205
  %t207 = icmp eq i32 %t206, 33
  %t208 = zext i1 %t207 to i32
  %t209 = icmp ne i32 %t208, 0
  br i1 %t209, label %then45, label %ifend47
then45:
  %t210 = load ptr, ptr %t0
  %t211 = getelementptr inbounds %Cmp_Node, ptr %t210, i32 0, i32 4
  %t212 = load ptr, ptr %t211
  %t213 = getelementptr inbounds %Cmp_Node, ptr %t212, i32 0, i32 1
  %t214 = load ptr, ptr %t213
  %t215 = load ptr, ptr %t0
  %t216 = getelementptr inbounds %Cmp_Node, ptr %t215, i32 0, i32 1
  %t217 = load ptr, ptr %t216
  %t218 = call i32 @fn_enum_ordinal(ptr %t214, ptr %t217)
  store i32 %t218, ptr %t219
  %t220 = load i32, ptr %t219
  %t221 = icmp sge i32 %t220, 0
  %t222 = zext i1 %t221 to i32
  %t223 = icmp ne i32 %t222, 0
  br i1 %t223, label %then48, label %ifend50
then48:
  %t224 = load i32, ptr %t219
  %t225 = call ptr @fn_itoa(i32 %t224)
  %t226 = call ptr @fn_val(ptr %t225, ptr @.str934)
  store ptr %t226, ptr %retval
  br label %ret
ifend50:
  br label %ifend47
ifend47:
  %t227 = load ptr, ptr %t0
  %t228 = getelementptr inbounds %Cmp_Node, ptr %t227, i32 0, i32 4
  %t229 = load ptr, ptr %t228
  %t230 = call ptr @fn_static_type(ptr %t229)
  store ptr %t230, ptr %t231
  %t232 = load ptr, ptr %t231
  %t233 = icmp ne ptr %t232, null
  %t234 = zext i1 %t233 to i32
  %t235 = icmp ne i32 %t234, 0
  br i1 %t235, label %then51, label %ifend53
then51:
  %t236 = load ptr, ptr %t231
  %t237 = load ptr, ptr %t0
  %t238 = getelementptr inbounds %Cmp_Node, ptr %t237, i32 0, i32 1
  %t239 = load ptr, ptr %t238
  %t240 = call ptr @fn_computed_expr(ptr %t236, ptr %t239)
  store ptr %t240, ptr %t241
  %t242 = load ptr, ptr %t241
  %t243 = icmp ne ptr %t242, null
  %t244 = zext i1 %t243 to i32
  %t245 = icmp ne i32 %t244, 0
  br i1 %t245, label %then54, label %ifend56
then54:
  %t246 = load ptr, ptr %t241
  %t247 = load ptr, ptr %t0
  %t248 = getelementptr inbounds %Cmp_Node, ptr %t247, i32 0, i32 4
  %t249 = load ptr, ptr %t248
  %t250 = call ptr @fn_qualify_fields(ptr %t246, ptr %t249)
  %t251 = call ptr @fn_emit_expr(ptr %t250)
  store ptr %t251, ptr %retval
  br label %ret
ifend56:
  br label %ifend53
ifend53:
  %t252 = load ptr, ptr %t0
  %t253 = call ptr @fn_emit_member_addr(ptr %t252)
  store ptr %t253, ptr %t254
  %t255 = load ptr, ptr %t254
  %t256 = load ptr, ptr @g_g_addr_ty
  %t257 = call ptr @fn_emit_load_at(ptr %t255, ptr %t256)
  store ptr %t257, ptr %retval
  br label %ret
ifend44:
  %t258 = load ptr, ptr %t0
  %t259 = getelementptr inbounds %Cmp_Node, ptr %t258, i32 0, i32 0
  %t260 = load i32, ptr %t259
  %t261 = icmp eq i32 %t260, 36
  %t262 = zext i1 %t261 to i32
  %t263 = icmp ne i32 %t262, 0
  br i1 %t263, label %then57, label %ifend59
then57:
  %t264 = load ptr, ptr %t0
  %t265 = call ptr @fn_emit_index_addr(ptr %t264)
  store ptr %t265, ptr %t266
  %t267 = load ptr, ptr @g_g_addr_ty
  %t268 = call i32 @fn_str_eq(ptr %t267, ptr @.str935)
  %t269 = icmp ne i32 %t268, 0
  br i1 %t269, label %then60, label %ifend62
then60:
  %t270 = load ptr, ptr %t266
  %t271 = call ptr @fn_str_concat(ptr @.str936, ptr %t270)
  %t272 = call ptr @fn_emit_bind(ptr %t271)
  store ptr %t272, ptr %t273
  %t274 = load ptr, ptr %t273
  %t275 = call ptr @fn_str_concat(ptr @.str937, ptr %t274)
  %t276 = call ptr @fn_str_concat(ptr %t275, ptr @.str938)
  %t277 = call ptr @fn_emit_bind(ptr %t276)
  %t278 = call ptr @fn_val(ptr %t277, ptr @.str939)
  store ptr %t278, ptr %retval
  br label %ret
ifend62:
  %t279 = load ptr, ptr %t266
  %t280 = load ptr, ptr @g_g_addr_ty
  %t281 = call ptr @fn_emit_load_at(ptr %t279, ptr %t280)
  store ptr %t281, ptr %retval
  br label %ret
ifend59:
  %t282 = load ptr, ptr %t0
  %t283 = getelementptr inbounds %Cmp_Node, ptr %t282, i32 0, i32 0
  %t284 = load i32, ptr %t283
  %t285 = icmp eq i32 %t284, 34
  %t286 = zext i1 %t285 to i32
  %t287 = icmp ne i32 %t286, 0
  br i1 %t287, label %then63, label %ifend65
then63:
  %t288 = load ptr, ptr %t0
  %t289 = call ptr @fn_emit_call(ptr %t288)
  store ptr %t289, ptr %retval
  br label %ret
ifend65:
  %t290 = load ptr, ptr %t0
  %t291 = getelementptr inbounds %Cmp_Node, ptr %t290, i32 0, i32 0
  %t292 = load i32, ptr %t291
  %t293 = icmp eq i32 %t292, 37
  %t294 = zext i1 %t293 to i32
  %t295 = icmp ne i32 %t294, 0
  br i1 %t295, label %then66, label %ifend68
then66:
  %t296 = load ptr, ptr %t0
  %t297 = call ptr @fn_emit_bin(ptr %t296)
  store ptr %t297, ptr %retval
  br label %ret
ifend68:
  %t298 = load ptr, ptr %t0
  %t299 = getelementptr inbounds %Cmp_Node, ptr %t298, i32 0, i32 0
  %t300 = load i32, ptr %t299
  %t301 = icmp eq i32 %t300, 38
  %t302 = zext i1 %t301 to i32
  %t303 = icmp ne i32 %t302, 0
  br i1 %t303, label %then69, label %ifend71
then69:
  %t304 = load ptr, ptr %t0
  %t305 = getelementptr inbounds %Cmp_Node, ptr %t304, i32 0, i32 4
  %t306 = load ptr, ptr %t305
  %t307 = call ptr @fn_emit_expr(ptr %t306)
  store ptr %t307, ptr %t308
  %t309 = load ptr, ptr %t0
  %t310 = getelementptr inbounds %Cmp_Node, ptr %t309, i32 0, i32 1
  %t311 = load ptr, ptr %t310
  %t312 = call i32 @fn_str_eq(ptr %t311, ptr @.str940)
  %t313 = icmp ne i32 %t312, 0
  br i1 %t313, label %then72, label %ifend74
then72:
  %t314 = load ptr, ptr %t308
  %t315 = getelementptr inbounds %Cmp_Val, ptr %t314, i32 0, i32 0
  %t316 = load ptr, ptr %t315
  %t317 = call ptr @fn_str_concat(ptr @.str941, ptr %t316)
  %t318 = call ptr @fn_emit_bind(ptr %t317)
  %t319 = call ptr @fn_val(ptr %t318, ptr @.str942)
  store ptr %t319, ptr %retval
  br label %ret
ifend74:
  %t320 = load ptr, ptr %t0
  %t321 = getelementptr inbounds %Cmp_Node, ptr %t320, i32 0, i32 1
  %t322 = load ptr, ptr %t321
  %t323 = call i32 @fn_str_eq(ptr %t322, ptr @.str943)
  %t324 = icmp ne i32 %t323, 0
  br i1 %t324, label %then75, label %ifend77
then75:
  %t325 = load ptr, ptr %t308
  %t326 = getelementptr inbounds %Cmp_Val, ptr %t325, i32 0, i32 0
  %t327 = load ptr, ptr %t326
  %t328 = call ptr @fn_str_concat(ptr @.str944, ptr %t327)
  %t329 = call ptr @fn_str_concat(ptr %t328, ptr @.str945)
  %t330 = call ptr @fn_emit_bind(ptr %t329)
  %t331 = call ptr @fn_val(ptr %t330, ptr @.str946)
  store ptr %t331, ptr %retval
  br label %ret
ifend77:
  %t332 = load ptr, ptr %t308
  %t333 = getelementptr inbounds %Cmp_Val, ptr %t332, i32 0, i32 0
  %t334 = load ptr, ptr %t333
  %t335 = call ptr @fn_str_concat(ptr @.str947, ptr %t334)
  %t336 = call ptr @fn_str_concat(ptr %t335, ptr @.str948)
  %t337 = call ptr @fn_emit_bind(ptr %t336)
  store ptr %t337, ptr %t338
  %t339 = load ptr, ptr %t338
  %t340 = call ptr @fn_str_concat(ptr @.str949, ptr %t339)
  %t341 = call ptr @fn_str_concat(ptr %t340, ptr @.str950)
  %t342 = call ptr @fn_emit_bind(ptr %t341)
  %t343 = call ptr @fn_val(ptr %t342, ptr @.str951)
  store ptr %t343, ptr %retval
  br label %ret
ifend71:
  call void @fn_perr(ptr @.str952)
  %t344 = call ptr @fn_val(ptr @.str953, ptr @.str954)
  store ptr %t344, ptr %retval
  br label %ret
ret:
  %t345 = load ptr, ptr %retval
  ret ptr %t345
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
  call void @fn_emit(ptr @.str955)
  %t3 = load ptr, ptr %t0
  call void @fn_emit(ptr %t3)
  call void @fn_emit(ptr @.str956)
  %t4 = load ptr, ptr %t1
  call void @fn_emit(ptr %t4)
  call void @fn_emit(ptr @.str957)
  %t5 = load ptr, ptr %t2
  call void @fn_emit(ptr %t5)
  call void @fn_emit(ptr @.str958)
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
  store ptr @.str959, ptr %t5
  store ptr @.str960, ptr %t6
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
  %t34 = call ptr @fn_str_concat(ptr @.str961, ptr %t33)
  %t35 = call ptr @fn_str_concat(ptr %t34, ptr @.str962)
  %t36 = load ptr, ptr %t0
  %t37 = getelementptr inbounds %Cmp_Node, ptr %t36, i32 0, i32 8
  %t38 = load i32, ptr %t37
  %t39 = call ptr @fn_itoa(i32 %t38)
  %t40 = call ptr @fn_str_concat(ptr %t35, ptr %t39)
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
  %t65 = call ptr @fn_str_concat(ptr @.str963, ptr %t64)
  call void @fn_perr(ptr %t65)
  br label %ifend11
ifend11:
  %t66 = load ptr, ptr %t4
  %t67 = getelementptr inbounds %Cmp_Node, ptr %t66, i32 0, i32 1
  %t68 = load ptr, ptr %t67
  %t69 = call ptr @fn_str_concat(ptr @.str964, ptr %t68)
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
  call void @fn_perr(ptr @.str965)
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
  %t106 = call i32 @fn_str_eq(ptr %t105, ptr @.str966)
  %t107 = icmp eq i32 %t106, 0
  %t108 = zext i1 %t107 to i32
  %t109 = icmp ne i32 %t108, 0
  br i1 %t109, label %then18, label %ifend20
then18:
  %t110 = load ptr, ptr %t93
  %t111 = call ptr @fn_str_concat(ptr @.str967, ptr %t110)
  %t112 = call ptr @fn_str_concat(ptr %t111, ptr @.str968)
  %t113 = load ptr, ptr %t5
  %t114 = call ptr @fn_str_concat(ptr %t112, ptr %t113)
  %t115 = call ptr @fn_emit_bind(ptr %t114)
  store ptr %t115, ptr %t116
  store ptr @.str969, ptr %t117
  %t118 = load ptr, ptr %t0
  %t119 = getelementptr inbounds %Cmp_Node, ptr %t118, i32 0, i32 1
  %t120 = load ptr, ptr %t119
  %t121 = call i32 @fn_str_eq(ptr %t120, ptr @.str970)
  %t122 = icmp ne i32 %t121, 0
  br i1 %t122, label %then21, label %ifend23
then21:
  store ptr @.str971, ptr %t117
  br label %ifend23
ifend23:
  %t123 = load ptr, ptr %t0
  %t124 = getelementptr inbounds %Cmp_Node, ptr %t123, i32 0, i32 1
  %t125 = load ptr, ptr %t124
  %t126 = call i32 @fn_str_eq(ptr %t125, ptr @.str972)
  %t127 = icmp ne i32 %t126, 0
  br i1 %t127, label %then24, label %ifend26
then24:
  store ptr @.str973, ptr %t117
  br label %ifend26
ifend26:
  %t128 = load ptr, ptr %t0
  %t129 = getelementptr inbounds %Cmp_Node, ptr %t128, i32 0, i32 1
  %t130 = load ptr, ptr %t129
  %t131 = call i32 @fn_str_eq(ptr %t130, ptr @.str974)
  %t132 = icmp ne i32 %t131, 0
  br i1 %t132, label %then27, label %ifend29
then27:
  store ptr @.str975, ptr %t117
  br label %ifend29
ifend29:
  %t133 = load ptr, ptr %t117
  %t134 = call ptr @fn_str_concat(ptr %t133, ptr @.str976)
  %t135 = load ptr, ptr %t116
  %t136 = call ptr @fn_str_concat(ptr %t134, ptr %t135)
  %t137 = call ptr @fn_str_concat(ptr %t136, ptr @.str977)
  %t138 = load ptr, ptr %t102
  %t139 = call ptr @fn_str_concat(ptr %t137, ptr %t138)
  %t140 = call ptr @fn_emit_bind(ptr %t139)
  store ptr %t140, ptr %t102
  br label %ifend20
ifend20:
  %t141 = load ptr, ptr %t93
  %t142 = call i32 @fn_str_eq(ptr %t141, ptr @.str978)
  %t143 = icmp ne i32 %t142, 0
  br i1 %t143, label %then30, label %ifend32
then30:
  %t144 = load ptr, ptr %t102
  %t145 = call ptr @fn_str_concat(ptr @.str979, ptr %t144)
  %t146 = call ptr @fn_str_concat(ptr %t145, ptr @.str980)
  %t147 = call ptr @fn_emit_bind(ptr %t146)
  store ptr %t147, ptr %t102
  br label %ifend32
ifend32:
  %t148 = load ptr, ptr %t93
  %t149 = load ptr, ptr %t102
  %t150 = load ptr, ptr %t5
  call void @fn_store_at(ptr %t148, ptr %t149, ptr %t150)
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
  %t9 = call ptr @fn_str_concat(ptr @.str981, ptr %t8)
  %t10 = call ptr @fn_str_concat(ptr %t9, ptr @.str982)
  %t11 = call ptr @fn_emit_bind(ptr %t10)
  store ptr %t11, ptr %t12
  %t13 = load ptr, ptr %t0
  %t14 = getelementptr inbounds %Cmp_Node, ptr %t13, i32 0, i32 6
  %t15 = load ptr, ptr %t14
  %t16 = icmp ne ptr %t15, null
  %t17 = zext i1 %t16 to i32
  store i32 %t17, ptr %t18
  %t19 = call ptr @fn_lbl(ptr @.str983)
  store ptr %t19, ptr %t20
  %t21 = call ptr @fn_lbl(ptr @.str984)
  store ptr %t21, ptr %t22
  %t23 = call ptr @fn_lbl(ptr @.str985)
  store ptr %t23, ptr %t24
  %t25 = load i32, ptr %t18
  %t26 = icmp ne i32 %t25, 0
  br i1 %t26, label %then0, label %else1
then0:
  call void @fn_emit(ptr @.str986)
  %t27 = load ptr, ptr %t12
  call void @fn_emit(ptr %t27)
  call void @fn_emit(ptr @.str987)
  %t28 = load ptr, ptr %t20
  call void @fn_emit(ptr %t28)
  call void @fn_emit(ptr @.str988)
  %t29 = load ptr, ptr %t22
  call void @fn_emit(ptr %t29)
  call void @fn_emit(ptr @.str989)
  br label %ifend2
else1:
  call void @fn_emit(ptr @.str990)
  %t30 = load ptr, ptr %t12
  call void @fn_emit(ptr %t30)
  call void @fn_emit(ptr @.str991)
  %t31 = load ptr, ptr %t20
  call void @fn_emit(ptr %t31)
  call void @fn_emit(ptr @.str992)
  %t32 = load ptr, ptr %t24
  call void @fn_emit(ptr %t32)
  call void @fn_emit(ptr @.str993)
  br label %ifend2
ifend2:
  %t33 = load ptr, ptr %t20
  call void @fn_emit(ptr %t33)
  call void @fn_emit(ptr @.str994)
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
  call void @fn_emit(ptr @.str995)
  %t41 = load ptr, ptr %t24
  call void @fn_emit(ptr %t41)
  call void @fn_emit(ptr @.str996)
  br label %ifend5
ifend5:
  %t42 = load i32, ptr %t18
  %t43 = icmp ne i32 %t42, 0
  br i1 %t43, label %then6, label %ifend8
then6:
  %t44 = load ptr, ptr %t22
  call void @fn_emit(ptr %t44)
  call void @fn_emit(ptr @.str997)
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
  call void @fn_emit(ptr @.str998)
  %t63 = load ptr, ptr %t24
  call void @fn_emit(ptr %t63)
  call void @fn_emit(ptr @.str999)
  br label %ifend14
ifend14:
  br label %ifend8
ifend8:
  %t64 = load ptr, ptr %t24
  call void @fn_emit(ptr %t64)
  call void @fn_emit(ptr @.str1000)
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
  %t1 = call ptr @fn_lbl(ptr @.str1001)
  store ptr %t1, ptr %t2
  %t3 = call ptr @fn_lbl(ptr @.str1002)
  store ptr %t3, ptr %t4
  %t5 = call ptr @fn_lbl(ptr @.str1003)
  store ptr %t5, ptr %t6
  call void @fn_emit(ptr @.str1004)
  %t7 = load ptr, ptr %t2
  call void @fn_emit(ptr %t7)
  call void @fn_emit(ptr @.str1005)
  %t8 = load ptr, ptr %t2
  call void @fn_emit(ptr %t8)
  call void @fn_emit(ptr @.str1006)
  %t9 = load ptr, ptr %t0
  %t10 = getelementptr inbounds %Cmp_Node, ptr %t9, i32 0, i32 4
  %t11 = load ptr, ptr %t10
  %t12 = call ptr @fn_emit_expr(ptr %t11)
  store ptr %t12, ptr %t13
  %t14 = load ptr, ptr %t13
  %t15 = getelementptr inbounds %Cmp_Val, ptr %t14, i32 0, i32 0
  %t16 = load ptr, ptr %t15
  %t17 = call ptr @fn_str_concat(ptr @.str1007, ptr %t16)
  %t18 = call ptr @fn_str_concat(ptr %t17, ptr @.str1008)
  %t19 = call ptr @fn_emit_bind(ptr %t18)
  store ptr %t19, ptr %t20
  call void @fn_emit(ptr @.str1009)
  %t21 = load ptr, ptr %t20
  call void @fn_emit(ptr %t21)
  call void @fn_emit(ptr @.str1010)
  %t22 = load ptr, ptr %t4
  call void @fn_emit(ptr %t22)
  call void @fn_emit(ptr @.str1011)
  %t23 = load ptr, ptr %t6
  call void @fn_emit(ptr %t23)
  call void @fn_emit(ptr @.str1012)
  %t24 = load ptr, ptr %t4
  call void @fn_emit(ptr %t24)
  call void @fn_emit(ptr @.str1013)
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
  call void @fn_emit(ptr @.str1014)
  %t34 = load ptr, ptr %t2
  call void @fn_emit(ptr %t34)
  call void @fn_emit(ptr @.str1015)
  br label %ifend2
ifend2:
  %t35 = load ptr, ptr %t6
  call void @fn_emit(ptr %t35)
  call void @fn_emit(ptr @.str1016)
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
  %t1 = call ptr @fn_emit_alloca(ptr @.str1017)
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
  call void @fn_store_at(ptr @.str1018, ptr %t10, ptr %t11)
  %t12 = load ptr, ptr %t0
  %t13 = getelementptr inbounds %Cmp_Node, ptr %t12, i32 0, i32 1
  %t14 = load ptr, ptr %t13
  %t15 = load ptr, ptr %t2
  call void @fn_loc_push(ptr %t14, ptr %t15, ptr @.str1019)
  %t16 = call ptr @fn_lbl(ptr @.str1020)
  store ptr %t16, ptr %t17
  %t18 = call ptr @fn_lbl(ptr @.str1021)
  store ptr %t18, ptr %t19
  %t20 = call ptr @fn_lbl(ptr @.str1022)
  store ptr %t20, ptr %t21
  %t22 = call ptr @fn_lbl(ptr @.str1023)
  store ptr %t22, ptr %t23
  call void @fn_emit(ptr @.str1024)
  %t24 = load ptr, ptr %t17
  call void @fn_emit(ptr %t24)
  call void @fn_emit(ptr @.str1025)
  %t25 = load ptr, ptr %t17
  call void @fn_emit(ptr %t25)
  call void @fn_emit(ptr @.str1026)
  %t26 = load ptr, ptr %t2
  %t27 = call ptr @fn_str_concat(ptr @.str1027, ptr %t26)
  %t28 = call ptr @fn_emit_bind(ptr %t27)
  store ptr %t28, ptr %t29
  %t30 = load ptr, ptr %t0
  %t31 = getelementptr inbounds %Cmp_Node, ptr %t30, i32 0, i32 5
  %t32 = load ptr, ptr %t31
  %t33 = call ptr @fn_emit_expr(ptr %t32)
  store ptr %t33, ptr %t34
  %t35 = load ptr, ptr %t29
  %t36 = call ptr @fn_str_concat(ptr @.str1028, ptr %t35)
  %t37 = call ptr @fn_str_concat(ptr %t36, ptr @.str1029)
  %t38 = load ptr, ptr %t34
  %t39 = getelementptr inbounds %Cmp_Val, ptr %t38, i32 0, i32 0
  %t40 = load ptr, ptr %t39
  %t41 = call ptr @fn_str_concat(ptr %t37, ptr %t40)
  %t42 = call ptr @fn_emit_bind(ptr %t41)
  store ptr %t42, ptr %t43
  call void @fn_emit(ptr @.str1030)
  %t44 = load ptr, ptr %t43
  call void @fn_emit(ptr %t44)
  call void @fn_emit(ptr @.str1031)
  %t45 = load ptr, ptr %t19
  call void @fn_emit(ptr %t45)
  call void @fn_emit(ptr @.str1032)
  %t46 = load ptr, ptr %t23
  call void @fn_emit(ptr %t46)
  call void @fn_emit(ptr @.str1033)
  %t47 = load ptr, ptr %t19
  call void @fn_emit(ptr %t47)
  call void @fn_emit(ptr @.str1034)
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
  call void @fn_emit(ptr @.str1035)
  %t57 = load ptr, ptr %t21
  call void @fn_emit(ptr %t57)
  call void @fn_emit(ptr @.str1036)
  br label %ifend2
ifend2:
  %t58 = load ptr, ptr %t21
  call void @fn_emit(ptr %t58)
  call void @fn_emit(ptr @.str1037)
  %t59 = load ptr, ptr %t2
  %t60 = call ptr @fn_str_concat(ptr @.str1038, ptr %t59)
  %t61 = call ptr @fn_emit_bind(ptr %t60)
  store ptr %t61, ptr %t62
  %t63 = load ptr, ptr %t62
  %t64 = call ptr @fn_str_concat(ptr @.str1039, ptr %t63)
  %t65 = call ptr @fn_str_concat(ptr %t64, ptr @.str1040)
  %t66 = call ptr @fn_emit_bind(ptr %t65)
  store ptr %t66, ptr %t67
  %t68 = load ptr, ptr %t67
  %t69 = load ptr, ptr %t2
  call void @fn_store_at(ptr @.str1041, ptr %t68, ptr %t69)
  call void @fn_emit(ptr @.str1042)
  %t70 = load ptr, ptr %t17
  call void @fn_emit(ptr %t70)
  call void @fn_emit(ptr @.str1043)
  %t71 = load ptr, ptr %t23
  call void @fn_emit(ptr %t71)
  call void @fn_emit(ptr @.str1044)
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
  call void @fn_store_at(ptr %t13, ptr %t16, ptr @.str1045)
  br label %ifend2
ifend2:
  call void @fn_emit(ptr @.str1046)
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
  %t36 = call i32 @fn_str_eq(ptr %t35, ptr @.str1047)
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
  %t6 = call ptr @fn_lbl(ptr @.str1048)
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
  store ptr @.str1049, ptr %t32
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
  %t57 = call ptr @fn_str_concat(ptr @.str1050, ptr %t56)
  %t58 = call ptr @fn_str_concat(ptr %t57, ptr @.str1051)
  %t59 = load ptr, ptr %t53
  %t60 = getelementptr inbounds %Cmp_Val, ptr %t59, i32 0, i32 0
  %t61 = load ptr, ptr %t60
  %t62 = call ptr @fn_str_concat(ptr %t58, ptr %t61)
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
  %t69 = call ptr @fn_str_concat(ptr @.str1052, ptr %t68)
  %t70 = call ptr @fn_str_concat(ptr %t69, ptr @.str1053)
  %t71 = load ptr, ptr %t64
  %t72 = call ptr @fn_str_concat(ptr %t70, ptr %t71)
  %t73 = call ptr @fn_emit_bind(ptr %t72)
  store ptr %t73, ptr %t32
  br label %ifend11
ifend11:
  %t74 = load i32, ptr %t34
  %t75 = add i32 %t74, 1
  store i32 %t75, ptr %t34
  br label %wcond6
wend8:
  %t76 = call ptr @fn_lbl(ptr @.str1054)
  store ptr %t76, ptr %t77
  %t78 = call ptr @fn_lbl(ptr @.str1055)
  store ptr %t78, ptr %t79
  call void @fn_emit(ptr @.str1056)
  %t80 = load ptr, ptr %t32
  call void @fn_emit(ptr %t80)
  call void @fn_emit(ptr @.str1057)
  %t81 = load ptr, ptr %t77
  call void @fn_emit(ptr %t81)
  call void @fn_emit(ptr @.str1058)
  %t82 = load ptr, ptr %t79
  call void @fn_emit(ptr %t82)
  call void @fn_emit(ptr @.str1059)
  %t83 = load ptr, ptr %t77
  call void @fn_emit(ptr %t83)
  call void @fn_emit(ptr @.str1060)
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
  call void @fn_emit(ptr @.str1061)
  %t91 = load ptr, ptr %t7
  call void @fn_emit(ptr %t91)
  call void @fn_emit(ptr @.str1062)
  br label %ifend14
ifend14:
  %t92 = load ptr, ptr %t79
  call void @fn_emit(ptr %t92)
  call void @fn_emit(ptr @.str1063)
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
  call void @fn_emit(ptr @.str1064)
  %t106 = load ptr, ptr %t7
  call void @fn_emit(ptr %t106)
  call void @fn_emit(ptr @.str1065)
  br label %ifend20
ifend20:
  %t107 = load ptr, ptr %t7
  call void @fn_emit(ptr %t107)
  call void @fn_emit(ptr @.str1066)
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
  store ptr @.str1067, ptr %t51
  %t52 = load ptr, ptr %t10
  %t53 = call ptr @fn_llty(ptr %t52)
  %t54 = call i32 @fn_str_eq(ptr %t53, ptr @.str1068)
  %t55 = icmp ne i32 %t54, 0
  br i1 %t55, label %then9, label %ifend11
then9:
  store ptr @.str1069, ptr %t51
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
  call void @fn_emit(ptr @.str1070)
  %t120 = load ptr, ptr @g_brk_lbl
  %t121 = getelementptr inbounds %LSlice, ptr %t120, i32 0, i32 0
  %t122 = load ptr, ptr %t121
  %t123 = load i32, ptr @g_nloop
  %t124 = sub i32 %t123, 1
  %t125 = getelementptr inbounds ptr, ptr %t122, i32 %t124
  %t126 = load ptr, ptr %t125
  call void @fn_emit(ptr %t126)
  call void @fn_emit(ptr @.str1071)
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
  call void @fn_emit(ptr @.str1072)
  %t133 = load ptr, ptr @g_cnt_lbl
  %t134 = getelementptr inbounds %LSlice, ptr %t133, i32 0, i32 0
  %t135 = load ptr, ptr %t134
  %t136 = load i32, ptr @g_nloop
  %t137 = sub i32 %t136, 1
  %t138 = getelementptr inbounds ptr, ptr %t135, i32 %t137
  %t139 = load ptr, ptr %t138
  call void @fn_emit(ptr %t139)
  call void @fn_emit(ptr @.str1073)
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
  call void @fn_perr(ptr @.str1074)
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
  call void @fn_emith(ptr @.str1075)
  call void @fn_emith(ptr @.str1076)
  call void @fn_emith(ptr @.str1077)
  %t0 = call ptr @fn_itoa(i32 1024)
  store ptr %t0, ptr %t1
  %t2 = load ptr, ptr %t1
  %t3 = call ptr @fn_str_concat(ptr @.str1078, ptr %t2)
  %t4 = call ptr @fn_str_concat(ptr %t3, ptr @.str1079)
  call void @fn_emith(ptr %t4)
  %t5 = load ptr, ptr %t1
  %t6 = call ptr @fn_str_concat(ptr @.str1080, ptr %t5)
  %t7 = call ptr @fn_str_concat(ptr %t6, ptr @.str1081)
  call void @fn_emith(ptr %t7)
  %t8 = load ptr, ptr %t1
  %t9 = call ptr @fn_str_concat(ptr @.str1082, ptr %t8)
  %t10 = call ptr @fn_str_concat(ptr %t9, ptr @.str1083)
  call void @fn_emith(ptr %t10)
  call void @fn_emith(ptr @.str1084)
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
  %t35 = call ptr @fn_str_concat(ptr @.str1085, ptr %t34)
  %t36 = call ptr @fn_str_concat(ptr %t35, ptr @.str1086)
  %t37 = load ptr, ptr %t1
  %t38 = call ptr @fn_str_concat(ptr %t36, ptr %t37)
  %t39 = call ptr @fn_str_concat(ptr %t38, ptr @.str1087)
  %t40 = load ptr, ptr %t25
  %t41 = getelementptr inbounds %Cmp_Node, ptr %t40, i32 0, i32 1
  %t42 = load ptr, ptr %t41
  %t43 = call ptr @fn_str_concat(ptr %t39, ptr %t42)
  %t44 = call ptr @fn_str_concat(ptr %t43, ptr @.str1088)
  call void @fn_emith(ptr %t44)
  %t45 = load ptr, ptr %t25
  %t46 = getelementptr inbounds %Cmp_Node, ptr %t45, i32 0, i32 1
  %t47 = load ptr, ptr %t46
  %t48 = call ptr @fn_str_concat(ptr @.str1089, ptr %t47)
  %t49 = call ptr @fn_str_concat(ptr %t48, ptr @.str1090)
  %t50 = load ptr, ptr %t1
  %t51 = call ptr @fn_str_concat(ptr %t49, ptr %t50)
  %t52 = call ptr @fn_str_concat(ptr %t51, ptr @.str1091)
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
  %t62 = call ptr @fn_str_concat(ptr @.str1092, ptr %t61)
  %t63 = call ptr @fn_str_concat(ptr %t62, ptr @.str1093)
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
  %t73 = call ptr @fn_str_concat(ptr @.str1094, ptr %t72)
  %t74 = call ptr @fn_str_concat(ptr %t73, ptr @.str1095)
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
  call void @fn_emit(ptr @.str1096)
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
  %t23 = call ptr @fn_str_concat(ptr @.str1097, ptr %t22)
  store ptr %t23, ptr %t24
  call void @fn_emit(ptr @.str1098)
  %t25 = load ptr, ptr %t24
  call void @fn_emit(ptr %t25)
  call void @fn_emit(ptr @.str1099)
  %t26 = load ptr, ptr %t1
  call void @fn_emit(ptr %t26)
  call void @fn_emit(ptr @.str1100)
  %t27 = load ptr, ptr @g_prog
  %t28 = getelementptr inbounds %LSlice, ptr %t27, i32 0, i32 0
  %t29 = load ptr, ptr %t28
  %t30 = load i32, ptr %t2
  %t31 = getelementptr inbounds ptr, ptr %t29, i32 %t30
  %t32 = load ptr, ptr %t31
  %t33 = getelementptr inbounds %Cmp_Node, ptr %t32, i32 0, i32 1
  %t34 = load ptr, ptr %t33
  call void @fn_emit(ptr %t34)
  call void @fn_emit(ptr @.str1101)
  call void @fn_emit(ptr @.str1102)
  %t35 = load ptr, ptr %t24
  call void @fn_emit(ptr %t35)
  call void @fn_emit(ptr @.str1103)
  br label %ifend5
ifend5:
  %t36 = load i32, ptr %t2
  %t37 = add i32 %t36, 1
  store i32 %t37, ptr %t2
  br label %wcond0
wend2:
  call void @fn_emit(ptr @.str1104)
  %t38 = load ptr, ptr %t1
  call void @fn_emit(ptr %t38)
  call void @fn_emit(ptr @.str1105)
  call void @fn_emit(ptr @.str1106)
  call void @fn_emit(ptr @.str1107)
  call void @fn_emit(ptr @.str1108)
  call void @fn_emit(ptr @.str1109)
  call void @fn_emit(ptr @.str1110)
  call void @fn_emit(ptr @.str1111)
  call void @fn_emit(ptr @.str1112)
  call void @fn_emit(ptr @.str1113)
  call void @fn_emit(ptr @.str1114)
  %t39 = load ptr, ptr %t1
  call void @fn_emit(ptr %t39)
  call void @fn_emit(ptr @.str1115)
  call void @fn_emit(ptr @.str1116)
  call void @fn_emit(ptr @.str1117)
  call void @fn_emit(ptr @.str1118)
  call void @fn_emit(ptr @.str1119)
  call void @fn_emit(ptr @.str1120)
  call void @fn_emit(ptr @.str1121)
  call void @fn_emit(ptr @.str1122)
  call void @fn_emit(ptr @.str1123)
  call void @fn_emit(ptr @.str1124)
  call void @fn_emit(ptr @.str1125)
  call void @fn_emit(ptr @.str1126)
  %t40 = load ptr, ptr %t1
  call void @fn_emit(ptr %t40)
  call void @fn_emit(ptr @.str1127)
  call void @fn_emit(ptr @.str1128)
  call void @fn_emit(ptr @.str1129)
  call void @fn_emit(ptr @.str1130)
  call void @fn_emit(ptr @.str1131)
  %t41 = load ptr, ptr %t1
  call void @fn_emit(ptr %t41)
  call void @fn_emit(ptr @.str1132)
  call void @fn_emit(ptr @.str1133)
  call void @fn_emit(ptr @.str1134)
  call void @fn_emit(ptr @.str1135)
  call void @fn_emit(ptr @.str1136)
  %t42 = load ptr, ptr %t1
  call void @fn_emit(ptr %t42)
  call void @fn_emit(ptr @.str1137)
  call void @fn_emit(ptr @.str1138)
  call void @fn_emit(ptr @.str1139)
  call void @fn_emit(ptr @.str1140)
  call void @fn_emit(ptr @.str1141)
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
  %t3 = call ptr @fn_emit_alloca(ptr @.str1142)
  store ptr %t3, ptr %t4
  %t5 = load ptr, ptr %t4
  call void @fn_store_at(ptr @.str1143, ptr @.str1144, ptr %t5)
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
  %t41 = call ptr @fn_lbl(ptr @.str1145)
  store ptr %t41, ptr %t42
  %t43 = call ptr @fn_lbl(ptr @.str1146)
  store ptr %t43, ptr %t44
  %t45 = call ptr @fn_lbl(ptr @.str1147)
  store ptr %t45, ptr %t46
  %t47 = call ptr @fn_lbl(ptr @.str1148)
  store ptr %t47, ptr %t48
  call void @fn_emit(ptr @.str1149)
  %t49 = load ptr, ptr %t42
  call void @fn_emit(ptr %t49)
  call void @fn_emit(ptr @.str1150)
  %t50 = load ptr, ptr %t42
  call void @fn_emit(ptr %t50)
  call void @fn_emit(ptr @.str1151)
  %t51 = load ptr, ptr %t4
  %t52 = call ptr @fn_str_concat(ptr @.str1152, ptr %t51)
  %t53 = call ptr @fn_emit_bind(ptr %t52)
  store ptr %t53, ptr %t54
  %t55 = call ptr @fn_emit_bind(ptr @.str1153)
  store ptr %t55, ptr %t56
  %t57 = load ptr, ptr %t54
  %t58 = call ptr @fn_str_concat(ptr @.str1154, ptr %t57)
  %t59 = call ptr @fn_str_concat(ptr %t58, ptr @.str1155)
  %t60 = load ptr, ptr %t56
  %t61 = call ptr @fn_str_concat(ptr %t59, ptr %t60)
  %t62 = call ptr @fn_emit_bind(ptr %t61)
  store ptr %t62, ptr %t63
  call void @fn_emit(ptr @.str1156)
  %t64 = load ptr, ptr %t63
  call void @fn_emit(ptr %t64)
  call void @fn_emit(ptr @.str1157)
  %t65 = load ptr, ptr %t44
  call void @fn_emit(ptr %t65)
  call void @fn_emit(ptr @.str1158)
  %t66 = load ptr, ptr %t48
  call void @fn_emit(ptr %t66)
  call void @fn_emit(ptr @.str1159)
  %t67 = load ptr, ptr %t44
  call void @fn_emit(ptr %t67)
  call void @fn_emit(ptr @.str1160)
  store i32 0, ptr @g_g_term
  %t68 = load ptr, ptr %t4
  %t69 = call ptr @fn_str_concat(ptr @.str1161, ptr %t68)
  %t70 = call ptr @fn_emit_bind(ptr %t69)
  store ptr %t70, ptr %t71
  %t72 = call ptr @fn_nreg()
  store ptr %t72, ptr %t73
  call void @fn_emit(ptr @.str1162)
  %t74 = load ptr, ptr %t73
  call void @fn_emit(ptr %t74)
  call void @fn_emit(ptr @.str1163)
  %t75 = load ptr, ptr %t2
  call void @fn_emit(ptr %t75)
  call void @fn_emit(ptr @.str1164)
  %t76 = load ptr, ptr %t71
  call void @fn_emit(ptr %t76)
  call void @fn_emit(ptr @.str1165)
  %t77 = load ptr, ptr %t73
  %t78 = call ptr @fn_str_concat(ptr @.str1166, ptr %t77)
  %t79 = call ptr @fn_emit_bind(ptr %t78)
  store ptr %t79, ptr %t80
  %t81 = load ptr, ptr %t80
  %t82 = call ptr @fn_str_concat(ptr @.str1167, ptr %t81)
  %t83 = call ptr @fn_str_concat(ptr %t82, ptr @.str1168)
  %t84 = call ptr @fn_emit_bind(ptr %t83)
  store ptr %t84, ptr %t85
  %t86 = call ptr @fn_lbl(ptr @.str1169)
  store ptr %t86, ptr %t87
  call void @fn_emit(ptr @.str1170)
  %t88 = load ptr, ptr %t85
  call void @fn_emit(ptr %t88)
  call void @fn_emit(ptr @.str1171)
  %t89 = load ptr, ptr %t87
  call void @fn_emit(ptr %t89)
  call void @fn_emit(ptr @.str1172)
  %t90 = load ptr, ptr %t46
  call void @fn_emit(ptr %t90)
  call void @fn_emit(ptr @.str1173)
  %t91 = load ptr, ptr %t87
  call void @fn_emit(ptr %t91)
  call void @fn_emit(ptr @.str1174)
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
  store ptr @.str1175, ptr %t120
  %t121 = load i32, ptr %t119
  %t122 = icmp sgt i32 %t121, 0
  %t123 = zext i1 %t122 to i32
  %t124 = icmp ne i32 %t123, 0
  br i1 %t124, label %then8, label %else9
then8:
  %t125 = call ptr @fn_nreg()
  store ptr %t125, ptr %t126
  call void @fn_emit(ptr @.str1176)
  %t127 = load ptr, ptr %t126
  call void @fn_emit(ptr %t127)
  call void @fn_emit(ptr @.str1177)
  %t128 = load ptr, ptr %t2
  call void @fn_emit(ptr %t128)
  call void @fn_emit(ptr @.str1178)
  %t129 = load ptr, ptr %t71
  call void @fn_emit(ptr %t129)
  call void @fn_emit(ptr @.str1179)
  %t130 = load ptr, ptr %t126
  %t131 = call ptr @fn_str_concat(ptr @.str1180, ptr %t130)
  %t132 = call ptr @fn_emit_bind(ptr %t131)
  store ptr %t132, ptr %t133
  %t134 = load ptr, ptr %t133
  %t135 = call ptr @fn_str_concat(ptr @.str1181, ptr %t134)
  %t136 = call ptr @fn_str_concat(ptr %t135, ptr @.str1182)
  %t137 = load i32, ptr %t119
  %t138 = call ptr @fn_itoa(i32 %t137)
  %t139 = call ptr @fn_str_concat(ptr %t136, ptr %t138)
  %t140 = call ptr @fn_emit_bind(ptr %t139)
  store ptr %t140, ptr %t141
  %t142 = load ptr, ptr %t114
  %t143 = getelementptr inbounds %Cmp_Node, ptr %t142, i32 0, i32 1
  %t144 = load ptr, ptr %t143
  %t145 = call ptr @fn_str_concat(ptr @.str1183, ptr %t144)
  %t146 = call ptr @fn_emit_bind(ptr %t145)
  store ptr %t146, ptr %t147
  %t148 = load ptr, ptr %t147
  %t149 = call ptr @fn_str_concat(ptr @.str1184, ptr %t148)
  %t150 = call ptr @fn_str_concat(ptr %t149, ptr @.str1185)
  %t151 = call ptr @fn_emit_bind(ptr %t150)
  store ptr %t151, ptr %t152
  %t153 = load ptr, ptr %t141
  %t154 = call ptr @fn_str_concat(ptr @.str1186, ptr %t153)
  %t155 = call ptr @fn_str_concat(ptr %t154, ptr @.str1187)
  %t156 = load ptr, ptr %t152
  %t157 = call ptr @fn_str_concat(ptr %t155, ptr %t156)
  %t158 = call ptr @fn_emit_bind(ptr %t157)
  store ptr %t158, ptr %t120
  br label %ifend10
else9:
  %t159 = call ptr @fn_nreg()
  store ptr %t159, ptr %t160
  call void @fn_emit(ptr @.str1188)
  %t161 = load ptr, ptr %t160
  call void @fn_emit(ptr %t161)
  call void @fn_emit(ptr @.str1189)
  %t162 = load ptr, ptr %t2
  call void @fn_emit(ptr %t162)
  call void @fn_emit(ptr @.str1190)
  %t163 = load ptr, ptr %t114
  %t164 = getelementptr inbounds %Cmp_Node, ptr %t163, i32 0, i32 1
  %t165 = load ptr, ptr %t164
  call void @fn_emit(ptr %t165)
  call void @fn_emit(ptr @.str1191)
  %t166 = load ptr, ptr %t71
  call void @fn_emit(ptr %t166)
  call void @fn_emit(ptr @.str1192)
  %t167 = load ptr, ptr %t160
  %t168 = call ptr @fn_str_concat(ptr @.str1193, ptr %t167)
  %t169 = call ptr @fn_emit_bind(ptr %t168)
  store ptr %t169, ptr %t170
  %t171 = load ptr, ptr %t170
  %t172 = call ptr @fn_str_concat(ptr @.str1194, ptr %t171)
  %t173 = call ptr @fn_str_concat(ptr %t172, ptr @.str1195)
  %t174 = call ptr @fn_emit_bind(ptr %t173)
  store ptr %t174, ptr %t120
  br label %ifend10
ifend10:
  %t175 = call ptr @fn_lbl(ptr @.str1196)
  store ptr %t175, ptr %t176
  call void @fn_emit(ptr @.str1197)
  %t177 = load ptr, ptr %t120
  call void @fn_emit(ptr %t177)
  call void @fn_emit(ptr @.str1198)
  %t178 = load ptr, ptr %t176
  call void @fn_emit(ptr %t178)
  call void @fn_emit(ptr @.str1199)
  %t179 = load ptr, ptr %t46
  call void @fn_emit(ptr %t179)
  call void @fn_emit(ptr @.str1200)
  %t180 = load ptr, ptr %t176
  call void @fn_emit(ptr %t180)
  call void @fn_emit(ptr @.str1201)
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
  call void @fn_emit(ptr @.str1202)
  %t233 = load ptr, ptr %t232
  call void @fn_emit(ptr %t233)
  call void @fn_emit(ptr @.str1203)
  %t234 = load ptr, ptr %t2
  call void @fn_emit(ptr %t234)
  call void @fn_emit(ptr @.str1204)
  %t235 = load ptr, ptr %t203
  %t236 = getelementptr inbounds %Cmp_Node, ptr %t235, i32 0, i32 1
  %t237 = load ptr, ptr %t236
  call void @fn_emit(ptr %t237)
  call void @fn_emit(ptr @.str1205)
  %t238 = load ptr, ptr %t203
  %t239 = getelementptr inbounds %Cmp_Node, ptr %t238, i32 0, i32 1
  %t240 = load ptr, ptr %t239
  call void @fn_emit(ptr %t240)
  call void @fn_emit(ptr @.str1206)
  %t241 = load ptr, ptr %t71
  call void @fn_emit(ptr %t241)
  call void @fn_emit(ptr @.str1207)
  %t242 = call ptr @fn_emit_alloca(ptr @.str1208)
  store ptr %t242, ptr %t243
  call void @fn_emit(ptr @.str1209)
  %t244 = load ptr, ptr %t232
  call void @fn_emit(ptr %t244)
  call void @fn_emit(ptr @.str1210)
  %t245 = load ptr, ptr %t243
  call void @fn_emit(ptr %t245)
  call void @fn_emit(ptr @.str1211)
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
  %t278 = call ptr @fn_str_concat(ptr @.str1212, ptr %t277)
  %t279 = call ptr @fn_str_concat(ptr %t278, ptr @.str1213)
  %t280 = call ptr @fn_emit_bind(ptr %t279)
  store ptr %t280, ptr %t281
  %t282 = call ptr @fn_lbl(ptr @.str1214)
  store ptr %t282, ptr %t283
  call void @fn_emit(ptr @.str1215)
  %t284 = load ptr, ptr %t281
  call void @fn_emit(ptr %t284)
  call void @fn_emit(ptr @.str1216)
  %t285 = load ptr, ptr %t283
  call void @fn_emit(ptr %t285)
  call void @fn_emit(ptr @.str1217)
  %t286 = load ptr, ptr %t46
  call void @fn_emit(ptr %t286)
  call void @fn_emit(ptr @.str1218)
  %t287 = load ptr, ptr %t283
  call void @fn_emit(ptr %t287)
  call void @fn_emit(ptr @.str1219)
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
  call void @fn_emit(ptr @.str1220)
  %t298 = load ptr, ptr %t46
  call void @fn_emit(ptr %t298)
  call void @fn_emit(ptr @.str1221)
  br label %ifend27
ifend27:
  %t299 = load ptr, ptr %t46
  call void @fn_emit(ptr %t299)
  call void @fn_emit(ptr @.str1222)
  %t300 = load ptr, ptr %t4
  %t301 = call ptr @fn_str_concat(ptr @.str1223, ptr %t300)
  %t302 = call ptr @fn_emit_bind(ptr %t301)
  store ptr %t302, ptr %t303
  %t304 = load ptr, ptr %t303
  %t305 = call ptr @fn_str_concat(ptr @.str1224, ptr %t304)
  %t306 = call ptr @fn_str_concat(ptr %t305, ptr @.str1225)
  %t307 = call ptr @fn_emit_bind(ptr %t306)
  store ptr %t307, ptr %t308
  %t309 = load ptr, ptr %t308
  %t310 = load ptr, ptr %t4
  call void @fn_store_at(ptr @.str1226, ptr %t309, ptr %t310)
  call void @fn_emit(ptr @.str1227)
  %t311 = load ptr, ptr %t42
  call void @fn_emit(ptr %t311)
  call void @fn_emit(ptr @.str1228)
  %t312 = load ptr, ptr %t48
  call void @fn_emit(ptr %t312)
  call void @fn_emit(ptr @.str1229)
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
  %t13 = call ptr @fn_str_concat(ptr @.str1230, ptr %t12)
  call void @fn_perr(ptr %t13)
  br label %ifend2
ifend2:
  %t14 = call ptr @fn_nreg()
  store ptr %t14, ptr %t15
  call void @fn_emit(ptr @.str1231)
  %t16 = load ptr, ptr %t15
  call void @fn_emit(ptr %t16)
  call void @fn_emit(ptr @.str1232)
  %t17 = load ptr, ptr %t4
  call void @fn_emit(ptr %t17)
  call void @fn_emit(ptr @.str1233)
  %t18 = load ptr, ptr %t1
  call void @fn_emit(ptr %t18)
  call void @fn_emit(ptr @.str1234)
  %t19 = load ptr, ptr %t0
  call void @fn_emit(ptr %t19)
  call void @fn_emit(ptr @.str1235)
  call void @fn_emit(ptr @.str1236)
  %t20 = load ptr, ptr %t15
  call void @fn_emit(ptr %t20)
  call void @fn_emit(ptr @.str1237)
  %t21 = call ptr @fn_nreg()
  store ptr %t21, ptr %t22
  call void @fn_emit(ptr @.str1238)
  %t23 = load ptr, ptr %t22
  call void @fn_emit(ptr %t23)
  call void @fn_emit(ptr @.str1239)
  %t24 = load ptr, ptr %t4
  call void @fn_emit(ptr %t24)
  call void @fn_emit(ptr @.str1240)
  %t25 = load ptr, ptr %t1
  call void @fn_emit(ptr %t25)
  call void @fn_emit(ptr @.str1241)
  %t26 = load ptr, ptr %t1
  call void @fn_emit(ptr %t26)
  call void @fn_emit(ptr @.str1242)
  %t27 = load ptr, ptr %t0
  call void @fn_emit(ptr %t27)
  call void @fn_emit(ptr @.str1243)
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
  call void @fn_emit(ptr @.str1244)
  %t49 = load ptr, ptr %t48
  call void @fn_emit(ptr %t49)
  call void @fn_emit(ptr @.str1245)
  %t50 = load ptr, ptr %t1
  call void @fn_emit(ptr %t50)
  call void @fn_emit(ptr @.str1246)
  %t51 = load ptr, ptr %t22
  call void @fn_emit(ptr %t51)
  call void @fn_emit(ptr @.str1247)
  %t52 = load i32, ptr %t28
  %t53 = call ptr @fn_itoa(i32 %t52)
  call void @fn_emit(ptr %t53)
  call void @fn_emit(ptr @.str1248)
  %t54 = load ptr, ptr %t46
  %t55 = getelementptr inbounds %Cmp_Node, ptr %t54, i32 0, i32 3
  %t56 = load ptr, ptr %t55
  %t57 = call ptr @fn_llty(ptr %t56)
  store ptr %t57, ptr %t58
  store ptr @.str1249, ptr %t59
  %t60 = load ptr, ptr %t58
  %t61 = call i32 @fn_str_eq(ptr %t60, ptr @.str1250)
  %t62 = icmp ne i32 %t61, 0
  br i1 %t62, label %then6, label %ifend8
then6:
  store ptr @.str1251, ptr %t59
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
  call void @fn_emit(ptr @.str1252)
  %t77 = load ptr, ptr %t58
  call void @fn_emit(ptr %t77)
  call void @fn_emit(ptr @.str1253)
  %t78 = load ptr, ptr %t59
  call void @fn_emit(ptr %t78)
  call void @fn_emit(ptr @.str1254)
  %t79 = load ptr, ptr %t48
  call void @fn_emit(ptr %t79)
  call void @fn_emit(ptr @.str1255)
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
  call void @fn_emit(ptr @.str1256)
  %t117 = load ptr, ptr %t116
  call void @fn_emit(ptr %t117)
  call void @fn_emit(ptr @.str1257)
  %t118 = load ptr, ptr %t1
  call void @fn_emit(ptr %t118)
  call void @fn_emit(ptr @.str1258)
  %t119 = load ptr, ptr %t22
  call void @fn_emit(ptr %t119)
  call void @fn_emit(ptr @.str1259)
  %t120 = load i32, ptr %t110
  %t121 = call ptr @fn_itoa(i32 %t120)
  call void @fn_emit(ptr %t121)
  call void @fn_emit(ptr @.str1260)
  %t122 = load ptr, ptr %t104
  %t123 = getelementptr inbounds %Cmp_Node, ptr %t122, i32 0, i32 4
  %t124 = load ptr, ptr %t123
  %t125 = call ptr @fn_emit_expr(ptr %t124)
  store ptr %t125, ptr %t126
  call void @fn_emit(ptr @.str1261)
  %t127 = load ptr, ptr %t7
  %t128 = load ptr, ptr %t104
  %t129 = getelementptr inbounds %Cmp_Node, ptr %t128, i32 0, i32 1
  %t130 = load ptr, ptr %t129
  %t131 = call ptr @fn_field_type(ptr %t127, ptr %t130)
  %t132 = call ptr @fn_llty(ptr %t131)
  call void @fn_emit(ptr %t132)
  call void @fn_emit(ptr @.str1262)
  %t133 = load ptr, ptr %t126
  %t134 = getelementptr inbounds %Cmp_Val, ptr %t133, i32 0, i32 0
  %t135 = load ptr, ptr %t134
  call void @fn_emit(ptr %t135)
  call void @fn_emit(ptr @.str1263)
  %t136 = load ptr, ptr %t116
  call void @fn_emit(ptr %t136)
  call void @fn_emit(ptr @.str1264)
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
  %t148 = call ptr @fn_emit_alloca(ptr @.str1265)
  store ptr %t148, ptr %t149
  call void @fn_emit(ptr @.str1266)
  %t150 = load ptr, ptr %t22
  call void @fn_emit(ptr %t150)
  call void @fn_emit(ptr @.str1267)
  %t151 = load ptr, ptr %t149
  call void @fn_emit(ptr %t151)
  call void @fn_emit(ptr @.str1268)
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
  call void @fn_emit(ptr @.str1269)
  %t27 = load ptr, ptr %t26
  call void @fn_emit(ptr %t27)
  call void @fn_emit(ptr @.str1270)
  %t28 = load ptr, ptr %t3
  call void @fn_emit(ptr %t28)
  call void @fn_emit(ptr @.str1271)
  %t29 = load ptr, ptr %t24
  call void @fn_emit(ptr %t29)
  call void @fn_emit(ptr @.str1272)
  %t30 = load ptr, ptr %t24
  call void @fn_emit(ptr %t30)
  call void @fn_emit(ptr @.str1273)
  %t31 = load ptr, ptr %t1
  call void @fn_emit(ptr %t31)
  call void @fn_emit(ptr @.str1274)
  %t32 = call ptr @fn_emit_alloca(ptr @.str1275)
  store ptr %t32, ptr %t33
  call void @fn_emit(ptr @.str1276)
  %t34 = load ptr, ptr %t26
  call void @fn_emit(ptr %t34)
  call void @fn_emit(ptr @.str1277)
  %t35 = load ptr, ptr %t33
  call void @fn_emit(ptr %t35)
  call void @fn_emit(ptr @.str1278)
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
  %t1 = call ptr @fn_emit_bind(ptr @.str1279)
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
  call void @fn_emit(ptr @.str1280)
  %t16 = load ptr, ptr %t15
  call void @fn_emit(ptr %t16)
  call void @fn_emit(ptr @.str1281)
  %t17 = load ptr, ptr %t13
  call void @fn_emit(ptr %t17)
  call void @fn_emit(ptr @.str1282)
  %t18 = load ptr, ptr %t2
  call void @fn_emit(ptr %t18)
  call void @fn_emit(ptr @.str1283)
  call void @fn_emit(ptr @.str1284)
  %t19 = load i32, ptr %t7
  %t20 = call ptr @fn_itoa(i32 %t19)
  call void @fn_emit(ptr %t20)
  call void @fn_emit(ptr @.str1285)
  %t21 = load ptr, ptr %t15
  call void @fn_emit(ptr %t21)
  call void @fn_emit(ptr @.str1286)
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
  call void @fn_emit(ptr @.str1287)
  %t16 = load ptr, ptr %t15
  call void @fn_emit(ptr %t16)
  call void @fn_emit(ptr @.str1288)
  %t17 = load ptr, ptr %t13
  call void @fn_emit(ptr %t17)
  call void @fn_emit(ptr @.str1289)
  %t18 = load ptr, ptr %t5
  %t19 = getelementptr inbounds %Cmp_Val, ptr %t18, i32 0, i32 0
  %t20 = load ptr, ptr %t19
  call void @fn_emit(ptr %t20)
  call void @fn_emit(ptr @.str1290)
  %t21 = load ptr, ptr %t15
  %t22 = call ptr @fn_str_concat(ptr @.str1291, ptr %t21)
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
  %t43 = call ptr @fn_str_concat(ptr @.str1292, ptr %t42)
  %t44 = call ptr @fn_str_concat(ptr %t43, ptr @.str1293)
  %t45 = load ptr, ptr %t41
  %t46 = call i32 @fn_find_arch_id(ptr %t45)
  %t47 = call ptr @fn_itoa(i32 %t46)
  %t48 = call ptr @fn_str_concat(ptr %t44, ptr %t47)
  %t49 = call ptr @fn_emit_bind(ptr %t48)
  store ptr %t49, ptr %t50
  %t51 = call ptr @fn_lbl(ptr @.str1294)
  store ptr %t51, ptr %t52
  %t53 = call ptr @fn_lbl(ptr @.str1295)
  store ptr %t53, ptr %t54
  call void @fn_emit(ptr @.str1296)
  %t55 = load ptr, ptr %t50
  call void @fn_emit(ptr %t55)
  call void @fn_emit(ptr @.str1297)
  %t56 = load ptr, ptr %t52
  call void @fn_emit(ptr %t56)
  call void @fn_emit(ptr @.str1298)
  %t57 = load ptr, ptr %t54
  call void @fn_emit(ptr %t57)
  call void @fn_emit(ptr @.str1299)
  %t58 = load ptr, ptr %t52
  call void @fn_emit(ptr %t58)
  call void @fn_emit(ptr @.str1300)
  %t59 = load ptr, ptr %t41
  call void @fn_emit(ptr %t59)
  call void @fn_emit(ptr @.str1301)
  %t60 = load ptr, ptr %t5
  %t61 = getelementptr inbounds %Cmp_Val, ptr %t60, i32 0, i32 0
  %t62 = load ptr, ptr %t61
  call void @fn_emit(ptr %t62)
  call void @fn_emit(ptr @.str1302)
  call void @fn_emit(ptr @.str1303)
  %t63 = load ptr, ptr %t54
  call void @fn_emit(ptr %t63)
  call void @fn_emit(ptr @.str1304)
  %t64 = load ptr, ptr %t54
  call void @fn_emit(ptr %t64)
  call void @fn_emit(ptr @.str1305)
  %t65 = load i32, ptr %t25
  %t66 = add i32 %t65, 1
  store i32 %t66, ptr %t25
  br label %wcond3
wend5:
  br label %ifend2
ifend2:
  call void @fn_emit(ptr @.str1306)
  %t67 = load ptr, ptr %t5
  %t68 = getelementptr inbounds %Cmp_Val, ptr %t67, i32 0, i32 0
  %t69 = load ptr, ptr %t68
  call void @fn_emit(ptr %t69)
  call void @fn_emit(ptr @.str1307)
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
  store ptr @.str1308, ptr %t1
  %t2 = load ptr, ptr %t0
  %t3 = getelementptr inbounds %Cmp_Node, ptr %t2, i32 0, i32 2
  %t4 = load i32, ptr %t3
  %t5 = icmp eq i32 %t4, 1
  %t6 = zext i1 %t5 to i32
  %t7 = icmp ne i32 %t6, 0
  br i1 %t7, label %then0, label %ifend2
then0:
  store ptr @.str1309, ptr %t1
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
  call void @fn_emit(ptr @.str1310)
  %t23 = load ptr, ptr %t22
  call void @fn_emit(ptr %t23)
  call void @fn_emit(ptr @.str1311)
  %t24 = load ptr, ptr %t20
  call void @fn_emit(ptr %t24)
  call void @fn_emit(ptr @.str1312)
  %t25 = load ptr, ptr %t0
  %t26 = getelementptr inbounds %Cmp_Node, ptr %t25, i32 0, i32 1
  %t27 = load ptr, ptr %t26
  call void @fn_emit(ptr %t27)
  call void @fn_emit(ptr @.str1313)
  %t28 = load ptr, ptr %t18
  %t29 = getelementptr inbounds %Cmp_Val, ptr %t28, i32 0, i32 0
  %t30 = load ptr, ptr %t29
  call void @fn_emit(ptr %t30)
  call void @fn_emit(ptr @.str1314)
  call void @fn_emit(ptr @.str1315)
  %t31 = load ptr, ptr %t1
  call void @fn_emit(ptr %t31)
  call void @fn_emit(ptr @.str1316)
  %t32 = load ptr, ptr %t22
  call void @fn_emit(ptr %t32)
  call void @fn_emit(ptr @.str1317)
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
  call void @fn_emit(ptr @.str1318)
  %t56 = load ptr, ptr %t55
  call void @fn_emit(ptr %t56)
  call void @fn_emit(ptr @.str1319)
  %t57 = load ptr, ptr %t20
  call void @fn_emit(ptr %t57)
  call void @fn_emit(ptr @.str1320)
  %t58 = load ptr, ptr %t0
  %t59 = getelementptr inbounds %Cmp_Node, ptr %t58, i32 0, i32 1
  %t60 = load ptr, ptr %t59
  call void @fn_emit(ptr %t60)
  call void @fn_emit(ptr @.str1321)
  %t61 = load ptr, ptr %t0
  %t62 = getelementptr inbounds %Cmp_Node, ptr %t61, i32 0, i32 1
  %t63 = load ptr, ptr %t62
  call void @fn_emit(ptr %t63)
  call void @fn_emit(ptr @.str1322)
  %t64 = load ptr, ptr %t18
  %t65 = getelementptr inbounds %Cmp_Val, ptr %t64, i32 0, i32 0
  %t66 = load ptr, ptr %t65
  call void @fn_emit(ptr %t66)
  call void @fn_emit(ptr @.str1323)
  %t67 = call ptr @fn_emit_alloca(ptr @.str1324)
  store ptr %t67, ptr %t68
  call void @fn_emit(ptr @.str1325)
  %t69 = load ptr, ptr %t55
  call void @fn_emit(ptr %t69)
  call void @fn_emit(ptr @.str1326)
  %t70 = load ptr, ptr %t68
  call void @fn_emit(ptr %t70)
  call void @fn_emit(ptr @.str1327)
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
  store ptr @.str1328, ptr %t80
  %t81 = load ptr, ptr %t0
  %t82 = getelementptr inbounds %Cmp_Node, ptr %t81, i32 0, i32 1
  %t83 = load ptr, ptr %t82
  %t84 = call i32 @fn_is_model(ptr %t83)
  %t85 = icmp ne i32 %t84, 0
  br i1 %t85, label %then12, label %ifend14
then12:
  store ptr @.str1329, ptr %t80
  br label %ifend14
ifend14:
  call void @fn_emit(ptr @.str1330)
  %t86 = load ptr, ptr %t1
  call void @fn_emit(ptr %t86)
  call void @fn_emit(ptr @.str1331)
  %t87 = load ptr, ptr %t80
  call void @fn_emit(ptr %t87)
  %t88 = load ptr, ptr %t0
  %t89 = getelementptr inbounds %Cmp_Node, ptr %t88, i32 0, i32 1
  %t90 = load ptr, ptr %t89
  call void @fn_emit(ptr %t90)
  call void @fn_emit(ptr @.str1332)
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
  store ptr @.str1333, ptr @g_ret_ty
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
  call void @fn_emit(ptr @.str1334)
  br label %ifend2
ifend2:
  call void @fn_emit(ptr @.str1335)
  %t14 = load ptr, ptr %t5
  store ptr %t14, ptr @g_code
  call void @fn_emit(ptr @.str1336)
  %t15 = load ptr, ptr %t0
  %t16 = getelementptr inbounds %Cmp_Node, ptr %t15, i32 0, i32 1
  %t17 = load ptr, ptr %t16
  call void @fn_emit(ptr %t17)
  call void @fn_emit(ptr @.str1337)
  %t18 = load ptr, ptr @g_falloc
  %t19 = call ptr @fn_buf_str(ptr %t18)
  call void @fn_emit(ptr %t19)
  %t20 = load ptr, ptr %t2
  %t21 = call ptr @fn_buf_str(ptr %t20)
  call void @fn_emit(ptr %t21)
  call void @fn_emit(ptr @.str1338)
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
  %t36 = call ptr @fn_str_concat(ptr @.str1339, ptr %t35)
  %t37 = call ptr @fn_emit_bind(ptr %t36)
  store ptr %t37, ptr %t38
  %t39 = load ptr, ptr %t38
  %t40 = call ptr @fn_str_concat(ptr @.str1340, ptr %t39)
  %t41 = call ptr @fn_str_concat(ptr %t40, ptr @.str1341)
  %t42 = call ptr @fn_emit_bind(ptr %t41)
  store ptr %t42, ptr %t43
  %t44 = call ptr @fn_lbl(ptr @.str1342)
  store ptr %t44, ptr %t45
  %t46 = call ptr @fn_lbl(ptr @.str1343)
  store ptr %t46, ptr %t47
  call void @fn_emit(ptr @.str1344)
  %t48 = load ptr, ptr %t43
  call void @fn_emit(ptr %t48)
  call void @fn_emit(ptr @.str1345)
  %t49 = load ptr, ptr %t45
  call void @fn_emit(ptr %t49)
  call void @fn_emit(ptr @.str1346)
  %t50 = load ptr, ptr %t47
  call void @fn_emit(ptr %t50)
  call void @fn_emit(ptr @.str1347)
  %t51 = load ptr, ptr %t45
  call void @fn_emit(ptr %t51)
  call void @fn_emit(ptr @.str1348)
  %t52 = load ptr, ptr %t15
  %t53 = getelementptr inbounds %Cmp_Node, ptr %t52, i32 0, i32 1
  %t54 = load ptr, ptr %t53
  call void @fn_emit(ptr %t54)
  call void @fn_emit(ptr @.str1349)
  call void @fn_emit(ptr @.str1350)
  %t55 = load ptr, ptr %t47
  call void @fn_emit(ptr %t55)
  call void @fn_emit(ptr @.str1351)
  %t56 = load ptr, ptr %t47
  call void @fn_emit(ptr %t56)
  call void @fn_emit(ptr @.str1352)
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
  store ptr @.str1353, ptr @g_ret_ty
  %t20 = call ptr @fn_buf_new()
  store ptr %t20, ptr %t21
  %t22 = call ptr @fn_buf_new()
  store ptr %t22, ptr @g_falloc
  %t23 = load ptr, ptr @g_code
  store ptr %t23, ptr %t24
  %t25 = load ptr, ptr %t21
  store ptr %t25, ptr @g_code
  %t26 = load ptr, ptr %t19
  call void @fn_emit_bind_props(ptr %t26, ptr @.str1354)
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
  call void @fn_emit(ptr @.str1355)
  br label %ifend5
ifend5:
  call void @fn_emit(ptr @.str1356)
  %t34 = load ptr, ptr %t24
  store ptr %t34, ptr @g_code
  call void @fn_emit(ptr @.str1357)
  %t35 = load ptr, ptr %t14
  %t36 = getelementptr inbounds %Cmp_Node, ptr %t35, i32 0, i32 1
  %t37 = load ptr, ptr %t36
  call void @fn_emit(ptr %t37)
  call void @fn_emit(ptr @.str1358)
  %t38 = load ptr, ptr @g_falloc
  %t39 = call ptr @fn_buf_str(ptr %t38)
  call void @fn_emit(ptr %t39)
  %t40 = load ptr, ptr %t21
  %t41 = call ptr @fn_buf_str(ptr %t40)
  call void @fn_emit(ptr %t41)
  call void @fn_emit(ptr @.str1359)
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
  call void @fn_emit(ptr @.str1360)
  call void @fn_emit(ptr @.str1361)
  call void @fn_emit(ptr @.str1362)
  %t27 = call ptr @fn_find_fn(ptr @.str1363)
  %t28 = icmp ne ptr %t27, null
  %t29 = zext i1 %t28 to i32
  %t30 = icmp ne i32 %t29, 0
  br i1 %t30, label %then6, label %ifend8
then6:
  call void @fn_emit(ptr @.str1364)
  br label %ifend8
ifend8:
  call void @fn_emit_calls_for_phase(ptr @.str1365)
  call void @fn_emit(ptr @.str1366)
  call void @fn_emit(ptr @.str1367)
  %t31 = call ptr @fn_emit_bind(ptr @.str1368)
  store ptr %t31, ptr %t32
  %t33 = load ptr, ptr %t32
  %t34 = call ptr @fn_str_concat(ptr @.str1369, ptr %t33)
  %t35 = call ptr @fn_str_concat(ptr %t34, ptr @.str1370)
  %t36 = call ptr @fn_emit_bind(ptr %t35)
  store ptr %t36, ptr %t37
  %t38 = call ptr @fn_find_fn(ptr @.str1371)
  %t39 = icmp ne ptr %t38, null
  %t40 = zext i1 %t39 to i32
  %t41 = icmp ne i32 %t40, 0
  br i1 %t41, label %then9, label %else10
then9:
  %t42 = call ptr @fn_emit_bind(ptr @.str1372)
  store ptr %t42, ptr %t43
  %t44 = load ptr, ptr %t43
  %t45 = call ptr @fn_str_concat(ptr @.str1373, ptr %t44)
  %t46 = call ptr @fn_str_concat(ptr %t45, ptr @.str1374)
  %t47 = call ptr @fn_emit_bind(ptr %t46)
  store ptr %t47, ptr %t48
  %t49 = load ptr, ptr %t37
  %t50 = call ptr @fn_str_concat(ptr @.str1375, ptr %t49)
  %t51 = call ptr @fn_str_concat(ptr %t50, ptr @.str1376)
  %t52 = load ptr, ptr %t48
  %t53 = call ptr @fn_str_concat(ptr %t51, ptr %t52)
  %t54 = call ptr @fn_emit_bind(ptr %t53)
  store ptr %t54, ptr %t55
  call void @fn_emit(ptr @.str1377)
  %t56 = load ptr, ptr %t55
  call void @fn_emit(ptr %t56)
  call void @fn_emit(ptr @.str1378)
  br label %ifend11
else10:
  call void @fn_emit(ptr @.str1379)
  %t57 = load ptr, ptr %t37
  call void @fn_emit(ptr %t57)
  call void @fn_emit(ptr @.str1380)
  br label %ifend11
ifend11:
  call void @fn_emit(ptr @.str1381)
  %t58 = call ptr @fn_find_fn(ptr @.str1382)
  %t59 = icmp ne ptr %t58, null
  %t60 = zext i1 %t59 to i32
  %t61 = icmp ne i32 %t60, 0
  br i1 %t61, label %then12, label %ifend14
then12:
  %t62 = call ptr @fn_emit_bind(ptr @.str1383)
  store ptr %t62, ptr %t63
  call void @fn_emit(ptr @.str1384)
  %t64 = load ptr, ptr %t63
  call void @fn_emit(ptr %t64)
  call void @fn_emit(ptr @.str1385)
  br label %ifend14
ifend14:
  call void @fn_emit_calls_for_phase(ptr @.str1386)
  call void @fn_emit_calls_for_phase(ptr @.str1387)
  call void @fn_emit_calls_for_phase(ptr @.str1388)
  call void @fn_emit_calls_for_phase(ptr @.str1389)
  call void @fn_emit_calls_for_phase(ptr @.str1390)
  call void @fn_emit(ptr @.str1391)
  call void @fn_emit(ptr @.str1392)
  call void @fn_emit_calls_for_phase(ptr @.str1393)
  %t65 = call ptr @fn_find_fn(ptr @.str1394)
  %t66 = icmp ne ptr %t65, null
  %t67 = zext i1 %t66 to i32
  %t68 = icmp ne i32 %t67, 0
  br i1 %t68, label %then15, label %ifend17
then15:
  call void @fn_emit(ptr @.str1395)
  br label %ifend17
ifend17:
  call void @fn_emit(ptr @.str1396)
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
  %t9 = call ptr @fn_str_concat(ptr @.str1397, ptr %t8)
  %t10 = call ptr @fn_str_concat(ptr %t9, ptr @.str1398)
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
  %t48 = call ptr @fn_lbl(ptr @.str1399)
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
  %t75 = call ptr @fn_str_concat(ptr @.str1400, ptr %t74)
  %t76 = call ptr @fn_str_concat(ptr %t75, ptr @.str1401)
  %t77 = load ptr, ptr %t73
  %t78 = getelementptr inbounds %Cmp_Val, ptr %t77, i32 0, i32 0
  %t79 = load ptr, ptr %t78
  %t80 = call ptr @fn_str_concat(ptr %t76, ptr %t79)
  %t81 = call ptr @fn_emit_bind(ptr %t80)
  store ptr %t81, ptr %t82
  %t83 = call ptr @fn_lbl(ptr @.str1402)
  store ptr %t83, ptr %t84
  %t85 = call ptr @fn_lbl(ptr @.str1403)
  store ptr %t85, ptr %t86
  call void @fn_emit(ptr @.str1404)
  %t87 = load ptr, ptr %t82
  call void @fn_emit(ptr %t87)
  call void @fn_emit(ptr @.str1405)
  %t88 = load ptr, ptr %t84
  call void @fn_emit(ptr %t88)
  call void @fn_emit(ptr @.str1406)
  %t89 = load ptr, ptr %t86
  call void @fn_emit(ptr %t89)
  call void @fn_emit(ptr @.str1407)
  %t90 = load ptr, ptr %t84
  call void @fn_emit(ptr %t90)
  call void @fn_emit(ptr @.str1408)
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
  call void @fn_emit(ptr @.str1409)
  %t98 = load ptr, ptr %t49
  call void @fn_emit(ptr %t98)
  call void @fn_emit(ptr @.str1410)
  br label %ifend10
ifend10:
  %t99 = load ptr, ptr %t86
  call void @fn_emit(ptr %t99)
  call void @fn_emit(ptr @.str1411)
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
  call void @fn_emit(ptr @.str1412)
  %t106 = load ptr, ptr %t49
  call void @fn_emit(ptr %t106)
  call void @fn_emit(ptr @.str1413)
  br label %ifend13
ifend13:
  %t107 = load ptr, ptr %t49
  call void @fn_emit(ptr %t107)
  call void @fn_emit(ptr @.str1414)
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
  call void @fn_perr(ptr @.str1415)
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
  %t56 = call ptr @fn_str_concat(ptr @.str1416, ptr %t55)
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
  call void @fn_emit(ptr @.str1417)
  %t67 = load ptr, ptr %t61
  %t68 = getelementptr inbounds %Cmp_Val, ptr %t67, i32 0, i32 0
  %t69 = load ptr, ptr %t68
  call void @fn_emit(ptr %t69)
  call void @fn_emit(ptr @.str1418)
  %t70 = load ptr, ptr %t66
  %t71 = getelementptr inbounds %Cmp_Val, ptr %t70, i32 0, i32 0
  %t72 = load ptr, ptr %t71
  call void @fn_emit(ptr %t72)
  call void @fn_emit(ptr @.str1419)
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
  %t5 = call ptr @fn_str_concat(ptr @.str1420, ptr %t4)
  store ptr %t5, ptr %t6
  %t7 = load i32, ptr @g_g_iok
  %t8 = add i32 %t7, 1
  store i32 %t8, ptr @g_g_iok
  call void @fn_emit(ptr @.str1421)
  %t9 = load ptr, ptr %t6
  call void @fn_emit(ptr %t9)
  call void @fn_emit(ptr @.str1422)
  %t10 = load ptr, ptr %t0
  call void @fn_emit(ptr %t10)
  call void @fn_emit(ptr @.str1423)
  %t11 = load ptr, ptr %t1
  call void @fn_emit(ptr %t11)
  call void @fn_emit(ptr @.str1424)
  %t12 = load ptr, ptr %t2
  call void @fn_emit(ptr %t12)
  call void @fn_emit(ptr @.str1425)
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
  call void @fn_emit_io(ptr %t3, ptr @.str1426, ptr @.str1427)
  %t4 = load ptr, ptr %t0
  call void @fn_emit_io(ptr %t4, ptr @.str1428, ptr @.str1429)
  call void @fn_emit(ptr @.str1430)
  %t5 = load ptr, ptr %t2
  call void @fn_emit(ptr %t5)
  call void @fn_emit(ptr @.str1431)
  %t6 = load ptr, ptr %t0
  call void @fn_emit_io(ptr %t6, ptr @.str1432, ptr @.str1433)
  %t7 = load ptr, ptr %t0
  call void @fn_emit_io(ptr %t7, ptr @.str1434, ptr @.str1435)
  %t8 = load ptr, ptr %t0
  call void @fn_emit_io(ptr %t8, ptr @.str1436, ptr @.str1437)
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
  %t37 = call ptr @fn_str_concat(ptr @.str1438, ptr %t36)
  call void @fn_emit_io(ptr %t28, ptr %t37, ptr @.str1439)
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
  %t70 = call ptr @fn_str_concat(ptr @.str1440, ptr %t69)
  store ptr %t70, ptr %t71
  call void @fn_emit(ptr @.str1441)
  %t72 = load ptr, ptr %t71
  call void @fn_emit(ptr %t72)
  call void @fn_emit(ptr @.str1442)
  %t73 = load ptr, ptr %t67
  call void @fn_emit(ptr %t73)
  call void @fn_emit(ptr @.str1443)
  %t74 = load ptr, ptr %t2
  call void @fn_emit(ptr %t74)
  call void @fn_emit(ptr @.str1444)
  %t75 = load ptr, ptr %t0
  %t76 = load ptr, ptr %t67
  %t77 = call ptr @fn_str_concat(ptr @.str1445, ptr %t76)
  %t78 = load ptr, ptr %t71
  call void @fn_emit_io(ptr %t75, ptr %t77, ptr %t78)
  %t79 = load ptr, ptr %t0
  %t80 = load ptr, ptr %t67
  %t81 = call ptr @fn_str_concat(ptr @.str1446, ptr %t80)
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
  call void @fn_emith(ptr @.str1447)
  call void @fn_emith(ptr @.str1448)
  call void @fn_emith(ptr @.str1449)
  %t0 = call ptr @fn_find_fn(ptr @.str1450)
  %t1 = icmp ne ptr %t0, null
  %t2 = zext i1 %t1 to i32
  store i32 %t2, ptr %t3
  %t4 = call ptr @fn_find_fn(ptr @.str1451)
  %t5 = icmp ne ptr %t4, null
  %t6 = zext i1 %t5 to i32
  store i32 %t6, ptr %t7
  call void @fn_emit(ptr @.str1452)
  call void @fn_emit(ptr @.str1453)
  call void @fn_emit(ptr @.str1454)
  call void @fn_emit(ptr @.str1455)
  call void @fn_emit_snapshot_blocks(ptr @.str1456)
  %t8 = load i32, ptr %t3
  %t9 = icmp ne i32 %t8, 0
  br i1 %t9, label %then0, label %ifend2
then0:
  call void @fn_emit(ptr @.str1457)
  br label %ifend2
ifend2:
  call void @fn_emit(ptr @.str1458)
  call void @fn_emit(ptr @.str1459)
  call void @fn_emit(ptr @.str1460)
  call void @fn_emit(ptr @.str1461)
  call void @fn_emit(ptr @.str1462)
  call void @fn_emit_snapshot_blocks(ptr @.str1463)
  %t10 = load i32, ptr %t7
  %t11 = icmp ne i32 %t10, 0
  br i1 %t11, label %then3, label %ifend5
then3:
  call void @fn_emit(ptr @.str1464)
  br label %ifend5
ifend5:
  call void @fn_emit(ptr @.str1465)
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
  %t6 = call i32 @fn_str_eq(ptr %t5, ptr @.str1466)
  %t7 = icmp ne i32 %t6, 0
  br i1 %t7, label %then0, label %ifend2
then0:
  store i32 0, ptr %retval
  br label %ret
ifend2:
  %t8 = load ptr, ptr %t4
  %t9 = call i32 @fn_str_eq(ptr %t8, ptr @.str1467)
  %t10 = icmp ne i32 %t9, 0
  br i1 %t10, label %then3, label %ifend5
then3:
  store i32 1, ptr %retval
  br label %ret
ifend5:
  %t11 = load ptr, ptr %t4
  %t12 = call i32 @fn_str_eq(ptr %t11, ptr @.str1468)
  %t13 = icmp ne i32 %t12, 0
  br i1 %t13, label %then6, label %ifend8
then6:
  store i32 2, ptr %retval
  br label %ret
ifend8:
  %t14 = load ptr, ptr %t4
  %t15 = call i32 @fn_str_eq(ptr %t14, ptr @.str1469)
  %t16 = icmp ne i32 %t15, 0
  br i1 %t16, label %then9, label %ifend11
then9:
  store i32 3, ptr %retval
  br label %ret
ifend11:
  %t17 = load ptr, ptr %t4
  %t18 = call i32 @fn_str_eq(ptr %t17, ptr @.str1470)
  %t19 = icmp ne i32 %t18, 0
  br i1 %t19, label %then12, label %ifend14
then12:
  store i32 4, ptr %retval
  br label %ret
ifend14:
  %t20 = load ptr, ptr %t4
  %t21 = call i32 @fn_str_eq(ptr %t20, ptr @.str1471)
  %t22 = icmp ne i32 %t21, 0
  br i1 %t22, label %then15, label %ifend17
then15:
  store i32 5, ptr %retval
  br label %ret
ifend17:
  %t23 = load ptr, ptr %t4
  %t24 = call i32 @fn_str_eq(ptr %t23, ptr @.str1472)
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
  %t3 = call i64 @strlen(ptr %t2)
  %t4 = trunc i64 %t3 to i32
  %t5 = call ptr @fn_str_slice(ptr %t1, i32 3, i32 %t4)
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
  %t78 = call ptr @fn_ui_prop(ptr %t77, ptr @.str1473)
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
  %t5 = call i64 @strlen(ptr %t4)
  %t6 = trunc i64 %t5 to i32
  %t7 = icmp sgt i32 %t6, 3
  %t8 = zext i1 %t7 to i32
  %t9 = icmp ne i32 %t8, 0
  %t10 = zext i1 %t9 to i32
  store i32 %t10, ptr %t3
  br i1 %t9, label %sc0, label %scend1
sc0:
  %t11 = load ptr, ptr %t0
  %t12 = getelementptr inbounds i8, ptr %t11, i32 0
  %t13 = load i8, ptr %t12
  %t14 = zext i8 %t13 to i32
  %t15 = icmp eq i32 %t14, 85
  %t16 = zext i1 %t15 to i32
  %t17 = icmp ne i32 %t16, 0
  %t18 = zext i1 %t17 to i32
  store i32 %t18, ptr %t3
  br label %scend1
scend1:
  %t19 = load i32, ptr %t3
  %t20 = icmp ne i32 %t19, 0
  %t21 = zext i1 %t20 to i32
  store i32 %t21, ptr %t2
  br i1 %t20, label %sc2, label %scend3
sc2:
  %t22 = load ptr, ptr %t0
  %t23 = getelementptr inbounds i8, ptr %t22, i32 1
  %t24 = load i8, ptr %t23
  %t25 = zext i8 %t24 to i32
  %t26 = icmp eq i32 %t25, 73
  %t27 = zext i1 %t26 to i32
  %t28 = icmp ne i32 %t27, 0
  %t29 = zext i1 %t28 to i32
  store i32 %t29, ptr %t2
  br label %scend3
scend3:
  %t30 = load i32, ptr %t2
  %t31 = icmp ne i32 %t30, 0
  %t32 = zext i1 %t31 to i32
  store i32 %t32, ptr %t1
  br i1 %t31, label %sc4, label %scend5
sc4:
  %t33 = load ptr, ptr %t0
  %t34 = getelementptr inbounds i8, ptr %t33, i32 2
  %t35 = load i8, ptr %t34
  %t36 = zext i8 %t35 to i32
  %t37 = icmp eq i32 %t36, 95
  %t38 = zext i1 %t37 to i32
  %t39 = icmp ne i32 %t38, 0
  %t40 = zext i1 %t39 to i32
  store i32 %t40, ptr %t1
  br label %scend5
scend5:
  %t41 = load i32, ptr %t1
  store i32 %t41, ptr %retval
  br label %ret
ret:
  %t42 = load i32, ptr %retval
  ret i32 %t42
}

define void @fn_ll_ui_set(i32 %arg_idx, i32 %arg_key, ptr %arg_val) {
entry:
  %t0 = alloca i32
  %t1 = alloca i32
  %t2 = alloca ptr
  store i32 %arg_idx, ptr %t0
  store i32 %arg_key, ptr %t1
  store ptr %arg_val, ptr %t2
  call void @fn_emit(ptr @.str1474)
  %t3 = load i32, ptr %t0
  %t4 = call ptr @fn_itoa(i32 %t3)
  call void @fn_emit(ptr %t4)
  call void @fn_emit(ptr @.str1475)
  %t5 = load i32, ptr %t1
  %t6 = call ptr @fn_itoa(i32 %t5)
  call void @fn_emit(ptr %t6)
  call void @fn_emit(ptr @.str1476)
  %t7 = load ptr, ptr %t2
  call void @fn_emit(ptr %t7)
  call void @fn_emit(ptr @.str1477)
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
  %t2 = call i32 @fn_str_eq(ptr %t1, ptr @.str1478)
  %t3 = icmp ne i32 %t2, 0
  br i1 %t3, label %then0, label %ifend2
then0:
  store i32 2, ptr %retval
  br label %ret
ifend2:
  %t4 = load ptr, ptr %t0
  %t5 = call i32 @fn_str_eq(ptr %t4, ptr @.str1479)
  %t6 = icmp ne i32 %t5, 0
  br i1 %t6, label %then3, label %ifend5
then3:
  store i32 3, ptr %retval
  br label %ret
ifend5:
  %t7 = load ptr, ptr %t0
  %t8 = call i32 @fn_str_eq(ptr %t7, ptr @.str1480)
  %t9 = icmp ne i32 %t8, 0
  br i1 %t9, label %then6, label %ifend8
then6:
  store i32 4, ptr %retval
  br label %ret
ifend8:
  %t10 = load ptr, ptr %t0
  %t11 = call i32 @fn_str_eq(ptr %t10, ptr @.str1481)
  %t12 = icmp ne i32 %t11, 0
  br i1 %t12, label %then9, label %ifend11
then9:
  store i32 5, ptr %retval
  br label %ret
ifend11:
  %t13 = load ptr, ptr %t0
  %t14 = call i32 @fn_str_eq(ptr %t13, ptr @.str1482)
  %t15 = icmp ne i32 %t14, 0
  br i1 %t15, label %then12, label %ifend14
then12:
  store i32 7, ptr %retval
  br label %ret
ifend14:
  %t16 = load ptr, ptr %t0
  %t17 = call i32 @fn_str_eq(ptr %t16, ptr @.str1483)
  %t18 = icmp ne i32 %t17, 0
  br i1 %t18, label %then15, label %ifend17
then15:
  store i32 8, ptr %retval
  br label %ret
ifend17:
  %t19 = load ptr, ptr %t0
  %t20 = call i32 @fn_str_eq(ptr %t19, ptr @.str1484)
  %t21 = icmp ne i32 %t20, 0
  br i1 %t21, label %then18, label %ifend20
then18:
  store i32 9, ptr %retval
  br label %ret
ifend20:
  %t22 = load ptr, ptr %t0
  %t23 = call i32 @fn_str_eq(ptr %t22, ptr @.str1485)
  %t24 = icmp ne i32 %t23, 0
  br i1 %t24, label %then21, label %ifend23
then21:
  store i32 10, ptr %retval
  br label %ret
ifend23:
  %t25 = load ptr, ptr %t0
  %t26 = call i32 @fn_str_eq(ptr %t25, ptr @.str1486)
  %t27 = icmp ne i32 %t26, 0
  br i1 %t27, label %then24, label %ifend26
then24:
  store i32 11, ptr %retval
  br label %ret
ifend26:
  %t28 = load ptr, ptr %t0
  %t29 = call i32 @fn_str_eq(ptr %t28, ptr @.str1487)
  %t30 = icmp ne i32 %t29, 0
  br i1 %t30, label %then27, label %ifend29
then27:
  store i32 13, ptr %retval
  br label %ret
ifend29:
  %t31 = load ptr, ptr %t0
  %t32 = call i32 @fn_str_eq(ptr %t31, ptr @.str1488)
  %t33 = icmp ne i32 %t32, 0
  br i1 %t33, label %then30, label %ifend32
then30:
  store i32 14, ptr %retval
  br label %ret
ifend32:
  %t34 = load ptr, ptr %t0
  %t35 = call i32 @fn_str_eq(ptr %t34, ptr @.str1489)
  %t36 = icmp ne i32 %t35, 0
  br i1 %t36, label %then33, label %ifend35
then33:
  store i32 15, ptr %retval
  br label %ret
ifend35:
  %t37 = load ptr, ptr %t0
  %t38 = call i32 @fn_str_eq(ptr %t37, ptr @.str1490)
  %t39 = icmp ne i32 %t38, 0
  br i1 %t39, label %then36, label %ifend38
then36:
  store i32 16, ptr %retval
  br label %ret
ifend38:
  %t40 = load ptr, ptr %t0
  %t41 = call i32 @fn_str_eq(ptr %t40, ptr @.str1491)
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
  call void @fn_emit(ptr @.str1492)
  %t6 = load ptr, ptr @g_uiw
  %t7 = getelementptr inbounds %LSlice, ptr %t6, i32 0, i32 1
  %t8 = load i32, ptr %t7
  %t9 = call ptr @fn_itoa(i32 %t8)
  call void @fn_emit(ptr %t9)
  call void @fn_emit(ptr @.str1493)
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
  call void @fn_ll_ui_set(i32 %t43, i32 17, ptr @.str1494)
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
  %t76 = call i32 @fn_str_eq(ptr %t75, ptr @.str1495)
  %t77 = icmp ne i32 %t76, 0
  br i1 %t77, label %then9, label %ifend11
then9:
  %t78 = load i32, ptr %t44
  %t79 = add i32 %t78, 1
  store i32 %t79, ptr %t44
  br label %wcond6
ifend11:
  %t80 = load ptr, ptr %t70
  %t81 = call i32 @fn_str_eq(ptr %t80, ptr @.str1496)
  %t82 = icmp ne i32 %t81, 0
  br i1 %t82, label %then12, label %else13
then12:
  %t83 = load ptr, ptr %t74
  %t84 = call ptr @fn_emit_expr(ptr %t83)
  store ptr %t84, ptr %t85
  call void @fn_emit(ptr @.str1497)
  %t86 = load i32, ptr %t10
  %t87 = call ptr @fn_itoa(i32 %t86)
  call void @fn_emit(ptr %t87)
  call void @fn_emit(ptr @.str1498)
  %t88 = load ptr, ptr %t85
  %t89 = getelementptr inbounds %Cmp_Val, ptr %t88, i32 0, i32 0
  %t90 = load ptr, ptr %t89
  call void @fn_emit(ptr %t90)
  call void @fn_emit(ptr @.str1499)
  br label %ifend14
else13:
  %t92 = load ptr, ptr %t70
  %t93 = call i32 @fn_str_eq(ptr %t92, ptr @.str1500)
  %t94 = icmp ne i32 %t93, 0
  %t95 = zext i1 %t94 to i32
  store i32 %t95, ptr %t91
  br i1 %t94, label %scend16, label %sc15
sc15:
  %t96 = load ptr, ptr %t70
  %t97 = call i32 @fn_str_eq(ptr %t96, ptr @.str1501)
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
  %t108 = call ptr @fn_str_concat(ptr @.str1502, ptr %t107)
  %t109 = call ptr @fn_str_concat(ptr %t108, ptr @.str1503)
  %t110 = call ptr @fn_emit_bind(ptr %t109)
  store ptr %t110, ptr %t111
  %t112 = load ptr, ptr %t70
  %t113 = call i32 @fn_str_eq(ptr %t112, ptr @.str1504)
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
  %t120 = call i32 @fn_str_eq(ptr %t119, ptr @.str1505)
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
  %t132 = call i32 @fn_str_eq(ptr %t131, ptr @.str1506)
  %t133 = icmp ne i32 %t132, 0
  br i1 %t133, label %then29, label %ifend31
then29:
  store i32 1, ptr %t128
  br label %ifend31
ifend31:
  %t134 = load ptr, ptr %t74
  %t135 = getelementptr inbounds %Cmp_Node, ptr %t134, i32 0, i32 1
  %t136 = load ptr, ptr %t135
  %t137 = call i32 @fn_str_eq(ptr %t136, ptr @.str1507)
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
  call void @fn_ll_ui_set(i32 %t177, i32 6, ptr @.str1508)
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
  call void @fn_emit(ptr @.str1509)
  %t183 = load ptr, ptr @g_falloc
  %t184 = call ptr @fn_buf_str(ptr %t183)
  call void @fn_emit(ptr %t184)
  %t185 = load ptr, ptr %t1
  %t186 = call ptr @fn_buf_str(ptr %t185)
  call void @fn_emit(ptr %t186)
  call void @fn_emit(ptr @.str1510)
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
  call void @fn_emit(ptr @.str1511)
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
  call void @fn_emit(ptr @.str1512)
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
  %t14 = call i32 @fn_str_eq(ptr %t13, ptr @.str1513)
  %t15 = icmp eq i32 %t14, 0
  %t16 = zext i1 %t15 to i32
  %t17 = icmp ne i32 %t16, 0
  br i1 %t17, label %then0, label %ifend2
then0:
  %t18 = load ptr, ptr @g_falloc
  call void @fn_buf_puts(ptr %t18, ptr @.str1514)
  %t19 = load ptr, ptr @g_falloc
  %t20 = load ptr, ptr %t12
  call void @fn_buf_puts(ptr %t19, ptr %t20)
  %t21 = load ptr, ptr @g_falloc
  call void @fn_buf_puts(ptr %t21, ptr @.str1515)
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
  call void @fn_emit(ptr @.str1516)
  %t47 = load ptr, ptr %t40
  %t48 = getelementptr inbounds %Cmp_Node, ptr %t47, i32 0, i32 3
  %t49 = load ptr, ptr %t48
  %t50 = call ptr @fn_llty(ptr %t49)
  call void @fn_emit(ptr %t50)
  call void @fn_emit(ptr @.str1517)
  %t51 = load ptr, ptr %t40
  %t52 = getelementptr inbounds %Cmp_Node, ptr %t51, i32 0, i32 1
  %t53 = load ptr, ptr %t52
  call void @fn_emit(ptr %t53)
  call void @fn_emit(ptr @.str1518)
  %t54 = load ptr, ptr %t46
  call void @fn_emit(ptr %t54)
  call void @fn_emit(ptr @.str1519)
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
  call void @fn_emit(ptr @.str1520)
  br label %ifend8
ifend8:
  call void @fn_emit(ptr @.str1521)
  %t71 = load ptr, ptr %t12
  %t72 = call i32 @fn_str_eq(ptr %t71, ptr @.str1522)
  %t73 = icmp ne i32 %t72, 0
  br i1 %t73, label %then9, label %else10
then9:
  call void @fn_emit(ptr @.str1523)
  br label %ifend11
else10:
  %t74 = load ptr, ptr %t12
  %t75 = call ptr @fn_str_concat(ptr @.str1524, ptr %t74)
  %t76 = call ptr @fn_str_concat(ptr %t75, ptr @.str1525)
  %t77 = call ptr @fn_emit_bind(ptr %t76)
  store ptr %t77, ptr %t78
  call void @fn_emit(ptr @.str1526)
  %t79 = load ptr, ptr %t12
  call void @fn_emit(ptr %t79)
  call void @fn_emit(ptr @.str1527)
  %t80 = load ptr, ptr %t78
  call void @fn_emit(ptr %t80)
  call void @fn_emit(ptr @.str1528)
  br label %ifend11
ifend11:
  %t81 = load ptr, ptr %t8
  store ptr %t81, ptr @g_code
  call void @fn_emit(ptr @.str1529)
  %t82 = load ptr, ptr %t12
  call void @fn_emit(ptr %t82)
  call void @fn_emit(ptr @.str1530)
  %t83 = load ptr, ptr %t0
  %t84 = getelementptr inbounds %Cmp_Node, ptr %t83, i32 0, i32 1
  %t85 = load ptr, ptr %t84
  call void @fn_emit(ptr %t85)
  call void @fn_emit(ptr @.str1531)
  %t86 = load ptr, ptr %t0
  call void @fn_emit_params_sig(ptr %t86)
  call void @fn_emit(ptr @.str1532)
  %t87 = load ptr, ptr @g_falloc
  %t88 = call ptr @fn_buf_str(ptr %t87)
  call void @fn_emit(ptr %t88)
  %t89 = load ptr, ptr %t5
  %t90 = call ptr @fn_buf_str(ptr %t89)
  call void @fn_emit(ptr %t90)
  call void @fn_emit(ptr @.str1533)
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
  store ptr @.str1534, ptr @g_ret_ty
  %t1 = call ptr @fn_buf_new()
  store ptr %t1, ptr %t2
  %t3 = call ptr @fn_buf_new()
  store ptr %t3, ptr @g_falloc
  %t4 = load ptr, ptr @g_code
  store ptr %t4, ptr %t5
  %t6 = load ptr, ptr %t2
  store ptr %t6, ptr @g_code
  %t7 = load ptr, ptr @g_falloc
  call void @fn_buf_puts(ptr %t7, ptr @.str1535)
  call void @fn_emit(ptr @.str1536)
  call void @fn_emit(ptr @.str1537)
  call void @fn_emit(ptr @.str1538)
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
  call void @fn_emit(ptr @.str1539)
  br label %ifend2
ifend2:
  call void @fn_emit(ptr @.str1540)
  %t15 = call ptr @fn_emit_bind(ptr @.str1541)
  store ptr %t15, ptr %t16
  call void @fn_emit(ptr @.str1542)
  %t17 = load ptr, ptr %t16
  call void @fn_emit(ptr %t17)
  call void @fn_emit(ptr @.str1543)
  %t18 = load ptr, ptr %t5
  store ptr %t18, ptr @g_code
  call void @fn_emit(ptr @.str1544)
  %t19 = load ptr, ptr @g_falloc
  %t20 = call ptr @fn_buf_str(ptr %t19)
  call void @fn_emit(ptr %t20)
  %t21 = load ptr, ptr %t2
  %t22 = call ptr @fn_buf_str(ptr %t21)
  call void @fn_emit(ptr %t22)
  call void @fn_emit(ptr @.str1545)
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
  store i32 0, ptr @g_g_uses_intstr
  store i32 0, ptr @g_g_uses_strslice
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
  %t113 = load i32, ptr @g_g_uses_intstr
  %t114 = icmp ne i32 %t113, 0
  br i1 %t114, label %then27, label %ifend29
then27:
  call void @fn_emit_int_str()
  br label %ifend29
ifend29:
  %t115 = load i32, ptr @g_g_uses_strslice
  %t116 = icmp ne i32 %t115, 0
  br i1 %t116, label %then30, label %ifend32
then30:
  call void @fn_emit_str_slice()
  br label %ifend32
ifend32:
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
  %t12 = alloca ptr
  %t31 = alloca ptr
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
  %t11 = load ptr, ptr @__stdoutp
  store ptr %t11, ptr %t12
  %t13 = load ptr, ptr %t12
  %t14 = load ptr, ptr %t3
  %t15 = load ptr, ptr %t3
  %t16 = call i64 @strlen(ptr %t15)
  %t17 = trunc i64 %t16 to i32
  %t18 = zext i32 %t17 to i64
  %t19 = call i64 @fwrite(ptr %t14, i64 1, i64 %t18, ptr %t13)
  %t20 = trunc i64 %t19 to i32
  %t21 = load ptr, ptr %t12
  %t22 = load ptr, ptr %t6
  %t23 = load ptr, ptr %t6
  %t24 = call i64 @strlen(ptr %t23)
  %t25 = trunc i64 %t24 to i32
  %t26 = zext i32 %t25 to i64
  %t27 = call i64 @fwrite(ptr %t22, i64 1, i64 %t26, ptr %t21)
  %t28 = trunc i64 %t27 to i32
  store i32 1, ptr %retval
  br label %ret
ifend2:
  %t29 = load ptr, ptr %t0
  %t30 = call ptr @fopen(ptr %t29, ptr @.str1546)
  store ptr %t30, ptr %t31
  %t32 = load ptr, ptr %t31
  %t33 = icmp eq ptr %t32, null
  %t34 = zext i1 %t33 to i32
  %t35 = icmp ne i32 %t34, 0
  br i1 %t35, label %then3, label %ifend5
then3:
  store i32 0, ptr %retval
  br label %ret
ifend5:
  %t36 = load ptr, ptr %t31
  %t37 = load ptr, ptr %t3
  %t38 = load ptr, ptr %t3
  %t39 = call i64 @strlen(ptr %t38)
  %t40 = trunc i64 %t39 to i32
  %t41 = zext i32 %t40 to i64
  %t42 = call i64 @fwrite(ptr %t37, i64 1, i64 %t41, ptr %t36)
  %t43 = trunc i64 %t42 to i32
  %t44 = load ptr, ptr %t31
  %t45 = load ptr, ptr %t6
  %t46 = load ptr, ptr %t6
  %t47 = call i64 @strlen(ptr %t46)
  %t48 = trunc i64 %t47 to i32
  %t49 = zext i32 %t48 to i64
  %t50 = call i64 @fwrite(ptr %t45, i64 1, i64 %t49, ptr %t44)
  %t51 = trunc i64 %t50 to i32
  %t52 = load ptr, ptr %t31
  call i32 @fclose(ptr %t52)
  store i32 1, ptr %retval
  br label %ret
ret:
  %t53 = load i32, ptr %retval
  ret i32 %t53
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
  %t27 = call ptr @fn_str_slice(ptr %t23, i32 %t25, i32 %t26)
  store ptr %t27, ptr %retval
  br label %ret
ret:
  %t28 = load ptr, ptr %retval
  ret ptr %t28
}

define ptr @fn_strip_ludic(ptr %arg_name) {
entry:
  %retval = alloca ptr
  %t0 = alloca ptr
  %t4 = alloca i32
  store ptr %arg_name, ptr %t0
  %t1 = load ptr, ptr %t0
  %t2 = call i64 @strlen(ptr %t1)
  %t3 = trunc i64 %t2 to i32
  store i32 %t3, ptr %t4
  %t5 = load i32, ptr %t4
  %t6 = icmp sgt i32 %t5, 6
  %t7 = zext i1 %t6 to i32
  %t8 = icmp ne i32 %t7, 0
  br i1 %t8, label %then0, label %ifend2
then0:
  %t9 = load ptr, ptr %t0
  %t10 = load i32, ptr %t4
  %t11 = sub i32 %t10, 6
  %t12 = load i32, ptr %t4
  %t13 = call ptr @fn_str_slice(ptr %t9, i32 %t11, i32 %t12)
  %t14 = call i32 @fn_str_eq(ptr %t13, ptr @.str1547)
  %t15 = icmp ne i32 %t14, 0
  br i1 %t15, label %then3, label %ifend5
then3:
  %t16 = load ptr, ptr %t0
  %t17 = load i32, ptr %t4
  %t18 = sub i32 %t17, 6
  %t19 = call ptr @fn_str_slice(ptr %t16, i32 0, i32 %t18)
  store ptr %t19, ptr %retval
  br label %ret
ifend5:
  br label %ifend2
ifend2:
  %t20 = load ptr, ptr %t0
  store ptr %t20, ptr %retval
  br label %ret
ret:
  %t21 = load ptr, ptr %retval
  ret ptr %t21
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
  %t4 = alloca i32
  store ptr %arg_d, ptr %t0
  %t1 = load ptr, ptr %t0
  %t2 = call i64 @strlen(ptr %t1)
  %t3 = trunc i64 %t2 to i32
  store i32 %t3, ptr %t4
  %t5 = load i32, ptr %t4
  %t6 = icmp eq i32 %t5, 0
  %t7 = zext i1 %t6 to i32
  %t8 = icmp ne i32 %t7, 0
  br i1 %t8, label %then0, label %ifend2
then0:
  %t9 = load ptr, ptr %t0
  store ptr %t9, ptr %retval
  br label %ret
ifend2:
  %t10 = load ptr, ptr %t0
  %t11 = load i32, ptr %t4
  %t12 = sub i32 %t11, 1
  %t13 = getelementptr inbounds i8, ptr %t10, i32 %t12
  %t14 = load i8, ptr %t13
  %t15 = zext i8 %t14 to i32
  %t16 = icmp eq i32 %t15, 47
  %t17 = zext i1 %t16 to i32
  %t18 = icmp ne i32 %t17, 0
  br i1 %t18, label %then3, label %ifend5
then3:
  %t19 = load ptr, ptr %t0
  store ptr %t19, ptr %retval
  br label %ret
ifend5:
  %t20 = load ptr, ptr %t0
  %t21 = call ptr @fn_str_concat(ptr %t20, ptr @.str1548)
  store ptr %t21, ptr %retval
  br label %ret
ret:
  %t22 = load ptr, ptr %retval
  ret ptr %t22
}

define void @fn_die(ptr %arg_msg) {
entry:
  %t0 = alloca ptr
  store ptr %arg_msg, ptr %t0
  %t1 = load ptr, ptr @__stderrp
  %t2 = load ptr, ptr %t0
  %t3 = load ptr, ptr %t0
  %t4 = call i64 @strlen(ptr %t3)
  %t5 = trunc i64 %t4 to i32
  %t6 = zext i32 %t5 to i64
  %t7 = call i64 @fwrite(ptr %t2, i64 1, i64 %t6, ptr %t1)
  %t8 = trunc i64 %t7 to i32
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
  %t84 = alloca ptr
  %t94 = alloca i32
  %t104 = alloca i32
  %t113 = alloca i32
  %t130 = alloca i32
  %t147 = alloca ptr
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
  %t11 = call i32 @fn_str_eq(ptr %t10, ptr @.str1549)
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
  %t25 = call i32 @fn_str_eq(ptr %t24, ptr @.str1550)
  %t26 = icmp ne i32 %t25, 0
  br i1 %t26, label %then6, label %else7
then6:
  store i32 1, ptr %t2
  br label %ifend8
else7:
  %t27 = load ptr, ptr %t23
  %t28 = call i32 @fn_str_eq(ptr %t27, ptr @.str1551)
  %t29 = icmp ne i32 %t28, 0
  br i1 %t29, label %then9, label %else10
then9:
  store i32 2, ptr %t2
  br label %ifend11
else10:
  %t30 = load ptr, ptr %t23
  %t31 = call i32 @fn_str_eq(ptr %t30, ptr @.str1552)
  %t32 = icmp ne i32 %t31, 0
  br i1 %t32, label %then12, label %else13
then12:
  store i32 1, ptr %t3
  br label %ifend14
else13:
  %t33 = load ptr, ptr %t23
  %t34 = call i32 @fn_str_eq(ptr %t33, ptr @.str1553)
  %t35 = icmp ne i32 %t34, 0
  br i1 %t35, label %then15, label %else16
then15:
  store i32 1, ptr %t4
  br label %ifend17
else16:
  %t36 = load ptr, ptr %t23
  %t37 = call i32 @fn_str_eq(ptr %t36, ptr @.str1554)
  %t38 = icmp ne i32 %t37, 0
  br i1 %t38, label %then18, label %else19
then18:
  store i32 1, ptr %t5
  br label %ifend20
else19:
  %t39 = load ptr, ptr %t23
  %t40 = call i32 @fn_str_eq(ptr %t39, ptr @.str1555)
  %t41 = icmp ne i32 %t40, 0
  br i1 %t41, label %then21, label %else22
then21:
  store i32 1, ptr %t6
  br label %ifend23
else22:
  %t42 = load ptr, ptr %t23
  %t43 = call i32 @fn_str_eq(ptr %t42, ptr @.str1556)
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
  %t64 = call ptr @fn_str_concat(ptr @.str1557, ptr %t63)
  %t65 = call ptr @fn_str_concat(ptr %t64, ptr @.str1558)
  store ptr %t65, ptr %t66
  %t67 = load ptr, ptr @__stderrp
  %t68 = load ptr, ptr %t66
  %t69 = load ptr, ptr %t66
  %t70 = call i64 @strlen(ptr %t69)
  %t71 = trunc i64 %t70 to i32
  %t72 = zext i32 %t71 to i64
  %t73 = call i64 @fwrite(ptr %t68, i64 1, i64 %t72, ptr %t67)
  %t74 = trunc i64 %t73 to i32
  br label %ifend32
else31:
  %t75 = load ptr, ptr %t23
  store ptr %t75, ptr %t0
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
  %t76 = load i32, ptr %t13
  %t77 = add i32 %t76, 1
  store i32 %t77, ptr %t13
  br label %wcond3
wend5:
  %t78 = load ptr, ptr %t0
  %t79 = icmp eq ptr %t78, null
  %t80 = zext i1 %t79 to i32
  %t81 = icmp ne i32 %t80, 0
  br i1 %t81, label %then33, label %ifend35
then33:
  call void @fn_die(ptr @.str1559)
  br label %ifend35
ifend35:
  %t82 = load ptr, ptr %t0
  %t83 = call ptr @fn_read_file(ptr %t82)
  store ptr %t83, ptr %t84
  %t85 = load ptr, ptr %t84
  %t86 = icmp eq ptr %t85, null
  %t87 = zext i1 %t86 to i32
  %t88 = icmp ne i32 %t87, 0
  br i1 %t88, label %then36, label %ifend38
then36:
  call void @fn_die(ptr @.str1560)
  br label %ifend38
ifend38:
  %t89 = load ptr, ptr %t0
  %t90 = call ptr @fn_dir_of(ptr %t89)
  store ptr %t90, ptr @g_cur_dir
  %t91 = load ptr, ptr %t84
  call void @fn_lex(ptr %t91)
  call void @fn_parse_program()
  %t92 = load i32, ptr %t4
  %t93 = icmp ne i32 %t92, 0
  br i1 %t93, label %then39, label %ifend41
then39:
  call void @exit(i32 0)
  unreachable
ifend41:
  call void @fn_maybe_splice_runtime()
  %t95 = load i32, ptr %t6
  %t96 = icmp ne i32 %t95, 0
  %t97 = zext i1 %t96 to i32
  store i32 %t97, ptr %t94
  br i1 %t96, label %scend43, label %sc42
sc42:
  %t98 = load ptr, ptr %t1
  %t99 = icmp ne ptr %t98, null
  %t100 = zext i1 %t99 to i32
  %t101 = icmp ne i32 %t100, 0
  %t102 = zext i1 %t101 to i32
  store i32 %t102, ptr %t94
  br label %scend43
scend43:
  %t103 = load i32, ptr %t94
  store i32 %t103, ptr %t104
  %t105 = load i32, ptr %t2
  %t106 = icmp eq i32 %t105, 1
  %t107 = zext i1 %t106 to i32
  %t108 = icmp ne i32 %t107, 0
  br i1 %t108, label %then44, label %else45
then44:
  store i32 1, ptr @g_g_windowed
  br label %ifend46
else45:
  %t109 = load i32, ptr %t2
  %t110 = icmp eq i32 %t109, 2
  %t111 = zext i1 %t110 to i32
  %t112 = icmp ne i32 %t111, 0
  br i1 %t112, label %then47, label %else48
then47:
  store i32 0, ptr @g_g_windowed
  br label %ifend49
else48:
  %t114 = load i32, ptr %t104
  %t115 = icmp ne i32 %t114, 0
  %t116 = zext i1 %t115 to i32
  store i32 %t116, ptr %t113
  br i1 %t115, label %sc50, label %scend51
sc50:
  %t117 = call i32 @fn_has_systems()
  %t118 = icmp ne i32 %t117, 0
  %t119 = zext i1 %t118 to i32
  store i32 %t119, ptr %t113
  br label %scend51
scend51:
  %t120 = load i32, ptr %t113
  store i32 %t120, ptr @g_g_windowed
  br label %ifend49
ifend49:
  br label %ifend46
ifend46:
  call void @fn_emit_program()
  %t121 = load i32, ptr %t3
  %t122 = icmp ne i32 %t121, 0
  br i1 %t122, label %then52, label %ifend54
then52:
  %t123 = load ptr, ptr %t1
  %t124 = call i32 @fn_ir_flush(ptr %t123)
  br label %ret
ifend54:
  %t125 = load i32, ptr %t104
  %t126 = icmp eq i32 %t125, 0
  %t127 = zext i1 %t126 to i32
  %t128 = icmp ne i32 %t127, 0
  br i1 %t128, label %then55, label %ifend57
then55:
  %t129 = call i32 @fn_ir_flush(ptr null)
  br label %ret
ifend57:
  %t131 = load i32, ptr %t6
  %t132 = icmp ne i32 %t131, 0
  %t133 = zext i1 %t132 to i32
  store i32 %t133, ptr %t130
  br i1 %t132, label %sc58, label %scend59
sc58:
  %t134 = load ptr, ptr %t1
  %t135 = icmp eq ptr %t134, null
  %t136 = zext i1 %t135 to i32
  %t137 = icmp ne i32 %t136, 0
  %t138 = zext i1 %t137 to i32
  store i32 %t138, ptr %t130
  br label %scend59
scend59:
  %t139 = load i32, ptr %t130
  %t140 = icmp ne i32 %t139, 0
  br i1 %t140, label %then60, label %ifend62
then60:
  %t141 = load ptr, ptr %t0
  %t142 = call ptr @fn_base_name(ptr %t141)
  %t143 = call ptr @fn_strip_ludic(ptr %t142)
  %t144 = call ptr @fn_str_concat(ptr @.str1561, ptr %t143)
  store ptr %t144, ptr %t1
  br label %ifend62
ifend62:
  %t145 = load ptr, ptr %t1
  %t146 = call ptr @fn_dir_of(ptr %t145)
  store ptr %t146, ptr %t147
  %t148 = load ptr, ptr %t147
  %t149 = call i64 @strlen(ptr %t148)
  %t150 = trunc i64 %t149 to i32
  %t151 = icmp sgt i32 %t150, 0
  %t152 = zext i1 %t151 to i32
  %t153 = icmp ne i32 %t152, 0
  br i1 %t153, label %then63, label %ifend65
then63:
  %t154 = load ptr, ptr %t147
  %t155 = call ptr @fn_str_concat(ptr @.str1562, ptr %t154)
  %t156 = call i32 @system(ptr %t155)
  br label %ifend65
ifend65:
  %t157 = load ptr, ptr %t1
  %t158 = call ptr @fn_str_concat(ptr %t157, ptr @.str1563)
  store ptr %t158, ptr %t159
  %t160 = load ptr, ptr %t159
  %t161 = call i32 @fn_ir_flush(ptr %t160)
  %t162 = icmp eq i32 %t161, 0
  %t163 = zext i1 %t162 to i32
  %t164 = icmp ne i32 %t163, 0
  br i1 %t164, label %then66, label %ifend68
then66:
  call void @fn_die(ptr @.str1564)
  br label %ifend68
ifend68:
  %t165 = call ptr @fn_getenv_or(ptr @.str1565, ptr @.str1566)
  store ptr %t165, ptr %t166
  %t167 = load ptr, ptr @L_argv
  %t168 = getelementptr ptr, ptr %t167, i32 0
  %t169 = load ptr, ptr %t168
  %t170 = call ptr @fn_dir_of(ptr %t169)
  %t171 = call ptr @fn_getenv_or(ptr @.str1567, ptr %t170)
  %t172 = call ptr @fn_ensure_slash(ptr %t171)
  store ptr %t172, ptr %t173
  %t174 = load ptr, ptr %t166
  %t175 = call ptr @fn_str_concat(ptr %t174, ptr @.str1568)
  %t176 = load ptr, ptr %t159
  %t177 = call ptr @fn_str_concat(ptr %t175, ptr %t176)
  store ptr %t177, ptr %t178
  %t179 = load i32, ptr @g_g_windowed
  %t180 = icmp ne i32 %t179, 0
  br i1 %t180, label %then69, label %ifend71
then69:
  %t181 = load ptr, ptr %t173
  %t182 = call ptr @fn_path_join(ptr %t181, ptr @.str1569)
  store ptr %t182, ptr %t183
  %t184 = load ptr, ptr %t178
  %t185 = call ptr @fn_str_concat(ptr %t184, ptr @.str1570)
  %t186 = load ptr, ptr %t183
  %t187 = call ptr @fn_str_concat(ptr %t185, ptr %t186)
  %t188 = call ptr @fn_str_concat(ptr %t187, ptr @.str1571)
  store ptr %t188, ptr %t178
  br label %ifend71
ifend71:
  %t189 = load ptr, ptr %t178
  %t190 = call ptr @fn_str_concat(ptr %t189, ptr @.str1572)
  %t191 = load ptr, ptr %t1
  %t192 = call ptr @fn_str_concat(ptr %t190, ptr %t191)
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
  %t201 = call ptr @fn_str_concat(ptr @.str1573, ptr %t200)
  %t202 = call i32 @system(ptr %t201)
  br label %ifend74
ifend74:
  %t203 = load i32, ptr %t195
  %t204 = icmp ne i32 %t203, 0
  %t205 = zext i1 %t204 to i32
  %t206 = icmp ne i32 %t205, 0
  br i1 %t206, label %then75, label %ifend77
then75:
  call void @fn_die(ptr @.str1574)
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
