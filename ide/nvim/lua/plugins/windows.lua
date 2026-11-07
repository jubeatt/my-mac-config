vim.pack.add({
  "https://github.com/nvim-mini/mini.bufremove",
  { src = "https://github.com/smart-splits-nvim/smart-splits.nvim", version = vim.version.range("3.*") },
})

-- Keep windows when deleting buffers, so the split beside nvim-tree survives.
local bufremove = require("mini.bufremove")
bufremove.setup()
vim.keymap.set("n", "<leader>d", bufremove.delete, { desc = "Delete buffer" })
vim.keymap.set("n", "<leader>D", function()
  local current = vim.api.nvim_get_current_buf()
  for _, buf in ipairs(vim.fn.getbufinfo({ buflisted = 1 })) do
    if buf.bufnr ~= current then
      bufremove.delete(buf.bufnr)
    end
  end
end, { desc = "Delete other buffers" })

-- At the outer edge this resizes the surrounding herdr pane instead.
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
