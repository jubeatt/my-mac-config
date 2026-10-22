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
  -- Previewing resolves each action, which vtsls rejects for disabled refactors.
  lsp = { code_actions = { previewer = false } },
})
-- Also render vim.ui.select (e.g. code actions) with fzf-lua.
require("fzf-lua").register_ui_select()
vim.keymap.set("n", "<leader>ff", "<cmd>FzfLua files<cr>", { desc = "Find files" })
vim.keymap.set("n", "<leader>fg", "<cmd>FzfLua live_grep<cr>", { desc = "Search content" })
-- Like VS Code's breadcrumb dropdown: pick a sibling of the current file.
vim.keymap.set("n", "<leader>fd", function()
  require("fzf-lua").files({
    cwd = vim.fn.expand("%:p:h"),
    fd_opts = "--color=never --type f --type l --max-depth 1",
  })
end, { desc = "Find files in current directory" })

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
  ensure_installed = { "tailwindcss", "lua_ls" },
})

-- TypeScript 7 native LSP: uses the project's tsc when it is 7+, otherwise the
-- global one from Homebrew.
vim.lsp.enable("tsc")

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

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(ev)
    vim.keymap.set("n", "gd", vim.lsp.buf.definition, { buffer = ev.buf, desc = "Go to definition" })
    -- fzf-lua pickers with preview instead of the built-in quickfix / location lists.
    vim.keymap.set("n", "grr", "<cmd>FzfLua lsp_references<cr>", { buffer = ev.buf, desc = "References" })
    vim.keymap.set("n", "gO", "<cmd>FzfLua lsp_document_symbols<cr>", { buffer = ev.buf, desc = "Document symbols" })
    vim.keymap.set(
      "n",
      "<leader>cu",
      source_action("source.removeUnusedImports"),
      { buffer = ev.buf, desc = "Remove unused imports" }
    )
    vim.keymap.set("n", "<leader>cD", source_action("source.fixAll"), { buffer = ev.buf, desc = "Fix all" })

    -- Highlight other references of the symbol under the cursor while it rests.
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
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
  end,
})
