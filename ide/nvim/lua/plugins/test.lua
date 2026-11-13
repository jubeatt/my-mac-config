vim.pack.add({ "https://github.com/vim-test/vim-test" })

-- vim-test's built-in toggleterm strategy sends to the last toggled terminal, which
-- could be a running dev server, so pin test runs to terminal 99 (99<C-\> toggles it).
vim.g["test#custom_strategies"] = {
  toggleterm_test = function(cmd)
    require("toggleterm").exec(cmd, 99, nil, nil, nil, "test")
  end,
}
vim.g["test#strategy"] = "toggleterm_test"
-- Playwright claims every *.test / *.spec file once @playwright/test is in
-- package.json, so limit it to e2e/ or playwright/ folders and leave the rest to Vitest / Jest.
vim.g["test#javascript#playwright#file_pattern"] = [[\v(^|/)(e2e|playwright)/.*(spec|test)\.(js|jsx|ts|tsx)$]]
-- vim-test only spots it.each / test.each when the title shares a line with `it.each(`,
-- and passes `%s` through literally. Also match a title on `])('...'` or on its own line,
-- cut before the first placeholder, so -t runs every row of the table.
-- The autoload file assigns the patterns unconditionally, so load it before extending them.
vim.cmd.runtime("autoload/test/javascript.vim")
local js_test_patterns = vim.g["test#javascript#patterns"]
table.insert(js_test_patterns.test, 1, [[\v^\s*%(\]\)\s*\(\s*)?(['"`])\zs[^%'"`]+\ze%(\%[sdifjoO#%]|\$\w)]])
vim.g["test#javascript#patterns"] = js_test_patterns
vim.keymap.set("n", "<leader>tt", "<cmd>TestNearest<cr>", { desc = "Run nearest test" })
vim.keymap.set("n", "<leader>tf", "<cmd>TestFile<cr>", { desc = "Run tests in file" })
vim.keymap.set("n", "<leader>tl", "<cmd>TestLast<cr>", { desc = "Rerun last test" })
-- Playwright only: Vitest rejects these flags.
vim.keymap.set("n", "<leader>th", "<cmd>TestNearest --headed<cr>", { desc = "Run nearest e2e test headed" })
vim.keymap.set("n", "<leader>tu", "<cmd>TestFile --ui<cr>", { desc = "Open e2e file in Playwright UI" })
