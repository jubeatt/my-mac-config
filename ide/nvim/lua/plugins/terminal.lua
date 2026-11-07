vim.pack.add({ "https://github.com/akinsho/toggleterm.nvim" })

require("toggleterm").setup({
  open_mapping = [[<C-\>]],
  size = 15,
  -- Same as insert mode's jk; buffer-local so the Lazygit terminal keeps its own j.
  on_create = function(term)
    vim.keymap.set("t", "jk", [[<C-\><C-n>]], { buffer = term.bufnr, desc = "Exit terminal mode" })
  end,
})
