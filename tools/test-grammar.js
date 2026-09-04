/* ============================================================================
 * test-grammar.js — tokenise Ludic with the real TextMate engine.
 *
 * A TextMate grammar is a pile of Oniguruma regexes in a JSON file: nothing
 * validates it, and a broken pattern shows up as "that word stopped being
 * coloured" months later. This runs the grammar through vscode-textmate, the
 * same engine VS Code uses, and asserts that specific spans get specific
 * scopes — including a ```ludic fence inside Markdown, which is the part most
 * likely to break silently.
 *
 *   node tools/test-grammar.js
 *
 * Needs vscode-textmate and vscode-oniguruma (from the VS Code extension's
 * node_modules, or a directory named by $LUDIC_NODE_MODULES); exits 2 when they
 * are not installed so the caller can report a skip rather than a pass.
 * ==========================================================================*/
const fs = require('fs');
const path = require('path');

const ROOT = path.dirname(__dirname);
const SHARED = path.join(ROOT, 'tools', 'editors', 'shared');

let vsctm, oniguruma;
try {
  const local = path.join(ROOT, 'tools', 'editors', 'vscode', 'node_modules');
  const paths = [local, ...(process.env.LUDIC_NODE_MODULES ? [process.env.LUDIC_NODE_MODULES] : []), ...module.paths];
  vsctm = require(require.resolve('vscode-textmate', { paths }));
  oniguruma = require(require.resolve('vscode-oniguruma', { paths }));
} catch (e) {
  console.log('  skip  TextMate grammar (npm i vscode-textmate vscode-oniguruma to run)');
  process.exit(2);
}

let passed = 0;
let failed = 0;

function ok(name) { passed++; console.log(`  ok    ${name}`); }
function bad(name, detail) { failed++; console.log(`  FAIL  ${name}\n        ${detail}`); }

async function main() {
  const wasmPath = require.resolve('vscode-oniguruma/release/onig.wasm', {
    paths: [path.join(ROOT, 'tools', 'editors', 'vscode', 'node_modules'), ...(process.env.LUDIC_NODE_MODULES ? [process.env.LUDIC_NODE_MODULES] : []), ...module.paths]
  });
  await oniguruma.loadWASM(fs.readFileSync(wasmPath).buffer);

  const onigLib = Promise.resolve({
    createOnigScanner: (sources) => new oniguruma.OnigScanner(sources),
    createOnigString: (s) => new oniguruma.OnigString(s)
  });

  const grammars = {
    'source.ludic': path.join(SHARED, 'ludic.tmLanguage.json'),
    'markdown.ludic.codeblock': path.join(SHARED, 'ludic.markdown-injection.json')
  };

  const registry = new vsctm.Registry({
    onigLib,
    loadGrammar: (scope) => {
      const file = grammars[scope];
      if (!file) return Promise.resolve(null);
      return Promise.resolve(vsctm.parseRawGrammar(fs.readFileSync(file, 'utf8'), file));
    },
    getInjections: (scope) =>
      scope === 'text.html.markdown' || scope.startsWith('text.html.markdown')
        ? ['markdown.ludic.codeblock']
        : undefined
  });

  const grammar = await registry.loadGrammar('source.ludic');
  if (!grammar) {
    bad('grammar loads', 'registry returned null');
    return report();
  }
  ok('grammar loads without a regex error');

  // Tokenise a line and return the scopes covering the first occurrence of a
  // substring, so assertions read in terms of the source rather than offsets.
  function scopesFor(line, needle, state = vsctm.INITIAL) {
    const at = line.indexOf(needle);
    if (at < 0) throw new Error(`${needle} not in ${line}`);
    const result = grammar.tokenizeLine(line, state);
    for (const t of result.tokens) {
      if (t.startIndex <= at && at < t.endIndex) return t.scopes;
    }
    return [];
  }
  function has(scopes, prefix) { return scopes.some((s) => s.startsWith(prefix)); }

  function expect(name, line, needle, prefix) {
    try {
      const scopes = scopesFor(line, needle);
      if (has(scopes, prefix)) ok(name);
      else bad(name, `${needle!== undefined ? JSON.stringify(needle) : ''} got [${scopes.join(' ')}], wanted ${prefix}`);
    } catch (e) {
      bad(name, e.message);
    }
  }

  expect('comment', '# a note', '# a note', 'comment.line');
  expect('string', 'const S: string = "hi"', '"hi"', 'string.quoted.double');
  expect('interpolated string', 'let m = `hp {hp}`', '`hp {hp}`', 'string.interpolated');
  expect('hex literal', 'Screen.clear(0x0e0e16)', '0x0e0e16', 'constant.numeric.hex');
  expect('fixed literal', 'let f = 1.5', '1.5', 'constant.numeric.fixed');
  expect('declaration keyword', 'property Pos { x: int = 0 }', 'property', 'storage.type.component');
  expect('property name', 'property Pos { x: int = 0 }', 'Pos', 'entity.name.type.component');
  expect('primitive type', 'property Pos { x: int = 0 }', 'int', 'support.type.primitive');
  expect('model keyword', 'model Hero { Pos, Stats }', 'model', 'storage.type.archetype');
  expect('model name', 'model Hero { Pos, Stats }', 'Hero', 'entity.name.type.archetype');
  expect('handler name', 'handler Move phase Update {', 'Move', 'entity.name.function.system');
  expect('phase name', 'handler Move phase Update {', 'Update', 'constant.language.phase');
  expect('clause keyword', 'handler Move phase Update {', 'phase', 'keyword.other.clause');
  expect('annotation', '@Queries(Pos, Vel) handler Move phase Update {', '@Queries', 'entity.name.function.decorator');
  expect('builtin call', '  print(1)', 'print', 'support.function.builtin');
  expect('control keyword', '  if a == 1 { }', 'if', 'keyword.control');
  expect('become keyword', '  become Playing', 'become', 'keyword.control');
  expect('member access', '  p.x = 1', 'x', 'variable.other.property');
  expect('query tag filter', 'for (p) in query [Pos, {Player}] {', 'Player', 'entity.name.type.tag');
  expect('query property', 'for (p) in query [Pos, {Player}] {', 'Pos', 'entity.name.type.component');
  expect('widget type', '    button id: Go text: "go"', 'button', 'support.class.widget');
  expect('user function call', '  my_helper(1)', 'my_helper', 'entity.name.function');
  expect('model in spawn', '  spawn Hero {', 'Hero', 'entity.name.type.archetype');
  expect('scene declaration', 'scene Battle {', 'Battle', 'entity.name.type');
  expect('prefab declaration', 'prefab Orc {', 'Orc', 'entity.name.type');
  expect('event declaration', 'event Hurt { amount: int = 0 }', 'Hurt', 'entity.name.type');

  // A whole file must tokenise without the engine bailing out.
  const sample = fs.readFileSync(path.join(ROOT, 'examples', 'games', 'menu.ludic'), 'utf8');
  let state = vsctm.INITIAL;
  let tokenCount = 0;
  for (const line of sample.split('\n')) {
    const r = grammar.tokenizeLine(line, state);
    state = r.ruleStack;
    tokenCount += r.tokens.length;
  }
  if (tokenCount > 200) ok(`tokenises examples/games/menu.ludic (${tokenCount} tokens)`);
  else bad('tokenises examples/games/menu.ludic', `only ${tokenCount} tokens`);

  // ---- the Markdown injection ---------------------------------------------
  const mdGrammar = await registry.loadGrammar('markdown.ludic.codeblock');
  if (!mdGrammar) {
    bad('markdown injection grammar loads', 'registry returned null');
    return report();
  }
  ok('markdown injection grammar loads without a regex error');

  // Drive the injection directly: feed it the fence, then the body, and check
  // the body is handed to source.ludic.
  const lines = ['```ludic', 'property Pos { x: int = 0 }', '```'];
  let mdState = vsctm.INITIAL;
  const bodyScopes = [];
  lines.forEach((line, i) => {
    const r = mdGrammar.tokenizeLine(line, mdState);
    mdState = r.ruleStack;
    if (i === 1) for (const t of r.tokens) bodyScopes.push(t.scopes.join(' '));
  });
  const joined = bodyScopes.join(' | ');
  if (joined.includes('meta.embedded.block.ludic')) ok('markdown fence body is embedded as Ludic');
  else bad('markdown fence body is embedded as Ludic', joined || '(no tokens)');
  if (joined.includes('storage.type.component')) ok('markdown fence body is highlighted by source.ludic');
  else bad('markdown fence body is highlighted by source.ludic', joined || '(no tokens)');

  report();
}

function report() {
  console.log(`  ${passed} passed, ${failed} failed`);
  process.exit(failed ? 1 : 0);
}

main().catch((e) => {
  console.log(`  FAIL  grammar test crashed\n        ${e.stack}`);
  process.exit(1);
});
