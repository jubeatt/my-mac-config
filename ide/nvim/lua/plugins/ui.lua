vim.pack.add({
  { src = "https://github.com/catppuccin/nvim", name = "catppuccin" },
  "https://github.com/nvim-mini/mini.icons",
  "https://github.com/nvim-lualine/lualine.nvim",
  "https://github.com/folke/which-key.nvim",
})

require("catppuccin").setup({
  flavour = "mocha",
})
vim.cmd.colorscheme("catppuccin")

-- Mocking nvim-web-devicons lets nvim-tree, lualine and fzf-lua pick up mini.icons.
local mini_icons = require("mini.icons")
mini_icons.setup()
mini_icons.mock_nvim_web_devicons()

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

-- Plugin-specific entries are added next to each plugin's setup.
require("which-key").setup({
  -- The marks / registers plugins still open immediately.
  delay = function(ctx)
    return ctx.plugin and 0 or 500
  end,
  -- which-key sizes its popup from this option and ignores winborder, so keep it explicit.
  win = { border = "none" },
  spec = {
    { "<leader>f", group = "Find / file" },
    { "<leader>g", group = "Git", mode = { "n", "x" } },
    { "<leader>c", group = "Code" },
    { "<leader>s", group = "Search", mode = { "n", "x" } },
    { "<leader>t", group = "Test" },
    { "<leader>x", group = "Diagnostics" },
    -- Built-in LSP keymaps (grn, gra, grr, gri, grt…); gra also works in visual mode.
    { "gr", group = "LSP", mode = { "n", "x" } },
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
