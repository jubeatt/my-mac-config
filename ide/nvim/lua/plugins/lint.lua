vim.pack.add({ "https://github.com/mfussenegger/nvim-lint" })

local lint = require("lint")
for _, filetype in ipairs({
  "javascript", "javascriptreact", "typescript", "typescriptreact",
  "html", "css", "scss", "vue", "json", "jsonc", "yaml",
  "markdown", "mdx", "text", "gitcommit", "lua", "python", "sh", "zsh",
}) do
  lint.linters_by_ft[filetype] = { "cspell" }
end

local function check_spelling(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  if not vim.api.nvim_buf_is_loaded(bufnr) or vim.bo[bufnr].buftype ~= "" then
    return
  end
  local filename = vim.api.nvim_buf_get_name(bufnr)
  if filename == "" then
    return
  end
  vim.api.nvim_buf_call(bufnr, function()
    -- Search for project configuration from the file, even when cwd is elsewhere.
    lint.try_lint(nil, { cwd = vim.fs.dirname(filename) })
  end)
end

vim.api.nvim_create_autocmd({ "BufReadPost", "BufWritePost", "InsertLeave" }, {
  group = vim.api.nvim_create_augroup("cspell-check", { clear = true }),
  callback = function(ev)
    -- FileType detection and other buffer callbacks must finish first.
    vim.schedule(function()
      check_spelling(ev.buf)
    end)
  end,
})
vim.keymap.set("n", "<leader>xs", check_spelling, { desc = "Check spelling" })
