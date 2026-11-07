vim.pack.add({
  "https://github.com/ibhagwan/fzf-lua",
  "https://github.com/MagicDuck/grug-far.nvim",
})

local fzf = require("fzf-lua")
fzf.setup({
  winopts = {
    preview = { layout = "vertical", vertical = "down:45%" },
  },
  files = {
    -- Parse file:line queries and jump to the requested line.
    line_query = true,
  },
  -- Previewing resolves each action, which vtsls rejects for disabled refactors.
  lsp = { code_actions = { previewer = false } },
})
fzf.register_ui_select()
vim.keymap.set("n", "<leader>ff", "<cmd>FzfLua files<cr>", { desc = "Find files" })
vim.keymap.set("n", "<leader>fb", "<cmd>FzfLua buffers<cr>", { desc = "Find open buffers" })
vim.keymap.set("n", "<leader>fg", "<cmd>FzfLua live_grep<cr>", { desc = "Search content" })
vim.keymap.set("n", "<leader>fr", "<cmd>FzfLua oldfiles<cr>", { desc = "Recent files" })
vim.keymap.set("n", "<leader>fd", function()
  fzf.files({
    cwd = vim.fn.expand("%:p:h"),
    fd_opts = "--color=never --type f --type l --max-depth 1",
  })
end, { desc = "Find files in current directory" })
vim.keymap.set("n", "<leader>xx", "<cmd>FzfLua diagnostics_workspace<cr>", { desc = "Workspace diagnostics" })
vim.keymap.set("n", "<leader>xd", "<cmd>FzfLua diagnostics_document<cr>", { desc = "Document diagnostics" })

local grug_far = require("grug-far")
grug_far.setup({
  -- Keep arrow keys as plain movement instead of opening each result on the left.
  keymaps = { openNextLocation = false, openPrevLocation = false },
})
vim.keymap.set("n", "<leader>sr", function()
  grug_far.open({ prefills = { search = vim.fn.expand("<cword>") } })
end, { desc = "Search and replace in project" })
-- grug-far splits paths on spaces, so escape them the same way it does.
local function current_file_path()
  return (vim.fn.expand("%"):gsub(" ", "\\ "))
end
vim.keymap.set("n", "<leader>sf", function()
  grug_far.open({ prefills = { search = vim.fn.expand("<cword>"), paths = current_file_path() } })
end, { desc = "Search and replace in current file" })
vim.keymap.set("x", "<leader>sr", grug_far.with_visual_selection, { desc = "Search and replace selection in project" })
vim.keymap.set("x", "<leader>sf", function()
  grug_far.with_visual_selection({ prefills = { paths = current_file_path() } })
end, { desc = "Search and replace selection in current file" })
