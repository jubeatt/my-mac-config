vim.pack.add({
  "https://github.com/neovim/nvim-lspconfig",
  "https://github.com/folke/lazydev.nvim",
  "https://github.com/mason-org/mason.nvim",
  "https://github.com/mason-org/mason-lspconfig.nvim",
  "https://github.com/folke/trouble.nvim",
})

vim.diagnostic.config({
  jump = {
    on_jump = function(diagnostic, bufnr)
      if diagnostic then
        vim.diagnostic.open_float({ bufnr = bufnr, scope = "cursor", focus = false })
      end
    end,
  },
})

require("lazydev").setup()

require("mason").setup()
-- Installed servers are enabled automatically.
require("mason-lspconfig").setup({
  ensure_installed = { "tailwindcss", "lua_ls", "jsonls", "cssls", "html", "pyright", "ruff", "bashls", "yamlls" },
})

-- Pyright infers the Python version from `python3` on PATH (macOS ships 3.9) unless the
-- project venv is active, so point it at the project's .venv when there is one.
-- Mutate settings in place: the client already holds this table when before_init runs.
vim.lsp.config("pyright", {
  before_init = function(_, config)
    local venv_python = config.root_dir and vim.fs.joinpath(config.root_dir, ".venv/bin/python")
    if venv_python and vim.uv.fs_stat(venv_python) then
      config.settings.python.pythonPath = venv_python
    end
  end,
})

-- TypeScript 7's native LSP.
vim.lsp.config("tsc", {
  on_init = function(client)
    -- TS7 handles folder renames but advertises only file-extension filters.
    local workspace = client.server_capabilities.workspace
    local operations = workspace and workspace.fileOperations
    local rename = operations and operations.willRename
    if rename then
      table.insert(rename.filters, { scheme = "file", pattern = { glob = "**/*", matches = "folder" } })
    end
  end,
})
vim.lsp.enable("tsc")

vim.lsp.enable("biome")

-- Oxlint's root_dir reports nil when no config is found; workspace_required keeps the server
-- from starting anyway. Oxfmt needs no LSP: conform formats on save.
vim.lsp.config("oxlint", { workspace_required = true })
vim.lsp.enable("oxlint")

vim.lsp.config("ast_grep", {
  cmd = function(dispatchers, config)
    local local_cmd = config.root_dir and vim.fs.joinpath(config.root_dir, "node_modules/.bin/ast-grep")
    local cmd = local_cmd and vim.fn.executable(local_cmd) == 1 and local_cmd or "ast-grep"
    return vim.lsp.rpc.start({ cmd, "lsp" }, dispatchers)
  end,
})
vim.lsp.enable("ast_grep")

-- Global rather than in LspAttach, so they still work when no server attached.
vim.keymap.set("n", "<leader>cl", function()
  local names = vim.tbl_map(function(client)
    return client.name
  end, vim.lsp.get_clients({ bufnr = 0 }))
  vim.notify(#names > 0 and table.concat(names, ", ") or "No LSP attached", vim.log.levels.INFO)
end, { desc = "Show attached LSP clients" })
vim.keymap.set("n", "<leader>cL", "<cmd>checkhealth vim.lsp<cr>", { desc = "LSP health report" })

local trouble = require("trouble")
trouble.setup({
  focus = true,
  keys = {
    ["<cr>"] = {
      action = function(view, ctx)
        if ctx.item then
          view:jump(ctx.item)
          view:close()
        elseif ctx.node then
          view:fold(ctx.node)
        end
      end,
      desc = "Jump and close",
    },
  },
  modes = {
    -- Keep the symbol gd / grr was invoked on; `r` still refreshes manually.
    -- gd / grr print their own one-line warning on no results.
    lsp_definitions = { auto_refresh = false, warn_no_results = false },
    lsp_references = { auto_refresh = false, warn_no_results = false },
  },
})

-- Open a Trouble LSP view; on no results, show a one-line warning instead of
-- Trouble's two-line one, which triggers a hit-enter prompt.
local function trouble_lsp(mode, empty_msg)
  local view = trouble.open(mode)
  if view then
    view.first_update:next(function()
      if view:count() == 0 then
        vim.notify(empty_msg, vim.log.levels.WARN)
      end
    end)
  end
  return view
end

local function source_action(kind)
  return function()
    vim.lsp.buf.code_action({ apply = true, context = { only = { kind }, diagnostics = {} } })
  end
end

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("lsp-attach", { clear = true }),
  callback = function(ev)
    -- Trouble jumps straight to a single definition and lists multiple ones like grr.
    vim.keymap.set("n", "gd", function()
      trouble_lsp("lsp_definitions", "No definition found")
    end, { buffer = ev.buf, desc = "Go to definition" })
    vim.keymap.set("n", "grr", function()
      if trouble.is_open("lsp_references") then
        trouble.close("lsp_references")
        return
      end
      local view = trouble_lsp("lsp_references", "No references found")
      if view then
        -- Trouble forces foldlevel=99 on its window; level 1 keeps the "References" header open but folds each file.
        view:wait(function()
          view:fold_level({ level = 1 })
        end)
      end
    end, { buffer = ev.buf, desc = "References" })
    vim.keymap.set("n", "gO", "<cmd>FzfLua lsp_document_symbols<cr>", { buffer = ev.buf, desc = "Document symbols" })
    -- Live variant re-queries the server on every keystroke, like VS Code's `#` symbol search.
    vim.keymap.set(
      "n",
      "<leader>fs",
      "<cmd>FzfLua lsp_live_workspace_symbols<cr>",
      { buffer = ev.buf, desc = "Workspace symbols" }
    )
    vim.keymap.set(
      "n",
      "<leader>cu",
      source_action("source.removeUnusedImports"),
      { buffer = ev.buf, desc = "Remove unused imports" }
    )

    local client = vim.lsp.get_client_by_id(ev.data.client_id)

    vim.keymap.set("n", "<leader>ci", function()
      vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = ev.buf }), { bufnr = ev.buf })
    end, { buffer = ev.buf, desc = "Toggle inlay hints" })

    if client and client:supports_method("textDocument/documentHighlight", ev.buf) then
      local group = vim.api.nvim_create_augroup("lsp-document-highlight", { clear = false })
      vim.api.nvim_clear_autocmds({ group = group, buffer = ev.buf })
      vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
        group = group,
        buffer = ev.buf,
        callback = vim.lsp.buf.document_highlight,
      })
      vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
        group = group,
        buffer = ev.buf,
        callback = vim.lsp.buf.clear_references,
      })
    end
  end,
})

vim.api.nvim_create_autocmd("LspDetach", {
  group = vim.api.nvim_create_augroup("lsp-detach", { clear = true }),
  callback = function(ev)
    -- Keep symbol highlighting while another client (e.g. tsc) still provides it.
    -- The detaching client is still listed while LspDetach runs, so skip it by id.
    for _, other in ipairs(vim.lsp.get_clients({ bufnr = ev.buf, method = "textDocument/documentHighlight" })) do
      if other.id ~= ev.data.client_id then
        return
      end
    end
    vim.lsp.util.buf_clear_references(ev.buf)
    pcall(vim.api.nvim_clear_autocmds, { group = "lsp-document-highlight", buffer = ev.buf })
  end,
})
