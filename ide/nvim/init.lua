-- Plugin names and Vim API identifiers make spell checking too noisy here.
-- cspell:disable

-- Set before any <leader> mapping is defined.
vim.g.mapleader = " "

-- nvim-tree replaces netrw; disable it before plugins load.
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Options (only those that differ from Neovim defaults)
vim.o.clipboard = "unnamed"
vim.o.wrap = false
vim.o.splitright = true
vim.o.splitbelow = true

vim.o.number = true
vim.o.cursorline = true
vim.o.scrolloff = 5
-- Reserve the sign column so gitsigns / diagnostics don't shift the text.
vim.o.signcolumn = "yes"

-- Keep undo history across sessions.
vim.o.undofile = true

-- No swap files: fzf-lua opens buffers via the API, where a stale swap only
-- prints E325 with no recover/delete prompt.
vim.o.swapfile = false

-- One ShaDa file per project, so jumps, recent files and marks stay within the
-- Git repo (or working directory) Neovim starts in. -i still picks its own file.
if vim.o.shadafile == "" then
  local cwd = vim.fn.getcwd()
  local root = vim.fs.root(cwd, ".git") or cwd
  vim.o.shadafile = vim.fn.stdpath("state") .. "/shada/" .. (root:gsub("/", "%%")) .. ".shada"
end

-- Open files fully unfolded; treesitter folds only close on demand.
vim.o.foldlevel = 99

vim.o.ignorecase = true
vim.o.smartcase = true

vim.o.tabstop = 2
vim.o.shiftwidth = 2
vim.o.expandtab = true

-- Ask to save instead of failing with E37, e.g. after grn edits other files.
vim.o.confirm = true

-- Idle time before CursorHold fires (default 4000ms); drives symbol highlighting.
vim.o.updatetime = 250

-- Outline floats (hover, diagnostics, completion, git hunk preview); their background is
-- barely darker than the editor's, so without a border they blend into the code.
vim.o.winborder = "rounded"

vim.keymap.set("i", "jk", "<Esc>", { desc = "Exit insert mode" })
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search highlights" })

-- A suspended nvim keeps its swap files, so opening the same file again hits E325.
vim.keymap.set({ "n", "x" }, "<C-z>", "<Nop>", { desc = "Disable suspend" })

-- Exiting merges jumps back from the project's ShaDa file, so overwrite it right away.
vim.keymap.set("n", "<leader>j", "<cmd>clearjumps | wshada!<cr>", { desc = "Clear jumplist" })

-- Copy the current file path or name to the system clipboard.
vim.keymap.set("n", "<leader>fp", function()
  vim.fn.setreg("+", vim.fn.expand("%:."))
end, { desc = "Copy relative path" })

vim.keymap.set("n", "<leader>fP", function()
  vim.fn.setreg("+", vim.fn.expand("%:p"))
end, { desc = "Copy absolute path" })

vim.keymap.set("n", "<leader>fn", function()
  vim.fn.setreg("+", vim.fn.expand("%:t"))
end, { desc = "Copy file name" })

-- autoread only checks on focus or buffer events, so edits from other tools can go unnoticed.
vim.keymap.set("n", "<leader>fR", "<cmd>checktime<cr>", { desc = "Reload files changed on disk" })

-- Plugins
-- Treesitter parsers must match the plugin version, so refresh them after each update.
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

-- vim-abolish's own cr reads the next key itself, which hides it from which-key; the
-- which-key spec maps each coercion instead. Set before vim.pack.add() loads the plugin.
vim.g.abolish_no_mappings = 1

vim.pack.add({
  { src = "https://github.com/nvim-treesitter/nvim-treesitter", version = "main" },
  "https://github.com/Wansmer/treesj",
  { src = "https://github.com/catppuccin/nvim", name = "catppuccin" },
  "https://github.com/ibhagwan/fzf-lua",
  "https://github.com/folke/trouble.nvim",
  "https://github.com/nvim-tree/nvim-tree.lua",
  "https://github.com/antosha417/nvim-lsp-file-operations",
  "https://github.com/nvim-mini/mini.icons",
  "https://github.com/nvim-mini/mini.bufremove",
  "https://github.com/nvim-mini/mini.surround",
  "https://github.com/tpope/vim-abolish",
  "https://github.com/nvim-lualine/lualine.nvim",
  "https://github.com/lewis6991/gitsigns.nvim",
  "https://github.com/sindrets/diffview.nvim",
  "https://github.com/MagicDuck/grug-far.nvim",
  "https://github.com/vim-test/vim-test",
  "https://github.com/akinsho/toggleterm.nvim",
  "https://github.com/neovim/nvim-lspconfig",
  "https://github.com/mfussenegger/nvim-lint",
  "https://github.com/stevearc/conform.nvim",
  "https://github.com/mason-org/mason.nvim",
  "https://github.com/mason-org/mason-lspconfig.nvim",
  "https://github.com/rafamadriz/friendly-snippets",
  -- Release tags ship a prebuilt fuzzy matcher binary.
  { src = "https://github.com/saghen/blink.cmp", version = vim.version.range("1.*") },
  "https://github.com/windwp/nvim-autopairs",
  "https://github.com/windwp/nvim-ts-autotag",
  "https://github.com/folke/which-key.nvim",
  "https://github.com/folke/flash.nvim",
  { src = "https://github.com/smart-splits-nvim/smart-splits.nvim", version = vim.version.range("3.*") },
})

-- Colorscheme
-- Plugin integrations (blink.cmp, nvim-tree, fzf-lua, gitsigns…) are detected from vim.pack automatically.
require("catppuccin").setup({
  flavour = "mocha",
})
vim.cmd.colorscheme("catppuccin")

-- Icons: mocking nvim-web-devicons lets nvim-tree, lualine and fzf-lua pick up mini.icons.
local mini_icons = require("mini.icons")
mini_icons.setup()
mini_icons.mock_nvim_web_devicons()

-- Delete a buffer but keep its windows, so ]b / [b skip it without closing the split beside nvim-tree.
require("mini.bufremove").setup()
vim.keymap.set("n", "<leader>d", function()
  require("mini.bufremove").delete()
end, { desc = "Delete buffer" })
vim.keymap.set("n", "<leader>D", function()
  local current = vim.api.nvim_get_current_buf()
  for _, buf in ipairs(vim.fn.getbufinfo({ buflisted = 1 })) do
    if buf.bufnr ~= current then
      require("mini.bufremove").delete(buf.bufnr)
    end
  end
end, { desc = "Delete other buffers" })

-- Statusline
require("lualine").setup({
  options = { theme = "catppuccin-nvim" },
  sections = {
    lualine_a = {
      {
        "mode",
        -- First letter of each word: NORMAL -> N, V-LINE -> VL, V-BLOCK -> VB.
        fmt = function(mode)
          return (mode:gsub("(%a)%a*%-?", "%1"))
        end,
      },
    },
    lualine_c = {},
    lualine_x = { { "filename", path = 1 } },
  },
  -- Always show listed buffers on top; tab numbers only appear while extra tabs (e.g. diffview) are open.
  tabline = {
    lualine_a = { { "buffers", symbols = { alternate_file = "" } } },
    lualine_z = {
      {
        "tabs",
        cond = function()
          return #vim.api.nvim_list_tabpages() > 1
        end,
      },
    },
  },
})

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
  "python",
}

-- Async and a no-op for parsers that are already installed.
require("nvim-treesitter").install(parsers)

vim.api.nvim_create_autocmd("FileType", {
  callback = function(ev)
    local lang = vim.treesitter.language.get_lang(ev.match)
    -- language.add() fails while a parser is still installing on first launch.
    if lang and vim.tbl_contains(parsers, lang) and vim.treesitter.language.add(lang) then
      vim.treesitter.start(ev.buf, lang)
      vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
      vim.wo[0][0].foldmethod = "expr"
      vim.wo[0][0].foldexpr = "v:lua.vim.treesitter.foldexpr()"
    end
  end,
})

-- Split / join syntax nodes, including arrow-function bodies.
require("treesj").setup({
  use_default_keymaps = false,
  max_join_length = 1000,
})
vim.keymap.set("n", "<leader>cs", require("treesj").split, { desc = "Split code block" })
vim.keymap.set("n", "<leader>cj", require("treesj").join, { desc = "Join code block" })

-- Auto-close brackets and quotes as they are typed, like VS Code.
require("nvim-autopairs").setup()

-- Auto-close and rename paired HTML / JSX / Vue tags via treesitter.
require("nvim-ts-autotag").setup()

-- Use explicit Flash jumps while keeping native f / t character motions.
require("flash").setup({
  modes = { char = { enabled = false } },
})
vim.keymap.set({ "n", "x", "o" }, "s", function()
  require("flash").jump()
end, { desc = "Flash jump" })
vim.keymap.set({ "n", "x", "o" }, "S", function()
  require("flash").treesitter()
end, { desc = "Flash treesitter selection" })

-- Add / delete / replace surrounding pairs; gs prefix because Flash owns s.
require("mini.surround").setup({
  mappings = {
    add = "gsa",
    delete = "gsd",
    replace = "gsr",
    find = "gsf",
    find_left = "gsF",
    highlight = "gsh",
  },
})

-- Popup listing the next available keys after a pause, e.g. after <leader>.
-- Keymap descriptions come from each mapping's desc.
require("which-key").setup({
  -- Wait longer than the 200ms default before showing the popup; the marks /
  -- registers plugins still open immediately.
  delay = function(ctx)
    return ctx.plugin and 0 or 500
  end,
  -- which-key sizes its popup from this option and ignores winborder, so keep it explicit.
  win = { border = "none" },
  spec = {
    { "<leader>f", group = "Find / file" },
    -- Git and Search also have visual-mode mappings (reset lines, replace selection).
    { "<leader>g", group = "Git", mode = { "n", "x" } },
    { "<leader>c", group = "Code" },
    { "<leader>s", group = "Search", mode = { "n", "x" } },
    { "<leader>t", group = "Test" },
    { "<leader>x", group = "Diagnostics" },
    -- Built-in LSP keymaps (grn, gra, grr, gri, grt…); gra also works in visual mode.
    { "gr", group = "LSP", mode = { "n", "x" } },
    { "gs", group = "Surround", mode = { "n", "x" } },
    { "gsa", desc = "Add: motion + pair (iw\" / iW\")" },
    { "gsa", desc = "Add: pair around selection (e.g. \")", mode = "x" },
    { "gsd", desc = "Delete: pair around cursor (e.g. ' / \")" },
    { "gsr", desc = "Replace: old + new pair (e.g. '\")" },
    { "gsf", desc = "Find: pair's right edge" },
    { "gsF", desc = "Find: pair's left edge" },
    { "gsh", desc = "Highlight: pair around cursor" },
    -- One mapping per vim-abolish coercion, so cr gets a popup.
    { "cr", group = "Coerce case" },
    { "crc", "<Plug>(abolish-coerce-word)c", desc = "camelCase", remap = true },
    { "crp", "<Plug>(abolish-coerce-word)p", desc = "PascalCase", remap = true },
    { "crs", "<Plug>(abolish-coerce-word)s", desc = "snake_case", remap = true },
    { "cru", "<Plug>(abolish-coerce-word)u", desc = "UPPER_CASE", remap = true },
    { "cr-", "<Plug>(abolish-coerce-word)-", desc = "dash-case", remap = true },
    { "cr.", "<Plug>(abolish-coerce-word).", desc = "dot.case", remap = true },
    { "cr<Space>", "<Plug>(abolish-coerce-word)<Space>", desc = "space case", remap = true },
    -- The nav preset lists ]( ]{ ]< [< which aren't Vim motions; the real
    -- unmatched-bracket motions are [( [{ ]) ]}.
    { "](", hidden = true },
    { "]{", hidden = true },
    { "]<", hidden = true },
    { "[<", hidden = true },
    { "[(", desc = "Previous unmatched (" },
    { "[{", desc = "Previous unmatched {" },
    { "])", desc = "Next unmatched )" },
    { "]}", desc = "Next unmatched }" },
  },
})

-- Hold Alt + hjkl / arrows to move the split border in that direction, like
-- smart-splits' README; at the outer edge it resizes the surrounding herdr pane instead.
local smart_splits = require("smart-splits")
vim.keymap.set("n", "<A-h>", smart_splits.resize_left, { desc = "Resize left" })
vim.keymap.set("n", "<A-j>", smart_splits.resize_down, { desc = "Resize down" })
vim.keymap.set("n", "<A-k>", smart_splits.resize_up, { desc = "Resize up" })
vim.keymap.set("n", "<A-l>", smart_splits.resize_right, { desc = "Resize right" })
vim.keymap.set("n", "<A-Left>", smart_splits.resize_left, { desc = "Resize left" })
vim.keymap.set("n", "<A-Down>", smart_splits.resize_down, { desc = "Resize down" })
vim.keymap.set("n", "<A-Up>", smart_splits.resize_up, { desc = "Resize up" })
vim.keymap.set("n", "<A-Right>", smart_splits.resize_right, { desc = "Resize right" })
-- Ghostty sends Alt-Left / Alt-Right as Esc b / Esc f for shell word jumps, which Neovim
-- reads as Alt-b / Alt-f; without these Esc then b moves the cursor back a word.
vim.keymap.set("n", "<A-b>", smart_splits.resize_left, { desc = "Resize left" })
vim.keymap.set("n", "<A-f>", smart_splits.resize_right, { desc = "Resize right" })

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
vim.keymap.set("n", "<leader>fr", "<cmd>FzfLua oldfiles<cr>", { desc = "Recent files" })
-- Like VS Code's breadcrumb dropdown: pick a sibling of the current file.
vim.keymap.set("n", "<leader>fd", function()
  require("fzf-lua").files({
    cwd = vim.fn.expand("%:p:h"),
    fd_opts = "--color=never --type f --type l --max-depth 1",
  })
end, { desc = "Find files in current directory" })
vim.keymap.set("n", "<leader>xx", "<cmd>FzfLua diagnostics_workspace<cr>", { desc = "Workspace diagnostics" })
vim.keymap.set("n", "<leader>xd", "<cmd>FzfLua diagnostics_document<cr>", { desc = "Document diagnostics" })
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

vim.keymap.set("n", "<leader>fO", function()
  local path = vim.api.nvim_buf_get_name(0)
  if vim.bo.buftype ~= "" or path == "" then
    vim.notify("Open a file before opening its folder in Finder", vim.log.levels.WARN)
    return
  end
  local _, err = vim.ui.open(vim.fn.fnamemodify(path, ":h"))
  if err then
    vim.notify(err, vim.log.levels.ERROR)
  end
end, { desc = "Open current folder in Finder" })

-- Results grouped by file in a foldable tree, like VS Code's references panel.
require("trouble").setup({
  focus = true,
  keys = {
    -- Like VS Code: jump and close on an item, toggle the fold on a file node.
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

-- File explorer
require("nvim-tree").setup({
  -- Show gitignored files by default; `I` still toggles them.
  filters = { git_ignored = false },
  -- `D` moves to the macOS Trash; the default `gio trash` isn't installed.
  trash = { cmd = "trash" },
  renderer = {
    icons = {
      -- Same glyphs mini.icons uses for directories.
      glyphs = {
        folder = {
          default = "󰉋",
          open = "󰝰",
          empty = "󰉖",
          empty_open = "󰷏",
        },
      },
    },
  },
})
vim.keymap.set("n", "<leader>e", "<cmd>NvimTreeFindFileToggle<cr>", { desc = "Toggle file explorer" })

-- Bridge nvim-tree renames and cut/paste moves to LSP import updates.
-- Auto-save files touched by LSP workspace edits, including symbol renames.
local file_operations = require("lsp-file-operations")
file_operations.setup({
  auto_save = true,
  operations = {
    willRenameFiles = true,
    didRenameFiles = true,
    willCreateFiles = false,
    didCreateFiles = false,
    willDeleteFiles = false,
    didDeleteFiles = false,
  },
})
vim.lsp.config("*", { capabilities = file_operations.default_capabilities() })

-- Single-file create / move from the command line; batches and folders stay in nvim-tree.
-- Create missing parent folders on save, so `:e new/dir/file.ts` just works.
vim.api.nvim_create_autocmd("BufWritePre", {
  callback = function(ev)
    if vim.bo[ev.buf].buftype == "" and not ev.match:match("^%w+://") then
      vim.fn.mkdir(vim.fs.dirname(ev.match), "p")
    end
  end,
})

-- Prefill `:e` with the current file's folder, or the working directory when there is none.
local function current_dir()
  local name = vim.api.nvim_buf_get_name(0)
  if vim.bo.buftype ~= "" or name == "" then
    return ""
  end
  local dir = vim.fn.fnamemodify(name, ":.:h")
  return dir == "." and "" or vim.fn.fnameescape(dir) .. "/"
end

vim.keymap.set("n", "<leader>fa", function()
  return ":e " .. current_dir()
end, { expr = true, desc = "Add file in current folder" })

vim.keymap.set("n", "<leader>fA", ":e ", { desc = "Add file in project root" })

-- Move or rename the current file; LSP servers update imports before the move.
vim.api.nvim_create_user_command("Mv", function(opts)
  local old = vim.api.nvim_buf_get_name(0)
  local new = vim.fn.fnamemodify(opts.args, ":p")
  if vim.bo.buftype ~= "" or not vim.uv.fs_stat(old) then
    vim.notify("Mv: current buffer is not a file on disk", vim.log.levels.ERROR)
    return
  end
  -- Check before willRename, so imports aren't rewritten for a move that won't happen.
  if vim.uv.fs_stat(new) then
    vim.notify("Mv: " .. opts.args .. " already exists", vim.log.levels.ERROR)
    return
  end
  local data = { old_name = old, new_name = new }
  file_operations.will_rename(data)
  vim.lsp.util.rename(old, new)
  file_operations.did_rename(data)
end, { nargs = 1, complete = "file", desc = "Move or rename the current file" })

vim.keymap.set("n", "<leader>fm", function()
  return ":Mv " .. vim.fn.expand("%:.")
end, { expr = true, desc = "Move / rename current file" })

-- Move the current file to the macOS Trash (`:Rm!` deletes it permanently) and close
-- its buffer, keeping the window.
vim.api.nvim_create_user_command("Rm", function(opts)
  local name = vim.api.nvim_buf_get_name(0)
  if vim.bo.buftype ~= "" or not vim.uv.fs_stat(name) then
    vim.notify("Rm: current buffer is not a file on disk", vim.log.levels.ERROR)
    return
  end
  local rel = vim.fn.fnamemodify(name, ":.")
  local prompt = opts.bang and ("Permanently delete " .. rel .. "?") or ("Move " .. rel .. " to Trash?")
  if vim.bo.modified then
    prompt = prompt .. " Unsaved changes will be lost."
  end
  if vim.fn.confirm(prompt, "&Yes\n&No", 2) ~= 1 then
    return
  end
  local result = vim.system(opts.bang and { "rm", name } or { "trash", name }):wait()
  if result.code ~= 0 then
    vim.notify("Rm: " .. vim.trim(result.stderr or ""), vim.log.levels.ERROR)
    return
  end
  require("mini.bufremove").delete(0, true)
end, { bang = true, desc = "Move the current file to Trash, or delete it with !" })

vim.keymap.set("n", "<leader>fx", "<cmd>Rm<cr>", { desc = "Delete current file (Trash)" })
vim.keymap.set("n", "<leader>fX", "<cmd>Rm!<cr>", { desc = "Delete current file permanently" })

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
local diffview_actions = require("diffview.actions")
-- Open the file under the cursor in the previous tab, then close the diff view it came from.
local function diffview_goto_file_and_close()
  local diffview_lib = require("diffview.lib")
  local view = diffview_lib.get_current_view()
  diffview_actions.goto_file_edit()
  if view and not view:is_cur_tabpage() then
    view:close()
    diffview_lib.dispose_view(view)
  end
end
-- Shared by every view; diffview copies keymaps on setup, so one table is enough.
local diffview_keymaps = {
  { "n", "<leader>e", diffview_actions.toggle_files, { desc = "Toggle file panel" } },
  { "n", "<leader>go", diffview_goto_file_and_close, { desc = "Open file and close diff view" } },
  ["<leader>b"] = false,
}
require("diffview").setup({
  -- Show removed lines in red on the old side instead of DiffAdd green.
  enhanced_diff_hl = true,
  -- Match the file explorer toggle in both diff and history views.
  keymaps = {
    view = diffview_keymaps,
    file_panel = diffview_keymaps,
    file_history_panel = diffview_keymaps,
  },
})
-- Run Lazygit inside Neovim so nvim-remote can open files in this instance.
local lazygit_session = nil
-- Called by Lazygit's edit commands before `nvim --remote`, so files open in the tab Lazygit came from.
function _G.LazygitReturnToEditor()
  if not lazygit_session then
    return
  end
  if vim.api.nvim_tabpage_is_valid(lazygit_session.origin_tab) then
    vim.api.nvim_set_current_tabpage(lazygit_session.origin_tab)
  end
  -- Lazygit reads this after its edit command returns, quits, and on_exit closes its tab.
  vim.fn.chansend(lazygit_session.job, "q")
end
vim.keymap.set("n", "<leader>gg", function()
  if vim.fn.executable("lazygit") ~= 1 then
    vim.notify("Install lazygit from the Brewfile first", vim.log.levels.WARN)
    return
  end
  local root = vim.fs.root(0, ".git") or vim.fs.root(vim.fn.getcwd(), ".git")
  if not root then
    vim.notify("Open a file or directory in a Git repository first", vim.log.levels.WARN)
    return
  end
  local origin_tab = vim.api.nvim_get_current_tabpage()
  vim.cmd.tabnew()
  local bufnr = vim.api.nvim_get_current_buf()
  vim.bo[bufnr].bufhidden = "wipe"
  local job = vim.fn.jobstart({ "lazygit" }, {
    term = true,
    cwd = root,
    on_exit = function(job_id, code)
      vim.schedule(function()
        if lazygit_session and lazygit_session.job == job_id then
          lazygit_session = nil
        end
        if code ~= 0 then
          vim.notify("Lazygit exited with code " .. code .. "; see the terminal output", vim.log.levels.WARN)
          return
        end
        for _, winid in ipairs(vim.fn.win_findbuf(bufnr)) do
          pcall(vim.api.nvim_win_close, winid, true)
        end
        if vim.api.nvim_buf_is_valid(bufnr) then
          vim.api.nvim_buf_delete(bufnr, { force = true })
        end
      end)
    end,
  })
  lazygit_session = { job = job, origin_tab = origin_tab }
  vim.cmd.startinsert()
end, { desc = "Open Lazygit" })
vim.keymap.set("n", "<leader>gd", "<cmd>DiffviewOpen<cr>", { desc = "Open git diff view" })
vim.keymap.set("n", "<leader>gh", "<cmd>DiffviewFileHistory %<cr>", { desc = "Current file git history" })
vim.keymap.set("n", "<leader>gH", "<cmd>DiffviewFileHistory<cr>", { desc = "Repository git history" })
vim.keymap.set("n", "<leader>gq", "<cmd>DiffviewClose<cr>", { desc = "Close git diff view" })

-- Project-wide search and replace with a live preview of every change.
require("grug-far").setup({
  -- Keep arrow keys as plain movement instead of opening each result on the left.
  keymaps = { openNextLocation = false, openPrevLocation = false },
})
vim.keymap.set("n", "<leader>sr", function()
  require("grug-far").open({ prefills = { search = vim.fn.expand("<cword>") } })
end, { desc = "Search and replace in project" })
-- grug-far splits paths on spaces, so escape them the same way it does.
local function current_file_path()
  return (vim.fn.expand("%"):gsub(" ", "\\ "))
end
vim.keymap.set("n", "<leader>sf", function()
  require("grug-far").open({ prefills = { search = vim.fn.expand("<cword>"), paths = current_file_path() } })
end, { desc = "Search and replace in current file" })
vim.keymap.set("v", "<leader>sr", function()
  require("grug-far").with_visual_selection()
end, { desc = "Search and replace selection in project" })
vim.keymap.set("v", "<leader>sf", function()
  require("grug-far").with_visual_selection({ prefills = { paths = current_file_path() } })
end, { desc = "Search and replace selection in current file" })

-- Run tests via the project's runner (Vitest, Jest, Playwright…), picked from
-- the file name and package.json. Output goes to toggleterm's terminal 9, so
-- 9<C-\> toggles it and it behaves like the other toggleterm terminals.
-- vim-test's built-in toggleterm strategy sends to the last toggled terminal,
-- which could be a running dev server, so pin the test runs to their own one.
vim.g["test#custom_strategies"] = {
  toggleterm_test = function(cmd)
    require("toggleterm").exec(cmd, 9, nil, nil, nil, "test")
  end,
}
vim.g["test#strategy"] = "toggleterm_test"
-- Playwright claims every *.test / *.spec file once @playwright/test is in
-- package.json, so limit it to e2e/ or playwright/ folders and leave the rest to Vitest / Jest.
vim.g["test#javascript#playwright#file_pattern"] = [[\v(^|/)(e2e|playwright)/.*(spec|test)\.(js|jsx|ts|tsx)$]]
vim.keymap.set("n", "<leader>tt", "<cmd>TestNearest<cr>", { desc = "Run nearest test" })
vim.keymap.set("n", "<leader>tf", "<cmd>TestFile<cr>", { desc = "Run tests in file" })
vim.keymap.set("n", "<leader>tl", "<cmd>TestLast<cr>", { desc = "Rerun last test" })

-- Long-running terminals (dev server, tsc --watch) in a bottom split: <C-\> toggles
-- them, 1<C-\> / 2<C-\> open numbered ones side by side. Closing the window only
-- hides a terminal; its job keeps running until the shell exits.
require("toggleterm").setup({
  open_mapping = [[<C-\>]],
  size = 15,
  -- Same as insert mode's jk; buffer-local so the Lazygit terminal keeps its own j.
  on_create = function(term)
    vim.keymap.set("t", "jk", [[<C-\><C-n>]], { buffer = term.bufnr, desc = "Exit terminal mode" })
  end,
})

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

-- CSpell is an external CLI; nvim-lint publishes its results as diagnostics.
local lint = require("lint")
for _, filetype in ipairs({
  "javascript", "javascriptreact", "typescript", "typescriptreact",
  "html", "css", "scss", "vue", "json", "jsonc", "yaml",
  "markdown", "mdx", "text", "gitcommit", "lua", "python", "sh", "zsh",
}) do
  lint.linters_by_ft[filetype] = { "cspell" }
end

local function check_spelling(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  if not vim.api.nvim_buf_is_loaded(bufnr) or vim.bo[bufnr].buftype ~= "" then
    return
  end
  local filename = vim.api.nvim_buf_get_name(bufnr)
  if filename == "" then
    return
  end
  vim.api.nvim_buf_call(bufnr, function()
    -- Search for project configuration from the file, even when cwd is elsewhere.
    lint.try_lint(nil, { cwd = vim.fs.dirname(filename) })
  end)
end

vim.api.nvim_create_autocmd({ "BufReadPost", "BufWritePost", "InsertLeave" }, {
  group = vim.api.nvim_create_augroup("cspell-check", { clear = true }),
  callback = function(ev)
    -- FileType detection and other buffer callbacks must finish first.
    vim.schedule(function()
      check_spelling(ev.buf)
    end)
  end,
})
vim.keymap.set("n", "<leader>xs", function()
  check_spelling()
end, { desc = "Check spelling" })

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
  ensure_installed = { "tailwindcss", "lua_ls", "jsonls", "cssls", "html", "pyright", "ruff", "bashls", "yamlls" },
})

-- TypeScript 7 native LSP: uses the project's tsc when it is 7+, otherwise the
-- global one from Homebrew.
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

-- Biome from the project's node_modules; attaches only when a
-- biome.json is found above the file.
vim.lsp.enable("biome")

-- Oxlint ships its own LSP (`oxlint --lsp`) and prefers the project's node_modules.
-- Its root_dir reports nil when no config is found; workspace_required keeps the server
-- from starting anyway. Oxfmt needs no LSP: conform formats on save.
vim.lsp.config("oxlint", { workspace_required = true })
vim.lsp.enable("oxlint")

-- Global rather than in LspAttach, so they still work when no server attached.
vim.keymap.set("n", "<leader>cl", function()
  local names = vim.tbl_map(function(client)
    return client.name
  end, vim.lsp.get_clients({ bufnr = 0 }))
  vim.notify(#names > 0 and table.concat(names, ", ") or "No LSP attached", vim.log.levels.INFO)
end, { desc = "Show attached LSP clients" })
vim.keymap.set("n", "<leader>cL", "<cmd>checkhealth vim.lsp<cr>", { desc = "LSP health report" })

-- Format on save with each tool's CLI: safe lint fixes, then formatting, like VS Code's
-- codeActionsOnSave + formatOnSave. LSP formatting stays off so tsc / jsonls never touch the file.
-- Filetypes follow the matching LSP configs; entries are added in run order.
local formatters_by_ft = {}
for _, tool in ipairs({ { "biome-check", "biome" }, { "oxlint", "oxlint" }, { "oxfmt", "oxfmt" } }) do
  local formatter, server = tool[1], tool[2]
  for _, ft in ipairs(vim.lsp.config[server].filetypes) do
    formatters_by_ft[ft] = formatters_by_ft[ft] or {}
    table.insert(formatters_by_ft[ft], formatter)
  end
end

local biome_configs = { "biome.json", "biome.jsonc", ".biome.json", ".biome.jsonc" }

require("conform").setup({
  formatters_by_ft = formatters_by_ft,
  formatters = {
    -- Biome and oxlint run only where the project has their config file.
    ["biome-check"] = { require_cwd = true },
    oxlint = {
      cwd = require("conform.util").root_file({ ".oxlintrc.json", ".oxlintrc.jsonc", "oxlint.config.ts" }),
      require_cwd = true,
    },
    -- Oxfmt is the fallback formatter for every project that doesn't use Biome. It picks the
    -- nearest .oxfmtrc.json, so a project without one gets ~/.oxfmtrc.json (linked from this repo).
    oxfmt = {
      condition = function(_, ctx)
        return not vim.fs.root(ctx.dirname, biome_configs)
      end,
    },
  },
  format_on_save = { timeout_ms = 1000 },
  -- Most projects use only one of these tools, so silently skip the rest.
  notify_no_formatters = false,
})

-- Completion (LSP items plus friendly-snippets, e.g. ES7 React's rafce)
require("blink.cmp").setup({
  -- Tab or Enter accepts, like VS Code.
  keymap = {
    preset = "super-tab",
    ["<CR>"] = { "accept", "fallback" },
  },
  completion = {
    documentation = { auto_show = true },
    -- Don't append "()" on accept; functions are often passed, not called.
    accept = { auto_brackets = { enabled = false } },
  },
  -- Parameter hints while typing a call, like VS Code; <C-k> toggles them.
  signature = { enabled = true },
  sources = { default = { "lsp", "snippets" } },
})

-- Apply a whole-file source action, e.g. remove every unused import at once.
local function source_action(kind)
  return function()
    vim.lsp.buf.code_action({ apply = true, context = { only = { kind }, diagnostics = {} } })
  end
end

-- Open a Trouble LSP view; on no results, show a one-line warning instead of
-- Trouble's two-line one, which triggers a hit-enter prompt.
local function trouble_lsp(mode, empty_msg)
  local view = require("trouble").open(mode)
  if view then
    view.first_update:next(function()
      if view:count() == 0 then
        vim.notify(empty_msg, vim.log.levels.WARN)
      end
    end)
  end
  return view
end

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(ev)
    -- Trouble jumps straight to a single definition and lists multiple ones like grr.
    vim.keymap.set("n", "gd", function()
      trouble_lsp("lsp_definitions", "No definition found")
    end, { buffer = ev.buf, desc = "Go to definition" })
    vim.keymap.set("n", "grr", function()
      local trouble = require("trouble")
      if trouble.is_open("lsp_references") then
        return trouble.close("lsp_references")
      end
      local view = trouble_lsp("lsp_references", "No references found")
      if view then
        -- Trouble forces foldlevel=99 on its window; level 1 keeps the "References" header open but folds each file.
        view:wait(function()
          view:fold_level({ level = 1 })
        end)
      end
    end, { buffer = ev.buf, desc = "References" })
    -- fzf-lua pickers with preview instead of the built-in quickfix / location lists.
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

    -- Inlay hints stay off by default; toggle them on demand.
    vim.keymap.set("n", "<leader>ci", function()
      vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = ev.buf }), { bufnr = ev.buf })
    end, { buffer = ev.buf, desc = "Toggle inlay hints" })

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
