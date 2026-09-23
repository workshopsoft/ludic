"""A small Ludic parser for migration tools: tokens with source offsets, statements and
expression trees, enough of the grammar to rewrite expressions in place and know which
declaration each name refers to. It does not check anything; it tolerates what it does not
understand by keeping it as raw text."""
import re

KEYWORDS = {'let', 'var', 'const', 'if', 'else', 'while', 'for', 'in', 'return', 'break', 'continue',
            'function', 'handler', 'property', 'model', 'program', 'import', 'event', 'emit', 'not',
            'and', 'or', 'new', 'true', 'false', 'null', 'extern', 'spawn', 'enum', 'match', 'fn',
            'scene', 'layer', 'ui', 'test', 'namespace', 'entry', 'become', 'numbers', 'on'}


class Tok:
    __slots__ = ('k', 't', 's', 'e', 'holes')

    def __init__(self, k, t, s, e):
        self.k, self.t, self.s, self.e, self.holes = k, t, s, e, None

    def __repr__(self):
        return f'{self.k}:{self.t!r}'


OPS = ['..', '->', '==', '!=', '<=', '>=', '+=', '-=', '*=', '/=', '%=', '<<', '>>', '&&', '||',
       '+', '-', '*', '/', '%', '<', '>', '=', '(', ')', '[', ']', '{', '}', ',', '.', ':', ';',
       '@', '&', '|', '^', '!', '?', '~']


NUM_RE = re.compile(r'0x[0-9a-fA-F_]+|\d[\d_]*(\.\d+(?!\.))?')
ID_RE = re.compile(r'[A-Za-z_][A-Za-z0-9_]*')


def tokenize(src, base=0):
    """Tokens of src; offsets are relative to the whole file (base added)."""
    toks = []
    i, n = 0, len(src)
    while i < n:
        c = src[i]
        if c == '\n':
            toks.append(Tok('NL', '\n', base + i, base + i + 1))
            i += 1
        elif c in ' \t\r':
            i += 1
        elif c == '#':
            j = src.find('\n', i)
            j = n if j < 0 else j
            i = j
        elif c == '"':
            j = i + 1
            while j < n and src[j] != '"':
                j += 2 if src[j] == '\\' else 1
            toks.append(Tok('STR', src[i:j + 1], base + i, base + j + 1))
            i = j + 1
        elif c == "'":
            j = i + 1
            while j < n and src[j] != "'":
                j += 2 if src[j] == '\\' else 1
            toks.append(Tok('CHR', src[i:j + 1], base + i, base + j + 1))
            i = j + 1
        elif c == '`':
            j = i + 1
            holes = []
            while j < n and src[j] != '`':
                if src[j] == '{':
                    d, k = 1, j + 1
                    while k < n and d:
                        if src[k] == '{': d += 1
                        elif src[k] == '}': d -= 1
                        k += 1
                    holes.append((j + 1, k - 1))
                    j = k
                else:
                    j += 1
            t = Tok('TMPL', src[i:j + 1], base + i, base + j + 1)
            t.holes = [tokenize(src[a:b], base + a) for a, b in holes]
            toks.append(t)
            i = j + 1
        elif c.isdigit():
            m = NUM_RE.match(src, i)
            toks.append(Tok('NUM', m.group(0), base + i, base + i + len(m.group(0))))
            i += len(m.group(0))
        elif c.isalpha() or c == '_':
            m = ID_RE.match(src, i)
            toks.append(Tok('ID', m.group(0), base + i, base + i + len(m.group(0))))
            i += len(m.group(0))
        else:
            for op in OPS:
                if src.startswith(op, i):
                    toks.append(Tok('OP', op, base + i, base + i + len(op)))
                    i += len(op)
                    break
            else:
                toks.append(Tok('OP', c, base + i, base + i + 1))
                i += 1
    return toks


class Node:
    """kind: num str chr tmpl id call member index slice unary bin paren list new fnref raw named"""
    __slots__ = ('kind', 'val', 'kids', 's', 'e', 'fn', 'sym', 'tmpl_holes')

    def __init__(self, kind, val, kids, s, e):
        self.kind, self.val, self.kids, self.s, self.e = kind, val, kids, s, e
        self.fn = None
        self.sym = None
        self.tmpl_holes = None


PREC = {'or': 1, '||': 1, 'and': 2, '&&': 2, '==': 3, '!=': 3, '<': 3, '<=': 3, '>': 3, '>=': 3,
        '..': 4, '|': 5, '^': 6, '&': 7, '<<': 8, '>>': 8, '+': 9, '-': 9, '*': 10, '/': 10, '%': 10}


class ExprParser:
    def __init__(self, toks, i=0):
        self.t, self.i = toks, i

    def peek(self, o=0):
        j = self.i + o
        return self.t[j] if j < len(self.t) else Tok('EOF', '', -1, -1)

    def eat(self):
        tk = self.peek()
        self.i += 1
        return tk

    def is_op(self, v):
        tk = self.peek()
        return tk.k == 'OP' and tk.t == v

    def binop(self):
        tk = self.peek()
        if tk.k == 'OP' and tk.t in PREC: return tk.t
        if tk.k == 'ID' and tk.t in ('and', 'or'): return tk.t
        return None

    def expr(self, minp=0):
        left = self.unary()
        while True:
            op = self.binop()
            if op is None or PREC[op] < minp:
                return left
            self.eat()
            while self.peek().k == 'NL': self.eat()
            right = self.expr(PREC[op] + 1)
            left = Node('bin', op, [left, right], left.s, right.e)

    def unary(self):
        tk = self.peek()
        if tk.k == 'OP' and tk.t in ('-', '!', '~'):
            self.eat()
            x = self.unary()
            return Node('unary', tk.t, [x], tk.s, x.e)
        if tk.k == 'ID' and tk.t == 'not':
            self.eat()
            x = self.unary()
            return Node('unary', 'not', [x], tk.s, x.e)
        return self.postfix(self.primary())

    def primary(self):
        tk = self.eat()
        if tk.k == 'NUM': return Node('num', tk.t, [], tk.s, tk.e)
        if tk.k == 'STR': return Node('str', tk.t, [], tk.s, tk.e)
        if tk.k == 'CHR': return Node('chr', tk.t, [], tk.s, tk.e)
        if tk.k == 'TMPL':
            n = Node('tmpl', tk.t, [], tk.s, tk.e)
            for ht in tk.holes:
                if ht:
                    p = ExprParser(ht)
                    try:
                        n.kids.append(p.expr())
                    except Exception:
                        pass
            return n
        if tk.k == 'OP' and tk.t == '(':
            x = self.expr()
            end = self.eat()
            return Node('paren', None, [x], tk.s, end.e)
        if tk.k == 'OP' and tk.t == '[':
            kids = []
            while not self.is_op(']') and self.peek().k != 'EOF':
                if self.peek().k == 'NL':
                    self.eat()
                    continue
                kids.append(self.expr())
                if self.is_op(','): self.eat()
            end = self.eat()
            return Node('list', None, kids, tk.s, end.e)
        if tk.k == 'ID' and tk.t == 'new':
            s = tk.s
            ty = ''
            while self.is_op('[') or self.is_op(']'): ty += self.eat().t
            nm = self.eat()
            return Node('new', ty + nm.t, [], s, nm.e)
        if tk.k == 'ID' and tk.t == 'fn' and self.peek().k == 'ID':
            nm = self.eat()
            return Node('fnref', nm.t, [], tk.s, nm.e)
        if tk.k == 'ID': return Node('id', tk.t, [], tk.s, tk.e)
        if tk.k == 'EOF': raise SyntaxError('end of input')
        return Node('raw', tk.t, [], tk.s, tk.e)

    def postfix(self, x):
        while True:
            if self.is_op('('):
                self.eat()
                args = []
                while not self.is_op(')') and self.peek().k != 'EOF':
                    if self.peek().k == 'NL':
                        self.eat()
                        continue
                    if self.peek().k == 'ID' and self.peek(1).k == 'OP' and self.peek(1).t == ':':
                        nm = self.eat()
                        self.eat()
                        v = self.expr()
                        args.append(Node('named', nm.t, [v], nm.s, v.e))
                    else:
                        args.append(self.expr())
                    if self.is_op(','): self.eat()
                end = self.eat()
                n = Node('call', None, [x] + args, x.s, end.e)
                x = n
            elif self.is_op('.') and self.peek(1).k == 'ID':
                self.eat()
                nm = self.eat()
                x = Node('member', nm.t, [x], x.s, nm.e)
            elif self.is_op('['):
                self.eat()
                a = self.expr()
                if self.is_op('..'):
                    self.eat()
                    b = self.expr()
                    end = self.eat()
                    x = Node('slice', None, [x, a, b], x.s, end.e)
                else:
                    end = self.eat()
                    x = Node('index', None, [x, a], x.s, end.e)
            else:
                return x


def walk(n):
    yield n
    for k in n.kids:
        yield from walk(k)
