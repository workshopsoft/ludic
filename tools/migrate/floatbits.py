"""Rewrite IEEE-float-bits-in-an-int code to Ludic's `float`.
  python3 floatbits.py <game dir> <ludic home> [--dry]
Converts <game>/src, <game>/lab and <home>/packages/ludic.render3d; <home>/runtime stays as it is
and is where raw bits remain (float_bits / float_from_bits at the calls into it)."""
import struct
import sys
from floatinfer import Program, FLOAT_OPS
from ludic_ast import PREC, walk

BIN = {'f_add': ('+', 9), 'f_sub': ('-', 9), 'f_mul': ('*', 10), 'f_div': ('/', 10), 'f_mod': ('%', 10)}
CMP = {'f_ls': ('<', 3), 'f_gt': ('>', 3)}
MATH = {'f_abs': 'abs', 'f_min': 'min', 'f_max': 'max', 'f_clamp': 'clamp', 'f_sqrt': 'sqrt', 'f_sin': 'sin',
        'f_cos': 'cos', 'f_tan': 'tan', 'f_atan2': 'atan2', 'f_floor': 'floor', 'f_pow': 'pow', 'f_exp': 'exp',
        'f_log': 'log', 'f_lerp': 'lerp', 'f_rad': 'deg_to_rad'}
CONST = {'F_ZERO': '0.0', 'F_ONE': '1.0', 'F_TWO': '2.0', 'F_HALF': '0.5', 'F_PI': 'PI'}
CONV = {'f_to_int': 'int', 'f_fx': 'fixed', 'f32_to_fx': 'fixed', 'fx_to_f32': 'float', 'f_from_int': 'float'}


def plain(v):
    """a float as decimal text Ludic reads: no exponent, the shortest that round-trips as f32"""
    import math
    if not math.isfinite(v): return '1000000000.0'       # a NaN or infinite sentinel: never equal to a real value
    for digits in range(1, 12):
        t = f'{v:.{digits}g}'
        if struct.unpack('>f', struct.pack('>f', float(t)))[0] == struct.unpack('>f', struct.pack('>f', v))[0]: break
    from decimal import Decimal
    t = format(Decimal(t), 'f')
    return t if '.' in t else t + '.0'


def flit(text, bits=False):
    """a literal's text as a float literal; with bits, a big int or hex is a float's bit pattern"""
    t = text.replace('_', '')
    if t.startswith('0x') and bits:
        return plain(struct.unpack('>f', struct.pack('>I', int(t, 16) & 0xffffffff))[0])
    if t.isdigit() and int(t) > (1 << 20) and bits:
        return plain(struct.unpack('>f', struct.pack('>I', int(t) & 0xffffffff))[0])
    if t.startswith('0x'): return plain(float(int(t, 16)))
    return t if '.' in t else t + '.0'


INT_OPS = ('+', '-', '*', '/', '%', '|', '&', '^', '<<', '>>')


class Rewriter:
    def __init__(self, prog):
        self.p = prog
        uf = prog.uf
        self.fl = lambda k: k is not None and uf.is_float(k) and not uf.is_int(k)
        self.to_float_lit = set()     # num nodes that stand where a float is
        self.wrap_bits = set()        # nodes whose float value leaves as bits
        self.wrap_from = set()        # nodes whose bits arrive as a float
        self.plan()

    # ---- where literals and bits cross --------------------------------------
    def value_into(self, node, target_float):
        """a value node flows into a slot: note a literal to float, or a crossing"""
        if node is None: return
        inner = node.kids[0] if node.kind == 'paren' else node
        lit = inner if inner.kind == 'num' else (inner.kids[0] if inner.kind == 'unary' and inner.val == '-' and inner.kids and inner.kids[0].kind == 'num' else None)
        k = self.p.node_key.get(id(node))
        if self.mixed_read(inner):
            if target_float: self.wrap_from.add(id(node))
            return
        if k is not None and k[0] == 'RC' and inner.kind == 'call' and inner.kids[0].kind == 'id':
            f = self.p.funcs.get(inner.kids[0].val)
            if f and f.ret and self.fl(f.ret.key) != self.fl(k): k = f.ret.key
        if target_float:
            if lit is not None: self.to_float_lit.add(id(lit))
            elif k is not None and not self.fl(k) and (self.p.uf.is_int(k) or k[0] in ('B', 'RC', 'RD')): self.wrap_from.add(id(node))
        else:
            if k is not None and self.fl(k): self.wrap_bits.add(id(node))

    def plan(self):
        p = self.p
        for fp in p.files:
            if fp.runtime: continue
            for s in fp.stmts:
                fn = s.fn
                if s.kind == 'let' and s.b is not None:
                    self.value_into(s.b, self.fl(s.decl.key))
                elif s.kind == 'assign':
                    tk = p.node_key.get(id(s.a))
                    if s.a.kind == 'index':
                        ck = p.node_key.get(id(s.a.kids[0]))
                        tf = ck is not None and ck not in p.mixed and self.fl(('E', ck))
                        self.value_into(s.b, tf)
                    else:
                        self.value_into(s.b, self.fl(tk))
                elif s.kind == 'return':
                    f = p.funcs.get(fn)
                    if f and f.ret: self.value_into(s.a, self.fl(f.ret.key))
            for d in fp.globals.values():
                if d.init is not None: self.value_into(d.init, self.fl(d.key))
            for fields in fp.props.values():
                for d in fields.values():
                    if d.init is not None: self.value_into(d.init, self.fl(d.key))
        for f, i, k, a in p.calls:
            self.value_into(a, self.fl(f.params[i].key))
        for call, a, k in p.bound_args:
            if self.fl(k) and a.kind != 'named': self.wrap_bits.add(id(a))
        for n_id, k in p.bound_rets.items():
            if self.fl(k): self.wrap_from.add(n_id)
        # comparisons between a float and a literal
        for fp in p.files:
            if fp.runtime: continue
            for s in fp.stmts:
                for e in (s.a, s.b):
                    if e is None: continue
                    for n in walk(e):
                        if n.kind == 'bin' and n.val in ('==', '!=', '<', '>', '<=', '>='):
                            a, b = n.kids
                            ka, kb = p.node_key.get(id(a)), p.node_key.get(id(b))
                            if self.fl(ka) and b.kind == 'num': self.to_float_lit.add(id(b))
                            if self.fl(kb) and a.kind == 'num': self.to_float_lit.add(id(a))
                        if n.kind == 'call' and n.kids[0].kind == 'id' and (n.kids[0].val in BIN or n.kids[0].val in CMP or n.kids[0].val in MATH or n.kids[0].val == 'f_neg'):
                            for arg in n.kids[1:]:
                                if self.mixed_read(arg): self.wrap_from.add(id(arg))
                        if n.kind == 'bin' and n.val in ('==', '!=', '<', '>', '<=', '>='):
                            a, b = n.kids
                            ka, kb = self.kind(a), self.kind(b)
                            if ka == 'f' and kb == 'i' and b.kind != 'num': self.wrap_bits.add(id(a))
                            if kb == 'f' and ka == 'i' and a.kind != 'num': self.wrap_bits.add(id(b))
                        if n.kind == 'bin' and n.val in INT_OPS:
                            a, b = n.kids
                            ka, kb = self.kind(a), self.kind(b)
                            bitwise = n.val in ('|', '&', '^', '<<', '>>')
                            if ka == 'f' and (bitwise or kb == 'i'): self.wrap_bits.add(id(a))
                            if kb == 'f' and (bitwise or ka == 'i'): self.wrap_bits.add(id(b))
                        if n.kind == 'call' and n.kids[0].kind == 'id' and n.kids[0].val in ('push',):
                            args = n.kids[1:]
                            if len(args) == 2:
                                ck = p.node_key.get(id(args[0]))
                                if ck is not None and ck not in p.mixed and self.fl(('E', ck)): self.value_into(args[1], True)

    # ---- rendering ----------------------------------------------------------
    def render(self, n, src):
        """(text, precedence) of a node after the rewrite"""
        t, pr = self.render_inner(n, src)
        if id(n) in self.wrap_bits: return f'float_bits({t})', 12
        if id(n) in self.wrap_from: return f'float_from_bits({t})', 12
        return t, pr

    def need(self, kid, src, minp):
        t, pr = self.render(kid, src)
        return f'({t})' if pr < minp else t

    def render_inner(self, n, src):
        k = n.kind
        if k == 'num':
            if id(n) in self.to_float_lit: return flit(n.val, bits=True), 12
            return n.val, 12
        if k == 'id':
            if n.val in CONST: return CONST[n.val], 12
            return n.val, 12
        if k == 'call' and n.kids[0].kind == 'id':
            name = n.kids[0].val
            args = n.kids[1:]
            if name in BIN and len(args) == 2:
                op, pr = BIN[name]
                return f'{self.need(args[0], src, pr)} {op} {self.need(args[1], src, pr + 1)}', pr
            if name in CMP and len(args) == 2:
                op, pr = CMP[name]
                return f'{self.need(args[0], src, pr + 1)} {op} {self.need(args[1], src, pr + 1)}', pr
            if name == 'f_neg' and len(args) == 1:
                return f'-{self.need(args[0], src, 11)}', 11
            if name in MATH:
                return f'Math.{MATH[name]}(' + ', '.join(self.render(a, src)[0] for a in args) + ')', 12
            if name == 'fx_to_f32' and len(args) == 1 and not self.is_fixed(args[0]):
                # Q16.16 bits in an int: float(x) of it would be the bits as a number
                return f'float({self.render(args[0], src)[0]}) / 65536.0', 10
            if name in CONV and len(args) == 1:
                return f'{CONV[name]}({self.render(args[0], src)[0]})', 12
            if name == 'fl' and len(args) == 1:
                a = args[0]
                if a.kind == 'num': return flit(a.val), 12
                if a.kind == 'unary' and a.val == '-' and a.kids[0].kind == 'num': return '-' + flit(a.kids[0].val), 11
                return f'float({self.render(a, src)[0]})', 12
            if name == 'fi' and len(args) == 1:
                a = args[0]
                if a.kind == 'num': return flit(a.val), 12
                if a.kind == 'unary' and a.val == '-' and a.kids[0].kind == 'num': return '-' + flit(a.kids[0].val), 11
                return f'float({self.render(a, src)[0]})', 12
            if name == 'fr' and len(args) == 2:
                parts = []
                for a in args:
                    parts.append(flit(a.val) if a.kind == 'num' else f'float({self.render(a, src)[0]})')
                return f'{parts[0]} / {parts[1]}', 10
            if name == 'f_neg1' and not args: return '-1.0', 11
            if name in ('words', 'ints_n') and self.float_container(n):
                return f'{"floats" if name == "words" else "floats_n"}(' + ', '.join(self.render(a, src)[0] for a in args) + ')', 12
        if k == 'new' and n.val == '[]int' and self.float_container(n): return 'new []float', 12
        if k == 'new' and n.val in ('[]words', '[][]int') and self.nested_float(('A', id(n))):
            return ('new []floats' if n.val == '[]words' else 'new [][]float'), 12
        if not n.kids: return src[n.s:n.e], self.prec_of(n)
        # splice the kids into the node's own text
        out, pos = [], n.s
        for idx, kid in enumerate(n.kids):
            if kid.s < pos or kid.s < 0: continue
            out.append(src[pos:kid.s])
            if n.kind == 'bin':
                pr = PREC[n.val]
                t = self.need(kid, src, pr if idx == 0 else pr + 1)
            elif n.kind == 'unary':
                t = self.need(kid, src, 11)
            elif n.kind in ('member', 'index', 'slice') and idx == 0 or n.kind == 'call' and idx == 0:
                t = self.need(kid, src, 12)
            else:
                t = self.render(kid, src)[0]
            out.append(t)
            pos = kid.e
        out.append(src[pos:n.e])
        return ''.join(out), self.prec_of(n)

    def nested_float(self, k):
        ik = ('E', k)
        return ik not in self.p.mixed and self.fl(('E', ik))

    def mixed_read(self, n):
        """an element of a buffer that holds both kinds: its bits, whatever the inference joined it to"""
        if n.kind != 'index': return False
        ck = self.p.node_key.get(id(n.kids[0]))
        return ck is not None and ck in self.p.mixed

    def is_fixed(self, n):
        k = self.p.node_key.get(id(n))
        if k is not None and self.p.types.get(k, '') == 'fixed': return True
        return n.kind == 'call' and n.kids[0].kind == 'id' and n.kids[0].val in ('f_fx', 'f32_to_fx')

    def kind(self, n):
        """'f', 'i', 'lit' or None: what a node carries, as far as the inference knows"""
        if n.kind == 'num': return 'i' if '.' not in n.val else 'lit'
        if n.kind == 'paren': return self.kind(n.kids[0])
        if self.mixed_read(n): return 'i'
        if n.kind == 'bin' and n.val in INT_OPS:
            ks = {self.kind(k) for k in n.kids} - {'lit', None}
            return ks.pop() if len(ks) == 1 else None
        k = self.p.node_key.get(id(n))
        if k is None: return None
        if self.fl(k): return 'f'
        if self.p.uf.is_int(k): return 'i'
        return None

    def float_container(self, n):
        k = self.p.node_key.get(id(n))
        return k is not None and k not in self.p.mixed and self.fl(('E', k))

    def prec_of(self, n):
        if n.kind == 'bin': return PREC[n.val]
        if n.kind == 'unary': return 11
        return 12

    # ---- files --------------------------------------------------------------
    def roots(self, fp):
        """the outermost expression nodes of a file, each once"""
        seen = []
        for s in fp.stmts:
            for e in (s.a, s.b):
                if e is not None: seen.append(e)
            if s.decl is not None and s.decl.init is not None and s.decl.init is not s.b: seen.append(s.decl.init)
        for d in fp.globals.values():
            if d.init is not None: seen.append(d.init)
        for fields in fp.props.values():
            for d in fields.values():
                if d.init is not None: seen.append(d.init)
        seen.sort(key=lambda n: (n.s, -n.e))
        out, end = [], -1
        for n in seen:
            if n.s >= end:
                out.append(n)
                end = n.e
        return out

    def decl_edits(self, fp):
        p = self.p
        edits = []
        decls = list(fp.globals.values())
        for fields in fp.props.values(): decls += list(fields.values())
        for f in fp.funcs.values():
            if f.file != fp.path: continue
            decls += list(f.params)
            if f.ret: decls.append(f.ret)
            decls += list(f.locals.values())
        for d in decls:
            if d.ts is None or d.ts < 0 or not d.ty: continue
            if d.ty == 'int' and self.fl(d.key): edits.append((d.ts, d.te, 'float'))
            elif d.ty in ('words', '[]int') and d.key not in p.mixed and self.fl(('E', d.key)):
                edits.append((d.ts, d.te, 'floats' if d.ty == 'words' else '[]float'))
            elif d.ty in ('[]words', '[][]int') and self.nested_float(d.key):
                edits.append((d.ts, d.te, '[]floats' if d.ty == '[]words' else '[][]float'))
        return edits

    def rewrite(self, fp):
        src = fp.src
        edits = self.decl_edits(fp)
        for n in self.roots(fp):
            t, _ = self.render(n, src)
            if t != src[n.s:n.e]: edits.append((n.s, n.e, t))
        edits.sort()
        out, pos = [], 0
        for s, e, t in edits:
            if s < pos: continue
            out.append(src[pos:s])
            out.append(t)
            pos = e
        out.append(src[pos:])
        return ''.join(out)


def main():
    game, home = sys.argv[1], sys.argv[2]
    dry = '--dry' in sys.argv
    prog = Program([game + '/src', game + '/lab', home + '/packages/ludic.render3d'], [home + '/runtime/native']).run()
    rw = Rewriter(prog)
    changed = 0
    for fp in prog.files:
        if fp.runtime: continue
        new = rw.rewrite(fp)
        if new != fp.src:
            changed += 1
            if not dry: open(fp.path, 'w').write(new)
    print(f'{changed} files rewritten')
    if dry:
        import difflib
        for fp in prog.files:
            if fp.runtime or not any(x in fp.path for x in sys.argv[3:] if not x.startswith('--')): continue
            new = rw.rewrite(fp)
            for l in difflib.unified_diff(fp.src.split('\n'), new.split('\n'), lineterm='', n=0): print(l)


if __name__ == '__main__':
    main()
