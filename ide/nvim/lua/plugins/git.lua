vim.pack.add({
  "https://github.com/lewis6991/gitsigns.nvim",
  "https://github.com/sindrets/diffview.nvim",
})

require("gitsigns").setup({
  on_attach = function(bufnr)
    local gitsigns = require("gitsigns")

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
    vim.keymap.set("x", "<leader>gr", function()
      gitsigns.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
    end, { buffer = bufnr, desc = "Reset selected lines" })
    vim.keymap.set("n", "<leader>gR", gitsigns.reset_buffer, { buffer = bufnr, desc = "Reset git buffer" })
    vim.keymap.set("n", "<leader>gb", function()
      gitsigns.blame_line({ full = true })
    end, { buffer = bufnr, desc = "Blame line" })
  end,
})

local diffview_actions = require("diffview.actions")
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
  keymaps = {
    view = diffview_keymaps,
    file_panel = diffview_keymaps,
    file_history_panel = diffview_keymaps,
  },
})
vim.keymap.set("n", "<leader>gd", "<cmd>DiffviewOpen<cr>", { desc = "Open git diff view" })
vim.keymap.set("n", "<leader>gh", "<cmd>DiffviewFileHistory %<cr>", { desc = "Current file git history" })
vim.keymap.set("n", "<leader>gH", "<cmd>DiffviewFileHistory<cr>", { desc = "Repository git history" })
vim.keymap.set("n", "<leader>gq", "<cmd>DiffviewClose<cr>", { desc = "Close git diff view" })
