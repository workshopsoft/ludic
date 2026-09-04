-- Ludic support for Neovim (0.9+), with no plugin manager and no dependencies.
--
--   :lua require('ludic').setup()
--   -- or, from init.lua:
--   vim.opt.runtimepath:append('/path/to/gpp/tools/editors/neovim')
--   require('ludic').setup({ server = '/path/to/gpp/bin/ludic-lsp' })
--
-- Highlighting here comes from the language server's semantic tokens, which
-- Neovim applies natively -- there is no tree-sitter grammar to install and no
-- second copy of the vocabulary to keep in sync.

local M = {}

local function find_executable(names, roots, subdirs)
  for _, root in ipairs(roots) do
    for _, sub in ipairs(subdirs) do
      for _, name in ipairs(names) do
        local p = root .. '/' .. sub .. '/' .. name
        if vim.fn.executable(p) == 1 then return p end
      end
    end
  end
  for _, name in ipairs(names) do
    if vim.fn.executable(name) == 1 then return name end
  end
  return nil
end

function M.setup(opts)
  opts = opts or {}

  -- .ludic files are Ludic
  vim.filetype.add({ extension = { ludic = 'ludic' } })

  vim.api.nvim_create_autocmd('FileType', {
    pattern = 'ludic',
    callback = function()
      vim.bo.commentstring = '# %s'
      vim.bo.comments = ':#'
      vim.bo.expandtab = true
      vim.bo.shiftwidth = opts.indent or 2
      vim.bo.tabstop = opts.indent or 2
    end,
  })

  local root_markers = { 'package.ludic', 'LANGUAGE.md', '.git' }

  local function root_dir(fname)
    local found = vim.fs.find(root_markers, { path = vim.fs.dirname(fname), upward = true })[1]
    return found and vim.fs.dirname(found) or vim.fs.dirname(fname)
  end

  vim.api.nvim_create_autocmd('FileType', {
    -- markdown is included on purpose: ```ludic fences get diagnostics and
    -- semantic highlighting like any source file
    pattern = { 'ludic', 'markdown' },
    callback = function(args)
      local root = root_dir(vim.api.nvim_buf_get_name(args.buf))
      local server = opts.server or find_executable(
        { 'ludic-lsp' }, { root }, { 'bin', 'build', '.' })
      if not server then return end
      local compiler = opts.compiler or find_executable(
        { 'ludicc' }, { root }, { 'bin', 'build', '.' }) or ''

      vim.lsp.start({
        name = 'ludic-lsp',
        cmd = { server, '--stdio' },
        root_dir = root,
        init_options = {
          compilerPath = compiler,
          compilerDiagnostics = opts.compiler_diagnostics ~= false,
          indentSize = opts.indent or 2,
        },
      }, { bufnr = args.buf })
    end,
  })

  if opts.format_on_save ~= false then
    vim.api.nvim_create_autocmd('BufWritePre', {
      pattern = { '*.ludic' },
      callback = function() vim.lsp.buf.format({ async = false, timeout_ms = 2000 }) end,
    })
  end
end

return M
