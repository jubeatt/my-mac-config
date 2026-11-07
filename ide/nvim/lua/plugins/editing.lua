-- vim-abolish's own cr reads the next key itself, which hides it from which-key; the
-- which-key spec below maps each coercion instead. Set before vim.pack.add() loads the plugin.
vim.g.abolish_no_mappings = 1

vim.pack.add({
  "https://github.com/Wansmer/treesj",
  "https://github.com/windwp/nvim-autopairs",
  "https://github.com/windwp/nvim-ts-autotag",
  "https://github.com/folke/flash.nvim",
  "https://github.com/nvim-mini/mini.surround",
  "https://github.com/tpope/vim-abolish",
})

local treesj = require("treesj")
treesj.setup({
  use_default_keymaps = false,
  max_join_length = 1000,
})
vim.keymap.set("n", "<leader>cs", treesj.split, { desc = "Split code block" })
vim.keymap.set("n", "<leader>cj", treesj.join, { desc = "Join code block" })

require("nvim-autopairs").setup()
require("nvim-ts-autotag").setup()

local flash = require("flash")
flash.setup({
  -- Keep native f / t motions.
  modes = { char = { enabled = false } },
})
vim.keymap.set({ "n", "x", "o" }, "s", flash.jump, { desc = "Flash jump" })
vim.keymap.set({ "n", "x", "o" }, "S", flash.treesitter, { desc = "Flash treesitter selection" })

-- gs prefix because Flash owns s.
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

require("which-key").add({
  { "gs", group = "Surround", mode = { "n", "x" } },
  { "gsa", desc = "Add: motion + pair (iw\" / iW\")" },
  { "gsa", desc = "Add: pair around selection (e.g. \")", mode = "x" },
  { "gsd", desc = "Delete: pair around cursor (e.g. ' / \")" },
  { "gsr", desc = "Replace: old + new pair (e.g. '\")" },
  { "gsf", desc = "Find: pair's right edge" },
  { "gsF", desc = "Find: pair's left edge" },
  { "gsh", desc = "Highlight: pair around cursor" },
  { "cr", group = "Coerce case" },
  { "crc", "<Plug>(abolish-coerce-word)c", desc = "camelCase", remap = true },
  { "crp", "<Plug>(abolish-coerce-word)p", desc = "PascalCase", remap = true },
  { "crs", "<Plug>(abolish-coerce-word)s", desc = "snake_case", remap = true },
  { "cru", "<Plug>(abolish-coerce-word)u", desc = "UPPER_CASE", remap = true },
  { "cr-", "<Plug>(abolish-coerce-word)-", desc = "dash-case", remap = true },
  { "cr.", "<Plug>(abolish-coerce-word).", desc = "dot.case", remap = true },
  { "cr<Space>", "<Plug>(abolish-coerce-word)<Space>", desc = "space case", remap = true },
})
