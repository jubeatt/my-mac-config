vim.api.nvim_create_autocmd("TextYankPost", {
  group = vim.api.nvim_create_augroup("highlight-yank", { clear = true }),
  callback = function()
    vim.hl.on_yank()
  end,
})

vim.api.nvim_create_autocmd("BufWritePre", {
  group = vim.api.nvim_create_augroup("mkdir-on-save", { clear = true }),
  callback = function(ev)
    if vim.bo[ev.buf].buftype == "" and not ev.match:match("^%w+://") then
      vim.fn.mkdir(vim.fs.dirname(ev.match), "p")
    end
  end,
})

