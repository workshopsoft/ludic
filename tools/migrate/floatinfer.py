"""Which Ludic ints are IEEE float bit patterns: union-find over every name a value can live in,
seeded by the fl/fi/f_* helpers (float) and by integer arithmetic (int)."""
import glob
import os
from ludic_decls import FileParse
from ludic_ast import walk

FLOAT_OPS = {'f_add': 2, 'f_sub': 2, 'f_mul': 2, 'f_div': 2, 'f_neg': 1, 'f_abs': 1, 'f_min': 2,
             'f_max': 2, 'f_clamp': 3, 'f_sqrt': 1, 'f_sin': 1, 'f_cos': 1, 'f_tan': 1, 'f_atan2': 2,
             'f_floor': 1, 'f_mod': 2, 'f_lerp': 3, 'f_rad': 1, 'f_pow': 2, 'f_exp': 1, 'f_log': 1}
FLOAT_CMP = {'f_ls', 'f_gt'}
FLOAT_CONST = {'F_ZERO', 'F_ONE', 'F_TWO', 'F_HALF', 'F_PI'}
CONTAINER_MAKERS = {'words', 'ints_n', 'ints_n1', 'floats'}


class UF:
    def __init__(self):
        self.p = {}
        self.sz = {}
        self.fl = {}
        self.it = {}

    def find(self, k):
        root = k
        while True:
            p = self.p.setdefault(root, root)
            if p == root: break
            root = p
        while k != root:
            nxt = self.p[k]
            self.p[k] = root
            k = nxt
        return root

    def union(self, a, b):
        if a is None or b is None: return
        ra, rb = self.find(a), self.find(b)
        if ra == rb: return
        if self.sz.get(ra, 1) > self.sz.get(rb, 1): ra, rb = rb, ra
        self.p[ra] = rb
        self.sz[rb] = self.sz.get(rb, 1) + self.sz.get(ra, 1)
        for d in (self.fl, self.it):
            if ra in d:
                n, ex = d.pop(ra)
                m, ex2 = d.get(rb, (0, []))
                d[rb] = (n + m, (ex2 + ex)[:4])

    def mark(self, k, which, why):
        if k is None: return
        r = self.find(k)
        d = self.fl if which == 'f' else self.it
        n, ex = d.get(r, (0, []))
        d[r] = (n + 1, ex if len(ex) >= 4 else ex + [why])

    def is_float(self, k):
        return k is not None and self.find(k) in self.fl

    def is_int(self, k):
        return k is not None and self.find(k) in self.it


class Program:
    def __init__(self, convert_roots, readonly_roots):
        self.files = []
        for root, runtime in [(r, False) for r in convert_roots] + [(r, True) for r in readonly_roots]:
            paths = [root] if root.endswith('.ludic') else sorted(glob.glob(root + '/**/*.ludic', recursive=True))
            for p in paths:
                self.files.append(FileParse(p, open(p).read(), runtime=runtime))
        self.funcs, self.globals, self.props = {}, {}, {}
        for fp in self.files:
            for n, f in fp.funcs.items():
                if n not in self.funcs or not f.runtime: self.funcs.setdefault(n, f)
            for n, d in fp.globals.items():
                d.key = ('G', n)
                self.globals.setdefault(n, d)
            for r, fields in fp.props.items():
                for fn_, d in fields.items():
                    d.key = ('F', r, fn_)
                self.props.setdefault(r, fields)
        for f in self.funcs.values():
            for i, d in enumerate(f.params): d.key = ('P', f.name, i)
            if f.ret: f.ret.key = ('R', f.name)
            for n, d in f.locals.items(): d.key = ('L', f.name, n)
        self.field_owners = {}
        for r, fields in self.props.items():
            for fn_ in fields: self.field_owners.setdefault(fn_, []).append(r)
        self.uf = UF()
        self.types = {}          # key -> declared type text
        for d in self.all_decls(): self.types[d.key] = d.ty
        # a declaration that already says float is evidence of its own: code converted earlier
        # (render3d, once the game had moved) is read as it is written
        for d in self.all_decls():
            if d.ty == 'float': self.uf.mark(d.key, 'f', 'declared float')
            elif d.ty in ('floats', '[]float'): self.uf.mark(('E', d.key), 'f', 'declared floats')
        self.calls = []          # (callee Func, arg index, arg key, node)
        self.bound_args = []     # (call node, arg node, arg key): a float going into a runtime call
        self.bound_rets = {}     # call node id -> key of a runtime result
        self.node_key = {}       # id(node) -> key
        self.stores = []         # (container key, value key, value node): a[i] = v, push(a, v)
        self.elinks = []         # (container, container): one buffer's contents flow into another's
        self.flows = []          # (a, b, where): a value moves between a and b (=, let, return, ==)
        self.splits = []         # the flows whose two ends turned out different kinds: bits cross there
        self.reads = []          # (container key, read-site key): v = a[i]
        self.rets = []           # (callee, call-site key)
        self.poly_ret = set()
        self.cur = ''
        self.scope = None
        self.mixed = set()       # containers holding both floats and ints: they keep their bits

    def all_decls(self):
        for d in self.globals.values(): yield d
        for fields in self.props.values():
            yield from fields.values()
        for f in self.funcs.values():
            yield from f.params
            if f.ret: yield f.ret
            yield from f.locals.values()

    # ---- names --------------------------------------------------------------
    def lookup(self, name, fn):
        f = self.funcs.get(fn)
        if f:
            sc = self.scope or {}
            if name in sc: return f.locals[sc[name]].key
            if name in f.locals and not sc: return f.locals[name].key
            for d in f.params:
                if d.name == name: return d.key
        if name in self.globals: return self.globals[name].key
        return None

    def type_of_key(self, k):
        return self.types.get(k, '')

    def rec_of(self, node, fn):
        """the record type an expression evaluates to, as far as declarations say"""
        if node.kind == 'id':
            k = self.lookup(node.val, fn)
            return self.type_of_key(k) if k else ''
        if node.kind == 'member':
            r = self.rec_of(node.kids[0], fn)
            d = self.props.get(r, {}).get(node.val)
            return d.ty if d else ''
        if node.kind == 'index':
            t = self.rec_of(node.kids[0], fn)
            return t[2:] if t.startswith('[]') else ''
        if node.kind == 'call' and node.kids[0].kind == 'id':
            f = self.funcs.get(node.kids[0].val)
            return f.ret.ty if f and f.ret else ''
        if node.kind == 'new': return node.val
        if node.kind == 'paren': return self.rec_of(node.kids[0], fn)
        return ''

    def member_key(self, node, fn):
        r = self.rec_of(node.kids[0], fn)
        if r in self.props and node.val in self.props[r]: return self.props[r][node.val].key
        owners = self.field_owners.get(node.val, [])
        if len(owners) == 1: return self.props[owners[0]][node.val].key
        return ('FU', id(node))

    CONTAINER_TYPES = ('words', 'floats', 'pointers')

    def is_container(self, k):
        if k is None: return False
        if k[0] == 'A': return True
        if k[0] == 'RC': return self.types.get(k, '') in self.CONTAINER_TYPES or self.types.get(k, '').startswith('[]')
        t = self.types.get(k, '')
        return t in self.CONTAINER_TYPES or t.startswith('[]')

    def flow(self, a, b):
        if a is not None and b is not None: self.flows.append((a, b, self.cur))

    def settle_flows(self):
        keep = []
        for a, b, where in self.flows:
            d = self.decide([a, b])
            if d == 'split':
                self.splits.append((a, b, where))
            elif d == 'join':
                self.link(a, b)
            else:
                keep.append((a, b, where))
        self.flows = keep

    def link(self, a, b):
        """a value flows between a and b. Buffers are not merged: their elements are linked, later,
        and only if the two carry the same kind of number"""
        if a is None or b is None: return
        if self.is_container(a) or self.is_container(b):
            self.elinks.append((a, b))
            return
        self.uf.union(a, b)

    def inner_of(self, k):
        """the key every inner buffer of nested buffer k shares, or None when k is not nested"""
        t = self.types.get(k, '')
        if not t.startswith('[]'): return None
        it = t[2:]
        if not (it in self.CONTAINER_TYPES or it.startswith('[]')): return None
        ik = ('E', k)
        self.types[ik] = it
        return ik

    def settle_elinks(self):
        for a, b in list(self.elinks):
            ia, ib = self.inner_of(a), self.inner_of(b)
            if ia is not None and ib is not None and (ia, ib) not in self.elinks: self.elinks.append((ia, ib))
        for a, b in self.elinks:
            ea, eb = ('E', a), ('E', b)
            if a in self.mixed or b in self.mixed: continue
            d = self.decide([ea, eb])
            if d == 'split':
                self.mixed.add(a)
                self.mixed.add(b)
                continue
            if d == 'join': self.uf.union(ea, eb)

    # ---- expressions -------------------------------------------------------
    def ev(self, n, fn):
        k = self._ev(n, fn)
        if k is not None: self.node_key[id(n)] = k
        return k

    def _ev(self, n, fn):
        uf = self.uf
        kind = n.kind
        if kind == 'num':
            if '.' in n.val: return None
            if n.val in ('0',) or n.val.startswith('0x'): return None
            if int(n.val.replace('_', '')) > (1 << 20): return None       # a float's bits, written out
            k = ('N', id(n))
            uf.mark(k, 'i', 'literal')
            return k
        if kind == 'id':
            if n.val in FLOAT_CONST:
                k = ('C', id(n))
                uf.mark(k, 'f', n.val)
                return k
            return self.lookup(n.val, fn)
        if kind == 'paren': return self.ev(n.kids[0], fn)
        if kind == 'tmpl':
            for x in n.kids: self.ev(x, fn)
            return None
        if kind == 'member': return self.member_key(n, fn) if n.kids[0].kind != 'id' or n.kids[0].val[:1].islower() else None
        if kind == 'index':
            ck = self.ev(n.kids[0], fn)
            ik = self.ev(n.kids[1], fn)
            uf.mark(ik, 'i', 'index')
            if ck is None: return None
            inner = self.inner_of(ck)
            if inner is not None: return inner
            rk = ('RD', id(n))
            self.reads.append((ck, rk))
            return rk
        if kind == 'slice':
            for x in n.kids: self.ev(x, fn)
            return None
        if kind == 'unary':
            x = self.ev(n.kids[0], fn)
            if n.val == '-':
                uf.mark(x, 'i', 'negated with -')
                return x
            return None
        if kind == 'bin':
            a, b = self.ev(n.kids[0], fn), self.ev(n.kids[1], fn)
            if n.val in ('==', '!='):
                self.flow(a, b)
                return None
            if n.val in ('and', 'or', '&&', '||'): return None
            if n.val in ('<', '>', '<=', '>='):
                self.flow(a, b)
                return None
            uf.mark(a, 'i', f'operand of {n.val}')
            uf.mark(b, 'i', f'operand of {n.val}')
            if n.val == '..': return None
            k = ('X', id(n))
            uf.mark(k, 'i', f'result of {n.val}')
            return k
        if kind == 'list':
            k = ('A', id(n))
            for x in n.kids:
                v = self.ev(x, fn)
                if v is not None: self.stores.append((k, v, x))
            return k
        if kind == 'new':
            if not n.val.startswith('[]'): return None
            self.types[('A', id(n))] = n.val
            return ('A', id(n))
        if kind == 'call': return self.ev_call(n, fn)
        for x in n.kids: self.ev(x, fn)
        return None

    def ev_call(self, n, fn):
        uf = self.uf
        callee = n.kids[0]
        args = n.kids[1:]
        name = callee.val if callee.kind == 'id' else None
        keys = [self.ev(a.kids[0] if a.kind == 'named' else a, fn) for a in args]
        if name in FLOAT_OPS:
            for k in keys: uf.mark(k, 'f', name)
            k = ('X', id(n))
            uf.mark(k, 'f', name)
            return k
        if name in FLOAT_CMP:
            for k in keys: uf.mark(k, 'f', name)
            return None
        if name in ('fl', 'fi', 'fr', 'f_from_int', 'fx_to_f32', 'f_neg1'):
            if name in ('fi', 'fr', 'f_from_int'):
                for k in keys: uf.mark(k, 'i', name)
            k = ('X', id(n))
            uf.mark(k, 'f', name)
            return k
        if name in ('f_to_int',):
            for k in keys: uf.mark(k, 'f', name)
            k = ('X', id(n))
            uf.mark(k, 'i', name)
            return k
        if name in ('f_fx', 'f32_to_fx'):
            for k in keys: uf.mark(k, 'f', name)
            return None
        if name == 'f_lt':
            for k in keys: uf.mark(k, 'f', name)
            return None
        if name in CONTAINER_MAKERS: return ('A', id(n))
        if name == 'push' and len(keys) == 2 and keys[0] is not None:
            inner = self.inner_of(keys[0])
            if inner is not None and keys[1] is not None:
                self.elinks.append((inner, keys[1]))
                return None
            if keys[1] is not None: self.stores.append((keys[0], keys[1], args[1]))
            return None
        if name == 'len':
            k = ('X', id(n))
            uf.mark(k, 'i', 'len')
            return k
        f = self.funcs.get(name) if name else None
        if f and not f.runtime and not f.extern:
            for i, k in enumerate(keys):
                if i < len(f.params): self.calls.append((f, i, k, args[i]))
            if not f.ret: return None
            rk = ('RC', id(n))
            self.types[rk] = f.ret.ty
            self.rets.append((f, rk))
            return rk
        # a runtime or engine call: a float going in leaves as bits, a result coming out is bits
        for i, a in enumerate(args):
            if keys[i] is not None: self.bound_args.append((n, a, keys[i]))
        k = ('B', id(n))
        self.bound_rets[id(n)] = k
        return k

    # ---- statements -------------------------------------------------------
    def run(self):
        uf = self.uf
        for d in self.globals.values():
            if d.init is not None: self.flow(d.key, self.ev(d.init, None))
        for fields in self.props.values():
            for d in fields.values():
                if d.init is not None: self.flow(d.key, self.ev(d.init, None))
        for fp in self.files:
            for s in fp.stmts:
                fn = s.fn
                self.scope = s.scope
                self.cur = f'{fp.path.split("/")[-1]}:{fn}:{s.kind}:{fp.src.count(chr(10), 0, (s.a or s.b).s if (s.a or s.b) else 0) + 1}'
                if s.kind == 'let':
                    if s.b is not None:
                        if not s.decl.ty: self.types[s.decl.key] = self.rec_of(s.b, fn)
                        self.flow(s.decl.key, self.ev(s.b, fn))
                elif s.kind == 'assign':
                    if s.a.kind == 'index':
                        ck = self.ev(s.a.kids[0], fn)
                        uf.mark(self.ev(s.a.kids[1], fn), 'i', 'index')
                        vk = self.ev(s.b, fn)
                        inner = self.inner_of(ck) if ck is not None else None
                        if inner is not None and vk is not None: self.elinks.append((inner, vk))
                        elif ck is not None and vk is not None: self.stores.append((ck, vk, s.b))
                    else:
                        self.flow(self.ev(s.a, fn), self.ev(s.b, fn))
                elif s.kind == 'opassign':
                    uf.mark(self.ev(s.a, fn), 'i', s.op)
                    uf.mark(self.ev(s.b, fn), 'i', s.op)
                elif s.kind == 'return':
                    f = self.funcs.get(fn)
                    k = self.ev(s.a, fn)
                    if f and f.ret: self.flow(f.ret.key, k)
                elif s.kind == 'forrange':
                    uf.mark(self.ev(s.a, fn), 'i', 'for range')
                    uf.mark(self.ev(s.b, fn), 'i', 'for range')
                    uf.mark(self.lookup(s.var, fn), 'i', 'for range')
                elif s.kind == 'foreach':
                    ck = self.ev(s.a, fn)
                    if ck is not None:
                        vk = self.lookup(s.var, fn)
                        et = self.types.get(ck, '')
                        if et.startswith('[]'): self.types[vk] = et[2:]
                        self.reads.append((ck, vk))
                else:
                    if s.a is not None: self.ev(s.a, fn)
        # parameters: joined to what is passed, unless a function is fed both kinds
        self.poly = set()
        self.cur = 'settle'
        self.final = False
        for _ in range(12):
            self.settle_flows()
            self.settle_params()
            self.settle_stores()
            self.settle_reads()
            self.settle_rets()
            self.settle_elinks()
        self.final = True             # what never gained a kind joins whatever it flows into
        for _ in range(3):
            self.settle_flows()
            self.settle_params()
            self.settle_stores()
            self.settle_reads()
            self.settle_rets()
            self.settle_elinks()
        self.spread_mixed()
        return self

    def spread_mixed(self):
        """a buffer shared with one that holds both kinds holds both too"""
        grew = True
        while grew:
            grew = False
            for a, b in self.elinks:
                if (a in self.mixed) != (b in self.mixed):
                    self.mixed.add(a)
                    self.mixed.add(b)
                    grew = True

    def decide(self, keys):
        """'join', 'wait' or 'split' for a set of keys a value flows between"""
        k = self.kinds_of(keys)
        if k == {'f', 'i'}: return 'split'
        if k or self.final: return 'join'
        return 'wait'

    def settle_reads(self):
        for ck, rk in self.reads:
            root = ck
            if root in self.mixed: continue
            e = ('E', root)
            d = self.decide([e, rk])
            if d == 'split':
                self.mixed.add(root)
                continue
            if d == 'join': self.uf.union(e, rk)

    def settle_rets(self):
        by = {}
        for f, rk in self.rets: by.setdefault(f.name, []).append(rk)
        for fn_, rks in by.items():
            if fn_ in self.poly_ret: continue
            rkey = self.funcs[fn_].ret.key
            probe = [('E', k) for k in rks + [rkey]] if self.is_container(rkey) else rks + [rkey]
            d = self.decide(probe)
            if d == 'split':
                self.poly_ret.add(fn_)
                continue
            if d == 'join':
                for rk in rks: self.link(rkey, rk)

    def kinds_of(self, keys):
        uf, kinds = self.uf, set()
        for k in keys:
            if k is None: continue
            if uf.is_float(k) and not uf.is_int(k): kinds.add('f')
            elif uf.is_int(k) and not uf.is_float(k): kinds.add('i')
        return kinds

    def settle_stores(self):
        by = {}
        for ck, vk, node in self.stores: by.setdefault(ck, []).append(vk)
        for root, vks in by.items():
            if root in self.mixed: continue
            d = self.decide(vks + [('E', root)])
            if d == 'split':
                self.mixed.add(root)
                continue
            if d == 'join':
                for vk in vks: self.uf.union(('E', root), vk)

    def settle_params(self):
        uf = self.uf
        by = {}
        for f, i, k, a in self.calls: by.setdefault((f.name, i), []).append(k)
        for (fn_, i), ks in by.items():
            f = self.funcs[fn_]
            pk = f.params[i].key
            cont = self.is_container(pk)
            kinds = set()
            for k in ks + [pk]:
                if k is None: continue
                q = ('E', k) if cont or self.is_container(k) else k
                if uf.is_float(q) and not uf.is_int(q): kinds.add('f')
                elif uf.is_int(q) and not uf.is_float(q): kinds.add('i')
            if kinds == {'f', 'i'}:
                self.poly.add((fn_, i))
                if self.final and not cont:
                    # an argument with no evidence of its own takes the parameter's kind
                    for k in ks:
                        if k is not None and not uf.is_float(k) and not uf.is_int(k) and not self.is_container(k): self.link(pk, k)
                continue
            if not kinds and not self.final: continue
            for k in ks: self.link(pk, k)

    def conflicts(self):
        uf = self.uf
        roots = set(uf.fl) & set(uf.it)
        return [(r, uf.fl[r], uf.it[r]) for r in roots]


if __name__ == '__main__':
    import sys
    game = sys.argv[1]
    home = sys.argv[2]
    prog = Program([game + '/src', game + '/lab', home + '/packages/ludic.render3d'], [home + '/runtime/native']).run()
    fl = sum(1 for d in prog.all_decls() if prog.uf.is_float(d.key) and not prog.uf.is_int(d.key))
    print(f'{len(prog.files)} files, {len(prog.funcs)} functions; {fl} declarations are float')
    cs = prog.conflicts()
    print(f'{len(cs)} groups are both; {len(prog.splits)} flows cross between kinds; {len(prog.poly)} params and {len(prog.poly_ret)} returns take both; {len(prog.mixed)} buffers hold both')
    for a, b, w in prog.splits[:25]: print('  split', w, a, b)
    names = {}
    for d in prog.all_decls():
        r = prog.uf.find(d.key)
        names.setdefault(r, []).append(d.key)
    for r, f_, i_ in sorted(cs, key=lambda c: -len(names.get(c[0], [])))[:25]:
        print(len(names.get(r, [])), names.get(r, [])[:6], 'F:', f_[:2], 'I:', i_[:3])
