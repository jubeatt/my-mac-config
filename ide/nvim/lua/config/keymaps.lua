vim.keymap.set("i", "jk", "<Esc>", { desc = "Exit insert mode" })
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search highlights" })

vim.keymap.set({ "n", "x" }, "<C-z>", "<Nop>", { desc = "Disable suspend" })

-- Exiting merges jumps back from the project's ShaDa file, so overwrite it right away.
vim.keymap.set("n", "<leader>j", "<cmd>clearjumps | wshada!<cr>", { desc = "Clear jumplist" })

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

local function system_open(path)
  local _, err = vim.ui.open(path)
  if err then
    vim.notify(err, vim.log.levels.ERROR)
  end
end

vim.keymap.set("n", "<leader>fo", function()
  local path = vim.api.nvim_buf_get_name(0)
  if vim.bo.buftype ~= "" or path == "" or vim.fn.filereadable(path) ~= 1 then
    vim.notify("Save the file before opening it in the default app", vim.log.levels.WARN)
    return
  end
  system_open(path)
end, { desc = "Open file in default app" })

vim.keymap.set("n", "<leader>fO", function()
  local path = vim.api.nvim_buf_get_name(0)
  if vim.bo.buftype ~= "" or path == "" then
    vim.notify("Open a file before opening its folder in Finder", vim.log.levels.WARN)
    return
  end
  system_open(vim.fn.fnamemodify(path, ":h"))
end, { desc = "Open current folder in Finder" })

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
