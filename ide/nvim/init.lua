-- Set before any <leader> mapping is defined.
vim.g.mapleader = " "

-- nvim-tree replaces netrw; disable it before plugins load.
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Options (only those that differ from Neovim defaults)
vim.o.clipboard = "unnamed"
vim.o.wrap = false

vim.o.number = true
vim.o.cursorline = true
vim.o.scrolloff = 5

vim.o.ignorecase = true
vim.o.smartcase = true

vim.o.tabstop = 2
vim.o.shiftwidth = 2
vim.o.expandtab = true

-- Ask to save instead of failing with E37, e.g. after grn edits other files.
vim.o.confirm = true

-- Idle time before CursorHold fires (default 4000ms); drives symbol highlighting.
vim.o.updatetime = 250

-- Move between windows (tree, editor, quickfix) without the <C-w> prefix.
vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Focus left window" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Focus lower window" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Focus upper window" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Focus right window" })

vim.keymap.set("n", "<leader>w", "<cmd>write<cr>", { desc = "Save current file" })
-- Rename (grn) edits other buffers without saving them.
vim.keymap.set("n", "<leader>W", "<cmd>wall<cr>", { desc = "Save all files" })

-- Copy the current file path or name to the system clipboard.
vim.keymap.set("n", "<leader>yp", function()
  vim.fn.setreg("+", vim.fn.expand("%:."))
end, { desc = "Copy relative path" })

vim.keymap.set("n", "<leader>yP", function()
  vim.fn.setreg("+", vim.fn.expand("%:p"))
end, { desc = "Copy absolute path" })

vim.keymap.set("n", "<leader>yn", function()
  vim.fn.setreg("+", vim.fn.expand("%:t"))
end, { desc = "Copy file name" })

-- Treesitter
local parsers = {
  "javascript",
  "typescript",
  "tsx",
  "vue",
  "html",
  "css",
  "scss",
  "json",
  "yaml",
  "markdown",
  "lua",
  "bash",
}

-- Parsers must match the plugin version, so refresh them after each update.
-- Registered before vim.pack.add() so it also fires on lockfile installs.
vim.api.nvim_create_autocmd("PackChanged", {
  callback = function(ev)
    if ev.data.spec.name == "nvim-treesitter" and ev.data.kind == "update" then
      if not ev.data.active then
        vim.cmd.packadd("nvim-treesitter")
      end
      vim.cmd("TSUpdate")
    end
  end,
})

vim.pack.add({
  { src = "https://github.com/nvim-treesitter/nvim-treesitter", version = "main" },
  "https://github.com/folke/tokyonight.nvim",
  "https://github.com/ibhagwan/fzf-lua",
  "https://github.com/nvim-tree/nvim-tree.lua",
  "https://github.com/nvim-tree/nvim-web-devicons",
  "https://github.com/nvim-lualine/lualine.nvim",
  "https://github.com/lewis6991/gitsigns.nvim",
  "https://github.com/sindrets/diffview.nvim",
  "https://github.com/neovim/nvim-lspconfig",
  "https://github.com/mason-org/mason.nvim",
  "https://github.com/mason-org/mason-lspconfig.nvim",
  -- Release tags ship a prebuilt fuzzy matcher binary.
  { src = "https://github.com/saghen/blink.cmp", version = vim.version.range("1.*") },
})

-- Colorscheme
vim.cmd.colorscheme("tokyonight-night")

-- Statusline
require("lualine").setup({ options = { theme = "nightfly" } })

-- Async and a no-op for parsers that are already installed.
require("nvim-treesitter").install(parsers)

vim.api.nvim_create_autocmd("FileType", {
  callback = function(ev)
    local lang = vim.treesitter.language.get_lang(ev.match)
    -- language.add() fails while a parser is still installing on first launch.
    if lang and vim.tbl_contains(parsers, lang) and vim.treesitter.language.add(lang) then
      vim.treesitter.start(ev.buf, lang)
    end
  end,
})

-- Fuzzy finder (files via fd, content via ripgrep)
require("fzf-lua").setup({
  winopts = {
    preview = { layout = "vertical", vertical = "down:45%" },
  },
  files = {
    -- Parse file:line queries and jump to the requested line.
    -- Ref: https://github.com/ibhagwan/fzf-lua/blob/main/OPTIONS.md#filesline_query
    line_query = true,
  },
  -- Previewing resolves each action, which vtsls rejects for disabled refactors.
  lsp = { code_actions = { previewer = false } },
})
-- Also render vim.ui.select (e.g. code actions) with fzf-lua.
require("fzf-lua").register_ui_select()
vim.keymap.set("n", "<leader>ff", "<cmd>FzfLua files<cr>", { desc = "Find files" })
vim.keymap.set("n", "<leader>fb", "<cmd>FzfLua buffers<cr>", { desc = "Find open buffers" })
vim.keymap.set("n", "<leader>fg", "<cmd>FzfLua live_grep<cr>", { desc = "Search content" })
-- Like VS Code's breadcrumb dropdown: pick a sibling of the current file.
vim.keymap.set("n", "<leader>fd", function()
  require("fzf-lua").files({
    cwd = vim.fn.expand("%:p:h"),
    fd_opts = "--color=never --type f --type l --max-depth 1",
  })
end, { desc = "Find files in current directory" })

vim.keymap.set("n", "<leader>fo", function()
  local path = vim.api.nvim_buf_get_name(0)
  if vim.bo.buftype ~= "" or path == "" or vim.fn.filereadable(path) ~= 1 then
    vim.notify("Save the file before opening it in the default app", vim.log.levels.WARN)
    return
  end
  local _, err = vim.ui.open(path)
  if err then
    vim.notify(err, vim.log.levels.ERROR)
  end
end, { desc = "Open file in default app" })

-- File explorer
require("nvim-tree").setup()
vim.keymap.set("n", "<leader>e", "<cmd>NvimTreeFindFileToggle<cr>", { desc = "Toggle file explorer" })

-- Git: change markers in the sign column, hunk navigation and line blame.
require("gitsigns").setup({
  on_attach = function(bufnr)
    local gitsigns = require("gitsigns")

    -- Keep the built-in ]c / [c behaviour inside diff mode (e.g. diffview).
    vim.keymap.set("n", "]c", function()
      if vim.wo.diff then
        vim.cmd.normal({ "]c", bang = true })
      else
        gitsigns.nav_hunk("next")
      end
    end, { buffer = bufnr, desc = "Next git hunk" })
    vim.keymap.set("n", "[c", function()
      if vim.wo.diff then
        vim.cmd.normal({ "[c", bang = true })
      else
        gitsigns.nav_hunk("prev")
      end
    end, { buffer = bufnr, desc = "Previous git hunk" })

    vim.keymap.set("n", "<leader>gp", gitsigns.preview_hunk, { buffer = bufnr, desc = "Preview git hunk" })
    vim.keymap.set("n", "<leader>gr", gitsigns.reset_hunk, { buffer = bufnr, desc = "Reset git hunk" })
    vim.keymap.set("v", "<leader>gr", function()
      gitsigns.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
    end, { buffer = bufnr, desc = "Reset selected lines" })
    vim.keymap.set("n", "<leader>gR", gitsigns.reset_buffer, { buffer = bufnr, desc = "Reset git buffer" })
    vim.keymap.set("n", "<leader>gb", function()
      gitsigns.blame_line({ full = true })
    end, { buffer = bufnr, desc = "Blame line" })
  end,
})

-- Side-by-side diff of the working tree, and per-file commit history.
vim.keymap.set("n", "<leader>gd", "<cmd>DiffviewOpen<cr>", { desc = "Open git diff view" })
vim.keymap.set("n", "<leader>gh", "<cmd>DiffviewFileHistory %<cr>", { desc = "Current file git history" })
vim.keymap.set("n", "<leader>gq", "<cmd>DiffviewClose<cr>", { desc = "Close git diff view" })

-- LSP
-- Built-in keymaps: K hover, grr references, grn rename, gra code action,
-- gri implementation, grt type definition, <C-w>d diagnostic at cursor.
vim.diagnostic.config({
  -- Show the full message when jumping with ]d / [d.
  jump = {
    on_jump = function(diagnostic, bufnr)
      if diagnostic then
        vim.diagnostic.open_float({ bufnr = bufnr, scope = "cursor", focus = false })
      end
    end,
  },
})

-- Make lua_ls aware of the Neovim runtime when editing this config.
vim.lsp.config("lua_ls", {
  settings = {
    Lua = {
      runtime = { version = "LuaJIT" },
      workspace = { library = { vim.env.VIMRUNTIME }, checkThirdParty = false },
    },
  },
})

require("mason").setup()
-- Installed servers are enabled automatically.
require("mason-lspconfig").setup({
  ensure_installed = { "tailwindcss", "lua_ls", "jsonls" },
})

-- TypeScript 7 native LSP: uses the project's tsc when it is 7+, otherwise the
-- global one from Homebrew.
vim.lsp.enable("tsc")

-- Biome from Homebrew (or the project's node_modules); attaches only when a
-- biome.json is found above the file.
vim.lsp.enable("biome")

-- Completion (LSP items only)
require("blink.cmp").setup({
  -- Tab or Enter accepts, like VS Code.
  keymap = {
    preset = "super-tab",
    ["<CR>"] = { "accept", "fallback" },
  },
  completion = { documentation = { auto_show = true } },
  sources = { default = { "lsp" } },
})

-- Apply a whole-file source action, e.g. remove every unused import at once.
local function source_action(kind)
  return function()
    vim.lsp.buf.code_action({ apply = true, context = { only = { kind }, diagnostics = {} } })
  end
end

-- Synchronous variant for BufWritePre, where an async code action would land
-- after the file is written.
local function apply_source_action_sync(client, bufnr, kind)
  local params = vim.lsp.util.make_range_params(0, client.offset_encoding)
  params.context = { only = { kind }, diagnostics = {} }
  local res = client:request_sync("textDocument/codeAction", params, 1000, bufnr)
  for _, action in ipairs(res and res.result or {}) do
    if not action.edit and client:supports_method("codeAction/resolve", bufnr) then
      local resolved = client:request_sync("codeAction/resolve", action, 1000, bufnr)
      action = resolved and resolved.result or action
    end
    if action.edit then
      vim.lsp.util.apply_workspace_edit(action.edit, client.offset_encoding)
    end
  end
end

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(ev)
    vim.keymap.set("n", "gd", vim.lsp.buf.definition, { buffer = ev.buf, desc = "Go to definition" })
    -- fzf-lua pickers with preview instead of the built-in quickfix / location lists.
    vim.keymap.set("n", "grr", "<cmd>FzfLua lsp_references<cr>", { buffer = ev.buf, desc = "References" })
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
    vim.keymap.set("n", "<leader>cD", source_action("source.fixAll"), { buffer = ev.buf, desc = "Fix all" })

    local client = vim.lsp.get_client_by_id(ev.data.client_id)

    -- On save, apply Biome's safe fixes then format with Biome only, so tsc /
    -- jsonls never touch the file. Same as VS Code's source.fixAll.biome + format on save.
    if client and client.name == "biome" then
      local group = vim.api.nvim_create_augroup("biome-on-save", { clear = false })
      vim.api.nvim_clear_autocmds({ group = group, buffer = ev.buf })
      vim.api.nvim_create_autocmd("BufWritePre", {
        group = group,
        buffer = ev.buf,
        callback = function()
          apply_source_action_sync(client, ev.buf, "source.fixAll.biome")
          -- Biome registers formatting dynamically, shortly after attaching.
          if client:supports_method("textDocument/formatting", ev.buf) then
            vim.lsp.buf.format({ bufnr = ev.buf, id = client.id })
          end
        end,
      })
    end

    -- Highlight other references of the symbol under the cursor while it rests.
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
  callback = function(ev)
    vim.lsp.buf.clear_references()
    pcall(vim.api.nvim_clear_autocmds, { group = "lsp-document-highlight", buffer = ev.buf })

    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if client and client.name == "biome" then
      pcall(vim.api.nvim_clear_autocmds, { group = "biome-on-save", buffer = ev.buf })
    end
  end,
})
