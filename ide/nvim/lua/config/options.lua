-- Set before any <leader> mapping is defined.
vim.g.mapleader = " "

-- nvim-tree replaces netrw; disable it before plugins load.
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

vim.o.clipboard = "unnamed"
vim.o.wrap = false
vim.o.splitright = true
vim.o.splitbelow = true

vim.o.number = true
vim.o.cursorline = true
vim.o.scrolloff = 5
vim.o.signcolumn = "yes"

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

vim.o.foldlevel = 99

vim.o.ignorecase = true
vim.o.smartcase = true

vim.o.tabstop = 2
vim.o.shiftwidth = 2
vim.o.expandtab = true

-- Ask to save instead of failing with E37, e.g. after grn edits other files.
vim.o.confirm = true

-- Drives the CursorHold symbol highlighting.
vim.o.updatetime = 250

-- Float backgrounds are barely darker than the editor's, so they blend in without a border.
vim.o.winborder = "rounded"

vim.o.tabclose = "uselast"
