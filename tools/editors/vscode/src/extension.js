/* ============================================================================
 * The VS Code half of Ludic support.
 *
 * There is deliberately very little here. Highlighting comes from the TextMate
 * grammar in syntaxes/ (shared, unmodified, with every other editor), and
 * everything else — completion, hover, diagnostics, formatting, symbols —
 * comes from `ludic-lsp`, the same binary JetBrains and Neovim talk to. This
 * file's whole job is finding that binary and keeping it alive.
 * ==========================================================================*/
const path = require('path');
const fs = require('fs');
const os = require('os');
const vscode = require('vscode');
const { LanguageClient, TransportKind } = require('vscode-languageclient/node');

let client = null;
let output = null;

/** Where the language server might be, in the order we should look. */
function resolveServer(folders) {
  const configured = vscode.workspace.getConfiguration('ludic').get('server.path');
  if (configured) return expand(configured);

  const names = ['ludic-lsp', 'ludic-lsp.exe'];
  for (const folder of folders) {
    const root = folder.uri.fsPath;
    for (const rel of ['build', 'tools/build', 'bin', '.']) {
      for (const name of names) {
        const p = path.join(root, rel, name);
        if (isExecutable(p)) return p;
      }
    }
  }
  // Fall back to PATH; spawning by bare name lets the OS resolve it.
  for (const dir of (process.env.PATH || '').split(path.delimiter)) {
    for (const name of names) {
      const p = path.join(dir, name);
      if (isExecutable(p)) return p;
    }
  }
  return null;
}

function resolveCompiler(folders) {
  const configured = vscode.workspace.getConfiguration('ludic').get('compilerPath');
  if (configured) return expand(configured);
  for (const folder of folders) {
    const p = path.join(folder.uri.fsPath, 'build', 'ludicc');
    if (isExecutable(p)) return p;
  }
  return '';
}

function expand(p) {
  return p.startsWith('~') ? path.join(os.homedir(), p.slice(1)) : p;
}

function isExecutable(p) {
  try {
    fs.accessSync(p, fs.constants.X_OK);
    return fs.statSync(p).isFile();
  } catch {
    return false;
  }
}

async function start(context) {
  const cfg = vscode.workspace.getConfiguration('ludic');
  if (!cfg.get('server.enabled')) return;

  const folders = vscode.workspace.workspaceFolders || [];
  const server = resolveServer(folders);
  if (!server) {
    // Not an error worth a modal: the grammar still highlights, and plenty of
    // people open a .ludic file without having built the toolchain.
    output.appendLine(
      'ludic-lsp not found. Build it with tools/build-tools.sh, or set "ludic.server.path". ' +
      'Syntax highlighting works without it; completion and diagnostics do not.'
    );
    return;
  }
  output.appendLine(`starting ${server}`);

  const serverOptions = {
    run: { command: server, args: ['--stdio'], transport: TransportKind.stdio },
    debug: { command: server, args: ['--stdio'], transport: TransportKind.stdio }
  };

  const clientOptions = {
    // Markdown is included on purpose: ```ludic fences in a .md get the same
    // diagnostics, hover and semantic highlighting as a real source file.
    documentSelector: [
      { scheme: 'file', language: 'ludic' },
      { scheme: 'file', language: 'markdown' }
    ],
    synchronize: {
      fileEvents: vscode.workspace.createFileSystemWatcher('**/*.ludic'),
      configurationSection: 'ludic'
    },
    outputChannel: output,
    initializationOptions: {
      compilerPath: resolveCompiler(folders),
      compilerDiagnostics: cfg.get('compilerDiagnostics'),
      indentSize: cfg.get('indentSize')
    }
  };

  client = new LanguageClient('ludic', 'Ludic Language Server', serverOptions, clientOptions);
  await client.start();
  context.subscriptions.push(client);
}

async function stop() {
  if (!client) return;
  const c = client;
  client = null;
  await c.stop();
}

async function activate(context) {
  output = vscode.window.createOutputChannel('Ludic');
  context.subscriptions.push(output);

  context.subscriptions.push(
    vscode.commands.registerCommand('ludic.restartServer', async () => {
      await stop();
      await start(context);
      vscode.window.setStatusBarMessage('Ludic: language server restarted', 3000);
    }),
    vscode.commands.registerCommand('ludic.showOutput', () => output.show())
  );

  context.subscriptions.push(
    vscode.workspace.onDidChangeConfiguration(async (e) => {
      if (e.affectsConfiguration('ludic.server')) {
        await stop();
        await start(context);
      }
    })
  );

  await start(context);
}

function deactivate() {
  return stop();
}

module.exports = { activate, deactivate };
