vim.pack.add({
  "https://github.com/nvim-tree/nvim-tree.lua",
  "https://github.com/antosha417/nvim-lsp-file-operations",
})

require("nvim-tree").setup({
  on_attach = function(bufnr)
    local api = require("nvim-tree.api")
    api.config.mappings.default_on_attach(bufnr)
    local opts = { buffer = bufnr, nowait = true, silent = true }
    vim.keymap.set("n", "[c", api.node.navigate.git.prev_skip_gitignored, vim.tbl_extend("force", opts, { desc = "nvim-tree: Prev Git" }))
    vim.keymap.set("n", "]c", api.node.navigate.git.next_skip_gitignored, vim.tbl_extend("force", opts, { desc = "nvim-tree: Next Git" }))
  end,
  filters = { git_ignored = false },
  update_focused_file = { enable = true },
  view = { width = { min = 30, max = "50%" } },
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
