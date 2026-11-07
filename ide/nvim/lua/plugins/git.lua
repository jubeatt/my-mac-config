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
