"""Statements and declarations of a Ludic file, over ludic_ast's tokens and expressions."""
from ludic_ast import tokenize, ExprParser, Node, Tok

STMT_END = ('NL', ';')


class Decl:
    """A typed name: its type text and where that text is, so a rewrite can change it."""
    __slots__ = ('name', 'ty', 'ts', 'te', 'file', 'init', 'key')

    def __init__(self, name, ty, ts, te, file, init=None):
        self.name, self.ty, self.ts, self.te, self.file, self.init = name, ty, ts, te, file, init
        self.key = None


class Func:
    __slots__ = ('name', 'params', 'ret', 'file', 'extern', 'runtime', 'locals')

    def __init__(self, name, file):
        self.name, self.file = name, file
        self.params, self.ret, self.extern, self.runtime, self.locals = [], None, False, False, {}


class Stmt:
    """kind: let assign opassign return expr cond forrange foreach
    a, b: expression nodes (lhs / rhs); decl: the Decl a let/var introduced"""
    __slots__ = ('kind', 'fn', 'a', 'b', 'decl', 'op', 'file', 'var', 'scope')

    def __init__(self, kind, fn, a=None, b=None, decl=None, op=None, file=None, var=None):
        self.kind, self.fn, self.a, self.b, self.decl, self.op, self.file, self.var = kind, fn, a, b, decl, op, file, var
        self.scope = None


class FileParse:
    def __init__(self, path, src, runtime=False):
        self.path, self.src, self.runtime = path, src, runtime
        self.t = [x for x in tokenize(src)]
        self.i = 0
        self.funcs, self.globals, self.props, self.stmts = {}, {}, {}, []
        self.float_directive = False
        self.parse()

    # ---- cursor -------------------------------------------------------------
    def pk(self, o=0):
        j = self.i + o
        return self.t[j] if j < len(self.t) else Tok('EOF', '', len(self.src), len(self.src))

    def at(self, k, v=None, o=0):
        tk = self.pk(o)
        return tk.k == k and (v is None or tk.t == v)

    def skip_nl(self):
        while self.at('NL') or self.at('OP', ';'): self.i += 1

    def skip_to_eol(self):
        d = 0
        while not self.at('EOF'):
            tk = self.pk()
            if tk.k == 'OP' and tk.t in '([{': d += 1
            if tk.k == 'OP' and tk.t in ')]}':
                if d == 0: return
                d -= 1
            if d == 0 and (tk.k == 'NL' or (tk.k == 'OP' and tk.t == ';')): return
            self.i += 1

    def skip_block(self):
        """from a `{`, past its matching `}`"""
        while not self.at('OP', '{') and not self.at('EOF'): self.i += 1
        d = 0
        while not self.at('EOF'):
            tk = self.pk()
            if tk.k == 'OP' and tk.t == '{': d += 1
            if tk.k == 'OP' and tk.t == '}':
                d -= 1
                if d == 0:
                    self.i += 1
                    return
            self.i += 1

    def type_here(self):
        """the type text starting at the cursor, up to = , ) { NL; returns (text, start, end)"""
        s = self.pk().s
        e = s
        d = 0
        parts = []
        while not self.at('EOF'):
            tk = self.pk()
            if tk.k == 'NL': break
            if tk.k == 'OP' and tk.t in ('=', ',', '{') and d == 0: break
            if tk.k == 'OP' and tk.t == ')' and d == 0: break
            if tk.k == 'OP' and tk.t in '([': d += 1
            if tk.k == 'OP' and tk.t in ')]': d -= 1
            parts.append(tk.t)
            e = tk.e
            self.i += 1
        return ''.join(parts), s, e

    def expr(self):
        p = ExprParser(self.t, self.i)
        n = p.expr()
        self.i = p.i
        return n

    # ---- the file -----------------------------------------------------------
    def parse(self):
        while not self.at('EOF'):
            self.skip_nl()
            if self.at('EOF'): break
            self.top()

    def top(self):
        tk = self.pk()
        if tk.k == 'OP' and tk.t == '@':
            self.i += 1
            self.i += 1
            if self.at('OP', '('):
                d = 0
                while True:
                    if self.at('OP', '('): d += 1
                    if self.at('OP', ')'): d -= 1
                    self.i += 1
                    if d == 0: break
            return
        if tk.k == 'OP' and tk.t == '}':
            self.i += 1
            return
        if tk.k != 'ID':
            self.skip_to_eol()
            if self.at('OP', '}') or self.at('OP', ')') or self.at('OP', ']'): self.i += 1
            return
        w = tk.t
        if w == 'program':
            self.i += 2
            self.skip_nl()
            if self.at('OP', '{'): self.i += 1
            return
        if w == 'numbers':
            self.float_directive = self.at('ID', 'float', 1)
            self.skip_to_eol()
            return
        if w == 'import' or w == 'model' and False:
            self.skip_to_eol()
            return
        if w == 'extern':
            self.i += 1
            self.function(extern=True)
            return
        if w == 'function':
            self.function()
            return
        if w == 'handler':
            nm = self.pk(1).t
            f = Func(nm, self.path)
            self.funcs.setdefault(nm, f)
            while not self.at('OP', '{') and not self.at('EOF'): self.i += 1
            self.i += 1
            self.body(f)
            return
        if w in ('var', 'const'):
            self.i += 1
            d = self.decl_here()
            if d: self.globals[d.name] = d
            return
        if w == 'property':
            self.prop()
            return
        if w in ('model', 'event', 'enum', 'ui', 'scene', 'layer', 'test', 'namespace', 'entry'):
            self.skip_block()
            return
        self.skip_to_eol()

    def decl_here(self):
        """after var/let/const: NAME [: TYPE] [= EXPR]"""
        nm = self.pk()
        if nm.k != 'ID':
            self.skip_to_eol()
            return None
        self.i += 1
        ty, ts, te = '', nm.e, nm.e
        if self.at('OP', ':'):
            self.i += 1
            ty, ts, te = self.type_here()
        init = None
        if self.at('OP', '='):
            self.i += 1
            init = self.expr()
        return Decl(nm.t, ty, ts, te, self.path, init)

    def prop(self):
        self.i += 1
        nm = self.pk().t
        self.i += 1
        while not self.at('OP', '{') and not self.at('EOF'): self.i += 1
        self.i += 1
        fields = self.props.setdefault(nm, {})
        while not self.at('OP', '}') and not self.at('EOF'):
            self.skip_nl()
            if self.at('ID') and self.at('OP', ':', 1):
                d = self.decl_here()
                if d: fields[d.name] = d
                if self.at('OP', ','): self.i += 1
            elif not self.at('OP', '}'):
                self.i += 1
        self.i += 1

    def function(self, extern=False):
        self.i += 1  # function
        nm = self.pk().t
        self.i += 1
        f = Func(nm, self.path)
        f.extern, f.runtime = extern, self.runtime
        self.funcs[nm] = f
        if self.at('OP', '('):
            self.i += 1
            while not self.at('OP', ')') and not self.at('EOF'):
                self.skip_nl()
                pn = self.pk()
                self.i += 1
                if self.at('OP', ':'):
                    self.i += 1
                    ty, ts, te = self.type_here()
                    f.params.append(Decl(pn.t, ty, ts, te, self.path))
                if self.at('OP', ','): self.i += 1
            self.i += 1
        if self.at('OP', '->'):
            self.i += 1
            ty, ts, te = self.type_here()
            f.ret = Decl('', ty, ts, te, self.path)
        if extern:
            self.skip_to_eol()
            return
        while not self.at('OP', '{') and not self.at('EOF') and not self.at('NL'): self.i += 1
        if self.at('OP', '{'):
            self.i += 1
            self.body(f)

    def body(self, f):
        """statements until the `}` that closes the function"""
        depth = 1
        self.scopes = [{}]
        self.pending = {}
        while not self.at('EOF'):
            self.skip_nl()
            if self.at('OP', '}'):
                self.i += 1
                depth -= 1
                if len(self.scopes) > 1: self.scopes.pop()
                if depth == 0: return
                # `} else if cond {` / `} else {`
                if self.at('ID', 'else'):
                    self.i += 1
                    if self.at('ID', 'if'):
                        self.i += 1
                        c = self.expr()
                        self.stmts.append(Stmt('cond', f.name, c, file=self.path))
                    if self.at('OP', '{'):
                        self.i += 1
                        depth += 1
                        self.scopes.append({})
                continue
            if self.at('OP', '{'):
                self.i += 1
                depth += 1
                self.scopes.append({})
                continue
            n0 = len(self.stmts)
            opened = self.statement(f)
            for st in self.stmts[n0:]:
                if st.scope is None: st.scope = self.visible()
            if opened:
                self.scopes.append(self.pending)
            self.pending = {}
            depth += opened

    def visible(self):
        out = {}
        for sc in self.scopes: out.update(sc)
        return out

    def bind(self, f, d):
        """a local declared here: its own entry, so a name reused in another block is another name"""
        uniq = d.name if d.name not in f.locals else f'{d.name}@{len(f.locals)}'
        f.locals[uniq] = d
        return uniq

    def statement(self, f):
        """one statement; returns how many blocks it opened"""
        tk = self.pk()
        w = tk.t if tk.k == 'ID' else None
        opened = 0
        if w in ('let', 'var', 'const'):
            self.i += 1
            d = self.decl_here()
            if d:
                uniq = self.bind(f, d)
                self.stmts.append(Stmt('let', f.name, decl=d, b=d.init, file=self.path))
                self.stmts[-1].scope = self.visible()
                self.scopes[-1][d.name] = uniq
        elif w in ('if', 'while'):
            self.i += 1
            c = self.expr()
            self.stmts.append(Stmt('cond', f.name, c, file=self.path))
        elif w == 'else':
            self.i += 1
            if self.at('ID', 'if'):
                self.i += 1
                c = self.expr()
                self.stmts.append(Stmt('cond', f.name, c, file=self.path))
        elif w == 'for':
            self.i += 1
            var = self.pk().t
            self.i += 2  # name in
            a = self.expr()
            if self.at('OP', '..'):
                self.i += 1
                b = self.expr()
                self.stmts.append(Stmt('forrange', f.name, a, b, var=var, file=self.path))
            else:
                self.stmts.append(Stmt('foreach', f.name, a, var=var, file=self.path))
            self.pending[var] = self.bind(f, Decl(var, '', -1, -1, self.path))
            self.stmts[-1].scope = dict(self.visible(), **{var: self.pending[var]})
        elif w == 'return':
            self.i += 1
            if not (self.at('NL') or self.at('OP', '}') or self.at('OP', ';')):
                self.stmts.append(Stmt('return', f.name, self.expr(), file=self.path))
        elif w in ('break', 'continue', 'quit'):
            self.i += 1
        elif w == 'spawn':
            self.skip_to_eol()
        else:
            try:
                a = self.expr()
            except Exception:
                self.skip_to_eol()
                return 0
            if self.at('OP') and self.pk().t in ('=', '+=', '-=', '*=', '/=', '%='):
                op = self.pk().t
                self.i += 1
                b = self.expr()
                self.stmts.append(Stmt('assign' if op == '=' else 'opassign', f.name, a, b, op=op, file=self.path))
            else:
                self.stmts.append(Stmt('expr', f.name, a, file=self.path))
        # a block opened on this line
        if self.at('OP', '{'):
            self.i += 1
            opened = 1
        return opened
