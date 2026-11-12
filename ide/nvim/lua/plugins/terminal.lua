vim.pack.add({ "https://github.com/akinsho/toggleterm.nvim" })

require("toggleterm").setup({
  open_mapping = [[<C-\>]],
  size = 15,
  -- Same as insert mode's jk.
  on_create = function(term)
    vim.keymap.set("t", "jk", [[<C-\><C-n>]], { buffer = term.bufnr, desc = "Exit terminal mode" })
  end,
})

local Terminal = require("toggleterm.terminal").Terminal

local lazygit_terminals = {}
-- Called by name from Lazygit's q and edit commands in ide/nvim/lazygit.yml and terminal/lazygit/config.yml.
function _G.LazygitHide()
  for _, term in pairs(lazygit_terminals) do
    if term:is_open() then
      term:close()
      return true
    end
  end
  return false
end
vim.keymap.set("n", "<leader>gg", function()
  if LazygitHide() then
    return
  end
  if vim.fn.executable("lazygit") ~= 1 then
    vim.notify("Install lazygit from the Brewfile first", vim.log.levels.WARN)
    return
  end
  local root = vim.fs.root(0, ".git") or vim.fs.root(vim.fn.getcwd(), ".git")
  if not root then
    vim.notify("Open a file or directory in a Git repository first", vim.log.levels.WARN)
    return
  end
  if not lazygit_terminals[root] then
    local user_config = vim.fs.joinpath(vim.trim(vim.fn.system({ "lazygit", "--print-config-dir" })), "config.yml")
    local nvim_overlay = vim.fs.joinpath(vim.fn.stdpath("config"), "lazygit.yml")
    lazygit_terminals[root] = Terminal:new({
      cmd = "lazygit",
      dir = root,
      direction = "float",
      float_opts = {
        border = "none",
        row = 0,
        col = 0,
        width = function()
          return vim.o.columns
        end,
        height = function()
          return vim.o.lines - vim.o.cmdheight
        end,
      },
      hidden = true,
      env = { LG_CONFIG_FILE = user_config .. "," .. nvim_overlay },
      -- Skip the shared jk mapping, or every j in Lazygit waits for timeoutlen.
      on_create = function() end,
    })
  end
  lazygit_terminals[root]:toggle()
end, { desc = "Toggle Lazygit" })
